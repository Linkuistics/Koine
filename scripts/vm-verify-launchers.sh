#!/bin/bash
# Verifies, on the signed Koine.app in a clone of the prepared launcher image
# (scripts/vm-prepare-launchers.sh, docs/verification/launcher-apps-vm.md: Gatekeeper
# ENFORCING, the twelve named launchers installed and past first run), that
# workspaceLaunchApplication under workspace:control AND desktop:control, and no read
# capability, launches each of Dia, ChatGPT, Claude, Zed, Visual Studio Code, Jump
# Desktop, Kimi, iTerm, Mail, Notes, Obsidian and Zotero while it is stopped and
# reactivates it while it runs, each time with another application (TextEdit) in front
# and Koine inactive.
#
# Every request is made by the contract-only client (clients/contract-only), written
# from the published contract alone, which obtains its grant through Koine's window.
# Activation is never inferred from the acknowledgment: Fixtures/LaunchWitness, an
# independent signed tool that holds no Koine code and needs no Accessibility, reads
# the system's own account of who is in front, which instances run, the kernel's start
# instant of each, and every launch and activation on the guest's clock. For each
# application the run records its bundle identifier, version, path, the callback
# latency and the activation latency of both requests, and whether the returned process
# is the kernel's. An acknowledgment without an observed activation fails its case: a
# case where Koine only holds the two controls and the application is not seen
# activating is PENDING, kept live and taken to Antony, never counted as a pass.
#
# Then, in the same clone:
#   * an application that is not installed, and one that was installed, launched, and
#     deleted (a registration whose bundle is gone), each report
#     APPLICATION_NOT_INSTALLED and launch nothing;
#   * the Gatekeeper-pending case: the pristine quarantined copy the preparation kept
#     aside is extracted, registered, and launched by its path. Its Gatekeeper dialog is
#     held open past the three-second bound; the request is `failed`, never dependency
#     absence, attempted once; and after the dialog is dismissed (declined, then in a
#     second pass accepted) nothing further is published and nothing is replayed.
#
# Nothing here runs an application on the host. The procedure and its recorded
# evidence: docs/verification/launchers-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
# KOINE_LAUNCHERS_IMAGE is the prepared image (default koine-launchers-prepared).
# KOINE_LAUNCHERS_ONLY=<name>[,<name>...] runs the cases of those applications only (none: no application).
# KOINE_LAUNCHERS_SKIP_EXTRA=1 skips the not-installed and Gatekeeper cases.
# Exit status: 0 every case passed; 1 a case failed; 3 every failure is a pending
# activation (controls-only), which goes to Antony.
# shellcheck disable=SC2016  # guest-side $HOME
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

IMAGE="${KOINE_LAUNCHERS_IMAGE:-koine-launchers-prepared}"
tart list --quiet 2>/dev/null | grep -qx "${IMAGE}" || {
    echo "Error: no prepared image ${IMAGE}. Run: task launchers:prepare" >&2
    exit 1
}
KOINE_VM_BASE="${IMAGE}"
KOINE_VM_LOG_PREFIX="launchers-vm-"
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

BUNDLE="clients/contract-only/dist/koine-client.mjs"
[ -f "${BUNDLE}" ] || { echo "Error: ${BUNDLE} does not exist. Run: task client" >&2; exit 1; }

OTHER="TextEdit"
MISSING_ID="dev.koine.test.NotInstalled"
UNINSTALL="Zotero"
PENDING_APP="Obsidian"
PENDING_ROOT="/Users/admin/gatekeeper-pending/extracted"
PENDING_COPY="${PENDING_ROOT}/${PENDING_APP}.app"
# The witness' watch log, the two grants' secrets, and the client's answers.
{
    WATCH='$HOME/watch.jsonl'
    BOTH='$HOME/koine-secret-both'
}
# shellcheck source=scripts/vm-verify-launch-lib.sh
source scripts/vm-verify-launch-lib.sh

