#!/bin/bash
# Verifies, on the signed Koine.app 1.0.1 in a clone of the prepared launcher image
# (scripts/vm-prepare-launchers.sh, docs/verification/launcher-apps-vm.md: Gatekeeper
# ENFORCING, Zed, Visual Studio Code, iTerm and Safari installed and past their first run),
# the V rows of the long-location target stage of workspaceOpenPath and workspaceRevealPath
# (docs/specs/workspace-launch-and-open.md#subjects-and-versions), through the contract-only
# client under workspace:control AND desktop:control, with Accessibility never granted.
#
# THE OBSERVERS ARE CONTROLLED FIRST, AT THE ADMITTED LENGTH. Before Koine is asked anything,
# a 1,023-byte document and directory, built component by component, are opened and revealed
# by an independent non-Koine route (`open` and `open -R` from the test agent), and each
# observer must see them:
#   delivery   the K134 witness application (a document handler that records the exact bytes
#              of the path it is handed, docs/verification/long-action-route/probe.m), the
#              handler's own window (TextEdit, Zed or Finder, read from the window server by
#              title), and Fixtures/LaunchWitness (launches, activations, the front application);
#   selection  Finder's own account of its front window's folder and selected item, by
#              AppleScript run from the test agent (scripts/vm-reveal-observe.applescript).
# No subject of 1,024 bytes or more is ever a control: no over-limit delivery by any route is a
# prerequisite, because the v1 decision defers it. An observer that cannot see the 1,023-byte
# control leaves every observation pending (exit 3); it passes and fails nothing.
#
# Sections (KOINE_TARGET_ONLY names them; the controls run first unless only platform and prompt are named):
#   reach    1,023-byte documents opened in their default handler and in Zed, a directory
#            opened in Finder and in Zed, a witness document delivered with its exact bytes,
#            and a document and a directory revealed;
#   refus    1,024-byte and about-1,500-byte documents, witness documents and directories,
#            opened by default, opened in Zed and revealed: Koine answers `failed` with
#            guidance naming the hand-off stage, the spelling and its byte count, and the
#            controlled observers, watching for longer than the control needed, see nothing
#            delivered or selected; and a missing long path, which is PATH_NOT_FOUND;
#   walk     the present outcomes only an effect shows (a 31- and a 32-link chain, a final
#            directory with mode 0600, one link inode with entries in two directories, a
#            finite repeated dot-link, multibyte, combining-character and emoji names) opened
#            and revealed, and the 300-byte ASCII impossible component, which is absent;
#   root     the filesystem root and a link to it, revealed with and without a trailing slash;
#   platform what the system does by itself, with no Koine: the default-handler lookup follows
#            ten symbolic links and answers nil from eleven, and a plain program that is not Koine
#            is prompted when it hands an item in a protected folder to an application;
#   prompt   first-use resolution in Desktop, Documents and Downloads: reveal, a directory opened
#            in Finder (named and by default) and a document opened with Zed named, each a first
#            use, with a positive control (a standalone probe's content read prompts) before
#            Koine's first request. A reveal must not prompt. An open's first use asks the user once,
#            naming Koine: the disposable clone's user ALLOWS it (Antony's decision), the open must
#            then complete with its effect, and a second request must be prompt-free.
# And, once, that Accessibility was absent throughout and that the run's subjects are unchanged.
#
# Nothing here runs an application on the host. The procedure and its recorded evidence:
# docs/verification/target-locations-vm.md
#
# The run takes hours, because the guest agent answers each command in seconds: start it
# detached (task target-locations:vm-detached) and read the transcript it names.
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_LAUNCHERS_IMAGE is the prepared image (default koine-launchers-prepared).
# Exit status: 0 every case passed; 1 a case failed; 3 an observer was not controlled, so the
# observations are pending; 4 a prompt named Koine that the recipe did not answer (a reveal's).
# shellcheck disable=SC1112,SC2016  # curly quotes in dialog labels; guest-side $HOME
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
KOINE_VM_LOG_PREFIX="target-locations-vm-"
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
WITNESS_ZIP=".build/long-action-route.zip"
PROBE_ZIP=".build/descriptor-walk-prompt.zip"
for zip in "${WITNESS_ZIP}" "${PROBE_ZIP}"; do
    [ -f "${zip}" ] || { echo "Error: ${zip} does not exist. Run: task fixture:long-action-route / task fixture:descriptor-walk-prompt" >&2; exit 1; }
done

# Everything this run reads or runs, digested now and again at the end: a run whose subjects
# changed under it (the script itself included, which the shell reads as it goes) measured
# nothing, and says so.
SUBJECTS=(scripts/vm-finder-observer-lib.sh scripts/vm-verify-target-locations.sh scripts/vm-long-location-fixtures.py scripts/vm-reveal-observe.applescript
    docs/verification/target-locations-vm/handler-lookup.swift docs/verification/target-locations-vm/submit.swift
    docs/verification/target-locations-vm/submitter-info.plist
    scripts/vm-verify-witness-lib.sh scripts/vm-verify-contract-client-lib.sh scripts/vm-verify-launch-lib.sh
    scripts/vm-launchers-lib.sh "${WITNESS_ZIP}" "${PROBE_ZIP}" "${BUNDLE}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
    "${APP_BUNDLE}/Contents/PlugIns/Workspace.koineprovider/manifest.json")
subjects_digest() { shasum -a 256 "${SUBJECTS[@]}"; }
SUBJECTS_BEFORE="$(subjects_digest)"
echo "Subjects of this run:"
echo "${SUBJECTS_BEFORE}"

OTHER="Calculator"
ZED_ID="dev.zed.Zed"
PROBE_ID="dev.antony.Koine.K174Probe"
{
    WATCH='$HOME/watch.jsonl'
    BOTH='$HOME/koine-secret-both'
    WORKSPACE_ONLY='$HOME/koine-secret-workspace'
    MANAGER='$HOME/koine-secret-manager'
    PATHS='$HOME/paths'
    WITNESS_LOG='/tmp/koine-k134-witness.jsonl'
}
# shellcheck source=scripts/vm-verify-launch-lib.sh
source scripts/vm-verify-launch-lib.sh
# shellcheck source=scripts/vm-verify-witness-lib.sh
source scripts/vm-verify-witness-lib.sh

NODE_ARCHIVE="$(scripts/stage-node-runtime.sh)"
WITNESS_BIN="$(Fixtures/LaunchWitness/build.sh .build/witness)"
RESULTS="${WORK}/results.jsonl"
: >"${RESULTS}"
OUT_DIR=".build/target-locations-vm"
mkdir -p "${OUT_DIR}"

