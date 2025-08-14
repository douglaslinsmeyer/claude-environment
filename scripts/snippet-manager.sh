#!/bin/bash

# Snippet Manager - Handles injection and removal of configuration snippets
# One snippet per target file approach

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
MANIFEST_FILE=".claude-environment-manifest.json"

# Read manifest
read_manifest() {
    local target_dir="$1"
    local manifest_path="$target_dir/$MANIFEST_FILE"
    
    if [[ -f "$manifest_path" ]]; then
        cat "$manifest_path"
    else
        # Return empty structure if no manifest exists
        echo '{"_meta":{"manifest_version":"1.0"},"installation":{},"snippets":{"injected":{}}}'
    fi
}

# Update manifest with snippet info
update_manifest() {
    local target_dir="$1"
    local target_file="$2"
    local action="$3"  # "inject" or "remove"
    local manifest_path="$target_dir/$MANIFEST_FILE"
    
    local current_manifest
    current_manifest=$(read_manifest "$target_dir")
    
    if ! command -v jq >/dev/null 2>&1; then
        print_error "jq is required for manifest updates"
        return 1
    fi
    
    local filename
    filename=$(basename "$target_file")
    
    if [[ "$action" == "inject" ]]; then
        # Add snippet info
        local snippet_type="settings"
        [[ "$filename" == "CLAUDE.md" ]] && snippet_type="claude"
        
        # Get version from snippet
        local version="2.5.0"  # Default version, could extract from file
        
        current_manifest=$(echo "$current_manifest" | jq \
            --arg file "$filename" \
            --arg type "$snippet_type" \
            --arg version "$version" \
            '.snippets.injected[$file] = {"type": $type, "version": $version, "target_file": $file}')
    elif [[ "$action" == "remove" ]]; then
        # Remove snippet info
        current_manifest=$(echo "$current_manifest" | jq \
            --arg file "$filename" \
            'del(.snippets.injected[$file])')
    fi
    
    # Write atomically
    echo "$current_manifest" | jq '.' > "$manifest_path.tmp"
    mv "$manifest_path.tmp" "$manifest_path"
}

# Inject settings.json snippet
inject_settings_snippet() {
    local snippet_file="$1"
    local target_file="$2"
    local dry_run="${3:-false}"
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would inject settings snippet into $target_file"
        return 0
    fi
    
    # Create target file if it doesn't exist
    if [[ ! -f "$target_file" ]]; then
        echo '{}' > "$target_file"
    fi
    
    # Create backup
    cp "$target_file" "$target_file.backup"
    
    # Read current settings and snippet
    local current_settings snippet_settings
    current_settings=$(cat "$target_file")
    snippet_settings=$(cat "$snippet_file")
    
    # Merge settings
    local merged_settings
    if command -v jq >/dev/null 2>&1; then
        merged_settings=$(echo "$current_settings" | jq ". + $snippet_settings")
        echo "$merged_settings" | jq '.' > "$target_file"
    else
        print_error "jq is required for JSON merging"
        return 1
    fi
    
    print_success "Injected settings snippet into $target_file"
    
    # Update manifest
    local target_dir
    target_dir=$(dirname "$target_file")
    update_manifest "$target_dir" "$target_file" "inject"
}

# Inject CLAUDE.md snippet
inject_claude_snippet() {
    local snippet_file="$1"
    local target_file="$2"
    local dry_run="${3:-false}"
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would inject CLAUDE.md snippet into $target_file"
        return 0
    fi
    
    # Create target file if it doesn't exist
    if [[ ! -f "$target_file" ]]; then
        touch "$target_file"
    fi
    
    # Check if snippet already exists
    if grep -q "CLAUDE-ENV-START" "$target_file"; then
        print_warning "Snippet already exists in $target_file, updating..."
        remove_claude_snippet "$target_file"
    fi
    
    # Create backup
    cp "$target_file" "$target_file.backup"
    
    # Append snippet to file
    {
        echo ""
        cat "$snippet_file"
        echo ""
    } >> "$target_file"
    
    print_success "Injected CLAUDE.md snippet into $target_file"
    
    # Update manifest
    local target_dir
    target_dir=$(dirname "$target_file")
    update_manifest "$target_dir" "$target_file" "inject"
}

