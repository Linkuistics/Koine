#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM with one real
# required launcher application (Notes, which ships with macOS), that
# workspaceLaunchApplication under workspace:control AND desktop:control launches
# it while it is stopped and reactivates it while it runs, each time with another
# application (TextEdit) frontmost and Koine inactive. Activation is never inferred
# from the acknowledgment: Fixtures/LaunchWitness, an independent signed tool that
# holds no Koine code and needs no Accessibility, reads the system's own account of
# who is in front, which instances run, the kernel's start instant of each and when
# a process exits. Covered: first run and Gatekeeper approval of the application;
# cold launch and reactivation with callback and activation timing; no second
# instance; the returned process identity against the kernel's and accepted
# unchanged by desktopApplication(process:) under desktop:read; the process's real
# exit; either control alone, and a revoked grant, launching nothing and moving no
# focus (application stopped, and running); Accessibility absent, then given, then
# revoked, with launch working and no consent dialog throughout; and the client's
# optional recovery, a desktop read plus an explicit focus under their own grants.
# The launch call path's native calls are inspected first
# (scripts/check-launch-call-path.sh). Nothing here runs the application on the
# host. The procedure and its recorded evidence: docs/verification/launch-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="launch-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

APPLICATION="Notes"
APPLICATION_ID="com.apple.Notes"
APPLICATION_PATH="/System/Applications/Notes.app"
OTHER="TextEdit"
WORKSPACE_OPERATIONS='$HOME/workspace-operations.graphql'
# shellcheck disable=SC2016  # guest-side $HOME
{
    BOTH_FILE='$HOME/koine-credential-both'
    WORKSPACE_ONLY_FILE='$HOME/koine-credential-workspace'
    DESKTOP_ONLY_FILE='$HOME/koine-credential-desktop'
    REVOKED_FILE='$HOME/koine-credential-revoked'
    WATCH='$HOME/watch.jsonl'
}
# The desktop-only grant is also the client's explicit-focus grant (desktop:control
# alone), and the reader's is also the manager's.
MANAGER_FILE="${CREDENTIAL_FILE}"
CONTROLLER_FILE="${DESKTOP_ONLY_FILE}"

step "The launch call path's native calls, inspected against the authority trace"
scripts/check-launch-call-path.sh

WITNESS_BIN="$(Fixtures/LaunchWitness/build.sh .build/witness)"
PROBE="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"

# --- the guest client, one shot -------------------------------------------------
# A launch is not safe to repeat: a second one is a reactivation. `guest` retries
# the agent's false "timed out" answer, which is right for a read and wrong here,
# so a launch request runs ONCE through the agent, writes its answer to a file of
# its own, and the file is read back (a read is safe to repeat). Only "the agent
# was not reached at all" (status 7) is run again, since then nothing ran.
CALLS=0
# call <credential file> <client arguments...>: the client's one JSON line in ANSWER.
call() {
    local credential="$1" file status operations="${WORKSPACE_OPERATIONS}"
    shift
    # A management call names no operations file.
    if [ "$1" = - ]; then
        operations=-
        shift
    fi
    CALLS=$((CALLS + 1))
    file="\$HOME/launch-answer-${CALLS}.json"
    for _ in 1 2 3; do
        status=0
        testanyware file exec "python3 \$HOME/vm-verify-launch-client.py \"${credential}\" \"${operations}\" $* > ${file}" >/dev/null 2>&1 || status=$?
        [ "${status}" != 7 ] || {
            sleep 5
            continue
        }
        break
    done
    ANSWER="$(guest_json "cat ${file}")" || fail "the client left no answer for: $*"
    echo "${ANSWER}"
}
# launch <credential file> [bundle identifier]
launch_application() { call "$1" launch "${2:-${APPLICATION_ID}}"; }

