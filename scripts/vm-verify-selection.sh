#!/bin/bash
# The V seam of the first-party selection acceptance (docs/specs/machine.md, "Selection acceptance";
# docs/verification/selection-vm.md): the update and trust rows in a clean, Gatekeeper-ENFORCING TestAnyware
# macOS clone. Nothing here runs Koine, a host or a provider on the build Mac.
#
#   1. the clone is put into the macOS default Gatekeeper posture, as scripts/vm-verify-notarized.sh does;
#   2. the RELEASED Koine (v0.1.0) is downloaded IN THE GUEST, given the quarantine a browser writes, unzipped
#      (which gives it to everything inside), launched by plain `open` through its first-run dialog, and given
#      a grant in its window: the old host, as a user has it;
#   3. the purpose-built signed hosts (scripts/build-selection-vm-hosts.py) arrive as a quarantined archive
#      and are unzipped, so they are downloads too; the fixtures, the harness and the conformance tool are
#      uploaded beside them;
#   4. scripts/verify-selection-vm.py runs in the guest: every scenario, alternative discovery order and
#      restart in a fresh host process, per-user installs that are genuine downloads, Gatekeeper's own verdict
#      (nothing injected) recorded beside the loaded paths, the released application given newly published
#      updates; meanwhile this script watches the screen for a system dialog, which must never appear.
#
# Needs `task selection:vm-hosts` first. KOINE_VM_KEEP=1 leaves the VM running. KOINE_VM_PASSWORD is the guest
# account's password (the golden image's default: admin). KOINE_SELECTION_V_ONLY=<text> runs only the scenarios
# whose name contains it.
# shellcheck disable=SC2016  # guest-side $HOME, expanded by the guest's shell, never here
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

VM_OUT=".build/selection-vm"
[ -f "${VM_OUT}/notarization.json" ] || {
    echo "Error: ${VM_OUT}/notarization.json does not exist. Run: task selection:vm-hosts" >&2
    exit 1
}
NOTARIZED="$(jq -r '.notarized' "${VM_OUT}/notarization.json")"
swift build --product KoineConformance >/dev/null
PRODUCTS="$(swift build --show-bin-path)"
FRAMEWORK="$(scripts/stage-provider-framework.sh debug)"
RELEASED_TAG="${KOINE_BASELINE_REVISION:-v0.1.0}"
RELEASED_ZIP="Koine-${RELEASED_TAG#v}-aarch64-apple-darwin.zip"
RELEASED_URL="https://github.com/linkuistics/koine/releases/download/${RELEASED_TAG}/${RELEASED_ZIP}"

# shellcheck disable=SC2034  # both read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="selection-vm-"
KOINE_VM_DISPLAY="1920x2160"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-verify-gatekeeper-lib.sh
source scripts/vm-verify-gatekeeper-lib.sh

GRANT_LABEL="selection-old-host"
TREE='$HOME/koine-selection'

# guest_bg <name> <command>: a command that outlasts the agent's 30s exec window, detached in the guest and polled.
# The launch takes a guard directory, because guest() retries an exec it falsely reports as timed out, and a
# retried launch that finds it taken starts nothing. Prints its log; returns its exit status.
guest_bg() {
    local name="$1" command="$2" status
    guest "mkdir \$HOME/${name}.started 2>/dev/null || exit 0; nohup bash -c '${command} > \$HOME/${name}.log 2>&1; echo \$? > \$HOME/${name}.exit' >/dev/null 2>&1 &"
    for _ in $(seq 1 240); do
        if guest "[ -e \$HOME/${name}.exit ]" >/dev/null 2>&1; then break; fi
        sleep 5
    done
    guest "cat \$HOME/${name}.log" | sed 's/^/  | /'
    status="$(guest "cat \$HOME/${name}.exit" 2>/dev/null | tr -d '[:space:]')"
    [ -n "${status}" ] || fail "${name} did not finish within 20 minutes"
    return "${status}"
}

start_vm
enforce_gatekeeper

step "The RELEASED Koine ${RELEASED_TAG}: downloaded in the guest, quarantined as a download is, unzipped"
guest_bg download-released "curl -sSL -m 600 -o \$HOME/${RELEASED_ZIP} ${RELEASED_URL} && ls -l \$HOME/${RELEASED_ZIP}" ||
    fail "the released archive could not be downloaded in the guest"
