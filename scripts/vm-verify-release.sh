#!/bin/bash
# Release acceptance, platform half: the composed platform cases run against the
# NOTARIZED, stapled, QUARANTINED Koine.app in ONE TestAnyware macOS session on a
# Gatekeeper-ENFORCING clone. Every case here has passed before on a
# development-signed bundle, in a clean VM of its own; what this run adds is that
# they hold on the release artifact, composed, so that a difference made by
# notarization, stapling or the quarantined install path is what it would catch.
#
# Covered: the hardened runtime with the empty entitlements file, read in the
# guest from the installed copy; Accessibility consent absent, requested (twice
# in one run of Koine, and again in a later one), given, and revoked, with the
# prompt and the System Settings entry attributed to Koine; the OS-permission
# error at the original response path and its distinction from a missing
# capability, with no dialog raised by a read; same-titled windows under distinct
# stable references, a live PID claimed at another start instant, an absent
# process, a malformed start instant, window closure, and what a Koine restart
# does to each kind of reference; the management window closed with the listener
# and the provider still serving; and login launch through a VM restart with no
# client installed. Which window Koine is talking about is never asked of Koine:
# Fixtures/WindowIdentityProbe reads it from the system.
#
# Nothing here runs the application on the host. The procedure and its recorded
# evidence: docs/verification/release-acceptance-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# Before a VM is spun. This run exists to assess the RELEASE artifact; run
# against an unnotarized bundle every Gatekeeper assertion below would read
# `rejected`, which says nothing about Koine and everything about the operator.
if ! xcrun stapler validate "${APP_BUNDLE}" >/dev/null 2>&1; then
    {
        echo "Error: ${APP_BUNDLE} carries no stapled notarization ticket."
        echo "  Platform acceptance is run on the release artifact. Run: task app && task app:notarize"
    } >&2
    exit 1
fi

# shellcheck disable=SC2034  # both read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="release-"
# Tall enough that the Security section of the Privacy & Security pane is on
# screen; vm-verify-gatekeeper-lib.sh's enable_developer_id explains why that is
# the mechanism rather than scrolling.
KOINE_VM_DISPLAY="1920x2160"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-verify-gatekeeper-lib.sh
source scripts/vm-verify-gatekeeper-lib.sh

READER_FILE="${CREDENTIAL_FILE}"
Q_PERMISSIONS='{ koineManagement { osPermissions { permission owner granted } } }'

# ask/body: the library's ask ends the run on anything but HTTP 200, and the
# agent's false "Process timed out after 30s" (scripts/vm-verify-lib.sh) can
# outlast its own retries on a read Koine answered. These are reads, safe to
# repeat, and a JSON body followed by its status line proves the client ran to
# its end whatever status the agent reports. Same shape, and for the same reason,
# as scripts/vm-verify-accessibility.sh's; kept local rather than pushed into the
# shared library so that four passing routes are not changed by this leaf.
ask() {
    for _ in 1 2 3 4 5; do
        RESPONSE="$(guest "bash \$HOME/vm-verify-client.sh \"${CREDENTIAL_FILE}\" '$1'" 2>&1 || true)"
        if grep -qx "HTTP 200" <<<"${RESPONSE}" && body | jq -e . >/dev/null 2>&1; then
            body
            return 0
        fi
        sleep 3
    done
    echo "${RESPONSE}"
    fail "expected HTTP 200 for: $1"
}
body() { grep -m1 '^{' <<<"${RESPONSE}"; }
# expect_permission <true|false>: osPermissions is exactly accessibility, koine, $1.
expect_permission() {
    ask "${Q_PERMISSIONS}" >/dev/null
    body | jq -e ".data.koineManagement.osPermissions == [{permission: \"accessibility\", owner: \"koine\", granted: $1}]" >/dev/null ||
        fail "osPermissions does not report accessibility, koine, granted: $1"
    echo "osPermissions: $(body | jq -c '.data.koineManagement.osPermissions')"
}
# follow <true|false>: osPermissions comes to report $1 with no restart of Koine.
follow() {
    local since
    since="$(date +%s)"
    until ask "${Q_PERMISSIONS}" >/dev/null 2>&1 && body | jq -e ".data.koineManagement.osPermissions[0].granted == $1" >/dev/null; do
        [ $(($(date +%s) - since)) -lt 60 ] || fail "osPermissions did not report granted: $1 within 60s"
        sleep 2
    done
    echo "Observation: osPermissions reported granted: $1 within $(($(date +%s) - since))s."
}
koine_pid() { guest "pgrep -f ${INSTALLED}/Contents/MacOS" 2>&1 | grep -E '^[0-9]+$' | tail -1; }

