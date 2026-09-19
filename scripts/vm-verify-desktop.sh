#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM and with real
# applications, the first desktop path: the bundled desktop provider is ACTIVE,
# an application resolves by its process identity, a mismatched start instant and
# an absent process are ordinary null, a malformed one is an input error, windows
# with the same title carry distinct references, and a grant without desktop:read
# is refused. Accessibility consent is given to Koine as a user gives it, in
# System Settings. Nothing here runs the application on the host. The procedure
# and its recorded evidence: docs/verification/desktop-application-and-windows-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="desktop-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh

VM_PASSWORD="${KOINE_VM_PASSWORD:-admin}"
# shellcheck disable=SC2016  # guest-side $HOME
STRANGER_FILE='$HOME/koine-credential-stranger'
Q_PROVIDERS='{ koineManagement { providers { provider version state diagnostic } } koine { availableCapabilities } }'

# create_grant <label> <credential file> <capability>...: through Koine's window.
create_grant() {
    local label="$1" file="$2"
    shift 2
    click '.id=="grant-label"'
    testanyware input type "${label}" >/dev/null
    sleep 1
    for capability in "$@"; do click ".id==\"capability-${capability}\""; done
    click '.role=="button" and .label=="Create Grant"'
    [ -n "$(value_of '.id=="grant-credential"')" ] || fail "the credential sheet did not appear"
    click '.role=="button" and .label=="Copy"'
    guest "umask 077; pbpaste > \"${file}\"; ls -l \"${file}\""
    click '.role=="button" and .label=="Done"'
}
# desktop <credential file> <application> <case>: the guest desktop client; its
# one JSON line is left in ANSWER.
desktop() {
    ANSWER="$(guest "python3 \$HOME/vm-verify-desktop-client.py \"$1\" \"$2\" $3" | tail -1)"
    echo "${ANSWER}"
    jq -e . >/dev/null <<<"${ANSWER}" || fail "the desktop client printed no JSON for $2 $3"
}
expect() { jq -e "$1" >/dev/null <<<"${ANSWER}" || fail "$2"; }

# Consent is System Settings' to record. Koine never requests it, so nothing has
# switched it on: Add, authenticate, and choose the installed bundle. (Once a read
# has asked AXIsProcessTrusted, macOS lists Koine there switched off, with no
# dialog; Add switches that entry on just the same.)
grant_accessibility() {
    guest 'open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"' || true
    SNAPSHOT_WINDOW="System Settings"
    # The pane takes a while to load, and a snapshot taken meanwhile is empty.
    local tries=0
    until element '.role=="button" and .label=="Add"' 2>/dev/null | grep -q '^{'; do
        tries=$((tries + 1))
        [ "${tries}" -lt 15 ] || fail "the Accessibility pane did not show its Add button"
        sleep 2
    done
    click '.role=="button" and .label=="Add"'
    sleep 2
    testanyware input type "${VM_PASSWORD}" >/dev/null
    testanyware input key return >/dev/null
    sleep 4
    testanyware input key g --modifiers cmd,shift >/dev/null
    sleep 2
    testanyware input type "${INSTALLED}" >/dev/null
    sleep 2
    testanyware input key return >/dev/null
    sleep 2
    testanyware input key return >/dev/null
    sleep 3
    [ "$(element '.label=="Koine" or .value=="Koine"')" != null ] || fail "Koine is not in the Accessibility list"
    unset SNAPSHOT_WINDOW
    testanyware input key q --modifiers cmd >/dev/null
    sleep 2
}

start_vm
install_app
testanyware file upload scripts/vm-verify-desktop-client.py /Users/admin/vm-verify-desktop-client.py >/dev/null

step "The desktop provider sealed in the signed bundle"
guest "find ${INSTALLED}/Contents/PlugIns -maxdepth 2"
guest "codesign --verify --strict --verbose=2 ${INSTALLED}/Contents/PlugIns/Desktop.koineprovider 2>&1"
guest "codesign -dvv ${INSTALLED}/Contents/PlugIns/Desktop.koineprovider 2>&1 | grep -E '^(Identifier|CodeDirectory|TeamIdentifier|Authority=Developer)'"

