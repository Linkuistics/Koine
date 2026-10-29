#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Bats isolates each test; setup runs for every case.

setup() {
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    export exec_root="${BATS_TEST_TMPDIR}/evidence"
    export exec_calls="${BATS_TEST_TMPDIR}/calls"
    export exec_reply="${BATS_TEST_TMPDIR}/reply"
    export exec_stderr="${BATS_TEST_TMPDIR}/stderr"
    export exec_started="${BATS_TEST_TMPDIR}/started"
    mkdir "${BATS_TEST_TMPDIR}/bin"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'SH'
#!/bin/bash
jq -cn --args '$ARGS.positional' -- "$@" >>"${exec_calls}"
touch "${exec_started}"
sleep "${exec_delay:-0}"
cat "${exec_reply}"
cat "${exec_stderr}" >&2
exit "${exec_status:-0}"
SH
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    printf 'CLI diagnostic\n' >"${exec_stderr}"
    printf '%s\n' '{"schema_version":"1.0","command":"probe","ok":true,"exit_code":0,"timed_out":false,"stdout":"READY\n","stderr":"guest diagnostic\n"}' >"${exec_reply}"
}

change_reply() {
    jq "$1" "${exec_reply}" >"${exec_reply}.new"
    mv "${exec_reply}.new" "${exec_reply}"
}

@test "clean exec retains exact bytes, command, VM, status and ordered receipts" {
    init_guest_evidence "${exec_root}" exact-vm
    run exec_guest_evidence "${exec_root}" one-shot launch probe '.stdout == "READY\n"'
    [[ "${status}" == 0 && "${output}" == READY ]]
    cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
    cmp "${exec_stderr}" "${exec_root}/000001/raw.stderr"
    [[ "$(cat "${exec_root}/000001/cli.exit")" == 0 ]]
    jq -e '. == ["file","exec","--vm","exact-vm","--json","--","probe"]' "${exec_calls}"
    jq -e '.ordinal == 1 and .vm == "exact-vm" and .class == "one-shot" and .operation == "launch" and .command == "probe" and (.started | length > 0)' "${exec_root}/000001/request.json"
    jq -e '.outcome == "clean" and (.ended | length > 0) and .duration_ns >= 0' "${exec_root}/000001/result.json"
    printf 'guest diagnostic\n' >"${BATS_TEST_TMPDIR}/want"
    cmp "${BATS_TEST_TMPDIR}/want" "${exec_root}/000001/guest.stderr"
}

@test "initialization refuses reuse without touching existing evidence" {
    init_guest_evidence "${exec_root}" exact-vm
    run init_guest_evidence "${exec_root}" different-vm
    [[ "${status}" != 0 ]]
    jq -e '.vm == "exact-vm"' "${exec_root}/subject.json"
    [[ ! -e "${exec_calls}" ]]
}

@test "missing and wrongly typed envelope fields cannot qualify matching text" {
    local original ordinal=0
    original="$(cat "${exec_reply}")"
    for mutation in 'del(.ok)' 'del(.timed_out)' 'del(.exit_code)' 'del(.stdout)' \
        'del(.stderr)' 'del(.command)' 'del(.schema_version)' '.ok = false' \
        '.timed_out = true' '.exit_code = -1' '.exit_code = false' \
        '.exit_code = "0"' '.ok = "true"' '.timed_out = 0' '.stdout = null' \
        '.stderr = []' '.schema_version = "2.0"' '.command = "other"' '.dry_run = true'; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/case-${ordinal}"
        printf '%s\n' "${original}" >"${exec_reply}"
        change_reply "${mutation}"
        init_guest_evidence "${exec_root}" exact-vm
        run exec_guest_evidence "${exec_root}" read-poll state probe '.stdout == "READY\n"'
        [[ "${status}" == 125 ]]
        [[ -f "${exec_root}/unavailable" ]]
        cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
    done
}

@test "partial malformed duplicate and multiple JSON responses stay unavailable" {
    local ordinal=0 good
    good="$(cat "${exec_reply}")"
    for reply in '' '{"ok":true' 'not JSON' "${good}${good}" \
        "${good%\}},\"extra\":NaN}" "${good%\}},\"extra\":Infinity}" \
        "${good%\}},\"ok\":false,\"ok\":true}"; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/case-${ordinal}"
        printf '%s' "${reply}" >"${exec_reply}"
        init_guest_evidence "${exec_root}" exact-vm
        run exec_guest_evidence "${exec_root}" evidence raw probe true
        [[ "${status}" == 125 ]]
        cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
    done
}

@test "nonzero CLI status never qualifies a clean envelope and never retries" {
    for exec_status in 7 255 1; do
        export exec_status
        exec_root="${BATS_TEST_TMPDIR}/status-${exec_status}"
        init_guest_evidence "${exec_root}" exact-vm
        run exec_guest_evidence "${exec_root}" one-shot launch probe true
        [[ "${status}" == 125 ]]
        [[ "$(cat "${exec_root}/000001/cli.exit")" == "${exec_status}" ]]
    done
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 3 ]]
}

