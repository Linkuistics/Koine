#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Each Bats test owns its environment.

setup() {
    # Only the external CLI and fixed settling sleeps are substituted. The
    # production facade, shared Python adapter, jq and receipt store stay real.
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    # shellcheck disable=SC2329 # Bats invokes these baseline definitions.
    if [[ "${KOINE_WINDOW_BASELINE:-0}" == 1 ]]; then
        # Execute the existing legacy list/action routes, and the actual legacy
        # count poll extracted without sourcing its VM/log startup side effects.
        # These deliberately have no strict receipts or payload checks.
        read_guest_windows() { testanyware agent windows --json; }
        act_guest_window() {
            local action="$3" window="$4"
            if [[ "${action}" == window-move ]]; then
                testanyware agent "${action}" --window "${window}" --x "$5" --y "$6"
            else
                testanyware agent "${action}" --window "${window}"
            fi
        }
        eval "$(awk '/^koine_windows\(\)|^await_windows\(\)/ {selected=1} selected {print} selected && /^}/ {selected=0}' "${BATS_TEST_DIRNAME}/../../scripts/vm-verify-lib.sh")"
        await_guest_window_count() {
            export APP_NAME="$3"
            await_windows "$4"
        }
        await_guest_textedit_window() { testanyware agent windows --json; }
    else
        # shellcheck source=scripts/vm-window-evidence-lib.sh
        source "${BATS_TEST_DIRNAME}/../../scripts/vm-window-evidence-lib.sh"
    fi
    export window_root="${BATS_TEST_TMPDIR}/evidence"
    export window_calls="${BATS_TEST_TMPDIR}/calls"
    export window_waits="${BATS_TEST_TMPDIR}/waits"
    export window_replies="${BATS_TEST_TMPDIR}/replies"
    mkdir "${window_replies}" "${BATS_TEST_TMPDIR}/bin" "${BATS_TEST_TMPDIR}/cwd"
    cd "${BATS_TEST_TMPDIR}/cwd" || return
    : >"${window_calls}"
    : >"${window_waits}"
    # shellcheck disable=SC2329 # Invoked by production poll functions.
    sleep() { echo "$*" >>"${window_waits}"; }
    # shellcheck disable=SC2329 # Invoked only by the legacy baseline poll.
    fail() {
        echo "legacy state failure: $*" >&2
        return 1
    }
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
set -euo pipefail
jq -cn --args '$ARGS.positional' -- "$@" >>"${window_calls}"
n=$(wc -l <"${window_calls}" | tr -d ' ')
if [[ -f "${window_replies}/${n}.json" ]]; then
    cat "${window_replies}/${n}.json"
elif [[ "$1 $2" == 'agent windows' ]]; then
    echo '{"schema_version":"1.0","ok":true,"windows":[]}'
else
    jq -cn --arg action "$2" '{schema_version:"1.0",ok:true,action:$action,success:true,message:null}'
fi
echo "window diagnostic $n" >&2
if [[ -f "${window_replies}/${n}.int" ]]; then kill -INT "$PPID"; sleep 0.1; fi
if [[ -f "${window_replies}/${n}.exit" ]]; then exit "$(cat "${window_replies}/${n}.exit")"; fi
CLI
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    init_guest_evidence "${window_root}" exact-window-vm
}

