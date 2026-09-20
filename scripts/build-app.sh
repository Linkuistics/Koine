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
PROVIDER_FRAMEWORK="$(scripts/stage-provider-framework.sh release)"

# Wipe first: the bundle is a pure function of the source tree.
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS" "${APP_BUNDLE}/Contents/Resources" \
    "${APP_BUNDLE}/Contents/Frameworks" "${APP_BUNDLE}/Contents/PlugIns"
# Contents/PlugIns is the in-application provider root. The desktop provider is
# built by its own build definition against the staged framework's interface,
# placed here, and signed before the bundle that seals it.
Providers/DesktopProvider/build.sh "$(dirname "${PROVIDER_FRAMEWORK}")" "${APP_BUNDLE}/Contents/PlugIns" >/dev/null
cp "${BIN_DIR}/KoineApp" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
# The one framework image the host and every provider link. Its module
# interface is for building providers, not for the shipped application.
cp -R "${PROVIDER_FRAMEWORK}" "${APP_BUNDLE}/Contents/Frameworks/"
rm -rf "${APP_BUNDLE}/Contents/Frameworks/${PROVIDER_FRAMEWORK_NAME}.framework/Modules" \
    "${APP_BUNDLE}/Contents/Frameworks/${PROVIDER_FRAMEWORK_NAME}.framework/Versions/A/Modules"

# The application supplies the trusted run paths: the OS Swift runtime, which
# holds the back-deployment libraries the executable links by @rpath
# (libswiftCompatibilitySpan), and its own Frameworks directory. The build's
# other run paths name the build tree and the toolchain and are removed.
EXECUTABLE="${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
otool -l "${EXECUTABLE}" | awk '/LC_RPATH/ { getline; getline; print $2 }' | while IFS= read -r rpath; do
    [ "${rpath}" = "/usr/lib/swift" ] || install_name_tool -delete_rpath "${rpath}" "${EXECUTABLE}"
done
install_name_tool -add_rpath "@executable_path/../Frameworks" "${EXECUTABLE}"
cp App/Info.plist "${APP_BUNDLE}/Contents/Info.plist"

if [ "$(plist_string CFBundleIdentifier "${APP_BUNDLE}/Contents/Info.plist")" != "${BUNDLE_ID}" ]; then
    echo "Error: App/Info.plist CFBundleIdentifier is not ${BUNDLE_ID} (scripts/signing-env.sh)." >&2
    exit 1
fi
# The two version keys agreeing is signing-env.sh's to establish; this is the
# same check against the copy that actually ships, so a hand-edited bundle plist
# cannot carry a version the source never named.
if [ "$(plist_string CFBundleShortVersionString "${APP_BUNDLE}/Contents/Info.plist")" != "${MARKETING_VERSION}" ] ||
    [ "$(plist_string CFBundleVersion "${APP_BUNDLE}/Contents/Info.plist")" != "${MARKETING_VERSION}" ]; then
    echo "Error: the bundle's version keys are not both ${MARKETING_VERSION} (scripts/signing-env.sh)." >&2
    exit 1
fi

xattr -cr "${APP_BUNDLE}"

echo "Signing as \"${SIGNING_IDENTITY}\"..."
# Inside-out: nested code first, then the bundle that seals it.
codesign --force --options runtime --sign "${SIGNING_IDENTITY}" \
    "${APP_BUNDLE}/Contents/Frameworks/${PROVIDER_FRAMEWORK_NAME}.framework"
for provider in "${APP_BUNDLE}"/Contents/PlugIns/*.koineprovider; do
    codesign --force --options runtime --sign "${SIGNING_IDENTITY}" "${provider}"
done
codesign --force --options runtime --entitlements App/Koine.entitlements \
    --sign "${SIGNING_IDENTITY}" "${APP_BUNDLE}"

echo "Built ${APP_BUNDLE}"
