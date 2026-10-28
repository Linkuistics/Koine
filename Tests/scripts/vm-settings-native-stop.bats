#!/usr/bin/env bats

setup() {
    export log_dir="${BATS_TEST_TMPDIR}/log"
    mkdir -p "${log_dir}"
    stop_script="${KOINE_NATIVE_STOP_SCRIPT:-${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/native-guest-stop.sh}"
}

teardown() {
    if [[ -f "${log_dir}/pid" ]]; then
        kill "$(cat "${log_dir}/pid")" 2>/dev/null || true
    fi
}

@test "native stop rejects a logger that ended before collection" {
    printf '0\n' >"${log_dir}/stream.exit"
    run bash "${stop_script}" "${log_dir}"
    [[ "${status}" != 0 ]]
    [[ ! -f "${log_dir}/stop-requested.txt" ]]
}

@test "native stop rejects a missing process without claiming intentional stop" {
    printf '2147483647\n' >"${log_dir}/pid"
    run bash "${stop_script}" "${log_dir}"
    [[ "${status}" != 0 ]]
    [[ ! -f "${log_dir}/stop-requested.txt" ]]
}

@test "native stop signals a live logger and waits for its recorded exit" {
    # A headless stand-in writes its own completion when TERM arrives.
    bash -c 'trap '\''printf "0\n" >"${log_dir}/stream.exit"; exit 0'\'' TERM; : >"${log_dir}/ready"; while :; do sleep 0.1; done' &
    logger_pid=$!
    printf '%s\n' "${logger_pid}" >"${log_dir}/pid"
    # Observe readiness rather than relying on child scheduling within a sleep.
    for _ in {1..20}; do
        [[ ! -f "${log_dir}/ready" ]] || break
        sleep 0.05
    done
    [[ -f "${log_dir}/ready" ]]
    run bash "${stop_script}" "${log_dir}"
    completed_before_cleanup=0
    if [[ -f "${log_dir}/stream.exit" ]]; then completed_before_cleanup=1; fi
    kill "${logger_pid}" 2>/dev/null || true
    wait "${logger_pid}"
    [[ "${status}" == 0 ]]
    [[ "${completed_before_cleanup}" == 1 ]]
    [[ -s "${log_dir}/stop-requested.txt" ]]
    [[ "$(cat "${log_dir}/stream.exit")" == 0 ]]
    rm "${log_dir}/pid"
}
