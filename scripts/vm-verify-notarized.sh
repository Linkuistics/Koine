#!/bin/bash
# Verifies the NOTARIZED, stapled Koine.app on a TestAnyware macOS clone whose
# Gatekeeper assessments are ENABLED, with the bundle carrying
# com.apple.quarantine — the one combination every earlier VM run lacked, and the
# gap four evidence documents defer to this stage. It shows a quarantined first
# launch with no right-click-Open and nothing stripped, an assessment that comes
# from the notarized rule rather than from assessments being off, the
# Accessibility consent dialog naming Koine on a notarized build, and the
# bundled desktop provider loading. In the per-user root, a quarantined
# un-notarized provider is refused by Koine before dlopen, with no system dialog
# and startup not held, and a quarantined notarized one loads. Nothing here runs
# the application on the host. The procedure and its recorded evidence:
# docs/verification/notarized-release-vm.md, and for the per-user providers
# docs/verification/provider-quarantine-precheck-vm.md
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
NOTARIZED_ROOT="${PRODUCTS}/NotarizedFixtureProviders"
if [ ! -d "${NOTARIZED_ROOT}/Fixture.koineprovider" ]; then
    echo "Error: ${NOTARIZED_ROOT}/Fixture.koineprovider does not exist. Run: task fixture:notarized" >&2
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
# patience than place_window's own 30s. On this path the window came up well
# after the endpoint descriptor did, when the service was held at a refused
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

step "A quarantined, UN-NOTARIZED same-team provider is refused before dlopen, with no system dialog"
# notarized-release-vm.md recorded the platform refusing this image at dlopen,
# behind a modal dialog that held the service until someone clicked Done. The
# loader now asks Gatekeeper first (spctl, which shows nothing) and refuses the
# provider itself, so none of that may be seen: no refusal in await_service's
# wait, no startup held, no dialog on screen, and Koine's own diagnostic instead.
[ -z "${REFUSAL_TEXT}" ] || fail "macOS raised its refusal dialog: the image reached dlopen"
[ -z "${BLOCKED_STARTUP}" ] || fail "the service's startup was held"
assert_no_system_refusal "un-notarized"
FIXTURE_DIAGNOSTIC="$(jq -r '.[] | select(.provider == "fixture") | .diagnostic // ""' <<<"${STATES}")"
jq -e '.[] | select(.provider == "fixture") | .state == "REJECTED"' >/dev/null <<<"${STATES}" ||
    fail "the fixture provider is not REJECTED"
grep -qF 'libFixtureProvider.dylib is quarantined and Gatekeeper refuses it (Unnotarized Developer ID)' <<<"${FIXTURE_DIAGNOSTIC}" ||
    fail "the refusal is not the loader's Gatekeeper refusal: ${FIXTURE_DIAGNOSTIC}"
! grep -q 'libFixtureProvider' <<<"${IMAGES}" ||
    fail "the refused plugin's image is mapped"
# Gatekeeper's verdict on the staged copy, asked the same way, as a user could.
guest "spctl --assess --type open --context context:primary-signature -vv \"${DATA}/ProviderStaging\"/Fixture-*/libFixtureProvider.dylib 2>&1" || true

step "Clearing the installed copy alone is not enough, and Koine still refuses it itself"
# The staged copy is named by content, which an extended attribute does not
# change, so Koine reuses the copy it made above and that copy keeps the
# attribute (README). What changes is that this is now Koine's refusal, not
# macOS's dialog.
quit_koine
guest "xattr -d -r com.apple.quarantine \"${PROVIDER_ROOT}/Fixture.koineprovider\"" || true
echo "Quarantine on the installed provider now: $(guest "xattr -p com.apple.quarantine \"${PROVIDER_ROOT}/Fixture.koineprovider\" 2>&1 || true")"
launch_and_read_state() {
    guest "open ${INSTALLED}" || true
    await_service
    ask "${Q_PROVIDERS}"
    STATES="$(sed -n 1p <<<"${RESPONSE}" | jq -c '[.data.koineManagement.providers[] | {provider, state, diagnostic}]')"
    echo "${STATES}"
    IMAGES="$(guest "lsof -p ${KOINE_PID} 2>/dev/null | grep -E 'Fixture|DesktopProvider'" || true)"
}
launch_and_read_state
[ -z "${REFUSAL_TEXT}" ] || fail "macOS raised its refusal dialog for the reused staged copy"
jq -e '.[] | select(.provider == "fixture") | .state == "REJECTED"' >/dev/null <<<"${STATES}" ||
    fail "the fixture loaded from a staged copy that is still quarantined"
FIXTURE_DIAGNOSTIC="$(jq -r '.[] | select(.provider == "fixture") | .diagnostic // ""' <<<"${STATES}")"
grep -qF 'Gatekeeper refuses it' <<<"${FIXTURE_DIAGNOSTIC}" || fail "not the Gatekeeper refusal: ${FIXTURE_DIAGNOSTIC}"

