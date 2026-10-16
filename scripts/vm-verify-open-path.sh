#!/bin/bash
# Verifies, on the signed Koine.app in a clone of the prepared launcher image
# (scripts/vm-prepare-launchers.sh, docs/verification/launcher-apps-vm.md: Gatekeeper
# ENFORCING, Zed, Visual Studio Code, iTerm and Safari installed and past their first run),
# that workspaceOpenPath under workspace:control AND desktop:control, and no read capability,
# opens a client-built path in the DEFAULT handler or in a named application, as the
# contract-only client (clients/contract-only) asks for it, with Accessibility never granted
# to Koine.
#
# What was opened is never inferred from Koine's acknowledgment. The handler's own window is
# read from the window server through the test agent (a window of that application whose title
# names the fixture), every fixture name is unique to its case, and a window that already
# carries the name before the request fails the run rather than passing it. Fixtures/
# LaunchWitness, an independent signed tool, reports who is in front, which instances run, the
# kernel's start instant of each, and every launch and activation, on the guest's clock.
#
# Sections (KOINE_OPEN_PATH_ONLY names them):
#   default   a temporary text file (in /tmp, itself a symlink), a directory and a document
#             package, each in its default handler;
#   zed       the same three with Zed named, and the configuration directory in Zed;
#   literal   spaces and shell punctuation, decomposed Unicode, a symlink to a file, to a
#             directory and a path through a symlinked parent, all literal;
#   source    source scripts with and without executable bits in their default editor and in
#             Zed;
#   refus     inputs and payloads refused before dispatch (empty, relative, tilde, file URL,
#             NUL, a blank application, an application bundle, a link to one, a Finder alias to
#             a document, to a folder and to an application, a program, a Windows executable),
#             dependencies (a missing file, parent, link, application and handler, and a path
#             below a file), an inspection that is denied, and either control alone or a revoked
#             grant: nothing opens in any of them;
#   react     disclosed handler reactions: Terminal and iTerm given scripts, a location
#             document followed by Safari or Finder. Observed and recorded, not prevented, and
#             no sandbox is claimed.
# And, once, that no default-handler setting changed, that Accessibility was absent throughout
# and that no consent dialog appeared.
#
# Nothing here runs an application on the host. The procedure and its recorded evidence:
# docs/verification/open-path-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
# KOINE_LAUNCHERS_IMAGE is the prepared image (default koine-launchers-prepared).
# Exit status: 0 every case passed; 1 a case failed; 3 nothing failed but an acknowledged open
# was not seen activating its handler, which goes to Antony.
# shellcheck disable=SC2016  # guest-side $HOME
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

IMAGE="${KOINE_LAUNCHERS_IMAGE:-koine-launchers-prepared}"
# Not `grep -q`: with pipefail, grep closing the pipe early can fail the pipeline (SIGPIPE to tart).
tart list --quiet 2>/dev/null | grep -x "${IMAGE}" >/dev/null || {
    echo "Error: no prepared image ${IMAGE}. Run: task launchers:prepare" >&2
    exit 1
}
KOINE_VM_BASE="${IMAGE}"
KOINE_VM_LOG_PREFIX="open-path-vm-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-launchers-lib.sh
source scripts/vm-launchers-lib.sh
# shellcheck source=scripts/vm-verify-contract-client-lib.sh
source scripts/vm-verify-contract-client-lib.sh

BUNDLE="clients/contract-only/dist/koine-client.mjs"
[ -f "${BUNDLE}" ] || { echo "Error: ${BUNDLE} does not exist. Run: task client" >&2; exit 1; }

# Everything this run reads or runs, digested now and again at the end: a run whose subjects
# changed under it (the script itself included, which the shell reads as it goes) measured
# nothing, and says so.
SUBJECTS=(scripts/vm-verify-open-path.sh scripts/vm-open-path-fixtures.sh scripts/vm-url-witness-server.mjs
    docs/verification/protected-path-metadata/make-alias.swift scripts/vm-verify-witness-lib.sh scripts/vm-verify-contract-client-lib.sh
    scripts/vm-verify-launch-lib.sh scripts/vm-launchers-lib.sh "${BUNDLE}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}")
subjects_digest() { shasum -a 256 "${SUBJECTS[@]}"; }
SUBJECTS_BEFORE="$(subjects_digest)"
echo "Subjects of this run:"
echo "${SUBJECTS_BEFORE}"

OTHER="Calculator"
TEXTEDIT_ID="com.apple.TextEdit"
FINDER_ID="com.apple.finder"
ZED_ID="dev.zed.Zed"
CODE_ID="com.microsoft.VSCode"
TERMINAL_ID="com.apple.Terminal"
ITERM_ID="com.googlecode.iterm2"
SAFARI_ID="com.apple.Safari"
HOST="koine-url.test"
PORT=8765
FXG="/Users/admin/open-path-fx"
TMPG="/tmp/koine-open-path"
{
    WATCH='$HOME/watch.jsonl'
    SERVER_LOG='$HOME/url-witness.jsonl'
    BOTH='$HOME/koine-secret-both'
    WORKSPACE_ONLY='$HOME/koine-secret-workspace'
    DESKTOP_ONLY='$HOME/koine-secret-desktop'
    REVOKED='$HOME/koine-secret-revoked'
    MANAGER='$HOME/koine-secret-manager'
    PATHS='$HOME/paths'
}
# shellcheck source=scripts/vm-verify-launch-lib.sh
source scripts/vm-verify-launch-lib.sh
# shellcheck source=scripts/vm-verify-witness-lib.sh
source scripts/vm-verify-witness-lib.sh

