#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM and with real
# applications, what the desktop provider remembers across Spaces. The second
# Space is a full-screen window's own. Covered: a window seen and then left on
# another Space is REMEMBERED under the reference it had while CURRENT, each
# window once, by listing and by desktopWindow alike; selecting it revalidates,
# focuses it and makes it CURRENT, and the window left behind REMEMBERED; a window
# closed while observable leaves no row and is unavailable, and the system's
# notification of its destruction is seen by an independent native witness,
# Fixtures/WindowIdentityProbe; a terminated application leaves nothing, under
# its own incarnation or its successor's; and with the management window closed a
# window opened and moved afterwards is still remembered. Quit stays prompt with
# observation running. Nothing here runs the application on the host. The
# procedure and its recorded evidence: docs/verification/desktop-remembered-windows-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="desktop-remembered-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

# rows <title>: the rows of the last listing with that title, as compact JSON.
rows() { jq -c "[.response.data.desktopApplication.windows[] | select(.title == \"$1\")]" <<<"${ANSWER}"; }
# expect_row <title> <reference> <observation>: exactly one such row, and it is this.
expect_row() {
    [ "$(rows "$1")" = "[{\"ref\":\"$2\",\"title\":\"$1\",\"observation\":\"$3\"}]" ] ||
        fail "$1 is not listed once as $3 under $2: $(rows "$1")"
}
# expect_window <reference> <title> <observation>: desktopWindow agrees with the listing.
expect_window() {
    lookup window "$1"
    expect "((.response.errors // []) | length == 0) and (.response.data.desktopWindow == {ref: \"$1\", title: \"$2\", observation: \"$3\"})" \
        "desktopWindow does not report $2 as $3"
}
# other_space: the front window becomes full screen, a Space of its own, and the
# desktop Space is returned to.
other_space() {
    testanyware input key f --modifiers ctrl,cmd >/dev/null
    sleep 4
    testanyware input key left --modifiers ctrl >/dev/null
    sleep 3
}

PROBE="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"

start_vm
install_app
testanyware file upload scripts/vm-verify-desktop-client.py /Users/admin/vm-verify-desktop-client.py >/dev/null
testanyware file upload docs/design/desktop-operations.graphql /Users/admin/desktop-operations.graphql >/dev/null
testanyware file upload "${PROBE}" /Users/admin/WindowIdentityProbe >/dev/null
# shellcheck disable=SC2016  # guest-side $HOME
guest 'chmod +x $HOME/WindowIdentityProbe; for n in a b c; do echo $n > $HOME/remembered-$n.txt; done'

step "Launch Koine and create a reading grant and a controlling grant"
launch
create_grant "vm-remembered-reader" "${CREDENTIAL_FILE}" koine:manage desktop:read
create_grant "vm-remembered-controller" "${CONTROLLER_FILE}" desktop:control

step "Real windows: two TextEdit documents"
# shellcheck disable=SC2016  # guest-side $HOME
guest 'open -a TextEdit $HOME/remembered-a.txt $HOME/remembered-b.txt' || true
sleep 5

step "Give Koine Accessibility consent in System Settings"
grant_accessibility

step "Both windows are seen on the desktop Space: CURRENT"
choices TextEdit
expect '.response.data.desktopApplication.windows | length == 2 and all(.[]; .observation == "CURRENT")' \
    "TextEdit does not list its two documents as CURRENT"
A="$(rows remembered-a.txt | jq -r '.[0].ref')"
B="$(rows remembered-b.txt | jq -r '.[0].ref')"
expect_row remembered-a.txt "${A}" CURRENT
expect_row remembered-b.txt "${B}" CURRENT
TEXTEDIT_REF="$(jq -r '.response.data.desktopApplication.ref' <<<"${ANSWER}")"

step "A is left on another Space: REMEMBERED under the same reference, B still CURRENT, each once"
focus "${A}"
expect_receipt "${A}"
expect_focused TextEdit '.window.title == "remembered-a.txt"'
A_ID="$(jq -r '.window.privateWindowId' <<<"${WITNESS}")"
T_PID="$(jq -r '.application.pid' <<<"${WITNESS}")"
other_space
witness
jq -e ".window.privateWindowId != ${A_ID}" >/dev/null <<<"${WITNESS}" || fail "the full-screen window still has focus: the desktop Space was not reached"
# Read before it is relied on: the application's own enumeration omits A here.
listed "${T_PID}" "[.windows[] | select(.privateWindowId == ${A_ID})] | length == 0"
choices TextEdit
expect '.response.data.desktopApplication.windows | length == 2' "TextEdit does not list two windows with one on another Space"
expect_row remembered-a.txt "${A}" REMEMBERED
expect_row remembered-b.txt "${B}" CURRENT
expect_window "${A}" remembered-a.txt REMEMBERED
expect_window "${B}" remembered-b.txt CURRENT
testanyware screen capture -o "${LOG%.log}-a-remembered.png" >/dev/null

step "Selecting the remembered window revalidates and focuses it; there it is CURRENT and B is REMEMBERED"
focus "${A}"
expect_receipt "${A}"
sleep 2
expect_focused TextEdit ".window.privateWindowId == ${A_ID}"
choices TextEdit
expect_row remembered-a.txt "${A}" CURRENT
expect_row remembered-b.txt "${B}" REMEMBERED

