#!/bin/bash
# The scheduled host check of app input (app-input-acceptance-k6), on Antony's
# Mac, at a time that he sets and with the procedure and chords that he
# approved. The signed Koine 0.7.0 candidate (.build/app/Koine.app, task app)
# sends one chord each to Dia and Telegram, which a VM cannot run past their
# accounts. The check proves route A for Chromium and Qt. It proves no row of
# these apps. The procedure and its recorded evidence: docs/verification/app-input-host.md
#
# The check runs in phases, because Antony acts between them:
#
#   record    the start state: the installed Koine, the front app, Dia and Telegram
#   backup    with the installed Koine quit, a manifest and a copy of its data directory
#   launch    the candidate, from its build path, on the same data directory
#   enrol     a grant request for input:read and input:control (Antony approves it in the window)
#   poll      the request's state
#   send <dia|telegram>   the app to the front, target capture, and the one chord
#   front     the app that was in front at the start, to the front again
#   restore   with the candidate quit, the data directory exactly as the backup found it, and the
#             installed Koine again if it ran at the start
#
# Each phase refuses unless KOINE_HOST_CHECK=approved, so nothing runs by accident.
# Nothing here asks for a permission. The installed Koine's Accessibility consent
# covers the candidate, which has the same identifier and Team ID. If the
# candidate reports os-permission, it sent nothing: stop and restore.
set -euo pipefail

cd "$(dirname "$0")/.."
[ "${KOINE_HOST_CHECK:-}" = approved ] || {
    echo "Error: the host check runs only at the time Antony set, with KOINE_HOST_CHECK=approved." >&2
    exit 2
}
CANDIDATE="$(pwd)/.build/app/Koine.app"
INSTALLED=/Applications/Koine.app
DATA="${HOME}/Library/Application Support/Koine"
BACKUP="${HOME}/Library/Application Support/Koine.host-check-backup"
EVIDENCE="$(pwd)/.build/host-check"
SECRET="${EVIDENCE}/secret"
OPERATIONS="$(pwd)/docs/design/input-operations.graphql"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
mkdir -p "${EVIDENCE}"
chmod 700 "${EVIDENCE}"
exec > >(tee -a "${EVIDENCE}/host-check.log") 2>&1

say() { printf '\n== %s %s\n' "$(date '+%H:%M:%S')" "$*"; }
fail() {
    echo "FAILED: $*"
    exit 1
}
front_bundle() { lsappinfo info -only bundleID "$(lsappinfo front)" | grep -o 'bundleID="[^"]*"' | cut -d'"' -f2; }
koine_pids() { pgrep -f "$1/Contents/MacOS/Koine" || true; }
# manifest: one line per file of the data directory, with its SHA-256, in a stable order.
manifest() { (cd "$1" && find . -type f ! -name instance.lock -print0 | sort -z | xargs -0 shasum -a 256); }
client() { python3 scripts/vm-verify-app-input-client.py "${SECRET}" "${OPERATIONS}" "$@"; }

case "${1:-}" in
record)
    say "The start state"
    echo "installed Koine: $(defaults read "${INSTALLED}/Contents/Info.plist" CFBundleShortVersionString), $(codesign -dvvv "${INSTALLED}" 2>&1 | grep '^CDHash=')"
    if [ -n "$(koine_pids "${INSTALLED}")" ]; then echo yes; else echo no; fi >"${EVIDENCE}/installed-running-at-start"
    echo "installed Koine running: $(cat "${EVIDENCE}/installed-running-at-start") $(koine_pids "${INSTALLED}" | tr '\n' ' ')"
    echo "candidate: $(defaults read "${CANDIDATE}/Contents/Info.plist" CFBundleShortVersionString), $(codesign -dvvv "${CANDIDATE}" 2>&1 | grep '^CDHash=')"
    front_bundle >"${EVIDENCE}/front-at-start"
    echo "front app: $(cat "${EVIDENCE}/front-at-start")"
    echo "Dia: pid $(pgrep -x Dia || echo none); Telegram: pid $(pgrep -x Telegram || echo none)"
    echo "Antony quits the installed Koine from its menu, if it runs."
    ;;
backup)
    say "Copy the data directory of the installed Koine"
    [ -z "$(koine_pids "${INSTALLED}")" ] || fail "the installed Koine still runs. Quit it from its menu first."
    [ ! -e "${BACKUP}" ] || fail "${BACKUP} already exists. Look at it before anything replaces it."
    manifest "${DATA}" >"${EVIDENCE}/data-at-start.sha256"
    echo "data directory: $(wc -l <"${EVIDENCE}/data-at-start.sha256" | tr -d ' ') files, manifest $(shasum -a 256 "${EVIDENCE}/data-at-start.sha256" | cut -c1-12)"
    /usr/bin/ditto "${DATA}" "${BACKUP}"
    manifest "${BACKUP}" | diff - "${EVIDENCE}/data-at-start.sha256" || fail "the copy differs from the data directory"
    echo "copy: ${BACKUP}, identical to the record"
    ;;
