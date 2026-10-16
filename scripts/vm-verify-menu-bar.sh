#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM, that Koine is
# a menu bar application: no Dock icon and one menu bar item from launch to Quit;
# its menu, status lines, mark and accessibility label as Accessibility consent
# and client grant requests come and go; the settings window at first launch and
# not once setup is complete, opened from the menu over another application's
# window however often it was closed, resizable, with its shortcuts working and
# with no visible menu bar; a client's request never opening it; reopening the
# running application showing it; login launch across a VM restart; and Quit from
# the menu. Nothing here runs the application on the host. The procedure and its
# recorded evidence: docs/verification/menu-bar-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="menu-bar-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

# shellcheck disable=SC2016  # guest-side $HOME
FIRST='$HOME/koine-secret-first' SECOND='$HOME/koine-secret-second'
WINDOW_TITLE="Koine Settings"
# The least content size of the settings window (ManagementView.minimumSize) and
# its default (ManagementView.defaultSize); the frame adds the title bar.
MIN_WIDTH=440 MIN_HEIGHT=320 DEFAULT_WIDTH=480 DEFAULT_HEIGHT=680

# enrol <secret file> <label>: a client asks for a capability; anonymous.
enrol() {
    guest_json "python3 \$HOME/vm-verify-enrollment-client.py \"$1\" enrol \"$2\" desktop:read" |
        jq -e '.status == 200 and ((.response.errors // []) | length == 0)' >/dev/null ||
        fail "enrollment of $2 was refused"
}
# frame: "x y w h" of the settings window.
frame() {
    testanyware agent windows --json | jq -r --arg title "${WINDOW_TITLE}" \
        '[.windows[] | select(.title == $title)][0] | "\(.positionX | floor) \(.positionY | floor) \(.sizeWidth | floor) \(.sizeHeight | floor)"'
}
# expect_menu <titles>: the open-and-read menu is exactly this.
expect_menu() {
    read_menu
    [ "${MENU}" = "$1" ] || fail "the menu is \"${MENU}\", not \"$1\""
}
# await_koine: the process runs and has served its descriptor.
await_koine() {
    for _ in $(seq 1 15); do
        if guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1; then return; fi
        sleep 2
    done
    fail "no endpoint descriptor after launch"
}
# await_settled: past the 2 s follow, so a window or a label has had its say.
await_settled() { sleep 6; }
# expect_stopped: Quit stopped the server as it always has.
expect_stopped() {
    sleep 3
    guest "! pgrep -f ${INSTALLED}/Contents/MacOS" >/dev/null || fail "Koine still runs after Quit"
    guest "[ ! -e \"${DATA}/endpoint.json\" ]" || fail "the descriptor survived Quit"
}

start_vm
install_app
testanyware file upload scripts/vm-verify-enrollment-client.py /Users/admin/vm-verify-enrollment-client.py >/dev/null
grant_system_events_automation

