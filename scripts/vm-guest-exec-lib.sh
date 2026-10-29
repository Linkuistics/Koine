# shellcheck shell=bash
# Source-only strict exec seam; sourcing it starts no process, transcript or VM.
init_guest_evidence() {
    python3 "${BASH_SOURCE[0]%/*}/vm-guest-exec.py" init "$@"
}
exec_guest_evidence() {
    local status=0
    python3 "${BASH_SOURCE[0]%/*}/vm-guest-exec.py" run "$@" || status=$?
    if [[ "${status}" != 0 && "${status}" != 125 && $# -gt 0 && -f "$1/subject.json" ]]; then
        # The backend may be missing or fail before its own latch path. Preserve
        # the first reason even across substitutions; no Python is needed here.
        (
            set -o noclobber
            printf 'guest-exec backend exit %s\n' "${status}" >"$1/unavailable"
        ) || :
    fi
    return "${status}"
}
