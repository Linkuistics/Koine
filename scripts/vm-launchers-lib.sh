# shellcheck shell=bash
# shellcheck disable=SC1112,SC2016,SC2034  # curly quotes in dialog labels; guest-side $HOME; variables the sourcing script uses
# Sourced by the VM scripts that prepare, check or reuse the twelve named launcher
# applications (vm-prepare-launchers.sh, and the acceptance that follows it), after
# scripts/vm-verify-lib.sh, scripts/vm-verify-desktop-lib.sh (VM_PASSWORD) and
# scripts/vm-verify-gatekeeper-lib.sh (enforce_gatekeeper, QUARANTINE). The
# procedure and what it recorded: docs/verification/launcher-apps-vm.md
#
# The catalogue, scripts/launcher-apps.json, names the applications. What a first
# run does to each is not guessable from the outside, so it is *driven*, not
# declared: every dialog that appears is read from the accessibility tree, answered
# by the narrow rule below that matches it, and written to ACTIONS as it happens.
# A dialog no rule matches is left alone and the application never settles, which
# fails the run; no rule signs in, enters an email address or accepts a purchase.

LAUNCHER_CATALOGUE="scripts/launcher-apps.json"
LAUNCHER_PENDING_DIR='$HOME/gatekeeper-pending'
# ACTIONS records every dialog answered, one JSON object per line, so the inventory
# can say which onboarding needed GUI action.
ACTIONS="${WORK}/first-run-actions.jsonl"
: >"${ACTIONS}"

# Dialogs any application can raise, as (accessibility application, button, meaning).
# The application is the system process that owns the dialog, not the launcher.
GLOBAL_DIALOGS='[
  {"app":"CoreServicesUIAgent","button":"Open","what":"Gatekeeper: downloaded from the Internet, open it?"},
  {"app":"UserNotificationCenter","button":"Don’t Allow","what":"system permission request (declined)"},
  {"app":"universalAccessAuthWarn","button":"Deny","what":"Accessibility (events) request (denied)","recurring":true}
]'

catalogue() { jq -c "$1" "${LAUNCHER_CATALOGUE}"; }
app_field() { jq -r --arg n "$1" ".apps[] | select(.name == \$n) | $2" "${LAUNCHER_CATALOGUE}"; }
app_names() { jq -r '.apps[].name' "${LAUNCHER_CATALOGUE}"; }