# --- the witness ------------------------------------------------------------------
witness_front() {
    sleep 1
    FRONT="$(guest_json "\$HOME/LaunchWitness frontmost")"
    echo "${FRONT}"
}
# expect_front <bundle identifier> [jq condition on the witness]: the system says
# this application is in front, and the window server's front window agrees.
expect_front() {
    witness_front
    jq -e ".application.bundleIdentifier == \"$1\" and (.frontCGWindow.pid == .application.pid) and (${2:-true})" >/dev/null <<<"${FRONT}" ||
        fail "the system does not show $1 in front${2:+ with: $2}"
}
instances() {
    INSTANCES="$(guest_json "\$HOME/LaunchWitness instances $1")"
    echo "${INSTANCES}"
}
# expect_instances <bundle identifier> <count>
expect_instances() {
    instances "$1"
    jq -e ".instances | length == $2" >/dev/null <<<"${INSTANCES}" || fail "$1 does not run as $2 instance(s)"
}
# Another application in front and Koine inactive: the precondition of every case.
put_other_in_front() {
    guest "open -a ${OTHER} \$HOME/launch-target.txt" || true
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
# The watch and exit bounds are generous on purpose: the agent's false timeouts
# stretched the time between starting a witness and sending a request past two
# minutes, and a witness that had already ended was taken for no activation.
# The witness's account of every launch, activation and termination, on the
# guest's clock, from before a request until it is stopped.
watch_start() {
    guest "rm -f ${WATCH}; (nohup \$HOME/LaunchWitness watch 1200 > ${WATCH} 2>&1 &)" || true
    local tries=0
    until [ -n "$(guest "cat ${WATCH}" 2>/dev/null || true)" ]; do
        tries=$((tries + 1))
        [ "${tries}" -lt 10 ] || fail "the witness did not start watching"
        sleep 1
    done
}
# guest_text <command>: for a read whose output the caller parses. The agent's
# false "timed out" report (scripts/vm-verify-lib.sh, guest) can follow a complete
# answer, and after twelve tries `guest` gives up with the answer in hand: keep the
# answer, drop the report, and let the caller's parsing prove it whole.
guest_text() {
    local out
    out="$(guest "$1" 2>&1)" || true
    grep -v -e '^Process timed out after' -e '^guest exec kept timing out' -e '^\[Process timed out' <<<"${out}" || true
}
watch_read() { EVENTS="$(guest_text "cat ${WATCH}")"; }
watch_stop() { guest "pkill -f 'LaunchWitness watch'" || true; }
# activation_of <bundle identifier> <after ms>: the witness saw this application
# activated after the request was sent; leaves the time in ACTIVATED_MS.
activation_of() {
    local tries=0
    while true; do
        watch_read
        ACTIVATED_MS="$(jq -rs "[.[] | select(.event == \"activated\" and .application.bundleIdentifier == \"$1\" and .atMs >= $2) | .atMs] | first // empty" <<<"${EVENTS}")"
        [ -z "${ACTIVATED_MS}" ] || return 0
        tries=$((tries + 1))
        [ "${tries}" -lt 10 ] || fail "the witness never saw $1 activated: acknowledgment without activation fails the case"
        sleep 2
    done
}
LAUNCHES=""
# timing <label>: the request's callback latency and the activation, on one clock.
timing() {
    local sent received callback activated
    sent="$(jq -r .sentMs <<<"${ANSWER}")"
    received="$(jq -r .receivedMs <<<"${ANSWER}")"
    callback=$((received - sent))
    activated=$((ACTIVATED_MS - sent))
    echo "Timing (${1}): answer ${callback} ms after the request was sent; the witness saw ${APPLICATION} activated ${activated} ms after it."
    LAUNCHES="${LAUNCHES}${1}: answer ${callback} ms, activation ${activated} ms
"
}
# expect_launched: the receipt is AVAILABLE with a process; PROCESS is left as {pid, startedAt}.
expect_launched() {
    expect '(.httpStatus == 200) and ((.response.errors // []) | length == 0) and (.response.data.workspaceLaunchApplication | .status == "AVAILABLE" and .dependency == null and .value.process.pid != null and .value.process.startedAt != null)' \
        "the launch did not return an AVAILABLE receipt with a process"
    PROCESS="$(jq -c '.response.data.workspaceLaunchApplication.value.process' <<<"${ANSWER}")"
}
# denied <what>: the launch was refused and nothing moved. Needs the state before it.
denied() {
    local what="$1" front_before instances_before
    witness_front >/dev/null
    front_before="$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")"
    instances "${APPLICATION_ID}" >/dev/null
    instances_before="$(jq -c '[.instances[] | [.pid, .startedAt]]' <<<"${INSTANCES}")"
    watch_start
    launch_application "$2"
    sleep 5
    watch_read
    watch_stop
    if [ -n "${3:-}" ]; then expect "$3" "${what}: not refused as expected"; fi
    jq -e -s '[.[] | select(.event == "launched" or .event == "activated")] | length == 0' >/dev/null <<<"${EVENTS}" ||
        fail "${what}: the system reported an application launched or activated"
    witness_front >/dev/null
    [ "$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")" = "${front_before}" ] || fail "${what}: focus moved"
    instances "${APPLICATION_ID}" >/dev/null
    [ "$(jq -c '[.instances[] | [.pid, .startedAt]]' <<<"${INSTANCES}")" = "${instances_before}" ] || fail "${what}: ${APPLICATION} was launched or replaced"
    echo "Observation: ${what}: nothing launched, activated or moved."
}
PERMISSION_DENIED='(.httpStatus == 403) and (.response.data.workspaceLaunchApplication == null) and (.response.errors | length >= 1) and (.response.errors[0] | .path == ["workspaceLaunchApplication"] and .extensions.kind == "permission" and .extensions.permissionClass == "capability")'
permission() {
    ask_manager '{ koineManagement { osPermissions { permission owner granted } } }'
}
# ask_manager <query>: a read under the manager grant, safe to repeat.
ask_manager() {
    local out
    for _ in 1 2 3 4 5; do
        out="$(guest "bash \$HOME/vm-verify-client.sh \"${MANAGER_FILE}\" '$1'" 2>&1 || true)"
        if grep -qx "HTTP 200" <<<"${out}"; then
            MANAGED="$(grep -m1 '^{' <<<"${out}")"
            echo "${MANAGED}"
            return 0
        fi
        sleep 2
    done
    fail "expected HTTP 200 for: $1"
}
# accessibility_is <true|false>: Koine's own account of the consent, until it says so.
accessibility_is() {
    local since
    since="$(date +%s)"
    until permission >/dev/null && jq -e ".data.koineManagement.osPermissions[0].granted == $1" >/dev/null <<<"${MANAGED}"; do
        [ $(($(date +%s) - since)) -lt 60 ] || fail "osPermissions did not report granted: $1 within 60s"
        sleep 2
    done
    echo "Observation: osPermissions reports accessibility granted: $1."
}
# capture_plain <credential file> <process JSON>: without the windows field.
capture_plain() {
    call "$1" capture-plain "$(jq -r .pid <<<"$2")" "$(jq -r .startedAt <<<"$2")"
}
# capture <credential file> <process JSON>: the receipt's process, unchanged, to desktopApplication(process:).
capture() {
    call "$1" capture "$(jq -r .pid <<<"$2")" "$(jq -r .startedAt <<<"$2")"
}

