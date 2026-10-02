#!/bin/bash
# Verifies, on the signed Koine.app in a clone of the prepared launcher image
# (scripts/vm-prepare-launchers.sh, docs/verification/launcher-apps-vm.md), the
# "Multiple copies and installation" row of docs/specs/workspace-launch-and-open.md for
# workspaceLaunchApplication and for workspaceOpenPath with a named application, as the
# contract-only client (clients/contract-only) asks for them under workspace:control AND
# desktop:control, with Accessibility never granted to Koine.
#
# The subject is Fixtures/InstallationFixture, an application built once in the guest and
# installed at several locations by scripts/vm-installation-fixtures.sh, registered with
# Launch Services under one bundle identifier twice. Every copy writes down which copy it is
# and what it was handed (its own log, on the guest's clock), and the witness
# (Fixtures/LaunchWitness, an independent signed tool that holds no Koine code) reports the
# kernel's identity and bundle of the process the receipt names. What Launch Services itself
# answers for each identifier is read by scripts/vm-registration-lookup.swift, the same
# NSWorkspace calls the provider's native adapter makes, and recorded beside each section.
#
# Sections (KOINE_INSTALLATIONS_ONLY names them):
#   reuse     two registered copies. Unconstrained launch and unconstrained named-application
#             opening reuse the running copy at the other location; an installation path
#             addresses exactly the chosen copy, while the other runs and when both do;
#   spelling  a symlink to the copy's folder, a symlink to its bundle, and composed and
#             decomposed Unicode spellings of a registered path, compared by file identity;
#   absent    a missing copy, a present unregistered copy, a copy deleted after registration
#             and one whose registration outlived its Info.plist, an identifier mismatch: each
#             reports its dependency and launches and substitutes nothing;
#   trash     a registered copy moved into the Trash: how long Launch Services keeps the registration
#             (measured: not long enough for a request to meet it), and what each form then reports;
#   denied    an unreadable folder, and a bundle whose contents are unreadable: a chosen path inside
#             the folder, and a registration pointing into it, are `failed`, never absence, and an
#             unreadable Info.plist is never read as another identifier;
#   bundle    a program that is not a bundle has no named-selector route, a bundle that
#             declares no identifier is not reachable by one, and a default handler without
#             an identifier still receives a document.
# And, once, that Accessibility was absent throughout and that no consent dialog appeared.
#
# Nothing here runs an application on the host. The procedure and its recorded evidence:
# docs/verification/application-installations-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
# KOINE_LAUNCHERS_IMAGE is the prepared image (default koine-launchers-prepared).
# Exit status: 0 every case passed; 1 a case failed.
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
KOINE_VM_LOG_PREFIX="installations-vm-"
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
SUBJECTS=(scripts/vm-verify-installations.sh scripts/vm-installation-fixtures.sh scripts/vm-installation-request.py scripts/vm-installation-trash-window.py scripts/vm-registration-lookup.swift
    Fixtures/InstallationFixture/main.swift scripts/vm-verify-witness-lib.sh scripts/vm-verify-contract-client-lib.sh
    scripts/vm-verify-launch-lib.sh scripts/vm-launchers-lib.sh "${BUNDLE}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}")
subjects_digest() { shasum -a 256 "${SUBJECTS[@]}"; }
SUBJECTS_BEFORE="$(subjects_digest)"
echo "Subjects of this run:"
echo "${SUBJECTS_BEFORE}"

OTHER="Calculator"
ID="dev.koine.test.InstallationFixture"
ROOT="/Users/admin/install-fx"
TRASHED="/Users/admin/.Trash/Fixture-trashed.app"
FIXTURE_LOG='$HOME/install-fixture.jsonl'
{
    WATCH='$HOME/watch.jsonl'
    BOTH='$HOME/koine-secret-both'
    MANAGER='$HOME/koine-secret-manager'
}
# shellcheck source=scripts/vm-verify-launch-lib.sh
source scripts/vm-verify-launch-lib.sh
# shellcheck source=scripts/vm-verify-witness-lib.sh
source scripts/vm-verify-witness-lib.sh

NODE_ARCHIVE="$(scripts/stage-node-runtime.sh)"
WITNESS_BIN="$(Fixtures/LaunchWitness/build.sh .build/witness)"
RESULTS="${WORK}/results.jsonl"
: >"${RESULTS}"
OUT_DIR=".build/installations-vm"
mkdir -p "${OUT_DIR}"

