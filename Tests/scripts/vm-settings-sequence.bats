#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Every test owns its environment.
# The finite Settings ordering sequence, scripts/settings-ordering-sequence.py,
# without a VM. Evidence roots hold real receipts from scripts/vm-guest-exec.py.
# Scenario controls replay the calls of the real entry points, which ran against
# the simulated backend. No control starts a clone.

setup() {
    bats_require_minimum_version 1.5.0
    export repo_root="${BATS_TEST_DIRNAME}/../.."
    export tool="${repo_root}/scripts/settings-ordering-sequence.py"
    export backend="${repo_root}/scripts/vm-guest-exec.py"
    export sequence="${BATS_TEST_TMPDIR}/sequence"
}

seq_tool() { python3 -I "${tool}" "$@"; }
# settle_phases SLOT PHASES: reach one row of the decision table. The product
# settle verb takes no phases, so only this control fixture can supply them.
settle_phases() {
    python3 -I "${repo_root}/Tests/scripts/fixtures/settings-sequence-settle.py" \
        "${tool}" "${sequence}" "$@"
}

# value SLOT FIELD: one field of a declared slot.
slot_field() {
    jq -er --arg slot "$1" --arg field "$2" '.slots[] | select(.slot == $slot) | .[$field]' \
        "${sequence}/sequence.json"
}

# phases [KEY=RESULT...]: every phase passed, except the named overrides.
# scenario=N and task=N set a status, and "null" means no status.
phases() {
    local scenario=0 task=0 file="${BATS_TEST_TMPDIR}/phases-$RANDOM$RANDOM.json" item key value
    local filter='.'
    for item in "$@"; do
        key="${item%%=*}" value="${item#*=}"
        case "${key}" in
        scenario) scenario="${value}" ;;
        task) task="${value}" ;;
        *) filter+=" | .${key}.result = \"${value}\"" ;;
        esac
    done
    jq -n --argjson scenario "${scenario}" --argjson task "${task}" '
        {result: "passed", detail: "control"} as $p
        | {scenario: {status: $scenario}, task: {status: $task}, collection: $p, subject: $p, environment: $p,
           endpoint: $p, audit: $p, stop: $p, inventory: $p, screenshots: $p}' |
        jq "${filter}" >"${file}"
    printf '%s\n' "${file}"
}

ready_receipt() {
    local file="${BATS_TEST_TMPDIR}/ready-$1.json"
    printf '{"set":"%s"}\n' "$1" >"${file}"
    printf '%s\n' "${file}"
}

# complete_root SLOT: one real root whose last clean receipt is the terminal
# operation of that slot's set.
complete_root() {
    local root terminal=textedit-quit-absence-state
    root="$(slot_field "$1" evidence_root)"
    [[ "$1" == E* ]] || terminal=installed-after
    python3 "${backend}" init "${root}" "$(slot_field "$1" clone)"
    python3 "${backend}" poll-step "${root}" "${terminal}" state 0 control
}

qualify() {
    seq_tool admit "${sequence}" "$1" >/dev/null
    complete_root "$1"
    settle_phases "$1" "$(phases)" >/dev/null
}

declare_ready() {
    seq_tool declare "${sequence}" >/dev/null
    seq_tool ready "${sequence}" focused "$(ready_receipt focused)" >/dev/null
}

expect_refused() {
    [[ "${status}" == 3 && "${output}" == *"$1"* ]] || {
        echo "expected a refusal with \"$1\": status ${status}: ${output}"
        return 1
    }
}

report_field() { seq_tool report "${sequence}" | jq -er "$1"; }

# step ROOT OPERATION [state|exhausted]: one real local receipt.
step() {
    if [[ "${3:-state}" == exhausted ]]; then
        python3 "${backend}" poll-step "$1" "$2" exhausted 1 control >/dev/null 2>&1 || :
    else
        python3 "${backend}" poll-step "$1" "$2" state 0 control
    fi
}

