#!/bin/bash
# shellcheck disable=SC2016  # guest-side $HOME
# The V seam of app input (Koine 0.7.0, input 1.0.0), on the signed Koine.app in
# ONE clean clone of the prepared launcher image (task launchers:prepare), which
# holds Zed, Zotero and Obsidian past their first runs.
#
#   - The Settings window shows the served input disclosures for a new grant, a
#     grant request and the grant list, and again for the existing grants after
#     a restart.
#   - Under input control, Koine sends every row of Antony's Modaliser screens
#     for Finder (16) and Safari (5), and one row each for Zed, Zotero and
#     Obsidian, to the app in front. Each row has its own witness.
#   - With TextEdit in front, Koine sends New Tab to Safari in the background.
#     Safari opens the tab, and TextEdit keeps its text.
#   - A Control-2 through the keystroke operation switches no Space. The Space
#     switch reaches Desktop 2 with the shortcut on, and it refuses with the
#     shortcut off.
#   - No permission dialog appears.
#
# Koine never witnesses its own sends. Each effect is read by a tool that shares
# no code with Koine: Fixtures/WindowIdentityProbe (the front app and the
# windows of an app), AppleScript to Finder and Safari, the TestAnyware agent's
# accessibility snapshot, OCR of the guest screen and the files of a folder.
# Fixtures/KeystrokeProbe reads the Space shortcuts and counts the Spaces, and
# it posts nothing in this run. Every operation is sent with the text of
# docs/design/input-operations.graphql. Nothing here runs the application or
# sends a chord on the host. The procedure and its recorded evidence:
# docs/verification/app-input-vm.md
#
# Exit 0: every check passed. Exit 3: an app did not act on a row's chord
# (route A has no fallback, so stop and ask Antony). Exit 1: any other failure.
# KOINE_LAUNCHERS_IMAGE is the prepared image (default koine-launchers-prepared).
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="app-input-"
# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_BASE="${KOINE_LAUNCHERS_IMAGE:-koine-launchers-prepared}"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

WINDOWS="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"
SPACES="$(Fixtures/KeystrokeProbe/build.sh .build/keystroke-probe | sed -n 1p)"
OPERATIONS='$HOME/input-operations.graphql'
REQUESTER='$HOME/koine-secret-input-requester'
CONTROLLER_FILE='$HOME/koine-input-controller'
SETTINGS=/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings
ROWS_FAILED=()

# What the served input disclosures must state (docs/specs/machine.md, "Capability disclosures").
CONTROL_PHRASES=("Sends a chord, one key with modifier keys such as Command-L" "a chord sent to a terminal can type and run commands"
    "answer a consent, password or security prompt" "Koine never brings an app to the front, and it never sends a chord to itself"
    "An app in the background can ignore a chord, act on a window behind other apps, or come to the front"
    "No other app receives the chord" "With desktop:control too, it switches to Mission Control desktop 1 to 9"
    "can change in the instant before macOS reads the chord")
READ_PHRASES=("Reads which app is the front app" "It reads no window titles and no window contents, and it sends no keys"
    "Sending a chord needs input:control")