# request_consent <what> <screenshot suffix>: the window's own request control,
# and what macOS did about it, left in CONSENT_DIALOG as yes or no.
#
# The FIRST request of a run of Koine is asserted to show the dialog naming
# Koine. A REPEAT request is only recorded: whether macOS shows the dialog a
# second time is the question accessibility-status-and-consent-vm.md left open in
# these words — "Whether macOS shows the dialog again is unverified" — so
# asserting an answer here would be asserting the thing being asked. What is
# asserted for every request is that Koine offers the control, and that any
# dialog that does appear names Koine rather than a client.
CONSENT_DIALOG=""
request_consent() {
    place_window
    [ "$(element '.id=="request-accessibility"')" != null ] ||
        fail "the window offers no Accessibility request control ($1)"
    click '.id=="request-accessibility"'
    sleep 3
    local found
    found="$(testanyware screen find-text "${DIALOG_TEXT}" --json)" || fail "the screen could not be read"
    if jq -e '.total > 0' >/dev/null <<<"${found}"; then
        CONSENT_DIALOG=yes
        jq -c '[.detections[].text]' <<<"${found}"
        jq -e '[.detections[].text] | any(test("Koine"))' >/dev/null <<<"${found}" ||
            fail "the consent dialog does not name Koine ($1)"
        testanyware screen capture -o "${LOG%.log}-$2.png" >/dev/null
        echo "Observation: the request ($1) showed macOS's consent dialog, naming Koine."
    else
        CONSENT_DIALOG=no
        testanyware screen capture -o "${LOG%.log}-$2.png" >/dev/null
        echo "Observation: the request ($1) showed no consent dialog; ${DIALOG_HOST}: $(guest "pgrep -x ${DIALOG_HOST} >/dev/null && echo running || echo not running")"
    fi
}

