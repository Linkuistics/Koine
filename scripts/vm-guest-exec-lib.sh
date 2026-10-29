# shellcheck shell=bash
# Source-only strict exec seam; sourcing it starts no process, transcript or VM.
init_guest_evidence() {
    python3 "${BASH_SOURCE[0]%/*}/vm-guest-exec.py" init "$@"
}
exec_guest_evidence() {
    python3 "${BASH_SOURCE[0]%/*}/vm-guest-exec.py" run "$@"
}
