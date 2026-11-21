#!/usr/bin/env bats
# shellcheck disable=SC2016,SC1112 # Guest-side $HOME; osascript prints U+2019.
# Each checked command runs on this host through /bin/bash -c, as the tagged
# agent runs it in a guest. This is host evidence, not guest evidence.
# A test-only osascript shim checks the exact System Events invocation, then
# runs the real /usr/bin/osascript with the same flags on a literal. Thus the
# real osascript prints each value, script error and status, and no Apple
# event reaches System Events or raises a consent prompt. The enrolment runs
# the real client against a local stub server under a temporary HOME, so it
# reaches no installed Koine.

setup() {
    bats_require_minimum_version 1.5.0
    # shellcheck source=scripts/vm-sysevents-evidence-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-sysevents-evidence-lib.sh"
    export read_calls="${BATS_TEST_TMPDIR}/calls" read_mode=host
    export read_stdout="${BATS_TEST_TMPDIR}/unused"
    export read_fixture="${BATS_TEST_DIRNAME}/fixtures/exec-read-cli.py"
    export host_literal="${BATS_TEST_TMPDIR}/literal" host_log="${BATS_TEST_TMPDIR}/osascript.log"
    : >"${read_stdout}"
    : >"${host_log}"
    mkdir "${BATS_TEST_TMPDIR}/bin"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
exec python3 "${read_fixture}" "$@"
CLI
    cat >"${BATS_TEST_TMPDIR}/bin/osascript" <<'SHIM'
#!/bin/bash
# Test-only: the exact System Events invocation, evaluated as a literal.
printf '%s\n' "$4" >>"${host_log}"
[[ $# == 4 && "$1" == -s && "$2" == so && "$3" == -e && "$4" == 'tell application "System Events" to '* ]] || exit 99
exec /usr/bin/osascript -s so -e "$(cat "${host_literal}")"
SHIM
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware" "${BATS_TEST_TMPDIR}/bin/osascript"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
}

# host_read ROOT LITERAL CLASS NAME [ARGUMENT...]: one read of the fresh root
# BATS_TEST_TMPDIR/ROOT, whose osascript evaluates LITERAL.
host_read() {
    printf '%s' "$2" >"${host_literal}"
    init_guest_evidence "${BATS_TEST_TMPDIR}/$1" host-sysevents
    read_guest_exec "${BATS_TEST_TMPDIR}/$1" "$3" host "${@:4}"
}

@test "real osascript output parses for every System Events read" {
    local record
    record="$(host_read r1 '{"Accessibility Not Granted…", "", "Settings…", "a, b", "Quit Koine"}' read-poll menu-titles)"
    jq -e '.value == ["Accessibility Not Granted…", "", "Settings…", "a, b", "Quit Koine"]' <<<"${record}"
    record="$(host_read r2 '{"Finder", missing value, "Koine"}' read-poll dock-items)"
    jq -e '.value == ["Finder", null, "Koine"]' <<<"${record}"
    record="$(host_read r3 '{"loginwindow", "Dock"}' read-poll sysevents-processes)"
    jq -e '.value == ["loginwindow", "Dock"]' <<<"${record}"
    record="$(host_read r4 1 read-poll menu-item-count)"
    jq -e '.value == 1' <<<"${record}"
    record="$(host_read r5 true read-poll background-only)"
    jq -e '.value == true' <<<"${record}"
    record="$(host_read r6 '"TextEdit"' read-poll front-application)"
    jq -e '.value == "TextEdit"' <<<"${record}"
    record="$(host_read r7 '"Koine, 1 grant request waiting, Accessibility not granted"' read-poll menu-item-label value)"
    jq -e '.value == "Koine, 1 grant request waiting, Accessibility not granted"' <<<"${record}"
    record="$(host_read r8 'missing value' read-poll menu-item-label value)"
    jq -e '.absent == false and .value == null' <<<"${record}"
    # A line break and a quote inside a string survive the source form.
    record="$(host_read r9 '"a \"b\"" & linefeed & "c"' read-poll menu-item-label value)"
    jq -e '.value == "a \"b\"\nc"' <<<"${record}"
    record="$(host_read r10 '{{1500, 0}, {30, 24}}' read-poll menu-item-frame)"
    jq -e '.text == "1500, 0, 30, 24"' <<<"${record}"
    record="$(host_read r11 '{{1490, 24}, {200, 22}}' read-poll menu-row-frame 'Settings…')"
    jq -e '.text == "1490, 24, 200, 22"' <<<"${record}"
    # Each read sent its own legacy AppleScript, unchanged.
    diff <(sed 's/^tell application "System Events" to //' "${host_log}") - <<'SCRIPTS'
get title of every menu item of menu 1 of menu bar item 1 of menu bar 2 of process "Koine"
get name of every UI element of list 1 of process "Dock"
get name of every process
get count of menu bar items of menu bar 2 of process "Koine"
get background only of process "Koine"
get name of first process whose frontmost is true
get description of menu bar item 1 of menu bar 2 of process "Koine"
get description of menu bar item 1 of menu bar 2 of process "Koine"
get description of menu bar item 1 of menu bar 2 of process "Koine"
get {position, size} of menu bar item 1 of menu bar 2 of process "Koine"
get {position, size} of menu item "Settings…" of menu 1 of menu bar item 1 of menu bar 2 of process "Koine"
SCRIPTS
}

@test "real osascript errors are an absence only in a poll and unavailable elsewhere" {
    local record absent='error "Can’t get menu bar 2 of process \"Koine\". Invalid index." number -1719'
    record="$(host_read r12 "${absent}" read-poll menu-item-label poll)"
    jq -e '.absent == true and .error == -1719' <<<"${record}"
    record="$(host_read r13 'error "Can’t get menu item." number -1728' read-poll menu-row-frame 'Quit Koine')"
    jq -e '.absent == true and .error == -1728' <<<"${record}"
    run host_read r14 "${absent}" read-poll menu-item-count
    [[ "${status}" == 125 ]]
    grep -q 'only a poll admits' "${BATS_TEST_TMPDIR}/r14/unavailable"
    run host_read r15 'error "Not authorized to send Apple events to System Events." number -1743' read-poll menu-item-label poll
    [[ "${status}" == 125 ]]
    grep -q 'AppleScript error -1743 is unavailable' "${BATS_TEST_TMPDIR}/r15/unavailable"
    run host_read r16 '1.5' read-poll menu-item-count
    [[ "${status}" == 125 ]]
    grep -q 'grammar' "${BATS_TEST_TMPDIR}/r16/unavailable"
    # A compile error of the literal is a syntax error, not an execution error.
    run host_read r17 'get (' read-poll menu-item-label poll
    [[ "${status}" == 125 ]]
    grep -q 'without one execution error' "${BATS_TEST_TMPDIR}/r17/unavailable"
}

@test "the real enrolment client prints one JSON line that the submission parses" {
    local home="${BATS_TEST_TMPDIR}/home" root server port record
    mkdir -p "${home}/Library/Application Support/Koine"
    cp "${BATS_TEST_DIRNAME}/../../scripts/vm-verify-enrollment-client.py" "${home}/"
    printf '200' >"${BATS_TEST_TMPDIR}/code"
    python3 -I -c '
import http.server, json, sys
class Stub(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        request = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        assert "credentialDigest" in request["variables"]["input"]
        code = int(open(sys.argv[2]).read())
        body = {"data": {"koineRequestGrant": {"requestId": "r1", "comparisonCode": "123456"}}}
        if code != 200:
            body = {"errors": [{"message": "refused"}]}
        data = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)
    def log_message(self, *arguments):
        pass
server = http.server.HTTPServer(("127.0.0.1", 0), Stub)
open(sys.argv[1] + ".tmp", "w").write(str(server.server_port))
__import__("os").rename(sys.argv[1] + ".tmp", sys.argv[1])
server.serve_forever()' "${BATS_TEST_TMPDIR}/port" "${BATS_TEST_TMPDIR}/code" 3>&- &
    server=$!
    for _ in $(seq 1 50); do [[ -s "${BATS_TEST_TMPDIR}/port" ]] && break || /bin/sleep 0.1; done
    port="$(cat "${BATS_TEST_TMPDIR}/port")"
    printf '{"port": %s, "path": "/graphql"}' "${port}" >"${home}/Library/Application Support/Koine/endpoint.json"
    root="${BATS_TEST_TMPDIR}/accepted"
    init_guest_evidence "${root}" host-enrol
    record="$(HOME="${home}" submit_guest_enrolment "${root}" enrol-first '$HOME/koine-secret-first' vm-editor)"
    jq -e '.status == 200 and .response.data.koineRequestGrant.requestId == "r1"' <<<"${record}"
    [[ -s "${home}/koine-secret-first" ]]
    printf '403' >"${BATS_TEST_TMPDIR}/code"
    root="${BATS_TEST_TMPDIR}/refused"
    init_guest_evidence "${root}" host-enrol
    run env HOME="${home}" bash -c 'source scripts/vm-sysevents-evidence-lib.sh &&
        submit_guest_enrolment "$1" enrol-second "\$HOME/koine-secret-second" vm-second' _ "${root}"
    [[ "${status}" == 1 && ! -e "${root}/unavailable" ]]
    jq -e '.status == 403' "${root}/000001/read.json"
    # A stopped server makes the client fail with a traceback: unavailable.
    kill "${server}"
    wait "${server}" 2>/dev/null || :
    root="${BATS_TEST_TMPDIR}/stopped"
    init_guest_evidence "${root}" host-enrol
    run env HOME="${home}" bash -c 'source scripts/vm-sysevents-evidence-lib.sh &&
        submit_guest_enrolment "$1" enrol-third "\$HOME/koine-secret-third" vm-third' _ "${root}"
    echo "diagnostic: status=${status} output=${output}"
    [[ "${status}" == 125 && -s "${root}/unavailable" && ! -e "${root}/000001/read.json" ]]
}