# simulate ENTRY: run a real entry point against the simulated backend and
# replay its calls into the real root $replayed. Environment selects a fault.
simulate() {
    local work="${BATS_TEST_TMPDIR}/sim-run"
    rm -rf "${work}"
    mkdir -p "${work}/bin" "${work}/sim" "${work}/repo/App" "${work}/repo/bundle/Koine.app/Contents"
    cp -R "${repo_root}/scripts" "${work}/repo/scripts"
    cp "${repo_root}/App/Info.plist" "${work}/repo/App/Info.plist"
    echo bundle >"${work}/repo/bundle/Koine.app/Contents/Info.plist"
    cp "${repo_root}/Tests/scripts/fixtures/settings-scenario-backend.py" "${work}/repo/scripts/vm-guest-exec.py"
    printf '#!/bin/bash\nexit 97\n' >"${work}/bin/testanyware"
    printf '#!/bin/bash\nexit 0\n' >"${work}/bin/sleep"
    chmod +x "${work}/bin/testanyware" "${work}/bin/sleep"
    PATH="${work}/bin:${PATH}" settings_sim="${work}/sim" scenario_legacy="${work}/legacy" \
        scenario_waits="${work}/waits" KOINE_APP_BUNDLE="${work}/repo/bundle/Koine.app" \
        KOINE_VM_BASE=testanyware-golden-macos-27 KOINE_VM_ID=exact-clone \
        KOINE_VM_EVIDENCE_ROOT="${work}/sim-root" "${work}/repo/scripts/$1" >"${work}/out" 2>&1 || :
    export replayed="${BATS_TEST_TMPDIR}/replayed-$RANDOM$RANDOM"
    python3 -I "${repo_root}/Tests/scripts/fixtures/settings-sequence-replay.py" \
        "${repo_root}/scripts" "${work}/sim/calls.jsonl" "${replayed}" exact-clone
}

classify() { seq_tool classify "${1:-${replayed}}" "${2:-ordinary}" "${3:-exact-clone}"; }

expect_kind() {
    local result
    result="$(classify)"
    jq -e --arg kind "$1" '.kind == $kind' <<<"${result}" >/dev/null || {
        echo "expected kind $1: ${result}"
        return 1
    }
    printf '%s\n' "${result}"
}

# --- declaration ------------------------------------------------------------

@test "the declaration holds exactly the five slots, in order, with their identities" {
    run seq_tool declare "${sequence}"
    [[ "${status}" == 0 ]]
    [[ "$(jq -r '[.slots[].slot] | join(" ")' "${sequence}/sequence.json")" == "E01 E02 A01 A02 A03" ]]
    [[ "$(jq -r '[.slots[].clone] | join(" ")' "${sequence}/sequence.json")" == "koine-k49-ordering-e01 koine-k49-ordering-e02 koine-k49-ordinary-a01 koine-k49-ordinary-a02 koine-k49-ordinary-a03" ]]
    [[ "$(jq -r '[.slots[].namespace] | unique | join(" ")' "${sequence}/sequence.json")" == "ordering-evaluation ordering-ordinary" ]]
    [[ "$(slot_field E02 entry)" == app:vm-verify-menu-bar-prefix ]]
    [[ "$(slot_field A03 entry)" == app:vm-verify-menu-bar ]]
    [[ "$(jq -r .base "${sequence}/sequence.json")" == testanyware-golden-macos-27 ]]
    [[ "$(stat -f %Lp "${sequence}")" == 700 ]]
    [[ ! -e "$(slot_field E01 evidence_root)" && -d "$(slot_field E01 output)" ]]
}

@test "a declaration refuses an existing directory" {
    mkdir "${sequence}"
    run seq_tool declare "${sequence}"
    expect_refused "already exists"
}

# --- admission --------------------------------------------------------------

