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
        TESTANYWARE_VM_ID settings_fault settings_fault_status settings_flags settings_at \
        scenario_signal scenario_signal_on settings_untitled_behind
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

# expect_outcome CLASS: status 1 and one classified state-failed receipt,
# with no later input.
expect_outcome() {
    local at
    at="$(call_index "scenario-assertion-$1")"
    if [[ "${status}" != 1 || "${at}" -le 0 || "$(input_after "${at}")" != '[]' ]] || [[ -s "${scenario_legacy}" ]]; then
        echo "expected outcome $1: status ${status}, at ${at}, later input $(input_after "${at}")"
        printf '%s\n' "${output}" | tail -5
        return 1
    fi
    jq -se --argjson n "${at}" '.[$n - 1] | .action == "poll-step" and .outcome == "state-failed"' \
        "${settings_sim}/calls.jsonl"
    [[ "$(jq -s 'map(select((.operation // "") | startswith("scenario-assertion"))) | length' "${settings_sim}/calls.jsonl")" == 1 ]]
}

# expect_order OPERATION...: each operation occurs, in this order.
expect_order() {
    local op previous=0 index
    for op in "$@"; do
        index="$(call_index "${op}")"
        [[ "${index}" -gt "${previous}" ]] || {
            echo "${op} at ${index}, after ${previous}"
            return 1
        }
        previous="${index}"
    done
}

# reset_run: a loop's next run starts from a fresh guest and transcript.
reset_run() {
    rm -f "${settings_sim}/calls.jsonl" "${settings_sim}/state.json"
    rm -rf "${scenario_repo}/.build"
}

# The Nth return, as settings_at counts them.
RETURNS=(first-selection reopen-1 reopen-2 reopen-3 requests accessibility quit)
SELECTIONS=(first-selection reopen-1-selection reopen-2-selection reopen-3-selection
    requests-selection accessibility-selection quit-selection)

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
        installed-after textedit-pid first-selection-identity first-selection-setup-front \
        first-selection-enabled screenshot-menu-first-selection reopen-1-menu-closed \
        screenshot-outcome-reopen-2; do
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
    expect_outcome not-front
    local at
    at="$(call_index scenario-assertion-not-front)"
    jq -se --argjson n "${at}" '.[$n - 1].arguments[2] | contains("did not come to the front over TextEdit")' \
        "${settings_sim}/calls.jsonl"
    # Both predicates keep their receipts on the one list, then the untouched
    # failure observations come before the latch. The front-application read
    # of the message is the observer.
    expect_order first-selection-front first-selection-front-state first-selection-front-title-state \
        first-selection-front-application first-selection-failure-windows failure-capture \
        first-selection-menu-closed scenario-assertion-not-front
    # One failure screenshot: the observations took it, so the stop takes none.
    [[ "$(jq -s 'map(select(.operation == "failure-capture")) | length' "${settings_sim}/calls.jsonl")" == 1 ]]
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

# --- the positive setup ----------------------------------------------------

@test "the positive setup precedes each of the four selections and uses the zero-count list" {
    run_scenario
    [[ "${status}" == 0 ]]
    [[ "${output}" == *'TextEdit: PID 909, window frame [700,120,603,505]'* ]]
    local sel index
    for sel in "${SELECTIONS[@]:0:4}"; do
        # The identity read, the setup reads and the screenshot come directly
        # before the menu opening, with no window read and no wait.
        jq -se --arg s "${sel}" 'map(.operation) as $o | ($o | index($s + "-item-1")) as $i
            | $o[$i - 10:$i] == [$s + "-identity", $s + "-identity-state",
                $s + "-setup-windows-state", $s + "-setup-front", $s + "-setup-front-state",
                $s + "-setup-sheets", $s + "-setup-sheets-state", $s + "-setup-menus",
                $s + "-setup-menus-state", "screenshot-setup-" + $s]' "${settings_sim}/calls.jsonl" || {
            echo "setup sequence of ${sel}"
            return 1
        }
    done
    # The first setup follows the menu count; each later one follows its count poll.
    jq -se 'map(.operation) as $o | ($o | index("first-selection-identity")) as $i
        | $o[$i - 1] == "first-close-count-state"' "${settings_sim}/calls.jsonl"
    for index in 1 2 3; do
        jq -se --arg s "reopen-${index}" 'map(.operation) as $o | ($o | index($s + "-selection-identity")) as $i
            | ($o[$i - 1] | test("^" + $s + "-closed-[0-9]+-state$"))' "${settings_sim}/calls.jsonl"
    done
    # No setup for the later returns or the Quit selections: each setup
    # operation belongs to one of the four selections.
    jq -se 'map((.operation // "") | select(test("-setup-")))
        | length > 0 and all(.[]; test("^(screenshot-setup-)?(first-selection|reopen-[123]-selection)(-setup-|$)"))' \
        "${settings_sim}/calls.jsonl"
    [[ "$(jq -s 'map((.operation // "") | select(test("^requests|^accessibility|^quit|^setup-quit|^final-quit")
        and test("-setup-"))) | length' "${settings_sim}/calls.jsonl")" == 0 ]]
}

