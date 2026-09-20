#!/bin/bash
# Verifies the NOTARIZED, stapled Koine.app on a TestAnyware macOS clone whose
# Gatekeeper assessments are ENABLED, with the bundle carrying
# com.apple.quarantine — the one combination every earlier VM run lacked, and the
# gap four evidence documents defer to this stage. It shows a quarantined first
# launch with no right-click-Open and nothing stripped, an assessment that comes
# from the notarized rule rather than from assessments being off, the
# Accessibility consent dialog naming Koine on a notarized build, and both a
# quarantined same-team provider in the per-user root and the bundled desktop
# provider loading. Nothing here runs the application on the host. The procedure
# and its recorded evidence: docs/verification/notarized-release-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# Before a VM is spun: an unnotarized bundle would make every assertion below
# read `rejected`, which says nothing about Koine and everything about the
# operator. This is the same check task app:verify makes, made early.
if ! xcrun stapler validate "${APP_BUNDLE}" >/dev/null 2>&1; then
    {
        echo "Error: ${APP_BUNDLE} carries no stapled notarization ticket."
        echo "  This run exists to assess a notarized build. Run: task app && task app:notarize"
    } >&2
    exit 1
fi

PRODUCTS="$(swift build --show-bin-path)"
APPROVED_ROOT="${PRODUCTS}/FixtureProviders"
if [ ! -d "${APPROVED_ROOT}/Fixture.koineprovider" ]; then
    echo "Error: ${APPROVED_ROOT}/Fixture.koineprovider does not exist. Run: task fixture:variants" >&2
    exit 1
fi

# shellcheck disable=SC2034  # both read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="notarized-"
# Tall enough that the Security section of the Privacy & Security pane is on
# screen; enable_developer_id explains why that is the mechanism.
KOINE_VM_DISPLAY="1920x2160"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-verify-gatekeeper-lib.sh
source scripts/vm-verify-gatekeeper-lib.sh

GRANT_LABEL="vm-notarized-script"
Q_PROVIDERS='{ koineManagement { providers { provider version state diagnostic } } }'
Q_FIXTURE='{ fixtureInfo { greeting } }'
# Guest-side, like DATA: $HOME is expanded by the guest's shell, never here.
PROVIDER_ROOT="${DATA}/Providers"

start_vm
enforce_gatekeeper
install_app_quarantined

step "Gatekeeper's verdict on the quarantined bundle, on its own merits"
ASSESSMENT="$(guest "spctl -a -t execute -vv ${INSTALLED} 2>&1")" || fail "Gatekeeper rejected the notarized bundle: ${ASSESSMENT}"
echo "${ASSESSMENT}"
grep -q 'accepted' <<<"${ASSESSMENT}" || fail "the assessment is not accepted"
grep -q 'source=Notarized Developer ID' <<<"${ASSESSMENT}" ||
    fail "accepted under a rule other than the notarized one"
! grep -q 'override=' <<<"${ASSESSMENT}" ||
    fail "accepted only because assessments are off, which is what this run exists to avoid"

step "A quarantined same-team fixture provider in the per-user root"
ditto -c -k "${APPROVED_ROOT}" "${WORK}/root.zip"
testanyware file upload "${WORK}/root.zip" /Users/admin/koine-provider-root.zip >/dev/null
guest "rm -rf \"${PROVIDER_ROOT}\" && mkdir -p \"${PROVIDER_ROOT}\" && ditto -x -k \$HOME/koine-provider-root.zip \"${PROVIDER_ROOT}\""
guest "xattr -w -r com.apple.quarantine \"${QUARANTINE}\" \"${PROVIDER_ROOT}/Fixture.koineprovider\""
PROVIDER_QUARANTINE="$(guest "xattr -p com.apple.quarantine \"${PROVIDER_ROOT}/Fixture.koineprovider\"")"
echo "Quarantine on the provider: ${PROVIDER_QUARANTINE}"
grep -q '^0181;' <<<"${PROVIDER_QUARANTINE}" || fail "the fixture provider is not quarantined"
guest "cat \"${PROVIDER_ROOT}/fixture.approval.json\"; echo"

first_launch_quarantined
# Only the notarized dialog reports a malware check that came back clean. The
# unnotarized one says Apple could not verify the app, and the App Store-only one
# says it was not downloaded from the App Store; both were seen on this golden
# while this procedure was established, which is how this is known to
# discriminate rather than to accept whatever is on screen. The shared helper
# asserts that a dialog appeared and that it is not a refusal; this is the
# assertion that makes it the NOTARIZED dialog, and it is this run's own.
grep -q 'none was detected' <<<"${DIALOG_TREE}" ||
    fail "the first-run dialog does not report that Apple checked the app; this is not the notarized path"

