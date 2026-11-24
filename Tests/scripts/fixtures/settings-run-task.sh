#!/bin/bash
# Stands in for `task ENTRY` in the containment controls. It writes real receipts
# through the real facades against the synthetic TestAnyware CLI. run_mode
# selects one scenario shape. No VM, agent or guest is contacted.
set -u
repo="${run_repo:?}"
root="${KOINE_VM_EVIDENCE_ROOT:?}"
out="${KOINE_K4_OUT:?}"
backend="${repo}/scripts/vm-guest-exec.py"
# shellcheck source=scripts/vm-guest-exec-lib.sh
source "${repo}/scripts/vm-guest-exec-lib.sh"
# shellcheck source=scripts/vm-lifecycle-evidence-lib.sh
source "${repo}/scripts/vm-lifecycle-evidence-lib.sh"
# shellcheck source=scripts/vm-exec-read-evidence-lib.sh
source "${repo}/scripts/vm-exec-read-evidence-lib.sh"
# shellcheck source=scripts/vm-file-evidence-lib.sh
source "${repo}/scripts/vm-file-evidence-lib.sh"

jq -cn --arg entry "$*" --arg pid "$$" --arg pgid "$(ps -o pgid= -p $$ | tr -d ' ')" \
    --arg vm "${KOINE_VM_ID-}" --arg base "${KOINE_VM_BASE-}" --arg root "${root}" --arg out "${out}" \
    --arg keep "${KOINE_VM_KEEP-unset}" \
    '{entry: $entry, pid: $pid, pgid: $pgid, vm: $vm, base: $base, root: $root, out: $out, keep: $keep}' \
    >>"${run_log:?}"

# Faults that the control sets for the caller's stop or list stay out of the run.
caller_mode="${lifecycle_mode:-clean}"
export lifecycle_mode=clean lifecycle_exit=0 lifecycle_block=0
unset lifecycle_only
# A read fault for the caller stays out of the scenario, unless the control
# names it for the scenario. The caller keeps its own environment.
export guest_fail="${scenario_guest_fail-}"

finish() {
    printf '%s\n' "$1" >"${out}/scenario.exit"
    exit "${2:-$1}"
}
step() { python3 "${backend}" poll-step "${root}" "$1" state 0 control; }
exhaust() { python3 "${backend}" poll-step "${root}" "$1" exhausted 1 control >/dev/null 2>&1 || :; }
begin() {
    # run_cli and run_jq declare other executables for the scenario than the frozen ones.
    KOINE_TESTANYWARE_CLI="${run_cli:-${KOINE_TESTANYWARE_CLI-}}" KOINE_JQ="${run_jq:-${KOINE_JQ-}}" \
        init_guest_evidence "${root}" "${KOINE_VM_ID}"
    inventory_guest_vms "${root}" read-poll vm-before absent >/dev/null
    start_guest_vm "${root}" vm-start "${KOINE_VM_BASE}" >/dev/null
    inventory_guest_vms "${root}" read-poll vm-after running >/dev/null
    # run_provenance=skip leaves the clone without its provenance record.
    [[ "${run_provenance-}" == skip ]] ||
        record_guest_provenance "${root}" clone-provenance >/dev/null 2>&1 || :
    # The setup records of the scenario. A control can make one of them fail.
    read_guest_exec "${root}" read-poll system system >/dev/null 2>&1 || :
    read_guest_exec "${root}" read-poll gatekeeper gatekeeper >/dev/null 2>&1 || :
    read_guest_exec "${root}" read-poll installed-before installed-inventory >/dev/null 2>&1 || :
}
# The last receipt of a complete run of the entry that this clone runs.
terminal() {
    case "${KOINE_VM_ID}" in
    koine-k49-ordinary-*) step installed-after ;;
    *) step textedit-quit-absence-state ;;
    esac
}
# last_attempt: the directory of the newest attempt.
last_attempt() { find "${root}" -mindepth 1 -maxdepth 1 -type d -name '[0-9]*' | sort | tail -1; }
# save_artifact DIGEST: a saved screenshot and its receipt, in the newest attempt.
save_artifact() {
    local attempt
    attempt="$(last_attempt)"
    printf 'saved screenshot\n' >"${attempt}/screen.png"
    jq -n --arg sha256 "$1" '{bytes: 17, sha256: $sha256}' >"${attempt}/artifact.json"
}

