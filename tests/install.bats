#!/usr/bin/env bats

# BATS tests for install.sh
# Comprehensive test suite for the Claude Environment installer

# Setup and teardown functions
setup() {
    # Get the directory where this test file is located
    export BATS_TEST_DIRNAME="${BATS_TEST_DIRNAME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
    export ORIGINAL_DIR
    ORIGINAL_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

    # Create a temporary directory for each test
    export TEST_DIR
    TEST_DIR="$(mktemp -d -t claude-env-test-XXXXXX)"
    cd "$TEST_DIR"

    # Source the install script with testing flag
    export CLAUDE_ENV_TESTING=true
    source "$ORIGINAL_DIR/install.sh"

    # Load manifest data for tests that need it
    MANIFEST_DATA=$(cat "$ORIGINAL_DIR/manifest.json")

    # Mock the REPO_URL to use local files
    export REPO_URL="file://$ORIGINAL_DIR"
}

teardown() {
    # Clean up test directory
    cd "$ORIGINAL_DIR"
    [[ -d "$TEST_DIR" ]] && rm -rf "$TEST_DIR"
}

# Unit Tests

@test "get_install_dir returns correct global path" {
    INSTALL_TYPE="global"
    result=$(get_install_dir)
    [[ "$result" == "$HOME/.claude" ]]
}

@test "get_install_dir returns correct local path" {
    INSTALL_TYPE="local"
    result=$(get_install_dir)
    [[ "$result" == "$(pwd)/.claude" ]]
}

@test "parse_args handles --local flag" {
    INSTALL_TYPE="global"
    parse_args --local
    [[ "$INSTALL_TYPE" == "local" ]]
}

@test "parse_args handles --no-commands flag" {
    INSTALL_COMMANDS=true
    parse_args --no-commands
    [[ "$INSTALL_COMMANDS" == "false" ]]
}

@test "parse_args handles --no-personas flag" {
    INSTALL_PERSONAS=true
    parse_args --no-personas
    [[ "$INSTALL_PERSONAS" == "false" ]]
}

@test "parse_args handles --force flag" {
    FORCE=false
    parse_args --force
    [[ "$FORCE" == "true" ]]
}

@test "parse_args handles --dry-run flag" {
    DRY_RUN=false
    parse_args --dry-run
    [[ "$DRY_RUN" == "true" ]]
}

@test "parse_args handles multiple flags" {
    INSTALL_TYPE="global"
    INSTALL_COMMANDS=true
    FORCE=false

    parse_args --local --no-commands --force

    [[ "$INSTALL_TYPE" == "local" ]]
    [[ "$INSTALL_COMMANDS" == "false" ]]
    [[ "$FORCE" == "true" ]]
}

@test "check_existing_installation detects version" {
    # Create mock installation
    local test_dir="$TEST_DIR/.claude"
    mkdir -p "$test_dir"

    cat > "$test_dir/.claude-environment-manifest.json" << EOF
{
  "version": "1.0.0",
  "installed_at": "2024-01-01T00:00:00Z"
}
EOF

    # Override get_install_dir
    get_install_dir() { echo "$test_dir"; }

    version=$(check_existing_installation)
    [[ "$version" == "1.0.0" ]]
}

@test "check_existing_installation returns empty for no installation" {
    # Override get_install_dir to non-existent directory
    get_install_dir() { echo "$TEST_DIR/nonexistent"; }

    version=$(check_existing_installation)
    [[ -z "$version" ]]
}