@test "timeout with matching real retained output cannot qualify" {
    cp "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/persisted-01/trace-disabled-after.json" "${exec_reply}"
    init_guest_evidence "${exec_root}" exact-vm
    local command
    command="$(jq -r .command "${exec_reply}")"
    run exec_guest_evidence "${exec_root}" evidence defaults "${command}" '.stdout == "KOINE_TRACE_DISABLED"'
    [[ "${status}" == 125 ]]
    cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
}

@test "missing command completion marker and invalid predicates latch unavailable" {
    local ordinal=0
    for predicate in '.stdout == "COMPLETE"' 'empty' 'true, true' 'true, false' 'null' 'not valid jq' 'halt' 'halt_error(0)'; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/predicate-${ordinal}"
        init_guest_evidence "${exec_root}" exact-vm
        run exec_guest_evidence "${exec_root}" evidence inventory probe "${predicate}"
        [[ "${status}" == 125 && -f "${exec_root}/unavailable" ]]
    done
}

@test "competing writers latch unavailable before a second transport can dispatch" {
    init_guest_evidence "${exec_root}" exact-vm
    export exec_delay=1
    exec_guest_evidence "${exec_root}" evidence context probe true >"${BATS_TEST_TMPDIR}/first.out" &
    local writer=$! ready=0
    for _ in $(seq 1 100); do
        if [[ -f "${exec_started}" ]]; then
            ready=1
            break
        fi
        sleep 0.02
    done
    if [[ "${ready}" != 1 ]]; then
        wait "${writer}"
        return 1
    fi
    run exec_guest_evidence "${exec_root}" one-shot launch probe true
    [[ "${status}" == 125 && -e "${exec_root}/unavailable" ]]
    wait "${writer}"
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
    run exec_guest_evidence "${exec_root}" read-poll state probe true
    [[ "${status}" == 125 ]]
}

@test "clean negative polling permits the next existing poll without a hidden retry" {
    init_guest_evidence "${exec_root}" exact-vm
    change_reply '.stdout = "ABSENT"'
    run exec_guest_evidence "${exec_root}" read-poll endpoint probe '.stdout == "ABSENT" or .stdout == "PRESENT"'
    [[ "${status}" == 0 && "${output}" == ABSENT ]]
    change_reply '.stdout = "PRESENT"'
    run exec_guest_evidence "${exec_root}" read-poll endpoint probe '.stdout == "ABSENT" or .stdout == "PRESENT"'
    [[ "${status}" == 0 && "${output}" == PRESENT ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 2 ]]
    jq -e '.ordinal == 2' "${exec_root}/000002/request.json"
    [[ ! -e "${exec_root}/unavailable" ]]
}

@test "failed poll latches across command substitution and prevents all later scenario dispatch" {
    init_guest_evidence "${exec_root}" exact-vm
    export exec_status=7
    local text
    text="$(exec_guest_evidence "${exec_root}" read-poll endpoint probe true)" || true
    [[ -z "${text}" ]]
    export exec_status=0
    run exec_guest_evidence "${exec_root}" read-poll endpoint probe true
    [[ "${status}" == 125 ]]
    run exec_guest_evidence "${exec_root}" one-shot reopen probe true
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
}

@test "disconnect followed by changed boot in collection stays unavailable and cannot relaunch" {
    init_guest_evidence "${exec_root}" exact-vm
    export exec_status=255
    run exec_guest_evidence "${exec_root}" one-shot restart probe true
    [[ "${status}" == 125 ]]
    cp "${exec_root}/unavailable" "${BATS_TEST_TMPDIR}/first-failure"
    export exec_status=0
    change_reply '.stdout = "CHANGED_BOOT"'
    run exec_guest_evidence "${exec_root}" evidence boot-after probe '.stdout == "CHANGED_BOOT"'
    [[ "${status}" == 0 ]]
    cmp "${BATS_TEST_TMPDIR}/first-failure" "${exec_root}/unavailable"
    run exec_guest_evidence "${exec_root}" one-shot launch probe true
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 2 ]]
}

@test "unfinished prior attempt blocks scenario input but allows evidence collection" {
    init_guest_evidence "${exec_root}" exact-vm
    mkdir "${exec_root}/000001"
    printf 'interrupted partial response' >"${exec_root}/000001/raw.stdout"
    run exec_guest_evidence "${exec_root}" one-shot launch probe true
    [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
    run exec_guest_evidence "${exec_root}" evidence context probe true
    [[ "${status}" == 0 && -e "${exec_root}/unavailable" ]]
    [[ "$(cat "${exec_root}/000001/raw.stdout")" == 'interrupted partial response' ]]
}

@test "unknown class and missing initialized subject never dispatch" {
    init_guest_evidence "${exec_root}" exact-vm
    run exec_guest_evidence "${exec_root}" retry launch probe true
    [[ "${status}" != 0 ]]
    run exec_guest_evidence "${exec_root}-absent" one-shot launch probe true
    [[ "${status}" != 0 && ! -e "${exec_calls}" ]]
}
