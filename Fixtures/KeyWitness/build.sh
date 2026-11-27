#!/bin/bash
# Builds and signs the key witness: test material for
# docs/verification/keystroke-route-vm.md, run only inside a VM.
#
# usage: build.sh <output directory>   (prints the application bundle)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../../scripts/signing-env.sh
source "${HERE}/../../scripts/signing-env.sh"
mkdir -p "$1"
OUT="$(cd "$1" && pwd)/KeyWitness.app"
rm -rf "${OUT}"
mkdir -p "${OUT}/Contents/MacOS"
swiftc -O -swift-version 5 -target "$(uname -m)-apple-macos${MINIMUM_OS}" -o "${OUT}/Contents/MacOS/KeyWitness" "${HERE}/main.swift"
cat >"${OUT}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>dev.koine.test.KeyWitness</string>
  <key>CFBundleName</key><string>KeyWitness</string>
  <key>CFBundleDisplayName</key><string>Key Witness</string>
  <key>CFBundleExecutable</key><string>KeyWitness</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>${MINIMUM_OS}</string>
  <key>NSPrincipalClass</key><string>NSApplication</string>
</dict></plist>
PLIST
codesign --force --options runtime --timestamp=none --sign "${SIGNING_IDENTITY}" "${OUT}" 2>/dev/null
echo "${OUT}"
