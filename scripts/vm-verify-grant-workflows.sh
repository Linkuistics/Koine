#!/bin/bash
# Release acceptance, grant-workflow half: both agreed grant workflows run end to
# end against the NOTARIZED, stapled, QUARANTINED Koine.app in ONE TestAnyware
# macOS session on a Gatekeeper-ENFORCING clone, together with the things
# docs/verification/grant-enrollment-vm.md explicitly did not drive — a refusal
# shown in the window, several requests pending at once with the window scrolled
# to reach one, the two enrollment limits crossed, and an enrolled grant revoked
# through the window with its credential refused afterwards on the connection
# that had just been served and again after a restart.
#
# Covered: the user-created grant handed to a script and the client that enrols
# itself and is approved in the window, the latter with no credential typed,
# pasted or shown; a pending requester unable to approve itself, enumerate
# others or reach a provider operation while it reads its own request;
# `already-decided` composed into the window's own sentence, with both lists
# re-read afterwards; sixteen pending requests, HTTP 429 with Retry-After past
# the rate limit and `pending-request-limit` past the pending cap; revocation of
# an enrolled grant in the window, refused on the same TCP connection that had
# just been served; and both workflows across a restart of Koine.
#
# Nothing here runs the application on the host, and no credential reaches the
# host: the manual workflow's delivery is the GUEST's clipboard, which is where
# Koine's Copy button puts it, and the enrolling clients keep their secrets in
# 0600 files of their own. The procedure and its recorded evidence:
# docs/verification/grant-workflow-acceptance-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# Before a VM is spun. This run exists to assess the RELEASE artifact; against an
# unnotarized bundle the Gatekeeper posture below would refuse it at first
# launch, which says nothing about either grant workflow.
if ! xcrun stapler validate "${APP_BUNDLE}" >/dev/null 2>&1; then
    {
        echo "Error: ${APP_BUNDLE} carries no stapled notarization ticket."
        echo "  Grant-workflow acceptance is run on the release artifact. Run: task app && task app:notarize"
    } >&2
    exit 1
fi

# shellcheck disable=SC2034  # both read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="grant-workflows-"
# Tall enough that the Security section of the Privacy & Security pane is on
# screen; vm-verify-gatekeeper-lib.sh's enable_developer_id explains why that is
# the mechanism rather than scrolling. Koine's own window is unaffected: it is a
# fixed frame whose scrolling content area is 480x680, and a taller screen does
# not grow it, which is what makes the scrolling case below real.
# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_DISPLAY="1920x2160"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-verify-gatekeeper-lib.sh
source scripts/vm-verify-gatekeeper-lib.sh

# The guest's files. Each enrolling client's secret is its own; the batch clients
# keep theirs, and their cached answers, under one directory.
# shellcheck disable=SC2016  # guest-side $HOME, expanded in the guest
MANAGER='$HOME/koine-secret-manager'
# shellcheck disable=SC2016
REFUSED='$HOME/koine-secret-refused'
# shellcheck disable=SC2016
PENDING='$HOME/koine-secret-pending'
# shellcheck disable=SC2016
KEEPALIVE='$HOME/koine-secret-keepalive'
# shellcheck disable=SC2016
BATCH_DIR='$HOME/koine-batch'
MANAGE_WARNING="permits issuing and revoking other grants"
# The two limits this run crosses, as Sources/KoineCore/RequestPolicy.swift
# states them. They are named here so that a policy change makes this run say
# so rather than quietly measuring something else.
PENDING_CAP=16
ENROLMENTS_PER_WINDOW=10

# ---------------------------------------------------------------------------
# Local helpers. The enrollment client's wrappers are copied from
# scripts/vm-verify-enrollment.sh rather than pushed into a shared library, for
# platform-acceptance-k42's reason: that script is a route that passes and this
# leaf cannot re-run it, so nothing it depends on is changed here.