NODE_ARCHIVE="$(scripts/stage-node-runtime.sh)"
WITNESS_BIN="$(Fixtures/LaunchWitness/build.sh .build/witness)"
RESULTS="${WORK}/results.jsonl"
: >"${RESULTS}"
OUT_DIR=".build/open-path-vm"
mkdir -p "${OUT_DIR}"

# --- the path files: the exact bytes each case submits -------------------------------------
# One file per path, carried into the guest in one archive and read there with --path-file, so
# that no shell, exec channel or terminal can repair, trim or re-encode what is sent. A trailing
# newline would be part of the submission, so none is written unless the case is about one.
mkdir -p "${WORK}/paths"
path_file() { printf '%s' "$2" >"${WORK}/paths/$1.txt"; }
LIT='lit $HOME ~ * ? [x] ; & '"'"' " # % ! (1).txt'
UNI=$'cafe\xcc\x81 \xe6\x97\xa5\xe6\x9c\xac.txt'
path_file tmp-text "${TMPG}/plain note.txt"
path_file folder "${FXG}/A Folder"
path_file package "${FXG}/Package Doc.rtfd"
path_file config-dir "/Users/admin/.config/modaliser"
path_file literal "${FXG}/${LIT}"
path_file unicode "${FXG}/${UNI}"
path_file link-file "${FXG}/link-to-note.txt"
path_file link-dir "${FXG}/link-to-folder"
path_file through-link "${FXG}/link-to-dir/inner note.txt"
path_file real-note "${FXG}/real-note.txt"
for ext in swift py js; do
    path_file "src-exec-${ext}" "${FXG}/src-exec.${ext}"
    path_file "src-plain-${ext}" "${FXG}/src-plain.${ext}"
done
# Refused as input.
path_file empty ""
path_file relative "open-path-fx/real-note.txt"
# shellcheck disable=SC2088  # the tilde is the point: it must stay literal
path_file tilde "~/open-path-fx/real-note.txt"
path_file file-url "file://${FXG}/real-note.txt"
printf '%s\0%s' "${FXG}/real" "note.txt" >"${WORK}/paths/nul.txt"
path_file app-bundle "/Applications/Zed.app"
path_file link-app "${FXG}/link-to-app"
path_file alias-note "${FXG}/alias-to-note"
path_file alias-folder "${FXG}/alias-to-folder"
path_file alias-app "${FXG}/alias-to-app"
path_file program "${FXG}/prog-machO"
path_file windows-exe "${FXG}/setup.exe"
# Dependencies, and the denied inspection.
path_file missing-file "${FXG}/no such file.txt"
path_file missing-parent "${FXG}/no such directory/inner.txt"
path_file dangling "${FXG}/link-to-nowhere"
path_file below-file "${FXG}/real-note.txt/inner.txt"
path_file trailing-slash "${FXG}/real-note.txt/"
path_file no-handler "${FXG}/no-handler.unknownzzz"
path_file locked "${FXG}/locked/secret.txt"
# The handlers' reactions.
path_file react-term "${FXG}/react-term.command"
path_file react-term-plain "${FXG}/react-term-plain.command"
path_file react-shell "${FXG}/react-shell.sh"
path_file react-shell-plain "${FXG}/react-shell-plain.sh"
path_file loc-http "${FXG}/loc-http.webloc"
path_file loc-file "${FXG}/loc-file.fileloc"
ditto -c -k "${WORK}/paths" "${WORK}/paths.zip"