NODE_ARCHIVE="$(scripts/stage-node-runtime.sh)"
WITNESS_BIN="$(Fixtures/LaunchWitness/build.sh .build/witness)"
RESULTS="${WORK}/results.jsonl"
: >"${RESULTS}"
OUT_DIR=".build/launchers-vm"
mkdir -p "${OUT_DIR}"

# contract_client_once, as the shared library has it but never run twice once it has started.
# The agent has answered "not reached" (status 7) for a command that went on to run: the
# client then ran again and the second launch was a reactivation, so the recorded send
# instant came 45 seconds after the process started. The answer file is created when the
# shell starts the command, so a file that exists means it ran, and it is waited for.
contract_client_once() {
    local file status
    ONCE_CALLS=$((ONCE_CALLS + 1))
    ANSWER=""
    file="\$HOME/client-answer-${ONCE_CALLS}.json"
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
        ANSWER="$(guest_json "cat ${file}" 2>/dev/null)" && break
        sleep 3
    done
    [ -n "${ANSWER:-}" ] && jq -e . >/dev/null <<<"${ANSWER}" || fail "the contract-only client left no answer for: $*"
    echo "${ANSWER}"
}

# launch_application <credential file> <bundle identifier> [client options...]: one launch,
# never repeated. The client's answer is left in ANSWER.
launch_application() {
    local credential="$1" id="$2"
    shift 2
    contract_client_once "launch --secret \"${credential}\" --bundle-identifier ${id} $*"
}