# enrollee <secret file> <case> [argument...]: the guest enrollment client; its
# one JSON line is left in ANSWER.
enrollee() {
    local file="$1"
    shift
    ANSWER="$(guest_json "python3 \$HOME/vm-verify-enrollment-client.py \"${file}\" $*")" ||
        fail "the enrollment client printed no JSON for: $*"
    echo "${ANSWER}"
}
# workflow <case> [argument...]: this run's own guest client, same contract.
workflow() {
    ANSWER="$(guest_json "python3 \$HOME/vm-verify-grant-workflow-client.py $*")" ||
        fail "the grant-workflow client printed no JSON for: $*"
    echo "${ANSWER}"
}
# enrol <secret file> <label> <capability>...: leaves REQUEST_ID and CODE.
enrol() {
    enrollee "$1" enrol "${@:2}"
    expect '.status == 200 and ((.response.errors // []) | length == 0)' "enrollment was refused"
    REQUEST_ID="$(jq -r .response.data.koineRequestGrant.requestId <<<"${ANSWER}")"
    CODE="$(jq -r .response.data.koineRequestGrant.comparisonCode <<<"${ANSWER}")"
}
expect_state() {
    enrollee "$1" poll
    expect ".response.data.koineGrantRequest.state == \"$2\"" "the client's poll does not say $2"
}
# The window's whole accessibility tree, searched in the guest for a client's
# secret and its digest, so that neither comes to the host.
expect_secret_not_shown() {
    snapshot >"${WORK}/window.json"
    testanyware file upload "${WORK}/window.json" /Users/admin/koine-window.json >/dev/null
    # shellcheck disable=SC2016  # guest-side $HOME
    enrollee "$1" shown-in '"$HOME/koine-window.json"'
    expect '.bytes > 1000 and .secret == false and .digest == false' "the window shows the client's secret or digest"
}
# The pending request rows the window is showing now, one request id per line.
# The row's own identifier is `request-<uuid>`; the label, code, capability and
# warning identifiers inside it are matched out by the UUID shape rather than by
# a list of prefixes, which would go stale the moment a row gains a control.
pending_rows() {
    snapshot | jq -r '[.. | objects | .id // empty
                      | select(test("^request-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"))
                      | .[8:]] | unique | .[]'
}
# read_frame: Koine's window on screen, into FRAME_X/Y/W/H and BOTTOM. The raw
# entry goes to the transcript too: the field spellings are the agent's, and a
# run that cannot read them should say what it was given rather than guess.
read_frame() {
    local entry
    entry="$(testanyware agent windows --json |
        jq -c --arg name "${APP_NAME}" '[.windows[] | select(((.title // .name // "")) | test($name))][0]')"
    echo "Koine's window: ${entry}"
    # Floored: these become shell arithmetic below, where a fractional point
    # coordinate is a syntax error rather than a rounding question.
    read -r FRAME_X FRAME_Y FRAME_W FRAME_H <<<"$(jq -r \
        '[(.positionX // .x // .bounds.x), (.positionY // .y // .bounds.y),
          (.sizeWidth // .width // .bounds.width), (.sizeHeight // .height // .bounds.height)]
         | map(if type == "number" then floor else . end) | join(" ")' <<<"${entry}")"
    case "${FRAME_H}" in '' | null) fail "the window's frame could not be read from the agent" ;; esac
    BOTTOM=$((FRAME_Y + FRAME_H))
}
# The pending rows a user can actually reach at this scroll position: those whose
# Deny button lies wholly inside the window's frame. The accessibility tree
# reports a row that is scrolled out of view as well, which is why reachability
# is decided by geometry here and not by the tree's membership.
# TITLE_BAR is subtracted from the top because a row scrolled under the title bar
# is not reachable, and the frame the agent reports includes it.
TITLE_BAR=30
visible_rows() {
    snapshot | jq -r --argjson top "$((FRAME_Y + TITLE_BAR))" --argjson bottom "${BOTTOM}" \
        '[.. | objects | select(((.id // "") | startswith("deny-")))
          | select(.positionY >= $top and (.positionY + .sizeHeight) <= $bottom)
          | .id[5:]] | unique | .[]'
}
# `--dy=<n>`, never `--dy <n>`: the value is negative for half the calls here and
# the argument parser reads a bare `-10` as a cluster of short flags, which ended
# a run with "unexpected argument '-1' found".
scroll_window() {
    testanyware input scroll $((FRAME_X + FRAME_W / 2)) $((FRAME_Y + FRAME_H / 2)) "--dy=$1" >/dev/null
    sleep 1
}
# Which sign of --dy moves the content towards the end of the list. Natural
# scrolling makes this a setting rather than a constant, so it is measured on a
# row that is on screen instead of assumed: a run that assumed it and was wrong
# would report "scrolling did not reach the row" about the wrong thing entirely.
SCROLL_TOWARDS_END=-10
calibrate_scroll() {
    local anchor row before after
    row="$(visible_rows | head -1)"
    [ -n "${row}" ] || fail "no pending row is on screen to calibrate scrolling against"
    anchor=".id==\"deny-${row}\""
    before="$(element "${anchor}" | jq -r '.positionY')"
    scroll_window -10
    after="$(element "${anchor}" | jq -r '.positionY')"
    if [ "$(jq -n "${after} < ${before}")" = true ]; then
        SCROLL_TOWARDS_END=-10
    else
        SCROLL_TOWARDS_END=10
    fi
    echo "A row at y=${before} moved to y=${after} under --dy -10; towards the end of the list is --dy ${SCROLL_TOWARDS_END}"
}
scroll_to_top() {
    local _
    for _ in $(seq 1 25); do
        testanyware input scroll $((FRAME_X + FRAME_W / 2)) $((FRAME_Y + FRAME_H / 2)) "--dy=$((-SCROLL_TOWARDS_END))" >/dev/null
    done
    sleep 1
}
# read_as <credential file> [query]: the client script under a credential, with
# the tolerance for the agent's false timeouts that the library's own ask() has
# but without its habit of ending the run — the status is the caller's to judge.
# Leaves the status in STATUS and the response body in BODY.
read_as() {
    local out
    for _ in 1 2 3 4 5; do
        out="$(guest "bash \$HOME/vm-verify-client.sh \"$1\" '${2:-}'" 2>&1 || true)"
        STATUS="$(grep -m1 -o 'HTTP [0-9]*' <<<"${out}" | cut -d' ' -f2 || true)"
        if [ -n "${STATUS}" ]; then
            BODY="$(grep -m1 '^{' <<<"${out}" || true)"
            echo "${out}"
            return 0
        fi
        sleep 3
    done
    echo "${out}"
    fail "the client script never printed a status for: ${2:-<default query>}"
}
# count_lines <text>: how many non-empty lines, and 0 for nothing at all — which
# `wc -l <<<""` gets wrong, and every assertion below is a count.
count_lines() { printf '%s\n' "$1" | sed '/^$/d' | wc -l | tr -d ' '; }
# label_of <batch answer> <request id>: which bulk client made that request.
label_of() {
    jq -r --arg id "$2" '[.results[] | select(.requestId == $id)][0].label // empty' <<<"$1"
}

