#!/usr/bin/env bats

# BATS tests for version consistency
# Ensures version numbers are synchronized across all files

setup() {
    export PROJECT_ROOT
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

    # Load test helpers
    source "$PROJECT_ROOT/tests/test-helpers.sh"
}

@test "VERSION file matches manifest.json version" {
    version_file=$(tr -d '[:space:]' < "$PROJECT_ROOT/VERSION")

    if has_jq; then
        manifest_version=$(get_manifest_version "$PROJECT_ROOT/manifest.json")
        [[ "$version_file" == "$manifest_version" ]] || \
            false "Version mismatch: VERSION=$version_file, manifest.json=$manifest_version"
    else
        skip "jq not available"
    fi
}

@test "CHANGELOG.md has entry for current version" {
    current_version=$(tr -d '[:space:]' < "$PROJECT_ROOT/VERSION")

    # Check if current version appears in changelog
    grep -q "## \[$current_version\]" "$PROJECT_ROOT/CHANGELOG.md" || \
        false "No changelog entry found for version $current_version"
}

@test "CHANGELOG.md version entries are in descending order" {
    # Extract version numbers from changelog
    versions=$(grep -E "^## \[[0-9]+\.[0-9]+\.[0-9]+\]" "$PROJECT_ROOT/CHANGELOG.md" | \
               sed 's/## \[\([0-9.]*\)\].*/\1/')

    # Check if versions are sorted in descending order
    sorted_versions=$(echo "$versions" | sort -rV)
    [[ "$versions" == "$sorted_versions" ]] || \
        false "CHANGELOG.md versions are not in descending order"
}

@test "install.sh references correct repository URL" {
    # Check that REPO_URL in install.sh contains the correct repository
    expected_repo="douglaslinsmeyer/claude-environment"

    grep -q "REPO_URL=.*$expected_repo" "$PROJECT_ROOT/install.sh" || \
        false "install.sh does not reference correct repository URL"
}

@test "no version placeholders remain" {
    # Check for common version placeholders
    ! grep -r "X\.X\.X\|0\.0\.0\|TODO.*version\|FIXME.*version" \
        --include="*.md" \
        --include="*.json" \
        --include="*.sh" \
        --exclude-dir=".git" \
        --exclude-dir="node_modules" \
        "$PROJECT_ROOT" || \
        false "Found version placeholders in files"
}

@test "version follows semantic versioning" {
    version=$(tr -d '[:space:]' < "$PROJECT_ROOT/VERSION")

    # Check version matches semver pattern
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || \
        false "Version '$version' does not follow semantic versioning (X.Y.Z)"
}