# --- helpers ---------------------------------------------------------------------------------
open_client() { contract_client_once "$@" >/dev/null; }
server_read() { SERVER_EVENTS="$(guest_text "cat ${SERVER_LOG}")"; }
# Calculator in front, Koine inactive: the precondition of every case. (The handlers under
# test include TextEdit, which the shared helper uses, so this one does not name a document.)
put_other_in_front() {
    guest "open -a ${OTHER}" || true
    local tries=0
    until witness_front >/dev/null && jq -e ".application.name == \"${OTHER}\"" >/dev/null <<<"${FRONT}"; do
        tries=$((tries + 1))
        [ "${tries}" -lt 15 ] || fail "${OTHER} did not come to the front"
        guest "open -a ${OTHER}" || true
        sleep 2
    done
    instances "${BUNDLE_ID}"
    jq -e '.instances | length == 1 and .[0].isActive == false' >/dev/null <<<"${INSTANCES}" || fail "Koine is active"
    echo "Precondition: ${OTHER} is in front ($(jq -c '.application | {pid, startedAt}' <<<"${FRONT}")) and Koine is inactive."
}
# accessibility_is <true|false>: Koine's own account of the consent, read under the manager grant.
accessibility_is() {
    local since
    since="$(date +%s)"
    until MANAGED="$(guest_json "bash \$HOME/vm-verify-client.sh \"${MANAGER}\" '{ koineManagement { osPermissions { permission owner granted } } }' | grep -m1 '^{'")" &&
        jq -e ".data.koineManagement.osPermissions[0].granted == $1" >/dev/null <<<"${MANAGED}"; do
        [ $(($(date +%s) - since)) -lt 60 ] || fail "osPermissions did not report granted: $1 within 60s"
        sleep 2
    done
    echo "Observation: Koine's own account (osPermissions): accessibility granted is $1."
}
# windows_with <application name> <alternatives, |-separated>: the titles of that application's
# windows that contain any alternative, as a JSON array.
windows_with() {
    local out
    # A read that answered nothing (the agent's false timeout) is read again, never taken for "no window".
    for _ in 1 2 3 4 5 6; do
        out="$(testanyware agent windows --json 2>/dev/null | jq -c --arg a "$1" --arg alts "$2" \
            '[.windows[] | select(.appName == $a) | .title as $t | select([($alts | split("|")[] | . as $s | select($s != "" and ($t | contains($s))))] | length > 0) | $t]' 2>/dev/null)" || out=""
        if [ -n "${out}" ]; then echo "${out}"; return 0; fi
        sleep 2
    done
    echo "the window list could not be read" >&2
    return 1
}
# title_wait <application name> <alternatives>: TITLES, the matching window titles, or empty
# after 60 seconds.
title_wait() {
    TITLES="[]"
    for _ in $(seq 1 30); do
        TITLES="$(windows_with "$1" "$2")" || TITLES="[]"
        [ "${TITLES}" != "[]" ] && [ -n "${TITLES}" ] && return 0
        sleep 2
    done
    TITLES="[]"
    return 1
}
# one_open <label> <handler id> <client arguments...>: with ${OTHER} in front and Koine
# inactive, sends one request and watches the system. Leaves in globals: ACK_CLASS, SENT,
# RECEIVED, PROCESS ({pid, startedAt} or null), ACTIVATED_MS (empty if the witness never saw the
# handler activated), EVENTS.
one_open() {
    local label="$1" handler="$2"
    shift 2
    put_other_in_front >/dev/null
    watch_start
    open_client "$@"
    ACK_CLASS="$(jq -r .classification <<<"${ANSWER}")"
    SENT="$(jq -r .sentMs <<<"${ANSWER}")"
    RECEIVED="$(jq -r .receivedMs <<<"${ANSWER}")"
    PROCESS="$(jq -c 'if .process then (.process | {pid, startedAt}) else null end' <<<"${ANSWER}")"
    ACTIVATED_MS=""
    if [ "${ACK_CLASS}" = ok ]; then activation_wait "${handler}" "${SENT}" || true; else sleep 5; fi
    watch_read
    echo "Witness events: $(jq -c -s '[.[] | select(.event == "launched" or .event == "activated") | {event, atMs, id: .application.bundleIdentifier, pid: .application.pid}]' <<<"${EVENTS}")"
    echo "${label}: ${ACK_CLASS}; answer $((RECEIVED - SENT)) ms after the request; activation $([ -n "${ACTIVATED_MS}" ] && echo "$((ACTIVATED_MS - SENT)) ms after it" || echo "NOT SEEN"); process ${PROCESS}"
}