# ---------------------------------------------------------------------------

start_vm
enforce_gatekeeper
install_app_quarantined
testanyware file upload scripts/vm-verify-enrollment-client.py /Users/admin/vm-verify-enrollment-client.py >/dev/null
testanyware file upload scripts/vm-verify-grant-workflow-client.py /Users/admin/vm-verify-grant-workflow-client.py >/dev/null
first_launch_quarantined
await_service

step "Workflow 1: the user creates a grant in the window and hands it to a script"
await_element '.id=="requests-empty"' present
create_grant "${GRANT_LABEL}" "${CREDENTIAL_FILE}" desktop:read
read_as "${CREDENTIAL_FILE}"
[ "${STATUS}" = 200 ] || fail "the manually created credential was refused (HTTP ${STATUS})"
MANUAL="$(jq -c '.data.koine.ownGrant | [.clientLabel, (.capabilities | sort), .state]' <<<"${BODY}")"
echo "The script's grant: ${MANUAL}"
[ "${MANUAL}" = "[\"${GRANT_LABEL}\",[\"desktop:read\"],\"ACTIVE\"]" ] ||
    fail "the manually created grant is not the one the window was asked for"

step "Workflow 2: a client enrols itself and is approved in the window, with nothing typed, pasted or shown"
enrol "${MANAGER}" first-manager koine:manage desktop:read desktop:control
MANAGER_ID="${REQUEST_ID}" MANAGER_CODE="${CODE}"
expect_state "${MANAGER}" PENDING
await_element ".id==\"request-${MANAGER_ID}\"" present
echo "Label: $(value_of ".id==\"request-label-${MANAGER_ID}\"")  Code: $(value_of ".id==\"request-code-${MANAGER_ID}\"")  Client's code: ${MANAGER_CODE}"
[ "$(value_of ".id==\"request-code-${MANAGER_ID}\"")" = "${MANAGER_CODE}" ] || fail "the window's code is not the client's"
grep -q "${MANAGE_WARNING}" <<<"$(text_of ".id==\"request-manage-warning-${MANAGER_ID}\"")" || fail "no koine:manage warning"
expect_secret_not_shown "${MANAGER}"
click ".id==\"request-capability-${MANAGER_ID}-desktop:control\""
click ".id==\"approve-${MANAGER_ID}\""
click '.role=="button" and .label=="Approve with koine:manage"'
await_element ".id==\"request-${MANAGER_ID}\"" absent
expect_state "${MANAGER}" APPROVED
expect '.response.data.koineGrantRequest.grant | .state == "ACTIVE" and (.capabilities | sort) == ["desktop:read","koine:manage"]' \
    "the enrolled grant is not the approved subset"