@test "a clean setup mismatch before any of the four selections is failed setup and opens no menu" {
    local case flag at sel
    for case in textedit-moved:1 textedit-title:2 front-other-pid:3 textedit-sheet:4 \
        textedit-dialog:1 menu-open-at-setup:2 koine-menu-open-at-setup:3; do
        flag="${case%:*}" at="${case#*:}" sel="${SELECTIONS[$((${case#*:} - 1))]}"
        reset_run
        export settings_flags="${flag}" settings_at="${at}"
        run_scenario
        expect_outcome setup-failed || {
            echo "case ${case}"
            return 1
        }
        [[ "${output}" == *"before ${sel}"* && "$(call_index "${sel}-item-1")" == -1 ]] || {
            echo "case ${case}: the menu of ${sel} opened, or the message names another selection"
            return 1
        }
    done
}

@test "missing or failed setup evidence is unavailable and opens no menu" {
    local case kind name sel at
    for case in flag:textedit-no-title:first-selection fault:textedit-pid:first-selection \
        fault:first-selection-identity:first-selection \
        fault:reopen-1-selection-setup-front:reopen-1-selection \
        fault:reopen-2-selection-setup-sheets:reopen-2-selection \
        fault:reopen-3-selection-setup-menus:reopen-3-selection \
        fault:screenshot-setup-first-selection:first-selection; do
        IFS=: read -r kind name sel <<<"${case}"
        reset_run
        unset settings_flags settings_fault
        if [[ "${kind}" == flag ]]; then export settings_flags="${name}"; else export settings_fault="${name}"; fi
        run_scenario
        at="$(call_index "${name}")"
        [[ "${kind}" == fault ]] || at="$(call_index "${sel}-setup-title")"
        if [[ "${status}" != 125 || "${at}" -le 0 || "$(input_after "${at}")" != '[]' ]] ||
            [[ "$(call_index "${sel}-item-1")" != -1 ]]; then
            echo "case ${case}: status ${status}, at ${at}, later input $(input_after "${at}")"
            printf '%s\n' "${output}" | tail -3
            return 1
        fi
    done
}

@test "two TextEdit processes after the preparation are failed setup" {
    export settings_flags=textedit-pids
    run_scenario
    expect_outcome setup-failed
    [[ "$(call_index first-selection-item-1)" == -1 ]]
}

# --- the route and the outcome classes -------------------------------------

@test "each return records its route and its closed menu, and the Quit selections keep theirs" {
    run_scenario
    [[ "${status}" == 0 ]]
    local index sel ret
    for index in 0 1 2 3 4 5 6; do
        sel="${SELECTIONS[${index}]}" ret="${RETURNS[${index}]}"
        # The enabled row and the open-menu screenshot come between the row
        # frame and the click, and the closed menu after the front checks.
        jq -se --arg s "${sel}" --arg r "${ret}" 'map(.operation) as $o
            | ($o | index($s + "-enabled")) as $e
            | ($o[$e - 1] | test("^" + $s + "-row-[0-9]+-state$"))
            and $o[$e + 1:$e + 3] == [$s + "-enabled-state", "screenshot-menu-" + $s]
            and ($o[$e + 3:] | index("menu-click")) != null
            and ($o[$e + 3:] | index("menu-click")) < ($o[$e + 3:] | index($r + "-window-1"))
            and ($o | index($r + "-front-title-state")) < ($o | index($r + "-menu-closed"))' \
            "${settings_sim}/calls.jsonl" || {
            echo "route of ${sel}"
            return 1
        }
    done
    # Each return has its outcome screenshot before the next input.
    expect_order screenshot-over-textedit screenshot-outcome-reopen-1 screenshot-outcome-reopen-2 \
        screenshot-outcome-reopen-3 screenshot-requests screenshot-outcome-accessibility \
        screenshot-outcome-reopen screenshot-outcome-quit
    [[ "$(call_index setup-quit-enabled)" == -1 && "$(call_index screenshot-menu-setup-quit)" == -1 ]]
    [[ "$(call_index final-quit-enabled)" == -1 && "$(call_index final-quit-menu-closed)" == -1 ]]
    # The resize focus keeps its front check, and the title audit joins it.
    expect_order resize-front-state resize-front-title-state
}

