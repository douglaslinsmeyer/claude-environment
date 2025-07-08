#!/bin/bash

# Generate manifest.json from manifest-source.json
# This script expands glob patterns and creates the final manifest used by install.sh

set -e  # Exit on any error

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_MANIFEST="$ROOT_DIR/manifest-source.json"
OUTPUT_MANIFEST="$ROOT_DIR/manifest.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Options
VERBOSE=false
DRY_RUN=false

# Error and warning tracking
ERRORS=()
WARNINGS=()

# Print functions
print_success() { echo -e "${GREEN}✓${NC} $1" >&2; }
print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1" >&2; }
print_info() { echo -e "${BLUE}ℹ${NC} $1" >&2; }
print_verbose() { 
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "  $1" >&2
    fi
}

# Show usage
show_usage() {
    cat << EOF >&2
Generate manifest.json from manifest-source.json

USAGE:
    ./scripts/generate-manifest.sh [OPTIONS]

OPTIONS:
    --verbose     Show detailed output
    --dry-run     Show what would be generated without writing
    --help        Show this help message

DESCRIPTION:
    This script reads manifest-source.json which contains glob patterns,
    expands them to actual file lists, and generates manifest.json with
    the complete file listing used by install.sh.

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose)
                VERBOSE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Check dependencies
check_dependencies() {
    if ! command -v jq >/dev/null 2>&1; then
        print_error "jq is required but not installed"
        print_info "Install jq: https://stedolan.github.io/jq/download/"
        exit 1
    fi
    
    if [[ ! -f "$SOURCE_MANIFEST" ]]; then
        print_error "Source manifest not found: $SOURCE_MANIFEST"
        exit 1
    fi
}

# Add error/warning
report_error() {
    local component=$1
    local message=$2
    ERRORS+=("[$component] $message")
    print_error "[$component] $message"
}

report_warning() {
    local component=$1
    local message=$2
    WARNINGS+=("[$component] $message")
    print_warning "[$component] $message"
}

# Expand glob patterns for a component
expand_component_files() {
    local component=$1
    local -a include_patterns=()
    local -a exclude_patterns=()
    local -a all_files=()
    local -a final_files=()
    
    # Change to root directory for consistent paths
    cd "$ROOT_DIR"
    
    # Read patterns from manifest
    local patterns_json
    patterns_json=$(jq -r ".components.\"$component\".files[]?" "$SOURCE_MANIFEST" 2>/dev/null)
    
    if [[ -z "$patterns_json" ]]; then
        report_error "$component" "No file patterns defined"
        return 1
    fi
    
    # Separate inclusion and exclusion patterns
    while IFS= read -r pattern; do
        if [[ "$pattern" =~ ^! ]]; then
            # Remove the ! prefix for exclusion patterns
            exclude_patterns+=("${pattern:1}")
            print_verbose "Exclude pattern: ${pattern:1}"
        else
            include_patterns+=("$pattern")
            print_verbose "Include pattern: $pattern"
        fi
    done <<< "$patterns_json"
    
    # Expand inclusion patterns
    for pattern in "${include_patterns[@]}"; do
        # Remove leading ./ if present for cleaner paths
        pattern="${pattern#./}"
        
        # Use find to expand the pattern
        while IFS= read -r -d '' file; do
            # Store relative path without leading ./
            file="${file#./}"
            all_files+=("$file")
            print_verbose "Found: $file"
        done < <(find . -type f -path "./$pattern" -print0 2>/dev/null)
    done
    
    # Remove duplicates
    # Remove duplicates and sort
    local sorted_files=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && sorted_files+=("$file")
    done < <(printf '%s\n' "${all_files[@]}" | LC_ALL=C sort -u)
    all_files=("${sorted_files[@]}")
    
    # Apply exclusion patterns
    for file in "${all_files[@]}"; do
        local excluded=false
        
        for exclude in "${exclude_patterns[@]}"; do
            # Remove leading ./ from exclude pattern
            exclude="${exclude#./}"
            
            # Check if file matches exclusion pattern
            if [[ "./$file" == "./$exclude" ]] || [[ "$file" == "$exclude" ]]; then
                excluded=true
                print_verbose "Excluded by pattern: $file (matches $exclude)"
                break
            fi
            
            # Check glob-style matching
            case "./$file" in
                "./$exclude")
                    excluded=true
                    print_verbose "Excluded by glob: $file (matches $exclude)"
                    break
                    ;;
            esac
        done
        
        if [[ "$excluded" == "false" ]]; then
            final_files+=("$file")
        fi
    done
    
    # Sort files for deterministic output
    printf '%s\n' "${final_files[@]}" | LC_ALL=C sort
}

