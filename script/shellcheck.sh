#!/bin/sh
# SPDX-FileCopyrightText: 2026 Mathieu Barbin <mathieu.barbin@gmail.com>
# SPDX-License-Identifier: MIT
set -eu

FILES=$(git ls-files '*.sh' | sort)

if [ -z "$FILES" ]; then
  echo "No shell scripts found."
  exit 0
fi

echo "🔍 Linting shell scripts with shellcheck..."
echo ""
for f in $FILES; do
  echo "  📄 $f"
done
echo ""

# shellcheck disable=SC2086
shellcheck --shell=sh --format=tty $FILES

echo ""
echo "✅ All shell scripts passed shellcheck."
