#!/usr/bin/env bash
# Build and sign the disposable descriptor-walk prompt probe (k174). Never launch it on
# the host: it is run only in an isolated TestAnyware VM.
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh
probe_root=".build/descriptor-walk-prompt"
rm -rf "${probe_root}" "${probe_root}.zip"
mkdir -p "${probe_root}/KoineK174Probe.app/Contents/MacOS"
cp App/Info.plist "${probe_root}/KoineK174Probe.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier dev.antony.Koine.K174Probe' "${probe_root}/KoineK174Probe.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName Koine K174 Probe' "${probe_root}/KoineK174Probe.app/Contents/Info.plist"
xcrun swiftc -swift-version 6 -target "arm64-apple-macosx${MINIMUM_OS}" \
  docs/verification/descriptor-walk-prompt/probe.swift \
  -o "${probe_root}/KoineK174Probe.app/Contents/MacOS/Koine"
codesign --force --options runtime --entitlements App/Koine.entitlements \
  --sign "${SIGNING_IDENTITY}" "${probe_root}/KoineK174Probe.app"
codesign --verify --strict "${probe_root}/KoineK174Probe.app"
/usr/bin/ditto -c -k "${probe_root}" "${probe_root}.zip"