SECTIONS="${KOINE_TARGET_ONLY:-}"
# wanted <section>: whether KOINE_TARGET_ONLY (a comma-separated list) names it.
wanted() {
    local word
    [ -z "${SECTIONS}" ] && return 0
    for word in ${SECTIONS//,/ }; do [[ "$1" == *"${word}"* ]] && return 0; done
    return 1
}

# --- helpers ---------------------------------------------------------------------------------
KOINE_RUNNING=0
open_client() { contract_client_once "$@" >/dev/null; }
put_other_in_front() {
    guest "open -a ${OTHER}" || true
    local tries=0
    until witness_front >/dev/null && jq -e ".application.name == \"${OTHER}\"" >/dev/null <<<"${FRONT}"; do
        tries=$((tries + 1))
        [ "${tries}" -lt 15 ] || fail "${OTHER} did not come to the front"
        guest "open -a ${OTHER}" || true
        sleep 2
    done
    if [ "${KOINE_RUNNING}" = 1 ]; then
        instances "${BUNDLE_ID}"
        jq -e '.instances | length == 1 and .[0].isActive == false' >/dev/null <<<"${INSTANCES}" || fail "Koine is active"
        echo "Precondition: ${OTHER} is in front ($(jq -c '.application | {pid, startedAt}' <<<"${FRONT}")) and Koine is inactive."
    else
        echo "Precondition: ${OTHER} is in front ($(jq -c '.application | {pid, startedAt}' <<<"${FRONT}")); Koine has not been started."
    fi
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
# windows that contain any alternative, as a JSON array. A read that answered nothing (the
# agent's false timeout) is read again, never taken for "no window".
windows_with() {
    local out
    for _ in 1 2 3 4 5 6; do
        out="$(testanyware agent windows --json 2>/dev/null | jq -c --arg a "$1" --arg alts "$2" \
            '[.windows[] | select(.appName == $a) | .title as $t | select([($alts | split("|")[] | . as $s | select($s != "" and ($t | contains($s))))] | length > 0) | $t]' 2>/dev/null)" || out=""
        if [ -n "${out}" ]; then echo "${out}"; return 0; fi
        sleep 2
    done
    echo "the window list could not be read" >&2
    return 1
}
# window_list: every window of every application but Notification Center, sorted, as JSON.
window_list() {
    local out
    for _ in 1 2 3 4 5 6; do
        out="$(testanyware agent windows --json 2>/dev/null | jq -c '[.windows[] | select(.appName != "Notification Center") | [.appName, .title]] | sort' 2>/dev/null)" || out=""
        if [ -n "${out}" ]; then echo "${out}"; return 0; fi
        sleep 2
    done
    echo "the window list could not be read" >&2
    return 1
}
# The manifest of the guest's subjects: one JSON line each with the exact path in base64.
path_b64() { jq -r --arg i "$1" 'select(.id == $i) | .path_b64' <<<"${MANIFEST}"; }
path_bytes() { jq -r --arg i "$1" 'select(.id == $i) | .bytes' <<<"${MANIFEST}"; }
# path_text <id>: the exact path (ASCII for the long subjects; bash holds bytes as they are).
path_text() { path_b64 "$1" | base64 -d; }

# shellcheck source=scripts/vm-finder-observer-lib.sh
source scripts/vm-finder-observer-lib.sh

# --- the observers' checks: each returns 0 when it sees the effect --------------------------
# What the case expects is in EXP_*: EXP_APP and EXP_TITLE (a handler's window whose title
# contains it), EXP_B64 (the witness document's exact path), EXP_PATH and EXP_NAME (Finder's
# selection: the item's exact path, or only its name when EXP_PATH is empty).
chk_window() {
    local titles
    titles="$(windows_with "${EXP_APP}" "${EXP_TITLE}")" || return 1
    [ "${titles}" != "[]" ] || return 1
    TITLES="${titles}"
}
chk_witness() {
    WLOG="$(guest_text "cat ${WITNESS_LOG} 2>/dev/null")"
    jq -e -s --arg b "${EXP_B64}" 'map(select(.deliveredB64 == $b)) | length > 0' >/dev/null <<<"${WLOG}"
}
chk_selected() {
    observe
    jq -e --arg p "${EXP_PATH}" --arg n "${EXP_NAME}" '
        .windows >= 1 and (.selected | length == 1)
        and (.selected[0].name | rtrimstr("/") | contains($n))
        and ($p == "" or ((.selected[0].path | rtrimstr("/")) == ($p | rtrimstr("/"))))' >/dev/null <<<"${OBS}"
}
chk_window_any() {
    observe
    jq -e '.windows >= 1' >/dev/null <<<"${OBS}"
}
chk_root_view() {
    observe
    jq -e '.windows >= 1 and .target == "/" and (.selected | length == 0)' >/dev/null <<<"${OBS}"
}
# poll <seconds> <check function>: the check, every two seconds, from T0; SEEN_S is how long
# after the request it first held.
T0=0
sent_now() { T0="$(date +%s)"; }
poll() {
    local limit="$1" check="$2"
    SEEN_S=""
    while :; do
        if "${check}"; then
            SEEN_S=$(($(date +%s) - T0))
            return 0
        fi
        [ $(($(date +%s) - T0)) -lt "${limit}" ] || return 1
        sleep 2
    done
}
POLL_LIMIT=120

# open_effect <kind> <how> <id>: sets the check and EXP_* that an open of the subject has.
open_effect() {
    local kind="$1" how="$2" id="$3"
    EXP_APP="" EXP_TITLE="" EXP_B64="" CHECK_FN="chk_window" OBSERVER="" TITLES=""
    case "${kind}:${how}" in
        txt:default) EXP_APP=TextEdit EXP_TITLE="${id}.txt" OBSERVER="TextEdit's window" ;;
        txt:zed) EXP_APP=Zed EXP_TITLE="${id}.txt" OBSERVER="Zed's window" ;;
        wit:default) EXP_B64="$(path_b64 "${id}")" CHECK_FN="chk_witness" OBSERVER="the witness's exact bytes" ;;
        dir:default) EXP_APP=Finder EXP_TITLE="${id}" OBSERVER="Finder's window" ;;
        dir:zed) EXP_APP=Zed EXP_TITLE="${id}" OBSERVER="Zed's window" ;;
        *) fail "no observer for ${kind}:${how}" ;;
    esac
}
# before_open: the effect must not already be there, or the case would prove nothing.
before_open() {
    if [ "${CHECK_FN}" = chk_witness ]; then
        guest "rm -f ${WITNESS_LOG}" || true
    else
        local earlier
        earlier="$(windows_with "${EXP_APP}" "${EXP_TITLE}")" || fail "the window list could not be read before the case"
        [ "${earlier}" = "[]" ] || fail "${EXP_APP} already shows a window naming ${EXP_TITLE} (${earlier}): the case would prove nothing"
    fi
}

CONTROL_MISSES=0
MAX_CONTROL_S=0
# control_open <kind: txt|wit|dir> <how: default|zed> <id>: the independent route, `open`,
# from the test agent. The observers must see a 1,023-byte subject delivered by it.
control_open() {
    local kind="$1" how="$2" id="$3" flag="" status="passed" exact="null"
    [ "${how}" = zed ] && flag="-a Zed"
    step "control: ${kind} opened by an independent route (${how}), ${id}, $(path_bytes "${id}") bytes"
    open_effect "${kind}" "${how}" "${id}"
    put_other_in_front >/dev/null
    before_open
    watch_start
    guest "open ${flag} \"\$(cat ${PATHS}/${id}.txt)\"" || true
    # The time is counted from the moment the guest's agent has run the command (it may have taken
    # minutes to answer: its exec channel is slow and retried), which is when the observers start looking.
    sent_now
    if poll "${POLL_LIMIT}" "${CHECK_FN}"; then
        echo "Seen by ${OBSERVER} ${SEEN_S} s after the request: ${TITLES:-$(jq -c -s '[.[] | {deliveredLength, id}]' <<<"${WLOG:-}")}"
        [ "${SEEN_S}" -le "${MAX_CONTROL_S}" ] || MAX_CONTROL_S="${SEEN_S}"
        [ "${CHECK_FN}" = chk_witness ] && exact=true
    else
        status="not-seen"
        CONTROL_MISSES=$((CONTROL_MISSES + 1))
        echo "NOT SEEN by ${OBSERVER} within ${POLL_LIMIT} s"
    fi
    watch_read
    watch_stop
    record --arg s control --arg c "${kind} ${how} by an independent route" --arg id "${id}" --argjson b "$(path_bytes "${id}")" --arg o "${OBSERVER}" \
        --arg st "${status}" --arg after "${SEEN_S:-}" --argjson exact "${exact}" \
        '{section: $s, case: $c, id: $id, bytes: $b, observer: $o, status: $st, seenAfterS: $after, exactBytes: $exact}'
    echo "Result: control: ${kind} ${how} ${id}: ${status}"
}
# control_reveal <kind: file|dir> <id>: `open -R`.
control_reveal() {
    local kind="$1" id="$2" status="passed" name
    step "control: ${kind} revealed by an independent route, ${id}, $(path_bytes "${id}") bytes"
    EXP_PATH="$(path_text "${id}")"
    name="$(basename "${EXP_PATH}")"
    EXP_NAME="${name}"
    close_finder_windows
    put_other_in_front >/dev/null
    watch_start
    guest "open -R \"\$(cat ${PATHS}/${id}.txt)\"" || true
    sent_now
    if poll "${POLL_LIMIT}" chk_selected; then
        echo "Finder's account ${SEEN_S} s after the request, exact path equal: $(jq -c '.selected[0] | {kind, name}' <<<"${OBS}")"
        [ "${SEEN_S}" -le "${MAX_CONTROL_S}" ] || MAX_CONTROL_S="${SEEN_S}"
    else
        status="not-seen"
        CONTROL_MISSES=$((CONTROL_MISSES + 1))
        echo "NOT SEEN: Finder's account ${OBS:-none}"
    fi
    watch_read
    watch_stop
    record --arg s control --arg c "${kind} revealed by an independent route" --arg id "${id}" --argjson b "$(path_bytes "${id}")" \
        --arg st "${status}" --arg after "${SEEN_S:-}" \
        '{section: $s, case: $c, id: $id, bytes: $b, observer: "Finder'"'"'s own account", status: $st, seenAfterS: $after, exactBytes: ($st == "passed")}'
    echo "Result: control: reveal ${kind} ${id}: ${status}"
}

