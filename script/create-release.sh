#!/bin/sh
# SPDX-FileCopyrightText: 2026 Mathieu Barbin <mathieu.barbin@gmail.com>
# SPDX-License-Identifier: MIT
#
# Extract release notes from CHANGES.md and create a GitHub release for a tag.
#
# Usage:
#   TAG=v1.0.0 ./script/create-release.sh
#   TAG=v1.0.0 ./script/create-release.sh --dry-run
#
# Expected environment:
#   TAG - the git tag (e.g. v1.0.0)
#
# Optional environment:
#   CHANGES_FILE - path to the changelog file (default: CHANGES.md)
set -eu

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

: "${TAG:?TAG must be set}"
CHANGES_FILE="${CHANGES_FILE:-CHANGES.md}"

RELEASE_BODY_FILE=$(mktemp)
trap 'rm -f "$RELEASE_BODY_FILE"' EXIT

# Remove leading 'v' if present for matching
VERSION="${TAG#v}"

# Extract the section for this version
awk -v heading="## $VERSION " '
  /^## / {
    if (index($0, heading) == 1) { flag=1; print; next }
    else if (flag) { exit }
  }
  flag { print }
' "$CHANGES_FILE" > "$RELEASE_BODY_FILE"

# Fallback if nothing found
if [ ! -s "$RELEASE_BODY_FILE" ]; then
  echo "No changelog entry found for $VERSION" > "$RELEASE_BODY_FILE"
fi

FLAGS="--draft --notes-file $RELEASE_BODY_FILE"
case "$TAG" in
  *-alpha*|*-beta*|*-rc*) FLAGS="$FLAGS --prerelease" ;;
esac

if [ "$DRY_RUN" = true ]; then
  echo "--- Release notes for $TAG ---"
  cat "$RELEASE_BODY_FILE"
  echo "--- Command ---"
  # shellcheck disable=SC2086
  echo gh release create "$TAG" $FLAGS
else
  # shellcheck disable=SC2086
  gh release create "$TAG" $FLAGS
fi
