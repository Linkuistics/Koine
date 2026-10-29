# shellcheck shell=bash
# Source-only strict window transports. No ambient VM or legacy fallback.
# Ordinary scenario adoption is a separate migration; callers must check every
# return, retain these original lists and perform their own outcome assertions.
# shellcheck source=scripts/vm-guest-exec-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-guest-exec-lib.sh"

_window_evidence_root() {
    [[ -n "$1" && -f "$1/subject.json" ]] || {
        echo 'window evidence requires an initialized nonempty root' >&2
        return 125
    }
}

_window_evidence_fail() {
    local root="$1" operation="$2" reason="$3"
    _window_evidence_root "${root}" || return
    fail_guest_evidence "${root}" "${operation}" "${reason}"
}

# read_guest_windows ROOT CLASS OPERATION: emit the entire qualified original
# envelope. An empty list is clean data; an error is never an absence observation.
read_guest_windows() {
    local root="${1-}" kind="${2-}" operation="${3-}" predicate
    _window_evidence_root "${root}" || return
    [[ $# == 3 && -n "${operation}" ]] || {
        _window_evidence_fail "${root}" window-list-arguments 'expected ROOT CLASS OPERATION'
        return "$?"
    }
    case "${kind}" in
    read-poll | evidence) ;;
    *)
        _window_evidence_fail "${root}" "${operation}" 'window list class must be read-poll or evidence'
        return "$?"
        ;;
    esac
    # Required WindowInfo geometry/app/type/focus, with optional title/elements.
    # No title, focus or process-identity assertion is added by the count schema.
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-protocol/src/window_info.rs
    predicate='(.windows | type == "array") and all(.windows[];
        type == "object" and (.appName | type == "string")
        and (.windowType | type == "string") and (.focused | type == "boolean")
        and ((has("title") | not) or (.title | type == "string"))
        and ((has("elements") | not) or (.elements | type == "array"))
        and all(.positionX, .positionY, .sizeWidth, .sizeHeight;
            type == "number" and isfinite))'
    cli_guest_evidence "${root}" "${kind}" "${operation}" "${predicate}" -- agent windows
}

# act_guest_window ROOT OPERATION window-{move,focus,close} WINDOW [X Y]
# This receipt proves clean submission, not the requested downstream UI state.
act_guest_window() {
    local root="${1-}" operation="${2-}" action="${3-}" window="${4-}" predicate
    local -a options=(--window "${window}")
    _window_evidence_root "${root}" || return
    [[ -n "${operation}" ]] || {
        _window_evidence_fail "${root}" window-action-arguments 'expected ROOT OPERATION ACTION WINDOW'
        return "$?"
    }
    case "${action}" in
    window-focus | window-close)
        [[ $# == 4 && -n "${window}" ]] || {
            _window_evidence_fail "${root}" "${operation}" 'expected one window target'
            return "$?"
        }
        ;;
    window-move)
        [[ $# == 6 && -n "${window}" && "$5" =~ ^-?[0-9]+$ && "$6" =~ ^-?[0-9]+$ ]] || {
            _window_evidence_fail "${root}" "${operation}" 'expected window target and integer x/y'
            return "$?"
        }
        options+=("--x=$5" "--y=$6")
        ;;
    *)
        _window_evidence_fail "${root}" "${operation}" 'unsupported window action'
        return "$?"
        ;;
    esac
    # emit_action reports action/success/message, not target coordinates/title.
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs
    predicate=".action == \"${action}\" and .success == true and has(\"message\")
        and (.message == null or (.message | type == \"string\"))"
    cli_guest_evidence "${root}" one-shot "${operation}" "${predicate}" -- agent "${action}" "${options[@]}"
}

# await_guest_window_count ROOT OPERATION APP {0,1}: existing Koine count poll.
await_guest_window_count() {
    local root="${1-}" operation="${2-}" app="${3-}" expected="${4-}" predicate
    _window_evidence_root "${root}" || return
    [[ $# == 4 && -n "${operation}" && -n "${app}" && "${expected}" =~ ^[01]$ ]] || {
        _window_evidence_fail "${root}" "${operation:-window-count-arguments}" 'expected ROOT OPERATION APP and window count 0 or 1'
        return "$?"
    }
    predicate="$(jq -cn --arg app "${app}" --argjson count "${expected}" \
        '"([.windows[] | select(.appName == \($app | tojson))] | length) == \($count)"' -r)" || {
        _window_evidence_fail "${root}" "${operation}" 'window count predicate encoding failed'
        return "$?"
    }
    _await_guest_windows "${root}" "${operation}" "${predicate}" 10
}

# Existing TextEdit preparation: fifteen by two, then an unconditional assertion.
await_guest_textedit_window() {
    local root="${1-}" operation="${2-}"
    _window_evidence_root "${root}" || return
    [[ $# == 2 && -n "${operation}" ]] || {
        _window_evidence_fail "${root}" textedit-poll-arguments 'expected ROOT OPERATION'
        return "$?"
    }
    _await_guest_windows "${root}" "${operation}" '([.windows[] | select(.appName == "TextEdit")] | length) >= 1' 15 1
}

# Internal: 0 means clean true state, 1 clean false, all other statuses stop.
# Both the full original list and this local predicate/status receive receipts.
_window_poll_read() {
    local root="$1" operation="$2" predicate="$3" response state_status=0
    response="$(read_guest_windows "${root}" read-poll "${operation}")" || return
    jq -e "${predicate}" >/dev/null <<<"${response}" || state_status=$?
    record_guest_poll "${root}" "${operation}-state" state "${state_status}" "${predicate}" || return
    if [[ "${state_status}" == 0 ]]; then
        printf '%s\n' "${response}"
    fi
    return "${state_status}"
}

_await_guest_windows() {
    local root="$1" operation="$2" predicate="$3" limit="$4" final_assertion="${5:-0}"
    local response attempt state_status=1 sleep_status
    for ((attempt = 1; attempt <= limit; attempt++)); do
        state_status=0
        response="$(_window_poll_read "${root}" "${operation}-${attempt}" "${predicate}")" || state_status=$?
        if [[ "${state_status}" == 0 ]]; then break; fi
        if [[ "${state_status}" != 1 ]]; then return "${state_status}"; fi
        # Preserve the final negative poll's existing sleep too. Only a clean
        # false state reaches it; failed/interrupted transport never does.
        sleep_status=0
        sleep 2 || sleep_status=$?
        if [[ "${sleep_status}" != 0 ]]; then
            record_guest_poll "${root}" "${operation}-${attempt}-sleep" sleep "${sleep_status}" "${predicate}"
            return "$?"
        fi
    done
    if [[ "${final_assertion}" == 1 ]]; then
        # The legacy TextEdit block always asserts again, even after an early
        # positive. It also allows a window to appear during the last sleep.
        state_status=0
        response="$(_window_poll_read "${root}" "${operation}-assertion" "${predicate}")" || state_status=$?
        if [[ "${state_status}" != 0 && "${state_status}" != 1 ]]; then return "${state_status}"; fi
    fi
    if [[ "${state_status}" == 0 ]]; then
        printf '%s\n' "${response}"
        return
    fi
    record_guest_poll "${root}" "${operation}-exhausted" exhausted 1 "${predicate}"
}
