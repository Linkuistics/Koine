# shellcheck shell=bash
# Source-only strict layer of the Settings scenario, scripts/vm-verify-menu-bar.sh.
# Sourcing defines functions only. Each function sends its transports through
# the reviewed facades into the one root that settings_begin initialises, and
# keeps the legacy action, read count, wait, poll bound and failure message.
# The shared libraries keep their legacy lanes for the other VM scripts.
# docs/verification/settings-activation/ORDERING-SCENARIO-RESULTS.md records
# the caller table and the controls.
#
# Two kinds of function exist. A function whose output a caller captures with
# $(...) only returns a status. Every other function runs in the scenario
# shell, and it ends the scenario itself on a failure, with the legacy message.
# shellcheck source=scripts/vm-exec-one-shot-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-exec-one-shot-evidence-lib.sh"
# shellcheck source=scripts/vm-window-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-window-evidence-lib.sh"
# shellcheck source=scripts/vm-click-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-click-evidence-lib.sh"
# shellcheck source=scripts/vm-capture-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-capture-evidence-lib.sh"
# shellcheck source=scripts/vm-file-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-file-evidence-lib.sh"
# shellcheck source=scripts/vm-lifecycle-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-lifecycle-evidence-lib.sh"
# shellcheck source=scripts/vm-input-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-input-evidence-lib.sh"
# shellcheck source=scripts/vm-menu-pointer-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-menu-pointer-lib.sh"
# shellcheck source=scripts/vm-window-resize-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-window-resize-lib.sh"

SETTINGS_APP="${APP_NAME:-Koine}"
SETTINGS_PANE_WINDOW="System Settings"
SETTINGS_FRONT=''
SETTINGS_LIST=''
SETTINGS_INTERRUPTED=''
# Set once the untouched failure observations took the failure screenshot.
SETTINGS_OBSERVED=''
# Set once the Automation check passed, so the failure observer can run.
SETTINGS_OBSERVER_READY=''
# The TextEdit PID and the frame of its one window after the preparation.
SETTINGS_TEXTEDIT_PID=''
SETTINGS_TEXTEDIT_FRAME=''
# The process entry of the identity read before a return's click.
SETTINGS_PRE_IDENTITY=''
# The count poll's list, and the failure observer's value.
SETTINGS_COUNT_LIST=''
SETTINGS_OBSERVED_FRONT=''

# --- the root, the traps and the fence ---------------------------------------

# settings_begin ROOT VM: the first act of the scenario, before any transport.
# The legacy cleanup trap of scripts/vm-verify-lib.sh would send a bare stop,
# so it goes first. init refuses an existing directory, so no root is reused.
# Then the traps and the fence take effect.
settings_begin() {
    local root="$1" vm="$2"
    trap - EXIT
    if [[ -z "${root}" || "${root}" == -* ]]; then
        echo "FAILED: the evidence root path is empty or an option: ${root}" >&2
        exit 2
    fi
    init_guest_evidence "${root}" "${vm}" || {
        echo "FAILED: the evidence root ${root} could not be initialised for ${vm}; no transport was sent" >&2
        exit 2
    }
    KOINE_VM_EVIDENCE_ROOT="$(cd "${root}" && pwd -P)"
    export KOINE_VM_EVIDENCE_ROOT
    # A signal can arrive inside a call whose output goes to /dev/null. The
    # report therefore writes to the scenario's own streams, kept here.
    exec 7>&1 8>&2
    trap 'settings_signal INT 2' INT
    trap 'settings_signal TERM 15' TERM
    trap 'settings_signal HUP 1' HUP
    trap 'settings_report $?' EXIT
    settings_fence
    echo "Evidence root: ${KOINE_VM_EVIDENCE_ROOT} (clone ${vm}); it can hold KOINE_VM_PASSWORD, so only its owner can enter it. Keep it private"
}

# A legacy transport in the strict scenario latches the root and sends nothing.
# The backend starts the real CLI as a subprocess, so these shell functions
# never shadow it. fail keeps the legacy name for the clean false state.
# shellcheck disable=SC2329 # Only a legacy call reaches these definitions.
settings_fence() {
    testanyware() { settings_legacy testanyware "$@"; }
    guest() { settings_legacy guest "$@"; }
    guest_text() { settings_legacy guest_text "$@"; }
    guest_json() { settings_legacy guest_json "$@"; }
    guest_once() { settings_legacy guest_once "$@"; }
    guest_long() { settings_legacy guest_long "$@"; }
    sysevents() { settings_legacy sysevents "$@"; }
    snapshot() { settings_legacy snapshot "$@"; }
    fail() { settings_fail "$@"; }
}

settings_legacy() {
    fail_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" legacy-transport \
        "the strict Settings scenario refuses the legacy $1 call: ${*:2}" || :
    return 125
}

# INT, TERM and HUP stop scenario input at once, including any pending
# release. The one record goes through the same writer domain. A held lock
# makes it the backend's recorded refusal, which also latches.
settings_signal() {
    trap '' INT TERM HUP
    SETTINGS_INTERRUPTED="SIG$1"
    fail_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" "scenario-signal-$1" \
        "scenario interrupted by SIG$1; no further scenario input, including any release" || :
    echo "INTERRUPTED: SIG$1; no further input or release was sent" >&8
    exit $((128 + $2))
}

# settings_report STATUS: the scenario sends no stop and deletes nothing.
# k57's finite caller owns the exact stop, the inventory and the collection,
# through the same root.
settings_report() {
    local status="$1"
    # Ignore, never restore: no later signal may cut the report short.
    trap '' INT TERM HUP
    {
        echo "Scenario status ${status}${SETTINGS_INTERRUPTED:+ after ${SETTINGS_INTERRUPTED}}." \
            "Evidence root: ${KOINE_VM_EVIDENCE_ROOT}. Work directory: ${WORK:-none}."
        printf 'Held pointer: '
        settings_held_pointer || echo unknown
        echo "The scenario sent no VM stop. The finite caller owns the exact stop and" \
            "inventory of ${VM_ID:-the clone}: testanyware vm stop ${VM_ID:-<clone>}"
    } >&7 2>&8
}

