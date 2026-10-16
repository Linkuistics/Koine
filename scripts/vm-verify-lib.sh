# shellcheck shell=bash
# shellcheck disable=SC2016,SC2034  # guest-side $HOME; variables the sourcing script uses
# Sourced by the VM verification scripts (vm-verify.sh, vm-verify-providers.sh),
# after scripts/signing-env.sh and from the repository root: the clean
# TestAnyware clone, its transcript, guest execution, and driving Koine's window.
# KOINE_VM_LOG_PREFIX names the transcript. The TestAnyware workarounds here are
# explained in docs/verification/resident-app-vm.md.

# KOINE_VM_NO_APP=1 is for the runs that prepare or inspect a guest and install no
# Koine (vm-prepare-launchers.sh): they need the clone and the helpers, not the build.
if [ "${KOINE_VM_NO_APP:-0}" != 1 ] && [ ! -d "${APP_BUNDLE}" ]; then
    echo "Error: ${APP_BUNDLE} does not exist. Run: task app" >&2
    exit 1
fi
for tool in testanyware jq ditto; do
    if ! command -v "${tool}" >/dev/null; then
        echo "Error: ${tool} is not on PATH." >&2
        exit 1
    fi
done

WORK="$(mktemp -d)"
LOG_DIR=".build/vm-verify"
mkdir -p "${LOG_DIR}"
LOG="${LOG_DIR}/${KOINE_VM_LOG_PREFIX:-}$(date +%Y%m%dT%H%M%S).log"
exec > >(tee "${LOG}") 2>&1

VM_ID="${KOINE_VM_ID:-koine-verify-$$}"
export TESTANYWARE_VM_ID="${VM_ID}"
INSTALLED="/Applications/${APP_NAME}.app"
# The settings window's title, which is also what the agent matches --window against.
WINDOW_TITLE="${APP_NAME} Settings"
DATA='$HOME/Library/Application Support/Koine'
CREDENTIAL_FILE='$HOME/koine-credential'
GRANT_LABEL="vm-script"

