#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM with one
# display, the happy path of window layout (Koine 0.5.0, desktop 1.0.1) with
# real applications. A reading grant lists the windows of TextEdit and Finder
# with references and frames, and the display with its full and visible frames.
# A controlling grant sets a window to the left half of the visible frame and
# then restores the frame that the reading grant read earlier. Order and
# visibility match the window server for overlapping windows of two
# applications, and for two TextEdit windows with equal bounds, in both orders.
# Display focus raises the front window, activates its application and moves the
# pointer to the centre of the display. The Settings window shows the served
# desktop disclosures in the create-grant view, the request view and the grant
# list, and again for the existing grants after a restart.
#
# Koine never witnesses its own answers. Fixtures/WindowIdentityProbe, an
# independent signed tool, reads frames, displays, the window server's order,
# the focused window and the pointer from the system. Every operation is sent
# with the text of docs/design/desktop-window-layout-operations.graphql.
# Nothing here runs the application on the host. The procedure and its recorded
# evidence: docs/verification/desktop-window-layout-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="window-layout-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

PROBE="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"
# shellcheck disable=SC2016  # guest-side $HOME
LAYOUT_OPERATIONS='$HOME/desktop-window-layout-operations.graphql'
# shellcheck disable=SC2016  # guest-side $HOME
REQUESTER='$HOME/koine-secret-layout-requester'
# Two points of tolerance: the window server's bounds and an Accessibility frame
# can differ by a fraction of a point, and the probe reads whole points.
TOLERANCE=2

# What the served desktop disclosures must state: the expanded reach of window
# layout (docs/specs/machine.md, "Capability disclosures" and "Window layout").
CONTROL_PHRASES=("Moves and resizes any window" "moves the pointer to the centre of the display" "It never clicks or types" "earlier Koine version that holds desktop:control")
READ_PHRASES=("Lists the windows of every application with a Dock icon" "the place in front-to-back order" "lists the displays" "earlier Koine version that holds desktop:read")

# layout <credential file> <case> [argument...]: the guest window layout client;
# its one JSON line is left in ANSWER.
layout() {
    local file="$1"
    shift
    ANSWER="$(guest_json "python3 \$HOME/vm-verify-window-layout-client.py \"${file}\" \"${LAYOUT_OPERATIONS}\" $*")" ||
        fail "the window layout client printed no JSON for: $*"
    echo "${ANSWER}"
}
no_errors() { expect '(.response.errors // []) | length == 0' "$1 reported errors"; }
# list_windows: DesktopWindowList under the reading grant, left in LIST.
list_windows() {
    layout "${CREDENTIAL_FILE}" list
    no_errors "DesktopWindowList"
    LIST="${ANSWER}"
}
# row <title>: the one row of the window list with that title, as JSON.
row() {
    jq -ce --arg t "$1" '[.response.data.desktopWindows[] | select(.window.title == $t)] | if length == 1 then .[0] else error("rows: \(length)") end' <<<"${LIST}" ||
        fail "the window list has not exactly one row titled $1"
}
# near <JSON rect a> <JSON rect b>: each of x, y, width and height within TOLERANCE.
near() {
    jq -en --argjson a "$1" --argjson b "$2" --argjson t "${TOLERANCE}" \
        '[$a.x - $b.x, $a.y - $b.y, $a.width - $b.width, $a.height - $b.height] | map(fabs <= $t) | all' >/dev/null
}
# rect_of <probe rect array>: the probe's [x, y, width, height] as a rect object.
rect_of() { jq -c '{x: .[0], y: .[1], width: .[2], height: .[3]}' <<<"$1"; }

# The witness: the window server's on-screen list, front to back, and the
# Accessibility windows of TextEdit and Finder with their window numbers.
stack() {
    STACK="$(guest_json "\$HOME/WindowIdentityProbe stack ${TEXTEDIT_PID} ${FINDER_PID}")"
    echo "${STACK}"
    jq -e '.trusted == true' >/dev/null <<<"${STACK}" || fail "the witness cannot read the windows"
}
# witness_rect <pid> <title>: the frame that Accessibility reports to the witness.
witness_rect() {
    local r
    r="$(jq -ce --argjson pid "$1" --arg t "$2" '[.windows[] | select(.pid == $pid and .title == $t)] | if length == 1 then .[0].rect else error("windows: \(length)") end' <<<"${STACK}")" ||
        fail "the witness does not see exactly one window titled $2"
    rect_of "${r}"
}

