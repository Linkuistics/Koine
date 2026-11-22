# shellcheck shell=bash
# Source-only OCR and element-centre clicks; ordinary caller adoption is separate.
# shellcheck source=scripts/vm-ui-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-ui-evidence-lib.sh"

# read_guest_text ROOT OPERATION QUERY [30]
# Preserve the two existing callers: one immediate read, or Allow's CLI timeout.
read_guest_text() {
    local root="${1-}" operation="${2-}" query="${3-}" predicate status=0
    _ui_evidence_root "${root}" || return
    if [[ ($# != 3 && $# != 4) || -z "${operation}" || -z "${query}" || "${query}" == -* ||
        ($# == 4 && "$4" != 30) ]]; then
        _ui_evidence_fail "${root}" "${operation:-ocr-arguments}" 'expected ROOT OPERATION QUERY [30]'
        return "$?"
    fi
    # Field/count contract from the immutable CLI and OCR value type.
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/screen.rs
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-ocr-client/src/detection.rs
    predicate="$(jq -rn --arg query "${query}" '".query == \($query | tojson)"')" || status=$?
    if [[ "${status}" != 0 ]]; then
        _click_evidence_local_failure "${root}" "${operation}-query" "${status}" state 'OCR query encoding failed'
        return "$?"
    fi
    predicate+=' and (.engine | type == "string" and length > 0)
        and (.detections | type == "array") and .truncated == false
        and (.returned | type == "number" and floor == . and . >= 0)
        and .returned == (.detections | length) and .total == .returned
        and all(.detections[]; type == "object" and (.text | type == "string")
            and all(.x, .y, .width, .height, .confidence; type == "number" and isfinite)
            and .width >= 0 and .height >= 0)'
    if [[ $# == 4 ]]; then
        cli_guest_evidence "${root}" read-poll "${operation}" "${predicate}" -- screen find-text "${query}" --timeout 30
    else
        cli_guest_evidence "${root}" read-poll "${operation}" "${predicate}" -- screen find-text "${query}"
    fi
}

_click_evidence_local_failure() {
    local root="$1" operation="$2" status="$3" phase="$4" predicate="$5"
    if ((status > 128 && status <= 192)); then
        record_guest_poll "${root}" "${operation}" "${phase}" "${status}" "${predicate}"
    else
        _ui_evidence_fail "${root}" "${operation}" "${phase} exit ${status}: ${predicate}"
    fi
}

# Private: project one already checked read, then issue one physical input.
_click_guest_target() {
    local root="$1" operation="$2" response="$3" selection="$4" predicate point x y status=0
    # Keep floor-of-centre and the CLI uint16 coordinate range; add no reads.
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/input.rs
    predicate="${selection}"' | select(type == "object" and .width > 0 and .height > 0)
        | [(.x + .width / 2 | floor), (.y + .height / 2 | floor)]
        | select(all(.[]; type == "number" and isfinite and . >= 0 and . <= 65535))
        | "\(.[0]) \(.[1])"'
    point="$(jq -er "${predicate}" <<<"${response}")" || status=$?
    if [[ "${status}" != 0 ]]; then
        _click_evidence_local_failure "${root}" "${operation}-centre" "${status}" state "${predicate}"
        return "$?"
    fi
    read -r x y <<<"${point}"
    cli_guest_evidence "${root}" one-shot "${operation}-click" ".x == ${x} and .y == ${y} and .button == \"left\" and .count == 1" -- input click "${x}" "${y}" || return
    sleep 2 || status=$?
    if [[ "${status}" != 0 ]]; then
        record_guest_poll "${root}" "${operation}-settle" sleep "${status}" 'sleep 2 after one clean click'
        return "$?"
    fi
}

# allow_target_predicate: the exact-target predicate on one OCR response.
allow_target_predicate() {
    printf '%s\n' 'any(.detections[]; .text == "Allow")'
}

# click_guest_allow ROOT OPERATION [deferred]: exec trigger and confirmation
# remain separate. With deferred, a clean terminal negative returns 1 without
# its receipt, so nothing latches yet. The caller takes its untouched failure
# reads, and it then records OPERATION-exact-target with allow_target_predicate.
click_guest_allow() {
    local root="${1-}" operation="${2-}" deferred="${3-}" response status=0 predicate
    predicate="$(allow_target_predicate)"
    _ui_evidence_root "${root}" || return
    if [[ ($# != 2 && ($# != 3 || "${deferred}" != deferred)) || -z "${operation}" ]]; then
        _ui_evidence_fail "${root}" "${operation:-allow-arguments}" 'expected ROOT OPERATION and an optional deferred'
        return "$?"
    fi
    response="$(read_guest_text "${root}" "${operation}-ocr" Allow 30)" || return
    # The CLI stops on a substring, not necessarily an exact Allow. A clean
    # terminal negative is failed setup; unusable target geometry is unavailable.
    jq -e "${predicate}" >/dev/null <<<"${response}" || status=$?
    if [[ "${status}" == 1 ]]; then
        [[ "${deferred}" != deferred ]] || return 1
        record_guest_poll "${root}" "${operation}-exact-target" exhausted 1 "${predicate}"
        return "$?"
    elif [[ "${status}" != 0 ]]; then
        _click_evidence_local_failure "${root}" "${operation}-exact-target" "${status}" state "${predicate}"
        return "$?"
    fi
    _click_guest_target "${root}" "${operation}" "${response}" '[.detections[] | select(.text == "Allow")][0]'
}

# click_guest_element ROOT OPERATION WINDOW CONDITION, after the existing reveal.
click_guest_element() {
    local root="${1-}" operation="${2-}" response
    _ui_evidence_root "${root}" || return
    if [[ $# != 4 || -z "${operation}" ]]; then
        _ui_evidence_fail "${root}" "${operation:-click-arguments}" 'expected ROOT OPERATION WINDOW CONDITION'
        return "$?"
    fi
    response="$(read_guest_element "${root}" "${operation}-element" "$3" "$4" geometry)" || return
    _click_guest_target "${root}" "${operation}" "${response}" '{x:.positionX, y:.positionY, width:.sizeWidth, height:.sizeHeight}'
}
