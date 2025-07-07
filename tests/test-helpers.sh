#!/bin/bash

# Test helper functions for dynamic manifest validation
# Provides single source of truth for test data

# Get project root
get_project_root() {
    cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

# Check if jq is available
has_jq() {
    command -v jq >/dev/null 2>&1
}

# Get all components from manifest
get_manifest_components() {
    local manifest="$1"
    if has_jq; then
        jq -r '.components | keys[]' "$manifest" 2>/dev/null
    else
        # Fallback to basic parsing if jq not available
        grep -E '^\s*"[^"]+"\s*:\s*{' "$manifest" | sed 's/.*"\([^"]*\)".*/\1/' | grep -v "components"
    fi
}

# Get files for a specific component
get_component_files() {
    local manifest="$1"
    local component="$2"
    if has_jq; then
        jq -r ".components[\"$component\"].files[]?" "$manifest" 2>/dev/null
    fi
}

# Get all files from manifest
get_all_manifest_files() {
    local manifest="$1"
    if has_jq; then
        jq -r '.components[].files[]' "$manifest" 2>/dev/null | sort | uniq
    fi
}

# Verify component structure
verify_component_structure() {
    local manifest="$1"
    local component="$2"

    if has_jq; then
        # Check component has description
        local desc
        desc=$(jq -r ".components[\"$component\"].description?" "$manifest" 2>/dev/null)
        [[ -n "$desc" && "$desc" != "null" ]] || return 1

        # Check component has files array
        local files
        files=$(jq -r ".components[\"$component\"].files?" "$manifest" 2>/dev/null)
        [[ -n "$files" && "$files" != "null" ]] || return 1
    fi
    return 0
}

# Get manifest version
get_manifest_version() {
    local manifest="$1"
    if has_jq; then
        jq -r '.version' "$manifest" 2>/dev/null
    else
        grep -E '^\s*"version"\s*:' "$manifest" | sed 's/.*"\([0-9.]*\)".*/\1/'
    fi
}

# Select a random file from manifest for testing
get_test_file() {
    local manifest="$1"
    get_all_manifest_files "$manifest" | head -1
}

# Check if all required fields exist in manifest
check_manifest_required_fields() {
    local manifest="$1"
    local errors=0

    if has_jq; then
        # Check version exists
        local version
        version=$(jq -r '.version' "$manifest" 2>/dev/null)
        if [[ -z "$version" || "$version" == "null" ]]; then
            echo "Missing required field: version"
            ((errors++))
        fi

        # Check components exists
        local components
        components=$(jq -r '.components' "$manifest" 2>/dev/null)
        if [[ -z "$components" || "$components" == "null" ]]; then
            echo "Missing required field: components"
            ((errors++))
        fi
    fi

    return $errors
}

# Export functions for use in tests
export -f get_project_root
export -f has_jq
export -f get_manifest_components
export -f get_component_files
export -f get_all_manifest_files
export -f verify_component_structure
export -f get_manifest_version
export -f get_test_file
export -f check_manifest_required_fields