# Every button of every window, with the owning process and where to click it.
screen_buttons() {
    testanyware agent snapshot --mode full --depth 20 --json | jq -c '
      [.windows[] | .appName as $a | .elements[]? | .. | objects
       | select(has("platformRole") and .platformRole == "AXButton" and .sizeWidth > 0)
       | {app: $a, label: .label,
          x: (.positionX + .sizeWidth / 2 | floor), y: (.positionY + .sizeHeight / 2 | floor)}]'
}
# The static text of one process's windows: the words of the dialog being answered.
screen_text() {
    testanyware agent snapshot --mode full --depth 20 --json | jq -r --arg app "$1" '
      [.windows[] | select(.appName == $app) | .elements[]? | .. | objects
       | select(.platformRole? == "AXStaticText") | .value // empty] | join(" / ")'
}
# Buttons whose label says a question is still open. Seen on an application's own window
# after it has settled, they mean a first-run step nothing answered (Notes' "Turn On
# iCloud" offer), which a window merely being present hides. The catalogue's `resting`
# buttons are the exception: Mail's Add Account sheet is its resting state, not a step.
UNANSWERED_LABELS='["OK","Cancel","Continue","Allow","Don’t Allow","Deny","Not Now","Later","Skip","Agree","Accept","Got It","Next"]'
unanswered_buttons() {
    local resting
    resting="$(jq -c --arg n "$2" '[.apps[] | select(.name == $n) | .resting // []] | add' "${LAUNCHER_CATALOGUE}")"
    screen_buttons | jq -r --arg app "$1" --argjson labels "${UNANSWERED_LABELS}" --argjson resting "${resting}" \
        '[.[] | select(.app == $app and (.label as $l | ($labels | index($l)) and (($resting | index($l)) | not))) | .label] | join(", ")'
}
window_of() {
    testanyware agent windows --json | jq -e --arg app "$1" '[.windows[] | select(.appName == $app)] | length >= 1' >/dev/null
}

# A recurring dialog is an application asking again whenever it is refused (Kimi's
# Accessibility request returns seconds after every Deny, for as long as it runs). It is
# answered once per run; when it comes back it is not an onboarding step to wait out, so
# it neither delays settling nor counts against a prepared image. RECURRING_ANSWERED holds
# the "owner|button" pairs already answered during this run of the application.
RECURRING_ANSWERED=""

# answer_dialogs <application> <rules json> [clear]: presses the first rule's button found
# on screen. Prints the meaning and returns 0 if one was pressed, 1 if nothing matched.
# `clear` presses recurring ones again too, to take their dialog off the screen.
answer_dialogs() {
    local buttons rule hit
    buttons="$(screen_buttons)"
    while IFS= read -r rule; do
        hit="$(jq -c --argjson r "${rule}" '[.[] | select(.app == $r.app and .label == $r.button)][0]' <<<"${buttons}")"
        [ "${hit}" != null ] || continue
        if [ "$(jq -r '.recurring // false' <<<"${rule}")" = true ]; then
            local key
            key="$(jq -r '"\(.app)|\(.button)"' <<<"${rule}")"
            if [ "${3:-}" != clear ] && [[ "${RECURRING_ANSWERED}" == *"[${key}]"* ]]; then continue; fi
            RECURRING_ANSWERED="${RECURRING_ANSWERED}[${key}]"
        fi
        local words
        words="$(screen_text "$(jq -r .app <<<"${rule}")" | cut -c1-300)"
        # shellcheck disable=SC2046
        testanyware input click $(jq -r '"\(.x) \(.y)"' <<<"${hit}") >/dev/null
        jq -cn --arg application "$1" --argjson rule "${rule}" --arg words "${words}" \
            '{application: $application, dialogOwner: $rule.app, button: $rule.button, meaning: $rule.what, words: $words, recurring: ($rule.recurring // false), atQuit: ($rule.atQuit // false)}' >>"${ACTIONS}"
        echo "  answered: $(jq -r '"\(.app): \(.button) (\(.what))"' <<<"${rule}")"
        return 0
    done < <(jq -c '.[]' <<<"$2")
    return 1
}

# run_application <name>: opens it as a user does and answers what appears until its
# own window is up and nothing is left to answer, twice running. STRICT=1 (the check
# of an already prepared image) makes any dialog at all a failure: that is the proof
# that preparation left nothing to approve.
run_application() {
    local name="$1" window rules settled=0 answered=0
    RECURRING_ANSWERED=""
    window="$(app_field "${name}" .windowApp)"
    rules="$(jq -c --argjson g "${GLOBAL_DIALOGS}" --arg n "${name}" '$g + (.apps[] | select(.name == $n) | .dialogs)' "${LAUNCHER_CATALOGUE}")"
    guest "open -a '${name}'" || true
    for _ in $(seq 1 40); do
        sleep 4
        if answer_dialogs "${name}" "${rules}"; then
            answered=$((answered + 1))
            settled=0
            [ "${STRICT:-0}" != 1 ] || fail "${name} still raised a dialog on a prepared image"
            continue
        fi
        if window_of "${window}"; then
            settled=$((settled + 1))
            [ "${settled}" -lt 2 ] || break
        else
            settled=0
        fi
    done
    [ "${settled}" -ge 2 ] || fail "${name} never settled with a window of its own and no dialog to answer"
    testanyware screen capture -o "${LOG%.log}-${name// /-}.png" >/dev/null
    local unanswered
    unanswered="$(unanswered_buttons "${window}" "${name}")"
    [ -z "${unanswered}" ] || fail "${name} settled but still shows: ${unanswered}; see ${LOG%.log}-${name// /-}.png"
    echo "${name}: settled with a ${window} window after answering ${answered} dialog(s); first run stops at: $(app_field "${name}" .reaches)"
}

# quit_application <name>: Command-Q, as a user quits; a force-kill is recorded, not hidden.
quit_application() {
    local name="$1" window path rules
    window="$(app_field "${name}" .windowApp)"
    path="$(app_field "${name}" .path)"
    rules="$(jq -c --argjson g "${GLOBAL_DIALOGS}" --arg n "${name}" '($g | map(select(.recurring))) + (.apps[] | select(.name == $n) | (.quitDialogs // []) | map(. + {atQuit: true}))' "${LAUNCHER_CATALOGUE}")"
    # An application that has only just settled can miss the first Command-Q (Notes, with
    # its welcome sheet still animating, did), and some ask to confirm (iTerm, with a
    # session open): so ask up to three times, answering what it asks, before forcing.
    for _ in 1 2 3; do
        # A recurring dialog on screen would hold the focus; take it off first.
        answer_dialogs "${name}" "${rules}" clear >/dev/null || true
        testanyware agent window-focus --window "${window}" >/dev/null 2>&1 || true
        sleep 1
        testanyware input key q --modifiers cmd >/dev/null
        for _ in 1 2 3; do
            sleep 2
            answer_dialogs "${name}" "${rules}" clear >/dev/null || true
            guest_text "pgrep -f '${path}/Contents/MacOS/' | wc -l" | grep -qx ' *0' && return 0
        done
    done
    guest "pkill -9 -f '${path}/Contents/MacOS/'" || true
    jq -cn --arg application "${name}" '{application: $application, dialogOwner: null, button: null, meaning: "did not quit on Command-Q; force-killed", words: "", recurring: false, atQuit: false}' >>"${ACTIONS}"
    echo "  ${name} did not quit on Command-Q; force-killed"
}

# The default browser. macOS asks "Keep X / Use Y" whenever one is changed, and the
# change is made by that answer, so the script that asks (scripts/vm-default-browser.swift,
# compiled in the guest) and the click that answers are two halves of one step.
install_default_browser_tool() {
    testanyware file upload scripts/vm-default-browser.swift /Users/admin/vm-default-browser.swift >/dev/null
    guest 'cd $HOME && swiftc -O vm-default-browser.swift -o vm-default-browser 2>&1 | tail -3'
    guest '[ -x $HOME/vm-default-browser ]' || fail "the default-browser tool did not build in the guest"
}
default_browser() { guest_text '$HOME/vm-default-browser get' | grep '^http -> ' | sed 's/^http -> //'; }
# set_default_browser <application path> <button label, e.g. Use “Dia”>
# The agent's exec channel can run a command twice, a retry arriving after the first run has
# long been answered, and each run of `set` raises a confirmation dialog of its own that
# nothing would answer. So the launch takes a guard directory unique to this run and call,
# and a retried launch that finds it taken starts nothing (as guest_long's does).
SET_DEFAULT_CALLS=0
set_default_browser() {
    SET_DEFAULT_CALLS=$((SET_DEFAULT_CALLS + 1))
    guest "mkdir \$HOME/default-browser-${VM_ID}-${SET_DEFAULT_CALLS}.started 2>/dev/null || exit 0; rm -f \$HOME/default-browser.out; (nohup \$HOME/vm-default-browser set '$1' > \$HOME/default-browser.out 2>&1 &)" || true
    local buttons hit
    for _ in $(seq 1 15); do
        sleep 2
        buttons="$(screen_buttons)"
        hit="$(jq -c --arg l "$2" '[.[] | select(.app == "CoreServicesUIAgent" and .label == $l)][0]' <<<"${buttons}")"
        [ "${hit}" = null ] || break
    done
    [ "${hit}" != null ] || fail "the system never asked to confirm the default browser ($2)"
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '"\(.x) \(.y)"' <<<"${hit}") >/dev/null
    jq -cn --arg button "$2" --arg path "$1" '{application: "default browser", dialogOwner: "CoreServicesUIAgent", button: $button, meaning: "confirm the default browser", words: $path}' >>"${ACTIONS}"
    sleep 3
    # Nothing is left standing: a confirmation still on screen would be taken for another
    # system dialog by whatever runs next.
    buttons="$(screen_buttons)"
    [ "$(jq -r '[.[] | select(.app == "CoreServicesUIAgent")] | length' <<<"${buttons}")" = 0 ] ||
        fail "a default-browser confirmation is still on screen after answering it: $(jq -c '[.[] | select(.app == "CoreServicesUIAgent") | .label]' <<<"${buttons}")"
}

