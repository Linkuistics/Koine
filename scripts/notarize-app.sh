#!/bin/bash
# Submits the built, signed Koine.app to Apple's notary service, waits for the
# verdict, staples the ticket to the bundle and checks the staple. The release
# artifact is zipped AFTER stapling, because the ticket lives in the bundle: a
# zip made before the staple carries no ticket and a machine that downloads it
# has to reach Apple to launch.
#
# There is no fallback. A missing credential or a rejected submission fails the
# task; it never leaves an unnotarized bundle behind as though it had succeeded.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

if [ ! -d "${APP_BUNDLE}" ]; then
    echo "Error: ${APP_BUNDLE} does not exist. Run: task app" >&2
    exit 1
fi

# The submission's version is the bundle's own, not App/Info.plist's, so a stale
# bundle cannot be notarized and released under the version now in the source.
BUNDLE_VERSION="$(plist_string CFBundleShortVersionString "${APP_BUNDLE}/Contents/Info.plist")"
if [ "${BUNDLE_VERSION}" != "${MARKETING_VERSION}" ]; then
    {
        echo "Error: ${APP_BUNDLE} is version ${BUNDLE_VERSION}, but ${INFO_PLIST} says ${MARKETING_VERSION}."
        echo "  The bundle predates the version it would be released as. Run: task app"
    } >&2
    exit 1
fi

# Asked of notarytool itself rather than of the keychain, and before anything is
# uploaded: a submission is minutes of Apple's time to discover a typo with.
PROBE="$(xcrun notarytool history --keychain-profile "${NOTARY_PROFILE}" 2>&1 || true)"
if grep -q 'No Keychain password item found' <<<"${PROBE}"; then
    {
        echo "Error: no notary keychain profile \"${NOTARY_PROFILE}\"."
        echo
        echo "  Koine notarizes with an App Store Connect API key, stored once. Create the key"
        echo "  at https://appstoreconnect.apple.com/access/integrations/api with the Developer"
        echo "  role, download its AuthKey_<KEYID>.p8 (downloadable once), and store it:"
        echo
        echo "    xcrun notarytool store-credentials \"${NOTARY_PROFILE}\" \\"
        echo "        --key /path/to/AuthKey_<KEYID>.p8 \\"
        echo "        --key-id <KEYID> \\"
        echo "        --issuer <ISSUER-UUID>"
        echo
        echo "  KEYID is the key's Key ID and ISSUER-UUID the team's Issuer ID, both shown on"
        echo "  that page. Name a different profile with KOINE_NOTARY_PROFILE."
        echo "  Koine is never released unnotarized, so there is no way past this."
    } >&2
    exit 1
fi

mkdir -p .build/app
SUBMISSION_ZIP=".build/app/${APP_NAME}-submission.zip"
SUBMISSION_LOG=".build/app/notarize-${MARKETING_VERSION}.log"

echo "Submitting ${APP_BUNDLE} (${MARKETING_VERSION}) as profile \"${NOTARY_PROFILE}\"..."
rm -f "${SUBMISSION_ZIP}"
ditto -c -k --keepParent "${APP_BUNDLE}" "${SUBMISSION_ZIP}"

# One submission, waited on in the foreground. Nothing here launches the wait in
# the background and infers the verdict from the launcher returning.
STATUS=0
xcrun notarytool submit "${SUBMISSION_ZIP}" \
    --keychain-profile "${NOTARY_PROFILE}" --wait 2>&1 | tee "${SUBMISSION_LOG}" || STATUS=$?

SUBMISSION_ID="$(awk '/^ *id: /{print $2; exit}' "${SUBMISSION_LOG}")"
if [ "${STATUS}" != 0 ] || ! grep -qE '^ *status: Accepted' "${SUBMISSION_LOG}"; then
    {
        echo
        echo "Error: notarization did not return Accepted."
        if [ -n "${SUBMISSION_ID}" ]; then
            echo "  Apple's reasons for submission ${SUBMISSION_ID}:"
            xcrun notarytool log "${SUBMISSION_ID}" --keychain-profile "${NOTARY_PROFILE}" 2>&1 | sed 's/^/    /'
            echo
            echo "  An unsigned nested binary or a missing secure timestamp is scripts/build-app.sh's"
            echo "  to fix. Do not weaken App/Koine.entitlements to make a submission pass."
        fi
    } >&2
    exit 1
fi
echo "Accepted (submission ${SUBMISSION_ID})."

echo "Stapling the ticket..."
xcrun stapler staple "${APP_BUNDLE}"
xcrun stapler validate "${APP_BUNDLE}"

rm -f "${SUBMISSION_ZIP}" ".build/app/${RELEASE_ARTIFACT}"
ditto -c -k --keepParent "${APP_BUNDLE}" ".build/app/${RELEASE_ARTIFACT}"

echo
echo "Notarized and stapled ${APP_BUNDLE}."
echo "  Release artifact: .build/app/${RELEASE_ARTIFACT}"
echo "  Release tag:      ${RELEASE_TAG}"
echo "  Next: task app:verify"
