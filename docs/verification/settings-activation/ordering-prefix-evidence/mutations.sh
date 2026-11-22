#!/bin/bash
# Two mutation controls of the k62 prefix suite and check. Run from the repository root.
set -u
echo "## 1. The guard of a failure case refuses a run that reached the quit's absence read"
calls="$(mktemp)"
printf '%s\n' '{"action":"read","kind":"read-poll","operation":"textedit-quit-absence","arguments":["process","textedit"],"outcome":"clean"}' >"${calls}"
eval "$(sed -n '/^refute() {/,/^}/p' Tests/scripts/vm-settings-prefix.bats)"
status=0
refute '"operation":"textedit-quit-absence"' "${calls}" || status=$?
echo "refute status ${status} (expected 1)"
echo "## 2. The check refuses the historical order prefix as the focused prefix"
status=0
python3 -I scripts/check-settings-prefix.py scripts/vm-verify-menu-bar.sh docs/verification/settings-activation/order-prefix.sh || status=$?
echo "check status ${status} (expected 1)"
