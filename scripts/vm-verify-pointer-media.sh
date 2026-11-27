#!/bin/bash
# shellcheck disable=SC2016  # guest-side $HOME
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM, the happy
# path of pointer and media (Koine 0.6.0, desktop 1.0.2) with a real player.
# The Settings window shows the served desktop disclosures for a new grant, a
# grant request and the grant list, and again for the existing grants after a
# restart. A reading grant reads the pointer position. A controlling grant
# nudges the pointer and posts the six media keys while Music plays a local
# playlist of three silent tracks in the background and TextEdit stays in front.
#
# Koine never witnesses its own answers. Fixtures/WindowIdentityProbe, an
# independent signed tool, reads the pointer, the front app and every
# mouse-moved, key and system-defined event at the session event tap.
# scripts/vm-verify-pointer-media-music.applescript reads Music's player state
# through Apple events, and the output volume through Standard Additions. Every
# operation is sent with the text of
# docs/design/desktop-pointer-media-operations.graphql. Nothing here runs the
# application, moves the pointer or posts a key on the host. The tracks are
# silent, because the sound of the guest reaches the speakers of the host. The
# procedure and its recorded evidence: docs/verification/desktop-pointer-media-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="pointer-media-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

PROBE="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"
# shellcheck disable=SC2016  # guest-side $HOME
POINTER_OPERATIONS='$HOME/desktop-pointer-media-operations.graphql'
# shellcheck disable=SC2016  # guest-side $HOME
REQUESTER='$HOME/koine-secret-pointer-requester'
# shellcheck disable=SC2016  # guest-side $HOME
MUSIC='osascript $HOME/vm-verify-pointer-media-music.applescript'
# The agreed tolerance of the position read: one point.
TOLERANCE=1
# Each track lasts five minutes, so that no track ends by itself during a case.
TRACK_SECONDS=300

# What the served desktop disclosures must state: the reach of pointer and media
# (docs/specs/machine.md, "Capability disclosures").
CONTROL_PHRASES=("Nudges the pointer one point to the right and back" "Now Playing app" "play/pause can make macOS open Music"
    "Posts volume up, volume down and mute" "It never clicks, and it never types into an app" "earlier Koine version that holds desktop:control")
READ_PHRASES=("reads the position of the pointer" "earlier Koine version that holds desktop:read")

# key_number <DesktopMediaKey>: its NX_KEYTYPE number, as docs/specs/machine.md, "Media keys", states it.
key_number() {
    case "$1" in
    PLAY_PAUSE) echo 16 ;;
    NEXT) echo 19 ;;
    PREVIOUS) echo 20 ;;
    VOLUME_UP) echo 0 ;;
    VOLUME_DOWN) echo 1 ;;
    MUTE) echo 7 ;;
    *) fail "no key number for $1" ;;
    esac
}