no_errors() { expect '(.response.errors // []) | length == 0' "$1 reported errors"; }
# input_client <credential file> <case> [argument...]: one guest client call, for a read
# that can be repeated; its one JSON line is left in ANSWER.
input_client() {
    local file="$1"
    shift
    ANSWER="$(guest_json "python3 \$HOME/vm-verify-app-input-client.py \"${file}\" \"${OPERATIONS}\" $*")" ||
        fail "the app input client printed no JSON for: $*"
    echo "${ANSWER}"
}
# once <name> <client case> [argument...]: under the controlling grant, one operation
# that must run exactly once. `guest` repeats a command that the agent reports as
# timed out, and a second chord changes the state under test. So the call takes a
# guard directory, and a repeat only prints the first answer.
once() {
    local name="$1"
    shift
    ANSWER="$(guest_json "mkdir \$HOME/${name}.started 2>/dev/null && python3 \$HOME/vm-verify-app-input-client.py \"${CONTROLLER_FILE}\" \"${OPERATIONS}\" $* > \$HOME/${name}.json; cat \$HOME/${name}.json")" ||
        fail "the app input client printed no JSON for ${name}"
    echo "${ANSWER}"
}
# send <name> <reference> <chord>: one chord, which Koine must report as SENT.
send() {
    once "$1" send "'$2'" "'$3'"
    expect '((.response.errors // []) | length == 0) and (.response.data.inputSendKeystroke == {outcome: "SENT"})' \
        "$1: Koine did not report SENT for $3"
}
# row <app> <row> <before> <after> <acted>: records the witness's reading; a row
# whose app did not act fails the run at the end with exit 3.
row() {
    if [ "$5" = 1 ]; then
        echo "ROW PASSED: $1, $2: the witness read ${3} -> ${4}"
    else
        echo "ROW FAILED: $1, $2: the witness read ${3} -> ${4}"
        ROWS_FAILED+=("$1: $2")
    fi
}
front_json() { guest_json '$HOME/WindowIdentityProbe focused' | jq -c '.application'; }
front_name() { front_json | jq -r '.name // "none"'; }
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
# capture_front <name> <bundle identifier>: target capture under input:read. The front
# target must be the app that the window witness names, with that pid in its reference.
capture_front() {
    input_client "${CREDENTIAL_FILE}" front
    no_errors "InputFrontTarget"
    expect ".response.data.inputFrontTarget | .name == \"$1\" and .bundleIdentifier == \"$2\" and .protection == \"ADDRESSABLE\" and (.ref | startswith(\"koine://input/target/${FRONT_PID}/\"))" \
        "the front target is not $1 with pid ${FRONT_PID}"
    TARGET="$(jq -r '.response.data.inputFrontTarget.ref' <<<"${ANSWER}")"
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
capture() { testanyware screen capture -o "${LOG%.log}-$1.png" >/dev/null 2>&1 || true; }
# try_click_text <text> <seconds>: clicks the centre of the first detection that is
# exactly this text, and fails as a command, not as the run, when there is none.
try_click_text() {
    local found
    found="$(testanyware screen find-text "$1" --timeout "$2" --json 2>/dev/null |
        jq -c --arg t "$1" '[.detections[] | select(.text == $t)][0]')" || true
    [ -n "${found}" ] && [ "${found}" != null ] || return 1
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '"\(.x + .width / 2 | floor) \(.y + .height / 2 | floor)"' <<<"${found}") >/dev/null
}
# allow_automation <app>: the first Apple event from the agent to the app raises a macOS
# Automation prompt that names testanyware-agent, which runs the witnesses. It is
# answered as a user would. Koine is not involved. AppleScript answers the name of an
# application itself, without an Apple event, so the query asks for its windows. OCR
# cannot find the button: with the prompt on screen, Vision read three garbled words
# from the whole screen. So the button comes from the prompt's accessibility snapshot
# (its window is UserNotificationCenter's "alert"), and the app's own answer proves
# the consent.
allow_automation() {
    local button=null
    guest "mkdir \$HOME/automation-$1.started 2>/dev/null || exit 0; nohup osascript -e 'tell application \"$1\" to get count of windows' > \$HOME/automation-$1.txt 2>&1 &" || true
    for _ in $(seq 1 15); do
        button="$(testanyware agent snapshot --mode full --window alert --depth 10 --json 2>/dev/null |
            jq -c '[.. | objects | select(.platformRole == "AXButton" and .label == "Allow")][0]' 2>/dev/null || echo null)"
        [ -n "${button}" ] && [ "${button}" != null ] && break
        sleep 2
    done
    [ -n "${button}" ] && [ "${button}" != null ] || fail "no Automation prompt for $1"
    # shellcheck disable=SC2046  # two coordinates
    testanyware input click $(jq -r '"\(.positionX + .sizeWidth / 2 | floor) \(.positionY + .sizeHeight / 2 | floor)"' <<<"${button}") >/dev/null
    for _ in $(seq 1 15); do
        guest_text "cat \$HOME/automation-$1.txt" | grep -qE '^[0-9]+$' && return 0
        sleep 2
    done
    fail "the witnesses cannot ask $1 for its state: $(guest_text "cat \$HOME/automation-$1.txt")"
}
# No consent dialog of any kind names Koine: Accessibility's says "would like to
# control", and the Screen Recording dialog says "would like to record".
# OCR reads nothing true when Vision misreads the screen, and an absent phrase then
# reads clean. So the menu bar's "Help" must be found first, on the same screen.
no_dialog() {
    [ "$(screen_count Help)" -ge 1 ] || fail "OCR cannot read the screen, so it cannot show that no dialog is there: $1"
    no_consent_dialog "$1"
    [ "$(screen_count "would like to")" = 0 ] || fail "a permission dialog is showing: $1"
}
# disclosure_of <element id>: the one disclosure text the window shows there,
# whitespace collapsed, after proving the element is on screen.
disclosure_of() {
    reveal ".id==\"$1\""
    element ".id==\"$1\"" | jq -r --arg id "$1" '[.. | strings] | map(select(length > 40 and . != $id)) | first // empty' | tr -s '[:space:]' ' ' | sed 's/ $//'
}
# expect_served <element id> <what> <capability>: on screen, in the words that
# koine:manage clients are served, naming the reach that the contract requires.
expect_served() {
    local shown served phrases
    served="$(jq -r --arg c "$3" '.response.data.koineManagement.capabilityDisclosures[] | select(.capability == $c) | .disclosure' <<<"${DISCLOSURES}" | tr -s '[:space:]' ' ' | sed 's/ $//')"
    shown="$(disclosure_of "$1")"
    echo "$2: ${shown}"
    [ -n "${served}" ] && [ "${shown}" = "${served}" ] || fail "$2 is not the served $3 disclosure"
    if [ "$3" = input:control ]; then phrases=("${CONTROL_PHRASES[@]}"); else phrases=("${READ_PHRASES[@]}"); fi
    for phrase in "${phrases[@]}"; do
        grep -qF -- "${phrase}" <<<"${shown}" || fail "$2 does not state: ${phrase}"
    done
}

