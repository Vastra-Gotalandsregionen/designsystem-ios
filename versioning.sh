#!/bin/bash

# Set variables
VERSION_FILE="VERSION"

# Fetch the current version
if [[ -f "$VERSION_FILE" ]]; then
    VERSION=$(cat "$VERSION_FILE")
else
    echo "Version file not found!"
    exit 1
fi

# Split the current version into Major, Minor, and Patch
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

# If version format is incorrect, initialize it
if [[ -z "$MAJOR" || -z "$MINOR" || -z "$PATCH" ]]; then
    echo "0.0.0" > "$VERSION_FILE"
    VERSION="0.0.0"
    IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
fi

# Check if the repository has any commits
if git rev-parse --verify HEAD >/dev/null 2>&1; then
    # There is at least one commit, compare changes with the previous commit
    GIT_DIFF_RANGE="HEAD^..HEAD"
    DIFF_CMD="git diff --name-status $GIT_DIFF_RANGE"
else
    # No commits yet (first commit), compare changes with an empty tree
    DIFF_CMD="git diff --cached --name-status"
fi

# Run the diff command to check for changes
FILES_ADDED_REMOVED=$($DIFF_CMD | grep -E '^[A|D]')
FILES_MODIFIED=$($DIFF_CMD | grep -E '^M')

# Determine whether to increase Minor or Patch version
if [[ ! -z "$FILES_ADDED_REMOVED" ]]; then
    echo "Files added or removed. Increasing Minor version."
    MINOR=$((MINOR + 1))
    PATCH=0  # Reset patch to 0 when Minor is incremented
elif [[ ! -z "$FILES_MODIFIED" ]]; then
    echo "Files modified. Increasing Patch version."
    PATCH=$((PATCH + 1))
else
    echo "No changes detected."
    exit 0  # Exit if no changes detected
fi

# Construct the new version
NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "Updating version: $VERSION -> $NEW_VERSION"

# Write the new version back to the version file
echo "$NEW_VERSION" > "$VERSION_FILE"

# Update LibraryInfo.swift with the new version
if [[ -f "update-package-version.sh" ]]; then
    echo "Updating LibraryInfo.swift..."
    ./update-package-version.sh
fi

# Commit the new version file and LibraryInfo.swift
git add "$VERSION_FILE"
git add Sources/DesignSystem/LibraryInfo.swift
git commit -m "Bump version to $NEW_VERSION [CI]"

# Add a tag with the new version (AFTER the commit)
git tag -a $NEW_VERSION -m "v$NEW_VERSION"
