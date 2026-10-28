#!/bin/bash
# One frozen focused scenario; run through Task from the repository root.
set -euo pipefail

stage=retention attempt="${1:?01 only}"
case "${stage}:${attempt}" in
retention:01) ;;
*)
    echo 'Unknown declared attempt' >&2
    exit 2
    ;;
esac
evidence="docs/verification/settings-activation"
out="$(pwd)/.build/settings-activation/${stage}/${attempt}"
mkdir -p "$(dirname "${out}")"
mkdir "${out}"
export KOINE_VM_ID="koine-k12-${stage}-${attempt}" TESTANYWARE_VM_ID="koine-k12-${stage}-${attempt}"
KOINE_APP_BUNDLE="$(pwd)/.build/settings-activation/events/Koine.app"
export KOINE_APP_BUNDLE
export KOINE_VM_BASE=testanyware-golden-macos-27 KOINE_VM_DISPLAY=1920x1080 KOINE_VM_KEEP=1
export KOINE_SETTINGS_TRACE=0 KOINE_K4_OUT="${out}"
# Collection runs on normal completion AND interruption, then cleanup always runs.
# shellcheck disable=SC2329 # Called by the EXIT handler.
collect() {
    date -u '+%Y-%m-%dT%H:%M:%SZ' >"${out}/collection-started.txt"
    if [ "${wrapper_status}" -ne 0 ]; then
        testanyware file upload docs/verification/window-resize/failure-observer-binary \
            /Users/admin/k12-activation-snapshot >"${out}/observer-upload.txt" 2>&1 || true
        testanyware file exec --json 'chmod +x /Users/admin/k12-activation-snapshot; /Users/admin/k12-activation-snapshot' \
            >"${out}/failure-native.json" 2>"${out}/failure-native.stderr" || true
        testanyware agent windows --json >"${out}/failure-windows.json" 2>"${out}/failure-windows.stderr" || true
        testanyware screen capture -o "${out}/failure-observed.png" >"${out}/failure-capture.txt" 2>&1 || true
    fi
    native_audit=0
    bash "${evidence}/deferred-transport.sh" || native_audit=1
    # Preserve independent downloads even when acquisition's envelope failed.
    if ! testanyware file download /Users/admin/deferred-native.tgz "${out}/deferred-native.tgz" \
        >"${out}/deferred-download.txt" 2>&1; then
        native_audit=1
        # One packaging-only recovery of the existing directory; never rerun collect.
        testanyware file exec --timeout 120 --json \
            'bash /Users/admin/deferred-package.sh /Users/admin/deferred-native /Users/admin/deferred-recovery.tgz 1' \
            >"${out}/deferred-recovery.json" 2>"${out}/deferred-recovery.stderr" || true
        testanyware file download /Users/admin/deferred-recovery.tgz "${out}/deferred-recovery.tgz" \
            >>"${out}/deferred-download.txt" 2>&1 || true
    fi
    mkdir "${out}/deferred-native"
    for name in started.txt collected.txt rendered.txt complete.txt acquisition.exit package.exit collect.stdout collect.stderr native.jsonl show.stderr; do
        testanyware file download "/Users/admin/deferred-native/${name}" "${out}/deferred-native/${name}" \
            >>"${out}/deferred-download.txt" 2>&1 || native_audit=1
    done
    bash "${evidence}/events-transport.sh" dump || native_audit=1
    for name in settings-events.json settings-events.json.complete; do
        testanyware file download "/Users/admin/${name}" "${out}/${name}" >>"${out}/events-download.txt" 2>&1 || native_audit=1
    done
    bash "${evidence}/context-trace-disabled.sh" after || native_audit=1
    printf '%s\n' "${native_audit}" >"${out}/native-collection.exit"
    environment_status=0 display_status=0
    testanyware file exec --json 'sw_vers; uname -m; spctl --status' >"${out}/guest-final.json" 2>"${out}/guest-final.stderr" || environment_status=$?
    printf '%s\n' "${environment_status}" >"${out}/guest-final-cli.exit"
    testanyware screen size --json >"${out}/final-display.json" 2>"${out}/final-display.stderr" || display_status=$?
    printf '%s\n' "${display_status}" >"${out}/final-display-cli.exit"
    find .build/vm-verify -type f -name 'menu-bar-*' | LC_ALL=C sort >"${out}/files-after.txt"
    comm -13 "${out}/files-before.txt" "${out}/files-after.txt" >"${out}/new-files.txt"
    while IFS= read -r file; do cp "${file}" "${out}/"; done <"${out}/new-files.txt"
    audit="${native_audit}"
    [ "${environment_status}" -eq 0 ] && [ "${display_status}" -eq 0 ] || audit=1
    jq -e '.ok == true and .exit_code == 0 and .timed_out == false and (.stdout | type == "string" and length > 0)' "${out}/guest-final.json" >/dev/null || audit=1
    jq -e '.ok == true and .width > 0 and .height > 0' "${out}/final-display.json" >/dev/null || audit=1
    [ "$(cat "${out}/installed-before-check.exit" 2>/dev/null)" = 0 ] || audit=1
    shasum -a 256 -c "${evidence}/${stage}-subjects.sha256" >"${out}/host-after.txt" 2>&1 || audit=1
    bash "${evidence}/inventory.sh" "${KOINE_APP_BUNDLE}" >"${out}/bundle-after.txt" || audit=1
    diff -u "${evidence}/${stage}-bundle.txt" "${out}/bundle-after.txt" >"${out}/bundle-diff.txt" || audit=1
    # A failed assertion never reaches the scenario's final inventory. Read it here
    # on every outcome, after the untouched failure capture. Keep raw exec status.
    testanyware file upload "${evidence}/inventory.sh" /Users/admin/k12-inventory.sh >"${out}/inventory-upload.txt" 2>&1 || audit=1
    testanyware file exec --json 'bash /Users/admin/k12-inventory.sh /Applications/Koine.app' \
        >"${out}/installed-after.json" 2>"${out}/installed-after.stderr" || audit=1
    if jq -er '.ok == true and .exit_code == 0 and .timed_out == false' "${out}/installed-after.json" >/dev/null; then
        jq -r '.stdout' "${out}/installed-after.json" | sed '/^$/d' >"${out}/installed-after.txt"
        diff -u "${evidence}/${stage}-bundle.txt" "${out}/installed-after.txt" >"${out}/installed-diff.txt" || audit=1
    else
        audit=1
    fi
    printf '%s\n' "${audit}" >"${out}/audit.exit"
    date -u '+%Y-%m-%dT%H:%M:%SZ' >"${out}/ended.txt"
    return "${audit}"
}
# shellcheck disable=SC2329 # Called by EXIT.
finish() {
    wrapper_status=$?
    trap - EXIT
    interruption_status=0
    trap 'interruption_status=130' INT
    trap 'interruption_status=143' TERM
    set +e
    printf '%s\n' "${wrapper_status}" >"${out}/wrapper.exit"
    # A separate shell preserves errexit inside collection without preventing
    # cleanup if collection itself fails.
    (
        set -e
        collect
    )
    collection_status=$?
    printf '%s\n' "${collection_status}" >"${out}/collection.exit"
    testanyware vm stop "${KOINE_VM_ID}" --json >"${out}/stop.json" 2>"${out}/stop.stderr"
    stop_status=$?
    if ! jq -e --arg id "${KOINE_VM_ID}" '.ok == true and .stopped == true and .id == $id' "${out}/stop.json" >/dev/null; then
        stop_status=1
    fi
    printf '%s\n' "${stop_status}" >"${out}/stop.exit"
    printf '%s\n' "${interruption_status}" >"${out}/interruption.exit"
    [ "${wrapper_status}" -ne 0 ] || wrapper_status="${interruption_status}"
    [ "${wrapper_status}" -ne 0 ] || wrapper_status="${collection_status}"
    [ "${wrapper_status}" -ne 0 ] || wrapper_status="${stop_status}"
    exit "${wrapper_status}"
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
date -u '+%Y-%m-%dT%H:%M:%SZ' >"${out}/started.txt"
shasum -a 256 -c "${evidence}/${stage}-subjects.sha256" >"${out}/host-before.txt"
bash "${evidence}/inventory.sh" "${KOINE_APP_BUNDLE}" >"${out}/bundle-before.txt"
diff -u "${evidence}/${stage}-bundle.txt" "${out}/bundle-before.txt" >"${out}/bundle-before-diff.txt"
mkdir -p .build/vm-verify
find .build/vm-verify -type f -name 'menu-bar-*' | LC_ALL=C sort >"${out}/files-before.txt"
status=0
KOINE_K4_OUT="${out}" mise exec -- task app:vm-settings-retention-scenario >"${out}/task.log" 2>&1 || status=$?
printf '%s\n' "${status}" >"${out}/task.exit"
date -u '+%Y-%m-%dT%H:%M:%SZ' >"${out}/scenario-ended.txt"
exit "${status}"