no_errors() { expect '(.response.errors // []) | length == 0' "$1 reported errors"; }
# pointer_client <credential file> <case> [argument...]: one guest client call, for a read
# that can be repeated; its one JSON line is left in ANSWER.
pointer_client() {
    local file="$1"
    shift
    ANSWER="$(guest_json "python3 \$HOME/vm-verify-pointer-media-client.py \"${file}\" \"${POINTER_OPERATIONS}\" $*")" ||
        fail "the pointer and media client printed no JSON for: $*"
    echo "${ANSWER}"
}
pointer() {
    POINTER="$(guest_json "\$HOME/WindowIdentityProbe pointer")"
    echo "${POINTER}"
}
guest_now() { guest_text 'date "+%Y-%m-%d %H:%M:%S"' | tail -1; }
# rcd_log <since>: the media commands that rcd sent through MediaRemote since then.
rcd_log() {
    guest_text "log show --start \"$1\" --style compact --predicate 'process == \"rcd\"' 2>/dev/null | grep -E 'Request: Command' | cut -c1-160" |
        sed 's/^/  | /'
}
front_app() { guest_json "\$HOME/WindowIdentityProbe focused" | jq -r '.application.name // "none"'; }
music_state() {
    MUSIC_STATE="$(guest_json "${MUSIC} state")" || fail "the Music witness printed no JSON"
    echo "Music: ${MUSIC_STATE}"
}
volume_state() {
    VOLUME="$(guest_json "${MUSIC} volume")" || fail "the volume witness printed no JSON"
    echo "Volume: ${VOLUME}"
}
# BEFORE_POST, when set, is a guest command that runs just before the post, in the
# same guest command, so that nothing waits between the two.
BEFORE_POST=''
# witnessed <name> <client case> [argument...]: under the controlling grant, one
# operation that must run exactly once, inside a window of the event witness.
# `guest` repeats a command that the agent reports as timed out, and a second
# media key changes the state under test. So the witness and the call each take
# a guard directory, and a repeat only prints the first answer. Koine's answer is
# left in ANSWER and the witness's events in EVENTS.
witnessed() {
    local name="$1"
    shift
    guest "mkdir \$HOME/${name}.events.started 2>/dev/null || exit 0; nohup \$HOME/WindowIdentityProbe events 5 > \$HOME/${name}.events.json 2>&1 &" ||
        fail "the event witness did not start for ${name}"
    sleep 1
    ANSWER="$(guest_json "mkdir \$HOME/${name}.started 2>/dev/null && ${BEFORE_POST:+${BEFORE_POST} >/dev/null && }python3 \$HOME/vm-verify-pointer-media-client.py \"${CONTROLLER_FILE}\" \"${POINTER_OPERATIONS}\" $* > \$HOME/${name}.json; cat \$HOME/${name}.json")" ||
        fail "the pointer and media client printed no JSON for ${name}"
    echo "${ANSWER}"
    local tries=0
    until EVENTS="$(guest_json "cat \$HOME/${name}.events.json" 2>/dev/null)"; do
        tries=$((tries + 1))
        [ "${tries}" -lt 15 ] || fail "the event witness gave no answer for ${name}"
        sleep 1
    done
    jq -e '.tap == true' >/dev/null <<<"${EVENTS}" || fail "the event witness has no event tap: ${EVENTS}"
    echo "Witnessed events: $(jq -c '[.events[] | del(.time)]' <<<"${EVENTS}")"
}
# no_keystroke: the window of the event witness saw no key event at all.
no_keystroke() {
    jq -e '[.events[] | select(.kind == "keyDown" or .kind == "keyUp" or .kind == "flagsChanged")] | length == 0' >/dev/null <<<"${EVENTS}" ||
        fail "a key event passed the session event tap: $1"
}
# press <name> <DesktopMediaKey>: the key under the controlling grant, its receipt,
# and the witness's view of it: exactly one system-defined event of subtype 8 down
# and one up, with the key number of the contract, no key event, and TextEdit in front.
press() {
    local number
    number="$(key_number "$2")"
    witnessed "$1" key "$2"
    expect "((.response.errors // []) | length == 0) and (.response.data.desktopPostMediaKey == {key: \"$2\"})" \
        "$2 did not return its receipt"
    jq -e --argjson down $(((number << 16) | (0xA << 8))) --argjson up $(((number << 16) | (0xB << 8))) \
        '[.events[] | select(.kind == "systemDefined" and .subtype == 8) | .data1] == [$down, $up]' >/dev/null <<<"${EVENTS}" ||
        fail "the witness did not see $2 as key ${number} down and then up"
    no_keystroke "$2"
    sleep 2
    local front
    front="$(front_app)"
    [ "${front}" = TextEdit ] || fail "TextEdit is not in front after $2: ${front}"
    echo "Observation: Koine posted $2 as key ${number} down and up; no key event passed; TextEdit stays in front."
}
# No consent dialog of any kind names Koine: Accessibility's says "would like to
# control", and the Screen Recording dialog says "would like to record".
no_dialog() {
    no_consent_dialog "$1"
    local found
    found="$(testanyware screen find-text "would like to" --json)" || fail "the screen could not be read"
    jq -e '.ok == true and .total == 0' >/dev/null <<<"${found}" || fail "a permission dialog is showing: $1"
}
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
# click_text <text> <seconds> <what>: the same, and the run fails when there is none.
click_text() { try_click_text "$1" "$2" || fail "$3: no \"$1\" on screen"; }

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

# Three silent tracks, made on the host and played only in the guest.
mkdir -p "${WORK}/silence"
for n in 1 2 3; do
    python3 - "${WORK}/silence/silence-${n}.wav" "${TRACK_SECONDS}" <<'EOF'