# --- what the witness and the screen say ------------------------------------------
quiet_instances() { INSTANCES="$(guest_json "\$HOME/LaunchWitness instances $1")"; }
instance_count() { quiet_instances "$1"; jq -r '.instances | length' <<<"${INSTANCES}"; }
# activation_wait <bundle identifier> <after ms>: ACTIVATED_MS, or empty after 40 seconds.
activation_wait() {
    ACTIVATED_MS=""
    for _ in $(seq 1 20); do
        watch_read
        ACTIVATED_MS="$(jq -rs "[.[] | select(.event == \"activated\" and .application.bundleIdentifier == \"$1\" and .atMs >= $2) | .atMs] | first // empty" <<<"${EVENTS}")"
        [ -z "${ACTIVATED_MS}" ] || return 0
        sleep 2
    done
    return 1
}
# system_dialogs: the owners and buttons of any Gatekeeper, permission or Accessibility
# dialog on screen, as "owner:button" words; empty when there is none.
system_dialogs() {
    screen_buttons | jq -r '[.[] | select(.app == "CoreServicesUIAgent" or .app == "UserNotificationCenter" or .app == "universalAccessAuthWarn") | "\(.app):\(.label)"] | join(", ")'
}
bundle_value() { guest_text "/usr/libexec/PlistBuddy -c 'Print :$2' '$1/Contents/Info.plist'" | tail -1; }
record() { jq -cn "$@" >>"${RESULTS}"; }

# one_launch <label> <credential file> <bundle identifier> [client options...]: puts TextEdit
# in front, sends one launch and watches the system for it. Leaves in globals: ACK_CLASS,
# SENT, RECEIVED, PROCESS (the client's {pid, startedAt} or null), ACTIVATED_MS (empty
# if the witness never saw the application activated), LAUNCHED (launch events seen).
one_launch() {
    local label="$1" credential="$2" id="$3"
    shift 3
    put_other_in_front >/dev/null
    watch_start
    launch_application "${credential}" "${id}" "$@" >/dev/null
    ACK_CLASS="$(jq -r .classification <<<"${ANSWER}")"
    SENT="$(jq -r .sentMs <<<"${ANSWER}")"
    RECEIVED="$(jq -r .receivedMs <<<"${ANSWER}")"
    PROCESS="$(jq -c 'if .process then (.process | {pid, startedAt}) else null end' <<<"${ANSWER}")"
    ACTIVATED_MS=""
    if [ "${ACK_CLASS}" = ok ]; then activation_wait "${id}" "${SENT}" || true; else sleep 5; fi
    watch_read
    watch_stop
    echo "Witness events: $(jq -c -s '[.[] | select(.event == "launched" or .event == "activated") | {event, atMs, name: .application.name, id: .application.bundleIdentifier, pid: .application.pid}]' <<<"${EVENTS}")"
    LAUNCHED="$(jq -rs "[.[] | select(.event == \"launched\" and .application.bundleIdentifier == \"${id}\" and .atMs >= ${SENT})] | length" <<<"${EVENTS}")"
    echo "${label}: ${ACK_CLASS}; answer $((RECEIVED - SENT)) ms after the request; activation $([ -n "${ACTIVATED_MS}" ] && echo "$((ACTIVATED_MS - SENT)) ms after it" || echo "NOT SEEN"); launch events ${LAUNCHED}; process ${PROCESS}"
}

# nothing_moved <what> <expectation jq> <credential> <bundle identifier> [client options...]:
# a launch that must launch nothing.
nothing_moved() {
    local what="$1" condition="$2" credential="$3" id="$4" front_before
    shift 4
    put_other_in_front >/dev/null
    witness_front >/dev/null
    front_before="$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")"
    watch_start
    launch_application "${credential}" "${id}" "$@" >/dev/null
    echo "${what}: $(jq -c '{classification, status, dependency, errors}' <<<"${ANSWER}")"
    expect "${condition}" "${what}: the client did not report it as expected"
    sleep 5
    watch_read
    watch_stop
    jq -e -s '[.[] | select(.event == "launched" or .event == "activated")] | length == 0' >/dev/null <<<"${EVENTS}" ||
        fail "${what}: the system reported an application launched or activated"
    witness_front >/dev/null
    [ "$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")" = "${front_before}" ] || fail "${what}: focus moved"
    echo "Observation: ${what}: nothing launched, activated or moved."
}

# judge_dialogs <when> <dialogs as system_dialogs printed them>: in launcher_case, whose
# `status` and `notes` it updates. Koine must raise nothing of its own and the launch must not
# raise Gatekeeper's dialog (the preparation approved every application). A permission request
# an application raises for itself is that application's onboarding (Kimi asks to find devices
# on the local network): it is recorded with its words, then declined so that it does not
# stand over the next case, and fails the case only if it names Koine. Kimi's recurring
# Accessibility (events) request is the preparation's recorded recurring behaviour, left for
# the quit that clears it.
judge_dialogs() {
    local when="$1" dialogs="$2" words hit
    [ -n "${dialogs}" ] || return 0
    notes="${notes}on screen after the ${when}: ${dialogs}; "
    if grep -q 'CoreServicesUIAgent' <<<"${dialogs}"; then
        status="failed"
        notes="${notes}Gatekeeper's dialog was raised by the ${when}; "
    fi
    if grep -q 'UserNotificationCenter' <<<"${dialogs}"; then
        words="$(screen_text UserNotificationCenter | cut -c1-300)"
        echo "Permission request on screen after the ${when}: ${words}"
        if grep -qi 'koine' <<<"${words}"; then
            status="failed"
            notes="${notes}a permission request names Koine: ${words}; "
        else
            hit="$(screen_buttons | jq -c '[.[] | select(.app == "UserNotificationCenter" and .label == "Don’t Allow")][0]')"
            if [ "${hit}" != null ]; then
                # shellcheck disable=SC2046
                testanyware input click $(jq -r '"\(.x) \(.y)"' <<<"${hit}") >/dev/null
                sleep 2
            fi
            notes="${notes}the application's own permission request, declined: ${words}; "
        fi
    fi
}

# --- one application, stopped and then running --------------------------------------
launcher_case() {
    local name="$1" path id version build status="passed" notes="" cold_cb cold_act react_cb react_act
    local cold_process kernel_match="n/a" react_same="n/a" dialogs_cold dialogs_react cold_launched react_launched count
    path="$(app_field "${name}" .path)"
    id="$(bundle_value "${path}" CFBundleIdentifier)"
    version="$(bundle_value "${path}" CFBundleShortVersionString)"
    build="$(bundle_value "${path}" CFBundleVersion)"
    APPLICATION="${name}"
    step "${name} (${id} ${version}, build ${build}) at ${path}"
    [ -n "${id}" ] || fail "${name} is not installed at ${path}: that is live preparation work, not a passing case"

    count="$(instance_count "${id}")"
    if [ "${count}" != 0 ]; then
        guest "pkill -9 -f '${path}/Contents/MacOS/'" || true
        sleep 3
        notes="${notes}running at the start, killed; "
    fi

    # Cold.
    one_launch "cold launch" "${BOTH}" "${id}"
    cold_process="${PROCESS}"
    if [ "${ACK_CLASS}" != ok ]; then
        status="failed"
        notes="${notes}cold launch was not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
        record --arg n "${name}" --arg id "${id}" --arg v "${version}" --arg b "${build}" --arg p "${path}" --arg s "${status}" --arg notes "${notes}" \
            '{application: $n, bundleIdentifier: $id, version: $v, build: $b, path: $p, status: $s, notes: $notes}'
        return 0
    fi
    cold_cb=$((RECEIVED - SENT))
    SENT_COLD="${SENT}"
    cold_launched="${LAUNCHED}"
    if [ -n "${ACTIVATED_MS}" ]; then cold_act=$((ACTIVATED_MS - SENT)); else cold_act=null; fi
    sleep 3
    testanyware screen capture -o "${LOG%.log}-${name// /-}.png" >/dev/null 2>&1 || true
    dialogs_cold="$(system_dialogs)"
    # Read in this shell, not a substitution: the kernel comparison below uses INSTANCES.
    quiet_instances "${id}"
    count="$(jq -r '.instances | length' <<<"${INSTANCES}")"
    echo "Instances after the cold launch: ${count}; dialogs on screen: ${dialogs_cold:-none}"
    [ "${count}" = 1 ] || notes="${notes}${count} instances after the cold launch; "
    if [ "${cold_process}" != null ] && [ "${count}" = 1 ]; then
        kernel_match="$(jq -c --argjson p "${cold_process}" '.instances[0] | {pid, startedAt} == $p' <<<"${INSTANCES}")"
        echo "Receipt ${cold_process}; kernel, read by the witness: $(jq -c '.instances[0] | {pid, startedAt}' <<<"${INSTANCES}") — equal: ${kernel_match}"
        [ "${kernel_match}" = true ] || { status="failed"; notes="${notes}the receipt's process is not the kernel's identity; "; }
    elif [ "${cold_process}" = null ]; then
        notes="${notes}no process in the cold receipt; "
    fi
    # A cold launch makes a process that did not exist when the request was sent: the kernel's
    # start instant of the one instance (read by the witness) is after the request. The system's
    # own launch notification is recorded beside it but is not the criterion: it can name the
    # application late or not at all.
    local started_ms
    started_ms="$(jq -r '.instances[0].startedAt | (.[0:19] + "Z" | fromdate) * 1000 + ((.[20:26] | tonumber) / 1000 | floor)' <<<"${INSTANCES}" 2>/dev/null || echo 0)"
    echo "Kernel start of the instance: ${started_ms} ms; request sent at ${SENT_COLD} ms; the witness's launch events for it: ${cold_launched}"
    [ "${started_ms}" -ge "${SENT_COLD}" ] 2>/dev/null || { status="failed"; notes="${notes}the instance did not start after the cold request was sent; "; }
    if [ -z "${ACTIVATED_MS}" ]; then
        [ "${status}" = failed ] || status="pending-activation"
        notes="${notes}acknowledged (answer ${cold_cb} ms) but the witness never saw ${name} activated after a cold launch; "
    fi
    judge_dialogs "cold launch" "${dialogs_cold}"

    # Reactivation: the same running copy, another application in front again.
    one_launch "reactivation" "${BOTH}" "${id}"
    react_launched="${LAUNCHED}"
    if [ "${ACK_CLASS}" != ok ]; then
        status="failed"
        notes="${notes}reactivation was not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
        react_cb=null
        react_act=null
    else
        react_cb=$((RECEIVED - SENT))
        if [ -n "${ACTIVATED_MS}" ]; then react_act=$((ACTIVATED_MS - SENT)); else react_act=null; fi
        if [ -z "${ACTIVATED_MS}" ]; then
            [ "${status}" = failed ] || status="pending-activation"
            notes="${notes}acknowledged (answer ${react_cb} ms) but the witness never saw ${name} activated by the reactivation; "
        fi
        if [ "${cold_process}" != null ] && [ "${PROCESS}" != null ]; then
            react_same="$([ "${PROCESS}" = "${cold_process}" ] && echo true || echo false)"
            [ "${react_same}" = true ] || { status="failed"; notes="${notes}the reactivation returned another process; "; }
        fi
        [ "${react_launched}" = 0 ] || { status="failed"; notes="${notes}the reactivation launched ${react_launched} application(s); "; }
        count="$(instance_count "${id}")"
        [ "${count}" = 1 ] || { status="failed"; notes="${notes}${count} instances after the reactivation; "; }
        dialogs_react="$(system_dialogs)"
        echo "Instances after the reactivation: ${count}; dialogs on screen: ${dialogs_react:-none}"
        judge_dialogs "reactivation" "${dialogs_react}"
    fi
    witness_front >/dev/null
    local front_name
    front_name="$(jq -r '.application.name' <<<"${FRONT}")"
    echo "Frontmost after the reactivation: ${front_name}"

    # Back to stopped, as a user quits.
    quit_application "${name}"
    sleep 2
    count="$(instance_count "${id}")"
    [ "${count}" = 0 ] || {
        guest "pkill -9 -f '${path}/Contents/MacOS/'" || true
        notes="${notes}${count} instance(s) remained after Command-Q, force-killed; "
        sleep 2
    }
    record --arg n "${name}" --arg id "${id}" --arg v "${version}" --arg b "${build}" --arg p "${path}" --arg s "${status}" --arg notes "${notes}" \
        --argjson coldCb "${cold_cb}" --argjson coldAct "${cold_act}" --argjson reactCb "${react_cb}" --argjson reactAct "${react_act}" \
        --arg kernel "${kernel_match}" --arg same "${react_same}" --arg front "${front_name}" \
        '{application: $n, bundleIdentifier: $id, version: $v, build: $b, path: $p, status: $s, coldCallbackMs: $coldCb, coldActivationMs: $coldAct,
          reactivationCallbackMs: $reactCb, reactivationActivationMs: $reactAct, receiptIsKernelIdentity: $kernel, reactivationSameProcess: $same,
          frontmostAfterReactivation: $front, notes: $notes}'
    echo "Result: ${name}: ${status}${notes:+ — ${notes}}"
}

