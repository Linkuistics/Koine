# shellcheck shell=bash
# Source-only checked System Events reads and the checked enrolment submission.
# scripts/vm_exec_reads.py owns each fixed guest command, its exact grammar and
# its parsed record. Each function keeps one existing assertion or poll of
# scripts/vm-verify-lib.sh or scripts/vm-verify-menu-bar.sh. Caller adoption,
# signals and the finite caller stay with their owners.
# shellcheck source=scripts/vm-exec-read-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-exec-read-evidence-lib.sh"

_sysevents_usage() {
    fail_guest_evidence "$1" "${2:-sysevents-arguments}" "expected $3"
}

# check_guest_read ROOT CLASS OPERATION PREDICATE NAME [ARGUMENT...]
# One checked read or submission, then one local state decision on its record
# under the same writer lock. 0 is a clean true state, and the record is
# printed. 1 is a clean false state, and nothing latches. Every other status
# stops, because the read or the decision is unavailable.
check_guest_read() {
    local root="${1-}" class="${2-}" operation="${3-}" predicate="${4-}" record state=0
    _exec_read_root "${root}" || return
    if [[ $# -lt 5 || -z "${operation}" || -z "${predicate}" ]]; then
        _sysevents_usage "${root}" "${operation}" 'ROOT CLASS OPERATION PREDICATE NAME [ARGUMENT...]'
        return
    fi
    shift 4
    record="$(_guest_evidence_backend read "${root}" "${class}" "${operation}" "$@")" || return
    jq -e "${predicate}" >/dev/null <<<"${record}" || state=$?
    record_guest_poll "${root}" "${operation}-state" state "${state}" "${predicate}" || return
    [[ "${state}" != 0 ]] || printf '%s\n' "${record}"
    return "${state}"
}

# Internal: LIMIT checked reads. Only a clean false state reaches the existing
# sleep. Exhaustion is a state failure.
_sysevents_poll() {
    local root="$1" operation="$2" limit="$3" delay="$4" predicate="$5"
    local attempt record state sleep_status
    shift 5
    for ((attempt = 1; attempt <= limit; attempt++)); do
        state=0
        record="$(check_guest_read "${root}" read-poll "${operation}-${attempt}" "${predicate}" "$@")" || state=$?
        if [[ "${state}" == 0 ]]; then
            printf '%s\n' "${record}"
            return 0
        fi
        [[ "${state}" == 1 ]] || return "${state}"
        sleep_status=0
        sleep "${delay}" || sleep_status=$?
        if [[ "${sleep_status}" != 0 ]]; then
            record_guest_poll "${root}" "${operation}-${attempt}-sleep" sleep "${sleep_status}" "${predicate}"
            return
        fi
    done
    record_guest_poll "${root}" "${operation}-exhausted" exhausted 1 "${predicate}"
}

# expect_guest_system_events ROOT OPERATION
# The check after the Automation grant: a complete, nonempty process list.
expect_guest_system_events() {
    [[ $# == 2 ]] || {
        _sysevents_usage "${1-}" "${2-}" 'ROOT OPERATION'
        return
    }
    check_guest_read "$1" read-poll "$2" '.value | length > 0' sysevents-processes
}

# expect_guest_menu_count ROOT OPERATION
# Koine has exactly one menu bar item.
expect_guest_menu_count() {
    [[ $# == 2 ]] || {
        _sysevents_usage "${1-}" "${2-}" 'ROOT OPERATION'
        return
    }
    check_guest_read "$1" read-poll "$2" '.value == 1' menu-item-count
}

# expect_guest_background_only ROOT OPERATION
# Koine is an agent application.
expect_guest_background_only() {
    [[ $# == 2 ]] || {
        _sysevents_usage "${1-}" "${2-}" 'ROOT OPERATION'
        return
    }
    check_guest_read "$1" read-poll "$2" '.value == true' background-only
}

# expect_guest_no_dock_item ROOT OPERATION
# No Dock item name contains "Koine". A missing value names no item.
expect_guest_no_dock_item() {
    [[ $# == 2 ]] || {
        _sysevents_usage "${1-}" "${2-}" 'ROOT OPERATION'
        return
    }
    check_guest_read "$1" read-poll "$2" \
        '[.value[] | strings | select(contains("Koine"))] == []' dock-items
}

# expect_guest_menu ROOT OPERATION TITLE...
# The open menu holds exactly these titles, in order. A separator is "".
# The comparison is between lists, never between rendered strings.
expect_guest_menu() {
    local root="${1-}" operation="${2-}" titles
    [[ $# -ge 3 ]] || {
        _sysevents_usage "${root}" "${operation}" 'ROOT OPERATION TITLE...'
        return
    }
    shift 2
    titles="$(jq -cn '$ARGS.positional' --args "$@")" || return
    check_guest_read "${root}" read-poll "${operation}" ".value == ${titles}" menu-titles
}

# await_guest_menu_label ROOT OPERATION LABEL
# await_menu_item_label: fifteen reads. Another label, a missing value or a
# clean absent item is a negative, and two seconds follow it.
await_guest_menu_label() {
    local root="${1-}" operation="${2-}" label
    [[ $# == 3 && -n "${operation}" ]] || {
        _sysevents_usage "${root}" "${operation}" 'ROOT OPERATION LABEL'
        return
    }
    label="$(jq -cn --arg label "$3" '$label')" || return
    _sysevents_poll "${root}" "${operation}" 15 2 \
        "(.absent | not) and .value == ${label}" menu-item-label poll
}

# await_guest_menu_frame ROOT OPERATION [TITLE]
# Without TITLE, the item frame poll of open_menu: five reads, each negative
# followed by two seconds. With TITLE, the row frame poll of choose_menu_item:
# five reads, each negative followed by one second. The legacy predicate held
# when the rendered frame began with a digit, which is a position whose x is a
# nonnegative integer. The record's text is the rendering that click_centre
# parses.
await_guest_menu_frame() {
    local root="${1-}" operation="${2-}"
    local predicate='(.absent | not) and (.value[0] | type == "array" and .[0] >= 0)'
    case "$#" in
    2) _sysevents_poll "${root}" "${operation}" 5 2 "${predicate}" menu-item-frame ;;
    3) _sysevents_poll "${root}" "${operation}" 5 1 "${predicate}" menu-row-frame "$3" ;;
    *) _sysevents_usage "${root}" "${operation}" 'ROOT OPERATION [TITLE]' ;;
    esac
}

# submit_guest_enrolment ROOT OPERATION SECRET LABEL
# The enrol submission of vm-verify-menu-bar.sh, sent once in the one-shot
# class. Its one complete JSON line must satisfy the legacy predicate: status
# 200 and no GraphQL error. 1 is a clean refusal. A failed submission latches,
# and no later text can make it clean.
submit_guest_enrolment() {
    [[ $# == 4 ]] || {
        _sysevents_usage "${1-}" "${2-}" 'ROOT OPERATION SECRET LABEL'
        return
    }
    check_guest_read "$1" one-shot "$2" \
        '.status == 200 and ((.response.errors // []) | length == 0)' enrol "$3" "$4"
}