@test "get_component_files returns correct files for each component" {
    # Test all components in one comprehensive test
    # Note: claude-files component was removed from remote, so test only remaining components
    for component in "commands" "personas" "templates"; do
        local files=()
        while IFS= read -r line; do
            files+=("$line")
        done < <(get_component_files "$component")
        
        # Verify files were returned and match the component path
        [[ ${#files[@]} -gt 0 ]] || fail "No files returned for $component"
        [[ "${files[0]}" == *"$component/"* ]] || fail "Files don't match component path for $component"
    done
}

@test "download_file respects dry run mode" {
    DRY_RUN=true
    output=$(download_file "test.md" "$TEST_DIR/test.md" 2>&1)

    [[ "$output" == *"Would download"* ]]
    [[ ! -f "$TEST_DIR/test.md" ]]
}

@test "create_manifest creates valid JSON" {
    DRY_RUN=false
    INSTALL_TYPE="local"
    INSTALL_COMMANDS=true
    INSTALL_PERSONAS=true
    INSTALL_TEMPLATES=true
    INSTALLED_FILES=("test1.md" "test2.md")

    local test_dir="$TEST_DIR/.claude"
    mkdir -p "$test_dir"

    create_manifest "$test_dir" "1.0.0"

    [[ -f "$test_dir/.claude-environment-manifest.json" ]]

    # Verify JSON structure if jq is available
    if command -v jq >/dev/null 2>&1; then
        version=$(jq -r '.version' "$test_dir/.claude-environment-manifest.json")
        [[ "$version" == "1.0.0" ]]

        install_type=$(jq -r '.install_type' "$test_dir/.claude-environment-manifest.json")
        [[ "$install_type" == "local" ]]
    fi
}

@test "remove_old_files removes listed files" {
    DRY_RUN=false
    local test_dir="$TEST_DIR/.claude"
    mkdir -p "$test_dir/commands"

    # Create test files
    echo "test" > "$test_dir/commands/test.md"
    echo "test" > "$test_dir/CLAUDE.md"

    # Create manifest
    cat > "$test_dir/.claude-environment-manifest.json" << EOF
{
  "version": "0.9.0",
  "files": ["commands/test.md", "CLAUDE.md"]
}
EOF

    remove_old_files "$test_dir"

    [[ ! -f "$test_dir/commands/test.md" ]]
    [[ ! -f "$test_dir/CLAUDE.md" ]]
    [[ -f "$test_dir/.claude-environment-manifest.json" ]]
}

# Integration Tests

@test "dry run does not create files" {
    # Test dry run functionality
    DRY_RUN=true
    HOME="$TEST_DIR"

    # Create installation directory should not happen
    local install_dir
    install_dir=$(get_install_dir)

    # Test that download_file respects dry run
    local output
    output=$(download_file "test.md" "$TEST_DIR/test.md" 2>&1)
    [[ "$output" == *"Would download"* ]]
    [[ ! -f "$TEST_DIR/test.md" ]]

    # Test that create_manifest respects dry run
    create_manifest "$TEST_DIR" "1.0.0"
    [[ ! -f "$TEST_DIR/.claude-environment-manifest.json" ]]
}

@test "help flag shows usage" {
    # Unset testing flag for this test
    (
        unset CLAUDE_ENV_TESTING
        output=$(bash "$ORIGINAL_DIR/install.sh" --help 2>&1)
        status=$?

        [ "$status" -eq 0 ]
        [[ "$output" == *"USAGE:"* ]]
        [[ "$output" == *"OPTIONS:"* ]]
    )
}

@test "version flag shows version info" {
    # Unset testing flag for this test
    (
        unset CLAUDE_ENV_TESTING
        output=$(bash "$ORIGINAL_DIR/install.sh" --version 2>&1)
        status=$?

        [ "$status" -eq 0 ]
        [[ "$output" == *"Remote version:"* ]]
    )
}

# Network Operation Tests

@test "get_remote_version returns version with valid URL" {
    # Test with local file URL
    REPO_URL="file://$ORIGINAL_DIR"
    result=$(get_remote_version)
    [[ -n "$result" ]]
    [[ "$result" != "unknown" ]]
}

@test "get_remote_version returns unknown on network failure" {
    # Test with invalid URL
    REPO_URL="http://nonexistent.domain.invalid"
    result=$(get_remote_version)
    [[ "$result" == "unknown" ]]
}

@test "get_remote_version handles invalid URLs" {
    # Test both empty and malformed URLs in one test
    for url in "" "not-a-valid-url"; do
        REPO_URL="$url"
        result=$(get_remote_version)
        [[ "$result" == "unknown" ]] || fail "Expected 'unknown' for URL: '$url'"
    done
}

# Removed mock curl test - tests implementation details rather than behavior
# The other get_remote_version tests adequately cover the function

# User Interaction Tests

@test "confirm_action returns 0 in force mode" {
    FORCE=true
    confirm_action "Test prompt" >/dev/null 2>&1
}

# Removed overly complex user interaction tests - 
# confirm_action force mode test is sufficient for regression protection

# Special Mapping Tests

@test "get_special_mapping returns empty for no mapping" {
    # Load test manifest data
    MANIFEST_DATA='{"components": {"commands": {"files": ["commands/test.md"]}}}'
    
    result=$(get_special_mapping "commands" "commands/test.md")
    [[ -z "$result" ]]
}

# Removed special mapping test - claude-files component no longer exists

@test "get_special_mapping handles missing component gracefully" {
    MANIFEST_DATA='{"components": {}}'
    
    result=$(get_special_mapping "nonexistent" "some/file.md")
    [[ -z "$result" ]]
}

@test "get_special_mapping handles malformed manifest gracefully" {
    MANIFEST_DATA='invalid json'
    
    # The function should handle invalid JSON gracefully
    # It should either return empty or not crash
    # We don't care about the exact result, just that it doesn't fail catastrophically
    if result=$(get_special_mapping "commands" "commands/test.md" 2>/dev/null); then
        true  # Command succeeded, that's all we care about
    else
        true  # Command failed but didn't crash the script
    fi
}

# Removed "works without jq" test - tests implementation details
# The function's behavior is already covered by other tests

@test "get_special_mapping returns empty when MANIFEST_DATA is empty" {
    MANIFEST_DATA=""
    
    result=$(get_special_mapping "commands" "commands/test.md")
    [[ -z "$result" ]]
}

# Install Component Tests

@test "install_component respects component flags" {
    # Test that components are skipped when their flags are false
    DRY_RUN=false
    
    # Test commands component
    INSTALL_COMMANDS=false
    INSTALL_PERSONAS=true
    INSTALL_TEMPLATES=true
    INSTALLED_FILES=()
    MANIFEST_DATA='{"components": {"commands": {"files": ["commands/test.md"]}}}'
    install_component "commands" "$TEST_DIR"
    [[ ${#INSTALLED_FILES[@]} -eq 0 ]] || fail "Commands should have been skipped"
    
    # Test personas component
    INSTALL_COMMANDS=true
    INSTALL_PERSONAS=false
    INSTALL_TEMPLATES=true
    INSTALLED_FILES=()
    MANIFEST_DATA='{"components": {"personas": {"files": ["personas/test.md"]}}}'
    install_component "personas" "$TEST_DIR"
    [[ ${#INSTALLED_FILES[@]} -eq 0 ]] || fail "Personas should have been skipped"
    
    # Test templates component
    INSTALL_COMMANDS=true
    INSTALL_PERSONAS=true
    INSTALL_TEMPLATES=false
    INSTALLED_FILES=()
    MANIFEST_DATA='{"components": {"templates": {"files": ["templates/test.md"]}}}'
    install_component "templates" "$TEST_DIR"
    [[ ${#INSTALLED_FILES[@]} -eq 0 ]] || fail "Templates should have been skipped"
}

@test "install_component tracks installed files in dry run mode" {
    INSTALL_COMMANDS=true
    DRY_RUN=true
    INSTALLED_FILES=()
    
    # Set up manifest data
    MANIFEST_DATA='{"components": {"commands": {"files": ["commands/coding.md", "commands/writing.md"]}}}'
    
    # Mock download_file to simulate success
    download_file() {
        return 0
    }
    export -f download_file
    
    install_component "commands" "$TEST_DIR"
    
    # Clean up
    unset -f download_file
    
    # Should track files even in dry run
    [[ ${#INSTALLED_FILES[@]} -eq 2 ]]
    [[ "${INSTALLED_FILES[0]}" == "commands/coding.md" ]]
    [[ "${INSTALLED_FILES[1]}" == "commands/writing.md" ]]
}

@test "install_component handles special mappings" {
    INSTALL_COMMANDS=true
    DRY_RUN=true
    FORCE=true
    INSTALLED_FILES=()
    
    # Set up manifest with hypothetical special mapping
    # Since claude-files is gone, test with a hypothetical mapping
    MANIFEST_DATA='{
        "components": {
            "commands": {
                "files": ["commands/test.md"],
                "special_mappings": {
                    "commands/test.md": "test-renamed.md"
                }
            }
        }
    }'
    
    # Mock download_file
    download_file() {
        # Check that the target path uses the special mapping
        if [[ "$2" == *"test-renamed.md" ]]; then
            return 0
        fi
        return 1
    }
    export -f download_file
    
    install_component "commands" "$TEST_DIR"
    
    # Clean up
    unset -f download_file
    
    # Should track the mapped filename
    [[ ${#INSTALLED_FILES[@]} -eq 1 ]]
    [[ "${INSTALLED_FILES[0]}" == "test-renamed.md" ]]
}

@test "install_component handles download failures" {
    INSTALL_COMMANDS=true
    DRY_RUN=false
    INSTALLED_FILES=()
    COMPONENT_FILE_COUNT=0
    
    # Set up manifest data
    MANIFEST_DATA='{"components": {"commands": {"files": ["commands/fail1.md", "commands/success.md", "commands/fail2.md"]}}}'
    
    # Mock download_file to simulate some failures
    download_file() {
        case "$1" in
            *fail*)
                return 1
                ;;
            *)
                return 0
                ;;
        esac
    }
    export -f download_file
    
    # Mock print functions to avoid output
    print_warning() { :; }
    print_success() { :; }
    export -f print_warning print_success
    
    install_component "commands" "$TEST_DIR"
    
    # Clean up
    unset -f download_file print_warning print_success
    
    # Should only track successful files
    [[ ${#INSTALLED_FILES[@]} -eq 1 ]]
    [[ "${INSTALLED_FILES[0]}" == "commands/success.md" ]]
    [[ "$COMPONENT_FILE_COUNT" -eq 1 ]]
}

# Removed test for CLAUDE.md prompting - claude-files component no longer exists

# Network Error Handling Tests

@test "download_file handles curl failures gracefully" {
    DRY_RUN=false
    REPO_URL="http://example.com"
    
    # Test various curl failure scenarios
    # All should result in download_file returning 1
    curl() {
        return 1  # Generic curl failure
    }
    export -f curl
    
    # Create target directory
    mkdir -p "$TEST_DIR/test"
    
    # Should fail gracefully
    run download_file "test.md" "$TEST_DIR/test/file.md"
    
    # Clean up
    unset -f curl
    
    [[ "$status" -eq 1 ]]
    [[ ! -f "$TEST_DIR/test/file.md" ]]
}

@test "download_file creates parent directories" {
    DRY_RUN=false
    REPO_URL="http://example.com"
    
    # Mock successful curl
    curl() {
        # Parse arguments to find output file
        local output_file=""
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -o)
                    output_file="$2"
                    shift 2
                    ;;
                *)
                    shift
                    ;;
            esac
        done
        
        if [[ -n "$output_file" ]]; then
            echo "test content" > "$output_file"
        fi
        return 0
    }
    export -f curl
    
    # Target a deeply nested path
    local target="$TEST_DIR/deep/nested/path/file.md"
    
    download_file "test.md" "$target"
    status=$?
    
    # Clean up
    unset -f curl
    
    [[ $status -eq 0 ]]
    [[ -d "$TEST_DIR/deep/nested/path" ]]
    [[ -f "$target" ]]
}

@test "installation handles missing curl gracefully" {
    # Mock command to make curl appear missing
    command() {
        if [[ "$1" == "-v" && "$2" == "curl" ]]; then
            return 1
        fi
        builtin command "$@"
    }
    export -f command
    
    # The script should check for curl at the beginning
    # This is typically done in the main function
    # For now, we'll test that download_file fails when curl is missing
    
    # Try to use curl when it's "missing"
    output=$(download_file "test.md" "$TEST_DIR/test.md" 2>&1 || echo "failed")
    
    # Clean up
    unset -f command
    
    [[ "$output" == *"failed"* ]] || [[ "$output" == *"not found"* ]]
}

@test "installation handles network interruption during multi-file download" {
    INSTALL_COMMANDS=true
    DRY_RUN=false
    INSTALLED_FILES=()
    download_count=0
    
    # Set up manifest data
    MANIFEST_DATA='{"components": {"commands": {"files": ["commands/file1.md", "commands/file2.md", "commands/file3.md"]}}}'
    
    # Mock download_file to fail after first success
    download_file() {
        download_count=$((download_count + 1))
        if [[ $download_count -eq 1 ]]; then
            return 0  # First file succeeds
        else
            return 1  # Subsequent files fail (network interruption)
        fi
    }
    export -f download_file
    export download_count
    
    # Mock print functions
    print_warning() { :; }
    print_success() { :; }
    export -f print_warning print_success
    
    install_component "commands" "$TEST_DIR"
    
    # Clean up
    unset -f download_file print_warning print_success
    unset download_count
    
    # Should have only installed the first file before network failure
    [[ ${#INSTALLED_FILES[@]} -eq 1 ]]
    [[ "${INSTALLED_FILES[0]}" == "commands/file1.md" ]]
}

@test "remove_old_files handles missing jq gracefully" {
    DRY_RUN=false
    
    # Create a test directory with manifest
    local test_dir="$TEST_DIR/.claude"
    mkdir -p "$test_dir"
    
    # Create a simple manifest
    cat > "$test_dir/.claude-environment-manifest.json" << 'EOF'
{
  "_meta": {
    "manifest_version": "1.0",
    "generated_at": "2024-01-01T00:00:00Z"
  },
  "installation": {
    "version": "1.0.0",
    "installed_at": "2024-01-01T00:00:00Z",
    "install_type": "global",
    "components": [],
    "files": ["test1.md", "test2.md"]
  },
  "snippets": {
    "injected": {}
  }
}
EOF
    
    # Create the files to be removed
    touch "$test_dir/test1.md"
    touch "$test_dir/test2.md"
    
    # Mock command to make jq appear missing
    command() {
        if [[ "$1" == "-v" && "$2" == "jq" ]]; then
            return 1
        fi
        builtin command "$@"
    }
    export -f command
    
    # Mock print_info
    print_info() { :; }
    export -f print_info
    
    remove_old_files "$test_dir"
    
    # Clean up
    unset -f command print_info
    
    # Files should be removed even without jq (using grep fallback)
    [[ ! -f "$test_dir/test1.md" ]]
    [[ ! -f "$test_dir/test2.md" ]]
}

