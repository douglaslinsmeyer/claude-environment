#!/usr/bin/env bats

# Test suite for snippet installation integration

setup() {
    # Source the install script in test mode
    export CLAUDE_ENV_TESTING=true
    # shellcheck disable=SC1091
    source "$BATS_TEST_DIRNAME/../install.sh"
    
    # Create temporary test directory
    TEST_DIR="$(mktemp -d)"
    export TEST_DIR
    export INSTALL_DIR="$TEST_DIR/.claude"
    
    # Override download_file function for testing
    download_file() {
        local remote_path="$1"
        local local_path="$2"
        
        # In dry run mode, don't actually create files
        if [[ "$DRY_RUN" == "true" ]]; then
            return 0
        fi
        
        # Create directory if needed
        mkdir -p "$(dirname "$local_path")"
        
        # Copy from actual project files for testing
        local source_file="$BATS_TEST_DIRNAME/../$remote_path"
        if [[ -f "$source_file" ]]; then
            cp "$source_file" "$local_path"
            return 0
        else
            return 1
        fi
    }
    
    # Override remote version and manifest functions
    get_remote_version() {
        cat "$BATS_TEST_DIRNAME/../VERSION"
    }
    
    get_remote_manifest() {
        cat "$BATS_TEST_DIRNAME/../manifest.json"
    }
    
    # Set up test environment
    cd "$TEST_DIR"
}

teardown() {
    # Clean up
    rm -rf "$TEST_DIR"
}

@test "install with snippets enabled" {
    # Run installation with snippets
    run main --local --force
    [ "$status" -eq 0 ]
    
    # Check that snippets directory was created
    [ -d "$INSTALL_DIR/snippets" ]
    
    # Check that snippet files were downloaded
    [ -f "$INSTALL_DIR/snippets/settings.json" ]
    [ -f "$INSTALL_DIR/snippets/CLAUDE.md" ]
}

@test "install with --no-snippets flag" {
    # Run installation without snippets
    run main --local --no-snippets --force
    [ "$status" -eq 0 ]
    
    # Snippets directory should not exist
    [ ! -d "$INSTALL_DIR/snippets" ]
}

@test "install with --no-inject flag" {
    # Run installation without injection
    run main --local --no-inject --force
    [ "$status" -eq 0 ]
    
    # Check that snippet files were downloaded but not injected
    [ -d "$INSTALL_DIR/snippets" ]
    [ -f "$INSTALL_DIR/snippets/settings.json" ]
    [ -f "$INSTALL_DIR/snippets/CLAUDE.md" ]
    
    # Target files should not be created
    [ ! -f "$INSTALL_DIR/settings.json" ]
    [ ! -f "$INSTALL_DIR/CLAUDE.md" ]
}

@test "dry run with snippets" {
    # Clean start to ensure directory doesn't exist
    rm -rf "$INSTALL_DIR"
    
    # Run dry run
    run main --local --dry-run
    [ "$status" -eq 0 ]
    
    # Should mention snippets in output
    [[ "$output" =~ "snippets" ]]
    
    # No actual files should be created
    [ ! -d "$INSTALL_DIR" ]
}

@test "snippet component in manifest" {
    # Run installation
    run main --local --force
    [ "$status" -eq 0 ]
    
    # Check manifest includes snippets component
    if command -v jq >/dev/null 2>&1; then
        run jq -e '.installation.components | index("snippets")' "$INSTALL_DIR/.claude-environment-manifest.json"
        [ "$status" -eq 0 ]
    fi
}