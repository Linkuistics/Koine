#!/usr/bin/env bats

setup() {
    evidence="${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation"
    script="${evidence}/deferred-join.py"
    snapshot="${evidence}/events-01/settings-events.json"
    native="${evidence}/events-01/native-path-records.jsonl"
}

@test "deferred reader joins four historical actual-PID calls to exact buffered intervals" {
    run python3 "${script}" "${snapshot}" "${native}"
    [[ "${status}" == 0 ]]
    jq -e '.qualified == true and .joinedSelections == [1,2,3,4] and
        all(.intervals[]; (.clientCalls | length) == 1)' <<<"${output}"
}

@test "deferred reader reports missing wrong-PID and out-of-interval calls as unmatched" {
    for mode in empty pid time; do
        case "${mode}" in
            empty) : >"${BATS_TEST_TMPDIR}/mutant" ;;
            pid) jq -c '.processID=9999' "${native}" >"${BATS_TEST_TMPDIR}/mutant" ;;
            time) jq -c '.timestamp="2026-10-27 20:00:00.000000-0700"' "${native}" >"${BATS_TEST_TMPDIR}/mutant" ;;
        esac
        run python3 "${script}" "${snapshot}" "${BATS_TEST_TMPDIR}/mutant"
        [[ "${status}" == 0 ]]
        jq -e '.qualified == false and .joinedSelections == [] and (.intervals | length) == 4' <<<"${output}"
    done
}

@test "deferred reader rejects malformed log JSON and incomplete buffered intervals" {
    echo 'bad JSON' >"${BATS_TEST_TMPDIR}/bad"
    run python3 "${script}" "${snapshot}" "${BATS_TEST_TMPDIR}/bad"
    [[ "${status}" != 0 ]]
    jq '.records |= map(select(.event != "application.activate.after"))' "${snapshot}" >"${BATS_TEST_TMPDIR}/snapshot"
    run python3 "${script}" "${BATS_TEST_TMPDIR}/snapshot" "${native}"
    [[ "${status}" != 0 ]]
}