# The archive carries the attribute and the unarchiver gives it to everything it extracts, into a directory of its
# own so that /Applications itself is not marked; the application is then moved, which keeps its attributes.
guest "xattr -w com.apple.quarantine \"${QUARANTINE}\" \$HOME/${RELEASED_ZIP} && rm -rf \$HOME/released && mkdir \$HOME/released && ditto -x -k \$HOME/${RELEASED_ZIP} \$HOME/released && rm -rf ${INSTALLED} && mv \$HOME/released/Koine.app ${INSTALLED}"
QUARANTINE_BEFORE="$(guest "xattr -p com.apple.quarantine ${INSTALLED}")"
echo "Quarantine on the released application: ${QUARANTINE_BEFORE}"
grep -q '^0181;' <<<"${QUARANTINE_BEFORE}" || fail "the released application is not quarantined"
guest "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' ${INSTALLED}/Contents/Info.plist" | tee "${WORK}/released-version"
grep -qx "${RELEASED_TAG#v}" "${WORK}/released-version" || fail "the downloaded application is not ${RELEASED_TAG}"
guest "xcrun stapler validate ${INSTALLED} 2>&1" || fail "the released application carries no stapled ticket"
ASSESSMENT="$(guest "spctl -a -t execute -vv ${INSTALLED} 2>&1")" || fail "Gatekeeper rejected the released application: ${ASSESSMENT}"
echo "${ASSESSMENT}"
grep -q 'source=Notarized Developer ID' <<<"${ASSESSMENT}" || fail "the released application is not accepted as notarized"
guest "ls ${INSTALLED}/Contents/PlugIns"

testanyware file upload scripts/vm-verify-client.sh /Users/admin/vm-verify-client.sh >/dev/null
first_launch_quarantined
grep -q 'none was detected' <<<"${DIALOG_TREE}" || fail "the first-run dialog is not the notarized one"
await_service
place_window
step "A grant made in the released application's own window: management and the desktop, read and control"
create_grant "${GRANT_LABEL}" "${CREDENTIAL_FILE}" "koine:manage" "desktop:read" "desktop:control"
guest "ls -la \"${DATA}\""
ask '{ koineManagement { providers { provider version state } } }'
quit_koine

step "Stage the harness, the fixtures, the conformance tool and the hosts"
TREE_LOCAL="${WORK}/tree"
mkdir -p "${TREE_LOCAL}/scripts" "${TREE_LOCAL}/Fixtures/SelectionHost" "${TREE_LOCAL}/App" "${TREE_LOCAL}/vm" "${TREE_LOCAL}/tools"
cp scripts/selection_harness.py scripts/verify-selection-updates.py scripts/verify-selection-vm.py "${TREE_LOCAL}/scripts/"
cp Fixtures/SelectionHost/hosts.json "${TREE_LOCAL}/Fixtures/SelectionHost/"
cp App/ProviderCatalogue.json "${TREE_LOCAL}/App/"
cp -R docs/design "${TREE_LOCAL}/design-tmp" && mkdir -p "${TREE_LOCAL}/docs" && mv "${TREE_LOCAL}/design-tmp" "${TREE_LOCAL}/docs/design"
cp -R "${VM_OUT}/fixtures" "${TREE_LOCAL}/vm/fixtures"
cp "${VM_OUT}/notarization.json" "${TREE_LOCAL}/vm/"
# The conformance tool finds its framework through an rpath into the build tree; the guest's copy carries its own.
cp "${PRODUCTS}/KoineConformance" "${TREE_LOCAL}/tools/KoineConformance"
mkdir -p "${TREE_LOCAL}/tools/Frameworks"
cp -R "${FRAMEWORK}" "${TREE_LOCAL}/tools/Frameworks/"
for rpath in $(otool -l "${TREE_LOCAL}/tools/KoineConformance" | awk '/cmd LC_RPATH/{getline; getline; print $2}'); do
    install_name_tool -delete_rpath "${rpath}" "${TREE_LOCAL}/tools/KoineConformance"
done
install_name_tool -add_rpath "@executable_path/Frameworks" "${TREE_LOCAL}/tools/KoineConformance"
codesign --force --sign - "${TREE_LOCAL}/tools/Frameworks/KoineProviderAPI.framework" "${TREE_LOCAL}/tools/KoineConformance"
ditto -c -k "${TREE_LOCAL}" "${WORK}/tree.zip"
testanyware file upload "${WORK}/tree.zip" /Users/admin/koine-selection.zip >/dev/null
guest "rm -rf ${TREE} && mkdir ${TREE} && ditto -x -k \$HOME/koine-selection.zip ${TREE} && ls ${TREE}"
# The hosts arrive as a download. Notarized, they are accepted as such (and stapled, so offline); unnotarized they
# are not quarantined, because Gatekeeper would rightly refuse them and the run would prove nothing about the loader.
ditto -c -k "${VM_OUT}/hosts" "${WORK}/hosts.zip"
testanyware file upload "${WORK}/hosts.zip" /Users/admin/koine-hosts.zip >/dev/null
if [ "${NOTARIZED}" = true ]; then
    guest "xattr -w com.apple.quarantine \"${QUARANTINE}\" \$HOME/koine-hosts.zip"
