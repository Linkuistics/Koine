#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Every test owns its environment.
# The slot run and containment of scripts/settings-ordering-sequence.py, without
# a VM. A fake `task` writes real receipts through the real facades, against the
# synthetic TestAnyware CLI. No control starts a clone.

setup() {
    bats_require_minimum_version 1.5.0
    export repo_root="${BATS_TEST_DIRNAME}/../.."
    export run_repo="${repo_root}"
    export tool="${repo_root}/scripts/settings-ordering-sequence.py"
    export sequence="${BATS_TEST_TMPDIR}/sequence"
    export lifecycle_calls="${BATS_TEST_TMPDIR}/calls"
    export lifecycle_guest="${BATS_TEST_TMPDIR}/guest"
    export lifecycle_state="${BATS_TEST_TMPDIR}/running"
    export lifecycle_ready="${BATS_TEST_TMPDIR}/ready"
    export lifecycle_fixture="${BATS_TEST_DIRNAME}/fixtures/file-lifecycle-cli.py"
    export run_fixture="${BATS_TEST_DIRNAME}/fixtures/settings-run-task.sh"
    export run_log="${BATS_TEST_TMPDIR}/task-calls"
    export run_ready="${BATS_TEST_TMPDIR}/task-ready"
    export run_holder="${BATS_TEST_TMPDIR}/holder"
    export lifecycle_mode=clean lifecycle_exit=0 lifecycle_block=0 run_mode=complete
    export KOINE_SEQUENCE_BOUNDS="holder=0.8,term=0.8,kill=3,stop=8,inventory=8,audit=8"
    unset KOINE_VM_KEEP KOINE_VM_DISPLAY KOINE_SETTINGS_TRACE lifecycle_only guest_fail
    # A mise shim would resolve back to the stub below, so skip the shim directory.
    real_task="$(type -ap task | grep -v '/mise/shims/' | head -n 1)"
    export real_task
    export frozen="${BATS_TEST_TMPDIR}/frozen"
    export screens="${BATS_TEST_TMPDIR}/screens.json"
    mkdir "${BATS_TEST_TMPDIR}/bin" "${lifecycle_guest}" "${frozen}"
    # shellcheck disable=SC2016 # The stub expands these when it runs.
    printf '#!/bin/bash\nexec python3 "${lifecycle_fixture}" "$@"\n' >"${BATS_TEST_TMPDIR}/bin/testanyware"
    # shellcheck disable=SC2016 # The stub expands these when it runs.
    printf '#!/bin/bash\nexec bash "${run_fixture}" "$@"\n' >"${BATS_TEST_TMPDIR}/bin/task"
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware" "${BATS_TEST_TMPDIR}/bin/task"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    : >"${lifecycle_calls}"
    : >"${run_log}"
    seq_tool declare "${sequence}" >/dev/null
    # shellcheck source=Tests/scripts/fixtures/settings-audit-frozen.sh
    source "${BATS_TEST_DIRNAME}/fixtures/settings-audit-frozen.sh"
    frozen_prepare
    frozen_receipt focused "${BATS_TEST_TMPDIR}/ready.json"
    printf '{"result":"passed","detail":"control"}\n' >"${screens}"
    seq_tool ready "${sequence}" focused "${BATS_TEST_TMPDIR}/ready.json" >/dev/null
}

teardown() {
    # Release a holder outside the group, so that no control leaks a process.
    if [[ -s "${run_holder}" ]]; then : >"${run_holder}.release"; fi
    if [[ -f "${lifecycle_ready}" ]]; then : >"${lifecycle_ready}.release"; fi
}

seq_tool() { python3 -I "${tool}" "$@"; }

slot_field() {
    jq -er --arg slot "$1" --arg field "$2" '.slots[] | select(.slot == $slot) | .[$field]' \
        "${sequence}/sequence.json"
}

