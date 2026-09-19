#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM, the
# client-requested grant workflow through the real UI, as the bootstrap of the
# first management client: a guest client makes its own secret and asks for
# koine:manage and the desktop capabilities; the window shows its label, code,
# exact capability set and the koine:manage warning without user action; a
# subset is approved there, deliberately; the client, its secret unchanged, then
# manages Koine over HTTP and approves a second client; a third is denied in the
# window; and all of it survives quitting and restarting Koine. No credential is
# typed, pasted, shown or brought to the host. Nothing here runs the application
# on the host. The procedure and its recorded evidence:
# docs/verification/grant-enrollment-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="enrollment-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh

# For guest_json.
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

# shellcheck disable=SC2016  # guest-side $HOME
FIRST='$HOME/koine-secret-first' SECOND='$HOME/koine-secret-second' THIRD='$HOME/koine-secret-third'
MANAGE_WARNING="permits issuing and revoking other grants"

# enrollee <secret file> <case> [argument...]: the guest client; its one JSON
# line is left in ANSWER.
enrollee() {
    local file="$1"
    shift
    ANSWER="$(guest_json "python3 \$HOME/vm-verify-enrollment-client.py \"${file}\" $*")" ||
        fail "the enrollment client printed no JSON for: $*"
    echo "${ANSWER}"
}
# expect <jq condition on ANSWER> <what failed>
expect() { jq -e "$1" >/dev/null <<<"${ANSWER}" || fail "$2"; }
# enrol <secret file> <label> <capability>...: leaves REQUEST_ID and CODE.
enrol() {
    enrollee "$@"
    expect '.status == 200 and ((.response.errors // []) | length == 0)' "enrollment was refused"
    REQUEST_ID="$(jq -r .response.data.koineRequestGrant.requestId <<<"${ANSWER}")"
    CODE="$(jq -r .response.data.koineRequestGrant.comparisonCode <<<"${ANSWER}")"
}
expect_state() {
    enrollee "$1" poll
    expect ".response.data.koineGrantRequest.state == \"$2\"" "the client's poll does not say $2"
}
# The secret confers no management: a permission error and no data.
expect_no_management() {
    enrollee "$1" manage
    expect '.response.data.koineManagement == null and .response.errors[0].extensions.kind == "permission"' \
        "$2 reached koineManagement"
}
# await_element <jq condition> <present|absent>: the window polls every two
# seconds; nothing is clicked or focused to make it look.
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
# shown_capabilities <request id>: the capabilities the window offers to tick.
shown_capabilities() {
    snapshot | jq -c --arg p "request-capability-$1-" \
        '[.. | objects | select((.id // "") | startswith($p)) | .id[($p | length):]] | unique'
}
# The window's whole accessibility tree, searched in the guest for the client's
# secret and its digest, so that neither comes to the host.
expect_secret_not_shown() {
    snapshot >"${WORK}/window.json"
    testanyware file upload "${WORK}/window.json" /Users/admin/koine-window.json >/dev/null
    # shellcheck disable=SC2016  # guest-side $HOME
    enrollee "$1" shown-in '"$HOME/koine-window.json"'
    expect '.bytes > 1000 and .secret == false and .digest == false' "the window shows the client's secret or digest"
}

start_vm
install_app
testanyware file upload scripts/vm-verify-enrollment-client.py /Users/admin/vm-verify-enrollment-client.py >/dev/null

step "Start Koine: no grant exists and no request is waiting"
launch
await_element '.id=="requests-empty"' present
guest "[ ! -e \"${FIRST}\" ]" || fail "a secret file already exists"

step "A client makes its own secret and asks for koine:manage and the desktop capabilities"
enrol "${FIRST}" enrol first-manager koine:manage desktop:read desktop:control
FIRST_ID="${REQUEST_ID}" FIRST_CODE="${CODE}"
guest "ls -l \"${FIRST}\""
expect_state "${FIRST}" PENDING
expect_no_management "${FIRST}" "a pending request's secret"
# Control for the search below: it finds the secret in the secret's own file.
enrollee "${FIRST}" shown-in "\"${FIRST}\""
expect '.secret == true' "the secret search cannot find a secret"

step "The window shows the request, with no user action: label, code, exact capability set, warning"
await_element ".id==\"request-${FIRST_ID}\"" present
testanyware screen capture -o "${LOG%.log}-request.png" >/dev/null
echo "Label: $(value_of ".id==\"request-label-${FIRST_ID}\"")  Code: $(value_of ".id==\"request-code-${FIRST_ID}\"")  Client's code: ${FIRST_CODE}"
[ "$(value_of ".id==\"request-label-${FIRST_ID}\"")" = first-manager ] || fail "the window shows another label"
[ "$(value_of ".id==\"request-code-${FIRST_ID}\"")" = "${FIRST_CODE}" ] || fail "the window's code is not the client's"
SHOWN="$(shown_capabilities "${FIRST_ID}")"
echo "Capabilities offered: ${SHOWN}"
[ "${SHOWN}" = '["desktop:control","desktop:read","koine:manage"]' ] || fail "the window does not offer exactly the requested set"
for capability in koine:manage desktop:read desktop:control; do
    [ "$(value_of ".id==\"request-capability-${FIRST_ID}-${capability}\"")" = 1 ] || fail "${capability} does not start ticked"
