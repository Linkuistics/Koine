#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM and with real
# applications, the first desktop path: the bundled desktop provider is ACTIVE,
# an application resolves by its process identity, a mismatched start instant and
# an absent process are ordinary null, a malformed one is an input error, windows
# with the same title carry distinct references, and a grant without desktop:read
# is refused. Then the references: the three lookups agree; a wrong-kind or
# malformed reference, a closed window, an ended process and a window reference
# from before a Koine restart are unavailable. And Accessibility consent: absent,
# and revoked while Koine runs, a read is an os-permission error and shows no
# consent dialog, which a control application is then seen to show. Consent is
# given to Koine as a user gives it, in System Settings. Nothing here runs the
# application on the host. The procedure and its recorded evidence:
# docs/verification/desktop-application-and-windows-vm.md
# and docs/verification/desktop-references-and-permission-vm.md
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
# lookup <application|application-plain|window> <reference>: by reference, with
# the reading grant; the answer is left in ANSWER.
lookup() {
    ANSWER="$(guest "python3 \$HOME/vm-verify-desktop-client.py \"${CREDENTIAL_FILE}\" --ref $1 '$2'" | tail -1)"
    echo "${ANSWER}"
    jq -e . >/dev/null <<<"${ANSWER}" || fail "the desktop client printed no JSON for $1 $2"
}
# An error at the field; never null without one, never a substitute.
expect_unavailable() {
    expect "(.response.data.$1 == null) and (.response.errors | length == 1) and (.response.errors[0] | .path == [\"$1\"] and .extensions.kind == \"unavailable\")" \
        "$2 was not unavailable at $1"
}
# expect_os_permission <jq path array>
expect_os_permission() {
    expect "(.response.errors | length == 1) and (.response.errors[0] | .path == $1 and (.extensions | .kind == \"permission\" and .permissionClass == \"os-permission\" and .osPermission == \"accessibility\" and .permissionOwner == \"koine\"))" \
        "not an os-permission error naming accessibility and koine at $1"
}
# The consent dialog is looked for as a user would see it: its text, read from
# the screen. The control at the end of the run is where this detector is seen to
# find one. The process that shows the dialog is no detector: macOS also starts
# it, showing nothing, when an untrusted application merely asks whether it is
# trusted (that is what lists Koine, switched off, in System Settings). Whether
# it runs is recorded, not asserted.
DIALOG_TEXT="would like to control"
DIALOG_HOST=universalAccessAuthWarn
no_consent_dialog() {
    sleep 3
    local found
    found="$(testanyware screen find-text "${DIALOG_TEXT}" --json)" || fail "the screen could not be read"
    jq -e '.ok == true and .total == 0' >/dev/null <<<"${found}" || fail "a consent dialog is showing: $1"
    echo "no consent dialog on screen ($1); ${DIALOG_HOST}: $(guest "pgrep -x ${DIALOG_HOST} >/dev/null && echo running || echo not running")"
}

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

# Revocation as a user does it: Koine's switch in the same pane, and the password
# macOS then asks for. The switch reads off before that sheet is answered, so its
# value proves nothing; the caller's next reads are the proof.
revoke_accessibility() {
    guest 'open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"' || true
    SNAPSHOT_WINDOW="System Settings"
    local tries=0
    until [ "$(value_of '.id=="Koine_Toggle"' 2>/dev/null)" = 1 ]; do
        tries=$((tries + 1))
        [ "${tries}" -lt 15 ] || fail "the Accessibility pane did not show Koine switched on"
        sleep 2
    done
    click '.id=="Koine_Toggle"'
    sleep 2
    testanyware input type "${VM_PASSWORD}" >/dev/null
    testanyware input key return >/dev/null
    unset SNAPSHOT_WINDOW
}

CONTROL="$(Fixtures/ConsentPromptControl/build.sh .build/control)"
ditto -c -k --keepParent "${CONTROL}" "${WORK}/control.zip"

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

