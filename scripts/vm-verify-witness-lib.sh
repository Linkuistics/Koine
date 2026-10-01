# shellcheck shell=bash
# shellcheck disable=SC1112,SC2016,SC2034  # curly quotes in dialog labels; guest-side $HOME; variables the sourcing script uses
# Sourced by the VM acceptances that watch what the system does to real applications in a
# clone of the prepared launcher image (vm-verify-launchers.sh, vm-verify-open-url.sh),
# after scripts/vm-verify-lib.sh, vm-verify-desktop-lib.sh, vm-launchers-lib.sh and
# vm-verify-launch-lib.sh. The sourcing script sets WATCH (the witness's log in the guest)
# and RESULTS (a host file that `record` appends JSON lines to), and `fail`s through the
# shared library.

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

# judge_dialogs <when> <dialogs as system_dialogs printed them>: in the calling case (a
# function with `status` and `notes` locals), whose `status` and `notes` it updates. Koine must raise nothing of its own and the launch must not
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
    if grep -q 'CoreServicesUIAgent:Open' <<<"${dialogs}"; then
        status="failed"
        notes="${notes}Gatekeeper's dialog was raised by the ${when}; "
    elif grep -q 'CoreServicesUIAgent' <<<"${dialogs}"; then
        # Another dialog of the same system process (a default-browser confirmation left
        # standing is the one seen): not Gatekeeper's, and not an answer to the ${when}.
        status="failed"
        notes="${notes}a system dialog is standing that the ${when} did not raise: ${dialogs}; "
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