# open_case <section> <case> <path file> <application: default|zed> <handler name> <handler id>
#           <title alternatives, |-separated> [<window application name, default the handler's>]
# The handler's window must appear, naming the fixture, and the receipt's process, when there is
# one, must be the kernel's identity for the handler's instance.
open_case() {
    local section="$1" case="$2" file="$3" application="$4" name="$5" id="$6" alts="$7" window="${8:-$5}"
    local status="passed" notes="" path cb act same="n/a" count dialogs flags=""
    path="$(cat "${WORK}/paths/${file}.txt")"
    [ "${application}" = zed ] && flags="--bundle-identifier ${ZED_ID}"
    step "${section}: ${case}"
    # A fixture whose name is already on a window would make this case pass for another's open.
    BEFORE="$(windows_with "${window}" "${alts}")" || fail "the window list could not be read before ${case}"
    [ "${BEFORE}" = "[]" ] || fail "${window} already shows a window naming ${alts} (${BEFORE}): the case would prove nothing"
    # shellcheck disable=SC2086
    one_open "${case}" "${id}" "open-path --secret \"${BOTH}\" --path-file \"${PATHS}/${file}.txt\" ${flags}"
    if [ "${ACK_CLASS}" != ok ]; then
        status="failed"
        notes="${notes}not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
        record --arg s "${section}" --arg c "${case}" --arg st "${status}" --arg n "${notes}" '{section: $s, case: $c, status: $st, notes: $n}'
        watch_stop
        return 0
    fi
    expect '.status == "AVAILABLE" and .dependency == null and .http.status == 200 and ((.errors // []) | length == 0)' "${case}: not an acknowledged open"
    cb=$((RECEIVED - SENT))
    if [ -n "${ACTIVATED_MS}" ]; then act=$((ACTIVATED_MS - SENT)); else act=null; fi
    if [ -z "${ACTIVATED_MS}" ]; then status="pending-activation"; notes="${notes}acknowledged but the witness never saw ${name} activated; "; fi
    if title_wait "${window}" "${alts}"; then
        echo "${window}'s window: ${TITLES}"
    else
        status="failed"
        notes="${notes}no ${window} window named ${alts} appeared within 60 s; windows: $(testanyware agent windows --json 2>/dev/null | jq -c "[.windows[] | select(.appName == \"${window}\") | .title]"); "
    fi
    sleep 1
    quiet_instances "${id}"
    count="$(jq -r '.instances | length' <<<"${INSTANCES}")"
    if [ "${PROCESS}" != null ] && [ "${count}" = 1 ]; then
        same="$(jq -c --argjson p "${PROCESS}" '.instances[0] | {pid, startedAt} == $p' <<<"${INSTANCES}")"
        echo "Receipt ${PROCESS}; kernel, read by the witness: $(jq -c '.instances[0] | {pid, startedAt}' <<<"${INSTANCES}") — equal: ${same}"
        [ "${same}" = true ] || { status="failed"; notes="${notes}the receipt's process is not the kernel's identity; "; }
    elif [ "${PROCESS}" = null ]; then
        notes="${notes}no process in the receipt; "
    else
        notes="${notes}${count} instances of ${name}, so the receipt was not compared; "
    fi
    watch_stop
    dialogs="$(system_dialogs)"
    echo "Dialogs on screen: ${dialogs:-none}"
    judge_dialogs "open" "${dialogs}"
    record --arg s "${section}" --arg c "${case}" --arg p "${path}" --arg app "${application}" --arg h "${id}" --arg st "${status}" --arg n "${notes}" \
        --argjson titles "${TITLES}" --argjson cb "${cb}" --argjson act "${act}" --arg same "${same}" \
        '{section: $s, case: $c, path: $p, application: $app, handler: $h, windows: $titles, status: $st, answerMs: $cb, activationMs: $act, receiptIsKernelIdentity: $same, notes: $n}'
    echo "Result: ${section}: ${case}: ${status}${notes:+ — ${notes}}"
}

# --- the guest ----------------------------------------------------------------------------------
start_vm
GATEKEEPER="$(guest 'spctl --status --verbose' 2>&1)"
echo "Gatekeeper in the clone: $(tr '\n' ';' <<<"${GATEKEEPER}")"
grep -qx 'assessments enabled' <<<"${GATEKEEPER}" ||
    fail "the clone is not Gatekeeper-enforcing; run: task launchers:prepare"
install_app
step "Carry the client, the Node runtime, the witnesses, the fixtures and the path files into the guest"
testanyware file upload "${NODE_ARCHIVE}" /Users/admin/node.tar.xz >/dev/null
testanyware file upload "${BUNDLE}" /Users/admin/koine-client.mjs >/dev/null
testanyware file upload scripts/vm-verify-contract-client-trim.py /Users/admin/trim.py >/dev/null
testanyware file upload scripts/vm-verify-launch-client.py /Users/admin/vm-verify-launch-client.py >/dev/null
testanyware file upload scripts/vm-url-witness-server.mjs /Users/admin/vm-url-witness-server.mjs >/dev/null
testanyware file upload "${WITNESS_BIN}" /Users/admin/LaunchWitness >/dev/null
testanyware file upload "${WORK}/paths.zip" /Users/admin/paths.zip >/dev/null
testanyware file upload docs/verification/protected-path-metadata/make-alias.swift /Users/admin/make-alias.swift >/dev/null
testanyware file upload scripts/vm-open-path-fixtures.sh /Users/admin/vm-open-path-fixtures.sh >/dev/null
guest 'cd $HOME && rm -rf node paths && tar -xJf node.tar.xz && mv node-*-darwin-arm64 node && chmod +x $HOME/LaunchWitness && echo open-path > $HOME/launch-target.txt && ditto -x -k paths.zip paths && ls paths | wc -l && ./node/bin/node --version'

step "The fixtures: a temporary text file, a directory, a document package, links, source scripts, programs, Finder aliases, scripts for the handlers to meet"
guest 'cd $HOME && swiftc -O make-alias.swift -o make-alias 2>&1 | tail -3'
guest '[ -x $HOME/make-alias ]' || fail "the alias maker did not build in the guest"
guest 'bash $HOME/vm-open-path-fixtures.sh $HOME/make-alias' || fail "the fixtures were not made"
# Every path a case submits must be what the case says it is, in the guest, before it is relied on.
# One exec for all of them: each round trip to the guest costs seconds.
PRESENT=("${TMPG}/plain note.txt" "${FXG}/A Folder" "${FXG}/Package Doc.rtfd" "${FXG}/${LIT}" "${FXG}/link-to-note.txt" "${FXG}/link-to-dir" "${FXG}/link-to-folder" "${FXG}/fileloc target.txt"
    "${FXG}/link-to-dir/inner note.txt" "${FXG}/src-exec.swift" "${FXG}/src-plain.js" "${FXG}/prog-machO" "${FXG}/setup.exe" "${FXG}/alias-to-note" "${FXG}/alias-to-app"
    "${FXG}/alias-to-folder" "${FXG}/link-to-app" "${FXG}/no-handler.unknownzzz" "${FXG}/react-term.command" "${FXG}/loc-http.webloc" "/Users/admin/.config/modaliser/config.scm"
    "${FXG}/link-to-nowhere")
ABSENT=("${FXG}/no such file.txt" "${FXG}/no such directory")
CHECK="missing=0"
for path in "${PRESENT[@]}"; do
    q="$(printf '%q' "${path}")"
    CHECK="${CHECK}; { test -e ${q} || test -L ${q}; } || { echo \"MISSING: \"${q}; missing=1; }"
done
for path in "${ABSENT[@]}"; do
    q="$(printf '%q' "${path}")"
    CHECK="${CHECK}; { ! test -e ${q} && ! test -L ${q}; } || { echo \"PRESENT BUT MUST NOT BE: \"${q}; missing=1; }"
done
CHECK="${CHECK}; echo checked-${#PRESENT[@]}-${#ABSENT[@]}-\${missing}"
FIXTURE_CHECK="$(guest_text "${CHECK}")"
echo "${FIXTURE_CHECK}"
grep -qx "checked-${#PRESENT[@]}-${#ABSENT[@]}-0" <<<"${FIXTURE_CHECK}" || fail "the guest's fixtures are not what the cases assume"
# The decomposed-Unicode name is compared by its bytes: the exec channel is known to re-normalise
# Unicode in a command line, so the name is not passed through one.
UNI_HEX="$(printf '%s' "${UNI}" | xxd -p | tr -d '\n')"
guest "python3 -c \"import os,sys; sys.exit(0 if '${UNI_HEX}' in [n.encode().hex() for n in os.listdir('${FXG}')] else 1)\"" ||
    fail "the decomposed-Unicode fixture is not in the guest under exactly the bytes the path file names"
echo "Fixture classes in the guest (the system's own account of each):"
guest "file '${FXG}/alias-to-note' '${FXG}/prog-machO' '${FXG}/link-to-nowhere' | cat; ls -ld '${FXG}/locked' '${FXG}/src-exec.swift' '${FXG}/src-plain.swift'"
guest "mdls -name kMDItemContentType -raw '${FXG}/alias-to-note'; echo; mdls -name kMDItemContentType -raw '${FXG}/alias-to-app'; echo" || true
echo "Modes: exec $(guest "stat -f %Lp '${FXG}/src-exec.js'") plain $(guest "stat -f %Lp '${FXG}/src-plain.js'") (sources); the locked directory $(guest "stat -f %Lp '${FXG}/locked'")."

step "Default handlers, read before: which application the system gives each fixture, and the handler settings' digest"
testanyware file upload /dev/stdin /Users/admin/handlers.swift >/dev/null <<'SWIFT'
import AppKit
import UniformTypeIdentifiers
// handlers <path>...: the default application the system gives each existing path, and its type.
for p in CommandLine.arguments.dropFirst() {
    let u = URL(fileURLWithPath: p)
    let h = NSWorkspace.shared.urlForApplication(toOpen: u)
    let id = h.flatMap { Bundle(url: $0)?.bundleIdentifier } ?? "none"
    let t = (try? u.resourceValues(forKeys: [.contentTypeKey]))?.contentType?.identifier ?? "?"
    print("\(u.lastPathComponent)\t\(t)\t\(id)")
}
let web = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "http://example.com")!)
print("http\t\(web.flatMap { Bundle(url: $0)?.bundleIdentifier } ?? "none")")
SWIFT
guest 'cd $HOME && swiftc -O handlers.swift -o handlers 2>&1 | tail -3'
HANDLED="'${TMPG}/plain note.txt' '${FXG}/A Folder' '${FXG}/Package Doc.rtfd' '${FXG}/src-exec.swift' '${FXG}/src-exec.py' '${FXG}/src-exec.js' '${FXG}/react-term.command' '${FXG}/react-shell.sh' '${FXG}/loc-http.webloc' '${FXG}/loc-file.fileloc' '${FXG}/no-handler.unknownzzz'"
LS_PLIST='$HOME/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist'
handler_state() {
    guest_text "\$HOME/handlers ${HANDLED}; shasum -a 256 ${LS_PLIST} 2>&1 | cut -d' ' -f1"
}
HANDLERS_BEFORE="$(handler_state)"
echo "${HANDLERS_BEFORE}"
grep -q "src-exec.py	public.python-script	${ZED_ID}" <<<"${HANDLERS_BEFORE}" || fail "the image's default for .py is not Zed; the source cases assume the image as prepared"
grep -q "src-exec.swift	public.swift-source	${CODE_ID}" <<<"${HANDLERS_BEFORE}" || fail "the image's default for .swift is not Visual Studio Code"
grep -q "no-handler.unknownzzz	.*	none" <<<"${HANDLERS_BEFORE}" || fail "the no-handler fixture has a handler in this image"

