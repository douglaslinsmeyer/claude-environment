#!/bin/bash

# Snippet Manager - Handles injection and removal of configuration snippets
# Supports both settings.json and CLAUDE.md files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print functions
print_success() { echo -e "${GREEN}✓${NC} $1" >&2; }
print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1" >&2; }
print_info() { echo -e "${BLUE}ℹ${NC} $1" >&2; }

# Constants
SNIPPET_MANIFEST=".snippet-manifest.json"
SNIPPET_MARKER_START="__CLAUDE_SNIPPET_START__"
SNIPPET_MARKER_END="__CLAUDE_SNIPPET_END__"

# Get snippet directory based on repository location
get_snippet_dir() {
    local repo_dir="${1:-$(pwd)}"
    echo "$repo_dir/snippets"
}

# Initialize snippet manifest
init_manifest() {
    local target_dir="$1"
    local manifest_path="$target_dir/$SNIPPET_MANIFEST"
    
    if [[ ! -f "$manifest_path" ]]; then
        echo '{"snippets": {}}' > "$manifest_path"
    fi
}

# Read snippet manifest
read_manifest() {
    local target_dir="$1"
    local manifest_path="$target_dir/$SNIPPET_MANIFEST"
    
    if [[ -f "$manifest_path" ]]; then
        cat "$manifest_path"
    else
        echo '{"snippets": {}}'
    fi
}

# Update snippet manifest
update_manifest() {
    local target_dir="$1"
    local snippet_id="$2"
    local snippet_data="$3"
    local manifest_path="$target_dir/$SNIPPET_MANIFEST"
    
    local current_manifest
    current_manifest=$(read_manifest "$target_dir")
    
    # Use jq if available
    if command -v jq >/dev/null 2>&1; then
        echo "$current_manifest" | jq ".snippets[\"$snippet_id\"] = $snippet_data" > "$manifest_path"
    else
        print_error "jq is required for manifest updates"
        return 1
    fi
}

# Remove snippet from manifest
remove_from_manifest() {
    local target_dir="$1"
    local snippet_id="$2"
    local manifest_path="$target_dir/$SNIPPET_MANIFEST"
    
    local current_manifest
    current_manifest=$(read_manifest "$target_dir")
    
    if command -v jq >/dev/null 2>&1; then
        echo "$current_manifest" | jq "del(.snippets[\"$snippet_id\"])" > "$manifest_path"
    else
        print_error "jq is required for manifest updates"
        return 1
    fi
}

# Inject settings.json snippet
inject_settings_snippet() {
    local snippet_file="$1"
    local target_file="$2"
    local dry_run="${3:-false}"
    
    # Read snippet metadata
    local snippet_id snippet_version snippet_settings
    if command -v jq >/dev/null 2>&1; then
        snippet_id=$(jq -r '.snippet_id' "$snippet_file")
        snippet_version=$(jq -r '.snippet_version' "$snippet_file")
        snippet_settings=$(jq -c '.settings' "$snippet_file")
    else
        print_error "jq is required for settings.json snippet injection"
        return 1
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would inject snippet '$snippet_id' v$snippet_version into $target_file"
        return 0
    fi
    
    # Create target file if it doesn't exist
    if [[ ! -f "$target_file" ]]; then
        echo '{}' > "$target_file"
    fi
    
    # Create backup
    cp "$target_file" "$target_file.backup"
    
    # Read current settings
    local current_settings
    current_settings=$(cat "$target_file")
    
    # Create snippet marker comment
    local marker_comment="\"_snippet_$snippet_id\": {\"version\": \"$snippet_version\", \"id\": \"$snippet_id\"}"
    
    # Merge settings
    local merged_settings
    merged_settings=$(echo "$current_settings" | jq ". + $snippet_settings + {$marker_comment}")
    
    # Write merged settings
    echo "$merged_settings" | jq '.' > "$target_file"
    
    print_success "Injected snippet '$snippet_id' v$snippet_version into $target_file"
    
    # Update manifest
    local target_dir
    target_dir=$(dirname "$target_file")
    update_manifest "$target_dir" "$snippet_id" "{\"type\": \"settings\", \"version\": \"$snippet_version\", \"file\": \"$(basename "$target_file")\"}"
}

# Inject CLAUDE.md snippet
inject_claude_snippet() {
    local snippet_file="$1"
    local target_file="$2"
    local dry_run="${3:-false}"
    
    # Extract snippet metadata from file
    local snippet_id snippet_version
    snippet_id=$(grep -o 'SNIPPET_START: [^ ]* ' "$snippet_file" | awk '{print $2}')
    snippet_version=$(grep -o 'SNIPPET_START: [^ ]* [^ ]*' "$snippet_file" | awk '{print $3}')
    
    if [[ -z "$snippet_id" ]]; then
        print_error "Invalid CLAUDE.md snippet format in $snippet_file"
        return 1
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would inject snippet '$snippet_id' v$snippet_version into $target_file"
        return 0
    fi
    
    # Create target file if it doesn't exist
    if [[ ! -f "$target_file" ]]; then
        touch "$target_file"
    fi
    
    # Check if snippet already exists
    if grep -q "SNIPPET_START: $snippet_id" "$target_file"; then
        print_warning "Snippet '$snippet_id' already exists in $target_file, updating..."
        remove_claude_snippet "$snippet_id" "$target_file"
    fi
    
    # Create backup
    cp "$target_file" "$target_file.backup"
    
    # Append snippet to file
    echo "" >> "$target_file"
    cat "$snippet_file" >> "$target_file"
    echo "" >> "$target_file"
    
    print_success "Injected snippet '$snippet_id' v$snippet_version into $target_file"
    
    # Update manifest
    local target_dir
    target_dir=$(dirname "$target_file")
    update_manifest "$target_dir" "$snippet_id" "{\"type\": \"claude\", \"version\": \"$snippet_version\", \"file\": \"$(basename "$target_file")\"}"
}