MANAGER_GRANT="$(jq -r .response.data.koineGrantRequest.grant.grantId <<<"${ANSWER}")"
await_element ".id==\"grant-${MANAGER_GRANT}\"" present
enrollee "${MANAGER}" manage
expect '(.response.errors // []) | length == 0' "the enrolled manager was refused koineManagement"

step "A pending requester reads its own request and nothing else"
enrol "${PENDING}" pending-client desktop:read
PENDING_ID="${REQUEST_ID}"
await_element ".id==\"request-${PENDING_ID}\"" present
workflow forbidden "\"${PENDING}\"" "${PENDING_ID}"
expect '.probes["own-request"].status == 200 and .probes["own-request"].data.koineGrantRequest.state == "PENDING"' \
    "a pending requester cannot read its own request"
expect '.probes["approve-itself"].status == 403 and (.probes["approve-itself"].kinds | index("permission"))' \
    "a pending requester approved itself"
expect '.probes.enumerate.status == 200 and .probes.enumerate.data.koineManagement == null and (.probes.enumerate.kinds | index("permission"))' \
    "a pending requester enumerated the management lists"
expect '.probes.provider.status == 200 and .probes.provider.data.desktopApplicationByReference == null and (.probes.provider.kinds | index("permission"))' \
    "a pending requester reached a provider operation"
expect '.probes["own-grant"].status == 200 and .probes["own-grant"].data.koine.ownGrant == null' \
    "a pending requester has a grant"

