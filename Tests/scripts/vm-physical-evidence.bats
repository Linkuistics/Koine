#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Bats gives each test its own setup/environment.

setup() {
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    # shellcheck source=scripts/vm-menu-pointer-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-menu-pointer-lib.sh"
    # shellcheck source=scripts/vm-window-resize-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-window-resize-lib.sh"
    export KOINE_VM_EVIDENCE_ROOT="${BATS_TEST_TMPDIR}/evidence"
    export WINDOW_TITLE='Koine Settings'
    export physical_calls="${BATS_TEST_TMPDIR}/calls"
    export physical_waits="${BATS_TEST_TMPDIR}/waits"
    export physical_replies="${BATS_TEST_TMPDIR}/replies"
    export physical_override="${BATS_TEST_TMPDIR}/override"
    mkdir "${physical_replies}" "${BATS_TEST_TMPDIR}/bin" "${BATS_TEST_TMPDIR}/cwd"
    cd "${BATS_TEST_TMPDIR}/cwd" || return
    : >"${physical_calls}"
    : >"${physical_waits}"
    # shellcheck disable=SC2329 # Called by the sourced physical helpers.
    sleep() { echo "$*" >>"${physical_waits}"; }
    # Strict geometry failure must not call the legacy fail(), whose real
    # implementation captures through a bare CLI outside the writer domain.
    # shellcheck disable=SC2329 # Called by the sourced legacy failure branch.
    fail() {
        echo "legacy fail: $*" >&2
        return 1
    }
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'SH'
#!/bin/bash
set -euo pipefail
jq -cn --args '$ARGS.positional' -- "$@" >>"${physical_calls}"
n=$(wc -l <"${physical_calls}" | tr -d ' ')
case "$1 $2" in
    'screen size') payload='{"width":1920,"height":1080}' ;;
    'agent windows') payload='{"windows":[{"appName":"TextEdit","windowType":"standard","focused":false,"positionX":650,"positionY":80,"sizeWidth":603,"sizeHeight":505},{"title":"Koine Settings","appName":"Koine","windowType":"standard","focused":true,"positionX":40,"positionY":40,"sizeWidth":480,"sizeHeight":712}]}' ;;
    'input move') payload=$(jq -cn --argjson x "$3" --argjson y "$4" '{x:$x,y:$y}') ;;
    'input click') payload=$(jq -cn --argjson x "$3" --argjson y "$4" '{x:$x,y:$y,button:"left",count:1}') ;;
    'input mouse-down'|'input mouse-up') payload=$(jq -cn --argjson x "$3" --argjson y "$4" '{x:$x,y:$y,button:"left"}') ;;
    *) exit 98 ;;
esac
if [[ "${physical_at:-0}" == "$n" && -f "${physical_override}" ]]; then
    cat "${physical_override}" >"${physical_replies}/$n"
else
    jq -n --argjson payload "$payload" '{schema_version:"1.0",ok:true} + $payload' >"${physical_replies}/$n"
fi
cat "${physical_replies}/$n"
echo "physical CLI diagnostic $n" >&2
if [[ "${physical_at:-0}" == "$n" ]]; then
    if [[ "${physical_signal:-}" == INT ]]; then kill -INT "$PPID"; sleep 0.1; fi
    exit "${physical_status:-0}"
fi
SH
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    init_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" exact-physical-vm
}

reset_physical() {
    KOINE_VM_EVIDENCE_ROOT="${BATS_TEST_TMPDIR}/$1"
    init_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" exact-physical-vm
    : >"${physical_calls}"
    : >"${physical_waits}"
}

assert_blocked() {
    local before
    before="$(wc -l <"${physical_calls}")"
    run click_at 10 10
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${physical_calls}")" == "${before}" ]]
    [[ -s "${KOINE_VM_EVIDENCE_ROOT}/unavailable" ]]
}

@test "strict menu route retains exact raw completions, VM, ordinals and unchanged waits" {
    click_centre '100, 0, 22, 15'
    jq -se '. == [["screen","size","--vm","exact-physical-vm","--json"],
        ["input","move","99","0","--vm","exact-physical-vm","--json"],
        ["input","move","111","7","--vm","exact-physical-vm","--json"],
        ["input","click","111","7","--vm","exact-physical-vm","--json"]]' "${physical_calls}"
    local n ordinal
    for n in 1 2 3 4; do
        printf -v ordinal '%06d' "${n}"
        cmp "${physical_replies}/${n}" "${KOINE_VM_EVIDENCE_ROOT}/${ordinal}/raw.stdout"
        jq -e --argjson n "${n}" '.ordinal == $n and .vm == "exact-physical-vm" and .payload_predicate != "true"' "${KOINE_VM_EVIDENCE_ROOT}/${ordinal}/request.json"
        jq -e '.outcome == "clean" and .cli_status == 0' "${KOINE_VM_EVIDENCE_ROOT}/${ordinal}/result.json"
        grep -qx "physical CLI diagnostic ${n}" "${KOINE_VM_EVIDENCE_ROOT}/${ordinal}/raw.stderr"
    done
    [[ "$(cat "${physical_waits}")" == $'0.3\n0.3\n1' ]]
}

