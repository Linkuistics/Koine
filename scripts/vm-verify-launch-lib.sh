# shellcheck shell=bash
# shellcheck disable=SC2016,SC2034  # guest-side $HOME; variables the sourcing script uses
# Sourced by the VM scripts that launch a real application in the guest and watch
# what the system did (vm-verify-launch.sh, vm-verify-launch-contract-client.sh),
# after vm-verify-lib.sh and vm-verify-desktop-lib.sh. The independent witness is
# Fixtures/LaunchWitness (docs/verification/launch-vm.md): it holds no Koine code
# and needs no Accessibility, and reports who is in front, which instances run, the
# kernel's start instant of each, and every launch, activation and termination on
# the guest's clock.
#
# The sourcing script sets, before calling anything here: APPLICATION (display
# name), APPLICATION_ID, APPLICATION_PATH, OTHER (the application put in front
# before each case), WATCH (the guest path of the watch log) and BUNDLE_ID (Koine's
# own, from signing-env.sh), and defines `launch_application`, which `denied` calls.
# The witness and the window probe are uploaded by the sourcing script.

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

# prepare_application: first run and Gatekeeper approval of ${APPLICATION}, completed
# in the VM, so that a launch in the cases that follow meets no onboarding sheet and
# no assessment dialog.
prepare_application() {
    step "${APPLICATION}: first run and Gatekeeper approval, completed in the VM"
    echo "Before: $(guest 'spctl --status --verbose' 2>&1 | tr '\n' '; ')"
    guest "echo ${VM_PASSWORD} | sudo -S spctl --global-enable" || true
    GATEKEEPER="$(guest 'spctl --status --verbose' 2>&1 || true)"
    echo "After:  $(tr '\n' '; ' <<<"${GATEKEEPER}")"
    grep -qx 'assessments enabled' <<<"${GATEKEEPER}" || fail "assessments are still disabled; there is no Gatekeeper approval to record"
    ASSESSMENT="$(guest "spctl -a -vv ${APPLICATION_PATH} 2>&1" || true)"
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

}
