#!/bin/bash
# Retain an independent endpoint transport alongside the unchanged safe read.
# Failure stays in the audit without preventing the declared application actions.
set -euo pipefail
out="${KOINE_K4_OUT:?attempt output directory}" expected="${1:?expected bundle inventory}"
check=0 upload_status=0 cli_status=0
testanyware file upload docs/verification/settings-activation/inventory.sh /Users/admin/k12-inventory.sh \
    >"${out}/initial-inventory-upload.txt" 2>&1 || upload_status=$?
printf '%s\n' "${upload_status}" >"${out}/initial-inventory-upload.exit"
if [ "${upload_status}" -eq 0 ]; then
    testanyware file exec --json 'bash /Users/admin/k12-inventory.sh /Applications/Koine.app' \
        >"${out}/installed-before-raw.json" 2>"${out}/installed-before-raw.stderr" || cli_status=$?
    printf '%s\n' "${cli_status}" >"${out}/installed-before-cli.exit"
    if [ "${cli_status}" -eq 0 ] && jq -e '.ok == true and .exit_code == 0 and .timed_out == false' "${out}/installed-before-raw.json" >/dev/null; then
        jq -r '.stdout' "${out}/installed-before-raw.json" | sed '/^$/d' >"${out}/installed-before-raw.txt"
        diff -u "${expected}" "${out}/installed-before-raw.txt" >"${out}/installed-before-raw-diff.txt" || check=1
    else
        check=1
    fi
else
    check=1
fi
printf '%s\n' "${check}" >"${out}/installed-before-check.exit"
