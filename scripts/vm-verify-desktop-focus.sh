#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM and with real
# applications, that desktopFocusWindow focuses exactly the window a reference
# names or reports why it did not. Which window has focus is never asked of
# Koine: Fixtures/WindowIdentityProbe, an independent signed tool, reads it from
# the system after every action. Covered: the chosen one of two same-titled
# windows, in both orders; a window of a background application; a minimised
# window; a window on another Space (focused or reported, whichever the OS does,
# and recorded); a closed window, a quit application, a restarted application, a
# reference that cannot be re-established, and revoked Accessibility consent,
# none of which moves focus. The reading grant and the controlling grant are
# separate: focus and its receipt need desktop:control alone. DesktopChoices and
# FocusDesktopWindow are sent as docs/design/desktop-operations.graphql has them.
# Nothing here runs the application on the host. The procedure and its recorded
# evidence: docs/verification/desktop-focus-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="desktop-focus-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

# shellcheck disable=SC2016  # guest-side $HOME
CONTROLLER_FILE='$HOME/koine-credential-controller'
OPERATIONS="\$HOME/desktop-operations.graphql"

# choices <application>: DesktopChoices under the reading grant.
choices() {
    ANSWER="$(guest_json "python3 \$HOME/vm-verify-desktop-client.py \"${CREDENTIAL_FILE}\" --operations \"${OPERATIONS}\" choices \"$1\"")"
    echo "${ANSWER}"
    jq -e '(.response.errors // []) | length == 0' >/dev/null <<<"${ANSWER}" || fail "DesktopChoices reported errors for $1"
}
# focus <reference>: FocusDesktopWindow under the controlling grant.
focus() {
    ANSWER="$(guest_json "python3 \$HOME/vm-verify-desktop-client.py \"${CONTROLLER_FILE}\" --operations \"${OPERATIONS}\" focus '$1'")"
    echo "${ANSWER}"
    jq -e . >/dev/null <<<"${ANSWER}" || fail "the desktop client printed no JSON for focus $1"
}
# The receipt is the submitted reference and nothing else.
expect_receipt() {
    expect "((.response.errors // []) | length == 0) and (.response.data.desktopFocusWindow == {ref: \"$1\"})" \
        "focusing $1 did not return its receipt"
}
# What has focus, as the system says: left in WITNESS, and summarised in FOCUSED
# as the focused application's PID and the focused window's window-server id.
witness() {
    sleep 1
    WITNESS="$(guest_json "\$HOME/WindowIdentityProbe focused")"
    echo "${WITNESS}"
    jq -e '.trusted == true' >/dev/null <<<"${WITNESS}" || fail "the witness cannot read the focused window"
    FOCUSED="$(jq -c '[.application.pid, .window.privateWindowId]' <<<"${WITNESS}")"
}
# expect_focused <application name> <jq condition on the witness>
expect_focused() {
    witness
    # The window server's front window is a second witness of the application.
    jq -e ".application.name == \"$1\" and (.frontCGWindow.pid == .application.pid) and ($2)" >/dev/null <<<"${WITNESS}" ||
        fail "the system does not show $1 focused with: $2"
}
# listed <pid> <jq condition on the windows that application lists now>
listed() {
    LISTED="$(guest_json "\$HOME/WindowIdentityProbe windows $1")"
    echo "${LISTED}"
    jq -e ".trusted == true and .windowsAXError == 0 and ($2)" >/dev/null <<<"${LISTED}" || fail "the application's windows are not as expected: $2"
}
# refused <reference> <what>: unavailable, and focus where it was.
refused() {
    witness
    local before="${FOCUSED}"
    focus "$1"
    expect_unavailable desktopFocusWindow "$2"
    witness
    [ "${FOCUSED}" = "${before}" ] || fail "focus moved from ${before} to ${FOCUSED} although $2 was unavailable"
}

PROBE="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"

start_vm
install_app
testanyware file upload scripts/vm-verify-desktop-client.py /Users/admin/vm-verify-desktop-client.py >/dev/null
testanyware file upload docs/design/desktop-operations.graphql /Users/admin/desktop-operations.graphql >/dev/null
testanyware file upload "${PROBE}" /Users/admin/WindowIdentityProbe >/dev/null
# shellcheck disable=SC2016  # guest-side $HOME
guest 'chmod +x $HOME/WindowIdentityProbe; echo focus > $HOME/focus-target.txt'