# --- the path files: the exact bytes each case submits -------------------------------------
# One file per path, carried into the guest in one archive and read there (`--path-file`, and
# `$(cat ...)` for an installation path), so that no shell, exec channel or terminal can
# repair, trim or re-encode what is sent. The exec channel is known to re-normalise Unicode in
# a command line, which is why a Unicode path is never typed into one.
mkdir -p "${WORK}/paths"
path_file() { printf '%s' "$2" >"${WORK}/paths/$1.txt"; }
E_ACUTE=$'\xc3\xa9'
E_COMBINING=$'e\xcc\x81'
N_TILDE=$'\xc3\xb1'
path_file app-A "${ROOT}/A/Fixture.app"
path_file app-B "${ROOT}/B/Fixture.app"
path_file app-link-dir "${ROOT}/link-to-B/Fixture.app"
path_file app-link-app "${ROOT}/link-to-B-app"
# Registered composed (Café), asked for decomposed (Cafe + U+0301), and the other way round.
path_file app-composed-as-decomposed "${ROOT}/Caf${E_COMBINING}/Fixture.app"
path_file app-decomposed-as-composed "${ROOT}/Caf${E_ACUTE} ${N_TILDE}/Fixture.app"
path_file app-missing "${ROOT}/no such folder/Fixture.app"
path_file app-unregistered "${ROOT}/unregistered/Fixture.app"
path_file app-stale "${ROOT}/stale/Fixture.app"
path_file app-noplist "${ROOT}/noplist/Fixture.app"
path_file app-trashed "${TRASHED}"
path_file app-locked "${ROOT}/locked/Fixture.app"
path_file app-bare "${ROOT}/bare/program"
path_file app-anon "${ROOT}/anon/Anonymous.app"
for n in 1 2 3 4 5 6 7 8 9 10 11 12; do path_file "doc-${n}" "${ROOT}/docs/note-${n}.koineinstall"; done
path_file doc-anon "${ROOT}/docs/default-anon.koineanon"
ditto -c -k "${WORK}/paths" "${WORK}/paths.zip"

# --- helpers ---------------------------------------------------------------------------------
# Calculator in front, Koine inactive: the precondition of every case.
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
    echo "Precondition: ${OTHER} is in front and Koine is inactive."
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
# What Launch Services says for each identifier, one line each, from the guest's own NSWorkspace calls.
registration() { guest_text "\$HOME/lookup $*"; }
FIXTURE_PROCESS_PATTERN='/Contents/MacOS/(Fixture|Anonymous)( |$)'
# quit_fixtures: every copy stopped, in one exec, and the stop observed.
quit_fixtures() {
    local count
    count="$(guest_text "pkill -f '${FIXTURE_PROCESS_PATTERN}'; for _ in 1 2 3 4 5 6 7 8; do pgrep -f '${FIXTURE_PROCESS_PATTERN}' >/dev/null || break; sleep 1; done; pkill -9 -f '${FIXTURE_PROCESS_PATTERN}'; sleep 1; echo remaining-\$(pgrep -f '${FIXTURE_PROCESS_PATTERN}' | wc -l | tr -d ' ')" | grep -o 'remaining-[0-9]*' | tail -1)"
    [ "${count}" = remaining-0 ] || fail "the fixture copies would not stop: ${count}"
}
# section_dialogs <section>: no Gatekeeper, consent or other system dialog is on screen after a section's
# requests (a dialog that one raised would stand over the next, so this is checked where it would show).
section_dialogs() {
    local dialogs
    dialogs="$(system_dialogs)"
    echo "Dialogs on screen after ${1}: ${dialogs:-none}"
    [ -z "${dialogs}" ] || fail "a system dialog is on screen after ${1}: ${dialogs}"
    record --arg s "$1" '{section: $s, case: "no system dialog after the section", status: "passed"}'
}

# --- one request, observed ----------------------------------------------------------------------
# request <launch|open> <bundle identifier or -> <installation path file or -> <document file or -> <effect: yes|no>
# Everything one case needs is done by scripts/vm-installation-request.py in ONE guest process, and
# its one answer is read back (the agent's exec channel costs seconds per command and reports a false
# timeout for a quarter of them): Calculator in front and Koine inactive, one request sent once, the
# copies' own logs since it was sent (awaited when `effect` is yes, and given time to show nothing
# happened when it is no), every instance of the identifier and every fixture process before and
# after, and the kernel's and the window server's account of the process the receipt names. Leaves
# OBS, one JSON object, and ANSWER.
# launch_detached <log file> <command...>: started in a session of its own, so that the agent ending the exec
# that started it (it reports a false timeout for a quarter of them, and then kills what the exec left running)
# does not end it. The guest scripts take their own lock, so starting one twice does nothing.
launch_detached() {
    guest "python3 -c 'import subprocess,sys; subprocess.Popen(sys.argv[2:], start_new_session=True, stdin=subprocess.DEVNULL, stdout=open(sys.argv[1], \"w\"), stderr=subprocess.STDOUT)' $*" || true
}
REQUEST_N=0
REQUEST_ENV=""
request() {
    local kind="$1" id="$2" app="$3" doc="$4" effect="$5" file tries=0
    REQUEST_N=$((REQUEST_N + 1))
    file="\$HOME/request-${REQUEST_N}.json"
    launch_detached "\$HOME/request-${REQUEST_N}.log" env ${REQUEST_ENV:-} python3 "\$HOME/request.py" "${file}" "${kind}" "${id}" "${app}" "${doc}" "${effect}" "${ID}" "${BUNDLE_ID}"
    OBS=""
    until OBS="$(guest_text "cat ${file} 2>/dev/null")" && jq -e . >/dev/null 2>&1 <<<"${OBS}"; do
        tries=$((tries + 1))
        [ "${tries}" -lt 120 ] || fail "request ${REQUEST_N} left no answer: $(guest_text "cat \$HOME/request-${REQUEST_N}.log")"
        sleep 4
    done
    jq -e 'has("error") | not' >/dev/null <<<"${OBS}" || fail "request ${REQUEST_N}: $(jq -c . <<<"${OBS}")"
    ANSWER="$(jq -c .answer <<<"${OBS}")"
    echo "Observation: $(jq -c '{classification: .answer.classification, status: .answer.status, reason: .answer.dependency.reason, process: .answer.process, errors: [.answer.errors[]? | .message],
        log: [.log[] | {event, label, pid, path}], instancesBefore: (.before | length), instancesAfter: [.after[] | {pid, bundle}], witness}' <<<"${OBS}")"
}