step "The page server (the location document's target) and Koine"
# Idempotent: the agent's exec channel can run a command twice.
guest "grep -q '${HOST}' /etc/hosts || echo ${VM_PASSWORD} | sudo -S sh -c 'printf \"127.0.0.1 ${HOST}\n\" >> /etc/hosts'" || true
guest "grep -c '${HOST}' /etc/hosts" | grep -qE '^[1-9]' || fail "the hosts entry was not written"
guest "lsof -nP -iTCP:${PORT} -sTCP:LISTEN >/dev/null || (nohup \$HOME/node/bin/node \$HOME/vm-url-witness-server.mjs ${PORT} ${SERVER_LOG} >/dev/null 2>&1 &)" || true
for _ in $(seq 1 20); do
    server_read
    grep -q '"kind":"listening"' <<<"${SERVER_EVENTS}" && break
    sleep 1
done
grep -q '"kind":"listening"' <<<"${SERVER_EVENTS}" || fail "the page server did not start"

step "Launch Koine; a manager grant in the window, then the contract-only client enrols its own grants"
launch
create_grant "open-path-manager" "${MANAGER}" koine:manage
accessibility_is false
enrol "${BOTH}" open-path-client-both workspace:control desktop:control
expect '.grant.capabilities == ["desktop:control","workspace:control"] or .grant.capabilities == ["workspace:control","desktop:control"]' \
    "the grant is not exactly both controls"
enrol "${WORKSPACE_ONLY}" open-path-client-workspace workspace:control
enrol "${DESKTOP_ONLY}" open-path-client-desktop desktop:control
enrol "${REVOKED}" open-path-client-revoked workspace:control desktop:control
REVOKED_GRANT="$(jq -r '.grant.grantId' <<<"${ANSWER}")"
guest "python3 \$HOME/vm-verify-launch-client.py \"${MANAGER}\" - revoke \"${REVOKED_GRANT}\"" | tail -1 | jq -e '.response.data.koineRevokeGrant.state == "REVOKED"' >/dev/null ||
    fail "the grant to be revoked was not revoked"
echo "Accessibility is not granted to Koine in this image: every open below is by workspace:control and desktop:control alone."