# Apply special mappings to files
apply_special_mappings() {
    local component=$1
    shift
    local -a files=("$@")
    local -a mapped_files=()
    
    # Get special mappings for this component
    local mappings
    mappings=$(jq -r ".components.\"$component\".special_mappings // {}" "$SOURCE_MANIFEST")
    
    for file in "${files[@]}"; do
        # Check if this file has a special mapping
        local mapped
        mapped=$(echo "$mappings" | jq -r ".\"$file\" // empty")
        
        if [[ -n "$mapped" ]]; then
            mapped_files+=("$mapped")
            print_verbose "Mapping: $file -> $mapped"
        else
            mapped_files+=("$file")
        fi
    done
    
    printf '%s\n' "${mapped_files[@]}"
}

# Process a single component
process_component() {
    local component=$1
    local description
    description=$(jq -r ".components.\"$component\".description" "$SOURCE_MANIFEST")
    
    print_info "Processing component: $component"
    
    # Expand files
    local -a files=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && files+=("$file")
    done < <(expand_component_files "$component")
    
    if [[ ${#files[@]} -eq 0 ]]; then
        report_warning "$component" "No files found matching patterns"
    else
        print_success "$component: ${#files[@]} files found"
    fi
    
    # Apply special mappings
    local -a mapped_files=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && mapped_files+=("$file")
    done < <(apply_special_mappings "$component" "${files[@]}")
    
    # Return JSON for this component
    local files_json
    files_json=$(printf '%s\n' "${mapped_files[@]}" | jq -R . | jq -s .)
    
    jq -n \
        --arg desc "$description" \
        --argjson files "$files_json" \
        '{description: $desc, files: $files}'
}

# Generate the complete manifest
generate_manifest() {
    # Read version from VERSION file
    local version_file="$ROOT_DIR/VERSION"
    if [[ ! -f "$version_file" ]]; then
        report_error "manifest" "VERSION file not found: $version_file"
        exit 1
    fi
    local version
    version=$(tr -d '[:space:]' < "$version_file")
    
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local source_hash
    source_hash=$(shasum -a 256 "$SOURCE_MANIFEST" | cut -d' ' -f1)
    
    print_info "Generating manifest version $version"
    
    # Process each component
    local components_json="{}"
    
    for component in $(jq -r '.components | keys[]' "$SOURCE_MANIFEST" | LC_ALL=C sort); do
        local component_json
        component_json=$(process_component "$component")
        components_json=$(echo "$components_json" | jq --arg key "$component" --argjson value "$component_json" '.[$key] = $value')
    done
    
    # Build final manifest with metadata
    jq -n \
        --arg version "$version" \
        --arg timestamp "$timestamp" \
        --arg source "manifest-source.json" \
        --arg hash "$source_hash" \
        --argjson components "$components_json" \
        '{
            version: $version,
            _generated: {
                timestamp: $timestamp,
                source: $source,
                source_hash: $hash
            },
            components: $components
        }' | jq --sort-keys '.'
}

# Validate results
validate_results() {
    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        echo >&2
        print_error "Manifest generation failed with ${#ERRORS[@]} error(s)"
        exit 1
    fi
    
    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo >&2
        print_warning "Completed with ${#WARNINGS[@]} warning(s)"
    fi
}

# Main function
main() {
    parse_args "$@"
    
    print_info "Manifest Generator"
    
    check_dependencies
    
    # Generate the manifest
    local manifest_json
    manifest_json=$(generate_manifest)
    
    # Validate results
    validate_results
    
    # Output or save
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Generated manifest (dry run):"
        echo "$manifest_json"
    else
        echo "$manifest_json" > "$OUTPUT_MANIFEST"
        print_success "Manifest written to: $OUTPUT_MANIFEST"
        
        # Show summary
        local total_files
        total_files=$(echo "$manifest_json" | jq '[.components[].files | length] | add')
        print_info "Total files in manifest: $total_files"
    fi
}

# Run main function
main "$@"