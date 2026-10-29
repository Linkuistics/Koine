#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Each test owns its environment.

setup() {
    bats_require_minimum_version 1.5.0
    # Real adapter, jq and store; substitute only the external CLI and sleeps.
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    if [[ "${KOINE_UI_BASELINE:-0}" == 1 ]]; then
        # Test-only wrappers for the old bare snapshot and first-match projection.
        # shellcheck disable=SC2329
        read_guest_snapshot() { testanyware agent snapshot --mode full --window "$4" --depth 14 --json; }
        # shellcheck disable=SC2329
        read_guest_element() {
            read_guest_snapshot "$1" read-poll "$2" "$3" |
                jq -c "[.. | objects | select(has(\"platformRole\")) | select($4)][0]"
        }
        eval "$(awk '/^await_element\(\)/ {selected=1} selected {print} selected && /^}/ {selected=0}' "${BATS_TEST_DIRNAME}/../../scripts/vm-verify-lib.sh")"
        # shellcheck disable=SC2329
        element() { read_guest_element "${ui_root}" legacy Koine "$1" optional; }
        # shellcheck disable=SC2329
        fail() {
            echo "legacy failure: $*" >&2
            return 1
        }
        # shellcheck disable=SC2329
        await_guest_element() { await_element "$4" "$5"; }
    else
        # shellcheck source=scripts/vm-ui-evidence-lib.sh
        source "${BATS_TEST_DIRNAME}/../../scripts/vm-ui-evidence-lib.sh"
    fi
    export ui_root="${BATS_TEST_TMPDIR}/evidence"
    export ui_calls="${BATS_TEST_TMPDIR}/calls"
    export ui_waits="${BATS_TEST_TMPDIR}/waits"
    export ui_replies="${BATS_TEST_TMPDIR}/replies"
    mkdir "${ui_replies}" "${BATS_TEST_TMPDIR}/bin" "${BATS_TEST_TMPDIR}/cwd"
    : >"${ui_calls}"
    : >"${ui_waits}"
    cd "${BATS_TEST_TMPDIR}/cwd" || return
    # shellcheck disable=SC2329
    sleep() {
        echo "$*" >>"${ui_waits}"
        return "${ui_sleep_status:-0}"
    }
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
set -euo pipefail
jq -cn --args '$ARGS.positional' -- "$@" >>"${ui_calls}"
n=$(wc -l <"${ui_calls}" | tr -d ' ')
if [[ -f "${ui_replies}/${n}.json" ]]; then
    cat "${ui_replies}/${n}.json"
else
    echo '{"schema_version":"1.0","ok":true,"windows":[]}'
fi
echo "snapshot diagnostic $n" >&2
if [[ -f "${ui_replies}/${n}.int" ]]; then kill -INT "$PPID"; sleep 0.1; fi
if [[ -f "${ui_replies}/${n}.exit" ]]; then exit "$(cat "${ui_replies}/${n}.exit")"; fi
CLI
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    init_guest_evidence "${ui_root}" exact-ui-vm
}

ui_fixture() {
    # Independent complete payload, including an ancestor without platformRole.
    echo '{"schema_version":"1.0","ok":true,"windows":[{"appName":"Koine","title":"Koine Settings","windowType":"standard","focused":true,"positionX":40,"positionY":40,"sizeWidth":480,"sizeHeight":712,"elements":[{"role":"group","enabled":true,"focused":false,"childCount":1,"actions":[],"children":[{"role":"textfield","platformRole":"AXTextField","id":"grant-label","value":"","enabled":true,"focused":true,"childCount":0,"actions":[],"positionX":60,"positionY":100,"sizeWidth":200,"sizeHeight":24}]}]}]}'
}

