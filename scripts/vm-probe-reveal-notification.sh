#!/bin/bash
# A bounded probe, not an acceptance: derived from scripts/vm-verify-reveal-path.sh (the same clone,
# fixtures, observer consent and grants) up to the point where the reveal cases would start, then a
# short sequence that reads the screen for macOS's "prevented from modifying apps" notice after each
# step, one sample each: a refused open of Zed.app (inspection only), then reveals of Notes.app,
# TextEdit.app and Zed.app (twice). Its result and what it cannot say:
# docs/verification/reveal-path-vm.md#the-app-management-notice. Nothing is asserted: it prints
# whether the notice was seen after each step.
# Verifies, on the signed Koine.app in a clone of the prepared launcher image
# (scripts/vm-prepare-launchers.sh, docs/verification/launcher-apps-vm.md), that
# workspaceRevealPath under workspace:control AND desktop:control, and no read capability,
# makes Finder select a client-built path, as the contract-only client (clients/contract-only)
# asks for it, with Accessibility never granted to Koine.
#
# What Finder showed is never inferred from Koine's receipt, which is only Finder's boolean
# acknowledgment. An independent observer reads it: Finder's own account, by AppleScript run
# from the test agent (a process of the test harness that is not Koine; its Automation consent
# for Finder is granted once, before Koine starts, in the disposable clone), of its front
# window's target folder and of the items selected in it. A screenshot of each case is kept
# beside it. Fixtures/LaunchWitness, an independent signed tool, reports who is in front and
# every launch and activation, on the guest's clock.
#
# Sections (KOINE_REVEAL_ONLY names them):
#   reveal    a file, a folder, an application bundle, a Finder alias file and the filesystem
#             root, and a path with spaces and shell punctuation, a folder addressed with a
#             trailing slash, a symlink, the root spelled `//` and a `..` that the kernel and
#             Finder may read differently (recorded, not asserted): each from a Finder with no window open, so that what
#             is observed is what the request caused;
#   refus     inputs refused before dispatch (empty, relative, tilde, file URL, NUL), the path
#             dependencies (a missing file, parent, link, and a path below a file), and either
#             control alone or a revoked grant: nothing reveals, no Finder window appears and
#             nothing is activated.
# And, once, that Accessibility was absent throughout and that no consent dialog is on screen.
#
# Nothing here runs an application on the host. The procedure and its recorded evidence:
# docs/verification/reveal-path-vm.md
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
KOINE_VM_LOG_PREFIX="reveal-notification-probe-"
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
SUBJECTS=(scripts/vm-verify-reveal-path.sh scripts/vm-reveal-path-fixtures.sh scripts/vm-reveal-observe.applescript
    docs/verification/protected-path-metadata/make-alias.swift scripts/vm-verify-witness-lib.sh scripts/vm-verify-contract-client-lib.sh
    scripts/vm-verify-launch-lib.sh scripts/vm-launchers-lib.sh "${BUNDLE}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}")
subjects_digest() { shasum -a 256 "${SUBJECTS[@]}"; }
SUBJECTS_BEFORE="$(subjects_digest)"
echo "Subjects of this run:"
echo "${SUBJECTS_BEFORE}"