# Changing the Accessibility list puts something in front of the change, and
# WHICH thing is not the same in every state — scripts/vm-verify-desktop-lib.sh
# types an administrator password a fixed two seconds after the click, and on
# this clone turning the switch OFF produced no such sheet within twenty seconds
# and left the switch on. A run that assumes one shape reports a revocation that
# never happened, and then fails a minute later saying "windows were still
# listed", which reads like a finding against Koine and is not one. So this reads
# the screen, RECORDS what it found, answers either shape, and then asserts the
# switch itself. Local to this run: four other passing routes use the library's.
all_windows() { testanyware agent snapshot --mode full --depth 20 --json; }
screen_texts() {
    all_windows | jq -r '[.windows[] | .elements[]? | .. | objects
        | select(.platformRole == "AXStaticText") | .value // empty] | join("\n")'
}
screen_buttons() {
    all_windows | jq -c '[.windows[] | .elements[]? | .. | objects
        | select(has("platformRole"))
        | select(.platformRole == "AXButton" and .sizeWidth > 0)
        | .label // empty]'
}
# click_button <label>: returns 1 when no such button is on screen.
click_button() {
    local b
    b="$(all_windows | jq -c --arg l "$1" '[.windows[] | .elements[]? | .. | objects
        | select(has("platformRole"))
        | select(.platformRole == "AXButton" and .sizeWidth > 0)
        | select((.label // "") == $l)][0]')"
    [ "${b}" != null ] && [ -n "${b}" ] || return 1
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '"\(.positionX + .sizeWidth / 2 | floor) \(.positionY + .sizeHeight / 2 | floor)"' <<<"${b}") >/dev/null
    sleep 3
    return 0
}
# answer_switch_prompt <what> <screenshot suffix>: whatever macOS put in front of
# the change, answered and recorded. The administrator sheet is recognised by its
# own "Modify Settings" button rather than by the word "password" anywhere on
# screen — the sidebar carries a "Login Password" row, which matched and made an
# earlier run report a sheet that was not there.
answer_switch_prompt() {
    sleep 3
    testanyware screen capture -o "${LOG%.log}-$2.png" >/dev/null
    local texts buttons
    texts="$(screen_texts)"
    buttons="$(screen_buttons)"
    echo "Buttons on screen after $1: ${buttons}"
    if grep -q 'Modify Settings' <<<"${buttons}" || grep -q 'Enter your password' <<<"${texts}"; then
        echo "An administrator authentication sheet is up; answering it."
        testanyware input type "${VM_PASSWORD}" >/dev/null
        sleep 1
        testanyware input key return >/dev/null
        sleep 3
    elif click_button "Later"; then
        echo "Observation: macOS asked whether to quit the application; Later was chosen, which leaves Koine running."
    else
        echo "Nothing stood in front of the change."
    fi
}
# toggle_reads <0|1> <tries>: Koine's switch, polled.
toggle_reads() {
    for _ in $(seq 1 "$2"); do
        [ "$(value_of '.id=="Koine_Toggle"' 2>/dev/null)" = "$1" ] && return 0
        sleep 2
    done
    return 1
}
# set_koine_switch <0|1> <what>: drive Koine's switch until the switch itself
# says it moved. Turning it ON has worked from a VNC click at the element's
# centre every time; turning it OFF has not — the click lands on the same 36x16
# control at the same coordinates and selects the row without flipping it, with
# nothing on screen five seconds later. Rather than pick one route and hope, this
# tries each way of pressing the control and stops as soon as the switch reads
# what was asked for, printing the route it used, so which one works is recorded
# rather than assumed.
set_koine_switch() {
    local want="$1" what="$2" route
    for route in press click press; do
        toggle_reads "${want}" 1 && return 0
        case "${route}" in
        press)
            echo "Route: agent press on the switch"
            testanyware agent press --role checkbox --id Koine_Toggle --window "System Settings" 2>&1 | sed 's/^/  /' || true
            ;;
        click)
            echo "Route: VNC click at the switch's centre"
            click '.id=="Koine_Toggle"'
            ;;
        esac
        answer_switch_prompt "${what} (${route})" "switch-${want}-${route}"
        toggle_reads "${want}" 5 && { echo "Observation: the switch moved to ${want} by ${route}."; return 0; }
    done
    echo "Koine's switch element after every route: $(element '.id=="Koine_Toggle"')"
    testanyware screen capture -o "${LOG%.log}-switch-${want}-stuck.png" >/dev/null
    return 1
}
# expect_toggle <0|1> <what just happened>: Koine's switch in the Accessibility
# pane, read only once whatever stood over it has been answered — its value while
# a sheet is up proves nothing (scripts/vm-verify-desktop-lib.sh's own note).
expect_toggle() {
    for _ in $(seq 1 15); do
        [ "$(value_of '.id=="Koine_Toggle"' 2>/dev/null)" = "$1" ] && return 0
        sleep 2
    done
    echo "Koine's switch element: $(element '.id=="Koine_Toggle"')"
    testanyware screen capture -o "${LOG%.log}-toggle-$1.png" >/dev/null
    fail "Koine's Accessibility switch does not read $1 after $2"
}
settings_accessibility() {
    guest "killall 'System Settings'" || true
    sleep 2
    guest 'open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"' || true
    SNAPSHOT_WINDOW="System Settings"
}
# revoke_accessibility: replaces the shared library's, for the reason above, and
# with a second route. Removing Koine's entry from the list is the other thing a
# user does in this pane and is the same revocation — consent is gone either way
# — so a switch that will not move does not end the run; which route was used is
# printed and goes into the evidence.
REVOCATION_ROUTE=""
revoke_accessibility() {
    settings_accessibility
    expect_toggle 1 "opening the Accessibility pane"
    echo "Koine's switch element: $(element '.id=="Koine_Toggle"')"
    if set_koine_switch 0 "turning Koine's Accessibility switch off"; then
        REVOCATION_ROUTE="Koine's switch in the Accessibility pane"
    else
        echo "The switch would not move by any route; removing Koine's entry instead."
        click_button "Remove" || fail "the Accessibility list offers no Remove control"
        answer_switch_prompt "removing Koine's entry" revoke-remove
        local tries=0
        until [ "$(element '.id=="Koine_Toggle"' 2>/dev/null)" = null ]; do
            tries=$((tries + 1))
            [ "${tries}" -lt 15 ] || fail "Koine is still listed in the Accessibility pane after Remove"
            sleep 2
        done
        REVOCATION_ROUTE="removing Koine's entry from the Accessibility pane, the switch having refused every route"
    fi
    echo "Observation: consent was revoked by ${REVOCATION_ROUTE}."
    unset SNAPSHOT_WINDOW
    guest "killall 'System Settings'" || true
}