# same_order <front key> <key>...: a key is "Application|title". Each key names
# exactly one row of the window list, ON_SCREEN with an order. The rows of these
# keys, sorted by order, equal the witness's front-to-back order of the same
# windows, and the first is the front key.
same_order() {
    local keys koine witness
    keys="$(printf '%s\n' "$@" | jq -R . | jq -cs .)"
    list_windows
    stack
    jq -e --argjson keys "${keys}" '[.response.data.desktopWindows[] | select("\(.window.application.name)|\(.window.title)" as $k | any($keys[]; . == $k))]
        | length == ($keys | length) and all(.visibility == "ON_SCREEN" and .order != null)' >/dev/null <<<"${LIST}" ||
        fail "the rows of ${keys} are not each one ON_SCREEN row with an order"
    koine="$(jq -c --argjson keys "${keys}" '[.response.data.desktopWindows[] | select(.order != null) | {k: "\(.window.application.name)|\(.window.title)", order}]
        | sort_by(.order) | map(.k) | map(select(. as $k | any($keys[]; . == $k)))' <<<"${LIST}")"
    witness="$(jq -c --argjson keys "${keys}" --argjson names "{\"${TEXTEDIT_PID}\": \"TextEdit\", \"${FINDER_PID}\": \"Finder\"}" \
        '[.front[] | "\($names[.pid | tostring])|\(.title)"] | map(select(. as $k | any($keys[]; . == $k)))' <<<"${STACK}")"
    echo "Koine's order: ${koine}"
    echo "The window server's order: ${witness}"
    [ "${koine}" = "${witness}" ] || fail "Koine's order ${koine} is not the window server's ${witness}"
    [ "$(jq -r '.[0]' <<<"${koine}")" = "$1" ] || fail "$1 is not in front"
}
# set_frame <reference> <JSON rect>: SetDesktopWindowFrame under the controlling grant.
set_frame() {
    layout "${CONTROLLER_FILE}" set-frame "'$1'" "$(jq -r '"\(.x) \(.y) \(.width) \(.height)"' <<<"$2")"
    expect "((.response.errors // []) | length == 0) and (.response.data.desktopSetWindowFrame == {ref: \"$1\"})" \
        "setting the frame of $1 did not return its receipt"
    sleep 1
}
# frame_of <reference>: DesktopWindowFrame under the reading grant, left in FRAME.
frame_of() {
    layout "${CREDENTIAL_FILE}" frame "'$1'"
    no_errors "DesktopWindowFrame"
    FRAME="$(jq -c '.response.data.desktopWindow.frame' <<<"${ANSWER}")"
    [ "${FRAME}" != null ] || fail "the frame of $1 is unknown"
}
# expect_frame <reference> <pid> <title> <JSON rect>: Koine and the witness both read it.
expect_frame() {
    frame_of "$1"
    near "${FRAME}" "$4" || fail "Koine reads ${FRAME} for $3, not $4"
    stack
    local seen
    seen="$(witness_rect "$2" "$3")"
    near "${seen}" "$4" || fail "the witness reads ${seen} for $3, not $4"
    echo "Observation: $3 is at $4: Koine reads ${FRAME}, the witness reads ${seen}."
}
# on_top <reference> <x> <y> <answer>
on_top() {
    layout "${CREDENTIAL_FILE}" on-top "'$1'" "$2" "$3"
    expect "((.response.errors // []) | length == 0) and .response.data.desktopWindowOnTop == \"$4\"" \
        "the point query did not answer $4 for $1 at ($2, $3)"
}
pointer() {
    POINTER="$(guest_json "\$HOME/WindowIdentityProbe pointer")"
    echo "${POINTER}"
}
# No consent dialog of any kind names Koine: Accessibility's says "would like to
# control", and the Screen Recording dialog says "would like to record".
no_dialog() {
    no_consent_dialog "$1"
    local found
    found="$(testanyware screen find-text "would like to" --json)" || fail "the screen could not be read"
    jq -e '.ok == true and .total == 0' >/dev/null <<<"${found}" || fail "a permission dialog is showing: $1"
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
    if [ "$3" = desktop:control ]; then phrases=("${CONTROL_PHRASES[@]}"); else phrases=("${READ_PHRASES[@]}"); fi
    for phrase in "${phrases[@]}"; do
        grep -qF -- "${phrase}" <<<"${shown}" || fail "$2 does not state: ${phrase}"
    done
}
capture() { testanyware screen capture -o "${LOG%.log}-$1.png" >/dev/null; }

