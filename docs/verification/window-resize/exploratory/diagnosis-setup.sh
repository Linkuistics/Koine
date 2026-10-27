#!/bin/bash
set -euo pipefail
source scripts/signing-env.sh
KOINE_VM_ID=koine-resize-k3-geometry
KOINE_VM_BASE=testanyware-golden-macos-27
KOINE_VM_KEEP=1
KOINE_VM_LOG_PREFIX=k3-geometry-
source scripts/vm-verify-lib.sh
start_vm
install_app
guest_once 'open /Applications/Koine.app'
await_windows 1
testanyware agent window-move --window 'Koine Settings' --x 40 --y 40 --json
testanyware agent windows --json