# Spaces, read by the keystroke probe, which posts nothing here.
space_now() { guest_json '$HOME/KeystrokeProbe spaces' | jq -r '.skylight.displays[0] | "\(.currentDesktop) \(.desktops)"'; }
# set_shortcut <digit> <true|false>: writes the "Switch to Desktop N" entry as
# Control and the digit, and asks macOS to apply the setting.
set_shortcut() {
    local id=$((117 + $1)) code=$((17 + $1))
    guest "defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add ${id} '<dict><key>enabled</key><$2/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>${code}</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>' && ${SETTINGS} -u"
}
show_shortcuts() { guest_json '$HOME/KeystrokeProbe shortcuts' | jq -c '.entries[0:2][]'; }

# The witnesses of Finder and Safari.
finder() { guest_text "osascript -e 'tell application \"Finder\" to get $1'" | tail -1; }
finder_titles() {
    guest_json "\$HOME/WindowIdentityProbe windows ${FINDER_PID}" | jq -c '[.windows[] | select(.role == "AXWindow") | .title]'
}
go_to_sheets() {
    testanyware agent snapshot --mode full --window KoineFinder --depth 20 --json | jq '[.. | objects | select(.id == "GoToWindow")] | length'
}
safari() { guest_text "osascript -e 'tell application \"Safari\" to get $1'" | tail -1; }
safari_snapshot() { testanyware agent snapshot --mode full --window Safari --depth 25 --json; }
address_focused() { safari_snapshot | jq -r '[.. | objects | select(.id == "WEB_BROWSER_ADDRESS_AND_SEARCH_FIELD") | .focused][0]'; }
find_banners() { safari_snapshot | jq '[.. | objects | select(.id == "FindBanner")] | length'; }
textedit_text() {
    testanyware agent snapshot --mode full --window front.txt --depth 12 --json | jq -c '[.. | objects | select(.platformRole == "AXTextArea") | .value]'
}
# finder_row <row> <chord> <witness command> <expected after>: the witness reads the
# command before and after; the row passes when the reading becomes the expected one.
finder_row() {
    local before after
    before="$(eval "$3")"
    send "finder-$(tr -c 'a-zA-Z0-9\n' '-' <<<"$1")" "${TARGET}" "$2"
    sleep 2
    after="$(eval "$3")"
    if [ "${after}" = "$4" ] && [ "${before}" != "$4" ]; then row Finder "$1" "${before}" "${after}" 1; else row Finder "$1" "${before}" "${after}" 0; fi
}

