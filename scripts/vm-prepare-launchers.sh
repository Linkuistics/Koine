#!/bin/bash
# Prepares, or checks, a reusable TestAnyware macOS VM image in which the twelve named
# launchers (scripts/launcher-apps.json: Dia, ChatGPT, Claude, Zed, Visual Studio Code,
# Jump Desktop, Kimi, iTerm, Mail, Notes, Obsidian, Zotero) are installed from their
# normal distribution, have each launched once past Gatekeeper and first-run UI without
# signing in to anything, and are inventoried as the system reports them.
#
#   vm-prepare-launchers.sh prepare   builds the image from the platform's golden image,
#                                     writes the inventory, and keeps the result as the
#                                     tart image ${KOINE_LAUNCHERS_IMAGE}
#   vm-prepare-launchers.sh inventory starts a fresh clone of that image and rewrites the
#                                     inventory from it, keeping the first-run record
#   vm-prepare-launchers.sh verify    starts a fresh clone of that image, reads the
#                                     inventory again and compares it with the one the
#                                     preparation wrote, then launches every application
#                                     with STRICT dialogs: none may ask anything
#
# Gatekeeper is ENFORCING in the image (assessments on, "App Store & Known Developers"),
# so a launcher's first launch would have raised its dialog had preparation not
# answered it. A pristine quarantined copy of one application is archived apart, never
# opened, for the Gatekeeper-pending case. The default browser is Safari; Dia is made
# the default and Safari restored, to show the alternate works. Nothing here runs an
# application on the host. The procedure and its evidence: docs/verification/launcher-apps-vm.md
#
# KOINE_LAUNCHERS_IMAGE   the tart image to write or read (default koine-launchers-prepared)
# KOINE_LAUNCHERS_OUTPUT  where the inventory goes (default .build/launcher-apps)
# KOINE_VM_KEEP=1         leaves the VM running afterwards, for inspection
# KOINE_VM_PASSWORD       the VM account's password (the golden image's default: admin)
# shellcheck disable=SC2016  # guest-side $HOME
set -euo pipefail

cd "$(dirname "$0")/.."
MODE="${1:-prepare}"
case "${MODE}" in prepare | verify | inventory) ;; *)
    echo "usage: $0 prepare|verify|inventory" >&2
    exit 2
    ;;
esac
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

IMAGE="${KOINE_LAUNCHERS_IMAGE:-koine-launchers-prepared}"
OUTPUT="${KOINE_LAUNCHERS_OUTPUT:-.build/launcher-apps}"
mkdir -p "${OUTPUT}"

# No Koine is installed: only the clone, the helpers and the logs are wanted.
export KOINE_VM_NO_APP=1
KOINE_VM_LOG_PREFIX="launchers-${MODE}-"
if [ "${MODE}" = prepare ]; then
    # Tall enough for the Security section of System Settings, which enforce_gatekeeper
    # needs on screen (as in vm-verify-notarized.sh).
    KOINE_VM_DISPLAY="1920x2160"
else
    KOINE_VM_BASE="${IMAGE}"
    tart list --quiet 2>/dev/null | grep -qx "${IMAGE}" || {
        echo "Error: no prepared image ${IMAGE}. Run: task launchers:prepare" >&2
        exit 1
    }
fi
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-verify-gatekeeper-lib.sh
source scripts/vm-verify-gatekeeper-lib.sh
# shellcheck source=scripts/vm-launchers-lib.sh
source scripts/vm-launchers-lib.sh

# inventory <file>: the guest reads what is installed; the host keeps the document.
inventory() {
    testanyware file upload scripts/vm-launchers-inventory.py /Users/admin/vm-launchers-inventory.py >/dev/null
    testanyware file upload "${LAUNCHER_CATALOGUE}" /Users/admin/launcher-apps.json >/dev/null
    # Twelve codesign and spctl assessments outlast the agent's 30-second exec window:
    # the guest reads them detached and the host polls.
    printf '/usr/bin/python3 "$HOME/vm-launchers-inventory.py" "$HOME/launcher-apps.json" > "$HOME/launcher-inventory.json"\n' >"${WORK}/launchers-inventory.sh"
    rm_started='rm -rf $HOME/launchers-inventory.started $HOME/launchers-inventory.exit'
    guest "${rm_started}" || true
    guest_long launchers-inventory "${WORK}/launchers-inventory.sh" >/dev/null || fail "the guest could not read its inventory"
    testanyware file download /Users/admin/launcher-inventory.json "$1" >/dev/null
    jq -e '.apps | length > 0' "$1" >/dev/null || fail "the guest produced no inventory"
}
# The part of an inventory that must survive a restart of the image: what is installed
# and approved, not what happens to be running or the quarantine timestamp.
stable() {
    jq -S '{macOS: .system.productVersion, build: .system.buildVersion, gatekeeper: .system.gatekeeper,
            defaultBrowser: .defaultBrowser, pending: .gatekeeperPendingArchives,
            apps: [.apps[] | {name, installed, path, realPath, bundleIdentifier, version, build,
                              teamIdentifier, gatekeeper, approved: .quarantine.approved,
                              quarantineAgent: .quarantine.agent}]}' "$1"
}