step "A refusal in the window: the request is decided over GraphQL while the confirmation stands"
# The order is forced by the UI rather than raced against the window's
# two-second poll. Clicking Approve on a request that asks for koine:manage
# raises RequestReviewView's confirmation and sends Koine nothing; the request it
# will decide is held by value, so the decision made below lands squarely between
# the window's read and the click that reaches the server.
enrol "${REFUSED}" refused-client koine:manage
REFUSED_ID="${REQUEST_ID}"
await_element ".id==\"request-${REFUSED_ID}\"" present
click ".id==\"approve-${REFUSED_ID}\""
await_element '.role=="button" and .label=="Approve with koine:manage"' present
testanyware screen capture -o "${LOG%.log}-before-refusal.png" >/dev/null
echo "The confirmation is up and Koine has been sent nothing:"
expect_state "${REFUSED}" PENDING
workflow deny-pending "\"${MANAGER}\"" pending-client
# Asserted on the state afterwards rather than on what this call changed: the
# agent repeats an exec it falsely reports as timed out, and the repeat has
# nothing left to deny. A run died on exactly that, reporting "the manager
# denied no such request" about a denial that had already happened.
expect '.listErrors == [] and (.listStatus | unique) == [200]' "the manager could not read the request list"
expect '.states["refused-client"] == "DENIED"' "the request was not denied over GraphQL"
expect '.states["pending-client"] == "PENDING"' "the request that was to be left alone was decided"
expect_state "${REFUSED}" DENIED
click '.role=="button" and .label=="Approve with koine:manage"'
await_element '.id=="requests-problem"' present
# The element's `value`, not `text_of`: that helper joins every string in the
# element, so the id and the platform role arrive in front of the sentence and no
# equality against it can hold. The other reads here use it with `grep`, which is
# why the difference had not shown up before.
PROBLEM="$(element '.id=="requests-problem"' | jq -r '.value // .label // empty')"
echo "The window says: ${PROBLEM}"
[ -n "${PROBLEM}" ] || fail "the window's refusal element carries no text"
testanyware screen capture -o "${LOG%.log}-refusal.png" >/dev/null
# shellcheck disable=SC1111  # the window composes typographic quotes, and that is what is checked
[ "${PROBLEM}" = "“refused-client” was not approved: it is already denied." ] ||
    fail "the window composed another sentence from already-decided: ${PROBLEM}"
# Its re-read of both lists, which is the half KoineManagementClientTests cannot
# show: the refused request is gone from the pending list, and no grant was made.
await_element ".id==\"request-${REFUSED_ID}\"" absent
enrollee "${REFUSED}" poll
expect '.response.data.koineGrantRequest.state == "DENIED" and .response.data.koineGrantRequest.grant == null' \
    "the refused request has a grant"
enrollee "${MANAGER}" manage
expect "[.response.data.koineManagement.grants[] | .clientLabel] | sort == [\"first-manager\",\"${GRANT_LABEL}\"]" \
    "the grant list gained or lost a grant across the refusal"
echo "Pending rows after the re-read: $(pending_rows | tr '\n' ' ')"
[ "$(pending_rows | wc -l | tr -d ' ')" = 1 ] || fail "the window's pending list is not just the one undecided request"

step "Restart Koine: both workflows persist, and the in-memory enrollment budget refills"
quit_koine
launch
read_as "${CREDENTIAL_FILE}" >/dev/null
[ "${STATUS}" = 200 ] || fail "the manually created credential stopped working across the restart (HTTP ${STATUS})"
enrollee "${MANAGER}" own
expect ".response.data.koine.ownGrant.grantId == \"${MANAGER_GRANT}\"" "the enrolled secret stopped working across the restart"
enrollee "${MANAGER}" manage
expect '.response.data.koineManagement.requests | map({(.clientLabel): .state}) | add
        == {"first-manager": "APPROVED", "pending-client": "PENDING", "refused-client": "DENIED"}' \
    "the decisions did not survive the restart"
await_element ".id==\"request-${PENDING_ID}\"" present

