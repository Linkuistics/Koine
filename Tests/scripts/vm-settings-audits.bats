#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Every test owns its environment.
# The per-item audits and the declared-environment comparison of
# scripts/settings-ordering-sequence.py, without a VM. A fake `task` writes real
# receipts through the real facades, against the synthetic TestAnyware CLI. The
# frozen subject is a set of local directories. No control starts a clone.

setup() {
    bats_require_minimum_version 1.5.0
    export repo_root="${BATS_TEST_DIRNAME}/../.."
    export run_repo="${repo_root}"
    export tool="${repo_root}/scripts/settings-ordering-sequence.py"
    export sequence="${BATS_TEST_TMPDIR}/sequence"
    export frozen="${BATS_TEST_TMPDIR}/frozen"
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
    mkdir "${BATS_TEST_TMPDIR}/bin" "${lifecycle_guest}" "${frozen}"
    # shellcheck disable=SC2016 # The stub expands these when it runs.
    printf '#!/bin/bash\nexec python3 "${lifecycle_fixture}" "$@"\n' >"${BATS_TEST_TMPDIR}/bin/testanyware"
    # shellcheck disable=SC2016 # The stub expands these when it runs.
    printf '#!/bin/bash\nexec bash "${run_fixture}" "$@"\n' >"${BATS_TEST_TMPDIR}/bin/task"
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware" "${BATS_TEST_TMPDIR}/bin/task"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    # shellcheck source=Tests/scripts/fixtures/declared-tools.sh
    source "${BATS_TEST_DIRNAME}/fixtures/declared-tools.sh"
    declare_tools "${BATS_TEST_TMPDIR}/bin/testanyware"
    : >"${lifecycle_calls}"
    : >"${run_log}"
    # shellcheck source=Tests/scripts/fixtures/settings-audit-frozen.sh
    source "${BATS_TEST_DIRNAME}/fixtures/settings-audit-frozen.sh"
    frozen_prepare
    export focused_receipt="${BATS_TEST_TMPDIR}/focused.json"
    export ordinary_receipt="${BATS_TEST_TMPDIR}/ordinary.json"
    export screens="${BATS_TEST_TMPDIR}/screens.json"
    printf '{"result":"passed","detail":"control"}\n' >"${screens}"
    frozen_receipt focused "${focused_receipt}"
    frozen_receipt ordinary "${ordinary_receipt}"
    seq_tool declare "${sequence}" >/dev/null
    seq_tool ready "${sequence}" focused "${focused_receipt}" >/dev/null
}

teardown() {
    chmod -R u+rwX "${frozen}" 2>/dev/null || :
}

seq_tool() { python3 -I "${tool}" "$@"; }

slot_field() {
    jq -er --arg slot "$1" --arg field "$2" '.slots[] | select(.slot == $slot) | .[$field]' \
        "${sequence}/sequence.json"
}

out_dir() { slot_field "${1:-E01}" output; }
report() { seq_tool report "${sequence}" | jq -er "$1"; }
settled() { report ".slots.E01.$1"; }
phase() { settled "phases.$1.result"; }
audits() { jq -er "$1" "$(out_dir)/containment/audits.json"; }
tasks() { wc -l <"${run_log}" | tr -d ' '; }
stops() { jq -c 'select(.[0] == "vm" and .[1] == "stop")' "${lifecycle_calls}" | wc -l | tr -d ' '; }
settle_slot() { seq_tool settle-run "${sequence}" "$1" "${screens}"; }
# run_e01: run the slot, then settle it with a passed screenshot audit.
run_e01() {
    run seq_tool run "${sequence}" E01
    [[ "${status}" == 0 ]] || return 0
    settle_slot E01 >/dev/null
}
pass_slot() {
    seq_tool run "${sequence}" "$1" >/dev/null
    settle_slot "$1" >/dev/null
}
pass_focused() {
    pass_slot E01
    pass_slot E02
    seq_tool ready "${sequence}" ordinary "${ordinary_receipt}" >/dev/null
}
pass_all() {
    pass_focused
    pass_slot A01
    pass_slot A02
    pass_slot A03
}

expect_refused() {
    [[ "${status}" == 3 && "${output}" == *"$1"* ]] || {
        echo "expected a refusal with \"$1\": status ${status}: ${output}"
        return 1
    }
}

# expect_held TEXT: the run refused, no Task ran and the slot stays NOT RUN.
expect_held() {
    expect_refused "$1"
    [[ "$(tasks)" == 0 && "$(report '.slots.E01.state')" == "NOT RUN" ]]
    [[ "$(report .outcome)" == no-acceptance && "$(report .held.slot)" == E01 ]]
}

# --- the frozen declaration --------------------------------------------------