out_dir() { slot_field E01 output; }
root() { slot_field E01 evidence_root; }
result() { jq -er "$1" "$(out_dir)/containment/result.json"; }
report() { seq_tool report "${sequence}" | jq -er "$1"; }
settled() { report ".slots.E01.$1"; }
phase() { settled "phases.$1.result"; }
count_cli() { jq -c --arg a "$1" --arg b "$2" 'select(.[0] == $a and .[1] == $b)' "${lifecycle_calls}" | wc -l | tr -d ' '; }
stops() { count_cli vm stop; }
starts() { count_cli vm start; }
lists() { count_cli vm list; }
inputs() { jq -c 'select(.[0] == "input")' "${lifecycle_calls}" | wc -l | tr -d ' '; }
tasks() { wc -l <"${run_log}" | tr -d ' '; }
is_running() { grep -qx koine-k49-ordering-e01 "${lifecycle_state}" 2>/dev/null; }
actions() { jq -r .action "$(out_dir)/containment/actions.jsonl"; }
# A bare ! cannot fail a Bats test, so these two return a status.
not_running() { if is_running; then
    echo "the clone is still running"
    return 1
fi; }
no_action() { if actions | grep -qx "$1"; then
    echo "unexpected action $1"
    return 1
fi; }

# run_e01: run the slot, and settle a collected run with a passed screenshot
# audit. The status and output stay those of the run.
run_e01() {
    run seq_tool run "${sequence}" E01
    [[ "${status}" == 0 ]] || return 0
    seq_tool settle-run "${sequence}" E01 "${screens}" >/dev/null
}

expect_refused() {
    [[ "${status}" == 3 && "${output}" == *"$1"* ]] || {
        echo "expected a refusal with \"$1\": status ${status}: ${output}"
        return 1
    }
}

# --- admission and the Task entry -------------------------------------------

@test "run admits the slot and runs its declared entry once, in its own recorded group" {
    run_e01
    [[ "${status}" == 0 ]]
    [[ "$(tasks)" == 1 ]]
    local call recorded
    call="$(cat "${run_log}")"
    recorded="$(out_dir)/containment/process.json"
    [[ "$(jq -r .entry <<<"${call}")" == app:vm-verify-menu-bar-prefix ]]
    [[ "$(jq -r .pgid <<<"${call}")" == "$(jq -r .pgid "${recorded}")" ]]
    [[ "$(jq -r .pid <<<"${call}")" == "$(jq -r .pgid <<<"${call}")" ]]
    [[ "$(jq -r .pgid <<<"${call}")" != "$(ps -o pgid= -p $$ | tr -d ' ')" ]]
    [[ "$(report '.slots.E01.state')" == settled ]]
}

@test "the run passes the declared clone, base, evidence root and output directory" {
    run_e01
    local call
    call="$(cat "${run_log}")"
    [[ "$(jq -r .vm <<<"${call}")" == koine-k49-ordering-e01 ]]
    [[ "$(jq -r .base <<<"${call}")" == testanyware-golden-macos-27 ]]
    [[ "$(jq -r .root <<<"${call}")" == "$(root)" ]]
    [[ "$(jq -r .out <<<"${call}")" == "$(out_dir)" ]]
    [[ "$(settled 'phases.scenario.status')" == 0 && "$(settled 'phases.task.status')" == 0 ]]
}

@test "a keep, display or trace request refuses before admission and consumes no slot" {
    local name
    for name in KOINE_VM_KEEP KOINE_VM_DISPLAY KOINE_SETTINGS_TRACE; do
        run env "${name}=1" python3 -I "${tool}" run "${sequence}" E01
        expect_refused "${name}"
    done
    [[ "$(tasks)" == 0 && "$(report '.slots.E01.state')" == "NOT RUN" ]]
    [[ ! -e "$(out_dir)/containment" ]]
}

@test "a slot that the ledger refuses starts no Task" {
    run seq_tool run "${sequence}" E02
    expect_refused "next slot is E01"
    [[ "$(tasks)" == 0 ]]
}

