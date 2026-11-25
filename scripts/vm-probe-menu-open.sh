#!/bin/bash
# A bounded probe, not an acceptance. It qualifies the open-menu signal of the
# Settings scenario (scripts/vm-settings-scenario-lib.sh) on a real guest.
#
# The probe installs the notarised Koine bundle on its own clone, closes the
# Settings window of the first launch, grants the test agent its System Events
# consent and opens TextEdit. It then reads two candidates for every TextEdit
# menu bar item and for the Koine item: the size of each menu under the item,
# and the `selected` attribute of the item. It reads them once with no menu
# open, once while each menu is open after a click on its item, and once after
# Escape closes it again. Each read keeps a screenshot. Nothing is asserted. The
# summary prints each read beside its state, and the screenshots are the
# independent evidence. The result and its limits:
# docs/verification/menu-bar-vm.md#the-open-menu-signal
#
# KOINE_TESTANYWARE_CLI is the absolute path of the testanyware executable.
# KOINE_VM_BASE names the golden image to clone. Both are required.
# KOINE_PROBE_VM names the clone (default koine-menu-oracle-probe).
# KOINE_PROBE_ZIP is the bundle zip (default: the notarised 0.4.1 zip).
# KOINE_PROBE_OUT is a new output directory (default under .build/vm-verify).
# The probe stops its clone when it ends, also after a failure.
set -euo pipefail

cd "$(dirname "$0")/.."

CLI="${KOINE_TESTANYWARE_CLI:?set KOINE_TESTANYWARE_CLI to the testanyware executable}"
BASE="${KOINE_VM_BASE:?set KOINE_VM_BASE to the golden image}"
VM="${KOINE_PROBE_VM:-koine-menu-oracle-probe}"
ZIP="${KOINE_PROBE_ZIP:-.build/release-0.4.1/Koine-0.4.1-aarch64-apple-darwin.zip}"
OUT="${KOINE_PROBE_OUT:-.build/vm-verify/menu-oracle-$(date -u +%Y%m%dT%H%M%SZ)}"
KOINE_ITEM='menu bar item 1 of menu bar 2 of process "Koine"'
TEXTEDIT_BAR='menu bar 1 of process "TextEdit"'

[[ -f "${ZIP}" ]] || {
    echo "no bundle zip at ${ZIP}" >&2
    exit 2
}
mkdir "${OUT}"
STARTED=""

# stop_clone: the screen as the probe left it, then the stop of the clone.
stop_clone() {
    [[ -n "${STARTED}" ]] || return 0
    "${CLI}" screen capture --vm "${VM}" -o "${OUT}/exit.png" >/dev/null 2>&1 || :
    "${CLI}" vm stop "${VM}" >"${OUT}/vm-stop.log" 2>&1 || :
}
trap stop_clone EXIT

# guest COMMAND: one guest command. The first System Events request after the
# consent grant has exceeded the default 30 s limit of the exec.
guest() { "${CLI}" file exec --vm "${VM}" --timeout 90 -- "$1"; }

# sysevents SCRIPT: one System Events request through osascript in the guest.
# "-s s" prints the value in source form, so lists and strings stay distinct.
sysevents() { guest "osascript -s s -e 'tell application \"System Events\" to $1'"; }

# read_or_note SCRIPT: one read, or the text of its failure.
read_or_note() {
    local value
    value="$(sysevents "$1" 2>&1)" || value="unavailable: ${value}"
    printf '%s' "${value}"
}

# observe LABEL: both candidates and a screenshot of the same state.
observe() {
    local label="$1" sizes selected
    sizes="$(read_or_note "get {size of every menu of every menu bar item of ${TEXTEDIT_BAR}, size of every menu of ${KOINE_ITEM}}")"
    selected="$(read_or_note "get {selected of every menu bar item of ${TEXTEDIT_BAR}, selected of ${KOINE_ITEM}}")"
    "${CLI}" screen capture --vm "${VM}" -o "${OUT}/${label}.png" >/dev/null
    printf '%s\t%s\t%s\n' "${label}" "${sizes}" "${selected}" | tee -a "${OUT}/reads.tsv"
}

# click_centre "{x, y}, {w, h}": one click at the centre of a frame.
click_centre() {
    local x y w h
    read -r x y w h <<<"$(tr -d '{},' <<<"$1")"
    "${CLI}" input click --vm "${VM}" $((x + w / 2)) $((y + h / 2)) >/dev/null
}

# probe_item LABEL REFERENCE: open one menu, observe it, close it, observe again.
probe_item() {
    local label="$1" reference="$2" frame
    frame="$(sysevents "get {position, size} of ${reference}")"
    click_centre "${frame}"
    sleep 1
    observe "open-${label}"
    "${CLI}" input key --vm "${VM}" escape >/dev/null
    sleep 1
    observe "closed-${label}"
}

echo "Start the clone ${VM} from ${BASE}"
"${CLI}" vm start --platform macos --wait --base "${BASE}" --id "${VM}" >"${OUT}/vm-start.log" 2>&1
STARTED=1
guest "sw_vers" | tee "${OUT}/system.txt"

echo "Install and launch ${ZIP}"
"${CLI}" file upload --vm "${VM}" "${ZIP}" /tmp/Koine.zip >/dev/null
guest "ditto -x -k /tmp/Koine.zip /Applications && open /Applications/Koine.app"
sleep 8

# The close comes first. After the consent click, the agent's window close
# timed out twice on this route.
echo "Close the Settings window of the first launch"
"${CLI}" agent window-close --vm "${VM}" --window "Koine Settings" >/dev/null

echo "Grant the test agent its System Events consent"
guest "nohup osascript -e 'tell application \"System Events\" to get name of every process' >/dev/null 2>&1 &"
# The OCR search stops at a substring, such as "Allowing control" in the body,
# so the probe waits for an exact "Allow" button. Coordinates may be fractional.
ALLOW=""
for _ in 1 2 3 4 5 6 7 8 9 10; do
    ALLOW="$("${CLI}" screen find-text --vm "${VM}" Allow --timeout 30 --json |
        jq -r '[.detections[] | select(.text == "Allow")][0] // empty
            | "{\(.x | floor), \(.y | floor)}, {\(.width | floor), \(.height | floor)}"')"
    [[ -z "${ALLOW}" ]] || break
    sleep 2
done
[[ -n "${ALLOW}" ]] || {
    echo "the Automation prompt shows no Allow button" >&2
    exit 1
}
click_centre "${ALLOW}"
sleep 2

echo "Open TextEdit in front"
guest "open -a TextEdit"
sleep 8

NAMES="$(sysevents "get name of every menu bar item of ${TEXTEDIT_BAR}")"
echo "TextEdit menu bar items: ${NAMES}" | tee "${OUT}/items.txt"
printf 'label\tmenu sizes {TextEdit items, Koine item}\tselected {TextEdit items, Koine item}\n' >"${OUT}/reads.tsv"
observe closed-initial
COUNT="$(sysevents "get count of menu bar items of ${TEXTEDIT_BAR}")"
for ((index = 1; index <= COUNT; index++)); do
    probe_item "textedit-${index}" "menu bar item ${index} of ${TEXTEDIT_BAR}"
done
probe_item koine "${KOINE_ITEM}"
echo "Reads and screenshots: ${OUT}"
