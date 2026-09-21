# shellcheck shell=bash
# shellcheck disable=SC2016,SC2034  # guest-side $HOME; variables the sourcing script uses
# Sourced by the VM verification scripts that need a Gatekeeper-ENFORCING clone
# and a QUARANTINED bundle (vm-verify-notarized.sh, vm-verify-release.sh), after
# scripts/vm-verify-lib.sh and scripts/vm-verify-desktop-lib.sh — it needs the
# latter's VM_PASSWORD. Everything here was established by the runs recorded in
# docs/verification/notarized-release-vm.md, and it lives in one file so the two
# routes cannot drift apart on a procedure that cost several runs to get right.
# The library snapshots to depth 14, which reaches Koine's own windows. System
# Settings' Security section is deeper, so the depth becomes a variable here and
# the library's default is kept for every other window.
SNAPSHOT_DEPTH=14
# The default is inside the expansion, not only in the assignment above. Under
# `set -u` an unset SNAPSHOT_DEPTH makes this abort in the subshell that
# element() runs it in, and the retry loops reading that just report the window
# never appearing — which is exactly what one caller's cleanup caused.
snapshot() { testanyware agent snapshot --mode full --window "${SNAPSHOT_WINDOW:-${APP_NAME}}" --depth "${SNAPSHOT_DEPTH:-14}" --json; }
# A quarantine value in the shape LaunchServices writes for a download: flags
# 0181 (downloaded, not yet opened), a timestamp, the agent, and a UUID. The
# substitutions are the guest's, so they are deliberately not expanded here.
# shellcheck disable=SC2016
QUARANTINE='0181;$(printf %x $(date +%s));Safari;$(uuidgen)'
# enforce_gatekeeper: the whole point of this run, and it is two switches rather
# than one. `spctl --status --verbose` reports them separately, and only the
# first has a command. Both are asserted, because with assessments enabled and
# developer id disabled the clone is "App Store only": a NOTARIZED Developer ID
# bundle is rejected there exactly as an unnotarized one is, and a run made in
# that state would record `rejected` and prove nothing — the same empty result
# the four evidence documents this run exists to close already carry.
enforce_gatekeeper() {
    step "Put the clone into a Gatekeeper-enforcing state"
    echo "Before: $(guest 'spctl --status --verbose' 2>&1 | tr '\n' '; ')"
    # Apple restricts DISABLING assessments on recent macOS, not enabling them.
    guest "echo ${VM_PASSWORD} | sudo -S spctl --global-enable" || true
    local status
    status="$(guest 'spctl --status --verbose' 2>&1)"
    echo "After:  $(tr '\n' '; ' <<<"${status}")"
    grep -qx 'assessments enabled' <<<"${status}" ||
        fail "assessments are still disabled; this run cannot say anything about notarization"
    grep -qx 'developer id enabled' <<<"${status}" || enable_developer_id
}