step "Before consent: windows are an os-permission error at desktopApplication.windows, and nothing prompts"
desktop "${CREDENTIAL_FILE}" Finder exact
expect '.response.data.desktopApplication == null' "windows were listed without Accessibility consent"
expect_os_permission '["desktopApplication","windows"]'
no_consent_dialog "after a windows read without consent"
testanyware screen capture -o "${LOG%.log}-before-consent.png" >/dev/null

step "Before consent: the application fields need none, by identity and by reference"
desktop "${CREDENTIAL_FILE}" Finder plain
expect '((.response.errors // []) | length == 0) and (.response.data.desktopApplication | .name == "Finder" and .bundleIdentifier == "com.apple.finder")' \
    "the application did not resolve without consent"
FINDER_REF="$(jq -r '.response.data.desktopApplication.ref' <<<"${ANSWER}")"
lookup application-plain "${FINDER_REF}"
expect '((.response.errors // []) | length == 0) and (.response.data.desktopApplicationByReference.name == "Finder")' \
    "the application did not resolve by reference without consent"
lookup application "${FINDER_REF}"
expect_os_permission '["desktopApplicationByReference","windows"]'

step "Before consent: a grant without desktop:read still gets the capability class, not the OS one"
desktop "${STRANGER_FILE}" Finder exact
expect '.response.errors[0].extensions | .kind == "permission" and .permissionClass == "capability" and .requiredCapability == "desktop:read"' \
    "the missing capability was not reported as such without consent"
no_consent_dialog "after every read without consent"

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

step "The three lookups agree"
desktop "${CREDENTIAL_FILE}" Finder exact
BY_IDENTITY="$(jq -cS '.response.data.desktopApplication' <<<"${ANSWER}")"
lookup application "${FINDER_REF}"
expect '(.response.errors // []) | length == 0' "the application lookup by reference reported errors"
[ "$(jq -cS '.response.data.desktopApplicationByReference' <<<"${ANSWER}")" = "${BY_IDENTITY}" ] ||
    fail "the application by reference differs from the application by process identity"
WINDOW_REFS="$(jq -r '.windows[].ref' <<<"${BY_IDENTITY}")"
for ref in ${WINDOW_REFS}; do
    lookup window "${ref}"
    [ "$(jq -cS '.response.data.desktopWindow' <<<"${ANSWER}")" = "$(jq -cS --arg r "${ref}" '.windows[] | select(.ref == $r)' <<<"${BY_IDENTITY}")" ] ||
        fail "desktopWindow differs from the row in windows for ${ref}"
done

step "The other resource kind, and a remainder this provider does not produce, are unavailable"
FIRST_WINDOW="$(head -1 <<<"${WINDOW_REFS}")"
lookup application "${FIRST_WINDOW}"
expect_unavailable desktopApplicationByReference "a window reference"
lookup window "${FINDER_REF}"
expect_unavailable desktopWindow "an application reference"
lookup application "${FINDER_REF}/"
expect_unavailable desktopApplicationByReference "a malformed remainder"
lookup window "${FIRST_WINDOW%/*}"
expect_unavailable desktopWindow "a malformed remainder"
lookup window "${FIRST_WINDOW%/*}/999999"
expect_unavailable desktopWindow "a token this run never issued"

step "A closed window is unavailable; the same-titled windows beside it still resolve"
guest "open -a Finder" || true
sleep 2
testanyware input key w --modifiers cmd >/dev/null
sleep 3
CLOSED=0
for ref in ${WINDOW_REFS}; do
    lookup window "${ref}"
    if jq -e '.response.data.desktopWindow != null' >/dev/null <<<"${ANSWER}"; then
        expect ".response.data.desktopWindow.ref == \"${ref}\" and ((.response.errors // []) | length == 0)" \
            "an open window resolved as another"
    else
        expect_unavailable desktopWindow "the closed window"
        CLOSED=$((CLOSED + 1))
    fi
done
[ "${CLOSED}" = 1 ] || fail "${CLOSED} window references became unavailable when one window closed"