step "Crossing the enrollment rate limit: ${ENROLMENTS_PER_WINDOW} admitted in a window, and the next refused with HTTP 429"
# The budget was refilled by the restart above and nothing else has spent it,
# which is why this can count. One request is already pending, so the batch is
# sized to reach the rate limit and not the pending cap.
workflow batch "\"${BATCH_DIR}\"" bulk 1 $((ENROLMENTS_PER_WINDOW + 1)) desktop:read >/dev/null
BATCH_ONE="${ANSWER}"
jq -c '[.results[] | {label, status, retryAfter, reasons}]' <<<"${BATCH_ONE}"
expect "[.results[] | select(.status == 200 and (.reasons | length) == 0)] | length == ${ENROLMENTS_PER_WINDOW}" \
    "not exactly ${ENROLMENTS_PER_WINDOW} enrollments were admitted in the window"
expect '[.results[] | select(.status == 429)] | length == 1' "the rate limit did not refuse the next enrollment with 429"
expect '[.results[] | select(.status == 429)][0].retryAfter | tonumber > 0' "the 429 carries no positive Retry-After"
echo "Retry-After: $(jq -r '[.results[] | select(.status == 429)][0].retryAfter' <<<"${BATCH_ONE}")s"

step "Waiting out the rate-limit window, then filling the pending cap (${PENDING_CAP}) and crossing it"
sleep 70
# One earlier request is still pending, so fewer are needed to reach the cap.
REMAINING=$((PENDING_CAP - ENROLMENTS_PER_WINDOW - 1))
workflow batch "\"${BATCH_DIR}\"" bulk $((ENROLMENTS_PER_WINDOW + 2)) $((REMAINING + 1)) desktop:read >/dev/null
BATCH_TWO="${ANSWER}"
jq -c '[.results[] | {label, status, retryAfter, reasons}]' <<<"${BATCH_TWO}"
expect "[.results[] | select(.status == 200 and (.reasons | length) == 0)] | length == ${REMAINING}" \
    "the second batch did not fill the pending cap"
expect '[.results[] | select(.reasons | index("pending-request-limit"))] | length == 1' \
    "the pending cap did not refuse the next enrollment"
# The two refusals are different things, and telling them apart is the point: the
# cap is an ordinary 200 carrying a domain reason, with no Retry-After anywhere.
expect '[.results[] | select(.reasons | index("pending-request-limit"))][0] | .status == 200 and .retryAfter == null' \
    "the pending-cap refusal was served as a rate limit"
echo "Pending-cap message: $(jq -r '[.results[] | select(.reasons | index("pending-request-limit"))][0].messages[0]' <<<"${BATCH_TWO}")"

step "The window with ${PENDING_CAP} requests pending together, and scrolling to reach one"
for _ in $(seq 1 20); do
    [ "$(pending_rows | wc -l | tr -d ' ')" = "${PENDING_CAP}" ] && break
    sleep 2
done
echo "Pending request rows in the window's tree: $(pending_rows | wc -l | tr -d ' ')"
read_frame
scroll_to_top
calibrate_scroll
scroll_to_top
TOP_VISIBLE="$(visible_rows)"
TOP_COUNT="$(count_lines "${TOP_VISIBLE}")"
testanyware screen capture -o "${LOG%.log}-many-pending.png" >/dev/null
echo "Rows a user can reach without scrolling: ${TOP_COUNT} of ${PENDING_CAP}"
[ "${TOP_COUNT}" -gt 0 ] || fail "no pending row is reachable at the top of the window"
[ "${TOP_COUNT}" -lt "${PENDING_CAP}" ] ||
    fail "all ${PENDING_CAP} rows fit at once, so this run does not show scrolling to reach one"
# Every one of them is reachable by scrolling, and the union proves the window is
# showing all sixteen rather than only the ones that fit at once.
REACHED="${TOP_VISIBLE}"
for _ in $(seq 1 40); do
    [ "$(count_lines "${REACHED}")" -ge "${PENDING_CAP}" ] && break
    scroll_window "${SCROLL_TOWARDS_END}"
    REACHED="$(printf '%s\n%s\n' "${REACHED}" "$(visible_rows)" | sed '/^$/d' | sort -u)"
