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

echo "Verified ${APP_BUNDLE}: ${BUNDLE_ID}, team ${TEAM_ID}, hardened runtime, ${PROVIDER_FRAMEWORK_NAME}.framework embedded, desktop provider sealed in PlugIns."
