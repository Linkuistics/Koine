#!/bin/bash
# Verifies the assembled bundle: a strict signature check, the hardened runtime,
# and the designated requirement the rest of the system will hold it to.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

if [ ! -d "${APP_BUNDLE}" ]; then
    echo "Error: ${APP_BUNDLE} does not exist. Run: task app" >&2
    exit 1
fi

# The version is one value: the bundle carries the version the source names, so
# a stale bundle is never verified, notarized or released as the current one.
BUNDLE_MARKETING="$(plist_string CFBundleShortVersionString "${APP_BUNDLE}/Contents/Info.plist")"
BUNDLE_BUILD="$(plist_string CFBundleVersion "${APP_BUNDLE}/Contents/Info.plist")"
if [ "${BUNDLE_MARKETING}" != "${MARKETING_VERSION}" ] || [ "${BUNDLE_BUILD}" != "${MARKETING_VERSION}" ]; then
    {
        echo "Error: ${APP_BUNDLE} is version ${BUNDLE_MARKETING} (build ${BUNDLE_BUILD}), not ${MARKETING_VERSION}."
        echo "  ${INFO_PLIST} is the one source of the version the tag, the artifact and the cask take."
        echo "  Rebuild it: task app"
    } >&2
    exit 1
fi

# The deployment floor is one value, and the sites that state it cannot all be
# derived. A bundle whose floor disagrees with the source is a stale bundle.
scripts/check-minimum-os.sh

codesign --verify --strict --deep --verbose=2 "${APP_BUNDLE}"

DETAILS="$(codesign --display --verbose=2 "${APP_BUNDLE}" 2>&1)"
if ! grep -q '^CodeDirectory.*flags=.*runtime' <<<"${DETAILS}"; then
    echo "Error: the hardened runtime flag is not set." >&2
    exit 1
fi

# The team is the identity's, read from the signature rather than assumed.
TEAM_ID="$(sed -n 's/^TeamIdentifier=//p' <<<"${DETAILS}")"
if [ -z "${TEAM_ID}" ] || [ "${TEAM_ID}" = "not set" ]; then
    echo "Error: the signature has no team identifier (ad-hoc or self-signed?)." >&2
    exit 1
fi
if [[ "${SIGNING_IDENTITY}" != *"(${TEAM_ID})"* ]]; then
    echo "Error: signed by team ${TEAM_ID}, which \"${SIGNING_IDENTITY}\" does not name." >&2
    exit 1
fi

# The provider framework: embedded once, signed by the same team, and found
# only through the application's own run path.
EXECUTABLE="${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
FRAMEWORK="${APP_BUNDLE}/Contents/Frameworks/${PROVIDER_FRAMEWORK_NAME}.framework"
INSTALL_NAME="@rpath/${PROVIDER_FRAMEWORK_NAME}.framework/Versions/A/${PROVIDER_FRAMEWORK_NAME}"
if [ "$(otool -D "${FRAMEWORK}/Versions/A/${PROVIDER_FRAMEWORK_NAME}" | tail -1)" != "${INSTALL_NAME}" ]; then
    echo "Error: the embedded framework does not have the install name ${INSTALL_NAME}." >&2
    exit 1
fi
if ! otool -L "${EXECUTABLE}" | grep -qF "${INSTALL_NAME} "; then
    echo "Error: the executable does not link ${INSTALL_NAME}; the framework was linked statically?" >&2
    exit 1
fi
RPATHS="$(otool -l "${EXECUTABLE}" | awk '/LC_RPATH/ { getline; getline; print $2 }')"
if [ "${RPATHS}" != $'/usr/lib/swift\n@executable_path/../Frameworks' ]; then
    echo "Error: the executable's run paths are not exactly /usr/lib/swift and @executable_path/../Frameworks:" >&2
    echo "${RPATHS}" >&2
    exit 1
fi
FRAMEWORK_TEAM="$(codesign --display --verbose=2 "${FRAMEWORK}" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
if [ "${FRAMEWORK_TEAM}" != "${TEAM_ID}" ]; then
    echo "Error: the framework is signed by team ${FRAMEWORK_TEAM:-none}, not ${TEAM_ID}." >&2
    exit 1
