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
await_guest_textedit_window "${KOINE_VM_EVIDENCE_ROOT}" textedit-window >/dev/null ||
    settings_stop "$?" "TextEdit has no window"
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