fi
guest "rm -rf ${TREE}/vm/hosts && mkdir ${TREE}/vm/hosts && ditto -x -k \$HOME/koine-hosts.zip ${TREE}/vm/hosts && ls ${TREE}/vm/hosts"
HOST_QUARANTINE="$(guest "xattr -p com.apple.quarantine ${TREE}/vm/hosts/slot/KoineSelectionHost.app 2>&1 || true")"
echo "Quarantine on a host application: ${HOST_QUARANTINE}"
if [ "${NOTARIZED}" = true ]; then
    grep -q '^0181;' <<<"${HOST_QUARANTINE}" || fail "the hosts are not quarantined downloads"
    for host in $(jq -r '.hosts[]' "${VM_OUT}/notarization.json"); do
        guest "xcrun stapler validate ${TREE}/vm/hosts/${host}/KoineSelectionHost.app 2>&1" || fail "${host} carries no stapled ticket"
        guest "spctl -a -t execute -vv ${TREE}/vm/hosts/${host}/KoineSelectionHost.app 2>&1" | grep -q 'source=Notarized Developer ID' ||
            fail "${host} is not accepted as notarized"
    done
else
    echo "UNNOTARIZED HOSTS: signed with the Developer ID identity only. This run cannot close the rows that need an intact notarized host."
fi

step "Run the scenarios in the guest, watching the screen for a system dialog"
# The command is a script of its own, so that an `--only` text needs no quoting through two shells.
{
    echo '#!/bin/bash'
    echo 'cd "$HOME/koine-selection"'
    printf 'ONLY=%q\n' "${KOINE_SELECTION_V_ONLY:-}"
    echo 'exec python3 -u scripts/verify-selection-vm.py vm/hosts vm/fixtures vm/results.json --conformance tools/KoineConformance --released-app /Applications/Koine.app --released-credential "$HOME/koine-credential" ${ONLY:+--only "$ONLY"}'
} >"${WORK}/run-selection.sh"
testanyware file upload "${WORK}/run-selection.sh" /Users/admin/run-selection.sh >/dev/null
guest "rm -rf \$HOME/selection-run.started \$HOME/selection-run.exit \$HOME/selection-run.log"
guest "mkdir \$HOME/selection-run.started; nohup bash -c 'bash \$HOME/run-selection.sh > \$HOME/selection-run.log 2>&1; echo \$? > \$HOME/selection-run.exit' >/dev/null 2>&1 &"
DIALOGS=0
SEEN=0
for poll in $(seq 1 360); do
    if guest "[ -e \$HOME/selection-run.exit ]" >/dev/null 2>&1; then break; fi
    # The screen, as a user would see it. A refusal dialog names "Not Opened" or "could not verify"; any other dialog
    # from the security agent is reported too, because a dialog the loader was meant to prevent is the finding.
    tree="$(testanyware agent snapshot --mode full --depth 20 --json 2>/dev/null |
        jq -r '[.windows[] | .elements[]? | .. | objects | select(.platformRole == "AXStaticText") | .value // empty] | join("\n")' 2>/dev/null || true)"
    if grep -qE 'Not Opened|could not verify|cannot be opened|malicious software' <<<"${tree}"; then
        DIALOGS=$((DIALOGS + 1))
        echo "SYSTEM DIALOG on screen (poll ${poll}):"
        grep -E 'Not Opened|could not verify|cannot be opened|malicious software' <<<"${tree}" | sed 's/^/  /'
        testanyware screen capture -o "${LOG%.log}-dialog-${DIALOGS}.png" >/dev/null 2>&1 || true
    fi
    if [ $((poll % 6)) = 0 ]; then
        SEEN=$((SEEN + 1))
        echo "-- $(guest "grep -cE '^  (ok|FAIL)' \$HOME/selection-run.log" 2>/dev/null | tail -1) host runs so far; last: $(guest "tail -n 1 \$HOME/selection-run.log" 2>/dev/null | tail -1 | cut -c1-160)"
    fi
    sleep 10
done
guest "[ -e \$HOME/selection-run.exit ]" >/dev/null 2>&1 || fail "the driver did not finish within an hour"
guest "cat \$HOME/selection-run.log" > "${LOG%.log}-driver.log"
tail -n 40 "${LOG%.log}-driver.log"
DRIVER_EXIT="$(guest "cat \$HOME/selection-run.exit" | tr -d '[:space:]')"
mkdir -p "${VM_OUT}/results"
RESULTS="${VM_OUT}/results/selection-vm-$(date +%Y%m%dT%H%M%S)"
guest "cat ${TREE}/vm/results.json" > "${RESULTS}.json" || true
cp "${LOG%.log}-driver.log" "${RESULTS}.log"
testanyware screen capture -o "${LOG%.log}-end.png" >/dev/null 2>&1 || true
echo "Results: ${RESULTS}.json; driver transcript ${RESULTS}.log"
echo "System dialogs seen on screen during the run: ${DIALOGS}"
[ "${DIALOGS}" = 0 ] || fail "a system dialog appeared during the run"
assert_no_system_refusal "after the run"
[ "${DRIVER_EXIT}" = 0 ] || fail "the driver exited ${DRIVER_EXIT}; see ${RESULTS}.log"

step "PASSED — transcript in ${LOG}"
