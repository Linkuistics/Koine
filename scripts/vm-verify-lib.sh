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
# Notification banners ("Login Item Added") cover the top-right of the screen
# and swallow clicks; keep the window at the top-left.
place_window() {
    local tries=0
    until element '.id=="grant-label"' 2>/dev/null | grep -q '^{'; do
        tries=$((tries + 1))
        [ "${tries}" -lt 15 ] || fail "the management window did not appear"
        sleep 2
    done
    testanyware agent window-move --window "${APP_NAME}" --x 40 --y 40 >/dev/null
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

launch() {
    # The agent's false timeout comes in bursts that can outlast guest's retries.
    # What follows proves the launch: the window, then the endpoint descriptor.
    guest "open ${INSTALLED}" || true
    place_window
    for _ in $(seq 1 12); do
        if guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1; then return; fi
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

quit_koine() {
    testanyware agent window-focus --window "${APP_NAME}" >/dev/null
    sleep 1
    testanyware input key q --modifiers cmd >/dev/null
    sleep 3
    guest "! pgrep -f ${INSTALLED}" >/dev/null || fail "Koine still runs after Quit"
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
