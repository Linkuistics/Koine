#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM, that Koine is
# a menu bar application: no Dock icon and one menu bar item from launch to Quit;
# its menu, status lines, mark and accessibility label as Accessibility consent
# and client grant requests come and go; the settings window at first launch and
# not once setup is complete, opened from the menu over another application's
# window however often it was closed, resizable, with its shortcuts working and
# with no visible menu bar; a client's request never opening it; reopening the
# running application showing it; login launch across a VM restart; and Quit from
# the menu. Nothing here runs the application on the host. The procedure and its
# recorded evidence: docs/verification/menu-bar-vm.md
#
# Every transport is one strict single attempt in one evidence root, through
# scripts/vm-settings-scenario-lib.sh. The caller table and the controls are in
# docs/verification/settings-activation/ORDERING-SCENARIO-RESULTS.md.
#
# KOINE_VM_BASE names the golden image to clone. It is required.
# KOINE_VM_EVIDENCE_ROOT names a new evidence root; the default is beside the
# transcript. The root can hold KOINE_VM_PASSWORD, so init creates it with mode
# 700: only its owner can enter it. Do not copy it out or publish it.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
# The scenario sends no VM stop. The finite caller stops the exact clone.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="menu-bar-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-settings-scenario-lib.sh
source scripts/vm-settings-scenario-lib.sh

# shellcheck disable=SC2016  # guest-side $HOME
FIRST='$HOME/koine-secret-first' SECOND='$HOME/koine-secret-second'
WINDOW_TITLE="Koine Settings"
# The least content size of the settings window (ManagementView.minimumSize) and
# its default (ManagementView.defaultSize); the frame adds the title bar.
MIN_WIDTH=440 MIN_HEIGHT=320 DEFAULT_WIDTH=480 DEFAULT_HEIGHT=680
# The menus that the scenario compares, each as a list. A separator is "".
NOT_GRANTED=("Accessibility Not Granted…" "" "Settings…" "Quit Koine")
ONE_REQUEST=("Review 1 Grant Request…" "${NOT_GRANTED[@]}")
TWO_REQUESTS=("Review 2 Grant Requests…" "${NOT_GRANTED[@]}")
GRANTED=("Settings…" "Quit Koine")

# settings_await_settled OPERATION: past the 2 s follow, so a window or a label
# has had its say.
settings_await_settled() { settings_sleep "$1" 6; }

# The root comes first: no transport precedes it.
settings_begin "${KOINE_VM_EVIDENCE_ROOT:-${LOG%.log}-evidence}" "${VM_ID}"

# The Settings harness takes no keepalive captures, as
# docs/adr/settings-harness-takes-no-keepalive-captures.md decides. The choice
# is in the source, so no environment variable can start the loop.
settings_start_vm
settings_install_app
settings_record_installed_bundle before
if [ "${KOINE_SETTINGS_TRACE:-0}" = 1 ]; then
    # The ordering protocol permits no enabling diagnostic write.
    refuse_guest_trace_defaults "${KOINE_VM_EVIDENCE_ROOT}" trace-defaults ||
        settings_stop "$?" "KOINE_SETTINGS_TRACE=1 asks for a diagnostic defaults write that the protocol refuses"
fi
upload_guest_file "${KOINE_VM_EVIDENCE_ROOT}" upload-enrollment-client \
    scripts/vm-verify-enrollment-client.py /Users/admin/vm-verify-enrollment-client.py >/dev/null ||
    settings_stop "$?" "the enrolment client upload failed"
settings_grant_system_events_automation

step "First launch: no Dock icon, one menu bar item, and the settings window because setup needs the user"
settings_expect_defaults defaults-before-launch "before the first launch"
settings_launch first-launch
settings_await_windows first-launch-window 1
LIST="$(settings_windows first-launch-windows)" || settings_stop "$?" "the window list could not be read"
echo "Windows: $(jq -c --arg app "${APP_NAME}" '[.windows[] | select(.appName == $app) | .title]' <<<"${LIST}")"
FRAME="$(settings_frame first-launch-frame)" || settings_require "$?" "the default frame could not be read"
echo "Default frame: ${FRAME}"
FRAME="$(settings_frame first-launch-size)" || settings_require "$?" "the default frame could not be read"
read -r _ _ W H <<<"${FRAME}"
[ "${W}" = "${DEFAULT_WIDTH}" ] && [ "${H}" -ge "${DEFAULT_HEIGHT}" ] && [ "${H}" -lt $((DEFAULT_HEIGHT + 60)) ] ||
    settings_fail "the window did not open at ${DEFAULT_WIDTH}x${DEFAULT_HEIGHT} plus its title bar: ${W}x${H}"
