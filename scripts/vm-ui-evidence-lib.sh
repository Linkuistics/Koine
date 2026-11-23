# shellcheck shell=bash
# Source-only strict snapshot/element reads. Scenario adoption is separate.
# shellcheck source=scripts/vm-guest-exec-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-guest-exec-lib.sh"

_ui_evidence_root() {
    [[ -n "$1" && -f "$1/subject.json" ]] || {
        echo 'UI evidence requires an initialized nonempty root' >&2
        return 125
    }
}

_ui_evidence_fail() {
    _ui_evidence_root "$1" || return
    fail_guest_evidence "$@"
}

# Private: callers validate their public arguments before constructing EXTRA.
_read_guest_snapshot() {
    local root="$1" kind="$2" operation="$3" window="$4" extra="$5" predicate
    # Full snapshots require element arrays on every returned window. Missing
    # trees cannot establish absence. Optional element fields are typed if present.
    # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs
    # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-protocol/src/element_info.rs
    # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-protocol/src/window_info.rs
    # Bind each recursive object before checking its optional fields.
    # shellcheck disable=SC2016 # jq variables, not shell expansions.
    predicate='def number_field: type == "number" and isfinite;
        def element_shape:
            . as $element | type == "object" and (.role | type == "string")
            and (.enabled | type == "boolean") and (.focused | type == "boolean")
            and (.childCount | number_field and floor == . and . >= 0)
            and (.actions | type == "array" and all(.[]; type == "string"))
            and all("id", "label", "value", "description", "platformRole";
                . as $key | $element | (has($key) | not) or (.[$key] | type == "string"))
            and ((has("showing") | not) or (.showing | type == "boolean"))
            and all("positionX", "positionY", "sizeWidth", "sizeHeight";
                . as $key | $element | (has($key) | not) or (.[$key] | number_field))
            and ((has("children") | not) or (.children | type == "array" and all(.[]; element_shape)));
        (.windows | type == "array") and all(.windows[];
            type == "object" and (.appName | type == "string")
            and (.windowType | type == "string") and (.focused | type == "boolean")
            and ((has("title") | not) or (.title | type == "string"))
            and all(.positionX, .positionY, .sizeWidth, .sizeHeight; number_field)
            and (.elements | type == "array" and all(.[]; element_shape)))'
    predicate+=" and (${extra})"
    cli_guest_evidence "${root}" "${kind}" "${operation}" "${predicate}" -- \
        agent snapshot --mode full --window "${window}" --depth 14
}

# read_guest_snapshot ROOT {read-poll,evidence} OPERATION WINDOW
# Emit the complete original qualified envelope, including every returned tree.
read_guest_snapshot() {
    local root="${1-}" kind="${2-}" operation="${3-}" window="${4-}"
    _ui_evidence_root "${root}" || return
    if [[ $# != 4 || -z "${operation}" || -z "${window}" || "${window}" == -* ||
        ("${kind}" != read-poll && "${kind}" != evidence) ]]; then
        _ui_evidence_fail "${root}" "${operation:-snapshot-arguments}" 'expected ROOT read-poll|evidence OPERATION WINDOW'
        return "$?"
    fi
    _read_guest_snapshot "${root}" "${kind}" "${operation}" "${window}" '(.windows | type == "array")'
}

_ui_element_selection() {
    # Preserve first-match document order and the existing platformRole filter.
    # Each selector must yield exactly one boolean for every candidate element.
    printf '[.. | objects | select(has("platformRole")) | select(
        [(%s)] | if . == [true] then true elif . == [false] then false
        else error("element selector must yield one boolean") end)][0]' "$1"
}