reset_ui() {
    ui_root="${BATS_TEST_TMPDIR}/$1"
    init_guest_evidence "${ui_root}" exact-ui-vm
    : >"${ui_calls}"
    : >"${ui_waits}"
    rm -f "${ui_replies}"/*
}

assert_ui_latched() {
    local before
    before="$(wc -l <"${ui_calls}")"
    run cli_guest_evidence "${ui_root}" one-shot later '.key == "return" and .modifiers == []' -- input key return
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${ui_calls}")" == "${before}" ]]
    [[ -s "${ui_root}/unavailable" ]]
}

@test "snapshot retains original bytes full tree exact argv VM and shared ordinals" {
    ui_fixture >"${ui_replies}/1.json"
    read_guest_snapshot "${ui_root}" read-poll original 'Koine Settings' >"${BATS_TEST_TMPDIR}/actual"
    cmp "${ui_replies}/1.json" "${BATS_TEST_TMPDIR}/actual"
    cmp "${ui_replies}/1.json" "${ui_root}/000001/raw.stdout"
    jq -se '. == [["agent","snapshot","--mode","full","--window","Koine Settings","--depth","14","--vm","exact-ui-vm","--json"]]' "${ui_calls}"
    jq -e '.vm == "exact-ui-vm" and .operation == "original" and .class == "read-poll" and .payload_predicate != "true"' "${ui_root}/000001/request.json"
    grep -qx 'snapshot diagnostic 1' "${ui_root}/000001/raw.stderr"
    ui_fixture >"${ui_replies}/2.json"
    read_guest_element "${ui_root}" field Koine '.id=="grant-label"' value >"${BATS_TEST_TMPDIR}/element"
    jq -e '.id == "grant-label" and .value == ""' "${BATS_TEST_TMPDIR}/element"
    jq -se 'map(.ordinal) == [1,2]' "${ui_root}"/*/request.json
}

@test "clean empty windows and empty element lists are optional negatives" {
    run --separate-stderr read_guest_element "${ui_root}" absent Koine '.id=="grant-label"' optional
    [[ "${status}" == 0 && "${output}" == null ]]
    ui_fixture | jq '.windows[0].elements=[]' >"${ui_replies}/2.json"
    run --separate-stderr read_guest_element "${ui_root}" absent-tree Koine '.id=="grant-label"' optional
    [[ "${status}" == 0 && "${output}" == null ]]
    jq -se 'length == 2 and all(.[]; .outcome == "clean")' "${ui_root}"/*/result.json
    [[ ! -e "${ui_root}/unavailable" ]]
}

@test "nonzero partial typed error and dry run never become absence or retry" {
    local problem
    for problem in exit partial error dry-run; do
        reset_ui "failure-${problem}"
        case "${problem}" in
        exit) echo 7 >"${ui_replies}/1.exit" ;;
        partial) echo '{"schema_version":' >"${ui_replies}/1.json" ;;
        error) echo '{"schema_version":"1.0","ok":false,"error":{"code":"WINDOW_NOT_FOUND"}}' >"${ui_replies}/1.json" ;;
        dry-run) echo '{"schema_version":"1.0","ok":true,"dry_run":false,"windows":[]}' >"${ui_replies}/1.json" ;;
        esac
        run await_guest_element "${ui_root}" absent Koine '.id=="grant-label"' absent
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 1 ]]
        [[ ! -s "${ui_waits}" ]]
        assert_ui_latched
    done
}

@test "snapshot validates every window and recursive element before a negative" {
    local change n=0
    for change in 'del(.windows)' '.windows={}' 'del(.windows[0].focused)' \
        '.windows[0].positionX="40"' 'del(.windows[0].elements)' \
        '.windows[0].elements[0].children={}' \
        '.windows[0].elements[0].children[0].value=0' \
        'del(.windows[0].elements[0].children[0].enabled)' \
        '.windows[0].elements[0].childCount=1.5' '.windows[0].elements[0].actions=[1]' \
        '.windows[0].elements[0].children[0].positionY=null'; do
        n=$((n + 1))
        reset_ui "schema-${n}"
        ui_fixture | jq "${change}" >"${ui_replies}/1.json"
        run read_guest_element "${ui_root}" schema Koine '.id=="not-present"' optional
        [[ "${status}" == 125 ]]
        assert_ui_latched
    done
}

@test "selected value geometry and height require actual consumed attributes" {
    local requirement change n=0
    for requirement in value geometry height; do
        for change in missing null; do
            n=$((n + 1))
            reset_ui "attribute-${n}"
            case "${requirement}" in value) field=value ;; *) field=sizeHeight ;; esac
            if [[ "${change}" == missing ]]; then
                ui_fixture | jq --arg field "${field}" 'del(.windows[0].elements[0].children[0][$field])' >"${ui_replies}/1.json"
            else
                ui_fixture | jq --arg field "${field}" '.windows[0].elements[0].children[0][$field]=null' >"${ui_replies}/1.json"
            fi
            run read_guest_element "${ui_root}" required Koine '.id=="grant-label"' "${requirement}"
            [[ "${status}" == 125 ]]
            assert_ui_latched
        done
    done
    reset_ui required-absence
    run read_guest_element "${ui_root}" required Koine '.id=="grant-label"' value
    [[ "${status}" == 125 ]]
    assert_ui_latched
}

@test "geometry and height accept actual attributes without requiring a text value" {
    ui_fixture | jq 'del(.windows[0].elements[0].children[0].value)' >"${ui_replies}/1.json"
    run --separate-stderr read_guest_element "${ui_root}" clickable Koine '.id=="grant-label"' geometry
    [[ "${status}" == 0 ]]
    jq -e '.positionX==60 and .sizeWidth==200 and (has("value")|not)' <<<"${output}"
    ui_fixture | jq '.windows[0].elements[0].children[0].sizeHeight=0' >"${ui_replies}/2.json"
    run --separate-stderr read_guest_element "${ui_root}" content Koine '.platformRole=="AXTextField"' height
    [[ "${status}" == 0 ]]
    jq -e '.sizeHeight==0' <<<"${output}"
    ui_fixture | jq '.windows[0].elements[0].children[0].sizeWidth=0' >"${ui_replies}/3.json"
    run read_guest_element "${ui_root}" unclickable Koine '.id=="grant-label"' geometry
    [[ "${status}" == 125 ]]
    assert_ui_latched
}

@test "clean negatives alone advance presence polls and retain state predicates" {
    ui_fixture >"${ui_replies}/3.json"
    run await_guest_element "${ui_root}" present Koine '.id=="grant-label"' present
    [[ "${status}" == 0 ]]
    [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 3 ]]
    [[ "$(cat "${ui_waits}")" == $'2\n2' ]]
    jq -se 'map(select(.transport=="poll-step") | .local_status) == [1,1,0] and all(.[] | select(.transport=="poll-step"); .poll_phase=="state" and (.state_predicate | contains("grant-label")))' "${ui_root}"/*/request.json
    [[ ! -e "${ui_root}/unavailable" ]]
}

