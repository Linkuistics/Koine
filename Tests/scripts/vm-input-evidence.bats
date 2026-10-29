#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Each Bats test owns its environment.
# shellcheck disable=SC2016,SC2028 # Literal JSON fixtures retain dollar signs and escapes.

setup() {
    # Real facade/backend/store/jq; only the external CLI and sleeps are replaced.
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    if [[ "${KOINE_INPUT_BASELINE:-0}" == 1 ]]; then
        # Test-only equivalent of the prior bare input routes.
        # shellcheck disable=SC2329
        scenario_input() {
            shift
            testanyware input "$@"
        }
    else
        # shellcheck source=scripts/vm-input-evidence-lib.sh
        source "${BATS_TEST_DIRNAME}/../../scripts/vm-input-evidence-lib.sh"
    fi
    export input_root="${BATS_TEST_TMPDIR}/evidence"
    export input_calls="${BATS_TEST_TMPDIR}/calls"
    export input_replies="${BATS_TEST_TMPDIR}/replies"
    export input_waits="${BATS_TEST_TMPDIR}/waits"
    export KOINE_VM_EVIDENCE_ROOT="${input_root}"
    mkdir "${input_replies}" "${BATS_TEST_TMPDIR}/bin" "${BATS_TEST_TMPDIR}/cwd"
    : >"${input_calls}"
    : >"${input_waits}"
    cd "${BATS_TEST_TMPDIR}/cwd" || return
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
set -euo pipefail
jq -cn --args '$ARGS.positional' -- "$@" >>"${input_calls}"
n=$(wc -l <"${input_calls}" | tr -d ' ')
if [[ -f "${input_replies}/reply.json" ]]; then
    cat "${input_replies}/reply.json"
else
    # Independent literal complete payloads, not computed by the facade.
    case "$2" in
        key) echo '{"schema_version":"1.0","ok":true,"key":"g","modifiers":["cmd","shift"]}' ;;
        type) echo '{"schema_version":"1.0","ok":true,"text":"a😀é\n\"$()","chars":9}' ;;
        scroll) echo '{"schema_version":"1.0","ok":true,"x":280,"y":396,"dx":0,"dy":-10}' ;;
    esac
fi
printf 'input diagnostic %s\n' "${n}" >&2
if [[ -f "${input_replies}/int" ]]; then kill -INT "$PPID"; sleep 0.1; fi
if [[ -f "${input_replies}/exit" ]]; then exit "$(cat "${input_replies}/exit")"; fi
CLI
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    init_guest_evidence "${input_root}" exact-input-vm
}

reset_input() {
    input_root="${BATS_TEST_TMPDIR}/$1"
    export KOINE_VM_EVIDENCE_ROOT="${input_root}"
    init_guest_evidence "${input_root}" exact-input-vm
    : >"${input_calls}"
    rm -f "${input_replies}"/*
}

input_attempt() {
    case "$1" in
    key) scenario_input consent-go key g --modifiers cmd,shift ;;
    type) scenario_input shortcut-text type $'a😀é\n"$()' ;;
    scroll) scenario_input scroll-window scroll 280 396 --dy=-10 ;;
    esac
}

assert_input_latched() {
    local before
    before="$(wc -l <"${input_calls}")"
    run scenario_input forbidden key g --modifiers cmd,shift
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${input_calls}")" == "${before}" ]]
    [[ -s "${input_root}/unavailable" ]]
}

@test "key text and scroll preserve original bytes exact argv and shared ordinals" {
    input_attempt key >"${BATS_TEST_TMPDIR}/key"
    input_attempt type >"${BATS_TEST_TMPDIR}/text"
    input_attempt scroll >"${BATS_TEST_TMPDIR}/scroll"
    cmp "${BATS_TEST_TMPDIR}/key" "${input_root}/000001/raw.stdout"
    cmp "${BATS_TEST_TMPDIR}/text" "${input_root}/000002/raw.stdout"
    cmp "${BATS_TEST_TMPDIR}/scroll" "${input_root}/000003/raw.stdout"
    jq -se '. == [["input","key","g","--modifiers","cmd,shift","--vm","exact-input-vm","--json"],["input","type","a😀é\n\"$()","--vm","exact-input-vm","--json"],["input","scroll","280","396","--dy=-10","--vm","exact-input-vm","--json"]]' "${input_calls}"
    jq -se 'map(.operation) == ["consent-go","shortcut-text","scroll-window"] and all(.[]; .class == "one-shot" and .payload_predicate != "true")' "${input_root}"/*/request.json
    jq -se 'all(.[]; .outcome == "clean" and .cli_status == 0)' "${input_root}"/*/result.json
    grep -qx 'input diagnostic 2' "${input_root}/000002/raw.stderr"
}

@test "plain keys empty text and positive scroll use their actual complete payloads" {
    echo '{"schema_version":"1.0","ok":true,"key":"return","modifiers":[]}' >"${input_replies}/reply.json"
    scenario_input password-submit key return
    echo '{"schema_version":"1.0","ok":true,"text":"","chars":0}' >"${input_replies}/reply.json"
    scenario_input empty-text type ''
    echo '{"schema_version":"1.0","ok":true,"x":0,"y":65535,"dx":0,"dy":10}' >"${input_replies}/reply.json"
    scenario_input scroll-back scroll 0 65535 --dy=10
    jq -se 'length == 3 and all(.[]; .outcome == "clean")' "${input_root}"/*/result.json
    [[ ! -e "${input_root}/unavailable" ]]
}

