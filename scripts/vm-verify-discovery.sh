#!/bin/bash
# The V seam of the first cut of app and file search (Koine 0.4.0), on the development-signed Koine.app
# in a clone of the prepared launcher image (scripts/vm-prepare-launchers.sh, docs/verification/launcher-apps-vm.md:
# Gatekeeper ENFORCING, the twelve named launchers installed and past first run). One run, one clone, every
# request made by the contract-only client (clients/contract-only), which obtains its grants through Koine's window:
#
#   1. Before Koine reads anything, the guest's own Spotlight is asked about its index
#      (scripts/vm-discovery-index-state.sh): the index status, how many application bundles it holds, and where
#      Safari, Finder and each of the twelve launchers are indexed. The count is sampled until it stops growing,
#      so that a catalogue missing an application can be told apart from an index that was still building.
#   2. Two grants: workspace:read alone, and workspace:control AND desktop:control with no read capability.
#      Neither grant alone does the other's work: the control grant is refused both reads naming workspace:read,
#      and the read grant is refused a launch naming a control capability.
#   3. `locations` returns a value for each of the ten default pairs, and `applications` lists Safari, Finder
#      and the twelve launchers, each by bundle identifier and path, with its status and coverage. A Safari or
#      Finder that the index does not report is NOT a pass: the run ends with status 5, which is the evidence
#      that the REGISTRATION lookup of the root brief is needed.
#   4. One listed application, Notes, is launched through workspaceLaunchApplication with the identifier and
#      path that the catalogue gave, under the control grants, while TextEdit is in front and Koine is inactive.
#      Activation is never inferred from the client's answer: Fixtures/LaunchWitness reads who is in front, which
#      instances run, and the kernel's start instant of each, on the guest's clock.
#   5. After every read, the screen is read for a system permission dialog. A dialog that names Koine is a new
#      consent posture and a STOP for the human (status 4): the run records what it said and which read raised
#      it, and goes no further. It is never dismissed as a pass, and the read is never changed to avoid it.
#
# Nothing here runs an application on the host. The procedure and its recorded evidence:
# docs/verification/discovery-vm.md
#
# KOINE_DISCOVERY_NOTARIZED=1 runs the check on the notarized, stapled bundle that `task app:notarize` left in
# .build/app, and refuses a bundle with no stapled ticket. `task app` builds the bundle again and drops the staple,
# so the task that sets this variable does not depend on it.
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
# KOINE_LAUNCHERS_IMAGE is the prepared image (default koine-launchers-prepared).
# KOINE_DISCOVERY_INDEX_WAIT is the longest wait for the index to settle, in seconds (default 900).
# Exit status: 0 every check passed; 1 a check failed; 4 a permission dialog names Koine (a stop for the
# human); 5 the only failure is a Safari or Finder that the index does not report (the lookup is needed);
# 6 the index had not settled when it was read, so a missing application proves nothing.
# shellcheck disable=SC2016  # guest-side $HOME
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

if [ "${KOINE_DISCOVERY_NOTARIZED:-}" = 1 ] && ! xcrun stapler validate "${APP_BUNDLE}" >/dev/null 2>&1; then
    echo "Error: ${APP_BUNDLE} carries no stapled notarization ticket. Run: task app && task app:notarize" >&2
    exit 1
fi

IMAGE="${KOINE_LAUNCHERS_IMAGE:-koine-launchers-prepared}"
tart list --quiet 2>/dev/null | grep -qx "${IMAGE}" || {
    echo "Error: no prepared image ${IMAGE}. Run: task launchers:prepare" >&2
    exit 1
}
KOINE_VM_BASE="${IMAGE}"
KOINE_VM_LOG_PREFIX="discovery-vm-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-verify-gatekeeper-lib.sh
source scripts/vm-verify-gatekeeper-lib.sh
# shellcheck source=scripts/vm-launchers-lib.sh
source scripts/vm-launchers-lib.sh
# shellcheck source=scripts/vm-verify-contract-client-lib.sh
source scripts/vm-verify-contract-client-lib.sh
# shellcheck source=scripts/vm-verify-witness-lib.sh
source scripts/vm-verify-witness-lib.sh

