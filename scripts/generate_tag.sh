#!/bin/bash

# Extract PR Title
PR_TITLE="$1"
echo "PR Title: '$PR_TITLE'"

# Extract version with 'v' prefix from the title
VERSION=$(echo "$PR_TITLE" | grep -oP 'v[0-9]+\.[0-9]+\.[0-9]+')
echo "Extracted Version: '$VERSION'"

# Check if VERSION was extracted successfully
if [ -z "$VERSION" ]; then
  echo "Error: Title does not contain a valid version format 'vX.Y.Z'."
  exit 1
fi

# Use the version directly as the tag
NEW_TAG="$VERSION"
echo "Generated Tag: $NEW_TAG"

echo "NEW_TAG=$NEW_TAG" >> $GITHUB_ENV