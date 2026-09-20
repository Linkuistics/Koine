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

# The library snapshots to depth 14, which reaches Koine's own windows. System
# Settings' Security section is deeper, so the depth becomes a variable here and
# the library's default is kept for every other window.
SNAPSHOT_DEPTH=14
# The default is inside the expansion, not only in the assignment above. Under
# `set -u` an unset SNAPSHOT_DEPTH makes this abort in the subshell that
# element() runs it in, and the retry loops reading that just report the window
# never appearing — which is exactly what one caller's cleanup caused.
snapshot() { testanyware agent snapshot --mode full --window "${SNAPSHOT_WINDOW:-${APP_NAME}}" --depth "${SNAPSHOT_DEPTH:-14}" --json; }

GRANT_LABEL="vm-notarized-script"
Q_PROVIDERS='{ koineManagement { providers { provider version state diagnostic } } }'
Q_FIXTURE='{ fixtureInfo { greeting } }'
# Guest-side, like DATA: $HOME is expanded by the guest's shell, never here.
PROVIDER_ROOT="${DATA}/Providers"

# A quarantine value in the shape LaunchServices writes for a download: flags
# 0181 (downloaded, not yet opened), a timestamp, the agent, and a UUID. The
# substitutions are the guest's, so they are deliberately not expanded here.
# shellcheck disable=SC2016
QUARANTINE='0181;$(printf %x $(date +%s));Safari;$(uuidgen)'

# enforce_gatekeeper: the whole point of this run, and it is two switches rather
# than one. `spctl --status --verbose` reports them separately, and only the
# first has a command. Both are asserted, because with assessments enabled and
# developer id disabled the clone is "App Store only": a NOTARIZED Developer ID
# bundle is rejected there exactly as an unnotarized one is, and a run made in
# that state would record `rejected` and prove nothing — the same empty result
# the four evidence documents this run exists to close already carry.
enforce_gatekeeper() {
    step "Put the clone into a Gatekeeper-enforcing state"
    echo "Before: $(guest 'spctl --status --verbose' 2>&1 | tr '\n' '; ')"
    # Apple restricts DISABLING assessments on recent macOS, not enabling them.
    guest "echo ${VM_PASSWORD} | sudo -S spctl --global-enable" || true
    local status
    status="$(guest 'spctl --status --verbose' 2>&1)"
    echo "After:  $(tr '\n' '; ' <<<"${status}")"
    grep -qx 'assessments enabled' <<<"${status}" ||
        fail "assessments are still disabled; this run cannot say anything about notarization"
    grep -qx 'developer id enabled' <<<"${status}" || enable_developer_id
}

