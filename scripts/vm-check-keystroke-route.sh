#!/bin/bash
# shellcheck disable=SC2016  # guest-side $HOME
# Probes route A for app input (keystroke-route-k2) in a clean clone of the
# prepared launcher image (task launchers:prepare), never on the host. Route A
# sends a chord into the target's own event stream with CGEventPostToPid.
#
# Fixtures/KeystrokeProbe builds each chord as Modaliser's KeystrokeEmitter
# builds it, and posts it either with CGEventPostToPid or at the HID event tap.
# Fixtures/KeyWitness records every key that reaches it. The window witness
# (Fixtures/WindowIdentityProbe) reads the front app, the on-screen windows and
# the events at a session-level tap. The run checks:
#
#   - Safari, Finder, Zed, Zotero and Obsidian each act on one chord from
#     Antony's Modaliser configuration while the app is in front.
#   - A Control-2 by route A switches no Space. At the HID event tap it does.
#   - A session-level keyboard tap does not see a route A chord.
#   - What reaches the front app when the shortcut is absent or disabled, and
#     when the Space does not exist.
#   - Whether a post without posting access delivers, and whether it raises a
#     consent dialog.
#
# Koine is not installed. The procedure and its recorded evidence:
# docs/verification/keystroke-route-vm.md
#
# Exit 0: every check passed. Exit 3: an app did not act on its route A chord.
# Then stop and ask Antony, and post no app chord at the HID event tap instead.
# Exit 4: the guest could not add or switch a Space, which is a harness limit.
# KOINE_LAUNCHERS_IMAGE is the prepared image (default koine-launchers-prepared).
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_NO_APP=1
# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="keystroke-route-"
# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_BASE="${KOINE_LAUNCHERS_IMAGE:-koine-launchers-prepared}"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

BUILT="$(Fixtures/KeystrokeProbe/build.sh .build/keystroke-probe)"
PROBE="$(sed -n 1p <<<"${BUILT}")"
WITNESS_APP="$(Fixtures/KeyWitness/build.sh .build/keystroke-probe)"
WINDOWS="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"
# The source user data of the probe's events (probeTag in its main.swift).
TAG=21202244876653122
WLOG='$HOME/keywitness.jsonl'
SETTINGS=/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings
ROUTE_A_FAILED=()

