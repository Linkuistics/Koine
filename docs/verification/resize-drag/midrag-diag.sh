#!/bin/bash
# One-off diagnostic: the frame after every held point of a paced drag, while
# the button stays down. Run from the repository root.
set -euo pipefail
CLI="${KOINE_TESTANYWARE_CLI:?}"; BASE="${KOINE_VM_BASE:?}"; VM=koine-midrag-diag
OUT="$1"; mkdir "${OUT}"
ZIP=.build/release-0.4.1/Koine-0.4.1-aarch64-apple-darwin.zip
STARTED=""
stop_clone() { [[ -n "${STARTED}" ]] || return 0; "${CLI}" vm stop "${VM}" >"${OUT}/vm-stop.log" 2>&1 || :; }
trap stop_clone EXIT
guest() { "${CLI}" file exec --vm "${VM}" --timeout 90 -- "$1"; }
T='Koine Settings'
frame() { "${CLI}" agent windows --vm "${VM}" --json | jq -r --arg t "$T" '[.windows[]|select(.title==$t)][0]|"\(.positionX|floor) \(.positionY|floor) \(.sizeWidth|floor) \(.sizeHeight|floor)"'; }
log() { printf '%s\t%s\t%s\n' "$1" "$2" "$(frame)" | tee -a "${OUT}/reads.tsv"; }
pointer() { "${CLI}" input "$@" --vm "${VM}" >/dev/null; }
"${CLI}" vm start --platform macos --wait --base "${BASE}" --id "${VM}" >"${OUT}/vm-start.log" 2>&1
STARTED=1
"${CLI}" file upload --vm "${VM}" "${ZIP}" /tmp/Koine.zip >/dev/null
guest "ditto -x -k /tmp/Koine.zip /Applications && open /Applications/Koine.app"
sleep 8
# run NAME POINTS...: move to the first point, press, hold each later point
# with a read after each, release at the last, read at once and after 2 s.
run() {
    local name="$1"; shift
    "${CLI}" agent window-resize --vm "${VM}" --window "$T" --width 480 --height 712 >/dev/null
    "${CLI}" agent window-move --vm "${VM}" --window "$T" --x 40 --y 40 >/dev/null
    "${CLI}" agent window-focus --vm "${VM}" --window "$T" >/dev/null
    sleep 1
    log "${name}" start
    local p last
    pointer move ${1/,/ }; sleep 0.5
    for p in "$@"; do pointer mouse-down ${p/,/ }; sleep 0.15; log "${name}" "down ${p}"; last="$p"; done
    sleep 1; log "${name}" "held 1s after ${last}"
    pointer mouse-up ${last/,/ }; sleep 1; log "${name}" "released ${last}"
    sleep 2; log "${name}" "released +2s"
}
run paced 517,749 539,768 561,787 583,806 606,825 628,844 650,863 673,882 695,901 717,920 740,940
run extra 517,749 539,768 561,787 583,806 606,825 628,844 650,863 673,882 695,901 717,920 740,940 745,945 750,950 740,940
"${CLI}" screen capture --vm "${VM}" -o "${OUT}/last.png" >/dev/null
