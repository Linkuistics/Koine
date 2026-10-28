#!/usr/bin/env bats

setup() {
    export native_out="${BATS_TEST_TMPDIR}/out"
    export native_calls="${BATS_TEST_TMPDIR}/calls"
    mkdir -p "${native_out}" "${BATS_TEST_TMPDIR}/bin"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${native_calls}"
printf '%s\n' "${native_reply}"
exit "${native_status:-0}"
SH
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    export KOINE_K4_OUT="${native_out}"
}

@test "native startup retains a timed-out transport and never replays it" {
    export native_reply='{"ok":false,"exit_code":-1,"timed_out":true,"stdout":"started"}' native_status=255
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/native-start.sh"
    [[ "${status}" != 0 ]]
    [[ "$(cat "${native_out}/native-start.json")" == "${native_reply}" ]]
    [[ "$(wc -l <"${native_calls}" | tr -d ' ')" == 1 ]]
}

@test "native startup rejects a failed envelope even when the CLI exits zero" {
    export native_reply='{"ok":true,"exit_code":-1,"timed_out":true,"stdout":"started"}'
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/native-start.sh"
    [[ "${status}" != 0 ]]
    [[ "$(cat "${native_out}/native-start.json")" == "${native_reply}" ]]
}

@test "native startup accepts and retains a clean readiness observation" {
    export native_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":""}'
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/native-start.sh"
    [[ "${status}" == 0 ]]
    [[ "$(cat "${native_out}/native-start.json")" == "${native_reply}" ]]
    [[ "$(wc -l <"${native_calls}" | tr -d ' ')" == 1 ]]
}