step "Launch Koine and create a reading grant and a controlling grant"
launch
create_grant "vm-focus-reader" "${CREDENTIAL_FILE}" koine:manage desktop:read
create_grant "vm-focus-controller" "${CONTROLLER_FILE}" desktop:control

step "The receipt exposes the submitted reference and no window read field"
ANSWER="$(guest_json "python3 \$HOME/vm-verify-desktop-client.py \"${CREDENTIAL_FILE}\" --type DesktopFocusReceipt")"
echo "${ANSWER}"
expect '[.response.data.__type.fields[].name] == ["ref"]' "DesktopFocusReceipt has fields other than ref"

step "Real windows: two Finder windows with the same title, and a TextEdit document"
guest "open -a Finder" || true
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 2
# shellcheck disable=SC2016  # guest-side $HOME
guest 'open -a TextEdit $HOME/focus-target.txt' || true
sleep 4

step "Give Koine Accessibility consent in System Settings"
grant_accessibility

step "List the choices with the reading grant"
choices Finder
# Finder opens a window of its own when it is activated with none, so there may be
# three; A and B are the first two, and every one has the same title.
expect '.response.data.desktopApplication.windows | length >= 2 and ([.[].title] | unique | length == 1) and ([.[].ref] | unique | length) == length' \
    "Finder does not list at least two windows with the same title under distinct references"
A="$(jq -r '.response.data.desktopApplication.windows[0].ref' <<<"${ANSWER}")"
B="$(jq -r '.response.data.desktopApplication.windows[1].ref' <<<"${ANSWER}")"
FINDER_REF="$(jq -r '.response.data.desktopApplication.ref' <<<"${ANSWER}")"
choices TextEdit
expect '.response.data.desktopApplication.windows | length == 1 and .[0].title == "focus-target.txt"' \
    "TextEdit does not list its one document"
T="$(jq -r '.response.data.desktopApplication.windows[0].ref' <<<"${ANSWER}")"

step "Two windows with the same title, from a background application: A, then B, then A"
guest 'open -a TextEdit' || true
expect_focused TextEdit '.window.title == "focus-target.txt"'
T_ID="$(jq -r '.window.privateWindowId' <<<"${WITNESS}")"
T_PID="$(jq -r '.application.pid' <<<"${WITNESS}")"
focus "${A}"
expect_receipt "${A}"
expect_focused Finder '.window.privateWindowId != null'
A_ID="$(jq -r '.window.privateWindowId' <<<"${WITNESS}")"
focus "${B}"
expect_receipt "${B}"
expect_focused Finder ".window.privateWindowId != ${A_ID}"
B_ID="$(jq -r '.window.privateWindowId' <<<"${WITNESS}")"
focus "${A}"
expect_receipt "${A}"
expect_focused Finder ".window.privateWindowId == ${A_ID}"
echo "Observation: reference A is window ${A_ID} and reference B is window ${B_ID}, both titled $(jq -c '.window.title' <<<"${WITNESS}")."

step "The other order, starting from a background application again: B, then A, then B"
guest 'open -a TextEdit' || true
expect_focused TextEdit ".window.privateWindowId == ${T_ID}"
focus "${B}"
expect_receipt "${B}"
expect_focused Finder ".window.privateWindowId == ${B_ID}"
focus "${A}"
expect_receipt "${A}"
expect_focused Finder ".window.privateWindowId == ${A_ID}"
focus "${B}"
expect_receipt "${B}"
expect_focused Finder ".window.privateWindowId == ${B_ID}"

step "A window of a background application"
focus "${T}"
expect_receipt "${T}"
expect_focused TextEdit ".window.privateWindowId == ${T_ID}"

step "A minimised window"
testanyware input key m --modifiers cmd >/dev/null
sleep 3
guest "open -a Finder" || true
expect_focused Finder ".window.privateWindowId == ${B_ID}"
# Seen to be minimised before the focus, or the reading after it proves nothing.
listed "${T_PID}" "[.windows[] | select(.privateWindowId == ${T_ID})] | length == 1 and .[0].minimized == true"
focus "${T}"
expect_receipt "${T}"
expect_focused TextEdit ".window.privateWindowId == ${T_ID} and .window.minimized == false"

