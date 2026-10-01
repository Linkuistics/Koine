#!/bin/bash
# Builds and signs the test browser of docs/verification/open-url-vm.md: an application that
# the system treats as a web browser and that records the URLs it is handed. Test material,
# run only inside a VM.
#
# usage: build.sh <output directory>   (prints the application bundle)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../../scripts/signing-env.sh
source "${HERE}/../../scripts/signing-env.sh"
mkdir -p "$1"
OUT="$(cd "$1" && pwd)/UrlBrowser.app"
rm -rf "${OUT}"
mkdir -p "${OUT}/Contents/MacOS"
swiftc -O -swift-version 5 -target "$(uname -m)-apple-macos${MINIMUM_OS}" -o "${OUT}/Contents/MacOS/UrlBrowser" "${HERE}/main.swift"
cat >"${OUT}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>dev.koine.test.UrlBrowser</string>
  <key>CFBundleName</key><string>UrlBrowser</string>
  <key>CFBundleDisplayName</key><string>UrlBrowser</string>
  <key>CFBundleExecutable</key><string>UrlBrowser</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>${MINIMUM_OS}</string>
  <key>NSPrincipalClass</key><string>NSApplication</string>
  <key>CFBundleURLTypes</key><array>
    <dict>
      <key>CFBundleURLName</key><string>Web site URL</string>
      <key>CFBundleURLSchemes</key><array><string>http</string><string>https</string></array>
    </dict>
  </array>
  <key>CFBundleDocumentTypes</key><array>
    <dict>
      <key>CFBundleTypeName</key><string>HTML document</string>
      <key>CFBundleTypeRole</key><string>Viewer</string>
      <key>LSItemContentTypes</key><array><string>public.html</string></array>
    </dict>
  </array>
</dict></plist>
PLIST
codesign --force --options runtime --timestamp=none --sign "${SIGNING_IDENTITY}" "${OUT}" 2>/dev/null
echo "${OUT}"
