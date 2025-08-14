#!/usr/bin/env bats

# Test suite for snippet manager functionality

setup() {
    # Create temporary test directory
    TEST_DIR="$(mktemp -d)"
    export TEST_DIR
    export SNIPPET_DIR="$TEST_DIR/snippets"
    export TARGET_DIR="$TEST_DIR/target"
    
    # Create directories
    mkdir -p "$SNIPPET_DIR" "$TARGET_DIR"
    
    # Copy snippet manager
    cp "$BATS_TEST_DIRNAME/../scripts/snippet-manager.sh" "$TEST_DIR/"
    export SNIPPET_MANAGER="$TEST_DIR/snippet-manager.sh"
    
    # Create test snippets (single file per target)
    cat > "$SNIPPET_DIR/settings.json" << 'EOF'
{
  "claude-environment": {
    "version": "2.5.0",
    "description": "Test settings",
    "testFeature": {
      "enabled": true,
      "value": "test"
    }
  }
}
EOF

    cat > "$SNIPPET_DIR/CLAUDE.md" << 'EOF'
<!-- CLAUDE-ENV-START v2.5.0 -->
## Test Standards
This is a test snippet for CLAUDE.md
<!-- CLAUDE-ENV-END -->
EOF
}

teardown() {
    # Clean up test directory
    rm -rf "$TEST_DIR"
}

@test "snippet-manager.sh exists and is executable" {
    [ -f "$SNIPPET_MANAGER" ]
    [ -x "$SNIPPET_MANAGER" ]
}

@test "inject settings.json snippet" {
    # Skip if jq is not available
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required for settings.json tests"
    fi
    
    # Run injection directly (not using run)
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings.json" "$TARGET_DIR/settings.json"
    
    # Check that settings.json was created
    [ -f "$TARGET_DIR/settings.json" ]
    
    # Verify content with jq
    if command -v jq >/dev/null 2>&1; then
        # Check that the claude-environment key exists
        jq -e '."claude-environment"' "$TARGET_DIR/settings.json" >/dev/null
        
        # Check that the test feature is present
        local enabled
        enabled=$(jq -r '."claude-environment".testFeature.enabled' "$TARGET_DIR/settings.json")
        [ "$enabled" = "true" ]
    fi
}

@test "inject CLAUDE.md snippet" {
    # Run injection
    run bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    [ "$status" -eq 0 ]
    
    # Check that CLAUDE.md was created
    [ -f "$TARGET_DIR/CLAUDE.md" ]
    
    # Verify content
    run grep "Test Standards" "$TARGET_DIR/CLAUDE.md"
    [ "$status" -eq 0 ]
    
    run grep "CLAUDE-ENV-START" "$TARGET_DIR/CLAUDE.md"
    [ "$status" -eq 0 ]
}

@test "remove settings.json snippet" {
    # Skip if jq is not available
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required for settings.json tests"
    fi
    
    # First inject
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings.json" "$TARGET_DIR/settings.json"
    
    # Then remove
    run bash "$SNIPPET_MANAGER" remove "$TARGET_DIR/settings.json"
    [[ "$status" -eq 0 ]]
    
    # Verify removal with jq
    if command -v jq >/dev/null 2>&1; then
        # claude-environment key should be gone
        run jq -e '."claude-environment"' "$TARGET_DIR/settings.json"
        [[ "$status" -ne 0 ]]
    fi
}

@test "remove CLAUDE.md snippet" {
    # First inject
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    
    # Then remove
    run bash "$SNIPPET_MANAGER" remove "$TARGET_DIR/CLAUDE.md"
    [ "$status" -eq 0 ]
    
    # Verify removal
    run grep "Test Standards" "$TARGET_DIR/CLAUDE.md"
    [ "$status" -ne 0 ]
}

@test "dry run mode" {
    # Test dry run for settings
    run bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings.json" "$TARGET_DIR/settings.json" true
    [ "$status" -eq 0 ]
    
    # File should not be created in dry run
    [ ! -f "$TARGET_DIR/settings.json" ]
    
    # Output should indicate dry run
    [[ "$output" =~ "Would inject" ]]
}

@test "list snippets" {
    # Skip if jq is not available
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required for listing snippets"
    fi
    
    # Inject some snippets first
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings.json" "$TARGET_DIR/settings.json"
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    
    # List snippets
    run bash "$SNIPPET_MANAGER" list "$TARGET_DIR"
    [ "$status" -eq 0 ]
    
    # Should list both snippets
    [[ "$output" =~ settings\.json ]]
    [[ "$output" =~ CLAUDE\.md ]]
}

@test "snippet manifest is created" {
    # Skip if jq is not available
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required for manifest tests"
    fi
    
    # Inject a snippet
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings.json" "$TARGET_DIR/settings.json"
    
    # Check manifest exists (new consolidated manifest)
    [ -f "$TARGET_DIR/.claude-environment-manifest.json" ]
    
    # Verify manifest content
    if command -v jq >/dev/null 2>&1; then
        run jq -e '.snippets.injected."settings.json"' "$TARGET_DIR/.claude-environment-manifest.json"
        [ "$status" -eq 0 ]
    fi
}

@test "update existing snippet" {
    # Skip if jq is not available
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required for update tests"
    fi
    
    # Create initial snippet
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings.json" "$TARGET_DIR/settings.json"
    
    # Create updated snippet
    cat > "$SNIPPET_DIR/settings.json" << 'EOF'
{
  "claude-environment": {
    "version": "2.5.0",
    "description": "Updated test settings",
    "testFeature": {
      "enabled": false,
      "value": "updated"
    }
  }
}
EOF
    
    # Re-inject (should update)
    run bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings.json" "$TARGET_DIR/settings.json"
    [ "$status" -eq 0 ]
    
    # Verify update with jq
    if command -v jq >/dev/null 2>&1; then
        run jq -r '."claude-environment".testFeature.value' "$TARGET_DIR/settings.json"
        [ "$output" = "updated" ]
    fi
}

@test "backup files are created" {
    # Skip if jq is not available
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required for backup tests"
    fi
    
    # Inject snippet
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings.json" "$TARGET_DIR/settings.json"
    
    # Check backup exists
    [ -f "$TARGET_DIR/settings.json.backup" ]
    
    # Remove snippet
    bash "$SNIPPET_MANAGER" remove "$TARGET_DIR/settings.json"
    
    # Backup should be updated
    [ -f "$TARGET_DIR/settings.json.backup" ]
}