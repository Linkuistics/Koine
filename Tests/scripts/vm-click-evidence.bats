#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Each test owns its environment.

setup() {
    bats_require_minimum_version 1.5.0
    # Real adapter, store, snapshot reader and jq; replace external CLI/sleep only.
    # shellcheck source=scripts/vm-ui-evidence-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-ui-evidence-lib.sh"
    if [[ "${KOINE_CLICK_BASELINE:-0}" == 1 ]]; then
        # Bare legacy routes, without the exec trigger/confirmation k81 owns.
        # shellcheck disable=SC2329
        read_guest_text() {
            if [[ $# == 4 ]]; then
                testanyware screen find-text "$3" --timeout "$4" --json
            else
                testanyware screen find-text "$3" --json
            fi
        }
        # shellcheck disable=SC2329
        click_guest_allow() {
            local found
            found="$(read_guest_text "$1" "$2" Allow 30 | jq -c '[.detections[] | select(.text == "Allow")][0]')" || true
            [[ -n "${found}" && "${found}" != null ]] || return 1
            # shellcheck disable=SC2046
            testanyware input click $(jq -r '"\(.x + .width / 2 | floor) \(.y + .height / 2 | floor)"' <<<"${found}") >/dev/null
            sleep 2
        }
        eval "$(awk '/^click\(\)/ {selected=1} selected {print} selected && /^}/ {selected=0}' "${BATS_TEST_DIRNAME}/../../scripts/vm-verify-lib.sh")"
        # shellcheck disable=SC2329
        element() { testanyware agent snapshot --mode full --window "${SNAPSHOT_WINDOW}" --depth 14 --json | jq -c "[.. | objects | select(has(\"platformRole\")) | select($1)][0]"; }
        # shellcheck disable=SC2329
        fail() {
            echo "legacy failure: $*" >&2
            return 1
        }
        # shellcheck disable=SC2329
        click_guest_element() { SNAPSHOT_WINDOW="$3" click "$4"; }
    else
        # shellcheck source=scripts/vm-click-evidence-lib.sh
        source "${BATS_TEST_DIRNAME}/../../scripts/vm-click-evidence-lib.sh"
    fi
    export click_root="${BATS_TEST_TMPDIR}/evidence"
    export click_calls="${BATS_TEST_TMPDIR}/calls" click_waits="${BATS_TEST_TMPDIR}/waits"
    export click_replies="${BATS_TEST_TMPDIR}/replies"
    mkdir "${click_replies}" "${BATS_TEST_TMPDIR}/bin" "${BATS_TEST_TMPDIR}/cwd"
    : >"${click_calls}"
    : >"${click_waits}"
    cd "${BATS_TEST_TMPDIR}/cwd" || return
    # shellcheck disable=SC2329
    sleep() {
        echo "$*" >>"${click_waits}"
        return "${click_sleep_status:-0}"
    }
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
set -euo pipefail
jq -cn --args '$ARGS.positional' -- "$@" >>"${click_calls}"
n=$(wc -l <"${click_calls}" | tr -d ' ')
cat "${click_replies}/${n}.json"
echo "click diagnostic ${n}" >&2
if [[ -f "${click_replies}/${n}.exit" ]]; then exit "$(cat "${click_replies}/${n}.exit")"; fi
CLI
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    init_guest_evidence "${click_root}" exact-click-vm
}

ocr_fixture() {
    echo '{"schema_version":"1.0","ok":true,"query":"Allow","engine":"vision","detections":[{"text":"allow something","x":1,"y":2,"width":3,"height":4,"confidence":0.8},{"text":"Allow","x":100.5,"y":200.5,"width":20,"height":40,"confidence":0.95},{"text":"Allow","x":400,"y":500,"width":30,"height":20,"confidence":0.9}],"returned":3,"total":3,"truncated":false}'
}

element_fixture() {
    echo '{"schema_version":"1.0","ok":true,"windows":[{"appName":"System Settings","title":"Accessibility","windowType":"standard","focused":true,"positionX":40,"positionY":40,"sizeWidth":480,"sizeHeight":712,"elements":[{"role":"button","platformRole":"AXButton","label":"Add","enabled":true,"focused":false,"childCount":0,"actions":["AXPress"],"positionX":60.5,"positionY":100.5,"sizeWidth":200,"sizeHeight":24}]}]}'
}

click_reply() { echo '{"schema_version":"1.0","ok":true,"x":110,"y":220,"button":"left","count":1}'; }

reset_click() {
    click_root="${BATS_TEST_TMPDIR}/$1"
    init_guest_evidence "${click_root}" exact-click-vm
    : >"${click_calls}"
    : >"${click_waits}"
    rm -f "${click_replies}"/*
}

assert_click_latched() {
    local count
    count="$(wc -l <"${click_calls}")"
    run cli_guest_evidence "${click_root}" one-shot later '.key == "return" and .modifiers == []' -- input key return
    [[ "${status}" == 125 && -s "${click_root}/unavailable" ]]
    [[ "$(wc -l <"${click_calls}")" == "${count}" ]]
}

@test "OCR preserves original bytes VM argv and nonconstant receipt" {
    ocr_fixture >"${click_replies}/1.json"
    read_guest_text "${click_root}" allow-read Allow 30 >"${BATS_TEST_TMPDIR}/actual"
    cmp "${click_replies}/1.json" "${BATS_TEST_TMPDIR}/actual"
    cmp "${click_replies}/1.json" "${click_root}/000001/raw.stdout"
    grep -qx 'click diagnostic 1' "${click_root}/000001/raw.stderr"
    jq -se '. == [["screen","find-text","Allow","--timeout","30","--vm","exact-click-vm","--json"]]' "${click_calls}"
    jq -e '.class == "read-poll" and .operation == "allow-read" and .payload_predicate != "true"' "${click_root}/000001/request.json"
}

@test "complete OCR empty is clean data without a timeout or second read" {
    ocr_fixture | jq '.query="would like to control" | .detections=[] | .returned=0 | .total=0' >"${click_replies}/1.json"
    read_guest_text "${click_root}" consent 'would like to control' >"${BATS_TEST_TMPDIR}/actual"
    jq -e '.total == 0 and .detections == []' "${BATS_TEST_TMPDIR}/actual"
    jq -e '.outcome == "clean"' "${click_root}/000001/result.json"
    jq -se '. == [["screen","find-text","would like to control","--vm","exact-click-vm","--json"]]' "${click_calls}"
    [[ ! -s "${click_waits}" && ! -e "${click_root}/unavailable" ]]
}

@test "incomplete OCR counts field types and truncation cannot qualify absence" {
    local change n=0
    for change in 'del(.detections)' '.detections={}' '.returned=2' '.total=4' '.truncated=true' \
        '.query="other"' '.engine=""' '.returned=3.5' '.detections[0].text=null' \
        'del(.detections[0].confidence)' '.detections[0].x="1"' '.detections[0].height=-1'; do
        n=$((n + 1))
        reset_click "ocr-schema-${n}"
        ocr_fixture | jq "${change}" >"${click_replies}/1.json"
        run read_guest_text "${click_root}" schema Allow
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${click_calls}" | tr -d ' ')" == 1 ]]
        assert_click_latched
    done
}

@test "failed partial and typed-error OCR stop before click and sleep" {
    local problem
    for problem in nonzero partial error error-zero dry-run; do
        reset_click "ocr-failed-${problem}"
        ocr_fixture >"${click_replies}/1.json"
        case "${problem}" in
        nonzero) echo 255 >"${click_replies}/1.exit" ;;
        partial) echo '{"schema_version":' >"${click_replies}/1.json" ;;
        error | error-zero)
            # v2.7.0 output.rs: top-level code/message; OCR_TIMEOUT exits 7.
            # error-zero is deliberately contradictory completion, not native.
            echo '{"schema_version":"1.0","ok":false,"code":"OCR_TIMEOUT","message":"OCR timed out","remediation":"Increase the OCR deadline or reduce screen complexity, then retry.","details":{}}' >"${click_replies}/1.json"
            if [[ "${problem}" == error ]]; then echo 7 >"${click_replies}/1.exit"; fi
            ;;
        dry-run) ocr_fixture | jq '.dry_run=false' >"${click_replies}/1.json" ;;
        esac
        run click_guest_allow "${click_root}" allow
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${click_calls}" | tr -d ' ')" == 1 && ! -s "${click_waits}" ]]
        if [[ "${problem}" == error || "${problem}" == error-zero ]]; then
            cmp "${click_replies}/1.json" "${click_root}/000001/raw.stdout"
            jq -e '.code == "OCR_TIMEOUT" and .message == "OCR timed out"' "${click_root}/000001/raw.stdout"
            if [[ "${problem}" == error ]]; then
                jq -e '.outcome == "unavailable" and .cli_status == 7' "${click_root}/000001/result.json"
            else
                jq -e '.outcome == "unavailable" and .cli_status == 0' "${click_root}/000001/result.json"
            fi
        fi
        assert_click_latched
    done
}

@test "Allow chooses first exact text floors its centre and clicks once" {
    ocr_fixture >"${click_replies}/1.json"
    click_reply >"${click_replies}/2.json"
    click_guest_allow "${click_root}" allow
    jq -se '.[1] == ["input","click","110","220","--vm","exact-click-vm","--json"] and length == 2' "${click_calls}"
    jq -se 'map(.class) == ["read-poll","one-shot"] and map(.ordinal) == [1,2]' "${click_root}"/*/request.json
    [[ "$(cat "${click_waits}")" == 2 ]]
}

@test "clean OCR without exact Allow records state failure without input" {
    local text n=0
    for text in empty allow "Don't Allow" allowed; do
        n=$((n + 1))
        reset_click "no-exact-allow-${n}"
        if [[ "${text}" == empty ]]; then
            ocr_fixture | jq '.detections=[] | .returned=0 | .total=0' >"${click_replies}/1.json"
        else
            ocr_fixture | jq --arg text "${text}" '.detections |= map(.text=$text)' >"${click_replies}/1.json"
        fi
        run click_guest_allow "${click_root}" allow
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${click_calls}" | tr -d ' ')" == 1 && ! -s "${click_waits}" ]]
        jq -e '.outcome == "clean"' "${click_root}/000001/result.json"
        jq -e '.transport == "poll-step" and .poll_phase == "exhausted" and .local_status == 1
            and .state_predicate == "any(.detections[]; .text == \"Allow\")"' "${click_root}/000002/request.json"
        jq -e '.outcome == "state-failed"' "${click_root}/000002/result.json"
        assert_click_latched
    done
}

