# shellcheck shell=bash
# shellcheck disable=SC2016,SC2034  # guest-side $HOME
# Sourced by the VM scripts that drive Koine through the contract-only client
# (vm-verify-contract-client.sh, vm-verify-launch-contract-client.sh), after
# vm-verify-lib.sh and vm-verify-desktop-lib.sh. The client is uploaded to the guest
# as $HOME/koine-client.mjs beside the Node runtime it needs ($HOME/node) by the
# sourcing script. The client's author had the published contract documents and one
# introspection response and no access to this repository; nothing here may teach
# it anything it did not learn from those.

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
    # click landing in TextEdit. Raise Koine first, every time, and show its window
    # first when setup left it closed.
    show_window
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

ONCE_CALLS=0
# contract_client_once <argument...>: for a command that is NOT safe to repeat (a launch, a
# URL open): `guest` and `guest_json` retry the agent's false "timed out" answer, which is
# right for a read and wrong here, since a second launch is a reactivation. So the client
# runs through the agent with its one line going to a file of its own, which is read back
# (a read is safe to repeat), and it is never run twice once it has started.
# The agent has answered "not reached" (status 7) for a command that went on to run: the
# client then ran again and the second launch was a reactivation, so the recorded send
# instant came 45 seconds after the process started. The answer file is created when the
# shell starts the command, so a file that exists means it ran, and it is waited for.
contract_client_once() {
    local file status
    ONCE_CALLS=$((ONCE_CALLS + 1))
    ANSWER=""
    file="\$HOME/client-answer-${ONCE_CALLS}.json"
    guest "rm -f ${file}" >/dev/null || true
    for _ in 1 2 3; do
        status=0
        testanyware file exec "${CLIENT} $* > ${file}" >/dev/null 2>&1 || status=$?
        if [ "${status}" = 7 ] || [ "${status}" = 255 ]; then
            if guest_text "[ -e ${file} ] && echo started" | grep -qx started; then break; fi
            sleep 5
            continue
        fi
        break
    done
    for _ in $(seq 1 20); do
        ANSWER="$(guest_json "cat ${file}" 2>/dev/null)" && break
        sleep 3
    done
    [ -n "${ANSWER:-}" ] && jq -e . >/dev/null <<<"${ANSWER}" || fail "the contract-only client left no answer for: $*"
    echo "${ANSWER}"
}