import sys, wave
with wave.open(sys.argv[1], "wb") as track:
    track.setnchannels(1)
    track.setsampwidth(2)
    track.setframerate(22050)
    track.writeframes(b"\0\0" * 22050 * int(sys.argv[2]))
EOF
    afconvert -f m4af -d aac "${WORK}/silence/silence-${n}.wav" "${WORK}/silence/Koine Silence ${n}.m4a"
    rm "${WORK}/silence/silence-${n}.wav"
done

start_vm
install_app
testanyware file upload scripts/vm-verify-pointer-media-client.py /Users/admin/vm-verify-pointer-media-client.py >/dev/null
testanyware file upload scripts/vm-verify-pointer-media-music.applescript /Users/admin/vm-verify-pointer-media-music.applescript >/dev/null
testanyware file upload scripts/vm-verify-enrollment-client.py /Users/admin/vm-verify-enrollment-client.py >/dev/null
testanyware file upload docs/design/desktop-pointer-media-operations.graphql /Users/admin/desktop-pointer-media-operations.graphql >/dev/null
testanyware file upload "${PROBE}" /Users/admin/WindowIdentityProbe >/dev/null
guest 'mkdir -p $HOME/KoineSilence'
for n in 1 2 3; do
    testanyware file upload "${WORK}/silence/Koine Silence ${n}.m4a" "/Users/admin/KoineSilence/Koine Silence ${n}.m4a" >/dev/null
done
# shellcheck disable=SC2016  # guest-side $HOME
guest 'chmod +x $HOME/WindowIdentityProbe; echo front > $HOME/front.txt; echo pointer > $HOME/pointer.txt; ls -l $HOME/KoineSilence'

step "Launch Koine and create a reading grant in the window"
launch
create_grant "vm-pointer-reader" "${CREDENTIAL_FILE}" koine:manage desktop:read

step "The served desktop disclosures state the reach of pointer and media"
pointer_client "${CREDENTIAL_FILE}" disclosures
no_errors "capabilityDisclosures"
expect '.response.data.koineManagement.capabilityDisclosures | map(.capability) == ["desktop:control","desktop:read","workspace:control","workspace:read"]' \
    "the served disclosures are not the two desktop ones and the two workspace ones"
DISCLOSURES="${ANSWER}"

step "The create-grant view: a new grant shows both desktop disclosures"
expect_served "disclosure-desktop:read" "the create-grant view, for desktop read" desktop:read
expect_served "disclosure-desktop:control" "the create-grant view, for desktop control" desktop:control
capture create-grant
create_grant "vm-pointer-controller" "${CONTROLLER_FILE}" desktop:control

step "The request view: a pending request for desktop read and desktop control shows both disclosures"
ANSWER="$(guest_json "python3 \$HOME/vm-verify-enrollment-client.py \"${REQUESTER}\" enrol pointer-requester desktop:read desktop:control")" ||
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

step "The grant list: each grant shows the disclosure of each desktop capability it holds"
pointer_client "${CREDENTIAL_FILE}" grants
no_errors "koineManagement.grants"
GRANTS_BEFORE="$(jq -c '.response.data.koineManagement.grants' <<<"${ANSWER}")"
grant_id() { jq -r --arg l "$1" 'map(select(.clientLabel == $l))[0].grantId' <<<"${GRANTS_BEFORE}"; }
READER_GRANT="$(grant_id vm-pointer-reader)"
CONTROLLER_GRANT="$(grant_id vm-pointer-controller)"
REQUESTER_GRANT="$(grant_id pointer-requester)"
jq -e 'map(select(.clientLabel == "pointer-requester"))[0] | .state == "ACTIVE" and (.capabilities | sort) == ["desktop:control","desktop:read"]' >/dev/null <<<"${GRANTS_BEFORE}" ||
    fail "the approved grant is not desktop:read and desktop:control"
expect_served "grant-disclosure-${READER_GRANT}-desktop:read" "the reading grant's row" desktop:read
expect_served "grant-disclosure-${CONTROLLER_GRANT}-desktop:control" "the controlling grant's row" desktop:control
expect_served "grant-disclosure-${REQUESTER_GRANT}-desktop:read" "the approved grant's row, for desktop read" desktop:read
expect_served "grant-disclosure-${REQUESTER_GRANT}-desktop:control" "the approved grant's row, for desktop control" desktop:control
capture grant-list

step "Give Koine Accessibility consent in System Settings"
grant_accessibility

