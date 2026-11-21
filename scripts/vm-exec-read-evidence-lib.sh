# shellcheck shell=bash
# Source-only checked guest exec reads. scripts/vm_exec_reads.py owns each
# fixed guest command, its exact grammar and its parsed record. Ordinary caller
# adoption, signals and the finite caller stay with their owners.
# shellcheck source=scripts/vm-guest-exec-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-guest-exec-lib.sh"

_exec_read_root() {
    [[ -n "$1" && -f "$1/subject.json" ]] || {
        echo 'exec read evidence requires an initialized nonempty root' >&2
        return 125
    }
}

# read_guest_exec ROOT {read-poll,evidence} OPERATION NAME [ARGUMENT]
# One checked read. A clean read prints its parsed record as one JSON line,
# and ROOT keeps the raw bytes. A negative fact, such as an absent descriptor,
# is a clean record. A failed read is never a negative. The evidence class
# admits only the reads that change no guest state.
read_guest_exec() {
    _exec_read_root "${1-}" || return
    _guest_evidence_backend read "$@"
}

# Internal: 0 means a clean true state, 1 a clean false state, and every other
# status stops. The read and the local state decision each get a receipt.
_exec_read_poll_step() {
    local root="$1" operation="$2" predicate="$3" record state=0
    record="$(read_guest_exec "${root}" read-poll "${operation}" endpoint)" || return
    jq -e "${predicate}" >/dev/null <<<"${record}" || state=$?
    record_guest_poll "${root}" "${operation}-state" state "${state}" "${predicate}" || return
    [[ "${state}" != 0 ]] || printf '%s\n' "${record}"
    return "${state}"
}

# await_guest_endpoint ROOT OPERATION {launch,login}
# The two existing descriptor polls. launch is await_koine: fifteen reads,
# each negative followed by two seconds, then a state failure. login is the
# loop after a restart: twenty-four reads, each negative followed by five
# seconds. Its exhaustion returns 1 and latches nothing, because the legacy
# loop continues to its process assertion.
await_guest_endpoint() {
    local root="${1-}" operation="${2-}" mode="${3-}" limit delay attempt
    local record state sleep_status predicate='.present == true'
    _exec_read_root "${root}" || return
    case "$#:${mode}" in
    3:launch) limit=15 delay=2 ;;
    3:login) limit=24 delay=5 ;;
    *)
        fail_guest_evidence "${root}" "${operation:-endpoint-poll-arguments}" \
            'expected ROOT OPERATION launch|login'
        return
        ;;
    esac
    [[ -n "${operation}" ]] || {
        fail_guest_evidence "${root}" endpoint-poll-arguments 'expected a nonempty operation'
        return
    }
    for ((attempt = 1; attempt <= limit; attempt++)); do
        state=0
        record="$(_exec_read_poll_step "${root}" "${operation}-${attempt}" "${predicate}")" || state=$?
        if [[ "${state}" == 0 ]]; then
            printf '%s\n' "${record}"
            return 0
        fi
        [[ "${state}" == 1 ]] || return "${state}"
        # Only a clean negative reaches the existing sleep.
        sleep_status=0
        sleep "${delay}" || sleep_status=$?
        if [[ "${sleep_status}" != 0 ]]; then
            record_guest_poll "${root}" "${operation}-${attempt}-sleep" sleep "${sleep_status}" "${predicate}"
            return
        fi
    done
    if [[ "${mode}" == launch ]]; then
        record_guest_poll "${root}" "${operation}-exhausted" exhausted 1 "${predicate}"
        return
    fi
    return 1
}