LIST="$(settings_windows first-launch-title)" || settings_stop "$?" "the window list could not be read"
settings_state first-launch-title "[.windows[] | select(.appName == \"Koine\")][0].title == \"${WINDOW_TITLE}\"" \
    "${LIST}" || settings_require "$?" "the window is not titled \"${WINDOW_TITLE}\""
RECORD="$(expect_guest_background_only "${KOINE_VM_EVIDENCE_ROOT}" first-launch-background)" ||
    settings_require "$?" "Koine is not an agent application"
echo "Background only (an agent application): $(jq -r '.value' <<<"${RECORD}")"
RECORD="$(expect_guest_no_dock_item "${KOINE_VM_EVIDENCE_ROOT}" first-launch-dock)" || {
    STATUS=$?
    RECORD="$(settings_last_record first-launch-dock)" || RECORD='{"value":[]}'
    echo "Dock: $(jq -r '.value | map(. // "missing value") | join(", ")' <<<"${RECORD}")"
    settings_require "${STATUS}" "Koine has a Dock icon"
}
echo "Dock: $(jq -r '.value | map(. // "missing value") | join(", ")' <<<"${RECORD}")"
settings_expect_menu_count first-launch-count "Koine has not exactly one menu bar item"
LABEL="$(settings_menu_label first-launch-item)" || settings_stop "$?" "the menu bar item could not be read"
echo "Item: ${LABEL}"
settings_await_menu_label first-launch-label "Koine, Accessibility not granted"
settings_expect_menu first-launch-menu "${NOT_GRANTED[@]}"
settings_capture first-launch

step "No visible menu bar, even with the window open: the menu bar stays the previous application's"
launch_guest_textedit "${KOINE_VM_EVIDENCE_ROOT}" textedit-launch ||
    settings_stop "$?" "the TextEdit launch was not submitted cleanly"
# Observed: on a clean clone, Settings… chosen within seconds of TextEdit's first
# launch left the window behind TextEdit's in three runs of five, and never once
# TextEdit had been up a while. The cause is not established (TextEdit taking the
# front again as its document appears is the suspect), so the check lets it settle.
# The checked poll owns the whole legacy loop and its final assertion.
settings_await_textedit_window textedit-window
settings_sleep textedit-settle 8
settings_window textedit-move window-move TextEdit 700 120
settings_sleep textedit-move 1
# TextEdit is in front of Koine's window, which is where it was first placed.
STATUS=0
settings_koine_in_front textedit-front || STATUS=$?
case "${STATUS}" in
0) settings_fail "Koine is in front before it was asked to be" ;;
1) ;;
*) settings_stop "${STATUS}" "the front window could not be read" ;;
esac
FRONT="$(settings_front_application textedit-front-application)" ||
    settings_stop "$?" "the front application could not be read"
echo "Front application: ${FRONT}"
# The positive setup compares each later list with this PID and frame.
settings_record_textedit

step "Close the window; Settings… brings it back over TextEdit's, to the front"
settings_window first-close window-close "${WINDOW_TITLE}"
settings_await_windows first-close-window 0
CLOSED_LIST="${SETTINGS_COUNT_LIST}"
settings_expect_menu_count first-close-count "the menu bar item went with the window"
# Each of the four selections: the pre-click identity, the positive setup on
# the zero-count list, the route, then the classified outcome. The front
# application read of a failure precedes the latch.
settings_pre_click_identity first-selection
settings_expect_setup first-selection "${CLOSED_LIST}"
settings_select_return first-selection "Settings…"
settings_expect_return first-selection "the window did not come to the front over TextEdit's" menu
# The outcome screenshot.
settings_capture over-textedit
for reopen in 1 2 3; do
    settings_window "reopen-${reopen}-close" window-close "${WINDOW_TITLE}"
    settings_await_windows "reopen-${reopen}-closed" 0
    settings_pre_click_identity "reopen-${reopen}-selection"
    settings_expect_setup "reopen-${reopen}-selection" "${SETTINGS_COUNT_LIST}"
    settings_select_return "reopen-${reopen}-selection" "Settings…"
    settings_expect_return "reopen-${reopen}" "Settings reopen ${reopen} did not bring the window to the front" menu
    settings_capture "outcome-reopen-${reopen}"