@test "a settled slot cannot run again" {
    run_e01
    run_e01
    expect_refused "next slot is E02"
    [[ "$(tasks)" == 1 && "$(stops)" == 1 ]]
}

@test "a missing Task executable refuses before admission" {
    local interpreter
    interpreter="$(python3 -c 'import sys; print(sys.executable)')"
    run env PATH=/nonexistent "${interpreter}" -I "${tool}" run "${sequence}" E01
    expect_refused "task"
    [[ "$(report '.slots.E01.state')" == "NOT RUN" ]]
}

@test "a manual settle cannot take a slot while its run is live" {
    export run_mode=signal-wait
    python3 -I "${tool}" run "${sequence}" E01 >/dev/null 2>&1 &
    local caller=$! phases="${BATS_TEST_TMPDIR}/phases.json"
    for _ in $(seq 1 200); do
        [[ -e "${run_ready}" ]] && break
        sleep 0.02
    done
    jq -n '{result: "passed", detail: "control"} as $p
        | {scenario: {status: 0}, task: {status: 0}, collection: $p, environment: $p,
           endpoint: $p, audit: $p, stop: $p, inventory: $p, screenshots: $p}' >"${phases}"
    run seq_tool settle "${sequence}" E01 "${phases}"
    kill -TERM "${caller}"
    wait "${caller}" || :
    expect_refused "run"
    [[ "$(jq -r .detail <<<"$(settled phases.stop)")" != control ]]
}

# --- results stay separate ---------------------------------------------------

@test "a complete run keeps its classification and qualifies with every phase passed" {
    run_e01
    [[ "$(settled classification.kind)" == complete ]]
    [[ "$(phase stop)" == passed && "$(phase inventory)" == passed && "$(phase collection)" == passed ]]
    local name
    for name in environment endpoint audit screenshots; do [[ "$(phase "${name}")" == passed ]]; done
    [[ "$(settled disposition)" == qualified && "$(settled cleanup)" == confirmed ]]
    not_running
}

@test "a failed assertion settles failed, and a clean stop does not requalify it" {
    export run_mode=assertion
    run_e01
    [[ "$(settled disposition)" == failed && "$(settled cleanup)" == confirmed ]]
    [[ "$(settled phases.scenario.status)" == 1 && "$(settled phases.task.status)" == 1 ]]
    [[ "$(stops)" == 1 ]]
    [[ "$(report .slots.E02.state)" == "NOT RUN" ]]
}

@test "a missing scenario status stays null beside a nonzero Task status" {
    export run_mode=no-exit
    run_e01
    [[ "$(settled phases.scenario.status)" == null && "$(settled phases.task.status)" == 7 ]]
    [[ "$(result .scenario.file)" == missing ]]
    [[ "$(settled disposition)" == unresolved ]]
}

@test "a malformed scenario status is no status" {
    export run_mode=malformed-exit
    run_e01
    [[ "$(settled phases.scenario.status)" == null && "$(result .scenario.file)" == malformed ]]
    [[ "$(settled disposition)" == unresolved ]]
}

@test "the manifest digests each retained file of a failed run" {
    export run_mode=assertion
    run_e01
    local manifest
    manifest="$(out_dir)/containment/manifest.json"
    local path expected
    path="$(root)/subject.json"
    expected="$(shasum -a 256 "${path}" | cut -d ' ' -f 1)"
    [[ "$(jq -r --arg p "${path}" '.files[] | select(.path == $p) | .sha256' "${manifest}")" == "${expected}" ]]
    [[ "$(jq -r '.errors | length' "${manifest}")" == 0 ]]
    jq -e --arg p "$(out_dir)/scenario.exit" '[.files[].path] | index($p) != null' "${manifest}" >/dev/null
}

# --- the start -------------------------------------------------------------

@test "a scenario that ends before its start sends no stop and reads the inventory" {
    export run_mode=before-start
    run_e01
    [[ "$(stops)" == 0 && "$(starts)" == 0 && "$(lists)" == 1 ]]
    [[ "$(phase stop)" == not-run && "$(phase inventory)" == passed ]]
    [[ "$(settled cleanup)" == not-requested ]]
}