# koine_open <section> <label> <kind> <how> <id>: Koine's request, observed by the same check.
koine_open() {
    local section="$1" label="$2" kind="$3" how="$4" id="$5" flags="" status="passed" notes="" cb
    [ "${how}" = zed ] && flags="--bundle-identifier ${ZED_ID}"
    step "${section}: ${label}, ${id}, $(path_bytes "${id}") bytes"
    open_effect "${kind}" "${how}" "${id}"
    put_other_in_front >/dev/null
    before_open
    watch_start
    # shellcheck disable=SC2086
    open_client "open-path --secret \"${BOTH}\" --path-file \"${PATHS}/${id}.txt\" ${flags}"
    sent_now
    cb=$(($(jq -r .receivedMs <<<"${ANSWER}") - $(jq -r .sentMs <<<"${ANSWER}")))
    if [ "$(jq -r .classification <<<"${ANSWER}")" != ok ]; then
        status="failed"
        notes="not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
    else
        expect '.status == "AVAILABLE" and .dependency == null and .http.status == 200 and ((.errors // []) | length == 0)' "${label}: not an acknowledged open"
    fi
    if poll "${POLL_LIMIT}" "${CHECK_FN}"; then
        echo "Seen by ${OBSERVER} ${SEEN_S} s after the answer: ${TITLES:-delivered}"
    else
        status="failed"
        notes="${notes}${OBSERVER} did not see it within ${POLL_LIMIT} s; "
    fi
    watch_read
    watch_stop
    dialogs="$(system_dialogs)"
    echo "Dialogs on screen: ${dialogs:-none}"
    judge_dialogs "open" "${dialogs}"
    record --arg s "${section}" --arg c "${label}" --arg id "${id}" --argjson b "$(path_bytes "${id}")" --arg o "${OBSERVER}" --arg st "${status}" \
        --arg n "${notes}" --argjson ms "${cb}" --arg after "${SEEN_S:-}" \
        '{section: $s, case: $c, id: $id, bytes: $b, observer: $o, status: $st, answerMs: $ms, seenAfterS: $after, notes: $n}'
    echo "Result: ${section}: ${label}: ${status}${notes:+ — ${notes}}"
}
# koine_reveal <section> <label> <id> <selected name> [<exact selected path or empty>]
koine_reveal() {
    local section="$1" label="$2" id="$3" name="$4" exact="${5-}" status="passed" notes="" cb
    step "${section}: ${label}, ${id}, $(path_bytes "${id}") bytes"
    EXP_NAME="${name}"
    EXP_PATH="${exact}"
    close_finder_windows
    put_other_in_front >/dev/null
    watch_start
    open_client "reveal-path --secret \"${BOTH}\" --path-file \"${PATHS}/${id}.txt\""
    sent_now
    cb=$(($(jq -r .receivedMs <<<"${ANSWER}") - $(jq -r .sentMs <<<"${ANSWER}")))
    if [ "$(jq -r .classification <<<"${ANSWER}")" != ok ]; then
        status="failed"
        notes="not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
    else
        expect '.status == "AVAILABLE" and .dependency == null and .http.status == 200 and ((.errors // []) | length == 0) and .selectionObserved == false' "${label}: not an acknowledged reveal"
    fi
    if poll "${POLL_LIMIT}" chk_selected; then
        echo "Finder's account ${SEEN_S} s after the answer: $(jq -c . <<<"${OBS}" | cut -c1-600)"
    else
        status="failed"
        notes="${notes}Finder does not show ${name} selected: $(jq -c . <<<"${OBS}" | cut -c1-600); "
    fi
    watch_read
    watch_stop
    dialogs="$(system_dialogs)"
    echo "Dialogs on screen: ${dialogs:-none}"
    judge_dialogs "reveal" "${dialogs}"
    record --arg s "${section}" --arg c "${label}" --arg id "${id}" --argjson b "$(path_bytes "${id}")" --arg st "${status}" \
        --arg n "${notes}" --argjson ms "${cb}" --arg after "${SEEN_S:-}" --argjson obs "${OBS}" \
        '{section: $s, case: $c, id: $id, bytes: $b, status: $st, answerMs: $ms, seenAfterS: $after, finder: $obs, notes: $n}'
    echo "Result: ${section}: ${label}: ${status}${notes:+ — ${notes}}"
}

# --- the guest ----------------------------------------------------------------------------------
start_vm
GATEKEEPER="$(guest 'spctl --status --verbose' 2>&1)"
echo "Gatekeeper in the clone: $(tr '\n' ';' <<<"${GATEKEEPER}")"
grep -qx 'assessments enabled' <<<"${GATEKEEPER}" ||
    fail "the clone is not Gatekeeper-enforcing; run: task launchers:prepare"
install_app
step "Carry the client, the Node runtime, the witnesses, the observer, the fixture builder and the probes into the guest"
testanyware file upload "${NODE_ARCHIVE}" /Users/admin/node.tar.xz >/dev/null
testanyware file upload "${BUNDLE}" /Users/admin/koine-client.mjs >/dev/null
testanyware file upload scripts/vm-verify-contract-client-trim.py /Users/admin/trim.py >/dev/null
testanyware file upload scripts/vm-verify-launch-client.py /Users/admin/vm-verify-launch-client.py >/dev/null
testanyware file upload "${WITNESS_BIN}" /Users/admin/LaunchWitness >/dev/null
testanyware file upload scripts/vm-reveal-observe.applescript /Users/admin/finder-observe.applescript >/dev/null
testanyware file upload scripts/vm-long-location-fixtures.py /Users/admin/vlf.py >/dev/null
testanyware file upload "${WITNESS_ZIP}" /Users/admin/lar.zip >/dev/null
testanyware file upload "${PROBE_ZIP}" /Users/admin/k174.zip >/dev/null
guest 'cd $HOME && rm -rf node && tar -xJf node.tar.xz && mv node-*-darwin-arm64 node && chmod +x $HOME/LaunchWitness && echo target-locations > $HOME/launch-target.txt && ./node/bin/node --version'

step "The K134 witness application: a document handler for .k134w that records the exact bytes it is handed"
guest 'cd $HOME && rm -rf lar k174 && ditto -x -k lar.zip lar && ditto -x -k k174.zip k174 &&
    rm -rf /Applications/KoineK134Witness.app /Applications/KoineK174Probe.app &&
    ditto lar/KoineK134Witness.app /Applications/KoineK134Witness.app && ditto k174/KoineK174Probe.app /Applications/KoineK174Probe.app &&
    L=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister &&
    $L -f /Applications/KoineK134Witness.app && $L -f /Applications/KoineK174Probe.app &&
    codesign --verify --strict /Applications/KoineK134Witness.app /Applications/KoineK174Probe.app && echo installed'
WITNESS_PROBE="$(guest_text 'echo witness > $HOME/probe.k134w; rm -f /tmp/koine-k134-witness.jsonl; open $HOME/probe.k134w; sleep 5; cat /tmp/koine-k134-witness.jsonl')"
grep deliveredB64 <<<"${WITNESS_PROBE}" >/dev/null ||
    fail "the witness application is not the default handler of .k134w, or records nothing: ${WITNESS_PROBE}"
echo "The witness is the default handler of .k134w: it recorded a short document."
guest 'pkill -x KoineK134Witness || true; rm -f /tmp/koine-k134-witness.jsonl'

