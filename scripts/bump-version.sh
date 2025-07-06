#!/bin/bash

# Version bump script for Claude Environment
# Usage: ./scripts/bump-version.sh [major|minor|patch]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get the bump type
BUMP_TYPE="${1:-patch}"

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo -e "${RED}Error: Invalid bump type '$BUMP_TYPE'${NC}"
    echo "Usage: $0 [major|minor|patch]"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(cat VERSION)

# Parse version components
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# Calculate new version
case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

echo -e "${BLUE}Bumping version from ${CURRENT_VERSION} to ${NEW_VERSION}${NC}"

# Update VERSION file
echo "$NEW_VERSION" > VERSION
echo -e "${GREEN}✓${NC} Updated VERSION file"

# Update CHANGELOG.md
DATE=$(date +%Y-%m-%d)
TEMP_FILE=$(mktemp)

# Ensure cleanup on exit
trap 'rm -f "$TEMP_FILE"' EXIT

# Get the previous version from changelog
PREV_VERSION=$(grep -E '^\[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | head -1 | sed 's/^\[\([^]]*\)\].*/\1/')

# Read the changelog and insert new version
awk -v version="$NEW_VERSION" -v date="$DATE" -v prev_version="$PREV_VERSION" '
    /^## \[Unreleased\]/ {
        print
        print ""
        print "## [" version "] - " date
        print ""
        print "### Added"
        print ""
        print "### Changed"
        print ""
        print "### Fixed"
        print ""
        print "### Removed"
        next
    }
    /^\[Unreleased\]:/ {
        print "[Unreleased]: https://github.com/douglaslinsmeyer/claude-environment/compare/v" version "...HEAD"
        if (prev_version) {
            print "[" version "]: https://github.com/douglaslinsmeyer/claude-environment/compare/v" prev_version "...v" version
        } else {
            print "[" version "]: https://github.com/douglaslinsmeyer/claude-environment/releases/tag/v" version
        }
        next
    }
    { print }
' CHANGELOG.md > "$TEMP_FILE"

mv "$TEMP_FILE" CHANGELOG.md
echo -e "${GREEN}✓${NC} Updated CHANGELOG.md"

# Update manifest.json
if [[ -f "manifest.json" ]]; then
    # Use sed to update the version in manifest.json
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/\"version\": \"${CURRENT_VERSION}\"/\"version\": \"${NEW_VERSION}\"/" manifest.json
    else
        # Linux
        sed -i "s/\"version\": \"${CURRENT_VERSION}\"/\"version\": \"${NEW_VERSION}\"/" manifest.json
    fi
    echo -e "${GREEN}✓${NC} Updated manifest.json"
fi

# Show what needs to be done
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update the Unreleased section in CHANGELOG.md with your changes"
echo "2. Commit the version bump:"
echo "   git add VERSION CHANGELOG.md manifest.json"
echo "   git commit -m \"chore: bump version to ${NEW_VERSION}\""
echo "3. Push to main:"
echo "   git push origin main"
echo ""
echo "The CI/CD pipeline will automatically:"
echo "  - Run all tests (unit, integration, linting)"
echo "  - If all tests pass, create tag v${NEW_VERSION}"
echo "  - Trigger release workflow to create GitHub release"
echo ""
echo "Note: Release will only be created if all tests pass!"