BUNDLE="clients/contract-only/dist/koine-client.mjs"
[ -f "${BUNDLE}" ] || { echo "Error: ${BUNDLE} does not exist. Run: task client" >&2; exit 1; }
INVENTORY=".build/launcher-apps/inventory.json"
[ -f "${INVENTORY}" ] || INVENTORY="docs/verification/launcher-apps/inventory.json"

OTHER="TextEdit"
APPLICATION="Notes"
APPLICATION_ID="com.apple.Notes"
APPLICATION_PATH="/System/Applications/Notes.app"
SAFARI_ID="com.apple.Safari"
FINDER_ID="com.apple.finder"
INDEX_WAIT="${KOINE_DISCOVERY_INDEX_WAIT:-900}"
# The ten pairs the query answers when no request is given, in the declared order.
DEFAULT_PAIRS='["HOME/USER","DESKTOP/USER","DOCUMENTS/USER","DOWNLOADS/USER","MOVIES/USER","MUSIC/USER","PICTURES/USER","APPLICATIONS/USER","APPLICATIONS/LOCAL","APPLICATIONS/SYSTEM"]'
{
    WATCH='$HOME/watch.jsonl'
    BOTH='$HOME/koine-secret-both'
    READ_ONLY='$HOME/koine-secret-read'
}
# shellcheck source=scripts/vm-verify-launch-lib.sh
source scripts/vm-verify-launch-lib.sh

NODE_ARCHIVE="$(scripts/stage-node-runtime.sh)"
WITNESS_BIN="$(Fixtures/LaunchWitness/build.sh .build/witness)"
OUT_DIR=".build/discovery-vm"
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"
FAILURES=()
note_failure() {
    FAILURES+=("$1")
    echo "FAILED CHECK: $1" >&2
}
MISSING_SPECIAL=()
INDEX_UNSETTLED=0

# stop_for_dialog <which read> <dialog owners> <words>: a permission dialog naming Koine. The run records what the
# dialog said and which read raised it, and stops: the human decides, because a new consent posture is theirs.
stop_for_dialog() {
    local read="$1" dialogs="$2" words="$3"
    testanyware screen capture -o "${LOG%.log}-koine-dialog.png" >/dev/null 2>&1 || true
    jq -n --arg read "${read}" --arg dialogs "${dialogs}" --arg words "${words}" \
        '{stop: "a permission dialog names Koine", read: $read, dialogOwners: $dialogs, words: $words}' >"${OUT_DIR}/stop.json"
    {
        echo "STOP: the ${read} raised a permission dialog that names Koine."
        echo "Dialog owners: ${dialogs}"
        echo "It said: ${words}"
        echo "This is a new consent posture. Issue 10 makes it the human's decision: it is not a pass, the read is not"
        echo "changed to avoid it, and nothing is published around it. Record is in ${OUT_DIR}/stop.json, screen in ${LOG%.log}-koine-dialog.png."
    } >&2
    exit 4
}
# no_koine_dialog <which read>: after a read, no system permission dialog names Koine. Any dialog on screen is
# recorded with its words; one that names Koine stops the run.
DIALOG_RECORD="${WORK}/dialogs.jsonl"
: >"${DIALOG_RECORD}"
no_koine_dialog() {
    local read="$1" dialogs words
    sleep 2
    dialogs="$(system_dialogs)"
    words=""
    if [ -n "${dialogs}" ]; then
        words="$(for owner in UserNotificationCenter CoreServicesUIAgent universalAccessAuthWarn; do screen_text "${owner}"; done | tr '\n' ' ' | cut -c1-600)"
        echo "A dialog is on screen after the ${read}: ${dialogs} — ${words}"
        if grep -qi 'koine' <<<"${dialogs} ${words}"; then stop_for_dialog "${read}" "${dialogs}" "${words}"; fi
        testanyware screen capture -o "${LOG%.log}-dialog-after-${read// /-}.png" >/dev/null 2>&1 || true
    fi
    jq -cn --arg read "${read}" --arg dialogs "${dialogs}" --arg words "${words}" '{read: $read, dialogs: $dialogs, words: $words}' >>"${DIALOG_RECORD}"
    echo "Observation: no permission dialog naming Koine after the ${read}${dialogs:+ (another dialog is on screen: ${dialogs})}."
}