# The held-pointer state from the ordered receipts: none, held, released or
# uncertain. A clean down without a later clean release is held. A failed,
# interrupted or partial held point or release is uncertain. k57 reads the
# receipts itself; this line only reports them.
settings_held_pointer() {
    python3 -I - "${KOINE_VM_EVIDENCE_ROOT}" <<'PY'
import json
import pathlib
import sys

state = "none"
for attempt in sorted(pathlib.Path(sys.argv[1]).glob("[0-9]" * 6)):
    try:
        operation = json.loads((attempt / "request.json").read_text())["operation"]
    except (OSError, ValueError, KeyError):
        continue
    if not (operation.startswith("resize-down-") or operation == "resize-release"):
        continue
    try:
        outcome = json.loads((attempt / "result.json").read_text())["outcome"]
    except (OSError, ValueError, KeyError):
        outcome = "partial"
    if outcome != "clean":
        state = "uncertain"
    elif state != "uncertain":
        state = "released" if operation == "resize-release" else "held"
print(state)
PY
}

# --- outcomes ---------------------------------------------------------------

# settings_fail MESSAGE: an existing assertion saw a clean false state. The
# untouched failure observations come first. Then one state-failed receipt
# keeps the legacy message, and the scenario exits 1.
settings_fail() {
    echo "FAILED: $*" >&2
    settings_failure_observations assertion
    record_guest_poll "${KOINE_VM_EVIDENCE_ROOT}" scenario-assertion exhausted 1 "$*" || :
    exit 1
}

# settings_fail_as OUTCOME MESSAGE: a classified clean false state. The one
# state-failed receipt, scenario-assertion-OUTCOME, keeps the class for k54.
# The classes are setup-failed, menu-item-disabled, menu-open (an unresolved
# selection), zero-window-same-process, process-lost, multiple-windows,
# not-front and window-identity. The untouched failure observations precede
# the receipt, unless a return already took them. The scenario exits 1.
settings_fail_as() {
    local outcome="$1"
    shift
    echo "FAILED: $* (outcome ${outcome})" >&2
    settings_failure_observations assertion
    record_guest_poll "${KOINE_VM_EVIDENCE_ROOT}" "scenario-assertion-${outcome}" exhausted 1 "$*" || :
    exit 1
}

# settings_failure_observations OPERATION: the protocol's untouched capture
# after a clean failed assertion, unless it already ran. It precedes the
# state-failed receipt, because that receipt latches the root, and the latch
# refuses the observer's System Events read.
settings_failure_observations() {
    [[ -n "${SETTINGS_OBSERVED}" ]] || settings_return_observations "$1"
}

# settings_require_as OUTCOME STATUS MESSAGE: status 1 is a classified clean
# false state, and any other nonzero status is already recorded.
settings_require_as() {
    if [[ "$2" == 1 ]]; then settings_fail_as "$1" "${@:3}"; fi
    settings_stop "${@:2}"
}

# settings_stop STATUS MESSAGE: a facade already recorded its own failure.
# The scenario keeps that status.
settings_stop() {
    local status="$1"
    shift
    echo "FAILED: $* (evidence status ${status})" >&2
    [[ -n "${SETTINGS_OBSERVED}" ]] || settings_failure_capture
    exit "${status}"
}

# settings_require STATUS MESSAGE: status 1 is a clean false state, and any
# other nonzero status is already recorded. Call it only after a failure.
settings_require() {
    if [[ "$1" == 1 ]]; then settings_fail "${@:2}"; fi
    settings_stop "$@"
}

# settings_local_failure OPERATION REASON: a host-side step failed.
settings_local_failure() {
    fail_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" "$1" "$2" || settings_stop "$?" "$2"
}

# The legacy failure screenshot, as one evidence-class collection.
settings_failure_capture() {
    local out
    out="$(capture_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" evidence failure-capture 2>/dev/null)" &&
        echo "Failure screenshot: $(jq -r '.path' <<<"${out}" 2>/dev/null)" >&2 || :
}

# settings_state OPERATION PREDICATE JSON: one local decision on one record,
# with its receipt. 0 and 1 are clean. Any other jq status latches.
settings_state() {
    local status=0
    jq -e "$2" >/dev/null <<<"$3" || status=$?
    record_guest_poll "${KOINE_VM_EVIDENCE_ROOT}" "$1-state" state "${status}" "$2" || return
    return "${status}"
}

# settings_sleep OPERATION SECONDS: an existing wait. A failed wait latches.
settings_sleep() {
    local status=0
    sleep "$2" || status=$?
    [[ "${status}" == 0 ]] && return
    record_guest_poll "${KOINE_VM_EVIDENCE_ROOT}" "$1-wait" sleep "${status}" "the existing ${2}-second wait" ||
        settings_stop "$?" "the ${2}-second wait of $1 failed"
}

# settings_last_record PREFIX: the newest record that a read whose operation
# begins with PREFIX printed. A host file read for a failure message only.
settings_last_record() {
    local directory
    while IFS= read -r directory; do
        jq -e --arg prefix "$1" '.operation | startswith($prefix)' \
            "${directory}/request.json" >/dev/null 2>&1 || continue
        if [[ -f "${directory}/read.json" ]]; then
            cat "${directory}/read.json"
            return
        fi
        if [[ -f "${directory}/raw.stdout" ]] && jq -e . "${directory}/raw.stdout" >/dev/null 2>&1; then
            cat "${directory}/raw.stdout"
            return
        fi
    done < <(find "${KOINE_VM_EVIDENCE_ROOT}" -mindepth 1 -maxdepth 1 -name '[0-9][0-9][0-9][0-9][0-9][0-9]' | LC_ALL=C sort -r)
    return 1
}

# settings_capture NAME [X,Y,WIDTH,HEIGHT]: an existing screenshot. The
# backend owns the unique path; NAME becomes the operation screenshot-NAME.
settings_capture() {
    local out name="$1"
    shift
    out="$(capture_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" read-poll "screenshot-${name}" "$@")" ||
        settings_stop "$?" "the screenshot ${name} could not be taken"
    echo "Screenshot ${name}: $(jq -r '.path' <<<"${out}")"
}

