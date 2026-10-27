#!/bin/bash
set -euo pipefail
source scripts/signing-env.sh
APP_BUNDLE="$PWD/.build/menu-interaction/Koine.app"
KOINE_VM_ID=koine-menu-k6-diagnosis
KOINE_VM_KEEP=1
KOINE_VM_LOG_PREFIX=menu-k6-controlled-
source scripts/vm-verify-lib.sh
sysevents() {
  local result
  result="$(testanyware file exec "osascript -e 'tell application \"System Events\" to $1'" --timeout 3 --json)"
  echo "READ ${result}" >&2
  jq -er '.stdout | select(length > 0)' <<<"$result" | tr -d '\r'
}
observe() {
  echo "OBSERVE $1 $(date -u +%FT%TZ)"
  testanyware file exec /Users/admin/activation-snapshot --timeout 3 --json | tee ".build/menu-focus/$1-native.json"
  testanyware agent windows --json | tee ".build/menu-focus/$1-windows.json"
  sysevents 'get name of first process whose frontmost is true'
  sysevents 'get {name, value of attribute "AXMain", value of attribute "AXFocused"} of every window of process "Koine"' || true
  testanyware screen capture -o ".build/menu-focus/$1.png" --json
}
testanyware agent window-close --window 'Koine Settings' --json
await_windows 0
observe fresh-before
open_menu
menu_titles
testanyware screen capture -o .build/menu-focus/fresh-open-menu.png --json
frame="$(sysevents "get {position, size} of menu item \"Settings…\" of menu 1 of ${KOINE_ITEM}")"
echo "ONE SETTINGS ACTION $(date -u +%FT%TZ)"
click_centre "$frame"
observe fresh-after-before-keyboard
testanyware input type 'k6-fresh-witness' --json
testanyware agent snapshot --window Koine --mode full --depth 14 --json > .build/menu-focus/fresh-keyboard-koine.json
testanyware agent snapshot --window TextEdit --mode full --depth 8 --json > .build/menu-focus/fresh-keyboard-textedit.json
jq -c '..|objects|select(.id? == "grant-label")' .build/menu-focus/fresh-keyboard-koine.json
observe fresh-after-keyboard