SECTIONS="${KOINE_OPEN_PATH_ONLY:-}"
# wanted <section>: whether KOINE_OPEN_PATH_ONLY (a comma-separated list of texts) names it.
wanted() {
    local word
    [ -z "${SECTIONS}" ] && return 0
    for word in ${SECTIONS//,/ }; do [[ "$1" == *"${word}"* ]] && return 0; done
    return 1
}

if wanted default; then
    open_case "default handler" "a temporary text file under /tmp (itself a symlink)" tmp-text default TextEdit "${TEXTEDIT_ID}" "plain note.txt"
    open_case "default handler" "a directory" folder default Finder "${FINDER_ID}" "A Folder"
    open_case "default handler" "a document package" package default TextEdit "${TEXTEDIT_ID}" "Package Doc"
fi

if wanted zed; then
    open_case "Zed named" "the temporary text file" tmp-text zed Zed "${ZED_ID}" "plain note.txt"
    open_case "Zed named" "the directory" folder zed Zed "${ZED_ID}" "A Folder"
    open_case "Zed named" "the document package" package zed Zed "${ZED_ID}" "Package Doc"
    open_case "Zed named" "the configuration directory (Client settings)" config-dir zed Zed "${ZED_ID}" "modaliser"
fi

if wanted literal; then
    open_case "literal paths" "spaces and shell punctuation, default handler" literal default TextEdit "${TEXTEDIT_ID}" "lit \$HOME ~ * ? [x] ; & "
    open_case "literal paths" "decomposed Unicode, default handler" unicode default TextEdit "${TEXTEDIT_ID}" "日本"
    open_case "literal paths" "a symlink to a file, default handler" link-file default TextEdit "${TEXTEDIT_ID}" "link-to-note.txt|real-note.txt"
    open_case "literal paths" "a symlink to a directory, default handler" link-dir default Finder "${FINDER_ID}" "link-to-folder|Link Target"
    open_case "literal paths" "a file through a symlinked parent, Zed named" through-link zed Zed "${ZED_ID}" "inner note.txt"
fi

if wanted source; then
    open_case "source scripts" "Swift source with its executable bit, default editor" src-exec-swift default "Visual Studio Code" "${CODE_ID}" "src-exec.swift" Code
    open_case "source scripts" "Swift source without it, default editor" src-plain-swift default "Visual Studio Code" "${CODE_ID}" "src-plain.swift" Code
    open_case "source scripts" "Python source with its executable bit, default editor (Zed in this image)" src-exec-py default Zed "${ZED_ID}" "src-exec.py"
    open_case "source scripts" "Python source without it, default editor (Zed in this image)" src-plain-py default Zed "${ZED_ID}" "src-plain.py"
    open_case "source scripts" "JavaScript with its executable bit, Zed named" src-exec-js zed Zed "${ZED_ID}" "src-exec.js"
    open_case "source scripts" "JavaScript without it, Zed named" src-plain-js zed Zed "${ZED_ID}" "src-plain.js"
    open_case "source scripts" "Swift source with its executable bit, Zed named" src-exec-swift zed Zed "${ZED_ID}" "src-exec.swift"
    open_case "source scripts" "Swift source without it, Zed named" src-plain-swift zed Zed "${ZED_ID}" "src-plain.swift"
fi

if wanted refus; then
    step "Refusals, dependencies, a denied inspection and denied grants: nothing opens"
    # Every case below must open nothing, so they are asked in one run in the guest under one
    # watch, with ${OTHER} in front: the agent's exec channel makes each round trip slow, and a
    # batch is also the stricter observation (not one application launch or activation, and the
    # front application never changes, from the first to the last).
    # <name>|<path file>|<client flags>|<jq condition on the answer>
    INPUT='.classification == "input-error" and .actionEffect == "none" and .process == null and .receipt == null and .status == null and .http.status == 200 and (.errors | length) == 1 and (.errors[0] | .path == ["workspaceOpenPath"] and .kind == null)'
    dependency() { printf '.classification == "dependency-unavailable" and .actionEffect == "none" and .process == null and .receipt == null and .status == "DEPENDENCY_UNAVAILABLE" and .dependency.reason == "%s"' "$1"; }
    CASES=(
        "empty|empty||${INPUT}"
        "relative|relative||${INPUT}"
        "tilde|tilde||${INPUT}"
        "file-url|file-url||${INPUT}"
        "nul|nul||${INPUT}"
        "blank-application|real-note|--bundle-identifier ' '|${INPUT}"
        "app-bundle|app-bundle||${INPUT}"
        "app-bundle-zed-named|app-bundle|--bundle-identifier ${ZED_ID}|${INPUT}"
        "link-to-app|link-app||${INPUT}"
        "alias-to-note|alias-note||${INPUT}"
        "alias-to-note-zed-named|alias-note|--bundle-identifier ${ZED_ID}|${INPUT}"
        "alias-to-folder|alias-folder||${INPUT}"
        "alias-to-app|alias-app||${INPUT}"
        "program|program||${INPUT}"
        "windows-executable|windows-exe||${INPUT}"
        "missing-file|missing-file||$(dependency PATH_NOT_FOUND)"
        "missing-parent|missing-parent||$(dependency PATH_NOT_FOUND)"
        "dangling-link|dangling||$(dependency PATH_NOT_FOUND)"
        "below-a-file|below-file||$(dependency PATH_NOT_FOUND)"
        "trailing-slash-on-a-file|trailing-slash||$(dependency PATH_NOT_FOUND)"
        "missing-file-and-missing-application|missing-file|--bundle-identifier com.example.koine.nothere|$(dependency PATH_NOT_FOUND)"
        "missing-application|real-note|--bundle-identifier com.example.koine.nothere|$(dependency APPLICATION_NOT_INSTALLED)"
        "missing-application-for-a-folder|folder|--bundle-identifier com.example.koine.nothere|$(dependency APPLICATION_NOT_INSTALLED)"
        "no-default-handler|no-handler||$(dependency NO_DEFAULT_HANDLER)"
        "inspection-denied|locked||.classification == \"failed\" and .process == null and .receipt == null and .http.status == 200"
    )
    BATCH="mkdir -p \$HOME/refusals && rm -f \$HOME/refusals/*"
    for spec in "${CASES[@]}"; do
        IFS='|' read -r name file flags _ <<<"${spec}"
        BATCH="${BATCH}; ${CLIENT} open-path --secret \"${BOTH}\" --path-file \"${PATHS}/${file}.txt\" ${flags} > \$HOME/refusals/${name}.json"
    done
    BATCH="${BATCH}; ${CLIENT} open-path --secret \"${WORKSPACE_ONLY}\" --path-file \"${PATHS}/real-note.txt\" > \$HOME/refusals/authority-workspace-only.json"
    BATCH="${BATCH}; ${CLIENT} open-path --secret \"${DESKTOP_ONLY}\" --path-file \"${PATHS}/real-note.txt\" > \$HOME/refusals/authority-desktop-only.json"
    BATCH="${BATCH}; ${CLIENT} open-path --secret \"${REVOKED}\" --path-file \"${PATHS}/real-note.txt\" > \$HOME/refusals/authority-revoked.json"
    BATCH="${BATCH}; ${CLIENT} open-path --secret \"${WORKSPACE_ONLY}\" --path-file \"${PATHS}/missing-file.txt\" > \$HOME/refusals/authority-before-inspection.json"
    put_other_in_front >/dev/null
    witness_front >/dev/null
    FRONT_BEFORE="$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")"
    WINDOWS_BEFORE="$(testanyware agent windows --json 2>/dev/null | jq -c '[.windows[] | select(.appName != "Notification Center") | [.appName, .title]] | sort')"
    watch_start
    # Nothing here can be harmed by a repeat: each client run is refused and opens nothing, and
    # a repeat that did open something is what the witness below would show.
    guest "${BATCH}" || true
    for _ in $(seq 1 30); do
        REFUSALS="$(guest_text 'cd $HOME/refusals && for f in *.json; do printf "%s " "${f%.json}"; cat "$f"; done')"
        [ "$(grep -c '^[a-z-]* {' <<<"${REFUSALS}")" = "$((${#CASES[@]} + 4))" ] && break
        sleep 3
    done
    sleep 6
    watch_read
    watch_stop
    # answer_of <case>: that case's one JSON line, in ANSWER.
    answer_of() {
        ANSWER="$(grep "^$1 {" <<<"${REFUSALS}" | head -1)"
        ANSWER="${ANSWER#* }"
        jq -e . >/dev/null <<<"${ANSWER}" || fail "the client left no answer for $1"
    }
    for spec in "${CASES[@]}"; do
        IFS='|' read -r name file flags condition <<<"${spec}"
        answer_of "${name}"
        echo "${name}: $(jq -c '{classification, actionEffect, status, dependency, errors: [.errors[]? | {message, path, kind}]}' <<<"${ANSWER}")"
        expect "${condition}" "${name}: not the answer the contract gives"
        record --arg n "${name}" --argjson a "$(jq -c '{classification, status, dependency, errors}' <<<"${ANSWER}")" '{case: "refused or unavailable", input: $n, status: "passed", answer: $a}'
    done
    answer_of authority-workspace-only
    echo "workspace:control alone: $(jq -c '{classification, http, requiredCapability, requiredCapabilities, phase}' <<<"${ANSWER}")"
    expect '.classification == "capability-denied" and .http.status == 403 and .requiredCapability == "desktop:control" and .requiredCapabilities == ["workspace:control","desktop:control"] and .process == null' \
        "workspace:control alone was not refused with the first unmet capability and the complete set"
    record '{case: "authority: workspace:control alone", status: "passed"}'
    answer_of authority-desktop-only
    echo "desktop:control alone: $(jq -c '{classification, http, requiredCapability, requiredCapabilities, phase}' <<<"${ANSWER}")"
    expect '.classification == "capability-denied" and .http.status == 403 and .requiredCapability == "workspace:control" and .requiredCapabilities == ["workspace:control","desktop:control"] and .process == null' \
        "desktop:control alone was not refused with the first unmet capability and the complete set"
    record '{case: "authority: desktop:control alone", status: "passed"}'
    answer_of authority-revoked
    echo "a revoked grant: $(jq -c '{classification, http, errors}' <<<"${ANSWER}")"
    expect '.http.status == 401 and .process == null and .receipt == null' "the revoked grant was not refused with 401"
    record '{case: "authority: revoked grant", status: "passed"}'
    answer_of authority-before-inspection
    echo "denial before inspection (a missing path, workspace:control alone): $(jq -c '{classification, http, dependency}' <<<"${ANSWER}")"
    expect '.classification == "capability-denied" and .http.status == 403 and .dependency == null' "a missing path was inspected before the capability was checked"
    record '{case: "authority: denial precedes inspection", status: "passed"}'
    jq -e -s '[.[] | select(.event == "launched" or .event == "activated")] | length == 0' >/dev/null <<<"${EVENTS}" ||
        fail "a refused open launched or activated an application: $(jq -c -s '[.[] | select(.event == "launched" or .event == "activated")]' <<<"${EVENTS}")"
    witness_front >/dev/null
    [ "$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")" = "${FRONT_BEFORE}" ] || fail "focus moved during the refusals"
    WINDOWS_AFTER="$(testanyware agent windows --json 2>/dev/null | jq -c '[.windows[] | select(.appName != "Notification Center") | [.appName, .title]] | sort')"
    [ "${WINDOWS_AFTER}" = "${WINDOWS_BEFORE}" ] || fail "a window appeared during the refusals: ${WINDOWS_BEFORE} -> ${WINDOWS_AFTER}"
    echo "Observation: ${#CASES[@]} refused, unavailable or failed requests and four denied ones: nothing launched, activated or moved, no window appeared."
fi

if wanted react; then
    # The handler decides what a document does. Each case sends one fixture to its default
    # handler and records what then happens, without asserting the reaction: no sandbox is
    # claimed, and the request is acknowledged or the case fails.
    react_case() {
        local case="$1" file="$2" handler="$3" id="$4" kind="$5"
        local status="recorded" notes="" observed="false" detail="" dialogs
        step "disclosed reaction: ${case}"
        guest "rm -f ${FXG}/markers/*" || true
        server_read
        local requests_before
        requests_before="$(jq -cs '[.[] | select(.kind == "request")] | length' <<<"${SERVER_EVENTS}")"
        one_open "${case}" "${id}" "open-path --secret \"${BOTH}\" --path-file \"${PATHS}/${file}.txt\""
        if [ "${ACK_CLASS}" != ok ]; then
            status="failed"
            notes="not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
        else
            for _ in $(seq 1 15); do
                case "${kind}" in
                marker)
                    detail="$(guest_text "ls ${FXG}/markers 2>/dev/null | tr '\n' ' '")"
                    [ -n "${detail// /}" ] && observed="true"
                    ;;
                request)
                    server_read
                    detail="$(jq -cs --argjson n "${requests_before}" '[.[] | select(.kind == "request")] | .[$n:] | map({target, host})' <<<"${SERVER_EVENTS}")"
                    [ "${detail}" != "[]" ] && observed="true"
                    ;;
                window)
                    detail="$(testanyware agent windows --json 2>/dev/null | jq -c '[.windows[] | select(.title | contains("fileloc target")) | {app: .appName, title}]')"
                    [ "${detail}" != "[]" ] && observed="true"
                    ;;
                esac
                [ "${observed}" = true ] && break
                sleep 2
            done
            notes="${handler} was handed the document; reaction observed: ${observed} (${detail})"
        fi
        watch_stop
        dialogs="$(system_dialogs)"
        echo "Dialogs on screen: ${dialogs:-none}"
        judge_dialogs "open" "${dialogs}"
        record --arg c "disclosed reaction: ${case}" --arg h "${handler}" --arg st "${status}" --arg n "${notes}" --argjson o "${observed}" --arg d "${detail}" \
            '{case: $c, handler: $h, status: $st, reactionObserved: $o, reaction: $d, notes: $n}'
        echo "Result: ${case}: ${status} — ${notes}"
    }
    react_case "a .command script with its executable bit, default handler (Terminal)" react-term Terminal "${TERMINAL_ID}" marker
    react_case "a .command script without it, default handler (Terminal)" react-term-plain Terminal "${TERMINAL_ID}" marker
    react_case "a .sh script with its executable bit, default handler (iTerm in this image)" react-shell iTerm "${ITERM_ID}" marker
    react_case "a .sh script without it, default handler (iTerm in this image)" react-shell-plain iTerm "${ITERM_ID}" marker
    react_case "a .webloc document naming an HTTP page, default handler (Safari)" loc-http Safari "${SAFARI_ID}" request
    react_case "a .fileloc document naming a local file, default handler (TextEdit in this image)" loc-file TextEdit "${TEXTEDIT_ID}" window