# settings_input OPERATION ACTION ARGUMENT...: one keyboard, text or scroll input.
settings_input() {
    scenario_input "$@" >/dev/null || settings_stop "$?" "the input $1 was not delivered cleanly"
}

# settings_window OPERATION ACTION WINDOW [X Y]: one window action.
settings_window() {
    act_guest_window "${KOINE_VM_EVIDENCE_ROOT}" "$@" >/dev/null ||
        settings_stop "$?" "the window action $1 was not submitted cleanly"
}

# --- the clone and the bundle -----------------------------------------------

settings_start_vm() {
    local record
    step "Start a clean VM (${VM_ID})"
    inventory_guest_vms "${KOINE_VM_EVIDENCE_ROOT}" read-poll vm-before absent >/dev/null ||
        settings_stop "$?" "the VM inventory before the start did not show ${VM_ID} absent"
    # KOINE_VM_BASE names the golden image. k57 supplies it for each slot.
    # KOINE_VM_DISPLAY overrides the guest's resolution, as before.
    start_guest_vm "${KOINE_VM_EVIDENCE_ROOT}" vm-start "${KOINE_VM_BASE-}" \
        ${KOINE_VM_DISPLAY:+"${KOINE_VM_DISPLAY}"} >/dev/null ||
        settings_stop "$?" "the clone ${VM_ID} did not start from the base \"${KOINE_VM_BASE-}\""
    inventory_guest_vms "${KOINE_VM_EVIDENCE_ROOT}" read-poll vm-after running >/dev/null ||
        settings_stop "$?" "the VM inventory after the start did not show ${VM_ID} running once"
    record="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" read-poll system system)" ||
        settings_stop "$?" "the guest system could not be read"
    jq -r '"\(.product_version) \(.build_version) \(.arch)"' <<<"${record}"
    record="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" read-poll gatekeeper gatekeeper)" ||
        settings_stop "$?" "the Gatekeeper status could not be read"
    echo "Gatekeeper: assessments $(jq -r '.assessments' <<<"${record}")"
}

settings_install_app() {
    local record
    step "Install the signed bundle (ditto zip, checked upload, checked extraction)"
    ditto -c -k --keepParent "${APP_BUNDLE}" "${WORK}/Koine.zip" ||
        settings_local_failure bundle-archive "ditto -c could not archive ${APP_BUNDLE}"
    upload_guest_file "${KOINE_VM_EVIDENCE_ROOT}" upload-bundle "${WORK}/Koine.zip" /tmp/Koine.zip >/dev/null ||
        settings_stop "$?" "the bundle upload failed"
    # The guest's /tmp does not survive the restart below; its home directory does.
    upload_guest_file "${KOINE_VM_EVIDENCE_ROOT}" upload-client scripts/vm-verify-client.sh \
        /Users/admin/vm-verify-client.sh >/dev/null ||
        settings_stop "$?" "the client script upload failed"
    submit_guest_extraction "${KOINE_VM_EVIDENCE_ROOT}" extract-bundle ||
        settings_stop "$?" "the extraction was not submitted cleanly"
    # Stated, not worked around: this route sets no quarantine attribute, so
    # Gatekeeper's first-launch check is not exercised here.
    record="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" read-poll quarantine quarantine)" ||
        settings_stop "$?" "the quarantine attribute could not be read"
    echo "Quarantine attribute: $(jq -r 'if .present then .value else "absent" end' <<<"${record}")"
    # The signature verification is the confirmation of the extraction.
    record="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" read-poll signature signature)" ||
        settings_stop "$?" "the signature could not be verified"
    jq -r '.text[]' <<<"${record}"
    settings_state signature '.valid == true' "${record}" ||
        settings_require "$?" "the VM rejects the signature"
    record="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" read-poll signature-display signature-display)" ||
        settings_stop "$?" "the signature could not be displayed"
    jq -r '.shown[]' <<<"${record}"
    record="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" read-poll assessment assessment)" ||
        settings_stop "$?" "the assessment could not be read"
    jq -r '.text[]' <<<"${record}"
    jq -e '.accepted' >/dev/null <<<"${record}" ||
        echo "(spctl assessment did not accept the bundle; recorded, not a failure of this stage)"
}

# settings_record_installed_bundle PHASE: the installed inventory, written
# once. The file is exclusive, and the raw bytes stay in the root.
settings_record_installed_bundle() {
    local phase="$1" record path="${LOG%.log}-installed-$1.txt"
    record="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" read-poll "installed-${phase}" installed-inventory)" ||
        settings_stop "$?" "incomplete installed bundle inventory (${phase})"
    (
        set -o noclobber
        jq -r '(.files[] | "\(.sha256)  \(.path)"), (.symlinks[] | "\(.path) -> \(.target)")' \
            <<<"${record}" >"${path}"
    ) || settings_local_failure "installed-${phase}-write" "the inventory file ${path} could not be written exclusively"
    echo "Installed bundle inventory: ${path}"
}

# --- launches and processes -------------------------------------------------

# settings_launch OPERATION: one open of the bundle, its descriptor poll and
# its identity read. SETTINGS_IDENTITY keeps the identity record.
settings_launch() {
    launch_guest_koine "${KOINE_VM_EVIDENCE_ROOT}" "$1" ||
        settings_stop "$?" "the launch $1 was not submitted cleanly"
    settings_await_koine "$1-endpoint"
    # shellcheck disable=SC2034 # The scenario passes it to the reopen confirmation.
    SETTINGS_IDENTITY="$(confirm_guest_launch "${KOINE_VM_EVIDENCE_ROOT}" "$1-identity")" ||
        settings_require "$?" "the launch $1 did not run one installed Koine process for its descriptor"
}

# settings_await_koine OPERATION: the process runs and has served its descriptor.
settings_await_koine() {
    await_guest_endpoint "${KOINE_VM_EVIDENCE_ROOT}" "$1" launch >/dev/null ||
        settings_stop "$?" "no endpoint descriptor after launch"
}

# settings_expect_stopped OPERATION: Quit stopped the server as it always has.
settings_expect_stopped() {
    settings_sleep "$1" 3
    check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll "$1-process" '.selected == []' \
        process executable >/dev/null || settings_require "$?" "Koine still runs after Quit"
    check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll "$1-descriptor" '.present == false' \
        endpoint >/dev/null || settings_require "$?" "the descriptor survived Quit"
}