@test "inventory lists each file, symlink and directory with its identity" {
    run seq_tool inventory "${frozen}/Koine.app" bundle
    [[ "${status}" == 0 ]]
    [[ "$(jq -r .name <<<"${output}")" == bundle ]]
    [[ "$(jq -r '.items[] | select(.path == "Contents/MacOS/Koine") | .sha256' <<<"${output}")" == "$(shasum -a 256 "${frozen}/Koine.app/Contents/MacOS/Koine" | cut -d' ' -f1)" ]]
    [[ "$(jq -r '.items[] | select(.path == "Contents/Resources/current") | .target' <<<"${output}")" == ../MacOS/Koine ]]
    [[ "$(jq -r '.items[] | select(.path == "Contents/MacOS") | .kind' <<<"${output}")" == directory ]]
}

@test "inventory refuses a root that does not exist" {
    run seq_tool inventory "${frozen}/absent" bundle
    expect_refused "no items"
}

@test "a receipt without a frozen declaration refuses the run before admission" {
    local other="${BATS_TEST_TMPDIR}/other"
    printf '{"set":"focused"}\n' >"${BATS_TEST_TMPDIR}/bare.json"
    seq_tool declare "${other}" >/dev/null
    seq_tool ready "${other}" focused "${BATS_TEST_TMPDIR}/bare.json" >/dev/null
    run seq_tool run "${other}" E01
    expect_refused "frozen declaration"
    [[ "$(tasks)" == 0 ]]
    [[ "$(seq_tool report "${other}" | jq -r .slots.E01.state)" == "NOT RUN" ]]
}

@test "a receipt that changed after readiness refuses the run before admission" {
    jq '.process_arguments = "/other"' "${focused_receipt}" >"${focused_receipt}.new"
    mv "${focused_receipt}.new" "${focused_receipt}"
    run seq_tool run "${sequence}" E01
    expect_refused "changed since"
    [[ "$(tasks)" == 0 && "$(report '.slots.E01.state')" == "NOT RUN" ]]
}

@test "a receipt with a path outside its root refuses the run" {
    local other="${BATS_TEST_TMPDIR}/other" bad="${BATS_TEST_TMPDIR}/bad.json"
    jq '.inputs[0].items[0].path = "../escape"' "${focused_receipt}" >"${bad}"
    seq_tool declare "${other}" >/dev/null
    seq_tool ready "${other}" focused "${bad}" >/dev/null
    run seq_tool run "${other}" E01
    expect_refused "frozen declaration"
}

# --- the host audit before a slot --------------------------------------------

@test "an extra input item before the slot holds the sequence and consumes no slot" {
    printf 'new\n' >"${frozen}/Koine.app/Contents/Resources/extra"
    run seq_tool run "${sequence}" E01
    expect_held "did not pass"
    [[ "$(report '.held.audit.inputs[0].extra[0]')" == Contents/Resources/extra ]]
}

@test "a missing input item before the slot holds the sequence" {
    rm "${frozen}/Koine.app/Contents/Info.plist"
    run seq_tool run "${sequence}" E01
    expect_held "did not pass"
    [[ "$(report '.held.audit.inputs[0].missing[0]')" == Contents/Info.plist ]]
}

@test "a changed input item before the slot holds the sequence" {
    printf 'changed\n' >>"${frozen}/Taskfile.yml"
    run seq_tool run "${sequence}" E01
    expect_held "did not pass"
    [[ "$(report '.held.audit.inputs[1].changed[0]')" == . ]]
}

@test "a replaced item with an equal count is not equal" {
    mv "${frozen}/Koine.app/Contents/Info.plist" "${frozen}/Koine.app/Contents/Renamed.plist"
    run seq_tool run "${sequence}" E01
    expect_held "did not pass"
    [[ "$(report '.held.audit.inputs[0].missing[0]')" == Contents/Info.plist ]]
    [[ "$(report '.held.audit.inputs[0].extra[0]')" == Contents/Renamed.plist ]]
}

@test "an unreadable input before the slot is unavailable and holds the sequence" {
    chmod 000 "${frozen}/Taskfile.yml"
    run seq_tool run "${sequence}" E01
    expect_held "did not pass"
    [[ "$(report '.held.audit.inputs[1].result')" == unavailable ]]
}

@test "an unreadable input directory is unavailable, and its items are not missing" {
    chmod 000 "${frozen}/Koine.app/Contents/MacOS"
    run seq_tool run "${sequence}" E01
    expect_held "did not pass"
    [[ "$(report '.held.audit.inputs[0].result')" == unavailable ]]
    [[ "$(report '.held.audit.inputs[0].missing | length')" == 0 ]]
}

@test "a held sequence refuses every later run and replays from the ledger" {
    printf 'changed\n' >>"${frozen}/Taskfile.yml"
    run seq_tool run "${sequence}" E01
    expect_held "did not pass"
    # Restoring the input does not clear the hold.
    printf 'tasks\n' >"${frozen}/Taskfile.yml"
    run seq_tool run "${sequence}" E01
    expect_refused "stopped"
    [[ "$(tasks)" == 0 ]]
}

