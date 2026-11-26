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
    # shellcheck source=Tests/scripts/fixtures/declared-tools.sh
    source "${BATS_TEST_DIRNAME}/fixtures/declared-tools.sh"
    declare_tools "${BATS_TEST_TMPDIR}/bin/testanyware"
    export KOINE_APP_BUNDLE="${scenario_repo}/bundle/Koine.app"
    export KOINE_VM_BASE=testanyware-golden-macos-27 KOINE_VM_ID=exact-settings-vm
    unset KOINE_VM_EVIDENCE_ROOT KOINE_VM_DISPLAY KOINE_VM_KEEP KOINE_SETTINGS_TRACE \
        TESTANYWARE_VM_ID settings_fault settings_fault_status settings_flags settings_at \
        scenario_signal scenario_signal_on settings_untitled_behind settings_finder_front \
        settings_close_ignored settings_no_value
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

@test "a lost restart reply with a changed boot runs through the login assertions to PASSED (k8)" {
    export settings_flags=restart-reply-lost
    run_scenario
    [[ "${status}" == 0 ]] || {
        printf '%s\n' "${output}" | tail -30
        return 1
    }
    [[ "${output}" == *'== PASSED'* && ! -s "${scenario_legacy}" ]]
    jq -se 'all(.[1:][]; .outcome == "clean")
        and (map(select(.operation == "restart")) | length == 1 and .[0].reply == "lost")' \
        "${settings_sim}/calls.jsonl"
    expect_order restart restart-boot-1 defaults-after-restart login-endpoint-1 login-process \
        login-launch-endpoint-1 login-windows final-stopped-process final-stopped-descriptor
}

@test "a lost restart reply with an unchanged boot stops at the restart as a test-driver or guest failure (k8)" {
    export settings_flags=restart-reply-lost,boot-stuck
    run_scenario
    [[ "${status}" == 125 ]]
    [[ "${output}" == *'FAILED: the VM did not come back from its restart; a test-driver or guest failure, not a Koine failure'* ]]
    jq -se 'map(select(.operation == "restart-boot-exhausted")) | length == 1 and .[0].outcome == "state-failed"' \
        "${settings_sim}/calls.jsonl"
    [[ "$(call_index login-endpoint-1)" == -1 ]]
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
        installed-after textedit-pid first-selection-identity first-selection-setup-sheets \
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
# pointer_fault is exit:POINT or kill:POINT, and POINT is up or down:N. An exit
# is a failed CLI. A kill ends the backend before its result, so the attempt is partial.
point=''
case "$2" in
    mouse-down) point="down:$(($(grep -c mouse-down "${signal_calls}") - 1))" ;;
    mouse-up) point=up ;;
esac
if [[ -n "${point}" && "${pointer_fault:-}" == *":${point}" ]]; then
    if [[ "${pointer_fault}" == kill:* ]]; then kill -KILL "${PPID}"; fi
    exit 7
fi
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

@test "the root of a failed settling wait classifies as interrupted" {
    export signal_fail_sleep_after=3
    signal_driver
    [[ "${status}" == 143 ]]
    refute 'scenario-signal-' <(receipts)
    python3 -I "${BATS_TEST_DIRNAME}/../../scripts/settings-ordering-sequence.py" classify \
        "${signal_root}" ordinary "$(jq -r .vm "${signal_root}/subject.json")" >"${BATS_TEST_TMPDIR}/class"
    jq -e '.kind == "interrupted" and .signals == [] and .first_failure.outcome == "interrupted"' \
        "${BATS_TEST_TMPDIR}/class"
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

@test "an omitted AXValue at shortcut-emptied is unavailable and is not an empty value (k175)" {
    # The control run reads a real empty string at the same operation.
    run_scenario
    [[ "${status}" == 0 ]]
    jq -se 'any(.[]; .operation == "shortcut-emptied-state" and .outcome == "clean")' \
        "${settings_sim}/calls.jsonl"
    reset_run
    export settings_no_value=shortcut-emptied
    run_scenario
    [[ "${status}" == 125 ]]
    [[ "${output}" == *'FAILED: ⌘A ⌘X did not empty the field (evidence status 125)'* ]]
    local at
    at="$(call_index shortcut-emptied)"
    [[ "${at}" -gt 0 ]]
    jq -se --argjson n "${at}" '.[$n - 1].outcome == "unavailable"' "${settings_sim}/calls.jsonl"
    # No state was judged, so the omission is neither an empty value nor a false state.
    [[ "$(call_index shortcut-emptied-state)" == -1 ]]
    refute 'scenario-assertion' "${settings_sim}/calls.jsonl"
    [[ "$(input_after "${at}")" == '[]' ]]
    [[ "$(call_index shortcut-paste)" == -1 ]]
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
            | $o[$i - 9:$i] == [$s + "-identity", $s + "-identity-state",
                $s + "-setup-windows-state", $s + "-setup-front-state",
                $s + "-setup-sheets", $s + "-setup-sheets-state", $s + "-setup-menus",
                $s + "-setup-menus-state", "screenshot-setup-" + $s]' "${settings_sim}/calls.jsonl" || {
            echo "setup sequence of ${sel}"
            return 1
        }
    done
    # The first setup follows the menu count and judges the zero-count list.
    # Each reopen setup follows its count poll, the focus step and the one
    # window read after it, and judges that list (k6).
    jq -se 'map(.operation) as $o | ($o | index("first-selection-identity")) as $i
        | $o[$i - 1] == "first-close-count-state"' "${settings_sim}/calls.jsonl"
    for index in 1 2 3; do
        jq -se --arg s "reopen-${index}" 'map(.operation) as $o | ($o | index($s + "-selection-identity")) as $i
            | $o[$i - 2:$i] == [$s + "-focus", $s + "-focused"]
            and ($o[$i - 3] | test("^" + $s + "-closed-[0-9]+-state$"))' "${settings_sim}/calls.jsonl" || {
            echo "focus step of reopen-${index}"
            return 1
        }
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
    for case in textedit-moved:1 textedit-title:2 textedit-not-focused:3 textedit-sheet:4 \
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
    # A flag case names the local failure record that it latches.
    local case kind name sel record at
    for case in flag:textedit-no-title:first-selection:setup-title \
        flag:textedit-no-focus:first-selection:setup-focus fault:textedit-pid:first-selection \
        fault:first-selection-identity:first-selection \
        fault:reopen-1-selection-setup-front-state:reopen-1-selection \
        fault:reopen-2-selection-setup-sheets:reopen-2-selection \
        fault:reopen-3-selection-setup-menus:reopen-3-selection \
        fault:screenshot-setup-first-selection:first-selection; do
        IFS=: read -r kind name sel record <<<"${case}"
        reset_run
        unset settings_flags settings_fault
        if [[ "${kind}" == flag ]]; then export settings_flags="${name}"; else export settings_fault="${name}"; fi
        run_scenario
        at="$(call_index "${name}")"
        [[ "${kind}" == fault ]] || at="$(call_index "${sel}-${record}")"
        if [[ "${status}" != 125 || "${at}" -le 0 || "$(input_after "${at}")" != '[]' ]] ||
            [[ "$(call_index "${sel}-item-1")" != -1 ]]; then
            echo "case ${case}: status ${status}, at ${at}, later input $(input_after "${at}")"
            printf '%s\n' "${output}" | tail -3
            return 1
        fi
    done
}

