#!/bin/bash
# One-off diagnostic: the visible frame of the guest's screen, and frozen drags
# to destinations inside and outside it. Run from the repository root.
set -euo pipefail
CLI="${KOINE_TESTANYWARE_CLI:?}"; BASE="${KOINE_VM_BASE:?}"; VM=koine-visible-frame-diag
OUT="$1"; mkdir "${OUT}"
ZIP=.build/release-0.4.1/Koine-0.4.1-aarch64-apple-darwin.zip
BEFORE=docs/verification/resize-drag/before-source/vm-window-resize-lib.sh
unset KOINE_VM_EVIDENCE_ROOT
testanyware() { "${CLI}" "$@" --vm "${VM}"; }
fail() { echo "FAILED: $*" >&2; return 1; }
source scripts/vm-window-resize-lib.sh
eval "$(sed -e '/^source /d' -e 's/^drag_window_corner()/drag_before()/' "${BEFORE}")"
STARTED=""
stop_clone() { [[ -n "${STARTED}" ]] || return 0; "${CLI}" vm stop "${VM}" >"${OUT}/vm-stop.log" 2>&1 || :; }
trap stop_clone EXIT
guest() { "${CLI}" file exec --vm "${VM}" --timeout 90 -- "$1"; }
frame() { "${CLI}" agent windows --vm "${VM}" --json | jq -r --arg t "$1" '[.windows[]|select(.title==$t)][0]|"\(.positionX|floor) \(.positionY|floor) \(.sizeWidth|floor) \(.sizeHeight|floor)"'; }
T='Koine Settings'
"${CLI}" vm start --platform macos --wait --base "${BASE}" --id "${VM}" >"${OUT}/vm-start.log" 2>&1
STARTED=1
"${CLI}" file upload --vm "${VM}" "${ZIP}" /tmp/Koine.zip >/dev/null
guest "ditto -x -k /tmp/Koine.zip /Applications && open /Applications/Koine.app"
sleep 8
guest "osascript -l JavaScript -e 'ObjC.import(\"AppKit\"); var s=\$.NSScreen.mainScreen; var f=s.frame, v=s.visibleFrame; JSON.stringify({frame:[f.origin.x,f.origin.y,f.size.width,f.size.height], visible:[v.origin.x,v.origin.y,v.size.width,v.size.height]})'" | tee "${OUT}/screen.json"
guest "defaults read com.apple.dock tilesize; defaults read com.apple.dock magnification; defaults read com.apple.dock orientation" >"${OUT}/dock.txt" 2>&1 || :
cat "${OUT}/dock.txt"
for dest in "740 900" "740 960" "800 700"; do
    "${CLI}" agent window-resize --vm "${VM}" --window "$T" --width 480 --height 712 >/dev/null
    "${CLI}" agent window-move --vm "${VM}" --window "$T" --x 40 --y 40 >/dev/null
    "${CLI}" agent window-focus --vm "${VM}" --window "$T" >/dev/null
    sleep 1
    start="$(frame "$T")"
    # shellcheck disable=SC2086
    drag_before ${dest} "$T" 2>/dev/null
    printf 'destination %s\tstart %s\tafter %s\n' "${dest}" "${start}" "$(frame "$T")" | tee -a "${OUT}/drags.tsv"
done
"${CLI}" screen capture --vm "${VM}" -o "${OUT}/last.png" >/dev/null