# --- the host audit after a slot ---------------------------------------------

@test "a clean slot passes each audit and qualifies" {
    run_e01
    [[ "${status}" == 0 ]]
    local name
    for name in environment endpoint audit screenshots; do [[ "$(phase "${name}")" == passed ]]; done
    [[ "$(settled disposition)" == qualified && "$(settled cleanup)" == confirmed ]]
}

@test "an input that changes during the slot fails the audit after it" {
    export run_mode=input-changes
    run_e01
    [[ "$(phase audit)" == failed && "$(settled disposition)" == unresolved ]]
    [[ "$(audits '.host_after[1].changed[0]')" == . ]]
    [[ "$(audits '.host_before[1].result')" == passed ]]
}

@test "an input item added during the slot fails the audit after it" {
    export run_mode=input-extra
    run_e01
    [[ "$(phase audit)" == failed ]]
    [[ "$(audits '.host_after[0].extra[0]')" == Contents/Resources/extra ]]
}

@test "an input item removed during the slot fails the audit after it" {
    export run_mode=input-missing
    run_e01
    [[ "$(phase audit)" == failed ]]
    [[ "$(audits '.host_after[0].missing[0]')" == Contents/Info.plist ]]
}

# --- the installed audit at both endpoints -----------------------------------

@test "the caller reads the installed bundle itself, before the stop" {
    run_e01
    local read stop
    read="$(jq -n '[inputs] | to_entries | map(select(.value[-1] | contains("KOINE_INVENTORY_COMPLETE"))) | last.key' "${lifecycle_calls}")"
    stop="$(jq -n '[inputs] | to_entries | map(select(.value[0] == "vm" and .value[1] == "stop")) | last.key' "${lifecycle_calls}")"
    ((read < stop))
    [[ "$(audits '.installed.after.result')" == passed ]]
}

@test "a guest file that changes during the slot fails the endpoint after it" {
    export run_mode=guest-changes
    run_e01
    [[ "$(phase endpoint)" == failed ]]
    [[ "$(audits '.installed.before.result')" == passed ]]
    [[ "$(audits '.installed.after.changed[0]')" == ./Contents/MacOS/Koine ]]
}

@test "an extra guest file fails the endpoint after the slot" {
    export run_mode=guest-extra
    run_e01
    [[ "$(phase endpoint)" == failed ]]
    [[ "$(audits '.installed.after.extra[0]')" == ./Contents/Resources/extra ]]
}

@test "a missing guest file fails the endpoint after the slot" {
    export run_mode=guest-missing
    run_e01
    [[ "$(phase endpoint)" == failed ]]
    [[ "$(audits '.installed.after.missing[0]')" == ./Contents/Info.plist ]]
}

@test "a changed guest symlink target fails the endpoint after the slot" {
    export run_mode=guest-link
    run_e01
    [[ "$(phase endpoint)" == failed ]]
    [[ "$(audits '.installed.after.changed[0]')" == ./Contents/Resources/current ]]
}

@test "an installed bundle that differs from the frozen bundle fails both endpoints" {
    printf 'another build\n' >"${guest_bundle}/Contents/MacOS/Koine"
    run_e01
    [[ "$(audits '.installed.before.result')" == failed && "$(audits '.installed.after.result')" == failed ]]
    [[ "$(phase endpoint)" == failed ]]
}

@test "a failed installed read after the slot is unavailable, not a mismatch" {
    export guest_fail=inventory
    run_e01
    [[ "$(phase endpoint)" == unavailable && "$(settled disposition)" == unresolved ]]
    [[ "$(audits '.installed.after.result')" == unavailable ]]
    [[ "$(stops)" == 1 ]]
}

@test "a failed installed read before the slot is unavailable" {
    export scenario_guest_fail=inventory
    run_e01
    [[ "$(audits '.installed.before.result')" == unavailable && "$(phase endpoint)" == unavailable ]]
}

@test "a run with no start attempt reads nothing from the guest" {
    export run_mode=no-root
    run_e01
    [[ "$(phase endpoint)" == not-run && "$(phase environment)" == not-run ]]
    [[ "$(jq -c 'select(.[0] == "file" and .[1] == "exec")' "${lifecycle_calls}" | wc -l | tr -d ' ')" == 0 ]]
}

# --- originals and partials --------------------------------------------------

@test "a saved artifact that matches its original passes" {
    export run_mode=artifact-clean
    run_e01
    [[ "$(phase audit)" == passed ]]
    (($(audits '.originals.compared') > 0))
    [[ "$(audits '.originals.mismatched | length')" == 0 ]]
}

@test "a saved artifact that differs from its original fails the audit" {
    export run_mode=artifact-changed
    run_e01
    [[ "$(phase audit)" == failed && "$(settled disposition)" == unresolved ]]
    [[ "$(audits '.originals.mismatched[0]')" == */screen.png ]]
}

