#!/bin/bash
# Builds and signs ConsentPromptControl.app: test material for
# docs/verification/desktop-references-and-permission-vm.md, run only inside a
# VM. It asks for Accessibility consent with the prompt option, which Koine
# never does, so that the verification sees what a consent dialog looks like.
#
# usage: build.sh <output directory>   (prints the bundle)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../../scripts/signing-env.sh
source "${HERE}/../../scripts/signing-env.sh"
mkdir -p "$1"
BUNDLE="$(cd "$1" && pwd)/ConsentPromptControl.app"
rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}/Contents/MacOS"
swiftc -O -swift-version 5 -target "$(uname -m)-apple-macos13.0" \
    -o "${BUNDLE}/Contents/MacOS/ConsentPromptControl" "${HERE}/main.swift"
cat >"${BUNDLE}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>dev.antony.Koine.fixture.consent-prompt-control</string>
<key>CFBundleExecutable</key><string>ConsentPromptControl</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force --options runtime --timestamp=none --sign "${SIGNING_IDENTITY}" "${BUNDLE}" 2>/dev/null
echo "${BUNDLE}"