start_vm
install_app
testanyware file upload scripts/vm-verify-desktop-client.py /Users/admin/vm-verify-desktop-client.py >/dev/null
testanyware file upload scripts/vm-verify-window-layout-client.py /Users/admin/vm-verify-window-layout-client.py >/dev/null
testanyware file upload scripts/vm-verify-enrollment-client.py /Users/admin/vm-verify-enrollment-client.py >/dev/null
testanyware file upload docs/design/desktop-operations.graphql /Users/admin/desktop-operations.graphql >/dev/null
testanyware file upload docs/design/desktop-window-layout-operations.graphql /Users/admin/desktop-window-layout-operations.graphql >/dev/null
testanyware file upload "${PROBE}" /Users/admin/WindowIdentityProbe >/dev/null
# shellcheck disable=SC2016  # guest-side $HOME
guest 'chmod +x $HOME/WindowIdentityProbe; echo a > $HOME/layout-a.txt; echo b > $HOME/layout-b.txt'

step "Launch Koine and create a reading grant in the window"
launch
create_grant "vm-layout-reader" "${CREDENTIAL_FILE}" koine:manage desktop:read

step "The served desktop disclosures state the reach of window layout"
layout "${CREDENTIAL_FILE}" disclosures
no_errors "capabilityDisclosures"
expect '.response.data.koineManagement.capabilityDisclosures | map(.capability) == ["desktop:control","desktop:read","workspace:control","workspace:read"]' \
    "the served disclosures are not the two desktop ones and the two workspace ones"
DISCLOSURES="${ANSWER}"

step "The create-grant view: a new grant shows both desktop disclosures"
expect_served "disclosure-desktop:read" "the create-grant view, for desktop read" desktop:read
expect_served "disclosure-desktop:control" "the create-grant view, for desktop control" desktop:control
capture create-grant
create_grant "vm-layout-controller" "${CONTROLLER_FILE}" desktop:control

step "The request view: a pending request for desktop read and desktop control shows both disclosures"
ANSWER="$(guest_json "python3 \$HOME/vm-verify-enrollment-client.py \"${REQUESTER}\" enrol layout-requester desktop:read desktop:control")" ||
    fail "the enrollment client printed no JSON"
echo "${ANSWER}"
expect '.status == 200 and ((.response.errors // []) | length == 0)' "enrollment was refused"
REQUEST_ID="$(jq -r .response.data.koineRequestGrant.requestId <<<"${ANSWER}")"
await_element ".id==\"request-${REQUEST_ID}\"" present
expect_served "request-disclosure-${REQUEST_ID}-desktop:read" "the request view, for desktop read" desktop:read
expect_served "request-disclosure-${REQUEST_ID}-desktop:control" "the request view, for desktop control" desktop:control
capture request-view
reveal_click ".id==\"approve-${REQUEST_ID}\""
await_element ".id==\"request-${REQUEST_ID}\"" absent

step "The grant list: each existing grant shows the disclosure of each desktop capability it holds"
layout "${CREDENTIAL_FILE}" grants
no_errors "koineManagement.grants"
GRANTS_BEFORE="$(jq -c '.response.data.koineManagement.grants' <<<"${ANSWER}")"
grant_id() { jq -r --arg l "$1" 'map(select(.clientLabel == $l))[0].grantId' <<<"${GRANTS_BEFORE}"; }
READER_GRANT="$(grant_id vm-layout-reader)"
CONTROLLER_GRANT="$(grant_id vm-layout-controller)"
REQUESTER_GRANT="$(grant_id layout-requester)"
jq -e 'map(select(.clientLabel == "layout-requester"))[0] | .state == "ACTIVE" and (.capabilities | sort) == ["desktop:control","desktop:read"]' >/dev/null <<<"${GRANTS_BEFORE}" ||
    fail "the approved grant is not desktop:read and desktop:control"
expect_served "grant-disclosure-${READER_GRANT}-desktop:read" "the reading grant's row" desktop:read
expect_served "grant-disclosure-${CONTROLLER_GRANT}-desktop:control" "the controlling grant's row" desktop:control
expect_served "grant-disclosure-${REQUESTER_GRANT}-desktop:read" "the approved grant's row, for desktop read" desktop:read
expect_served "grant-disclosure-${REQUESTER_GRANT}-desktop:control" "the approved grant's row, for desktop control" desktop:control
capture grant-list

