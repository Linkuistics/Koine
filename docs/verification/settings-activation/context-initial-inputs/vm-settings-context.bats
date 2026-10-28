#!/usr/bin/env bats

setup() {
    export context_out="${BATS_TEST_TMPDIR}/out" context_calls="${BATS_TEST_TMPDIR}/calls"
    mkdir -p "${context_out}" "${BATS_TEST_TMPDIR}/bin"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${context_calls}"
printf '%s\n' "${context_reply}"
exit "${context_status:-0}"
SH
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}" KOINE_K4_OUT="${context_out}"
}

@test "context rejects enabled tracing and preserves the one observation" {
    export context_reply='{"ok":true,"exit_code":1,"timed_out":false,"stdout":"/Users/admin/settings-activation.jsonl","stderr":""}'
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/context-trace-disabled.sh" before
    [[ "${status}" != 0 ]]
    [[ "$(cat "${context_out}/trace-disabled-before.json")" == "${context_reply}" ]]
    [[ "$(wc -l <"${context_calls}" | tr -d ' ')" == 1 ]]
}

@test "context rejects timed-out trace observation even with a success marker" {
    export context_reply='{"ok":true,"exit_code":0,"timed_out":true,"stdout":"KOINE_TRACE_DISABLED\n","stderr":""}'
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/context-trace-disabled.sh" after
    [[ "${status}" != 0 ]]
    [[ "$(cat "${context_out}/trace-disabled-after.json")" == "${context_reply}" ]]
}

@test "context requires the disabled marker from a clean single transport" {
    export context_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"unexpected\n","stderr":""}'
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/context-trace-disabled.sh" before
    [[ "${status}" != 0 ]]
    export context_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"KOINE_TRACE_DISABLED\n","stderr":""}'
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/context-trace-disabled.sh" after
    [[ "${status}" == 0 ]]
    [[ "$(cat "${context_out}/trace-disabled-after.json")" == "${context_reply}" ]]
}
