#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM, that a client
# written from the documented contract alone drives the launch path:
# clients/contract-only, regenerated from the introspection response the signed
# build serves (core + desktop + workspace), obtains its grants through the
# client-requested workflow, introspects the schema it was generated against, and
# launches one real required launcher application (Notes, which ships with macOS)
# through workspaceLaunchApplication while it is stopped and reactivates it while it
# runs, each time with another application (TextEdit) frontmost and Koine inactive.
# Activation is never inferred from the client's answer: Fixtures/LaunchWitness, an
# independent signed tool that holds no Koine code, reads the system's own account
# of who is in front, which instances run, and the kernel's start instant of each.
#
# The client's author had the published contract documents and no access to this
# repository (scripts/vm-verify-contract-client-lib.sh), so every outcome below is
# one it must tell apart from what the documents say alone:
#   * a dependency that is unavailable: an application that is not installed, a typed
#     result and no launch;
#   * a capability denial, with the first unmet capability and the complete required
#     set, for a grant holding either control alone;
#   * a launch that failed: an application that is installed but cannot be opened,
#     attempted once and never replayed;
#   * an absent process: the launched process's identity, handed unchanged to
#     desktopApplication(process:), resolves while it runs and is ordinary null once
#     it has exited.
#
# The procedure and its recorded evidence: docs/verification/launch-contract.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="launch-contract-client-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-verify-contract-client-lib.sh
source scripts/vm-verify-contract-client-lib.sh

BUNDLE="clients/contract-only/dist/koine-client.mjs"
[ -f "${BUNDLE}" ] || { echo "Error: ${BUNDLE} does not exist. Run: task client" >&2; exit 1; }

APPLICATION="Notes"
APPLICATION_ID="com.apple.Notes"
APPLICATION_PATH="/System/Applications/Notes.app"
OTHER="TextEdit"
MISSING_ID="dev.koine.test.NotInstalled"
BROKEN_ID="dev.koine.test.BrokenLaunch"
# shellcheck disable=SC2016  # guest-side $HOME
{
    WATCH='$HOME/watch.jsonl'
    BOTH='$HOME/koine-secret-both'
    WORKSPACE_ONLY='$HOME/koine-secret-workspace'
    DESKTOP_ONLY='$HOME/koine-secret-desktop'
    # READER is desktop:read alone: the read that resolves the receipt's process.
}
# shellcheck source=scripts/vm-verify-launch-lib.sh
source scripts/vm-verify-launch-lib.sh

NODE_ARCHIVE="$(scripts/stage-node-runtime.sh)"
WITNESS_BIN="$(Fixtures/LaunchWitness/build.sh .build/witness)"

