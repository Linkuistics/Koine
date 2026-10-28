#!/usr/bin/env bats

setup() {
    local repo="${BATS_TEST_DIRNAME}/../.."
    export retention_root="${BATS_TEST_TMPDIR}/repo" retention_stop_reply='{"ok":true,"stopped":true,"id":"koine-k12-retention-01"}'
    export display_reply='{"ok":true,"width":1920,"height":1080}'
    export environment_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"fixture"}'
    export retention_calls="${BATS_TEST_TMPDIR}/calls"
    mkdir -p "${retention_root}/docs/verification/settings-activation" "${retention_root}/bin" \
        "${retention_root}/.build/settings-activation/events/Koine.app"
    cp "${repo}/docs/verification/settings-activation/retention-run.sh" "${retention_root}/run.sh"
    cp "${repo}/docs/verification/settings-activation/inventory.sh" "${retention_root}/docs/verification/settings-activation/"
    cd "${retention_root}"
    export fixture_evidence="${retention_root}/docs/verification/settings-activation"
    printf 'subject\n' > .build/settings-activation/events/Koine.app/subject
    shasum -a 256 .build/settings-activation/events/Koine.app/subject > "${fixture_evidence}/retention-subjects.sha256"
    bash "${fixture_evidence}/inventory.sh" .build/settings-activation/events/Koine.app > "${fixture_evidence}/retention-bundle.txt"
    printf 'exit 0\n' > "${fixture_evidence}/events-transport.sh"
    printf 'exit 0\n' > "${fixture_evidence}/deferred-transport.sh"
    printf 'exit 0\n' > "${fixture_evidence}/context-trace-disabled.sh"
    cat >bin/mise <<'SH'
#!/bin/bash
echo "$PPID" >"${retention_root}/wrapper-pid"
echo scenario >>"${retention_calls}"
echo fixture >.build/vm-verify/menu-bar-fixture.log
echo "${initial_check:-0}" >"${KOINE_K4_OUT}/installed-before-check.exit"
echo "${scenario_status:-0}" >"${KOINE_K4_OUT}/scenario.exit"
exit "${scenario_status:-0}"
SH
    cat >bin/testanyware <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${retention_calls}"
if [[ "$1 $2" == 'vm stop' ]]; then
    printf '%s\n' "${retention_stop_reply}"
    exit "${retention_stop_cli:-0}"
elif [[ "$*" == 'file exec --json bash /Users/admin/k12-inventory.sh '* ]]; then
    jq -n --rawfile out "${fixture_evidence}/retention-bundle.txt" '{ok:true,exit_code:0,timed_out:false,stdout:$out}'
elif [[ "$1 $2" == 'screen size' ]]; then
    printf '%s\n' "${display_reply}"
    exit "${display_cli:-0}"
elif [[ "$4" == 'sw_vers; uname -m; spctl --status' ]]; then
    printf '%s\n' "${environment_reply}"
    exit "${environment_cli:-0}"
elif [[ "$1 $2" == 'file download' ]]; then
    echo fixture >"$4"
else
    echo '{"ok":true,"exit_code":0,"timed_out":false}'
fi
SH
    chmod +x bin/*
    export PATH="${retention_root}/bin:${PATH}"
}

@test "retention preserves environment CLI failure and fails audit while stopping once" {
    export environment_cli=7
    run bash run.sh 01
    [[ "${status}" != 0 ]]
    [[ "$(cat .build/settings-activation/retention/01/guest-final-cli.exit)" == 7 ]]
    [[ "$(cat .build/settings-activation/retention/01/audit.exit)" == 1 ]]
    [[ "$(grep -c '^vm stop ' "${retention_calls}")" == 1 ]]
}

@test "retention rejects timeout environment and false-ok display envelopes" {
    export environment_reply='{"ok":true,"exit_code":-1,"timed_out":true,"stdout":"plausible"}'
    export display_reply='{"ok":false,"width":1920,"height":1080}'
    run bash run.sh 01
    [[ "${status}" != 0 ]]
    [[ "$(cat .build/settings-activation/retention/01/audit.exit)" == 1 ]]
    [[ "$(cat .build/settings-activation/retention/01/guest-final.json)" == "${environment_reply}" ]]
    [[ "$(cat .build/settings-activation/retention/01/final-display.json)" == "${display_reply}" ]]
    [[ "$(grep -c '^vm stop ' "${retention_calls}")" == 1 ]]
}

@test "retention stops once and records TERM received during ordinary collection" {
    cat >"${fixture_evidence}/deferred-transport.sh" <<'SH'
kill -TERM "$(cat "${retention_root}/wrapper-pid")"
sleep 0.1
SH
    run bash run.sh 01
    [[ "${status}" == 143 ]]
    [[ "$(cat .build/settings-activation/retention/01/interruption.exit)" == 143 ]]
    [[ "$(cat .build/settings-activation/retention/01/stop.exit)" == 0 ]]
    [[ "$(grep -c '^vm stop ' "${retention_calls}")" == 1 ]]
}

@test "retention accepts clean collection and refuses overwriting an attempt" {
    run bash run.sh 01
    [[ "${status}" == 0 ]]
    run bash run.sh 01
    [[ "${status}" != 0 ]]
    [[ "$(grep -c '^scenario$' "${retention_calls}")" == 1 ]]
}

@test "retention preserves a failed independent initial endpoint in its audit" {
    export initial_check=1
    run bash run.sh 01
    [[ "${status}" != 0 ]]
    [[ "$(cat .build/settings-activation/retention/01/audit.exit)" == 1 ]]
    [[ "$(cat .build/settings-activation/retention/01/scenario.exit)" == 0 ]]
    [[ "$(grep -c '^vm stop ' "${retention_calls}")" == 1 ]]
}

@test "retention initial raw endpoint distinguishes complete text from CLI success" {
    local helper="${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/retention-installed-before.sh"
    cat >bin/testanyware <<'SH'
#!/bin/bash
if [[ "$1 $2" == 'file exec' ]]; then
    jq -n --rawfile out "${fixture_evidence}/retention-bundle.txt" '{ok:true,exit_code:0,timed_out:false,stdout:$out}'
    exit "${endpoint_cli:-0}"
fi
SH
    chmod +x bin/testanyware
    export KOINE_K4_OUT="${BATS_TEST_TMPDIR}/endpoint"
    mkdir "${KOINE_K4_OUT}"
    cp "${fixture_evidence}/retention-bundle.txt" "${KOINE_K4_OUT}/expected-bundle.txt"
    run bash "${helper}" "${KOINE_K4_OUT}/expected-bundle.txt"
    [[ "${status}" == 0 ]]
    [[ "$(cat "${KOINE_K4_OUT}/installed-before-check.exit")" == 0 ]]
    export endpoint_cli=7
    run bash "${helper}" "${KOINE_K4_OUT}/expected-bundle.txt"
    [[ "${status}" == 0 ]]
    [[ "$(cat "${KOINE_K4_OUT}/installed-before-check.exit")" == 1 ]]
    [[ "$(cat "${KOINE_K4_OUT}/installed-before-cli.exit")" == 7 ]]
    jq -e '.ok == true and .exit_code == 0 and .timed_out == false' "${KOINE_K4_OUT}/installed-before-raw.json"
}