# --- the verdict of one case -----------------------------------------------------------------------
CASE_STATUS=passed
CASE_NOTES=""
CASE_NAME=""
case_begin() {
    CASE_STATUS=passed
    CASE_NOTES=""
    CASE_NAME="$1"
    step "$1"
}
# check <jq condition on OBS> <what must hold>
check() {
    if ! jq -e "$1" >/dev/null <<<"${OBS}"; then
        CASE_STATUS=failed
        CASE_NOTES="${CASE_NOTES}$2; "
        echo "CHECK FAILED: $2"
    fi
}
case_end() {
    # $1 section; the answer, log and instances are recorded with the verdict.
    record --arg s "$1" --arg c "${CASE_NAME}" --arg st "${CASE_STATUS}" --arg n "${CASE_NOTES}" --argjson o "${OBS:-null}" \
        '{section: $s, case: $c, status: $st, notes: $n, observed: $o}'
    echo "Result: $1: ${CASE_NAME}: ${CASE_STATUS}${CASE_NOTES:+ — ${CASE_NOTES}}"
}

# What a case may require, as jq conditions on OBS.
ACK='.answer.classification == "ok" and .answer.status == "AVAILABLE" and .answer.dependency == null and ((.answer.errors // []) | length == 0)'
# the receipt names the process the copy `L` itself logged, and the kernel's start instant is the receipt's
receipt_is() { printf '.answer.process as $p | $p != null and .witness.pid == $p.pid and .witness.startedAt == $p.startedAt and any(.log[]; .pid == $p.pid and .label == "%s")' "$1"; }
only_copy() { printf '(.log | length) > 0 and all(.log[]; .label == "%s")' "$1"; }
saw() { printf 'any(.log[]; .label == "%s" and .event == "%s")' "$1" "$2"; }
NOTHING='(.log | length) == 0 and .procsAfter == .procsBefore and .answer.process == null'
dependency() { printf '.answer.classification == "dependency-unavailable" and .answer.status == "DEPENDENCY_UNAVAILABLE" and .answer.dependency.reason == "%s" and (%s)' "$1" "${NOTHING}"; }
FAILED='.answer.classification == "failed" and .answer.process == null and (.log | length) == 0 and .procsAfter == .procsBefore'

# --- the guest ----------------------------------------------------------------------------------
start_vm
GATEKEEPER="$(guest 'spctl --status --verbose' 2>&1)"
echo "Gatekeeper in the clone: $(tr '\n' ';' <<<"${GATEKEEPER}")"
grep -qx 'assessments enabled' <<<"${GATEKEEPER}" ||
    fail "the clone is not Gatekeeper-enforcing; run: task launchers:prepare"
install_app
step "Carry the client, the Node runtime, the witness, the fixture and the path files into the guest"
testanyware file upload "${NODE_ARCHIVE}" /Users/admin/node.tar.xz >/dev/null
testanyware file upload "${BUNDLE}" /Users/admin/koine-client.mjs >/dev/null
testanyware file upload scripts/vm-verify-contract-client-trim.py /Users/admin/trim.py >/dev/null
testanyware file upload scripts/vm-verify-launch-client.py /Users/admin/vm-verify-launch-client.py >/dev/null
testanyware file upload "${WITNESS_BIN}" /Users/admin/LaunchWitness >/dev/null
testanyware file upload "${WORK}/paths.zip" /Users/admin/paths.zip >/dev/null
guest 'mkdir -p $HOME/fx-src'
testanyware file upload Fixtures/InstallationFixture/main.swift /Users/admin/fx-src/main.swift >/dev/null
testanyware file upload scripts/vm-installation-fixtures.sh /Users/admin/vm-installation-fixtures.sh >/dev/null
testanyware file upload scripts/vm-registration-lookup.swift /Users/admin/lookup.swift >/dev/null
testanyware file upload scripts/vm-installation-request.py /Users/admin/request.py >/dev/null
testanyware file upload scripts/vm-installation-trash-window.py /Users/admin/trash-window.py >/dev/null
guest 'cd $HOME && rm -rf node paths && tar -xJf node.tar.xz && mv node-*-darwin-arm64 node && chmod +x $HOME/LaunchWitness && ditto -x -k paths.zip paths && ls paths | wc -l && ./node/bin/node --version'

step "The fixture: one application installed at several locations, registered under one identifier"
# The recipe outlasts one exec, and is not safe to run twice, so it runs detached under a guard.
guest 'cd $HOME && mkdir fx.started 2>/dev/null || exit 0; rm -rf /Users/admin/install-fx; (nohup bash -c "bash vm-installation-fixtures.sh \$HOME/fx-src /Users/admin/install-fx > fx.log 2>&1; echo \$? > fx.exit" >/dev/null 2>&1 &)' || true
for _ in $(seq 1 60); do
    guest "[ -e \$HOME/fx.exit ]" >/dev/null 2>&1 && break
    sleep 3