step "A window on another Space: whichever the OS allows is recorded"
testanyware input key f --modifiers ctrl,cmd >/dev/null # full screen: a Space of its own
sleep 4
testanyware input key left --modifiers ctrl >/dev/null # back to the desktop Space
sleep 3
witness
jq -e ".window.privateWindowId != ${T_ID}" >/dev/null <<<"${WITNESS}" || fail "the full-screen window still has focus: the desktop Space was not reached"
# An application lists the windows of the current Space alone
# (docs/verification/desktop-window-identity.md): from here, not this one.
listed "${T_PID}" "[.windows[] | select(.privateWindowId == ${T_ID})] | length == 0"
focus "${T}"
if jq -e '(.response.errors // []) | length == 0' >/dev/null <<<"${ANSWER}"; then
    expect_receipt "${T}"
    sleep 2
    expect_focused TextEdit ".window.privateWindowId == ${T_ID}"
    echo "Observation: the window on another Space was focused; the system switched to its Space."
else
    expect '(.response.data.desktopFocusWindow == null) and (.response.errors | length == 1) and (.response.errors[0] | .path == ["desktopFocusWindow"] and .extensions.kind == "failed")' \
        "a window on another Space was neither focused nor reported as failed"
    echo "Observation: the window on another Space was not focused, and the failure was reported: $(jq -c '.response.errors[0].message' <<<"${ANSWER}")"
    guest 'open -a TextEdit' || true
    sleep 3
fi
testanyware screen capture -o "${LOG%.log}-other-space.png" >/dev/null
testanyware input key f --modifiers ctrl,cmd >/dev/null # leave full screen
sleep 4

step "A closed window is unavailable and focus does not move; the same-titled window beside it still focuses"
focus "${A}"
expect_receipt "${A}"
expect_focused Finder ".window.privateWindowId == ${A_ID}"
testanyware input key w --modifiers cmd >/dev/null
sleep 3
guest 'open -a TextEdit' || true
refused "${A}" "the closed window"
focus "${B}"
expect_receipt "${B}"
expect_focused Finder ".window.privateWindowId == ${B_ID}"

step "After the application quits, and after it restarts, its window is unavailable and focus does not move"
guest "open -a Stickies" || true
sleep 4
choices Stickies
expect '.response.data.desktopApplication.windows | length >= 1' "Stickies lists no window"
S="$(jq -r '.response.data.desktopApplication.windows[0].ref' <<<"${ANSWER}")"
focus "${S}"
expect_receipt "${S}"
expect_focused Stickies '.window.privateWindowId != null'
guest "killall Stickies" || true
sleep 3
guest "! pgrep -x Stickies" >/dev/null || fail "Stickies still runs"
guest 'open -a TextEdit' || true
refused "${S}" "a window of the application that quit"
guest "open -a Stickies" || true
sleep 4
guest "pgrep -x Stickies" >/dev/null || fail "Stickies did not start again"
guest 'open -a TextEdit' || true
refused "${S}" "a window of the application's earlier run"

step "A reference that cannot be re-established is unavailable and focus does not move"
refused "${B%/*}/999999" "a token this run never issued"
refused "${FINDER_REF}" "an application reference"
quit_koine
launch
refused "${B}" "a window reference from before a Koine restart"
choices Finder
LIVE="$(jq -r '.response.data.desktopApplication.windows[0].ref' <<<"${ANSWER}")"
[ "${LIVE}" != "${B}" ] || fail "the new run listed the window under the earlier run's reference"
guest 'open -a TextEdit' || true
focus "${LIVE}"
expect_receipt "${LIVE}"
expect_focused Finder ".window.privateWindowId != null and .window.privateWindowId != ${A_ID}"

step "Consent revoked while Koine runs: focus is an os-permission error, nothing prompts and focus does not move"
revoke_accessibility
REVOKED_AT="$(date +%s)"
while true; do
    witness
    BEFORE="${FOCUSED}"
    focus "${LIVE}"
    if jq -e '.response.errors | length > 0' >/dev/null <<<"${ANSWER}"; then break; fi
    [ $(($(date +%s) - REVOKED_AT)) -lt 60 ] || fail "the window was still focused 60s after consent was revoked"
    sleep 2
done
expect '.response.data.desktopFocusWindow == null' "a receipt was returned without consent"
expect_os_permission '["desktopFocusWindow"]'
witness
[ "${FOCUSED}" = "${BEFORE}" ] || fail "focus moved from ${BEFORE} to ${FOCUSED} without consent"
no_consent_dialog "after a focus with consent revoked"
testanyware screen capture -o "${LOG%.log}-after-revocation.png" >/dev/null
guest "killall 'System Settings'" || true

step "Quit Koine"
quit_koine

step "PASSED — transcript in ${LOG}"