# client_to_file <name> <argument...>: a read whose answer is too large for the agent's exec channel. The client writes
# its one line to a file in the guest, the file is brought back whole, and ANSWER is that line without the duplicate
# `response` field (the whole line is kept in OUT_DIR/<name>.json). A read is safe to repeat, but is run once.
client_to_file() {
    local name="$1" file status
    shift
    file="\$HOME/answer-${name}.json"
    guest "rm -f ${file}" >/dev/null || true
    for _ in 1 2 3; do
        status=0
        testanyware file exec "${CLIENT} $* > ${file}" >/dev/null 2>&1 || status=$?
        if [ "${status}" = 7 ] || [ "${status}" = 255 ]; then
            if guest_text "[ -e ${file} ] && echo started" | grep -qx started; then break; fi
            sleep 5
            continue
        fi
        break
    done
    for _ in $(seq 1 20); do
        if testanyware file download "/Users/admin/answer-${name}.json" "${OUT_DIR}/${name}.json" >/dev/null 2>&1 &&
            jq -e . "${OUT_DIR}/${name}.json" >/dev/null 2>&1; then
            break
        fi
        sleep 3
    done
    jq -e . "${OUT_DIR}/${name}.json" >/dev/null 2>&1 || fail "the contract-only client left no answer for: $*"
    ANSWER="$(jq -c 'del(.response)' "${OUT_DIR}/${name}.json")"
    echo "${name}: $(jq -c '{classification, status, items: (.items | if . == null then null else length end), resultsTruncated, errors: [.errors[] | {classification, path, kind}], requiredCapability, requiredCapabilities, phase}' <<<"${ANSWER}")"
}

# --- The guest ----------------------------------------------------------------------------------
start_vm
install_app
step "Carry the client, the Node runtime it needs, the witness and the index probe into the guest"
testanyware file upload "${NODE_ARCHIVE}" /Users/admin/node.tar.xz >/dev/null
testanyware file upload "${BUNDLE}" /Users/admin/koine-client.mjs >/dev/null
testanyware file upload scripts/vm-verify-contract-client-trim.py /Users/admin/trim.py >/dev/null
testanyware file upload "${WITNESS_BIN}" /Users/admin/LaunchWitness >/dev/null
testanyware file upload scripts/vm-discovery-index-state.sh /Users/admin/vm-discovery-index-state.sh >/dev/null
guest 'cd $HOME && rm -rf node && tar -xJf node.tar.xz && mv node-*-darwin-arm64 node && chmod +x $HOME/LaunchWitness && echo launch > $HOME/launch-target.txt && ./node/bin/node --version'
echo "Guest: $(guest 'sw_vers -productVersion') $(guest 'sw_vers -buildVersion'); Gatekeeper: $(guest 'spctl --status' 2>&1 || true)"

# The identifiers and paths the catalogue is held to: Safari, Finder, and the twelve launchers as the image's
# own inventory recorded them. Safari and Finder name no path, because their location is the system's to say.
EXPECTED="$(jq -c '[.apps[] | {name, bundleIdentifier, path}]' "${INVENTORY}")"
[ "$(jq 'length' <<<"${EXPECTED}")" = 12 ] || fail "the inventory ${INVENTORY} does not list twelve launchers"
EXPECTED="$(jq -c --arg s "${SAFARI_ID}" --arg f "${FINDER_ID}" '[{name: "Safari", bundleIdentifier: $s, path: null}, {name: "Finder", bundleIdentifier: $f, path: null}] + .' <<<"${EXPECTED}")"
IDENTIFIERS="$(jq -r '.[].bundleIdentifier' <<<"${EXPECTED}" | tr '\n' ' ')"
echo "Held to ${IDENTIFIERS}"