@test "admission takes only the next slot, after its set is ready" {
    seq_tool declare "${sequence}"
    run seq_tool admit "${sequence}" E01
    expect_refused "not ready"
    seq_tool ready "${sequence}" focused "$(ready_receipt focused)"
    for slot in E02 A01 A03; do
        run seq_tool admit "${sequence}" "${slot}"
        expect_refused "next slot is E01"
    done
    run seq_tool admit "${sequence}" E01
    [[ "${status}" == 0 && "$(jq -r .clone <<<"${output}")" == koine-k49-ordering-e01 ]]
    run seq_tool admit "${sequence}" E01
    expect_refused "unsettled"
}

@test "a started slot without a settlement blocks the next slot" {
    declare_ready
    seq_tool admit "${sequence}" E01
    run seq_tool admit "${sequence}" E02
    expect_refused "E01 is unsettled"
    [[ "$(report_field '.slots.E01.state')" == started-unsettled ]]
    [[ "$(report_field '.slots.E02.state')" == "NOT RUN" ]]
}

@test "the ordinary set needs both focused slots qualified and its own readiness" {
    declare_ready
    run seq_tool ready "${sequence}" ordinary "$(ready_receipt ordinary)"
    expect_refused "both focused slots"
    qualify E01
    run seq_tool ready "${sequence}" ordinary "$(ready_receipt ordinary)"
    expect_refused "both focused slots"
    qualify E02
    run seq_tool admit "${sequence}" A01
    expect_refused "not ready"
    seq_tool ready "${sequence}" ordinary "$(ready_receipt ordinary)"
    run seq_tool ready "${sequence}" ordinary "$(ready_receipt ordinary)"
    expect_refused "already ready"
    qualify A01
}

@test "five qualified slots end the sequence, and no sixth admission exists" {
    declare_ready
    qualify E01
    qualify E02
    [[ "$(report_field .outcome)" == focused-sample-passed ]]
    seq_tool ready "${sequence}" ordinary "$(ready_receipt ordinary)"
    qualify A01
    qualify A02
    qualify A03
    # Acceptance also needs the closing golden audit, which vm-settings-audits.bats runs.
    [[ "$(report_field .outcome)" == awaiting-golden-audit ]]
    run seq_tool admit "${sequence}" A03
    expect_refused "no slot remains"
    run seq_tool admit "${sequence}" A04
    [[ "${status}" == 2 ]]
}

@test "the first failure stops the sequence and leaves every later slot NOT RUN" {
    declare_ready
    qualify E01
    seq_tool admit "${sequence}" E02
    root="$(slot_field E02 evidence_root)"
    python3 "${backend}" init "${root}" koine-k49-ordering-e02
    step "${root}" scenario-assertion-setup-failed exhausted
    settle_phases E02 "$(phases scenario=1 task=201)" >/dev/null
    [[ "$(report_field '.slots.E02.disposition')" == failed ]]
    for slot in A01 A02 A03; do
        [[ "$(report_field ".slots.${slot}.state")" == "NOT RUN" ]]
    done
    [[ "$(report_field .outcome)" == no-acceptance ]]
    run seq_tool ready "${sequence}" ordinary "$(ready_receipt ordinary)"
    expect_refused "stopped"
    run seq_tool admit "${sequence}" A01
    expect_refused "stopped"
    run settle_phases E02 "$(phases)"
    expect_refused "not awaiting settlement"
}

@test "one writer: a held lock refuses and records the refusal" {
    declare_ready
    python3 -I -c '
import fcntl, sys, time
stream = open(sys.argv[1], "a")
fcntl.flock(stream, fcntl.LOCK_EX)
print("held", flush=True)
time.sleep(30)
' "${sequence}/.writer" >"${BATS_TEST_TMPDIR}/held" &
    holder=$!
    for _ in {1..100}; do
        [[ -s "${BATS_TEST_TMPDIR}/held" ]] && break
        /bin/sleep 0.05
    done
    run seq_tool admit "${sequence}" E01
    kill "${holder}"
    wait "${holder}" || :
    expect_refused "competing"
    [[ "$(jq -r .reason "${sequence}/refusals.jsonl")" == *competing* ]]
    [[ "$(find "${sequence}/ledger" -name '*-started.json' | wc -l | tr -d ' ')" == 0 ]]
}

