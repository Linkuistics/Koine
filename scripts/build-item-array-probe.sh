#!/usr/bin/env bash
# Disposable (k146): build and sign the item-array submission helper and the short recording application.
# Launch only in an isolated VM.
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh
root=".build/item-array-submission"
rm -rf "${root}" "${root}.zip"
src="docs/verification/item-array-submission"
build() { # name bundle-id source
  local app="${root}/$1.app"
  mkdir -p "${app}/Contents/MacOS"
  xcrun clang -fobjc-arc -Wall -Wno-deprecated-declarations -arch arm64 "-mmacosx-version-min=${MINIMUM_OS}" \
    "${src}/$3" -framework AppKit -framework CoreServices -o "${app}/Contents/MacOS/$1"
  cp App/Info.plist "${app}/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $2" "${app}/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $1" "${app}/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName $1" "${app}/Contents/Info.plist" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable $1" "${app}/Contents/Info.plist"
  codesign --force --options runtime --entitlements App/Koine.entitlements --sign "${SIGNING_IDENTITY}" "${app}"
  codesign --verify --strict "${app}"
}
build K146Probe dev.antony.Koine.K146Probe probe.m
build K146Rec dev.antony.Koine.K146Rec recorder.m
/usr/bin/ditto -c -k "${root}" "${root}.zip"