@test "a run that leaves no root sends no stop and keeps the no-root class" {
    export run_mode=no-root
    run_e01
    [[ "$(settled classification.kind)" == no-root && "$(stops)" == 0 ]]
    [[ "$(phase collection)" == unavailable && "$(phase inventory)" == passed ]]
    [[ "$(result .root_created_by_caller)" == true ]]
}

@test "a failed start keeps its uncertain creation, contains that clone and starts no other" {
    export run_mode=start-failed
    run_e01
    [[ "$(starts)" == 1 && "$(stops)" == 1 ]]
    [[ "$(result .start.uncertain)" == true ]]
    [[ "$(jq -c 'select(.[1] == "stop")' "${lifecycle_calls}" | jq -r '.[2]')" == koine-k49-ordering-e01 ]]
    not_running
    [[ "$(phase stop)" == passed && "$(settled disposition)" == unresolved ]]
}

@test "an interrupted start keeps its uncertain creation and contains that clone" {
    export run_mode=start-blocked
    python3 -I "${tool}" run "${sequence}" E01 >"${BATS_TEST_TMPDIR}/out" 2>&1 &
    local caller=$!
    for _ in $(seq 1 300); do
        [[ -e "${lifecycle_ready}" ]] && break
        sleep 0.02
    done
    [[ -e "${lifecycle_ready}" ]]
    kill -INT "${caller}"
    wait "${caller}"
    [[ "$(result .start.uncertain)" == true && "$(stops)" == 1 && "$(starts)" == 1 ]]
    not_running
    [[ "$(result '.interruptions[0]')" == SIGINT ]]
}

# --- refusals ---------------------------------------------------------------

@test "each refused collection, confirmation and stop request keeps its reason" {
    export run_mode=refusals
    run_e01
    local refusals
    refusals="$(out_dir)/containment/refusals.json"
    [[ "$(jq '[.[] | select(.class == "collection")] | length' "${refusals}")" -ge 1 ]]
    [[ "$(jq '[.[] | select(.class == "confirmation")] | length' "${refusals}")" -ge 1 ]]
    [[ "$(jq '[.[] | select(.class == "stop")] | length' "${refusals}")" -ge 1 ]]
    [[ "$(jq '[.[] | select(.source == "facade")] | length' "${refusals}")" -ge 1 ]]
    jq -e 'all(.[]; (.reason | type == "string" and length > 0))' "${refusals}" >/dev/null
    jq -e '[.[] | select(.class == "stop")][0].reason | test("competing evidence writer")' "${refusals}" >/dev/null
    [[ "$(phase collection)" == failed ]]
}

@test "an unreadable refusal line stays recorded, and collection does not pass" {
    local parsed
    parsed="$(
        python3 -I - "${tool}" <<'PY'
import importlib.util, json, pathlib, sys, tempfile
spec = importlib.util.spec_from_file_location("sequence", sys.argv[1])
module = importlib.util.module_from_spec(spec)
sys.modules["sequence"] = module
spec.loader.exec_module(module)
root = pathlib.Path(tempfile.mkdtemp())
(root / "refusals.jsonl").write_bytes(b'{"source":"backend","reason":"tru')
print(json.dumps(module.read_refusals(root)))
PY
    )"
    [[ "$(jq -r '.[0].class' <<<"${parsed}")" == unreadable ]]
}

# --- lock holders -----------------------------------------------------------

@test "an owned holder that finishes is awaited, and no signal is sent" {
    export run_mode=holder-brief
    run_e01
    [[ "$(result .holder.result)" == waited && "$(stops)" == 1 ]]
    no_action group-term
    [[ "$(phase stop)" == passed ]]
}