done
guest 'cat $HOME/fx.log' | tail -3
[ "$(guest_text 'cat $HOME/fx.exit' | tr -d '[:space:]')" = 0 ] || fail "the fixture recipe did not finish"
guest 'cd $HOME && swiftc -O lookup.swift -o lookup 2>&1 | tail -3'
guest '[ -x $HOME/lookup ]' || fail "the registration lookup did not build in the guest"
echo "Fixture copies in the guest:"
guest "find ${ROOT} -maxdepth 2 -name '*.app' -o -name program -o -type l | sort"
guest "codesign --verify --strict ${ROOT}/A/Fixture.app ${ROOT}/B/Fixture.app && echo signed"

# Registration, as Launch Services answers it, before anything is asked of Koine.
step "What Launch Services says about each identifier before any request"
REGISTRATION_BEFORE="$(registration ${ID} ${ID}.Composed ${ID}.Decomposed ${ID}.Stale ${ID}.NoPlist ${ID}.Trashed ${ID}.Unregistered ${ID}.Locked)"
echo "${REGISTRATION_BEFORE}"
OPENS_BEFORE="$(guest_text "\$HOME/lookup --opens ${ROOT}/docs/default-anon.koineanon")"
echo "${OPENS_BEFORE}"
PREFERRED="$(awk -F'\t' -v id="${ID}" '$1 == id {print $2}' <<<"${REGISTRATION_BEFORE}")"
LISTED="$(awk -F'\t' -v id="${ID}" '$1 == id {print $3}' <<<"${REGISTRATION_BEFORE}")"
case "${PREFERRED}" in
*/A/Fixture.app) P=A; N=B ;;
*/B/Fixture.app) P=B; N=A ;;
*) fail "Launch Services does not name one of the two copies for ${ID}: ${PREFERRED}" ;;
esac
{ grep -q "${ROOT}/A/Fixture.app" <<<"${LISTED}" && grep -q "${ROOT}/B/Fixture.app" <<<"${LISTED}"; } ||
    fail "Launch Services does not list both copies of ${ID}: ${LISTED}"
echo "Launch Services chooses copy ${P} for ${ID}; the other, ${N}, is the one a running copy stands in for."
# The precondition of the absent cases, read rather than assumed. (Launch Services registers a bundle
# it finds under the home folder on its own, some time after it appears, so the unregistered copy is
# unregistered again, and read again, right before the cases that need it.)
grep -q "^${ID}.Stale	none	none$" <<<"${REGISTRATION_BEFORE}" || echo "Note: a registration for the deleted copy remains; recorded."
grep -q "^${ID}.NoPlist	${ROOT}/noplist/Fixture.app" <<<"${REGISTRATION_BEFORE}" || fail "the registration that outlives its Info.plist did not remain"
record --arg r "${REGISTRATION_BEFORE}" --arg preferred "${P}" '{section: "registration", case: "what Launch Services says before any request", status: "recorded", registration: $r, preferredCopy: $preferred}'

step "Launch Koine; a manager grant in the window, then the contract-only client enrols its own grant"
launch
create_grant "installations-manager" "${MANAGER}" koine:manage
accessibility_is false
enrol "${BOTH}" installations-client-both workspace:control desktop:control
expect '.grant.capabilities == ["desktop:control","workspace:control"] or .grant.capabilities == ["workspace:control","desktop:control"]' \
    "the grant is not exactly both controls"
echo "Accessibility is not granted to Koine in this image: every request below is by workspace:control and desktop:control alone."

