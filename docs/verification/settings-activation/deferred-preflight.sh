#!/bin/bash
# Keep the single raw preflight envelope, including normalized command output.
set -euo pipefail
out="${KOINE_K4_OUT:?attempt output directory}"
testanyware file exec --json 'bash /Users/admin/deferred-guest-preflight.sh' \
    >"${out}/deferred-preflight.json" 2>"${out}/deferred-preflight.stderr"
jq -e '.ok == true and .exit_code == 0 and .timed_out == false and
    (.stdout | rtrimstr("\n") | split("\n")[-1]) == "KOINE_DEFERRED_PREFLIGHT_COMPLETE"' "${out}/deferred-preflight.json" >/dev/null