step "Returning A to the desktop Space makes both CURRENT"
testanyware input key f --modifiers ctrl,cmd >/dev/null # leave full screen
sleep 5
choices TextEdit
expect '.response.data.desktopApplication.windows | length == 2' "TextEdit does not list two windows back on one Space"
expect_row remembered-a.txt "${A}" CURRENT
expect_row remembered-b.txt "${B}" CURRENT

step "A is closed while observable: the system reports its destruction, no row is left and it is unavailable"
# Detached from the exec that starts it, which would otherwise wait for it.
guest "nohup \$HOME/WindowIdentityProbe observe ${T_PID} 90 </dev/null >\$HOME/observe.json 2>/dev/null &" || true
sleep 3
focus "${A}"
expect_receipt "${A}"
expect_focused TextEdit ".window.privateWindowId == ${A_ID}"
guest "pgrep -x WindowIdentityProbe" >/dev/null || fail "the witness is not observing before the window is closed"
echo "closing at $(guest 'date -u +%Y-%m-%dT%H:%M:%SZ')"
testanyware input key w --modifiers cmd >/dev/null
sleep 3
# Seen to have closed, natively, before anything is concluded from the witness.
listed "${T_PID}" "[.windows[] | select(.privateWindowId == ${A_ID})] | length == 0"
tries=0
until guest "[ -s \$HOME/observe.json ]" >/dev/null 2>&1; do
    tries=$((tries + 1))
    [ "${tries}" -lt 50 ] || fail "the witness never finished"
    sleep 2
done
OBSERVED="$(guest_json "cat \$HOME/observe.json")"
echo "${OBSERVED}"
jq -e ".trusted == true and .observerAXError == 0 and (.registrationAXErrors | length == 2 and all(.[]; . == 0)) and ([.destroyed[].privateWindowId] == [${A_ID}])" >/dev/null <<<"${OBSERVED}" ||
    fail "the witness was not told of the destruction of window ${A_ID} alone"
choices TextEdit
expect '.response.data.desktopApplication.windows | length == 1' "TextEdit does not list one window after the other closed"
expect_row remembered-b.txt "${B}" CURRENT
lookup window "${A}"
expect_unavailable desktopWindow "the closed window"
guest 'open -a Finder' || true
refused "${A}" "the closed window"

step "Close the management window: everything from here runs without it"
testanyware agent window-close --window "${APP_NAME}" >/dev/null
sleep 2

step "A terminated application leaves nothing, under its own incarnation or its successor's"
focus "${B}"
expect_receipt "${B}"
expect_focused TextEdit '.window.title == "remembered-b.txt"'
other_space
choices TextEdit
expect '.response.data.desktopApplication.windows | length == 1' "TextEdit does not list exactly its one window on another Space"
expect_row remembered-b.txt "${B}" REMEMBERED
guest "killall TextEdit" || true
sleep 3
guest "! pgrep -x TextEdit" >/dev/null || fail "TextEdit still runs"
lookup window "${B}"
expect_unavailable desktopWindow "a remembered window of the application that ended"
lookup application-plain "${TEXTEDIT_REF}"
expect_unavailable desktopApplicationByReference "the application that ended"
# A killed TextEdit restores its windows, full screen included, and the rest of
# the run would happen inside that Space: -F opens it fresh, restoring nothing.
# shellcheck disable=SC2016  # guest-side $HOME
guest 'open -F -a TextEdit $HOME/remembered-c.txt' || true
sleep 5
choices TextEdit
# What the successor lists is its own and seen now.
expect_row remembered-c.txt "$(rows remembered-c.txt | jq -r '.[0].ref')" CURRENT
expect "[.response.data.desktopApplication.windows[] | select(.observation != \"CURRENT\" or .ref == \"${B}\" or .ref == \"${A}\")] | length == 0" \
    "the successor lists something remembered from the earlier incarnation"
expect '.response.data.desktopApplication.ref != "'"${TEXTEDIT_REF}"'"' "the successor has the earlier incarnation's reference"
echo "Observation: the successor lists $(jq -c '[.response.data.desktopApplication.windows[].title]' <<<"${ANSWER}")."

step "With the management window closed, a window opened and moved afterwards is still remembered"
# shellcheck disable=SC2016  # guest-side $HOME
guest 'echo d > $HOME/remembered-d.txt; open -a TextEdit $HOME/remembered-d.txt' || true
sleep 5
choices TextEdit
D="$(rows remembered-d.txt | jq -r '.[0].ref')"
expect_row remembered-d.txt "${D}" CURRENT
focus "${D}"
expect_receipt "${D}"
expect_focused TextEdit '.window.title == "remembered-d.txt"'
D_ID="$(jq -r '.window.privateWindowId' <<<"${WITNESS}")"
D_PID="$(jq -r '.application.pid' <<<"${WITNESS}")"
other_space
listed "${D_PID}" "[.windows[] | select(.privateWindowId == ${D_ID})] | length == 0"
choices TextEdit
expect_row remembered-d.txt "${D}" REMEMBERED
focus "${D}"
expect_receipt "${D}"
sleep 2
expect_focused TextEdit ".window.privateWindowId == ${D_ID}"
testanyware input key f --modifiers ctrl,cmd >/dev/null # leave full screen
sleep 5

step "Quit Koine: prompt, with observation running"
guest "open ${INSTALLED}" || true
place_window
quit_koine

step "PASSED — transcript in ${LOG}"
