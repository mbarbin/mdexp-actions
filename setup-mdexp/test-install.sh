#!/bin/sh
# SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>
# SPDX-License-Identifier: MIT
set -eu

# Usage: ./test-install.sh <version> <digest>
if [ $# -ne 2 ]; then
  echo "Usage: $0 <mdexp-version> <mdexp-digest>" >&2
  exit 1
fi

BINARY="mdexp"
MDEXP_VERSION="$1"
MDEXP_DIGEST="$2"
FAKE_TMPDIR="$(mktemp -d)"
trap 'rm -rf "${FAKE_TMPDIR}"' EXIT

# Set up fake GitHub Actions environment variables
export MDEXP_VERSION
export MDEXP_DIGEST
export RUNNER_TEMP="${FAKE_TMPDIR}"
export RUNNER_OS="Linux"
export GITHUB_PATH="${FAKE_TMPDIR}/github_path.txt"

# This is where the install script is installing the binary.
INSTALL_DIR="${FAKE_TMPDIR}/install/bin"

# Remove any previous binary in the temp dir
rm -f "${INSTALL_DIR}/${BINARY}"

# Run the install script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"${SCRIPT_DIR}/install.sh"

# Check if the binary was installed
if [ -x "${INSTALL_DIR}/${BINARY}" ]; then
  echo "${BINARY} binary installed successfully at ${INSTALL_DIR}/${BINARY}"
  "${INSTALL_DIR}/${BINARY}" --version
else
  echo "Error: ${BINARY} binary was not installed in ${INSTALL_DIR}/" >&2
  exit 1
fi

# Show the updated GITHUB_PATH
if [ -f "${FAKE_TMPDIR}/github_path.txt" ]; then
  echo "GITHUB_PATH contents:"
  cat "${FAKE_TMPDIR}/github_path.txt"
fi