@test "each reopen gives TextEdit's window focus, and the setup judges the list after it (k6)" {
    run_scenario
    [[ "${status}" == 0 ]]
    local index
    # The step targets TextEdit, and its read is one complete window list.
    for index in 1 2 3; do
        jq -se --arg s "reopen-${index}-focus" 'map(select(.operation == $s)) | length == 1
            and (.[0] | tostring | test("window-focus")) and (.[0] | tostring | test("TextEdit"))' \
            "${settings_sim}/calls.jsonl" || {
            echo "the focus step of reopen-${index}"
            return 1
        }
        jq -se --arg s "reopen-${index}-focused" 'map(select(.operation == $s)) | length == 1
            and (.[0] | tostring | test("windows"))' "${settings_sim}/calls.jsonl" || {
            echo "the window read of reopen-${index}"
            return 1
        }
    done
    # A step that leaves no window focused is failed setup, and no menu opens.
    # The close before each reopen leaves no window focused in the model, so
    # the strict front predicate rejects the list read after the step.
    reset_run
    export settings_flags=focus-ignored
    run_scenario
    expect_outcome setup-failed
    [[ "${output}" == *"before reopen-1-selection, the TextEdit window is not the front, focused window"* ]]
    [[ "$(call_index reopen-1-selection-item-1)" == -1 ]]
    # An unavailable read after the step stops the scenario before the setup.
    reset_run
    unset settings_flags
    export settings_fault=reopen-2-focused
    run_scenario
    [[ "${status}" == 125 && "$(call_index reopen-2-selection-identity)" == -1 ]]
    [[ "$(input_after "$(call_index reopen-2-focused)")" == '[]' ]]
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

@test "the setup and the closed-menu checks read the size of the menus under each item (k5)" {
    run_scenario
    [[ "${status}" == 0 ]]
    # Each setup reads the menu sizes under the TextEdit and Koine items. Each
    # closed-menu check reads the menu sizes under the Koine item. No check
    # reads the selection of an item, and no check reads the menu names.
    jq -se 'map(select((.operation // "") | test("-setup-menus$")))
        | length == 4 and all(.[]; .action == "read" and .arguments == ["menu-bar-menu-sizes"])' \
        "${settings_sim}/calls.jsonl"
    jq -se 'map(select((.operation // "") | test("-menu-closed$")))
        | length == 7 and all(.[]; .action == "read" and .arguments == ["koine-menu-sizes"])' \
        "${settings_sim}/calls.jsonl"
    [[ "$(jq -s 'map(select(.action == "read" and (.arguments[0] == "open-menus"
        or .arguments[0] == "menu-item-selected" or .arguments[0] == "menu-bar-menus"
        or .arguments[0] == "koine-menus"))) | length' "${settings_sim}/calls.jsonl")" == 0 ]]
}

@test "a disabled row is recorded and not clicked" {
    export settings_flags=row-disabled settings_at=2
    run_scenario
    expect_outcome menu-item-disabled
    # A classified failure outside a return takes the untouched failure
    # observations before its receipt (k165).
    expect_order reopen-1-selection-enabled-state assertion-front-application \
        assertion-failure-windows failure-capture scenario-assertion-menu-item-disabled
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
    # The resize focus takes them in the same order (k165).
    reset_run
    export settings_untitled_behind=resize-front
    run_scenario
    expect_order resize-front-title resize-front-failure-windows failure-capture
}

# The protocol's untouched capture after a failed assertion: one observer
# read, one evidence-class window list and one screenshot, before the
# state-failed receipt latches the root (k165).
@test "a false front at the resize focus takes the untouched failure observations first (k165)" {
    export settings_finder_front=resize-front
    run_scenario
    expect_outcome not-front
    [[ "${output}" == *'the window is not focused for the resize exercise'* ]]
    # Both predicates are clean false on the one list.
    jq -se '(map(select(.operation == "resize-front-state"))[0].arguments[1] == "1")
        and (map(select(.operation == "resize-front-title-state"))[0].arguments[1] == "1")' \
        "${settings_sim}/calls.jsonl"
    expect_order resize-front-title-state resize-front-front-application \
        resize-front-failure-windows failure-capture scenario-assertion-not-front
    jq -se '(map(select(.operation == "resize-front-front-application"))[0]
            | .action == "read" and .arguments == ["front-application"] and .outcome == "clean")
        and (map(select(.operation == "resize-front-failure-windows"))[0]
            | .action == "cli" and .kind == "evidence" and .outcome == "clean")' \
        "${settings_sim}/calls.jsonl"
    [[ "$(jq -s 'map(select(.operation == "failure-capture")) | length' "${settings_sim}/calls.jsonl")" == 1 ]]
}

# The flag loses the step from the press to the first held movement, as the
# guest did (issue #21). The anchored drag grows the window to the destination.
# The drag from before the anchor stops one step short and fails the scenario.
@test "the anchored drag grows the window where the drag from before it stops short (k7)" {
    export settings_flags=first-step-lost
    run_scenario
    [[ "${status}" == 0 && "${output}" == *'Larger: 40 40 703 903'* ]] || {
        printf '%s\n' "${output}" | grep -E 'Larger|FAILED' >&2
        return 1
    }
    reset_run
    cp "${BATS_TEST_DIRNAME}/../../docs/verification/resize-drag/before-source/vm-window-resize-lib.sh" \
        "${scenario_repo}/scripts/vm-window-resize-lib.sh"
    run_scenario
    [[ "${status}" == 1 && "${output}" == *'Larger: 40 40 681 884'* ]]
    [[ "${output}" == *'FAILED: the window did not grow; resize acceptance is unestablished'* ]]
}

