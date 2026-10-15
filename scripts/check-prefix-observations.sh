#!/bin/bash
# These synthetic native snapshots test predicate discrimination only, never V.
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
jq '.answer.application.applicationPath = null
    | .answer.errors[0].message |= sub("the application path as written"; "the remaining application path after symbolic link 1")
    | .nativeSelectionBefore = {preferred: {path: "/short/alias/Fixture.app", bytes: 24,
        expandedBytes: 1024, knownPhysicalPath: "/physical/long/Fixture.app",
        identifier: "dev.koine.test.InstallationFixture", expansions: [{bytes: 1024}]},
        listed: [{knownPhysicalPath: "/physical/long/Fixture.app", expandedBytes: 1024,
                  identifier: "dev.koine.test.InstallationFixture"},
                 {knownPhysicalPath: "/Users/admin/install-fx/A/Fixture.app"}]}' \
    docs/verification/application-locations-vm/first-refusal.json >"${work}/good.json"
predicate='include "prefix-registration-observations"; discovered_refusal(1024; "launch") and registered_order(1024; "A"; "before")'
jq -L scripts -e "${predicate}" "${work}/good.json" >/dev/null
for mutation in \
    '.nativeSelectionBefore.preferred.knownPhysicalPath = null' \
    '.nativeSelectionBefore.preferred.expandedBytes = 1023' \
    '.nativeSelectionBefore.preferred.identifier = "another.identifier"' \
    '.nativeSelectionBefore.listed |= reverse' \
    '.nativeSelectionBefore.listed[0].knownPhysicalPath = null' \
    '.answer.errors[0].message |= sub("symbolic link 1"; "symbolic link 2")' \
    '.answer.errors[0].message |= sub("1024 bytes,"; "1500 bytes,")' \
    '.log = [{event: "open"}]' \
    '.procsAfter = ["new process"]' \
    '.answer.application.applicationPath = "/short/alias/Fixture.app"' \
    'del(.log)' 'del(.before,.after)' 'del(.procsBefore,.procsAfter)'; do
    jq "${mutation}" "${work}/good.json" >"${work}/mutant.json"
    if jq -L scripts -e "${predicate}" "${work}/mutant.json" >/dev/null; then
        echo "FAILED: prefix observer accepted ${mutation}" >&2
        exit 1
    fi
done
# Both order directions must discriminate, rather than finding any long entry.
jq -L scripts -e 'include "prefix-registration-observations"; .nativeSelectionBefore.listed |= reverse | registered_order(1024; "A"; "after")' "${work}/good.json" >/dev/null
# A running subject requires the exact request-local incarnation, not setup history.
running='include "prefix-registration-observations"; running_short({pid: 42, startedAt: "start"})'
jq '.before = [{pid:42, startedAt:"start", bundle:"/Users/admin/install-fx/A/Fixture.app"}] | .procsBefore = ["42 Fixture"]' "${work}/good.json" >"${work}/running.json"
jq -L scripts -e "${running}" "${work}/running.json" >/dev/null
for mutation in '.before = []' '.before[0].pid = 43' '.before[0].startedAt = "another"' '.before[0].bundle = "/another/Fixture.app"' 'del(.procsBefore)'; do
    if jq "${mutation}" "${work}/running.json" | jq -L scripts -e "${running}" >/dev/null; then
        echo "FAILED: running observer accepted ${mutation}" >&2
        exit 1
    fi
done
echo "Passed synthetic native/refusal/running controls and rejected corruptions (no V evidence)"
reveal=docs/verification/prefix-registration-vm/request-1.json
if [ -f "${reveal}" ]; then
    if jq -e '.answer | .answer.classification == "ok" and .answer.status == "AVAILABLE"' "${reveal}" >/dev/null; then
        echo "FAILED: the wrong answer nesting unexpectedly passed" >&2
        exit 1
    fi
    jq -e '.answer | .classification == "ok" and .status == "AVAILABLE" and .dependency == null and ((.errors // []) | length == 0)' "${reveal}" >/dev/null
    echo "Passed recorded reveal acknowledgement; wrong-nesting mutation rejected (no Finder selection acceptance)"
fi