step() { printf '\n== %s\n' "$*"; }
fail() {
    echo "FAILED: $*" >&2
    testanyware screen capture -o "${LOG%.log}-failure.png" >/dev/null 2>&1 || true
    exit 1
}
# Runs a command in the guest. Observed with this TestAnyware agent: about half
# of all execs, `true` included, run to completion and are then reported as
# "Process timed out after 30s" with status 255. Every command here is safe to
# repeat, so that one answer is retried; anything else is the command's own.
# Six tries were exhausted about once in a run of sixty execs, on commands that
# never reach Koine as well as ones that do, so the bound is twelve.
guest() {
    local out status
    for _ in 1 2 3 4 5 6 7 8 9 10 11 12; do
        status=0
        out="$(testanyware file exec "$1" 2>&1)" || status=$?
        if [ "${status}" = 255 ] && grep -q 'Process timed out after 30s' <<<"${out}"; then
            continue
        fi
        # 7 is testanyware's CONNECTION_TIMEOUT: the agent was not reached at all.
        if [ "${status}" = 7 ]; then
            sleep 5
            continue
        fi
        [ -z "${out}" ] || echo "${out}"
        return "${status}"
    done
    echo "guest exec kept timing out: $1" >&2
    [ -z "${out}" ] || echo "${out}" >&2
    return 255
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
# guest_long <name> <local script>: runs a script that outlasts the agent's 30s
# exec window — a Homebrew install, a cask download — detached in the guest, and
# polls for its exit status. Its transcript is echoed into this run's log, and
# its status is returned. guest() silently retries an exec that falsely times
# out, and these scripts can not be repeated: one run's reinstall was launched
# twice, and the second `brew install` truncated the log to "Not upgrading
# koine". So the launch takes a guard directory, and a retried launch that finds
# it already taken starts nothing.
guest_long() {
    local name="$1" script="$2" status
    testanyware file upload "${script}" "/Users/admin/${name}.sh" >/dev/null
    guest "mkdir \$HOME/${name}.started 2>/dev/null || exit 0; nohup bash -c 'bash \$HOME/${name}.sh > \$HOME/${name}.log 2>&1; echo \$? > \$HOME/${name}.exit' >/dev/null 2>&1 &"
    for _ in $(seq 1 180); do
        if guest "[ -e \$HOME/${name}.exit ]" >/dev/null 2>&1; then break; fi
        sleep 5
    done
    guest "cat \$HOME/${name}.log" | sed 's/^/  | /'
    status="$(guest "cat \$HOME/${name}.exit" 2>/dev/null | tr -d '[:space:]')"
    [ -n "${status}" ] || fail "${name} did not finish within 15 minutes"
    return "${status}"
}

cleanup() {
    [ -z "${VNC_KEEPALIVE_PID:-}" ] || kill "${VNC_KEEPALIVE_PID}" 2>/dev/null || true
    rm -rf "${WORK}"
    if [ "${KOINE_VM_KEEP:-0}" = 1 ]; then
        echo "VM ${VM_ID} left running. Stop it with: testanyware vm stop ${VM_ID}"
    else
        testanyware vm stop "${VM_ID}" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

# The accessibility tree of Koine's windows, deep enough to reach a grant row's
# children. SwiftUI controls here refuse `agent press` (HTTP 400), so elements
# are found semantically and clicked over VNC at their centre, re-read each time.
# SNAPSHOT_WINDOW names another application's window for the helpers below.
snapshot() { testanyware agent snapshot --mode full --window "${SNAPSHOT_WINDOW:-${APP_NAME}}" --depth 14 --json; }
element() {
    snapshot | jq -c "[.. | objects | select(has(\"platformRole\")) | select($1)][0]"
}
value_of() { element "$1" | jq -r '.value // empty'; }
click() {
    local e
    # Koine's window is a frame around content that outgrows it, and the
    # tree reports scrolled-out elements too; a click at one's centre lands on
    # the title bar or the wallpaper. So an element of Koine's window is first
    # scrolled wholly on screen. Another application's window is clicked as read.
    [ -n "${SNAPSHOT_WINDOW:-}" ] || reveal "$1"
    e="$(element "$1")"
    [ "${e}" != null ] || fail "no UI element matches: $1"
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '"\(.positionX + .sizeWidth / 2 | floor) \(.positionY + .sizeHeight / 2 | floor)"' <<<"${e}") >/dev/null
    sleep 2
}
# await_element <jq condition> <present|absent>: the window polls on its own;
# nothing is clicked or focused to make it look.
await_element() {
    for _ in $(seq 1 10); do
        if [ "$(element "$1")" != null ]; then
            [ "$2" = absent ] || return 0
        else
            [ "$2" = present ] || return 0
        fi
        sleep 2
    done
    fail "window element $1 was not $2"
}
text_of() { element "$1" | jq -r '[.. | strings] | join(" ")'; }
# The settings window opens at 480x680 around scrolling content (the grant form's
# disclosures make it longer than the frame), and no check resizes it except
# vm-verify-menu-bar.sh, so an element is on screen, and clickable, only when its
# frame lies inside the window's. The accessibility tree reports an element that
# is scrolled out of view as well, so what a person can see is decided by
# geometry, not by the tree's membership.
TITLE_BAR=30
read_frame() {
    local entry
    entry="$(testanyware agent windows --json |
        jq -c --arg title "${WINDOW_TITLE}" '[.windows[] | select((.title // .name // "") == $title)][0]')"
    read -r FRAME_X FRAME_Y FRAME_W FRAME_H <<<"$(jq -r \
        '[(.positionX // .x // .bounds.x), (.positionY // .y // .bounds.y),
          (.sizeWidth // .width // .bounds.width), (.sizeHeight // .bounds.height // .height)]
         | map(if type == "number" then floor else . end) | join(" ")' <<<"${entry}")"
    case "${FRAME_H}" in '' | null) fail "the window's frame could not be read from the agent: ${entry}" ;; esac
    BOTTOM=$((FRAME_Y + FRAME_H))
}
# on_screen <jq condition>: the element exists and lies wholly inside the window.
on_screen() {
    local e
    e="$(element "$1")"
    [ "${e}" != null ] || return 1
    jq -e --argjson top "$((FRAME_Y + TITLE_BAR))" --argjson bottom "${BOTTOM}" \
        '.positionY >= $top and (.positionY + .sizeHeight) <= $bottom' >/dev/null <<<"${e}"
}
# Which sign of --dy moves content towards the end. Natural scrolling makes this
# a setting, so it is measured on an element rather than assumed.
SCROLL_END=-10
scroll_by() {
    testanyware input scroll $((FRAME_X + FRAME_W / 2)) $((FRAME_Y + FRAME_H / 2)) "--dy=$1" >/dev/null
    sleep 1
}
calibrate_window_scroll() {
    local before after
    read_frame
    before="$(element '.id=="grant-label"' | jq -r '.positionY')"
    scroll_by -10
    after="$(element '.id=="grant-label"' | jq -r '.positionY')"
    if [ "$(jq -n "${after} < ${before}")" = true ]; then SCROLL_END=-10; else SCROLL_END=10; fi
    echo "grant-label at y=${before} moved to y=${after} under --dy -10; towards the end is --dy ${SCROLL_END}"
    for _ in $(seq 1 30); do scroll_by $((-SCROLL_END)); done
}
# reveal <jq condition>: scroll until the element is wholly on screen.
reveal() {
    local e y
    read_frame
    for _ in $(seq 1 60); do
        if on_screen "$1"; then return 0; fi
        e="$(element "$1")"
        [ "${e}" != null ] || fail "no UI element matches: $1"
        y="$(jq -r '.positionY' <<<"${e}")"
        if [ "$(jq -n "${y} > ${FRAME_Y} + ${FRAME_H} / 2")" = true ]; then
            scroll_by "${SCROLL_END}"
        else
            scroll_by $((-SCROLL_END))
        fi
    done
    fail "scrolling did not bring $1 on screen"
}
# reveal_click <jq condition>: scroll the element on screen, then click it.
reveal_click() {
    reveal "$1"
    click "$1"
}
# show_window: the settings window is on screen, however Koine was launched. A
# launch finding setup complete opens none (the launch rule), and `open` of the
# running bundle is a reopen, which shows it, so a check that needs the window
# asks for it here instead of waiting for one. The window can come up late after
# a first launch, so the reopen is repeated rather than awaited once.
show_window() {
    local windows
    for _ in $(seq 1 12); do
        windows="$(koine_windows 2>/dev/null || true)"
        if [[ "${windows}" =~ ^[1-9] ]]; then return 0; fi
        guest "open ${INSTALLED}" || true
        sleep 5
    done
    fail "the settings window did not appear"
}
# Notification banners ("Login Item Added") cover the top-right of the screen
# and swallow clicks; keep the window at the top-left.
place_window() {
    local tries=0
    show_window
    # More patience than a launch usually needs: after a quarantined first launch
    # the window came up well after the endpoint descriptor, and a run was failed
    # for a window whose failure screenshot showed it present and rendered.
    until element '.id=="grant-label"' 2>/dev/null | grep -q '^{'; do
        tries=$((tries + 1))
        [ "${tries}" -lt 45 ] || fail "the settings window did not show its controls"
        sleep 2
    done
    testanyware agent window-move --window "${WINDOW_TITLE}" --x 40 --y 40 >/dev/null
    testanyware agent window-focus --window "${APP_NAME}" >/dev/null
    sleep 1
}
# client [query]: the default query is the client script's own.
client() { guest "bash \$HOME/vm-verify-client.sh \"${CREDENTIAL_FILE}\" '${1:-}'" || true; }
expect_status() {
    local out
    out="$(client)"
    echo "${out}"
    grep -qx "HTTP $1" <<<"${out}" || fail "the client script expected HTTP $1"
}

