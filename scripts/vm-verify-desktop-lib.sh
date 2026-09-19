# shellcheck shell=bash
# shellcheck disable=SC2016,SC2034  # guest-side $HOME; variables the sourcing script uses
# Sourced by the desktop VM verification scripts (vm-verify-desktop.sh,
# vm-verify-desktop-focus.sh) after scripts/vm-verify-lib.sh: grants made in
# Koine's window, the guest desktop client, the error shapes, and Accessibility
# consent given and revoked as a user does it, in System Settings.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).

VM_PASSWORD="${KOINE_VM_PASSWORD:-admin}"

# guest_json <command>: for a guest command whose whole answer is one JSON line.
# The agent's false "timed out" report (scripts/vm-verify-lib.sh, guest) comes in
# bursts that outlast any bound on retries: a focus that Koine had answered with
# its receipt was reported timed out twelve times running. A complete JSON answer
# proves the command ran to its end whatever status the agent gives it, and a
# truncated one does not parse, so that alone is accepted here. Prints the line.
guest_json() {
    local out status=0
    out="$(guest "$1" 2>&1)" || status=$?
    out="$(grep -v -e '^Process timed out after' -e '^guest exec kept timing out' <<<"${out}" | tail -1)"
    if jq -e . >/dev/null 2>&1 <<<"${out}"; then
        echo "${out}"
        return 0
    fi
    echo "${out}" >&2
    [ "${status}" != 0 ] || status=1
    return "${status}"
}

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
