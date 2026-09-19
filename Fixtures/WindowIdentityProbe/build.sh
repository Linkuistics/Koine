#!/bin/bash
# Builds and signs the window identity probe: test material for
# docs/verification/desktop-window-identity.md, run only inside a VM.
#
# usage: build.sh <output directory>   (prints the executable)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../../scripts/signing-env.sh
source "${HERE}/../../scripts/signing-env.sh"
mkdir -p "$1"
OUT="$(cd "$1" && pwd)/WindowIdentityProbe"
swiftc -O -swift-version 5 -target "$(uname -m)-apple-macos13.0" -o "${OUT}" "${HERE}/main.swift"
codesign --force --options runtime --timestamp=none --sign "${SIGNING_IDENTITY}" "${OUT}" 2>/dev/null
echo "${OUT}"