@test "a plain failed assertion takes the untouched failure observations before its receipt (k165)" {
    export settings_flags=resize-ignored
    run_scenario
    [[ "${status}" == 1 ]]
    [[ "${output}" == *'FAILED: the window did not grow; resize acceptance is unestablished'* ]]
    local at
    at="$(call_index scenario-assertion)"
    [[ "${at}" -gt 0 && "$(input_after "${at}")" == '[]' && ! -s "${scenario_legacy}" ]]
    jq -se --argjson n "${at}" '.[$n - 1] | .action == "poll-step" and .outcome == "state-failed"' \
        "${settings_sim}/calls.jsonl"
    expect_order resize-grown-state assertion-front-application assertion-failure-windows \
        failure-capture scenario-assertion
    jq -se 'map(select(.operation == "assertion-front-application"))[0].outcome == "clean"' \
        "${settings_sim}/calls.jsonl"
    [[ "$(jq -s 'map(select(.operation == "failure-capture")) | length' "${settings_sim}/calls.jsonl")" == 1 ]]
    [[ "$(jq -s 'map(select((.operation // "") | startswith("scenario-assertion"))) | length' \
        "${settings_sim}/calls.jsonl")" == 1 ]]
}

# A poll that the scenario library ends records its state-failed receipt only
# after the untouched observations (k165).
@test "an exhausted count poll takes the untouched failure observations before its receipt (k165)" {
    export settings_close_ignored=first-close
    run_scenario
    [[ "${status}" == 125 ]]
    local at
    at="$(call_index first-close-window-exhausted)"
    [[ "${at}" -gt 0 && "$(input_after "${at}")" == '[]' && ! -s "${scenario_legacy}" ]]
    jq -se --argjson n "${at}" '.[$n - 1] | .action == "poll-step" and .outcome == "state-failed"' \
        "${settings_sim}/calls.jsonl"
    # The poll keeps its ten reads, then the observations precede the receipt.
    [[ "$(call_index first-close-window-11)" == -1 ]]
    expect_order first-close-window-10 first-close-window-front-application \
        first-close-window-failure-windows failure-capture first-close-window-exhausted
    [[ "$(jq -s 'map(select(.operation == "failure-capture")) | length' "${settings_sim}/calls.jsonl")" == 1 ]]
    # The message counts the windows of the list that the last read judged.
    [[ "${output}" == *'FAILED: Koine has 1 windows, not 0'* ]]
}

@test "an exhausted reveal takes the untouched failure observations before its receipt (k165)" {
    export settings_flags=scroll-ignored
    run_scenario
    [[ "${status}" == 125 ]]
    [[ "${output}" == *'FAILED: scrolling did not bring .id=="login-launch" on screen'* ]]
    local at
    at="$(call_index least-size-login-exhausted)"
    [[ "${at}" -gt 0 && "$(input_after "${at}")" == '[]' && ! -s "${scenario_legacy}" ]]
    expect_order least-size-login-60-scroll least-size-login-front-application \
        least-size-login-failure-windows failure-capture least-size-login-exhausted
    [[ "$(jq -s 'map(select(.operation == "failure-capture")) | length' "${settings_sim}/calls.jsonl")" == 1 ]]
}

@test "a failed assertion before the Automation check takes no observer read (k165)" {
    # The System Events observer cannot succeed yet, and its Apple event could
    # raise the consent prompt. The window list and the screenshot still run.
    export settings_flags=signature-invalid
    run_scenario
    [[ "${status}" == 1 ]]
    [[ "${output}" == *'FAILED: the VM rejects the signature'* ]]
    [[ "${output}" == *'the failure observer was not run'* ]]
    expect_order signature-state assertion-failure-windows failure-capture scenario-assertion
    [[ "$(call_index assertion-front-application)" == -1 ]]
    [[ "$(call_index automation-request)" == -1 ]]
    [[ "$(input_after "$(call_index scenario-assertion)")" == '[]' ]]
}

# expect_facade_exhaustion RECEIPT MESSAGE ORDER...: a poll that a reviewed
# facade exhausts keeps its receipt, its outcome and status 125. The untouched
# observations precede the receipt, with one screenshot and no later input (k166).
expect_facade_exhaustion() {
    local receipt="$1" message="$2" at
    shift 2
    if [[ "${status}" != 125 || "${output}" != *"FAILED: ${message}"* ]] || [[ -s "${scenario_legacy}" ]]; then
        echo "receipt ${receipt}: status ${status}"
        printf '%s\n' "${output}" | tail -5
        return 1
    fi
    at="$(call_index "${receipt}")"
    [[ "${at}" -gt 0 && "$(input_after "${at}")" == '[]' ]]
    jq -se --argjson n "${at}" '.[$n - 1] | .action == "poll-step" and .outcome == "state-failed"' \
        "${settings_sim}/calls.jsonl"
    expect_order "$@" failure-capture "${receipt}"
    [[ "$(jq -s 'map(select(.operation == "failure-capture")) | length' "${settings_sim}/calls.jsonl")" == 1 ]]
    [[ "$(jq -s --arg op "${receipt}" 'map(select(.operation == $op)) | length' "${settings_sim}/calls.jsonl")" == 1 ]]
}

@test "an exhausted launch endpoint poll takes the observations before its receipt (k166)" {
    export settings_flags=endpoint-absent
    run_scenario
    expect_facade_exhaustion first-launch-endpoint-exhausted 'no endpoint descriptor after launch' \
        first-launch-endpoint-15 first-launch-endpoint-front-application first-launch-endpoint-failure-windows
    [[ "$(call_index first-launch-endpoint-16)" == -1 ]]
    jq -se 'map(select(.operation == "first-launch-endpoint-front-application"))[0].outcome == "clean"' \
        "${settings_sim}/calls.jsonl"
}

@test "an exhausted menu label poll takes the observations and keeps the label it judged (k166)" {
    export settings_flags=label-stuck
    run_scenario
    # The message names the polled label, never the observer's later value.
    expect_facade_exhaustion first-launch-label-exhausted \
        "the menu bar item's label is \"Koine, stuck\", not \"Koine, Accessibility not granted\"" \
        first-launch-label-15 first-launch-label-front-application first-launch-label-failure-windows
    [[ "$(call_index first-launch-label-16)" == -1 ]]
}

@test "an exhausted menu item frame poll takes the observations before its receipt (k166)" {
    export settings_flags=item-frame-absent
    run_scenario
    expect_facade_exhaustion first-launch-menu-item-exhausted "Koine's menu bar item has no position" \
        first-launch-menu-item-5 first-launch-menu-item-front-application \
        first-launch-menu-item-failure-windows
    [[ "$(call_index first-launch-menu-item-6)" == -1 ]]
}