if [ "${MODE}" = prepare ]; then
    start_vm
    enforce_gatekeeper

    step "Install the launchers from their normal distribution"
    # The Homebrew in the golden image is months old, and the installation takes
    # longer than the agent's 30-second exec window: it runs detached and is polled.
    testanyware file upload scripts/vm-launchers-install.py /Users/admin/vm-launchers-install.py >/dev/null
    testanyware file upload "${LAUNCHER_CATALOGUE}" /Users/admin/launcher-apps.json >/dev/null
    printf '/usr/bin/python3 "$HOME/vm-launchers-install.py" "$HOME/launcher-apps.json"\n' >"${WORK}/launchers-install.sh"
    guest_long launchers-install "${WORK}/launchers-install.sh" || fail "an installation failed; see its transcript above"
    guest 'df -h / | tail -1'

    step "Keep a pristine quarantined copy aside for the Gatekeeper-pending case"
    stash_pending_copy

    step "Restart the guest, so the first runs are made in a boot that has not seen the installers"
    restart_guest

    step "First run of each launcher: Gatekeeper approval and onboarding, never signing in"
    while IFS= read -r -u 3 name; do
        step "${name}"
        # iTerm asks its update question only from the second launch on.
        for launch in $(seq 1 "$(app_field "${name}" '.launches // 1')"); do
            echo "${name}: launch ${launch}"
            run_application "${name}"
            quit_application "${name}"
        done
    done 3< <(app_names)
    # Zotero's first run opens its welcome page in the default browser.
    if guest_text 'pgrep -x Safari' | grep -q '^[0-9]'; then
        echo "Safari was opened by a first run; quitting it."
        testanyware agent window-focus --window Safari >/dev/null 2>&1 || true
        testanyware input key q --modifiers cmd >/dev/null
        sleep 3
    fi

    step "The default browser: Safari now, Dia made the alternate, Safari restored"
    install_default_browser_tool
    DEFAULT_BEFORE="$(default_browser)"
    echo "Default browser: ${DEFAULT_BEFORE}"
    grep -q 'Safari.app' <<<"${DEFAULT_BEFORE}" || fail "Safari is not the default browser at the start"
    set_default_browser /Applications/Dia.app 'Use “Dia”'
    DEFAULT_DIA="$(default_browser)"
    echo "After choosing Dia: ${DEFAULT_DIA}"
    grep -q '/Applications/Dia.app' <<<"${DEFAULT_DIA}" || fail "Dia did not become the default browser"
    set_default_browser "${DEFAULT_BEFORE%% *}" 'Use “Safari”'
    DEFAULT_AFTER="$(default_browser)"
    echo "After restoring Safari: ${DEFAULT_AFTER}"
    [ "${DEFAULT_AFTER}" = "${DEFAULT_BEFORE}" ] || fail "Safari was not restored as the default browser"

    step "Inventory, from the guest"
    inventory "${OUTPUT}/inventory.json"
    # The actions are the onboarding that needed GUI work; they are part of the record.
    jq -s . "${ACTIONS}" >"${OUTPUT}/first-run-actions.json"
    jq -n --slurpfile i "${OUTPUT}/inventory.json" --slurpfile a "${OUTPUT}/first-run-actions.json" \
        '$i[0] + {firstRunActions: $a[0]}' >"${OUTPUT}/inventory-with-actions.json"
    mv "${OUTPUT}/inventory-with-actions.json" "${OUTPUT}/inventory.json"
    jq -r '.apps[] | [.name, .bundleIdentifier, .version, .path, (.gatekeeper.source // "-"), (.quarantine.flags // "none"), (.quarantine.approved | tostring)] | @tsv' "${OUTPUT}/inventory.json" | column -t -s "$(printf '\t')"
    jq -e '[.apps[] | select(.installed | not)] | length == 0' "${OUTPUT}/inventory.json" >/dev/null || fail "an application is missing from the inventory"
    # A quarantined download still unapproved after its first run would raise Gatekeeper's
    # dialog at the first launch a client makes (Zed did, before the restart above).
    jq -e '[.apps[] | select(.quarantine.present and (.quarantine.approved | not))] | length == 0' "${OUTPUT}/inventory.json" >/dev/null ||
        fail "an application is still quarantined and unapproved after its first run"
    jq -e '[.apps[] | select(.running)] | length == 0' "${OUTPUT}/inventory.json" >/dev/null || fail "an application is still running"

    step "Keep the prepared state as the image ${IMAGE}"
    guest "echo ${VM_PASSWORD} | sudo -S shutdown -h now" || true
    for _ in $(seq 1 30); do
        sleep 4
        tart list 2>/dev/null | grep -E "^local +${VM_ID} " | grep -q stopped && break
    done
    tart list 2>/dev/null | grep -E "^local +${VM_ID} " | grep -q stopped || fail "the guest did not shut down"
    tart delete "${IMAGE}" 2>/dev/null || true
    tart clone "${VM_ID}" "${IMAGE}"
    tart list | grep -E "^local +${IMAGE} "
    echo "Prepared: ${IMAGE}. Inventory: ${OUTPUT}/inventory.json"
    # The clone's own bookkeeping is stopped by cleanup; the image stays.
    exit 0