# --- the guest ------------------------------------------------------------------------
start_vm
GATEKEEPER="$(guest 'spctl --status --verbose' 2>&1)"
echo "Gatekeeper in the clone: $(tr '\n' ';' <<<"${GATEKEEPER}")"
grep -qx 'assessments enabled' <<<"${GATEKEEPER}" && grep -qx 'developer id enabled' <<<"${GATEKEEPER}" ||
    fail "the clone is not Gatekeeper-enforcing; run: task launchers:prepare"
install_app
step "Carry the client, the Node runtime it needs and the witness into the guest"
testanyware file upload "${NODE_ARCHIVE}" /Users/admin/node.tar.xz >/dev/null
testanyware file upload "${BUNDLE}" /Users/admin/koine-client.mjs >/dev/null
testanyware file upload scripts/vm-verify-contract-client-trim.py /Users/admin/trim.py >/dev/null
testanyware file upload "${WITNESS_BIN}" /Users/admin/LaunchWitness >/dev/null
guest 'cd $HOME && rm -rf node && tar -xJf node.tar.xz && mv node-*-darwin-arm64 node && chmod +x $HOME/LaunchWitness && echo launch > $HOME/launch-target.txt && ./node/bin/node --version'

step "Launch Koine; the contract-only client enrols a grant of both controls and no read, approved in the window"
launch
enrol "${BOTH}" launchers-client-both workspace:control desktop:control
expect '.grant.capabilities == ["desktop:control","workspace:control"] or .grant.capabilities == ["workspace:control","desktop:control"]' \
    "the grant is not exactly both controls"