PROBE="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"

# The probe's window list for an application includes Finder's DESKTOP, which is
# an AXScrollArea with no title and no window-server id rather than a window —
# "Finder's desktop is an element of its window list and no window"
# (docs/verification/desktop-application-and-windows-vm.md). Counting it would
# make every count below one too many, and its null title defeats the
# same-title check outright, which is what a first run of this script died of.
# The system's windows, for this run's purposes, are the AXWindow rows.
SYSTEM_WINDOWS='[.windows[] | select(.role == "AXWindow")]'

start_vm
enforce_gatekeeper
install_app_quarantined
testanyware file upload scripts/vm-verify-desktop-client.py /Users/admin/vm-verify-desktop-client.py >/dev/null
testanyware file upload docs/design/desktop-operations.graphql /Users/admin/desktop-operations.graphql >/dev/null
testanyware file upload "${PROBE}" /Users/admin/WindowIdentityProbe >/dev/null
# shellcheck disable=SC2016  # guest-side $HOME
guest 'chmod +x $HOME/WindowIdentityProbe'

step "The release artifact's hardened runtime and empty entitlements, read from the installed copy in the guest"
# The spec asks for the entitlement behaviour of the SIGNED RELEASE build rather
# than an extrapolation from a development run, and the guest is where the copy
# that actually launches lives. App/Koine.entitlements is deliberately an empty
# dict: the hardened runtime with no exceptions. An exception — library
# validation disabled, for instance — would be an entitlement, so an empty
# dictionary is the checkable form of "no exceptions", and the flags word is
# asserted whole rather than by substring so that a second flag cannot hide in it.
ENTITLEMENTS="$(guest "codesign -d --entitlements - --xml ${INSTALLED} 2>/dev/null | plutil -convert json -o - -")"
echo "Entitlements: ${ENTITLEMENTS}"
[ "${ENTITLEMENTS}" = "{}" ] || fail "the release bundle carries entitlements: ${ENTITLEMENTS}"
for code in "${INSTALLED}" "${INSTALLED}/Contents/PlugIns/Desktop.koineprovider"; do
    FLAGS="$(guest "codesign -dvv ${code} 2>&1 | sed -n 's/^CodeDirectory.*\(flags=[^ ]*\).*/\1/p'")"
    echo "${code}: ${FLAGS}"
    [ "${FLAGS}" = "flags=0x10000(runtime)" ] || fail "${code} is not hardened-runtime-and-nothing-else: ${FLAGS}"
done

# The first launch of a quarantined bundle. That the dialog is the NOTARIZED one
# — "Apple checked it for malicious software and none was detected", with an Open
# button, rather than either refusal — is established and recorded in
# docs/verification/notarized-release-vm.md, on this same artifact; repeating that
# discrimination here would add nothing. What this needs from it is the launch.
first_launch_quarantined
await_service