start_vm
install_app
testanyware file upload scripts/vm-verify-app-input-client.py /Users/admin/vm-verify-app-input-client.py >/dev/null
testanyware file upload scripts/vm-verify-enrollment-client.py /Users/admin/vm-verify-enrollment-client.py >/dev/null
testanyware file upload docs/design/input-operations.graphql /Users/admin/input-operations.graphql >/dev/null
testanyware file upload "${WINDOWS}" /Users/admin/WindowIdentityProbe >/dev/null
testanyware file upload "${SPACES}" /Users/admin/KeystrokeProbe >/dev/null
guest 'chmod +x $HOME/WindowIdentityProbe $HOME/KeystrokeProbe'
guest 'mkdir -p $HOME/KoineFinder && touch $HOME/KoineFinder/visible.txt $HOME/KoineFinder/.koine-hidden'
guest 'printf "<html><head><title>Koine Page</title></head><body><h1>Koine input page</h1><p>The word koala appears here.</p></body></html>" > $HOME/koine-page.html'
guest 'echo "TextEdit stays unchanged" > $HOME/front.txt'

step "Prepare two Spaces, with Switch to Desktop 1 and Switch to Desktop 2 on"
# The Spaces bar shows its add button at the top right of the screen. The run does
# not trust the click. The Space count that follows checks it.
read -r SCREEN_W _ <<<"$(testanyware screen size | tr 'x' ' ')"
guest 'open -a "Mission Control"' || true
sleep 2
testanyware input move "$((SCREEN_W / 2))" 5 >/dev/null
sleep 2
testanyware input click "$((SCREEN_W - 27))" 101 >/dev/null
sleep 2
testanyware input key escape >/dev/null
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
echo "desktop ${CURRENT} of ${COUNT}"
[ "${COUNT}" = 2 ] && [ "${CURRENT}" = 1 ] || fail "the guest has ${COUNT} desktops, on desktop ${CURRENT}, after the click"
set_shortcut 1 true
set_shortcut 2 true
show_shortcuts
guest_json '$HOME/KeystrokeProbe shortcuts' | jq -e '[.entries[0:2][] | .enabled and .controlDigit] == [true, true]' >/dev/null ||
    fail "the Desktop 1 and Desktop 2 entries do not read as enabled Control-digit shortcuts"

step "Launch Koine and create a reading grant in the window"
launch
create_grant "vm-input-reader" "${CREDENTIAL_FILE}" koine:manage input:read

step "The served input disclosures state the reach of app input"
input_client "${CREDENTIAL_FILE}" disclosures
no_errors "capabilityDisclosures"
expect '.response.data.koineManagement.capabilityDisclosures | map(.capability) | sort == ["desktop:control","desktop:read","input:control","input:read","workspace:control","workspace:read"]' \
    "the served disclosures are not the two desktop, two input and two workspace ones"
DISCLOSURES="${ANSWER}"

step "The create-grant view: a new grant shows both input disclosures"
expect_served "disclosure-input:read" "the create-grant view, for input read" input:read
expect_served "disclosure-input:control" "the create-grant view, for input control" input:control
capture create-grant
create_grant "vm-input-controller" "${CONTROLLER_FILE}" input:control desktop:control

step "The request view: a pending request for input read and input control shows both disclosures"
ANSWER="$(guest_json "python3 \$HOME/vm-verify-enrollment-client.py \"${REQUESTER}\" enrol input-requester input:read input:control")" ||
    fail "the enrollment client printed no JSON"