await_service
guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1 || fail "no endpoint descriptor after the first launch"
KOINE_PID="$(guest "pgrep -f ${INSTALLED}/Contents/MacOS" 2>&1 | grep -E '^[0-9]+$' | tail -1)"
echo "Koine pid: ${KOINE_PID}"
[ -n "${KOINE_PID}" ] || fail "Koine is not running after the first launch"

# Only now, with any Gatekeeper dialog cleared off the screen — and with more
# patience than place_window's own 30s. On this path the window comes up well
# after the endpoint descriptor does: the service had been held at the refused
# dlopen, and a run was failed with "the management window did not appear" whose
# failure screenshot showed the window present and fully rendered.
for _ in $(seq 1 45); do
    element '.id=="grant-label"' 2>/dev/null | grep -q '^{' && break
    sleep 2
done
place_window

step "Nothing was stripped: the attribute is still on the launched bundle"
# LaunchServices rewrites the flags field once the user has approved a launch, so
# the value is expected to change; what matters is that the attribute is still
# there — neither the install route nor the launch removed it, and the bundle was
# assessed as a quarantined one throughout.
QUARANTINE_AFTER="$(guest "xattr -p com.apple.quarantine ${INSTALLED}")"
echo "Quarantine before launch: ${QUARANTINE_BEFORE}"
echo "Quarantine after launch:  ${QUARANTINE_AFTER}"
[ -n "${QUARANTINE_AFTER}" ] || fail "the quarantine attribute was removed by the launch"

step "A grant through the window, for management and the desktop"
# Not fixture:read yet: that capability exists only while the fixture provider is
# loaded, and the case immediately below is the one where it is not.
create_grant "${GRANT_LABEL}" "${CREDENTIAL_FILE}" "koine:manage" "desktop:read"

step "The bundled desktop provider loads from Contents/PlugIns under quarantine"
# The application's own notarization ticket covers everything inside the bundle,
# so Koine's own provider is not subject to what happens to the per-user one.
ask "${Q_PROVIDERS}"
STATES="$(sed -n 1p <<<"${RESPONSE}" | jq -c '[.data.koineManagement.providers[] | {provider, state, diagnostic}]')"
echo "${STATES}"
jq -e '.[] | select(.provider == "desktop") | .state == "ACTIVE"' >/dev/null <<<"${STATES}" ||
    fail "the bundled desktop provider is not ACTIVE"
IMAGES="$(guest "lsof -p ${KOINE_PID} 2>/dev/null | grep -E 'DesktopProvider|Fixture'")"
echo "${IMAGES}"
# Every provider is dlopen'ed from Koine's own content-addressed staging copy
# rather than from the root it was found in — the behaviour signed-app-provider-vm.md
# already records for the per-user root, and it holds for the bundled one too.
# So the witness that the BUNDLED provider loaded is a Desktop- staging entry,
# together with Contents/PlugIns holding exactly that provider in the guest.
grep 'DesktopProvider' <<<"${IMAGES}" | grep -qF "/ProviderStaging/Desktop-" ||
    fail "the desktop provider's image was not mapped from a Desktop- staging copy"
guest "ls ${INSTALLED}/Contents/PlugIns" | grep -qx 'Desktop.koineprovider' ||
    fail "the in-application provider root does not hold exactly Desktop.koineprovider"

step "A quarantined, UN-NOTARIZED same-team provider is refused at dlopen"
# This is the answer to the question signed-app-provider-vm.md deferred in these
# words: "whether a quarantined, un-notarized same-team plugin still passes
# dlopen is not shown here". It does not. The fixture is signed by the same team
# and carries Koine's approval record, but seal.sh signs it with no secure
# timestamp and nothing notarizes it, so Gatekeeper judges it on its own —
# downstream of Koine's approval check and team comparison, both of which passed.
[ -n "${REFUSAL_TEXT}" ] || fail "macOS raised no Gatekeeper refusal for the quarantined plugin"
# The consequence, not just the refusal: the service had not begun listening
# while that dialog stood, which the wait above had to clear to get this far.
[ -n "${BLOCKED_STARTUP}" ] ||
    fail "the refusal did not block startup, so this run has not shown what it reports"
grep -q 'libFixtureProvider' <<<"${REFUSAL_TEXT}" ||
    fail "the refusal does not name the plugin"
grep -q 'could not verify' <<<"${REFUSAL_TEXT}" ||
    fail "the refusal is not Gatekeeper's could-not-verify one"
jq -e '.[] | select(.provider == "fixture") | .state != "ACTIVE"' >/dev/null <<<"${STATES}" ||
    fail "the fixture provider is ACTIVE although macOS refused to open its image"
! grep -q 'libFixtureProvider' <<<"${IMAGES}" ||
    fail "the refused plugin's image is mapped"

