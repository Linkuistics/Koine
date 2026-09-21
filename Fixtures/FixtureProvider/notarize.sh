#!/bin/bash
# Makes a NOTARIZED copy of the fixture provider in a root of its own, approved
# there: the plain fixture's bundle, re-signed with a secure timestamp and the
# hardened runtime, which notarization requires and seal.sh deliberately omits,
# then submitted to Apple's notary service and waited on. It is the good bundle
# the loader's Gatekeeper check must not refuse when it arrives quarantined.
#
# The ticket is NOT stapled, because it cannot be: a stapled ticket lives in
# <bundle>/Contents/CodeResources, and a provider bundle is shallow, so
# `stapler staple` fails with error 73. A Mac that meets this bundle has to look
# its ticket up online, which is what the check is shown doing
# (docs/verification/provider-quarantine-precheck-vm.md).
#
# usage: notarize.sh <root holding Fixture.koineprovider> <output root>
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../../scripts/signing-env.sh
source "${HERE}/../../scripts/signing-env.sh"
PLAIN="$(cd "$1" && pwd)/Fixture.koineprovider"
[ -d "${PLAIN}" ] || {
    echo "Error: ${PLAIN} does not exist. Run: task fixture" >&2
    exit 1
}
rm -rf "$2"
mkdir -p "$2"
OUT="$(cd "$2" && pwd)"
BUNDLE="${OUT}/Fixture.koineprovider"
cp -R "${PLAIN}" "${BUNDLE}"
xattr -cr "${BUNDLE}"
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" "${BUNDLE}"

SUBMISSION_ZIP="${OUT}/submission.zip"
SUBMISSION_LOG="${OUT}/notarize.log"
ditto -c -k --keepParent "${BUNDLE}" "${SUBMISSION_ZIP}"
# One submission, waited on in the foreground; the verdict is read from it.
STATUS=0
xcrun notarytool submit "${SUBMISSION_ZIP}" \
    --keychain-profile "${NOTARY_PROFILE}" --wait >"${SUBMISSION_LOG}" 2>&1 || STATUS=$?
rm -f "${SUBMISSION_ZIP}"
SUBMISSION_ID="$(awk '/^ *id: /{print $2; exit}' "${SUBMISSION_LOG}")"
if [ "${STATUS}" != 0 ] || ! grep -qE '^ *status: Accepted' "${SUBMISSION_LOG}"; then
    {
        cat "${SUBMISSION_LOG}"
        echo "Error: the fixture's notarization did not return Accepted (profile \"${NOTARY_PROFILE}\")."
        [ -z "${SUBMISSION_ID}" ] ||
            xcrun notarytool log "${SUBMISSION_ID}" --keychain-profile "${NOTARY_PROFILE}" 2>&1 | sed 's/^/    /'
    } >&2
    exit 1
fi

TEAM="$(codesign -dvv "${BUNDLE}" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
printf '{ "providerId": "fixture", "teamIdentifier": "%s" }\n' "${TEAM}" >"${OUT}/fixture.approval.json"
echo "Notarized ${BUNDLE} (submission ${SUBMISSION_ID}); CDHash $(codesign -dvvv "${BUNDLE}" 2>&1 | sed -n 's/^CDHash=//p')" >&2
echo "${BUNDLE}"