# launch: starts Koine, waits for its endpoint descriptor, and leaves the settings
# window shown and placed, as every check that drives it expects.
launch() {
    # The agent's false timeout comes in bursts that can outlast guest's retries.
    # What follows proves the launch: the endpoint descriptor, then the window.
    guest "open ${INSTALLED}" || true
    for _ in $(seq 1 12); do
        if guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1; then
            place_window
            return
        fi
        sleep 2
    done
    fail "no endpoint descriptor after launch"
}
# ask <query>: prints the response and leaves it in RESPONSE; HTTP 200 expected.
ask() {
    RESPONSE="$(client "$1")"
    echo "${RESPONSE}"
    grep -qx "HTTP 200" <<<"${RESPONSE}" || fail "expected HTTP 200 for: $1"
}

# quit_koine: ⌘Q from the settings window, which is shown first when setup left
# it closed. Quit Koine in the menu bar item's menu is choose_menu_item.
quit_koine() {
    show_window
    testanyware agent window-focus --window "${APP_NAME}" >/dev/null
    sleep 1
    testanyware input key q --modifiers cmd >/dev/null
    sleep 3
    guest "! pgrep -f ${INSTALLED}" >/dev/null || fail "Koine still runs after Quit"
}
# quit_koine_or_terminate: the end of a run that records rather than fails: ⌘Q from
# the window up to three times, then the process is terminated and that is said.
quit_koine_or_terminate() {
    for _ in 1 2 3; do
        show_window
        testanyware agent window-focus --window "${APP_NAME}" >/dev/null 2>&1 || true
        sleep 1
        testanyware input key q --modifiers cmd >/dev/null || true
        sleep 3
        guest "! pgrep -f ${INSTALLED}" >/dev/null 2>&1 && return
    done
    echo "Koine did not quit on Command-Q three times; terminated (recorded, not an acceptance case)."
    guest "pkill -f ${INSTALLED}" || true
}