@test "clean absence poll succeeds without input or sleep" {
    run await_guest_element "${ui_root}" absent Koine '.id=="grant-label"' absent
    [[ "${status}" == 0 ]]
    [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 1 ]]
    [[ ! -s "${ui_waits}" ]]
    jq -e '.poll_phase=="state" and .local_status==0' "${ui_root}/000002/request.json"
}

@test "ten clean negatives retain the final sleep and distinct state exhaustion" {
    run await_guest_element "${ui_root}" exhausted Koine '.id=="grant-label"' present
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 10 ]]
    [[ "$(wc -l <"${ui_waits}" | tr -d ' ')" == 10 ]]
    [[ "$(sort -u "${ui_waits}")" == 2 ]]
    jq -e '.transport=="poll-step" and .poll_phase=="exhausted" and .local_status==1' "${ui_root}/000021/request.json"
    jq -e '.outcome=="state-failed"' "${ui_root}/000021/result.json"
    assert_ui_latched
}

@test "invalid selectors and multiple-result selectors latch before another read" {
    local selector n=0
    for selector in '.id ==' 'error("decode failed")' 'true,false'; do
        n=$((n + 1))
        reset_ui "selector-${n}"
        ui_fixture >"${ui_replies}/1.json"
        run read_guest_element "${ui_root}" invalid Koine "${selector}" optional
        [[ "${status}" == 125 ]]
        assert_ui_latched
    done
}