@test "each family rejects nonzero partial typed error and dry-run completion without retry" {
    local action problem
    for action in key type scroll; do
        for problem in exit partial error dry-run; do
            reset_input "${action}-${problem}"
            case "${problem}" in
            exit) echo 7 >"${input_replies}/exit" ;;
            partial) echo '{"schema_version":' >"${input_replies}/reply.json" ;;
            error)
                echo '{"schema_version":"1.0","ok":false,"error":{"code":"CONNECTION_TIMEOUT"}}' >"${input_replies}/reply.json"
                echo 7 >"${input_replies}/exit"
                ;;
            dry-run) echo '{"schema_version":"1.0","ok":true,"dry_run":false,"key":"g","modifiers":["cmd","shift"],"text":"a😀é\n\"$()","chars":9,"x":280,"y":396,"dx":0,"dy":-10}' >"${input_replies}/reply.json" ;;
            esac
            run input_attempt "${action}"
            [[ "${status}" == 125 ]]
            [[ "$(wc -l <"${input_calls}" | tr -d ' ')" == 1 ]]
            assert_input_latched
        done
    done
}

@test "key payload must echo requested key and exact ordered modifier array" {
    local payload n=0
    for payload in '{"key":"a","modifiers":["cmd","shift"]}' '{"key":"g"}' \
        '{"key":"g","modifiers":"cmd,shift"}' '{"key":"g","modifiers":["shift","cmd"]}' \
        '{"key":"g","modifiers":["cmd"]}'; do
        n=$((n + 1))
        reset_input "key-schema-${n}"
        jq -c '. + {schema_version:"1.0",ok:true}' <<<"${payload}" >"${input_replies}/reply.json"
        run input_attempt key
        [[ "${status}" == 125 ]]
        assert_input_latched
    done
}

@test "type payload requires exact text and Unicode scalar count" {
    local payload n=0
    for payload in '{"text":"different","chars":9}' '{"text":"a😀é\n\"$()"}' \
        '{"text":"a😀é\n\"$()","chars":10}' '{"text":"a😀é\n\"$()","chars":"9"}'; do
        n=$((n + 1))
        reset_input "text-schema-${n}"
        jq -c '. + {schema_version:"1.0",ok:true}' <<<"${payload}" >"${input_replies}/reply.json"
        run input_attempt type
        [[ "${status}" == 125 ]]
        assert_input_latched
    done
}

@test "scroll payload must include exact x y dx and signed dy" {
    local change n=0
    for change in 'del(.x)' '.x=281' '.y="396"' 'del(.dx)' '.dx=1' 'del(.dy)' '.dy=10'; do
        n=$((n + 1))
        reset_input "scroll-schema-${n}"
        echo '{"schema_version":"1.0","ok":true,"x":280,"y":396,"dx":0,"dy":-10}' | jq "${change}" >"${input_replies}/reply.json"
        run input_attempt scroll
        [[ "${status}" == 125 ]]
        assert_input_latched
    done
}

@test "explicit empty missing and uninitialized roots never fall back or write cwd artifacts" {
    local root
    for root in '' "${BATS_TEST_TMPDIR}/missing" "${BATS_TEST_TMPDIR}/cwd"; do
        KOINE_VM_EVIDENCE_ROOT="${root}"
        run scenario_input invalid-root key g --modifiers cmd,shift
        [[ "${status}" == 125 ]]
        [[ "${output}" == *'initialized nonempty root'* ]]
        [[ ! -s "${input_calls}" ]]
        [[ ! -e unavailable && ! -e writer.lock && ! -e refusals.jsonl ]]
    done
}

@test "invalid action arguments refuse and latch before dispatch including under nounset" {
    local args n=0
    for args in 'operation key' 'operation type one two' 'operation key g --modifiers' \
        'operation key g --modifiers cmd,,shift' 'operation click 1 2' \
        'operation scroll' 'operation scroll -1 0 --dy=10' 'operation scroll 0 65536 --dy=10' \
        'operation scroll 0 0 --dy=2147483648' 'operation scroll 0 0 --dy=1.5' \
        'operation key --help' 'operation type --vm=other'; do
        n=$((n + 1))
        reset_input "arguments-${n}"
        # Deliberately split the fixed test vectors, not production input data.
        IFS=' ' read -r -a vector <<<"${args}"
        if [[ "${KOINE_INPUT_BASELINE:-0}" == 1 ]]; then
            export -f scenario_input
            run bash -u -c 'scenario_input "$@"' _ "${vector[@]}"
        else
            run bash -u -c 'source "$1"; shift; scenario_input "$@"' _ \
                "${BATS_TEST_DIRNAME}/../../scripts/vm-input-evidence-lib.sh" "${vector[@]}"
        fi
        [[ "${status}" == 125 ]]
        [[ ! -s "${input_calls}" ]]
        assert_input_latched
    done
}