start_vm
install_app
testanyware file upload scripts/vm-verify-desktop-client.py /Users/admin/vm-verify-desktop-client.py >/dev/null
testanyware file upload scripts/vm-verify-launch-client.py /Users/admin/vm-verify-launch-client.py >/dev/null
testanyware file upload docs/design/desktop-operations.graphql /Users/admin/desktop-operations.graphql >/dev/null
testanyware file upload docs/design/workspace-operations.graphql /Users/admin/workspace-operations.graphql >/dev/null
testanyware file upload "${WITNESS_BIN}" /Users/admin/LaunchWitness >/dev/null
testanyware file upload "${PROBE}" /Users/admin/WindowIdentityProbe >/dev/null
# shellcheck disable=SC2016  # guest-side $HOME
guest 'chmod +x $HOME/LaunchWitness $HOME/WindowIdentityProbe; echo launch > $HOME/launch-target.txt'

step "Launch Koine and create the grants"
launch
# The window's grant form scrolls out of reach once several grants are listed, so
# the first grant, a reader and manager, is made in the window and the rest by it,
# through koineCreateGrant, as the window's own client makes them.
create_grant "vm-launch-reader-manager" "${CREDENTIAL_FILE}" koine:manage desktop:read
# grant <label> <credential file> <capability>...: the manager makes a grant.
grant() {
    local label="$1" file="$2"
    shift 2
    call "${CREDENTIAL_FILE}" - grant "${label}" "${file}" "$@"
    expect '((.response.errors // []) | length == 0) and (.response.data.koineCreateGrant.grant.state == "ACTIVE")' "the grant ${label} was not created"
    GRANT_ID="$(jq -r '.response.data.koineCreateGrant.grant.grantId' <<<"${ANSWER}")"
}
ask_status() { RESPONSE="$(guest "bash \$HOME/vm-verify-client.sh \"$1\"" 2>&1 || true)"; echo "${RESPONSE}"; }
grant "vm-launch-revoked" "${REVOKED_FILE}" workspace:control desktop:control
ask_status "${REVOKED_FILE}"
grep -qx "HTTP 200" <<<"${RESPONSE}" || fail "the grant to be revoked is not accepted before it is revoked"
call "${CREDENTIAL_FILE}" - revoke "${GRANT_ID}"
expect '.response.data.koineRevokeGrant.state == "REVOKED"' "the grant was not revoked"
ask_status "${REVOKED_FILE}"
grep -qx "HTTP 401" <<<"${RESPONSE}" || fail "the revoked grant is still accepted"
grant "vm-launch-both" "${BOTH_FILE}" workspace:control desktop:control
grant "vm-launch-workspace-only" "${WORKSPACE_ONLY_FILE}" workspace:control
grant "vm-launch-desktop-only" "${DESKTOP_ONLY_FILE}" desktop:control

