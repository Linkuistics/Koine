#!/usr/bin/env bats

setup() {
    export KOINE_K4_OUT="${BATS_TEST_TMPDIR}/out" deferred_calls="${BATS_TEST_TMPDIR}/calls"
    mkdir -p "${KOINE_K4_OUT}" "${BATS_TEST_TMPDIR}/bin"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${deferred_calls}"
printf '%s\n' "${deferred_reply}"
exit "${deferred_status:-0}"
SH
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    script="${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/deferred-transport.sh"
    export deferred_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"KOINE_DEFERRED_COMPLETE\n","stderr":""}'
}

@test "deferred collection accepts and retains one clean completed transport" {
    run bash "${script}"
    [[ "${status}" == 0 ]]
    [[ "$(cat "${KOINE_K4_OUT}/deferred-collect.json")" == "${deferred_reply}" ]]
    [[ "$(wc -l <"${deferred_calls}" | tr -d ' ')" == 1 ]]
}

@test "deferred collection rejects timeout guest failure and CLI failure without replay" {
    for reply in \
        '{"ok":true,"exit_code":0,"timed_out":true,"stdout":"KOINE_DEFERRED_COMPLETE\n"}' \
        '{"ok":true,"exit_code":1,"timed_out":false,"stdout":"KOINE_DEFERRED_COMPLETE\n"}' \
        '{"ok":false,"exit_code":0,"timed_out":false,"stdout":"KOINE_DEFERRED_COMPLETE\n"}'; do
        export deferred_reply="${reply}"
        run bash "${script}"
        [[ "${status}" != 0 ]]
    done
    export deferred_status=1
    run bash "${script}"
    [[ "${status}" != 0 ]]
    [[ "$(wc -l <"${deferred_calls}" | tr -d ' ')" == 4 ]]
}

@test "deferred collection rejects missing completion and preserves raw output" {
    export deferred_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"partial"}'
    run bash "${script}"
    [[ "${status}" != 0 ]]
    [[ "$(cat "${KOINE_K4_OUT}/deferred-collect.json")" == "${deferred_reply}" ]]
}

@test "deferred packaging preserves a partial archive and original acquisition failure" {
    mkdir -p "${BATS_TEST_TMPDIR}/partial/system.logarchive"
    echo partial >"${BATS_TEST_TMPDIR}/partial/system.logarchive/raw"
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/deferred-package.sh" \
        "${BATS_TEST_TMPDIR}/partial" "${BATS_TEST_TMPDIR}/partial.tgz" 7
    [[ "${status}" == 7 ]]
    [[ -s "${BATS_TEST_TMPDIR}/partial.tgz" ]]
    tar -xOf "${BATS_TEST_TMPDIR}/partial.tgz" partial/system.logarchive/raw | grep -qx partial
    [[ "$(cat "${BATS_TEST_TMPDIR}/partial/acquisition.exit")" == 7 ]]
    [[ "$(cat "${BATS_TEST_TMPDIR}/partial/package.exit")" == 0 ]]
    [[ ! -e "${BATS_TEST_TMPDIR}/partial/complete.txt" ]]
}

@test "deferred packaging failure stays failed even after successful acquisition" {
    mkdir -p "${BATS_TEST_TMPDIR}/partial"
    run bash "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/deferred-package.sh" \
        "${BATS_TEST_TMPDIR}/partial" "${BATS_TEST_TMPDIR}/absent/partial.tgz" 0
    [[ "${status}" != 0 ]]
    [[ "$(cat "${BATS_TEST_TMPDIR}/partial/acquisition.exit")" == 0 ]]
    [[ "$(cat "${BATS_TEST_TMPDIR}/partial/package.exit")" != 0 ]]
    [[ ! -e "${BATS_TEST_TMPDIR}/partial/complete.txt" ]]
}

@test "deferred preflight accepts the exact clean guest response with normalized trailing newline" {
    local evidence="${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation"
    export deferred_reply
    deferred_reply="$(cat "${evidence}/deferred-01/deferred-preflight.json")"
    run bash "${evidence}/deferred-preflight.sh"
    [[ "${status}" == 0 ]]
    deferred_reply="$(jq '.stdout += "\n"' <<<"${deferred_reply}")"
    run bash "${evidence}/deferred-preflight.sh"
    [[ "${status}" == 0 ]]
}

@test "deferred preflight rejects timeout and wrong completion despite normalized output" {
    local evidence="${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation"
    export deferred_reply
    deferred_reply="$(jq '.timed_out=true' "${evidence}/deferred-01/deferred-preflight.json")"
    run bash "${evidence}/deferred-preflight.sh"
    [[ "${status}" != 0 ]]
    deferred_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"KOINE_DEFERRED_PREFLIGHT_COMPLETEwrong"}'
    run bash "${evidence}/deferred-preflight.sh"
    [[ "${status}" != 0 ]]
}

@test "deferred preflight rejects failed guest CLI and false-ok envelopes without replay" {
    local evidence="${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation"
    export deferred_reply
    for mutation in '.exit_code=7' '.ok=false'; do
        deferred_reply="$(jq "${mutation}" "${evidence}/deferred-01/deferred-preflight.json")"
        run bash "${evidence}/deferred-preflight.sh"
        [[ "${status}" != 0 ]]
        [[ "$(cat "${KOINE_K4_OUT}/deferred-preflight.json")" == "${deferred_reply}" ]]
    done
    deferred_reply="$(cat "${evidence}/deferred-01/deferred-preflight.json")"
    export deferred_status=7
    run bash "${evidence}/deferred-preflight.sh"
    [[ "${status}" == 7 ]]
    [[ "$(wc -l <"${deferred_calls}" | tr -d ' ')" == 3 ]]
}
