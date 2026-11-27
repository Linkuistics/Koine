#!/bin/bash
# Builds and signs the keystroke probe: test material for
# docs/verification/keystroke-route-vm.md, run only inside a VM. It packages
# one binary in two forms. The TestAnyware agent starts the bare executable,
# which inherits the agent's consent. `open` starts each of two app bundles as
# its own responsible process, with no consent of its own.
# KeystrokeProbe.app and KeystrokeProbeControl.app differ only in their
# identifiers, so macOS can ask for consent for each one apart. A bundle runs
# in the background, so starting it does not change the front app.
#
# usage: build.sh <output directory>   (prints the executable, then each bundle)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../../scripts/signing-env.sh
source "${HERE}/../../scripts/signing-env.sh"
mkdir -p "$1"
DIR="$(cd "$1" && pwd)"
OUT="${DIR}/KeystrokeProbe"
swiftc -O -swift-version 5 -target "$(uname -m)-apple-macos${MINIMUM_OS}" -o "${OUT}" "${HERE}/main.swift"
codesign --force --options runtime --timestamp=none --sign "${SIGNING_IDENTITY}" "${OUT}" 2>/dev/null
# bundle <name>: the probe as an app bundle with its own identifier.
bundle() {
    local app="${DIR}/$1.app"
    rm -rf "${app}"
    mkdir -p "${app}/Contents/MacOS"
    cp "${OUT}" "${app}/Contents/MacOS/KeystrokeProbe"
    cat >"${app}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>dev.koine.test.$1</string>
  <key>CFBundleName</key><string>$1</string>
  <key>CFBundleExecutable</key><string>KeystrokeProbe</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>${MINIMUM_OS}</string>
  <key>LSBackgroundOnly</key><true/>
</dict></plist>
PLIST
    codesign --force --options runtime --timestamp=none --sign "${SIGNING_IDENTITY}" "${app}" 2>/dev/null
    echo "${app}"
}

echo "${OUT}"
bundle KeystrokeProbe
bundle KeystrokeProbeControl
