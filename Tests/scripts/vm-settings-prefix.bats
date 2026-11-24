#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Every test owns its environment.
# The focused prefix of the Settings scenario, scripts/vm-verify-menu-bar-prefix.sh,
# without a VM.
#
# The first tests check the byte correspondence with
# scripts/check-settings-prefix.py, on the real files and on mutated copies.
# The later tests run the prefix and the complete scenario against the same
# simulated backend (Tests/scripts/fixtures/settings-scenario-backend.py), in
# a copied repository, and compare the logged calls and waits.

setup() {
    bats_require_minimum_version 1.5.0
    export repo_root="${BATS_TEST_DIRNAME}/../.."
    export check="${repo_root}/scripts/check-settings-prefix.py"
    export copies="${BATS_TEST_TMPDIR}/copies"
    export scenario_repo="${BATS_TEST_TMPDIR}/repo"
    export settings_sim="${BATS_TEST_TMPDIR}/sim"
    export scenario_legacy="${BATS_TEST_TMPDIR}/legacy-cli"
    export scenario_waits="${BATS_TEST_TMPDIR}/waits"
    export runs="${BATS_TEST_TMPDIR}/runs"
    mkdir -p "${copies}" "${scenario_repo}/App" "${scenario_repo}/bundle/Koine.app/Contents" \
        "${settings_sim}" "${runs}" "${BATS_TEST_TMPDIR}/bin"
    cp -p "${repo_root}/scripts/vm-verify-menu-bar.sh" "${copies}/scenario.sh"
    cp -p "${repo_root}/scripts/vm-verify-menu-bar-prefix.sh" "${copies}/prefix.sh"
    cp -R "${repo_root}/scripts" "${scenario_repo}/scripts"
    cp "${repo_root}/App/Info.plist" "${scenario_repo}/App/Info.plist"
    echo bundle >"${scenario_repo}/bundle/Koine.app/Contents/Info.plist"
    cp "${repo_root}/Tests/scripts/fixtures/settings-scenario-backend.py" \
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
    # One root path for every run, so the logged calls compare directly.
    export KOINE_VM_EVIDENCE_ROOT="${BATS_TEST_TMPDIR}/root"
    unset KOINE_VM_DISPLAY KOINE_VM_KEEP KOINE_SETTINGS_TRACE KOINE_K4_OUT \
        TESTANYWARE_VM_ID settings_fault settings_fault_status settings_flags settings_at \
        scenario_signal scenario_signal_on settings_untitled_behind
}

# refute PATTERN FILE: Bats does not fail a test on a negated command.
refute() {
    if grep -q -- "$1" "$2"; then
        grep -n -- "$1" "$2"
        return 1
    fi
}

# differ A B: the two files differ.
differ() {
    if cmp -s "$1" "$2"; then
        echo "$1 and $2 are the same"
        return 1
    fi
}

# check_copies: the check on the two copies.
check_copies() {
    run python3 -I "${check}" "${copies}/scenario.sh" "${copies}/prefix.sh"
}

# expect_refused: the check refuses the copies with status 1.
expect_refused() {
    check_copies
    [[ "${status}" == 1 && "${output}" == *'FAILED: '* ]] || {
        echo "expected a refusal: status ${status}: ${output}"
        return 1
    }
}

# extract: the copied prefix becomes the leading lines of the copied scenario,
# through the line that ends the TextEdit quit.
extract() {
    local end
    end="$(awk '/^quit_guest_textedit /{q=NR} q && NR>=q && !/(\|\||\\)$/{print NR; exit}' "${copies}/scenario.sh")"
    head -n "${end}" "${copies}/scenario.sh" >"${copies}/prefix.sh"
}

