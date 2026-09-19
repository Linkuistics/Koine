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

if [ ! -d "${APP_BUNDLE}" ]; then
    echo "Error: ${APP_BUNDLE} does not exist. Run: task app" >&2
    exit 1
fi
for tool in testanyware jq ditto; do
    if ! command -v "${tool}" >/dev/null; then
        echo "Error: ${tool} is not on PATH." >&2
        exit 1
    fi
done

WORK="$(mktemp -d)"
LOG_DIR=".build/vm-verify"
mkdir -p "${LOG_DIR}"
LOG="${LOG_DIR}/$(date +%Y%m%dT%H%M%S).log"
exec > >(tee "${LOG}") 2>&1

VM_ID="koine-verify-$$"
export TESTANYWARE_VM_ID="${VM_ID}"
INSTALLED="/Applications/${APP_NAME}.app"
DATA='$HOME/Library/Application Support/Koine'
CREDENTIAL_FILE='$HOME/koine-credential'
GRANT_LABEL="vm-script"

step() { printf '\n== %s\n' "$*"; }
fail() {
    echo "FAILED: $*" >&2
    testanyware screen capture -o "${LOG%.log}-failure.png" >/dev/null 2>&1 || true
    exit 1
}
# Runs a command in the guest. Observed with this TestAnyware agent: about half
# of all execs, `true` included, run to completion and are then reported as
# "Process timed out after 30s" with status 255. Every command here is safe to
# repeat, so that one answer is retried; anything else is the command's own.
guest() {
    local out status
    for _ in 1 2 3 4 5 6; do
        status=0
        out="$(testanyware file exec "$1" 2>&1)" || status=$?
        if [ "${status}" = 255 ] && grep -q 'Process timed out after 30s' <<<"${out}"; then
            continue
        fi
        [ -z "${out}" ] || echo "${out}"
        return "${status}"
    done
    echo "guest exec kept timing out: $1" >&2
    return 255
}

cleanup() {
    rm -rf "${WORK}"
    if [ "${KOINE_VM_KEEP:-0}" = 1 ]; then
        echo "VM ${VM_ID} left running. Stop it with: testanyware vm stop ${VM_ID}"
    else
        testanyware vm stop "${VM_ID}" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

# The accessibility tree of Koine's windows, deep enough to reach a grant row's
# children. SwiftUI controls here refuse `agent press` (HTTP 400), so elements
# are found semantically and clicked over VNC at their centre, re-read each time.
snapshot() { testanyware agent snapshot --mode full --window "${APP_NAME}" --depth 12 --json; }
element() {
    snapshot | jq -c "[.. | objects | select(has(\"platformRole\")) | select($1)][0]"
}
value_of() { element "$1" | jq -r '.value // empty'; }
click() {
    local e
    e="$(element "$1")"
    [ "${e}" != null ] || fail "no UI element matches: $1"
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '"\(.positionX + .sizeWidth / 2 | floor) \(.positionY + .sizeHeight / 2 | floor)"' <<<"${e}") >/dev/null
    sleep 2
}
# Notification banners ("Login Item Added") cover the top-right of the screen
# and swallow clicks; keep the window at the top-left.
place_window() {
    local tries=0
    until element '.id=="grant-label"' 2>/dev/null | grep -q '^{'; do
        tries=$((tries + 1))
        [ "${tries}" -lt 15 ] || fail "the management window did not appear"
        sleep 2
    done
    testanyware agent window-move --window "${APP_NAME}" --x 40 --y 40 >/dev/null
    testanyware agent window-focus --window "${APP_NAME}" >/dev/null
    sleep 1
}
client() { guest "bash \$HOME/vm-verify-client.sh \"${CREDENTIAL_FILE}\"" || true; }
expect_status() {
    local out
    out="$(client)"
    echo "${out}"
    grep -qx "HTTP $1" <<<"${out}" || fail "the client script expected HTTP $1"
}

step "Start a clean VM (${VM_ID})"
testanyware vm start --platform macos --id "${VM_ID}" >/dev/null
guest 'sw_vers; uname -m'
echo "Gatekeeper: $(guest 'spctl --status' 2>&1 || true)"

step "Install the signed bundle (ditto zip, testanyware file upload, ditto -x)"
ditto -c -k --keepParent "${APP_BUNDLE}" "${WORK}/Koine.zip"
testanyware file upload "${WORK}/Koine.zip" /tmp/Koine.zip >/dev/null
# The guest's /tmp does not survive the restart below; its home directory does.
testanyware file upload scripts/vm-verify-client.sh /Users/admin/vm-verify-client.sh >/dev/null
guest "ditto -x -k /tmp/Koine.zip /Applications"
# Stated, not worked around: this route sets no quarantine attribute, so
# Gatekeeper's first-launch check is not exercised here.
echo "Quarantine attribute: $(guest "xattr -p com.apple.quarantine ${INSTALLED} 2>&1 || true")"
guest "codesign --verify --strict --deep --verbose=2 ${INSTALLED} 2>&1" || fail "the VM rejects the signature"
guest "codesign --display --verbose=2 ${INSTALLED} 2>&1 | grep -E '^(Identifier|TeamIdentifier|Authority=Developer|CodeDirectory)'"
guest "spctl -a -vv ${INSTALLED} 2>&1" || echo "(spctl assessment did not accept the bundle; recorded, not a failure of this stage)"

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