@test "the setup and the closed-menu checks enumerate the menus under each item (k162)" {
    run_scenario
    [[ "${status}" == 0 ]]
    # Each setup reads the menus under the TextEdit and Koine items. Each
    # closed-menu check reads the menus under the Koine item. No check reads
    # the selection of an item.
    jq -se 'map(select((.operation // "") | test("-setup-menus$")))
        | length == 4 and all(.[]; .action == "read" and .arguments == ["menu-bar-menus"])' \
        "${settings_sim}/calls.jsonl"
    jq -se 'map(select((.operation // "") | test("-menu-closed$")))
        | length == 7 and all(.[]; .action == "read" and .arguments == ["koine-menus"])' \
        "${settings_sim}/calls.jsonl"
    [[ "$(jq -s 'map(select(.action == "read" and (.arguments[0] == "open-menus"
        or .arguments[0] == "menu-item-selected"))) | length' "${settings_sim}/calls.jsonl")" == 0 ]]
}

@test "a disabled row is recorded and not clicked" {
    export settings_flags=row-disabled settings_at=2
    run_scenario
    expect_outcome menu-item-disabled
    expect_order reopen-1-selection-enabled-state scenario-assertion-menu-item-disabled
    [[ "$(call_index screenshot-menu-reopen-1-selection)" == -1 ]]
}

@test "a menu that stays open after the click makes the outcome unresolved" {
    export settings_flags=menu-stays-open
    run_scenario
    expect_outcome menu-open
    [[ "${output}" == *'the menu stayed open after first-selection, so the outcome is unresolved'* ]]
    expect_order first-selection-front-title-state first-selection-menu-closed-state \
        scenario-assertion-menu-open
}

@test "a wrong title on the front list is a window-identity failure, for later returns too" {
    local at ret
    for at in 1 5 7; do
        ret="${RETURNS[$((at - 1))]}"
        reset_run
        export settings_flags=wrong-title settings_at="${at}"
        run_scenario
        expect_outcome window-identity || {
            echo "return ${ret}"
            return 1
        }
        # The front predicate holds on the same list, and the audit does not.
        jq -se --arg r "${ret}" '(map(select(.operation == $r + "-front-state"))[0].arguments[1] == "0")
            and (map(select(.operation == $r + "-front-title-state"))[0].arguments[1] == "1")' \
            "${settings_sim}/calls.jsonl"
        expect_order "${ret}-front-title-state" "${ret}-front-application" "${ret}-failure-windows" \
            failure-capture "${ret}-menu-closed" scenario-assertion-window-identity
    done
}

@test "a Koine window without a title makes the audit unavailable" {
    export settings_flags=no-title
    run_scenario
    [[ "${status}" == 125 ]]
    local at
    at="$(call_index first-selection-front-title)"
    # The audit's own refusal stops the scenario, not a later read.
    [[ "${at}" -gt 0 && "${output}" == *'the title audit of first-selection is unavailable'* ]]
    jq -se --argjson n "${at}" '.[$n - 1].action == "fail"' "${settings_sim}/calls.jsonl"
    [[ "$(input_after "${at}")" == '[]' ]]
    [[ "$(call_index scenario-assertion-window-identity)" == -1 ]]
}

@test "an unavailable title audit beside a false front predicate stays unavailable (k162)" {
    local op ret at
    # The app reopen and the resize focus judge a list whose front window is
    # Finder's and whose one Koine window has no title.
    for op in reopen-front resize-front; do
        reset_run
        export settings_untitled_behind="${op}"
        run_scenario
        at="$(call_index "${op}-title")"
        if [[ "${status}" != 125 || "${at}" -le 0 ]]; then
            echo "case ${op}: status ${status}, title audit at ${at}"
            printf '%s\n' "${output}" | tail -3
            return 1
        fi
        # The front predicate is a clean false on the same list.
        jq -se --arg op "${op}" 'map(select(.operation == $op + "-state"))[0].arguments[1] == "1"' \
            "${settings_sim}/calls.jsonl"
        jq -se --argjson n "${at}" '.[$n - 1].action == "fail"' "${settings_sim}/calls.jsonl"
        [[ "$(input_after "${at}")" == '[]' ]]
        [[ "$(jq -s 'map(select((.operation // "") | startswith("scenario-assertion"))) | length' \
            "${settings_sim}/calls.jsonl")" == 0 ]] || {
            echo "case ${op}: a clean outcome class replaced the unavailable audit"
            return 1
        }
        [[ "${output}" == *"the title audit of ${op%-front}"*" is unavailable"* ]]
    done
    # The reopen keeps its untouched failure observations after the audit.
    reset_run
    export settings_untitled_behind=reopen-front
    run_scenario
    expect_order reopen-front-title reopen-failure-windows failure-capture
}