step "Real windows: two TextEdit documents and one Finder window"
# shellcheck disable=SC2016  # guest-side $HOME
guest 'open -a TextEdit $HOME/layout-a.txt $HOME/layout-b.txt' || true
sleep 4
guest "open -a Finder" || true
sleep 3
# Finder opens a window of its own when it is activated with none. Close every
# Finder window, then open exactly one, so its title names one row.
testanyware input key w --modifiers cmd,alt >/dev/null
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 3
TEXTEDIT_PID="$(guest_text "pgrep -x TextEdit" | head -1)"
FINDER_PID="$(guest_text "pgrep -x Finder" | head -1)"
[ -n "${TEXTEDIT_PID}" ] && [ -n "${FINDER_PID}" ] || fail "TextEdit or Finder does not run"

step "Give Koine Accessibility consent in System Settings"
grant_accessibility

step "The window list: TextEdit and Finder windows with references, applications and frames, as the witness reads them"
list_windows
A_ROW="$(row layout-a.txt)"
B_ROW="$(row layout-b.txt)"
A="$(jq -r '.window.ref' <<<"${A_ROW}")"
B="$(jq -r '.window.ref' <<<"${B_ROW}")"
F_ROW="$(jq -ce '[.response.data.desktopWindows[] | select(.window.application.name == "Finder")] | if length == 1 then .[0] else error("Finder rows: \(length)") end' <<<"${LIST}")" ||
    fail "the window list has not exactly one Finder row"
F="$(jq -r '.window.ref' <<<"${F_ROW}")"
F_TITLE="$(jq -r '.window.title' <<<"${F_ROW}")"
for r in "${A_ROW}" "${B_ROW}" "${F_ROW}"; do
    jq -e '(.window.ref | startswith("koine://desktop/window/")) and .window.application.ref != null and .window.frame != null' >/dev/null <<<"${r}" ||
        fail "a row has no window reference, no application or no frame: ${r}"
done
jq -e '.window.application.name == "TextEdit" and .window.application.bundleIdentifier == "com.apple.TextEdit"' >/dev/null <<<"${A_ROW}" ||
    fail "layout-a.txt does not belong to TextEdit"
jq -e '.window.application.bundleIdentifier == "com.apple.finder"' >/dev/null <<<"${F_ROW}" || fail "the Finder row does not belong to Finder"
stack
for spec in "${TEXTEDIT_PID}|layout-a.txt|${A_ROW}" "${TEXTEDIT_PID}|layout-b.txt|${B_ROW}" "${FINDER_PID}|${F_TITLE}|${F_ROW}"; do
    IFS='|' read -r pid title r <<<"${spec}"
    seen="$(witness_rect "${pid}" "${title}")"
    near "$(jq -c '.window.frame' <<<"${r}")" "${seen}" || fail "Koine's frame of ${title} is not the witness's ${seen}"
    echo "Observation: ${title} has frame $(jq -c '.window.frame' <<<"${r}"); the witness reads ${seen}."
done

step "The display list: one primary display with its full and visible frames, as the witness reads them"
layout "${CREDENTIAL_FILE}" displays
no_errors "DesktopDisplayList"
DISPLAYS="${ANSWER}"
WITNESS_DISPLAYS="$(guest_json "\$HOME/WindowIdentityProbe displays")"
echo "${WITNESS_DISPLAYS}"
jq -e '.listError == 0 and (.displays | length == 1) and .displays[0].primary == true and .displays[0].visibleFrame != null' >/dev/null <<<"${WITNESS_DISPLAYS}" ||
    fail "the witness does not see one primary display with a visible frame"
expect '.response.data.desktopDisplays | length == 1 and .[0].primary == true and .[0].visibleFrame != null' \
    "Koine does not list one primary display with a visible frame"
DISPLAY_REF="$(jq -r '.response.data.desktopDisplays[0].ref' <<<"${DISPLAYS}")"
[ "${DISPLAY_REF}" = "koine://desktop/display/$(jq -r '.displays[0].id' <<<"${WITNESS_DISPLAYS}")" ] ||
    fail "the display reference ${DISPLAY_REF} does not name the witness's display"