# run_entry NAME SCRIPT: one run from a fresh guest, transcript and root. Its
# calls and its waits are kept under $runs/NAME. The kept calls drop the root
# and keep only the file name of an upload's local path, because each run's
# work directory has a random name.
run_entry() {
    rm -f "${settings_sim}/calls.jsonl" "${settings_sim}/state.json" "${scenario_waits}.signalled"
    rm -rf "${scenario_repo}/.build" "${KOINE_VM_EVIDENCE_ROOT}"
    : >"${scenario_waits}"
    run "${scenario_repo}/scripts/$2"
    printf '%s\n' "${status}" >"${runs}/$1.status"
    printf '%s\n' "${output}" >"${runs}/$1.output"
    jq -c 'del(.root) | if .action == "upload" then .arguments[0] |= sub("^.*/"; "") else . end' \
        "${settings_sim}/calls.jsonl" >"${runs}/$1.calls"
    cp "${scenario_waits}" "${runs}/$1.waits"
}

# run_both: the complete scenario, then the prefix, under the same environment.
run_both() {
    run_entry complete vm-verify-menu-bar.sh
    run_entry prefix vm-verify-menu-bar-prefix.sh
}

# The FAILED and INTERRUPTED lines of a run, which name its outcome.
outcome_lines() {
    grep -E '^(FAILED|INTERRUPTED): ' "${runs}/$1.output" || :
}

# expect_same_failure: both runs stop at the same call with the same status,
# message and receipts, before the end of the prefix.
expect_same_failure() {
    local complete prefix
    complete="$(cat "${runs}/complete.status")" prefix="$(cat "${runs}/prefix.status")"
    if [[ "${complete}" == 0 || "${complete}" != "${prefix}" ]] ||
        ! cmp -s "${runs}/complete.calls" "${runs}/prefix.calls" ||
        ! cmp -s "${runs}/complete.waits" "${runs}/prefix.waits" ||
        [[ "$(outcome_lines complete)" != "$(outcome_lines prefix)" ]] ||
        [[ -z "$(outcome_lines prefix)" ]] || [[ -s "${scenario_legacy}" ]]; then
        echo "case ${1}: complete ${complete}, prefix ${prefix}"
        diff "${runs}/complete.calls" "${runs}/prefix.calls" | head -5
        outcome_lines complete
        outcome_lines prefix
        return 1
    fi
    # The failure happens inside the prefix, so neither run reached its quit.
    refute '"operation":"textedit-quit-absence"' "${runs}/prefix.calls"
}

@test "the prefix is the exact leading bytes of the scenario through the TextEdit quit" {
    run python3 -I "${check}"
    [[ "${status}" == 0 ]] || {
        echo "${output}"
        return 1
    }
    # The same facts, read directly: the prefix's last command is the quit,
    # and the scenario's next line that is not blank is the resize step.
    local size lines
    size="$(wc -c <"${copies}/prefix.sh")" lines="$(wc -l <"${copies}/prefix.sh")"
    cmp -s "${copies}/prefix.sh" <(head -c "${size}" "${copies}/scenario.sh")
    grep -Eq '^quit_guest_textedit ' <(tail -2 "${copies}/prefix.sh")
    [[ "$(tail -n "+$((lines + 1))" "${copies}/scenario.sh" | grep -m1 -v '^[[:space:]]*$')" == 'step "The window resizes'* ]]
    [[ -x "${repo_root}/scripts/vm-verify-menu-bar-prefix.sh" ]]
}

@test "a changed, missing or extra byte in the prefix fails the check" {
    check_copies
    [[ "${status}" == 0 ]]
    local original="${copies}/prefix.original"
    cp -p "${copies}/prefix.sh" "${original}"
    # The TextEdit settling wait changes from 8 to 9 seconds.
    sed 's/^settings_sleep textedit-settle 8$/settings_sleep textedit-settle 9/' "${original}" >"${copies}/prefix.sh"
    differ "${original}" "${copies}/prefix.sh"
    expect_refused
    # The TextEdit quit is missing.
    head -n "$(($(wc -l <"${original}") - 2))" "${original}" >"${copies}/prefix.sh"
    expect_refused
    # The prefix runs on into the resize step.
    sed -n '1,/^step "The window resizes/p' "${copies}/scenario.sh" >"${copies}/prefix.sh"
    expect_refused
    # One extra blank line, and then one missing final newline.
    { cat "${original}" && echo; } >"${copies}/prefix.sh"
    expect_refused
    printf '%s' "$(cat "${original}")" >"${copies}/prefix.sh"
    expect_refused
    # The restored bytes pass again.
    cp -p "${original}" "${copies}/prefix.sh"
    check_copies
    [[ "${status}" == 0 ]]
}