step "Accessibility consent is absent"
accessibility_is false

step "${APPLICATION}: first run and Gatekeeper approval, completed in the VM"
echo "Before: $(guest 'spctl --status --verbose' 2>&1 | tr '\n' '; ')"
guest "echo ${VM_PASSWORD} | sudo -S spctl --global-enable" || true
GATEKEEPER="$(guest 'spctl --status --verbose' 2>&1)"
echo "After:  $(tr '\n' '; ' <<<"${GATEKEEPER}")"
grep -qx 'assessments enabled' <<<"${GATEKEEPER}" || fail "assessments are still disabled; there is no Gatekeeper approval to record"
ASSESSMENT="$(guest "spctl -a -vv ${APPLICATION_PATH} 2>&1")"
echo "${ASSESSMENT}"
grep -q 'accepted' <<<"${ASSESSMENT}" && grep -q 'source=Apple System' <<<"${ASSESSMENT}" && ! grep -q 'override=' <<<"${ASSESSMENT}" ||
    fail "Gatekeeper does not accept ${APPLICATION} as Apple System"
echo "Quarantine attribute: $(guest "xattr -p com.apple.quarantine ${APPLICATION_PATH} 2>&1 || true")"
guest "codesign --display --verbose=2 ${APPLICATION_PATH} 2>&1 | grep -E '^(Identifier|Authority|TeamIdentifier|Format)'" || true
echo "Application: $(guest "/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' ${APPLICATION_PATH}/Contents/Info.plist") version $(guest "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' ${APPLICATION_PATH}/Contents/Info.plist") (build $(guest "/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' ${APPLICATION_PATH}/Contents/Info.plist")) at ${APPLICATION_PATH}; macOS $(guest 'sw_vers -productVersion')."
guest "open -a ${APPLICATION}" || true
SNAPSHOT_WINDOW="${APPLICATION}"
tries=0
until element '.role=="button" and .label=="Continue"' 2>/dev/null | grep -q '^{'; do
    tries=$((tries + 1))
    [ "${tries}" -lt 15 ] || fail "${APPLICATION}'s welcome sheet did not appear"
    sleep 2