echo "${ANSWER}"
expect '.status == 200 and ((.response.errors // []) | length == 0)' "enrollment was refused"
REQUEST_ID="$(jq -r .response.data.koineRequestGrant.requestId <<<"${ANSWER}")"
await_element ".id==\"request-${REQUEST_ID}\"" present
expect_served "request-disclosure-${REQUEST_ID}-input:read" "the request view, for input read" input:read
expect_served "request-disclosure-${REQUEST_ID}-input:control" "the request view, for input control" input:control
capture request-view
reveal_click ".id==\"approve-${REQUEST_ID}\""
await_element ".id==\"request-${REQUEST_ID}\"" absent

step "The grant list: each grant shows the disclosure of each input capability it holds"
input_client "${CREDENTIAL_FILE}" grants
no_errors "koineManagement.grants"
GRANTS_BEFORE="$(jq -c '.response.data.koineManagement.grants' <<<"${ANSWER}")"
grant_id() { jq -r --arg l "$1" 'map(select(.clientLabel == $l))[0].grantId' <<<"${GRANTS_BEFORE}"; }
READER_GRANT="$(grant_id vm-input-reader)"
CONTROLLER_GRANT="$(grant_id vm-input-controller)"
REQUESTER_GRANT="$(grant_id input-requester)"
jq -e 'map(select(.clientLabel == "input-requester"))[0] | .state == "ACTIVE" and (.capabilities | sort) == ["input:control","input:read"]' >/dev/null <<<"${GRANTS_BEFORE}" ||
    fail "the approved grant is not input:read and input:control"
expect_served "grant-disclosure-${READER_GRANT}-input:read" "the reading grant's row" input:read
expect_served "grant-disclosure-${CONTROLLER_GRANT}-input:control" "the controlling grant's row" input:control
expect_served "grant-disclosure-${REQUESTER_GRANT}-input:read" "the approved grant's row, for input read" input:read
expect_served "grant-disclosure-${REQUESTER_GRANT}-input:control" "the approved grant's row, for input control" input:control
capture grant-list

step "Give Koine Accessibility consent in System Settings"
grant_accessibility

step "Allow the witnesses to ask Finder and Safari for their state"
allow_automation Finder
allow_automation Safari
guest 'osascript -e "tell application \"Safari\" to close every window"' || true
# With the dense text of Koine's Settings window on screen, Vision misread whole
# screens, so OCR witnesses read nothing. Cropped without that window, the same
# capture read in full. The window closes here, and the restart opens it again.
testanyware agent window-close --window "${WINDOW_TITLE}" >/dev/null
sleep 2
no_dialog "before the chords"