# --- 1. The index, before Koine reads ----------------------------------------------------------
step "The index state, read by the guest's own Spotlight before Koine reads anything"
SAMPLES="[]"
LAST=""
STABLE=0
STARTED_AT=$(date +%s)
INDEX_STATE=""
while true; do
    # TestAnyware drops a call now and then when it is busy, so a sample is tried three times before it fails.
    INDEX_STATE=""
    for attempt in 1 2 3; do
        if INDEX_STATE="$(guest_json "bash \$HOME/vm-discovery-index-state.sh ${IDENTIFIERS}")"; then break; fi
        echo "The index sample failed on attempt ${attempt}."
        INDEX_STATE=""
        sleep 10
    done
    [ -n "${INDEX_STATE}" ] || fail "the guest could not read its index state"
    COUNT="$(jq -r .applicationBundles <<<"${INDEX_STATE}")"
    ELAPSED=$(($(date +%s) - STARTED_AT))
    echo "Index at ${ELAPSED}s: $(jq -r .mdutil <<<"${INDEX_STATE}"); ${COUNT} application bundles"
    SAMPLES="$(jq -c --argjson c "${COUNT}" --argjson e "${ELAPSED}" '. + [{atSeconds: $e, applicationBundles: $c}]' <<<"${SAMPLES}")"
    if [ "${COUNT}" = "${LAST}" ] && [ "${COUNT}" -gt 0 ]; then STABLE=$((STABLE + 1)); else STABLE=0; fi
    LAST="${COUNT}"
    [ "${STABLE}" -lt 3 ] || break
    if [ "${ELAPSED}" -ge "${INDEX_WAIT}" ]; then
        INDEX_UNSETTLED=1
        echo "The index had not settled after ${ELAPSED}s."
        break
    fi
    sleep 20
done
jq -n --argjson state "${INDEX_STATE}" --argjson samples "${SAMPLES}" --argjson settled "$((1 - INDEX_UNSETTLED))" \
    '$state + {samples: $samples, settled: ($settled == 1)}' >"${OUT_DIR}/index-state.json"
jq -r '.present | to_entries[] | "  \(.key): \(if (.value | length) == 0 then "NOT in the index" else (.value | join(", ")) end)"' <<<"${INDEX_STATE}"
echo "Settled: $((1 - INDEX_UNSETTLED)); bundles in the index when it was read: ${COUNT}"

# --- Koine and its two grants -----------------------------------------------------------------
step "Launch Koine; the client finds the endpoint from the descriptor alone"
launch
contract_client "probe"
expect '.classification == "ok" and .descriptor.present == true and .descriptor.contractVersion == "koine-desktop/1"' \
    "the client did not read the endpoint descriptor"

step "The client enrols two grants itself, and the user approves each in the window"
enrol "${READ_ONLY}" discovery-client-read workspace:read
expect '.grant.capabilities == ["workspace:read"]' "the grant is not workspace:read alone"
enrol "${BOTH}" discovery-client-control workspace:control desktop:control
expect '.grant.capabilities == ["desktop:control","workspace:control"] or .grant.capabilities == ["workspace:control","desktop:control"]' \
    "the grant is not exactly both controls"

step "The schema the client was generated against is the one Koine serves"
contract_client "inspect --secret \"${READ_ONLY}\""
expect '.classification == "ok" and .koine.contractVersion == "koine-desktop/1" and .koine.ownGrant.state == "ACTIVE"' \
    "InspectOwnConnection did not answer for the read grant"
SERVED_DIGEST="$(jq -r .koine.schemaDigest <<<"${ANSWER}")"
contract_client_trimmed "introspect --secret \"${READ_ONLY}\" --out \$HOME/introspection.json"
expect '.classification == "ok" and (.errors | length) == 0 and .schemaDigestsEqual == true' \
    "the served schema is not the one this client was generated against"
[ "$(jq -r .servedSchemaDigest <<<"${ANSWER}")" = "${SERVED_DIGEST}" ] || fail "the digest the introspection reports is not the one Koine served this session"
echo "Digest generated against: $(jq -r .generatedAgainstSchemaDigest <<<"${ANSWER}")"
echo "Digest served now:        ${SERVED_DIGEST}"
testanyware file download /Users/admin/introspection.json "${OUT_DIR}/introspection.json" >/dev/null
jq -e '.data.__schema.types[] | select(.name == "Query") | .fields[] | select(.name == "workspaceSpecialLocations" or .name == "workspaceApplications") | .name' \
    "${OUT_DIR}/introspection.json" >/dev/null || fail "the introspection response does not carry the two discovery roots"