# read_guest_element ROOT OPERATION WINDOW CONDITION REQUIREMENT
# optional modes return null for no match. Other modes require a matching
# element and its consumed attributes; an empty string remains a valid value.
read_guest_element() {
    local root="${1-}" operation="${2-}" window="${3-}" condition="${4-}" requirement="${5-}"
    local selection contract response result status=0
    _ui_evidence_root "${root}" || return
    if [[ $# != 5 || -z "${operation}" || -z "${window}" || "${window}" == -* || -z "${condition}" ]]; then
        _ui_evidence_fail "${root}" "${operation:-element-arguments}" 'expected ROOT OPERATION WINDOW CONDITION REQUIREMENT'
        return "$?"
    fi
    case "${requirement}" in
    optional) contract='(. == null or type == "object")' ;;
    optional-vertical)
        contract='. == null or (type == "object" and all(.positionY, .sizeHeight;
            type == "number" and isfinite) and .sizeHeight >= 0)'
        ;;
    position-y) contract='type == "object" and (.positionY | type == "number" and isfinite)' ;;
    value) contract='type == "object" and (.value | type == "string")' ;;
    geometry)
        contract='type == "object" and all(.positionX, .positionY, .sizeWidth, .sizeHeight;
            type == "number" and isfinite) and .sizeWidth > 0 and .sizeHeight > 0'
        ;;
    height) contract='type == "object" and (.sizeHeight | type == "number" and isfinite and . >= 0)' ;;
    *)
        _ui_evidence_fail "${root}" "${operation}" 'element requirement must be optional, optional-vertical, position-y, value, geometry or height'
        return "$?"
        ;;
    esac
    selection="$(_ui_element_selection "${condition}")" || return
    response="$(_read_guest_snapshot "${root}" read-poll "${operation}" "${window}" "${selection} | ${contract}")" || return
    result="$(jq -c "${selection}" <<<"${response}")" || status=$?
    if [[ "${status}" != 0 ]]; then
        if ((status > 128 && status <= 192)); then
            record_guest_poll "${root}" "${operation}-decode" state "${status}" "${selection}"
        else
            _ui_evidence_fail "${root}" "${operation}-decode" "element decoder exit ${status}"
        fi
        return "$?"
    fi
    printf '%s\n' "${result}"
}

# await_guest_element ROOT OPERATION WINDOW CONDITION {present,absent}
# The existing await_element bound: ten reads, two seconds after each negative,
# including the final negative. No input, repeated submission or wait extension.
await_guest_element() {
    local root="${1-}" operation="${2-}" window="${3-}" condition="${4-}" expected="${5-}"
    local response predicate attempt state_status sleep_status
    _ui_evidence_root "${root}" || return
    if [[ $# != 5 || -z "${operation}" || -z "${window}" || "${window}" == -* || -z "${condition}" ||
        ("${expected}" != present && "${expected}" != absent) ]]; then
        _ui_evidence_fail "${root}" "${operation:-element-poll-arguments}" 'expected ROOT OPERATION WINDOW CONDITION present|absent'
        return "$?"
    fi
    predicate="$(_ui_element_selection "${condition}")" || return
    if [[ "${expected}" == present ]]; then predicate+=' != null'; else predicate+=' == null'; fi
    for attempt in 1 2 3 4 5 6 7 8 9 10; do
        response="$(read_guest_element "${root}" "${operation}-${attempt}" "${window}" "${condition}" optional)" || return
        state_status=1
        if [[ ("${response}" != null && "${expected}" == present) ||
            ("${response}" == null && "${expected}" == absent) ]]; then state_status=0; fi
        record_guest_poll "${root}" "${operation}-${attempt}-state" state "${state_status}" "${predicate}" || return
        [[ "${state_status}" != 0 ]] || return 0
        sleep_status=0
        sleep 2 || sleep_status=$?
        if [[ "${sleep_status}" != 0 ]]; then
            record_guest_poll "${root}" "${operation}-${attempt}-sleep" sleep "${sleep_status}" "${predicate}"
            return "$?"
        fi
    done
    record_guest_poll "${root}" "${operation}-exhausted" exhausted 1 "${predicate}"
}