@test "a changed declaration or ledger refuses every later step" {
    declare_ready
    cp -p "${sequence}/sequence.json" "${BATS_TEST_TMPDIR}/sequence.json"
    chmod u+w "${sequence}/sequence.json"
    jq '.slots[0].clone = "other-clone"' "${BATS_TEST_TMPDIR}/sequence.json" >"${sequence}/sequence.json"
    run seq_tool admit "${sequence}" E01
    expect_refused "declaration"
    cp "${BATS_TEST_TMPDIR}/sequence.json" "${sequence}/sequence.json"
    seq_tool admit "${sequence}" E01 >/dev/null
    printf '{"ordinal": 9, "event": "settled"}\n' >"${sequence}/ledger/000009-settled.json"
    run seq_tool report "${sequence}"
    expect_refused "ledger"
    rm "${sequence}/ledger/000009-settled.json"
    printf 'partial' >"${sequence}/ledger/000003-settled.json.partial"
    run settle_phases E01 "$(phases)"
    expect_refused "ledger"
}

@test "an admission refuses a reused evidence root or a used output directory" {
    declare_ready
    mkdir "$(slot_field E01 evidence_root)"
    run seq_tool admit "${sequence}" E01
    expect_refused "evidence root"
    rmdir "$(slot_field E01 evidence_root)"
    : >"$(slot_field E01 output)/left-over"
    run seq_tool admit "${sequence}" E01
    expect_refused "output directory"
}

# --- classification of real receipts ----------------------------------------

@test "a complete run classifies as complete for its own set only" {
    simulate vm-verify-menu-bar-prefix.sh
    result="$(classify "${replayed}" focused)"
    jq -e '.kind == "complete" and .pointer == "none" and .attempts > 100' <<<"${result}"
    # The focused terminal operation does not complete the ordinary scenario.
    [[ "$(classify "${replayed}" ordinary | jq -r .kind)" == incomplete ]]
    simulate vm-verify-menu-bar.sh
    jq -e '.kind == "complete" and .pointer == "released"' <<<"$(classify "${replayed}" ordinary)"
}

@test "a run that stops before its terminal receipt is incomplete, even at status zero" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" textedit-quit
    [[ "$(classify "${root}" focused | jq -r .kind)" == incomplete ]]
}

@test "the three recurrence classes on a menu return are candidates, with their return" {
    export settings_flags=zero-window-alive settings_at=2
    simulate vm-verify-menu-bar.sh
    result="$(expect_kind recurrence-candidate)"
    jq -e '.class == "zero-window-same-process" and .return == "reopen-1" and .blockers == []' <<<"${result}"
    export settings_flags=two-windows settings_at=1
    simulate vm-verify-menu-bar.sh
    jq -e '.class == "multiple-windows" and .return == "first-selection"' <<<"$(expect_kind recurrence-candidate)"
    export settings_flags=no-front-after-settings
    simulate vm-verify-menu-bar.sh
    jq -e '.class == "not-front" and .blockers == []' <<<"$(expect_kind recurrence-candidate)"
}

@test "a false front outside a menu return is a failed assertion, not a recurrence" {
    unset settings_flags settings_at
    export settings_finder_front=resize-front
    simulate vm-verify-menu-bar.sh
    jq -e '.class == "not-front" and (.blockers | length > 0)' <<<"$(expect_kind assertion-failed)"
}

@test "a failed observer before a recurrence class leaves the outcome unresolved" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" exact-clone
    for op in first-selection-identity first-selection-enabled screenshot-menu-first-selection \
        menu-click first-selection-front first-selection-front-state first-selection-front-title-state; do
        step "${root}" "${op}"
    done
    python3 "${backend}" fail "${root}" first-selection-front-application 'observer failed' || :
    for op in first-selection-failure-windows failure-capture first-selection-menu-closed; do
        step "${root}" "${op}"
    done
    step "${root}" scenario-assertion-not-front exhausted
    result="$(classify "${root}")"
    jq -e '.kind == "unresolved-outcome" and .class == "not-front"
        and (.blockers | any(test("first-selection-front-application")))' <<<"${result}"
}