start_vm() {
    step "Start a clean VM (${VM_ID})"
    # KOINE_VM_DISPLAY overrides the guest's resolution. Only the notarized run
    # needs it, to put a control far below the fold of a System Settings pane on
    # screen at all; every other run takes testanyware's default.
    # KOINE_VM_BASE clones a prepared tart image instead of the platform's golden.
    testanyware vm start --platform macos --id "${VM_ID}" \
        ${KOINE_VM_BASE:+--base "${KOINE_VM_BASE}"} \
        ${KOINE_VM_DISPLAY:+--display "${KOINE_VM_DISPLAY}"} >/dev/null
    # On a macOS 27 host, Virtualization.framework's VNC server (which tart serves
    # the guest's screen through) hits an assertion in
    # -[_VZVirtualMachineAccessor addAccessorObserver:] when a client connects
    # after about 60s with none, and takes tart and the guest down with it. A run
    # waits that long whenever it polls a cask install over the agent alone, so a
    # background capture keeps the server from going idle until cleanup stops it.
    ( while sleep 20; do
        testanyware screen capture -o "${WORK}/keepalive.png" >/dev/null 2>&1 || true
    done ) >/dev/null 2>&1 &
    VNC_KEEPALIVE_PID=$!
    disown "${VNC_KEEPALIVE_PID}"
    guest 'sw_vers; uname -m'
    echo "Gatekeeper: $(guest 'spctl --status' 2>&1 || true)"
}