# probe_once <name> <arguments>: runs the agent-started probe at most once.
# `guest` repeats a command that the agent reports as timed out, and a second
# chord would change the state under test. So the run takes a guard directory,
# and a repeat that finds it only prints the first answer.
probe_once() {
    local name="$1" answer
    shift
    answer="$(guest_json "mkdir \$HOME/$name.started 2>/dev/null && \$HOME/KeystrokeProbe $* > \$HOME/$name.json; cat \$HOME/$name.json")" ||
        fail "the probe printed no answer for $*"
    jq -e '.trusted and .postAccess and .posted' >/dev/null <<<"${answer}" || fail "the probe could not post $*: ${answer}"
    jq -c '{route, chord, pid, target, front: .frontBefore.name, time}' <<<"${answer}"
}
front_json() { guest_json '$HOME/WindowIdentityProbe focused' | jq -c '.application'; }
# bring_front <name> <guest command>: runs the command, then waits until the
# window witness names the app in front. Leaves its pid in FRONT_PID.
bring_front() {
    local app
    guest "$2" >/dev/null || true
    for _ in $(seq 1 20); do
        app="$(front_json 2>/dev/null || echo null)"
        if [ "$(jq -r '.name // ""' <<<"${app}")" = "$1" ]; then
            FRONT_PID="$(jq -r '.pid' <<<"${app}")"
            echo "front app: $1 (pid ${FRONT_PID})"
            return 0
        fi
        sleep 2
    done
    fail "$1 did not come to the front; front app: ${app}"
}
spaces_json() { guest_json '$HOME/KeystrokeProbe spaces'; }
# space_now: the current desktop and the desktop count, as SkyLight reports them.
space_now() { spaces_json | jq -r '.skylight.displays[0] | "\(.currentDesktop) \(.desktops)"'; }
show_spaces() {
    spaces_json | jq -c '{skylight: .skylight.displays, preferences: .preferences.displays, activeSpaceID: .skylight.activeSpaceID}'
}
show_shortcuts() { guest_json '$HOME/KeystrokeProbe shortcuts' | jq -c '.entries[0:3][]'; }
# set_shortcut <digit> <true|false>: writes the "Switch to Desktop N" entry as
# Control and the digit, and asks macOS to apply the setting.
set_shortcut() {
    local id=$((117 + $1)) code
    code="$(jq -r --arg d "$1" '{"1": 18, "2": 19, "3": 20}[$d]' <<<'{}')"
    guest "defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add ${id} '<dict><key>enabled</key><$2/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>${code}</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>' && ${SETTINGS} -u"
}
witness_clear() { guest ": > ${WLOG}"; }
# witness_events: the keys that reached the key witness, one compact array.
witness_events() {
    guest_text "cat ${WLOG}" | grep '^{' | jq -sc "[.[] | [.kind, .keycode, .flags, .active, (.sourceUserData == ${TAG})]]"
}
# expect_chord <keycode>: the whole Control chord reached the key witness from
# the probe, in Modaliser's order.
expect_chord() {
    local events
    events="$(witness_events)"
    echo "key witness: ${events}"
    jq -e --argjson k "$1" '. == [["flagsChanged",59,262144,true,true],["keyDown",$k,262144,true,true],["keyUp",$k,262144,true,true],["flagsChanged",59,0,true,true]]' \
        >/dev/null <<<"${events}" || fail "the key witness did not receive Control and key $1 in Modaliser's order"
}
# screen_count <text>: how often OCR finds the text on the guest screen.
screen_count() {
    local found
    for _ in 1 2 3; do
        found="$(testanyware screen find-text "$1" --json 2>/dev/null)" || true
        if jq -e '.ok == true' >/dev/null 2>&1 <<<"${found}"; then
            jq -r '.total' <<<"${found}"
            return 0
        fi
        sleep 2
    done
    fail "the screen could not be read for \"$1\""
}
# The first line of the dialog. With a long app name, "this Mac" wraps to the
# next line, and OCR reads each line apart.
DIALOG_PHRASE="would like to control"
# dialog_seen <label>: whether a consent dialog shows, with a screen capture.
dialog_seen() {
    sleep 3
    testanyware screen capture -o "${LOG%.log}-$1.png" >/dev/null 2>&1 || true
    [ "$(screen_count "${DIALOG_PHRASE}")" != 0 ]
}
deny_dialog() {
    local found
    found="$(testanyware screen find-text "Deny" --json | jq -c '[.detections[] | select(.text == "Deny")][0]')"
    [ "${found}" != null ] || fail "the consent dialog has no Deny button"
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '"\(.x + .width / 2 | floor) \(.y + .height / 2 | floor)"' <<<"${found}") >/dev/null
    sleep 2
}
standard_windows() {
    guest_json "\$HOME/WindowIdentityProbe windows $1" | jq '[.windows[] | select(.subrole == "AXStandardWindow")] | length'
}
on_screen_windows() { guest_json "\$HOME/WindowIdentityProbe stack $1" | jq --argjson p "$1" '[.entries[] | select(.pid == $p and .layer == 0)] | length'; }
# route_a <app> <result of the witness check>: records a failure, and the run goes on.
route_a() {
    if [ "$2" = acted ]; then
        echo "ROUTE A: $1 acted on its chord"
    else
        echo "ROUTE A FAILED: $1 did not act on its chord"
        ROUTE_A_FAILED+=("$1")
    fi
    testanyware screen capture -o "${LOG%.log}-$1.png" >/dev/null 2>&1 || true
}

start_vm
for file in "${PROBE}" "${WINDOWS}"; do
    testanyware file upload "${file}" "/Users/admin/$(basename "${file}")" >/dev/null
done
for app in KeystrokeProbe KeystrokeProbeControl; do
    ditto -c -k --keepParent ".build/keystroke-probe/${app}.app" "${WORK}/${app}.zip"
    testanyware file upload "${WORK}/${app}.zip" "/Users/admin/${app}.zip" >/dev/null
done
ditto -c -k --keepParent "${WITNESS_APP}" "${WORK}/KeyWitness.zip"
testanyware file upload "${WORK}/KeyWitness.zip" /Users/admin/KeyWitness.zip >/dev/null
guest 'cd $HOME && chmod +x KeystrokeProbe WindowIdentityProbe && for z in KeystrokeProbe KeystrokeProbeControl KeyWitness; do ditto -x -k $z.zip .; done; ls -d *.app'