reset_windows() {
    window_root="${BATS_TEST_TMPDIR}/$1"
    init_guest_evidence "${window_root}" exact-window-vm
    : >"${window_calls}"
    : >"${window_waits}"
    rm -f "${window_replies}"/*
}

window_fixture() {
    # Full independently specified WindowInfo, with a second app and an absent
    # optional title. Counts must not silently add title/focus requirements.
    echo '{"schema_version":"1.0","ok":true,"windows":[{"appName":"TextEdit","title":"Untitled","windowType":"standard","focused":true,"positionX":700,"positionY":120,"sizeWidth":600,"sizeHeight":500},{"appName":"Koine","windowType":"standard","focused":false,"positionX":40,"positionY":40,"sizeWidth":480,"sizeHeight":712}]}'
}

assert_window_latched() {
    local before
    before="$(wc -l <"${window_calls}")"
    run act_guest_window "${window_root}" later-close window-close 'Koine Settings'
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${window_calls}")" == "${before}" ]]
    [[ -s "${window_root}/unavailable" ]]
}

@test "window list emits the original full envelope and pins VM and ordinal" {
    window_fixture >"${window_replies}/1.json"
    read_guest_windows "${window_root}" read-poll original-count >"${BATS_TEST_TMPDIR}/actual"
    cmp "${window_replies}/1.json" "${BATS_TEST_TMPDIR}/actual"
    cmp "${window_replies}/1.json" "${window_root}/000001/raw.stdout"
    jq -se '. == [["agent","windows","--vm","exact-window-vm","--json"]]' "${window_calls}"
    jq -e '.ordinal == 1 and .vm == "exact-window-vm" and .class == "read-poll" and .operation == "original-count" and .payload_predicate != "true"' "${window_root}/000001/request.json"
    grep -qx 'window diagnostic 1' "${window_root}/000001/raw.stderr"
    jq -e '.outcome == "clean" and .cli_status == 0' "${window_root}/000001/result.json"
}

@test "only clean list negatives advance the ten by two count poll" {
    window_fixture >"${window_replies}/3.json"
    await_guest_window_count "${window_root}" reopen Koine 1 >"${BATS_TEST_TMPDIR}/actual"
    cmp "${window_replies}/3.json" "${BATS_TEST_TMPDIR}/actual"
    [[ "$(cat "${window_waits}")" == $'2\n2' ]]
    [[ "$(wc -l <"${window_calls}" | tr -d ' ')" == 3 ]]
    jq -e '.outcome == "clean"' "${window_root}/000001/result.json" "${window_root}/000002/result.json"
    [[ ! -e "${window_root}/unavailable" ]]
}

@test "zero expected windows is clean data without title or focus strengthening" {
    run await_guest_window_count "${window_root}" closed Koine 0
    [[ "${status}" == 0 ]]
    jq -e '.windows == []' <<<"${output}"
    [[ ! -s "${window_waits}" ]]
    reset_windows count-only
    window_fixture >"${window_replies}/1.json"
    run await_guest_window_count "${window_root}" count-only Koine 1
    [[ "${status}" == 0 ]]
    [[ ! -s "${window_waits}" ]]
    jq -e '.windows[1].focused == false and (.windows[1] | has("title") | not)' <<<"${output}"
}

@test "TextEdit poll retains fifteen by two and returns its original successful list" {
    window_fixture >"${window_replies}/15.json"
    await_guest_textedit_window "${window_root}" prepare >"${BATS_TEST_TMPDIR}/actual"
    cmp "${window_replies}/15.json" "${BATS_TEST_TMPDIR}/actual"
    [[ "$(wc -l <"${window_calls}" | tr -d ' ')" == 15 ]]
    [[ "$(wc -l <"${window_waits}" | tr -d ' ')" == 14 ]]
    [[ "$(sort -u "${window_waits}")" == 2 ]]
}

@test "clean exhausted polls retain each list and a separate state confirmation" {
    local kind limit
    for kind in koine textedit; do
        reset_windows "exhaust-${kind}"
        if [[ "${kind}" == koine ]]; then
            run await_guest_window_count "${window_root}" missing Koine 1
            limit=10
        else
            run await_guest_textedit_window "${window_root}" missing
            limit=15
        fi
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${window_calls}" | tr -d ' ')" == "${limit}" ]]
        [[ "$(wc -l <"${window_waits}" | tr -d ' ')" == "${limit}" ]]
        jq -se --argjson n "${limit}" 'length == $n + 1 and all(.[0:$n][]; .outcome == "clean") and .[$n].outcome == "unavailable"' "${window_root}"/*/result.json
        jq -se '.[-1].transport == "confirmation" and .[-1].operation == "missing-exhausted" and (.[-1].reason | contains("clean window poll exhausted"))' "${window_root}"/*/request.json
        assert_window_latched
    done
}

@test "failed poll stops immediately despite matching text with no retry or input" {
    local problem
    for problem in exit partial missing-schema false-ok duplicate typed-error; do
        reset_windows "failed-${problem}"
        window_fixture >"${window_replies}/2.json"
        case "${problem}" in
        exit) echo 7 >"${window_replies}/2.exit" ;;
        partial) echo '{"schema_version":' >"${window_replies}/2.json" ;;
        missing-schema) echo '{"ok":true,"windows":[]}' >"${window_replies}/2.json" ;;
        false-ok) echo '{"schema_version":"1.0","ok":false,"windows":[]}' >"${window_replies}/2.json" ;;
        duplicate) echo '{"schema_version":"1.0","ok":true,"windows":[],"windows":[]}' >"${window_replies}/2.json" ;;
        typed-error)
            echo '{"schema_version":"1.0","ok":false,"error":{"code":"WINDOW_NOT_FOUND"}}' >"${window_replies}/2.json"
            echo 3 >"${window_replies}/2.exit"
            ;;
        esac
        if await_guest_window_count "${window_root}" reopen Koine 1; then return 1; fi
        [[ "$(wc -l <"${window_calls}" | tr -d ' ')" == 2 ]]
        [[ "$(cat "${window_waits}")" == 2 ]]
        cmp "${window_replies}/2.json" "${window_root}/000002/raw.stdout"
        assert_window_latched
    done
}

@test "window schemas reject incomplete arrays and malformed required or optional fields" {
    local mutation n=0
    for mutation in 'del(.windows)' '.windows=null' '.windows={}' '.windows=[null]' \
        'del(.windows[0].appName)' '.windows[0].appName=2' 'del(.windows[0].windowType)' \
        '.windows[0].focused="true"' 'del(.windows[0].focused)' 'del(.windows[0].positionX)' \
        '.windows[0].positionY="120"' '.windows[0].sizeWidth=null' 'del(.windows[0].sizeHeight)' \
        '.windows[1].title=null' '.windows[1].title=3' '.windows[1].elements={}'; do
        n=$((n + 1))
        reset_windows "schema-${n}"
        window_fixture | jq "${mutation}" >"${window_replies}/1.json"
        run read_guest_windows "${window_root}" read-poll schema
        [[ "${status}" == 125 ]]
        assert_window_latched
    done
}

@test "window actions require matching actual receipt without invented target echo" {
    act_guest_window "${window_root}" move-textedit window-move TextEdit 700 120
    act_guest_window "${window_root}" focus-resize window-focus 'Koine Settings'
    act_guest_window "${window_root}" close-settings window-close 'Koine Settings'
    jq -se '. == [["agent","window-move","--window","TextEdit","--x","700","--y","120","--vm","exact-window-vm","--json"],["agent","window-focus","--window","Koine Settings","--vm","exact-window-vm","--json"],["agent","window-close","--window","Koine Settings","--vm","exact-window-vm","--json"]]' "${window_calls}"
    jq -se 'all(.[]; .class == "one-shot" and .payload_predicate != "true")' "${window_root}"/*/request.json
    jq -se 'all(.[]; .outcome == "clean")' "${window_root}"/*/result.json
}

@test "every window action rejects failed nonzero partial and mismatching completions" {
    local action problem
    for action in window-move window-focus window-close; do
        for problem in exit partial wrong-action failed-success missing-success wrong-message; do
            reset_windows "${action}-${problem}"
            jq -cn --arg action "${action}" '{schema_version:"1.0",ok:true,action:$action,success:true,message:"completed"}' >"${window_replies}/1.json"
            case "${problem}" in
            exit) echo 7 >"${window_replies}/1.exit" ;;
            partial) echo '{"schema_version":' >"${window_replies}/1.json" ;;
            wrong-action) echo '{"schema_version":"1.0","ok":true,"action":"window-resize","success":true,"message":null}' >"${window_replies}/1.json" ;;
            failed-success) jq -cn --arg action "${action}" '{schema_version:"1.0",ok:true,action:$action,success:false,message:null}' >"${window_replies}/1.json" ;;
            missing-success) jq -cn --arg action "${action}" '{schema_version:"1.0",ok:true,action:$action,message:null}' >"${window_replies}/1.json" ;;
            wrong-message) jq -cn --arg action "${action}" '{schema_version:"1.0",ok:true,action:$action,success:true,message:4}' >"${window_replies}/1.json" ;;
            esac
            if [[ "${action}" == window-move ]]; then
                run act_guest_window "${window_root}" action "${action}" TextEdit 700 120
            else
                run act_guest_window "${window_root}" action "${action}" 'Koine Settings'
            fi
            [[ "${status}" == 125 ]]
            [[ "$(wc -l <"${window_calls}" | tr -d ' ')" == 1 ]]
            assert_window_latched
        done
    done
}

@test "collection preserves a prior failure and cannot restore input eligibility" {
    fail_guest_evidence "${window_root}" earlier 'existing failure' || :
    read_guest_windows "${window_root}" evidence untouched >"${BATS_TEST_TMPDIR}/actual"
    jq -e '.windows == []' "${BATS_TEST_TMPDIR}/actual"
    jq -e '.class == "evidence"' "${window_root}/000002/request.json"
    assert_window_latched
}

@test "empty absent and uninitialized roots cause no CLI or cwd artifacts" {
    local root
    mkdir "${BATS_TEST_TMPDIR}/uninitialized"
    for root in '' "${BATS_TEST_TMPDIR}/absent" "${BATS_TEST_TMPDIR}/uninitialized"; do
        run read_guest_windows "${root}" read-poll invalid
        [[ "${status}" == 125 ]]
        run act_guest_window "${root}" invalid window-close 'Koine Settings'
        [[ "${status}" == 125 ]]
    done
    [[ ! -s "${window_calls}" ]]
    [[ -z "$(ls -A .)" ]]
    [[ -z "$(ls -A "${BATS_TEST_TMPDIR}/uninitialized")" ]]
}

@test "invalid arguments latch and cannot dispatch scenario input" {
    local invalid n=0
    for invalid in action class count app; do
        n=$((n + 1))
        reset_windows "invalid-${n}"
        case "${invalid}" in
        action) run act_guest_window "${window_root}" invalid window-resize 'Koine Settings' ;;
        class) run read_guest_windows "${window_root}" one-shot invalid ;;
        count) run await_guest_window_count "${window_root}" invalid Koine -1 ;;
        app) run await_guest_window_count "${window_root}" invalid '' 1 ;;
        esac
        [[ "${status}" == 125 ]]
        [[ ! -s "${window_calls}" ]]
        assert_window_latched
    done
}

@test "adapter SIGINT propagates distinctly and stops the poll before sleep or release" {
    touch "${window_replies}/1.int"
    window_fixture >"${window_replies}/1.json"
    run await_guest_window_count "${window_root}" interrupted Koine 1
    [[ "${status}" == 130 ]]
    [[ ! -s "${window_waits}" ]]
    [[ "$(wc -l <"${window_calls}" | tr -d ' ')" == 1 ]]
    jq -e '.outcome == "interrupted"' "${window_root}/000001/result.json"
    assert_window_latched
}

@test "missing helper arguments under nounset latch an initialized root" {
    local helper
    for helper in read_guest_windows act_guest_window await_guest_window_count await_guest_textedit_window; do
        reset_windows "missing-${helper}"
        run bash -u -c 'source "$1"; "$2" "$3"' _ \
            "${BATS_TEST_DIRNAME}/../../scripts/vm-window-evidence-lib.sh" "${helper}" "${window_root}"
        [[ "${status}" == 125 ]]
        [[ ! -s "${window_calls}" ]]
        assert_window_latched
    done
}