@test "invalid Allow size and out-of-range derived coordinates refuse input" {
    local change n=0
    for change in '.width=0' '.height=0' '.x=-20' '.y=65536' '.x=1e308 | .width=1e308'; do
        n=$((n + 1))
        reset_click "allow-geometry-${n}"
        ocr_fixture | jq ".detections[1] |= (${change})" >"${click_replies}/1.json"
        run click_guest_allow "${click_root}" allow
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${click_calls}" | tr -d ' ')" == 1 && ! -s "${click_waits}" ]]
        jq -e '.transport == "confirmation" and (.reason | startswith("state exit 4:"))' "${click_root}/000002/request.json"
        jq -e '.outcome == "unavailable" and (.reason | startswith("state exit 4:"))' "${click_root}/000002/result.json"
        assert_click_latched
    done
}

@test "wrong click echo button count or failed completion stops without settling" {
    local change n=0
    for change in '.x=111' '.y=221' '.button="right"' '.count=2' '.x="110"' 'nonzero'; do
        n=$((n + 1))
        reset_click "click-echo-${n}"
        ocr_fixture >"${click_replies}/1.json"
        if [[ "${change}" == nonzero ]]; then
            click_reply >"${click_replies}/2.json"
            echo 7 >"${click_replies}/2.exit"
        else click_reply | jq "${change}" >"${click_replies}/2.json"; fi
        run click_guest_allow "${click_root}" allow
        [[ "${status}" == 125 && ! -s "${click_waits}" ]]
        [[ "$(wc -l <"${click_calls}" | tr -d ' ')" == 2 ]]
        assert_click_latched
    done
}