@test "a stuck owned holder ends with its recorded group before the stop" {
    export run_mode=holder-stuck
    run_e01
    [[ "$(result .holder.result)" == ended && "$(stops)" == 1 ]]
    actions | grep -qx group-term
    no_action group-kill
    [[ "$(phase stop)" == passed ]]
}

@test "a holder that ignores TERM ends by KILL, recorded separately" {
    export run_mode=holder-ignores-term
    run_e01
    [[ "$(result .holder.result)" == ended ]]
    actions | grep -qx group-term
    actions | grep -qx group-kill
    [[ "$(stops)" == 1 ]]
}

@test "a holder outside the group leaves cleanup unresolved and sends no stop" {
    export run_mode=holder-outside
    run_e01
    [[ "${status}" == 0 ]]
    [[ "$(result .holder.result)" == unresolved && "$(stops)" == 0 ]]
    [[ "$(phase stop)" == not-run && "$(phase inventory)" == not-run ]]
    [[ "$(settled cleanup)" == unresolved && "$(report .slots.E02.state)" == "NOT RUN" ]]
    is_running
    [[ ! -e "$(root)/unavailable" ]]
    run seq_tool admit "${sequence}" E02
    expect_refused "stopped"
}

@test "containment keeps an existing latch and its first reason" {
    export run_mode=before-start
    run_e01
    grep -q 'the inventory before the start failed' "$(root)/unavailable"
}

# --- held input -------------------------------------------------------------

@test "a clean down without a release stays held, with no release sent" {
    export run_mode=down-held
    run_e01
    [[ "$(result .held_input)" == held && "$(settled classification.pointer)" == held ]]
    [[ "$(inputs)" == 0 ]]
    [[ "$(stops)" == 1 ]]
    not_running
}

@test "a clean down and a clean release are released" {
    export run_mode=down-released
    run_e01
    [[ "$(result .held_input)" == released ]]
}

@test "a failed held point is uncertain" {
    export run_mode=down-failed
    run_e01
    [[ "$(result .held_input)" == uncertain && "$(inputs)" == 0 ]]
}

@test "a partial release proves no release" {
    export run_mode=release-partial
    run_e01
    [[ "$(result .held_input)" == uncertain && "$(inputs)" == 0 ]]
}

@test "a missing receipt makes the pointer uncertain" {
    export run_mode=ordinal-gap
    run_e01
    [[ "$(result .held_input)" == uncertain ]]
}

# --- the stop ---------------------------------------------------------------

@test "a nonzero stop is failed, is not repeated, and still gets its inventory" {
    export lifecycle_only=stop lifecycle_exit=7
    run_e01
    [[ "$(stops)" == 1 && "$(phase stop)" == failed && "$(phase inventory)" == passed ]]
    [[ "$(settled cleanup)" == unresolved && "$(result .stop.status)" == 125 ]]
}

@test "a malformed stop response is failed" {
    export lifecycle_only=stop lifecycle_mode=partial
    run_e01
    [[ "$(stops)" == 1 && "$(phase stop)" == failed && "$(settled cleanup)" == unresolved ]]
}

@test "a stop response that says not stopped is failed" {
    export lifecycle_only=stop lifecycle_mode=stop-false
    run_e01
    [[ "$(stops)" == 1 && "$(phase stop)" == failed ]]
}

@test "a stop that outlasts its bound is unavailable and is not repeated" {
    export lifecycle_only=stop lifecycle_block=1
    export KOINE_SEQUENCE_BOUNDS="holder=0.8,term=0.8,kill=3,stop=1,inventory=8"
    run_e01
    [[ "$(stops)" == 1 && "$(phase stop)" == unavailable && "$(settled cleanup)" == unresolved ]]
    [[ "$(result .stop.timed_out)" == true ]]
    [[ "$(lists)" -ge 3 ]]
}