step "Nothing was stripped: the attribute is still on the launched bundle"
QUARANTINE_AFTER="$(guest "xattr -p com.apple.quarantine ${INSTALLED}")"
echo "Quarantine before launch: ${QUARANTINE_BEFORE}"
echo "Quarantine after launch:  ${QUARANTINE_AFTER}"
[ -n "${QUARANTINE_AFTER}" ] || fail "the quarantine attribute was removed by the launch"
KOINE_PID="$(koine_pid)"
echo "Koine pid: ${KOINE_PID}"

step "Two grants in the window: one that reads the desktop, one that does not"
# The controlling grant is this run's grant-without-desktop:read as well. It is a
# real grant with a real capability, which is what makes the contrast below the
# one the spec asks for: a capability refusal, not an unauthenticated request.
create_grant "vm-release-reader" "${READER_FILE}" koine:manage desktop:read
create_grant "vm-release-controller" "${CONTROLLER_FILE}" desktop:control

step "Real windows: two Finder windows with the same title, seen natively before Koine is asked anything"
guest "open -a Finder" || true
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 3
FINDER_PID="$(guest "pgrep -x Finder" 2>&1 | grep -E '^[0-9]+$' | tail -1)"
[ -n "${FINDER_PID}" ] || fail "Finder is not running"
# The witness first. Without this the refusal below could be Koine reporting an
# OS permission error about a desktop that has nothing on it. The count it
# establishes is this run's baseline: every later claim about what Koine's
# references track is made as a CHANGE against it, on both sides, rather than by
# equating two enumerations that need not agree window for window.
listed "${FINDER_PID}" "(${SYSTEM_WINDOWS} | length) >= 2 and ((${SYSTEM_WINDOWS} | map(.title) | unique | length) == 1)"
PROBE_BASELINE="$(jq -r "${SYSTEM_WINDOWS} | length" <<<"${LISTED}")"
echo "The system says Finder has ${PROBE_BASELINE} windows, all titled $(jq -c "${SYSTEM_WINDOWS}[0].title" <<<"${LISTED}")."

step "Consent absent: windows are an os-permission error at the original path, and nothing prompts"
expect_permission false
desktop "${READER_FILE}" Finder exact
expect '.response.data.desktopApplication == null' "windows were listed without Accessibility consent"
expect_os_permission '["desktopApplication","windows"]'
no_consent_dialog "after a windows read without consent"

step "Consent absent: the application fields that need none still resolve"
desktop "${READER_FILE}" Finder plain
expect '((.response.errors // []) | length == 0) and (.response.data.desktopApplication | .name == "Finder" and .bundleIdentifier == "com.apple.finder")' \
    "the application did not resolve without consent"
FINDER_REF="$(jq -r '.response.data.desktopApplication.ref' <<<"${ANSWER}")"

step "Consent absent: a grant without desktop:read gets the capability class, not the OS one"
desktop "${CONTROLLER_FILE}" Finder exact
expect '.response.errors[0].extensions | .kind == "permission" and .permissionClass == "capability" and .requiredCapability == "desktop:read"' \
    "the missing capability was not reported as such"
no_consent_dialog "after every read without consent"

step "The window's request: macOS shows its dialog, naming Koine"
request_consent "the first request of this run of Koine" consent-dialog-first
[ "${CONSENT_DIALOG}" = yes ] || fail "the first request showed no consent dialog"
echo "Shown by: $(guest "pgrep -lx ${DIALOG_HOST}" || true)"
testanyware input key escape >/dev/null
sleep 2

step "A SECOND request in the same run of Koine: whatever macOS does is recorded"
request_consent "a second request in the same run of Koine" consent-dialog-second
SECOND_IN_RUN="${CONSENT_DIALOG}"

step "System Settings lists Koine, switched off; consent is then given there"
if [ "${SECOND_IN_RUN}" = yes ]; then
    OPEN="$(testanyware screen find-text "Open System Settings" --timeout 10 --require-match --json)" ||
        fail "the dialog offers no route to System Settings"
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '.detections[0] | "\(.x + .width / 2 | floor) \(.y + .height / 2 | floor)"' <<<"${OPEN}") >/dev/null
else
    click '.id=="open-accessibility-settings"'
