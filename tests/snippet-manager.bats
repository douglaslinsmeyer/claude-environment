#!/usr/bin/env bats

# Test suite for snippet manager functionality

setup() {
    # Create temporary test directory
    TEST_DIR="$(mktemp -d)"
    export TEST_DIR
    export SNIPPET_DIR="$TEST_DIR/snippets"
    export TARGET_DIR="$TEST_DIR/target"
    
    # Create directories
    mkdir -p "$SNIPPET_DIR/settings" "$SNIPPET_DIR/claude-md" "$TARGET_DIR"
    
    # Copy snippet manager
    cp "$BATS_TEST_DIRNAME/../scripts/snippet-manager.sh" "$TEST_DIR/"
    export SNIPPET_MANAGER="$TEST_DIR/snippet-manager.sh"
    
    # Create test snippets
    cat > "$SNIPPET_DIR/settings/test-feature.json" << 'EOF'
{
  "snippet_id": "test-feature",
  "snippet_version": "1.0.0",
  "description": "Test feature",
  "settings": {
    "testFeature": {
      "enabled": true,
      "value": "test"
    }
  }
}
EOF

    cat > "$SNIPPET_DIR/claude-md/test-standards.md" << 'EOF'
<!-- SNIPPET_START: test-standards 1.0.0 -->
## Test Standards
This is a test snippet for CLAUDE.md
<!-- SNIPPET_END: test-standards -->
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
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings/test-feature.json" "$TARGET_DIR/settings.json"
    
    # Check that settings.json was created
    [ -f "$TARGET_DIR/settings.json" ]
    
    # Verify content with jq
    if command -v jq >/dev/null 2>&1; then
        # Check that the test feature is present
        local enabled
        enabled=$(jq -r '.testFeature.enabled' "$TARGET_DIR/settings.json")
        [ "$enabled" = "true" ]
        
        # Check snippet marker exists
        jq -e '."_snippet_test-feature"' "$TARGET_DIR/settings.json" >/dev/null
    fi
}

@test "inject CLAUDE.md snippet" {
    # Run injection
    run bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/claude-md/test-standards.md" "$TARGET_DIR/CLAUDE.md"
    [ "$status" -eq 0 ]
    
    # Check that CLAUDE.md was created
    [ -f "$TARGET_DIR/CLAUDE.md" ]
    
    # Verify content
    run grep "Test Standards" "$TARGET_DIR/CLAUDE.md"
    [ "$status" -eq 0 ]
    
    run grep "SNIPPET_START: test-standards" "$TARGET_DIR/CLAUDE.md"
    [ "$status" -eq 0 ]
}

@test "remove settings.json snippet" {
    # Skip if jq is not available
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required for settings.json tests"
    fi
    
    # First inject
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings/test-feature.json" "$TARGET_DIR/settings.json"
    
    # Then remove
    run bash "$SNIPPET_MANAGER" remove "test-feature" "$TARGET_DIR/settings.json"
    [[ "$status" -eq 0 ]]
    
    # Verify removal with jq
    if command -v jq >/dev/null 2>&1; then
        # Feature should be gone
        run jq -e '.testFeature' "$TARGET_DIR/settings.json"
        [[ "$status" -ne 0 ]]
        
        # Marker should be gone
        run jq -e '."_snippet_test-feature"' "$TARGET_DIR/settings.json"
        [[ "$status" -ne 0 ]]
    fi
}

@test "remove CLAUDE.md snippet" {
    # First inject
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/claude-md/test-standards.md" "$TARGET_DIR/CLAUDE.md"
    
    # Then remove
    run bash "$SNIPPET_MANAGER" remove "test-standards" "$TARGET_DIR/CLAUDE.md"
    [ "$status" -eq 0 ]
    
    # Verify removal
    run grep "Test Standards" "$TARGET_DIR/CLAUDE.md"
    [ "$status" -ne 0 ]
}

@test "dry run mode" {
    # Test dry run for settings
    run bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings/test-feature.json" "$TARGET_DIR/settings.json" true
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
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings/test-feature.json" "$TARGET_DIR/settings.json"
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/claude-md/test-standards.md" "$TARGET_DIR/CLAUDE.md"
    
    # List snippets
    run bash "$SNIPPET_MANAGER" list "$TARGET_DIR"
    [ "$status" -eq 0 ]
    
    # Should list both snippets
    [[ "$output" =~ "test-feature" ]]
    [[ "$output" =~ "test-standards" ]]
}

@test "snippet manifest is created" {
    # Skip if jq is not available
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required for manifest tests"
    fi
    
    # Inject a snippet
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings/test-feature.json" "$TARGET_DIR/settings.json"
    
    # Check manifest exists
    [ -f "$TARGET_DIR/.snippet-manifest.json" ]
    
    # Verify manifest content
    if command -v jq >/dev/null 2>&1; then
        run jq -e '.snippets."test-feature"' "$TARGET_DIR/.snippet-manifest.json"
        [ "$status" -eq 0 ]
    fi
}

@test "update existing snippet" {
    # Skip if jq is not available
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required for update tests"
    fi
    
    # Create initial snippet
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings/test-feature.json" "$TARGET_DIR/settings.json"
    
    # Create updated snippet
    cat > "$SNIPPET_DIR/settings/test-feature.json" << 'EOF'
{
  "snippet_id": "test-feature",
  "snippet_version": "2.0.0",
  "description": "Updated test feature",
  "settings": {
    "testFeature": {
      "enabled": false,
      "value": "updated"
    }
  }
}
EOF
    
    # Re-inject (should update)
    run bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings/test-feature.json" "$TARGET_DIR/settings.json"
    [ "$status" -eq 0 ]
    
    # Verify update with jq
    if command -v jq >/dev/null 2>&1; then
        run jq -r '.testFeature.value' "$TARGET_DIR/settings.json"
        [ "$output" = "updated" ]
    fi
}

@test "backup files are created" {
    # Skip if jq is not available
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required for backup tests"
    fi
    
    # Inject snippet
    bash "$SNIPPET_MANAGER" inject "$SNIPPET_DIR/settings/test-feature.json" "$TARGET_DIR/settings.json"
    
    # Check backup exists
    [ -f "$TARGET_DIR/settings.json.backup" ]
    
    # Remove snippet
    bash "$SNIPPET_MANAGER" remove "test-feature" "$TARGET_DIR/settings.json"
    
    # Backup should be updated
    [ -f "$TARGET_DIR/settings.json.backup" ]
}