step "First launch: no Dock icon, one menu bar item, and the settings window because setup needs the user"
guest "open ${INSTALLED}" || true
await_koine
await_windows 1
echo "Windows: $(testanyware agent windows --json | jq -c "[.windows[] | select(.appName == \"${APP_NAME}\") | .title]")"
echo "Default frame: $(frame)"
read -r _ _ W H <<<"$(frame)"
[ "${W}" = "${DEFAULT_WIDTH}" ] && [ "${H}" -ge "${DEFAULT_HEIGHT}" ] && [ "${H}" -lt $((DEFAULT_HEIGHT + 60)) ] ||
    fail "the window did not open at ${DEFAULT_WIDTH}x${DEFAULT_HEIGHT} plus its title bar: ${W}x${H}"
testanyware agent windows --json |
    jq -e --arg title "${WINDOW_TITLE}" '[.windows[] | select(.appName == "Koine")][0].title == $title' >/dev/null ||
    fail "the window is not titled \"${WINDOW_TITLE}\""
BACKGROUND="$(sysevents 'get background only of process "Koine"')"
echo "Background only (an agent application): ${BACKGROUND}"
[ "${BACKGROUND}" = true ] || fail "Koine is not an agent application"
DOCK="$(sysevents 'get name of every UI element of list 1 of process "Dock"')"
echo "Dock: ${DOCK}"
! grep -q "Koine" <<<"${DOCK}" || fail "Koine has a Dock icon"
[ "$(menu_item_count)" = 1 ] || fail "Koine has not exactly one menu bar item"
echo "Item: $(menu_item_label)"
await_menu_item_label "Koine, Accessibility not granted"
expect_menu "Accessibility Not Granted…, , Settings…, Quit Koine"
testanyware screen capture -o "${LOG%.log}-first-launch.png" >/dev/null

step "No visible menu bar, even with the window open: the menu bar stays the previous application's"
guest "open -a TextEdit" || true
# Observed: on a clean clone, Settings… chosen within seconds of TextEdit's first
# launch left the window behind TextEdit's in three runs of five, and never once
# TextEdit had been up a while. The cause is not established (TextEdit taking the
# front again as its document appears is the suspect), so the check lets it settle.
for _ in $(seq 1 15); do
    testanyware agent windows --json | jq -e '[.windows[] | select(.appName == "TextEdit")] | length >= 1' >/dev/null && break
    sleep 2
done
testanyware agent windows --json | jq -e '[.windows[] | select(.appName == "TextEdit")] | length >= 1' >/dev/null ||
    fail "TextEdit has no window"
sleep 8
testanyware agent window-move --window TextEdit --x 700 --y 120 >/dev/null
sleep 1
# TextEdit is in front of Koine's window, which is where it was first placed.
koine_in_front && fail "Koine is in front before it was asked to be"
echo "Front application: $(sysevents 'get name of first process whose frontmost is true')"

step "Close the window; Settings… brings it back over TextEdit's, to the front"
testanyware agent window-close --window "${WINDOW_TITLE}" >/dev/null
await_windows 0
[ "$(menu_item_count)" = 1 ] || fail "the menu bar item went with the window"
choose_menu_item "Settings…"
await_windows 1
koine_in_front || fail "the window did not come to the front over TextEdit's: $(front_windows); front application: $(sysevents 'get name of first process whose frontmost is true')"
testanyware screen capture -o "${LOG%.log}-over-textedit.png" >/dev/null
for _ in 1 2 3; do
    testanyware agent window-close --window "${WINDOW_TITLE}" >/dev/null
    await_windows 0
    choose_menu_item "Settings…"
    await_windows 1
done
koine_in_front || fail "the window did not come to the front after being closed three more times"
guest "osascript -e 'tell application \"TextEdit\" to quit saving no'" || true

step "The window resizes: larger, then no smaller than its least size, where its content scrolls"
testanyware agent window-move --window "${WINDOW_TITLE}" --x 40 --y 40 >/dev/null
sleep 1
drag_window_corner 740 940
echo "Larger: $(frame)"
read -r _ _ W H <<<"$(frame)"
[ "${W}" -ge 690 ] && [ "${H}" -ge 880 ] || fail "the window did not grow"
drag_window_corner 100 100
echo "Smaller: $(frame)"
read -r _ _ W H <<<"$(frame)"
[ "${W}" = "${MIN_WIDTH}" ] || fail "the window's least width is not ${MIN_WIDTH}: ${W}"
[ "${H}" -ge "${MIN_HEIGHT}" ] && [ "${H}" -lt $((MIN_HEIGHT + 60)) ] || fail "the window's least height is not ${MIN_HEIGHT} plus its title bar: ${H}"
testanyware screen capture -o "${LOG%.log}-least-size.png" >/dev/null
# Every control stays reachable by scrolling, at the least size.
calibrate_window_scroll
reveal '.id=="login-launch"'
reveal '.id=="grant-label"'
reveal '.id=="accessibility-status"'

step "Shortcuts, with no visible menu bar: ⌘A, ⌘C, ⌘X, ⌘V in a field, ⌘W"
reveal_click '.id=="grant-label"'
testanyware input type "shortcut" >/dev/null
sleep 1
[ "$(value_of '.id=="grant-label"')" = shortcut ] || fail "typing reached no field"
testanyware input key a --modifiers cmd >/dev/null
testanyware input key c --modifiers cmd >/dev/null
testanyware input key x --modifiers cmd >/dev/null
sleep 1
[ -z "$(value_of '.id=="grant-label"')" ] || fail "⌘A ⌘X did not empty the field"
testanyware input key v --modifiers cmd >/dev/null
sleep 1
[ "$(value_of '.id=="grant-label"')" = shortcut ] || fail "⌘V did not restore what ⌘C copied"
testanyware input key a --modifiers cmd >/dev/null
testanyware input key x --modifiers cmd >/dev/null
testanyware input key w --modifiers cmd >/dev/null
await_windows 0
[ "$(menu_item_count)" = 1 ] || fail "⌘W took the menu bar item with it"

step "A client's request shows the mark and a line within a poll, and never opens the window"
enrol "${FIRST}" "vm-editor"
await_menu_item_label "Koine, 1 grant request waiting, Accessibility not granted"
await_settled
[ "$(koine_windows)" = 0 ] || fail "a client's request brought the window forward"
expect_menu "Review 1 Grant Request…, Accessibility Not Granted…, , Settings…, Quit Koine"
testanyware screen capture --region 1500,0,420,200 -o "${LOG%.log}-mark.png" >/dev/null
enrol "${SECOND}" "vm-second"
await_menu_item_label "Koine, 2 grant requests waiting, Accessibility not granted"
expect_menu "Review 2 Grant Requests…, Accessibility Not Granted…, , Settings…, Quit Koine"
[ "$(koine_windows)" = 0 ] || fail "a second request brought the window forward"

step "The line opens the window at Requests, scrolled there from the least size"
choose_menu_item "Review 2 Grant Requests…"
await_windows 1
koine_in_front || fail "the window did not come to the front"
sleep 2
read_frame
on_screen '(.id // "") | startswith("request-label-")' || fail "the window did not scroll to the requests"
echo "Requests on screen: $(element '(.id // "") | startswith("request-label-")' | jq -c '[.id, .value]')"
testanyware screen capture -o "${LOG%.log}-requests.png" >/dev/null
click '(.id // "") | startswith("deny-")'
sleep 4
click '(.id // "") | startswith("deny-")'
sleep 4
await_menu_item_label "Koine, Accessibility not granted"
expect_menu "Accessibility Not Granted…, , Settings…, Quit Koine"

step "The Accessibility line opens the window at Accessibility, scrolled there from below"
reveal '.id=="login-launch"'
testanyware agent window-close --window "${WINDOW_TITLE}" >/dev/null
await_windows 0
choose_menu_item "Accessibility Not Granted…"
await_windows 1
sleep 2
read_frame
on_screen '.id=="accessibility-status"' || fail "the window did not scroll to Accessibility"

step "Consent given in System Settings: the mark and the line go within a poll"
grant_accessibility
await_menu_item_label "Koine"
expect_menu "Settings…, Quit Koine"
await_windows 1

step "Setup complete: enable login launch, Quit from the menu, and a launch by hand starts silently"
reveal_click '.id=="login-launch"'
[ "$(value_of '.id=="login-launch-status"')" = "Koine will start when you log in." ] || fail "login launch is not enabled"
choose_menu_item "Quit Koine"
expect_stopped
guest_once "open ${INSTALLED}"
await_koine
await_settled
[ "$(koine_windows)" = 0 ] || fail "the window opened though setup is complete"
await_menu_item_label "Koine"
echo "Item: $(menu_item_label); windows: $(koine_windows)"

step "Opening Koine again while it runs shows the window"
guest "open ${INSTALLED}" || true
await_windows 1
koine_in_front || fail "reopening did not bring the window to the front: $(front_windows)"
testanyware agent window-close --window "${WINDOW_TITLE}" >/dev/null
await_windows 0

step "Quit with ⌘Q from the window, then restart the VM: only the login item can start Koine"
choose_menu_item "Settings…"
await_windows 1
testanyware input key q --modifiers cmd >/dev/null
expect_stopped
BOOT_BEFORE="$(guest 'sysctl -n kern.boottime')"
# Not through guest(): a restart must never be repeated by a retry.
testanyware file exec 'echo admin | sudo -S shutdown -r now' >/dev/null 2>&1 || true
sleep 30
for _ in $(seq 1 60); do
    BOOT_AFTER="$(guest 'sysctl -n kern.boottime' 2>/dev/null || true)"
    if [ -n "${BOOT_AFTER}" ] && [ "${BOOT_AFTER}" != "${BOOT_BEFORE}" ]; then break; fi
    sleep 5
done
[ -n "${BOOT_AFTER}" ] && [ "${BOOT_AFTER}" != "${BOOT_BEFORE}" ] || fail "the VM did not come back from its restart"

step "After login, with nothing having launched Koine: the item, and no window"
for _ in $(seq 1 24); do
    if guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1; then break; fi
    sleep 5
done
guest "pgrep -lf ${INSTALLED}" || fail "Koine was not started at login"
await_koine
await_settled
[ "$(menu_item_count)" = 1 ] || fail "no menu bar item after login launch"
await_menu_item_label "Koine"
[ "$(koine_windows)" = 0 ] || fail "the window opened at login launch though setup is complete"
echo "Item after login launch: $(menu_item_label); windows: $(koine_windows)"
BACKGROUND="$(sysevents 'get background only of process "Koine"')"
[ "${BACKGROUND}" = true ] || fail "Koine started at login is not an agent application"
testanyware screen capture -o "${LOG%.log}-after-login.png" >/dev/null

step "Quit Koine from the menu: the server stops as it always has"
PORT="$(guest "jq -r .port \"${DATA}/endpoint.json\"")"
choose_menu_item "Quit Koine"
expect_stopped
REFUSED=""
for _ in 1 2 3 4; do
    REFUSED="$(guest "curl -s -m 3 -o /dev/null http://127.0.0.1:${PORT}/graphql; echo \$?" || true)"
    [ -z "${REFUSED}" ] || break
done
echo "curl to the old port ${PORT}: exit ${REFUSED}"
[ "${REFUSED}" = 7 ] || fail "something still answers on port ${PORT}"

step "PASSED — transcript in ${LOG}"