@test "invalid roots and arguments refuse without CLI or cwd writes" {
    local root
    for root in '' "${BATS_TEST_TMPDIR}/missing" "${BATS_TEST_TMPDIR}/cwd"; do
        run read_guest_snapshot "${root}" read-poll invalid Koine
        [[ "${status}" == 125 ]]
        [[ ! -s "${ui_calls}" ]]
        [[ ! -e unavailable && ! -e .writer && ! -e refusals.jsonl && ! -e subject.json ]]
    done
    run read_guest_snapshot "${ui_root}" one-shot invalid Koine
    [[ "${status}" == 125 ]]
    assert_ui_latched
}

@test "prior failure blocks reads but evidence collection cannot clear the latch" {
    fail_guest_evidence "${ui_root}" earlier 'existing failure' || :
    run read_guest_snapshot "${ui_root}" read-poll forbidden Koine
    [[ "${status}" == 125 && ! -s "${ui_calls}" ]]
    run read_guest_snapshot "${ui_root}" evidence collect Koine
    [[ "${status}" == 0 ]]
    [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 1 ]]
    assert_ui_latched
}

@test "sleep failure and signal statuses stop without another snapshot" {
    local signal
    for signal in 1 130 143 129; do
        reset_ui "sleep-${signal}"
        ui_sleep_status="${signal}"
        run await_guest_element "${ui_root}" sleeping Koine '.id=="grant-label"' present
        if [[ "${signal}" == 1 ]]; then [[ "${status}" == 125 ]]; else [[ "${status}" == "${signal}" ]]; fi
        [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 1 ]]
        jq -e --argjson status "${signal}" '.poll_phase=="sleep" and .local_status==$status' "${ui_root}/000003/request.json"
        assert_ui_latched
    done
}

@test "adapter SIGINT retains interruption and refuses later input" {
    touch "${ui_replies}/1.int"
    run read_guest_snapshot "${ui_root}" read-poll interrupted Koine
    [[ "${status}" == 130 ]]
    jq -e '.outcome=="interrupted"' "${ui_root}/000001/result.json"
    assert_ui_latched
}

@test "failed local decoder output is never emitted or consumed and signals stay distinct" {
    local local_status
    for local_status in 1 44 130 143 129; do
        reset_ui "decode-${local_status}"
        ui_fixture >"${ui_replies}/1.json"
        # Python's payload check uses the real jq executable. This substitutes
        # only the shell's post-validation projection, including partial output.
        # shellcheck disable=SC2329
        jq() {
            echo '{"positionX":999}'
            return "${local_status}"
        }
        run read_guest_element "${ui_root}" decoder Koine '.id=="grant-label"' geometry
        unset -f jq
        if ((local_status > 128)); then [[ "${status}" == "${local_status}" ]]; else [[ "${status}" == 125 ]]; fi
        [[ "${output}" != *'"positionX":999'* ]]
        [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 1 ]]
        assert_ui_latched
    done
}

@test "sourcing has no startup effects and missing public arguments are safe under nounset" {
    local helper="${BATS_TEST_DIRNAME}/../../scripts/vm-ui-evidence-lib.sh" public
    if [[ "${KOINE_UI_BASELINE:-0}" == 1 ]]; then
        # Exercise the bare route for a meaningful baseline failure, not a
        # missing new source file or a missing baseline function in a subshell.
        run read_guest_snapshot '' read-poll missing Koine
        [[ "${status}" == 125 ]]
        return
    fi
    run bash -u -c 'source "$1"' _ "${helper}"
    [[ "${status}" == 0 && -z "${output}" && ! -s "${ui_calls}" ]]
    for public in read_guest_snapshot read_guest_element await_guest_element; do
        run bash -u -c 'source "$1"; "$2"' _ "${helper}" "${public}"
        [[ "${status}" == 125 ]]
        [[ ! -s "${ui_calls}" ]]
    done
}