@test "two Koine windows after a selection are a multiple-windows failure" {
    export settings_flags=two-windows
    run_scenario
    expect_outcome multiple-windows
    [[ "${output}" == *'Koine has 2 windows, not 1'* ]]
    # The deferred exhaustion follows the untouched observations and the closed menu.
    expect_order first-selection-window-10 first-selection-front-application \
        first-selection-failure-windows failure-capture first-selection-menu-closed \
        first-selection-window-exhausted scenario-assertion-multiple-windows
    [[ "$(call_index first-selection-liveness)" == -1 ]]
}

@test "zero windows with the same live process are a same-process recurrence, for later returns too" {
    local at ret
    for at in 1 6; do
        ret="${RETURNS[$((at - 1))]}"
        reset_run
        export settings_flags=zero-window-alive settings_at="${at}"
        run_scenario
        expect_outcome zero-window-same-process || {
            echo "return ${ret}"
            return 1
        }
        # The liveness read is clean because nothing has latched before it.
        expect_order "${ret}-window-10" "${ret}-liveness" "${ret}-liveness-state" \
            "${ret}-front-application" "${ret}-failure-windows" failure-capture "${ret}-menu-closed" \
            "${ret}-window-exhausted" scenario-assertion-zero-window-same-process
        jq -se --arg r "${ret}" 'map(select(.operation == $r + "-liveness"))[0]
            | .outcome == "clean" and .arguments == ["process-identity", "101"]' "${settings_sim}/calls.jsonl"
        jq -se --arg r "${ret}" 'map(select(.operation == $r + "-failure-windows"))[0].kind == "evidence"' \
            "${settings_sim}/calls.jsonl"
    done
}

@test "a lost or replaced process after zero windows is process loss, not a recurrence" {
    local case flag at ret
    for case in zero-window-crash:3 zero-window-reused:1; do
        flag="${case%:*}" at="${case#*:}" ret="${RETURNS[$((${case#*:} - 1))]}"
        reset_run
        export settings_flags="${flag}" settings_at="${at}"
        run_scenario
        expect_outcome process-lost || {
            echo "case ${case}"
            return 1
        }
        [[ "${output}" == *'process lost during selection'* ]]
        expect_order "${ret}-liveness-state" "${ret}-front-application" failure-capture \
            "${ret}-window-exhausted" scenario-assertion-process-lost
        # A lost process has no menu to read.
        [[ "$(call_index "${ret}-menu-closed")" == -1 ]]
    done
}

@test "a failed liveness read leaves the zero-window outcome unresolved" {
    export settings_flags=zero-window-alive settings_fault=first-selection-liveness
    run_scenario
    [[ "${status}" == 125 ]]
    [[ "${output}" == *'its liveness is unavailable, so the outcome is unresolved'* ]]
    local at
    at="$(call_index first-selection-liveness)"
    [[ "$(input_after "${at}")" == '[]' ]]
    # The observer is refused after the latch, and its text is never used.
    jq -se 'map(select(.operation == "first-selection-front-application"))[0].outcome == "refused"' \
        "${settings_sim}/calls.jsonl"
    expect_order first-selection-liveness first-selection-failure-windows failure-capture \
        first-selection-window-exhausted
    [[ "$(jq -s 'map(select((.operation // "") | startswith("scenario-assertion"))) | length' "${settings_sim}/calls.jsonl")" == 0 ]]
}

@test "an app reopen that shows no window compares the silent launch's process" {
    export settings_flags=reopen-no-window
    run_scenario
    expect_outcome zero-window-same-process
    # The silent launch's PID, and no menu read for a reopen.
    jq -se 'map(select(.operation == "reopen-liveness"))[0].arguments == ["process-identity", "202"]' \
        "${settings_sim}/calls.jsonl"
    [[ "$(call_index reopen-menu-closed)" == -1 ]]
    expect_order reopen-identity reopen-window-10 reopen-liveness reopen-front-application \
        reopen-window-exhausted scenario-assertion-zero-window-same-process
}
