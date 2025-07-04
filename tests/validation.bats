#!/usr/bin/env bats

# BATS tests for file validation
# Ensures all project files meet quality standards

setup() {
    export PROJECT_ROOT
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

# Markdown file validation

@test "all markdown files have content" {
    while IFS= read -r file; do
        [[ -s "$file" ]] || fail "Empty markdown file: $file"
    done < <(find "$PROJECT_ROOT" -name "*.md" -not -path "*/\.*" -not -path "*/node_modules/*")
}

@test "all markdown files start with header" {
    while IFS= read -r file; do
        first_line=$(head -n 1 "$file")
        [[ "$first_line" == "#"* ]] || fail "No header in: $file"
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

@test "manifest.json has required fields" {
    if command -v jq >/dev/null 2>&1; then
        version=$(jq -r '.version' "$PROJECT_ROOT/manifest.json")
        [[ "$version" != "null" ]]

        # Check components exist
        components=$(jq -r '.components | keys[]' "$PROJECT_ROOT/manifest.json" 2>/dev/null)
        [[ "$components" == *"workflows"* ]]
        [[ "$components" == *"personas"* ]]
        [[ "$components" == *"claude-files"* ]]
        [[ "$components" == *"templates"* ]]
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
    grep -q 'REPO_URL="https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main"' "$PROJECT_ROOT/install.sh"
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

# Workflow file validation

@test "all workflow files have proper structure" {
    for file in "$PROJECT_ROOT"/workflows/*/*.md; do
        [[ ! -f "$file" ]] && continue

        content=$(cat "$file")
        basename=$(basename "$file")

        # Check for title
        [[ "$content" == *"# "* ]] || fail "No title in workflow: $basename"

        # Check for sections
        [[ "$content" == *"## "* ]] || fail "No sections in workflow: $basename"
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
    if command -v jq >/dev/null 2>&1; then
        # Get all file references from manifest
        files=$(jq -r '.components[].files[]' "$PROJECT_ROOT/manifest.json" 2>/dev/null | sort | uniq)

        while IFS= read -r file; do
            [[ -z "$file" ]] && continue
            [[ -f "$PROJECT_ROOT/$file" ]] || fail "File in manifest does not exist: $file"
        done <<< "$files"
    else
        skip "jq not available"
    fi
}

# No debug artifacts

@test "no console.log in shell scripts" {
    ! grep -r "console\.log" "$PROJECT_ROOT" \
        --include="*.sh" \
        --exclude-dir=.git \
        --exclude-dir=node_modules
}

@test "no TODO comments in shell scripts" {
    # Allow TODOs in markdown documentation but not in scripts
    ! grep -r "TODO\|FIXME\|XXX" "$PROJECT_ROOT" \
        --include="*.sh" \
        --exclude-dir=.git \
        --exclude-dir=node_modules \
        --exclude-dir=tests
}

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