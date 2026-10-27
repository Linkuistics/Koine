#!/bin/bash
set -euo pipefail
source scripts/signing-env.sh
APP_BUNDLE="$PWD/.build/menu-interaction/Koine.app"
KOINE_VM_ID=koine-menu-k8-diagnosis
KOINE_VM_KEEP=1
KOINE_VM_LOG_PREFIX=menu-k8-action-
source scripts/vm-verify-lib.sh
# Read-only calls accept a complete JSON payload even if exec reports its known false timeout.
observe() {
    local name="$1" status=0
    echo "OBSERVE ${name} $(date -u +%FT%TZ)"
    testanyware file exec /Users/admin/activation-snapshot --timeout 3 --json > ".build/menu-activation/${name}-native.json" || status=$?
    echo "Native transport status: ${status}"
    cat ".build/menu-activation/${name}-native.json"
    jq -e '.stdout | fromjson | has("front") and has("windows")' ".build/menu-activation/${name}-native.json" >/dev/null
    testanyware agent windows --json | tee ".build/menu-activation/${name}-windows.json"
    testanyware screen capture -o ".build/menu-activation/${name}.png" --json
}
step 'Historical route: TextEdit was launched once in setup; close Koine once, then choose Settings once'
testanyware agent window-close --window 'Koine Settings' --json
await_windows 0
observe historical-before
open_menu
testanyware screen capture -o .build/menu-activation/historical-open-menu.png --json
frame="$(sysevents "get {position, size} of menu item \"Settings…\" of menu 1 of ${KOINE_ITEM}")"
echo "ONE SETTINGS ACTION $(date -u +%FT%TZ) frame=${frame}"
click_centre "$frame"
observe historical-after-before-keyboard
# No keyboard or window-focus intervention follows this action.