echo "Accessibility is not granted to Koine in this image (its first run in this clone): activation below is by workspace:control and desktop:control alone."

step "The inventory the image was recorded with, against what this clone says"
INVENTORY="$(ls .build/launcher-apps/inventory.json docs/verification/launcher-apps/inventory.json 2>/dev/null | head -1)"
echo "Recorded inventory: ${INVENTORY}"

NAMES="$(app_names)"
if [ -n "${KOINE_LAUNCHERS_ONLY:-}" ]; then
    NAMES="$(tr ',' '\n' <<<"${KOINE_LAUNCHERS_ONLY}")"
    [ "${KOINE_LAUNCHERS_ONLY}" != none ] || NAMES=""
fi

while IFS= read -r NAME; do
    [ -n "${NAME}" ] || continue
    launcher_case "${NAME}"
    # The recorded inventory is a cross-check, not a source: identifiers must agree.
    if [ -n "${INVENTORY}" ]; then
        recorded="$(jq -r --arg n "${NAME}" '.apps[] | select(.name == $n) | .bundleIdentifier' "${INVENTORY}")"
        actual="$(jq -rs --arg n "${NAME}" '[.[] | select(.application == $n) | .bundleIdentifier] | last' "${RESULTS}")"
        [ "${recorded}" = "${actual}" ] || fail "${NAME}: the clone's bundle identifier ${actual} is not the inventory's ${recorded}"
    fi