@test "shared prior window or confirmation failure blocks every input family" {
    fail_guest_evidence "${input_root}" earlier 'existing failure' || :
    local action
    for action in key type scroll; do
        run input_attempt "${action}"
        [[ "${status}" == 125 ]]
        [[ ! -s "${input_calls}" ]]
    done
    grep -q 'existing failure' "${input_root}/unavailable"
}

@test "SIGINT in every input family retains interruption without later input" {
    local action
    for action in key type scroll; do
        reset_input "interrupt-${action}"
        touch "${input_replies}/int"
        run input_attempt "${action}"
        [[ "${status}" == 130 ]]
        jq -e '.outcome == "interrupted"' "${input_root}/000001/result.json"
        assert_input_latched
    done
}

@test "unset root preserves existing bare input argv and nonzero status" {
    unset KOINE_VM_EVIDENCE_ROOT
    scenario_input legacy-key key g --modifiers cmd,shift
    scenario_input legacy-text type $'a😀é\n"$()'
    scenario_input legacy-scroll scroll 280 396 --dy=-10
    jq -se '. == [["input","key","g","--modifiers","cmd,shift"],["input","type","a😀é\n\"$()"],["input","scroll","280","396","--dy=-10"]]' "${input_calls}"
    echo 7 >"${input_replies}/exit"
    run scenario_input legacy-failure key return
    [[ "${status}" == 7 ]]
    [[ ! -e "${input_root}/000001" ]]
}

load_caller() {
    # Read real functions without sourcing VM startup/log/trap side effects.
    eval "$(awk -v name="$1" '$0 ~ "^"name"\\(\\)" {selected=1} selected {print} selected && /^}/ {selected=0}' "${BATS_TEST_DIRNAME}/../../scripts/$2")"
}

@test "consumed scroll and menu helpers stop before settling sleep even with errexit suppressed" {
    load_caller scroll_by vm-verify-lib.sh
    load_caller read_menu vm-verify-lib.sh
    FRAME_X=40 FRAME_Y=40 FRAME_W=480 FRAME_H=712
    # shellcheck disable=SC2329
    open_menu() { :; }
    # shellcheck disable=SC2329
    menu_titles() { echo 'Settings…, Quit Koine'; }
    # shellcheck disable=SC2329
    sleep() { echo "$*" >>"${input_waits}"; }
    echo 7 >"${input_replies}/exit"
    if scroll_by -10; then return 1; else [[ "$?" == 125 ]]; fi
    [[ ! -s "${input_waits}" ]]
    reset_input menu-stop
    echo 7 >"${input_replies}/exit"
    if read_menu; then return 1; else [[ "$?" == 125 ]]; fi
    [[ ! -s "${input_waits}" ]]
    [[ "$(wc -l <"${input_calls}" | tr -d ' ')" == 1 ]]
}

@test "actual scroll callers propagate failed input before another read or pointer action" {
    local name
    for name in scroll_by calibrate_window_scroll reveal reveal_click click; do
        load_caller "${name}" vm-verify-lib.sh
    done
    export FRAME_X=40 FRAME_Y=40 FRAME_W=480 FRAME_H=712 BOTTOM=752 SCROLL_END=-10 TITLE_BAR=30
    # Only read-only UI dependencies are supplied; production scroll and callers stay real.
    # shellcheck disable=SC2329
    read_frame() { :; }
    # shellcheck disable=SC2329
    element() { echo '{"positionY":800}'; }
    # shellcheck disable=SC2329
    on_screen() { return 1; }
    # shellcheck disable=SC2329
    sleep() { echo "$*" >>"${input_waits}"; }
    for name in calibrate_window_scroll reveal reveal_click click; do
        reset_input "caller-${name}"
        echo 7 >"${input_replies}/exit"
        if "${name}" '.id=="grant-label"'; then return 1; else [[ "$?" == 125 ]]; fi
        [[ ! -s "${input_waits}" ]]
        [[ "$(wc -l <"${input_calls}" | tr -d ' ')" == 1 ]]
        assert_input_latched
    done
}

@test "actual consent sequence stops after failed text before key or later settling" {
    load_caller grant_accessibility vm-verify-desktop-lib.sh
    export VM_PASSWORD=admin INSTALLED=/Applications/Koine.app
    # Preceding UI/setup steps are not the subject of this input boundary check.
    # shellcheck disable=SC2329
    guest() { :; }
    # shellcheck disable=SC2329
    element() { echo '{}'; }
    # shellcheck disable=SC2329
    click() { :; }
    # shellcheck disable=SC2329
    sleep() { echo "$*" >>"${input_waits}"; }
    echo 7 >"${input_replies}/exit"
    if grant_accessibility; then return 1; else [[ "$?" == 125 ]]; fi
    [[ "$(cat "${input_waits}")" == 2 ]]
    [[ "$(wc -l <"${input_calls}" | tr -d ' ')" == 1 ]]
    jq -e '.operation == "consent-password"' "${input_root}/000001/request.json"
}