# settings_expect_defaults OPERATION WHEN: the diagnostic defaults are absent
# or false, as the ordering protocol requires.
settings_expect_defaults() {
    check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll "$1" '.diagnostics_disabled == true' \
        defaults >/dev/null || settings_require "$?" "the diagnostic defaults are not disabled $2"
}

# --- System Events ------------------------------------------------------------

settings_grant_system_events_automation() {
    request_guest_automation "${KOINE_VM_EVIDENCE_ROOT}" automation-request ||
        settings_stop "$?" "the System Events request was not submitted cleanly"
    # The checked click keeps the legacy two seconds after it.
    click_guest_allow "${KOINE_VM_EVIDENCE_ROOT}" automation-allow ||
        settings_require "$?" "the Automation prompt for System Events did not appear"
    expect_guest_system_events "${KOINE_VM_EVIDENCE_ROOT}" automation-check >/dev/null ||
        settings_require "$?" "System Events still refuses the agent"
    SETTINGS_OBSERVER_READY=1
}

settings_expect_menu_count() {
    expect_guest_menu_count "${KOINE_VM_EVIDENCE_ROOT}" "$1" >/dev/null || settings_require "$?" "$2"
}

# settings_menu_label OPERATION: the item's description, as one read.
settings_menu_label() {
    local record
    record="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" read-poll "$1" menu-item-label value)" || return
    jq -r '.value // "missing value"' <<<"${record}"
}

# settings_await_menu_label OPERATION LABEL
settings_await_menu_label() {
    local got
    await_guest_menu_label "${KOINE_VM_EVIDENCE_ROOT}" "$1" "$2" >/dev/null || {
        local status=$?
        got="$(settings_last_record "$1-" | jq -r '.value // "missing value"' 2>/dev/null)" || got=unknown
        settings_stop "${status}" "the menu bar item's label is \"${got}\", not \"$2\""
    }
}

settings_open_menu() {
    local record
    record="$(await_guest_menu_frame "${KOINE_VM_EVIDENCE_ROOT}" "$1-item")" ||
        settings_stop "$?" "Koine's menu bar item has no position"
    click_centre "$(jq -r '.text' <<<"${record}")" ||
        settings_stop "$?" "the click on Koine's menu bar item was not delivered cleanly"
}

# settings_expect_menu OPERATION TITLE...: the open-and-read menu is exactly
# these titles. As before, the menu closes before the comparison fails.
settings_expect_menu() {
    local operation="$1" record status=0 menu expected
    shift
    settings_open_menu "${operation}"
    record="$(expect_guest_menu "${KOINE_VM_EVIDENCE_ROOT}" "${operation}" "$@")" || status=$?
    [[ "${status}" == 0 || "${status}" == 1 ]] || settings_stop "${status}" "the menu could not be read"
    [[ "${status}" == 0 ]] || record="$(settings_last_record "${operation}")" || record='{"value":[]}'
    menu="$(jq -r '.value | join(", ")' <<<"${record}")"
    echo "Menu: ${menu}"
    settings_input "${operation}-close" key escape
    settings_sleep "${operation}-close" 1
    expected="$(jq -rn '$ARGS.positional | join(", ")' --args "$@")"
    [[ "${status}" == 0 ]] || settings_fail "the menu is \"${menu}\", not \"${expected}\""
}

# settings_choose_menu_item OPERATION TITLE: open the menu and click the item.
settings_choose_menu_item() {
    local record
    settings_open_menu "$1"
    record="$(await_guest_menu_frame "${KOINE_VM_EVIDENCE_ROOT}" "$1-row" "$2")" ||
        settings_stop "$?" "the menu has no item \"$2\""
    click_centre "$(jq -r '.text' <<<"${record}")" ||
        settings_stop "$?" "the click on the menu item \"$2\" was not delivered cleanly"
    settings_sleep "$1" 2
}

# settings_front_application OPERATION: the front process, as one read.
settings_front_application() {
    local record
    record="$(read_guest_exec "${KOINE_VM_EVIDENCE_ROOT}" read-poll "$1" front-application)" || return
    jq -r '.value' <<<"${record}"
}

settings_enrol() {
    submit_guest_enrolment "${KOINE_VM_EVIDENCE_ROOT}" "enrol-$2" "$1" "$2" >/dev/null ||
        settings_require "$?" "enrollment of $2 was refused"
}

# --- windows -------------------------------------------------------------------

# settings_windows OPERATION: one complete window list.
settings_windows() {
    read_guest_windows "${KOINE_VM_EVIDENCE_ROOT}" read-poll "$1"
}

# settings_frame OPERATION: "x y w h" of the settings window, from one list.
# 1 means that the list holds no window of that title.
settings_frame() {
    local list title
    list="$(settings_windows "$1")" || return
    title="$(jq -cn --arg title "${WINDOW_TITLE}" '$title')" || return
    settings_state "$1" "any(.windows[]; .title == ${title})" "${list}" || return
    jq -r --arg title "${WINDOW_TITLE}" '[.windows[] | select(.title == $title)][0]
        | "\(.positionX | floor) \(.positionY | floor) \(.sizeWidth | floor) \(.sizeHeight | floor)"' <<<"${list}"
}

# settings_read_frame OPERATION: FRAME_X, FRAME_Y, FRAME_W, FRAME_H and BOTTOM.
settings_read_frame() {
    local frame
    frame="$(settings_frame "$1")" ||
        settings_require "$?" "the window's frame could not be read from the agent"
    read -r FRAME_X FRAME_Y FRAME_W FRAME_H <<<"${frame}"
    BOTTOM=$((FRAME_Y + FRAME_H))
}

# settings_koine_count OPERATION: the number of Koine windows on screen.
settings_koine_count() {
    local list
    list="$(settings_windows "$1")" || return
    jq --arg app "${SETTINGS_APP}" '[.windows[] | select(.appName == $app)] | length' <<<"${list}"
}

