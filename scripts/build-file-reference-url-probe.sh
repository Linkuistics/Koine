#!/usr/bin/env bash
# k149: build only; execute solely in the authorized disposable guest.
set -euo pipefail
IFS=$'\n\t'
cd "$(dirname "$0")/.."
source scripts/signing-env.sh
probe_root=".build/file-reference-url-acquisition"
probe_app="${probe_root}/K149Probe.app"
mkdir -p "${probe_app}/Contents/MacOS"
xcrun clang -fobjc-arc -Wall -Wextra -arch arm64 "-mmacosx-version-min=${MINIMUM_OS}" \
  docs/verification/file-reference-url-acquisition/probe.m -framework Foundation -framework CoreFoundation \
  -o "${probe_app}/Contents/MacOS/K149Probe"
cat > "${probe_app}/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>dev.antony.Koine.K149Probe</string>
<key>CFBundleExecutable</key><string>K149Probe</string>
<key>CFBundleName</key><string>K149Probe</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force --options runtime --entitlements App/Koine.entitlements --sign "${SIGNING_IDENTITY}" "${probe_app}"
codesign --verify --strict "${probe_app}"
/usr/bin/ditto -c -k "${probe_root}" "${probe_root}.zip"