# enable_developer_id: the second switch, which no spctl spelling reaches on
# macOS 26.5 — --developer-id-enable is unrecognized, and --enable --label
# "Developer ID" answers "This operation is no longer supported". It is set where
# a user sets it, and the guest is left in the macOS DEFAULT posture ("App Store
# & Known Developers"), which is still strictly more enforcing than the golden
# image's assessments-disabled state.
#
# Three things about this pane were each established the hard way:
#  * The control sits ~1600pt down a pane that does not scroll under `input
#    scroll`, and the accessibility tree reports its position in an unclipped
#    layout space that does not move. So the guest is started tall enough
#    (KOINE_VM_DISPLAY) for the control to be on screen, and the reported
#    position is then simply correct.
#  * `agent press` refuses these controls with HTTP 400 — the same refusal
#    vm-verify-lib.sh records for Koine's own SwiftUI controls — so the popup and
#    its menu item are clicked over VNC at their centres.
#  * The menu opens into a window of its own, and the menu bar's items are in the
#    tree too with zero width. Both are why this snapshots every window and keeps
#    only items that have a size.
enable_developer_id() {
    echo "The clone is App Store-only; setting the default posture in System Settings."
    guest 'open "x-apple.systempreferences:com.apple.preference.security"' || true
    SNAPSHOT_WINDOW="System Settings"
    SNAPSHOT_DEPTH=24
    sleep 8
    testanyware agent window-move --window "${SNAPSHOT_WINDOW}" --x 0 --y 0 >/dev/null || true
    testanyware agent window-resize --window "${SNAPSHOT_WINDOW}" --width 1400 --height 2100 >/dev/null || true
    testanyware agent window-focus --window "${SNAPSHOT_WINDOW}" >/dev/null || true
    sleep 3

    click '.platformRole=="AXPopUpButton"'
    sleep 1
    local item
    item="$(testanyware agent snapshot --mode full --depth 26 --json |
        jq -c '[.windows[] | .elements[]? | .. | objects
               | select(has("platformRole"))
               | select(.platformRole == "AXMenuItem" and .sizeWidth > 0)
               | select((.label // "") | test("Known Developers"))][0]')"
    [ "${item}" != null ] && [ -n "${item}" ] ||
        fail "the Allow-applications menu offers no \"App Store & Known Developers\""
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '"\(.positionX + .sizeWidth / 2 | floor) \(.positionY + .sizeHeight / 2 | floor)"' <<<"${item}") >/dev/null
    sleep 3

    # The change is authorised by an administrator. The prompt is a sheet on the
    # pane rather than a window of its own, so it is confirmed by reading the
    # screen; nothing below would work if the password went to the wrong place.
    testanyware screen find-text "Enter your password to allow this" --timeout 20 --require-match --json >/dev/null ||
        fail "no authentication sheet appeared for the security setting"
    testanyware input type "${VM_PASSWORD}" >/dev/null
    sleep 1
    testanyware input key return >/dev/null
    sleep 6
    testanyware input key q --modifiers cmd >/dev/null
    # Restore the depth rather than unsetting it: 14 is the value every other
    # window here is read at, and leaving it unset broke two runs.
    unset SNAPSHOT_WINDOW
    SNAPSHOT_DEPTH=14
    sleep 2

    local after
    after="$(guest 'spctl --status --verbose' 2>&1)"
    echo "After System Settings: $(tr '\n' '; ' <<<"${after}")"
    grep -qx 'assessments enabled' <<<"${after}" || fail "assessments were turned off by that change"
    grep -qx 'developer id enabled' <<<"${after}" ||
        fail "the clone is still App Store-only, so a notarized build would be rejected here too and this run would prove nothing"
}

# install_app_quarantined: as the library's install_app, except that the bundle
# is given com.apple.quarantine explicitly — `testanyware file upload` sets none
# — and that the attribute is asserted present BEFORE anything launches. A run
# that discovers the attribute missing afterwards has proved nothing.
install_app_quarantined() {
    step "Install the notarized bundle and quarantine it, as a download arrives"
    ditto -c -k --keepParent "${APP_BUNDLE}" "${WORK}/Koine.zip"
    testanyware file upload "${WORK}/Koine.zip" /tmp/Koine.zip >/dev/null
    testanyware file upload scripts/vm-verify-client.sh /Users/admin/vm-verify-client.sh >/dev/null
    guest "ditto -x -k /tmp/Koine.zip /Applications"
    guest "xattr -w -r com.apple.quarantine \"${QUARANTINE}\" ${INSTALLED}"
    QUARANTINE_BEFORE="$(guest "xattr -p com.apple.quarantine ${INSTALLED}")"
    echo "Quarantine on the bundle: ${QUARANTINE_BEFORE}"
    grep -q '^0181;' <<<"${QUARANTINE_BEFORE}" || fail "the bundle is not quarantined; the launch below would prove nothing"
    echo "Quarantined files inside it: $(guest "xattr -r -p com.apple.quarantine ${INSTALLED} 2>/dev/null | wc -l" | tr -d ' ')"
    guest "xcrun stapler validate ${INSTALLED} 2>&1" || fail "the ticket is not stapled into the installed copy"
}

# await_service: waits for the endpoint descriptor, dismissing any Gatekeeper
# plugin refusal that stands in the way, then waits for the management window.
#
# The refused plugin does not merely fail to load: it BLOCKS KOINE'S STARTUP.
# Measured directly — Koine's process running, its dialog on screen, and no
# endpoint.json in its data directory minutes later. Providers are dlopen'ed
# while the service comes up and macOS's refusal is a modal dialog a person must
# dismiss, so the server never begins listening until someone clicks Done.
# REFUSAL_TEXT and BLOCKED_STARTUP are left set for the assertions further down.
REFUSAL_TEXT=""
BLOCKED_STARTUP=""
await_service() {
    # The service first, the window second, and with more patience than the library's
    # launch(): a quarantined first launch goes through Gatekeeper's approval path
    # and was measured taking longer than place_window's own 30s, so calling that
    # first reports "the management window did not appear" for an application that
    # was merely still starting.
    # The refused plugin does not merely fail to load: it BLOCKS KOINE'S STARTUP.
    # Measured directly — Koine's process running, its dialog on screen, and no
    # endpoint.json in its data directory minutes later. The dlopen of a provider
    # happens while the service is coming up, and macOS's refusal is a modal dialog
    # that a person has to dismiss, so the server never begins listening until
    # someone clicks Done. That is why this is dismissed inside the wait rather than
    # after it: waiting for the endpoint first is a deadlock, and it cost two runs.
    REFUSAL_TEXT=""
    BLOCKED_STARTUP=""
    missing=0
    for attempt in $(seq 1 45); do
        if guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1; then break; fi

        TREE="$(testanyware agent snapshot --mode full --depth 20 --json 2>/dev/null |
            jq -r '[.windows[] | .elements[]? | .. | objects
                   | select(.platformRole == "AXStaticText") | .value // empty] | join("\n")' 2>/dev/null || true)"
        if grep -qi 'libFixtureProvider' <<<"${TREE}"; then
            if [ -z "${REFUSAL_TEXT}" ]; then
                REFUSAL_TEXT="$(grep -i 'libFixtureProvider' <<<"${TREE}")"
                step "macOS refuses the quarantined plugin, and Koine cannot finish starting until it is dismissed"
                # Recorded at the moment it is true: the process is up, the dialog is
                # on screen, and there is no endpoint descriptor.
                BLOCKED_STARTUP="$(guest "pgrep -f ${INSTALLED}/Contents/MacOS >/dev/null && [ ! -e \"${DATA}/endpoint.json\" ] && echo blocked" || true)"
                echo "Koine running with no endpoint descriptor: ${BLOCKED_STARTUP:-no}"
                echo "${REFUSAL_TEXT}" | sed 's/^/  /'
                testanyware screen capture -o "${LOG%.log}-plugin-refused.png" >/dev/null
            fi
            # Attempted on EVERY iteration while the dialog stands, never latched
            # after one go: a single click that lands too early leaves the dialog up
            # and the service down, and the loop then waits out its whole bound on a
            # dismissal that never happened. That is what two runs actually died of.
            DONE_BUTTON="$(testanyware agent snapshot --mode full --depth 20 --json 2>/dev/null |
                jq -c '[.windows[] | .elements[]? | .. | objects | select(has("platformRole"))
                       | select(.platformRole == "AXButton" and .sizeWidth > 0)
                       | select((.label // "") == "Done")][0]' 2>/dev/null || echo null)"
            if [ "${DONE_BUTTON}" != null ] && [ -n "${DONE_BUTTON}" ]; then
                # shellcheck disable=SC2046
                testanyware input click $(jq -r '"\(.positionX + .sizeWidth / 2 | floor) \(.positionY + .sizeHeight / 2 | floor)"' <<<"${DONE_BUTTON}") >/dev/null || true
            fi
        fi

        # Liveness, from the host. `testanyware vm list` is NOT the instrument for
        # this: it reported "Running clones: (none)" for a clone tart listed as
        # `running` and whose agent answered every call, and trusting it aborted a
        # good run with a false "the clone died". tart's own state column is what
        # the TestAnyware guidance says to read, and three consecutive misses rather
        # than one keeps a momentary listing hiccup from ending a run.
        if [ $((attempt % 5)) = 0 ] && command -v tart >/dev/null; then
            if tart list 2>/dev/null | grep "${VM_ID}" | grep -q running; then
                missing=0
            else
                missing=$((missing + 1))
                [ "${missing}" -lt 3 ] || fail "tart no longer lists ${VM_ID} as running; the clone died mid-run"
            fi
        fi
        sleep 2
    done
    guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1 || fail "no endpoint descriptor after the launch"
    KOINE_PID="$(guest "pgrep -f ${INSTALLED}/Contents/MacOS" 2>&1 | grep -E '^[0-9]+$' | tail -1)"
    echo "Koine pid: ${KOINE_PID}"
    [ -n "${KOINE_PID}" ] || fail "Koine is not running after the launch"
    # More patience than place_window's own 30s: on this path the window comes up
    # well after the descriptor, and a run was failed with "the management window
    # did not appear" whose failure screenshot showed it present and rendered.
    for _ in $(seq 1 45); do
        element '.id=="grant-label"' 2>/dev/null | grep -q '^{' && break
        sleep 2
    done
    place_window
}

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

step "First launch of the quarantined copy: plain open, no right-click-Open"
# `open` is what a user does by double-clicking in the Finder. Nothing here
# removes the attribute, passes -a, or reaches for the right-click-Open override.
#
# A quarantined app gets a first-run dialog even when it is notarized, and WHICH
# dialog is the whole point of this run. The notarized one says Apple checked the
# app and offers Open; the two refusals do not:
#   unnotarized, developer id enabled ->  "can't be opened because Apple cannot
#                                          check it for malicious software"
#   any build, App Store-only         ->  "can't be opened because it was not
#                                          downloaded from the App Store"
# Both were seen on this golden while establishing the procedure, which is how
# this detector is known to tell them apart rather than to accept anything.
# `open` returns -1712 here rather than 0: the first-run dialog blocks the launch
# it is waiting on. That is the dialog appearing, not a failure to open.
guest "open ${INSTALLED}" || true
sleep 6

# Read as text, not as pixels. OCR loses this dialog twice over: it matches
# within a line, and the headline wraps across "…an app downloaded / from the
# Internet…", so a phrase spanning the break finds nothing while the words are
# plainly on screen; and the grey body line that carries the whole verdict came
# back as "Trom the internet" and worse. The accessibility tree returns each
# static text whole, newlines and all, which is what this needs to distinguish.
DIALOG_TREE=""
for _ in $(seq 1 12); do
    DIALOG_TREE="$(testanyware agent snapshot --mode full --depth 20 --json |
        jq -r '[.windows[] | .elements[]? | .. | objects
               | select(.platformRole == "AXStaticText") | .value // empty] | join("\n")')"
    grep -q 'downloaded from the Internet' <<<"${DIALOG_TREE}" && break
    sleep 3
done
echo "${DIALOG_TREE}" | sed 's/^/  /'
testanyware screen capture -o "${LOG%.log}-first-launch.png" >/dev/null
grep -q 'downloaded from the Internet' <<<"${DIALOG_TREE}" ||
    fail "no first-run dialog appeared at all for a quarantined bundle"
# Only the notarized dialog reports a malware check that came back clean. The
# unnotarized one says Apple could not verify the app, and the App Store-only one
# says it was not downloaded from the App Store; both were seen on this golden
# while this procedure was established, which is how this is known to
# discriminate rather than to accept whatever is on screen.
grep -q 'none was detected' <<<"${DIALOG_TREE}" ||
    fail "the first-run dialog does not report that Apple checked the app; this is not the notarized path"
! grep -q "can’t be opened" <<<"${DIALOG_TREE}" || fail "Gatekeeper refused the bundle on first launch"

# The ordinary Open button, not the right-click-Open override. The dialog is
# CoreServicesUIAgent's, so every window is searched rather than Koine's. This is
# also the structural half of telling the dialogs apart, and the more robust
# half: a refusal offers OK, Move to Trash or Show in Finder, and never Open.
OPEN_BUTTON="$(testanyware agent snapshot --mode full --depth 20 --json |
    jq -c '[.windows[] | .elements[]? | .. | objects
           | select(has("platformRole"))
           | select(.platformRole == "AXButton" and .sizeWidth > 0)
           | select((.label // "") == "Open")][0]')"
[ "${OPEN_BUTTON}" != null ] && [ -n "${OPEN_BUTTON}" ] ||
    fail "the first-run dialog offers no Open button"
# shellcheck disable=SC2046
testanyware input click $(jq -r '"\(.positionX + .sizeWidth / 2 | floor) \(.positionY + .sizeHeight / 2 | floor)"' <<<"${OPEN_BUTTON}") >/dev/null
sleep 3

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
