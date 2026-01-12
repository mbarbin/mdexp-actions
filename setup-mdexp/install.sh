#!/bin/sh
# SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>
# SPDX-License-Identifier: MIT
set -eu

if [ -z "${MDEXP_VERSION:-}" ]; then
  echo "Error: MDEXP_VERSION environment variable must be set to a specific version (e.g., 0.0.20260403)." >&2
  exit 1
fi

BINARY="mdexp"
REPO="mbarbin/ocaml-mdexp"
VERSION="${MDEXP_VERSION}"
TMPDIR="${RUNNER_TEMP:-/tmp}"
INSTALL_DIR="${TMPDIR}/install/bin"
mkdir -p "${INSTALL_DIR}"

os=$(echo "${RUNNER_OS:-$(uname -s)}" | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)
bin_name="${BINARY}-${VERSION}-${os}-${arch}"
url="https://github.com/${REPO}/releases/download/${VERSION}/${bin_name}"

bin_path="${INSTALL_DIR}/${bin_name}"

echo "::group::Installing ${BINARY} https://github.com/${REPO}"
if command -v curl >/dev/null 2>&1; then
  curl -sSLf -o "${bin_path}" "$url"
elif command -v wget >/dev/null 2>&1; then
  wget -q -O "${bin_path}" "$url"
else
  echo "Error: curl or wget is required to download the ${BINARY} binary." >&2
  exit 1
fi
echo "::endgroup::"

echo "::group::Verifying build attestation for ${bin_name}"
if command -v gh >/dev/null 2>&1; then
  if [ -z "${GH_TOKEN:-}" ]; then
    echo "::warning::GH_TOKEN environment variable is not set. Skipping attestation verification."
  else
    GH_TOKEN="${GH_TOKEN}" gh attestation verify "${bin_path}" --owner mbarbin --signer-repo "${REPO}"
  fi
else
  echo "::warning::gh CLI not found, skipping attestation verification."
fi
echo "::endgroup::"

chmod +x "${bin_path}"
mv "${bin_path}" "${INSTALL_DIR}/${BINARY}"
echo "${INSTALL_DIR}" >> "$GITHUB_PATH"

echo "::group::${BINARY} --version"
"${INSTALL_DIR}/${BINARY}" --version
echo "::endgroup::"
