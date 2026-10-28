#!/bin/bash
# Disposable golden's documented admin/admin account; no logging mutations.
set -euo pipefail
for verb in collect show; do
    status=0
    /usr/bin/log help "${verb}" 2>&1 || status=$?
    printf '\nlog help %s exit: %s\n' "${verb}" "${status}"
    # `log help` prints usage and returns EX_USAGE on the installed host version.
    [ "${status}" -eq 0 ] || [ "${status}" -eq 64 ]
done
printf '%s\n' admin | sudo -S -p '' /usr/bin/log config --status
ps -axo pid,comm,args
echo KOINE_DEFERRED_PREFLIGHT_COMPLETE