@test "an exhausted menu row poll takes the observations on both menu routes (k166)" {
    export settings_flags=row-absent
    run_scenario
    expect_facade_exhaustion first-selection-row-exhausted 'the menu has no item "Settings…"' \
        first-selection-row-5 first-selection-row-front-application first-selection-row-failure-windows
    [[ "$(call_index first-selection-row-6)" == -1 ]]
    [[ "$(call_index first-selection-enabled)" == -1 ]]
    reset_run
    export settings_flags=quit-row-absent
    run_scenario
    expect_facade_exhaustion setup-quit-row-exhausted 'the menu has no item "Quit Koine"' \
        setup-quit-row-5 setup-quit-row-front-application setup-quit-row-failure-windows
}

@test "an exhausted TextEdit poll takes the observations after its final assertion (k166)" {
    export settings_flags=textedit-no-window
    run_scenario
    expect_facade_exhaustion textedit-window-exhausted 'TextEdit has no window' \
        textedit-window-15 textedit-window-assertion textedit-window-front-application \
        textedit-window-failure-windows
    [[ "$(call_index textedit-window-16)" == -1 ]]
    [[ "$(call_index textedit-settle-wait)" == -1 ]]
}

@test "a missing exact Allow target takes the observations but runs no observer (k166)" {
    export settings_flags=allow-substring
    run_scenario
    expect_facade_exhaustion automation-allow-exact-target 'the Automation prompt for System Events did not appear' \
        automation-allow-ocr automation-allow-failure-windows
    # The Automation check has not passed, so the k165 rule holds.
    [[ "${output}" == *'the failure observer was not run'* ]]
    [[ "$(call_index automation-allow-front-application)" == -1 ]]
    [[ "$(call_index automation-allow-click)" == -1 ]]
    [[ "$(call_index automation-check)" == -1 ]]
}

@test "an unavailable read in a deferred facade poll is no clean exhaustion (k166)" {
    local fault base
    for fault in first-launch-endpoint-1 first-launch-label-1 first-launch-menu-item-1 \
        first-selection-row-1 textedit-window-1 textedit-window-assertion automation-allow-ocr; do
        reset_run
        export settings_flags='' settings_fault="${fault}"
        [[ "${fault}" != textedit-window-assertion ]] || export settings_flags=textedit-no-window
        run_scenario
        base="${fault%-1}"
        base="${base%-assertion}"
        base="${base%-ocr}"
        if [[ "${status}" != 125 || "$(call_index "${base}-failure-windows")" != -1 ||
        "$(call_index "${base}-exhausted")" != -1 || "$(call_index "${base}-exact-target")" != -1 ]]; then
            echo "fault ${fault}: status ${status}"
            printf '%s\n' "${output}" | tail -5
            return 1
        fi
    done
}

