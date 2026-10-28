#!/bin/bash
# Reject premature completion before requesting intentional log termination.
set -euo pipefail
log_dir="${1:-/Users/admin/native-activation-log}"
test ! -e "${log_dir}/stream.exit"
log_pid="$(cat "${log_dir}/pid")"
kill -0 "${log_pid}"
date -u '+%Y-%m-%dT%H:%M:%SZ' >"${log_dir}/stop-requested.txt"
kill -TERM "${log_pid}"
for _ in 1 2 3 4 5; do
    test ! -e "${log_dir}/stream.exit" || break
    sleep 1
done
# log may handle TERM and return 0, or terminate with signal status 143.
case "$(cat "${log_dir}/stream.exit")" in
0 | 143) ;;
*) exit 1 ;;
esac
