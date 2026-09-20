#!/bin/bash
# Verifies, on the notarized Koine.app in a clean TestAnyware macOS VM, that a
# client written from the documented contract alone runs the whole path: it
# obtains a grant through the client-requested workflow, reads the endpoint
# descriptor to find where to connect, presents its bearer credential,
# introspects the schema it was generated against, resolves a running
# application, lists its windows and focuses a chosen one — passing the window
# reference back unchanged. The five operations of
# docs/design/desktop-operations.graphql are sent as that file has them.
#
# The client under test is clients/contract-only. Its author had the spec, the
# operations file, the bearer-grant ADR and one introspection response, and no
# access to this repository; nothing here may teach it anything it did not learn
# from those. This script is the harness, not the client: it drives the VM, the
# management window and System Settings, and it checks the client's answers
# against an independent witness of what the system actually did
# (Fixtures/WindowIdentityProbe).
#
# Error classification is exercised, not just the happy path: a capability
# denial, an OS-permission refusal, an absent process, a gone window and a
# service that is not running are each asked for and each told apart.
#
# The procedure and its recorded evidence: docs/verification/contract-only-client.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="contract-client-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

BUNDLE="clients/contract-only/dist/koine-client.mjs"
[ -f "${BUNDLE}" ] || { echo "Error: ${BUNDLE} does not exist. Run: task client" >&2; exit 1; }

NODE_ARCHIVE="$(scripts/stage-node-runtime.sh)"
PROBE="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"

# shellcheck disable=SC2016  # guest-side $HOME
READER='$HOME/koine-secret-reader'
# shellcheck disable=SC2016  # guest-side $HOME
CONTROLLER='$HOME/koine-secret-controller'
CLIENT='$HOME/node/bin/node $HOME/koine-client.mjs'

# client <argument...>: the contract-only client in the guest; its one JSON line
# is left in ANSWER. Every command it offers is safe to repeat, which is what
# guest_json needs to survive the agent's false timeouts.
contract_client() {
    ANSWER="$(guest_json "${CLIENT} $*")" || fail "the contract-only client printed no JSON for: $*"
    echo "${ANSWER}"
}
# The same, for the one command whose answer embeds a whole introspection
# response: the guest drops that field before the line crosses the exec channel.
contract_client_trimmed() {
    ANSWER="$(guest_json "${CLIENT} $* | python3 \$HOME/trim.py")" ||
        fail "the contract-only client printed no JSON for: $*"
    echo "${ANSWER}"
}
expect() { jq -e "$1" >/dev/null <<<"${ANSWER}" || fail "$2"; }
# approve_in_window <request id> <label> <comparison code>: the user's own
# decision, made in Koine's window, after comparing the code the window shows
# with the one the client holds. No credential is typed, pasted or shown.
approve_in_window() {
    local id="$1" label="$2" code="$3"
    # The clicks below go to screen coordinates, and by this point in the run
    # real application windows cover Koine's. A snapshot reads through them — the
    # label and code check out — so the only symptom of a covered window is the
    # click landing in TextEdit. Raise Koine first, every time.
    testanyware agent window-focus --window "${APP_NAME}" >/dev/null
    sleep 1
    await_element ".id==\"request-${id}\"" present
    echo "Window shows: label $(value_of ".id==\"request-label-${id}\"")  code $(value_of ".id==\"request-code-${id}\"")"
    [ "$(value_of ".id==\"request-label-${id}\"")" = "${label}" ] || fail "the window shows another label"
    [ "$(value_of ".id==\"request-code-${id}\"")" = "${code}" ] || fail "the window's comparison code is not the client's"
    click ".id==\"approve-${id}\""
    await_element ".id==\"request-${id}\"" absent
}
# enrol <secret file> <label> <capability>...: the client-requested workflow,
# end to end, through the window. Leaves the grant's capabilities in ANSWER.
enrol() {
    local secret="$1" label="$2"
    shift 2
    local arguments=""
    for capability in "$@"; do arguments="${arguments} --capability ${capability}"; done
    contract_client "enrol --secret \"${secret}\" --label ${label}${arguments}"
    expect '.classification == "ok" and (.requestId | length > 0) and (.comparisonCode | length > 0)' \
        "the client's enrollment request was refused"
    local id code
    id="$(jq -r .requestId <<<"${ANSWER}")"
    code="$(jq -r .comparisonCode <<<"${ANSWER}")"
    contract_client "poll --secret \"${secret}\""
    expect '.requestState == "PENDING"' "the client's own poll does not say PENDING"
    approve_in_window "${id}" "${label}" "${code}"
    contract_client "poll --secret \"${secret}\""
    expect '.requestState == "APPROVED"' "the client's own poll does not say APPROVED"
    echo "Approved: request ${id}, comparison code ${code}, capabilities $(jq -c '.grant.capabilities' <<<"${ANSWER}")"
}