@test "a recurrence needs one clean click between the enabled read and its class" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" exact-clone
    for op in first-selection-identity first-selection-enabled screenshot-menu-first-selection \
        first-selection-front first-selection-front-state first-selection-front-title-state \
        first-selection-front-application first-selection-failure-windows failure-capture \
        first-selection-menu-closed; do
        step "${root}" "${op}"
    done
    step "${root}" scenario-assertion-not-front exhausted
    jq -e '.kind == "unresolved-outcome" and (.blockers | any(test("one clean row click")))' \
        <<<"$(classify "${root}")"
}

@test "other classes keep their own disposition" {
    export settings_flags=two-windows settings_at=1
    root="${BATS_TEST_TMPDIR}/root"
    for class in window-identity process-lost setup-failed menu-item-disabled; do
        rm -rf "${root}"
        python3 "${backend}" init "${root}" exact-clone
        step "${root}" "scenario-assertion-${class}" exhausted
        jq -e --arg class "${class}" '.kind == "assertion-failed" and .class == $class' <<<"$(classify "${root}")"
    done
    rm -rf "${root}"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" scenario-assertion-menu-open exhausted
    jq -e '.kind == "unresolved-outcome" and .class == "menu-open"' <<<"$(classify "${root}")"
}

@test "signals, boot exhaustion and poll exhaustion classify by their receipts" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" exact-clone
    python3 "${backend}" fail "${root}" scenario-signal-TERM 'interrupted' || :
    jq -e '.kind == "interrupted" and .signals == ["TERM"]' <<<"$(classify "${root}")"
    rm -rf "${root}"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" restart-boot-exhausted exhausted
    jq -e '.kind == "test-driver"' <<<"$(classify "${root}")"
    rm -rf "${root}"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" first-selection-row-exhausted exhausted
    jq -e '.kind == "assertion-failed" and .exhausted == ["first-selection-row-exhausted"]' <<<"$(classify "${root}")"
    rm -rf "${root}"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" reopen-1-window-exhausted exhausted
    [[ "$(classify "${root}" | jq -r .kind)" == unresolved-outcome ]]
}

@test "the pointer state comes from the ordered held-point receipts" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" resize-down-1
    # A failed wait is a latch reason, and it is not a held point.
    python3 "${backend}" poll-step "${root}" resize-hold-1-wait sleep 1 control || :
    [[ "$(classify "${root}" | jq -r .pointer)" == held ]]
    rm -rf "${root}"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" resize-down-1
    step "${root}" resize-release
    [[ "$(classify "${root}" | jq -r .pointer)" == released ]]
    python3 "${backend}" fail "${root}" resize-release 'failed release' || :
    [[ "$(classify "${root}" | jq -r .pointer)" == uncertain ]]
    rm -rf "${root}"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" resize-down-1
    rm "${root}/000001/result.json"
    jq -e '.pointer == "uncertain" and .kind == "unavailable"' <<<"$(classify "${root}")"
}

@test "an evidence root of another clone or a missing root is not a Koine failure" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" other-clone
    step "${root}" textedit-quit-absence-state
    [[ "$(classify "${root}" focused exact-clone | jq -r .kind)" == unavailable ]]
    [[ "$(classify "${BATS_TEST_TMPDIR}/absent" focused | jq -r .kind)" == no-root ]]
}

@test "a latch or a refusal keeps an otherwise complete run unavailable" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" textedit-quit-absence-state
    printf '{"reason":"refused"}\n' >"${root}/refusals.jsonl"
    [[ "$(classify "${root}" focused | jq -r .kind)" == unavailable ]]
    rm "${root}/refusals.jsonl"
    printf 'latched\n' >"${root}/unavailable"
    [[ "$(classify "${root}" focused | jq -r .kind)" == unavailable ]]
}

# --- settlement -------------------------------------------------------------