done
quit_guest_textedit "${KOINE_VM_EVIDENCE_ROOT}" textedit-quit ||
    settings_require "$?" "TextEdit still runs after its quit"

step "The window resizes: larger, then no smaller than its least size, where its content scrolls"
settings_window resize-move window-move "${WINDOW_TITLE}" 40 40
settings_window resize-focus window-focus "${WINDOW_TITLE}"
settings_expect_front resize-front "the window is not focused for the resize exercise"
settings_sleep resize-front 1
# A title-bar drag is no proxy for corner delivery: it stayed still in the same
# guest where a held-button corner path grew and shrank this window. Exercise
# the corner itself, retaining the original dimension and content requirements.
drag_window_corner 740 940 || settings_stop "$?" "the corner drag to 740, 940 did not complete cleanly"
RESIZE_FRAME="$(settings_frame resize-grown)" || settings_require "$?" "the grown window frame could not be read"
echo "Larger: ${RESIZE_FRAME}"
read -r _ _ W H <<<"${RESIZE_FRAME}"
[ "${W}" -ge 690 ] && [ "${H}" -ge 880 ] || settings_fail "the window did not grow; resize acceptance is unestablished"
drag_window_corner 100 100 || settings_stop "$?" "the corner drag to 100, 100 did not complete cleanly"
RESIZE_FRAME="$(settings_frame resize-least)" || settings_require "$?" "the minimum window frame could not be read"
echo "Smaller: ${RESIZE_FRAME}"
read -r _ _ W H <<<"${RESIZE_FRAME}"
[ "${W}" = "${MIN_WIDTH}" ] || settings_fail "the window's least width is not ${MIN_WIDTH}: ${W}"
[ "${H}" -ge "${MIN_HEIGHT}" ] && [ "${H}" -lt $((MIN_HEIGHT + 60)) ] ||
    settings_fail "the window's least height is not ${MIN_HEIGHT} plus its title bar: ${H}"
# Check content directly: the outer frame includes platform window chrome.
RESIZE_CONTENT="$(settings_element least-size-content '.platformRole=="AXScrollArea"' height)" ||
    settings_stop "$?" "the minimum content frame could not be read"
(
    set -o noclobber
    printf '%s\n' "${RESIZE_CONTENT}" >"${LOG%.log}-least-size-content.json"
) || settings_local_failure least-size-content-write "the content record could not be written exclusively"
settings_state least-size-content "(.sizeHeight | type == \"number\") and .sizeHeight >= ${MIN_HEIGHT}" \
    "${RESIZE_CONTENT}" || settings_require "$?" "the window content is below ${MIN_HEIGHT} high: ${RESIZE_CONTENT}"
echo "Minimum content height: $(jq -r '.sizeHeight' <<<"${RESIZE_CONTENT}")"
settings_capture "least-size-${W}x${H}"
# Every control stays reachable by scrolling at the observed minimum size.
settings_calibrate_window_scroll
settings_reveal least-size-login '.id=="login-launch"'
settings_reveal least-size-label '.id=="grant-label"'
settings_reveal least-size-accessibility '.id=="accessibility-status"'

step "Shortcuts, with no visible menu bar: ⌘A, ⌘C, ⌘X, ⌘V in a field, ⌘W"
settings_reveal_click shortcut-field '.id=="grant-label"'
settings_input shortcut-type type "shortcut"
settings_sleep shortcut-type 1
settings_expect_value shortcut-typed '.id=="grant-label"' shortcut "typing reached no field"
settings_input shortcut-select-copy key a --modifiers cmd
settings_input shortcut-copy key c --modifiers cmd
settings_input shortcut-cut key x --modifiers cmd
settings_sleep shortcut-cut 1
settings_expect_value shortcut-emptied '.id=="grant-label"' "" "⌘A ⌘X did not empty the field"
settings_input shortcut-paste key v --modifiers cmd
settings_sleep shortcut-paste 1
settings_expect_value shortcut-pasted '.id=="grant-label"' shortcut "⌘V did not restore what ⌘C copied"
settings_input shortcut-select-clear key a --modifiers cmd
settings_input shortcut-clear key x --modifiers cmd
settings_input shortcut-close key w --modifiers cmd
settings_await_windows shortcut-closed 0
settings_expect_menu_count shortcut-count "⌘W took the menu bar item with it"

