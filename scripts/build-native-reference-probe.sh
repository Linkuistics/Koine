#!/usr/bin/env bash
# Disposable (k143): build and sign the native-reference acquisition helper. Launch only in an isolated VM.
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh
root=".build/native-reference-acquisition"
rm -rf "${root}" "${root}.zip"
app="${root}/KoineK143Probe.app"
mkdir -p "${app}/Contents/MacOS"
xcrun clang -fobjc-arc -Wall -Wno-deprecated-declarations -arch arm64 "-mmacosx-version-min=${MINIMUM_OS}" \
  docs/verification/native-reference-acquisition/probe.m -framework AppKit -framework CoreServices \
  -o "${app}/Contents/MacOS/KoineK143Probe"
cp App/Info.plist "${app}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier dev.antony.Koine.K143Probe" "${app}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName Koine K143 Probe" "${app}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleName Koine K143 Probe" "${app}/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable KoineK143Probe" "${app}/Contents/Info.plist"
codesign --force --options runtime --entitlements App/Koine.entitlements --sign "${SIGNING_IDENTITY}" "${app}"
codesign --verify --strict "${app}"
/usr/bin/ditto -c -k "${root}" "${root}.zip"
