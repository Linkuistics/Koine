#!/usr/bin/env bats

setup() {
    export KOINE_K4_OUT="${BATS_TEST_TMPDIR}/out" persisted_calls="${BATS_TEST_TMPDIR}/calls"
    mkdir -p "${KOINE_K4_OUT}" "${BATS_TEST_TMPDIR}/bin"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${persisted_calls}"
printf '%s\n' "${persisted_reply}"
exit "${persisted_status:-0}"
SH
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    script="${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/persisted-config.sh"
    export persisted_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"status\nKOINE_PERSISTED_enable_COMPLETE","stderr":""}'
}

@test "persisted config retains one normalized successful enable response" {
    run bash "${script}" enable
    [[ "${status}" == 0 ]]
    [[ "$(cat "${KOINE_K4_OUT}/persisted-enable.json")" == "${persisted_reply}" ]]
    [[ "$(wc -l <"${persisted_calls}" | tr -d ' ')" == 1 ]]
}

@test "persisted config rejects failed transports and wrong phase without replay" {
    for reply in \
        '{"ok":true,"exit_code":0,"timed_out":true,"stdout":"KOINE_PERSISTED_enable_COMPLETE"}' \
        '{"ok":true,"exit_code":1,"timed_out":false,"stdout":"KOINE_PERSISTED_enable_COMPLETE"}' \
        '{"ok":false,"exit_code":0,"timed_out":false,"stdout":"KOINE_PERSISTED_enable_COMPLETE"}' \
        '{"ok":true,"exit_code":0,"timed_out":false,"stdout":"KOINE_PERSISTED_status_COMPLETE"}'; do
        export persisted_reply="${reply}"
        run bash "${script}" enable
        [[ "${status}" != 0 ]]
        [[ "$(cat "${KOINE_K4_OUT}/persisted-enable.json")" == "${persisted_reply}" ]]
    done
    export persisted_status=7
    run bash "${script}" enable
    [[ "${status}" == 7 ]]
    [[ "$(wc -l <"${persisted_calls}" | tr -d ' ')" == 5 ]]
}

@test "persisted config reads status and refuses unknown phases before any transport" {
    export persisted_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"KOINE_PERSISTED_status_COMPLETE\n"}'
    run bash "${script}" status
    [[ "${status}" == 0 ]]
    run bash "${script}" reset
    [[ "${status}" == 2 ]]
    [[ "$(wc -l <"${persisted_calls}" | tr -d ' ')" == 1 ]]
}

@test "persisted scenario refuses direct invocation before any VM command" {
    unset KOINE_K4_OUT KOINE_VM_ID TESTANYWARE_VM_ID KOINE_APP_BUNDLE
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/persisted-prefix.sh"
    [[ "${status}" != 0 ]]
    [[ ! -e "${persisted_calls}" ]]
}
