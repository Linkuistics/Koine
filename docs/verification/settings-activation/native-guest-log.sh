#!/bin/bash
# Runs only in a disposable guest, guarded by the caller's mkdir.
set -euo pipefail
cd /Users/admin/native-activation-log
/usr/bin/log help stream >help.txt 2>&1 || true
date -u '+%Y-%m-%dT%H:%M:%SZ' >started.txt
# log stream is the public observation surface; no private activation call.
# https://developer.apple.com/documentation/os/logging
status=0
/usr/bin/log stream --style ndjson --level debug --timeout 15m \
    --predicate 'process IN {"Koine", "WindowServer", "Dock", "TextEdit", "runningboardd", "loginwindow", "lsd", "coreservicesd"}' \
    >stream.jsonl 2>stream.stderr &
log_pid=$!
printf '%s\n' "${log_pid}" >pid
ps -p "${log_pid}" -o pid=,ppid=,comm= >process.txt || true
wait "${log_pid}" || status=$?
printf '%s\n' "${status}" >stream.exit
date -u '+%Y-%m-%dT%H:%M:%SZ' >ended.txt