step "Finder: every row of Antony's Finder screen, with Finder in front"
bring_front Finder 'open $HOME/KoineFinder'
FINDER_PID="${FRONT_PID}"
guest 'osascript -e "tell application \"Finder\" to set current view of front Finder window to icon view"' || true
capture_front Finder com.apple.finder
[ "$(finder 'name of front Finder window')" = KoineFinder ] || fail "the front Finder window is not KoineFinder"
finder_row "View: List, Command-2" cmd+2 "finder 'current view of front Finder window'" "list view"
finder_row "View: Column, Command-3" cmd+3 "finder 'current view of front Finder window'" "column view"
finder_row "View: Gallery, Command-4" cmd+4 "finder 'current view of front Finder window'" "flow view"
finder_row "View: Icon, Command-1" cmd+1 "finder 'current view of front Finder window'" "icon view"
# OCR reads the name of the hidden file without its leading dot.
finder_row "Toggle Hidden, Command-Shift-Period" cmd+shift+. "screen_count koine-hidden" 1
finder_row "New Folder, Command-Shift-N" cmd+shift+n "guest_text 'ls \$HOME/KoineFinder' | grep -c '^untitled folder\$' || true" 1
testanyware input key return >/dev/null
sleep 1
finder_row "Get Info, Command-I" cmd+i "finder_titles | jq '[.[] | select(. != null and endswith(\" Info\"))] | length'" 1
testanyware input key w --modifiers cmd >/dev/null
sleep 2
[ "$(finder_titles | jq '[.[] | select(. != null and endswith(" Info"))] | length')" = 0 ] || fail "the Info window did not close"
# The panel shows the last path that Finder went to, so its placeholder can be absent.
# The snapshot shows the panel as the sheet GoToWindow of the window.
finder_row "Go to Folder, Command-Shift-G" cmd+shift+g go_to_sheets 1
testanyware input key escape >/dev/null
sleep 2
[ "$(go_to_sheets)" = 0 ] || fail "the Go to Folder panel did not close"
finder_row "Connect to Server, Command-K" cmd+k "finder_titles | jq '[.[] | select(. == \"Connect to Server\")] | length'" 1
testanyware input key w --modifiers cmd >/dev/null
sleep 2
[ "$(finder_titles | jq '[.[] | select(. == "Connect to Server")] | length')" = 0 ] || fail "the Connect to Server window did not close"
[ "$(finder 'name of front Finder window')" = KoineFinder ] || fail "the KoineFinder window is not in front of Finder again"
COMPUTER="$(guest_text 'scutil --get ComputerName' | tail -1)"
finder_row "Go: Home, Command-Shift-H" cmd+shift+h "finder 'name of front Finder window'" admin
finder_row "Go: Applications, Command-Shift-A" cmd+shift+a "finder 'name of front Finder window'" Applications
finder_row "Go: Desktop, Command-Shift-D" cmd+shift+d "finder 'name of front Finder window'" Desktop
finder_row "Go: Downloads, Command-Option-L" cmd+alt+l "finder 'name of front Finder window'" Downloads
finder_row "Go: Recents, Command-Shift-F" cmd+shift+f "finder 'name of front Finder window'" Recents
finder_row "Go: Computer, Command-Shift-C" cmd+shift+c "finder 'name of front Finder window'" "${COMPUTER}"
WINDOWS_BEFORE="$(finder 'count of Finder windows')"
finder_row "New Window, Command-N" cmd+n "finder 'count of Finder windows'" "$((WINDOWS_BEFORE + 1))"
capture Finder

step "Safari: every row of Antony's Safari screen, with Safari in front"
bring_front Safari 'open -a Safari $HOME/koine-page.html'
SAFARI_PID="${FRONT_PID}"
sleep 3
capture_front Safari com.apple.Safari
SAFARI_TARGET="${TARGET}"
[ "$(safari 'URL of current tab of front window')" = "file:///Users/admin/koine-page.html" ] || fail "Safari does not show the page"
before="$(find_banners)"
send safari-find "${TARGET}" cmd+f
sleep 2
after="$(find_banners)"
if [ "${before}" = 0 ] && [ "${after}" = 1 ]; then row Safari "Find on Page, Command-F" "${before} find banners" "${after}" 1; else row Safari "Find on Page, Command-F" "${before} find banners" "${after}" 0; fi
before="$(address_focused)"
send safari-address "${TARGET}" cmd+l
sleep 2
after="$(address_focused)"
if [ "${before}" = false ] && [ "${after}" = true ]; then row Safari "Focus Address Bar, Command-L" "address field focused ${before}" "${after}" 1; else row Safari "Focus Address Bar, Command-L" "address field focused ${before}" "${after}" 0; fi
before="$(safari 'count of tabs of front window')"
send safari-new-tab "${TARGET}" cmd+t
sleep 2
after="$(safari 'count of tabs of front window')"
if [ "${after}" = $((before + 1)) ]; then row Safari "New Tab, Command-T" "${before} tabs" "${after}" 1; else row Safari "New Tab, Command-T" "${before} tabs" "${after}" 0; fi
before="${after}"
send safari-close-tab "${TARGET}" cmd+w
sleep 2
after="$(safari 'count of tabs of front window')"
if [ "${after}" = $((before - 1)) ]; then row Safari "Close Tab, Command-W" "${before} tabs" "${after}" 1; else row Safari "Close Tab, Command-W" "${before} tabs" "${after}" 0; fi
before="${after}"
send safari-reopen-tab "${TARGET}" cmd+shift+t
sleep 2
after="$(safari 'count of tabs of front window')"
if [ "${after}" = $((before + 1)) ]; then row Safari "Reopen Closed Tab, Command-Shift-T" "${before} tabs" "${after}" 1; else row Safari "Reopen Closed Tab, Command-Shift-T" "${before} tabs" "${after}" 0; fi
capture Safari

