#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM, that Koine
# owns its OS permission visibly: with Accessibility consent absent the window
# shows guidance naming Koine and koineManagement.osPermissions reports
# granted: false, to koine:manage alone and without a consent dialog; the
# window's request makes macOS show its dialog naming Koine, and System Settings
# lists Koine; after consent there, and with no restart, the window and
# osPermissions agree and a desktop read succeeds; after consent is removed both
# follow. The window also shows each provider's state and where the service is
# serving. Nothing here runs the application on the host. The procedure and its
# recorded evidence: docs/verification/accessibility-status-and-consent-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="accessibility-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh

# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

# shellcheck disable=SC2016  # guest-side $HOME
STRANGER_FILE='$HOME/koine-credential-stranger'
Q_PERMISSIONS='{ koineManagement { osPermissions { permission owner granted } } }'

# ask <query>: replaces the library's, for the reason guest_json gives. These are
# reads, safe to repeat, and a JSON body followed by its HTTP status line proves
# the client ran to its end whatever the agent reports; that alone is accepted.
ask() {
    for _ in 1 2 3 4 5; do
        RESPONSE="$(guest "bash \$HOME/vm-verify-client.sh \"${CREDENTIAL_FILE}\" '$1'" 2>&1 || true)"
        if grep -qx "HTTP 200" <<<"${RESPONSE}" && body | jq -e . >/dev/null 2>&1; then
            body
            return 0
        fi
        sleep 3
    done
    echo "${RESPONSE}"
    fail "expected HTTP 200 for: $1"
}
body() { grep -m1 '^{' <<<"${RESPONSE}"; }
# expect_permission <true|false>: osPermissions is exactly accessibility, koine, $1.
expect_permission() {
    ask "${Q_PERMISSIONS}"
    body | jq -e "(.errors // []) | length == 0" >/dev/null || fail "osPermissions reported errors"
    body | jq -e ".data.koineManagement.osPermissions == [{permission: \"accessibility\", owner: \"koine\", granted: $1}]" >/dev/null ||
        fail "osPermissions does not report accessibility, koine, granted: $1"
}
# follow <true|false> <window text>: with no restart, osPermissions and then the
# window come to report $1. How long that took is recorded.
follow() {
    local since
    since="$(date +%s)"
    until ask "${Q_PERMISSIONS}" >/dev/null && body | jq -e ".data.koineManagement.osPermissions[0].granted == $1" >/dev/null; do
        [ $(($(date +%s) - since)) -lt 60 ] || fail "osPermissions did not report granted: $1 within 60s"
        sleep 2
    done
    echo "Observation: osPermissions reported granted: $1 within $(($(date +%s) - since))s, Koine pid $(koine_pid)."
    expect_permission "$1"
    testanyware agent window-focus --window "${APP_NAME}" >/dev/null
    sleep 3
    echo "Window: $(value_of '.id=="accessibility-status"')"
    grep -q "$2" <<<"$(value_of '.id=="accessibility-status"')" || fail "the window does not say: $2"
}

koine_pid() { guest "pgrep -f ${INSTALLED}/Contents/MacOS" 2>&1 | grep -E '^[0-9]+$' | tail -1; }

start_vm
install_app
testanyware file upload scripts/vm-verify-desktop-client.py /Users/admin/vm-verify-desktop-client.py >/dev/null

step "Launch Koine and create two grants in its window"
launch
KOINE_PID="$(koine_pid)"
echo "Koine pid ${KOINE_PID}"
create_grant "vm-manager" "${CREDENTIAL_FILE}" koine:manage desktop:read
create_grant "vm-stranger" "${STRANGER_FILE}" desktop:read
testanyware screen capture -o "${LOG%.log}-window.png" >/dev/null

step "The window shows the service where the descriptor says it is, and the desktop provider's state"
PORT="$(guest "jq -r .port \"${DATA}/endpoint.json\"" 2>&1 | grep -E '^[0-9]+$' | tail -1)"
SERVICE="$(value_of '.id=="service-status"')"
echo "Descriptor port ${PORT}; window: ${SERVICE}"
grep -q "Serving koine-desktop/1 at http://127.0.0.1:${PORT}/graphql" <<<"${SERVICE}" ||
    fail "the window does not show the endpoint the descriptor names"
ask '{ koineManagement { providers { provider version state diagnostic } } }'
PROVIDER_ROW="$(snapshot | jq -c '[.. | objects | select(.id? == "provider-desktop")][0] | [.. | objects | (.label?, .value?) | select(. != null and . != "")]')"
echo "Provider row: ${PROVIDER_ROW}"
STATE="$(body | jq -r '.data.koineManagement.providers[] | select(.provider == "desktop") | .state')"
[ "${STATE}" = ACTIVE ] || fail "the desktop provider is not ACTIVE"
grep -q "Active" <<<"${PROVIDER_ROW}" || fail "the window does not show the desktop provider Active"

