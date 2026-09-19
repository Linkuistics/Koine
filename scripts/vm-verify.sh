#!/bin/bash
# Verifies the signed Koine.app in a clean TestAnyware macOS VM: installation
# and signature, login launch with no client, the manual grant workflow and
# revocation through the real UI, window close, and Quit. Nothing here runs the
# application on the host. The procedure and its recorded evidence:
# docs/verification/resident-app-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh

start_vm
install_app

step "Start Koine and enable login launch in the UI"
guest "open ${INSTALLED}"
place_window
echo "Before: $(value_of '.id=="login-launch-status"')"
click '.id=="login-launch"'
echo "After:  $(value_of '.id=="login-launch-status"')"
[ "$(value_of '.id=="login-launch"')" = 1 ] || fail "the login-launch toggle did not turn on"
[ "$(value_of '.id=="login-launch-status"')" = "Koine will start when you log in." ] ||
    fail "login launch is not reported enabled"

step "Quit Koine, then restart the VM: only the login item can start it again"
testanyware input key q --modifiers cmd >/dev/null
sleep 3
guest "! pgrep -f ${INSTALLED}" >/dev/null || fail "Koine still runs after Quit"
guest "[ ! -e \"${DATA}/endpoint.json\" ]" || fail "the descriptor survived Quit"
BOOT_BEFORE="$(guest 'sysctl -n kern.boottime')"
# Not through guest(): a restart must never be repeated by a retry.
testanyware file exec 'echo admin | sudo -S shutdown -r now' >/dev/null 2>&1 || true
sleep 30
for _ in $(seq 1 60); do
    BOOT_AFTER="$(guest 'sysctl -n kern.boottime' 2>/dev/null || true)"
    if [ -n "${BOOT_AFTER}" ] && [ "${BOOT_AFTER}" != "${BOOT_BEFORE}" ]; then break; fi
    sleep 5
done
[ -n "${BOOT_AFTER}" ] && [ "${BOOT_AFTER}" != "${BOOT_BEFORE}" ] || fail "the VM did not come back from its restart"

step "After login, with nothing having launched Koine"
for _ in $(seq 1 24); do
    if guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1; then break; fi
    sleep 5
done
guest "pgrep -lf ${INSTALLED}" || fail "Koine was not started at login"
guest "cat \"${DATA}/endpoint.json\"; echo" || fail "no endpoint descriptor after login"
# No credential exists yet; an answering listener says 401.
UNAUTHENTICATED="$(guest "curl -s -m 5 -o /dev/null -w '%{http_code}' \"http://127.0.0.1:\$(jq -r .port \"${DATA}/endpoint.json\")/graphql\" -H 'Content-Type: application/json' -d '{\"query\":\"{ koine { contractVersion } }\"}'")"
echo "Listener without a credential: HTTP ${UNAUTHENTICATED}"
[ "${UNAUTHENTICATED}" = 401 ] || fail "the listener did not answer 401 to an unauthenticated request"

step "Create a grant through the UI and deliver its credential to a script"
place_window
click '.id=="grant-label"'
testanyware input type "${GRANT_LABEL}" >/dev/null
sleep 1
click '.role=="button" and .label=="Create Grant"'
[ -n "$(value_of '.id=="grant-credential"')" ] || fail "the credential sheet did not appear"
# Delivery is the sheet's own Copy button and the VM's clipboard; the
# credential is never printed or brought to the host.
click '.role=="button" and .label=="Copy"'
guest "umask 077; pbpaste > \"${CREDENTIAL_FILE}\"; ls -l \"${CREDENTIAL_FILE}\""
click '.role=="button" and .label=="Done"'
[ -z "$(value_of '.id=="grant-credential"')" ] || fail "the credential is still shown after Done"
expect_status 200
client | grep -q "\"clientLabel\":\"${GRANT_LABEL}\"" || fail "Query.koine did not report the grant created in the UI"

step "Close the management window; the service still answers"
testanyware agent window-close --window "${APP_NAME}" >/dev/null
sleep 2
WINDOWS="$(testanyware agent windows --json | jq "[.windows[] | select(.appName == \"${APP_NAME}\" and .title == \"${APP_NAME}\")] | length")"
[ "${WINDOWS}" = 0 ] || fail "the management window is still open"
expect_status 200

step "Reopen the window and revoke the grant through the UI"
guest "open ${INSTALLED}"
place_window
click '(.id // "") | startswith("revoke-")'
click '.role=="button" and ((.label // "") | startswith("Revoke “"))'
ROW="$(element '(.id // "") | test("^grant-[0-9a-f]{8}-")' | jq -c '[.children[] | .value // .label]')"
echo "Grant row: ${ROW}"
grep -q '"Revoked"' <<<"${ROW}" || fail "the grant row does not show Revoked"
expect_status 401

step "Quit Koine"
testanyware agent window-focus --window "${APP_NAME}" >/dev/null
sleep 1
PORT="$(guest "jq -r .port \"${DATA}/endpoint.json\"")"
testanyware input key q --modifiers cmd >/dev/null
sleep 3
guest "! pgrep -f ${INSTALLED}" >/dev/null || fail "Koine still runs after Quit"
guest "ls \"${DATA}\""
guest "[ ! -e \"${DATA}/endpoint.json\" ]" || fail "the descriptor survived Quit"
client
REFUSED="$(guest "curl -s -m 3 -o /dev/null http://127.0.0.1:${PORT}/graphql; echo \$?" || true)"
echo "curl to the old port ${PORT}: exit ${REFUSED}"
[ "${REFUSED}" = 7 ] || fail "something still answers on port ${PORT}"

step "PASSED — transcript in ${LOG}"