step "An ended process: its application and window references are unavailable"
guest "open -a Stickies" || true
sleep 4
desktop "${CREDENTIAL_FILE}" Stickies exact
expect '.response.data.desktopApplication.windows | length >= 1' "Stickies lists no window"
STICKIES_REF="$(jq -r '.response.data.desktopApplication.ref' <<<"${ANSWER}")"
STICKIES_WINDOW="$(jq -r '.response.data.desktopApplication.windows[0].ref' <<<"${ANSWER}")"
guest "killall Stickies" || true
sleep 3
guest "! pgrep -x Stickies" >/dev/null || fail "Stickies still runs"
lookup application-plain "${STICKIES_REF}"
expect_unavailable desktopApplicationByReference "the ended application"
lookup window "${STICKIES_WINDOW}"
expect_unavailable desktopWindow "a window of the ended application"

step "Across a Koine restart: an application reference resolves again, a window reference is unavailable"
desktop "${CREDENTIAL_FILE}" Finder exact
LIVE_WINDOW="$(jq -r '.response.data.desktopApplication.windows[0].ref' <<<"${ANSWER}")"
lookup application-plain "${FINDER_REF}"
BEFORE_RESTART="$(jq -cS '.response.data.desktopApplicationByReference' <<<"${ANSWER}")"
quit_koine
launch
lookup application-plain "${FINDER_REF}"
[ "$(jq -cS '.response.data.desktopApplicationByReference' <<<"${ANSWER}")" = "${BEFORE_RESTART}" ] ||
    fail "the application reference did not resolve to the same application after the restart"
lookup window "${LIVE_WINDOW}"
expect_unavailable desktopWindow "a window reference from before the restart"
desktop "${CREDENTIAL_FILE}" Finder exact
expect ".response.data.desktopApplication.windows | length >= 1 and all(.ref != \"${LIVE_WINDOW}\")" \
    "the new run did not list the open windows under its own references"
LIVE_WINDOW="$(jq -r '.response.data.desktopApplication.windows[0].ref' <<<"${ANSWER}")"

step "Consent revoked while Koine runs, by its switch in System Settings: how soon reads report it is recorded"
revoke_accessibility
REVOKED_AT="$(date +%s)"
until desktop "${CREDENTIAL_FILE}" Finder exact && jq -e '.response.errors | length > 0' >/dev/null <<<"${ANSWER}"; do
    [ $(($(date +%s) - REVOKED_AT)) -lt 60 ] || fail "windows were still listed 60s after consent was revoked"
    sleep 2
done
echo "Observation: the first read to report revoked consent completed $(($(date +%s) - REVOKED_AT))s after the password was entered."
expect_os_permission '["desktopApplication","windows"]'
lookup window "${LIVE_WINDOW}"
expect_os_permission '["desktopWindow"]'
lookup application-plain "${FINDER_REF}"
expect '((.response.errors // []) | length == 0) and (.response.data.desktopApplicationByReference.name == "Finder")' \
    "the application did not resolve by reference after consent was revoked"
no_consent_dialog "after reads with consent revoked"
testanyware screen capture -o "${LOG%.log}-after-revocation.png" >/dev/null
testanyware input key q --modifiers cmd >/dev/null # System Settings
sleep 2

step "Quit Koine"
quit_koine

step "Control: an application that asks with the prompt option does show the dialog this run looked for"
testanyware file upload "${WORK}/control.zip" /Users/admin/control.zip >/dev/null
# shellcheck disable=SC2016  # guest-side $HOME
guest 'cd $HOME && ditto -x -k control.zip . && open $HOME/ConsentPromptControl.app' || true
sleep 5
testanyware screen find-text "${DIALOG_TEXT}" --timeout 20 --require-match --json | jq -c '.detections[0]' ||
    fail "the control showed no consent dialog: the detector proves nothing"
testanyware screen capture -o "${LOG%.log}-control-dialog.png" >/dev/null

step "PASSED — transcript in ${LOG}"