install_app() {
    step "Install the signed bundle (ditto zip, testanyware file upload, ditto -x)"
    ditto -c -k --keepParent "${APP_BUNDLE}" "${WORK}/Koine.zip"
    testanyware file upload "${WORK}/Koine.zip" /tmp/Koine.zip >/dev/null
    # The guest's /tmp does not survive the restart below; its home directory does.
    testanyware file upload scripts/vm-verify-client.sh /Users/admin/vm-verify-client.sh >/dev/null
    guest "ditto -x -k /tmp/Koine.zip /Applications"
    # Stated, not worked around: this route sets no quarantine attribute, so
    # Gatekeeper's first-launch check is not exercised here.
    echo "Quarantine attribute: $(guest "xattr -p com.apple.quarantine ${INSTALLED} 2>&1 || true")"
    guest "codesign --verify --strict --deep --verbose=2 ${INSTALLED} 2>&1" || fail "the VM rejects the signature"
    guest "codesign --display --verbose=2 ${INSTALLED} 2>&1 | grep -E '^(Identifier|TeamIdentifier|Authority=Developer|CodeDirectory)'"
    guest "spctl -a -vv ${INSTALLED} 2>&1" || echo "(spctl assessment did not accept the bundle; recorded, not a failure of this stage)"
}

# The menu bar item and the settings window of the agent application. TestAnyware's
# agent lists windows but not status items, so the item is read and its menu opened
# through System Events (osascript in the guest), and chosen the way a user does:
# the mouse over VNC. System Events asks, once per clone, whether the agent may
# control it; grant_system_events_automation answers that prompt.
KOINE_ITEM='menu bar item 1 of menu bar 2 of process "Koine"'
# sysevents <AppleScript expression>: its value, as osascript prints it. An empty
# answer is "no such element" as often as "nothing", so callers that need to tell
# them apart poll.
sysevents() {
    local script="tell application \"System Events\" to $1"
    guest_text "osascript -e '${script}'" | tr -d '\r'
}
# The first System Events call of a clone raises a macOS Automation prompt naming
# "testanyware-agent" and blocks until it is answered. It is started in the
# background and the prompt's Allow button is clicked, as a user would.
grant_system_events_automation() {
    guest "nohup osascript -e 'tell application \"System Events\" to get name of every process' >/dev/null 2>&1 &" || true
    local found
    found="$(testanyware screen find-text "Allow" --timeout 30 --json 2>/dev/null |
        jq -c '[.detections[] | select(.text == "Allow")][0]')" || true
    [ -n "${found}" ] && [ "${found}" != null ] || fail "the Automation prompt for System Events did not appear"
    # shellcheck disable=SC2046
    testanyware input click $(jq -r '"\(.x + .width / 2 | floor) \(.y + .height / 2 | floor)"' <<<"${found}") >/dev/null
    sleep 2
    [ -n "$(sysevents 'get name of every process')" ] || fail "System Events still refuses the agent"
}
# click_at <x> <y>: a menu tracks the pointer, and a click with no movement before
# it chooses nothing, so the pointer is brought onto the target first.
click_at() {
    testanyware input move $(($1 - 12)) $(($2 - 8)) >/dev/null
    sleep 0.3
    testanyware input move "$1" "$2" >/dev/null
    sleep 0.3
    testanyware input click "$1" "$2" >/dev/null
    sleep 1
}
# click_centre <"x, y, w, h" as System Events prints position then size>
click_centre() {
    local x y w h
    IFS=', ' read -r x y w h <<<"$(tr -s ', ' ' ' <<<"$1")"
    [[ "${x}${y}${w}${h}" =~ ^[0-9]+$ ]] || fail "not a frame: $1"
    click_at $((x + w / 2)) $((y + h / 2))
}
# menu_item_count: how many items Koine has in the menu bar. One, always.
menu_item_count() { sysevents "get count of menu bar items of menu bar 2 of process \"Koine\""; }
# menu_item_label: the item's accessibility description, which is what VoiceOver
# reads and what states the mark.
menu_item_label() { sysevents "get description of ${KOINE_ITEM}"; }
await_menu_item_label() {
    local got=""
    for _ in $(seq 1 15); do
        got="$(menu_item_label)"
        [ "${got}" != "$1" ] || return 0
        sleep 2
    done
    fail "the menu bar item's label is \"${got}\", not \"$1\""
}
# open_menu: click the item; the menu stays open until a choice or escape.
open_menu() {
    local frame="" tries=0
    until [[ "${frame}" =~ ^[0-9] ]]; do
        tries=$((tries + 1))
        [ "${tries}" -lt 6 ] || fail "Koine's menu bar item has no position"
        frame="$(sysevents "get {position, size} of ${KOINE_ITEM}")"
        [[ "${frame}" =~ ^[0-9] ]] || sleep 2
    done
    click_centre "${frame}"
}
# menu_titles: the titles of the open menu's items, separators as empty ones.
menu_titles() { sysevents "get title of every menu item of menu 1 of ${KOINE_ITEM}"; }
# read_menu: the menu's titles, read open and closed again.
read_menu() {
    open_menu
    MENU="$(menu_titles)"
    echo "Menu: ${MENU}"
    testanyware input key escape >/dev/null
    sleep 1
}
# choose_menu_item <title>: open the menu and click the item.
choose_menu_item() {
    open_menu
    local frame=""
    for _ in $(seq 1 5); do
        frame="$(sysevents "get {position, size} of menu item \"$1\" of menu 1 of ${KOINE_ITEM}")"
        [[ "${frame}" =~ ^[0-9] ]] && break
        sleep 1
    done
    [[ "${frame}" =~ ^[0-9] ]] || fail "the menu has no item \"$1\""
    click_centre "${frame}"
    sleep 2
}
# koine_windows: the number of Koine windows on screen.
koine_windows() {
    testanyware agent windows --json |
        jq --arg app "${APP_NAME}" '[.windows[] | select(.appName == $app)] | length'
}
await_windows() {
    local got=""
    for _ in $(seq 1 10); do
        got="$(koine_windows)"
        [ "${got}" != "$1" ] || return 0
        sleep 2
    done
    fail "Koine has ${got} windows, not $1"
}
# front_windows: the windows front to back, as the agent lists them, without the
# widgets and banners Notification Center keeps on screen (a "Login Item Added"
# banner is a window of its own, and in front of everything while it shows).
front_windows() {
    testanyware agent windows --json |
        jq -c '[.windows[] | select(.appName != "Notification Center") | [.appName, .title, .focused]]'
}
# koine_in_front: Koine's window is the front window and the key one.
koine_in_front() {
    front_windows | jq -e --arg app "${APP_NAME}" '.[0] | .[0] == $app and .[2] == true' >/dev/null
}
# drag_window_corner <x> <y> [title]: a user's resize, the pointer taking the
# window's bottom-right corner to that point. `agent window-resize` is not that: it
# sets the frame by accessibility and is not held to the window's least size, which
# a drag is.
drag_window_corner() {
    local frame x y w h
    frame="$(testanyware agent windows --json | jq -r --arg title "${3:-${WINDOW_TITLE}}" \
        '[.windows[] | select(.title == $title)][0] | "\(.positionX | floor) \(.positionY | floor) \(.sizeWidth | floor) \(.sizeHeight | floor)"')"
    read -r x y w h <<<"${frame}"
    testanyware input move $((x + w - 1)) $((y + h - 1)) >/dev/null
    sleep 0.5
    testanyware input mouse-down $((x + w - 1)) $((y + h - 1)) >/dev/null
    testanyware input mouse-up "$1" "$2" >/dev/null
    sleep 1
}
# guest_once <command>: a command that must run exactly once. `open` of a running
# Koine is a reopen, which shows the settings window, so a launch that must stay
# silent cannot be repeated by guest()'s retry of the agent's false timeout; what
# follows the launch (await_koine) proves it happened.
guest_once() { testanyware file exec "$1" >/dev/null 2>&1 || true; }
