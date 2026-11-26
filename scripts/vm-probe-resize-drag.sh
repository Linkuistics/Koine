#!/bin/bash
# A bounded probe, not an acceptance. It compares the corner drag of the shared
# scenario (scripts/vm-verify-menu-bar.sh) before and after its anchor
# point, on a real guest.
#
# The probe installs one Koine bundle on its own clone. Its first trial drags
# TextEdit's Untitled window with the drag from before the anchor point, as a
# control. Its next trial drags Koine's Settings window of the first launch
# with the same drag. The last two trials each drag a reopened Settings window
# with the drag of scripts/vm-window-resize-lib.sh. A reopened window keeps
# the last frame, so the probe first sets it to 480 by 712 through
# Accessibility, the frame of a new window.
#
# Each trial sets up its window as the scenario's resize step does. Then it
# drags the corner to 740, 940 and to 100, 100. It reads the frame at once
# after each drag and again two seconds later. The probe asserts nothing. The
# summary prints each frame, and the
# screenshots are the independent evidence. The result and its limits:
# docs/verification/menu-bar-vm.md#the-anchor-point
#
# The drag from before the anchor point is the frozen helper
# docs/verification/resize-drag/before-source/vm-window-resize-lib.sh. The
# probe runs both drags without an evidence root, so no receipt slows a request.
#
# KOINE_TESTANYWARE_CLI is the absolute path of the testanyware executable.
# KOINE_VM_BASE names the golden image to clone. Both are required.
# KOINE_PROBE_VM names the clone (default koine-resize-drag-probe).
# KOINE_PROBE_ZIP is the bundle zip (default: the notarised 0.4.1 zip).
# KOINE_PROBE_OUT is a new output directory (default under .build/vm-verify).
# The probe stops its clone when it ends, also after a failure.
set -euo pipefail

cd "$(dirname "$0")/.."

CLI="${KOINE_TESTANYWARE_CLI:?set KOINE_TESTANYWARE_CLI to the testanyware executable}"
BASE="${KOINE_VM_BASE:?set KOINE_VM_BASE to the golden image}"
VM="${KOINE_PROBE_VM:-koine-resize-drag-probe}"
ZIP="${KOINE_PROBE_ZIP:-.build/release-0.4.1/Koine-0.4.1-aarch64-apple-darwin.zip}"
OUT="${KOINE_PROBE_OUT:-.build/vm-verify/resize-drag-$(date -u +%Y%m%dT%H%M%SZ)}"
BEFORE=docs/verification/resize-drag/before-source/vm-window-resize-lib.sh
BEFORE_SHA256=6851d1bd6d88e8084a5d11db8f4fb7b531a42fcec588e36a2572d51b33b74405
SETTINGS_TITLE='Koine Settings'
TEXTEDIT_TITLE='Untitled'

[[ -f "${ZIP}" ]] || {
    echo "no bundle zip at ${ZIP}" >&2
    exit 2
}
[[ "$(shasum -a 256 "${BEFORE}" | cut -d' ' -f1)" == "${BEFORE_SHA256}" ]] || {
    echo "the frozen helper ${BEFORE} changed" >&2
    exit 2
}

# Both drags run in their legacy mode, which writes no receipt. The helpers
# address the clone through this function.
unset KOINE_VM_EVIDENCE_ROOT
testanyware() { "${CLI}" "$@" --vm "${VM}"; }
fail() {
    echo "FAILED: $*" >&2
    return 1
}
# shellcheck source=scripts/vm-window-resize-lib.sh
source scripts/vm-window-resize-lib.sh
# The frozen helper defines the same function. The copy renames it and drops
# its source line, because the live library supplies the same primitives.
eval "$(sed -e '/^source /d' -e 's/^drag_window_corner()/drag_before()/' "${BEFORE}")"

mkdir "${OUT}"
STARTED=""

# stop_clone: the screen as the probe left it, then the stop of the clone.
stop_clone() {
    [[ -n "${STARTED}" ]] || return 0
    "${CLI}" screen capture --vm "${VM}" -o "${OUT}/exit.png" >/dev/null 2>&1 || :
    "${CLI}" vm stop "${VM}" >"${OUT}/vm-stop.log" 2>&1 || :
}
trap stop_clone EXIT

# guest COMMAND: one guest command.
guest() { "${CLI}" file exec --vm "${VM}" --timeout 90 -- "$1"; }