step "The pointer position: Koine reads where the witness reads the pointer, within one point"
for spot in "700 420" "1310 777"; do
    # shellcheck disable=SC2086  # two coordinates
    testanyware input move ${spot} >/dev/null
    sleep 1
    pointer
    pointer_client "${CREDENTIAL_FILE}" position
    no_errors "DesktopPointerPosition"
    KOINE_POINT="$(jq -c '.response.data.desktopPointer.location' <<<"${ANSWER}")"
    [ "${KOINE_POINT}" != null ] || fail "Koine cannot establish the pointer position"
    jq -en --argjson k "${KOINE_POINT}" --argjson w "$(jq -c '.point' <<<"${POINTER}")" --argjson t "${TOLERANCE}" \
        '($k.x - $w[0] | fabs) <= $t and ($k.y - $w[1] | fabs) <= $t' >/dev/null ||
        fail "Koine reads ${KOINE_POINT}, and the witness reads $(jq -c '.point' <<<"${POINTER}")"
    echo "Observation: Koine reads ${KOINE_POINT}; the witness reads $(jq -c '.point' <<<"${POINTER}")."
done

step "The nudge: the pointer moves one point to the right and back, with two mouse-moved events, and ends where it started"
guest 'open -a TextEdit $HOME/pointer.txt' || true
sleep 4
[ "$(front_app)" = TextEdit ] || fail "TextEdit is not in front for the nudge"
# Typing makes TextEdit hide the pointer until the mouse moves. The witness records
# what CGCursorIsVisible says before and after the nudge, as an observation only.
testanyware input type "typed" >/dev/null
sleep 1
pointer
START="$(jq -c '.point' <<<"${POINTER}")"
echo "Observation: before the nudge, CGCursorIsVisible says $(jq -c '.cursorVisible' <<<"${POINTER}")."
witnessed nudge nudge
expect "((.response.errors // []) | length == 0) and (.response.data.desktopNudgePointer == {outcome: \"NUDGED\"})" \
    "the nudge did not report NUDGED"
jq -e --argjson s "${START}" '[.events[] | select(.kind == "mouseMoved") | .point] as $m
    | ($m | length) == 2 and ($m[0][0] - ($s[0] + 1) | fabs) <= 0.5 and ($m[0][1] - $s[1] | fabs) <= 0.5
    and ($m[1][0] - $s[0] | fabs) <= 0.5 and ($m[1][1] - $s[1] | fabs) <= 0.5' >/dev/null <<<"${EVENTS}" ||
    fail "the witness did not see two mouse-moved events, one point to the right of ${START} and then back"
no_keystroke "the nudge"
pointer
jq -en --argjson p "$(jq -c '.point' <<<"${POINTER}")" --argjson s "${START}" '($p[0] - $s[0] | fabs) <= 0.5 and ($p[1] - $s[1] | fabs) <= 0.5' >/dev/null ||
    fail "the pointer is at $(jq -c '.point' <<<"${POINTER}"), not back at ${START}"
jq -e '.pressedMouseButtons == 0' >/dev/null <<<"${POINTER}" || fail "a pointer button is held after the nudge"
echo "Observation: the pointer is back at ${START} with no button held. After the nudge, CGCursorIsVisible says $(jq -c '.cursorVisible' <<<"${POINTER}")."

step "Music: open it, pass its welcome window, and allow the witness to ask it for its state"
guest 'open -a Music' || true
click_text "Start Listening" 60 "the welcome window of Music"
sleep 5
# Music then asks in a sheet of its own whether it may notify about new music.
# "Not Now" declines, so that macOS asks nothing about Music's notifications.
capture music-notifications-sheet
click_text "Not Now" 30 "the notification sheet of Music"
sleep 3
testanyware screen find-text "Hear About New Music First" --json | jq -e '.ok == true and .total == 0' >/dev/null ||
    fail "the notification sheet of Music is still showing"
capture music-welcome-passed
# The first Apple event to Music raises a macOS Automation prompt that names
# testanyware-agent, which runs the witness. It is answered as a user would.
guest "nohup ${MUSIC} state >/dev/null 2>&1 &" || true
click_text "Allow" 30 "the Automation prompt for Music"
sleep 2
music_state

