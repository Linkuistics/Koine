#!/bin/bash
# shellcheck disable=SC2016  # guest-side $HOME
# Checks, in a clean TestAnyware macOS VM with no player running, what macOS does
# with a media key that Koine will post: a system-defined event of subtype 8,
# down and then up, at the HID event tap, as Modaliser posts it. The design of
# pointer and media (pointer-media-k2) needs the answer for the desktop:control
# disclosure: does macOS open Music when no app holds Now Playing?
#
# Fixtures/MediaKeyProbe posts each key once. Volume down and volume up first
# prove that a posted key takes effect. Then, with TextEdit in front, the run
# posts next, previous and play/pause. After each key it reads whether Music
# runs, which app is in front (Fixtures/WindowIdentityProbe) and what rcd and
# mediaremoted logged. Koine is not installed. Nothing here posts a key on the
# host. The procedure and its recorded evidence:
# docs/verification/media-key-music-launch.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_NO_APP=1
# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="media-key-music-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

MEDIA_PROBE="$(Fixtures/MediaKeyProbe/build.sh .build/media-key-probe)"
WITNESS="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"

# post_once <name> <key>: posts the key at most once. `guest` repeats a command
# that the agent reports as timed out, and a second post would change the state
# under test. So the post takes a guard directory, and a repeat that finds the
# directory only prints the first answer. Prints the probe's JSON line.
post_once() {
    local answer
    answer="$(guest_json "mkdir \$HOME/$1.started 2>/dev/null && \$HOME/MediaKeyProbe post $2 > \$HOME/$1.json; cat \$HOME/$1.json")" ||
        fail "the probe printed no answer for $2"
    jq -e '.trusted and .postAccess and .posted' >/dev/null <<<"${answer}" ||
        fail "the probe could not post $2: ${answer}"
    echo "${answer}"
}
volume() { guest_text 'osascript -e "output volume of (get volume settings)"' | grep -E '^[0-9]+$' | tail -1; }
music_running() { guest 'pgrep -x Music' >/dev/null 2>&1; }
front_app() { guest_json '$HOME/WindowIdentityProbe focused' | jq -r '.application.name // "none"'; }
guest_now() { guest_text 'date "+%Y-%m-%d %H:%M:%S"' | tail -1; }
# daemon_log <since>: what rcd and mediaremoted logged about media commands since then.
daemon_log() {
    guest_text "log show --start \"$1\" --style compact --predicate 'process == \"rcd\" OR process == \"mediaremoted\"' 2>/dev/null | grep -E 'Request: Command|not available for command|requested a launch|MRDLaunchApplicationWithReason|Dropping command' | cut -c1-220" |
        sed 's/^/  | /'
}

start_vm
testanyware file upload "${MEDIA_PROBE}" /Users/admin/MediaKeyProbe >/dev/null
testanyware file upload "${WITNESS}" /Users/admin/WindowIdentityProbe >/dev/null
guest 'chmod +x $HOME/MediaKeyProbe $HOME/WindowIdentityProbe; echo front > $HOME/front.txt'

step "No player runs, and the guest has an output device"
guest 'pgrep -lx "Music|TV|Podcasts|QuickTime Player"' && fail "a player already runs"
guest_text 'system_profiler SPAudioDataType | grep -E "Default Output Device|^        [A-Z].*:$"'

step "Control: a posted volume key changes the output volume"
before="$(volume)"
post_once control-down volume-down
after="$(volume)"
echo "output volume ${before} -> ${after}"
[ -n "${before}" ] && [ -n "${after}" ] && [ "${after}" -lt "${before}" ] || fail "volume down did not lower the output volume"
post_once control-up volume-up
restored="$(volume)"
echo "output volume ${after} -> ${restored}"
[ "${restored}" -gt "${after}" ] || fail "volume up did not raise the output volume"

step "TextEdit in front"
guest 'open -a TextEdit $HOME/front.txt'
sleep 4
[ "$(front_app)" = TextEdit ] || fail "TextEdit is not in front"
echo "front app: TextEdit"

for key in next previous; do
    step "Post ${key} with no Now Playing app"
    since="$(guest_now)"
    post_once "music-${key}" "${key}"
    sleep 8
    if music_running; then fail "Music started after ${key}"; fi
    echo "Music: not running 8 s after ${key}; front app: $(front_app)"
    daemon_log "${since}"
done

step "Post play/pause with no Now Playing app"
since="$(guest_now)"
post_once music-play-pause play-pause
started=''
for second in 1 2 3 4 5 6 7 8 9 10; do
    sleep 1
    if music_running; then
        started="${second}"
        break
    fi
done
sleep 3
front="$(front_app)"
testanyware screen capture -o "${LOG%.log}-play-pause.png" >/dev/null 2>&1 || true
daemon_log "${since}"
if [ -n "${started}" ]; then
    echo "RESULT: macOS opened Music within ${started} s of play/pause; front app 3 s later: ${front}"
else
    echo "RESULT: Music did not start within 10 s of play/pause; front app: ${front}"
fi
echo "Screen: ${LOG%.log}-play-pause.png"