# Remove settings.json snippet
remove_settings_snippet() {
    local target_file="$1"
    
    if [[ ! -f "$target_file" ]]; then
        print_warning "Target file $target_file does not exist"
        return 0
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        print_error "jq is required for settings removal"
        return 1
    fi
    
    # Create backup
    cp "$target_file" "$target_file.backup"
    
    # Remove claude-environment key
    local current_settings
    current_settings=$(cat "$target_file")
    echo "$current_settings" | jq 'del(."claude-environment")' > "$target_file"
    
    print_success "Removed settings snippet from $target_file"
    
    # Update manifest
    local target_dir
    target_dir=$(dirname "$target_file")
    update_manifest "$target_dir" "$target_file" "remove"
}

# Remove CLAUDE.md snippet
remove_claude_snippet() {
    local target_file="$1"
    
    if [[ ! -f "$target_file" ]]; then
        print_warning "Target file $target_file does not exist"
        return 0
    fi
    
    # Create backup
    cp "$target_file" "$target_file.backup"
    
    # Remove snippet using sed - everything between markers
    sed -i.tmp '/<!-- CLAUDE-ENV-START/,/<!-- CLAUDE-ENV-END -->/d' "$target_file"
    rm -f "$target_file.tmp"
    
    # Remove any trailing blank lines
    sed -i.tmp -e :a -e '/^\s*$/d;N;ba' "$target_file"
    rm -f "$target_file.tmp"
    
    print_success "Removed CLAUDE.md snippet from $target_file"
    
    # Update manifest
    local target_dir
    target_dir=$(dirname "$target_file")
    update_manifest "$target_dir" "$target_file" "remove"
}

# List installed snippets
list_snippets() {
    local target_dir="$1"
    local manifest
    manifest=$(read_manifest "$target_dir")
    
    if command -v jq >/dev/null 2>&1; then
        local snippets
        snippets=$(echo "$manifest" | jq -r '.snippets.injected | to_entries[] | "\(.key) (v\(.value.version)) - \(.value.type)"')
        if [[ -z "$snippets" ]]; then
            print_info "No snippets installed"
        else
            echo "$snippets"
        fi
    else
        print_warning "jq is required to list snippets"
    fi
}

# Main function
main() {
    local action="$1"
    local snippet_file="$2"
    local target_file="$3"
    local dry_run="${4:-false}"
    
    case "$action" in
        inject)
            if [[ -z "$snippet_file" || -z "$target_file" ]]; then
                print_error "Usage: $0 inject <snippet_file> <target_file> [--dry-run]"
                exit 1
            fi
            
            # Determine snippet type and inject
            local target_basename
            target_basename=$(basename "$target_file")
            
            case "$target_basename" in
                settings.json)
                    inject_settings_snippet "$snippet_file" "$target_file" "$dry_run"
                    ;;
                CLAUDE.md)
                    inject_claude_snippet "$snippet_file" "$target_file" "$dry_run"
                    ;;
                *)
                    print_error "Unknown target file type: $target_basename"
                    exit 1
                    ;;
            esac
            ;;
            
        remove)
            # For remove, target_file is actually in $2
            target_file="$2"
            if [[ -z "$target_file" ]]; then
                print_error "Usage: $0 remove <target_file>"
                exit 1
            fi
            
            # Determine file type and remove
            local target_basename
            target_basename=$(basename "$target_file")
            
            case "$target_basename" in
                settings.json)
                    remove_settings_snippet "$target_file"
                    ;;
                CLAUDE.md)
                    remove_claude_snippet "$target_file"
                    ;;
                *)
                    print_error "Unknown target file type: $target_basename"
                    exit 1
                    ;;
            esac
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