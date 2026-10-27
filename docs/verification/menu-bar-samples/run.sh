#!/bin/bash
# One declared k4 attempt; invoke from the repository root through Task.
set -euo pipefail

attempt="${1:-}" version="${2:-}"
case "${attempt}:${version}" in
01:0.3.0 | 02:0.4.0 | 03:0.4.0 | 04:0.3.0) ;;
*)
    echo 'Usage: run.sh {01 0.3.0|02 0.4.0|03 0.4.0|04 0.3.0}' >&2
    exit 2
    ;;
esac
root="$(pwd)"
evidence=docs/verification/menu-bar-samples
PATH="$(cat "${evidence}/tool-path.txt")"
export PATH
out="${root}/.build/menu-samples/results/${attempt}"
mkdir -p "$(dirname "${out}")"
mkdir "${out}" # Refuse overwrites and competing writers.
export KOINE_VM_ID="koine-k4-${attempt}"
export TESTANYWARE_VM_ID="${KOINE_VM_ID}"
export KOINE_APP_BUNDLE="${root}/.build/menu-samples/releases/${version}/Koine.app"
export KOINE_VM_BASE=testanyware-golden-macos-27 KOINE_VM_DISPLAY=1920x1080 KOINE_VM_KEEP=1

# shellcheck disable=SC2329 # Invoked by the EXIT trap.
cleanup() {
    testanyware vm stop "${KOINE_VM_ID}" --json >"${out}/stop.json" 2>"${out}/stop.stderr" || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
date -u '+%Y-%m-%dT%H:%M:%SZ' >"${out}/started.txt"
printf '%s\n' "${version}" >"${out}/version.txt"
shasum -a 256 -c "${evidence}/subjects-before.sha256" >"${out}/host-before-check.txt"
mkdir -p .build/vm-verify
find .build/vm-verify -type f -name 'menu-bar-*' | LC_ALL=C sort >"${out}/files-before.txt"
status=0
# Task reports its own exit (usually 201) for a failed script. The inner shell
# retains the real scenario status while executing the unchanged scenario once.
KOINE_K4_OUT="${out}" mise exec -- env PATH="${PATH}" task app:vm-verify-menu-bar >"${out}/task.log" 2>&1 || status=$?
printf '%s\n' "${status}" >"${out}/task.exit"
date -u '+%Y-%m-%dT%H:%M:%SZ' >"${out}/scenario-ended.txt"

# After failure, no key, focus, repeated menu action or application launch.
# The qualified k7 observer uses a fresh process for each native read.
if [ "${status}" -ne 0 ]; then
    testanyware file upload docs/verification/window-resize/failure-observer-binary \
        /Users/admin/k4-activation-snapshot >"${out}/observer-upload.txt" 2>&1 || true
    testanyware file exec --json 'chmod +x /Users/admin/k4-activation-snapshot; /Users/admin/k4-activation-snapshot' \
        >"${out}/failure-native.json" 2>"${out}/failure-native.stderr" || true
    testanyware agent windows --json >"${out}/failure-windows.json" 2>"${out}/failure-windows.stderr" || true
    testanyware screen capture -o "${out}/failure-observed.png" >"${out}/failure-capture.txt" 2>&1 || true
fi
testanyware screen size --json >"${out}/final-display.json" 2>"${out}/final-display.stderr" || true
testanyware file exec --json 'sw_vers; uname -m; spctl --status' \
    >"${out}/guest-final.json" 2>"${out}/guest-final.stderr" || true
find .build/vm-verify -type f -name 'menu-bar-*' | LC_ALL=C sort >"${out}/files-after.txt"
comm -13 "${out}/files-before.txt" "${out}/files-after.txt" >"${out}/new-files.txt"
while IFS= read -r file; do cp "${file}" "${out}/"; done <"${out}/new-files.txt"
audit=0
shasum -a 256 -c "${evidence}/subjects-before.sha256" >"${out}/host-after-check.txt" 2>&1 || audit=1
bash "${evidence}/inventory.sh" >"${out}/subjects-after.sha256" 2>"${out}/inventory.stderr" || audit=1
diff -u "${evidence}/subjects-before.sha256" "${out}/subjects-after.sha256" >"${out}/inventory-diff.txt" || audit=1
bash "${evidence}/links.sh" >"${out}/links-after.txt" 2>"${out}/links.stderr" || audit=1
diff -u "${evidence}/links-before.txt" "${out}/links-after.txt" >"${out}/links-diff.txt" || audit=1
printf '%s\n' "${audit}" >"${out}/audit.exit"
date -u '+%Y-%m-%dT%H:%M:%SZ' >"${out}/ended.txt"
[ "${status}" -ne 0 ] || status="${audit}"
exit "${status}"