# launch_application <credential file> [bundle identifier] [client options...]: one launch,
# never repeated. The client's answer is left in ANSWER.
launch_application() {
    local credential="$1" id="${2:-${APPLICATION_ID}}"
    shift $(($# > 1 ? 2 : 1))
    contract_client_once "launch --secret \"${credential}\" --bundle-identifier ${id} $*"
}

# nothing_moved <what> <expectation jq> <credential> <bundle identifier>: a launch that
# must launch nothing. The witness reports no application launched or activated since
# the request, the front application is the one that was in front, and ${APPLICATION}
# runs as it did before.
nothing_moved() {
    local what="$1" condition="$2" credential="$3" id="$4" front_before instances_before
    witness_front >/dev/null
    front_before="$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")"
    instances "${APPLICATION_ID}" >/dev/null
    instances_before="$(jq -c '[.instances[] | [.pid, .startedAt]]' <<<"${INSTANCES}")"
    watch_start
    launch_application "${credential}" "${id}"
    expect "${condition}" "${what}: the client did not report it as expected"
    sleep 5
    watch_read
    watch_stop
    jq -e -s '[.[] | select(.event == "launched" or .event == "activated")] | length == 0' >/dev/null <<<"${EVENTS}" ||
        fail "${what}: the system reported an application launched or activated"
    witness_front >/dev/null
    [ "$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")" = "${front_before}" ] || fail "${what}: focus moved"
    instances "${APPLICATION_ID}" >/dev/null
    [ "$(jq -c '[.instances[] | [.pid, .startedAt]]' <<<"${INSTANCES}")" = "${instances_before}" ] || fail "${what}: ${APPLICATION} was launched or replaced"
    echo "Observation: ${what}: nothing launched, activated or moved."
}

# expect_launched: the client reports an acknowledged launch with a process; PROCESS is
# left as {pid, startedAt}, exactly as the client printed it.
expect_launched() {
    expect '.classification == "ok" and .http.status == 200 and .status == "AVAILABLE" and .dependency == null and (.process.pid > 0) and (.process.startedAt | length > 0)' \
        "the client did not report an acknowledged launch with a process"
    PROCESS="$(jq -c '.process | {pid, startedAt}' <<<"${ANSWER}")"
}

LAUNCHES=""
timing() {
    local sent received callback activated
    sent="$(jq -r .sentMs <<<"${ANSWER}")"
    received="$(jq -r .receivedMs <<<"${ANSWER}")"
    callback=$((received - sent))
    activated=$((ACTIVATED_MS - sent))
    echo "Timing (${1}): the client's answer ${callback} ms after it sent the request; the witness saw ${APPLICATION} activated ${activated} ms after it."
    LAUNCHES="${LAUNCHES}${1}: answer ${callback} ms, activation ${activated} ms
"
}

start_vm
install_app
step "Carry the client, the Node runtime it needs and the witness into the guest"
testanyware file upload "${NODE_ARCHIVE}" /Users/admin/node.tar.xz >/dev/null
testanyware file upload "${BUNDLE}" /Users/admin/koine-client.mjs >/dev/null
testanyware file upload scripts/vm-verify-contract-client-trim.py /Users/admin/trim.py >/dev/null
testanyware file upload "${WITNESS_BIN}" /Users/admin/LaunchWitness >/dev/null
# shellcheck disable=SC2016  # guest-side $HOME
guest 'cd $HOME && rm -rf node && tar -xJf node.tar.xz && mv node-*-darwin-arm64 node && chmod +x $HOME/LaunchWitness && echo launch > $HOME/launch-target.txt && ./node/bin/node --version'

step "An application that is installed but cannot be opened: a bundle whose executable is a truncated Mach-O, registered with Launch Services"
# A bundle with no executable at all is not registered, so it is an application that is not
# installed; one whose executable is cut short is registered and fails to open (-10810).
mkdir -p "${WORK}/BrokenLaunch.app/Contents/MacOS"
head -c 8192 /usr/bin/true >"${WORK}/BrokenLaunch.app/Contents/MacOS/BrokenLaunch"
chmod 755 "${WORK}/BrokenLaunch.app/Contents/MacOS/BrokenLaunch"
cat >"${WORK}/BrokenLaunch.app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>${BROKEN_ID}</string>
  <key>CFBundleName</key><string>BrokenLaunch</string>
  <key>CFBundleExecutable</key><string>BrokenLaunch</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
</dict></plist>
PLIST
ditto -c -k --keepParent "${WORK}/BrokenLaunch.app" "${WORK}/BrokenLaunch.zip"
testanyware file upload "${WORK}/BrokenLaunch.zip" /Users/admin/BrokenLaunch.zip >/dev/null
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister
# shellcheck disable=SC2016  # guest-side $HOME
guest "mkdir -p \$HOME/Applications && cd \$HOME/Applications && rm -rf BrokenLaunch.app && ditto -x -k \$HOME/BrokenLaunch.zip \$HOME/Applications && ${LSREGISTER} -f \$HOME/Applications/BrokenLaunch.app && ls -l \$HOME/Applications/BrokenLaunch.app/Contents/MacOS"
echo "Registered: ${BROKEN_ID}, whose executable is 8192 bytes of a Mach-O and nothing more."

step "With no Koine running, the client says the service is unavailable"
contract_client "probe"
expect '.classification == "service-unavailable"' "the client did not report an absent service as unavailable"

step "Launch Koine; the client finds the endpoint from the descriptor alone"
launch
contract_client "probe"
expect '.classification == "ok" and .descriptor.present == true and .descriptor.contractVersion == "koine-desktop/1"' \
    "the client did not read the endpoint descriptor"

step "The client enrols four grants itself, and the user approves each in the window"
enrol "${BOTH}" launch-client-both workspace:control desktop:control
expect '.grant.capabilities == ["desktop:control","workspace:control"] or .grant.capabilities == ["workspace:control","desktop:control"]' \
    "the grant is not exactly both controls"
enrol "${WORKSPACE_ONLY}" launch-client-workspace workspace:control
expect '.grant.capabilities == ["workspace:control"]' "the grant is not workspace:control alone"
enrol "${DESKTOP_ONLY}" launch-client-desktop desktop:control
expect '.grant.capabilities == ["desktop:control"]' "the grant is not desktop:control alone"
enrol "${READER}" launch-client-reader desktop:read
expect '.grant.capabilities == ["desktop:read"]' "the grant is not desktop:read alone"

step "InspectOwnConnection and introspection: the schema served is the one the client was generated against"
contract_client "inspect --secret \"${BOTH}\""
expect '.classification == "ok" and .koine.contractVersion == "koine-desktop/1" and .koine.ownGrant.state == "ACTIVE"' \
    "InspectOwnConnection did not answer for the launch grant"
SERVED_DIGEST="$(jq -r .koine.schemaDigest <<<"${ANSWER}")"
# shellcheck disable=SC2016  # guest-side $HOME
contract_client_trimmed "introspect --secret \"${READER}\" --out \$HOME/introspection.json"
expect '.classification == "ok" and (.errors | length) == 0 and .schemaDigestsEqual == true' \
    "the served schema is not the one this client was generated against"
echo "Digest generated against: $(jq -r .generatedAgainstSchemaDigest <<<"${ANSWER}")"
echo "Digest served now:        $(jq -r .servedSchemaDigest <<<"${ANSWER}")"
[ "$(jq -r .servedSchemaDigest <<<"${ANSWER}")" = "${SERVED_DIGEST}" ] || fail "the digest the introspection reports is not the one Koine served this session"
testanyware file download /Users/admin/introspection.json "${WORK}/introspection.json" >/dev/null
mkdir -p .build/launch-contract-client
cp "${WORK}/introspection.json" .build/launch-contract-client/introspection.json
echo "The client's own introspection response brought back: $(wc -c <"${WORK}/introspection.json") bytes"
printf '%s' "${SERVED_DIGEST}" >.build/launch-contract-client/digest

prepare_application

step "A dependency that is unavailable: the application is not installed. A typed result, and nothing launches"
put_other_in_front
nothing_moved "an application that is not installed" \
    '.classification == "dependency-unavailable" and .status == "DEPENDENCY_UNAVAILABLE" and .dependency.reason == "APPLICATION_NOT_INSTALLED" and (.dependency.guidance | length > 0) and .process == null' \
    "${BOTH}" "${MISSING_ID}"
echo "Dependency: $(jq -c '.dependency' <<<"${ANSWER}")"

step "A capability denial, with its complete required set: either control alone, and nothing launches"
put_other_in_front
nothing_moved "workspace:control alone" \
    '.classification == "capability-denied" and .http.status == 403 and .requiredCapability == "desktop:control" and .requiredCapabilities == ["workspace:control","desktop:control"]' \
    "${WORKSPACE_ONLY}" "${APPLICATION_ID}"
echo "Denied: first unmet $(jq -r .requiredCapability <<<"${ANSWER}"), complete set $(jq -c .requiredCapabilities <<<"${ANSWER}")"
nothing_moved "desktop:control alone" \
    '.classification == "capability-denied" and .http.status == 403 and .requiredCapability == "workspace:control" and .requiredCapabilities == ["workspace:control","desktop:control"]' \
    "${DESKTOP_ONLY}" "${APPLICATION_ID}"
echo "Denied: first unmet $(jq -r .requiredCapability <<<"${ANSWER}"), complete set $(jq -c .requiredCapabilities <<<"${ANSWER}")"

step "A launch that failed: the application is installed but cannot be opened, so the attempt fails and is not replayed"
put_other_in_front
CALLS_BEFORE="${ONCE_CALLS}"
nothing_moved "an installed application that cannot be opened" \
    '.classification == "failed" and .http.status == 200 and .actionEffect == "may-have-begun" and .process == null' \
    "${BOTH}" "${BROKEN_ID}"
[ "${ONCE_CALLS}" = $((CALLS_BEFORE + 1)) ] || fail "the failed launch was sent more than once"
echo "Failed: $(jq -c '.errors' <<<"${ANSWER}")"

step "Cold launch under both controls and no read capability, with ${OTHER} in front"
put_other_in_front
watch_start
launch_application "${BOTH}"
expect_launched
COLD_PROCESS="${PROCESS}"
COLD_SENT="$(jq -r .sentMs <<<"${ANSWER}")"
activation_of "${APPLICATION_ID}" "${COLD_SENT}"
timing "cold launch"
expect_front "${APPLICATION_ID}" ".application.pid == $(jq -r .pid <<<"${COLD_PROCESS}")"
watch_stop
expect_instances "${APPLICATION_ID}" 1
KERNEL="$(jq -c '.instances[0] | {pid, startedAt}' <<<"${INSTANCES}")"
echo "Receipt, as the client printed it: ${COLD_PROCESS}; the kernel's, read by the witness: ${KERNEL}"
[ "${COLD_PROCESS}" = "${KERNEL}" ] || fail "the receipt's process is not the kernel's identity for the launched application"

step "The receipt's process is handed to a desktop read unchanged"
contract_client "choices --secret \"${READER}\" --pid $(jq -r .pid <<<"${COLD_PROCESS}") --started-at $(jq -r .startedAt <<<"${COLD_PROCESS}")"
# Accessibility is absent: the application resolves, and the window list is an
# os-permission refusal the client tells apart from absence.
expect '.classification == "os-permission-denied" and .desktopApplication == null' \
    "with Accessibility absent the handoff was not an os-permission refusal"
expect '(.response.errors | length == 1) and (.response.errors[0] | .path == ["desktopApplication","windows"] and .extensions.permissionClass == "os-permission" and .extensions.osPermission == "accessibility")' \
    "the refusal is not an os-permission error at the window list"
echo "Observation: the process identity was accepted; only the window list was refused, for Koine's missing Accessibility consent."
step "Give Koine Accessibility consent, then the same process, unchanged, resolves with its windows"
grant_accessibility
contract_client "choices --secret \"${READER}\" --pid $(jq -r .pid <<<"${COLD_PROCESS}") --started-at $(jq -r .startedAt <<<"${COLD_PROCESS}")"
expect '.classification == "ok" and .desktopApplication.name == "Notes" and (.windows | length >= 1)' \
    "the receipt's process did not resolve to the launched application and its windows"
echo "Observation: $(jq -c '{name: .desktopApplication.name, windows: (.windows | length)}' <<<"${ANSWER}")"

step "Reactivation while running, with ${OTHER} in front and Koine inactive: the running copy is reused"
put_other_in_front
watch_start
launch_application "${BOTH}"
expect_launched
[ "${PROCESS}" = "${COLD_PROCESS}" ] || fail "the reactivation returned another process: ${PROCESS} against ${COLD_PROCESS}"
SENT="$(jq -r .sentMs <<<"${ANSWER}")"
activation_of "${APPLICATION_ID}" "${SENT}"
timing "reactivation"
expect_front "${APPLICATION_ID}" ".application.pid == $(jq -r .pid <<<"${COLD_PROCESS}")"
watch_read
watch_stop
expect_instances "${APPLICATION_ID}" 1
jq -e -s '[.[] | select(.event == "launched")] | length == 0' >/dev/null <<<"${EVENTS}" || fail "the reactivation launched an application"
echo "Observation: the same process ${COLD_PROCESS} is the only instance, and no application launched."

step "An absent process: after the application exits, the same identity is ordinary null, told apart from denial and from a failure"
guest "killall ${APPLICATION}" || true
sleep 3
expect_instances "${APPLICATION_ID}" 0
contract_client "choices --secret \"${READER}\" --pid $(jq -r .pid <<<"${COLD_PROCESS}") --started-at $(jq -r .startedAt <<<"${COLD_PROCESS}")"
expect '.classification == "absent" and .absence == "server-null" and .response.data.desktopApplication == null and ((.response.errors // []) | length) == 0' \
    "an exited process was not ordinary null"

step "Measured timings"
printf '%s' "${LAUNCHES}"

step "After Quit, the client says the service is unavailable again"
quit_koine
contract_client "probe"
expect '.classification == "service-unavailable"' "the client did not report the stopped service as unavailable"

step "PASSED — transcript in ${LOG}"
