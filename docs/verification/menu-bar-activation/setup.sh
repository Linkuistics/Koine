#!/bin/bash
set -euo pipefail
source scripts/signing-env.sh
APP_BUNDLE="$PWD/.build/menu-interaction/Koine.app"
KOINE_VM_ID=koine-menu-k8-diagnosis
KOINE_VM_BASE=testanyware-golden-macos-27
KOINE_VM_KEEP=1
KOINE_VM_LOG_PREFIX=menu-k8-setup-
source scripts/vm-verify-lib.sh
start_vm
install_app
testanyware file upload .build/menu-activation/activation-snapshot /Users/admin/activation-snapshot --json
grant_system_events_automation
guest_once 'open /Applications/Koine.app'
await_windows 1
guest_once 'open -a TextEdit'
sleep 10
testanyware agent windows --json