# expect_backend_exit FAULT: an injected backend exit of 1 stayed unavailable.
# It took no failure observation and no state-failed receipt. The first latch
# reason and the original status both remain in the root.
expect_backend_exit() {
    local fault="$1" root
    root="$(jq -rs '.[0].root' "${settings_sim}/calls.jsonl")"
    if [[ "${status}" != 125 ]] ||
        [[ "$(jq -s 'map(select(.outcome == "state-failed"
            or ((.operation // "") | endswith("-failure-windows")))) | length' \
            "${settings_sim}/calls.jsonl")" != 0 ]] ||
        [[ "$(cat "${root}/unavailable")" != "${fault}: injected unavailable answer" ]] ||
        ! grep -q '^backend_exit=1 ' "${root}/facade-refusals.log"; then
        echo "fault ${fault}: status ${status}"
        printf '%s\n' "${output}" | tail -5
        return 1
    fi
}

@test "a backend exit of 1 is no clean state at any read or record boundary (k168)" {
    local case fault
    for case in first-launch-endpoint-1: first-launch-endpoint-15:endpoint-absent \
        first-launch-endpoint-15-state:endpoint-absent first-launch-label-1: \
        first-launch-label-15:label-stuck first-launch-label-15-state:label-stuck \
        first-launch-menu-item-1: first-launch-menu-item-5:item-frame-absent \
        first-launch-menu-item-5-state:item-frame-absent first-selection-row-1: \
        first-selection-row-5:row-absent first-selection-row-5-state:row-absent \
        textedit-window-1: textedit-window-15:textedit-no-window \
        textedit-window-15-state:textedit-no-window textedit-window-assertion:textedit-no-window \
        textedit-window-assertion-state:textedit-no-window automation-allow-ocr: \
        first-selection-window-1: first-selection-window-10:two-windows \
        first-selection-window-10-state:two-windows login-endpoint-1: \
        first-launch-count: first-launch-menu:; do
        fault="${case%%:*}"
        reset_run
        export settings_flags="${case#*:}" settings_fault="${fault}" settings_fault_status=1
        run_scenario
        expect_backend_exit "${fault}"
    done
    # The failed menu read sends no corrective close.
    [[ "$(call_index first-launch-menu-close)" == -1 ]]
}

@test "a backend exit of 1 while recording a failed wait stays unavailable (k168)" {
    cat >"${BATS_TEST_TMPDIR}/bin/sleep" <<'SLEEP'
#!/bin/bash
[[ "$(tail -1 "${settings_sim}/calls.jsonl" | jq -r '.operation // ""')" != first-launch-endpoint-1-state ]] || exit 7
exit 0
SLEEP
    export settings_flags=endpoint-absent settings_fault=first-launch-endpoint-1-sleep settings_fault_status=1
    run_scenario
    expect_backend_exit first-launch-endpoint-1-sleep
    [[ "$(call_index first-launch-endpoint-2)" == -1 ]]
}

# record_waits_after OPERATION: the sleep stub logs each wait that directly
# follows that call to the file ${scenario_waits}.after.
record_waits_after() {
    export scenario_wait_mark="$1"
    cat >"${BATS_TEST_TMPDIR}/bin/sleep" <<'SLEEP'
#!/bin/bash
[[ "$(tail -1 "${settings_sim}/calls.jsonl" | jq -r '.operation // ""')" != "${scenario_wait_mark}" ]] ||
    printf '%s\n' "$1" >>"${scenario_waits}.after"
exit 0
SLEEP
}

@test "a clean menu mismatch keeps the menu open for its untouched observations (k168)" {
    record_waits_after first-launch-menu-state
    export settings_flags=menu-title-wrong
    run_scenario
    [[ "${status}" == 1 ]]
    [[ "${output}" == *'FAILED: the menu is "'*', Unexpected", not "'* ]]
    [[ "$(call_index first-launch-menu-close)" == -1 ]]
    [[ ! -e "${scenario_waits}.after" ]]
    expect_order first-launch-menu-state assertion-front-application assertion-failure-windows \
        failure-capture scenario-assertion
    # After the comparison, the one guest read outside the evidence class is
    # the independent observer.
    jq -se --argjson n "$(call_index first-launch-menu-state)" '.[$n:] | map(select(
        (.action == "cli" or .action == "read" or .action == "upload")
        and .kind != "evidence" and .outcome != "refused"
        and .operation != "assertion-front-application")) == []' "${settings_sim}/calls.jsonl"
    jq -se 'map(select(.operation == "assertion-front-application"))[0].outcome == "clean"' \
        "${settings_sim}/calls.jsonl"
}

@test "a matching menu still closes with one Escape and its one-second wait (k168)" {
    record_waits_after first-launch-menu-close
    run_scenario
    [[ "${status}" == 0 ]]
    local at
    at="$(call_index first-launch-menu-close)"
    [[ "${at}" -eq "$(($(call_index first-launch-menu-state) + 1))" ]]
    jq -se --argjson n "${at}" '.[$n - 1] | .action == "cli" and any(.arguments[]; . == "escape")' \
        "${settings_sim}/calls.jsonl"
    [[ "$(cat "${scenario_waits}.after")" == 1 ]]
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

# --- scenario-level controls (k164) -----------------------------------------

# record_all_waits: the sleep stub logs "OPERATION SECONDS" for each wait, where
# OPERATION is the call that the wait follows.
record_all_waits() {
    cat >"${BATS_TEST_TMPDIR}/bin/sleep" <<'SLEEP'
#!/bin/bash
printf '%s %s\n' "$(tail -1 "${settings_sim}/calls.jsonl" | jq -r '.operation // ""')" "$1" >>"${scenario_waits}.ops"
exit 0
SLEEP
}

# operation_count REGEX: the calls whose operation matches.
operation_count() {
    jq -s --arg re "$1" 'map(select((.operation // "") | test($re))) | length' \
        "${settings_sim}/calls.jsonl"
}

# wait_count REGEX SECONDS: the waits of that length after a matching call.
wait_count() {
    awk -v re="$1" -v seconds="$2" '$1 ~ re && $2 == seconds { n++ } END { print n + 0 }' \
        "${scenario_waits}.ops"
}

@test "a failed library load before the root sends no VM stop, and other scripts keep theirs (k164)" {
    local entry library saved="${BATS_TEST_TMPDIR}/saved-library"
    for entry in vm-verify-menu-bar.sh vm-verify-menu-bar-prefix.sh; do
        for library in vm-verify-desktop-lib.sh vm-settings-scenario-lib.sh vm-window-resize-lib.sh; do
            reset_run
            : >"${scenario_legacy}"
            cp "${scenario_repo}/scripts/${library}" "${saved}"
            echo 'return 3' >"${scenario_repo}/scripts/${library}"
            run "${scenario_repo}/scripts/${entry}"
            cp "${saved}" "${scenario_repo}/scripts/${library}"
            if [[ "${status}" == 0 || -s "${scenario_legacy}" || -s "${settings_sim}/calls.jsonl" ]]; then
                echo "${entry} with ${library}: status ${status}; legacy: $(cat "${scenario_legacy}")"
                return 1
            fi
        done
    done
    # Another VM script that sources the library keeps the legacy cleanup stop.
    cat >"${scenario_repo}/scripts/vm-other-verify.sh" <<'SH'
#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/signing-env.sh
source scripts/vm-verify-lib.sh
SH
    chmod +x "${scenario_repo}/scripts/vm-other-verify.sh"
    : >"${scenario_legacy}"
    run "${scenario_repo}/scripts/vm-other-verify.sh"
    [[ "${status}" == 0 ]]
    grep -qx 'vm stop exact-settings-vm' "${scenario_legacy}"
}

@test "an exhausted reveal makes 120 element reads, one frame read and 60 scrolls with their waits (k164)" {
    record_all_waits
    export settings_flags=scroll-ignored
    run_scenario
    [[ "${status}" == 125 ]]
    [[ "$(operation_count '^least-size-login-frame$')" == 1 ]]
    [[ "$(operation_count '^least-size-login-[0-9]+$')" == 60 ]]
    [[ "$(operation_count '^least-size-login-[0-9]+-position$')" == 60 ]]
    [[ "$(operation_count '^least-size-login-[0-9]+-scroll$')" == 60 ]]
    [[ "$(jq -s 'map(select(.action == "cli" and ((.operation // "") | startswith("least-size-login-"))
        and (.arguments | index("snapshot")))) | length' "${settings_sim}/calls.jsonl")" == 120 ]]
    [[ "$(call_index least-size-login-61)" == -1 ]]
    [[ "$(wait_count '^least-size-login-[0-9]+-scroll$' 1)" == 60 ]]
}

@test "the calibration sends one probe and exactly 30 scrolls back, each with its wait (k164)" {
    local case flags dy
    for case in :--dy=10 scroll-ignored:--dy=-10; do
        flags="${case%%:*}" dy="${case#*:}"
        reset_run
        rm -f "${scenario_waits}.ops"
        record_all_waits
        export settings_flags="${flags}"
        run_scenario
        expect_order calibrate-before calibrate-scroll calibrate-after calibrate-back-1 calibrate-back-30
        [[ "$(operation_count '^calibrate-scroll$')" == 1 ]]
        [[ "$(operation_count '^calibrate-back-[0-9]+$')" == 30 ]]
        [[ "$(call_index calibrate-back-31)" == -1 ]]
        [[ "$(wait_count '^calibrate-back-[0-9]+$' 1)" == 30 ]]
        jq -se --arg dy "${dy}" 'map(select((.operation // "") | test("^calibrate-back-")))
            | all(.[]; .arguments | index($dy))' "${settings_sim}/calls.jsonl"
    done
}

@test "a missing Add button makes 15 reads and 14 waits and then fails before any click (k164)" {
    record_all_waits
    export settings_flags=add-absent
    run_scenario
    [[ "${status}" == 1 ]]
    [[ "${output}" == *'FAILED: the Accessibility pane did not show its Add button'* ]]
    [[ "$(operation_count '^accessibility-add-[0-9]+$')" == 15 ]]
    [[ "$(operation_count '^accessibility-add-[0-9]+-state$')" == 15 ]]
    [[ "$(call_index accessibility-add-16)" == -1 ]]
    [[ "$(wait_count '^accessibility-add-[0-9]+-state$' 2)" == 14 ]]
    [[ "$(wait_count '^accessibility-add-15-state$' 2)" == 0 ]]
    expect_order accessibility-add-15-state assertion-front-application assertion-failure-windows \
        failure-capture scenario-assertion
    [[ "$(call_index accessibility-add-click)" == -1 && "$(call_index consent-password)" == -1 ]]
    [[ "$(input_after "$(call_index scenario-assertion)")" == '[]' ]]
}

@test "the scenario's TextEdit call makes one poll read and one assertion read (k164)" {
    run_scenario
    [[ "${status}" == 0 ]]
    jq -se 'map(.operation) as $o | $o[($o | index("textedit-launch")) + 1:($o | index("textedit-move"))]
        == ["textedit-window-1", "textedit-window-1-state", "textedit-window-assertion",
            "textedit-window-assertion-state"]' "${settings_sim}/calls.jsonl"
    # An exhausted poll keeps fifteen reads, their waits and the one assertion.
    reset_run
    record_all_waits
    export settings_flags=textedit-no-window
    run_scenario
    [[ "$(operation_count '^textedit-window-[0-9]+$')" == 15 ]]
    [[ "$(operation_count '^textedit-window-assertion$')" == 1 ]]
    [[ "$(wait_count '^textedit-window-[0-9]+-state$' 2)" == 15 ]]
}

@test "the scenario's on-screen and position reads keep their own element modes (k164)" {
    run_scenario
    [[ "${status}" == 0 ]]
    local vertical='. == null or (type == "object" and all(.positionY, .sizeHeight;'
    local position='type == "object" and (.positionY | type == "number" and isfinite)'
    jq -se --arg mode "${vertical}" 'map(select((.operation // "")
            | test("^(requests|accessibility)-on-screen$|^least-size-[a-z]+-[0-9]+$"))) as $reads
        | ($reads | length) >= 5 and all($reads[]; .arguments[0] | contains($mode))' \
        "${settings_sim}/calls.jsonl"
    jq -se --arg mode "${position}" 'map(select((.operation // "")
            | test("^calibrate-(before|after)$|-[0-9]+-position$"))) as $reads
        | ($reads | length) >= 2 and all($reads[]; .arguments[0] | contains($mode))' \
        "${settings_sim}/calls.jsonl"
    # Behaviour: each mode refuses the attribute that it alone requires.
    reset_run
    export settings_flags=element-no-height
    run_scenario
    [[ "${status}" == 125 ]]
    jq -se 'map(select(.operation == "least-size-login-1"))[0].outcome == "unavailable"' \
        "${settings_sim}/calls.jsonl"
    [[ "$(call_index calibrate-after)" -gt 0 ]]
    reset_run
    export settings_flags=element-no-position
    run_scenario
    [[ "${status}" == 125 ]]
    [[ "${output}" == *'the calibration element could not be read'* ]]
    jq -se 'map(select(.operation == "calibrate-before"))[0].outcome == "unavailable"' \
        "${settings_sim}/calls.jsonl"
    [[ "$(call_index calibrate-scroll)" == -1 ]]
}