step "Doing what the diagnostic says: its own command deletes the staged copy, and the provider loads"
# The command is taken from the diagnostic verbatim, so what is shown here is
# that a user who follows it gets a loading provider — quoting included, since
# the staging directory is under "Application Support".
# shellcheck disable=SC2016  # the backquotes are the diagnostic's own
REMEDY="$(sed -n 's/.*delete its staged copy with `\(.*\)`\.$/\1/p' <<<"${FIXTURE_DIAGNOSTIC}")"
echo "Remedy from the diagnostic: ${REMEDY}"
[ -n "${REMEDY}" ] || fail "the diagnostic names no command to delete the staged copy"
quit_koine
# Judged by what it leaves, not by its exit status: the agent can repeat an exec
# it falsely reports as timed out, and a repeat of this finds nothing to delete.
guest "${REMEDY}" || true
LEFT="$(guest "ls -d \"${DATA}/ProviderStaging\"/Fixture-* 2>/dev/null | wc -l" | tr -d ' ')"
echo "Fixture staging copies left: ${LEFT}"
[ "${LEFT}" = 0 ] || fail "the diagnostic's own command left the staged copy in place"
launch_and_read_state
jq -e '.[] | select(.provider == "fixture") | .state == "ACTIVE"' >/dev/null <<<"${STATES}" ||
    fail "the fixture provider is still not ACTIVE with quarantine cleared and its staged copy deleted"
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

step "A quarantined NOTARIZED provider is not refused: Gatekeeper looks its ticket up"
# The good bundle the check must not refuse. It cannot carry a stapled ticket
# (Fixtures/FixtureProvider/notarize.sh), and this clone has never seen it, so
# the `notarized` code requirement — an offline lookup — is expected to fail on
# it here, which is why the loader does not use that requirement. Recorded, not
# asserted: it is the reason for the design, not the behaviour under test.
quit_koine
ditto -c -k "${NOTARIZED_ROOT}" "${WORK}/notarized-root.zip"
testanyware file upload "${WORK}/notarized-root.zip" /Users/admin/koine-notarized-root.zip >/dev/null
guest "rm -rf \"${PROVIDER_ROOT}\" && mkdir -p \"${PROVIDER_ROOT}\" && ditto -x -k \$HOME/koine-notarized-root.zip \"${PROVIDER_ROOT}\""
guest "xattr -w -r com.apple.quarantine \"${QUARANTINE}\" \"${PROVIDER_ROOT}/Fixture.koineprovider\""
echo "Quarantine on the notarized provider: $(guest "xattr -p com.apple.quarantine \"${PROVIDER_ROOT}/Fixture.koineprovider\"")"
guest "codesign -dvvv \"${PROVIDER_ROOT}/Fixture.koineprovider\" 2>&1 | grep -E '^(CDHash|Timestamp)='" || true
echo "The offline \`notarized\` requirement before Koine starts: $(guest "codesign -v -R=notarized \"${PROVIDER_ROOT}/Fixture.koineprovider\" 2>&1 && echo satisfied || echo not satisfied" | tail -1)"
launch_and_read_state
[ -z "${REFUSAL_TEXT}" ] || fail "macOS raised a refusal dialog for the notarized provider"
assert_no_system_refusal "notarized"
jq -e '.[] | select(.provider == "fixture") | .state == "ACTIVE"' >/dev/null <<<"${STATES}" ||
    fail "the quarantined, notarized provider was refused: $(jq -c '.[] | select(.provider == "fixture")' <<<"${STATES}")"
echo "${IMAGES}"
NOTARIZED_STAGED="$(grep 'libFixtureProvider' <<<"${IMAGES}" | grep -oE '/.*/ProviderStaging/Fixture-[0-9a-f]+' | head -1)"
[ -n "${NOTARIZED_STAGED}" ] || fail "the notarized provider's image is not mapped from a staging copy"
STAGED_QUARANTINE="$(guest "xattr -p com.apple.quarantine \"${NOTARIZED_STAGED}/libFixtureProvider.dylib\" 2>&1" || true)"
echo "Quarantine on the image that was loaded: ${STAGED_QUARANTINE}"
grep -q '^01[0-9a-f]1;' <<<"${STAGED_QUARANTINE}" ||
    fail "the loaded copy is not quarantined, so Gatekeeper's check was never asked of it"
guest "spctl --assess --type open --context context:primary-signature -vv \"${NOTARIZED_STAGED}/libFixtureProvider.dylib\" 2>&1" || true
echo "The offline \`notarized\` requirement after: $(guest "codesign -v -R=notarized \"${PROVIDER_ROOT}/Fixture.koineprovider\" 2>&1 && echo satisfied || echo not satisfied" | tail -1)"
ask "${Q_FIXTURE}"
grep -q '"greeting":"' <<<"${RESPONSE}" || fail "the notarized provider served no field"
jq -e '.[] | select(.provider == "desktop") | .state == "ACTIVE"' >/dev/null <<<"${STATES}" ||
    fail "the bundled desktop provider is no longer ACTIVE"
testanyware screen capture -o "${LOG%.log}-notarized-provider.png" >/dev/null

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
