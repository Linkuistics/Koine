#!/bin/bash
# Preserve one trace-disabled observation; never replay an unsuccessful read.
set -euo pipefail
phase="${1:?before or after}"
out="${KOINE_K4_OUT:?attempt output directory}"
# shellcheck disable=SC2016 # Substitutions run only in the disposable guest.
testanyware file exec --json 'value=$(defaults read dev.antony.Koine KoineSettingsActivationTrace 2>&1); status=$?; if [ "$status" -eq 0 ]; then printf "%s\n" "$value"; exit 1; fi; case "$value" in *"does not exist"* | Error:\ Domain\ ?dev.antony.Koine?\ not\ found.) ;; *) printf "%s\n" "$value"; exit 1;; esac; test ! -e /Users/admin/settings-activation.jsonl || exit 1; echo KOINE_TRACE_DISABLED' \
    >"${out}/trace-disabled-${phase}.json" 2>"${out}/trace-disabled-${phase}.stderr"
jq -e '.ok == true and .exit_code == 0 and .timed_out == false and .stdout == "KOINE_TRACE_DISABLED\n"' \
    "${out}/trace-disabled-${phase}.json" >/dev/null