@test "strict successful resize preserves corner, eleven held points, release and waits" {
    drag_window_corner 740 940
    jq -se 'length == 14 and .[0] == ["agent","windows","--vm","exact-physical-vm","--json"]
        and .[1][0:4] == ["input","move","517","749"]
        and .[2][0:4] == ["input","mouse-down","517","749"]
        and .[3][0:4] == ["input","mouse-down","539","768"]
        and .[7][0:4] == ["input","mouse-down","628","844"]
        and .[12][0:4] == ["input","mouse-down","740","940"]
        and .[13][0:4] == ["input","mouse-up","740","940"]
        and all(.[]; .[-3:] == ["--vm","exact-physical-vm","--json"])' "${physical_calls}"
    [[ "$(cat "${physical_waits}")" == "$(
        printf '0.5\n0.2\n'
        for _ in {1..10}; do echo 0.15; done
        echo 1
    )" ]]
    jq -e '.outcome == "clean"' "${KOINE_VM_EVIDENCE_ROOT}/000014/result.json"
}

@test "strict menu rejects mismatching and incomplete move or click payloads" {
    local stage payload iteration=0
    for stage in 2 3 4; do
        for payload in '{"x":99,"y":99}' '{"x":111}' '{"x":"111","y":7}' \
            '{"x":111,"y":7,"button":"right","count":1}' \
            '{"x":111,"y":7,"button":"left","count":2}'; do
            # Button/count belong to clicks only; moves require exactly their x/y.
            [[ "${stage}" == 4 || "${payload}" != *button* ]] || continue
            iteration=$((iteration + 1))
            reset_physical "schema-${iteration}"
            export physical_at="${stage}"
            jq -cn --argjson payload "${payload}" '{schema_version:"1.0",ok:true} + $payload' >"${physical_override}"
            run click_centre '100, 0, 22, 15'
            [[ "${status}" == 125 ]]
            [[ "$(wc -l <"${physical_calls}" | tr -d ' ')" == "${stage}" ]]
            assert_blocked
        done
    done
}

@test "strict screen dimensions reject missing, malformed, fractional and oversized payloads" {
    local payload iteration=0
    for payload in '{}' '{"width":1920}' '{"width":1920,"height":null}' \
        '{"width":1920.5,"height":1080}' '{"width":1,"height":1080}' \
        '{"width":65536,"height":1080}' '{"width":"1920","height":1080}'; do
        iteration=$((iteration + 1))
        reset_physical "size-${iteration}"
        export physical_at=1
        jq -cn --argjson payload "${payload}" '{schema_version:"1.0",ok:true} + $payload' >"${physical_override}"
        run click_at 10 10
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${physical_calls}" | tr -d ' ')" == 1 ]]
        assert_blocked
    done
}

@test "strict helper refuses CLI errors and invalid base envelopes at every menu stage" {
    local stage problem
    for stage in 1 2 3 4; do
        for problem in nonzero partial false-ok missing-schema dry-run duplicate; do
            reset_physical "base-${stage}-${problem}"
            export physical_at="${stage}" physical_status=0
            rm -f "${physical_override}"
            case "${problem}" in
            nonzero) physical_status=7 ;;
            partial) printf '{"schema_version":' >"${physical_override}" ;;
            false-ok) echo '{"schema_version":"1.0","ok":false}' >"${physical_override}" ;;
            missing-schema) echo '{"ok":true}' >"${physical_override}" ;;
            dry-run) echo '{"schema_version":"1.0","ok":true,"dry_run":true}' >"${physical_override}" ;;
            duplicate) echo '{"schema_version":"1.0","ok":true,"ok":true}' >"${physical_override}" ;;
            esac
            # Deliberately test a conditional caller: errexit supplies no safety.
            if click_at 100 100; then return 1; fi
            [[ "$(wc -l <"${physical_calls}" | tr -d ' ')" == "${stage}" ]]
            assert_blocked
        done
    done
}

