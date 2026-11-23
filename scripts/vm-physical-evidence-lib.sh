# shellcheck shell=bash
# Source-only migration facade. An explicitly set KOINE_VM_EVIDENCE_ROOT selects
# strict receipts; unset preserves existing VM consumers during migration.
# shellcheck source=scripts/vm-guest-exec-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-guest-exec-lib.sh"

_physical_root() {
    # An empty Path would address cwd. Without an initialized subject there is
    # no evidence directory in which it is safe to write a refusal or lock.
    [[ -n "${KOINE_VM_EVIDENCE_ROOT:-}" && -f "${KOINE_VM_EVIDENCE_ROOT}/subject.json" ]] || {
        echo 'physical evidence requires an initialized nonempty root' >&2
        return 125
    }
}

_physical_cli() {
    local kind="$1" operation="$2" predicate="$3"
    shift 3
    if [[ "${KOINE_VM_EVIDENCE_ROOT+x}" ]]; then
        _physical_root || return
        cli_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" "${kind}" "${operation}" "${predicate}" -- "$@"
    else
        case "$1 $2" in
        'screen size' | 'agent windows') testanyware "$@" --json ;;
        *) testanyware "$@" ;;
        esac
    fi
}

_physical_fail() {
    if [[ "${KOINE_VM_EVIDENCE_ROOT+x}" ]]; then
        _physical_root || return
        fail_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" physical-geometry "$*"
        return "$?"
    fi
    fail "$*"
    return 1
}

# _physical_sleep OPERATION SECONDS: one existing wait between pointer actions.
# A caller that tests a helper's status turns off errexit inside it, so the
# helper must check each wait itself. In strict mode a failed wait records one
# sleep receipt, which latches the root. Either way the failure is returned, so
# no later input or release follows it.
_physical_sleep() {
    local status=0
    sleep "$2" || status=$?
    [[ "${status}" == 0 ]] && return 0
    if [[ "${KOINE_VM_EVIDENCE_ROOT+x}" ]]; then
        _physical_root || return
        record_guest_poll "${KOINE_VM_EVIDENCE_ROOT}" "$1" sleep "${status}" "the existing ${2}-second wait" ||
            return
    fi
    return "${status}"
}

_physical_coordinates() {
    [[ "$1" =~ ^[0-9]{1,5}$ && "$2" =~ ^[0-9]{1,5}$ ]] &&
        ((10#$1 <= 65535 && 10#$2 <= 65535))
}

_physical_pointer() {
    local operation="$1" action="$2" x="$3" y="$4" predicate
    # The real v3.0.0 payloads report actual coordinates; click also returns the
    # default left button and count=1, while down/up return the left button.
    # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/input.rs
    predicate=".x == ${x} and .y == ${y}"
    case "${action}" in
    click) predicate+=' and .button == "left" and .count == 1' ;;
    mouse-down | mouse-up) predicate+=' and .button == "left"' ;;
    esac
    _physical_cli one-shot "${operation}" "${predicate}" input "${action}" "${x}" "${y}"
}

_physical_resize_frame() {
    local title="$1" title_json predicate response frame
    title_json="$(jq -cn --arg title "${title}" '$title')" || {
        _physical_fail 'resize title encoding failed'
        return "$?"
    }
    # WindowInfo requires geometry/app/type/focus; titles may be absent on other
    # entries. Require one usable target on the same original complete list.
    # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-protocol/src/window_info.rs
    predicate='(.windows | type == "array") and all(.windows[];
        type == "object" and (.appName | type == "string")
        and (.windowType | type == "string") and (.focused | type == "boolean")
        and ((has("title") | not) or (.title | type == "string"))
        and all(.positionX, .positionY, .sizeWidth, .sizeHeight;
            type == "number" and isfinite))
        and ([.windows[] | select(.title == '
    predicate+="${title_json}"
    predicate+=')] | length == 1 and all(.[];
        .sizeWidth >= 3 and .sizeHeight >= 3
        and ((.positionX | floor) + (.sizeWidth | floor) - 3) >= 0
        and ((.positionX | floor) + (.sizeWidth | floor) - 3) <= 65535
        and ((.positionY | floor) + (.sizeHeight | floor) - 3) >= 0
        and ((.positionY | floor) + (.sizeHeight | floor) - 3) <= 65535))'
    response="$(_physical_cli read-poll resize-frame "${predicate}" agent windows)" || return
    frame="$(jq -er --arg title "${title}" '[.windows[] | select(.title == $title)][0]
        | "\(.positionX | floor) \(.positionY | floor) \(.sizeWidth | floor) \(.sizeHeight | floor)"' <<<"${response}")" || {
        _physical_fail 'resize frame decoding failed'
        return "$?"
    }
    printf '%s\n' "${frame}"
}