# hold MODE: a process that keeps the evidence writer lock after this script
# exits. Every mode ends by itself, so a failed control leaks no process.
hold() {
    python3 -I -c '
import fcntl, os, signal, sys, time
lock, mode, ready = sys.argv[1:4]
if mode == "outside":
    os.setsid()
if mode == "ignore-term":
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
stream = open(lock, "a")
fcntl.flock(stream, fcntl.LOCK_EX)
open(ready, "w").write(str(os.getpid()))
end = time.monotonic() + (0.4 if mode == "brief" else 20)
while time.monotonic() < end and not os.path.exists(ready + ".release"):
    time.sleep(0.02)
' "${root}/.writer" "$1" "${run_holder:?}" </dev/null >/dev/null 2>&1 &
    until [[ -s "${run_holder}" ]]; do sleep 0.02; done
}

case "${run_mode:-complete}" in
complete)
    begin
    terminal
    finish 0
    ;;
assertion)
    begin
    exhaust scenario-assertion-setup-failed
    finish 1
    ;;
no-exit)
    begin
    terminal
    exit 7
    ;;
malformed-exit)
    begin
    terminal
    printf 'zero' >"${out}/scenario.exit"
    exit 0
    ;;
no-root)
    finish 2
    ;;
before-start)
    init_guest_evidence "${root}" "${KOINE_VM_ID}"
    fail_guest_evidence "${root}" vm-before 'the inventory before the start failed' || :
    finish 125
    ;;
start-failed)
    init_guest_evidence "${root}" "${KOINE_VM_ID}"
    inventory_guest_vms "${root}" read-poll vm-before absent >/dev/null
    lifecycle_exit=7 start_guest_vm "${root}" vm-start "${KOINE_VM_BASE}" >/dev/null || :
    finish 125
    ;;
start-blocked)
    init_guest_evidence "${root}" "${KOINE_VM_ID}"
    inventory_guest_vms "${root}" read-poll vm-before absent >/dev/null
    # The clone exists, and the start never returns its identity.
    # shellcheck disable=SC2154 # The control exports the state file.
    printf '%s\n' "${KOINE_VM_ID}" >>"${lifecycle_state}"
    lifecycle_block=1 lifecycle_only=start start_guest_vm "${root}" vm-start "${KOINE_VM_BASE}" >/dev/null
    finish 125
    ;;
signal-wait)
    begin
    trap 'fail_guest_evidence "${root}" scenario-signal-TERM interrupted || :; exit 143' TERM
    : >"${run_ready:?}"
    for _ in $(seq 1 400); do sleep 0.05; done
    finish 0
    ;;
down-held)
    begin
    step resize-down-1
    finish 1
    ;;
down-released)
    begin
    step resize-down-1
    step resize-release
    terminal
    finish 0
    ;;
down-failed)
    begin
    exhaust resize-down-1
    finish 125
    ;;
release-partial)
    begin
    step resize-down-1
    next="$(printf '%06d' $(($(find "${root}" -mindepth 1 -maxdepth 1 -type d -name '[0-9]*' | wc -l) + 1)))"
    mkdir "${root}/${next}"
    printf '{"operation":"resize-release"}\n' >"${root}/${next}/request.json"
    finish 1
    ;;
ordinal-gap)
    begin
    step resize-down-1
    step resize-release
    last="$(find "${root}" -mindepth 1 -maxdepth 1 -type d -name '[0-9]*' | sort | tail -1)"
    mv "${last}" "${root}/000099"
    finish 1
    ;;
holder-brief | holder-stuck | holder-ignores-term | holder-outside)
    begin
    terminal
    case "${run_mode}" in
    holder-brief) hold brief ;;
    holder-stuck) hold stuck ;;
    holder-ignores-term) hold ignore-term ;;
    holder-outside) hold outside ;;
    esac
    finish 0
    ;;
input-changes)
    begin
    terminal
    printf 'changed during the slot\n' >>"${frozen:?}/Taskfile.yml"
    finish 0
    ;;
input-extra)
    begin
    terminal
    printf 'new\n' >"${frozen:?}/Koine.app/Contents/Resources/extra"
    finish 0
    ;;
input-missing)
    begin
    terminal
    rm "${frozen:?}/Koine.app/Contents/Info.plist"
    finish 0
    ;;
guest-changes)
    begin
    terminal
    printf 'changed in the guest\n' >>"${guest_bundle:?}/Contents/MacOS/Koine"
    finish 0
    ;;
guest-extra)
    begin
    terminal
    printf 'new\n' >"${guest_bundle:?}/Contents/Resources/extra"
    finish 0
    ;;