@test "a window at the silent launch fails its assertion before the reopen (k164)" {
    export settings_flags=silent-launch-window
    run_scenario
    [[ "${status}" == 1 ]]
    [[ "${output}" == *'FAILED: the window opened though setup is complete'* ]]
    jq -se 'map(select(.operation == "silent-launch-windows-state"))[0].arguments[1] == "1"' \
        "${settings_sim}/calls.jsonl"
    expect_order silent-launch-identity silent-launch-windows-state assertion-front-application \
        assertion-failure-windows failure-capture scenario-assertion
    [[ "$(call_index reopen)" == -1 ]]
    [[ "$(input_after "$(call_index scenario-assertion)")" == '[]' ]]
}

@test "a clean on-screen negative stays apart from a failed read (k164)" {
    export settings_flags=requests-off-screen
    run_scenario
    [[ "${status}" == 1 ]]
    [[ "${output}" == *'FAILED: the window did not scroll to the requests'* ]]
    jq -se 'map(select(.operation == "requests-on-screen"))[0].outcome == "clean"' "${settings_sim}/calls.jsonl"
    jq -se 'map(select(.operation == "requests-on-screen-state"))[0].arguments[1] == "1"' \
        "${settings_sim}/calls.jsonl"
    expect_order requests-on-screen-state assertion-failure-windows failure-capture scenario-assertion
    local case fault code
    for case in requests-on-screen:125 requests-on-screen:1 least-size-login-1:125 least-size-login-1:1; do
        fault="${case%:*}" code="${case#*:}"
        reset_run
        export settings_flags='' settings_fault="${fault}" settings_fault_status="${code}"
        run_scenario
        if [[ "${status}" != 125 || "$(call_index "${fault}-state")" != -1 ||
        "$(call_index "${fault}-position")" != -1 || "$(call_index "${fault}-scroll")" != -1 ||
        "$(operation_count '^scenario-assertion')" != 0 ]]; then
            echo "fault ${case}: status ${status}"
            printf '%s\n' "${output}" | tail -4
            return 1
        fi
    done
}

# surface_scan ENTRY: the report of the static scan on the copied repository.
surface_scan() {
    python3 -I "${BATS_TEST_DIRNAME}/fixtures/settings-surface-scan.py" "${scenario_repo}/scripts/$1"
}