# Remove settings.json snippet
remove_settings_snippet() {
    local snippet_id="$1"
    local target_file="$2"
    
    if [[ ! -f "$target_file" ]]; then
        print_warning "Target file $target_file does not exist"
        return 0
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        print_error "jq is required for settings.json snippet removal"
        return 1
    fi
    
    # Create backup
    cp "$target_file" "$target_file.backup"
    
    # Get all keys associated with the snippet
    local snippet_marker="_snippet_$snippet_id"
    local current_settings snippet_data
    current_settings=$(cat "$target_file")
    
    # Check if snippet exists
    if ! echo "$current_settings" | jq -e ".\"$snippet_marker\"" >/dev/null 2>&1; then
        print_warning "Snippet '$snippet_id' not found in $target_file"
        return 0
    fi
    
    # Read original snippet to know what keys to remove
    local snippet_dir target_dir
    target_dir=$(dirname "$target_file")
    snippet_dir=$(get_snippet_dir)
    local snippet_file="$snippet_dir/settings/$snippet_id.json"
    
    if [[ -f "$snippet_file" ]]; then
        # Get keys from original snippet
        local keys_to_remove
        keys_to_remove=$(jq -r '.settings | keys[]' "$snippet_file" 2>/dev/null || echo "")
        
        # Remove snippet keys and marker
        local jq_filter="del(.\"$snippet_marker\")"
        for key in $keys_to_remove; do
            jq_filter="$jq_filter | del(.\"$key\")"
        done
        
        echo "$current_settings" | jq "$jq_filter" > "$target_file"
    else
        # Just remove the marker
        echo "$current_settings" | jq "del(.\"$snippet_marker\")" > "$target_file"
    fi
    
    print_success "Removed snippet '$snippet_id' from $target_file"
    
    # Update manifest
    remove_from_manifest "$target_dir" "$snippet_id"
}

# Remove CLAUDE.md snippet
remove_claude_snippet() {
    local snippet_id="$1"
    local target_file="$2"
    
    if [[ ! -f "$target_file" ]]; then
        print_warning "Target file $target_file does not exist"
        return 0
    fi
    
    # Create backup
    cp "$target_file" "$target_file.backup"
    
    # Remove snippet using sed
    sed -i.tmp "/<!-- SNIPPET_START: $snippet_id/,/<!-- SNIPPET_END: $snippet_id -->/d" "$target_file"
    rm -f "$target_file.tmp"
    
    print_success "Removed snippet '$snippet_id' from $target_file"
    
    # Update manifest
    local target_dir
    target_dir=$(dirname "$target_file")
    remove_from_manifest "$target_dir" "$snippet_id"
}

# List installed snippets
list_snippets() {
    local target_dir="$1"
    local manifest
    manifest=$(read_manifest "$target_dir")
    
    if command -v jq >/dev/null 2>&1; then
        echo "$manifest" | jq -r '.snippets | to_entries[] | "\(.key) (v\(.value.version)) - \(.value.type) in \(.value.file)"'
    else
        print_warning "jq is required to list snippets properly"
    fi
}

# Main function
main() {
    local action="$1"
    local snippet_path="$2"
    local target_path="$3"
    local dry_run="${4:-false}"
    
    case "$action" in
        inject)
            if [[ -z "$snippet_path" || -z "$target_path" ]]; then
                print_error "Usage: $0 inject <snippet_path> <target_path> [--dry-run]"
                exit 1
            fi
            
            # Initialize manifest in target directory
            local target_dir
            target_dir=$(dirname "$target_path")
            init_manifest "$target_dir"
            
            # Determine snippet type and inject
            if [[ "$snippet_path" == *.json ]]; then
                inject_settings_snippet "$snippet_path" "$target_path" "$dry_run"
            elif [[ "$snippet_path" == *.md ]]; then
                inject_claude_snippet "$snippet_path" "$target_path" "$dry_run"
            else
                print_error "Unknown snippet type for $snippet_path"
                exit 1
            fi
            ;;
            
        remove)
            local snippet_id="$2"
            local target_file="$3"
            
            if [[ -z "$snippet_id" || -z "$target_file" ]]; then
                print_error "Usage: $0 remove <snippet_id> <target_file>"
                exit 1
            fi
            
            # Determine file type and remove
            if [[ "$target_file" == *.json ]]; then
                remove_settings_snippet "$snippet_id" "$target_file"
            elif [[ "$target_file" == *.md ]]; then
                remove_claude_snippet "$snippet_id" "$target_file"
            else
                print_error "Unknown target file type for $target_file"
                exit 1
            fi
            ;;
            
        list)
            local target_dir="${2:-.}"
            list_snippets "$target_dir"
            ;;
            
        *)
            print_error "Unknown action: $action"
            echo "Usage: $0 {inject|remove|list} ..." >&2
            exit 1
            ;;
    esac
}

# Run if not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi