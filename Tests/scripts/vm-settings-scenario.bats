#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Every test owns its environment.
# The adopted Settings scenario, scripts/vm-verify-menu-bar.sh, without a VM.
#
# Most tests run the real entry point in a copied repository. A simulated
# backend (Tests/scripts/fixtures/settings-scenario-backend.py) takes the place
# of scripts/vm-guest-exec.py, so every shell facade runs unchanged and each of
# its calls is logged. The signal controls instead run the real backend with a
# fixture CLI, so their receipts are the real ordered receipts.

setup() {
    bats_require_minimum_version 1.5.0
    local root="${BATS_TEST_DIRNAME}/../.."
    export scenario_repo="${BATS_TEST_TMPDIR}/repo"
    export settings_sim="${BATS_TEST_TMPDIR}/sim"
    export scenario_legacy="${BATS_TEST_TMPDIR}/legacy-cli"
    export scenario_waits="${BATS_TEST_TMPDIR}/waits"
    mkdir -p "${scenario_repo}/App" "${scenario_repo}/bundle/Koine.app/Contents" \
        "${settings_sim}" "${BATS_TEST_TMPDIR}/bin"
    cp -R "${root}/scripts" "${scenario_repo}/scripts"
    cp "${root}/App/Info.plist" "${scenario_repo}/App/Info.plist"
    echo bundle >"${scenario_repo}/bundle/Koine.app/Contents/Info.plist"
    cp "${root}/Tests/scripts/fixtures/settings-scenario-backend.py" \
        "${scenario_repo}/scripts/vm-guest-exec.py"
    : >"${scenario_legacy}"
    : >"${scenario_waits}"
    # A bare CLI call would bypass the root. The fence must make this unreachable.
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
printf '%s\n' "$*" >>"${scenario_legacy}"
exit 97
CLI
    # Waits are recorded, not slept. A test can arm one signal at a wait.
    cat >"${BATS_TEST_TMPDIR}/bin/sleep" <<'SLEEP'
#!/bin/bash
printf '%s\n' "$1" >>"${scenario_waits}"
if [[ -n "${scenario_signal_on:-}" && "$1" == "${scenario_signal_on}" && ! -e "${scenario_waits}.signalled" ]]; then
    : >"${scenario_waits}.signalled"
    kill "-${scenario_signal}" "${PPID}"
fi
exit 0
SLEEP
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware" "${BATS_TEST_TMPDIR}/bin/sleep"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    export KOINE_APP_BUNDLE="${scenario_repo}/bundle/Koine.app"
    export KOINE_VM_BASE=testanyware-golden-macos-27 KOINE_VM_ID=exact-settings-vm
    unset KOINE_VM_EVIDENCE_ROOT KOINE_VM_DISPLAY KOINE_VM_KEEP KOINE_SETTINGS_TRACE \
        TESTANYWARE_VM_ID settings_fault settings_fault_status settings_flags \
        scenario_signal scenario_signal_on
}

run_scenario() {
    run "${scenario_repo}/scripts/vm-verify-menu-bar.sh"
}

# refute PATTERN FILE: Bats does not fail a test on a negated grep.
refute() {
    if grep -q -- "$1" "$2"; then
        grep -n -- "$1" "$2"
        return 1
    fi
}

# The ordinal (1-based line) of the first call whose operation is $1.
call_index() {
    jq -rs --arg op "$1" 'map(.operation) | index($op) | if . == null then -1 else . + 1 end' \
        "${settings_sim}/calls.jsonl"
}

# Calls after line $1 that could change the guest: anything but an
# evidence-class collection or a local record.
input_after() {
    jq -cs --argjson n "$1" '.[$n:] | map(select(
        (.action == "cli" or .action == "read" or .action == "upload")
        and .kind != "evidence" and .outcome != "refused"))' "${settings_sim}/calls.jsonl"
}

@test "the adopted scenario runs to PASSED with every call in one root initialised first" {
    run_scenario
    [[ "${status}" == 0 ]] || {
        printf '%s\n' "${output}" | tail -30
        return 1
    }
    [[ "${output}" == *'== PASSED'* ]]
    [[ ! -s "${scenario_legacy}" ]]
    # init is the first backend call, then every call names the same root.
    jq -se '.[0].action == "init" and .[0].vm == "exact-settings-vm"
        and (map(.root) | unique | length == 1)
        and all(.[1:][]; .outcome == "clean")' "${settings_sim}/calls.jsonl"
    # The start is bracketed by the absent and running inventories.
    jq -se 'map(select(.action == "cli") | .operation)[:3] == ["vm-before", "vm-start", "vm-after"]' \
        "${settings_sim}/calls.jsonl"
    # The scenario sends no stop; the finite caller owns it.
    refute '"stop"' "${settings_sim}/calls.jsonl"
    [[ "${output}" == *'sent no VM stop'* ]]
}

@test "the adopted scenario keeps the checked confirmations in their existing positions" {
    run_scenario
    [[ "${status}" == 0 ]]
    local op previous=0 index
    # Each confirmation follows its submission, in the scenario's order.
    for op in extract-bundle signature automation-request automation-allow-ocr \
        automation-check defaults-before-launch first-launch first-launch-endpoint-1 \
        first-launch-identity textedit-launch textedit-window-1 textedit-quit \
        textedit-quit-absence accessibility-pane accessibility-add-1 silent-launch \
        silent-launch-identity reopen reopen-identity boot-before restart \
        restart-boot-1 defaults-after-restart login-endpoint-1 login-process \
        port-descriptor port-refusal installed-after; do
        index="$(call_index "${op}")"
        [[ "${index}" -gt "${previous}" ]] || {
            echo "${op} at ${index}, after ${previous}"
            return 1
        }
        previous="${index}"
    done
    # The reopen compares with the silent launch's identity record.
    jq -se 'map(select(.operation == "reopen-identity"))[0].arguments[0] == "launch-identity"' \
        "${settings_sim}/calls.jsonl"
}

# One unavailable answer in each transport family. Each must stop the scenario
# with that status and leave no later input: only the evidence-class failure
# screenshot may follow.
@test "an unavailable answer in any transport family stops every later scenario input" {
    local fault at
    for fault in vm-before vm-start upload-bundle extract-bundle signature automation-allow-ocr \
        automation-check defaults-before-launch first-launch first-launch-endpoint-1 \
        first-launch-identity first-launch-label-1 first-launch-menu-item-1 first-launch-menu \
        screenshot-first-launch textedit-window-1 reopen-2-front resize-move resize-down-3 \
        least-size-login-1 shortcut-type enrol-vm-editor requests-deny-1-click \
        accessibility-add-1 reopen-identity restart restart-boot-1 login-process port-refusal \
        installed-after; do
        rm -f "${settings_sim}/calls.jsonl" "${settings_sim}/state.json"
        rm -rf "${scenario_repo}/.build"
        export settings_fault="${fault}"
        run_scenario
        at="$(call_index "${fault}")"
        if [[ "${status}" != 125 || "${at}" -le 0 || "$(input_after "${at}")" != '[]' ]] ||
            [[ "${output}" != *'FAILED: '* ]] || [[ -s "${scenario_legacy}" ]]; then
            echo "fault ${fault}: status ${status}, at ${at}, later input $(input_after "${at}")"
            printf '%s\n' "${output}" | tail -5
            return 1
        fi
        jq -se --argjson n "${at}" '.[$n:] | map(select(.action == "capture"))
            | length <= 1 and all(.[]; .kind == "evidence")' "${settings_sim}/calls.jsonl"
    done
}

@test "a failed read keeps the legacy failure message" {
    export settings_fault=reopen-2-front
    run_scenario
    [[ "${status}" == 125 ]]
    [[ "${output}" == *'FAILED: Settings reopen 2 did not bring the window to the front'* ]]
}

@test "a clean false state records the legacy message as state-failed and stops" {
    export settings_flags=no-front-after-settings
    run_scenario
    [[ "${status}" == 1 ]]
    [[ "${output}" == *'did not come to the front over TextEdit'* ]]
    local at
    at="$(call_index scenario-assertion)"
    # The front-application read of the message precedes the latch.
    [[ "$(call_index first-selection-front-application)" -lt "${at}" ]]
    jq -se --argjson n "${at}" '.[$n - 1] | .action == "poll-step" and .outcome == "state-failed"
        and (.arguments[2] | contains("did not come to the front over TextEdit"))' \
        "${settings_sim}/calls.jsonl"
    [[ "$(input_after "${at}")" == '[]' ]]
}

@test "a fenced legacy transport latches instead of dispatching" {
    # Mutation: a bare CLI call after the install step.
    sed -i '' 's/^settings_install_app$/settings_install_app; testanyware agent windows --json/' \
        "${scenario_repo}/scripts/vm-verify-menu-bar.sh"
    grep -q 'testanyware agent windows --json' "${scenario_repo}/scripts/vm-verify-menu-bar.sh"
    run_scenario
    [[ "${status}" == 125 ]]
    [[ ! -s "${scenario_legacy}" ]]
    local at
    at="$(call_index legacy-transport)"
    [[ "${at}" -gt 0 ]]
    [[ "$(input_after "${at}")" == '[]' ]]
}

@test "KOINE_SETTINGS_TRACE=1 refuses before the first launch and sends nothing for it" {
    export KOINE_SETTINGS_TRACE=1
    run_scenario
    [[ "${status}" == 125 ]]
    [[ "$(call_index trace-defaults)" -gt 0 ]]
    [[ "$(call_index first-launch)" == -1 ]]
}

@test "a missing golden base latches before any VM start" {
    unset KOINE_VM_BASE
    run_scenario
    [[ "${status}" == 125 ]]
    jq -se 'map(select(.operation == "vm-start")) | length == 1 and .[0].action == "fail"' \
        "${settings_sim}/calls.jsonl"
    [[ "$(input_after 0 | jq 'map(select(.operation != "vm-before")) | length')" == 0 ]]
}

@test "an existing evidence root is refused before any transport" {
    export KOINE_VM_EVIDENCE_ROOT="${BATS_TEST_TMPDIR}/reused"
    mkdir "${KOINE_VM_EVIDENCE_ROOT}"
    run_scenario
    [[ "${status}" != 0 ]]
    [[ ! -s "${settings_sim}/calls.jsonl" && ! -s "${scenario_legacy}" ]]
}

@test "HUP during a scenario wait records the signal and sends nothing more" {
    # The first 8-second wait is the TextEdit settling sleep.
    export scenario_signal=HUP scenario_signal_on=8
    run_scenario
    [[ "${status}" == 129 ]]
    [[ "$(tail -1 "${scenario_waits}")" == 8 ]]
    [[ "$(grep -cx 8 "${scenario_waits}")" == 1 ]]
    local at
    at="$(call_index scenario-signal-HUP)"
    [[ "${at}" -gt 0 ]]
    jq -se --argjson n "${at}" 'length == $n and .[$n - 1].action == "fail"' \
        "${settings_sim}/calls.jsonl"
    [[ "${output}" == *'INTERRUPTED: SIGHUP'* && "${output}" == *'sent no VM stop'* ]]
}

# --- held-pointer controls with the real backend ---------------------------

# The real backend, a fixture CLI and the Settings traps around the reviewed
# resize helper. The fixture can interrupt one held-point attempt.
signal_driver() {
    local real="${BATS_TEST_DIRNAME}/../../scripts"
    export signal_calls="${BATS_TEST_TMPDIR}/signal-calls"
    export signal_root="${BATS_TEST_TMPDIR}/signal-evidence"
    : >"${signal_calls}"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
set -euo pipefail
jq -cn --args '$ARGS.positional' -- "$@" >>"${signal_calls}"
case "$1 $2" in
    'agent windows') payload='{"windows":[{"title":"Koine Settings","appName":"Koine","windowType":"standard","focused":true,"positionX":40,"positionY":40,"sizeWidth":480,"sizeHeight":712}]}' ;;
    'input move') payload=$(jq -cn --argjson x "$3" --argjson y "$4" '{x:$x,y:$y}') ;;
    'input mouse-down'|'input mouse-up') payload=$(jq -cn --argjson x "$3" --argjson y "$4" '{x:$x,y:$y,button:"left"}') ;;
    *) exit 98 ;;
esac
jq -cn --argjson payload "${payload}" '{schema_version:"1.0",ok:true} + $payload'
downs="$(grep -c mouse-down "${signal_calls}" || :)"
if [[ "$2" == mouse-down && "${signal_attempt:-}" == "${downs}" ]]; then
    # A terminal interrupt reaches the backend and the scenario together.
    kill -INT "${PPID}" "${settings_driver_pid}"
    /bin/sleep 0.2
fi
CLI
    cat >"${BATS_TEST_TMPDIR}/bin/sleep" <<'SLEEP'
#!/bin/bash
printf '%s\n' "$1" >>"${scenario_waits}"
downs="$(grep -c mouse-down "${signal_calls}" || :)"
if [[ -n "${signal_sleep_after:-}" && "${downs}" == "${signal_sleep_after}" && ! -e "${scenario_waits}.signalled" ]]; then
    : >"${scenario_waits}.signalled"
    kill -TERM "${PPID}"
fi
# The wait process alone fails, as if it received TERM. No trap runs.
if [[ -n "${signal_fail_sleep_after:-}" && "${downs}" == "${signal_fail_sleep_after}" && ! -e "${scenario_waits}.failed" ]]; then
    : >"${scenario_waits}.failed"
    exit 143
fi
exit 0
SLEEP
    cat >"${BATS_TEST_TMPDIR}/driver.sh" <<SH
#!/bin/bash
set -euo pipefail
# shellcheck source=/dev/null
source "${real}/vm-settings-scenario-lib.sh"
WINDOW_TITLE='Koine Settings' VM_ID=exact-signal-vm WORK="${BATS_TEST_TMPDIR}"
settings_begin "\${signal_root}" exact-signal-vm
export settings_driver_pid=\$\$
# The scenario's own conditional call, in which Bash ignores errexit.
drag_window_corner 740 940 || settings_stop "\$?" "the corner drag to 740, 940 did not complete cleanly"
echo after-drag
SH
    chmod +x "${BATS_TEST_TMPDIR}/driver.sh"
    run "${BATS_TEST_TMPDIR}/driver.sh"
}

# operation:outcome for each real receipt, in ordinal order.
receipts() {
    local directory
    for directory in "${signal_root}"/[0-9][0-9][0-9][0-9][0-9][0-9]; do
        printf '%s:%s\n' "$(jq -r .operation "${directory}/request.json")" \
            "$(jq -r '.outcome // "partial"' "${directory}/result.json" 2>/dev/null || echo partial)"
    done
}

@test "TERM in the settling sleep after a clean held point sends no further input or release" {
    export signal_sleep_after=3
    # A permissive umask still gives a root that only its owner can enter.
    umask 022
    signal_driver
    [[ "${status}" == 143 ]]
    [[ "$(stat -f %Lp "${signal_root}")" == 700 ]]
    [[ "${output}" != *after-drag* ]]
    receipts >"${BATS_TEST_TMPDIR}/receipts"
    [[ "$(tail -2 "${BATS_TEST_TMPDIR}/receipts")" == $'resize-down-2:clean\nscenario-signal-TERM:unavailable' ]]
    refute '^resize-release:' "${BATS_TEST_TMPDIR}/receipts"
    refute '^resize-down-3:' "${BATS_TEST_TMPDIR}/receipts"
    [[ "$(grep -c mouse-down "${signal_calls}")" == 3 ]]
    refute mouse-up "${signal_calls}"
    [[ "${output}" == *'Held pointer: held'* ]]
    grep -q 'scenario interrupted by SIGTERM' "${signal_root}/unavailable"
}

@test "a failed settling wait after a clean held point stops input and release without a trap" {
    export signal_fail_sleep_after=3
    signal_driver
    [[ "${status}" == 143 ]]
    [[ "${output}" != *after-drag* ]]
    receipts >"${BATS_TEST_TMPDIR}/receipts"
    # Only the evidence-class failure screenshot may follow the wait's receipt.
    [[ "$(grep -v '^failure-capture:' "${BATS_TEST_TMPDIR}/receipts" | tail -2)" == $'resize-down-2:clean\nresize-hold-2-wait:interrupted' ]]
    refute '^resize-release:' "${BATS_TEST_TMPDIR}/receipts"
    refute '^resize-down-3:' "${BATS_TEST_TMPDIR}/receipts"
    [[ "$(grep -c mouse-down "${signal_calls}")" == 3 ]]
    refute mouse-up "${signal_calls}"
    [[ "${output}" == *'Held pointer: held'* ]]
    [[ "${output}" == *'the corner drag to 740, 940 did not complete cleanly (evidence status 143)'* ]]
    [[ -s "${signal_root}/unavailable" ]]
}

@test "INT during a held-point attempt keeps it interrupted and sends no release" {
    export signal_attempt=4
    signal_driver
    [[ "${status}" == 130 ]]
    [[ "${output}" != *after-drag* ]]
    receipts >"${BATS_TEST_TMPDIR}/receipts"
    [[ "$(tail -2 "${BATS_TEST_TMPDIR}/receipts")" == $'resize-down-3:interrupted\nscenario-signal-INT:unavailable' ]]
    refute '^resize-release:' "${BATS_TEST_TMPDIR}/receipts"
    refute mouse-up "${signal_calls}"
    [[ "${output}" == *'Held pointer: uncertain'* ]]
}

# --- the caller inventory --------------------------------------------------

# Legacy transports in command position, outside comments.
legacy_calls() {
    grep -nE '(^|[;&|({]|\$\(|\bthen|\bdo|\belse)[[:space:]]*(testanyware|guest|guest_text|guest_json|guest_once|guest_long|sysevents|snapshot|element|value_of|click|reveal|reveal_click|on_screen|read_frame|frame|koine_windows|await_windows|front_windows|koine_in_front|menu_item_count|menu_item_label|await_menu_item_label|open_menu|read_menu|menu_titles|expect_menu|choose_menu_item|grant_accessibility|grant_system_events_automation|install_app|start_vm|start_vm_without_keepalive|record_installed_bundle|enrol|await_koine|await_settled|expect_stopped|calibrate_window_scroll|scroll_by|fail)([[:space:]]|$|\))' "$@" |
        grep -vE '^[^:]+:[0-9]+:[[:space:]]*#' || :
}

@test "the caller inventory finds no legacy transport in the adopted scenario surface" {
    local scripts="${BATS_TEST_DIRNAME}/../../scripts"
    local before="${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/ordering-scenario-evidence/scenario-before.sh"
    # Positive control: the instrument finds the legacy callers it targets.
    [[ "$(legacy_calls "${before}" | wc -l | tr -d ' ')" -gt 100 ]]
    [[ -z "$(legacy_calls "${scripts}/vm-verify-menu-bar.sh" "${scripts}/vm-settings-scenario-lib.sh")" ]]
    # Mutation control: one injected legacy call is found.
    cp "${scripts}/vm-verify-menu-bar.sh" "${BATS_TEST_TMPDIR}/mutated.sh"
    echo 'guest true' >>"${BATS_TEST_TMPDIR}/mutated.sh"
    [[ "$(legacy_calls "${BATS_TEST_TMPDIR}/mutated.sh" | wc -l | tr -d ' ')" == 1 ]]
}

# --- the request label and the transcript ----------------------------------

@test "a request label without its value is unavailable before the screenshot and the denials" {
    # The on-screen read needs no value, so it stays clean.
    export settings_flags=request-label-no-value
    run_scenario
    [[ "${status}" == 125 ]]
    [[ "${output}" == *'FAILED: the request label could not be read'* ]]
    local at
    at="$(call_index requests-label)"
    [[ "$(call_index requests-on-screen)" -lt "${at}" ]]
    jq -se --argjson n "${at}" '.[$n - 1].outcome == "unavailable"' "${settings_sim}/calls.jsonl"
    [[ "$(input_after "${at}")" == '[]' ]]
    [[ "$(call_index screenshot-requests)" == -1 ]]
}

# Two runs in one timestamp second choose one transcript name.
same_second() {
    export scenario_stamp=20261122T040000
    cat >"${BATS_TEST_TMPDIR}/bin/date" <<'DATE'
#!/bin/bash
if [[ "$*" == '+%Y%m%dT%H%M%S' ]]; then
    echo "${scenario_stamp}"
    exit 0
fi
exec /bin/date "$@"
DATE
    chmod +x "${BATS_TEST_TMPDIR}/bin/date"
    export earlier_log="${scenario_repo}/.build/vm-verify/menu-bar-${scenario_stamp}.log"
    mkdir -p "${earlier_log%/*}"
    printf 'the earlier run\n' >"${earlier_log}"
    cp "${earlier_log}" "${BATS_TEST_TMPDIR}/earlier.log"
}

@test "an earlier transcript with its default root survives a refused run in the same second" {
    same_second
    mkdir "${earlier_log%.log}-evidence"
    run_scenario
    # The duty first: the earlier bytes survive. Then the refusal itself.
    cmp "${BATS_TEST_TMPDIR}/earlier.log" "${earlier_log}"
    [[ "${status}" == 2 ]]
    [[ "${output}" == *'already exists'* ]]
    [[ ! -s "${settings_sim}/calls.jsonl" && ! -s "${scenario_legacy}" ]]
}

@test "an earlier transcript survives a run in the same second with a distinct root" {
    same_second
    export KOINE_VM_EVIDENCE_ROOT="${BATS_TEST_TMPDIR}/distinct"
    run_scenario
    # The duty first: the earlier bytes survive. Then the refusal itself.
    cmp "${BATS_TEST_TMPDIR}/earlier.log" "${earlier_log}"
    [[ "${status}" == 2 ]]
    [[ "${output}" == *'already exists'* ]]
    [[ ! -e "${KOINE_VM_EVIDENCE_ROOT}" ]]
    [[ ! -s "${settings_sim}/calls.jsonl" && ! -s "${scenario_legacy}" ]]
}
