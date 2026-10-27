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

cd "$1"
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="menu-bar-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

# shellcheck disable=SC2016  # guest-side $HOME
WINDOW_TITLE="Koine Settings"
# The least content size of the settings window (ManagementView.minimumSize) and
# its default (ManagementView.defaultSize); the frame adds the title bar.
MIN_WIDTH=440 MIN_HEIGHT=320

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

# One focused attempt of the revised explicit-focus recipe in a fresh clone.
start_vm
install_app
record_installed_bundle before
guest_once "open ${INSTALLED}"
await_koine
await_windows 1
step "The window resizes: larger, then no smaller than its least size, where its content scrolls"
testanyware agent window-move --window "${WINDOW_TITLE}" --x 40 --y 40 >/dev/null
testanyware agent window-focus --window "${WINDOW_TITLE}" >/dev/null
koine_in_front || fail "the window is not focused for the resize exercise: $(front_windows)"
sleep 1
# A title-bar drag is no proxy for corner delivery: it stayed still in the same
# guest where a held-button corner path grew and shrank this window. Exercise
# the corner itself, retaining the original dimension and content requirements.
drag_window_corner 740 940
echo "Larger: $(frame)"
read -r _ _ W H <<<"$(frame)"
[ "${W}" -ge 690 ] && [ "${H}" -ge 880 ] || fail "the window did not grow; resize acceptance is unestablished"
drag_window_corner 100 100
echo "Smaller: $(frame)"
read -r _ _ W H <<<"$(frame)"
[ "${W}" = "${MIN_WIDTH}" ] || fail "the window's least width is not ${MIN_WIDTH}: ${W}"
[ "${H}" -ge "${MIN_HEIGHT}" ] && [ "${H}" -lt $((MIN_HEIGHT + 60)) ] || fail "the window's least height is not ${MIN_HEIGHT} plus its title bar: ${H}"
testanyware screen capture -o "${LOG%.log}-least-size-${W}x${H}.png" >/dev/null
# Every control stays reachable by scrolling at the observed minimum size.
calibrate_window_scroll
reveal '.id=="login-launch"'
reveal '.id=="grant-label"'
reveal '.id=="accessibility-status"'

echo "Reached controls by scrolling: login-launch, grant-label, accessibility-status"
echo "Frame after scrolling: $(frame)"
testanyware agent windows --json > "${LOG%.log}-windows-after-scroll.json"
record_installed_bundle after
cmp "${LOG%.log}-installed-before.txt" "${LOG%.log}-installed-after.txt" || fail "the installed bundle changed during the focused attempt"
step "PASSED focused resize/scroll segment only"