step "Music plays the three silent tracks of a local playlist in the background, and TextEdit is in front"
MUSIC_SETUP="$(guest_json "mkdir \$HOME/music-setup.started 2>/dev/null && ${MUSIC} setup \$HOME/KoineSilence > \$HOME/music-setup.json; cat \$HOME/music-setup.json")" ||
    fail "the playlist could not be made"
echo "Setup: ${MUSIC_SETUP}"
guest 'open -a TextEdit $HOME/front.txt' || true
sleep 5
music_state
jq -e '.state == "playing" and .track == "Koine Silence 1" and .playlistTracks == 3' >/dev/null <<<"${MUSIC_STATE}" ||
    fail "Music does not play the first of the three tracks"
[ "$(front_app)" = TextEdit ] || fail "TextEdit is not in front while Music plays"
capture music-playing
# The dialog check at the end reads only what the keys caused: nothing that names
# Music or Koine asks for a permission before the cases.
no_dialog "before the media keys"

step "PLAY_PAUSE pauses Music, and PLAY_PAUSE again resumes it"
press play-pause-1 PLAY_PAUSE
music_state
jq -e '.state == "paused"' >/dev/null <<<"${MUSIC_STATE}" || fail "PLAY_PAUSE did not pause Music"
press play-pause-2 PLAY_PAUSE
music_state
jq -e '.state == "playing"' >/dev/null <<<"${MUSIC_STATE}" || fail "PLAY_PAUSE did not resume Music"

step "NEXT goes to the next track"
SINCE="$(guest_now)"
press next NEXT
rcd_log "${SINCE}"
music_state
jq -e '.state == "playing" and .track == "Koine Silence 2"' >/dev/null <<<"${MUSIC_STATE}" || fail "NEXT did not go to the next track"

step "PREVIOUS goes back: to the start of the current track or to the previous track, as Music decides"
sleep 6
music_state
jq -e '.track == "Koine Silence 2" and .position >= 5' >/dev/null <<<"${MUSIC_STATE}" || fail "the second track has not played for 5 seconds"
BEFORE="$(jq -r '.position' <<<"${MUSIC_STATE}")"
SINCE="$(guest_now)"
press previous-1 PREVIOUS
rcd_log "${SINCE}"
music_state
# Without an effect, the position would be BEFORE plus the seconds that the press took.
if jq -e --argjson b "${BEFORE}" '.state == "playing" and .track == "Koine Silence 2" and .position < $b' >/dev/null <<<"${MUSIC_STATE}"; then
    echo "Observation: at second ${BEFORE}, PREVIOUS restarted the current track."
    # Music goes to the previous track only near the start of a track. So the position
    # is set to 0 in the same guest command as the post.
    BEFORE_POST="${MUSIC} set-position 0"
    press previous-2 PREVIOUS
    BEFORE_POST=''
    music_state
fi
jq -e '.state == "playing" and .track == "Koine Silence 1"' >/dev/null <<<"${MUSIC_STATE}" || fail "PREVIOUS did not go to the previous track"
echo "Observation: PREVIOUS went to the previous track."

step "VOLUME_UP and VOLUME_DOWN change the output volume, and MUTE switches the mute"
VOLUME="$(guest_json "${MUSIC} set-volume 50")" || fail "the output volume could not be set"
volume_state
jq -e '.outputVolume == 50 and .outputMuted == false' >/dev/null <<<"${VOLUME}" || fail "the output volume is not 50 and unmuted"
press volume-up VOLUME_UP
volume_state
jq -e '.outputVolume > 50' >/dev/null <<<"${VOLUME}" || fail "VOLUME_UP did not raise the output volume"
press volume-down VOLUME_DOWN
volume_state
jq -e '.outputVolume == 50' >/dev/null <<<"${VOLUME}" || fail "VOLUME_DOWN did not lower the output volume back to 50"
press mute-on MUTE
volume_state
jq -e '.outputMuted == true' >/dev/null <<<"${VOLUME}" || fail "MUTE did not mute the output"
press mute-off MUTE
volume_state
jq -e '.outputMuted == false' >/dev/null <<<"${VOLUME}" || fail "MUTE did not switch the mute off"
music_state
capture media-keys
no_dialog "after the nudge and the six media keys"

step "Quit and restart Koine: the existing grants keep their disclosures, and nothing was revoked or reauthorised"
quit_koine
launch
pointer_client "${CREDENTIAL_FILE}" grants
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
