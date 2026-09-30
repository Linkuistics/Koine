#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh
probe_root=".build/protected-path-metadata"
mkdir -p "${probe_root}/KoineK73Probe.app/Contents/MacOS"
cp App/Info.plist "${probe_root}/KoineK73Probe.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier dev.antony.Koine.K73Probe' "${probe_root}/KoineK73Probe.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName Koine K73 Probe' "${probe_root}/KoineK73Probe.app/Contents/Info.plist"
xcrun swiftc -swift-version 6 -target "arm64-apple-macosx${MINIMUM_OS}" \
  docs/verification/protected-path-metadata/probe.swift \
  -o "${probe_root}/KoineK73Probe.app/Contents/MacOS/Koine"
codesign --force --options runtime --entitlements App/Koine.entitlements \
  --sign "${SIGNING_IDENTITY}" "${probe_root}/KoineK73Probe.app"
codesign --verify --strict "${probe_root}/KoineK73Probe.app"

for location in Desktop Documents Downloads; do
  fixture="${probe_root}/Fixture${location}.app"
  mkdir -p "${fixture}/Contents/MacOS"
  cp App/Info.plist "${fixture}/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier dev.antony.Koine.K73Fixture${location}" "${fixture}/Contents/Info.plist"
  # Do not borrow a host executable whose Mach-O floor may exceed the guest OS.
  cp "${probe_root}/KoineK73Probe.app/Contents/MacOS/Koine" "${fixture}/Contents/MacOS/Koine"
  codesign --force --options runtime --entitlements App/Koine.entitlements \
    --sign "${SIGNING_IDENTITY}" "${fixture}"
  codesign --verify --strict "${fixture}"
done
xcrun swiftc -swift-version 6 -target "arm64-apple-macosx${MINIMUM_OS}" \
  docs/verification/protected-path-metadata/make-alias.swift \
  -o "${probe_root}/make-alias"
/usr/bin/ditto -c -k "${probe_root}" "${probe_root}.zip"