@test "a saved guest stream that differs from its raw response fails the audit" {
    export run_mode=stream-changed
    run_e01
    [[ "$(phase audit)" == failed ]]
    [[ "$(audits '.originals.mismatched[0]')" == */guest.stdout ]]
}

@test "a partial original stays named and does not fail its audit" {
    export run_mode=partial-original
    run_e01
    [[ "$(audits '.originals.result')" == passed ]]
    [[ "$(audits '.originals.partials | length')" == 1 ]]
    [[ "$(settled classification.kind)" == unavailable && "$(settled disposition)" == unresolved ]]
}

# expect_lost MEMBER...: a clean read loses these files before the manifest.
expect_lost() {
    export run_mode=member-lost lost_operation=system lost_members="$*"
    run_e01
    [[ "$(phase audit)" == failed && "$(audits '.originals.result')" == failed ]]
    [[ "$(settled classification.kind)" == complete && "$(settled disposition)" == unresolved ]]
    local member
    for member in "$@"; do
        audits '.originals.missing' | jq -e --arg member "${member}" 'any(endswith("/" + $member))' >/dev/null
    done
    run seq_tool run "${sequence}" E02
    expect_refused "stopped"
}

@test "a clean read that lost its saved stdout fails the audit" {
    expect_lost guest.stdout
}

@test "a clean read that lost its saved stderr fails the audit" {
    expect_lost guest.stderr
}

@test "a clean read that lost both streams and its response fails the audit" {
    expect_lost guest.stdout guest.stderr raw.stdout
}

@test "a clean read that lost its parsed record fails the audit" {
    expect_lost read.json
}

@test "a clean command that lost its exit record fails the audit" {
    export run_mode=member-lost lost_operation=vm-after lost_members=cli.exit
    run_e01
    [[ "$(phase audit)" == failed && "$(settled disposition)" == unresolved ]]
    audits '.originals.missing' | jq -e 'any(endswith("/cli.exit"))' >/dev/null
}

@test "a clean transfer that lost its record fails the audit" {
    export run_mode=upload-lost
    run_e01
    [[ "$(phase audit)" == failed && "$(settled disposition)" == unresolved ]]
    audits '.originals.missing' | jq -e 'any(endswith("/transfer.json"))' >/dev/null
}

@test "every clean attempt of a complete run holds its required members" {
    run_e01
    [[ "$(audits '.originals.missing | length')" == 0 && "$(phase audit)" == passed ]]
    (($(audits '.originals.compared') > 0))
}

@test "a failed attempt with a partial response owes no guest stream" {
    export run_mode=partial-response
    run_e01
    [[ "$(audits '.originals.missing | length')" == 0 ]]
    [[ "$(audits '.originals.unreadable | length')" == 0 ]]
    [[ "$(audits '.originals.result')" == passed ]]
    [[ "$(settled disposition)" == unresolved ]]
}

@test "a retained file that changes before settlement fails the audit" {
    run seq_tool run "${sequence}" E01
    printf 'edited\n' >>"$(slot_field E01 evidence_root)/000001/request.json"
    settle_slot E01 >/dev/null
    [[ "$(phase audit)" == failed ]]
    [[ "$(settled 'phases.audit.detail')" == *manifest* ]]
}

@test "a retained file that disappears before settlement fails the audit" {
    run seq_tool run "${sequence}" E01
    rm "$(slot_field E01 evidence_root)/000001/cli.exit"
    settle_slot E01 >/dev/null
    [[ "$(phase audit)" == failed ]]
}

@test "a file added to the evidence before settlement fails the audit" {
    run seq_tool run "${sequence}" E01
    printf 'added\n' >"$(slot_field E01 evidence_root)/added"
    settle_slot E01 >/dev/null
    [[ "$(phase audit)" == failed ]]
}

# --- the stopped golden image ------------------------------------------------

@test "five clean slots wait for the closing golden audit, then accept" {
    pass_all
    [[ "$(report .outcome)" == awaiting-golden-audit ]]
    run seq_tool close "${sequence}"
    [[ "${status}" == 0 ]]
    [[ "$(report .outcome)" == accepted-finite-sample ]]
    [[ "$(report .closed.golden.result)" == passed ]]
}

@test "a golden item that changes before A01 holds the sequence" {
    pass_focused
    printf 'changed\n' >>"${frozen}/golden/disk.img"
    run seq_tool run "${sequence}" A01
    expect_refused "did not pass"
    [[ "$(report .slots.A01.state)" == "NOT RUN" && "$(report .outcome)" == no-acceptance ]]
    [[ "$(report '.held.audit.golden.changed[0]')" == disk.img ]]
}

@test "an extra golden item before A01 holds the sequence" {
    pass_focused
    printf 'new\n' >"${frozen}/golden/extra"
    run seq_tool run "${sequence}" A01
    expect_refused "did not pass"
    [[ "$(report '.held.audit.golden.extra[0]')" == extra ]]
}

