# shellcheck shell=bash
# Source-only capture helpers. Ordinary caller adoption is separate.
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
