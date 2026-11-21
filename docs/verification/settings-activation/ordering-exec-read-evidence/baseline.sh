#!/bin/bash
# Run the new exec read controls against legacy semantics. The scratch tree
# takes the backend and facade at the parent revision, before this leaf, and
# the new suite and fixture from the working copy. The suite's baseline mode
# replaces the new helpers with test-only wrappers of the legacy guest and
# guest_text semantics. Usage: baseline.sh REVISION SCRATCH OUTPUT
set -euo pipefail
revision="$1" scratch="$2" output="$3"
mkdir "${scratch}" "${scratch}/scripts" "${scratch}/Tests" "${scratch}/Tests/scripts" "${scratch}/Tests/scripts/fixtures"
for file in scripts/vm-guest-exec.py scripts/vm-guest-exec-lib.sh scripts/vm_capture_artifact.py; do
    jj file show -r "${revision}" "${file}" >"${scratch}/${file}"
done
cp Tests/scripts/vm-exec-read-evidence.bats "${scratch}/Tests/scripts/"
cp Tests/scripts/fixtures/exec-read-cli.py "${scratch}/Tests/scripts/fixtures/"
{
    printf '# command: env KOINE_EXEC_READ_BASELINE=1 bats Tests/scripts/vm-exec-read-evidence.bats\n'
    printf '# revision of the backend and facade: %s\n' "$(jj log --no-graph -r "${revision}" -T 'commit_id')"
    printf '# started: %s\n# subjects\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    (cd "${scratch}" && shasum -a 256 scripts/* Tests/scripts/vm-exec-read-evidence.bats Tests/scripts/fixtures/exec-read-cli.py)
    printf 'absent  scripts/vm-exec-read-evidence-lib.sh\nabsent  scripts/vm_exec_reads.py\n# output\n'
    status=0
    (cd "${scratch}" && KOINE_EXEC_READ_BASELINE=1 bats Tests/scripts/vm-exec-read-evidence.bats 2>&1) || status=$?
    printf '# bats exit: %s\n# ended: %s\n' "${status}" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >"${output}"