# --- 2. A control grant alone reads nothing ---------------------------------------------------
step "A grant holding both controls and no read capability is refused both reads, naming workspace:read"
client_to_file control-locations "locations --secret \"${BOTH}\""
expect '.classification == "capability-denied" and .http.status == 200 and .phase == "execution" and .requiredCapability == "workspace:read" and .items == null' \
    "the control grant alone read the special locations"
client_to_file control-applications "applications --secret \"${BOTH}\""
expect '.classification == "capability-denied" and .http.status == 200 and .phase == "execution" and .requiredCapability == "workspace:read" and .items == null' \
    "the control grant alone read the application catalogue"
no_koine_dialog "refused reads"

# --- 3. The reads -------------------------------------------------------------------------------
step "The special locations: a value for each of the ten default pairs"
client_to_file locations "locations --secret \"${READ_ONLY}\""
expect '.classification == "ok" and .http.status == 200 and (.status == "AVAILABLE" or .status == "PARTIAL") and (.items | length) >= 10' \
    "the special locations were not read: $(jq -c '{classification, status, errors}' <<<"${ANSWER}")"
no_koine_dialog "special-locations read"
GUEST_HOME="$(guest_text 'echo $HOME' | tail -1)"
jq -c --argjson pairs "${DEFAULT_PAIRS}" --arg home "${GUEST_HOME}" '
    . as $a
    | [$pairs[] | . as $p | ($a.items | map(select("\(.kind)/\(.domain)" == $p))) as $found
       | {pair: $p, found: ($found | length), location: ($found[0].location // null), sources: ($found[0].sources // null)}]' <<<"${ANSWER}" >"${OUT_DIR}/locations-by-pair.json"
jq -r '.[] | "  \(.pair): \(.location // "NO VALUE")"' "${OUT_DIR}/locations-by-pair.json"
jq -e 'all(.[]; .found >= 1 and (.location | type == "string" and startswith("/")) and .sources == ["FOUNDATION_LOCATIONS"])' "${OUT_DIR}/locations-by-pair.json" >/dev/null ||
    note_failure "a default location has no value, or a value that is not an absolute path from the Foundation source"
[ "$(jq -r '.[] | select(.pair == "HOME/USER") | .location' "${OUT_DIR}/locations-by-pair.json")" = "${GUEST_HOME}" ] ||
    note_failure "the home location is not the guest's home ${GUEST_HOME}"
[ "$(jq -r '.[] | select(.pair == "DOCUMENTS/USER") | .location' "${OUT_DIR}/locations-by-pair.json")" = "${GUEST_HOME}/Documents" ] ||
    note_failure "the documents location is not ${GUEST_HOME}/Documents"
[ "$(jq -r '.[] | select(.pair == "APPLICATIONS/LOCAL") | .location' "${OUT_DIR}/locations-by-pair.json")" = "/Applications" ] ||
    note_failure "the local applications location is not /Applications"
jq -e 'all(.items[]; .contentsAvailability == "UNKNOWN")' <<<"${ANSWER}" >/dev/null ||
    note_failure "a location says something about its contents: a returned location is a value, not an inspection"

step "The application catalogue: Safari, Finder and the twelve launchers"
client_to_file applications "applications --secret \"${READ_ONLY}\""
APPLICATIONS_ANSWER="${ANSWER}"
no_koine_dialog "application-catalogue read"
echo "Status: $(jq -r .status <<<"${ANSWER}"); coverage: $(jq -c '.sources | map({source, availability, observations, category, examined, diagnostics: (.diagnostics | map(.reason))})' <<<"${ANSWER}")"
jq -e '.classification == "ok" and .http.status == 200 and (.items | type == "array")' <<<"${ANSWER}" >/dev/null ||
    fail "the application catalogue was not read: $(jq -c '{classification, status, errors, sources}' <<<"${ANSWER}")"
CATALOGUE_COUNT="$(jq '.items | length' <<<"${ANSWER}")"
echo "The catalogue lists ${CATALOGUE_COUNT} applications."
# Held to the expectation, one row each: where the index put it before Koine read, and what the catalogue says.
jq -c --argjson expected "${EXPECTED}" --argjson state "${INDEX_STATE}" '
    . as $a
    | [$expected[] | . as $e
       | ($a.items | map(select(.bundleIdentifier == $e.bundleIdentifier))) as $found
       | {name: $e.name, bundleIdentifier: $e.bundleIdentifier, expectedPath: $e.path,
          indexedBefore: ($state.present[$e.bundleIdentifier] // []),
          catalogue: ($found | map({applicationPath, name, sources})),
          listed: (($found | length) > 0),
          pathMatches: (if $e.path == null then null else ($found | any(.applicationPath == $e.path)) end)}]' <<<"${ANSWER}" >"${OUT_DIR}/catalogue-by-application.json"
jq -r '.[] | "  \(.name) (\(.bundleIdentifier)): \(if .listed then (.catalogue | map("\(.applicationPath) [\(.name)]") | join("; ")) else "NOT LISTED" end); indexed before the read: \(if (.indexedBefore | length) == 0 then "no" else "yes" end)"' "${OUT_DIR}/catalogue-by-application.json"
jq -e '[.items[] | select(.sources != ["INDEXED_APPS"])] | length == 0' <<<"${ANSWER}" >/dev/null ||
    note_failure "a catalogue choice names a source other than INDEXED_APPS, which is all this cut reads"
# Absent from the catalogue: an index that was still building, an application the index does not report, or a defect.
while IFS= read -r row; do
    name="$(jq -r .name <<<"${row}")"
    id="$(jq -r .bundleIdentifier <<<"${row}")"
    if [ "$(jq -r .listed <<<"${row}")" = true ]; then
        if [ "$(jq -r .pathMatches <<<"${row}")" = false ]; then
            note_failure "${name} is listed, but not at the path the image's inventory recorded: $(jq -c .catalogue <<<"${row}")"
        fi
        continue
    fi
    if [ "${INDEX_UNSETTLED}" = 1 ]; then
        echo "${name} is not listed, and the index had not settled: this proves nothing about ${name}."
    elif [ "$(jq '.indexedBefore | length' <<<"${row}")" -gt 0 ]; then
        note_failure "${name} is in the settled index ($(jq -c .indexedBefore <<<"${row}")) but not in the catalogue: an adapter defect"
    elif [ "${id}" = "${SAFARI_ID}" ] || [ "${id}" = "${FINDER_ID}" ]; then
        MISSING_SPECIAL+=("${name}")
        echo "${name} is not in the settled index, and so not in the catalogue: the REGISTRATION lookup of the root brief is needed."
    else
        note_failure "${name} is in neither the settled index nor the catalogue, though the image has it installed"
    fi
done < <(jq -c '.[]' "${OUT_DIR}/catalogue-by-application.json")
jq -e '.sources | length >= 1 and all(.[]; .source == "INDEXED_APPS")' <<<"${ANSWER}" >/dev/null ||
    note_failure "the coverage does not say it is the index's"

# --- 4. A read grant alone acts on nothing; one listed application launches --------------------
step "A grant holding workspace:read alone is refused a launch, and nothing launches"
put_other_in_front
contract_client_once "launch --secret \"${READ_ONLY}\" --bundle-identifier ${APPLICATION_ID}"
expect '.classification == "capability-denied" and .http.status == 403 and .process == null and (.requiredCapabilities | index("workspace:control")) != null' \
    "the read grant alone launched, or was refused without naming the control capabilities"
echo "Denied: first unmet $(jq -r .requiredCapability <<<"${ANSWER}"), complete set $(jq -c .requiredCapabilities <<<"${ANSWER}")"
expect_instances "${APPLICATION_ID}" 0

step "One listed application launches through workspaceLaunchApplication with the identifier and path the catalogue gave"
ENTRY="$(jq -c --arg id "${APPLICATION_ID}" '[.items[] | select(.bundleIdentifier == $id)][0]' <<<"${APPLICATIONS_ANSWER}")"
[ "${ENTRY}" != null ] || fail "the catalogue does not list ${APPLICATION} to launch"
LISTED_ID="$(jq -r .bundleIdentifier <<<"${ENTRY}")"
LISTED_PATH="$(jq -r .applicationPath <<<"${ENTRY}")"
echo "The catalogue's entry: ${ENTRY}"
put_other_in_front
watch_start
contract_client_once "launch --secret \"${BOTH}\" --bundle-identifier ${LISTED_ID} --application-path \"${LISTED_PATH}\""
expect '.classification == "ok" and .http.status == 200 and .status == "AVAILABLE" and .dependency == null and (.process.pid > 0) and (.process.startedAt | length > 0)' \
    "the catalogue's identifier and path did not launch the application"
PROCESS="$(jq -c '.process | {pid, startedAt}' <<<"${ANSWER}")"
SENT="$(jq -r .sentMs <<<"${ANSWER}")"
RECEIVED="$(jq -r .receivedMs <<<"${ANSWER}")"
activation_of "${LISTED_ID}" "${SENT}"
echo "Timing: the client's answer $((RECEIVED - SENT)) ms after it sent the request; the witness saw ${APPLICATION} activated $((ACTIVATED_MS - SENT)) ms after it."
expect_front "${LISTED_ID}" ".application.pid == $(jq -r .pid <<<"${PROCESS}")"
watch_stop
expect_instances "${LISTED_ID}" 1
KERNEL="$(jq -c '.instances[0] | {pid, startedAt}' <<<"${INSTANCES}")"
echo "Receipt, as the client printed it: ${PROCESS}; the kernel's, read by the witness: ${KERNEL}"
[ "${PROCESS}" = "${KERNEL}" ] || note_failure "the receipt's process is not the kernel's identity for the launched application"
no_koine_dialog "launch"
LAUNCH_RECORD="$(jq -cn --argjson entry "${ENTRY}" --argjson process "${PROCESS}" --argjson kernel "${KERNEL}" \
    --argjson answerMs "$((RECEIVED - SENT))" --argjson activationMs "$((ACTIVATED_MS - SENT))" \
    '{catalogueEntry: $entry, receipt: $process, kernel: $kernel, receiptIsKernelIdentity: ($process == $kernel), answerMs: $answerMs, activationMs: $activationMs}')"
guest "killall ${APPLICATION}" || true
sleep 3

# --- The record -----------------------------------------------------------------------------------
step "Results"
jq -n \
    --slurpfile index "${OUT_DIR}/index-state.json" \
    --slurpfile locations "${OUT_DIR}/locations-by-pair.json" \
    --slurpfile catalogue "${OUT_DIR}/catalogue-by-application.json" \
    --slurpfile dialogs "${DIALOG_RECORD}" \
    --argjson applications "${APPLICATIONS_ANSWER}" \
    --argjson launch "${LAUNCH_RECORD}" \
    --arg digest "${SERVED_DIGEST}" \
    --arg guest "$(guest 'sw_vers -productVersion') ($(guest 'sw_vers -buildVersion'))" \
    --argjson missingSpecial "$(printf '%s\n' "${MISSING_SPECIAL[@]:-}" | jq -R . | jq -sc 'map(select(. != ""))')" \
    --argjson failures "$(printf '%s\n' "${FAILURES[@]:-}" | jq -R . | jq -sc 'map(select(. != ""))')" \
    '{guest: $guest, schemaDigest: $digest, index: $index[0], locations: $locations[0],
      catalogue: {status: $applications.status, resultsTruncated: $applications.resultsTruncated, sources: $applications.sources,
                  count: ($applications.items | length), byApplication: $catalogue[0]},
      launch: $launch, dialogsAfterEachRead: $dialogs, missingSpecial: $missingSpecial, failures: $failures}' >"${OUT_DIR}/results.json"
echo "Written: ${OUT_DIR}/results.json"

step "Quit Koine"
quit_koine

if [ "${#FAILURES[@]}" != 0 ]; then
    echo "FAILED: ${#FAILURES[@]} check(s) failed — transcript in ${LOG}" >&2
    exit 1
fi
if [ "${INDEX_UNSETTLED}" = 1 ]; then
    echo "INDEX NOT SETTLED: the index was still growing when it was read, so an application missing from it proves nothing — transcript in ${LOG}" >&2
    exit 6
fi
if [ "${#MISSING_SPECIAL[@]}" != 0 ]; then
    echo "LOOKUP NEEDED: the settled index does not report ${MISSING_SPECIAL[*]} — transcript in ${LOG}" >&2
    exit 5
fi
step "PASSED — transcript in ${LOG}"