step "Start state"
show_spaces
show_shortcuts

step "Add a second Space in Mission Control"
# The Spaces bar shows its add button at the top right of the screen. The run
# does not trust the click. The Space count that follows checks it.
read -r SCREEN_W _ <<<"$(testanyware screen size | tr 'x' ' ')"
guest 'open -a "Mission Control"' || true
sleep 2
testanyware input move "$((SCREEN_W / 2))" 5 >/dev/null
sleep 2
testanyware input click "$((SCREEN_W - 27))" 101 >/dev/null
sleep 2
testanyware input key escape >/dev/null
sleep 2
show_spaces
read -r CURRENT COUNT <<<"$(space_now)"
if [ "${COUNT}" != 2 ] || [ "${CURRENT}" != 1 ]; then
    echo "HARNESS LIMIT: the guest has ${COUNT} desktops, on desktop ${CURRENT}, after the click"
    exit 4
fi

step "Key witness in front"
bring_front "Key Witness" "open \$HOME/KeyWitness.app --args ${WLOG}"
WPID="${FRONT_PID}"

step "Control-2 at the HID event tap with no Desktop 2 entry"
witness_clear
probe_once hid-absent hid ctrl+2
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
echo "desktop ${CURRENT} of ${COUNT}"
[ "${CURRENT}" = 1 ] || fail "Control-2 switched the Space with no Desktop 2 entry"
expect_chord 19

step "Turn on Switch to Desktop 1 and Switch to Desktop 2"
set_shortcut 1 true
set_shortcut 2 true
show_shortcuts
guest_json '$HOME/KeystrokeProbe shortcuts' | jq -e '[.entries[0:2][] | .enabled and .controlDigit] == [true, true]' >/dev/null ||
    fail "the Desktop 1 and Desktop 2 entries do not read as enabled Control-digit shortcuts"

step "Control-2 by route A to the key witness"
witness_clear
probe_once pid-control-2 send "${WPID}" ctrl+2
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
echo "desktop ${CURRENT} of ${COUNT}"
[ "${CURRENT}" = 1 ] || fail "Control-2 by route A switched the Space"
expect_chord 19

step "Control-2 at the HID event tap"
before="$(on_screen_windows "${WPID}")"
witness_clear
probe_once hid-control-2 hid ctrl+2
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
after="$(on_screen_windows "${WPID}")"
echo "desktop ${CURRENT} of ${COUNT}; key witness windows on screen: ${before} -> ${after}"
echo "front app: $(front_json)"
echo "key witness: $(witness_events)"
if [ "${CURRENT}" != 2 ]; then
    echo "HARNESS LIMIT: Control-2 at the HID event tap did not switch to Space 2"
    exit 4
fi
[ "${before}" -ge 1 ] && [ "${after}" = 0 ] || fail "the key witness window did not leave the screen"
witness_events | jq -e 'map(select(.[0] != "flagsChanged")) == []' >/dev/null ||
    fail "a key other than Control reached the key witness"

step "Control-1 at the HID event tap"
probe_once hid-control-1 hid ctrl+1
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
echo "desktop ${CURRENT} of ${COUNT}"
[ "${CURRENT}" = 1 ] || fail "Control-1 did not return to Space 1"
bring_front "Key Witness" "open \$HOME/KeyWitness.app"

step "A keyboard tap at the session level"
# The tap listens for 25 seconds. The agent can delay or repeat a command, so
# the posts wait until the tap process runs. The log prints when the tap began
# beside the time of each post. Route A sends Control-Shift-K (key 40) to the
# key witness, and then the HID event tap gets Control-Shift-J (key 38).
witness_clear
guest 'mkdir $HOME/tap.started 2>/dev/null || exit 0; nohup $HOME/WindowIdentityProbe events 25 > $HOME/tap.json 2>&1 &'
tap_running=''
for _ in $(seq 1 15); do
    if guest 'pgrep -f "WindowIdentityProbe events" >/dev/null' >/dev/null 2>&1; then
        tap_running=1
        break
    fi
    sleep 1
done
[ -n "${tap_running}" ] || fail "the session tap process did not start"
sleep 2
probe_once tap-pid send "${WPID}" ctrl+shift+k
sleep 1
probe_once tap-hid hid ctrl+shift+j
TAP=''
for _ in $(seq 1 20); do
    TAP="$(guest_json 'cat $HOME/tap.json' 2>/dev/null)" && break
    sleep 2
