#!/bin/bash
# A bounded probe, not an acceptance. It qualifies the focus step before each
# Settings reopen of the shared scenario (scripts/vm-verify-menu-bar.sh) on a
# real guest.
#
# The probe installs the notarised Koine bundle on its own clone, closes the
# Settings window of the first launch, grants the test agent its System Events
# consent and opens TextEdit. It then runs three cycles, as the reopen loop
# does. Each cycle chooses Settings… from Koine's menu over TextEdit's window,
# closes the Settings window while Koine is active, sends the agent's
# window-focus to TextEdit and reads the window list at once, as the scenario
# does. It reads the list again after one second. If the focus step leaves
# TextEdit's window unfocused, a click on its title bar follows, with a third
# read. Each read keeps the front application and a screenshot. Nothing is
# asserted. The summary prints each read beside its state, and the screenshots
# are the independent evidence. The result and its limits:
# docs/verification/menu-bar-vm.md#the-reopen-focus-step
#
# KOINE_TESTANYWARE_CLI is the absolute path of the testanyware executable.
# KOINE_VM_BASE names the golden image to clone. Both are required.
# KOINE_PROBE_VM names the clone (default koine-reopen-focus-probe).
# KOINE_PROBE_ZIP is the bundle zip (default: the notarised 0.4.1 zip).
# KOINE_PROBE_OUT is a new output directory (default under .build/vm-verify).
# The probe stops its clone when it ends, also after a failure.
set -euo pipefail

cd "$(dirname "$0")/.."

CLI="${KOINE_TESTANYWARE_CLI:?set KOINE_TESTANYWARE_CLI to the testanyware executable}"
BASE="${KOINE_VM_BASE:?set KOINE_VM_BASE to the golden image}"
VM="${KOINE_PROBE_VM:-koine-reopen-focus-probe}"
ZIP="${KOINE_PROBE_ZIP:-.build/release-0.4.1/Koine-0.4.1-aarch64-apple-darwin.zip}"
OUT="${KOINE_PROBE_OUT:-.build/vm-verify/reopen-focus-$(date -u +%Y%m%dT%H%M%SZ)}"
KOINE_ITEM='menu bar item 1 of menu bar 2 of process "Koine"'
SETTINGS_TITLE='Koine Settings'

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

# observe LABEL: the window list, the front application and a screenshot of the
# same state. The list keeps its whole JSON; the summary keeps each window's
# application, title and focused flag, front to back, without Notification
# Center, as the scenario's setup judges it. FOCUSED is "true" when TextEdit's
# window is the first entry and focused.
observe() {
    local label="$1" list front summary
    list="$("${CLI}" agent windows --vm "${VM}" --json)"
    printf '%s\n' "${list}" >"${OUT}/${label}.windows.json"
    front="$(sysevents 'get name of first process whose frontmost is true' 2>&1)" ||
        front="unavailable: ${front}"
    "${CLI}" screen capture --vm "${VM}" -o "${OUT}/${label}.png" >/dev/null
    summary="$(jq -c '[.windows[] | select(.appName != "Notification Center")
        | [.appName, .title, .focused]]' <<<"${list}")"
    FOCUSED="$(jq -r '[.windows[] | select(.appName != "Notification Center")][0]
        | .appName == "TextEdit" and .focused == true' <<<"${list}")"
    printf '%s\t%s\t%s\t%s\n' "${label}" "${FOCUSED}" "${front}" "${summary}" | tee -a "${OUT}/reads.tsv"
}

# click_centre "{x, y}, {w, h}": one click at the centre of a frame.
click_centre() {
    local x y w h
    read -r x y w h <<<"$(tr -d '{},' <<<"$1")"
    "${CLI}" input click --vm "${VM}" $((x + w / 2)) $((y + h / 2)) >/dev/null
}

# click_title_bar: one click on the title bar of TextEdit's window, 14 points
# below its top edge and clear of its buttons, from the newest window list.
click_title_bar() {
    local point
    point="$(jq -r '[.windows[] | select(.appName == "TextEdit")][0]
        | "\(.positionX + .sizeWidth / 2 | floor) \(.positionY + 14 | floor)"' <<<"$1")"
    # shellcheck disable=SC2086 # The point is two integers.
    "${CLI}" input click --vm "${VM}" ${point} >/dev/null
}

# frame LABEL SCRIPT: one frame read, logged. An empty frame stops the probe,
# because a click at an empty frame would land on the Apple menu.
frame() {
    local value
    value="$(sysevents "$2")"
    printf '%s\t%s\n' "$1" "${value}" | tee -a "${OUT}/frames.tsv" >&2
    [[ "${value}" =~ [0-9] ]] || {
        echo "the frame $1 is empty" >&2
        exit 1
    }
    printf '%s' "${value}"
}

# choose_settings CYCLE: Settings… from Koine's menu, by the scenario's route.
# The screenshot shows the open menu before the row click.
choose_settings() {
    local item row
    item="$(frame "item-$1" "get {position, size} of ${KOINE_ITEM}")"
    click_centre "${item}"
    sleep 1
    row="$(frame "row-$1" "tell (first menu item of menu 1 of ${KOINE_ITEM} whose title starts with \"Settings\") to get {position, size}")"
    "${CLI}" screen capture --vm "${VM}" -o "${OUT}/menu-$1.png" >/dev/null
    click_centre "${row}"
    sleep 2
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
# timed out twice on this route (k5).
echo "Close the Settings window of the first launch"
"${CLI}" agent window-close --vm "${VM}" --window "${SETTINGS_TITLE}" >/dev/null

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

printf 'label\tTextEdit first and focused\tfront application\twindows [app, title, focused]\n' >"${OUT}/reads.tsv"
observe initial
for cycle in 1 2 3; do
    echo "Cycle ${cycle}: Settings…, close while Koine is active, focus TextEdit"
    choose_settings "${cycle}"
    observe "open-${cycle}"
    "${CLI}" agent window-close --vm "${VM}" --window "${SETTINGS_TITLE}" >/dev/null
    sleep 2
    observe "closed-${cycle}"
    "${CLI}" agent window-focus --vm "${VM}" --window TextEdit --json >"${OUT}/focus-${cycle}.json"
    # The scenario reads the list at once after the step, with no wait.
    observe "focused-${cycle}"
    sleep 1
    observe "focused-later-${cycle}"
    if [[ "${FOCUSED}" != true ]]; then
        click_title_bar "$(cat "${OUT}/focused-later-${cycle}.windows.json")"
        sleep 1
        observe "clicked-${cycle}"
    fi
done
echo "Reads and screenshots: ${OUT}"