launch)
    say "Launch the candidate from its build path"
    [ -d "${BACKUP}" ] || fail "no copy of the data directory. Run backup first."
    [ -z "$(koine_pids "${INSTALLED}")" ] || fail "the installed Koine runs"
    open "${CANDIDATE}"
    for _ in $(seq 1 20); do
        [ -n "$(koine_pids "${CANDIDATE}")" ] && [ "${DATA}/endpoint.json" -nt "${BACKUP}" ] && break
        sleep 1
    done
    [ -n "$(koine_pids "${CANDIDATE}")" ] || fail "the candidate did not start"
    echo "candidate running: pid $(koine_pids "${CANDIDATE}" | tr '\n' ' '); endpoint written $(stat -f '%Sm' "${DATA}/endpoint.json")"
    ;;
enrol)
    say "Request a grant for input:read and input:control"
    rm -f "${SECRET}" "${SECRET}".approve-*
    python3 scripts/vm-verify-enrollment-client.py "${SECRET}" enrol k6-host-check input:read input:control
    echo "Antony approves the request named k6-host-check in the candidate's Settings window."
    ;;
poll)
    python3 scripts/vm-verify-enrollment-client.py "${SECRET}" poll
    ;;
send)
    case "${2:-}" in
    dia) BUNDLE=company.thebrowser.dia CHORD=cmd+t ROW="New Tab" ;;
    telegram) BUNDLE=com.tdesktop.Telegram CHORD=cmd+f ROW="Search in Chat" ;;
    *) fail "send takes dia or telegram" ;;
    esac
    say "${2}: ${ROW}, ${CHORD}"
    open -b "${BUNDLE}"
    for _ in $(seq 1 10); do
        [ "$(front_bundle)" = "${BUNDLE}" ] && break
        sleep 1
    done
    [ "$(front_bundle)" = "${BUNDLE}" ] || fail "${BUNDLE} is not in front: $(front_bundle)"
    sleep 1
    ANSWER="$(client front)"
    echo "${ANSWER}"
    jq -e --arg b "${BUNDLE}" '((.response.errors // []) | length == 0) and .response.data.inputFrontTarget.bundleIdentifier == $b and .response.data.inputFrontTarget.protection == "ADDRESSABLE"' >/dev/null <<<"${ANSWER}" ||
        fail "the front target is not ${BUNDLE}"
    TARGET="$(jq -r '.response.data.inputFrontTarget.ref' <<<"${ANSWER}")"
    [ ! -e "${EVIDENCE}/sent-${2}" ] || fail "the chord to ${2} was already sent once"
    touch "${EVIDENCE}/sent-${2}"
    ANSWER="$(client send "${TARGET}" "${CHORD}")"
    echo "${ANSWER}"
    echo "front app after the chord: $(front_bundle)"
    jq -e '((.response.errors // []) | length == 0) and .response.data.inputSendKeystroke.outcome == "SENT"' >/dev/null <<<"${ANSWER}" ||
        fail "Koine did not report SENT. If the error is os-permission, Koine sent nothing: restore now."
    echo "Antony reads the effect on the screen, and then undoes it by hand."
    ;;
front)
    say "The app that was in front at the start, to the front again"
    open -b "$(cat "${EVIDENCE}/front-at-start")"
    sleep 1
    echo "front app: $(front_bundle)"
    ;;
restore)
    say "Restore the data directory and the installed Koine"
    [ -z "$(koine_pids "${CANDIDATE}")" ] || fail "the candidate still runs. Quit it from its menu first."
    [ -d "${BACKUP}" ] || fail "no copy of the data directory"
    manifest "${BACKUP}" | diff - "${EVIDENCE}/data-at-start.sha256" || fail "the copy no longer matches the record"
    echo "what the candidate changed:"
    manifest "${DATA}" | diff "${EVIDENCE}/data-at-start.sha256" - || true
    rsync -a --delete "${BACKUP}/" "${DATA}/"
    manifest "${DATA}" | diff - "${EVIDENCE}/data-at-start.sha256" || fail "the restored data directory differs from the record"
    # Koine makes its provider staging read-only, so the copy is made writable before it goes.
    chmod -R u+w "${BACKUP}"
    rm -rf "${BACKUP}"
    "${LSREGISTER}" -u "${CANDIDATE}"
    "${LSREGISTER}" -f "${INSTALLED}"
    if [ "$(cat "${EVIDENCE}/installed-running-at-start")" = yes ]; then
        open "${INSTALLED}"
        sleep 3
    fi
    echo "installed Koine running: pids $(koine_pids "${INSTALLED}" | tr '\n' ' ')"
    echo "installed Koine: $(defaults read "${INSTALLED}/Contents/Info.plist" CFBundleShortVersionString), $(codesign -dvvv "${INSTALLED}" 2>&1 | grep '^CDHash=')"
    echo "data directory: identical to the record; the copy is removed; the candidate is unregistered from Launch Services"
    ;;
*)
    sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'
    exit 2
    ;;
esac
