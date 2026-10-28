#!/bin/bash
# A single raw acquisition; a timeout never becomes a successful collection.
set -euo pipefail
out="${KOINE_K4_OUT:?attempt output directory}"
testanyware file exec --timeout 120 --json 'bash /Users/admin/deferred-guest-collect.sh' \
    >"${out}/deferred-collect.json" 2>"${out}/deferred-collect.stderr"
jq -e '.ok == true and .exit_code == 0 and .timed_out == false and
    (.stdout | rtrimstr("\n")) == "KOINE_DEFERRED_COMPLETE"' "${out}/deferred-collect.json" >/dev/null