# The pristine quarantined copy for the Gatekeeper-pending case: archived BEFORE any
# first run, in an archive whose extraction restores com.apple.quarantine (tar does;
# ditto's zip does not, even with --qtn), and kept away from the approved copy.
stash_pending_copy() {
    local name path
    name="$(jq -r '.apps[] | select(.gatekeeperPending) | .name' "${LAUNCHER_CATALOGUE}")"
    path="$(app_field "${name}" .path)"
    guest "xattr -p com.apple.quarantine '${path}' | grep -q '^0181;'" || fail "${name} is not in the never-opened quarantined state; there is nothing pristine to keep"
    guest "mkdir -p ${LAUNCHER_PENDING_DIR} && tar -C /Applications -czf ${LAUNCHER_PENDING_DIR}/${name}.app.tar.gz '${name}.app'" || fail "could not archive the pending copy"
    echo "Pending copy: ${name} archived at ${LAUNCHER_PENDING_DIR}/${name}.app.tar.gz, quarantined and never opened."
}

# restart_guest: a restart of the guest, as after installing software. Gatekeeper keeps
# its verdicts for the boot it is in: Zed's cask runs the application's own command-line
# tool while installing, and in that boot Zed then opened with no Gatekeeper dialog and its
# quarantine flag unapproved, yet in every later boot it raised the dialog. First runs
# made in a boot that has already seen the installers approve nothing that lasts.
restart_guest() {
    guest "echo ${VM_PASSWORD} | sudo -S shutdown -r now" || true
    sleep 20
    local tries=0
    until guest_text 'uptime' | grep -qE 'up [0-9]+ (secs|mins)'; do
        tries=$((tries + 1))
        [ "${tries}" -lt 30 ] || fail "the guest did not come back after its restart"
        sleep 5
    done
    # Only the desktop being up says the login session is: wait for the Dock's windows.
    tries=0
    until testanyware agent windows --json 2>/dev/null | jq -e '.windows | length >= 1' >/dev/null; do
        tries=$((tries + 1))
        [ "${tries}" -lt 30 ] || fail "the guest's desktop did not come back after its restart"
        sleep 5
    done
    echo "Restarted: $(guest_text 'uptime')"
}
