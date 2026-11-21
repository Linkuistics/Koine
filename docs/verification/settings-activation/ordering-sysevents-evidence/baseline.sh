#!/bin/bash
# Run the k151 controls against legacy semantics. The scratch tree takes
# scripts/ from REVISION, the parent of the k151 change, and the new suite and
# the shared fixture from the working copy. KOINE_SYSEVENTS_BASELINE=1 replaces
# the new facade with test-only wrappers of the legacy sysevents, guest_json
# and enrol semantics. Usage: baseline.sh REVISION SCRATCH OUTPUT
set -euo pipefail
revision="$1" scratch="$2" output="$3"
mkdir "${scratch}"
mkdir -p "${scratch}/scripts" "${scratch}/Tests/scripts/fixtures"
for file in $(jj file list -r "${revision}" scripts); do
    mkdir -p "${scratch}/$(dirname "${file}")"
    jj file show -r "${revision}" "${file}" >"${scratch}/${file}"
done
cp Tests/scripts/vm-sysevents-evidence.bats "${scratch}/Tests/scripts/"
cp Tests/scripts/fixtures/exec-read-cli.py "${scratch}/Tests/scripts/fixtures/"
{
    printf '# command: KOINE_SYSEVENTS_BASELINE=1 bats Tests/scripts/vm-sysevents-evidence.bats\n'
    printf '# revision of scripts/: %s\n' "$(jj log --no-graph -r "${revision}" -T 'commit_id')"
    printf '# started: %s\n# subjects\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    (cd "${scratch}" && shasum -a 256 scripts/vm-guest-exec.py scripts/vm-guest-exec-lib.sh scripts/vm_exec_reads.py \
        scripts/vm-verify-lib.sh scripts/vm-verify-menu-bar.sh scripts/vm-verify-desktop-lib.sh \
        Tests/scripts/vm-sysevents-evidence.bats Tests/scripts/fixtures/exec-read-cli.py)
    printf '# output\n'
    status=0
    (cd "${scratch}" && KOINE_SYSEVENTS_BASELINE=1 bats Tests/scripts/vm-sysevents-evidence.bats 2>&1) || status=$?
    printf '# bats exit: %s\n# ended: %s\n' "${status}" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >"${output}"
