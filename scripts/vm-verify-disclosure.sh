#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM, that the
# native window discloses workspace control's reach wherever a person grants or
# reviews it, and that a koine:manage client is served the same words: the
# create-grant view for a new grant, the request view for a pending request, and
# the grant list for an existing grant, each observed in the window itself and
# compared with what the management client reads over HTTP. A request that asks
# for nothing disclosed shows none, a revoked grant discloses nothing, and a
# restart changes no grant. No credential is typed, pasted, shown or brought to
# the host. Nothing here runs the application on the host. The procedure and its
# recorded evidence: docs/verification/workspace-disclosure-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# shellcheck disable=SC2034  # read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="disclosure-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

# shellcheck disable=SC2016  # guest-side $HOME
MANAGER='$HOME/koine-secret-manager' WORKSPACE='$HOME/koine-secret-workspace'
CAPABILITY="workspace:control"
# What the spec requires the disclosure to state, as phrases of it: any
# registered installed application, document execution and redirects by
# handlers, and both controls.
PHRASES=("any application registered on this Mac" "run a script or follow a location document" "desktop:control")

# Local copies of the enrollment script's wrappers, for the reason the
# grant-workflow script gives: that route passes and is not changed here.
enrollee() {
    local file="$1"
    shift
    ANSWER="$(guest_json "python3 \$HOME/vm-verify-enrollment-client.py \"${file}\" $*")" ||
        fail "the enrollment client printed no JSON for: $*"
    echo "${ANSWER}"
}
expect() { jq -e "$1" >/dev/null <<<"${ANSWER}" || fail "$2"; }
enrol() {
    enrollee "$1" enrol "${@:2}"
    expect '.status == 200 and ((.response.errors // []) | length == 0)' "enrollment was refused"
    REQUEST_ID="$(jq -r .response.data.koineRequestGrant.requestId <<<"${ANSWER}")"
}

# capture <name>: a screenshot of the window as it stands, for the record.
capture() { testanyware screen capture -o "${LOG%.log}-$1.png" >/dev/null; }

# disclosure_of <element id>: the one disclosure text the window shows there,
# whitespace collapsed, after proving the element is on screen.
disclosure_of() {
    reveal ".id==\"$1\""
    element ".id==\"$1\"" | jq -r --arg id "$1" '[.. | strings] | map(select(length > 40 and . != $id)) | first // empty' | tr -s '[:space:]' ' ' | sed 's/ $//'
}
# expect_disclosure <element id> <what>: on screen, in the served words, naming
# everything the spec requires.
expect_disclosure() {
    local shown
    shown="$(disclosure_of "$1")"
    echo "$2: ${shown}"
    [ "${shown}" = "${SERVED}" ] || fail "$2 is not the text koine:manage clients are served"
    for phrase in "${PHRASES[@]}"; do
        grep -qF -- "${phrase}" <<<"${shown}" || fail "$2 does not state: ${phrase}"
    done
}
# no_disclosure <element id> <what>
no_disclosure() {
    [ "$(element ".id==\"$1\"")" = null ] || fail "$2 carries a disclosure it should not"
}

start_vm
install_app
testanyware file upload scripts/vm-verify-enrollment-client.py /Users/admin/vm-verify-enrollment-client.py >/dev/null

step "Start Koine: no grant exists and no request is waiting"
launch
await_element '.id=="requests-empty"' present

step "A manager is enrolled and approved in the window; a request for koine:manage alone shows no disclosure"
enrol "${MANAGER}" disclosure-manager koine:manage
MANAGER_REQUEST="${REQUEST_ID}"
await_element ".id==\"request-${MANAGER_REQUEST}\"" present
no_disclosure "request-disclosure-${MANAGER_REQUEST}-koine:manage" "koine:manage"
click ".id==\"approve-${MANAGER_REQUEST}\""
click '.role=="button" and .label=="Approve with koine:manage"'
await_element ".id==\"request-${MANAGER_REQUEST}\"" absent
enrollee "${MANAGER}" own
MANAGER_GRANT="$(jq -r .response.data.koine.ownGrant.grantId <<<"${ANSWER}")"

step "The management client is served the disclosure: the words the window must then show"
enrollee "${MANAGER}" disclosures
expect '(.response.errors // []) | length == 0' "the manager could not read the disclosures"
expect '.response.data.koineManagement.capabilityDisclosures | length == 1 and .[0].capability == "workspace:control"' \
    "the served disclosures are not exactly workspace:control's"
SERVED="$(jq -r '.response.data.koineManagement.capabilityDisclosures[0].disclosure' <<<"${ANSWER}" | tr -s '[:space:]' ' ' | sed 's/ $//')"
echo "Served: ${SERVED}"
for phrase in "${PHRASES[@]}"; do
    grep -qF -- "${phrase}" <<<"${SERVED}" || fail "the served disclosure does not state: ${phrase}"
done