start_vm
install_app
step "Carry the client and the Node runtime it needs into the guest"
testanyware file upload "${NODE_ARCHIVE}" /Users/admin/node.tar.xz >/dev/null
testanyware file upload "${BUNDLE}" /Users/admin/koine-client.mjs >/dev/null
testanyware file upload "${PROBE}" /Users/admin/WindowIdentityProbe >/dev/null
testanyware file upload scripts/vm-verify-contract-client-trim.py /Users/admin/trim.py >/dev/null
# shellcheck disable=SC2016  # guest-side $HOME
guest 'cd $HOME && rm -rf node && tar -xJf node.tar.xz && mv node-*-darwin-arm64 node && chmod +x $HOME/WindowIdentityProbe && ./node/bin/node --version'

step "With no Koine running, the client says the service is unavailable"
contract_client "probe"
expect '.classification == "service-unavailable"' "the client did not report an absent service as unavailable"

step "Launch Koine; the client finds the endpoint from the descriptor alone"
launch
contract_client "probe"
expect '.classification == "ok" and .descriptor.present == true and .descriptor.contractVersion == "koine-desktop/1" and .descriptor.graphqlPath == "/graphql"' \
    "the client did not read the endpoint descriptor"
echo "Endpoint the client built for itself: $(jq -r .descriptor.url <<<"${ANSWER}")"

step "The client enrols itself for desktop:read, and the user approves in the window"
enrol "${READER}" contract-only-reader desktop:read
expect '.grant.capabilities == ["desktop:read"] and .grant.state == "ACTIVE"' "the reading grant is not an active desktop:read alone"

step "InspectOwnConnection: the contract version and the caller's own grant"
contract_client "inspect --secret \"${READER}\""
expect '.classification == "ok" and .koine.contractVersion == "koine-desktop/1" and .koine.ownGrant.state == "ACTIVE"' \
    "InspectOwnConnection did not answer for the reading grant"
SERVED_DIGEST="$(jq -r .koine.schemaDigest <<<"${ANSWER}")"

step "The client introspects, and compares what it generated against with what is served"
# shellcheck disable=SC2016  # guest-side $HOME
contract_client_trimmed "introspect --secret \"${READER}\" --out \$HOME/introspection.json"
expect '.classification == "ok" and .byteCount > 30000 and (.errors | length) == 0 and .schemaDigestsEqual == true' \
    "the served schema is not the one this client was generated against"
echo "Digest generated against: $(jq -r .generatedAgainstSchemaDigest <<<"${ANSWER}")"
echo "Digest served now:        $(jq -r .servedSchemaDigest <<<"${ANSWER}")"
[ "$(jq -r .servedSchemaDigest <<<"${ANSWER}")" = "${SERVED_DIGEST}" ] ||
    fail "the digest the introspection reports is not the one Koine served this session"
testanyware file download /Users/admin/introspection.json "${WORK}/introspection.json" >/dev/null
mkdir -p .build/contract-client
cp "${WORK}/introspection.json" .build/contract-client/introspection.json
echo "Introspection response brought back: $(wc -c <"${WORK}/introspection.json") bytes"

step "Real windows: two Finder windows and a TextEdit document"
guest "open -a Finder" || true
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 2
# shellcheck disable=SC2016  # guest-side $HOME
guest 'echo contract-only > $HOME/contract-target.txt; open -a TextEdit $HOME/contract-target.txt' || true
sleep 4

step "Without Accessibility consent, the window list is an os-permission refusal, told apart from absence"
contract_client "choices --secret \"${READER}\" --application Finder"
expect '.classification == "os-permission-denied" and .desktopApplication == null' \
    "the client did not classify the refusal as an OS-permission one"
expect '(.response.errors | length) == 1 and (.response.errors[0] | .path == ["desktopApplication","windows"] and (.extensions | .kind == "permission" and .permissionClass == "os-permission" and .osPermission == "accessibility" and .permissionOwner == "koine"))' \
    "the refusal is not an os-permission error naming accessibility and koine at the window list"
no_consent_dialog "after a read without consent"

step "Give Koine Accessibility consent in System Settings"
grant_accessibility