done
testanyware screen capture -o "${LOG%.log}-first-run.png" >/dev/null
click '.role=="button" and .label=="Continue"'
sleep 3
unset SNAPSHOT_WINDOW
testanyware agent windows --json | jq -e "[.windows[] | select(.appName == \"${APPLICATION}\" and (.title | startswith(\"${APPLICATION}\")))] | length >= 1" >/dev/null ||
    fail "${APPLICATION} shows no window after its first run"
guest "killall ${APPLICATION}" || true
sleep 3
expect_instances "${APPLICATION_ID}" 0

step "Grant and revocation refusals with ${APPLICATION} stopped: nothing launches and no focus moves"
put_other_in_front
denied "the revoked grant" "${REVOKED_FILE}" '.httpStatus == 401'
denied "workspace:control alone" "${WORKSPACE_ONLY_FILE}" "${PERMISSION_DENIED}"
echo "Refusal: $(jq -c '.response.errors[0] | {message, path, extensions}' <<<"${ANSWER}")"
denied "desktop:control alone" "${DESKTOP_ONLY_FILE}" "${PERMISSION_DENIED}"
echo "Refusal: $(jq -c '.response.errors[0] | {message, path, extensions}' <<<"${ANSWER}")"
denied "desktop:read alone" "${CREDENTIAL_FILE}" "${PERMISSION_DENIED}"

step "Cold launch under both controls and no read capability, with ${OTHER} in front"
put_other_in_front
watch_start
launch_application "${BOTH_FILE}"
expect_launched
COLD_PROCESS="${PROCESS}"
COLD_SENT="$(jq -r .sentMs <<<"${ANSWER}")"
activation_of "${APPLICATION_ID}" "${COLD_SENT}"
timing "cold launch"
expect_front "${APPLICATION_ID}" ".application.pid == $(jq -r .pid <<<"${COLD_PROCESS}")"
watch_read
echo "Witness events: $(jq -c -s '[.[] | select(.event == "launched" or .event == "activated") | {event, atMs, name: .application.name}]' <<<"${EVENTS}")"
watch_stop
expect_instances "${APPLICATION_ID}" 1

step "The receipt's process identity is the kernel's, and desktopApplication(process:) accepts it unchanged"
KERNEL="$(jq -c '.instances[0] | {pid, startedAt}' <<<"${INSTANCES}")"
echo "Receipt: ${COLD_PROCESS}; kernel, read by the witness: ${KERNEL}"
[ "${COLD_PROCESS}" = "${KERNEL}" ] || fail "the receipt's process is not the kernel's identity for the launched application"
capture "${BOTH_FILE}" "${COLD_PROCESS}"
expect '(.response.data.desktopApplication == null) and (.response.errors | length >= 1) and (.response.errors[0].extensions.kind == "permission")' \
    "a grant with no read capability read the application"
# Accessibility is absent, so the designed capture's windows field cannot be read;
# the process itself is what desktopApplication(process:) accepts, and a call
# without windows shows that.
capture_plain "${CREDENTIAL_FILE}" "${COLD_PROCESS}"
expect '((.response.errors // []) | length == 0) and (.response.data.desktopApplication | .bundleIdentifier == "com.apple.Notes" and .name == "Notes" and .ref != null)' \
    "desktopApplication(process:) did not accept the receipt's process under desktop:read"
capture "${CREDENTIAL_FILE}" "${COLD_PROCESS}"
expect '(.response.errors | length == 1) and (.response.errors[0] | .path == ["desktopApplication", "windows"] and .extensions.permissionClass == "os-permission" and .extensions.osPermission == "accessibility")' \
    "the designed capture, with Accessibility absent, was not an os-permission error at windows alone"
echo "Observation: with Accessibility absent the process is accepted; only the windows field is refused, as an os-permission error naming accessibility."

step "Reactivation while running, with ${OTHER} in front and Koine inactive: the running copy is reused"
put_other_in_front
watch_start
launch_application "${BOTH_FILE}"
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
[ "$(jq -c '.instances[0] | {pid, startedAt}' <<<"${INSTANCES}")" = "${COLD_PROCESS}" ] || fail "the running copy was replaced"
echo "Observation: the same process ${COLD_PROCESS} is the only instance, and no application launched."

