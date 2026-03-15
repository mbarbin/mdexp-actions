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
if [ -z "${MDEXP_DIGEST:-}" ]; then
  echo "Error: MDEXP_DIGEST environment variable must be set to an expected digest (e.g., sha256:abc123...)." >&2
  exit 1
fi

DIGEST="${MDEXP_DIGEST}"
TMPDIR="${RUNNER_TEMP:-/tmp}"
INSTALL_DIR="${TMPDIR}/install/bin"
mkdir -p "${INSTALL_DIR}"

os=$(echo "${RUNNER_OS:-$(uname -s)}" | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)
bin_name="${BINARY}-${VERSION}-${os}-${arch}"
url="https://github.com/${REPO}/releases/download/${VERSION}/${bin_name}"

bin_path="${INSTALL_DIR}/${bin_name}"
archive_name="${bin_name}.tar.gz"
archive_url="https://github.com/${REPO}/releases/download/${VERSION}/${archive_name}"
archive_path="${TMPDIR}/${archive_name}"

echo "::group::Installing ${BINARY} https://github.com/${REPO}"

# Try downloading the compressed archive first, fall back to raw binary.
download_archive=true
if command -v curl >/dev/null 2>&1; then
  if ! curl -sSLf -o "${archive_path}" "${archive_url}"; then
    download_archive=false
    echo "Archive not available, falling back to raw binary download."
    curl -sSLf -o "${bin_path}" "$url"
  fi
elif command -v wget >/dev/null 2>&1; then
  if ! wget -q -O "${archive_path}" "${archive_url}"; then
    download_archive=false
    echo "Archive not available, falling back to raw binary download."
    wget -q -O "${bin_path}" "$url"
  fi
else
  echo "Error: curl or wget is required to download the ${BINARY} binary." >&2
  exit 1
fi

if [ "${download_archive}" = true ]; then
  tar -xzf "${archive_path}" -C "${TMPDIR}"
  mv "${TMPDIR}/${BINARY}" "${bin_path}"
  rm -f "${archive_path}"
fi
echo "::endgroup::"

echo "::group::Verifying binary digest"
algorithm="${DIGEST%%:*}"
expected_hash="${DIGEST#*:}"
case "${algorithm}" in
  sha256)
    if command -v sha256sum >/dev/null 2>&1; then
      actual_hash=$(sha256sum "${bin_path}" | cut -d ' ' -f 1)
    elif command -v shasum >/dev/null 2>&1; then
      actual_hash=$(shasum -a 256 "${bin_path}" | cut -d ' ' -f 1)
    else
      echo "::error title=Missing tool::sha256sum or shasum is required to verify the binary digest"
      exit 1
    fi
    ;;
  *)
    echo "::error title=Unsupported algorithm::Digest algorithm '${algorithm}' is not supported. Supported: sha256"
    exit 1
    ;;
esac
if [ "${actual_hash}" != "${expected_hash}" ]; then
  echo "::error title=Digest mismatch::${algorithm}: expected ${expected_hash} but got ${actual_hash} for ${bin_name}"
  exit 1
fi
echo "Digest verified: ${algorithm}:${actual_hash}"
echo "::endgroup::"

echo "::group::Verifying build attestation for ${bin_name}"
if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh CLI is required to verify build attestation." >&2
  exit 1
fi
gh attestation verify "${bin_path}" --repo "${REPO}" --format json
echo "::endgroup::"

chmod +x "${bin_path}"
mv "${bin_path}" "${INSTALL_DIR}/${BINARY}"
echo "${INSTALL_DIR}" >> "$GITHUB_PATH"

echo "::group::${BINARY} --version"
"${INSTALL_DIR}/${BINARY}" --version
echo "::endgroup::"
