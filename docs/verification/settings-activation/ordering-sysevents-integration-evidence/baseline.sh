#!/bin/bash
# Run the k156 controls against the read table before the k156 repair.
# The scratch tree takes every script and test from the working copy, except
# scripts/vm_exec_reads.py, which comes from REVISION. Both suites run: the
# synthetic suite and the host suite, which runs real osascript on literals.
# Usage: baseline.sh REVISION SCRATCH OUTPUT
set -euo pipefail
revision="$1" scratch="$2" output="$3"
mkdir "${scratch}"
cp -R scripts "${scratch}/scripts"
mkdir -p "${scratch}/Tests"
cp -R Tests/scripts "${scratch}/Tests/scripts"
jj file show -r "${revision}" scripts/vm_exec_reads.py >"${scratch}/scripts/vm_exec_reads.py"
{
    printf '# command: bats Tests/scripts/vm-sysevents-evidence.bats Tests/scripts/vm-sysevents-host.bats\n'
    printf '# revision of scripts/vm_exec_reads.py: %s\n' "$(jj log --no-graph -r "${revision}" -T 'commit_id')"
    printf '# started: %s\n# subjects\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    (cd "${scratch}" && shasum -a 256 scripts/vm_exec_reads.py scripts/vm-guest-exec.py scripts/vm-guest-exec-lib.sh \
        scripts/vm-sysevents-evidence-lib.sh Tests/scripts/vm-sysevents-evidence.bats Tests/scripts/vm-sysevents-host.bats \
        Tests/scripts/fixtures/exec-read-cli.py)
    printf '# output\n'
    status=0
    (cd "${scratch}" && bats Tests/scripts/vm-sysevents-evidence.bats Tests/scripts/vm-sysevents-host.bats 2>&1) || status=$?
    printf '# bats exit: %s\n# ended: %s\n' "${status}" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >"${output}"