step "The subjects, built component by component in the guest (no whole-path call addresses a long location)"
guest 'chmod -R u+rwx $HOME/tlf $HOME/wfx 2>/dev/null; rm -rf $HOME/tlf $HOME/wfx $HOME/paths; python3 $HOME/vlf.py all $HOME/tlf $HOME/wfx $HOME/paths' |
    tee "${OUT_DIR}/subjects.txt" | tr '\n' ' ' | fold -w 200
echo
MANIFEST="$(guest_text 'cat $HOME/paths/manifest.jsonl')"
[ "$(grep -c '^{' <<<"${MANIFEST}")" -ge 30 ] || fail "the guest's manifest of subjects is incomplete"
printf '%s\n' "${MANIFEST}" >"${OUT_DIR}/manifest.jsonl"
for id in c1023-txt-d k1023-dir-d r1024-txt r1024-dir r1500-wit m1023; do
    echo "Subject ${id}: $(path_bytes "${id}") bytes"
done
step "The guest's own account of every subject, by descriptors alone: present, absent or an impossible name"
guest 'python3 $HOME/vlf.py check $HOME/paths' | tee "${OUT_DIR}/descriptor-check.txt" | awk '{ printf "%s | ", $0 } END { print "" }' | fold -w 200
while read -r id bytes state; do
    want=present
    case "${id}" in m1023 | m1500) want=absent ;; impossible) want=impossible ;; esac
    [ "${state}" = "${want}" ] || fail "subject ${id} (${bytes} bytes) is ${state} in the guest, and the cases assume ${want}"
done <"${OUT_DIR}/descriptor-check.txt"

step "The observer: Finder's own account of its windows and selection, read by a process that is not Koine"
allow_observer
step "The window server, the witness and the front application: the observers' baseline"
echo "Windows: $(window_list)"

# --- THE CONTROLS: before Koine is asked anything ----------------------------------------------------
if wanted reach || wanted refus || wanted walk || wanted root; then
    step "THE CONTROLS: 1,023-byte subjects opened and revealed by an independent, non-Koine route"
    control_open txt default c1023-txt-d
    control_open txt zed c1023-txt-z
    control_open wit default c1023-wit
    control_open dir default c1023-dir-d
    control_open dir zed c1023-dir-z
    control_reveal file c1023-rev-txt
    control_reveal dir c1023-rev-dir
    echo "The slowest control was seen ${MAX_CONTROL_S} s after its request; an observation of nothing watches for longer than that."
else
    echo "Only the prompt section is wanted: its own positive control (a standalone probe's prompt) stands in for the 1,023-byte controls."
    MAX_CONTROL_S=20
fi
if [ "${CONTROL_MISSES}" != 0 ]; then
    step "PENDING: ${CONTROL_MISSES} observer(s) could not see the 1,023-byte control"
    jq -s '.' "${RESULTS}" >"${OUT_DIR}/results.json"
    echo "Every Koine observation stays pending: an observer that cannot see the control passes and fails nothing. Written: ${OUT_DIR}/results.json"
    exit 3
fi
# Watching for the window the control needed: at least a minute, and three times the slowest control.
WATCH_S=$((MAX_CONTROL_S * 3))
[ "${WATCH_S}" -ge 60 ] || WATCH_S=60
echo "Observations of nothing will watch for ${WATCH_S} s after the last request."

step "Launch Koine; a manager grant in the window, then the contract-only client enrols its own grants"
launch
KOINE_RUNNING=1
create_grant "target-locations-manager" "${MANAGER}" koine:manage
accessibility_is false
enrol "${BOTH}" target-locations-client-both workspace:control desktop:control
expect '.grant.capabilities == ["desktop:control","workspace:control"] or .grant.capabilities == ["workspace:control","desktop:control"]' \
    "the grant is not exactly both controls"
enrol "${WORKSPACE_ONLY}" target-locations-client-workspace workspace:control
echo "Accessibility is not granted to Koine in this image: every request below is by workspace:control and desktop:control alone."

if wanted reach; then
    koine_open reach "a 1,023-byte document opened in its default handler" txt default k1023-txt-d
    koine_open reach "a 1,023-byte document opened with Zed named" txt zed k1023-txt-z
    koine_open reach "a 1,023-byte witness document, delivered with its exact bytes" wit default k1023-wit
    koine_open reach "a 1,023-byte directory opened in its default handler" dir default k1023-dir-d
    koine_open reach "a 1,023-byte directory opened with Zed named" dir zed k1023-dir-z
    koine_reveal reach "a 1,023-byte document revealed" k1023-rev-txt "k1023-rev-txt.txt" "$(path_text k1023-rev-txt)"
    koine_reveal reach "a 1,023-byte directory revealed" k1023-rev-dir "k1023-rev-dir" "$(path_text k1023-rev-dir)"
fi