step "With the quarantine cleared, as approving an install would, the same provider loads"
# The complement, and the reason the refusal above is about quarantine rather
# than about the bundle, the team or the approval record: nothing else changes.
quit_koine
guest "xattr -d -r com.apple.quarantine \"${PROVIDER_ROOT}/Fixture.koineprovider\"" || true
echo "Quarantine on the installed provider now: $(guest "xattr -p com.apple.quarantine \"${PROVIDER_ROOT}/Fixture.koineprovider\" 2>&1 || true")"
REFUSAL_TEXT=""
launch_and_read_state() {
    guest "open ${INSTALLED}" || true
    await_service
    ask "${Q_PROVIDERS}"
    STATES="$(sed -n 1p <<<"${RESPONSE}" | jq -c '[.data.koineManagement.providers[] | {provider, state}]')"
    echo "${STATES}"
}
launch_and_read_state

# Clearing the installed copy alone is expected NOT to be enough, and the run
# records that rather than working around it silently.
if ! jq -e '.[] | select(.provider == "fixture") | .state == "ACTIVE"' >/dev/null <<<"${STATES}"; then
    step "Clearing the installed copy is not enough: Koine reuses its staged copy, which keeps the attribute"
    # Koine stages each provider under a digest of its CONTENT, and removing an
    # extended attribute does not change content — so the digest is unchanged,
    # the directory staged during the first launch is reused, and it is still the
    # quarantined copy that gets dlopen'ed. The proof is the value itself: the
    # staged copy carries the identical timestamp and UUID this run wrote onto
    # the installed bundle, so it was inherited at staging time and not applied
    # afresh. The staged tree is also read-only, so a user cannot clear it there.
    STAGED_QUARANTINE="$(guest "xattr -p com.apple.quarantine \"${DATA}/ProviderStaging\"/Fixture-*/libFixtureProvider.dylib 2>/dev/null" || true)"
    echo "Quarantine on the staged copy:  ${STAGED_QUARANTINE:-(none)}"
    echo "Quarantine this run installed:  ${PROVIDER_QUARANTINE}"
    grep -qF "${PROVIDER_QUARANTINE#*;}" <<<"${STAGED_QUARANTINE}" ||
        echo "(the staged value differs from the installed one; it was not inherited at staging)"
    guest "ls -ld \"${DATA}/ProviderStaging\"/Fixture-*" || true

    step "Invalidating the staged copy is what actually works"
    # The remedy the finding implies: the staged copy has to go, or be stripped.
    # With it gone, Koine re-stages from the cleared source and nothing else in
    # this run has changed — which is what makes the refusal attributable to the
    # quarantine attribute rather than to the bundle, the team or the approval.
    quit_koine
    guest "chmod -R u+w \"${DATA}/ProviderStaging\" && rm -rf \"${DATA}/ProviderStaging\"/Fixture-*" || true
    REFUSAL_TEXT=""
    launch_and_read_state
    STAGED_AFTER="$(guest "xattr -p com.apple.quarantine \"${DATA}/ProviderStaging\"/Fixture-*/libFixtureProvider.dylib 2>&1" || true)"
    echo "Quarantine on the re-staged copy: ${STAGED_AFTER}"
fi

jq -e '.[] | select(.provider == "fixture") | .state == "ACTIVE"' >/dev/null <<<"${STATES}" ||
    fail "the fixture provider is still not ACTIVE with quarantine cleared"
jq -e '.[] | select(.provider == "desktop") | .state == "ACTIVE"' >/dev/null <<<"${STATES}" ||
    fail "the bundled desktop provider is no longer ACTIVE"

create_grant "${GRANT_LABEL}-fixture" "${CREDENTIAL_FILE}" "koine:manage" "desktop:read" "fixture:read"
ask "${Q_FIXTURE}"
grep -q '"greeting":"' <<<"${RESPONSE}" || fail "the per-user provider served no field"

# ACTIVE is the loader's own word; the mapped image is the independent witness
# that dlopen happened, and where the image came from.
IMAGES="$(guest "lsof -p ${KOINE_PID} 2>/dev/null | grep -E 'Fixture|DesktopProvider'")"
echo "${IMAGES}"
grep 'libFixtureProvider' <<<"${IMAGES}" | grep -qF "/ProviderStaging/Fixture-" ||
    fail "the provider's image was not mapped from a Fixture- staging copy"

step "The Accessibility consent dialog names Koine on the notarized build"
place_window
click '.id=="request-accessibility"'
sleep 3
DIALOG="$(testanyware screen find-text "${DIALOG_TEXT}" --timeout 20 --require-match --json)" ||
    fail "the request showed no consent dialog"
jq -c '.detections' <<<"${DIALOG}"
jq -e '[.detections[].text] | any(test("Koine"))' >/dev/null <<<"${DIALOG}" ||
    fail "the consent dialog does not name Koine"
testanyware screen capture -o "${LOG%.log}-consent-dialog.png" >/dev/null
echo "Shown by: $(guest "pgrep -lx ${DIALOG_HOST}" || true)"
testanyware input key escape >/dev/null
sleep 2

step "Quit Koine"
quit_koine

step "PASSED — transcript in ${LOG}"
