#!/usr/bin/env bats
# Controls for the comparison of the Settings scenario with baseline f019161b.
# Every changed input runs on a private copy. No VM or CLI is used.

setup() {
    cd "${BATS_TEST_DIRNAME}/../.." || return 1
    check=scripts/check-settings-baseline.py
    evidence=docs/verification/settings-activation/ordering-baseline-evidence
    review="${BATS_TEST_TMPDIR}/classification.json"
    cp "${evidence}/classification.json" "${review}"
}

# Run one Python statement on the copied classification.
edit_review() {
    python3 -I - "${review}" "$1" <<'PY'
import json
import sys

path, statement = sys.argv[1:]
review = json.load(open(path, encoding="utf-8"))
exec(statement)
json.dump(review, open(path, "w", encoding="utf-8"), ensure_ascii=False)
PY
}

refused_review() {
    run python3 -I "${check}" --classification "${review}" --case "$1"
    [[ "${status}" == 1 ]]
    [[ "${output}" == *"$2"* ]]
}

@test "the complete scenario matches the retained record of baseline f019161b" {
    run python3 -I "${check}"
    [[ "${status}" == 0 ]] || {
        printf '%s\n' "${output}"
        return 1
    }
    [[ "${output}" == *'17 cases'*'0 findings'* ]]
}

@test "the retained record is the derivation of the real baseline script" {
    run python3 -I "${check}" --derive-baseline "${BATS_TEST_TMPDIR}/baseline.json"
    [[ "${status}" == 0 ]]
    cmp "${evidence}/baseline.json" "${BATS_TEST_TMPDIR}/baseline.json"
}

@test "each changed input, wait, bound or assertion fails the control" {
    run python3 -I Tests/scripts/fixtures/settings-baseline-mutations.py
    [[ "${status}" == 0 ]] || {
        printf '%s\n' "${output}"
        return 1
    }
    [[ "${output}" == *'19 of 19 mutations detected'* ]]
}

@test "an unclassified failure difference fails the control" {
    edit_review 'review["failure_differences"] = [row for row in review["failure_differences"] if row["case"] != "window-count"]'
    refused_review window-count 'window-count: failure'
}

@test "an unclassified event difference fails the control" {
    edit_review 'review["event_differences"] = []'
    refused_review menu-titles 'menu-titles: event'
}

@test "a classified removal that is not in the record fails the control" {
    edit_review 'review["event_differences"][0]["removed"] = ["input key return", "wait 1"]'
    refused_review menu-titles 'classified removal'
}

@test "a difference without a known class fails the control" {
    edit_review 'review["source_differences"][0]["class"] = "unexplained"'
    refused_review complete 'unknown class'
}

@test "a class without a resolving citation fails the control" {
    edit_review 'review["classes"]["message-only"]["citation"] += "-missing"'
    refused_review complete 'citation heading not found'
}

@test "a wait table that differs from the baseline waits fails the control" {
    edit_review 'review["waits"][0]["seconds"] = 3'
    refused_review complete 'wait table differs'
}

@test "an assertion table that omits a baseline assertion fails the control" {
    edit_review 'del review["assertions"][25]'
    refused_review complete 'assertion table differs'
}

@test "the baseline CLI refuses a command that it does not simulate" {
    export settings_sim="${BATS_TEST_TMPDIR}" KOINE_VM_ID=exact-settings-vm
    export settings_backend="${PWD}/Tests/scripts/fixtures/settings-scenario-backend.py"
    run python3 -I Tests/scripts/fixtures/settings-baseline-cli.py file exec 'unknown command'
    [[ "${status}" == 98 ]]
    grep -q unsimulated "${BATS_TEST_TMPDIR}/calls.jsonl"
}