fi

step "No handler setting changed: the defaults read before are the defaults now"
HANDLERS_AFTER="$(handler_state)"
echo "${HANDLERS_AFTER}"
if [ "${HANDLERS_AFTER}" = "${HANDLERS_BEFORE}" ]; then
    echo "Observation: the default application of every fixture type, the http handler and the LaunchServices handler settings' digest are as they were."
    record '{case: "no handler setting changed", status: "passed"}'
else
    echo "before: ${HANDLERS_BEFORE}" >&2
    fail "a default-handler setting changed during the run"
fi

step "Accessibility was absent throughout, and no consent dialog is on screen"
accessibility_is false
no_consent_dialog "after every open"
record '{case: "accessibility absent throughout", status: "passed"}'

step "The subjects of the run are as they were at its start"
[ "$(subjects_digest)" = "${SUBJECTS_BEFORE}" ] || fail "a subject of this run changed while it ran; the run measured nothing"
echo "Unchanged: ${#SUBJECTS[@]} files, digested before and after."

step "Results"
jq -s '.' "${RESULTS}" >"${OUT_DIR}/results.json"
jq -r '.[] | select(.answerMs != null) | "\(.section // "-"): \(.case): \(.status); answer \(.answerMs) ms, activation \(.activationMs) ms; receipt = kernel: \(.receiptIsKernelIdentity // "n/a"); \(.windows | tostring)"' "${OUT_DIR}/results.json"
jq -r '.[] | select(.case != null and .answerMs == null) | "\(.case)\(if .input then " " + .input else "" end): \(.status)"' "${OUT_DIR}/results.json"
echo "Written: ${OUT_DIR}/results.json"
FAILED="$(jq '[.[] | select(.status == "failed")] | length' "${OUT_DIR}/results.json")"
PENDING="$(jq '[.[] | select(.status == "pending-activation")] | length' "${OUT_DIR}/results.json")"

step "Quit Koine"
quit_koine_or_terminate

if [ "${FAILED}" != 0 ]; then
    echo "FAILED: ${FAILED} case(s) failed, ${PENDING} pending — transcript in ${LOG}" >&2
    exit 1
fi
if [ "${PENDING}" != 0 ]; then
    echo "PENDING: ${PENDING} acknowledged open(s) not seen activating their handler; they stay live and go to Antony — transcript in ${LOG}" >&2
    exit 3
fi
step "PASSED — transcript in ${LOG}"
