#!/bin/bash
# Run only after focus observations, in the disposable macOS guest.
set -euo pipefail
out=/Users/admin/deferred-native
mkdir "${out}"
# shellcheck disable=SC2329 # Called by the EXIT trap.
package_on_exit() {
    local status=$?
    trap - EXIT
    set +e
    bash /Users/admin/deferred-package.sh "${out}" /Users/admin/deferred-native.tgz "${status}"
    exit $?
}
trap package_on_exit EXIT
date -u '+%Y-%m-%dT%H:%M:%SZ' >"${out}/started.txt"
# Info is only briefly retained; --debug cannot recreate disabled Debug events.
# https://developer.apple.com/videos/play/wwdc2020/10168/ (8:17 persistence)
# shellcheck disable=SC2024 # Guest admin owns these output redirects.
printf '%s\n' admin | sudo -S -p '' /usr/bin/log collect --last 10m --output "${out}/system.logarchive" \
    >"${out}/collect.stdout" 2>"${out}/collect.stderr"
date -u '+%Y-%m-%dT%H:%M:%SZ' >"${out}/collected.txt"
# The installed guest's `log help show/collect` is saved before application launch.
/usr/bin/log show --archive "${out}/system.logarchive" --style ndjson --info --debug \
    --predicate "$(cat /Users/admin/context-predicate.txt)" \
    >"${out}/native.jsonl" 2>"${out}/show.stderr"
date -u '+%Y-%m-%dT%H:%M:%SZ' >"${out}/rendered.txt"
