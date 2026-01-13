#!/bin/sh
# SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>
# SPDX-License-Identifier: MIT
set -eu

usage() {
  echo "Usage: $0 <release-type> <version>"
  echo "  <release-type>: alpha | beta | rc | stable"
  echo "  <version>: version number, e.g. 1.0.0 or 1.0.0.1"
  exit 1
}

if [ $# -ne 2 ]; then
  usage
fi

RELEASE_TYPE="$1"
VERSION="$2"

case "$RELEASE_TYPE" in
  alpha|beta|rc)
    # Find the highest existing pre-release number for this version/type
    LAST_NUM=$(git tag | awk -F"${RELEASE_TYPE}\." "/^v${VERSION}-${RELEASE_TYPE}\.[0-9]+$/ {print \$2}" | sort -n | tail -n1)
    if [ -z "$LAST_NUM" ]; then
      NEXT_NUM=1
    else
      NEXT_NUM=$((LAST_NUM + 1))
    fi
    RELEASE_VERSION="${VERSION}-${RELEASE_TYPE}.$NEXT_NUM"
    ;;
  stable)
    RELEASE_VERSION="$VERSION"
    ;;
  *)
    echo "Error: Unknown release type '$RELEASE_TYPE'"
    usage
    ;;
esac

TAG="v$RELEASE_VERSION"
MESSAGE="Release $RELEASE_TYPE version $RELEASE_VERSION"

# Verify CHANGES.md top section matches the computed tag (without 'v') and today's date
TODAY=$(date +%Y-%m-%d)
CHANGES_HEADER="## $RELEASE_VERSION ($TODAY)"
CHANGES_LINE=$(head -n 1 CHANGES.md | tr -d '\r\n')
if [ "$CHANGES_LINE" != "$CHANGES_HEADER" ]; then
  echo "Error: Top of CHANGES.md does not match expected release version and date." >&2
  echo "Expected: $CHANGES_HEADER" >&2
  echo "Found:    $CHANGES_LINE" >&2
  exit 1
fi

cat <<EOF
About to run:
  git tag -a $TAG -m "$MESSAGE"
EOF

printf "Proceed? [y/N]: "
read -r ans
case "$ans" in
  y|Y)
    git tag -a "$TAG" -m "$MESSAGE"
    echo "Tag $TAG created."
    ;;
  *)
    echo "Aborted."
    exit 1
    ;;
esac
