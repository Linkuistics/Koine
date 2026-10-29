# shellcheck shell=bash
# Source-only evidence seam; sourcing it starts no process, transcript or VM.
init_guest_evidence() {
    python3 "${BASH_SOURCE[0]%/*}/vm-guest-exec.py" init "$@"
}
exec_guest_evidence() {
    _guest_evidence_backend run "$@"
}
check_guest_evidence() {
    # Inspection only. All later dispatch must still use the locked adapters.
    _guest_evidence_backend check "$@"
}
fail_guest_evidence() {
    # Call after a failed downstream/artifact check; always returns nonzero.
    _guest_evidence_backend fail "$@"
}
record_guest_poll() {
    # Record a local state decision/failure under the same writer lock/ordinals.
    _guest_evidence_backend poll-step "$@"
}
cli_guest_evidence() {
    _guest_evidence_backend cli "$@"
}
_guest_evidence_backend() {
    local action="$1"
    shift
    local status=0
    python3 "${BASH_SOURCE[0]%/*}/vm-guest-exec.py" "${action}" "$@" || status=$?
    if [[ "${status}" != 0 && "${status}" != 125 && $# -gt 0 && -f "$1/subject.json" ]]; then
        # The backend may be missing or fail before its own latch path. Preserve
        # the first reason even across substitutions; no Python is needed here.
        (
            set -o noclobber
            printf 'guest-exec backend exit %s\n' "${status}" >"$1/unavailable"
        ) || :
        # Keep each facade failure even if an earlier reason already latched.
        # Shell quoting retains argument boundaries without a working backend.
        local request refusal
        printf -v request '%q ' "${action}" "$@"
        printf -v refusal 'backend_exit=%s argv=%s' "${status}" "${request}"
        printf '%s\n' "${refusal}" >>"$1/facade-refusals.log" || :
    fi
    return "${status}"
}