# record LABEL TITLE: the window list and the frame of the window TITLE. The
# list keeps its whole JSON. The summary keeps the frame, the focused flag and
# the front window's application.
record() {
    local label="$1" title="$2" list row
    list="$("${CLI}" agent windows --vm "${VM}" --json)"
    printf '%s\n' "${list}" >"${OUT}/${label}.windows.json"
    row="$(jq -r --arg title "${title}" '
        ([.windows[] | select(.title == $title)][0]) as $w
        | ([.windows[] | select(.appName != "Notification Center")][0].appName) as $front
        | if $w == null then "absent\t-\t\($front)"
          else "\($w.positionX | floor) \($w.positionY | floor) \($w.sizeWidth | floor) \($w.sizeHeight | floor)\t\($w.focused)\t\($front)"
          end' <<<"${list}")"
    printf '%s\t%s\n' "${label}" "${row}" | tee -a "${OUT}/frames.tsv"
    [[ "${row}" != absent* ]] || {
        echo "the window ${title} is absent at ${label}" >&2
        exit 1
    }
}

# trial NAME TITLE DRAG: the resize exercise of the scenario on the window
# TITLE, with the drag function DRAG.
trial() {
    local name="$1" title="$2" drag="$3"
    echo "Trial ${name}: ${drag} on ${title}"
    "${CLI}" agent window-move --vm "${VM}" --window "${title}" --x 40 --y 40 >/dev/null
    "${CLI}" agent window-focus --vm "${VM}" --window "${title}" >/dev/null
    sleep 1
    record "${name}-start" "${title}"
    "${drag}" 740 940 "${title}" 2>>"${OUT}/${name}.pointer.log"
    record "${name}-grown" "${title}"
    sleep 2
    record "${name}-grown-later" "${title}"
    "${CLI}" screen capture --vm "${VM}" -o "${OUT}/${name}-grown.png" >/dev/null
    "${drag}" 100 100 "${title}" 2>>"${OUT}/${name}.pointer.log"
    record "${name}-least" "${title}"
    sleep 2
    record "${name}-least-later" "${title}"
    "${CLI}" screen capture --vm "${VM}" -o "${OUT}/${name}-least.png" >/dev/null
}

# reopen_settings: close the Settings window, then open the running Koine
# again, as the scenario's reopen step does. The window then takes the frame
# of a new window, 480 by 712.
reopen_settings() {
    "${CLI}" agent window-close --vm "${VM}" --window "${SETTINGS_TITLE}" >/dev/null
    sleep 2
    guest "open /Applications/Koine.app"
    sleep 3
    "${CLI}" agent window-resize --vm "${VM}" --window "${SETTINGS_TITLE}" --width 480 --height 712 >/dev/null
}

echo "Start the clone ${VM} from ${BASE}"
"${CLI}" vm start --platform macos --wait --base "${BASE}" --id "${VM}" >"${OUT}/vm-start.log" 2>&1
STARTED=1
guest "sw_vers" | tee "${OUT}/system.txt"
"${CLI}" --version | tee "${OUT}/testanyware.txt"
shasum -a 256 "${ZIP}" scripts/vm-window-resize-lib.sh "${BEFORE}" | tee "${OUT}/subjects.sha256"

echo "Install and launch ${ZIP}"
"${CLI}" file upload --vm "${VM}" "${ZIP}" /tmp/Koine.zip >/dev/null
guest "ditto -x -k /tmp/Koine.zip /Applications && open /Applications/Koine.app"
sleep 8

echo "Open TextEdit"
guest "open -a TextEdit"
sleep 8

printf 'label\tframe x y w h\tfocused\tfront application\n' >"${OUT}/frames.tsv"
"${CLI}" agent window-resize --vm "${VM}" --window "${TEXTEDIT_TITLE}" --width 480 --height 712 >/dev/null
trial textedit-before "${TEXTEDIT_TITLE}" drag_before
guest "osascript -e 'tell application \"TextEdit\" to quit saving no'"
sleep 2

trial koine-before "${SETTINGS_TITLE}" drag_before
reopen_settings
trial koine-after-1 "${SETTINGS_TITLE}" drag_window_corner
reopen_settings
trial koine-after-2 "${SETTINGS_TITLE}" drag_window_corner
echo "Frames and screenshots: ${OUT}"