@test "a timed-out stop whose CLI ignores TERM ends by KILL before the inventory" {
    export lifecycle_only=stop lifecycle_block=1 lifecycle_ignore_term=1
    export KOINE_SEQUENCE_BOUNDS="holder=0.8,term=0.8,kill=3,stop=1,inventory=8"
    run_e01
    [[ "$(stops)" == 1 && "$(phase stop)" == unavailable ]]
    actions | grep -qx containment-stop-group-kill
    # The stop never acted, so the free lock gives a real read of the live clone.
    [[ "$(phase inventory)" == failed && "$(result .inventory.detail)" == "receipt unavailable, status 125" ]]
    [[ ! -e "$(root)/refusals.jsonl" ]]
    is_running
}

# --- the inventory ----------------------------------------------------------

@test "a clone still listed after the stop fails the inventory" {
    export lifecycle_only=stop lifecycle_mode=stop-keeps
    run_e01
    [[ "$(phase stop)" == passed && "$(phase inventory)" == failed ]]
    [[ "$(settled cleanup)" == unresolved ]]
}

@test "a truncated inventory is not an absence" {
    export lifecycle_only=list lifecycle_mode=list-truncated
    run_e01
    [[ "$(phase inventory)" == failed && "$(settled cleanup)" == unresolved ]]
}

@test "an inventory row with a missing field is not an absence" {
    export lifecycle_only=list lifecycle_mode=list-field
    run_e01
    [[ "$(phase inventory)" == failed && "$(settled cleanup)" == unresolved ]]
}

@test "an inventory that outlasts its bound is unavailable" {
    export lifecycle_only=list lifecycle_block=1
    export KOINE_SEQUENCE_BOUNDS="holder=0.8,term=0.8,kill=3,stop=8,inventory=1"
    run_e01
    [[ "$(phase inventory)" == unavailable && "$(settled cleanup)" == unresolved ]]
    [[ "$(result .inventory.timed_out)" == true ]]
}

# --- interruption -----------------------------------------------------------

@test "a signal reaches the recorded group once, then the run collects, stops and settles" {
    export run_mode=signal-wait
    python3 -I "${tool}" run "${sequence}" E01 >"${BATS_TEST_TMPDIR}/out" 2>&1 &
    local caller=$!
    for _ in $(seq 1 300); do
        [[ -e "${run_ready}" ]] && break
        sleep 0.02
    done
    [[ -e "${run_ready}" ]]
    kill -TERM "${caller}"
    wait "${caller}"
    seq_tool settle-run "${sequence}" E01 "${screens}" >/dev/null
    [[ "$(settled classification.kind)" == interrupted ]]
    [[ "$(settled phases.task.status)" == 143 && "$(stops)" == 1 ]]
    [[ "$(actions | grep -c '^signal-forwarded$')" == 1 ]]
    [[ "$(phase stop)" == passed && "$(settled disposition)" == unresolved ]]
    not_running
}

@test "a later signal does not cut the containment short" {
    export run_mode=signal-wait
    python3 -I "${tool}" run "${sequence}" E01 >"${BATS_TEST_TMPDIR}/out" 2>&1 &
    local caller=$!
    for _ in $(seq 1 300); do
        [[ -e "${run_ready}" ]] && break
        sleep 0.02
    done
    kill -TERM "${caller}"
    sleep 0.05
    kill -TERM "${caller}" || :
    kill -HUP "${caller}" || :
    wait "${caller}"
    seq_tool settle-run "${sequence}" E01 "${screens}" >/dev/null
    [[ "$(stops)" == 1 && "$(report '.slots.E01.state')" == settled ]]
    [[ "$(actions | grep -c '^signal-forwarded$')" == 1 ]]
    not_running
}