# settle_with_class CLASS PHASE...: E01 ends with one classified menu return.
settle_recurrence() {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    root="$(slot_field E01 evidence_root)"
    python3 "${backend}" init "${root}" koine-k49-ordering-e01
    for op in first-selection-identity first-selection-enabled screenshot-menu-first-selection \
        menu-click first-selection-front first-selection-front-state first-selection-front-title-state \
        first-selection-front-application first-selection-failure-windows failure-capture \
        first-selection-menu-closed; do
        step "${root}" "${op}"
    done
    step "${root}" scenario-assertion-not-front exhausted
    settle_phases E01 "$(phases scenario=1 task=201 "$@")" >/dev/null
}

@test "a corroborated recurrence rejects, and later failures do not erase it" {
    settle_recurrence collection=failed audit=unavailable stop=failed inventory=unavailable
    [[ "$(report_field '.slots.E01.disposition')" == rejected ]]
    [[ "$(report_field .outcome)" == rejected ]]
    [[ "$(report_field '.slots.E01.cleanup')" == unresolved ]]
    [[ "$(report_field '.slots.E01.phases.collection.result')" == failed ]]
    [[ "$(report_field '.slots.E02.state')" == "NOT RUN" ]]
}

@test "a recurrence without a corroborating screenshot stays unresolved" {
    settle_recurrence screenshots=unavailable
    [[ "$(report_field '.slots.E01.disposition')" == unresolved ]]
    [[ "$(report_field .outcome)" == no-acceptance ]]
}

@test "a recurrence without the admitted subject stays unresolved" {
    local result
    for result in failed unavailable not-run; do
        rm -rf "${sequence:?}"
        settle_recurrence "subject=${result}"
        [[ "$(report_field '.slots.E01.classification.kind')" == recurrence-candidate ]]
        [[ "$(report_field '.slots.E01.disposition')" == unresolved ]]
        [[ "$(report_field .outcome)" == no-acceptance ]]
    done
}

@test "every phase and status must pass before a slot qualifies" {
    for override in task=201 scenario=null collection=failed subject=failed environment=unavailable endpoint=not-run \
        audit=failed stop=failed inventory=unavailable screenshots=not-run; do
        rm -rf "${sequence}"
        declare_ready
        seq_tool admit "${sequence}" E01 >/dev/null
        complete_root E01
        settle_phases E01 "$(phases "${override}")" >/dev/null
        [[ "$(report_field '.slots.E01.disposition')" == unresolved ]] || {
            echo "override ${override} qualified"
            return 1
        }
    done
}

@test "a scenario zero cannot override failed receipts" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    root="$(slot_field E01 evidence_root)"
    python3 "${backend}" init "${root}" koine-k49-ordering-e01
    step "${root}" scenario-assertion-setup-failed exhausted
    settle_phases E01 "$(phases)" >/dev/null
    [[ "$(report_field '.slots.E01.disposition')" == unresolved ]]
    [[ "$(report_field '.slots.E01.conflicts | length')" -gt 0 ]]
}

@test "a run that left no root is unresolved and claims no Koine failure" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    settle_phases E01 "$(phases scenario=2 task=201)" >/dev/null
    [[ "$(report_field '.slots.E01.disposition')" == unresolved ]]
    [[ "$(report_field '.slots.E01.classification.kind')" == no-root ]]
}

@test "held input prevents a slot from qualifying" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    root="$(slot_field E01 evidence_root)"
    python3 "${backend}" init "${root}" koine-k49-ordering-e01
    step "${root}" resize-down-1
    step "${root}" textedit-quit-absence-state
    settle_phases E01 "$(phases)" >/dev/null
    [[ "$(report_field '.slots.E01.disposition')" == unresolved ]]
    [[ "$(report_field '.slots.E01.classification.pointer')" == held ]]
}

