# shellcheck shell=bash
# Source-only checked file transfers. Ordinary caller adoption is separate.
# shellcheck source=scripts/vm-guest-exec-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-guest-exec-lib.sh"

_file_evidence_root() {
    [[ -n "$1" && -f "$1/subject.json" ]] || {
        echo 'file evidence requires an initialized nonempty root' >&2
        return 125
    }
}

# upload_guest_file ROOT OPERATION LOCAL /REMOTE
# One one-shot upload. The backend makes LOCAL absolute and digests it under
# the writer lock before and after the dispatch.
# The receipt proves only the local size. A download names this ordinal to
# prove the guest bytes.
upload_guest_file() {
    _file_evidence_root "${1-}" || return
    local root="$1"
    shift
    _guest_evidence_backend upload "${root}" one-shot "$@"
}

# download_guest_file ROOT {read-poll,evidence} OPERATION /REMOTE [UPLOAD_ORDINAL]
# The backend owns the unique copy path and checks it before unlocking. A named
# upload ordinal must match the guest bytes, byte for byte.
download_guest_file() {
    _file_evidence_root "${1-}" || return
    _guest_evidence_backend download "$@"
}
