#!/usr/bin/env bash
# Disposable (k134): build and sign the long-action prototype bundles. Launch only in an isolated VM.
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh
root=".build/long-action-route"
rm -rf "${root}" "${root}.zip"
mkdir -p "${root}"
xcrun clang -fobjc-arc -Wno-deprecated-declarations -arch arm64 "-mmacosx-version-min=${MINIMUM_OS}" \
  docs/verification/long-action-route/probe.m -framework AppKit -framework CoreServices \
  -o "${root}/exe"
make_bundle() { # name identifier display
  local app="${root}/$1.app"
  mkdir -p "${app}/Contents/MacOS"
  cp App/Info.plist "${app}/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $2" "${app}/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $3" "${app}/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName $3" "${app}/Contents/Info.plist" 2>/dev/null || true
  cp "${root}/exe" "${app}/Contents/MacOS/Koine"
}
make_bundle KoineK134Probe dev.antony.Koine.K134Probe "Koine K134 Probe"
make_bundle KoineK134Fixture dev.antony.Koine.K134Fixture "Koine K134 Fixture"
make_bundle KoineK134Witness dev.antony.Koine.K134Witness "Koine K134 Witness"
plist="${root}/KoineK134Witness.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes array' "${plist}"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0 dict' "${plist}"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:CFBundleTypeName string K134 witness document' "${plist}"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Editor' "${plist}"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions array' "${plist}"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:0 string k134w' "${plist}"
for app in KoineK134Probe KoineK134Fixture KoineK134Witness; do
  codesign --force --options runtime --entitlements App/Koine.entitlements \
    --sign "${SIGNING_IDENTITY}" "${root}/${app}.app"
  codesign --verify --strict "${root}/${app}.app"
done
rm "${root}/exe"
/usr/bin/ditto -c -k "${root}" "${root}.zip"