@test "malformed phases refuse and leave the slot unsettled" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    complete_root E01
    bad="${BATS_TEST_TMPDIR}/bad.json"
    for filter in 'del(.stop)' '.extra = 1' '.stop.result = "fine"' '.task.status = "0"' '.scenario.status = 300' \
        '.audit.detail = 1'; do
        jq "${filter}" "$(phases)" >"${bad}"
        run settle_phases E01 "${bad}"
        expect_refused "phases"
    done
    printf '{"scenario": {"status": 0}, "scenario": {"status": 1}}' >"${bad}"
    run settle_phases E01 "${bad}"
    expect_refused "phases"
    [[ "$(report_field '.slots.E01.state')" == started-unsettled ]]
}

# --- recovery after a lost caller -------------------------------------------

@test "a recovery settlement takes no phases from its operator" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    complete_root E01
    run seq_tool settle "${sequence}" E01 "$(phases)"
    [[ "${status}" == 2 ]]
    [[ "$(report_field '.slots.E01.state')" == started-unsettled ]]
}

@test "a recovery of a complete root cannot qualify or confirm cleanup" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    complete_root E01
    printf '0\n' >"$(slot_field E01 output)/scenario.exit"
    seq_tool settle "${sequence}" E01 >/dev/null
    [[ "$(report_field '.slots.E01.classification.kind')" == complete ]]
    [[ "$(report_field '.slots.E01.disposition')" == unresolved ]]
    [[ "$(report_field '.slots.E01.cleanup')" == unresolved ]]
    [[ "$(report_field '.slots.E01.phases.scenario.status')" == 0 ]]
    [[ "$(report_field '.slots.E01.phases.task.status')" == null ]]
    [[ "$(report_field '[.slots.E01.phases | to_entries[] | select(.value.result?) | .value.result] | unique | join(" ")')" == unavailable ]]
    run seq_tool admit "${sequence}" E02
    expect_refused "stopped"
}

@test "a recovery keeps a recurrence class without rejecting the repair" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    root="$(slot_field E01 evidence_root)"
    python3 "${backend}" init "${root}" koine-k49-ordering-e01
    for op in first-selection-identity first-selection-enabled screenshot-menu-first-selection \
        menu-click first-selection-front first-selection-front-state first-selection-front-title-state \
        first-selection-front-application first-selection-failure-windows failure-capture \
        first-selection-menu-closed; do
        step "${root}" "${op}"
    done
    step "${root}" scenario-assertion-not-front exhausted
    printf '1\n' >"$(slot_field E01 output)/scenario.exit"
    seq_tool settle "${sequence}" E01 >/dev/null
    [[ "$(report_field '.slots.E01.classification.kind')" == recurrence-candidate ]]
    [[ "$(report_field '.slots.E01.disposition')" == unresolved ]]
    [[ "$(report_field .outcome)" == no-acceptance ]]
}

@test "a recovery keeps a failed assertion, with its cleanup unresolved" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    root="$(slot_field E01 evidence_root)"
    python3 "${backend}" init "${root}" koine-k49-ordering-e01
    step "${root}" scenario-assertion-setup-failed exhausted
    printf '1\n' >"$(slot_field E01 output)/scenario.exit"
    seq_tool settle "${sequence}" E01 >/dev/null
    [[ "$(report_field '.slots.E01.disposition')" == failed ]]
    [[ "$(report_field '.slots.E01.cleanup')" == unresolved ]]
}

@test "a recovery with no root or scenario status stays unresolved" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    seq_tool settle "${sequence}" E01 >/dev/null
    [[ "$(report_field '.slots.E01.classification.kind')" == no-root ]]
    [[ "$(report_field '.slots.E01.disposition')" == unresolved ]]
    [[ "$(report_field '.slots.E01.phases.scenario.status')" == null ]]
}

# --- defects that a read of the handoffs found -------------------------------

@test "an exhausted poll keeps its status 125 and settles as a failed assertion" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    root="$(slot_field E01 evidence_root)"
    python3 "${backend}" init "${root}" koine-k49-ordering-e01
    step "${root}" first-selection-row-exhausted exhausted
    settle_phases E01 "$(phases scenario=125 task=201)" >/dev/null
    [[ "$(report_field '.slots.E01.disposition')" == failed ]]
    [[ "$(report_field '.slots.E01.conflicts | length')" == 0 ]]
}