done <<<"${NAMES}"

if [ "${KOINE_LAUNCHERS_SKIP_EXTRA:-0}" != 1 ]; then
    step "An application that is not installed reports APPLICATION_NOT_INSTALLED, and nothing launches"
    APPLICATION="${MISSING_ID}"
    nothing_moved "an application that is not installed" \
        '.classification == "dependency-unavailable" and .status == "DEPENDENCY_UNAVAILABLE" and .dependency.reason == "APPLICATION_NOT_INSTALLED" and (.dependency.guidance | length > 0) and .process == null' \
        "${BOTH}" "${MISSING_ID}"
    record --arg id "${MISSING_ID}" '{case: "not installed", bundleIdentifier: $id, status: "passed"}'

    step "An application that was installed, launched and then deleted reports APPLICATION_NOT_INSTALLED, and nothing launches"
    UPATH="$(app_field "${UNINSTALL}" .path)"
    UID_="$(jq -rs --arg n "${UNINSTALL}" '[.[] | select(.application == $n) | .bundleIdentifier] | last' "${RESULTS}")"
    if [ "${UID_}" = null ] || [ -z "${UID_}" ]; then UID_="$(bundle_value "${UPATH}" CFBundleIdentifier)"; fi
    echo "Deleting ${UNINSTALL} (${UID_}) from ${UPATH} in the disposable clone; the system's registration is left as it is."
    guest "echo ${VM_PASSWORD} | sudo -S rm -rf '${UPATH}'" || true
    guest "[ ! -e '${UPATH}' ]" || fail "${UNINSTALL} is still installed"
    nothing_moved "${UNINSTALL}, deleted after it was registered" \
        '.classification == "dependency-unavailable" and .status == "DEPENDENCY_UNAVAILABLE" and .dependency.reason == "APPLICATION_NOT_INSTALLED" and .process == null' \
        "${BOTH}" "${UID_}"
    record --arg n "${UNINSTALL}" --arg id "${UID_}" '{case: "uninstalled", application: $n, bundleIdentifier: $id, status: "passed"}'

    # --- the Gatekeeper-pending case ---------------------------------------------------
    pending_extract() {
        guest "rm -rf ${PENDING_ROOT} && mkdir -p ${PENDING_ROOT} && tar -C ${PENDING_ROOT} -xzf ${LAUNCHER_PENDING_DIR}/${PENDING_APP}.app.tar.gz" || fail "the pending archive does not extract"
        local flags
        flags="$(guest_text "xattr -p com.apple.quarantine '${PENDING_COPY}'")"
        echo "Quarantine on the extracted copy: ${flags}"
        grep -q '^0181;' <<<"${flags}" || fail "the extracted copy is not in the never-opened quarantined state"
        guest "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f '${PENDING_COPY}'" || true
        guest "[ -x '${PENDING_COPY}/Contents/MacOS/${PENDING_APP}' ]" || fail "the pending copy has no executable"
    }
    PENDING_ID="$(bundle_value "/Applications/${PENDING_APP}.app" CFBundleIdentifier)"
    pending_case() {
        local mode="$1" button="$2" gk_dialog gk_count held cb status="passed" notes=""
        step "Gatekeeper held open past the bound (${mode})"
        APPLICATION="${PENDING_APP} (pending copy)"
        pending_extract
        [ "$(instance_count "${PENDING_ID}")" = 0 ] || fail "${PENDING_APP} is running before the case"
        [ -z "$(system_dialogs)" ] || fail "a system dialog is already on screen: $(system_dialogs)"
        put_other_in_front >/dev/null
        watch_start
        # The request: the client answers once, at the bound or earlier, while the dialog is up.
        launch_application "${BOTH}" "${PENDING_ID}" "--application-path \"${PENDING_COPY}\"" >/dev/null
        SENT="$(jq -r .sentMs <<<"${ANSWER}")"
        RECEIVED="$(jq -r .receivedMs <<<"${ANSWER}")"
        cb=$((RECEIVED - SENT))
        echo "The client's answer: $(jq -c '{classification, status, dependency, errors, actionEffect, process}' <<<"${ANSWER}") after ${cb} ms"
        gk_dialog="$(system_dialogs)"
        testanyware screen capture -o "${LOG%.log}-gatekeeper-held-${mode}.png" >/dev/null 2>&1 || true
        echo "Dialogs on screen when the answer arrived: ${gk_dialog:-none}"
        expect '.classification == "failed" and .http.status == 200 and .process == null' \
            "the held launch was not reported as failed with no process (never dependency absence, never success)"
        [ "${cb}" -ge 2500 ] && [ "${cb}" -le 6000 ] || { status="failed"; notes="${notes}the answer came ${cb} ms after the request, not at the three-second bound; "; }
        grep -q 'CoreServicesUIAgent:Open' <<<"${gk_dialog}" || { status="failed"; notes="${notes}no Gatekeeper dialog was outstanding at the answer; "; }
        # Held well past the bound: the dialog is still the only one, nothing launched, nothing replayed.
        sleep 10
        gk_count="$(screen_buttons | jq -r '[.[] | select(.app == "CoreServicesUIAgent" and .label == "Open")] | length')"
        echo "Gatekeeper dialogs 10 s after the answer: ${gk_count}"
        [ "${gk_count}" = 1 ] || { status="failed"; notes="${notes}${gk_count} Gatekeeper dialogs outstanding (replay?); "; }
        watch_read
        held="$(jq -rs '[.[] | select(.event == "launched" or .event == "activated")] | length' <<<"${EVENTS}")"
        [ "${held}" = 0 ] || { status="failed"; notes="${notes}the system reported ${held} launch/activation events while the dialog was held; "; }
        # Dismiss it.
        local hit
        hit="$(screen_buttons | jq -c --arg l "${button}" '[.[] | select(.app == "CoreServicesUIAgent" and .label == $l)][0]')"
        [ "${hit}" != null ] || fail "the Gatekeeper dialog has no ${button} button: $(screen_buttons | jq -c '[.[] | select(.app == "CoreServicesUIAgent") | .label]')"
        # shellcheck disable=SC2046
        testanyware input click $(jq -r '"\(.x) \(.y)"' <<<"${hit}") >/dev/null
        echo "Dismissed the dialog with ${button}."
        sleep 12
        watch_read
        local launched
        launched="$(jq -rs '[.[] | select(.event == "launched" and .application.bundleIdentifier == "'"${PENDING_ID}"'")] | length' <<<"${EVENTS}")"
        echo "Launch events for ${PENDING_ID} after dismissal: ${launched}; Gatekeeper dialogs: $(screen_buttons | jq -r '[.[] | select(.app == "CoreServicesUIAgent")] | length')"
        if [ "${button}" = Open ]; then
            [ "${launched}" = 1 ] || { status="failed"; notes="${notes}accepting the dialog produced ${launched} launches, not the one original submission; "; }
            [ "$(instance_count "${PENDING_ID}")" = 1 ] || { status="failed"; notes="${notes}accepting the dialog left $(instance_count "${PENDING_ID}") instances; "; }
        else
            [ "${launched}" = 0 ] || { status="failed"; notes="${notes}declining the dialog still launched ${launched}; "; }
            [ "$(instance_count "${PENDING_ID}")" = 0 ] || { status="failed"; notes="${notes}declining the dialog left an instance; "; }
        fi
        watch_stop
        # Nothing published late: the answer was the only one, the endpoint is unaffected and its
        # next answer is its own — an ordinary launch of another launcher succeeds with its own receipt.
        local NOTES_ID
        NOTES_ID="$(bundle_value /System/Applications/Notes.app CFBundleIdentifier)"
        one_launch "a launch after the dialog was dismissed (Notes)" "${BOTH}" "${NOTES_ID}"
        [ "${ACK_CLASS}" = ok ] && [ -n "${ACTIVATED_MS}" ] || { status="failed"; notes="${notes}the next, ordinary launch was not served normally; "; }
        guest "pkill -9 -f '/System/Applications/Notes.app/Contents/MacOS/'" || true
        guest "pkill -9 -f '${PENDING_COPY}/Contents/MacOS/'" || true
        record --arg mode "${mode}" --arg s "${status}" --arg notes "${notes}" --argjson cb "${cb}" --arg button "${button}" --argjson launched "${launched}" \
            '{case: "gatekeeper-pending", dismissedWith: $button, answerMs: $cb, launchEventsAfterDismissal: $launched, status: $s, notes: $notes}'
        echo "Result: Gatekeeper-pending (${mode}): ${status}${notes:+ — ${notes}}"
    }
    pending_case "declined" "Cancel"
    pending_case "accepted" "Open"
    guest "pkill -9 -f '${PENDING_COPY}/Contents/MacOS/'; rm -rf '${PENDING_ROOT}'" || true
