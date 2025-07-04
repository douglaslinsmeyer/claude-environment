#!/usr/bin/env bats

# Test for the version bump script

setup() {
    # Create a temporary directory for testing
    export TEST_DIR="$BATS_TEST_TMPDIR/bump-version-test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"

    # Copy the bump version script
    cp "$BATS_TEST_DIRNAME/../scripts/bump-version.sh" ./bump-version.sh
    chmod +x ./bump-version.sh

    # Create test VERSION file
    echo "1.2.3" > VERSION

    # Create test CHANGELOG.md
    cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- New feature X

### Changed
- Updated feature Y

## [1.2.3] - 2024-01-01

### Added
- Initial release

[Unreleased]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.3...HEAD
[1.2.3]: https://github.com/douglaslinsmeyer/claude-environment/releases/tag/v1.2.3
EOF
}

teardown() {
    cd ..
    rm -rf "$TEST_DIR"
}

@test "bump patch version" {
    run ./bump-version.sh patch

    [ "$status" -eq 0 ]
    [[ "$output" == *"Bumping version from 1.2.3 to 1.2.4"* ]]

    # Check VERSION file
    version_content=$(cat VERSION)
    [ "$version_content" = "1.2.4" ]

    # Check CHANGELOG.md has new version section
    changelog_content=$(cat CHANGELOG.md)
    [[ "$changelog_content" == *"## [1.2.4]"* ]]
    [[ "$changelog_content" == *"[1.2.4]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.3...v1.2.4"* ]]
    [[ "$changelog_content" == *"[Unreleased]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.4...HEAD"* ]]
}

@test "bump minor version" {
    run ./bump-version.sh minor

    [ "$status" -eq 0 ]
    [[ "$output" == *"Bumping version from 1.2.3 to 1.3.0"* ]]

    # Check VERSION file
    version_content=$(cat VERSION)
    [ "$version_content" = "1.3.0" ]

    # Check CHANGELOG.md
    changelog_content=$(cat CHANGELOG.md)
    [[ "$changelog_content" == *"## [1.3.0]"* ]]
}

@test "bump major version" {
    run ./bump-version.sh major

    [ "$status" -eq 0 ]
    [[ "$output" == *"Bumping version from 1.2.3 to 2.0.0"* ]]

    # Check VERSION file
    version_content=$(cat VERSION)
    [ "$version_content" = "2.0.0" ]

    # Check CHANGELOG.md
    changelog_content=$(cat CHANGELOG.md)
    [[ "$changelog_content" == *"## [2.0.0]"* ]]
}

@test "default to patch when no argument" {
    run ./bump-version.sh

    [ "$status" -eq 0 ]
    [[ "$output" == *"Bumping version from 1.2.3 to 1.2.4"* ]]

    version_content=$(cat VERSION)
    [ "$version_content" = "1.2.4" ]
}

@test "invalid bump type shows error" {
    run ./bump-version.sh invalid

    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: Invalid bump type 'invalid'"* ]]
    [[ "$output" == *"Usage:"* ]]
}

@test "preserves unreleased content in changelog" {
    run ./bump-version.sh patch

    [ "$status" -eq 0 ]

    # Check that unreleased content is preserved
    changelog_content=$(cat CHANGELOG.md)
    [[ "$changelog_content" == *"## [Unreleased]"* ]]
    [[ "$changelog_content" == *"- New feature X"* ]]
    [[ "$changelog_content" == *"- Updated feature Y"* ]]
}

@test "changelog sections are properly formatted" {
    run ./bump-version.sh patch

    [ "$status" -eq 0 ]

    # Check that new version section has all subsections
    changelog_content=$(cat CHANGELOG.md)

    # Check that the new version was added
    [[ "$changelog_content" == *"## [1.2.4] -"* ]]

    # Check that all standard sections are added after the new version
    [[ "$changelog_content" == *"## [1.2.4] -"*"### Added"* ]]
    [[ "$changelog_content" == *"## [1.2.4] -"*"### Changed"* ]]
    [[ "$changelog_content" == *"## [1.2.4] -"*"### Fixed"* ]]
    [[ "$changelog_content" == *"## [1.2.4] -"*"### Removed"* ]]
}

@test "date format in changelog is correct" {
    run ./bump-version.sh patch

    [ "$status" -eq 0 ]

    # Check date format (YYYY-MM-DD)
    changelog_content=$(cat CHANGELOG.md)
    current_date=$(date +%Y-%m-%d)
    [[ "$changelog_content" == *"## [1.2.4] - $current_date"* ]]
}

@test "handles version with zeros correctly" {
    echo "1.0.0" > VERSION

    run ./bump-version.sh patch

    [ "$status" -eq 0 ]
    [[ "$output" == *"Bumping version from 1.0.0 to 1.0.1"* ]]

    version_content=$(cat VERSION)
    [ "$version_content" = "1.0.1" ]
}

@test "handles complex changelog with multiple versions" {
    # Create a more complex changelog
    cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- New feature X

## [1.2.3] - 2024-01-01

### Added
- Feature A

## [1.2.2] - 2023-12-01

### Fixed
- Bug B

## [1.2.1] - 2023-11-01

### Changed
- Config C

[Unreleased]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.3...HEAD
[1.2.3]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/douglaslinsmeyer/claude-environment/releases/tag/v1.2.1
EOF

    run ./bump-version.sh patch

    [ "$status" -eq 0 ]

    # Check all links are updated correctly
    changelog_content=$(cat CHANGELOG.md)
    [[ "$changelog_content" == *"[Unreleased]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.4...HEAD"* ]]
    [[ "$changelog_content" == *"[1.2.4]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.3...v1.2.4"* ]]
    # Original links should remain
    [[ "$changelog_content" == *"[1.2.3]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.2...v1.2.3"* ]]
}

@test "next steps output is complete" {
    run ./bump-version.sh patch

    [ "$status" -eq 0 ]

    # Check for all expected next steps
    [[ "$output" == *"Next steps:"* ]]
    [[ "$output" == *"1. Update the Unreleased section"* ]]
    [[ "$output" == *"2. Commit the version bump:"* ]]
    [[ "$output" == *"git add VERSION CHANGELOG.md"* ]]
    [[ "$output" == *"git commit -m \"chore: bump version to 1.2.4\""* ]]
    [[ "$output" == *"3. Push to main:"* ]]
    [[ "$output" == *"git push origin main"* ]]
    [[ "$output" == *"The CI/CD pipeline will automatically:"* ]]
    [[ "$output" == *"Run all tests"* ]]
    [[ "$output" == *"create tag v1.2.4"* ]]
}