@test "a scenario change before the quit fails the check until the prefix is extracted again" {
    # An added screenshot after each reopen's outcome screenshot.
    # shellcheck disable=SC2016 # The scenario's own variable, kept literal.
    sed 's/^    settings_capture "outcome-reopen-${reopen}"$/&\n    settings_capture "extra-${reopen}"/' \
        "${repo_root}/scripts/vm-verify-menu-bar.sh" >"${copies}/scenario.sh"
    grep -q 'settings_capture "extra-' "${copies}/scenario.sh"
    expect_refused
    extract
    check_copies
    [[ "${status}" == 0 ]]
    # A change after the quit does not touch the prefix.
    cp -p "${repo_root}/scripts/vm-verify-menu-bar.sh" "${copies}/scenario.sh"
    extract
    sed 's/^settings_sleep resize-front 1$/settings_sleep resize-front 2/' \
        "${repo_root}/scripts/vm-verify-menu-bar.sh" >"${copies}/scenario.sh"
    differ "${copies}/scenario.sh" "${repo_root}/scripts/vm-verify-menu-bar.sh"
    check_copies
    [[ "${status}" == 0 ]]
}

@test "a scenario without exactly one TextEdit quit before the resize step is refused" {
    local scenario="${repo_root}/scripts/vm-verify-menu-bar.sh"
    # No quit.
    sed '/^quit_guest_textedit /,+1d' "${scenario}" >"${copies}/scenario.sh"
    expect_refused
    [[ "${output}" == *'0 TextEdit quit commands'* ]]
    # Two quits.
    # shellcheck disable=SC2016 # The scenario's own variable, kept literal.
    sed 's/^quit_guest_textedit /quit_guest_textedit "${KOINE_VM_EVIDENCE_ROOT}" early || :\n&/' \
        "${scenario}" >"${copies}/scenario.sh"
    expect_refused
    [[ "${output}" == *'2 TextEdit quit commands'* ]]
    # No resize step.
    sed '/^step "The window resizes/d' "${scenario}" >"${copies}/scenario.sh"
    expect_refused
    [[ "${output}" == *'0 resize steps'* ]]
    # A command between the quit and the resize step.
    sed 's/^step "The window resizes/settings_sleep extra 1\n&/' "${scenario}" >"${copies}/scenario.sh"
    expect_refused
    [[ "${output}" == *'not blank'* ]]
}

@test "the prefix keeps the execute permission of the scenario" {
    chmod -x "${copies}/prefix.sh"
    expect_refused
    [[ "${output}" == *'execute permission'* ]]
}

@test "the prefix runs the scenario's calls and waits through the TextEdit quit and sends nothing after it" {
    run_both
    [[ "$(cat "${runs}/complete.status")" == 0 && "$(cat "${runs}/prefix.status")" == 0 ]] || {
        tail -5 "${runs}/complete.output" "${runs}/prefix.output"
        return 1
    }
    local count
    count="$(wc -l <"${runs}/prefix.calls")"
    # The prefix's calls are the complete run's first calls. Its last calls
    # are the TextEdit quit, the clean absence read and that read's state.
    cmp -s "${runs}/prefix.calls" <(head -n "${count}" "${runs}/complete.calls")
    jq -se '(.[-3:] | map(.operation)) == ["textedit-quit", "textedit-quit-absence", "textedit-quit-absence-state"]
        and all(.[1:][]; .outcome == "clean")' "${runs}/prefix.calls"
    # The complete run continues with the resize move.
    [[ "$(sed -n "$((count + 1))p" "${runs}/complete.calls" | jq -r .operation)" == resize-move ]]
    # The same waits, in the same order, up to the quit.
    cmp -s "${runs}/prefix.waits" <(head -n "$(wc -l <"${runs}/prefix.waits")" "${runs}/complete.waits")
    [[ "$(wc -l <"${runs}/complete.waits")" -gt "$(wc -l <"${runs}/prefix.waits")" ]]
    # All four selections, each with its setup and its classified outcome checks.
    local selection
    for selection in first-selection reopen-1-selection reopen-2-selection reopen-3-selection; do
        jq -se --arg s "${selection}" 'map(.operation) | index($s + "-setup-front-state") != null
            and index($s + "-enabled") != null and index("screenshot-setup-" + $s) != null' "${runs}/prefix.calls"
    done
    # The EXIT report states status 0. No PASSED line, no stop and no legacy call.
    grep -q '^Scenario status 0\. ' "${runs}/prefix.output"
    refute 'PASSED' "${runs}/prefix.output"
    refute '"stop"' "${runs}/prefix.calls"
    grep -q 'sent no VM stop' "${runs}/prefix.output"
    [[ ! -s "${scenario_legacy}" ]]
}