step "DesktopChoices: the application and its windows"
contract_client "choices --secret \"${READER}\" --application Finder"
expect '.classification == "ok" and (.windows | length) >= 2 and (.desktopApplication.name | length > 0) and ([.windows[].ref] | unique | length) == (.windows | length)' \
    "the client did not list at least two Finder windows under distinct references"
A="$(jq -r '.windows[0].ref' <<<"${ANSWER}")"
B="$(jq -r '.windows[1].ref' <<<"${ANSWER}")"
echo "Process identity the client captured: $(jq -c '.process' <<<"${ANSWER}")"
echo "Application: $(jq -c '{name: .desktopApplication.name, ref: .desktopApplication.ref}' <<<"${ANSWER}")"

step "An absent process is ordinary null, and the client says absent rather than denied"
contract_client "choices --secret \"${READER}\" --pid 1000000 --started-at 2026-01-01T00:00:00.000000Z"
expect '.classification == "absent" and .absence == "server-null" and .response.data.desktopApplication == null and ((.response.errors // []) | length) == 0' \
    "an absent process was not an ordinary null"

step "The reading grant cannot focus: a capability denial, told apart from both of the above"
contract_client "focus --secret \"${READER}\" --ref '${A}'"
expect '.classification == "capability-denied" and .http.status == 403 and .receipt == null' \
    "focusing under desktop:read alone was not a capability denial"
expect '(.response.errors | length) == 1 and (.response.errors[0] | .path == ["desktopFocusWindow"] and (.extensions | .kind == "permission" and .permissionClass == "capability" and .requiredCapability == "desktop:control" and .phase == "authorization"))' \
    "the denial does not name desktop:control at the action's path"

step "A second enrollment, for desktop:control, approved in the window"
enrol "${CONTROLLER}" contract-only-controller desktop:control
expect '.grant.capabilities == ["desktop:control"] and .grant.state == "ACTIVE"' "the controlling grant is not an active desktop:control alone"

step "FocusDesktopWindow: the chosen window, and the reference comes back unchanged"
guest 'open -a TextEdit' || true
expect_focused TextEdit '.window.title == "contract-target.txt"'
contract_client "focus --secret \"${CONTROLLER}\" --ref '${A}'"
expect '.classification == "ok" and .receiptRefMatchesSubmitted == true' "the focus was refused"
expect ".receipt == {ref: \"${A}\"}" "the receipt is not the submitted reference unchanged"
expect_focused Finder '.window.privateWindowId != null'
A_ID="$(jq -r '.window.privateWindowId' <<<"${WITNESS}")"
echo "The system agrees: Finder window ${A_ID} has focus."

step "The other window, so that the client is choosing rather than activating"
guest 'open -a TextEdit' || true
contract_client "focus --secret \"${CONTROLLER}\" --ref '${B}'"
expect '.receiptRefMatchesSubmitted == true' "the second receipt is not the submitted reference unchanged"
expect_focused Finder ".window.privateWindowId != ${A_ID}"
B_ID="$(jq -r '.window.privateWindowId' <<<"${WITNESS}")"
echo "The system agrees: Finder window ${B_ID} has focus, and it is not ${A_ID}."
testanyware screen capture -o "${LOG%.log}-focused.png" >/dev/null

step "A window that is gone is unavailable, told apart from denial and from absence, and focus does not move"
contract_client "focus --secret \"${CONTROLLER}\" --ref '${A}'"
expect_focused Finder ".window.privateWindowId == ${A_ID}"
testanyware input key w --modifiers cmd >/dev/null
sleep 3
guest 'open -a TextEdit' || true
witness
BEFORE="${FOCUSED}"
contract_client "focus --secret \"${CONTROLLER}\" --ref '${A}'"
expect '.classification == "unavailable" and .receipt == null and .http.status == 200' \
    "a closed window was not classified unavailable"
expect '(.response.errors | length) == 1 and (.response.errors[0] | .path == ["desktopFocusWindow"] and .extensions.kind == "unavailable")' \
    "the closed window did not raise unavailable at the action's path"
witness
[ "${FOCUSED}" = "${BEFORE}" ] || fail "focus moved from ${BEFORE} to ${FOCUSED} although the window was gone"

step "After Quit, the client says the service is unavailable again — not that it was denied"
quit_koine
contract_client "probe"
expect '.classification == "service-unavailable"' "the client did not report the stopped service as unavailable"
contract_client "inspect --secret \"${READER}\""
expect '.classification == "service-unavailable"' "a request to a stopped Koine was not a transport state"

step "PASSED — transcript in ${LOG}"