if wanted refus; then
    step "refus: extant 1,024-byte and about 1,500-byte locations are refused; nothing is delivered or selected"
    # Every request below must deliver or select nothing, so they are asked in one run in the
    # guest under one watch, with ${OTHER} in front and no Finder window open: the agent's exec
    # channel makes each round trip slow, and a batch is also the stricter observation (not one
    # window, delivery, selection or activation, and the front application never changes, from
    # the first request to the last). <name>|<id>|<operation: open|zed|reveal>
    FAILED='.classification == "failed" and .actionEffect == "may-have-begun" and .receipt == null and .dependency == null and .http.status == 200 and (.errors | length) == 1 and (.errors[0].kind == "failed")'
    REFUSALS_LIST=()
    for length in 1024 1500; do
        for kind in txt wit dir; do
            id="r${length}-${kind}"
            REFUSALS_LIST+=("${id}-open|${id}|open" "${id}-zed|${id}|zed" "${id}-reveal|${id}|reveal")
        done
    done
    # Absent, not over the limit: only the walk says so, at any length.
    ABSENT_LIST=("m1023-open|m1023|open" "m1500-open|m1500|open" "m1500-zed|m1500|zed" "m1023-reveal|m1023|reveal" "m1500-reveal|m1500|reveal"
        "impossible-open|impossible|open" "impossible-reveal|impossible|reveal")
    BATCH="mkdir -p \$HOME/refusals && rm -f \$HOME/refusals/*"
    for spec in "${REFUSALS_LIST[@]}" "${ABSENT_LIST[@]}"; do
        IFS='|' read -r name id operation <<<"${spec}"
        case "${operation}" in
            open) BATCH="${BATCH}; ${CLIENT} open-path --secret \"${BOTH}\" --path-file \"${PATHS}/${id}.txt\" > \$HOME/refusals/${name}.json" ;;
            zed) BATCH="${BATCH}; ${CLIENT} open-path --secret \"${BOTH}\" --path-file \"${PATHS}/${id}.txt\" --bundle-identifier ${ZED_ID} > \$HOME/refusals/${name}.json" ;;
            reveal) BATCH="${BATCH}; ${CLIENT} reveal-path --secret \"${BOTH}\" --path-file \"${PATHS}/${id}.txt\" > \$HOME/refusals/${name}.json" ;;
        esac
    done
    TOTAL=$((${#REFUSALS_LIST[@]} + ${#ABSENT_LIST[@]}))
    close_finder_windows
    put_other_in_front >/dev/null
    guest "rm -f ${WITNESS_LOG}" || true
    witness_front >/dev/null
    FRONT_BEFORE="$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")"
    WINDOWS_BEFORE="$(window_list)"
    echo "Windows before the batch: ${WINDOWS_BEFORE}"
    watch_start
    # A repeat harms nothing: each request is refused and delivers nothing, and a repeat that did
    # deliver something is what the observers below would show.
    guest "${BATCH}" || true
    for _ in $(seq 1 60); do
        REFUSED="$(guest_text 'cd $HOME/refusals && for f in *.json; do printf "%s " "${f%.json}"; cat "$f"; done')"
        [ "$(grep -c '^[a-z0-9-]* {' <<<"${REFUSED}")" -ge "${TOTAL}" ] && break
        sleep 3
    done
    echo "All ${TOTAL} requests answered; watching ${WATCH_S} s more for anything delivered, opened or selected."
    sleep "${WATCH_S}"
    watch_read
    watch_stop
    answer_of() {
        ANSWER="$(grep "^$1 {" <<<"${REFUSED}" | head -1)"
        ANSWER="${ANSWER#* }"
        jq -e . >/dev/null <<<"${ANSWER}" || fail "the client left no answer for $1"
    }
    for spec in "${REFUSALS_LIST[@]}"; do
        IFS='|' read -r name id operation <<<"${spec}"
        answer_of "${name}"
        bytes="$(path_bytes "${id}")"
        echo "${name}: $(jq -c '{classification, actionEffect, errors: [.errors[]? | {message, path, kind}]}' <<<"${ANSWER}" | cut -c1-500)"
        expect "${FAILED}" "${name}: not a failed result at the action's own response path"
        [ "$(jq -r '.errors[0].path | join(".")' <<<"${ANSWER}")" = "$([ "${operation}" = reveal ] && echo workspaceRevealPath || echo workspaceOpenPath)" ] ||
            fail "${name}: the error is not at the action's own response path"
        MESSAGE="$(jq -r '.errors[0].message' <<<"${ANSWER}")"
        grep -q 'The application hand-off was refused: the path as written is '"${bytes}"' bytes' <<<"${MESSAGE}" ||
            fail "${name}: the guidance does not name the hand-off stage, the spelling and ${bytes} bytes: ${MESSAGE}"
        grep -q 'No request was made' <<<"${MESSAGE}" || fail "${name}: the guidance does not say no request was made: ${MESSAGE}"
        record --arg n "${name}" --arg id "${id}" --argjson b "${bytes}" --arg m "${MESSAGE}" \
            '{section: "refus", case: "extant over-limit location refused", input: $n, id: $id, bytes: $b, status: "passed", guidance: $m}'
    done
    for spec in "${ABSENT_LIST[@]}"; do
        IFS='|' read -r name id _ <<<"${spec}"
        answer_of "${name}"
        echo "${name}: $(jq -c '{classification, actionEffect, status, dependency}' <<<"${ANSWER}")"
        expect '.classification == "dependency-unavailable" and .actionEffect == "none" and .receipt == null and .status == "DEPENDENCY_UNAVAILABLE" and .dependency.reason == "PATH_NOT_FOUND"' \
            "${name}: not PATH_NOT_FOUND"
        record --arg n "${name}" --arg id "${id}" '{section: "refus", case: "absent location is PATH_NOT_FOUND", input: $n, id: $id, status: "passed"}'
    done
    # The observers, over the whole batch.
    jq -e -s '[.[] | select(.event == "launched" or .event == "activated")] | length == 0' >/dev/null <<<"${EVENTS}" ||
        fail "a refused request launched or activated an application: $(jq -c -s '[.[] | select(.event == "launched" or .event == "activated")]' <<<"${EVENTS}")"
    guest_text "cat ${WITNESS_LOG} 2>/dev/null" | grep -q . && fail "the witness application was delivered a document by a refused request"
    witness_front >/dev/null
    [ "$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")" = "${FRONT_BEFORE}" ] || fail "focus moved during the batch"
    WINDOWS_AFTER="$(window_list)"
    [ "${WINDOWS_AFTER}" = "${WINDOWS_BEFORE}" ] || fail "a window appeared during the batch: ${WINDOWS_BEFORE} -> ${WINDOWS_AFTER}"
    observe
    jq -e '.windows == 0 and (.selected | length == 0)' >/dev/null <<<"${OBS}" || fail "Finder shows a window or a selection after the batch: ${OBS}"
    echo "Observation: ${#REFUSALS_LIST[@]} extant over-limit requests (document, witness document and directory, each opened, opened in Zed and revealed, at 1,024 and about 1,500 bytes) and ${#ABSENT_LIST[@]} absent ones, over ${WATCH_S} s: no launch, no activation, no window, no delivery to the witness, the front application unchanged, and Finder's own account still no window and no selection."
    record --argjson w "${WATCH_S}" '{section: "refus", case: "nothing delivered or selected for any over-limit location", status: "passed", watchedSeconds: $w}'
fi

if wanted walk; then
    step "walk: present outcomes only an effect shows"
    # Each is within the limit, so its open or reveal has an effect the controlled observers see.
    walk_open() { # <id> <window title alternatives, |-separated> <how: default|zed>
        local id="$1" stem="$2" how="${3:-default}" status="passed" notes="" cb flags=""
        step "walk: ${id} opened (${how})"
        if [ "${how}" = zed ]; then
            EXP_APP=Zed EXP_TITLE="${stem}" CHECK_FN=chk_window OBSERVER="Zed's window"
            flags="--bundle-identifier ${ZED_ID}"
        else
            EXP_APP=TextEdit EXP_TITLE="${stem}" CHECK_FN=chk_window OBSERVER="TextEdit's window"
        fi
        put_other_in_front >/dev/null
        before_open
        watch_start
        # shellcheck disable=SC2086
        open_client "open-path --secret \"${BOTH}\" --path-file \"${PATHS}/${id}.txt\" ${flags}"
        sent_now
        cb=$(($(jq -r .receivedMs <<<"${ANSWER}") - $(jq -r .sentMs <<<"${ANSWER}")))
        if [ "$(jq -r .classification <<<"${ANSWER}")" != ok ]; then
            status="failed"
            notes="not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
        else
            expect '.status == "AVAILABLE" and .dependency == null and .http.status == 200 and ((.errors // []) | length == 0)' "${id}: not an acknowledged open"
        fi
        if poll "${POLL_LIMIT}" chk_window; then
            echo "${EXP_APP}'s window ${SEEN_S} s after the answer: ${TITLES}"
        else
            status="failed"
            notes="${notes}no ${EXP_APP} window naming ${stem} within ${POLL_LIMIT} s; "
        fi
        watch_stop
        dialogs="$(system_dialogs)"
        echo "Dialogs on screen: ${dialogs:-none}"
        judge_dialogs "open" "${dialogs}"
        record --arg id "${id}" --arg how "${how}" --arg o "${OBSERVER}" --arg st "${status}" --arg n "${notes}" --argjson ms "${cb}" --arg after "${SEEN_S:-}" \
            '{section: "walk", case: ("present outcome opened (" + $how + ")"), id: $id, observer: $o, status: $st, answerMs: $ms, seenAfterS: $after, notes: $n}'
        echo "Result: walk: ${id} open (${how}): ${status}${notes:+ — ${notes}}"
    }
    # walk_limit <id> <window title alternatives>: the walk resolved the chain, and the system's own
    # default-handler lookup answers nil for a chain of more than ten links (section `platform`), so
    # the answer is NO_DEFAULT_HANDLER, with nothing opened. That is the accepted mapping of a nil
    # handler for a target the walk found, and not an absence.
    walk_limit() {
        local id="$1" stem="$2" status="passed" notes=""
        step "walk: ${id} opened in its default handler (the platform's lookup stops after ten links)"
        EXP_APP=TextEdit EXP_TITLE="${stem}" CHECK_FN=chk_window OBSERVER="TextEdit's window"
        put_other_in_front >/dev/null
        before_open
        open_client "open-path --secret \"${BOTH}\" --path-file \"${PATHS}/${id}.txt\""
        echo "${id}: $(jq -c '{classification, actionEffect, status, dependency}' <<<"${ANSWER}")"
        jq -e '.classification == "dependency-unavailable" and .actionEffect == "none" and .receipt == null and .dependency.reason == "NO_DEFAULT_HANDLER"' >/dev/null <<<"${ANSWER}" || {
            status="failed"
            notes="not NO_DEFAULT_HANDLER: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
        }
        sleep 20
        if chk_window; then
            status="failed"
            notes="${notes}a TextEdit window naming ${stem} appeared: ${TITLES}; "
        fi
        record --arg id "${id}" --arg st "${status}" --arg n "${notes}" --argjson a "$(jq -c '{classification, status, dependency}' <<<"${ANSWER}")" \
            '{section: "walk", case: "default open of a chain longer than ten links: the platform lookup answers nil", id: $id, status: $st, answer: $a, notes: $n}'
        echo "Result: walk: ${id} default open (platform lookup limit): ${status}${notes:+ — ${notes}}"
    }
    # Reference, not an assertion: what an independent `open` does with a directory it cannot search.
    step "walk: what an independent route does with a final directory without search permission (reference, recorded)"
    CLOSED_BEFORE="$(window_list)"
    guest "osascript -e 'tell application \"Finder\" to close every window'; open \"\$(cat ${PATHS}/closed.txt)\"" || true
    sleep 10
    CLOSED_AFTER="$(window_list)"
    echo "Windows before: ${CLOSED_BEFORE}"
    echo "Windows after an independent open of the mode-0600 directory: ${CLOSED_AFTER}"
    record --arg b "${CLOSED_BEFORE}" --arg a "${CLOSED_AFTER}" '{section: "walk", case: "reference: independent open of a final directory without search permission", status: "recorded", before: $b, after: $a}'
    walk_open w10 "w10-target.txt" default
    koine_reveal walk "w10: a 10-link chain revealed (the link itself is selected)" w10 "w10-10.txt" ""
    walk_limit w11 "w11-target.txt"
    walk_open w11 "w11-target.txt|w11-11.txt" zed
    koine_reveal walk "w11: an 11-link chain revealed (the link itself is selected)" w11 "w11-11.txt" ""
    walk_limit w31 "w31-target.txt"
    walk_open w31 "w31-target.txt|w31-31.txt" zed
    koine_reveal walk "w31: a 31-link chain revealed (the link itself is selected)" w31 "w31-31.txt" ""
    walk_limit w32 "w32-target.txt"
    walk_open w32 "w32-target.txt|w32-32.txt" zed
    koine_reveal walk "w32: a 32-link chain revealed (the link itself is selected)" w32 "w32-32.txt" ""
    walk_open two-dir "two-dir.txt" default
    koine_reveal walk "two-dir: one link inode in two directories revealed" two-dir "two-dir.txt" ""
    walk_open dot "dot-f.txt" default
    koine_reveal walk "dot: a finite repeated dot-link revealed" dot "dot-f.txt" ""
    walk_open mb300 "-mb300" default
    koine_reveal walk "mb300: a 300-byte multibyte name revealed" mb300 "-mb300" ""
    walk_open comb "-comb" default
    koine_reveal walk "comb: a combining-character name revealed" comb "-comb" ""
    walk_open emoji "-emoji" default
    koine_reveal walk "emoji: an emoji name revealed" emoji "-emoji" ""
    koine_reveal walk "closed: a final directory with mode 0600 revealed (never opened by the walk)" closed "closed-dir" ""
    step "walk: a final directory with mode 0600 opened (recorded: the independent route showed no window either)"
    put_other_in_front >/dev/null
    open_client "open-path --secret \"${BOTH}\" --path-file \"${PATHS}/closed.txt\""
    echo "closed open: $(jq -c '{classification, status, dependency, errors}' <<<"${ANSWER}")"
    record --argjson a "$(jq -c '{classification, status, dependency, errors}' <<<"${ANSWER}")" '{section: "walk", case: "a final directory with mode 0600 opened", status: "recorded", answer: $a}'
    sleep 10
    echo "Windows after: $(window_list)"
fi

if wanted root; then
    step "root: the filesystem root and a link to it, revealed"
    ROOTS="${WORK}/rootpaths"
    mkdir -p "${ROOTS}"
    printf '%s' "/" >"${ROOTS}/root.txt"
    printf '%s' "//" >"${ROOTS}/root-slashes.txt"
    printf '%s' "/." >"${ROOTS}/root-dot.txt"
    printf '%s' "/.." >"${ROOTS}/root-dotdot.txt"
    printf '%s' "/var/.." >"${ROOTS}/var-dotdot.txt"
    printf '%s' "/Volumes/Macintosh HD" >"${ROOTS}/link.txt"
    printf '%s' "/Volumes/Macintosh HD/" >"${ROOTS}/link-slash.txt"
    ditto -c -k "${ROOTS}" "${WORK}/rootpaths.zip"
    testanyware file upload "${WORK}/rootpaths.zip" /Users/admin/rootpaths.zip >/dev/null
    guest 'cd $HOME && rm -rf rootpaths && ditto -x -k rootpaths.zip rootpaths && ls rootpaths | wc -l && ls -ld "/Volumes/Macintosh HD"' || fail "the root paths did not reach the guest"
    guest '[ -L "/Volumes/Macintosh HD" ] && [ "$(readlink "/Volumes/Macintosh HD")" = "/" ]' || fail "/Volumes/Macintosh HD is not a link to /"
    # root_case <name> <expectation: root-view|link|recorded> <note>
    root_case() {
        local name="$1" want="$2" label="$3" status="passed" notes="" file="rootpaths/$1.txt" cb seen=false
        step "root: ${label}"
        close_finder_windows
        put_other_in_front >/dev/null
        watch_start
        open_client "reveal-path --secret \"${BOTH}\" --path-file \"\$HOME/${file}\""
        sent_now
        cb=$(($(jq -r .receivedMs <<<"${ANSWER}") - $(jq -r .sentMs <<<"${ANSWER}")))
        [ "$(jq -r .classification <<<"${ANSWER}")" = ok ] || { status="failed"; notes="not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "; }
        case "${want}" in
            root-view) CHECK=chk_root_view ;;
            link) EXP_NAME="Macintosh HD" EXP_PATH="" CHECK=chk_selected ;;
            recorded) CHECK=chk_window_any ;;
        esac
        if poll 60 "${CHECK}"; then seen=true; fi
        echo "Finder's account: $(jq -c . <<<"${OBS}" | cut -c1-600)"
        if [ "${seen}" != true ]; then
            status="failed"
            notes="${notes}Finder does not show the expected ${want}; "
        fi
        watch_stop
        record --arg c "${label}" --arg w "${want}" --arg st "${status}" --arg n "${notes}" --argjson ms "${cb}" --argjson obs "${OBS}" \
            '{section: "root", case: $c, expected: $w, status: $st, answerMs: $ms, finder: $obs, notes: $n}'
        echo "Result: root: ${label}: ${status}${notes:+ — ${notes}}"
    }
    root_case root root-view "/ is the root view"
    root_case root-slashes root-view "// is the root view"
    root_case root-dot root-view "/. is the root view"
    root_case root-dotdot root-view "/.. is the root view"
    root_case link link "/Volumes/Macintosh HD, a link to /, is selected as the link"
    root_case link-slash root-view "/Volumes/Macintosh HD/ names the root: the root view"
    root_case var-dotdot recorded "/var/.. is /private by the physical parent, not the root (recorded as Finder shows it)"
    echo "For reference, an independent route (open -R) reads the link spellings differently from Koine's accepted rule and is recorded, not asserted:"
    for name in link link-slash; do
        guest "osascript -e 'tell application \"Finder\" to close every window'; open -R \"\$(cat \$HOME/rootpaths/${name}.txt)\"" || true
        sleep 6
        observe
        echo "  open -R ${name}: $(jq -c . <<<"${OBS}" | cut -c1-400)"
        record --arg n "${name}" --argjson obs "${OBS}" '{section: "root", case: "reference: independent open -R", input: $n, status: "recorded", finder: $obs}'
    done
