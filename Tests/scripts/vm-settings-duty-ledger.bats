#!/usr/bin/env bats
# Controls for the per-duty ledger check. Each control changes a private copy.

setup() {
    cd "${BATS_TEST_DIRNAME}/../.." || return 1
    check=scripts/check-settings-duty-ledger.py
    ledger=docs/verification/settings-activation/ordering-reconciliation-evidence/duties.json
    copy="${BATS_TEST_TMPDIR}/duties.json"
    cp "${ledger}" "${copy}"
}

# Run one Python statement on the copied rows. `met` is the first met row.
mutate() {
    python3 - "${copy}" "$1" <<'PY'
import json
import sys

path, statement = sys.argv[1:]
rows = json.load(open(path, encoding="utf-8"))
met = next(row for row in rows if row["disposition"] == "met")
exec(statement)
json.dump(rows, open(path, "w", encoding="utf-8"))
PY
}

refused() {
    run python3 "${check}" "$@" "${copy}"
    [[ "${status}" == 1 ]]
}

@test "the delivered ledger holds every archived sentence and resolves each citation" {
    run python3 "${check}"
    [[ "${status}" == 0 ]]
    [[ "${output}" == *"393 duties:"* ]]
    [[ "${output}" == *"; 0 findings" ]]
}

@test "a missing duty is refused" {
    mutate 'del rows[0]'
    refused
    [[ "${output}" == *"D001: missing duty"* ]]
}

@test "a duplicate row is refused" {
    mutate 'rows.append(dict(rows[0]))'
    refused
    [[ "${output}" == *"D001: duplicate row"* ]]
}

@test "changed duty text is refused" {
    mutate 'rows[0]["text"] += " Changed."'
    refused
    [[ "${output}" == *"D001: differs from the archived contract"* ]]
}

@test "a changed archived contract is refused" {
    archive="${BATS_TEST_TMPDIR}/archive"
    cp -R docs/verification/grove-tree-structure/original-briefs "${archive}"
    printf '\nA new binding duty appears here.\n' >>"${archive}/k85.txt"
    refused --archive "${archive}"
    [[ "${output}" == *"missing duty"* ]]
}

@test "an unknown disposition is refused" {
    mutate 'met["disposition"] = "passed"'
    refused
    [[ "${output}" == *"unknown disposition: passed"* ]]
}

@test "a met duty without a control is refused" {
    mutate 'met["controls"] = []'
    refused
    [[ "${output}" == *"met without a control"* ]]
}

@test "a met duty without source is refused" {
    mutate 'met["source"] = []'
    refused
    [[ "${output}" == *"met without source"* ]]
}

@test "a control name that is not an exact test is refused" {
    mutate 'met["controls"][0]["test"] += " renamed"'
    refused
    [[ "${output}" == *"control not found"* ]]
}

@test "a source symbol that is not in its file is refused" {
    mutate 'met["source"][0]["symbol"] = "symbol_that_does_not_exist_here"'
    refused
    [[ "${output}" == *"source not found"* ]]
}

@test "a gap without an owner handle is refused" {
    mutate 'met.update(disposition="gap", owner="someone", note="Missing work.")'
    refused
    [[ "${output}" == *"gap without an owner handle"* ]]
}

@test "a limit without an authority is refused" {
    mutate 'met.update(disposition="limit", authority=None)'
    refused
    [[ "${output}" == *"limit without an authority"* ]]
}

@test "require-closed refuses an open gap" {
    mutate 'met.update(disposition="gap", owner="settings-example-k1", note="Missing work.")'
    run python3 "${check}" "${copy}"
    [[ "${output}" != *"open gap"* ]]
    refused --require-closed
    [[ "${output}" == *"open gap owned by settings-example-k1"* ]]
}

@test "require-closed passes when no gap remains" {
    mutate '[row.update(disposition="limit", authority="docs/adr/settings-harness-takes-no-keepalive-captures.md", owner=None) for row in rows if row["disposition"] == "gap"]'
    run python3 "${check}" --require-closed "${copy}"
    [[ "${status}" == 0 ]]
}

@test "an unreadable or malformed ledger is a usage failure" {
    run python3 "${check}" "${BATS_TEST_TMPDIR}/absent.json"
    [[ "${status}" == 2 ]]
    printf '{"not": "a list"}' >"${copy}"
    run python3 "${check}" "${copy}"
    [[ "${status}" == 2 ]]
}
