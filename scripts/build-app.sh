#!/bin/bash
# Assembles and signs Koine.app around the Swift package's KoineApp executable.
# Package.swift stays the only build definition.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# Preconditions before anything is built or destroyed. There is no ad-hoc
# fallback: a differently signed bundle has a different designated requirement,
# which silently resets TCC and login-item state.
if ! security find-identity -v -p codesigning | grep -qF "\"${SIGNING_IDENTITY}\""; then
    {
        echo "Error: no valid code-signing identity \"${SIGNING_IDENTITY}\" in the keychain."
        echo "  Install that Developer ID certificate with its private key, or name another"
        echo "  identity with KOINE_SIGNING_IDENTITY=\"<name from the list below>\"."
        echo "  Koine is never ad-hoc signed. Valid identities here:"
        security find-identity -v -p codesigning | sed 's/^/    /'
    } >&2
    exit 1
fi

echo "Building KoineApp (release)..."
swift build -c release --product KoineApp
BIN_DIR="$(swift build -c release --show-bin-path)"

# Wipe first: the bundle is a pure function of the source tree.
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS" "${APP_BUNDLE}/Contents/Resources"
# Contents/Frameworks arrives with the provider framework; nested code is then
# signed here, inside-out, before the bundle.
cp "${BIN_DIR}/KoineApp" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp App/Info.plist "${APP_BUNDLE}/Contents/Info.plist"

if [ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "${APP_BUNDLE}/Contents/Info.plist")" != "${BUNDLE_ID}" ]; then
    echo "Error: App/Info.plist CFBundleIdentifier is not ${BUNDLE_ID} (scripts/signing-env.sh)." >&2
    exit 1
fi

xattr -cr "${APP_BUNDLE}"

echo "Signing as \"${SIGNING_IDENTITY}\"..."
codesign --force --options runtime --entitlements App/Koine.entitlements \
    --sign "${SIGNING_IDENTITY}" "${APP_BUNDLE}"

echo "Built ${APP_BUNDLE}"