step "Consent absent: the window gives guidance naming Koine, osPermissions reports granted: false, and nothing prompts"
GUIDANCE="$(value_of '.id=="accessibility-status"')"
echo "Window: ${GUIDANCE}"
grep -q "Koine does not have Accessibility access" <<<"${GUIDANCE}" || fail "the window shows no guidance"
grep -q "Koine is the application that needs it" <<<"${GUIDANCE}" || fail "the guidance does not name Koine"
expect_permission false
no_consent_dialog "after osPermissions reads and the window's own polling without consent"

step "A grant without koine:manage cannot read osPermissions"
MANAGER_FILE="${CREDENTIAL_FILE}"
CREDENTIAL_FILE="${STRANGER_FILE}"
ask "${Q_PERMISSIONS}"
CREDENTIAL_FILE="${MANAGER_FILE}"
body | jq -e '.data.koineManagement == null and (.errors | length == 1) and (.errors[0] | .path == ["koineManagement"] and (.extensions | .kind == "permission" and .permissionClass == "capability" and .requiredCapability == "koine:manage"))' >/dev/null ||
    fail "osPermissions was not refused for want of koine:manage"

step "The window's request: macOS shows its consent dialog, naming Koine"
click '.id=="request-accessibility"'
sleep 3
DIALOG="$(testanyware screen find-text "${DIALOG_TEXT}" --timeout 20 --require-match --json)" ||
    fail "the request showed no consent dialog"
jq -c '.detections' <<<"${DIALOG}"
jq -e '[.detections[].text] | any(test("Koine"))' >/dev/null <<<"${DIALOG}" || fail "the dialog does not name Koine"
testanyware screen capture -o "${LOG%.log}-consent-dialog.png" >/dev/null
echo "Shown by: $(guest "pgrep -lx ${DIALOG_HOST}" || true)"

step "The dialog leads to System Settings, which lists Koine, switched off"
OPEN="$(testanyware screen find-text "Open System Settings" --timeout 10 --require-match --json)" || fail "the dialog offers no route to System Settings"
# shellcheck disable=SC2046
testanyware input click $(jq -r '.detections[0] | "\(.x + .width / 2 | floor) \(.y + .height / 2 | floor)"' <<<"${OPEN}") >/dev/null
SNAPSHOT_WINDOW="System Settings"
tries=0
until [ "$(value_of '.id=="Koine_Toggle"' 2>/dev/null)" = 0 ]; do
    tries=$((tries + 1))
    [ "${tries}" -lt 15 ] || fail "System Settings does not list Koine, switched off"
    sleep 2
done
testanyware screen capture -o "${LOG%.log}-settings-entry.png" >/dev/null

step "Consent given by Koine's switch; with no restart the window and osPermissions agree, and a desktop read succeeds"
click '.id=="Koine_Toggle"'
sleep 2
testanyware input type "${VM_PASSWORD}" >/dev/null
testanyware input key return >/dev/null
sleep 3
testanyware input key q --modifiers cmd >/dev/null # System Settings
unset SNAPSHOT_WINDOW
sleep 2
follow true "Koine has Accessibility access"
[ "$(element '.id=="request-accessibility"')" = null ] || fail "the request control is still offered after consent"
[ "$(koine_pid)" = "${KOINE_PID}" ] || fail "Koine was restarted"
guest "open -a Finder" || true
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 2
desktop "${CREDENTIAL_FILE}" Finder exact
expect '((.response.errors // []) | length == 0) and (.response.data.desktopApplication.windows | length >= 1)' \
    "a desktop read did not succeed after consent"
testanyware screen capture -o "${LOG%.log}-after-consent.png" >/dev/null

step "Consent removed in System Settings: the window and osPermissions follow, and a desktop read is an os-permission error"
revoke_accessibility
sleep 3
testanyware input key q --modifiers cmd >/dev/null # System Settings
sleep 2
follow false "Koine does not have Accessibility access"
[ "$(koine_pid)" = "${KOINE_PID}" ] || fail "Koine was restarted"
desktop "${CREDENTIAL_FILE}" Finder exact
expect_os_permission '["desktopApplication","windows"]'
testanyware screen capture -o "${LOG%.log}-after-removal.png" >/dev/null

step "The window's other control opens the Accessibility pane, where Koine is still listed"
click '.id=="open-accessibility-settings"'
SNAPSHOT_WINDOW="System Settings"
tries=0
until [ "$(value_of '.id=="Koine_Toggle"' 2>/dev/null)" = 0 ]; do
    tries=$((tries + 1))
    [ "${tries}" -lt 15 ] || fail "the control did not open the Accessibility pane listing Koine"
    sleep 2
done
testanyware input key q --modifiers cmd >/dev/null
unset SNAPSHOT_WINDOW
sleep 2

step "Quit Koine"
quit_koine

step "PASSED — transcript in ${LOG}"