@test "a missing golden item before A01 holds the sequence" {
    pass_focused
    rm "${frozen}/golden/nvram.bin"
    run seq_tool run "${sequence}" A01
    expect_refused "did not pass"
    [[ "$(report '.held.audit.golden.missing[0]')" == nvram.bin ]]
}

@test "an E slot does not read the golden image" {
    printf 'changed\n' >>"${frozen}/golden/disk.img"
    run_e01
    [[ "$(settled disposition)" == qualified ]]
}

@test "a golden item that changes after A01 prevents acceptance at the close" {
    pass_all
    printf 'changed\n' >>"${frozen}/golden/config.json"
    run seq_tool close "${sequence}"
    [[ "${status}" == 0 ]]
    [[ "$(report .outcome)" == no-acceptance ]]
    [[ "$(report '.closed.golden.changed[0]')" == config.json ]]
}

@test "an unreadable golden item at the close prevents acceptance" {
    pass_all
    chmod 000 "${frozen}/golden/nvram.bin"
    run seq_tool close "${sequence}"
    [[ "${status}" == 0 ]]
    [[ "$(report .outcome)" == no-acceptance && "$(report .closed.golden.result)" == unavailable ]]
}

@test "the close refuses while a slot is unsettled, and it runs once" {
    seq_tool run "${sequence}" E01 >/dev/null
    run seq_tool close "${sequence}"
    expect_refused "unsettled"
    settle_slot E01 >/dev/null
    run seq_tool close "${sequence}"
    expect_refused "not over"
    export run_mode=assertion
    seq_tool run "${sequence}" E02 >/dev/null
    settle_slot E02 >/dev/null
    seq_tool close "${sequence}" >/dev/null
    run seq_tool close "${sequence}"
    expect_refused "already closed"
}

@test "an ordinary receipt that differs from the focused receipt holds A01" {
    pass_slot E01
    pass_slot E02
    jq '.environment.build_version = "26A999"' "${ordinary_receipt}" >"${ordinary_receipt}.new"
    mv "${ordinary_receipt}.new" "${ordinary_receipt}"
    seq_tool ready "${sequence}" ordinary "${ordinary_receipt}" >/dev/null
    run seq_tool run "${sequence}" A01
    expect_refused "did not pass"
    [[ "$(report .slots.A01.state)" == "NOT RUN" && "$(report .held.slot)" == A01 ]]
}

# --- G5: the declared environment --------------------------------------------

@test "G5: a different guest build fails the environment and stops the sequence" {
    export guest_build=26A999
    run_e01
    [[ "$(phase environment)" == failed && "$(settled disposition)" == unresolved ]]
    [[ "$(audits '.environment.system.result')" == failed ]]
    [[ "$(audits '.environment.gatekeeper.result')" == passed ]]
    run seq_tool run "${sequence}" E02
    expect_refused "stopped"
}

@test "G5: a different product version fails the environment" {
    export guest_version=27.1
    run_e01
    [[ "$(audits '.environment.system.result')" == failed && "$(phase environment)" == failed ]]
}

@test "G5: a different Gatekeeper state fails the environment" {
    export guest_gatekeeper=disabled
    run_e01
    [[ "$(audits '.environment.gatekeeper.result')" == failed && "$(phase environment)" == failed ]]
    [[ "$(audits '.environment.system.result')" == passed ]]
}

@test "G5: an injected process argument fails the environment" {
    export guest_arguments="/Applications/Koine.app/Contents/MacOS/Koine --trace"
    run_e01
    [[ "$(audits '.environment.process.result')" == failed && "$(phase environment)" == failed ]]
    [[ "$(audits '.environment.process.observed[0]')" == *--trace ]]
}

@test "G5: a failed system receipt is unavailable, not a mismatch" {
    export scenario_guest_fail=system
    run_e01
    [[ "$(audits '.environment.system.result')" == unavailable && "$(phase environment)" == unavailable ]]
}

@test "G5: a failed Gatekeeper receipt is unavailable" {
    export scenario_guest_fail=gatekeeper
    run_e01
    [[ "$(audits '.environment.gatekeeper.result')" == unavailable ]]
}

@test "G5: a failed process read is unavailable" {
    export guest_fail=process
    run_e01
    [[ "$(audits '.environment.process.result')" == unavailable && "$(phase environment)" == unavailable ]]
}

@test "G5: a clean process row cannot hide a later failed process read" {
    export run_mode=process-row guest_fail=process
    run_e01
    [[ "$(audits '.environment.process.result')" == unavailable && "$(phase environment)" == unavailable ]]
    [[ "$(settled disposition)" == unresolved ]]
}