step "The create-grant view: a new grant, with workspace control offered"
calibrate_window_scroll
reveal ".id==\"capability-${CAPABILITY}\""
capture create-offered
expect_disclosure "disclosure-${CAPABILITY}" "the create-grant view"
for other in koine:manage desktop:read desktop:control workspace:read; do
    [ "$(element ".id==\"capability-${other}\"")" != null ] || fail "${other} is not offered"
    no_disclosure "disclosure-${other}" "${other}"
done
reveal_click '.id=="grant-label"'
testanyware input type "workspace-grant" >/dev/null
reveal_click ".id==\"capability-${CAPABILITY}\""
[ "$(value_of ".id==\"capability-${CAPABILITY}\"")" = 1 ] || fail "workspace:control did not tick"
reveal_click '.id=="capability-desktop:control"'
reveal_click '.role=="button" and .label=="Create Grant"'
await_element '.role=="button" and .label=="Done"' present
click '.role=="button" and .label=="Done"'
enrollee "${MANAGER}" manage
NEW_GRANT="$(jq -r '.response.data.koineManagement.grants | map(select(.clientLabel == "workspace-grant"))[0].grantId' <<<"${ANSWER}")"
expect '.response.data.koineManagement.grants | map(select(.clientLabel == "workspace-grant"))[0] | .state == "ACTIVE" and (.capabilities | sort) == ["desktop:control","workspace:control"]' \
    "the new grant is not workspace:control and desktop:control"

step "The request view: a pending request for workspace control"
enrol "${WORKSPACE}" workspace-client workspace:control desktop:control desktop:read
WS_REQUEST="${REQUEST_ID}"
await_element ".id==\"request-${WS_REQUEST}\"" present
reveal ".id==\"request-disclosure-${WS_REQUEST}-${CAPABILITY}\""
capture request-pending
expect_disclosure "request-disclosure-${WS_REQUEST}-${CAPABILITY}" "the request view"
# Desktop control's expanded reach is window-layout's disclosure, not this one's.
no_disclosure "request-disclosure-${WS_REQUEST}-desktop:control" "desktop:control"
no_disclosure "request-disclosure-${WS_REQUEST}-desktop:read" "desktop:read"
reveal_click ".id==\"approve-${WS_REQUEST}\""
await_element ".id==\"request-${WS_REQUEST}\"" absent
enrollee "${WORKSPACE}" poll
WS_GRANT="$(jq -r .response.data.koineGrantRequest.grant.grantId <<<"${ANSWER}")"
expect '.response.data.koineGrantRequest.grant | .state == "ACTIVE" and (.capabilities | sort) == ["desktop:control","desktop:read","workspace:control"]' \
    "the approved grant is not the requested set"

step "The grant list: both existing grants disclose, and a grant without workspace control does not"
reveal ".id==\"grant-disclosure-${NEW_GRANT}-${CAPABILITY}\""
capture grant-list
expect_disclosure "grant-disclosure-${NEW_GRANT}-${CAPABILITY}" "the new grant's row"
expect_disclosure "grant-disclosure-${WS_GRANT}-${CAPABILITY}" "the approved grant's row"
no_disclosure "grant-disclosure-${MANAGER_GRANT}-koine:manage" "the manager's row"
no_disclosure "grant-disclosure-${WS_GRANT}-desktop:control" "an approved desktop:control"

step "Quit and restart Koine: the existing grants still disclose, and nothing was revoked or reauthorized"
enrollee "${MANAGER}" manage
BEFORE="$(jq -c '.response.data.koineManagement.grants' <<<"${ANSWER}")"
quit_koine
launch
await_element '.id=="requests-empty"' present
enrollee "${MANAGER}" manage
AFTER="$(jq -c '.response.data.koineManagement.grants' <<<"${ANSWER}")"
[ "${BEFORE}" = "${AFTER}" ] || fail "the restart changed the grants: ${BEFORE} -> ${AFTER}"
expect_disclosure "grant-disclosure-${NEW_GRANT}-${CAPABILITY}" "the new grant's row after the restart"
expect_disclosure "grant-disclosure-${WS_GRANT}-${CAPABILITY}" "the approved grant's row after the restart"
capture after-restart

step "A revoked grant holds nothing, so its row discloses nothing"
reveal ".id==\"revoke-${NEW_GRANT}\""
click ".id==\"revoke-${NEW_GRANT}\""
click '.role=="button" and ((.label // "") | startswith("Revoke “"))'
for _ in $(seq 1 10); do
    [ "$(element ".id==\"grant-disclosure-${NEW_GRANT}-${CAPABILITY}\"")" = null ] && break
    sleep 2
done
no_disclosure "grant-disclosure-${NEW_GRANT}-${CAPABILITY}" "a revoked grant"
expect_disclosure "grant-disclosure-${WS_GRANT}-${CAPABILITY}" "the still-active grant's row"

step "PASSED — transcript in ${LOG}"