@test "the surface scan classifies each legacy transport that the scenario reaches (k164)" {
    local entry report resize
    for entry in vm-verify-menu-bar.sh vm-verify-menu-bar-prefix.sh; do
        report="$(surface_scan "${entry}")"
        # The prefix stops before the resize, so only the complete scenario
        # reaches the corner drag and its two root-unset transports.
        resize='[["vm-window-resize-lib.sh", "drag_window_corner", "root-unset"],
            ["vm-window-resize-lib.sh", "drag_window_corner", "root-unset"]]'
        if [[ "${entry}" == vm-verify-menu-bar-prefix.sh ]]; then
            resize='[]'
            [[ "$(jq '.functions | index("drag_window_corner")' <<<"${report}")" == null ]]
        else
            jq -e '.functions | index("drag_window_corner")' <<<"${report}"
        fi
        # Positive control: the scan reaches the deepest helpers of each family.
        jq -e '.functions as $f | all("_physical_cli", "scenario_input",
            "_sysevents_poll_as", "_await_guest_windows", "click_guest_allow", "capture_guest_evidence",
            "upload_guest_file", "start_guest_vm", "_guest_evidence_backend"; . as $n | $f | index($n))' <<<"${report}"
        [[ "$(jq -c '.dynamic' <<<"${report}")" == '[]' ]]
        # Each transport is in a lane that needs an unset root.
        jq -e --argjson resize "${resize}" '[.legacy[] | select(.kind == "call" and .command == "testanyware")
            | [.file, .function, .lane]] == ([
            ["vm-input-evidence-lib.sh", "scenario_input", "root-unset"],
            ["vm-physical-evidence-lib.sh", "_physical_cli", "root-unset"],
            ["vm-physical-evidence-lib.sh", "_physical_cli", "root-unset"]] + $resize)' <<<"${report}"
        # The one other legacy call is a failure message in the same lane.
        jq -e '[.legacy[] | select(.kind == "call" and .command != "testanyware")
            | [.command, .function, .lane]] == [["fail", "_physical_fail", "root-unset"]]' <<<"${report}"
        # The one legacy function reached only prints a step heading.
        jq -e '[.legacy[] | select(.kind == "function") | .function] == ["step"]' <<<"${report}"
    done
}

@test "the surface scan detects an unguarded transport in a helper or a restored trap (k164)" {
    local scripts="${scenario_repo}/scripts" saved="${BATS_TEST_TMPDIR}/saved-library" report
    # Mutation: the input lane no longer tests for an unset root.
    cp "${scripts}/vm-input-evidence-lib.sh" "${saved}"
    # shellcheck disable=SC2016 # The pattern names shell text literally.
    sed -i '' 's/if \[\[ ! "${KOINE_VM_EVIDENCE_ROOT+x}" \]\]; then/if [[ -n "${operation}" ]]; then/' \
        "${scripts}/vm-input-evidence-lib.sh"
    report="$(surface_scan vm-verify-menu-bar.sh)"
    cp "${saved}" "${scripts}/vm-input-evidence-lib.sh"
    jq -e 'any(.legacy[]; .function == "scenario_input" and .lane == "unguarded")' <<<"${report}"
    # Mutation: a new transport in a helper that only the facades call.
    cp "${scripts}/vm-guest-exec-lib.sh" "${saved}"
    sed -i '' 's/^cli_guest_evidence() {$/cli_guest_evidence() {\n    testanyware agent windows --json/' \
        "${scripts}/vm-guest-exec-lib.sh"
    report="$(surface_scan vm-verify-menu-bar.sh)"
    cp "${saved}" "${scripts}/vm-guest-exec-lib.sh"
    jq -e 'any(.legacy[]; .function == "cli_guest_evidence" and .lane == "unguarded")' <<<"${report}"
    # Mutation: the legacy cleanup trap applies to the scenario again.
    cp "${scripts}/vm-verify-lib.sh" "${saved}"
    # shellcheck disable=SC2016 # The pattern names shell text literally.
    sed -i '' '/^case "${BASH_SOURCE\[1\]##\*\/}" in$/,/^esac$/c\
trap cleanup EXIT
' "${scripts}/vm-verify-lib.sh"
    grep -qx 'trap cleanup EXIT' "${scripts}/vm-verify-lib.sh"
    report="$(surface_scan vm-verify-menu-bar.sh)"
    cp "${saved}" "${scripts}/vm-verify-lib.sh"
    jq -e 'any(.legacy[]; .function == "cleanup" and .lane == "unguarded")' <<<"${report}"
}

@test "the surface scan finds no constant-true predicate and detects each mutation (k164)" {
    local scripts="${scenario_repo}/scripts" saved="${BATS_TEST_TMPDIR}/saved-library" report index
    report="$(surface_scan vm-verify-menu-bar.sh)"
    # Positive control: predicates of each seam, literal, composed and built.
    jq -e '.predicate_count >= 50 and (.predicates as $p | all(".diagnostics_disabled == true",
        ".value | length > 0", ".selected == []", "(.absent | not) and .value == \"Koine\"";
        . as $n | $p | index($n)))
        and any(.predicates[]; contains(".button == \"left\""))
        and any(.predicates[]; contains("def number_field"))' <<<"${report}"
    [[ "$(jq -c '.constant_true' <<<"${report}")" == '[]' && "$(jq -c '.unparsed' <<<"${report}")" == '[]' ]]
    # Each mutation makes one real predicate constant, by one route to the gate:
    # a forwarded literal, a local state, a disjunction, a variable and a builder.
    local files=(vm-sysevents-evidence-lib.sh vm-settings-scenario-lib.sh vm-settings-scenario-lib.sh
        vm-input-evidence-lib.sh vm-exec-read-evidence-lib.sh)
    # shellcheck disable=SC2016 # Each entry names shell text literally.
    local olds=("'.value | length > 0'" "'.valid == true'" "'.diagnostics_disabled == true'"
        'predicate=".x == $1 and .y == $2 and .dx == 0 and .dy == ${dy}"' "'.present == true'")
    local news=("'true'" "'. == .'" "'true or .x'" "predicate='true'" "'true'")
    for index in "${!files[@]}"; do
        cp "${scripts}/${files[index]}" "${saved}"
        OLD="${olds[index]}" NEW="${news[index]}" python3 -I -c '
import os, pathlib, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
assert os.environ["OLD"] in text
path.write_text(text.replace(os.environ["OLD"], os.environ["NEW"], 1))' "${scripts}/${files[index]}"
        report="$(surface_scan vm-verify-menu-bar.sh)"
        cp "${saved}" "${scripts}/${files[index]}"
        jq -e --arg file "${files[index]}" 'any(.constant_true[]; .file == $file)' <<<"${report}" || {
            echo "mutation not detected: ${olds[index]}"
            return 1
        }
    done
}

# held_fault FAULT: the real backend and the reviewed drag, with one pointer fault.
held_fault() {
    rm -rf "${BATS_TEST_TMPDIR}/signal-evidence"
    export pointer_fault="$1"
    signal_driver
    receipts >"${BATS_TEST_TMPDIR}/receipts"
}

