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

jq -cn --arg entry "$*" --arg pid "$$" --arg pgid "$(ps -o pgid= -p $$ | tr -d ' ')" \
    --arg vm "${KOINE_VM_ID-}" --arg base "${KOINE_VM_BASE-}" --arg root "${root}" --arg out "${out}" \
    --arg keep "${KOINE_VM_KEEP-unset}" \
    '{entry: $entry, pid: $pid, pgid: $pgid, vm: $vm, base: $base, root: $root, out: $out, keep: $keep}' \
    >>"${run_log:?}"

# Faults that the control sets for the caller's stop or list stay out of the run.
caller_mode="${lifecycle_mode:-clean}"
export lifecycle_mode=clean lifecycle_exit=0 lifecycle_block=0
unset lifecycle_only

finish() {
    printf '%s\n' "$1" >"${out}/scenario.exit"
    exit "${2:-$1}"
}
step() { python3 "${backend}" poll-step "${root}" "$1" state 0 control; }
exhaust() { python3 "${backend}" poll-step "${root}" "$1" exhausted 1 control >/dev/null 2>&1 || :; }
begin() {
    init_guest_evidence "${root}" "${KOINE_VM_ID}"
    inventory_guest_vms "${root}" read-poll vm-before absent >/dev/null
    start_guest_vm "${root}" vm-start "${KOINE_VM_BASE}" >/dev/null
    inventory_guest_vms "${root}" read-poll vm-after running >/dev/null
}
terminal() { step textedit-quit-absence-state; }

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
