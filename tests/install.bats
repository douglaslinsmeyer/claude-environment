#!/usr/bin/env bats

# BATS tests for install.sh
# Comprehensive test suite for the Claude Environment installer

# Setup and teardown functions
setup() {
    # Get the directory where this test file is located
    export BATS_TEST_DIRNAME="${BATS_TEST_DIRNAME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
    export ORIGINAL_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

    # Create a temporary directory for each test
    export TEST_DIR="$(mktemp -d -t claude-env-test-XXXXXX)"
    cd "$TEST_DIR"

    # Source the install script with testing flag
    export CLAUDE_ENV_TESTING=true
    source "$ORIGINAL_DIR/install.sh"

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

@test "parse_args handles --no-workflows flag" {
    INSTALL_WORKFLOWS=true
    parse_args --no-workflows
    [[ "$INSTALL_WORKFLOWS" == "false" ]]
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
    INSTALL_WORKFLOWS=true
    FORCE=false

    parse_args --local --no-workflows --force

    [[ "$INSTALL_TYPE" == "local" ]]
    [[ "$INSTALL_WORKFLOWS" == "false" ]]
    [[ "$FORCE" == "true" ]]
}

@test "check_existing_installation detects version" {
    # Create mock installation
    local test_dir="$TEST_DIR/.claude"
    mkdir -p "$test_dir"

    cat > "$test_dir/.claude-install-manifest" << EOF
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

@test "get_component_files returns workflow files" {
    files=($(get_component_files "workflows"))
    [[ ${#files[@]} -gt 0 ]]
    [[ "${files[0]}" == *"workflows/"* ]]
}

@test "get_component_files returns persona files" {
    files=($(get_component_files "personas"))
    [[ ${#files[@]} -gt 0 ]]
    [[ "${files[0]}" == *"personas/"* ]]
}

@test "get_component_files returns claude files" {
    files=($(get_component_files "claude-files"))
    [[ ${#files[@]} -gt 0 ]]
    [[ "${files[0]}" == *"claude-files/"* ]]
}

@test "get_component_files returns template files" {
    files=($(get_component_files "templates"))
    [[ ${#files[@]} -gt 0 ]]
    [[ "${files[0]}" == *"templates/"* ]]
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
    INSTALL_WORKFLOWS=true
    INSTALL_PERSONAS=true
    INSTALL_TEMPLATES=true
    INSTALLED_FILES=("test1.md" "test2.md")

    local test_dir="$TEST_DIR/.claude"
    mkdir -p "$test_dir"

    create_manifest "$test_dir" "1.0.0"

    [[ -f "$test_dir/.claude-install-manifest" ]]

    # Verify JSON structure if jq is available
    if command -v jq >/dev/null 2>&1; then
        version=$(jq -r '.version' "$test_dir/.claude-install-manifest")
        [[ "$version" == "1.0.0" ]]

        install_type=$(jq -r '.install_type' "$test_dir/.claude-install-manifest")
        [[ "$install_type" == "local" ]]
    fi
}

@test "remove_old_files removes listed files" {
    DRY_RUN=false
    local test_dir="$TEST_DIR/.claude"
    mkdir -p "$test_dir/workflows"

    # Create test files
    echo "test" > "$test_dir/workflows/test.md"
    echo "test" > "$test_dir/CLAUDE.md"

    # Create manifest
    cat > "$test_dir/.claude-install-manifest" << EOF
{
  "version": "0.9.0",
  "files": ["workflows/test.md", "CLAUDE.md"]
}
EOF

    remove_old_files "$test_dir"

    [[ ! -f "$test_dir/workflows/test.md" ]]
    [[ ! -f "$test_dir/CLAUDE.md" ]]
    [[ -f "$test_dir/.claude-install-manifest" ]]
}

# Integration Tests

@test "full global installation succeeds" {
    skip "Requires full file structure"

    HOME="$TEST_DIR" run bash "$ORIGINAL_DIR/install.sh" --force

    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_DIR/.claude" ]]
    [[ -f "$TEST_DIR/.claude/CLAUDE.md" ]]
    [[ -d "$TEST_DIR/.claude/workflows" ]]
    [[ -d "$TEST_DIR/.claude/personas" ]]
    [[ -d "$TEST_DIR/.claude/templates" ]]
}

@test "local installation succeeds" {
    skip "Requires full file structure"

    run bash "$ORIGINAL_DIR/install.sh" --local --force

    [[ "$status" -eq 0 ]]
    [[ -d ".claude" ]]
    [[ -f ".claude/CLAUDE.md" ]]
}

@test "dry run does not create files" {
    # Unset testing flag and run in subshell
    (
        unset CLAUDE_ENV_TESTING
        cd "$ORIGINAL_DIR"
        HOME="$TEST_DIR" output=$(bash install.sh --dry-run 2>&1)

        [[ "$output" == *"DRY RUN"* ]]
        [[ ! -d "$TEST_DIR/.claude" ]]
    )
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