done
[ -n "${TAP}" ] || fail "the session tap printed no answer"
TAP_KEYS="$(jq -c '[.events[] | select(.kind != "mouseMoved") | [.kind, .keycode]]' <<<"${TAP}")"
echo "tap: $(jq -c '{tap, trusted, began, seconds}' <<<"${TAP}") ${TAP_KEYS}"
echo "key witness: $(witness_events)"
jq -e '.tap and .trusted' >/dev/null <<<"${TAP}" || fail "the session tap did not start"
jq -e 'any(.[]; . == ["keyDown", 38])' >/dev/null <<<"${TAP_KEYS}" || fail "the session tap missed the chord at the HID event tap"
jq -e 'map(select(.[1] == 40)) == []' >/dev/null <<<"${TAP_KEYS}" || fail "the session tap saw the route A chord"
witness_events | jq -e 'any(.[]; .[0] == "keyDown" and .[1] == 40) and any(.[]; .[0] == "keyDown" and .[1] == 38)' >/dev/null ||
    fail "the key witness did not receive both chords"

step "Control-2 at the HID event tap with Switch to Desktop 2 turned off"
set_shortcut 2 false
show_shortcuts
witness_clear
probe_once hid-disabled hid ctrl+2
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
echo "desktop ${CURRENT} of ${COUNT}"
[ "${CURRENT}" = 1 ] || fail "Control-2 switched the Space with its shortcut off"
expect_chord 19

step "Control-3 at the HID event tap with Switch to Desktop 3 on and no Space 3"
set_shortcut 3 true
show_shortcuts
witness_clear
probe_once hid-missing hid ctrl+3
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
echo "desktop ${CURRENT} of ${COUNT}"
[ "${CURRENT}" = 1 ] && [ "${COUNT}" = 2 ] || fail "Control-3 changed the Spaces"
expect_chord 20

step "Finder: New Window, Command-N"
bring_front Finder 'open -a Finder'
before="$(standard_windows "${FRONT_PID}")"
probe_once finder send "${FRONT_PID}" cmd+n
sleep 3
after="$(standard_windows "${FRONT_PID}")"
echo "Finder standard windows: ${before} -> ${after}"
if [ "${after}" -gt "${before}" ]; then route_a Finder acted; else route_a Finder none; fi

step "Safari: New Tab, Command-T"
bring_front Safari 'open -a Safari'
sleep 2
safari_tabs() {
    testanyware agent snapshot --mode full --window Safari --depth 25 --json |
        jq '[.. | objects | select(.platformRole == "AXRadioButton" and ((.id // "") | startswith("TabBarTab")))] | length'
}
before="$(safari_tabs)"
probe_once safari send "${FRONT_PID}" cmd+t
sleep 3
after="$(safari_tabs)"
echo "Safari tab elements: ${before} -> ${after}"
if [ "${after}" -ge 2 ] && [ "${after}" -gt "${before}" ]; then route_a Safari acted; else route_a Safari none; fi

step "Zed: Command Palette, Command-Shift-P"
# Zed exposes only its menu bar to Accessibility, so OCR reads the palette.
bring_front Zed 'open -a Zed'
sleep 4
before="$(screen_count "Execute a command")"
probe_once zed send "${FRONT_PID}" cmd+shift+p
sleep 3
after="$(screen_count "Execute a command")"
echo "\"Execute a command\" on screen: ${before} -> ${after}"
if [ "${before}" = 0 ] && [ "${after}" -ge 1 ]; then route_a Zed acted; else route_a Zed none; fi
testanyware input key escape >/dev/null

step "Zotero: Advanced Search, Command-Shift-F"
# Zotero 10 opens the search as a pane in its main window, so OCR reads it.
bring_front Zotero 'open -a Zotero'
sleep 6
before="$(screen_count "Advanced Search")"
probe_once zotero send "${FRONT_PID}" cmd+shift+f
sleep 4
after="$(screen_count "Advanced Search")"
echo "\"Advanced Search\" on screen: ${before} -> ${after}"
if [ "${before}" = 0 ] && [ "${after}" -ge 1 ]; then route_a Zotero acted; else route_a Zotero none; fi

