#!/usr/bin/env bats

# BATS tests for file validation
# Ensures all project files meet quality standards

setup() {
    export PROJECT_ROOT
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

    # Load test helpers
    source "$PROJECT_ROOT/tests/test-helpers.sh"
}

# Markdown file validation

@test "all markdown files have content" {
    while IFS= read -r file; do
        [[ -s "$file" ]] || fail "Empty markdown file: $file"
    done < <(find "$PROJECT_ROOT" -name "*.md" -not -path "*/\.*" -not -path "*/node_modules/*")
}

@test "all markdown files start with header or YAML frontmatter" {
    while IFS= read -r file; do
        first_line=$(head -n 1 "$file")
        # Allow either markdown header (#) or YAML frontmatter (---)
        [[ "$first_line" == "#"* ]] || [[ "$first_line" == "---" ]] || fail "No header or frontmatter in: $file"
    done < <(find "$PROJECT_ROOT" -name "*.md" -not -path "*/\.*" -not -path "*/node_modules/*")
}

# JSON validation

@test "manifest.json exists" {
    [[ -f "$PROJECT_ROOT/manifest.json" ]]
}

@test "manifest.json is valid JSON" {
    if command -v jq >/dev/null 2>&1; then
        jq empty "$PROJECT_ROOT/manifest.json"
    else
        skip "jq not available"
    fi
}

@test "manifest.json conforms to schema" {
    # Check if ajv-cli is available for JSON schema validation
    if command -v ajv >/dev/null 2>&1; then
        ajv validate -s "$PROJECT_ROOT/tests/manifest-schema.json" -d "$PROJECT_ROOT/manifest.json"
    elif command -v python3 >/dev/null 2>&1; then
        # Fallback to Python jsonschema if available
        if python3 -c "import jsonschema" 2>/dev/null; then
            python3 -c "
import json, sys
import jsonschema
with open('$PROJECT_ROOT/tests/manifest-schema.json') as f:
    schema = json.load(f)
with open('$PROJECT_ROOT/manifest.json') as f:
    data = json.load(f)
try:
    jsonschema.validate(data, schema)
except jsonschema.ValidationError as e:
    print(f'Schema validation error: {e.message}')
    sys.exit(1)
"
        else
            skip "Python jsonschema module not available"
        fi
    else
        skip "No JSON schema validator available"
    fi
}

@test "manifest.json has required fields" {
    if has_jq; then
        # Check required fields
        check_manifest_required_fields "$PROJECT_ROOT/manifest.json"

        # Dynamically check that manifest has at least one component
        components=$(get_manifest_components "$PROJECT_ROOT/manifest.json")
        [[ -n "$components" ]]

        # Verify each component has proper structure
        while IFS= read -r component; do
            [[ -z "$component" ]] && continue
            verify_component_structure "$PROJECT_ROOT/manifest.json" "$component" || \
                fail "Component '$component' missing required fields"
        done <<< "$components"
    else
        skip "jq not available"
    fi
}

# Install script validation

@test "install.sh exists and is executable" {
    [[ -f "$PROJECT_ROOT/install.sh" ]]
    [[ -x "$PROJECT_ROOT/install.sh" ]]
}

@test "install.sh has correct shebang" {
    shebang=$(head -n 1 "$PROJECT_ROOT/install.sh")
    [[ "$shebang" == "#!/bin/bash" ]]
}

@test "install.sh has correct REPO_URL" {
    # Check that REPO_URL uses environment variable with fallback
    grep -qE 'REPO_URL="\$\{CLAUDE_ENV_REPO_URL:-https://raw\.githubusercontent\.com/douglaslinsmeyer/claude-environment/main\}"' "$PROJECT_ROOT/install.sh"
}

@test "install.sh has valid syntax" {
    bash -n "$PROJECT_ROOT/install.sh"
}

# VERSION file validation

@test "VERSION file exists" {
    [[ -f "$PROJECT_ROOT/VERSION" ]]
}

@test "VERSION follows semantic versioning" {
    version=$(cat "$PROJECT_ROOT/VERSION")
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# README validation

@test "README.md has installation instructions" {
    grep -q "curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash" "$PROJECT_ROOT/README.md"
}

@test "README.md has required sections" {
    readme_content=$(cat "$PROJECT_ROOT/README.md")

    [[ "$readme_content" == *"## Quick Install"* ]]
    [[ "$readme_content" == *"## What Gets Installed"* ]]
    [[ "$readme_content" == *"## Installation Options"* ]]
}

# Command file validation

@test "all command files have proper structure" {
    for file in "$PROJECT_ROOT"/commands/*/*.md; do
        [[ ! -f "$file" ]] && continue

        content=$(cat "$file")
        basename=$(basename "$file")
        first_line=$(head -n 1 "$file")

        # Check for YAML frontmatter
        [[ "$first_line" == "---" ]] || fail "No YAML frontmatter in command: $basename"

        # Check for description in frontmatter
        [[ "$content" == *"description:"* ]] || fail "No description in command: $basename"

        # Check for $ARGUMENTS placeholder
        [[ "$content" == *"\$ARGUMENTS"* ]] || fail "No \$ARGUMENTS placeholder in command: $basename"
    done
}

# Persona file validation

@test "all persona files have proper structure" {
    for file in "$PROJECT_ROOT"/personas/*.md; do
        [[ ! -f "$file" ]] && continue

        content=$(cat "$file")
        basename=$(basename "$file")

        # Check for title
        [[ "$content" == *"# "* ]] || fail "No title in persona: $basename"

        # Check for sections
        [[ "$content" == *"## "* ]] || fail "No sections in persona: $basename"
    done
}

# Check for file references in manifest

@test "all files in manifest exist" {
    if has_jq; then
        # Get all file references from manifest using helper
        files=$(get_all_manifest_files "$PROJECT_ROOT/manifest.json")

        while IFS= read -r file; do
            [[ -z "$file" ]] && continue
            [[ -f "$PROJECT_ROOT/$file" ]] || fail "File in manifest does not exist: $file"
        done <<< "$files"
    else
        skip "jq not available"
    fi
}

# No debug artifacts

# Test files validation

@test "all test files are executable" {
    for file in "$PROJECT_ROOT"/tests/*.sh "$PROJECT_ROOT"/tests/*.bats; do
        [[ ! -f "$file" ]] && continue
        [[ -x "$file" ]] || fail "Test file not executable: $file"
    done
}

# GitHub Actions validation

@test "CI workflow exists" {
    [[ -f "$PROJECT_ROOT/.github/workflows/ci.yml" ]]
}

@test "Release functionality exists in CI workflow" {
    # Release workflow was consolidated into CI workflow
    grep -q "create-release:" "$PROJECT_ROOT/.github/workflows/ci.yml"
    grep -q "Create GitHub Release" "$PROJECT_ROOT/.github/workflows/ci.yml"
}