@test "a clean drag reports released, and each failed or partial point reports uncertain (k164)" {
    held_fault ''
    [[ "${status}" == 0 && "${output}" == *after-drag* && "${output}" == *'Held pointer: released'* ]]
    local case fault operation outcome
    for case in exit:up:resize-release:unavailable kill:up:resize-release:partial \
        exit:down:0:resize-down-0:unavailable kill:down:0:resize-down-0:partial \
        exit:down:5:resize-down-5:unavailable kill:down:5:resize-down-5:partial \
        exit:down:10:resize-down-10:unavailable kill:down:10:resize-down-10:partial \
        exit:down:11:resize-down-11:unavailable kill:down:11:resize-down-11:partial; do
        outcome="${case##*:}"
        operation="${case%:*}"
        operation="${operation##*:}"
        fault="${case%:*}"
        fault="${fault%:*}"
        held_fault "${fault}"
        if [[ "${status}" == 0 || "${output}" == *after-drag* || "${output}" != *'Held pointer: uncertain'* ]] ||
            ! grep -qx "${operation}:${outcome}" "${BATS_TEST_TMPDIR}/receipts"; then
            echo "fault ${fault}: status ${status}"
            cat "${BATS_TEST_TMPDIR}/receipts"
            printf '%s\n' "${output}" | tail -4
            return 1
        fi
        # A failed held point sends neither a later point nor a release.
        if [[ "${fault}" == *:down:* ]]; then
            refute mouse-up "${signal_calls}"
            [[ "$(grep -c mouse-down "${signal_calls}")" == "$((${fault##*:} + 1))" ]]
        fi
    done
}

# consent_driver: the real backend, a fixture CLI and the real consent path.
consent_driver() {
    local real="${BATS_TEST_DIRNAME}/../../scripts"
    export consent_root="${BATS_TEST_TMPDIR}/consent-evidence"
    # This fixture logs nothing, so the password has no copy outside the root.
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
set -euo pipefail
case "$1 $2" in
    'agent snapshot')
        payload='{"windows":[{"appName":"System Settings","title":"Accessibility","windowType":"standard","focused":true,"positionX":200,"positionY":200,"sizeWidth":700,"sizeHeight":600,"elements":[{"role":"button","platformRole":"AXButton","label":"Add","enabled":true,"focused":false,"childCount":0,"actions":[],"positionX":500,"positionY":600,"sizeWidth":30,"sizeHeight":20},{"role":"row","platformRole":"AXRow","label":"Koine","enabled":true,"focused":false,"childCount":0,"actions":[],"positionX":400,"positionY":400,"sizeWidth":300,"sizeHeight":20}]}]}'
        ;;
    'input click') payload=$(jq -cn --argjson x "$3" --argjson y "$4" '{x:$x,y:$y,button:"left",count:1}') ;;
    'input type') payload=$(jq -cn --arg text "$3" '{text:$text,chars:($text | length)}') ;;
    'input key')
        modifiers='[]'
        if [[ "${4-}" == --modifiers ]]; then modifiers=$(jq -cn --arg m "$5" '$m | split(",")'); fi
        payload=$(jq -cn --arg key "$3" --argjson m "${modifiers}" '{key:$key,modifiers:$m}')
        ;;
    *) exit 98 ;;
esac
jq -cn --argjson payload "${payload}" '{schema_version:"1.0",ok:true} + $payload'
CLI
    cat >"${BATS_TEST_TMPDIR}/consent.sh" <<SH
#!/bin/bash
set -euo pipefail
# shellcheck source=/dev/null
source "${real}/vm-verify-desktop-lib.sh"
# shellcheck source=/dev/null
source "${real}/vm-settings-scenario-lib.sh"
WINDOW_TITLE='Koine Settings' VM_ID=exact-consent-vm WORK="${BATS_TEST_TMPDIR}"
INSTALLED=/Applications/Koine.app
settings_begin "\${consent_root}" exact-consent-vm
# The pane opens by a one-shot exec, which the one-shot suite owns.
open_guest_accessibility_pane() { :; }
settings_grant_accessibility
echo consent-done
SH
    chmod +x "${BATS_TEST_TMPDIR}/consent.sh"
    run "${BATS_TEST_TMPDIR}/consent.sh"
}

@test "a consent run with a password override keeps the raw text only in the private root (k164)" {
    # Synthetic text only. It is no account password.
    local password='synthetic-consent-text-8f3a' attempt
    export KOINE_VM_PASSWORD="${password}"
    umask 022
    consent_driver
    [[ "${status}" == 0 && "${output}" == *consent-done* ]] || {
        printf '%s\n' "${output}" | tail -8
        return 1
    }
    [[ "$(stat -f %Lp "${consent_root}")" == 700 ]]
    # The attempt keeps the exact text, in its argv and in the raw response.
    attempt="$(grep -l '"operation": *"consent-password"' "${consent_root}"/*/request.json)"
    attempt="${attempt%/request.json}"
    jq -e --arg text "${password}" '.argv | index($text)' "${attempt}/request.json"
    jq -e --arg text "${password}" '.text == $text and .chars == ($text | length)' "${attempt}/raw.stdout"
    # The transcript and every file outside the root have no copy.
    [[ "${output}" != *"${password}"* ]]
    [[ -z "$(grep -rlF --exclude-dir=consent-evidence -- "${password}" "${BATS_TEST_TMPDIR}" || :)" ]]
}

@test "the scenario records the clone provenance between the inventory and the first guest read, with the declared jq (k180)" {
    cat >"${BATS_TEST_TMPDIR}/declared-jq" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"${BATS_TEST_TMPDIR}/declared-jq.log"
exec "${KOINE_JQ}" "\$@"
SH
    chmod +x "${BATS_TEST_TMPDIR}/declared-jq"
    export KOINE_JQ="${BATS_TEST_TMPDIR}/declared-jq"
    run_scenario
    [[ "${status}" == 0 && "${output}" == *'== PASSED'* ]]
    jq -se 'map(.operation)[1:6] == ["vm-before", "vm-start", "vm-after", "clone-provenance", "system"]
        and (map(select(.action == "provenance")) | length) == 1' "${settings_sim}/calls.jsonl"
    # The signature decision is a local jq predicate of the scenario.
    grep -qF -- '-e .valid == true' "${BATS_TEST_TMPDIR}/declared-jq.log"
}

@test "a failed clone provenance stops the scenario, and only the failure screenshot follows (k180)" {
    export settings_fault=clone-provenance
    run_scenario
    [[ "${status}" == 125 ]]
    [[ "${output}" == *'FAILED: the provenance of the clone exact-settings-vm could not be recorded'* ]]
    # The real backend refuses that evidence-class capture too: no record follows the start.
    jq -se 'map(.operation) | .[(index("clone-provenance") + 1):] == ["failure-capture"]' \
        "${settings_sim}/calls.jsonl"
}