@test "G5: no observed Koine process is unavailable, not a pass" {
    export guest_process=none
    run_e01
    [[ "$(audits '.environment.process.result')" == unavailable && "$(settled disposition)" == unresolved ]]
}

# --- the diagnostic defaults -------------------------------------------------

@test "the caller reads the defaults after the slot, and a clean absence passes" {
    run_e01
    [[ "$(audits '.environment.defaults.result')" == passed ]]
    [[ -n "$(find "$(slot_field E01 evidence_root)" -name request.json -exec grep -l audit-defaults-after {} +)" ]]
}

@test "a diagnostic key after the slot fails the environment" {
    export guest_defaults_key=KoineSettingsActivationTrace
    run_e01
    [[ "$(audits '.environment.defaults.result')" == failed && "$(phase environment)" == failed ]]
}

@test "a failed defaults read after the slot is unavailable, not an absence" {
    export guest_fail=defaults
    run_e01
    [[ "$(audits '.environment.defaults.result')" == unavailable && "$(phase environment)" == unavailable ]]
}

# --- separate results and the screenshot route -------------------------------

@test "one failed audit leaves the other results separate" {
    export guest_gatekeeper=disabled run_mode=guest-changes
    run_e01
    [[ "$(phase environment)" == failed && "$(phase endpoint)" == failed ]]
    [[ "$(phase audit)" == passed && "$(phase stop)" == passed && "$(phase inventory)" == passed ]]
}

@test "a failed audit does not change a failed assertion" {
    export run_mode=assertion guest_gatekeeper=disabled
    run_e01
    [[ "$(settled disposition)" == failed && "$(phase environment)" == failed ]]
}

@test "run stops before settlement, and the slot blocks the next slot" {
    run seq_tool run "${sequence}" E01
    [[ "${status}" == 0 && "$(jq -r .state <<<"${output}")" == awaiting-screenshot-audit ]]
    [[ "$(report .slots.E01.state)" == started-unsettled ]]
    [[ "$(jq -r .screenshots.result "$(out_dir)/containment/phases.json")" == not-run ]]
    run seq_tool run "${sequence}" E02
    expect_refused "unsettled"
}

@test "settle-run carries the screenshot audit into its phase" {
    seq_tool run "${sequence}" E01 >/dev/null
    printf '{"result":"unavailable","detail":"one image is unreadable"}\n' >"${screens}"
    settle_slot E01 >/dev/null
    [[ "$(phase screenshots)" == unavailable && "$(settled 'phases.screenshots.detail')" == *unreadable* ]]
    [[ "$(settled disposition)" == unresolved ]]
    [[ -f "$(out_dir)/containment/screenshots.json" ]]
}

@test "a recurrence becomes rejected only with a passed screenshot audit" {
    export run_mode=recurrence
    seq_tool run "${sequence}" E01 >/dev/null
    settle_slot E01 >/dev/null
    [[ "$(settled classification.kind)" == recurrence-candidate ]]
    [[ "$(settled disposition)" == rejected && "$(report .outcome)" == rejected ]]
}

# expect_invalid_recurrence: the wrong subject keeps its class and no rejection.
expect_invalid_recurrence() {
    export run_mode=recurrence
    seq_tool run "${sequence}" E01 >/dev/null
    settle_slot E01 >/dev/null
    [[ "$(settled classification.kind)" == recurrence-candidate ]]
    [[ "$(phase subject)" == failed && "$(phase screenshots)" == passed ]]
    [[ "$(settled disposition)" == unresolved && "$(report .outcome)" == no-acceptance ]]
    [[ "$(settled phases.scenario.status)" == 1 ]]
    run seq_tool run "${sequence}" E02
    expect_refused "stopped"
}

@test "a recurrence on a different guest build does not reject the repair" {
    export guest_build=26A999
    expect_invalid_recurrence
    [[ "$(audits .subject.detail)" == *system* ]]
}

@test "a recurrence under a different Gatekeeper state does not reject the repair" {
    export guest_gatekeeper=disabled
    expect_invalid_recurrence
    [[ "$(audits .subject.detail)" == *gatekeeper* ]]
}

@test "a recurrence on a different installed bundle does not reject the repair" {
    printf 'another build\n' >"${guest_bundle}/Contents/MacOS/Koine"
    expect_invalid_recurrence
    [[ "$(audits .subject.detail)" == *installed-before* ]]
}

@test "a recurrence with undeclared process arguments does not reject the repair" {
    export guest_arguments="/Applications/Koine.app/Contents/MacOS/Koine --trace"
    expect_invalid_recurrence
    [[ "$(audits .subject.detail)" == *"process arguments"* ]]
}

@test "a recurrence with no clean pre-selection receipt stays unresolved" {
    export run_mode=recurrence scenario_guest_fail=system
    seq_tool run "${sequence}" E01 >/dev/null
    settle_slot E01 >/dev/null
    [[ "$(phase subject)" == unavailable && "$(settled disposition)" == unresolved ]]
}

