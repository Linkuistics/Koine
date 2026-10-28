#!/bin/bash
# One native logger launch/readiness observation, preserving its raw transport.
set -euo pipefail
out="${KOINE_K4_OUT:?attempt output directory}"
# shellcheck disable=SC2016 # All substitutions execute in the guest.
testanyware file exec --json 'mkdir /Users/admin/native-activation-log || exit 1; nohup bash /Users/admin/native-guest-log.sh >/Users/admin/native-activation-log/launcher.txt 2>&1 </dev/null & for n in 1 2 3 4 5; do test ! -s /Users/admin/native-activation-log/pid || break; sleep 1; done; test -s /Users/admin/native-activation-log/pid && kill -0 "$(cat /Users/admin/native-activation-log/pid)"' \
    >"${out}/native-start.json" 2>"${out}/native-start.stderr"
jq -e '.ok == true and .exit_code == 0 and .timed_out == false' "${out}/native-start.json" >/dev/null
