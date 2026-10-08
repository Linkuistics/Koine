#!/bin/bash
# Mutation controls against independently recorded real delivery, never synthetic success.
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
evidence=docs/verification/application-installations-vm/results.json
jq '.[] | select(.case == "open: nothing running; the named application unconstrained opens the document in the copy Launch Services chooses (A)") | .observed' "${evidence}" >"${work}/good.json"
test "$(jq -s length "${work}/good.json")" = 1
predicate='include "application-location-observations"; short_workflow("A"; "open"; "/Users/admin/install-fx/docs/note-1.koineinstall")'
jq_arguments=(-L scripts)
jq "${jq_arguments[@]}" -e "${predicate}" "${work}/good.json" >/dev/null
reject_mutation() {
    local name="$1" mutation="$2"
    jq "${mutation}" "${work}/good.json" >"${work}/mutant.json"
    if jq "${jq_arguments[@]}" -e "${predicate}" "${work}/mutant.json" >/dev/null; then
        echo "FAILED: observer accepted ${name}" >&2
        exit 1
    fi
    echo "Rejected: ${name}"
}
reject_mutation wrong-copy '.log[].bundlePath = "/a/different/Fixture.app" | .witness.bundle = "/a/different/Fixture.app" | .after[].bundle = "/a/different/Fixture.app"'
reject_mutation wrong-document '(.log[] | select(.event == "open") | .path) = "/Users/admin/install-fx/docs/note-2.koineinstall"'
reject_mutation null-receipt '.answer.process = null'
reject_mutation wrong-kernel-start '.witness.startedAt = "different-incarnation"'
reject_mutation no-delivery '.log |= map(select(.event != "open"))'
echo "Passed: recorded delivery control and five rejected mutations"

refusal="${1:-docs/verification/application-locations-vm/first-refusal.json}"
cp "${refusal}" "${work}/good.json"
application="$(jq -r .answer.application.applicationPath "${work}/good.json")"
# shellcheck disable=SC2016  # application is a jq argument, not a shell expression
predicate='include "application-refusal-observations"; supplied_refusal(1024; "launch"; $application)'
jq_arguments=(-L scripts --arg application "${application}")
jq "${jq_arguments[@]}" -e "${predicate}" "${work}/good.json" >/dev/null
reject_mutation wrong-spelling-kind '.answer.errors[0].message |= sub("as written"; "as resolved")'
reject_mutation wrong-byte-count '.answer.errors[0].message |= sub("1024 bytes,"; "1500 bytes,")'
reject_mutation wrong-response-path '.answer.errors[0].path = ["workspaceOpenPath"]'
reject_mutation invented-dependency '.answer.dependency = {reason: "APPLICATION_NOT_INSTALLED"}'
reject_mutation receipt-on-refusal '.answer.process = {pid: 1, startedAt: "unexpected"}'
reject_mutation unexpected-delivery '.log = [{event: "open"}]'
reject_mutation new-process '.procsAfter = ["an unexpected process"]'
reject_mutation wrong-selected-path '.answer.application.applicationPath = "/somewhere/else"'
echo "Passed: recorded literal-spelling refusal and eight rejected mutations"