@test "strict geometry errors latch before any pointer action without legacy failure capture" {
    local target iteration=0
    for target in '' '1, 2, 0, 20' '1, 2, 20' '1, -1, 20, 20' '1920, 0, 20, 20'; do
        iteration=$((iteration + 1))
        reset_physical "geometry-${iteration}"
        run click_centre "${target}"
        [[ "${status}" == 125 && "${output}" != *'legacy fail:'* ]]
        jq -se 'any(.[]; .transport == "confirmation")' "${KOINE_VM_EVIDENCE_ROOT}"/*/request.json
        jq -se 'all(.[]; .[0] != "input")' "${physical_calls}"
        assert_blocked
    done
}

@test "an explicit empty or unknown physical evidence root never selects legacy transport" {
    local root
    for root in '' "${BATS_TEST_TMPDIR}/unknown" "${BATS_TEST_TMPDIR}/cwd"; do
        KOINE_VM_EVIDENCE_ROOT="${root}"
        run click_at 10 10
        [[ "${status}" != 0 && ! -s "${physical_calls}" ]]
        [[ ! -e .writer && ! -e unavailable && ! -e refusals.jsonl ]]
        run click_centre ''
        [[ "${status}" != 0 && ! -s "${physical_calls}" ]]
        [[ ! -e .writer && ! -e unavailable && ! -e refusals.jsonl ]]
        run drag_window_corner 740 940
        [[ "${status}" != 0 && ! -s "${physical_calls}" ]]
        [[ ! -e .writer && ! -e unavailable && ! -e refusals.jsonl ]]
    done
}

@test "a prior latch blocks all physical reads and input" {
    run fail_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" setup 'failed setup'
    [[ "${status}" == 125 ]]
    run click_at 100 100
    [[ "${status}" == 125 && ! -s "${physical_calls}" ]]
    run drag_window_corner 740 940
    [[ "${status}" == 125 && ! -s "${physical_calls}" ]]
}

@test "strict resize stops at each failed dispatch without unrecorded release" {
    local stage ordinal
    for stage in {1..14}; do
        reset_physical "resize-failure-${stage}"
        export physical_at="${stage}" physical_status=255
        if drag_window_corner 740 940; then return 1; fi
        [[ "$(wc -l <"${physical_calls}" | tr -d ' ')" == "${stage}" ]]
        printf -v ordinal '%06d' "${stage}"
        jq -e '.outcome == "unavailable" and .cli_status == 255' "${KOINE_VM_EVIDENCE_ROOT}/${ordinal}/result.json"
        assert_blocked
    done
}

@test "strict resize rejects wrong down and up coordinates or button" {
    local stage payload iteration=0
    for stage in 3 8 14; do
        for payload in '{"x":1,"y":2,"button":"left"}' \
            '{"x":740,"y":940,"button":"right"}' '{"x":740,"y":940}'; do
            iteration=$((iteration + 1))
            reset_physical "held-schema-${iteration}"
            export physical_at="${stage}"
            jq -cn --argjson payload "${payload}" '{schema_version:"1.0",ok:true} + $payload' >"${physical_override}"
            run drag_window_corner 740 940
            [[ "${status}" == 125 ]]
            [[ "$(wc -l <"${physical_calls}" | tr -d ' ')" == "${stage}" ]]
            assert_blocked
        done
    done
}

@test "strict resize refuses incomplete, ambiguous and unusable window observations" {
    local payload iteration=0
    for payload in '{}' '{"windows":null}' '{"windows":[]}' \
        '{"windows":[{"title":"Koine Settings"}]}' \
        '{"windows":[{"title":"Koine Settings","appName":"Koine","windowType":"standard","focused":true,"positionX":40,"positionY":40,"sizeWidth":null,"sizeHeight":712}]}' \
        '{"windows":[{"title":"Koine Settings","appName":"Koine","windowType":"standard","focused":true,"positionX":-500,"positionY":40,"sizeWidth":480,"sizeHeight":712}]}' \
        '{"windows":[{"title":"Koine Settings","appName":"Koine","windowType":"standard","focused":true,"positionX":40,"positionY":40,"sizeWidth":480,"sizeHeight":712},{"title":"Koine Settings","appName":"Koine","windowType":"standard","focused":false,"positionX":40,"positionY":40,"sizeWidth":480,"sizeHeight":712}]}'; do
        iteration=$((iteration + 1))
        reset_physical "windows-${iteration}"
        export physical_at=1
        jq -cn --argjson payload "${payload}" '{schema_version:"1.0",ok:true} + $payload' >"${physical_override}"
        run drag_window_corner 740 940
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${physical_calls}" | tr -d ' ')" == 1 ]]
        assert_blocked
    done
}

@test "strict resize validates destinations before reading windows or pressing a button" {
    local point
    for point in '-1 100' 'hello 100' '65536 100' '100 1.5'; do
        reset_physical "destination-${point// /-}"
        read -r x y <<<"${point}"
        run drag_window_corner "${x}" "${y}"
        [[ "${status}" == 125 && ! -s "${physical_calls}" ]]
        assert_blocked
    done
}

@test "adapter interruption remains distinct through a physical helper and stops input" {
    export physical_at=2 physical_signal=INT
    run click_at 100 100
    [[ "${status}" == 130 ]]
    jq -e '.outcome == "interrupted"' "${KOINE_VM_EVIDENCE_ROOT}/000002/result.json"
    [[ "$(wc -l <"${physical_calls}" | tr -d ' ')" == 2 ]]
    assert_blocked
}

@test "failed title encoding latches before resize dispatch" {
    # shellcheck disable=SC2329 # Called by the sourced frame reader.
    jq() {
        if [[ "$1" == -cn && "${2:-}" == --arg && "${3:-}" == title ]]; then return 7; fi
        command jq "$@"
    }
    run drag_window_corner 740 940
    [[ "${status}" == 125 && ! -s "${physical_calls}" ]]
    assert_blocked
}

@test "failed frame decoding cannot qualify emitted geometry or leave input eligible" {
    # shellcheck disable=SC2329 # Called by the sourced frame reader.
    jq() {
        command jq "$@"
        if [[ "$1" == -er && "${2:-}" == --arg && "${3:-}" == title ]]; then return 7; fi
    }
    run drag_window_corner 740 940
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${physical_calls}" | tr -d ' ')" == 1 ]]
    assert_blocked
}

@test "failed display decoding cannot qualify emitted dimensions or leave input eligible" {
    # shellcheck disable=SC2329 # Called by the sourced display reader.
    jq() {
        command jq "$@"
        if [[ "$1" == -er ]]; then return 7; fi
    }
    run click_at 100 100
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${physical_calls}" | tr -d ' ')" == 1 ]]
    assert_blocked
}

# Bash ignores errexit inside a function that a conditional caller runs, as the
# scenario's `helper || settings_stop` does. Wait number $1 then fails with $2.
fail_wait_at() {
    export physical_wait_fails_at="$1" physical_wait_status="$2"
    # shellcheck disable=SC2329 # Called by the sourced physical helpers.
    sleep() {
        echo "$*" >>"${physical_waits}"
        [[ "$(wc -l <"${physical_waits}" | tr -d ' ')" != "${physical_wait_fails_at}" ]] ||
            return "${physical_wait_status}"
    }
}

# assert_failed_wait WAIT STATUS OUTCOME: the helper returned STATUS. Wait WAIT
# followed dispatch WAIT + 1, and its receipt is ordinal WAIT + 2. Nothing later.
assert_failed_wait() {
    local ordinal
    [[ "${status}" == "$2" ]]
    [[ "$(wc -l <"${physical_calls}" | tr -d ' ')" == $(($1 + 1)) ]]
    [[ "$(wc -l <"${physical_waits}" | tr -d ' ')" == "$1" ]]
    printf -v ordinal '%06d' $(($1 + 2))
    jq -e --arg outcome "$3" '.outcome == $outcome' "${KOINE_VM_EVIDENCE_ROOT}/${ordinal}/result.json"
    jq -e '.transport == "poll-step" and .poll_phase == "sleep"' "${KOINE_VM_EVIDENCE_ROOT}/${ordinal}/request.json"
    assert_blocked
}

@test "a failed resize wait in a conditional caller latches and stops all later input, including the release" {
    local wait
    # Thirteen waits: after the move, after each of eleven held points, after the release.
    for wait in {1..13}; do
        reset_physical "resize-wait-${wait}"
        fail_wait_at "${wait}" 143
        status=0
        drag_window_corner 740 940 || status=$?
        assert_failed_wait "${wait}" 143 interrupted
    done
    reset_physical resize-wait-unavailable
    fail_wait_at 5 1
    status=0
    drag_window_corner 740 940 || status=$?
    assert_failed_wait 5 125 unavailable
}

@test "a failed menu wait in a conditional caller latches and stops the target move and the click" {
    local wait
    # Three waits: after the approach, after the target move, after the click.
    for wait in 1 2 3; do
        reset_physical "menu-wait-${wait}"
        fail_wait_at "${wait}" 143
        status=0
        click_centre '100, 0, 22, 15' || status=$?
        assert_failed_wait "${wait}" 143 interrupted
    done
}
