#!/bin/bash
# measure.sh OUTPUT -- COMMAND...: digest the subjects, run once, digest again.
set -uo pipefail
out="$1"; shift; [[ "$1" == -- ]] && shift
subjects=(scripts/vm-guest-exec.py scripts/vm-guest-exec-lib.sh scripts/vm_capture_artifact.py
  scripts/vm-file-evidence-lib.sh scripts/vm-lifecycle-evidence-lib.sh
  Tests/scripts/vm-file-lifecycle-evidence.bats Tests/scripts/fixtures/file-lifecycle-cli.py
  Tests/scripts/vm-guest-exec.bats Tests/scripts/vm-capture-evidence.bats Taskfile.yml)
digest() { for f in "${subjects[@]}"; do if [[ -e "$f" ]]; then shasum -a 256 "$f"; else echo "absent  $f"; fi; done; }
{
  echo "# command: $*"
  echo "# started: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "# subjects before"; digest
  echo "# output"
} >"$out"
status=0
"$@" >>"$out" 2>&1 || status=$?
before="$(sed -n '/^# subjects before$/,/^# output$/p' "$out" | sed '1d;$d')"
{
  echo "# exit: ${status}"
  echo "# subjects after"; digest
  if [[ "$(digest)" == "${before}" ]]; then echo "# subjects unchanged"; else echo "# SUBJECTS CHANGED"; fi
  echo "# ended: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >>"$out"
exit "${status}"
