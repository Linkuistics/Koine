#!/usr/bin/env bash
# Build only; execution belongs to the one authorized disposable guest.
set -euo pipefail
IFS=$'\n\t'
cd "$(dirname "$0")/.."
source scripts/signing-env.sh
probe_root=".build/bookmark-name-resolution"
probe_app="${probe_root}/K158Probe.app"
mkdir -p "${probe_app}/Contents/MacOS"
xcrun clang -fobjc-arc -Wall -Wextra -Werror -arch arm64 "-mmacosx-version-min=${MINIMUM_OS}" \
  docs/verification/bookmark-name-resolution/probe.m -framework Foundation \
  -o "${probe_app}/Contents/MacOS/K158Probe"
cat >"${probe_app}/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>dev.antony.Koine.K158Probe</string>
<key>CFBundleExecutable</key><string>K158Probe</string>
<key>CFBundleName</key><string>K158Probe</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force --options runtime --entitlements App/Koine.entitlements --sign "${SIGNING_IDENTITY}" "${probe_app}"
codesign --verify --strict "${probe_app}"
/usr/bin/ditto -c -k "${probe_root}" "${probe_root}.zip"