fi

# --- the protected folders: fixtures, and the helpers the two sections below share ----------------------
protected_fixtures() {
    # Made by the test agent (which has Full Disk Access, so making them prompts nothing): a document
    # and a directory in each of Desktop, Documents and Downloads, and a Documents file for the control.
    guest 'rm -rf /Users/admin/Desktop/koine-prot-Desktop /Users/admin/Desktop/koine-prot-doc-Desktop.txt
        rm -rf /Users/admin/Documents/koine-prot-Documents /Users/admin/Documents/koine-prot-doc-Documents.txt
        rm -rf /Users/admin/Downloads/koine-prot-Downloads /Users/admin/Downloads/koine-prot-doc-Downloads.txt
        for f in Desktop Documents Downloads; do
            mkdir -p "/Users/admin/$f/koine-prot-$f"; printf "inside\n" > "/Users/admin/$f/koine-prot-$f/inner.txt"
            printf "koine-prot-doc-$f\n" > "/Users/admin/$f/koine-prot-doc-$f.txt"; done
        mkdir -p /Users/admin/Documents/k174 && printf "k174" > /Users/admin/Documents/k174/sample.txt; echo made'
    mkdir -p "${WORK}/prot"
    local folder
    for folder in Desktop Documents Downloads; do
        printf '%s' "/Users/admin/${folder}/koine-prot-doc-${folder}.txt" >"${WORK}/prot/prot-doc-${folder}.txt"
        printf '%s' "/Users/admin/${folder}/koine-prot-${folder}" >"${WORK}/prot/prot-dir-${folder}.txt"
    done
    ditto -c -k "${WORK}/prot" "${WORK}/prot.zip"
    testanyware file upload "${WORK}/prot.zip" /Users/admin/prot.zip >/dev/null
    guest 'cd $HOME && rm -rf prot && ditto -x -k prot.zip prot && ls prot' || fail "the protected paths did not reach the guest"
}
tcc_rows() {
    # The user and system consent databases, read by the test agent (which has Full Disk Access).
    local sql="select service,client,auth_value from access where client = '$1'"
    guest_text "sqlite3 \$HOME/Library/Application\\ Support/com.apple.TCC/TCC.db \"${sql}\"; echo ${VM_PASSWORD} | sudo -S sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"${sql}\" 2>/dev/null" | grep -v '^Password:' || true
}
prompt_words() { screen_text UserNotificationCenter | cut -c1-400; }
# decline_prompts <seconds>: every permission request that appears in that time is read, kept in
# DECLINED_WORDS and declined (a click on Don’t Allow), so that none stands over the next case.
# A prompt for a protected folder can follow a case by a few seconds: the application the request
# handed a document to asks for it itself once it reads it.
decline_prompts() {
    local limit="$1" started words hit
    started="$(date +%s)"
    DECLINED_WORDS=""
    while :; do
        words="$(prompt_words)"
        if [ -n "${words}" ]; then
            [ -n "${DECLINED_WORDS}" ] || testanyware screen capture -o "${OUT_DIR}/prompt-${PROMPT_LABEL:-case}.png" >/dev/null 2>&1 || true
            DECLINED_WORDS="${DECLINED_WORDS}${words} | "
            hit="$(screen_buttons | jq -c --arg b "${CLICK:-Don’t Allow}" '[.[] | select(.app == "UserNotificationCenter" and .label == $b)][0]')"
            # shellcheck disable=SC2046
            [ "${hit}" = null ] || testanyware input click $(jq -r '"\(.x) \(.y)"' <<<"${hit}") >/dev/null
            sleep 3
            continue
        fi
        [ $(($(date +%s) - started)) -lt "${limit}" ] || return 0
        sleep 4
    done
}
# A standalone probe's prompt is the observer's positive control: a run whose control did not
# prompt could not have seen a prompt.
prompt_control() {
    step "prompt: the positive control, a standalone probe's content read in Documents (must prompt)"
    guest "tccutil reset All ${PROBE_ID}; rm -f /tmp/koine-k174-begin.json /tmp/koine-k174-end.json; open -n /Applications/KoineK174Probe.app --args content-read-control \$HOME/Documents/k174/sample.txt" || true
    local words=""
    for _ in $(seq 1 30); do
        words="$(prompt_words)"
        [ -z "${words}" ] || break
        sleep 2
    done
    echo "The control's dialog: ${words:-none}"
    if ! grep -qi 'KoineK174Probe' <<<"${words}"; then
        step "PENDING: the observer did not see the control's prompt, so a prompt-free reading would prove nothing"
        record '{section: "prompt", case: "positive control", status: "not-seen"}'
        jq -s '.' "${RESULTS}" >"${OUT_DIR}/results.json"
        exit 3
    fi
    PROMPT_LABEL="control" decline_prompts 4
    record --arg w "${words}" '{section: "prompt", case: "positive control: a standalone probe prompts in Documents", status: "passed", dialog: $w}'
    guest "pkill -f KoineK174Probe || true"
}