@test "element click consumes one geometry snapshot and preserves centre input wait" {
    element_fixture >"${click_replies}/1.json"
    click_reply | jq '.x=160 | .y=112' >"${click_replies}/2.json"
    click_guest_element "${click_root}" add 'System Settings' '.role=="button" and .label=="Add"'
    jq -se '. == [["agent","snapshot","--mode","full","--window","System Settings","--depth","14","--vm","exact-click-vm","--json"],["input","click","160","112","--vm","exact-click-vm","--json"]]' "${click_calls}"
    [[ "$(cat "${click_waits}")" == 2 ]]
    jq -se 'map(.outcome) == ["clean","clean"]' "${click_root}"/*/result.json
}

@test "missing element tree geometry or invalid centre stops before element click" {
    local change n=0
    for change in '.windows=[]' 'del(.windows[0].elements)' 'del(.windows[0].elements[0].positionX)' \
        '.windows[0].elements[0].sizeWidth=0' '.windows[0].elements[0].positionX=-500' \
        '.windows[0].elements[0].positionY=65536'; do
        n=$((n + 1))
        reset_click "element-geometry-${n}"
        element_fixture | jq "${change}" >"${click_replies}/1.json"
        run click_guest_element "${click_root}" add 'System Settings' '.label=="Add"'
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${click_calls}" | tr -d ' ')" == 1 && ! -s "${click_waits}" ]]
        assert_click_latched
    done
}

@test "snapshot nonzero completion with valid geometry never permits input" {
    element_fixture >"${click_replies}/1.json"
    echo 7 >"${click_replies}/1.exit"
    run click_guest_element "${click_root}" add 'System Settings' '.label=="Add"'
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${click_calls}" | tr -d ' ')" == 1 && ! -s "${click_waits}" ]]
    assert_click_latched
}

@test "failed local centre decoder output is never used for input" {
    ocr_fixture >"${click_replies}/1.json"
    # Fault only the local centre projection, keeping adapter validation real.
    # shellcheck disable=SC2329
    jq() {
        if [[ "${1-}" == -er && "${2-}" == *'floor'* ]]; then
            echo '110 220'
            return 9
        fi
        command jq "$@"
    }
    run click_guest_allow "${click_root}" allow
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${click_calls}" | tr -d ' ')" == 1 && ! -s "${click_waits}" ]]
    command jq -e '.transport == "confirmation" and (.reason | startswith("state exit 9:"))' "${click_root}/000002/request.json"
    command jq -e '.outcome == "unavailable" and (.reason | startswith("state exit 9:"))' "${click_root}/000002/result.json"
    assert_click_latched
}

@test "interrupted query encoder preserves signal status before dispatch" {
    # The local encoder emits plausible output before interruption. It must not
    # become a usable predicate or dispatch any CLI invocation.
    # shellcheck disable=SC2329
    jq() {
        if [[ "${1-}" == -rn ]]; then
            echo '.query == "Allow"'
            return 143
        fi
        command jq "$@"
    }
    run read_guest_text "${click_root}" consent Allow 30
    [[ "${status}" == 143 && ! -s "${click_calls}" && ! -s "${click_waits}" ]]
    command jq -e '.transport == "poll-step" and .poll_phase == "state" and .local_status == 143' "${click_root}/000001/request.json"
    command jq -e '.outcome == "interrupted"' "${click_root}/000001/result.json"
    assert_click_latched
}

@test "failed query encoder retains local exit in unavailable receipt" {
    # shellcheck disable=SC2329
    jq() {
        if [[ "${1-}" == -rn ]]; then
            echo '.query == "Allow"'
            return 9
        fi
        command jq "$@"
    }
    run read_guest_text "${click_root}" consent Allow
    [[ "${status}" == 125 && ! -s "${click_calls}" && ! -s "${click_waits}" ]]
    command jq -e '.transport == "confirmation" and (.reason | startswith("state exit 9:"))' "${click_root}/000001/request.json"
    command jq -e '.outcome == "unavailable" and (.reason | startswith("state exit 9:"))' "${click_root}/000001/result.json"
    assert_click_latched
}

@test "failed or interrupted exact-target evaluation is never a clean negative" {
    local code
    # shellcheck disable=SC2329
    jq() {
        if [[ "${1-}" == -e && "${2-}" == 'any(.detections[]; .text == "Allow")' ]]; then
            echo false
            return "${click_state_status}"
        fi
        command jq "$@"
    }
    for code in 9 143; do
        reset_click "target-state-${code}"
        export click_state_status="${code}"
        ocr_fixture >"${click_replies}/1.json"
        run click_guest_allow "${click_root}" allow
        [[ "$(wc -l <"${click_calls}" | tr -d ' ')" == 1 && ! -s "${click_waits}" ]]
        if [[ "${code}" == 143 ]]; then
            [[ "${status}" == 143 ]]
            command jq -e '.transport == "poll-step" and .poll_phase == "state" and .local_status == 143' "${click_root}/000002/request.json"
            command jq -e '.outcome == "interrupted"' "${click_root}/000002/result.json"
        else
            [[ "${status}" == 125 ]]
            command jq -e '.transport == "confirmation" and (.reason | startswith("state exit 9:"))' "${click_root}/000002/request.json"
            command jq -e '.outcome == "unavailable"' "${click_root}/000002/result.json"
        fi
        assert_click_latched
    done
}

@test "failed or interrupted settling keeps exact local status and stops later input" {
    local code
    for code in 7 130; do
        reset_click "sleep-${code}"
        export click_sleep_status="${code}"
        ocr_fixture >"${click_replies}/1.json"
        click_reply >"${click_replies}/2.json"
        run click_guest_allow "${click_root}" allow
        if [[ "${code}" == 130 ]]; then [[ "${status}" == 130 ]]; else [[ "${status}" == 125 ]]; fi
        jq -e --argjson code "${code}" '.poll_phase == "sleep" and .local_status == $code' "${click_root}/000003/request.json"
        [[ "$(cat "${click_waits}")" == 2 ]]
        assert_click_latched
    done
}

@test "inclusive coordinate limits retain original floor-of-centre rule" {
    ocr_fixture | jq '.detections[1] |= (.x=-0.25 | .y=65534.75 | .width=1 | .height=1)' >"${click_replies}/1.json"
    click_reply | jq '.x=0 | .y=65535' >"${click_replies}/2.json"
    click_guest_allow "${click_root}" allow
    jq -se '.[1] == ["input","click","0","65535","--vm","exact-click-vm","--json"]' "${click_calls}"
    [[ "$(cat "${click_waits}")" == 2 ]]
}

@test "interrupted local decoder preserves signal and emitted point is unused" {
    ocr_fixture >"${click_replies}/1.json"
    # shellcheck disable=SC2329
    jq() {
        if [[ "${1-}" == -er && "${2-}" == *'floor'* ]]; then
            echo '110 220'
            return 143
        fi
        command jq "$@"
    }
    run click_guest_allow "${click_root}" allow
    [[ "${status}" == 143 ]]
    [[ "$(wc -l <"${click_calls}" | tr -d ' ')" == 1 && ! -s "${click_waits}" ]]
    command jq -e '.poll_phase=="state" and .local_status==143' "${click_root}/000002/request.json"
    command jq -e '.outcome=="interrupted"' "${click_root}/000002/result.json"
    assert_click_latched
}

@test "source-only library and missing arguments are safe under nounset" {
    # Characterization of the new interface; no legacy startup repair is claimed.
    [[ "${KOINE_CLICK_BASELINE:-0}" != 1 ]] || skip 'new source-only interface only'
    run bash -uc 'source "$1"; read_guest_text' -- "${BATS_TEST_DIRNAME}/../../scripts/vm-click-evidence-lib.sh"
    [[ "${status}" == 125 ]]
    run bash -uc 'source "$1"; click_guest_allow' -- "${BATS_TEST_DIRNAME}/../../scripts/vm-click-evidence-lib.sh"
    [[ "${status}" == 125 ]]
    run bash -uc 'source "$1"; click_guest_element' -- "${BATS_TEST_DIRNAME}/../../scripts/vm-click-evidence-lib.sh"
    [[ "${status}" == 125 && ! -s "${click_calls}" && ! -s "${click_waits}" ]]
    [[ -z "$(find . -mindepth 1 -print)" ]]
}

@test "invalid roots and arguments refuse before dispatch or cwd writes" {
    run read_guest_text '' empty Allow
    [[ "${status}" == 125 && ! -s "${click_calls}" ]]
    [[ -z "$(find . -mindepth 1 -print)" ]]
    run click_guest_allow "${BATS_TEST_TMPDIR}/missing" allow
    [[ "${status}" == 125 && ! -s "${click_calls}" ]]
    [[ -z "$(find . -mindepth 1 -print)" ]]
    run read_guest_text "${click_root}" invalid Allow 31
    [[ "${status}" == 125 && ! -s "${click_calls}" ]]
    [[ -z "$(find . -mindepth 1 -print)" ]]
}
