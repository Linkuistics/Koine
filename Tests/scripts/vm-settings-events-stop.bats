#!/usr/bin/env bats

setup() {
    local repo="${BATS_TEST_DIRNAME}/../.."
    export events_root="${BATS_TEST_TMPDIR}/repo" events_stop_reply='{"ok":true,"stopped":true,"id":"koine-k12-events-01"}'
    export events_calls="${BATS_TEST_TMPDIR}/calls"
    mkdir -p "${events_root}/docs/verification/settings-activation" "${events_root}/bin" \
        "${events_root}/.build/settings-activation/events/Koine.app"
    cp "${repo}/docs/verification/settings-activation/events-run.sh" "${events_root}/run.sh"
    cp "${repo}/docs/verification/settings-activation/inventory.sh" "${events_root}/docs/verification/settings-activation/"
    cd "${events_root}"
    export fixture_evidence="${events_root}/docs/verification/settings-activation"
    printf 'subject\n' > .build/settings-activation/events/Koine.app/subject
    shasum -a 256 .build/settings-activation/events/Koine.app/subject > "${fixture_evidence}/events-subjects.sha256"
    bash "${fixture_evidence}/inventory.sh" .build/settings-activation/events/Koine.app > "${fixture_evidence}/events-bundle.txt"
    printf 'exit 0\n' > "${fixture_evidence}/events-transport.sh"
    printf 'exit 0\n' > "${fixture_evidence}/context-trace-disabled.sh"
    cat >bin/mise <<'SH'
#!/bin/bash
echo scenario >>"${events_calls}"
echo fixture >.build/vm-verify/menu-bar-fixture.log
echo "${scenario_status:-0}" >"${KOINE_K4_OUT}/scenario.exit"
exit "${scenario_status:-0}"
SH
    cat >bin/testanyware <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${events_calls}"
if [[ "$1 $2" == 'vm stop' ]]; then
    printf '%s\n' "${events_stop_reply}"
    exit "${events_stop_cli:-0}"
elif [[ "$*" == 'file exec --json bash /Users/admin/k12-inventory.sh '* ]]; then
    jq -n --rawfile out "${fixture_evidence}/events-bundle.txt" '{ok:true,exit_code:0,timed_out:false,stdout:$out}'
elif [[ "$1 $2" == 'file download' ]]; then
    echo fixture >"$4"
else
    echo '{"ok":true,"exit_code":0,"timed_out":false}'
fi
SH
    chmod +x bin/*
    export PATH="${events_root}/bin:${PATH}"
}

@test "events wrapper rejects a false stopped result even when CLI succeeds" {
    export events_stop_reply='{"ok":true,"stopped":false,"id":"koine-k12-events-01"}'
    run bash run.sh 01
    [[ "${status}" != 0 ]]
    [[ "$(cat .build/settings-activation/events/01/stop.exit)" == 1 ]]
    [[ "$(cat .build/settings-activation/events/01/stop.json)" == "${events_stop_reply}" ]]
    [[ "$(grep -c '^vm stop ' "${events_calls}")" == 1 ]]
}

@test "events wrapper rejects the wrong stopped VM identity" {
    export events_stop_reply='{"ok":true,"stopped":true,"id":"other-vm"}'
    run bash run.sh 01
    [[ "${status}" != 0 ]]
    [[ "$(cat .build/settings-activation/events/01/stop.exit)" == 1 ]]
}

@test "events wrapper preserves a scenario failure and still stops once" {
    export scenario_status=201
    run bash run.sh 01
    [[ "${status}" == 201 ]]
    [[ "$(cat .build/settings-activation/events/01/stop.exit)" == 0 ]]
    [[ "$(grep -c '^scenario$' "${events_calls}")" == 1 ]]
    [[ "$(tail -1 "${events_calls}")" == 'vm stop koine-k12-events-01 --json' ]]
}

@test "events wrapper accepts clean cleanup and preserves CLI stop failure" {
    run bash run.sh 01
    [[ "${status}" == 0 ]]
    # A second invocation cannot overwrite the first attempt's evidence.
    run bash run.sh 01
    [[ "${status}" != 0 ]]
    [[ "$(grep -c '^scenario$' "${events_calls}")" == 1 ]]
}

@test "events wrapper rejects nonzero stop CLI with matching returned text" {
    export events_stop_cli=7
    run bash run.sh 01
    [[ "${status}" == 7 ]]
    [[ "$(cat .build/settings-activation/events/01/stop.exit)" == 7 ]]
}