fi
SNAPSHOT_WINDOW="System Settings"
tries=0
until [ "$(value_of '.id=="Koine_Toggle"' 2>/dev/null)" = 0 ]; do
    tries=$((tries + 1))
    [ "${tries}" -lt 15 ] || fail "System Settings does not list Koine, switched off"
    sleep 2
done
testanyware screen capture -o "${LOG%.log}-settings-entry.png" >/dev/null
echo "Koine's switch element: $(element '.id=="Koine_Toggle"')"
unset SNAPSHOT_WINDOW
# Consent is given by the list's Add control, which is how
# desktop-references-and-permission-vm.md and desktop-focus-vm.md give it, and
# the route their revocation is known to pair with. The switch is a second way
# into the same entry — it was used here in an earlier run of this script and
# worked in that direction — but what this run needs afterwards is to take
# consent away again, so it uses the route the earlier runs revoke from.
grant_accessibility
follow true
[ "$(koine_pid)" = "${KOINE_PID}" ] || fail "Koine was restarted"

step "Same-titled windows under distinct references, stable across two listings"
desktop "${READER_FILE}" Finder exact
expect '(.response.errors // []) | length == 0' "resolving Finder reported errors"
expect '.response.data.desktopApplication.windows | length >= 2 and ([.[].title] | unique | length == 1) and ([.[].ref] | unique | length) == length' \
    "the same-titled windows do not carry distinct references"
expect '.response.data.desktopApplication.windows | all(.observation == "CURRENT" and (.ref | startswith("koine://desktop/window/")))' \
    "a window is not CURRENT with a window reference"
FIRST_REFS="$(jq -c '[.response.data.desktopApplication.windows[].ref] | sort' <<<"${ANSWER}")"
WINDOW_REFS="$(jq -r '.response.data.desktopApplication.windows[].ref' <<<"${ANSWER}")"
KOINE_BASELINE="$(grep -c . <<<"${WINDOW_REFS}")"
desktop "${READER_FILE}" Finder exact
[ "$(jq -c '[.response.data.desktopApplication.windows[].ref] | sort' <<<"${ANSWER}")" = "${FIRST_REFS}" ] ||
    fail "a second listing gave the same windows other references"
echo "Koine lists ${KOINE_BASELINE} windows where the system says ${PROBE_BASELINE}."

step "PID reuse as far as it can be observed: the same live PID at another start instant is another process"
# A PID cannot be made to recur on demand. What is observable is the other half
# of the identity: the live PID claimed at a start instant that is not its own is
# ordinary absence, with no error at all — which is what keeps a reused PID from
# resolving its predecessor.
for case in later absent; do
    desktop "${READER_FILE}" Finder "${case}"
    expect '.response.data.desktopApplication == null and ((.response.errors // []) | length == 0)' "${case}: not an ordinary null"
done
desktop "${READER_FILE}" Finder malformed
expect '.response.data.desktopApplication == null and (.response.errors | length == 1) and (.response.errors[0].extensions.kind == null)' \
    "the malformed start instant was not an input error"

step "A closed window is unavailable; the same-titled windows beside it still resolve"
CLOSE_TARGET="$(head -1 <<<"${WINDOW_REFS}")"
lookup window "${CLOSE_TARGET}"
expect "((.response.errors // []) | length == 0) and (.response.data.desktopWindow.ref == \"${CLOSE_TARGET}\")" \
    "the window chosen for closing does not resolve to begin with"
guest "open -a Finder" || true
sleep 2
testanyware input key w --modifiers cmd >/dev/null
sleep 3
# Seen to have closed, natively, before anything is concluded from Koine's answer.
listed "${FINDER_PID}" "(${SYSTEM_WINDOWS} | length) == $((PROBE_BASELINE - 1))"
CLOSED=0
for ref in ${WINDOW_REFS}; do
    lookup window "${ref}"
    if jq -e '.response.data.desktopWindow != null' >/dev/null <<<"${ANSWER}"; then
        expect ".response.data.desktopWindow.ref == \"${ref}\" and ((.response.errors // []) | length == 0)" \
            "an open window resolved as another"
    else
        expect_unavailable desktopWindow "the closed window"
        CLOSED=$((CLOSED + 1))
    fi