@test "a malformed pre-selection record leaves a recurrence unresolved" {
    export run_mode=recurrence-record-shape
    seq_tool run "${sequence}" E01 >/dev/null
    settle_slot E01 >/dev/null
    [[ "$(phase subject)" == unavailable && "$(settled disposition)" == unresolved ]]
}

@test "a later failed read does not erase a qualified recurrence" {
    local name
    for name in inventory defaults process; do
        rm -rf "${sequence:?}"
        seq_tool declare "${sequence}" >/dev/null
        seq_tool ready "${sequence}" focused "${focused_receipt}" >/dev/null
        : >"${lifecycle_state}"
        export run_mode=recurrence guest_fail="${name}"
        seq_tool run "${sequence}" E01 >/dev/null
        settle_slot E01 >/dev/null
        [[ "$(phase subject)" == passed && "$(settled disposition)" == rejected ]] || {
            echo "a later failed ${name} read erased the recurrence"
            return 1
        }
    done
}

@test "a guest change after the selection does not erase a qualified recurrence" {
    export run_mode=recurrence-later-change
    seq_tool run "${sequence}" E01 >/dev/null
    settle_slot E01 >/dev/null
    [[ "$(audits '.installed.before.result')" == passed && "$(audits '.installed.after.result')" == failed ]]
    [[ "$(phase endpoint)" == failed && "$(phase subject)" == passed ]]
    [[ "$(settled disposition)" == rejected ]]
}

@test "a recurrence with an unpassed screenshot audit stays unresolved" {
    export run_mode=recurrence
    seq_tool run "${sequence}" E01 >/dev/null
    printf '{"result":"not-run","detail":"no audit"}\n' >"${screens}"
    settle_slot E01 >/dev/null
    [[ "$(settled disposition)" == unresolved ]]
}

@test "settle-run refuses a malformed audit and leaves the slot unsettled" {
    seq_tool run "${sequence}" E01 >/dev/null
    printf '{"result":"maybe","detail":"control"}\n' >"${screens}"
    run settle_slot E01
    expect_refused "screenshot audit"
    printf '{"result":"passed","detail":"control","extra":1}\n' >"${screens}"
    run settle_slot E01
    expect_refused "screenshot audit"
    [[ "$(report .slots.E01.state)" == started-unsettled ]]
}

@test "settle-run refuses a slot with no collected run, and a second settlement" {
    run settle_slot E01
    expect_refused "not awaiting"
    seq_tool run "${sequence}" E01 >/dev/null
    settle_slot E01 >/dev/null
    run settle_slot E01
    expect_refused "not awaiting"
}

@test "a malformed read record is unavailable, and the slot still settles" {
    export run_mode=record-shape
    run_e01
    [[ "${status}" == 0 && "$(report .slots.E01.state)" == settled ]]
    [[ "$(phase endpoint)" == unavailable && "$(settled disposition)" == unresolved ]]
    [[ "$(phase stop)" == passed ]]
}

@test "a recovery settle cannot replace the phases of a collected run" {
    export guest_gatekeeper=disabled
    seq_tool run "${sequence}" E01 >/dev/null
    run seq_tool settle "${sequence}" E01
    expect_refused "settle-run"
    [[ "$(report .slots.E01.state)" == started-unsettled ]]
}

@test "a bundle that is one file refuses the run" {
    local other="${BATS_TEST_TMPDIR}/other" bad="${BATS_TEST_TMPDIR}/bad.json" single
    single="$(seq_tool inventory "${frozen}/Taskfile.yml" bundle)"
    jq --argjson single "${single}" '.inputs = [$single]' "${focused_receipt}" >"${bad}"
    seq_tool declare "${other}" >/dev/null
    seq_tool ready "${other}" focused "${bad}" >/dev/null
    run seq_tool run "${other}" E01
    expect_refused "frozen declaration"
}

@test "settle-run cannot change a phase other than the screenshots" {
    export guest_gatekeeper=disabled
    seq_tool run "${sequence}" E01 >/dev/null
    printf '{"result":"passed","detail":"control"}\n' >"${screens}"
    settle_slot E01 >/dev/null
    [[ "$(phase environment)" == failed && "$(settled disposition)" == unresolved ]]
}

# --- the declared executables and the clone provenance (k180) ---------------

@test "a receipt without both executables or the TestAnyware paths refuses the run before admission (k180)" {
    local other="${BATS_TEST_TMPDIR}/other" case
    for case in no-cli linked-jq no-paths relative-state; do
        rm -rf "${other}"
        case "${case}" in
        no-cli) jq '.inputs |= map(select(.name != "testanyware"))' "${focused_receipt}" ;;
        linked-jq) jq '(.inputs[] | select(.name == "jq") | .items) = [{path: ".", kind: "symlink", target: "jq"}]' "${focused_receipt}" ;;
        no-paths) jq 'del(.testanyware_paths)' "${focused_receipt}" ;;
        relative-state) jq '.testanyware_paths.state_dir = "state"' "${focused_receipt}" ;;
        esac >"${BATS_TEST_TMPDIR}/${case}.json"
        seq_tool declare "${other}" >/dev/null
        seq_tool ready "${other}" focused "${BATS_TEST_TMPDIR}/${case}.json" >/dev/null
        run seq_tool run "${other}" E01
        expect_refused "frozen declaration"
    done
    [[ "$(tasks)" == 0 ]]
}