step "A client's request shows the mark and a line within a poll, and never opens the window"
settings_enrol "${FIRST}" "vm-editor"
settings_await_menu_label first-request-label "Koine, 1 grant request waiting, Accessibility not granted"
settings_await_settled first-request-settle
settings_expect_koine_count first-request-windows 0 "a client's request brought the window forward"
settings_expect_menu first-request-menu "${ONE_REQUEST[@]}"
settings_capture mark 1500,0,420,200
settings_enrol "${SECOND}" "vm-second"
settings_await_menu_label second-request-label "Koine, 2 grant requests waiting, Accessibility not granted"
settings_expect_menu second-request-menu "${TWO_REQUESTS[@]}"
settings_expect_koine_count second-request-windows 0 "a second request brought the window forward"

step "The line opens the window at Requests, scrolled there from the least size"
settings_pre_click_identity requests-selection
settings_select_return requests-selection "Review 2 Grant Requests…"
settings_expect_return requests "the window did not come to the front" menu
settings_sleep requests-front 2
settings_read_frame requests-frame
settings_on_screen requests-on-screen '(.id // "") | startswith("request-label-")' ||
    settings_require "$?" "the window did not scroll to the requests"
# The echo is required evidence: the same one read requires the matching label
# and its displayed value. A missing label or an omitted AXValue is unavailable.
ELEMENT="$(settings_element requests-label '(.id // "") | startswith("request-label-")' value)" ||
    settings_stop "$?" "the request label could not be read"
echo "Requests on screen: $(jq -c '[.id, .value]' <<<"${ELEMENT}")"
# The outcome screenshot: only reads and a wait follow the return before it.
settings_capture requests
settings_click requests-deny-1 '(.id // "") | startswith("deny-")'
settings_sleep requests-deny-1 4
settings_click requests-deny-2 '(.id // "") | startswith("deny-")'
settings_sleep requests-deny-2 4
settings_await_menu_label requests-denied-label "Koine, Accessibility not granted"
settings_expect_menu requests-denied-menu "${NOT_GRANTED[@]}"

step "The Accessibility line opens the window at Accessibility, scrolled there from below"
settings_reveal accessibility-below '.id=="login-launch"'
settings_window accessibility-close window-close "${WINDOW_TITLE}"
settings_await_windows accessibility-closed 0
settings_pre_click_identity accessibility-selection
settings_select_return accessibility-selection "Accessibility Not Granted…"
settings_expect_return accessibility "the Accessibility line did not bring the window to the front" menu
settings_sleep accessibility-front 2
settings_read_frame accessibility-frame
settings_on_screen accessibility-on-screen '.id=="accessibility-status"' ||
    settings_require "$?" "the window did not scroll to Accessibility"
settings_capture outcome-accessibility

step "Consent given in System Settings: the mark and the line go within a poll"
settings_grant_accessibility
settings_await_menu_label granted-label "Koine"
settings_expect_menu granted-menu "${GRANTED[@]}"
settings_await_windows granted-window 1

step "Setup complete: enable login launch, Quit from the menu, and a launch by hand starts silently"
settings_reveal_click login-toggle '.id=="login-launch"'
settings_expect_value login-status '.id=="login-launch-status"' "Koine will start when you log in." \
    "login launch is not enabled"
settings_choose_menu_item setup-quit "Quit Koine"
settings_expect_stopped setup-stopped
settings_launch silent-launch
SILENT_IDENTITY="${SETTINGS_IDENTITY}"
settings_await_settled silent-launch-settle
settings_expect_koine_count silent-launch-windows 0 "the window opened though setup is complete"
settings_await_menu_label silent-launch-label "Koine"
LABEL="$(settings_menu_label silent-launch-item)" || settings_stop "$?" "the menu bar item could not be read"
COUNT="$(settings_koine_count silent-launch-count)" || settings_stop "$?" "the window list could not be read"
echo "Item: ${LABEL}; windows: ${COUNT}"