done
[ "${CLOSED}" = 1 ] || fail "${CLOSED} window references became unavailable when one window closed"
desktop "${READER_FILE}" Finder exact
expect "(.response.data.desktopApplication.windows | length) == $((KOINE_BASELINE - 1))" \
    "Koine's listing did not lose exactly the closed window"

step "The management window closed: the listener answers and the desktop provider still serves"
testanyware agent window-close --window "${APP_NAME}" >/dev/null
sleep 2
OPEN_WINDOWS="$(testanyware agent windows --json | jq "[.windows[] | select(.appName == \"${APP_NAME}\" and .title == \"${APP_NAME}\")] | length")"
[ "${OPEN_WINDOWS}" = 0 ] || fail "the management window is still open"
expect_status 200
# A state change made while there is no window, and served after it: the provider
# is still reading the desktop, not replaying what the window had seen.
guest "open -a Finder" || true
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 3
listed "${FINDER_PID}" "(${SYSTEM_WINDOWS} | length) == ${PROBE_BASELINE}"
desktop "${READER_FILE}" Finder exact
expect "(.response.data.desktopApplication.windows | length) == ${KOINE_BASELINE}" \
    "the provider did not serve the window opened while the management window was closed"
NEW_REFS="$(jq -r '.response.data.desktopApplication.windows[].ref' <<<"${ANSWER}")"
[ -n "$(comm -13 <(sort <<<"${WINDOW_REFS}") <(sort <<<"${NEW_REFS}"))" ] ||
    fail "no new window reference appeared for the window opened with no management window"
LIVE_WINDOW="$(head -1 <<<"${NEW_REFS}")"

step "Across a Koine restart: an application reference resolves again, a window reference does not"
lookup application-plain "${FINDER_REF}"
BEFORE_RESTART="$(jq -cS '.response.data.desktopApplicationByReference' <<<"${ANSWER}")"
guest "open ${INSTALLED}" || true
place_window
quit_koine
launch
[ "$(koine_pid)" != "${KOINE_PID}" ] || fail "Koine kept its pid across the restart"
KOINE_PID="$(koine_pid)"
lookup application-plain "${FINDER_REF}"
[ "$(jq -cS '.response.data.desktopApplicationByReference' <<<"${ANSWER}")" = "${BEFORE_RESTART}" ] ||
    fail "the application reference did not resolve to the same application after the restart"
lookup window "${LIVE_WINDOW}"
expect_unavailable desktopWindow "a window reference from before the restart"
desktop "${READER_FILE}" Finder exact
expect ".response.data.desktopApplication.windows | length >= 1 and all(.ref != \"${LIVE_WINDOW}\")" \
    "the new run did not list the open windows under its own references"
LIVE_WINDOW="$(jq -r '.response.data.desktopApplication.windows[0].ref' <<<"${ANSWER}")"

step "Consent revoked while Koine runs: an os-permission error at the original path, and nothing prompts"
revoke_accessibility
REVOKED_AT="$(date +%s)"
until desktop "${READER_FILE}" Finder exact && jq -e '.response.errors | length > 0' >/dev/null <<<"${ANSWER}"; do
    [ $(($(date +%s) - REVOKED_AT)) -lt 60 ] || fail "windows were still listed 60s after consent was revoked"
    sleep 2
done
echo "Observation: the first read to report revoked consent completed $(($(date +%s) - REVOKED_AT))s after the password was entered."
expect_os_permission '["desktopApplication","windows"]'
lookup window "${LIVE_WINDOW}"
expect_os_permission '["desktopWindow"]'
lookup application-plain "${FINDER_REF}"
expect '((.response.errors // []) | length == 0) and (.response.data.desktopApplicationByReference.name == "Finder")' \
    "the application did not resolve by reference after consent was revoked"
desktop "${CONTROLLER_FILE}" Finder exact
expect '.response.errors[0].extensions | .kind == "permission" and .permissionClass == "capability" and .requiredCapability == "desktop:read"' \
    "with consent revoked, a missing capability was not still reported as the capability class"
no_consent_dialog "after reads with consent revoked"
testanyware screen capture -o "${LOG%.log}-after-revocation.png" >/dev/null
follow false

step "A request in a LATER run of Koine: whatever macOS does is recorded"
quit_koine
launch
request_consent "the first request of a later run of Koine, after consent was given and removed" consent-dialog-later
LATER_RUN="${CONSENT_DIALOG}"
[ "${CONSENT_DIALOG}" = no ] || testanyware input key escape >/dev/null
sleep 2
echo "Observation, the open question closed: with Koine already listed in System Settings, a repeat request showed a dialog: ${SECOND_IN_RUN} in the same run of Koine, ${LATER_RUN} in a later one."

step "Login launch: enable it in the window, quit Koine, and restart the VM with no client installed"
place_window
echo "Before: $(value_of '.id=="login-launch-status"')"
click '.id=="login-launch"'
[ "$(value_of '.id=="login-launch"')" = 1 ] || fail "the login-launch toggle did not turn on"
[ "$(value_of '.id=="login-launch-status"')" = "Koine will start when you log in." ] ||
    fail "login launch is not reported enabled"
# Koine is quit first so that macOS's reopening of applications that were running
# cannot be what starts it: resident-app-vm.md's method, and the only thing that
# makes the launch after the restart attributable to the login item.
quit_koine
guest "[ ! -e \"${DATA}/endpoint.json\" ]" || fail "the descriptor survived Quit"
BOOT_BEFORE="$(guest 'sysctl -n kern.boottime')"
# Not through guest(): a restart must never be repeated by a retry.
testanyware file exec "echo ${VM_PASSWORD} | sudo -S shutdown -r now" >/dev/null 2>&1 || true
sleep 30
BOOT_AFTER=""
for _ in $(seq 1 60); do
    BOOT_AFTER="$(guest 'sysctl -n kern.boottime' 2>/dev/null || true)"
    if [ -n "${BOOT_AFTER}" ] && [ "${BOOT_AFTER}" != "${BOOT_BEFORE}" ]; then break; fi
    sleep 5
done
[ -n "${BOOT_AFTER}" ] && [ "${BOOT_AFTER}" != "${BOOT_BEFORE}" ] || fail "the VM did not come back from its restart"

step "After login, with nothing having launched Koine and no client installed"
for _ in $(seq 1 24); do
    if guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1; then break; fi
    sleep 5
done
guest "pgrep -lf ${INSTALLED}" || fail "Koine was not started at login"
guest "cat \"${DATA}/endpoint.json\"; echo" || fail "no endpoint descriptor after login"
# Still the release artifact it was before the restart: the ticket is stapled into
# the installed copy and the quarantine attribute is still on it.
guest "xcrun stapler validate ${INSTALLED} 2>&1" || fail "the installed copy lost its stapled ticket across the restart"
echo "Quarantine after the restart: $(guest "xattr -p com.apple.quarantine ${INSTALLED}")"
# The grants this run made in the window survive the restart, and the listener
# refuses a request that carries no credential at all.
expect_status 200
client | grep -q '"clientLabel":"vm-release-reader"' || fail "Query.koine did not report the grant made before the restart"
UNAUTHENTICATED="$(guest "curl -s -m 5 -o /dev/null -w '%{http_code}' \"http://127.0.0.1:\$(jq -r .port \"${DATA}/endpoint.json\")/graphql\" -H 'Content-Type: application/json' -d '{\"query\":\"{ koine { contractVersion } }\"}'")"
echo "Listener without a credential: HTTP ${UNAUTHENTICATED}"
[ "${UNAUTHENTICATED}" = 401 ] || fail "the listener did not answer 401 to an unauthenticated request"

step "Quit Koine"
place_window
quit_koine

step "PASSED — transcript in ${LOG}"