step "Refusals with ${APPLICATION} running in the background: nothing activates and no focus moves"
put_other_in_front
denied "the revoked grant" "${REVOKED_FILE}" '.httpStatus == 401'
denied "workspace:control alone" "${WORKSPACE_ONLY_FILE}" "${PERMISSION_DENIED}"
denied "desktop:control alone" "${DESKTOP_ONLY_FILE}" "${PERMISSION_DENIED}"

step "The process exits: the witness observes it, and the identity is no longer resolvable"
guest "rm -f \$HOME/exit.json; (nohup \$HOME/LaunchWitness exit $(jq -r .pid <<<"${COLD_PROCESS}") 900 > \$HOME/exit.json 2>&1 &)" || true
sleep 2
guest "killall ${APPLICATION}" || true
tries=0
until [ -n "$(guest 'cat $HOME/exit.json' 2>/dev/null || true)" ]; do
    tries=$((tries + 1))
    [ "${tries}" -lt 30 ] || fail "the witness saw no exit"
    sleep 2
done
EXIT="$(guest_json 'cat $HOME/exit.json')"
echo "${EXIT}"
jq -e '.exited == true' >/dev/null <<<"${EXIT}" || fail "the process did not exit"
expect_instances "${APPLICATION_ID}" 0
capture_plain "${CREDENTIAL_FILE}" "${COLD_PROCESS}"
# An identity that names no live process is a complete null, not an error.
expect '((.response.errors // []) | length == 0) and .response.data.desktopApplication == null' "the exited process is still resolvable"
echo "Observation: after the exit desktopApplication(process:) answers null, without an error, for the same identity."

step "Give Koine Accessibility consent; the optional recovery: a desktop read, then an explicit focus, each under its own grant"
grant_accessibility
accessibility_is true
put_other_in_front
launch_application "${BOTH_FILE}"
expect_launched
RECOVERY_PROCESS="${PROCESS}"
sleep 3
put_other_in_front
tries=0
while true; do
    capture "${CREDENTIAL_FILE}" "${RECOVERY_PROCESS}"
    WINDOW="$(jq -r '.response.data.desktopApplication.windows[0].ref // empty' <<<"${ANSWER}")"
    [ -z "${WINDOW}" ] || break
    tries=$((tries + 1))
    [ "${tries}" -lt 10 ] || fail "the launched application lists no window to focus"
    sleep 2
done
expect '.response.data.desktopApplication | .name == "Notes" and (.windows | length >= 1)' "the read did not list the launched application's window"
focus "${WINDOW}"
expect_receipt "${WINDOW}"
expect_front "${APPLICATION_ID}" ".application.pid == $(jq -r .pid <<<"${RECOVERY_PROCESS}")"
echo "Observation: the window ${WINDOW} was focused by the explicit desktopFocusWindow call, under desktop:control alone."
guest "killall ${APPLICATION}" || true
sleep 3

step "Consent revoked while Koine runs: launch still works and raises no consent prompt"
revoke_accessibility
accessibility_is false
guest "killall 'System Settings'" || true
put_other_in_front
watch_start
launch_application "${BOTH_FILE}"
expect_launched
SENT="$(jq -r .sentMs <<<"${ANSWER}")"
activation_of "${APPLICATION_ID}" "${SENT}"
timing "cold launch, consent revoked"
expect_front "${APPLICATION_ID}" ".application.pid == $(jq -r .pid <<<"${PROCESS}")"
no_consent_dialog "after a launch with consent revoked"
put_other_in_front
launch_application "${BOTH_FILE}"
expect_launched
SENT="$(jq -r .sentMs <<<"${ANSWER}")"
activation_of "${APPLICATION_ID}" "${SENT}"
timing "reactivation, consent revoked"
watch_stop
expect_front "${APPLICATION_ID}"
expect_instances "${APPLICATION_ID}" 1
no_consent_dialog "after a reactivation with consent revoked"
testanyware screen capture -o "${LOG%.log}-after-revocation.png" >/dev/null

step "Measured timings"
printf '%s' "${LAUNCHES}"

step "Quit Koine"
quit_koine

step "PASSED — transcript in ${LOG}"