guest-missing)
    begin
    terminal
    rm "${guest_bundle:?}/Contents/Info.plist"
    finish 0
    ;;
guest-link)
    begin
    terminal
    rm "${guest_bundle:?}/Contents/Resources/current"
    ln -s ../Info.plist "${guest_bundle}/Contents/Resources/current"
    finish 0
    ;;
artifact-clean)
    begin
    step saved-capture
    save_artifact "$(printf 'saved screenshot\n' | shasum -a 256 | cut -d' ' -f1)"
    terminal
    finish 0
    ;;
artifact-changed)
    begin
    step saved-capture
    save_artifact "$(printf 'the original\n' | shasum -a 256 | cut -d' ' -f1)"
    terminal
    finish 0
    ;;
stream-changed)
    begin
    terminal
    guest_stream="$(grep -l '"operation": "system"' "${root}"/*/request.json | head -1)"
    printf 'edited\n' >"$(dirname "${guest_stream}")/guest.stdout"
    finish 0
    ;;
process-row)
    begin
    read_guest_exec "${root}" read-poll login-process process bundle >/dev/null
    terminal
    finish 0
    ;;
record-shape)
    begin
    terminal
    installed="$(grep -l '"operation": "installed-before"' "${root}"/*/request.json | head -1)"
    printf '{}\n' >"$(dirname "${installed}")/read.json"
    finish 0
    ;;
partial-original)
    begin
    terminal
    next="$(printf '%06d' $(($(find "${root}" -mindepth 1 -maxdepth 1 -type d -name '[0-9]*' | wc -l) + 1)))"
    mkdir "${root}/${next}"
    printf '{"operation":"late-read"}\n' >"${root}/${next}/request.json"
    printf 'partial bytes\n' >"${root}/${next}/raw.stdout"
    finish 0
    ;;
recurrence | recurrence-later-change | recurrence-record-shape)
    begin
    for operation in first-selection-identity first-selection-enabled \
        screenshot-menu-first-selection; do step "${operation}"; done
    step menu-click
    for operation in first-selection-front-application first-selection-failure-windows \
        failure-capture first-selection-menu-closed first-selection-liveness; do step "${operation}"; done
    exhaust first-selection-window-exhausted
    exhaust scenario-assertion-zero-window-same-process
    if [[ "${run_mode}" == recurrence-later-change ]]; then
        # The caller's later read of the guest sees this change.
        printf 'changed after the selection\n' >>"${guest_bundle:?}/Contents/MacOS/Koine"
    elif [[ "${run_mode}" == recurrence-record-shape ]]; then
        installed="$(grep -l '"operation": "installed-before"' "${root}"/*/request.json | head -1)"
        printf '{}\n' >"$(dirname "${installed}")/read.json"
    fi
    finish 1
    ;;
member-lost)
    begin
    terminal
    # shellcheck disable=SC2154 # The control names the attempt and its members.
    lost_attempt="$(dirname "$(grep -l "\"operation\": \"${lost_operation}\"" "${root}"/*/request.json | head -1)")"
    # shellcheck disable=SC2154,SC2086 # The members are separate words.
    for member in ${lost_members}; do rm "${lost_attempt:?}/${member:?}"; done
    finish 0
    ;;
upload-lost)
    begin
    printf 'upload\n' >"${out}/upload.txt"
    upload_guest_file "${root}" upload-control "${out}/upload.txt" /tmp/control >/dev/null
    lost_attempt="$(dirname "$(grep -l '"operation": "upload-control"' "${root}"/*/request.json | head -1)")"
    rm "${lost_attempt:?}/transfer.json"
    terminal
    finish 0
    ;;
partial-response)
    begin
    terminal
    lifecycle_mode=partial read_guest_exec "${root}" evidence late-read system >/dev/null 2>&1 || :
    finish 0
    ;;
refusals)
    begin
    terminal
    hold stuck
    cli_guest_evidence "${root}" evidence collect-windows '.ok == true' -- agent windows >/dev/null 2>&1 || :
    fail_guest_evidence "${root}" confirm-state 'a refused confirmation' >/dev/null 2>&1 || :
    stop_guest_vm "${root}" scenario-stop >/dev/null 2>&1 || :
    # An invalid class exits 2, which the facade records separately.
    _guest_evidence_backend cli "${root}" invalid-class op '.ok' -- agent windows >/dev/null 2>&1 || :
    : >"${run_holder}.release"
    wait
    finish 125
    ;;
*)
    echo "unknown run_mode ${run_mode} (${caller_mode})" >&2
    exit 99
    ;;
esac