# settings_expect_koine_count OPERATION COUNT MESSAGE: one read and its decision.
settings_expect_koine_count() {
    local list
    list="$(settings_windows "$1")" || settings_stop "$?" "$3"
    settings_state "$1" "([.windows[] | select(.appName == \"${SETTINGS_APP}\")] | length) == $2" \
        "${list}" || settings_require "$?" "$3"
}

# settings_await_windows OPERATION COUNT: the existing count poll.
# SETTINGS_COUNT_LIST keeps the list that satisfied it. The poll defers its
# exhaustion receipt, so the untouched failure observations precede the
# latch. The receipt keeps the facade's name and status (k165).
settings_await_windows() {
    local got list status=0 receipt=0 predicate
    list="$(await_guest_window_count "${KOINE_VM_EVIDENCE_ROOT}" "$1" "${SETTINGS_APP}" "$2" deferred)" ||
        status=$?
    if [[ "${status}" == 0 ]]; then
        # shellcheck disable=SC2034 # The scenario passes it to the positive setup.
        SETTINGS_COUNT_LIST="${list}"
        return
    fi
    if [[ "${status}" == 1 ]]; then
        got="$(jq --arg app "${SETTINGS_APP}" '[.windows[] | select(.appName == $app)] | length' \
            <<<"${list}" 2>/dev/null)" || got=unknown
        settings_failure_observations "$1"
        predicate="$(window_count_predicate "${SETTINGS_APP}" "$2")" || predicate="count == $2"
        record_guest_poll "${KOINE_VM_EVIDENCE_ROOT}" "$1-exhausted" exhausted 1 "${predicate}" || receipt=$?
        [[ "${receipt}" != 0 ]] || receipt=125
        settings_stop "${receipt}" "Koine has ${got:-unknown} windows, not $2"
    fi
    got="$(settings_last_record "$1-" |
        jq --arg app "${SETTINGS_APP}" '[.windows[] | select(.appName == $app)] | length' 2>/dev/null)" || got=unknown
    settings_stop "${status}" "Koine has ${got} windows, not $2"
}

# settings_koine_in_front OPERATION: Koine's window is the front window and
# the key one. SETTINGS_FRONT keeps that same list, front to back, without
# Notification Center, for the failure message.
settings_koine_in_front() {
    local list
    list="$(settings_windows "$1")" || return
    SETTINGS_LIST="${list}"
    SETTINGS_FRONT="$(jq -c '[.windows[] | select(.appName != "Notification Center")
        | [.appName, .title, .focused]]' <<<"${list}")" || {
        fail_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" "$1-decode" 'the front list could not be decoded'
        return
    }
    settings_state "$1" "[.windows[] | select(.appName != \"Notification Center\")][0]
        | .appName == \"${SETTINGS_APP}\" and .focused == true" "${list}"
}

