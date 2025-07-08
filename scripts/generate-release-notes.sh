#!/bin/bash

# Generate release notes from CHANGELOG.md
# Usage: ./generate-release-notes.sh <version>

set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    echo "Error: Version parameter required"
    echo "Usage: $0 <version>"
    exit 1
fi

if [[ ! -f "CHANGELOG.md" ]]; then
    echo "Error: CHANGELOG.md not found"
    exit 1
fi

# Extract changelog section for this version
changelog=$(awk -v ver="## [$VERSION]" '
    $0 ~ ver { found=1; next }
    found && /^## \[/ { exit }
    found { print }
' CHANGELOG.md)

if [[ -z "$changelog" ]]; then
    echo "Error: No changelog entry found for version $VERSION"
    exit 1
fi

# Generate release notes
cat <<EOF
## Installation

\`\`\`bash
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/v$VERSION/install.sh | bash
\`\`\`

## What's Changed

$changelog

---

**Full Changelog**: https://github.com/douglaslinsmeyer/claude-environment/blob/main/CHANGELOG.md
EOF