step "Zed: Command Palette, Command-Shift-P"
# Zed exposes only its menu bar to Accessibility, so OCR reads the palette.
bring_front Zed 'open -a Zed'
sleep 4
capture_front Zed dev.zed.Zed
before="$(screen_count "Execute a command")"
send zed-palette "${TARGET}" cmd+shift+p
sleep 3
after="$(screen_count "Execute a command")"
if [ "${before}" = 0 ] && [ "${after}" -ge 1 ]; then row Zed "Command Palette, Command-Shift-P" "\"Execute a command\" ${before}" "${after}" 1; else row Zed "Command Palette, Command-Shift-P" "\"Execute a command\" ${before}" "${after}" 0; fi
capture Zed
testanyware input key escape >/dev/null

step "Zotero: Advanced Search, Command-Shift-F"
# Zotero 10 opens the search as a pane in its main window, so OCR reads it.
bring_front Zotero 'open -a Zotero'
sleep 6
capture_front Zotero org.zotero.zotero
before="$(screen_count "Advanced Search")"
send zotero-search "${TARGET}" cmd+shift+f
sleep 4
after="$(screen_count "Advanced Search")"
if [ "${before}" = 0 ] && [ "${after}" -ge 1 ]; then row Zotero "Advanced Search, Command-Shift-F" "\"Advanced Search\" ${before}" "${after}" 1; else row Zotero "Advanced Search, Command-Shift-F" "\"Advanced Search\" ${before}" "${after}" 0; fi
capture Zotero

step "Obsidian: New Note, Command-N"
# Obsidian stops at its vault chooser until it has a vault, so the run gives it one
# vault with one note. A new note is a new file in the vault.
guest 'mkdir -p $HOME/KoineVault && echo "# Welcome" > $HOME/KoineVault/Welcome.md && printf "{\"vaults\":{\"6b6f696e65766c74\":{\"path\":\"%s/KoineVault\",\"ts\":1795787000000,\"open\":true}}}" "$HOME" > "$HOME/Library/Application Support/obsidian/obsidian.json"'
bring_front Obsidian 'open -a Obsidian'
sleep 4
capture_front Obsidian md.obsidian
before="$(guest_text 'ls $HOME/KoineVault' | grep -c '\.md$' || true)"
send obsidian-new-note "${TARGET}" cmd+n
sleep 3
listing="$(guest_text 'ls $HOME/KoineVault')"
after="$(grep -c '\.md$' <<<"${listing}" || true)"
if [ "${after}" -gt "${before}" ] && grep -q '^Untitled' <<<"${listing}"; then
    row Obsidian "New Note, Command-N" "${before} notes" "${after}: $(tr '\n' ' ' <<<"${listing}")" 1
else
    row Obsidian "New Note, Command-N" "${before} notes" "${after}: $(tr '\n' ' ' <<<"${listing}")" 0
fi
capture Obsidian

step "A background target: with TextEdit in front, Koine sends New Tab to Safari"
bring_front TextEdit 'open -a TextEdit $HOME/front.txt'
TEXT_BEFORE="$(textedit_text)"
echo "TextEdit text: ${TEXT_BEFORE}"
[ "${TEXT_BEFORE}" = '["TextEdit stays unchanged\n"]' ] || fail "TextEdit does not show its document"
before="$(safari 'count of tabs of front window')"
send safari-background "${SAFARI_TARGET}" cmd+t
sleep 3
after="$(safari 'count of tabs of front window')"
TEXT_AFTER="$(textedit_text)"
echo "Safari tabs: ${before} -> ${after}; TextEdit text: ${TEXT_AFTER}; front app afterwards: $(front_json)"
if [ "${after}" = $((before + 1)) ]; then row "Safari in the background" "New Tab, Command-T" "${before} tabs" "${after}" 1; else row "Safari in the background" "New Tab, Command-T" "${before} tabs" "${after}" 0; fi
[ "${TEXT_AFTER}" = "${TEXT_BEFORE}" ] || fail "TextEdit's text changed: ${TEXT_AFTER}"
guest "kill -0 ${SAFARI_PID}" || fail "Safari is not the process that Koine captured"
capture background