if wanted platform; then
    step "platform: what the system does by itself, with no Koine involved"
    protected_fixtures
    prompt_control
    # (1) The default-handler lookup follows at most ten symbolic links: asked as Koine's adapter asks it.
    testanyware file upload docs/verification/target-locations-vm/handler-lookup.swift /Users/admin/handler-lookup.swift >/dev/null
    guest 'cd $HOME && swiftc -O handler-lookup.swift -o handler-lookup 2>&1 | tail -3'
    LOOKUP="$(guest_text '$HOME/handler-lookup $HOME/wfx')"
    echo "NSWorkspace.urlForApplication(toOpen:) for the Nth link of a chain: $(tr '\n' ';' <<<"${LOOKUP}")"
    if ! { grep -qx '10 TextEdit.app' <<<"${LOOKUP}" && grep -qx '11 nil' <<<"${LOOKUP}" && grep -qx '32 nil' <<<"${LOOKUP}"; }; then
        fail "the platform's handler lookup does not stop after ten links as the chain cases assume: ${LOOKUP}"
    fi
    record --arg l "${LOOKUP}" '{section: "platform", case: "the default-handler lookup follows ten symbolic links and answers nil from eleven", status: "passed", lookup: $l}'
    # (2) A plain program that is not Koine is prompted when it hands an item in a protected folder to
    # an application. Built as an ad-hoc-signed bundle and started through Launch Services.
    testanyware file upload docs/verification/target-locations-vm/submit.swift /Users/admin/submit.swift >/dev/null
    testanyware file upload docs/verification/target-locations-vm/submitter-info.plist /Users/admin/submitter-info.plist >/dev/null
    guest 'set -e; cd $HOME; A=/Applications/KoineK180Submit.app; rm -rf $A; mkdir -p $A/Contents/MacOS
        swiftc -O submit.swift -o $A/Contents/MacOS/submit 2>&1 | tail -2; cp submitter-info.plist $A/Contents/Info.plist
        codesign --force -s - $A; echo built' || fail "the plain submitter did not build"
    echo "x" >"${WORK}/k180-tmp-doc.txt"
    testanyware file upload "${WORK}/k180-tmp-doc.txt" /tmp/k180-doc.txt >/dev/null
    plain_case() { # <label> <path> <application path or -> <expect: prompt|none>
        local label="$1" target="$2" application="$3" want="$4" got="none" status="passed"
        step "platform: a plain program, not Koine: ${label}"
        guest "pkill -f KoineK180Submit || true; pkill -x Zed || true; rm -f /tmp/k180-out.txt; tccutil reset All dev.antony.k180.submit" || true
        PROMPT_LABEL="plain-${label//[^A-Za-z0-9]/-}" decline_prompts 4
        guest "open -n /Applications/KoineK180Submit.app --stdout /tmp/k180-out.txt --stderr /tmp/k180-out.txt --args \"${target}\" ${application}" || true
        PROMPT_LABEL="plain-${label//[^A-Za-z0-9]/-}" decline_prompts 40
        echo "Requests seen: ${DECLINED_WORDS:-none}"
        grep -q 'KoineK180Submit' <<<"${DECLINED_WORDS}" && got="prompt"
        echo "The plain program's own output: $(guest_text 'cat /tmp/k180-out.txt' | tr '\n' ' ')"
        echo "Its rows in the consent database: $(tcc_rows dev.antony.k180.submit | tr '\n' ';')"
        [ "${got}" = "${want}" ] || status="failed"
        record --arg l "${label}" --arg w "${want}" --arg g "${got}" --arg st "${status}" --arg d "${DECLINED_WORDS}" \
            '{section: "platform", case: ("plain program: " + $l), expected: $w, observed: $g, status: $st, dialogs: $d}'
        echo "Result: platform: ${label}: ${status} (expected ${want}, saw ${got})"
    }
    plain_case "a document in /tmp handed to Zed (no protected folder)" "/tmp/k180-doc.txt" /Applications/Zed.app none
    for folder in Desktop Documents Downloads; do
        plain_case "a document in ${folder} handed to Zed" "/Users/admin/${folder}/koine-prot-doc-${folder}.txt" /Applications/Zed.app prompt
    done
    plain_case "a directory in Desktop opened by its default handler" "/Users/admin/Desktop/koine-prot-Desktop" "-" prompt
    guest 'pkill -f KoineK180Submit || true; pkill -x Zed || true' || true