# settings_title_audit OPERATION LIST: the protocol's audit of the same full
# list that the front predicate judged. Exactly one Koine window, titled
# WINDOW_TITLE, and it is the front and focused entry. A Koine window without
# a title is unavailable, never a wrong title.
settings_title_audit() {
    local title
    jq -e --arg app "${SETTINGS_APP}" 'all(.windows[] | select(.appName == $app); has("title"))' \
        >/dev/null <<<"$2" || {
        fail_guest_evidence "${KOINE_VM_EVIDENCE_ROOT}" "$1-title" \
            'a Koine window in the front list has no title, so the title audit is unavailable'
        return
    }
    title="$(jq -cn --arg title "${WINDOW_TITLE}" '$title')" || return
    settings_state "$1-title" "([.windows[] | select(.appName == \"${SETTINGS_APP}\")]
            | length == 1 and .[0].title == ${title})
        and ([.windows[] | select(.appName != \"Notification Center\")][0]
            | .appName == \"${SETTINGS_APP}\" and .title == ${title} and .focused == true)" "$2"
}

# settings_expect_front OPERATION MESSAGE: the window is in front, or the
# scenario ends with MESSAGE and the list that it judged. The title audit
# runs on the same list, and both results keep their receipts. As at a
# return, a clean false predicate takes the untouched failure observations
# before any stop (k165).
settings_expect_front() {
    local front=0 title=0
    settings_koine_in_front "$1" || front=$?
    [[ "${front}" == 0 || "${front}" == 1 ]] || settings_stop "${front}" "$2: the front window could not be read"
    settings_title_audit "$1" "${SETTINGS_LIST}" || title=$?
    if [[ "${front}" == 1 || "${title}" == 1 ]]; then
        settings_return_observations "$1"
    fi
    # An unavailable audit keeps its status, even beside a false front (k162).
    [[ "${title}" == 0 || "${title}" == 1 ]] ||
        settings_stop "${title}" "$2: ${SETTINGS_FRONT}; the title audit of $1 is unavailable"
    [[ "${front}" == 0 ]] || settings_fail_as not-front "$2: ${SETTINGS_FRONT}"
    [[ "${title}" == 0 ]] ||
        settings_require_as window-identity "${title}" "$2: the front list has not exactly one \"${WINDOW_TITLE}\" window in front: ${SETTINGS_FRONT}"
}

# --- the positive setup and the returns --------------------------------------

# settings_record_textedit: after the TextEdit preparation, its PID and the
# frame of its one window. The frame comes from the list of the textedit-front
# read, so no window read is added.
settings_record_textedit() {
    local record
    settings_state textedit-prepared '[.windows[] | select(.appName == "TextEdit")] | length == 1' \
        "${SETTINGS_LIST}" ||
        settings_require_as setup-failed "$?" "TextEdit has not exactly one window after its preparation"
    SETTINGS_TEXTEDIT_FRAME="$(jq -c '[.windows[] | select(.appName == "TextEdit")][0]
        | [.positionX, .positionY, .sizeWidth, .sizeHeight]' <<<"${SETTINGS_LIST}")" ||
        settings_local_failure textedit-frame "the TextEdit frame could not be decoded"
    record="$(check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll textedit-pid '.selected | length == 1' \
        process textedit)" ||
        settings_require_as setup-failed "$?" "TextEdit does not run as one process after its preparation"
    SETTINGS_TEXTEDIT_PID="$(jq -r '.selected[0]' <<<"${record}")"
    echo "TextEdit: PID ${SETTINGS_TEXTEDIT_PID}, window frame ${SETTINGS_TEXTEDIT_FRAME}"
}

# settings_expect_setup OPERATION LIST: the positive setup before one of the
# four Settings selections over TextEdit, with no added wait. LIST is the
# zero-count list of the close check, so no window read is added. A clean
# mismatch is failed setup. Missing or unreadable evidence is unavailable.
settings_expect_setup() {
    local operation="$1" list="$2"
    jq -e 'all(.windows[] | select(.appName == "TextEdit"); has("title"))' >/dev/null <<<"${list}" ||
        settings_local_failure "${operation}-setup-title" \
            "a TextEdit window in the zero-count list has no title, so the setup is unavailable"
    settings_state "${operation}-setup-windows" "([.windows[] | select(.appName == \"${SETTINGS_APP}\")] | length) == 0
        and ([.windows[] | select(.appName == \"TextEdit\")] | length) == 1
        and ([.windows[] | select(.appName == \"TextEdit\")][0]
            | .windowType == \"standard\" and .title == \"Untitled\"
            and [.positionX, .positionY, .sizeWidth, .sizeHeight] == ${SETTINGS_TEXTEDIT_FRAME})" "${list}" ||
        settings_require_as setup-failed "$?" \
            "before ${operation}, the list shows a Koine window, or not one standard Untitled TextEdit window at ${SETTINGS_TEXTEDIT_FRAME}"
    check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll "${operation}-setup-front" \
        ".value == [\"TextEdit\", ${SETTINGS_TEXTEDIT_PID}]" front-process >/dev/null ||
        settings_require_as setup-failed "$?" "before ${operation}, TextEdit (PID ${SETTINGS_TEXTEDIT_PID}) is not the front process"
    check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll "${operation}-setup-sheets" \
        '.value == [["AXStandardWindow"], [[]]]' textedit-windows >/dev/null ||
        settings_require_as setup-failed "$?" "before ${operation}, TextEdit shows a dialog, a sheet or another window"
    # The protocol's oracle: no menu under any TextEdit item or Koine's item.
    check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll "${operation}-setup-menus" \
        '(.value[1] | all(length == 0)) and (.value[2] | length == 0)' menu-bar-menus >/dev/null ||
        settings_require_as setup-failed "$?" "before ${operation}, a TextEdit or Koine menu is open"
    settings_capture "setup-${operation}"
}

# settings_pre_click_identity OPERATION: one identity read before a return's
# menu opens. SETTINGS_PRE_IDENTITY keeps its process entry.
settings_pre_click_identity() {
    local record
    record="$(confirm_guest_launch "${KOINE_VM_EVIDENCE_ROOT}" "$1-identity")" ||
        settings_require_as setup-failed "$?" "before $1, the descriptor does not name one installed Koine process"
    SETTINGS_PRE_IDENTITY="$(jq -c '.process' <<<"${record}")"
}

# settings_select_return OPERATION TITLE: a Settings or status-line selection,
# by the existing physical route. The route adds the row's enabled state and a
# screenshot of the open menu before the click. The item's frame, the derived
# points, the display size and each input keep their receipts.
settings_select_return() {
    local operation="$1" title="$2" record
    settings_open_menu "${operation}"
    record="$(await_guest_menu_frame "${KOINE_VM_EVIDENCE_ROOT}" "${operation}-row" "${title}")" ||
        settings_stop "$?" "the menu has no item \"${title}\""
    check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll "${operation}-enabled" '.value == true' \
        menu-row-enabled "${title}" >/dev/null ||
        settings_require_as menu-item-disabled "$?" "the menu item \"${title}\" is not enabled"
    settings_capture "menu-${operation}"
    echo "Menu item \"${title}\": enabled, frame $(jq -r '.text' <<<"${record}")"
    click_centre "$(jq -r '.text' <<<"${record}")" ||
        settings_stop "$?" "the click on the menu item \"${title}\" was not delivered cleanly"
    settings_sleep "${operation}" 2
}

# settings_menu_closed OPERATION: 0 when Koine's item exposes no menu after
# the click, 1 when it exposes one. Any other status is already recorded.
settings_menu_closed() {
    check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll "$1-menu-closed" '.value | length == 0' \
        koine-menus >/dev/null
}

# settings_return_observations OPERATION: the untouched failure capture of a
# failed assertion, after a return's liveness read and before any latch from
# this scenario. One read with the independent observer, one window list in
# the evidence class and one screenshot. A failed observer keeps its own
# receipt, and its text is never used. SETTINGS_OBSERVED_FRONT keeps the
# observer's value. Before the Automation check passes, the observer is NOT
# RUN: it cannot succeed, and its Apple event can raise the consent prompt.
settings_return_observations() {
    SETTINGS_OBSERVED_FRONT="unavailable"
    if [[ -n "${SETTINGS_OBSERVER_READY}" ]]; then
        SETTINGS_OBSERVED_FRONT="$(settings_front_application "$1-front-application")" ||
            SETTINGS_OBSERVED_FRONT="unavailable"
    else
        SETTINGS_OBSERVED_FRONT="not run"
        echo "NOT RUN: the failure observer was not run, because the System Events Automation check has not passed" >&2
    fi
    read_guest_windows "${KOINE_VM_EVIDENCE_ROOT}" evidence "$1-failure-windows" >/dev/null || :
    settings_failure_capture
    SETTINGS_OBSERVED=1
}

# settings_return_classify OPERATION ROUTE OUTCOME MESSAGE [PREDICATE]: after
# the observations, a menu selection reads its menu once more. With PREDICATE,
# the deferred exhaustion receipt of the count poll follows that read, because
# the receipt latches the root. An open menu makes the outcome unresolved.
# Then the classified failure ends the scenario.
settings_return_classify() {
    local status=0
    [[ "$2" != menu ]] || settings_menu_closed "$1" || status=$?
    settings_record_exhaustion "$1" "${5-}"
    [[ "${status}" != 1 ]] || settings_fail_as menu-open "$4; the menu stayed open, so the outcome is unresolved"
    [[ "${status}" == 0 ]] ||
        settings_stop "${status}" "$4; the closed-menu read is unavailable, so the outcome is unresolved"
    settings_fail_as "$3" "$4"
}

# settings_record_exhaustion OPERATION [PREDICATE]: the deferred receipt of a
# return's count poll, under the facade's own name. It latches the root.
settings_record_exhaustion() {
    [[ -z "$2" ]] ||
        record_guest_poll "${KOINE_VM_EVIDENCE_ROOT}" "$1-window-exhausted" exhausted 1 "$2" || :
}

# settings_expect_return OPERATION MESSAGE {menu,reopen}: the window came back,
# one and front and focused, and titled. The count poll defers its exhaustion,
# so that a zero-window failure can still read the liveness of the process of
# SETTINGS_PRE_IDENTITY. A menu return then reads its closed menu. The caller
# takes the outcome screenshot.
settings_expect_return() {
    local operation="$1" message="$2" route="$3" status=0 list count pid front=0 title=0 predicate
    # A deferred exhaustion prints the final clean list that it judged.
    list="$(await_guest_window_count "${KOINE_VM_EVIDENCE_ROOT}" "${operation}-window" "${SETTINGS_APP}" 1 \
        deferred)" || status=$?
    if [[ "${status}" == 1 ]]; then
        count="$(jq --arg app "${SETTINGS_APP}" '[.windows[] | select(.appName == $app)] | length' \
            <<<"${list}" 2>/dev/null)" || count=unknown
        [[ -n "${count}" ]] || count=unknown
        predicate="$(window_count_predicate "${SETTINGS_APP}" 1)" || predicate='count == 1'
        pid="$(jq -r '.pid' <<<"${SETTINGS_PRE_IDENTITY}")"
        if [[ "${count}" == 0 ]]; then
            status=0
            check_guest_read "${KOINE_VM_EVIDENCE_ROOT}" read-poll "${operation}-liveness" \
                ".process == ${SETTINGS_PRE_IDENTITY}" process-identity "${pid}" >/dev/null || status=$?
            settings_return_observations "${operation}"
            case "${status}" in
            0) settings_return_classify "${operation}" "${route}" zero-window-same-process \
                "Koine has 0 windows, not 1, and the same Koine process (PID ${pid}) still runs; front application: ${SETTINGS_OBSERVED_FRONT}" \
                "${predicate}" ;;
            1)
                # A lost process has no menu to read.
                settings_record_exhaustion "${operation}" "${predicate}"
                settings_fail_as process-lost \
                    "process lost during selection: Koine has 0 windows, and PID ${pid} no longer names the process ${SETTINGS_PRE_IDENTITY}"
                ;;
            *)
                settings_record_exhaustion "${operation}" "${predicate}"
                settings_stop "${status}" \
                    "Koine has 0 windows, not 1, and its liveness is unavailable, so the outcome is unresolved"
                ;;
            esac
        fi
        settings_return_observations "${operation}"
        if [[ "${count}" == unknown ]]; then
            settings_record_exhaustion "${operation}" "${predicate}"
            settings_local_failure "${operation}-window-count" "the last count list could not be read, so the outcome is unresolved"
        fi
        settings_return_classify "${operation}" "${route}" multiple-windows \
            "Koine has ${count} windows, not 1; front application: ${SETTINGS_OBSERVED_FRONT}" "${predicate}"
    fi
    [[ "${status}" == 0 ]] || settings_stop "${status}" "the window count of ${operation} could not be read"
    settings_koine_in_front "${operation}-front" || front=$?
    [[ "${front}" == 0 || "${front}" == 1 ]] || settings_stop "${front}" "$2: the front window could not be read"
    settings_title_audit "${operation}-front" "${SETTINGS_LIST}" || title=$?
    if [[ "${front}" == 1 ]]; then
        settings_return_observations "${operation}"
        # An unavailable audit keeps its status, even beside a false front (k162).
        [[ "${title}" == 0 || "${title}" == 1 ]] || settings_stop "${title}" \
            "${message}: ${SETTINGS_FRONT}; the title audit of ${operation} is unavailable, so the outcome is unresolved"
        settings_return_classify "${operation}" "${route}" not-front \
            "${message}: ${SETTINGS_FRONT}; front application: ${SETTINGS_OBSERVED_FRONT}"
    fi
    if [[ "${title}" == 1 ]]; then
        settings_return_observations "${operation}"
        settings_return_classify "${operation}" "${route}" window-identity \
            "${message}: the front list has not exactly one \"${WINDOW_TITLE}\" window in front: ${SETTINGS_FRONT}"
    fi
    [[ "${title}" == 0 ]] || settings_stop "${title}" "the title audit of ${operation} is unavailable"
    if [[ "${route}" == menu ]]; then
        status=0
        settings_menu_closed "${operation}" || status=$?
        [[ "${status}" == 0 ]] ||
            settings_require_as menu-open "${status}" "the menu stayed open after ${operation}, so the outcome is unresolved"
    fi
}

# --- elements of a window ------------------------------------------------------

# settings_element OPERATION CONDITION REQUIREMENT [WINDOW]: one element read.
settings_element() {
    read_guest_element "${KOINE_VM_EVIDENCE_ROOT}" "$1" "${4:-${SETTINGS_APP}}" "$2" "$3"
}

# settings_on_screen OPERATION CONDITION: the element exists and lies wholly
# inside the window frame last read. 1 is a clean off-screen or absent result.
settings_on_screen() {
    local element
    element="$(settings_element "$1" "$2" optional-vertical)" || return
    settings_state "$1" "(. != null) and .positionY >= $((FRAME_Y + TITLE_BAR))
        and (.positionY + .sizeHeight) <= ${BOTTOM}" "${element}"
}

# settings_scroll_by OPERATION DY: one scroll at the window centre.
settings_scroll_by() {
    settings_input "$1" scroll $((FRAME_X + FRAME_W / 2)) $((FRAME_Y + FRAME_H / 2)) "--dy=$2"
    settings_sleep "$1" 1
}

# Which sign of --dy moves content towards the end. Natural scrolling makes this
# a setting, so it is measured on an element rather than assumed.
settings_calibrate_window_scroll() {
    local before after moved index element
    settings_read_frame calibrate-frame
    element="$(settings_element calibrate-before '.id=="grant-label"' position-y)" ||
        settings_stop "$?" "the calibration element could not be read"
    before="$(jq -r '.positionY' <<<"${element}")"
    settings_scroll_by calibrate-scroll -10
    element="$(settings_element calibrate-after '.id=="grant-label"' position-y)" ||
        settings_stop "$?" "the calibration element could not be read again"
    after="$(jq -r '.positionY' <<<"${element}")"
    moved="$(jq -n "${after} < ${before}")" ||
        settings_local_failure calibrate-compare "the calibration positions could not be compared"
    if [[ "${moved}" == true ]]; then SCROLL_END=-10; else SCROLL_END=10; fi
    echo "grant-label at y=${before} moved to y=${after} under --dy -10; towards the end is --dy ${SCROLL_END}"
    for ((index = 1; index <= 30; index++)); do
        settings_scroll_by "calibrate-back-${index}" $((-SCROLL_END))
    done
}

# settings_reveal OPERATION CONDITION: scroll until the element is wholly on screen.
settings_reveal() {
    local operation="$1" condition="$2" index status element y below
    settings_read_frame "${operation}-frame"
    for ((index = 1; index <= 60; index++)); do
        status=0
        settings_on_screen "${operation}-${index}" "${condition}" || status=$?
        case "${status}" in
        0) return 0 ;;
        1) ;; # A clean negative may proceed to the existing scroll decision.
        *) settings_stop "${status}" "the element ${condition} could not be read" ;;
        esac
        element="$(settings_element "${operation}-${index}-position" "${condition}" position-y)" ||
            settings_stop "$?" "no UI element matches: ${condition}"
        y="$(jq -r '.positionY' <<<"${element}")"
        below="$(jq -n "${y} > ${FRAME_Y} + ${FRAME_H} / 2")" ||
            settings_local_failure "${operation}-${index}-compare" "the reveal position could not be compared"
        if [[ "${below}" == true ]]; then
            settings_scroll_by "${operation}-${index}-scroll" "${SCROLL_END}"
        else
            settings_scroll_by "${operation}-${index}-scroll" $((-SCROLL_END))
        fi
    done
    # The untouched failure observations precede the latch (k165).
    settings_failure_observations "${operation}"
    record_guest_poll "${KOINE_VM_EVIDENCE_ROOT}" "${operation}-exhausted" exhausted 1 \
        "scrolling did not bring ${condition} on screen" || settings_stop "$?" "scrolling did not bring ${condition} on screen"
}

# settings_click OPERATION CONDITION [WINDOW]: an element of Koine's window is
# first scrolled wholly on screen. Another window's element is clicked as read.
# The checked click keeps the legacy two seconds after it.
settings_click() {
    local window="${3:-${SETTINGS_APP}}"
    [[ "${window}" != "${SETTINGS_APP}" ]] || settings_reveal "$1-reveal" "$2"
    click_guest_element "${KOINE_VM_EVIDENCE_ROOT}" "$1" "${window}" "$2" ||
        settings_stop "$?" "the click on $2 was not delivered cleanly"
}

# settings_reveal_click OPERATION CONDITION: as before, the reveal runs twice.
settings_reveal_click() {
    settings_reveal "$1-first-reveal" "$2"
    settings_click "$1" "$2"
}

# settings_expect_value OPERATION CONDITION VALUE MESSAGE: one value read. A
# failed AX copy omits the value, and that is unavailable, never empty.
settings_expect_value() {
    local element expected
    element="$(settings_element "$1" "$2" value)" || settings_stop "$?" "$4"
    expected="$(jq -cn --arg value "$3" '$value')"
    settings_state "$1" ".value == ${expected}" "${element}" || settings_require "$?" "$4"
}

# --- Accessibility consent ---------------------------------------------------

# Consent is System Settings' to record: Add, authenticate, and choose the
# installed bundle, as scripts/vm-verify-desktop-lib.sh grant_accessibility.
settings_grant_accessibility() {
    local tries element status
    open_guest_accessibility_pane "${KOINE_VM_EVIDENCE_ROOT}" accessibility-pane ||
        settings_stop "$?" "the Accessibility pane was not opened cleanly"
    # The pane takes a while to load. A missing tree is unavailable, not empty.
    for ((tries = 1; ; tries++)); do
        element="$(settings_element "accessibility-add-${tries}" '.role=="button" and .label=="Add"' \
            optional "${SETTINGS_PANE_WINDOW}")" ||
            settings_stop "$?" "the Accessibility pane could not be read"
        status=0
        settings_state "accessibility-add-${tries}" '. != null' "${element}" || status=$?
        [[ "${status}" != 0 ]] && [[ "${status}" != 1 ]] &&
            settings_stop "${status}" "the Accessibility pane could not be read"
        [[ "${status}" == 0 ]] && break
        if ((tries >= 15)); then
            settings_fail "the Accessibility pane did not show its Add button"
        fi
        settings_sleep "accessibility-add-${tries}" 2
    done
    settings_click accessibility-add '.role=="button" and .label=="Add"' "${SETTINGS_PANE_WINDOW}"
    settings_sleep accessibility-add 2
    settings_input consent-password type "${VM_PASSWORD}"
    settings_input consent-password-submit key return
    settings_sleep consent-password-submit 4
    settings_input consent-go-to-folder key g --modifiers cmd,shift
    settings_sleep consent-go-to-folder 2
    settings_input consent-bundle-path type "${INSTALLED}"
    settings_sleep consent-bundle-path 2
    settings_input consent-path-submit key return
    settings_sleep consent-path-submit 2
    settings_input consent-add-submit key return
    settings_sleep consent-add-submit 3
    element="$(settings_element accessibility-koine '.label=="Koine" or .value=="Koine"' \
        optional "${SETTINGS_PANE_WINDOW}")" ||
        settings_stop "$?" "the Accessibility list could not be read"
    settings_state accessibility-koine '. != null' "${element}" ||
        settings_require "$?" "Koine is not in the Accessibility list"
    settings_input consent-settings-quit key q --modifiers cmd
    settings_sleep consent-settings-quit 2
}