fi

# The in-application provider root holds exactly the desktop provider: signed by
# the same team with the hardened runtime, linking the framework by its install
# name, and embedding no copy of it.
PLUGINS="${APP_BUNDLE}/Contents/PlugIns"
DESKTOP="${PLUGINS}/Desktop.koineprovider"
if [ "$(ls -A "${PLUGINS}" 2>/dev/null)" != "Desktop.koineprovider" ]; then
    echo "Error: ${PLUGINS} does not hold exactly Desktop.koineprovider." >&2
    exit 1
fi
codesign --verify --strict --verbose=2 "${DESKTOP}"
DESKTOP_DETAILS="$(codesign --display --verbose=2 "${DESKTOP}" 2>&1)"
if [ "$(sed -n 's/^TeamIdentifier=//p' <<<"${DESKTOP_DETAILS}")" != "${TEAM_ID}" ] ||
    ! grep -q '^CodeDirectory.*flags=.*runtime' <<<"${DESKTOP_DETAILS}"; then
    echo "Error: the desktop provider is not signed by team ${TEAM_ID} with the hardened runtime." >&2
    exit 1
fi
if ! otool -L "${DESKTOP}/libDesktopProvider.dylib" | grep -qF "${INSTALL_NAME} "; then
    echo "Error: the desktop provider does not link ${INSTALL_NAME}." >&2
    exit 1
fi
if [ -n "$(find "${DESKTOP}" -name '*.framework')" ]; then
    echo "Error: the desktop provider embeds a framework." >&2
    exit 1
fi

echo "Designated requirement:"
codesign --display --requirements - "${APP_BUNDLE}" 2>/dev/null | sed -n 's/^designated => /  /p'

# The bundle must satisfy the requirement clients of its identity rely on.
codesign --verify --strict \
    -R="identifier \"${BUNDLE_ID}\" and anchor apple generic and certificate leaf[subject.OU] = \"${TEAM_ID}\"" \
    "${APP_BUNDLE}"

# The notarization ticket, stapled into the bundle. `stapler validate` reads the
# ticket from the bundle itself, so this passes with the network down, which is
# the whole point of stapling: a downloaded copy launches without asking Apple.
if ! STAPLE="$(xcrun stapler validate "${APP_BUNDLE}" 2>&1)"; then
    {
        echo "${STAPLE}"
        echo "Error: ${APP_BUNDLE} carries no stapled notarization ticket."
        echo "  Koine is released notarized. Run: task app:notarize"
    } >&2
    exit 1
fi

# Gatekeeper's own verdict on the bundle. Two things are asserted, and the second
# is the one that is easy to lose: `accepted` alone is worth nothing on a machine
# whose assessments are disabled, because spctl accepts everything there and says
# so in an override= line. The source must be the notarized rule.
ASSESSMENT="$(spctl --assess --type execute -vv "${APP_BUNDLE}" 2>&1)" || {
    echo "${ASSESSMENT}" >&2
    echo "Error: Gatekeeper rejects ${APP_BUNDLE}." >&2
    exit 1
}
echo "${ASSESSMENT}" | sed 's/^/  /'
if grep -q 'override=' <<<"${ASSESSMENT}"; then
    {
        echo "Error: Gatekeeper accepted the bundle only because assessments are off here:"
        grep 'override=' <<<"${ASSESSMENT}" | sed 's/^/    /'
        echo "  That says nothing about the bundle. Re-run where \`spctl --status\` is enabled."
    } >&2
    exit 1
fi
if ! grep -q 'source=Notarized Developer ID' <<<"${ASSESSMENT}"; then
    {
        echo "Error: Gatekeeper accepted the bundle under a rule other than the notarized one."
        echo "  Expected source=Notarized Developer ID."
    } >&2
    exit 1
fi

echo "Verified ${APP_BUNDLE}: ${MARKETING_VERSION}, notarized and stapled, ${BUNDLE_ID}, team ${TEAM_ID}, hardened runtime, ${PROVIDER_FRAMEWORK_NAME}.framework embedded, desktop provider sealed in PlugIns."