@test "a failure inside the prefix has the same outcome in the prefix and in the scenario" {
    local case
    # Unavailable answers: the TextEdit PID, a setup read, a route read and a
    # closed-menu read, at the first and later selections.
    for case in textedit-pid first-selection-setup-front-state reopen-2-selection-setup-sheets \
        reopen-3-selection-setup-menus reopen-3-selection-enabled screenshot-menu-reopen-1-selection \
        reopen-2-window-1 reopen-3-menu-closed textedit-quit textedit-quit-absence; do
        export settings_fault="${case}"
        run_both
        if [[ "${case}" == textedit-quit* ]]; then
            # A fault at the quit stops both runs at the same call.
            [[ "$(cat "${runs}/complete.status")" == 125 ]]
            cmp -s "${runs}/complete.calls" "${runs}/prefix.calls"
            [[ "$(outcome_lines complete)" == "$(outcome_lines prefix)" ]]
            continue
        fi
        expect_same_failure "fault ${case}"
    done
    unset settings_fault
    # Clean false states and classified outcomes, at the fourth selection.
    export settings_at=4
    for case in textedit-moved textedit-title textedit-not-focused textedit-sheet textedit-dialog \
        menu-open-at-setup koine-menu-open-at-setup row-disabled menu-stays-open wrong-title \
        no-title two-windows no-front-after-settings zero-window-crash zero-window-reused; do
        export settings_flags="${case}"
        run_both
        expect_same_failure "flag ${case}"
    done
}

@test "a signal inside the prefix stops it as it stops the scenario" {
    # The first 8-second wait is the TextEdit settling sleep.
    export scenario_signal=HUP scenario_signal_on=8
    run_both
    [[ "$(cat "${runs}/prefix.status")" == 129 ]]
    expect_same_failure "HUP"
    grep -q 'INTERRUPTED: SIGHUP' "${runs}/prefix.output"
}

@test "the Task entry of the prefix records its status like the complete scenario's entry" {
    cp "${repo_root}/Taskfile.yml" "${scenario_repo}/Taskfile.yml"
    export KOINE_K4_OUT="${BATS_TEST_TMPDIR}/k4"
    mkdir -p "${KOINE_K4_OUT}"
    rm -rf "${scenario_repo}/.build" "${KOINE_VM_EVIDENCE_ROOT}"
    run task --dir "${scenario_repo}" app:vm-verify-menu-bar-prefix
    [[ "${status}" == 0 && "$(cat "${KOINE_K4_OUT}/scenario.exit")" == 0 ]]
    # A failure keeps its status in the file and in Task's exit.
    export settings_fault=reopen-2-selection-setup-sheets
    rm -rf "${scenario_repo}/.build" "${KOINE_VM_EVIDENCE_ROOT}"
    rm -f "${settings_sim}/calls.jsonl" "${settings_sim}/state.json"
    run task --dir "${scenario_repo}" app:vm-verify-menu-bar-prefix
    [[ "${status}" != 0 && "$(cat "${KOINE_K4_OUT}/scenario.exit")" == 125 ]]
}