step "Control-2 through the keystroke operation switches no Space"
bring_front TextEdit 'open -a TextEdit $HOME/front.txt'
capture_front TextEdit com.apple.TextEdit
send textedit-control-2 "${TARGET}" ctrl+2
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
echo "desktop ${CURRENT} of ${COUNT}; TextEdit text: $(textedit_text)"
[ "${CURRENT}" = 1 ] || fail "Control-2 through the keystroke operation switched the Space"

step "The Space switch reaches Desktop 2 with the shortcut on, and Desktop 1 again"
[ "$(front_name)" = TextEdit ] || fail "TextEdit is not in front for the Space switch"
once switch-2 switch 2
expect '((.response.errors // []) | length == 0) and (.response.data.inputSwitchSpace == {outcome: "POSTED"})' "the switch to Desktop 2 did not report POSTED"
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
echo "desktop ${CURRENT} of ${COUNT}; front app: $(front_json)"
[ "${CURRENT}" = 2 ] || fail "the Space switch did not reach Desktop 2"
capture desktop-2
once switch-1 switch 1
expect '((.response.errors // []) | length == 0) and (.response.data.inputSwitchSpace == {outcome: "POSTED"})' "the switch to Desktop 1 did not report POSTED"
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
echo "desktop ${CURRENT} of ${COUNT}; front app: $(front_json)"
[ "${CURRENT}" = 1 ] || fail "the Space switch did not return to Desktop 1"

step "The Space switch refuses with Switch to Desktop 2 turned off"
set_shortcut 2 false
show_shortcuts
bring_front TextEdit 'open -a TextEdit $HOME/front.txt'
once switch-off switch 2
expect '((.response.errors // []) | length == 0) and (.response.data.inputSwitchSpace == {outcome: "SHORTCUT_OFF"})' "the switch with the shortcut off did not report SHORTCUT_OFF"
sleep 2
read -r CURRENT COUNT <<<"$(space_now)"
echo "desktop ${CURRENT} of ${COUNT}; TextEdit text: $(textedit_text)"
[ "${CURRENT}" = 1 ] || fail "the refused switch changed the Space"
no_dialog "after the chords and the Space switches"

step "Quit and restart Koine: the existing grants keep their disclosures, and nothing was revoked or reauthorised"
# The test apps go first, so that Koine's window can come to the front for Command-Q.
guest 'pkill -x Safari; pkill -x TextEdit; pkill -x zed; pkill -x Zed; pkill -x zotero; pkill -x Zotero; pkill -x Obsidian; true' || true
sleep 2
quit_koine
launch
input_client "${CREDENTIAL_FILE}" grants
no_errors "koineManagement.grants"
GRANTS_AFTER="$(jq -c '.response.data.koineManagement.grants' <<<"${ANSWER}")"
[ "${GRANTS_BEFORE}" = "${GRANTS_AFTER}" ] || fail "the restart changed the grants: ${GRANTS_BEFORE} -> ${GRANTS_AFTER}"
expect_served "grant-disclosure-${READER_GRANT}-input:read" "the reading grant's row after the restart" input:read
expect_served "grant-disclosure-${CONTROLLER_GRANT}-input:control" "the controlling grant's row after the restart" input:control
expect_served "grant-disclosure-${REQUESTER_GRANT}-input:read" "the approved grant's row after the restart, for input read" input:read
expect_served "grant-disclosure-${REQUESTER_GRANT}-input:control" "the approved grant's row after the restart, for input control" input:control
capture after-restart

step "Quit Koine"
quit_koine

step "Result"
if [ "${#ROWS_FAILED[@]}" -gt 0 ]; then
    printf 'ROW FAILED: %s\n' "${ROWS_FAILED[@]}"
    echo "RESULT: an app did not act on a row's chord. Stop and ask Antony: route A has no fallback."
    exit 3
fi
step "PASSED — transcript in ${LOG}"