done
REACHED_COUNT="$(count_lines "${REACHED}")"
echo "Rows reached by scrolling through the list: ${REACHED_COUNT}"
[ "${REACHED_COUNT}" = "${PENDING_CAP}" ] ||
    fail "only ${REACHED_COUNT} of ${PENDING_CAP} pending rows could be reached in the window"
testanyware screen capture -o "${LOG%.log}-scrolled.png" >/dev/null
# One that was not reachable at the top, and one of the bulk clients so that its
# own poll can confirm the decision: deciding it is what the scrolling was for.
TARGET=""
while read -r candidate; do
    [ -n "$(label_of "${BATCH_TWO}" "${candidate}")$(label_of "${BATCH_ONE}" "${candidate}")" ] || continue
    TARGET="${candidate}"
    break
done < <(comm -13 <(sort <<<"${TOP_VISIBLE}") <(printf '%s\n' "${REACHED}"))
[ -n "${TARGET}" ] || fail "no row of this run's bulk clients needed scrolling to reach"
for _ in $(seq 1 40); do
    grep -qx "${TARGET}" <<<"$(visible_rows)" && break
    scroll_window "${SCROLL_TOWARDS_END}"
done
grep -qx "${TARGET}" <<<"$(visible_rows)" || fail "scrolling did not bring the chosen row onto the screen"
click ".id==\"deny-${TARGET}\""
await_element ".id==\"request-${TARGET}\"" absent
TARGET_LABEL="$(label_of "${BATCH_TWO}" "${TARGET}")"
[ -n "${TARGET_LABEL}" ] || TARGET_LABEL="$(label_of "${BATCH_ONE}" "${TARGET}")"
echo "Denied by scrolling to its row: ${TARGET_LABEL}"
workflow poll "\"${BATCH_DIR}\"" "${TARGET_LABEL}"
expect '.response.data.koineGrantRequest.state == "DENIED"' "the request denied in the window is not denied"

step "Clear the pending list over GraphQL"
workflow deny-pending "\"${MANAGER}\"" >/dev/null
echo "Requests by state afterwards: $(jq -c '[.states[]] | group_by(.) | map({(.[0]): length}) | add' <<<"${ANSWER}")"
expect '.listErrors == [] and .pending == 0' "requests are still pending after every one was denied"
await_element '.id=="requests-empty"' present
scroll_to_top

step "An enrolled grant is revoked in the window, and its credential is refused on the connection just served"
enrol "${KEEPALIVE}" keepalive-client desktop:read
KEEPALIVE_ID="${REQUEST_ID}"
await_element ".id==\"request-${KEEPALIVE_ID}\"" present
click ".id==\"approve-${KEEPALIVE_ID}\""
await_element ".id==\"request-${KEEPALIVE_ID}\"" absent
expect_state "${KEEPALIVE}" APPROVED
KEEPALIVE_GRANT="$(jq -r .response.data.koineGrantRequest.grant.grantId <<<"${ANSWER}")"
await_element ".id==\"grant-${KEEPALIVE_GRANT}\"" present
# The client opens one connection, is served on it, and then waits on a file
# rather than exiting, because a guest exec is one-shot and the revocation
# between its two requests is the host's to make in the window.
# Two execs, and the launch is guarded, because the agent repeats an exec it
# falsely reports as timed out: clearing the files and starting the client in one
# command would let a repeat delete the first client's files under it, and an
# unguarded start would leave two clients racing on one set of them.
# Two execs, and the launch is guarded by an atomic mkdir, because the agent
# repeats an exec it falsely reports as timed out: clearing the files and
# starting the client in one command would let a repeat delete the first
# client's files under it, and an unguarded start would leave two clients racing
# on one set of them. The guard is a directory rather than a pgrep because the
# exec's own shell carries the pattern in its command line and would match it.
guest "rm -rf \$HOME/keepalive.ready \$HOME/keepalive.go \$HOME/keepalive.out \$HOME/keepalive.lock; echo cleared"
guest "if mkdir \$HOME/keepalive.lock 2>/dev/null; then \
nohup python3 \$HOME/vm-verify-grant-workflow-client.py keepalive \"${KEEPALIVE}\" \
\$HOME/keepalive.ready \$HOME/keepalive.go \$HOME/keepalive.out >/dev/null 2>&1 & \
fi; sleep 2; echo started" || true
for _ in $(seq 1 20); do
    # shellcheck disable=SC2016  # guest-side $HOME
    guest '[ -e "$HOME/keepalive.ready" ]' >/dev/null 2>&1 && break
    sleep 2
