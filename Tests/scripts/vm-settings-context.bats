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

# Execute the guest command itself with only defaults replaced, so the missing
# domain's real reported wording cannot be hidden by an envelope-only fixture.
run_guest_preflight() {
    cat >"${BATS_TEST_TMPDIR}/bin/defaults" <<'SH'
#!/bin/bash
printf '%s\n' "${defaults_output}"
exit "${defaults_status}"
SH
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'SH'
#!/bin/bash
set +e
bash -c "$4" >"${context_out}/guest-stdout" 2>"${context_out}/guest-stderr"
result=$?
jq -n --argjson result "$result" --rawfile out "${context_out}/guest-stdout" --rawfile err "${context_out}/guest-stderr" \
    '{ok:true, schema_version:"1.0", exit_code:$result, timed_out:false, stdout:$out, stderr:$err}'
SH
    chmod +x "${BATS_TEST_TMPDIR}/bin/defaults"
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/context-trace-disabled.sh" before
}

@test "context accepts the guest's absent-domain diagnostic" {
    export defaults_output="Error: Domain 'dev.antony.Koine' not found." defaults_status=1
    run_guest_preflight
    [[ "${status}" == 0 ]]
    [[ "$(cat "${context_out}/guest-stdout")" == KOINE_TRACE_DISABLED ]]
}

@test "context accepts the actual missing-key diagnostic after memory mode creates the domain" {
    export defaults_output="Error: Could not find key 'KoineSettingsActivationTrace' in domain 'dev.antony.Koine'." defaults_status=1
    run_guest_preflight
    [[ "${status}" == 0 ]]
    [[ "$(cat "${context_out}/guest-stdout")" == KOINE_TRACE_DISABLED ]]
}

@test "context refuses an unexpected preference error and an enabled preference" {
    export defaults_output='Could not communicate with preferences daemon' defaults_status=1
    run_guest_preflight
    [[ "${status}" != 0 ]]
    export defaults_output='/Users/admin/settings-activation.jsonl' defaults_status=0
    run_guest_preflight
    [[ "${status}" != 0 ]]
}

@test "context accepts the actual newline-normalized success transport" {
    export context_reply='{"command":"preflight","ok":true,"schema_version":"1.0","exit_code":0,"timed_out":false,"stdout":"KOINE_TRACE_DISABLED","stderr":""}'
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/context-trace-disabled.sh" before
    [[ "${status}" == 0 ]]
    [[ "$(cat "${context_out}/trace-disabled-before.json")" == "${context_reply}" ]]
}