SECTIONS="${KOINE_INSTALLATIONS_ONLY:-}"
# wanted <section>: whether KOINE_INSTALLATIONS_ONLY (a comma-separated list of texts) names it.
wanted() {
    local word
    [ -z "${SECTIONS}" ] && return 0
    for word in ${SECTIONS//,/ }; do [[ "$1" == *"${word}"* ]] && return 0; done
    return 1
}
guest "rm -f ${FIXTURE_LOG}" || true
quit_fixtures

if wanted reuse; then
    S="reuse"
    # --- launch ----------------------------------------------------------------------------
    case_begin "launch: nothing running; unconstrained launch starts the copy Launch Services chooses (${P})"
    request launch "${ID}" - - yes
    check "${ACK}" "the launch was not acknowledged"
    check "$(only_copy "${P}")" "a copy other than ${P} ran"
    check "$(saw "${P}" launched)" "${P} did not start"
    check "$(receipt_is "${P}")" "the receipt is not the kernel's identity for the process that logged itself as ${P}"
    check '(.after | length) == 1' "not exactly one instance"
    case_end "${S}"
    quit_fixtures

    case_begin "launch: the other copy (${N}) is running; an unconstrained launch reuses it and starts no second copy"
    request launch "${ID}" "app-${N}" - yes
    check "${ACK}" "launching ${N} by its path was not acknowledged"
    check "$(saw "${N}" launched)" "${N} did not start"
    case_end "${S}"
    case_begin "launch: unconstrained, with ${N} running, reuses ${N} rather than starting ${P}"
    request launch "${ID}" - - yes
    check "${ACK}" "the unconstrained launch was not acknowledged"
    check "$(saw "${N}" reopen)" "the running ${N} was not asked to reopen"
    check "$(only_copy "${N}")" "a copy other than ${N} was reached"
    check "$(receipt_is "${N}")" "the receipt is not ${N}'s kernel identity"
    check '(.after | length) == 1 and (.after[0].pid == (.before[0].pid))' "the running copy was not the only instance afterwards, or changed"
    check '(.procsAfter | length) == 1' "a second process of the fixture exists"
    case_end "${S}"

    case_begin "launch: a path chooses exactly ${P} while ${N} runs; ${N} is untouched"
    request launch "${ID}" "app-${P}" - yes
    check "${ACK}" "the constrained launch was not acknowledged"
    check "$(saw "${P}" launched)" "${P} did not start"
    check "$(only_copy "${P}")" "the request reached a copy other than the one chosen"
    check "$(receipt_is "${P}")" "the receipt is not ${P}'s kernel identity"
    check '(.after | length) == 2' "not exactly two instances"
    check '(.before[0].pid as $n | any(.after[]; .pid == $n))' "the running copy did not survive"
    case_end "${S}"

    case_begin "launch: with both running, a path chooses ${N} (reopen) and starts nothing"
    request launch "${ID}" "app-${N}" - yes
    check "${ACK}" "the constrained launch was not acknowledged"
    check "$(saw "${N}" reopen)" "${N} was not asked to reopen"
    check "$(only_copy "${N}")" "the request reached a copy other than the one chosen"
    check "$(receipt_is "${N}")" "the receipt is not ${N}'s kernel identity"
    check '(.after | length) == 2 and ((.before | map(.pid) | sort) == (.after | map(.pid) | sort))' "the instances changed"
    case_end "${S}"

    case_begin "launch: with both running, a path chooses ${P} (reopen) and starts nothing"
    request launch "${ID}" "app-${P}" - yes
    check "${ACK}" "the constrained launch was not acknowledged"
    check "$(saw "${P}" reopen)" "${P} was not asked to reopen"
    check "$(only_copy "${P}")" "the request reached a copy other than the one chosen"
    check "$(receipt_is "${P}")" "the receipt is not ${P}'s kernel identity"
    check '(.after | length) == 2 and ((.before | map(.pid) | sort) == (.after | map(.pid) | sort))' "the instances changed"
    case_end "${S}"
    quit_fixtures

    # --- open a document in the named application ---------------------------------------------
    case_begin "open: nothing running; the named application unconstrained opens the document in the copy Launch Services chooses (${P})"
    request open "${ID}" - doc-1 yes
    check "${ACK}" "the open was not acknowledged"
    check "$(only_copy "${P}")" "a copy other than ${P} ran"
    check 'any(.log[]; .event == "open" and (.path | endswith("/docs/note-1.koineinstall")))' "the document was not handed over"
    check "$(receipt_is "${P}")" "the receipt is not ${P}'s kernel identity"
    case_end "${S}"
    quit_fixtures

    case_begin "open: ${N} is running; the named application unconstrained reuses it for the document"
    request launch "${ID}" "app-${N}" - yes
    check "${ACK}" "launching ${N} by its path was not acknowledged"
    case_end "${S}"
    case_begin "open: the unconstrained named open hands the document to the running ${N}, never starting ${P}"
    request open "${ID}" - doc-2 yes
    check "${ACK}" "the open was not acknowledged"
    check "$(saw "${N}" open)" "${N} did not receive the document"
    check "$(only_copy "${N}")" "a copy other than ${N} was reached"
    check 'any(.log[]; .event == "open" and (.path | endswith("/docs/note-2.koineinstall")))' "the document handed over is not the one sent"
    check "$(receipt_is "${N}")" "the receipt is not ${N}'s kernel identity"
    check '(.procsAfter | length) == 1 and (.after | length) == 1' "a second copy started"
    case_end "${S}"

    case_begin "open: a path chooses exactly ${P} while ${N} runs; the document goes to ${P} only"
    request open "${ID}" "app-${P}" doc-3 yes
    check "${ACK}" "the open was not acknowledged"
    check "$(saw "${P}" open)" "${P} did not receive the document"
    check "$(only_copy "${P}")" "the request reached a copy other than the one chosen"
    check "$(receipt_is "${P}")" "the receipt is not ${P}'s kernel identity"
    check '(.after | length) == 2' "not exactly two instances"
    case_end "${S}"

    case_begin "open: with both running, a path chooses ${N}; the document goes to ${N} only"
    request open "${ID}" "app-${N}" doc-4 yes
    check "${ACK}" "the open was not acknowledged"
    check "$(saw "${N}" open)" "${N} did not receive the document"
    check "$(only_copy "${N}")" "the request reached a copy other than the one chosen"
    check "$(receipt_is "${N}")" "the receipt is not ${N}'s kernel identity"
    check '(.after | length) == 2 and ((.before | map(.pid) | sort) == (.after | map(.pid) | sort))' "the instances changed"
    case_end "${S}"
    quit_fixtures
    section_dialogs "reuse"
fi

if wanted spelling; then
    S="spelling"
    # Another copy runs first, so that a launch which merely reused "a running copy" would show.
    for spelling in "link-dir|a symlink to the copy's folder|doc-5" "link-app|a symlink to the copy's bundle|doc-6"; do
        IFS='|' read -r file what doc <<<"${spelling}"
        quit_fixtures
        request launch "${ID}" "app-A" - yes >/dev/null
        case_begin "launch: ${what} chooses copy B by file identity, with copy A running"
        request launch "${ID}" "app-${file}" - yes
        check "${ACK}" "the launch was not acknowledged"
        check "$(only_copy B)" "the copy that ran is not B"
        check "$(saw B launched)" "B did not start"
        check "$(receipt_is B)" "the receipt is not B's kernel identity"
        check '(.after | length) == 2' "not exactly two instances"
        case_end "${S}"
        case_begin "open: ${what} chooses copy B by file identity, with copy A running and B stopped"
        guest "pkill -f '${ROOT}/B/Fixture.app/Contents/MacOS/Fixture'" || true
        sleep 3
        request open "${ID}" "app-${file}" "${doc}" yes
        check "${ACK}" "the open was not acknowledged"
        check "$(only_copy B)" "the copy that ran is not B"
        check "$(saw B open)" "B did not receive the document"
        check "$(receipt_is B)" "the receipt is not B's kernel identity"
        case_end "${S}"
    done
    quit_fixtures
    # The Unicode spellings: each registered under one normalisation form and asked for in the other.
    for spelling in "app-composed-as-decomposed|${ID}.Composed|U1|composed|decomposed|doc-7" "app-decomposed-as-composed|${ID}.Decomposed|U2|decomposed|composed|doc-8"; do
        IFS='|' read -r file id label registered asked doc <<<"${spelling}"
        quit_fixtures
        case_begin "launch: a path spelled ${asked} chooses the copy registered ${registered}"
        request launch "${id}" "${file}" - yes
        check "${ACK}" "the launch was not acknowledged"
        check "$(only_copy "${label}")" "the copy that ran is not ${label}"
        check "$(saw "${label}" launched)" "${label} did not start"
        check "$(receipt_is "${label}")" "the receipt is not ${label}'s kernel identity"
        check ".answer.application.applicationPath | type == \"string\"" "the client did not record the path it sent"
        case_end "${S}"
        quit_fixtures
        case_begin "open: a path spelled ${asked} chooses the copy registered ${registered}"
        request open "${id}" "${file}" "${doc}" yes
        check "${ACK}" "the open was not acknowledged"
        check "$(only_copy "${label}")" "the copy that ran is not ${label}"
        check "$(saw "${label}" open)" "${label} did not receive the document"
        check "$(receipt_is "${label}")" "the receipt is not ${label}'s kernel identity"
        case_end "${S}"
    done
    quit_fixtures
    section_dialogs "spelling"
fi

if wanted absent; then
    S="absent"
    quit_fixtures
    # Each case is asked as a launch and as a named opening; every one launches nothing, and
    # neither copy of ${ID} may stand in for the one that was asked for.
    ABSENT=(
        "a missing copy (the path does not exist)|${ID}|app-missing|APPLICATION_NOT_INSTALLED"
        "a present copy that is not registered|${ID}.Unregistered|app-unregistered|APPLICATION_NOT_INSTALLED"
        "a copy deleted after it was registered|${ID}.Stale|app-stale|APPLICATION_NOT_INSTALLED"
        "a registration that outlived its bundle's Info.plist (the bundle declares no identifier)|${ID}.NoPlist|app-noplist|APPLICATION_IDENTITY_MISMATCH"
        "a present copy of another identifier|dev.koine.test.Other|app-B|APPLICATION_IDENTITY_MISMATCH"
    )
    for spec in "${ABSENT[@]}"; do
        IFS='|' read -r what id file reason <<<"${spec}"
        REQUEST_ENV=""
        [ "${id}" != "${ID}.Unregistered" ] || REQUEST_ENV="KOINE_UNREGISTER=${ROOT}/unregistered/Fixture.app:${ID}.Unregistered"
        case_begin "launch: ${what}, chosen by its path, is ${reason}"
        request launch "${id}" "${file}" - no
        check "$(dependency "${reason}")" "not ${reason} with nothing launched"
        case_end "${S}"
        case_begin "open: ${what}, chosen by its path, is ${reason}"
        request open "${id}" "${file}" doc-9 no
        check "$(dependency "${reason}")" "not ${reason} with nothing opened"
        case_end "${S}"
    done
    # The unconstrained forms of the registrations that cannot be chosen.
    for spec in "a present copy that is not registered|${ID}.Unregistered|APPLICATION_NOT_INSTALLED" "a copy deleted after it was registered|${ID}.Stale|APPLICATION_NOT_INSTALLED" "a registration that outlived its bundle's Info.plist|${ID}.NoPlist|APPLICATION_IDENTITY_MISMATCH"; do
        IFS='|' read -r what id reason <<<"${spec}"
        REQUEST_ENV=""
        [ "${id}" != "${ID}.Unregistered" ] || REQUEST_ENV="KOINE_UNREGISTER=${ROOT}/unregistered/Fixture.app:${ID}.Unregistered"
        case_begin "launch: ${what}, by identifier alone, is ${reason}"
        request launch "${id}" - - no
        check "$(dependency "${reason}")" "not ${reason} with nothing launched"
        case_end "${S}"
        case_begin "open: ${what}, by identifier alone, is ${reason}"
        request open "${id}" - doc-9 no
        check "$(dependency "${reason}")" "not ${reason} with nothing opened"
        case_end "${S}"
    done
    REQUEST_ENV=""
    # A running copy never stands in for the copy that was asked for and is not installed.
    request launch "${ID}" "app-${N}" - yes >/dev/null
    case_begin "launch: with ${N} running, a missing path is still APPLICATION_NOT_INSTALLED and ${N} is not substituted"
    request launch "${ID}" app-missing - no
    check '.answer.classification == "dependency-unavailable" and .answer.dependency.reason == "APPLICATION_NOT_INSTALLED" and .answer.process == null' "not APPLICATION_NOT_INSTALLED"
    check '(.log | length) == 0 and .procsAfter == .procsBefore' "the running copy was reopened, or another was started"
    case_end "${S}"
    quit_fixtures
    section_dialogs "absent"
fi

if wanted trash; then
    S="trash"
    quit_fixtures
    # What the platform does with a registered copy moved into the Trash, measured (the contract says such a copy
    # stays eligible, and Launch Services is where eligibility starts): a fresh copy is registered, moved, and
    # Launch Services is asked as fast as the guest can ask, for four seconds, three times.
    step "How long Launch Services keeps a registered copy that was moved into the Trash"
    launch_detached "\$HOME/trash-window.log" python3 "\$HOME/trash-window.py" "\$HOME/trash-window.json" 3
    TRASH_WINDOW_JSON=""
    for _ in $(seq 1 60); do
        TRASH_WINDOW_JSON="$(guest_text 'cat $HOME/trash-window.json 2>/dev/null')"
        jq -e . >/dev/null 2>&1 <<<"${TRASH_WINDOW_JSON}" && break
        sleep 4
    done
    jq -e . >/dev/null 2>&1 <<<"${TRASH_WINDOW_JSON}" || fail "the Trash timeline was not recorded"
    echo "Timeline: $(jq -c . <<<"${TRASH_WINDOW_JSON}")"
    record --argjson t "${TRASH_WINDOW_JSON}" '{section: "trash", case: "how long Launch Services keeps a registered copy moved into the Trash", status: "recorded", timeline: $t}'
    # Each request makes a fresh copy, registers it and moves it into the Trash immediately before the request
    # (scripts/vm-installation-request.py). Launch Services has then dropped it, so a request meets no registration.
    REQUEST_ENV="KOINE_TRASH=${TRASHED}:${ID}.Trashed"
    GONE='(.registrationAfter | test("\\tnone\\tnone$"))'
    case_begin "launch: a copy moved into the Trash, by identifier alone, reports what Launch Services then says (nothing registered)"
    request launch "${ID}.Trashed" - - no
    check "${GONE}" "Launch Services still reported the Trash copy after the request"
    check "$(dependency APPLICATION_NOT_INSTALLED)" "not APPLICATION_NOT_INSTALLED with nothing launched"
    case_end "${S}"
    case_begin "launch: a copy moved into the Trash, chosen by its path, reports what Launch Services then says (nothing registered)"
    request launch "${ID}.Trashed" app-trashed - no
    check "${GONE}" "Launch Services still reported the Trash copy after the request"
    check "$(dependency APPLICATION_NOT_INSTALLED)" "not APPLICATION_NOT_INSTALLED with nothing launched"
    case_end "${S}"
    case_begin "open: a copy moved into the Trash, chosen by its path, reports what Launch Services then says (nothing registered)"
    request open "${ID}.Trashed" app-trashed doc-10 no
    check "${GONE}" "Launch Services still reported the Trash copy after the request"
    check "$(dependency APPLICATION_NOT_INSTALLED)" "not APPLICATION_NOT_INSTALLED with nothing opened"
    case_end "${S}"
    REQUEST_ENV=""
    guest "rm -rf ${TRASHED}" || true
    section_dialogs "trash"
fi

if wanted denied; then
    S="denied"
    quit_fixtures
    step "Make the folder of one registered copy unreadable, and read what Launch Services then answers"
    guest "chmod 000 ${ROOT}/locked" || fail "the folder was not locked"
    sleep 3
    REGISTRATION_LOCKED="$(registration ${ID}.Locked)"
    echo "${REGISTRATION_LOCKED}"
    record --arg r "${REGISTRATION_LOCKED}" '{section: "denied", case: "what Launch Services says for a registered copy in an unreadable folder", status: "recorded", registration: $r}'
    case_begin "launch: a path inside an unreadable folder is failed, never absence"
    request launch "${ID}.Locked" app-locked - no
    check "${FAILED}" "not a failure with nothing launched"
    case_end "${S}"
    case_begin "open: a path inside an unreadable folder is failed, never absence"
    request open "${ID}.Locked" app-locked doc-11 no
    check "${FAILED}" "not a failure with nothing opened"
    case_end "${S}"
    if cut -f2 <<<"${REGISTRATION_LOCKED}" | grep -q "${ROOT}/locked/Fixture.app"; then
        case_begin "launch: a registration that points into an unreadable folder is failed, never absence"
        request launch "${ID}.Locked" - - no
        check "${FAILED}" "not a failure with nothing launched"
        case_end "${S}"
    else
        echo "Launch Services dropped the registration of the unreadable copy, so there is no registration to deny by identifier alone: recorded."
        record '{section: "denied", case: "a registration that points into an unreadable folder", status: "not-producible", notes: "Launch Services reports no registration for the copy once its folder is unreadable"}'
    fi
    guest "chmod 755 ${ROOT}/locked" || true
    # The same copy with its folder readable and its bundle's contents sealed: the bundle is there and its
    # Info.plist cannot be read, which `Bundle(url:)` reports as no identifier at all. A denial must not read as
    # another identifier.
    step "Seal the bundle's contents instead of its folder"
    guest "chmod 000 ${ROOT}/locked/Fixture.app/Contents" || fail "the bundle was not sealed"
    sleep 3
    REGISTRATION_SEALED="$(registration ${ID}.Locked)"
    echo "${REGISTRATION_SEALED}"
    record --arg r "${REGISTRATION_SEALED}" '{section: "denied", case: "what Launch Services says for a registered copy whose contents are unreadable", status: "recorded", registration: $r}'
    case_begin "launch: a bundle whose contents cannot be read is failed, never a different identifier"
    request launch "${ID}.Locked" app-locked - no
    check "${FAILED}" "not a failure with nothing launched"
    case_end "${S}"
    case_begin "open: a bundle whose contents cannot be read is failed, never a different identifier"
    request open "${ID}.Locked" app-locked doc-11 no
    check "${FAILED}" "not a failure with nothing opened"
    case_end "${S}"
    guest "chmod 755 ${ROOT}/locked/Fixture.app/Contents" || true
    section_dialogs "denied"
fi

if wanted bundle; then
    S="bundle"
    quit_fixtures
    case_begin "launch: a program that is not a bundle has no named-selector route"
    request launch "${ID}" app-bare - no
    check "$(dependency APPLICATION_NOT_INSTALLED)" "not APPLICATION_NOT_INSTALLED with nothing launched"
    case_end "${S}"
    case_begin "open: a program that is not a bundle has no named-selector route"
    request open "${ID}" app-bare doc-12 no
    check "$(dependency APPLICATION_NOT_INSTALLED)" "not APPLICATION_NOT_INSTALLED with nothing opened"
    case_end "${S}"
    case_begin "launch: a bundle that declares no identifier is not reachable by any named identifier"
    request launch "${ID}" app-anon - no
    check "$(dependency APPLICATION_IDENTITY_MISMATCH)" "not APPLICATION_IDENTITY_MISMATCH with nothing launched"
    case_end "${S}"
    case_begin "open: a bundle that declares no identifier is not reachable by a named identifier"
    request open "${ID}" app-anon doc-12 no
    check "$(dependency APPLICATION_IDENTITY_MISMATCH)" "not APPLICATION_IDENTITY_MISMATCH with nothing opened"
    case_end "${S}"
    case_begin "open: the default handler of a document, which declares no identifier, still receives it"
    OPENS_NOW="$(guest_text "\$HOME/lookup --opens ${ROOT}/docs/default-anon.koineanon")"
    echo "Launch Services' default for the document: ${OPENS_NOW}"
    cut -f2 <<<"${OPENS_NOW}" | grep -q "${ROOT}/anon/Anonymous.app" || fail "the anonymous bundle is not the document's default handler in this image"
    cut -f3 <<<"${OPENS_NOW}" | grep -qx none || fail "the default handler declares an identifier after all"
    request open - - doc-anon yes
    check "${ACK}" "the default-handler open was not acknowledged"
    check "$(only_copy ANON)" "the document did not reach the anonymous bundle"
    check "$(saw ANON open)" "the anonymous bundle did not receive the document"
    check "$(receipt_is ANON)" "the receipt is not the anonymous bundle's kernel identity"
    case_end "${S}"
    quit_fixtures
    section_dialogs "bundle"
fi

step "Accessibility was absent throughout, and no consent dialog is on screen"
accessibility_is false
no_consent_dialog "after every request"
record '{case: "accessibility absent throughout", status: "passed"}'

step "The subjects of the run are as they were at its start"
[ "$(subjects_digest)" = "${SUBJECTS_BEFORE}" ] || fail "a subject of this run changed while it ran; the run measured nothing"
echo "Unchanged: ${#SUBJECTS[@]} files, digested before and after."

step "Results"
jq -s '.' "${RESULTS}" >"${OUT_DIR}/results.json"
jq -r '.[] | select(.case != null) | "\(.section // "-"): \(.case): \(.status)"' "${OUT_DIR}/results.json"
echo "Written: ${OUT_DIR}/results.json"
FAILED_COUNT="$(jq '[.[] | select(.status == "failed")] | length' "${OUT_DIR}/results.json")"

step "Quit Koine"
for _ in 1 2 3; do
    testanyware agent window-focus --window "${APP_NAME}" >/dev/null 2>&1 || true
    sleep 1
    testanyware input key q --modifiers cmd >/dev/null || true
    sleep 3
    guest "! pgrep -f ${INSTALLED}" >/dev/null 2>&1 && break
done
guest "! pgrep -f ${INSTALLED}" >/dev/null 2>&1 || { echo "Koine did not quit on Command-Q three times; terminated (recorded, not an acceptance case)."; guest "pkill -f ${INSTALLED}" || true; }

if [ "${FAILED_COUNT}" != 0 ]; then
    echo "FAILED: ${FAILED_COUNT} case(s) failed — transcript in ${LOG}" >&2
    exit 1
fi
step "PASSED — transcript in ${LOG}"
