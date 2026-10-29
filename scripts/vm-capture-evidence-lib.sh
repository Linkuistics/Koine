# shellcheck shell=bash
# Source-only capture/keepalive helpers; ordinary caller adoption is separate.
# shellcheck source=scripts/vm-guest-exec-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-guest-exec-lib.sh"

_capture_evidence_root() {
    [[ -n "$1" && -f "$1/subject.json" ]] || {
        echo 'capture evidence requires an initialized nonempty root' >&2
        return 125
    }
}

# capture_guest_evidence ROOT {read-poll,evidence} OPERATION [X,Y,WIDTH,HEIGHT]
# The backend owns the unique output path and checks the PNG before unlocking.
capture_guest_evidence() {
    _capture_evidence_root "${1-}" || return
    _guest_evidence_backend capture "$@"
}

# Foreground loop for the caller to own as a background child and later reap.
# Preserve while/sleep20/capture, with no ignored error or subsequent tick on failure.
keepalive_guest_evidence() {
    local root="${1-}" tick=0 status
    _capture_evidence_root "${root}" || return
    if [[ $# != 1 ]]; then
        fail_guest_evidence "${root}" keepalive-arguments 'expected ROOT'
        return "$?"
    fi
    while :; do
        tick=$((tick + 1))
        status=0
        sleep 20 || status=$?
        if [[ "${status}" != 0 ]]; then
            record_guest_poll "${root}" "keepalive-sleep-${tick}" sleep "${status}" 'sleep 20 before each keepalive capture'
            return "$?"
        fi
        capture_guest_evidence "${root}" read-poll "keepalive-${tick}" || return
    done
}