OTHER="Calculator"
FINDER_ID="com.apple.finder"
FXG="/Users/admin/reveal-fx"
{
    WATCH='$HOME/watch.jsonl'
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
OUT_DIR=".build/reveal-path-vm"
mkdir -p "${OUT_DIR}"

# --- the path files: the exact bytes each case submits -------------------------------------
# One file per path, carried into the guest in one archive and read there with --path-file, so
# that no shell, exec channel or terminal can repair, trim or re-encode what is sent.
mkdir -p "${WORK}/paths"
path_file() { printf '%s' "$2" >"${WORK}/paths/$1.txt"; }
LIT='lit $HOME ~ * ? [x] ; & '"'"' " # % ! (1).txt'
path_file file "${FXG}/dir/note.txt"
path_file folder "${FXG}/dir/sub folder"
path_file folder-slash "${FXG}/dir/sub folder/"
path_file app "/Applications/Zed.app"
path_file notes "/System/Applications/Notes.app"
path_file textedit "/System/Applications/TextEdit.app"
path_file alias "${FXG}/dir/Alias to note"
path_file root "/"
path_file root-slashes "//"
path_file dotdot-through-link "/var/.."
path_file literal "${FXG}/dir/${LIT}"
path_file symlink "${FXG}/dir/link-to-note.txt"
# Refused as input.
path_file empty ""
path_file relative "reveal-fx/dir/note.txt"
# shellcheck disable=SC2088  # the tilde is the point: it must stay literal
path_file tilde "~/reveal-fx/dir/note.txt"
path_file file-url "file://${FXG}/dir/note.txt"
printf '%s\0%s' "${FXG}/dir/no" "te.txt" >"${WORK}/paths/nul.txt"
# Dependencies.
path_file missing-file "${FXG}/dir/no such file.txt"
path_file missing-parent "${FXG}/no such directory/inner.txt"
path_file dangling "${FXG}/dir/link-to-nowhere"
path_file below-file "${FXG}/dir/note.txt/inner.txt"
path_file trailing-slash-file "${FXG}/dir/note.txt/"
ditto -c -k "${WORK}/paths" "${WORK}/paths.zip"

# --- helpers ---------------------------------------------------------------------------------
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

# observe: Finder's own account of what it shows, as JSON in OBS:
#   {windows: n, target: <front window's folder or null>, title: <its title or null>,
#    selected: [{path, kind, name}]}
# A read, so it is safe to repeat and `guest_text` may retry it.
observe() {
    OBS_RAW="$(guest_text 'osascript $HOME/finder-observe.applescript')"
    OBS="$(jq -Rn '
        [inputs | split("\t")] as $r
        | {windows: ([$r[] | select(.[0] == "WINDOWS") | .[1] | tonumber][0] // null),
           target: ([$r[] | select(.[0] == "TARGET") | .[1]][0] // null),
           title: ([$r[] | select(.[0] == "TITLE") | .[1]][0] // null),
           selected: [$r[] | select(.[0] == "SELECTED") | {path: .[1], kind: .[2], name: .[3]}]}' <<<"${OBS_RAW}")" ||
        fail "Finder's account could not be read: ${OBS_RAW}"
    jq -e '.windows != null' >/dev/null <<<"${OBS}" || fail "Finder's account is incomplete: ${OBS_RAW}"
}
# A Finder with no window: what each case starts from, so that any window and selection after
# the request is the request's doing.
close_finder_windows() {
    guest 'osascript -e '"'"'tell application "Finder" to close every window'"'"'' || true
    for _ in 1 2 3 4 5; do
        observe
        jq -e '.windows == 0' >/dev/null <<<"${OBS}" && return 0
        sleep 2
    done
    fail "Finder still shows a window after closing them: ${OBS}"
}
# The observer is a process of the test harness, which macOS asks about once: the first time
# it asks Finder anything, "testanyware-agent wants access to control Finder". That consent is
# the observer's and not Koine's, it is given here before Koine starts, and nothing of Koine's
# is asked for it. The dialog is answered by clicking Allow where the accessibility tree puts it.
allow_observer() {
    # One exec, not retried (a retry would ask again): it stays blocked on the dialog until the
    # click below, so it runs in the background of this shell and is waited for after the click.
    testanyware file exec 'osascript $HOME/finder-observe.applescript >$HOME/obs-first.txt 2>&1' >/dev/null 2>&1 &
    local first=$! hit="null" tries=0
    while [ "${hit}" = null ]; do
        tries=$((tries + 1))
        [ "${tries}" -lt 20 ] || break
        hit="$(screen_buttons | jq -c '[.[] | select(.app == "UserNotificationCenter" and .label == "Allow")][0]')"
        [ "${hit}" != null ] || sleep 2
    done
    if [ "${hit}" != null ]; then
        echo "The observer's own consent dialog: $(screen_text UserNotificationCenter | cut -c1-200)"
        # shellcheck disable=SC2046
        testanyware input click $(jq -r '"\(.x) \(.y)"' <<<"${hit}") >/dev/null
        OBSERVER_CONSENT="asked and allowed"
    else
        OBSERVER_CONSENT="not asked (already granted in the image)"
    fi
    wait "${first}" || true
    sleep 2
    observe
    echo "Observer consent: ${OBSERVER_CONSENT}. Finder's account with no window open: $(jq -c . <<<"${OBS}")"
}
# strip a trailing slash: Finder names a folder with one, a request may or may not.
bare() { printf '%s' "${1%/}"; }

# reveal_case <section> <case> <path file> <kind: item|root> <expected selected path> <expected target folder>
#             <expected kind of the selected item, or empty>
# One request with ${OTHER} in front and Koine inactive, from a Finder with no window. The
# acknowledgment must be ok and echo the submitted path; and Finder's own account must be
# that its front window shows the expected folder with exactly the expected item selected
# (the root: a window on "/" with nothing selected). The item is also named: Finder's path
# for a selected symlink is its target's, so the name is what says the link itself was selected.
reveal_case() {
    local section="$1" case="$2" file="$3" kind="$4" want_item="$5" want_target="$6" want_kind="${7:-}"
    local status="passed" notes="" path ack sent received answer_ms act="null" shot
    path="$(cat "${WORK}/paths/${file}.txt")"
    step "${section}: ${case}"
    close_finder_windows
    put_other_in_front >/dev/null
    watch_start
    open_client "reveal-path --secret \"${BOTH}\" --path-file \"${PATHS}/${file}.txt\""
    ack="$(jq -r .classification <<<"${ANSWER}")"
    sent="$(jq -r .sentMs <<<"${ANSWER}")"
    received="$(jq -r .receivedMs <<<"${ANSWER}")"
    answer_ms=$((received - sent))
    if [ "${ack}" != ok ]; then
        status="failed"
        notes="not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
    else
        expect '.status == "AVAILABLE" and .dependency == null and .http.status == 200 and ((.errors // []) | length == 0) and .selectionObserved == false' "${case}: not an acknowledged reveal"
        [ "$(jq -r .receipt.path <<<"${ANSWER}")" = "${path}" ] || { status="failed"; notes="${notes}the receipt does not echo the submitted path; "; }
    fi
    # Finder's account: polled, because the window and the selection follow the acknowledgment.
    local seen=false
    for _ in $(seq 1 15); do
        observe
        if [ "${kind}" = recorded ]; then
            # Finder's own reading of a path the kernel and Finder may read differently: seen and
            # recorded, not asserted, since the contract promises only the acknowledgment.
            jq -e '.windows >= 1' >/dev/null <<<"${OBS}" && { seen=true; break; }
        elif [ "${kind}" = root ]; then
            jq -e --arg t "${want_target}" '.windows >= 1 and (.target | . != null and (. == $t)) and (.selected | length == 0)' >/dev/null <<<"${OBS}" && { seen=true; break; }
        else
            jq -e --arg i "${want_item}" --arg t "${want_target}" --arg k "${want_kind}" --arg n "$(basename "$(bare "${path}")")" \
                '.windows >= 1 and ((.target // "") | rtrimstr("/")) == ($t | rtrimstr("/")) and (.selected | length == 1) and ((.selected[0].path) | rtrimstr("/")) == ($i | rtrimstr("/")) and ($k == "" or .selected[0].kind == $k) and (.selected[0].name | rtrimstr("/")) == ($n | rtrimstr("/"))' >/dev/null <<<"${OBS}" && { seen=true; break; }
        fi
        sleep 2
    done
    echo "Finder's account: $(jq -c . <<<"${OBS}")"
    if [ "${seen}" != true ]; then
        status="failed"
        notes="${notes}Finder does not show ${want_item} selected in ${want_target}; "
    fi
    shot="${OUT_DIR}/${file}.png"
    testanyware screen capture -o "${shot}" >/dev/null 2>&1 || true
    # Whether the witness saw Finder activated is recorded, not required, and read once: reveal
    # is not a launch, the contract asks for no activation, and Finder was seen not to take the
    # front from another application on a request of Koine's, so waiting for one would only
    # spend minutes of the guest's slow exec channel per case.
    watch_read
    watch_stop
    ACTIVATED_MS="$(jq -rs "[.[] | select(.event == \"activated\" and .application.bundleIdentifier == \"${FINDER_ID}\" and .atMs >= ${sent}) | .atMs] | first // empty" <<<"${EVENTS}" 2>/dev/null || true)"
    [ -z "${ACTIVATED_MS}" ] || act=$((ACTIVATED_MS - sent))
    echo "Witness events: $(jq -c -s '[.[] | select(.event == "launched" or .event == "activated") | {event, atMs, id: .application.bundleIdentifier}]' <<<"${EVENTS}")"
    echo "${case}: ${ack}; answer ${answer_ms} ms after the request; Finder activation $([ "${act}" != null ] && echo "${act} ms after it" || echo "NOT SEEN")"
    local dialogs
    dialogs="$(system_dialogs)"
    echo "Dialogs on screen: ${dialogs:-none}"
    [ -z "${dialogs}" ] || { status="failed"; notes="${notes}a dialog is on screen after the reveal: ${dialogs}; "; }
    record --arg s "${section}" --arg c "${case}" --arg p "${path}" --arg st "${status}" --arg n "${notes}" --argjson obs "${OBS}" \
        --argjson ms "${answer_ms}" --argjson act "${act}" --arg shot "${file}.png" \
        '{section: $s, case: $c, path: $p, status: $st, answerMs: $ms, finderActivationMs: $act, finder: $obs, screenshot: $shot, notes: $n}'
    echo "Result: ${section}: ${case}: ${status}${notes:+ — ${notes}}"
}

# --- the guest ----------------------------------------------------------------------------------
start_vm
GATEKEEPER="$(guest 'spctl --status --verbose' 2>&1)"
echo "Gatekeeper in the clone: $(tr '\n' ';' <<<"${GATEKEEPER}")"
grep -qx 'assessments enabled' <<<"${GATEKEEPER}" ||
    fail "the clone is not Gatekeeper-enforcing; run: task launchers:prepare"
install_app
step "Carry the client, the Node runtime, the witness, the observer, the fixtures and the path files into the guest"
testanyware file upload "${NODE_ARCHIVE}" /Users/admin/node.tar.xz >/dev/null
testanyware file upload "${BUNDLE}" /Users/admin/koine-client.mjs >/dev/null
testanyware file upload scripts/vm-verify-contract-client-trim.py /Users/admin/trim.py >/dev/null
testanyware file upload scripts/vm-verify-launch-client.py /Users/admin/vm-verify-launch-client.py >/dev/null
testanyware file upload "${WITNESS_BIN}" /Users/admin/LaunchWitness >/dev/null
testanyware file upload "${WORK}/paths.zip" /Users/admin/paths.zip >/dev/null
testanyware file upload docs/verification/protected-path-metadata/make-alias.swift /Users/admin/make-alias.swift >/dev/null
testanyware file upload scripts/vm-reveal-path-fixtures.sh /Users/admin/vm-reveal-path-fixtures.sh >/dev/null
testanyware file upload scripts/vm-reveal-observe.applescript /Users/admin/finder-observe.applescript >/dev/null
guest 'cd $HOME && rm -rf node paths && tar -xJf node.tar.xz && mv node-*-darwin-arm64 node && chmod +x $HOME/LaunchWitness && echo reveal-path > $HOME/launch-target.txt && ditto -x -k paths.zip paths && ls paths | wc -l && ./node/bin/node --version'

step "The fixtures: a directory of siblings with a file, a folder, a Finder alias file, a literal-punctuation file and links"
guest 'cd $HOME && swiftc -O make-alias.swift -o make-alias 2>&1 | tail -3'
guest '[ -x $HOME/make-alias ]' || fail "the alias maker did not build in the guest"
guest 'bash $HOME/vm-reveal-path-fixtures.sh $HOME/make-alias' || fail "the fixtures were not made"
PRESENT=("${FXG}/dir/note.txt" "${FXG}/dir/other.txt" "${FXG}/dir/sub folder" "${FXG}/dir/Alias to note" "${FXG}/dir/${LIT}" "${FXG}/dir/link-to-note.txt"
    "${FXG}/dir/link-to-nowhere" "/Applications/Zed.app")
ABSENT=("${FXG}/dir/no such file.txt" "${FXG}/no such directory")
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
echo "Fixture classes in the guest (the system's own account of each):"
guest "file '${FXG}/dir/Alias to note' '${FXG}/dir/link-to-nowhere'; mdls -name kMDItemContentType -raw '${FXG}/dir/Alias to note'; echo" || true

step "The observer: Finder's own account of its windows and selection, read by a process that is not Koine"
allow_observer

step "Launch Koine; a manager grant in the window, then the contract-only client enrols its own grants"
launch
create_grant "reveal-path-manager" "${MANAGER}" koine:manage
accessibility_is false
enrol "${BOTH}" reveal-path-client-both workspace:control desktop:control
expect '.grant.capabilities == ["desktop:control","workspace:control"] or .grant.capabilities == ["workspace:control","desktop:control"]' \
    "the grant is not exactly both controls"
enrol "${WORKSPACE_ONLY}" reveal-path-client-workspace workspace:control
enrol "${DESKTOP_ONLY}" reveal-path-client-desktop desktop:control
enrol "${REVOKED}" reveal-path-client-revoked workspace:control desktop:control
REVOKED_GRANT="$(jq -r '.grant.grantId' <<<"${ANSWER}")"
guest "python3 \$HOME/vm-verify-launch-client.py \"${MANAGER}\" - revoke \"${REVOKED_GRANT}\"" | tail -1 | jq -e '.response.data.koineRevokeGrant.state == "REVOKED"' >/dev/null ||
    fail "the grant to be revoked was not revoked"
echo "Accessibility is not granted to Koine in this image: every reveal below is by workspace:control and desktop:control alone."


notification_seen() {
    local found
    found="$(testanyware screen find-text "prevented from modifying" --json)" || { echo "screen unreadable"; return 2; }
    jq -e '.ok == true and .total >= 1' >/dev/null <<<"${found}"
}
probe() {
    local label="$1"; shift
    step "probe: ${label}"
    "$@"
    sleep 6
    if notification_seen; then echo "NOTIFICATION SEEN after: ${label}"; else echo "no notification after: ${label}"; fi
    testanyware screen capture -o ".build/reveal-notification-probe-${label// /-}.png" >/dev/null 2>&1 || true
}
step "Baseline"
if notification_seen; then echo "NOTIFICATION ALREADY SEEN at baseline"; else echo "no notification at baseline"; fi
probe "open-path of Zed.app, refused, inspection only" open_client "open-path --secret \"${BOTH}\" --path-file \"${PATHS}/app.txt\""
probe "reveal of Notes.app" open_client "reveal-path --secret \"${BOTH}\" --path-file \"${PATHS}/notes.txt\""
probe "reveal of TextEdit.app" open_client "reveal-path --secret \"${BOTH}\" --path-file \"${PATHS}/textedit.txt\""
probe "reveal of Zed.app" open_client "reveal-path --secret \"${BOTH}\" --path-file \"${PATHS}/app.txt\""
probe "reveal of Zed.app again" open_client "reveal-path --secret \"${BOTH}\" --path-file \"${PATHS}/app.txt\""
step "DONE"