@test "an exhausted poll with a scenario zero is a conflict" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    root="$(slot_field E01 evidence_root)"
    python3 "${backend}" init "${root}" koine-k49-ordering-e01
    step "${root}" first-selection-row-exhausted exhausted
    settle_phases E01 "$(phases)" >/dev/null
    [[ "$(report_field '.slots.E01.disposition')" == unresolved ]]
}

@test "a signal that met a held lock is classified from its refusal record" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" first-selection-identity
    python3 -I -c '
import fcntl, sys, time
stream = open(sys.argv[1], "a")
fcntl.flock(stream, fcntl.LOCK_EX)
print("held", flush=True)
time.sleep(30)
' "${root}/.writer" >"${BATS_TEST_TMPDIR}/held" &
    holder=$!
    for _ in {1..100}; do
        [[ -s "${BATS_TEST_TMPDIR}/held" ]] && break
        /bin/sleep 0.05
    done
    python3 "${backend}" fail "${root}" scenario-signal-INT 'interrupted' || :
    kill "${holder}"
    wait "${holder}" || :
    jq -e '.kind == "interrupted" and .signals == ["INT"]' <<<"$(classify "${root}")"
}

@test "an ordinal gap before a recurrence class blocks the candidate" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" exact-clone
    for op in lost-attempt first-selection-identity first-selection-enabled screenshot-menu-first-selection \
        menu-click first-selection-front first-selection-front-state first-selection-front-title-state \
        first-selection-front-application first-selection-failure-windows failure-capture \
        first-selection-menu-closed; do
        step "${root}" "${op}"
    done
    step "${root}" scenario-assertion-not-front exhausted
    rm -rf "${root}/000001"
    jq -e '.kind == "unresolved-outcome" and (.blockers | any(test("gap")))' <<<"$(classify "${root}")"
}

@test "a failure after the class does not remove a recurrence candidate" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" exact-clone
    for op in first-selection-identity first-selection-enabled screenshot-menu-first-selection \
        menu-click first-selection-front first-selection-front-state first-selection-front-title-state \
        first-selection-front-application first-selection-failure-windows failure-capture \
        first-selection-menu-closed; do
        step "${root}" "${op}"
    done
    step "${root}" scenario-assertion-not-front exhausted
    python3 "${backend}" fail "${root}" later-collection 'collection failed' || :
    step "${root}" another-collection
    rm "${root}/000014/result.json"
    jq -e '.kind == "recurrence-candidate" and (.unfinished | length) == 1' <<<"$(classify "${root}")"
}

@test "an unreadable request can hide a held point, so the pointer is uncertain" {
    root="${BATS_TEST_TMPDIR}/root"
    python3 "${backend}" init "${root}" exact-clone
    step "${root}" resize-down-1
    step "${root}" resize-release
    rm "${root}/000002/request.json"
    [[ "$(classify "${root}" | jq -r .pointer)" == uncertain ]]
}

@test "a hand-edited disposition refuses when the ledger replays" {
    declare_ready
    seq_tool admit "${sequence}" E01 >/dev/null
    root="$(slot_field E01 evidence_root)"
    python3 "${backend}" init "${root}" koine-k49-ordering-e01
    step "${root}" scenario-assertion-setup-failed exhausted
    settle_phases E01 "$(phases scenario=1 task=201)" >/dev/null
    entry="${sequence}/ledger/000003-settled.json"
    jq '.disposition = "qualified"' "${entry}" >"${entry}.edited"
    chmod u+w "${entry}"
    mv "${entry}.edited" "${entry}"
    run seq_tool admit "${sequence}" E02
    expect_refused "ledger"
}

@test "an unreadable output directory refuses the admission without a traceback" {
    declare_ready
    rmdir "$(slot_field E01 output)"
    run seq_tool admit "${sequence}" E01
    expect_refused "E01"
    [[ "${output}" != *Traceback* ]]
    [[ "$(find "${sequence}/ledger" -name '*-started.json' | wc -l | tr -d ' ')" == 0 ]]
}
