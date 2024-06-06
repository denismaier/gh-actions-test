#!/bin/bash
set -euo pipefail

# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Get the current version from the .version file
current_version=$(jq -r '.version' src/manifest.json)

# Check if the changelog contains a ##-level heading for the current release
if ! grep -q "## v$current_version" CHANGELOG.md; then
    echo "Error: CHANGELOG.md does not contain a heading for version v$current_version."
    exit 1
fi

echo "Pre-commit checks passed."