DISPLAY_FRAME="$(jq -c '.response.data.desktopDisplays[0].frame' <<<"${DISPLAYS}")"
VISIBLE="$(jq -c '.response.data.desktopDisplays[0].visibleFrame' <<<"${DISPLAYS}")"
near "${DISPLAY_FRAME}" "$(rect_of "$(jq -c '.displays[0].bounds' <<<"${WITNESS_DISPLAYS}")")" || fail "the display frame is not the witness's"
near "${VISIBLE}" "$(rect_of "$(jq -c '.displays[0].visibleFrame' <<<"${WITNESS_DISPLAYS}")")" || fail "the visible frame is not the witness's"
jq -en --argjson f "${DISPLAY_FRAME}" --argjson v "${VISIBLE}" \
    '$f.x == 0 and $f.y == 0 and $v.y > $f.y and $v.x >= $f.x and $v.y + $v.height <= $f.y + $f.height and $v.x + $v.width <= $f.x + $f.width' >/dev/null ||
    fail "the visible frame ${VISIBLE} does not leave out the menu bar inside the frame ${DISPLAY_FRAME}"
echo "Observation: the display frame is ${DISPLAY_FRAME} and the visible frame is ${VISIBLE}."

step "Frame setting: layout-a.txt to the left half of the visible frame, then the earlier frame that a client restore sets"
frame_of "${A}"
EARLIER="${FRAME}"
LEFT="$(jq -c '{x: .x, y: .y, width: (.width / 2 | floor), height: .height}' <<<"${VISIBLE}")"
set_frame "${A}" "${LEFT}"
expect_frame "${A}" "${TEXTEDIT_PID}" layout-a.txt "${LEFT}"
capture left-half
set_frame "${A}" "${EARLIER}"
expect_frame "${A}" "${TEXTEDIT_PID}" layout-a.txt "${EARLIER}"

# Test windows stay right of the Settings window, which launch places at the top left.
X0="$(jq -r '.x + 560 | floor' <<<"${VISIBLE}")"
Y0="$(jq -r '.y + 60 | floor' <<<"${VISIBLE}")"

step "Order and visibility, two applications: layout-a.txt and the Finder window overlap"
A_OVERLAP="{\"x\": ${X0}, \"y\": ${Y0}, \"width\": 600, \"height\": 400}"
F_OVERLAP="{\"x\": $((X0 + 200)), \"y\": $((Y0 + 100)), \"width\": 600, \"height\": 400}"
set_frame "${A}" "${A_OVERLAP}"
set_frame "${F}" "${F_OVERLAP}"
INSIDE_X=$((X0 + 400))
INSIDE_Y=$((Y0 + 250))
focus "${A}"
expect_receipt "${A}"
same_order "TextEdit|layout-a.txt" "Finder|${F_TITLE}"
on_top "${A}" "${INSIDE_X}" "${INSIDE_Y}" ON_TOP
on_top "${F}" "${INSIDE_X}" "${INSIDE_Y}" NOT_ON_TOP
capture order-textedit-front
focus "${F}"
expect_receipt "${F}"
same_order "Finder|${F_TITLE}" "TextEdit|layout-a.txt"
on_top "${F}" "${INSIDE_X}" "${INSIDE_Y}" ON_TOP
on_top "${A}" "${INSIDE_X}" "${INSIDE_Y}" NOT_ON_TOP
capture order-finder-front

step "Order and visibility, two TextEdit windows with equal bounds"
EQUAL="{\"x\": $((X0 + 100)), \"y\": $((Y0 + 50)), \"width\": 500, \"height\": 350}"
set_frame "${A}" "${EQUAL}"
set_frame "${B}" "${EQUAL}"
expect_frame "${B}" "${TEXTEDIT_PID}" layout-b.txt "${EQUAL}"
focus "${A}"
expect_receipt "${A}"
same_order "TextEdit|layout-a.txt" "TextEdit|layout-b.txt"
focus "${B}"
expect_receipt "${B}"
same_order "TextEdit|layout-b.txt" "TextEdit|layout-a.txt"
focus "${A}"
expect_receipt "${A}"
same_order "TextEdit|layout-a.txt" "TextEdit|layout-b.txt"

step "A minimised window is OFF_SCREEN with no order"
focus "${B}"
expect_receipt "${B}"
testanyware input key m --modifiers cmd >/dev/null
sleep 3
listed "${TEXTEDIT_PID}" '[.windows[] | select(.title == "layout-b.txt")] | length == 1 and .[0].minimized == true'
list_windows
row layout-b.txt | jq -e '.visibility == "OFF_SCREEN" and .order == null' >/dev/null || fail "the minimised window is not OFF_SCREEN with no order"
row layout-a.txt | jq -e '.visibility == "ON_SCREEN" and .order != null' >/dev/null || fail "layout-a.txt is not ON_SCREEN with an order"