fi

# --- inventory ------------------------------------------------------------------
if [ "${MODE}" = inventory ]; then
    start_vm
    inventory "${OUTPUT}/inventory-fresh.json"
    # The first-run record belongs to the preparation, not to a later reading.
    if [ -s "${OUTPUT}/inventory.json" ]; then
        jq -n --slurpfile fresh "${OUTPUT}/inventory-fresh.json" --slurpfile old "${OUTPUT}/inventory.json" \
            '$fresh[0] + {firstRunActions: ($old[0].firstRunActions // [])}' >"${OUTPUT}/inventory.json.new"
    else
        cp "${OUTPUT}/inventory-fresh.json" "${OUTPUT}/inventory.json.new"
    fi
    mv "${OUTPUT}/inventory.json.new" "${OUTPUT}/inventory.json"
    rm -f "${OUTPUT}/inventory-fresh.json"
    echo "Inventory of ${IMAGE} written to ${OUTPUT}/inventory.json"
    exit 0
fi

# --- verify ---------------------------------------------------------------------
start_vm
step "Gatekeeper is still enforcing in the clone"
GATEKEEPER="$(guest 'spctl --status --verbose' 2>&1 | tr '\n' ';')"
echo "${GATEKEEPER}"
grep -q 'assessments enabled;developer id enabled' <<<"${GATEKEEPER}" || fail "the image does not enforce Gatekeeper"

step "Inventory of the clone, against the one the preparation wrote"
RECORDED="${OUTPUT}/inventory.json"
[ -s "${RECORDED}" ] || fail "no recorded inventory at ${RECORDED}; run: task launchers:prepare"
inventory "${OUTPUT}/inventory-verify.json"
if diff <(stable "${RECORDED}") <(stable "${OUTPUT}/inventory-verify.json"); then
    echo "The inventory of the clone matches the recorded one: $(jq '.apps | length' "${OUTPUT}/inventory-verify.json") applications."
else
    fail "the clone's inventory differs from the recorded one (above)"
fi

step "The pristine quarantined copy is still pristine"
PENDING="$(jq -r '.apps[] | select(.gatekeeperPending) | .name' "${LAUNCHER_CATALOGUE}")"
guest "rm -rf /tmp/pending && mkdir /tmp/pending && tar -C /tmp/pending -xzf ${LAUNCHER_PENDING_DIR}/${PENDING}.app.tar.gz" || fail "the pending archive does not extract"
FLAGS="$(guest_text "xattr -p com.apple.quarantine '/tmp/pending/${PENDING}.app'")"
echo "Extracted ${PENDING}: quarantine ${FLAGS}"
grep -q '^0181;' <<<"${FLAGS}" || fail "the extracted copy is not quarantined and unopened"
guest 'rm -rf /tmp/pending'

step "Every launcher opens with nothing left to approve"
STRICT=1
while IFS= read -r -u 3 name; do
    step "${name}"
    run_application "${name}"
    quit_application "${name}"
done 3< <(app_names)
if guest_text 'pgrep -x Safari' | grep -q '^[0-9]'; then
    testanyware agent window-focus --window Safari >/dev/null 2>&1 || true
    testanyware input key q --modifiers cmd >/dev/null
    sleep 3
fi
jq -e -s 'map(select((.recurring or .atQuit) | not)) | length == 0' "${ACTIONS}" >/dev/null || {
    cat "${ACTIONS}"
    fail "a launcher needed an answer on a prepared image"
}
echo "VERIFIED: ${IMAGE}; ${OUTPUT}/inventory-verify.json matches ${RECORDED}."