# enable_developer_id: the second switch, which no spctl spelling reaches on
# macOS 26.5 — --developer-id-enable is unrecognized, and --enable --label
# "Developer ID" answers "This operation is no longer supported". It is set where
# a user sets it, and the guest is left in the macOS DEFAULT posture ("App Store
# & Known Developers"), which is still strictly more enforcing than the golden
# image's assessments-disabled state.
#
# Three things about this pane were each established the hard way:
#  * The control sits ~1600pt down a pane that does not scroll under `input
#    scroll`, and the accessibility tree reports its position in an unclipped
#    layout space that does not move. So the guest is started tall enough
#    (KOINE_VM_DISPLAY) for the control to be on screen, and the reported
#    position is then simply correct.
#  * `agent press` refuses these controls with HTTP 400 — the same refusal
#    vm-verify-lib.sh records for Koine's own SwiftUI controls — so the popup and
#    its menu item are clicked over VNC at their centres.
#  * The menu opens into a window of its own, and the menu bar's items are in the
#    tree too with zero width. Both are why this snapshots every window and keeps
#    only items that have a size.
enable_developer_id() {
    echo "The clone is App Store-only; setting the default posture in System Settings."
    guest 'open "x-apple.systempreferences:com.apple.preference.security"' || true
    SNAPSHOT_WINDOW="System Settings"
    SNAPSHOT_DEPTH=24
    sleep 8
    testanyware agent window-move --window "${SNAPSHOT_WINDOW}" --x 0 --y 0 >/dev/null || true
    testanyware agent window-resize --window "${SNAPSHOT_WINDOW}" --width 1400 --height 2100 >/dev/null || true
    testanyware agent window-focus --window "${SNAPSHOT_WINDOW}" >/dev/null || true
    sleep 3

    click '.platformRole=="AXPopUpButton"'
    sleep 1
    local item
    item="$(testanyware agent snapshot --mode full --depth 26 --json |
        jq -c '[.windows[] | .elements[]? | .. | objects
               | select(has("platformRole"))
               | select(.platformRole == "AXMenuItem" and .sizeWidth > 0)
               | select((.label // "") | test("Known Developers"))][0]')"
    [ "${item}" != null ] && [ -n "${item}" ] ||
        fail "the Allow-applications menu offers no \"App Store & Known Developers\""
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '"\(.positionX + .sizeWidth / 2 | floor) \(.positionY + .sizeHeight / 2 | floor)"' <<<"${item}") >/dev/null
    sleep 3

    # The change is authorised by an administrator. The prompt is a sheet on the
    # pane rather than a window of its own, so it is confirmed by reading the
    # screen; nothing below would work if the password went to the wrong place.
    testanyware screen find-text "Enter your password to allow this" --timeout 20 --require-match --json >/dev/null ||
        fail "no authentication sheet appeared for the security setting"
    testanyware input type "${VM_PASSWORD}" >/dev/null
    sleep 1
    testanyware input key return >/dev/null
    sleep 6
    testanyware input key q --modifiers cmd >/dev/null
    # Restore the depth rather than unsetting it: 14 is the value every other
    # window here is read at, and leaving it unset broke two runs.
    unset SNAPSHOT_WINDOW
    SNAPSHOT_DEPTH=14
    sleep 2

    local after
    after="$(guest 'spctl --status --verbose' 2>&1)"
    echo "After System Settings: $(tr '\n' '; ' <<<"${after}")"
    grep -qx 'assessments enabled' <<<"${after}" || fail "assessments were turned off by that change"
    grep -qx 'developer id enabled' <<<"${after}" ||
        fail "the clone is still App Store-only, so a notarized build would be rejected here too and this run would prove nothing"
}

# install_app_quarantined: as the library's install_app, except that the bundle
# is given com.apple.quarantine explicitly — `testanyware file upload` sets none
# — and that the attribute is asserted present BEFORE anything launches. A run
# that discovers the attribute missing afterwards has proved nothing.
install_app_quarantined() {
    step "Install the notarized bundle and quarantine it, as a download arrives"
    ditto -c -k --keepParent "${APP_BUNDLE}" "${WORK}/Koine.zip"
    testanyware file upload "${WORK}/Koine.zip" /tmp/Koine.zip >/dev/null
    testanyware file upload scripts/vm-verify-client.sh /Users/admin/vm-verify-client.sh >/dev/null
    guest "ditto -x -k /tmp/Koine.zip /Applications"
    guest "xattr -w -r com.apple.quarantine \"${QUARANTINE}\" ${INSTALLED}"
    QUARANTINE_BEFORE="$(guest "xattr -p com.apple.quarantine ${INSTALLED}")"
    echo "Quarantine on the bundle: ${QUARANTINE_BEFORE}"
    grep -q '^0181;' <<<"${QUARANTINE_BEFORE}" || fail "the bundle is not quarantined; the launch below would prove nothing"
    echo "Quarantined files inside it: $(guest "xattr -r -p com.apple.quarantine ${INSTALLED} 2>/dev/null | wc -l" | tr -d ' ')"
    guest "xcrun stapler validate ${INSTALLED} 2>&1" || fail "the ticket is not stapled into the installed copy"
}

# await_service: waits for the endpoint descriptor, dismissing any Gatekeeper
# plugin refusal that stands in the way, then waits for the management window.
#
# Since quarantined-provider-precheck-k49 the loader asks Gatekeeper before
# dlopen and refuses such a plugin itself, so no dialog is expected; the
# dismissal stays so that a regression is recorded, in REFUSAL_TEXT, rather than
# deadlocking the run. What it was written against, before that:
# the refused plugin does not merely fail to load: it BLOCKS KOINE'S STARTUP.
# Measured directly — Koine's process running, its dialog on screen, and no
# endpoint.json in its data directory minutes later. Providers are dlopen'ed
# while the service comes up and macOS's refusal is a modal dialog a person must
# dismiss, so the server never begins listening until someone clicks Done.
# REFUSAL_TEXT and BLOCKED_STARTUP are left set for the assertions further down.
REFUSAL_TEXT=""
BLOCKED_STARTUP=""
await_service() {
    # The service first, the window second, and with more patience than the library's
    # launch(): a quarantined first launch goes through Gatekeeper's approval path
    # and was measured taking longer than place_window's own 30s, so calling that
    # first reports "the management window did not appear" for an application that
    # was merely still starting.
    # The refused plugin does not merely fail to load: it BLOCKS KOINE'S STARTUP.
    # Measured directly — Koine's process running, its dialog on screen, and no
    # endpoint.json in its data directory minutes later. The dlopen of a provider
    # happens while the service is coming up, and macOS's refusal is a modal dialog
    # that a person has to dismiss, so the server never begins listening until
    # someone clicks Done. That is why this is dismissed inside the wait rather than
    # after it: waiting for the endpoint first is a deadlock, and it cost two runs.
    REFUSAL_TEXT=""
    BLOCKED_STARTUP=""
    missing=0
    for attempt in $(seq 1 45); do
        if guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1; then break; fi

        TREE="$(testanyware agent snapshot --mode full --depth 20 --json 2>/dev/null |
            jq -r '[.windows[] | .elements[]? | .. | objects
                   | select(.platformRole == "AXStaticText") | .value // empty] | join("\n")' 2>/dev/null || true)"
        # The dialog's wording, never the library's name: Koine's own window
        # shows the loader's diagnostic, which names the library too, and a run
        # matched it here as a refusal the platform never raised.
        if grep -qE 'Not Opened|could not verify' <<<"${TREE}"; then
            if [ -z "${REFUSAL_TEXT}" ]; then
                REFUSAL_TEXT="$(grep -E 'Not Opened|could not verify' <<<"${TREE}")"
                step "macOS refuses the quarantined plugin, and Koine cannot finish starting until it is dismissed"
                # Recorded at the moment it is true: the process is up, the dialog is
                # on screen, and there is no endpoint descriptor.
                BLOCKED_STARTUP="$(guest "pgrep -f ${INSTALLED}/Contents/MacOS >/dev/null && [ ! -e \"${DATA}/endpoint.json\" ] && echo blocked" || true)"
                echo "Koine running with no endpoint descriptor: ${BLOCKED_STARTUP:-no}"
                echo "${REFUSAL_TEXT}" | sed 's/^/  /'
                testanyware screen capture -o "${LOG%.log}-plugin-refused.png" >/dev/null
            fi
            # Attempted on EVERY iteration while the dialog stands, never latched
            # after one go: a single click that lands too early leaves the dialog up
            # and the service down, and the loop then waits out its whole bound on a
            # dismissal that never happened. That is what two runs actually died of.
            DONE_BUTTON="$(testanyware agent snapshot --mode full --depth 20 --json 2>/dev/null |
                jq -c '[.windows[] | .elements[]? | .. | objects | select(has("platformRole"))
                       | select(.platformRole == "AXButton" and .sizeWidth > 0)
                       | select((.label // "") == "Done")][0]' 2>/dev/null || echo null)"
            if [ "${DONE_BUTTON}" != null ] && [ -n "${DONE_BUTTON}" ]; then
                # shellcheck disable=SC2046
                testanyware input click $(jq -r '"\(.positionX + .sizeWidth / 2 | floor) \(.positionY + .sizeHeight / 2 | floor)"' <<<"${DONE_BUTTON}") >/dev/null || true
            fi
        fi

        # Liveness, from the host. `testanyware vm list` is NOT the instrument for
        # this: it reported "Running clones: (none)" for a clone tart listed as
        # `running` and whose agent answered every call, and trusting it aborted a
        # good run with a false "the clone died". tart's own state column is what
        # the TestAnyware guidance says to read, and three consecutive misses rather
        # than one keeps a momentary listing hiccup from ending a run.
        if [ $((attempt % 5)) = 0 ] && command -v tart >/dev/null; then
            if tart list 2>/dev/null | grep "${VM_ID}" | grep -q running; then
                missing=0
            else
                missing=$((missing + 1))
                [ "${missing}" -lt 3 ] || fail "tart no longer lists ${VM_ID} as running; the clone died mid-run"
            fi
        fi
        sleep 2
    done
    guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1 || fail "no endpoint descriptor after the launch"
    KOINE_PID="$(guest "pgrep -f ${INSTALLED}/Contents/MacOS" 2>&1 | grep -E '^[0-9]+$' | tail -1)"
    echo "Koine pid: ${KOINE_PID}"
    [ -n "${KOINE_PID}" ] || fail "Koine is not running after the launch"
    # More patience than place_window's own 30s: on this path the window comes up
    # well after the descriptor, and a run was failed with "the management window
    # did not appear" whose failure screenshot showed it present and rendered.
    for _ in $(seq 1 45); do
        element '.id=="grant-label"' 2>/dev/null | grep -q '^{' && break
        sleep 2
    done
    place_window
}

# assert_no_system_refusal <what>: no plugin refusal dialog on screen, read the
# way await_service reads one and the way notarized-release-vm.md's run first
# found it — every window's static text, where it arrived whole as
# "“libFixtureProvider.dylib” Not Opened" / "Apple could not verify …". Koine's
# own window shows the loader's diagnostic, which names the library too, so the
# match is on the dialog's wording, never on the library's name.
assert_no_system_refusal() {
    local tree
    tree="$(testanyware agent snapshot --mode full --depth 20 --json |
        jq -r '[.windows[] | .elements[]? | .. | objects
               | select(.platformRole == "AXStaticText") | .value // empty] | join("\n")')"
    testanyware screen capture -o "${LOG%.log}-no-refusal-$1.png" >/dev/null
    if grep -qE 'Not Opened|could not verify' <<<"${tree}"; then
        grep -E 'Not Opened|could not verify' <<<"${tree}" | sed 's/^/  /'
        fail "a system refusal dialog is on screen ($1 provider)"
    fi
    echo "No system refusal dialog on screen ($1 provider)."
}

# first_launch_quarantined: the first launch of the quarantined copy, by plain
# `open` — what a user does by double-clicking in the Finder. Nothing here
# removes the attribute, passes -a, or reaches for the right-click-Open override.
# `open` returns -1712 rather than 0: the first-run dialog blocks the launch it
# is waiting on. That is the dialog appearing, not a failure to open.
#
# A quarantined app gets a first-run dialog even when it is notarized, and WHICH
# dialog it is distinguishes the notarized path from the two refusals:
#   unnotarized, developer id enabled ->  "can't be opened because Apple cannot
#                                          check it for malicious software"
#   any build, App Store-only         ->  "can't be opened because it was not
#                                          downloaded from the App Store"
# Both were seen on this golden while establishing the procedure. This asserts
# the two facts every caller needs — a dialog appeared, and it is not a refusal —
# and leaves its whole text in DIALOG_TREE, so a caller that exists to
# discriminate (vm-verify-notarized.sh) makes the finer assertions itself.
#
# Read as text, not as pixels. OCR loses this dialog twice over: it matches
# within a line, and the headline wraps across "…an app downloaded / from the
# Internet…", so a phrase spanning the break finds nothing while the words are
# plainly on screen; and the grey body line that carries the whole verdict came
# back as "Trom the internet" and worse. The accessibility tree returns each
# static text whole, newlines and all, which is what this needs to distinguish.
DIALOG_TREE=""
first_launch_quarantined() {
    step "First launch of the quarantined copy: plain open, no right-click-Open"
    guest "open ${INSTALLED}" || true
    sleep 6
    DIALOG_TREE=""
    for _ in $(seq 1 12); do
        DIALOG_TREE="$(testanyware agent snapshot --mode full --depth 20 --json |
            jq -r '[.windows[] | .elements[]? | .. | objects
                   | select(.platformRole == "AXStaticText") | .value // empty] | join("\n")')"
        grep -q 'downloaded from the Internet' <<<"${DIALOG_TREE}" && break
        sleep 3
    done
    echo "${DIALOG_TREE}" | sed 's/^/  /'
    testanyware screen capture -o "${LOG%.log}-first-launch.png" >/dev/null
    grep -q 'downloaded from the Internet' <<<"${DIALOG_TREE}" ||
        fail "no first-run dialog appeared at all for a quarantined bundle"
    ! grep -q "can’t be opened" <<<"${DIALOG_TREE}" || fail "Gatekeeper refused the bundle on first launch"

    # The ordinary Open button, not the right-click-Open override. The dialog is
    # CoreServicesUIAgent's, so every window is searched rather than Koine's. This
    # is also the structural half of telling the dialogs apart, and the more robust
    # half: a refusal offers OK, Move to Trash or Show in Finder, and never Open.
    local button
    button="$(testanyware agent snapshot --mode full --depth 20 --json |
        jq -c '[.windows[] | .elements[]? | .. | objects
               | select(has("platformRole"))
               | select(.platformRole == "AXButton" and .sizeWidth > 0)
               | select((.label // "") == "Open")][0]')"
    [ "${button}" != null ] && [ -n "${button}" ] ||
        fail "the first-run dialog offers no Open button"
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '"\(.positionX + .sizeWidth / 2 | floor) \(.positionY + .sizeHeight / 2 | floor)"' <<<"${button}") >/dev/null
    sleep 3
}