@test "optional vertical reads preserve absence and qualify only consumed screen attributes" {
    run --separate-stderr read_guest_element "${ui_root}" absent Koine '.id=="grant-label"' optional-vertical
    [[ "${status}" == 0 && "${output}" == null ]]
    local y
    for y in 100 -100; do
        ui_fixture | jq --argjson y "${y}" 'del(.windows[0].elements[0].children[0].positionX,
            .windows[0].elements[0].children[0].sizeWidth,
            .windows[0].elements[0].children[0].value) |
            .windows[0].elements[0].children[0].positionY=$y |
            .windows[0].elements[0].children[0].sizeHeight=0' >"${ui_replies}/$(($(wc -l <"${ui_calls}") + 1)).json"
        run --separate-stderr read_guest_element "${ui_root}" screen Koine '.id=="grant-label"' optional-vertical
        [[ "${status}" == 0 ]]
        jq -e --argjson y "${y}" '.positionY==$y and .sizeHeight==0 and (has("positionX")|not) and (has("sizeWidth")|not)' <<<"${output}"
        # Actual on_screen predicate: a clean off-screen object is data, not unavailable.
        run jq -e '.positionY >= 50 and (.positionY + .sizeHeight) <= 700' <<<"${output}"
        if [[ "${y}" == 100 ]]; then [[ "${status}" == 0 ]]; else [[ "${status}" == 1 ]]; fi
    done
    [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 3 ]]
    jq -se 'length==3 and all(.[]; .outcome=="clean")' "${ui_root}"/*/result.json
    [[ ! -e "${ui_root}/unavailable" ]]
}

@test "required position reads accept y alone and refuse absence" {
    ui_fixture | jq 'del(.windows[0].elements[0].children[0].positionX,
        .windows[0].elements[0].children[0].sizeWidth,
        .windows[0].elements[0].children[0].sizeHeight,
        .windows[0].elements[0].children[0].value)' >"${ui_replies}/1.json"
    run --separate-stderr read_guest_element "${ui_root}" scroll Koine '.id=="grant-label"' position-y
    [[ "${status}" == 0 ]]
    jq -e '.positionY==100 and (has("sizeHeight")|not)' <<<"${output}"
    jq -e '.class=="read-poll" and (.payload_predicate|contains("positionY"))' "${ui_root}/000001/request.json"
    run read_guest_element "${ui_root}" missing Koine '.id=="grant-label"' position-y
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 2 ]]
    assert_ui_latched
}

@test "vertical requirements refuse missing or invalid consumed attributes without another read" {
    local requirement change n=0
    for requirement in optional-vertical position-y; do
        for change in 'del(.positionY)' '.positionY=null' '.positionY="100"' \
            'del(.sizeHeight)' '.sizeHeight=-1'; do
            if [[ "${requirement}" == position-y && "${change}" == *sizeHeight* ]]; then continue; fi
            n=$((n + 1))
            reset_ui "vertical-${n}"
            ui_fixture | jq ".windows[0].elements[0].children[0] |= (${change})" >"${ui_replies}/1.json"
            run read_guest_element "${ui_root}" invalid Koine '.id=="grant-label"' "${requirement}"
            [[ "${status}" == 125 ]]
            [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 1 ]]
            assert_ui_latched
        done
    done
}

@test "a missing tree in another window refuses a positive and stops a settling poll" {
    ui_fixture | jq '.windows += [(.windows[0] | del(.elements))]' >"${ui_replies}/1.json"
    run await_guest_element "${ui_root}" settling Koine '.id=="grant-label"' present
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 1 && ! -s "${ui_waits}" ]]
    jq -e '.outcome=="unavailable"' "${ui_root}/000001/result.json"
    assert_ui_latched
}

@test "selector qualification depends on candidates and syntax failure follows dispatch" {
    local selector n=0
    for selector in '42' 'true,false' 'error("candidate only")'; do
        n=$((n + 1))
        reset_ui "empty-selector-${n}"
        run await_guest_element "${ui_root}" empty Koine "${selector}" absent
        [[ "${status}" == 0 ]]
        [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 1 && ! -s "${ui_waits}" ]]
        [[ ! -e "${ui_root}/unavailable" ]]
    done
    reset_ui syntax-selector
    run read_guest_element "${ui_root}" syntax Koine '.id ==' optional
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${ui_calls}" | tr -d ' ')" == 1 ]]
    jq -e '.outcome=="unavailable"' "${ui_root}/000001/result.json"
    assert_ui_latched
}
