#!/bin/bash
set -euo pipefail
phase="${1:?enable or status}"
case "${phase}" in enable | status) ;; *) exit 2 ;; esac
out="${KOINE_K4_OUT:?attempt output directory}"
testanyware file exec --json "bash /Users/admin/persisted-guest-config.sh ${phase}" \
    >"${out}/persisted-${phase}.json" 2>"${out}/persisted-${phase}.stderr"
jq -e --arg marker "KOINE_PERSISTED_${phase}_COMPLETE" \
    '.ok == true and .exit_code == 0 and .timed_out == false and
    (.stdout | rtrimstr("\n") | split("\n")[-1]) == $marker' \
    "${out}/persisted-${phase}.json" >/dev/null