done
WARNING="$(text_of ".id==\"request-manage-warning-${FIRST_ID}\"")"
echo "Warning: ${WARNING}"
grep -q "${MANAGE_WARNING}" <<<"${WARNING}" || fail "no koine:manage warning on the request"
expect_secret_not_shown "${FIRST}"

step "Untick desktop:control; Approve alone decides nothing while koine:manage is ticked"
click ".id==\"request-capability-${FIRST_ID}-desktop:control\""
[ "$(value_of ".id==\"request-capability-${FIRST_ID}-desktop:control\"")" = 0 ] || fail "desktop:control did not untick"
click ".id==\"approve-${FIRST_ID}\""
await_element '.role=="button" and .label=="Approve with koine:manage"' present
testanyware screen capture -o "${LOG%.log}-manage-confirmation.png" >/dev/null
expect_state "${FIRST}" PENDING
# The approving button is not the default one: Return leaves the request
# pending. The dialog has no default button, so Return leaves it up as well.
testanyware input key return >/dev/null
sleep 2
expect_state "${FIRST}" PENDING
testanyware input key escape >/dev/null
await_element '.role=="button" and .label=="Approve with koine:manage"' absent
expect_state "${FIRST}" PENDING

step "Approve the subset, confirming koine:manage"
click ".id==\"approve-${FIRST_ID}\""
click '.role=="button" and .label=="Approve with koine:manage"'
await_element ".id==\"request-${FIRST_ID}\"" absent
expect_state "${FIRST}" APPROVED
expect '.response.data.koineGrantRequest.grant | .state == "ACTIVE" and (.capabilities | sort) == ["desktop:read","koine:manage"]' \
    "the grant is not the approved subset"
FIRST_GRANT="$(jq -r .response.data.koineGrantRequest.grant.grantId <<<"${ANSWER}")"
await_element ".id==\"grant-${FIRST_GRANT}\"" present
echo "Grant row: $(element ".id==\"grant-${FIRST_GRANT}\"" | jq -c '[.children[] | .value // .label]')"

step "The client, its secret unchanged, manages Koine over HTTP"
enrollee "${FIRST}" own
expect ".response.data.koine.ownGrant.grantId == \"${FIRST_GRANT}\"" "the secret is not its grant's bearer"
enrollee "${FIRST}" manage
expect "(.response.errors // []) | length == 0" "the first manager was refused koineManagement"
expect ".response.data.koineManagement.requests | map(select(.requestId == \"${FIRST_ID}\"))[0].state == \"APPROVED\"" \
    "the manager does not see its own request approved"

step "A second client asks; the window shows it; the first manager approves it over GraphQL"
enrol "${SECOND}" enrol second-client desktop:read
SECOND_ID="${REQUEST_ID}"
await_element ".id==\"request-${SECOND_ID}\"" present
expect_no_management "${SECOND}" "a pending request's secret"
enrollee "${FIRST}" approve "${SECOND_ID}" desktop:read
expect '.response.data.koineApproveGrantRequest | .state == "ACTIVE" and .capabilities == ["desktop:read"]' \
    "the first manager's approval did not make the grant"
SECOND_GRANT="$(jq -r .response.data.koineApproveGrantRequest.grantId <<<"${ANSWER}")"
expect_state "${SECOND}" APPROVED
await_element ".id==\"request-${SECOND_ID}\"" absent
expect_no_management "${SECOND}" "a grant without koine:manage"

step "A third client asks for koine:manage and is denied in the window"
enrol "${THIRD}" enrol third-client koine:manage
THIRD_ID="${REQUEST_ID}"
await_element ".id==\"request-${THIRD_ID}\"" present
grep -q "${MANAGE_WARNING}" <<<"$(text_of ".id==\"request-manage-warning-${THIRD_ID}\"")" || fail "no koine:manage warning on the third request"
click ".id==\"deny-${THIRD_ID}\""
await_element ".id==\"request-${THIRD_ID}\"" absent
expect_state "${THIRD}" DENIED
expect '.response.data.koineGrantRequest.grant == null' "a denied request has a grant"
expect_no_management "${THIRD}" "a denied request's secret"
await_element '.id=="requests-empty"' present

step "Quit and restart Koine: the grants and the decisions are still there"
quit_koine
launch
await_element '.id=="requests-empty"' present
enrollee "${FIRST}" manage
expect "(.response.errors // []) | length == 0" "the first manager was refused after the restart"
expect ".response.data.koineManagement.requests | map({(.requestId): .state}) | add == {\"${FIRST_ID}\": \"APPROVED\", \"${SECOND_ID}\": \"APPROVED\", \"${THIRD_ID}\": \"DENIED\"}" \
    "the decisions did not survive the restart"
expect ".response.data.koineManagement.grants | map({(.grantId): [.state, (.capabilities | sort)]}) | add == {\"${FIRST_GRANT}\": [\"ACTIVE\", [\"desktop:read\",\"koine:manage\"]], \"${SECOND_GRANT}\": [\"ACTIVE\", [\"desktop:read\"]]}" \
    "the grants did not survive the restart"
enrollee "${SECOND}" own
expect ".response.data.koine.ownGrant.grantId == \"${SECOND_GRANT}\"" "the second client's secret stopped working"
expect_state "${THIRD}" DENIED
await_element ".id==\"grant-${FIRST_GRANT}\"" present
expect_secret_not_shown "${FIRST}"
testanyware screen capture -o "${LOG%.log}-after-restart.png" >/dev/null

step "PASSED — transcript in ${LOG}"
