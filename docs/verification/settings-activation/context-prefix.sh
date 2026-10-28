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

cd "$(dirname "$0")/../../.."
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

# Inventory the installed subject, separately from the extracted host input.
# The completion marker rejects a truncated read, including a false exec timeout.
record_installed_bundle() {
    local phase="$1" inventory
    inventory="$(guest_text "set -euo pipefail; cd '${INSTALLED}'; find . -type f -exec shasum -a 256 {} + | LC_ALL=C sort; find . -type l -exec stat -f '%N -> %Y' {} + | LC_ALL=C sort; echo KOINE_INVENTORY_COMPLETE")"
    [ "${inventory##*$'\n'}" = KOINE_INVENTORY_COMPLETE ] || fail "incomplete installed bundle inventory (${phase})"
    printf '%s\n' "${inventory%$'\n'KOINE_INVENTORY_COMPLETE}" > "${LOG%.log}-installed-${phase}.txt"
    echo "Installed bundle inventory: ${LOG%.log}-installed-${phase}.txt"
}

start_vm
install_app
record_installed_bundle before
bash docs/verification/settings-activation/context-trace-disabled.sh before
testanyware file upload scripts/vm-verify-enrollment-client.py /Users/admin/vm-verify-enrollment-client.py >/dev/null
grant_system_events_automation

step "Start the native unified-log sidecar before Koine"
testanyware file upload docs/verification/settings-activation/context-guest-log.sh /Users/admin/native-guest-log.sh >/dev/null
testanyware file upload docs/verification/settings-activation/context-predicate.txt /Users/admin/context-predicate.txt >/dev/null
testanyware file upload docs/verification/settings-activation/native-guest-stop.sh /Users/admin/native-guest-stop.sh >/dev/null
bash docs/verification/settings-activation/native-start.sh

step "First launch: no Dock icon, one menu bar item, and the settings window because setup needs the user"
guest_once "open ${INSTALLED}"
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
for reopen in 1 2 3; do
    testanyware agent window-close --window "${WINDOW_TITLE}" >/dev/null
    await_windows 0
    choose_menu_item "Settings…"
    await_windows 1
    koine_in_front || fail "Settings reopen ${reopen} did not bring the window to the front: $(front_windows)"
done
