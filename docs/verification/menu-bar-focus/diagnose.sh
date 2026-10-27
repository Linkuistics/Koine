#!/bin/bash
set -euo pipefail
source scripts/signing-env.sh
APP_BUNDLE="$PWD/.build/menu-interaction/Koine.app"
KOINE_VM_ID=koine-menu-k6-diagnosis
KOINE_VM_KEEP=1
KOINE_VM_LOG_PREFIX=menu-k6-diagnosis-
source scripts/vm-verify-lib.sh
source scripts/vm-verify-desktop-lib.sh
observe() {
  echo "OBSERVE $1 $(date -u +%FT%TZ)"
  testanyware agent windows --json | tee ".build/menu-focus/$1-windows.json"
  sysevents 'get name of first process whose frontmost is true'
  sysevents 'get {name, value of attribute "AXMain", value of attribute "AXFocused"} of every window of process "Koine"'
  testanyware screen capture -o ".build/menu-focus/$1.png" --json
}
await_windows 1
guest_once 'open -a TextEdit'
sleep 10
testanyware agent window-move --window TextEdit --x 700 --y 120 --json
observe before-close
testanyware agent window-close --window 'Koine Settings' --json
await_windows 0
observe before-action
testanyware file upload .build/menu-focus/front-monitor /Users/admin/front-monitor --json
guest 'chmod +x /Users/admin/front-monitor'
testanyware file exec 'nohup /Users/admin/front-monitor > /Users/admin/front-monitor.jsonl 2>&1 &' --detach --json
open_menu
MENU="$(menu_titles)"
echo "Menu: $MENU"
testanyware screen capture -o .build/menu-focus/open-menu.png --json
frame="$(sysevents "get {position, size} of menu item \"Settings…\" of menu 1 of ${KOINE_ITEM}")"
echo "ACTION $(date -u +%FT%TZ)"
click_centre "$frame"
observe after-action
sleep 10
observe after-ten-seconds
testanyware file download /Users/admin/front-monitor.jsonl .build/menu-focus/front-monitor.jsonl --json