@test "the run passes the frozen executables, and a qualifying slot names them and its provenance (k180)" {
    run env -u KOINE_TESTANYWARE_CLI -u KOINE_JQ python3 -I "${tool}" run "${sequence}" E01
    [[ "${status}" == 0 ]]
    settle_slot E01 >/dev/null
    [[ "$(phase subject)" == passed && "$(settled disposition)" == qualified ]]
    audits '.provenance.result == "passed"' >/dev/null
    jq -e --arg cli "${KOINE_TESTANYWARE_CLI}" --arg jq "${KOINE_JQ}" \
        '.executables.testanyware.path == $cli and .executables.jq.path == $jq' \
        "$(slot_field E01 evidence_root)/subject.json"
}

@test "a changed executable holds the sequence before admission (k180)" {
    printf '# changed\n' >>"${KOINE_TESTANYWARE_CLI}"
    run seq_tool run "${sequence}" E01
    expect_held "failed: testanyware"
}

@test "a slot without a provenance record cannot qualify (k180)" {
    export run_provenance=skip
    run_e01
    audits '.provenance.result == "unavailable" and .provenance.detail == "0 provenance attempts"' >/dev/null
    [[ "$(phase subject)" == unavailable && "$(settled disposition)" == unresolved ]]
}

@test "a provenance on other frozen paths or a scenario on another CLI fails the subject (k180)" {
    local other="${BATS_TEST_TMPDIR}/other"
    jq '.testanyware_paths.state_dir = "/other/state"' "${focused_receipt}" >"${BATS_TEST_TMPDIR}/state.json"
    seq_tool declare "${other}" >/dev/null
    seq_tool ready "${other}" focused "${BATS_TEST_TMPDIR}/state.json" >/dev/null
    seq_tool run "${other}" E01 >/dev/null
    [[ "$(jq -r .provenance.result "$(jq -er '.slots[0].output' "${other}/sequence.json")/containment/audits.json")" == failed ]]
    jq -e '.provenance.detail | endswith("differs: state_dir, spec path")' \
        "$(jq -er '.slots[0].output' "${other}/sequence.json")/containment/audits.json"
    cp "${KOINE_TESTANYWARE_CLI}" "${BATS_TEST_TMPDIR}/other-cli"
    cp "${KOINE_JQ}" "${BATS_TEST_TMPDIR}/other-jq"
    export run_cli="${BATS_TEST_TMPDIR}/other-cli" run_jq="${BATS_TEST_TMPDIR}/other-jq"
    run_e01
    [[ "$(phase subject)" == failed && "$(settled disposition)" == unresolved ]]
    audits '.provenance.detail | contains("subject.json records another testanyware executable")
        and contains("subject.json records another jq executable")
        and contains("000001 ran another CLI") and contains("000001 ran another jq")' >/dev/null
}

@test "a guest transport ordered before the provenance record fails the provenance audit (k180)" {
    local root="${BATS_TEST_TMPDIR}/tamper"
    (
        # shellcheck source=scripts/vm-lifecycle-evidence-lib.sh
        source "${repo_root}/scripts/vm-lifecycle-evidence-lib.sh"
        init_guest_evidence "${root}" koine-k49-ordering-e01
        start_guest_vm "${root}" vm-start testanyware-golden-macos-27 >/dev/null
        record_guest_provenance "${root}" clone-provenance
        cli_guest_evidence "${root}" one-shot key true -- input key return >/dev/null
    )
    run_check() {
        python3 -I - "${tool}" "${root}" "${focused_receipt}" <<'PY_CONTROL'
import importlib.util, json, sys
spec = importlib.util.spec_from_file_location("sequence", sys.argv[1])
module = importlib.util.module_from_spec(spec)
sys.modules["sequence"] = module
spec.loader.exec_module(module)
frozen = json.load(open(sys.argv[3]))
print(json.dumps(module.provenance_check(module.Path(sys.argv[2]), frozen, "koine-k49-ordering-e01", "not-run")))
PY_CONTROL
    }
    [[ "$(run_check | jq -r .result)" == passed ]]
    mv "${root}/000002" "${root}/swap"
    mv "${root}/000003" "${root}/000002"
    mv "${root}/swap" "${root}/000003"
    run_check | jq -e '.result == "failed" and (.detail | endswith("differs: ordinal, order"))'
}