fi

if wanted prompt; then
    step "prompt: first-use resolution in Desktop, Documents and Downloads"
    protected_fixtures
    prompt_control
    # Every case is a first use: Koine's consent is reset before it. A reveal is the walk and Finder's
    # selection and must not prompt. An open is submitted to the system, which asks the user once for the
    # folder, naming Koine: in this disposable clone that request is APPROVED (Antony's decision: a
    # prompt in the VM is answered there), and then the open must complete with its effect, and a second
    # request of the same open must be prompt-free with the consent recorded. A default open of a
    # protected DOCUMENT is not made: its handler lookup is the known, separately decided prompt
    # (protected-default-open-k89). Zed, which a named document is handed to, asks for the folder itself
    # once it reads the document: it is quit before every case and its own request is approved and
    # attributed to it.
    PROMPTED=0
    for folder in Desktop Documents Downloads; do
        for op in reveal-doc reveal-dir open-dir-finder open-dir open-doc-zed; do
            step "prompt: ${folder}: ${op}"
            guest "pkill -x Zed || true; tccutil reset All ${BUNDLE_ID}" || true
            CLICK="Don’t Allow" PROMPT_LABEL="clear" decline_prompts 4
            [ -z "${DECLINED_WORDS}" ] || echo "A request was standing before the case and is declined: ${DECLINED_WORDS}"
            TCC_BEFORE="$(tcc_rows "${BUNDLE_ID}")"
            echo "Koine's rows in the consent databases before the request: ${TCC_BEFORE:-none}"
            close_finder_windows
            put_other_in_front >/dev/null
            EXP_APP="" EXP_TITLE="" CHECK_FN=chk_window EXP_NAME="" EXP_PATH=""
            case "${op}" in
                reveal-doc) CMD="reveal-path --secret \"${BOTH}\" --path-file \"\$HOME/prot/prot-doc-${folder}.txt\"" ;;
                reveal-dir) CMD="reveal-path --secret \"${BOTH}\" --path-file \"\$HOME/prot/prot-dir-${folder}.txt\"" ;;
                open-dir-finder)
                    CMD="open-path --secret \"${BOTH}\" --path-file \"\$HOME/prot/prot-dir-${folder}.txt\" --bundle-identifier com.apple.finder"
                    EXP_APP=Finder EXP_TITLE="koine-prot-${folder}"
                    ;;
                open-dir)
                    CMD="open-path --secret \"${BOTH}\" --path-file \"\$HOME/prot/prot-dir-${folder}.txt\""
                    EXP_APP=Finder EXP_TITLE="koine-prot-${folder}"
                    ;;
                open-doc-zed)
                    CMD="open-path --secret \"${BOTH}\" --path-file \"\$HOME/prot/prot-doc-${folder}.txt\" --bundle-identifier ${ZED_ID}"
                    EXP_APP=Zed EXP_TITLE="koine-prot-doc-${folder}.txt"
                    ;;
            esac
            open_client "${CMD}"
            sent_now
            status="passed"
            notes=""
            first="$(jq -c '{classification, status, dependency, errors: [.errors[]? | {message, kind}]}' <<<"${ANSWER}")"
            if [ -z "${EXP_APP}" ]; then
                # A reveal: watch for a prompt as long as the controls needed; there must be none.
                CLICK="Don’t Allow" PROMPT_LABEL="${folder}-${op}" decline_prompts "$((WATCH_S < 150 ? WATCH_S : 150))"
                echo "Requests seen: ${DECLINED_WORDS:-none}"
                [ -z "${DECLINED_WORDS}" ] || { status="prompted"; PROMPTED=1; notes="${notes}a reveal raised a request: ${DECLINED_WORDS}"; }
                [ "$(jq -r .classification <<<"${ANSWER}")" = ok ] || { status="failed"; notes="${notes}not acknowledged: ${first}; "; }
            else
                # An open: the first use asks the user once, naming Koine. Approve it, as the user of this
                # disposable clone does, and read what the open then does.
                CLICK="Allow" PROMPT_LABEL="${folder}-${op}" decline_prompts "$((WATCH_S < 150 ? WATCH_S : 150))"
                echo "Requests seen and allowed: ${DECLINED_WORDS:-none}"
                if grep -q '“Koine” would like' <<<"${DECLINED_WORDS}"; then
                    notes="${notes}Koine's request was allowed; "
                else
                    status="failed"
                    notes="${notes}no request naming Koine appeared for an open in a protected folder; "
                fi
                TCC_ALLOWED="$(tcc_rows "${BUNDLE_ID}")"
                echo "Koine's rows after allowing: ${TCC_ALLOWED:-none}"
                grep -q '|dev.antony.Koine|2$' <<<"${TCC_ALLOWED}" || { status="failed"; notes="${notes}Koine's consent row is not an allowance: ${TCC_ALLOWED}; "; }
                # The first request answered while the dialog stood (it is bounded at three seconds); did it
                # still complete once the dialog was answered?
                sleep 5
                if chk_window; then
                    notes="${notes}the first request completed after the allowance (${EXP_APP}: ${TITLES}); "
                else
                    notes="${notes}the first request did not complete after the allowance; "
                fi
                # A second request, from a clean state: acknowledged, with its effect, and prompt-free.
                guest "pkill -x Zed || true" || true
                close_finder_windows
                put_other_in_front >/dev/null
                open_client "${CMD}"
                sent_now
                second="$(jq -c '{classification, status, dependency, errors: [.errors[]? | {message, kind}]}' <<<"${ANSWER}")"
                if [ "$(jq -r .classification <<<"${ANSWER}")" = ok ]; then
                    expect '.status == "AVAILABLE" and .dependency == null and .http.status == 200 and ((.errors // []) | length == 0)' "${folder} ${op}: the second request is not an acknowledged open"
                else
                    status="failed"
                    notes="${notes}the second request was not acknowledged: ${second}; "
                fi
                if poll "${POLL_LIMIT}" chk_window; then
                    echo "${EXP_APP}'s window ${SEEN_S} s after the second answer: ${TITLES}"
                else
                    status="failed"
                    notes="${notes}no ${EXP_APP} window naming ${EXP_TITLE} after the second request; "
                fi
                CLICK="Allow" PROMPT_LABEL="${folder}-${op}-second" decline_prompts 20
                if [ -n "${DECLINED_WORDS}" ]; then
                    notes="${notes}after the second request: ${DECLINED_WORDS}"
                    grep -q '“Koine” would like' <<<"${DECLINED_WORDS}" && { status="failed"; notes="${notes} (Koine asked again); "; }
                fi
                first="${first} | second ${second}"
            fi
            record --arg f "${folder}" --arg o "${op}" --arg st "${status}" --arg n "${notes}" --arg a "${first}" \
                '{section: "prompt", case: ($f + ": " + $o), status: $st, answers: $a, notes: $n}'
            echo "Result: prompt: ${folder} ${op}: ${status}${notes:+ — ${notes}}"
        done
    done
    guest 'pkill -x Zed || true' || true
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
jq -r '.[] | "\(.section // "-"): \(.case) \(.id // .input // ""): \(.status)"' "${OUT_DIR}/results.json"
echo "Written: ${OUT_DIR}/results.json"
FAILED_COUNT="$(jq '[.[] | select(.status == "failed")] | length' "${OUT_DIR}/results.json")"

step "Quit Koine"
quit_koine_or_terminate

if [ "${FAILED_COUNT}" != 0 ]; then
    echo "FAILED: ${FAILED_COUNT} case(s) failed — transcript in ${LOG}" >&2
    exit 1
fi
if [ "${PROMPTED:-0}" = 1 ]; then
    echo "PROMPTED: first-use resolution raised a permission request naming Koine. If it prompts, the leaf stops and goes to Antony — transcript in ${LOG}" >&2
    exit 4
fi
step "PASSED — transcript in ${LOG}"
