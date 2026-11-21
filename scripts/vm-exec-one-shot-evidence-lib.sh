# shellcheck shell=bash
# Source-only checked one-shot submissions and their downstream confirmations.
# scripts/vm_exec_reads.py owns each unchanged legacy command and its exact
# clean stdout. Each submission is sent once in the one-shot class. A failed
# submission latches the root, so no later read or answer can make it clean.
# Caller adoption, signals and the finite caller stay with their owners.
# shellcheck source=scripts/vm-sysevents-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-sysevents-evidence-lib.sh"

_one_shot_usage() {
    fail_guest_evidence "$1" "${2:-one-shot-arguments}" "expected $3"
}

# submit_guest_once ROOT OPERATION NAME
# One checked submission. 0 prints the record. Every failure is unavailable.
submit_guest_once() {
    [[ $# == 3 && -n "$2" ]] || {
        _one_shot_usage "${1-}" "${2-}" 'ROOT OPERATION NAME'
        return
    }
    _exec_read_root "$1" || return
    _guest_evidence_backend read "$1" one-shot "$2" "$3"
}

# The setup submissions whose confirmations are existing assertions that k76
# places in their existing positions: the signature verification after the
# extraction, the TextEdit window poll after its launch, the Allow prompt and
# the System Events check after the Automation request, and the Add button
# poll after the Accessibility pane opens.
submit_guest_extraction() { _one_shot_fixed "$@" extract-bundle; }
launch_guest_textedit() { _one_shot_fixed "$@" open-textedit; }
request_guest_automation() { _one_shot_fixed "$@" request-automation; }
open_guest_accessibility_pane() { _one_shot_fixed "$@" open-accessibility-pane; }

# launch_guest_koine ROOT OPERATION
# The `open` of the first launch, the silent launch and the reopen.
launch_guest_koine() { _one_shot_fixed "$@" open-koine; }

_one_shot_fixed() {
    [[ $# == 3 ]] || {
        _one_shot_usage "${1-}" "${2-}" 'ROOT OPERATION'
        return
    }
    submit_guest_once "$1" "$2" "$3" >/dev/null
}

# confirm_guest_launch ROOT OPERATION
# After a launch and its endpoint poll: one identity read. The descriptor's PID
# is the only process that the legacy executable pattern selects, and the
# kernel's executable path is the installed one. 0 prints the identity record.
# 1 is a clean mismatch, such as a stale descriptor or a second process.
confirm_guest_launch() {
    [[ $# == 2 ]] || {
        _one_shot_usage "${1-}" "${2-}" 'ROOT OPERATION'
        return
    }
    check_guest_read "$1" read-poll "$2" '.present and .joined' launch-identity
}

# confirm_guest_reopen ROOT OPERATION IDENTITY
# After the reopen: one identity read. The same process remains: the same
# instance, PID, start time in microseconds and executable as IDENTITY, the
# record that confirm_guest_launch printed. 1 is a clean mismatch.
confirm_guest_reopen() {
    local root="${1-}" operation="${2-}" before
    [[ $# == 3 ]] || {
        _one_shot_usage "${root}" "${operation}" 'ROOT OPERATION IDENTITY'
        return
    }
    _exec_read_root "${root}" || return
    before="$(jq -ce 'select(.read == "launch-identity" and .joined == true)
        | {instance: .descriptor.instanceId, process}' <<<"$3")" || {
        _one_shot_usage "${root}" "${operation}" 'IDENTITY to be a joined launch identity record'
        return
    }
    check_guest_read "${root}" read-poll "${operation}" \
        ".present and .joined and ({instance: .descriptor.instanceId, process} == ${before})" \
        launch-identity
}

# quit_guest_textedit ROOT OPERATION
# The one TextEdit quit, then one clean absence read. 0 means that no TextEdit
# process remains. 1 is a clean presence. A failed quit reads nothing.
quit_guest_textedit() {
    [[ $# == 2 ]] || {
        _one_shot_usage "${1-}" "${2-}" 'ROOT OPERATION'
        return
    }
    submit_guest_once "$1" "$2" quit-textedit >/dev/null || return
    check_guest_read "$1" read-poll "$2-absence" '.selected == []' process textedit
}

# restart_guest ROOT OPERATION BOOT
# The one restart. BOOT is the clean boot record read before it. After a clean
# submission, the existing 30-second wait, then at most sixty boot reads, each
# unchanged boot followed by five seconds. 0 prints the changed boot record.
# Exhaustion is a state failure. A failed submission or a failed read, such as
# a refused connection while the guest restarts, is unavailable at once, even
# if the boot later changes.
restart_guest() {
    local root="${1-}" operation="${2-}" before sleep_status=0
    [[ $# == 3 && -n "${operation}" ]] || {
        _one_shot_usage "${root}" "${operation}" 'ROOT OPERATION BOOT'
        return
    }
    _exec_read_root "${root}" || return
    before="$(jq -ce 'select(.read == "boot") | [.sec, .usec]' <<<"$3")" || {
        _one_shot_usage "${root}" "${operation}" 'BOOT to be a boot record'
        return
    }
    submit_guest_once "${root}" "${operation}" restart >/dev/null || return
    sleep 30 || sleep_status=$?
    if [[ "${sleep_status}" != 0 ]]; then
        record_guest_poll "${root}" "${operation}-wait" sleep "${sleep_status}" 'the 30-second wait'
        return
    fi
    _sysevents_poll "${root}" "${operation}-boot" 60 5 "[.sec, .usec] != ${before}" boot
}

# refuse_guest_trace_defaults ROOT OPERATION
# The ordering protocol permits no enabling diagnostic defaults write, so the
# legacy KOINE_SETTINGS_TRACE write becomes this refusal. Nothing is sent.
refuse_guest_trace_defaults() {
    [[ $# == 2 ]] || {
        _one_shot_usage "${1-}" "${2-}" 'ROOT OPERATION'
        return
    }
    _exec_read_root "$1" || return
    fail_guest_evidence "$1" "$2" 'the ordering protocol permits no enabling diagnostic defaults write'
}