fi

step "Results"
jq -s '.' "${RESULTS}" >"${OUT_DIR}/results.json"
jq -r '.[] | select(.application != null and .coldCallbackMs != null) |
    "\(.application) \(.version) (\(.bundleIdentifier)): \(.status); cold answer \(.coldCallbackMs) ms, activation \(.coldActivationMs) ms; reactivation answer \(.reactivationCallbackMs) ms, activation \(.reactivationActivationMs) ms; receipt = kernel: \(.receiptIsKernelIdentity)"' "${OUT_DIR}/results.json"
jq -r '.[] | select(.case != null) | "\(.case): \(.status)\(if .notes then " — " + .notes else "" end)"' "${OUT_DIR}/results.json"
echo "Written: ${OUT_DIR}/results.json"
FAILED="$(jq '[.[] | select(.status == "failed")] | length' "${OUT_DIR}/results.json")"
PENDING="$(jq '[.[] | select(.status == "pending-activation")] | length' "${OUT_DIR}/results.json")"

step "Quit Koine"
quit_koine

if [ "${FAILED}" != 0 ]; then
    echo "FAILED: ${FAILED} case(s) failed, ${PENDING} pending — transcript in ${LOG}" >&2
    exit 1
fi
if [ "${PENDING}" != 0 ]; then
    echo "PENDING: ${PENDING} controls-only activation case(s) did not activate; they stay live and go to Antony — transcript in ${LOG}" >&2
    exit 3
fi
step "PASSED — transcript in ${LOG}"
