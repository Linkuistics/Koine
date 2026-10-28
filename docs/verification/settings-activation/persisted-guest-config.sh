#!/bin/bash
# Execute only in the declared disposable guest, never on the host/golden.
set -euo pipefail
phase="${1:?enable or status}"
case "${phase}" in enable | status) ;; *) exit 2 ;; esac
if [ "${phase}" = enable ]; then
    help_status=0
    /usr/bin/log help config 2>&1 || help_status=$?
    [ "${help_status}" -eq 0 ] || [ "${help_status}" -eq 64 ]
fi
for subsystem in com.apple.SkyLight com.apple.SkyLight.processes com.apple.launchservices; do
    printf 'BEFORE %s\n' "${subsystem}"
    printf '%s\n' admin | sudo -S -p '' /usr/bin/log config --status --subsystem "${subsystem}"
    if [ "${phase}" = enable ]; then
        # Public log config help defines level and persist independently. Debug
        # persistence is needed before observation; log show cannot restore it.
        # https://developer.apple.com/videos/play/wwdc2020/10168/
        printf '%s\n' admin | sudo -S -p '' /usr/bin/log config --subsystem "${subsystem}" --mode level:debug,persist:debug
        printf 'AFTER %s\n' "${subsystem}"
        printf '%s\n' admin | sudo -S -p '' /usr/bin/log config --status --subsystem "${subsystem}"
    fi
done
echo "KOINE_PERSISTED_${phase}_COMPLETE"