done
# shellcheck disable=SC2016  # guest-side $HOME
guest '[ -e "$HOME/keepalive.ready" ]' >/dev/null 2>&1 || fail "the keep-alive client was never served on its connection"
click ".id==\"revoke-${KEEPALIVE_GRANT}\""
click '.role=="button" and ((.label // "") | startswith("Revoke "))'
for _ in $(seq 1 20); do
    grep -qi revoked <<<"$(text_of ".id==\"grant-${KEEPALIVE_GRANT}\"")" && break
    sleep 2
done
echo "The grant's row after the window revoked it: $(element ".id==\"grant-${KEEPALIVE_GRANT}\"" | jq -c '[.children[]? | .value // .label]')"
grep -qi revoked <<<"$(text_of ".id==\"grant-${KEEPALIVE_GRANT}\"")" || fail "the window does not show the grant revoked"
testanyware screen capture -o "${LOG%.log}-revoked.png" >/dev/null
# shellcheck disable=SC2016  # guest-side $HOME
guest 'touch "$HOME/keepalive.go"'
for _ in $(seq 1 20); do
    # shellcheck disable=SC2016  # guest-side $HOME
    guest '[ -e "$HOME/keepalive.out" ]' >/dev/null 2>&1 && break
    sleep 2
done
# shellcheck disable=SC2016  # guest-side $HOME
ANSWER="$(guest_json 'cat "$HOME/keepalive.out"')" || fail "the keep-alive client left no answer"
echo "${ANSWER}"
expect '.before.status == 200 and .before.data.koine.ownGrant.state == "ACTIVE"' \
    "the keep-alive client was not served before the revocation"
expect '.sameConnection == true' \
    "the second request went out on another connection, so this shows nothing about a live one"
expect '.after.status == 401 and (.after.authenticate | test("Bearer"))' \
    "the revoked credential was not refused 401 on the connection that had just been served"

step "Across a restart of Koine: the revoked credential is still refused and both workflows still work"
quit_koine
launch
enrollee "${KEEPALIVE}" own
expect '.status == 401' "the revoked credential works again after a restart"
read_as "${CREDENTIAL_FILE}" >/dev/null
[ "${STATUS}" = 200 ] || fail "the manually created credential stopped working (HTTP ${STATUS})"
enrollee "${MANAGER}" manage
expect '(.response.errors // []) | length == 0' "the enrolled manager was refused after the restart"
expect ".response.data.koineManagement.grants | map({(.clientLabel): .state}) | add
        | .[\"${GRANT_LABEL}\"] == \"ACTIVE\" and .[\"first-manager\"] == \"ACTIVE\" and .[\"keepalive-client\"] == \"REVOKED\"" \
    "the grants are not as the window and the revocation left them"
expect '.response.data.koineManagement.requests | map(select(.state == "PENDING")) | length == 0' \
    "requests are still pending after every one was decided"
await_element '.id=="requests-empty"' present
expect_secret_not_shown "${MANAGER}"
testanyware screen capture -o "${LOG%.log}-after-restart.png" >/dev/null

step "Quit Koine"
quit_koine

step "PASSED — transcript in ${LOG}"