@test "the installed Task keeps the scenario in the recorded group and passes a signal" {
    [[ -x "${real_task}" ]]
    local scratch="${BATS_TEST_TMPDIR}/real-task"
    mkdir "${scratch}"
    cat >"${scratch}/Taskfile.yml" <<'YAML'
version: '3'
tasks:
  entry:
    cmds:
      - |
        status=0
        bash "${run_fixture}" entry || status=$?
        printf '%s\n' "${status}" > "${KOINE_K4_OUT}/scenario.exit"
        exit "${status}"
YAML
    # shellcheck disable=SC2016 # The stub expands these when it runs.
    printf '#!/bin/bash\nexec "${real_task}" --dir "%s" entry\n' "${scratch}" >"${BATS_TEST_TMPDIR}/bin/task"
    export run_mode=signal-wait
    python3 -I "${tool}" run "${sequence}" E01 >"${BATS_TEST_TMPDIR}/out" 2>&1 &
    local caller=$!
    for _ in $(seq 1 400); do
        [[ -e "${run_ready}" ]] && break
        sleep 0.02
    done
    [[ -e "${run_ready}" ]]
    [[ "$(jq -r .pgid "${run_log}")" == "$(jq -r .pgid "$(out_dir)/containment/process.json")" ]]
    kill -TERM "${caller}"
    wait "${caller}"
    seq_tool settle-run "${sequence}" E01 "${screens}" >/dev/null
    [[ "$(settled classification.kind)" == interrupted && "$(stops)" == 1 ]]
    [[ "$(settled phases.scenario.status)" == 143 && "$(settled phases.task.status)" == 201 ]]
    not_running
}

@test "a signal before the gate opens withholds the Task and records no status" {
    local parsed
    parsed="$(
        python3 -I - "${tool}" "$(out_dir)" "$(root)" <<'PY_CONTROL'
import importlib.util, json, pathlib, signal, sys, time
spec = importlib.util.spec_from_file_location("sequence", sys.argv[1])
module = importlib.util.module_from_spec(spec)
sys.modules["sequence"] = module
spec.loader.exec_module(module)
declared = {"slot": "E01", "set": "focused", "clone": "koine-k49-ordering-e01",
            "entry": module.PREFIX_ENTRY, "output": sys.argv[2], "evidence_root": sys.argv[3]}
containment = module.Containment(declared, dict(module.DEFAULT_BOUNDS), [signal.SIGTERM], {}, {"inputs": []})
process = containment.start_task("task")
process.wait(timeout=10)
print(json.dumps({"released": containment.released, "status": process.returncode}))
PY_CONTROL
    )"
    [[ "$(jq -r .released <<<"${parsed}")" == false && "$(jq -r .status <<<"${parsed}")" == 125 ]]
    [[ "$(tasks)" == 0 ]]
}

@test "a failed exit watch withholds the Task and does not hang the caller" {
    local parsed
    parsed="$(
        python3 -I - "${tool}" "$(out_dir)" "$(root)" <<'PY_CONTROL'
import importlib.util, json, select, signal, sys
spec = importlib.util.spec_from_file_location("sequence", sys.argv[1])
module = importlib.util.module_from_spec(spec)
sys.modules["sequence"] = module
spec.loader.exec_module(module)
declared = {"slot": "E01", "set": "focused", "clone": "koine-k49-ordering-e01",
            "entry": module.PREFIX_ENTRY, "output": sys.argv[2], "evidence_root": sys.argv[3]}
def refuse():
    raise OSError("no kqueue")
select.kqueue = refuse
containment = module.Containment(declared, dict(module.DEFAULT_BOUNDS), [], {}, {"inputs": []})
process = containment.start_task("task")
signal.alarm(5)
containment.await_task(process)
signal.alarm(0)
process.wait(timeout=5)
print(json.dumps({"released": containment.released}))
PY_CONTROL
    )"
    [[ "$(jq -r .released <<<"${parsed}")" == false && "$(tasks)" == 0 ]]
}

# --- later slots ------------------------------------------------------------

@test "an unresolved stop keeps every later slot NOT RUN" {
    export lifecycle_only=stop lifecycle_exit=7
    run_e01
    local slot
    for slot in E02 A01 A02 A03; do
        [[ "$(report ".slots.${slot}.state")" == "NOT RUN" ]]
    done
    run seq_tool run "${sequence}" E02
    expect_refused "stopped"
    [[ "$(tasks)" == 1 ]]
}
