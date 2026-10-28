#!/usr/bin/env bats

setup() {
    export KOINE_K4_OUT="${BATS_TEST_TMPDIR}/out" events_calls="${BATS_TEST_TMPDIR}/calls"
    mkdir -p "${KOINE_K4_OUT}" "${BATS_TEST_TMPDIR}/bin"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${events_calls}"
printf '%s\n' "${events_reply}"
exit "${events_status:-0}"
SH
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export events_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"KOINE_EVENTS_ENABLED","stderr":""}'
    script="${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/events-transport.sh"
}

@test "events enable accepts a clean normalized transport and retains it" {
    run bash "${script}" enable
    [[ "${status}" == 0 ]]
    [[ "$(cat "${KOINE_K4_OUT}/events-enable.json")" == "${events_reply}" ]]
    [[ "$(wc -l <"${events_calls}" | tr -d ' ')" == 1 ]]
}

@test "events never accept a timeout, guest failure or transport failure as enable success" {
    for reply in \
        '{"ok":true,"exit_code":0,"timed_out":true,"stdout":"KOINE_EVENTS_ENABLED","stderr":""}' \
        '{"ok":true,"exit_code":1,"timed_out":false,"stdout":"KOINE_EVENTS_ENABLED","stderr":""}' \
        '{"ok":false,"exit_code":0,"timed_out":false,"stdout":"KOINE_EVENTS_ENABLED","stderr":""}'; do
        export events_reply="${reply}"
        run bash "${script}" enable
        [[ "${status}" != 0 ]]
    done
    [[ "$(wc -l <"${events_calls}" | tr -d ' ')" == 3 ]]
}

@test "events reject a wrong enable marker and preserve nonzero CLI failure without replay" {
    export events_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"wrong","stderr":""}'
    run bash "${script}" enable
    [[ "${status}" != 0 ]]
    export events_status=1 events_reply='{"ok":true,"exit_code":0,"timed_out":false,"stdout":"KOINE_EVENTS_ENABLED","stderr":""}'
    run bash "${script}" enable
    [[ "${status}" != 0 ]]
    [[ "$(cat "${KOINE_K4_OUT}/events-enable.json")" == "${events_reply}" ]]
    [[ "$(wc -l <"${events_calls}" | tr -d ' ')" == 2 ]]
}

dump_reply() {
    export events_reply
    events_reply="$(jq -nc --arg out "$1" '{ok:true,exit_code:0,timed_out:false,stdout:$out,stderr:""}')"
}

@test "events dump retains complete JSON and rejects loss or missing call boundaries" {
    local snapshot
    snapshot='{"format":"koine-settings-events/1","capacity":4096,"dropped":0,"records":[{"sequence":1,"selection":0,"event":"buffer.started"},{"sequence":2,"selection":1,"event":"callback.settings"},{"sequence":3,"selection":1,"event":"show.enter"},{"sequence":4,"selection":1,"event":"window.makeKeyAndOrderFront.before"},{"sequence":5,"selection":1,"event":"window.makeKeyAndOrderFront.after"},{"sequence":6,"selection":1,"event":"application.activate.before"},{"sequence":7,"selection":1,"event":"application.activate.after"},{"sequence":8,"selection":1,"event":"buffer.dump"}]}'
    dump_reply "${snapshot}"
    run bash "${script}" dump
    [[ "${status}" == 0 ]]
    [[ "$(cat "${KOINE_K4_OUT}/events.json")" == "${snapshot}" ]]
    dump_reply "$(jq '.dropped=1' <<<"${snapshot}")"
    run bash "${script}" dump
    [[ "${status}" != 0 ]]
    dump_reply "$(jq 'del(.records[5])' <<<"${snapshot}")"
    run bash "${script}" dump
    [[ "${status}" != 0 ]]
}

@test "events dump rejects empty output and timeout even with returned JSON" {
    dump_reply ''
    run bash "${script}" dump
    [[ "${status}" != 0 ]]
    export events_reply='{"ok":true,"exit_code":0,"timed_out":true,"stdout":"{}","stderr":""}'
    run bash "${script}" dump
    [[ "${status}" != 0 ]]
    [[ "$(wc -l <"${events_calls}" | tr -d ' ')" == 2 ]]
}

@test "events dump retains a chmod failure from its actual guest command" {
    chmod() { echo 'chmod refused' >&2; return 1; }
    export -f chmod
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'SH'
#!/bin/bash
bash -c "$4" >"${KOINE_K4_OUT}/guest-out" 2>"${KOINE_K4_OUT}/guest-err"
result=$?
jq -n --argjson result "$result" --rawfile out "${KOINE_K4_OUT}/guest-out" --rawfile err "${KOINE_K4_OUT}/guest-err" \
    '{ok:true,exit_code:$result,timed_out:false,stdout:$out,stderr:$err}'
SH
    run bash "${script}" dump
    [[ "${status}" != 0 ]]
    jq -e '.exit_code == 1 and .stderr == "chmod refused\n"' "${KOINE_K4_OUT}/events-dump.json"
}