step "Display focus: Finder in front with no window; the front window is raised and the pointer moves to the centre"
focus "${F}"
expect_receipt "${F}"
testanyware input key w --modifiers cmd,alt >/dev/null
sleep 3
witness
jq -e '.application.name == "Finder"' >/dev/null <<<"${WITNESS}" || fail "Finder is not in front"
BEFORE_FOCUS="${FOCUSED}"
stack
A_ID="$(jq -r '[.windows[] | select(.title == "layout-a.txt")][0].privateWindowId' <<<"${STACK}")"
FRONT="$(jq -c --argjson pids "[${TEXTEDIT_PID}, ${FINDER_PID}]" '[.front[] | select(.pid as $p | any($pids[]; . == $p))][0]' <<<"${STACK}")"
echo "The witness's front listed window: ${FRONT}"
jq -e ".windowNumber == ${A_ID}" >/dev/null <<<"${FRONT}" || fail "layout-a.txt is not the front listed window before display focus"
jq -e ".window.privateWindowId != ${A_ID}" >/dev/null <<<"${WITNESS}" || fail "layout-a.txt already has focus, so display focus would prove nothing"
testanyware input move 60 300 >/dev/null
sleep 1
pointer
CENTRE="$(jq -c '[.x + .width / 2, .y + .height / 2]' <<<"${DISPLAY_FRAME}")"
jq -en --argjson p "$(jq -c '.point' <<<"${POINTER}")" --argjson c "${CENTRE}" '($p[0] - $c[0] | fabs) > 50 or ($p[1] - $c[1] | fabs) > 50' >/dev/null ||
    fail "the pointer is already at the centre ${CENTRE}, so a move would prove nothing"
layout "${CONTROLLER_FILE}" focus-display "'${DISPLAY_REF}'"
expect "((.response.errors // []) | length == 0) and (.response.data.desktopFocusDisplay == {ref: \"${DISPLAY_REF}\", outcome: \"WINDOW_FOCUSED\", pointerMoved: true})" \
    "display focus did not report the front window focused and the pointer moved"
expect_focused TextEdit ".window.privateWindowId == ${A_ID}"
echo "Observation: focus moved from ${BEFORE_FOCUS} to ${FOCUSED}."
pointer
jq -en --argjson p "$(jq -c '.point' <<<"${POINTER}")" --argjson c "${CENTRE}" '($p[0] - $c[0] | fabs) <= 1 and ($p[1] - $c[1] | fabs) <= 1' >/dev/null ||
    fail "the pointer is at $(jq -c '.point' <<<"${POINTER}"), not the centre ${CENTRE}"
jq -e '.pressedMouseButtons == 0' >/dev/null <<<"${POINTER}" || fail "a pointer button is held after display focus"
echo "Observation: the pointer is at $(jq -c '.point' <<<"${POINTER}"), the centre of the display."
capture display-focus
no_dialog "after frame setting, the point query and display focus"

step "Quit and restart Koine: the existing grants keep their disclosures, and nothing was revoked or reauthorised"
quit_koine
launch
layout "${CREDENTIAL_FILE}" grants
no_errors "koineManagement.grants"
GRANTS_AFTER="$(jq -c '.response.data.koineManagement.grants' <<<"${ANSWER}")"
[ "${GRANTS_BEFORE}" = "${GRANTS_AFTER}" ] || fail "the restart changed the grants: ${GRANTS_BEFORE} -> ${GRANTS_AFTER}"
expect_served "grant-disclosure-${READER_GRANT}-desktop:read" "the reading grant's row after the restart" desktop:read
expect_served "grant-disclosure-${CONTROLLER_GRANT}-desktop:control" "the controlling grant's row after the restart" desktop:control
expect_served "grant-disclosure-${REQUESTER_GRANT}-desktop:read" "the approved grant's row after the restart, for desktop read" desktop:read
expect_served "grant-disclosure-${REQUESTER_GRANT}-desktop:control" "the approved grant's row after the restart, for desktop control" desktop:control
capture after-restart

step "Quit Koine"
quit_koine

step "PASSED — transcript in ${LOG}"