step "Launch Koine and create two grants in its window"
launch
create_grant "vm-desktop-reader" "${CREDENTIAL_FILE}" koine:manage desktop:read
create_grant "vm-desktop-stranger" "${STRANGER_FILE}" desktop:control

step "koineManagement.providers reports the desktop provider ACTIVE, with both capabilities"
ask "${Q_PROVIDERS}"
[ "$(sed -n 1p <<<"${RESPONSE}" | jq -r '.data.koineManagement.providers[] | select(.provider == "desktop") | .state')" = ACTIVE ] ||
    fail "the desktop provider is not ACTIVE"
for capability in desktop:read desktop:control; do
    sed -n 1p <<<"${RESPONSE}" | jq -e --arg c "${capability}" '.data.koine.availableCapabilities | index($c)' >/dev/null ||
        fail "${capability} is not an available capability"
done

step "Real windows: two Finder windows with the same title"
# What these open is asserted below, so a guest exec that only reports a timeout
# does not end the run.
guest "open -a Finder" || true
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 2

step "Before consent: windows are an error, at desktopApplication.windows (recorded; classified by the next leaf)"
desktop "${CREDENTIAL_FILE}" Finder exact
expect '.response.errors | length > 0' "windows were listed without Accessibility consent"

step "Give Koine Accessibility consent in System Settings"
grant_accessibility

step "Resolve Finder by pid and startedAt, and list its windows"
desktop "${CREDENTIAL_FILE}" Finder exact
expect '(.response.errors // []) | length == 0' "resolving Finder reported errors"
expect '.response.data.desktopApplication | .name == "Finder" and .bundleIdentifier == "com.apple.finder"' "Finder did not resolve"
expect '.response.data.desktopApplication.ref | startswith("koine://desktop/application/")' "no application reference"
# Finder's desktop is an element of its window list and no window: every row is
# one of the titled windows opened above, and none is manufactured for it.
expect '.response.data.desktopApplication.windows | length >= 2 and all(.title != "")' "Finder does not list only its real windows"
expect '.response.data.desktopApplication.windows | ([.[].title] | unique | length == 1) and ([.[].ref] | unique | length) == length' \
    "the same-titled windows do not carry distinct references"
expect '.response.data.desktopApplication.windows | all(.observation == "CURRENT" and (.ref | startswith("koine://desktop/window/")))' \
    "a window is not CURRENT with a window reference"
FIRST_REFS="$(jq -c '[.response.data.desktopApplication.windows[].ref] | sort' <<<"${ANSWER}")"
desktop "${CREDENTIAL_FILE}" Finder exact
[ "$(jq -c '[.response.data.desktopApplication.windows[].ref] | sort' <<<"${ANSWER}")" = "${FIRST_REFS}" ] ||
    fail "a second listing gave the same windows other references"

step "The same live PID with another startedAt, and an absent process, are ordinary null"
for case in later absent; do
    desktop "${CREDENTIAL_FILE}" Finder "${case}"
    expect '.response.data.desktopApplication == null and ((.response.errors // []) | length == 0)' "${case}: not an ordinary null"
done

step "A startedAt that is not in the canonical form is an input error, never a fallback to the PID"
desktop "${CREDENTIAL_FILE}" Finder malformed
expect '.response.data.desktopApplication == null and (.response.errors | length == 1) and (.response.errors[0].extensions.kind == null)' \
    "the malformed start instant was not an input error"

step "A grant without desktop:read is refused"
desktop "${STRANGER_FILE}" Finder exact
expect '.response.errors[0].extensions | .kind == "permission" and .permissionClass == "capability" and .requiredCapability == "desktop:read"' \
    "the missing capability was not reported"

step "Quit Koine"
quit_koine

step "PASSED — transcript in ${LOG}"