step "Opening Koine again while it runs shows the window"
launch_guest_koine "${KOINE_VM_EVIDENCE_ROOT}" reopen || settings_stop "$?" "the reopen was not submitted cleanly"
confirm_guest_reopen "${KOINE_VM_EVIDENCE_ROOT}" reopen-identity "${SILENT_IDENTITY}" >/dev/null ||
    settings_require "$?" "the reopen did not keep the same Koine process"
# The confirmation proved the silent launch's process, so its entry is the
# identity that a zero-window outcome compares.
SETTINGS_PRE_IDENTITY="$(jq -c '.process' <<<"${SILENT_IDENTITY}")"
settings_expect_return reopen "reopening did not bring the window to the front" reopen
settings_capture outcome-reopen
settings_window reopen-close window-close "${WINDOW_TITLE}"
settings_await_windows reopen-closed 0

step "Quit with ⌘Q from the window, then restart the VM: only the login item can start Koine"
settings_pre_click_identity quit-selection
settings_select_return quit-selection "Settings…"
settings_expect_return quit "Settings did not focus the window before Command-Q" menu
settings_capture outcome-quit
settings_input pre-restart-quit key q --modifiers cmd
settings_expect_stopped quit-stopped
BOOT_BEFORE="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" evidence boot-before boot)" ||
    settings_stop "$?" "the boot time before the restart could not be read"
# One submission, the existing 30-second wait and at most sixty boot reads.
# Exhaustion is a test-driver or guest failure, never a Koine failure.
restart_guest "${KOINE_VM_EVIDENCE_ROOT}" restart "${BOOT_BEFORE}" >/dev/null ||
    settings_stop "$?" "the VM did not come back from its restart; a test-driver or guest failure, not a Koine failure"
settings_expect_defaults defaults-after-restart "after the restart"

step "After login, with nothing having launched Koine: the item, and no window"
STATUS=0
await_guest_endpoint "${KOINE_VM_EVIDENCE_ROOT}" login-endpoint login >/dev/null || STATUS=$?
# A clean exhaustion continues to the process assertion, as before.
[ "${STATUS}" = 0 ] || [ "${STATUS}" = 1 ] || settings_stop "${STATUS}" "the descriptor after login could not be read"
RECORD="$(check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll login-process '(.selected | length) > 0' process bundle)" ||
    settings_require "$?" "Koine was not started at login"
echo "Started at login: $(jq -c '.selected' <<<"${RECORD}")"
settings_await_koine login-launch-endpoint
settings_await_settled login-settle
settings_expect_menu_count login-count "no menu bar item after login launch"
settings_await_menu_label login-label "Koine"
settings_expect_koine_count login-windows 0 "the window opened at login launch though setup is complete"
LABEL="$(settings_menu_label login-item)" || settings_stop "$?" "the menu bar item could not be read"
COUNT="$(settings_koine_count login-count-echo)" || settings_stop "$?" "the window list could not be read"
echo "Item after login launch: ${LABEL}; windows: ${COUNT}"
expect_guest_background_only "${KOINE_VM_EVIDENCE_ROOT}" login-background >/dev/null ||
    settings_require "$?" "Koine started at login is not an agent application"
settings_capture after-login

step "Quit Koine from the menu: the server stops as it always has"
# The descriptor record carries the port, so no read is added.
RECORD="$(check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll port-descriptor '.present == true' endpoint)" ||
    settings_require "$?" "the descriptor holds no port"
PORT="$(jq -r '.descriptor.port' <<<"${RECORD}")"
settings_choose_menu_item final-quit "Quit Koine"
settings_expect_stopped final-stopped
# A clean read is never empty, so the legacy loop ends at its first clean read.
RECORD="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" read-poll port-refusal port-refusal "${PORT}")" ||
    settings_stop "$?" "the old port ${PORT} could not be probed"
echo "curl to the old port ${PORT}: exit $(jq -r '.curl_exit' <<<"${RECORD}")"
settings_state port-refusal '.curl_exit == 7' "${RECORD}" ||
    settings_require "$?" "something still answers on port ${PORT}"

settings_record_installed_bundle after
STATUS=0
cmp "${LOG%.log}-installed-before.txt" "${LOG%.log}-installed-after.txt" || STATUS=$?
[ "${STATUS}" != 1 ] || settings_fail "the installed bundle changed during the scenario"
[ "${STATUS}" = 0 ] || settings_local_failure installed-compare "the installed inventories could not be compared"

step "PASSED — transcript in ${LOG}"
