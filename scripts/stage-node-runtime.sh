#!/bin/bash
# Puts a pinned Node runtime in .build/node, for the contract-only client to run
# under inside a TestAnyware VM. The golden macOS image has python3 and curl and
# no node, so the run carries its own rather than depending on the guest
# reaching nodejs.org while it runs. The archive is checked against the version's
# published SHASUMS256.txt before it is ever unpacked or uploaded.
#
# Prints the path of the verified archive on stdout.
set -euo pipefail

cd "$(dirname "$0")/.."

NODE_VERSION="${KOINE_NODE_VERSION:-v24.21.0}"
ARCHIVE="node-${NODE_VERSION}-darwin-arm64.tar.xz"
DIR=".build/node"
mkdir -p "${DIR}"

if [ ! -f "${DIR}/${ARCHIVE}" ]; then
    echo "Downloading ${ARCHIVE}" >&2
    curl -fsSL -o "${DIR}/${ARCHIVE}.part" "https://nodejs.org/dist/${NODE_VERSION}/${ARCHIVE}"
    mv "${DIR}/${ARCHIVE}.part" "${DIR}/${ARCHIVE}"
fi
curl -fsSL -o "${DIR}/SHASUMS256.txt" "https://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txt"

EXPECTED="$(awk -v a="${ARCHIVE}" '$2 == a { print $1 }' "${DIR}/SHASUMS256.txt")"
[ -n "${EXPECTED}" ] || { echo "Error: ${ARCHIVE} is not listed in SHASUMS256.txt" >&2; exit 1; }
ACTUAL="$(shasum -a 256 "${DIR}/${ARCHIVE}" | cut -d' ' -f1)"
if [ "${ACTUAL}" != "${EXPECTED}" ]; then
    echo "Error: ${ARCHIVE} does not match its published digest (${ACTUAL} against ${EXPECTED})" >&2
    exit 1
fi
echo "${ARCHIVE}: ${ACTUAL} matches its published digest" >&2
echo "${DIR}/${ARCHIVE}"