step "Obsidian: New Note, Command-N"
# Obsidian stops at its vault chooser until it has a vault, so the run gives
# it one vault with one note. A new note is a new file in the vault.
guest 'mkdir -p $HOME/KoineVault && echo "# Welcome" > $HOME/KoineVault/Welcome.md && printf "{\"vaults\":{\"6b6f696e65766c74\":{\"path\":\"%s/KoineVault\",\"ts\":1795787000000,\"open\":true}}}" "$HOME" > "$HOME/Library/Application Support/obsidian/obsidian.json"'
bring_front Obsidian 'open -a Obsidian'
sleep 4
before="$(guest_text 'ls $HOME/KoineVault' | grep -c '\.md$' || true)"
probe_once obsidian send "${FRONT_PID}" cmd+n
sleep 3
listing="$(guest_text 'ls $HOME/KoineVault')"
after="$(grep -c '\.md$' <<<"${listing}" || true)"
echo "vault notes: ${before} -> ${after}: $(tr '\n' ' ' <<<"${listing}")"
if [ "${after}" -gt "${before}" ] && grep -q '^Untitled' <<<"${listing}"; then
    route_a Obsidian acted
else
    route_a Obsidian none
fi

step "Observation: Command-N by route A to Finder in the background"
bring_front "Key Witness" "open \$HOME/KeyWitness.app"
FINDER_PID="$(guest_text 'pgrep -x Finder' | grep -E '^[0-9]+$' | head -1)"
before="$(standard_windows "${FINDER_PID}")"
probe_once background send "${FINDER_PID}" cmd+n
sleep 3
after="$(standard_windows "${FINDER_PID}")"
echo "OBSERVED: Finder standard windows ${before} -> ${after}; front app afterwards: $(front_json)"

step "Posting without access, by route A"
# KeystrokeProbe.app is its own responsible process with no consent. It sends
# Control-Shift-L (key 37) to the key witness.
bring_front "Key Witness" "open \$HOME/KeyWitness.app"
witness_clear
guest 'mkdir $HOME/noaccess-pid.started 2>/dev/null || exit 0; open -g -W $HOME/KeystrokeProbe.app --args send '"${WPID}"' ctrl+shift+l --out $HOME/noaccess-pid.json'
echo "probe: $(guest_json 'cat $HOME/noaccess-pid.json' | jq -c '{route, trusted, postAccess, listenAccess, posted, front: .frontBefore.name}')"
if dialog_seen noaccess-pid; then
    echo "OBSERVED: a consent dialog appeared after the route A post"
    deny_dialog
else
    echo "OBSERVED: no consent dialog after the route A post"
fi
echo "key witness: $(witness_events)"

step "Posting without access, at the HID event tap"
# KeystrokeProbeControl.app has its own identifier and no consent. It posts
# Control-Shift-H (key 4) at the HID event tap.
bring_front "Key Witness" "open \$HOME/KeyWitness.app"
witness_clear
guest 'mkdir $HOME/noaccess-hid.started 2>/dev/null || exit 0; open -g -W $HOME/KeystrokeProbeControl.app --args hid ctrl+shift+h --out $HOME/noaccess-hid.json'
echo "probe: $(guest_json 'cat $HOME/noaccess-hid.json' | jq -c '{route, trusted, postAccess, listenAccess, posted, front: .frontBefore.name}')"
if dialog_seen noaccess-hid; then
    echo "OBSERVED: a consent dialog appeared after the HID post"
    deny_dialog
else
    echo "OBSERVED: no consent dialog after the HID post"
fi
echo "key witness: $(witness_events)"

step "Control: the key witness still receives a chord from the agent-started probe"
bring_front "Key Witness" "open \$HOME/KeyWitness.app"
witness_clear
probe_once witness-control send "${WPID}" ctrl+shift+l
sleep 1
echo "key witness: $(witness_events)"
witness_events | jq -e 'any(.[]; .[0] == "keyDown" and .[1] == 37)' >/dev/null || fail "the key witness received nothing"

step "Result"
if [ "${#ROUTE_A_FAILED[@]}" -gt 0 ]; then
    echo "RESULT: route A failed for ${ROUTE_A_FAILED[*]}. Stop and ask Antony. Do not post app chords at the HID event tap."
    exit 3
fi
echo "RESULT: every app acted on its route A chord, and every Space and tap check passed"
