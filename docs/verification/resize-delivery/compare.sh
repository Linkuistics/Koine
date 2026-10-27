#!/bin/bash
set -euo pipefail
inset="$1"
out="$PWD/docs/verification/resize-delivery/inset-${inset}"
mkdir -p "$out"
source scripts/signing-env.sh
APP_BUNDLE="$PWD/.build/menu-interaction/Koine.app"
KOINE_VM_ID="koine-k10-inset-${inset}"
KOINE_VM_BASE=testanyware-golden-macos-27
KOINE_VM_LOG_PREFIX="k10-inset-${inset}-"
source scripts/vm-verify-lib.sh
source scripts/vm-verify-desktop-lib.sh
start_vm
install_app
testanyware file upload docs/verification/window-resize/failure-observer-binary /Users/admin/k10-observer >/dev/null
guest 'chmod +x /Users/admin/k10-observer'
guest_once 'open /Applications/Koine.app'
await_windows 1
place_window
testanyware agent wait --window Koine --timeout 30 --json > "$out/ready.json"
echo 'SETUP COMPLETE: Koine launched, controls present, default geometry retained'
for app in Koine TextEdit; do
    if [ "$app" = Koine ]; then
        title='Koine Settings'
    else
        guest_once 'open -a TextEdit'
        testanyware agent wait --window TextEdit --timeout 30 --json > "$out/textedit-ready.json"
        sleep 8
        title=Untitled
        testanyware agent window-move --window 'Koine Settings' --x 1100 --y 40 --json > "$out/koine-clear.json"
        testanyware agent window-resize --window "$title" --width 480 --height 712 --json > "$out/textedit-initial-size.json"
    fi
    testanyware agent window-move --window "$title" --x 40 --y 40 --json > "$out/$app-place.json"
    testanyware agent window-focus --window "$title" --json > "$out/$app-focus.json"
    sleep 1
    testanyware agent windows --json > "$out/$app-before.json"
    jq -e --arg app "$app" --arg title "$title" '.windows[0] | .appName == $app and .title == $title and .focused == true and .positionX == 40 and .positionY == 40 and .sizeWidth == 480 and .sizeHeight == 712' "$out/$app-before.json" >/dev/null
    testanyware file exec /Users/admin/k10-observer --timeout 3 --json > "$out/$app-native-before.json"
    jq -e --arg app "$app" '.stdout | fromjson | .front == $app and any(.apps[]; .name == $app and .active == true)' "$out/$app-native-before.json" >/dev/null
    x=$((520 - inset)) y=$((752 - inset))
    echo "TRIAL $app inset=$inset from=$x,$y to=740,940 steps=100 preparation=0.5s post=1s $(date -u +%FT%TZ)"
    testanyware input move "$x" "$y" --json > "$out/$app-move.json"
    sleep 0.5
    testanyware input drag "$x" "$y" 740 940 --steps 100 --json > "$out/$app-drag.json"
    sleep 1
    testanyware agent windows --json > "$out/$app-after.json"
    testanyware file exec /Users/admin/k10-observer --timeout 3 --json > "$out/$app-native-after.json"
    testanyware screen capture -o "$out/$app-after.png" --json > "$out/$app-capture.json"
    jq -c --arg app "$app" '.windows[] | select(.appName == $app)' "$out/$app-after.json"
done
