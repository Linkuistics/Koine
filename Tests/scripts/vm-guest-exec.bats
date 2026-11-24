#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Bats isolates each test; setup runs for every case.

setup() {
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    export exec_root="${BATS_TEST_TMPDIR}/evidence"
    export exec_calls="${BATS_TEST_TMPDIR}/calls"
    export exec_reply="${BATS_TEST_TMPDIR}/reply"
    export exec_stderr="${BATS_TEST_TMPDIR}/stderr"
    export exec_started="${BATS_TEST_TMPDIR}/started"
    mkdir "${BATS_TEST_TMPDIR}/bin"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'SH'
#!/bin/bash
jq -cn --args '$ARGS.positional' -- "$@" >>"${exec_calls}"
touch "${exec_started}"
if [[ -n "${exec_release:-}" ]]; then
    until [[ -f "${exec_release}" ]]; do sleep 0.02; done
fi
sleep "${exec_delay:-0}"
cat "${exec_reply}"
cat "${exec_stderr}" >&2
touch "${exec_started}.done"
exit "${exec_status:-0}"
SH
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    # shellcheck source=Tests/scripts/fixtures/declared-tools.sh
    source "${BATS_TEST_DIRNAME}/fixtures/declared-tools.sh"
    declare_tools "${BATS_TEST_TMPDIR}/bin/testanyware"
    printf 'CLI diagnostic\n' >"${exec_stderr}"
    printf '%s\n' '{"schema_version":"1.0","command":"probe","ok":true,"exit_code":0,"timed_out":false,"stdout":"READY\n","stderr":"guest diagnostic\n","exec_id":"synthetic-exec","record":"agent","legacy_projection":"macos","outcome":{"kind":"exited","exit_code":0},"evidence":{"stdout":{"base64":"UkVBRFkK","capture":"complete"},"stderr":{"base64":"Z3Vlc3QgZGlhZ25vc3RpYwo=","capture":"complete"}}}' >"${exec_reply}"
}

@test "nonexec attempts share exec ordinals and retain exact raw JSON" {
    init_guest_evidence "${exec_root}" exact-vm
    check_guest_evidence "${exec_root}"
    exec_guest_evidence "${exec_root}" read-poll before probe true >/dev/null
    printf '%s\n' '{"schema_version":"1.0","ok":true,"x":10,"y":20}' >"${exec_reply}"
    run cli_guest_evidence "${exec_root}" one-shot row-click '.x == 10 and .y == 20' -- input click 10 20
    [[ "${status}" == 0 ]]
    cmp "${exec_reply}" "${exec_root}/000002/raw.stdout"
    cmp "${exec_stderr}" "${exec_root}/000002/raw.stderr"
    jq -e '.ordinal == 2 and .transport == "cli" and .vm == "exact-vm" and .argv == [env.KOINE_TESTANYWARE_CLI,"input","click","10","20","--vm","exact-vm","--json"]' "${exec_root}/000002/request.json"
    jq -e '.outcome == "clean" and .cli_status == 0 and .emission_status == "flushed"' "${exec_root}/000002/result.json"
    check_guest_evidence "${exec_root}"
    [[ ! -e "${exec_root}/000003" ]]
}

@test "nonexec failure blocks exec and input while collection preserves the first latch" {
    init_guest_evidence "${exec_root}" exact-vm
    export exec_status=7
    run cli_guest_evidence "${exec_root}" read-poll windows true -- agent windows
    [[ "${status}" == 125 ]]
    local first
    first="$(cat "${exec_root}/unavailable")"
    run check_guest_evidence "${exec_root}"
    [[ "${status}" == 125 ]]
    run exec_guest_evidence "${exec_root}" one-shot launch probe true
    [[ "${status}" == 125 ]]
    run cli_guest_evidence "${exec_root}" one-shot click true -- input click 10 20
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
    export exec_status=0
    run cli_guest_evidence "${exec_root}" evidence failure-windows '.stdout == "READY\n"' -- agent windows
    [[ "${status}" == 0 ]]
    [[ "$(cat "${exec_root}/unavailable")" == "${first}" ]]
    run check_guest_evidence "${exec_root}"
    [[ "${status}" == 125 ]]
}

@test "failed downstream confirmation is ordinal evidence and cannot restore input" {
    init_guest_evidence "${exec_root}" exact-vm
    exec_guest_evidence "${exec_root}" one-shot launch probe true >/dev/null
    run fail_guest_evidence "${exec_root}" launch-identity 'wrong executable identity'
    [[ "${status}" == 125 ]]
    jq -e '.ordinal == 2 and .transport == "confirmation" and .operation == "launch-identity" and .reason == "wrong executable identity" and .argv == []' "${exec_root}/000002/request.json"
    jq -e '.outcome == "unavailable" and .cli_status == null and .emission_status == "not-attempted"' "${exec_root}/000002/result.json"
    run cli_guest_evidence "${exec_root}" one-shot click true -- input click 10 20
    [[ "${status}" == 125 ]]
    run fail_guest_evidence "${exec_root}" capture-artifact 'missing image'
    [[ "${status}" == 125 && -f "${exec_root}/000003/result.json" ]]
    [[ "$(cat "${exec_root}/unavailable")" == '000002: wrong executable identity' ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
}

@test "evidence class refuses mutating CLI actions even after a prior latch" {
    local action phase
    for phase in eligible latched; do
        for action in click start upload focus menu snapshot-menu snapshot-menu-equals; do
            exec_root="${BATS_TEST_TMPDIR}/${phase}-${action}"
            init_guest_evidence "${exec_root}" exact-vm
            if [[ "${phase}" == latched ]]; then
                fail_guest_evidence "${exec_root}" setup 'original failure' || :
            fi
            case "${action}" in
            click) set -- input click 10 20 ;;
            start) set -- vm start --platform macos ;;
            upload) set -- file upload local /tmp/guest ;;
            focus) set -- agent window-focus --window TextEdit ;;
            menu) set -- agent show-menu --menu File ;;
            snapshot-menu) set -- agent snapshot --open-menu File ;;
            snapshot-menu-equals) set -- agent snapshot --open-menu=File ;;
            esac
            run cli_guest_evidence "${exec_root}" evidence "${action}" true -- "$@"
            [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
            [[ -s "${exec_root}/unavailable" ]]
        done
    done
}

@test "latched CLI evidence still admits collection and exact clone stop" {
    init_guest_evidence "${exec_root}" exact-vm
    fail_guest_evidence "${exec_root}" setup 'original failure' || :
    local action
    for action in windows snapshot size list stop; do
        case "${action}" in
        windows) set -- agent windows ;;
        snapshot) set -- agent snapshot --window TextEdit ;;
        size) set -- screen size ;;
        list) set -- vm list --all ;;
        stop) set -- vm stop exact-vm ;;
        esac
        run cli_guest_evidence "${exec_root}" evidence "${action}" '.ok == true' -- "$@"
        [[ "${status}" == 0 ]]
    done
    # Collection of guest files uses the checked download in
    # vm-file-lifecycle-evidence.bats; the generic route refuses it.
    run cli_guest_evidence "${exec_root}" evidence download '.ok == true' -- file download /tmp/evidence local
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 5 ]]
    [[ "$(cat "${exec_root}/unavailable")" == '000001: original failure' ]]
}

@test "refusals retain each request and reason without replacing the first latch" {
    init_guest_evidence "${exec_root}" exact-vm
    fail_guest_evidence "${exec_root}" setup 'original failure' || :
    run cli_guest_evidence "${exec_root}" evidence wrong-stop true -- vm stop other-vm
    [[ "${status}" == 125 ]]
    run check_guest_evidence "${exec_root}"
    [[ "${status}" == 125 ]]
    run exec_guest_evidence "${exec_root}" one-shot launch probe true
    [[ "${status}" == 125 ]]
    run python3 "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec.py" cli "${exec_root}" invalid
    [[ "${status}" == 2 ]]
    run fail_guest_evidence "${exec_root}" '' $'missing\nidentity'
    [[ "${status}" == 125 ]]
    jq -se 'length == 5
        and .[0].arguments[3] == "wrong-stop" and (.[0].reason | contains("pinned vm stop"))
        and .[1].arguments[0] == "check" and (.[1].reason | contains("latch"))
        and .[2].arguments[0] == "run" and (.[2].reason | contains("latch"))
        and .[3].arguments[2] == "invalid" and .[3].reason == "invalid evidence arguments"
        and .[4].arguments[-1] == "missing\nidentity" and (.[4].reason | contains("operation"))
        and all(.[]; .source == "backend" and (.at | length > 0))' "${exec_root}/refusals.jsonl"
    [[ "$(cat "${exec_root}/unavailable")" == '000001: original failure' ]]
    [[ ! -e "${exec_root}/000002" && ! -e "${exec_calls}" ]]
}

@test "nonexec rejects malformed success dry-run failed CLI and incomplete command payloads" {
    local n=0 reply
    for reply in '' '{"ok":true' '{"schema_version":"1.0","ok":true,"ok":false}' \
        '{"schema_version":"1.0","ok":true,"x":NaN}' \
        '{"schema_version":"1.0","ok":true}{}' \
        '{"schema_version":"1.0"}' '{"ok":true}' \
        '{"schema_version":"1.0","ok":"true"}' \
        '{"schema_version":"1.0","ok":false,"x":10}' \
        '{"schema_version":"1.0","ok":true,"dry_run":false,"x":10}' \
        '{"schema_version":"1.0","ok":true,"x":20}' \
        '{"schema_version":"1.0","ok":true}'; do
        n=$((n + 1))
        exec_root="${BATS_TEST_TMPDIR}/case-${n}"
        init_guest_evidence "${exec_root}" exact-vm
        printf '%s' "${reply}" >"${exec_reply}"
        run cli_guest_evidence "${exec_root}" one-shot click '.x == 10' -- input click 10 20
        [[ "${status}" == 125 && -s "${exec_root}/unavailable" ]]
        cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
    done
    for predicate in halt empty true,false null 'invalid syntax'; do
        n=$((n + 1))
        exec_root="${BATS_TEST_TMPDIR}/case-${n}"
        init_guest_evidence "${exec_root}" exact-vm
        printf '%s' '{"schema_version":"1.0","ok":true,"x":10}' >"${exec_reply}"
        run cli_guest_evidence "${exec_root}" one-shot click "${predicate}" -- input click 10 20
        [[ "${status}" == 125 ]]
    done
    export exec_status=255
    init_guest_evidence "${BATS_TEST_TMPDIR}/nonzero" exact-vm
    run cli_guest_evidence "${BATS_TEST_TMPDIR}/nonzero" one-shot click true -- input click 10 20
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 18 ]]
}

@test "exec latch and incomplete receipts gate nonexec without dispatch" {
    init_guest_evidence "${exec_root}" exact-vm
    export exec_status=1
    run exec_guest_evidence "${exec_root}" read-poll state probe true
    [[ "${status}" == 125 ]]
    run cli_guest_evidence "${exec_root}" one-shot click true -- input click 10 20
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
    init_guest_evidence "${exec_root}-partial" exact-vm
    mkdir "${exec_root}-partial/000001"
    printf '{"outcome":' >"${exec_root}-partial/000001/result.json"
    run check_guest_evidence "${exec_root}-partial"
    [[ "${status}" == 125 && -s "${exec_root}-partial/unavailable" ]]
    run cli_guest_evidence "${exec_root}-partial" one-shot click true -- input click 10 20
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
}

@test "nonexec endpoint overrides and alternate exec routes refuse before dispatch" {
    local n=0
    for argument in --connect --connect=other --vm --vm=other --agent=other --vnc=other --platform=linux --json --dry-run --; do
        n=$((n + 1))
        init_guest_evidence "${exec_root}-${n}" exact-vm
        run cli_guest_evidence "${exec_root}-${n}" one-shot click true -- input click 10 20 "${argument}"
        [[ "${status}" == 125 && -s "${exec_root}-${n}/unavailable" ]]
    done
    init_guest_evidence "${exec_root}" exact-vm
    run cli_guest_evidence "${exec_root}" one-shot launch true -- file exec probe
    [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
}

@test "VM start refuses viewer and retained-failure options before dispatch" {
    local argument n=0
    for argument in --viewer --viewer=true --keep-on-failure --keep-on-failure=true; do
        n=$((n + 1))
        exec_root="${BATS_TEST_TMPDIR}/start-${n}"
        init_guest_evidence "${exec_root}" exact-vm
        run cli_guest_evidence "${exec_root}" one-shot start true -- vm start --platform macos "${argument}"
        [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
        [[ -s "${exec_root}/unavailable" && ! -e "${exec_root}/000001" ]]
    done
}

@test "caller ID overrides refuse on both VM start and endpoint routes" {
    local route form
    for route in start endpoint; do
        for form in separate equals; do
            exec_root="${BATS_TEST_TMPDIR}/${route}-${form}"
            init_guest_evidence "${exec_root}" exact-vm
            case "${route}" in
            start) set -- vm start --platform macos ;;
            endpoint) set -- input click 10 20 ;;
            esac
            if [[ "${form}" == separate ]]; then
                set -- "$@" --id other
            else
                set -- "$@" --id=other
            fi
            run cli_guest_evidence "${exec_root}" one-shot override true -- "$@"
            [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
            [[ -s "${exec_root}/unavailable" && ! -e "${exec_root}/000001" ]]
        done
    done
}

@test "nonexec start list and screen size retain explicit call payloads and generic upload refuses" {
    init_guest_evidence "${exec_root}" exact-vm
    start_reply exact-vm >"${exec_reply}"
    cli_guest_evidence "${exec_root}" one-shot start '.id == "exact-vm"' -- vm start --platform macos --wait >/dev/null
    jq -e '.argv == [env.KOINE_TESTANYWARE_CLI,"vm","start","--platform","macos","--wait","--id","exact-vm","--json"]' "${exec_root}/000001/request.json"
    printf '%s\n' '{"schema_version":"1.0","ok":true,"vms":[]}' >"${exec_reply}"
    cli_guest_evidence "${exec_root}" evidence stopped '.vms == []' -- vm list --all >/dev/null
    jq -e '.argv == [env.KOINE_TESTANYWARE_CLI,"vm","list","--all","--json"]' "${exec_root}/000002/request.json"
    declare_clone_spec exact-vm
    record_guest_provenance "${exec_root}" clone-provenance
    printf '%s\n' '{"schema_version":"1.0","ok":true,"marker":"complete"}' >"${exec_reply}"
    cli_guest_evidence "${exec_root}" evidence size '.marker == "complete"' -- screen size >"${BATS_TEST_TMPDIR}/received"
    cmp "${exec_reply}" "${BATS_TEST_TMPDIR}/received"
    jq -e '.argv == [env.KOINE_TESTANYWARE_CLI,"screen","size","--vm","exact-vm","--json"]' "${exec_root}/000004/request.json"
    check_guest_evidence "${exec_root}"
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 3 ]]
    # Uploads use the checked transfer in vm-file-lifecycle-evidence.bats.
    run cli_guest_evidence "${exec_root}" one-shot upload '.marker == "complete"' -- file upload 'local file' '/tmp/guest file'
    [[ "${status}" == 125 && ! -e "${exec_root}/000005" ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 3 ]]
}

@test "nonexec invalid invocations and missing backends latch before later input" {
    local n=0 args
    for args in check fail cli; do
        n=$((n + 1))
        init_guest_evidence "${exec_root}-${n}" exact-vm
        run python3 "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec.py" "${args}" "${exec_root}-${n}" extra
        [[ "${status}" == 2 && -s "${exec_root}-${n}/unavailable" ]]
        run cli_guest_evidence "${exec_root}-${n}" one-shot click true -- input click 10 20
        [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
    done
    local facade="${BATS_TEST_TMPDIR}/facade/vm-guest-exec-lib.sh"
    mkdir "${facade%/*}"
    cp "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh" "${facade}"
    init_guest_evidence "${exec_root}" exact-vm
    run bash -c 'source "$1"; cli_guest_evidence "$2" one-shot click true -- input click 10 20' _ "${facade}" "${exec_root}"
    [[ "${status}" != 0 && -s "${exec_root}/unavailable" ]]
    [[ "$(cat "${exec_root}/unavailable")" == 'guest-exec backend exit 2' ]]
    [[ "$(cat "${exec_root}/facade-refusals.log")" == "backend_exit=2 argv=cli ${exec_root} one-shot click true -- input click 10 20 " ]]
    run exec_guest_evidence "${exec_root}" one-shot launch probe true
    [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
}

@test "lifecycle evidence binds the pinned identity and never accepts a different stop" {
    init_guest_evidence "${exec_root}" exact-vm
    printf '%s\n' '{"schema_version":"1.0","ok":true,"id":"exact-vm","stopped":true}' >"${exec_reply}"
    cli_guest_evidence "${exec_root}" evidence stop '.id == "exact-vm" and .stopped == true' -- vm stop exact-vm >/dev/null
    jq -e '.argv == [env.KOINE_TESTANYWARE_CLI,"vm","stop","exact-vm","--json"]' "${exec_root}/000001/request.json"
    run cli_guest_evidence "${exec_root}" evidence wrong-stop true -- vm stop other-vm
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
}

@test "nonexec orphan and gate confirmation exec callers share one writer lock" {
    run python3 - "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec.py" "${exec_root}" <<'PY'
import os
import json
import signal
import subprocess
import sys
import time
from pathlib import Path

backend, root = sys.argv[1], Path(sys.argv[2])
subprocess.run([sys.executable, backend, 'init', str(root), 'exact-vm'], check=True)
started, calls = Path(os.environ['exec_started']), Path(os.environ['exec_calls'])
release = root / 'release'
process = subprocess.Popen([sys.executable, backend, 'cli', str(root), 'evidence',
                            'windows', 'true', '--', 'agent', 'windows'],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                           env=dict(os.environ, exec_release=str(release)))
try:
    for _ in range(250):
        if started.exists(): break
        time.sleep(.02)
    assert started.exists(), 'CLI did not start'
    process.send_signal(signal.SIGTERM)
    assert process.wait(timeout=5) == -signal.SIGTERM
    for args in (['poll-step', str(root), 'state', 'state', '1', '.windows == []'],
                 ['check', str(root)], ['fail', str(root), 'confirmation', 'failed'],
                 ['read', str(root), 'evidence', 'context', 'boot'],
                 ['cli', str(root), 'evidence', 'context', 'true', '--', 'agent', 'windows'],
                 ['cli', str(root), 'evidence', 'containment', 'true', '--', 'vm', 'stop', 'exact-vm']):
        result = subprocess.run([sys.executable, backend, *args], capture_output=True)
        assert result.returncode == 125, (args, result.returncode)
        assert (root / 'unavailable').read_text().strip() == 'competing evidence writer', args
        refusal = json.loads((root / 'refusals.jsonl').read_text().splitlines()[-1])
        assert refusal['reason'] == 'competing evidence writer', refusal
        assert refusal['arguments'] == args, refusal
    assert len((root / 'refusals.jsonl').read_text().splitlines()) == 6
    assert calls.read_text().count('\n') == 1
    assert (root / 'unavailable').read_text().strip() == 'competing evidence writer'
    assert not (root / '000002').exists()
finally:
    release.touch()
    if process.poll() is None:
        process.kill()
        process.wait(timeout=5)
    for _ in range(250):
        if Path(str(started) + '.done').exists(): break
        time.sleep(.02)
PY
    printf '%s\n' "${output}"
    [[ "${status}" == 0 ]]
}

change_reply() {
    jq "$1" "${exec_reply}" >"${exec_reply}.new"
    mv "${exec_reply}.new" "${exec_reply}"
}

# The envelope of the checked boot read: scripts/vm_exec_reads.py owns its command.
checked_boot_reply() {
    change_reply '.command = "sysctl -n kern.boottime"
        | .stdout = "{ sec = 1795249999, usec = 1 } Sat Nov 21 19:33:19 2026"'
}

@test "clean exec retains exact bytes, command, VM, status and ordered receipts" {
    init_guest_evidence "${exec_root}" exact-vm
    run exec_guest_evidence "${exec_root}" one-shot launch probe '.stdout == "READY\n"'
    [[ "${status}" == 0 && "${output}" == READY ]]
    cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
    cmp "${exec_stderr}" "${exec_root}/000001/raw.stderr"
    [[ "$(cat "${exec_root}/000001/cli.exit")" == 0 ]]
    jq -e '. == ["file","exec","--vm","exact-vm","--json","--","probe"]' "${exec_calls}"
    jq -e '.ordinal == 1 and .vm == "exact-vm" and .class == "one-shot" and .operation == "launch" and .command == "probe" and (.started | length > 0)' "${exec_root}/000001/request.json"
    jq -e '.outcome == "clean" and (.ended | length > 0) and .duration_ns >= 0' "${exec_root}/000001/result.json"
    printf 'guest diagnostic\n' >"${BATS_TEST_TMPDIR}/want"
    cmp "${BATS_TEST_TMPDIR}/want" "${exec_root}/000001/guest.stderr"
}

@test "initialization refuses reuse without touching existing evidence" {
    init_guest_evidence "${exec_root}" exact-vm
    run init_guest_evidence "${exec_root}" different-vm
    [[ "${status}" != 0 ]]
    jq -e '.vm == "exact-vm"' "${exec_root}/subject.json"
    [[ ! -e "${exec_calls}" ]]
}

@test "missing and wrongly typed envelope fields cannot qualify matching text" {
    local original ordinal=0
    original="$(cat "${exec_reply}")"
    for mutation in 'del(.ok)' 'del(.timed_out)' 'del(.exit_code)' 'del(.stdout)' \
        'del(.stderr)' 'del(.command)' 'del(.schema_version)' '.ok = false' \
        '.timed_out = true' '.exit_code = -1' '.exit_code = false' \
        '.exit_code = "0"' '.ok = "true"' '.timed_out = 0' '.stdout = null' \
        '.stderr = []' '.schema_version = "2.0"' '.command = "other"' '.dry_run = true'; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/case-${ordinal}"
        printf '%s\n' "${original}" >"${exec_reply}"
        change_reply "${mutation}"
        init_guest_evidence "${exec_root}" exact-vm
        run exec_guest_evidence "${exec_root}" read-poll state probe '.stdout == "READY\n"'
        [[ "${status}" == 125 ]]
        [[ -f "${exec_root}/unavailable" ]]
        cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
    done
}

@test "a legacy, partial or undecodable exec record cannot qualify a clean exit" {
    local original ordinal=0
    original="$(cat "${exec_reply}")"
    for mutation in 'del(.record)' '.record = "legacy"' '.legacy_projection = "linux"' \
        '.legacy_projection = null' '.outcome = {"kind":"unknown","reason":"legacy_agent"}' \
        '.outcome = {"kind":"signalled","signal":9,"signal_name":"SIGKILL"}' \
        '.outcome = {"kind":"exited","exit_code":1}' '.outcome.exit_code = false' \
        '.outcome.exit_code = 0.0' '.evidence = null' 'del(.evidence.stderr)' \
        '.evidence.stdout.capture = "incomplete"' '.evidence.stderr.capture = "incomplete"' \
        '.evidence.stdout.base64 = "/w=="' '.evidence.stderr.base64 = "not base64"'; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/record-${ordinal}"
        printf '%s\n' "${original}" >"${exec_reply}"
        change_reply "${mutation}"
        init_guest_evidence "${exec_root}" exact-vm
        run exec_guest_evidence "${exec_root}" read-poll state probe '.stdout == "READY\n"'
        [[ "${status}" == 125 ]]
        [[ -f "${exec_root}/unavailable" ]]
        jq -e '.outcome == "unavailable"' "${exec_root}/000001/result.json"
        cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
    done
    # The same adapter accepts the unchanged complete record.
    exec_root="${BATS_TEST_TMPDIR}/record-clean"
    printf '%s\n' "${original}" >"${exec_reply}"
    init_guest_evidence "${exec_root}" exact-vm
    run exec_guest_evidence "${exec_root}" read-poll state probe '.stdout == "READY\n"'
    [[ "${status}" == 0 ]]
}

@test "a clean CLI status with a withdrawing diagnostic stays unavailable" {
    local ordinal=0 family action line
    printf '%s\n' '{"schema_version":"1.0","ok":true}' >"${exec_reply}"
    while IFS='|' read -r family action line; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/diagnostic-${ordinal}"
        printf 'progress\n%s\n' "${line}" >"${exec_stderr}"
        init_guest_evidence "${exec_root}" exact-vm
        if [[ "${family}" == vm ]]; then
            run cli_guest_evidence "${exec_root}" one-shot start true -- vm start --platform macos
        else
            run cli_guest_evidence "${exec_root}" read-poll step true -- "${family}" "${action}" argument
        fi
        [[ "${status}" == 125 ]]
        [[ -f "${exec_root}/unavailable" ]]
        jq -e '.outcome == "unavailable" and .cli_status == 0' "${exec_root}/000001/result.json"
        cmp "${exec_stderr}" "${exec_root}/000001/raw.stderr"
    done <<'ROWS'
vm|start|  warning: VNC size wait: no session read 1920x1080 within 30 s. The last of 120 sessions read 1280x720. The first command can read that size.
vm|start|  VNC size wait skipped: the screen size of the guest is not known, so the first command can read a stale size
screen|find-text|testanyware: the Vision worker failed (response timeout); trying a new worker
input|click|warning: the guest gave no sign within 10 s that it read the input; the input may not have reached it.
input|key|warning: the guest connection ended before the guest showed that it read the input (reset); the input may not have reached it.
ROWS
}

@test "a diagnostic stays clean when it withdraws nothing for that command" {
    local ordinal=0 family action line
    printf '%s\n' '{"schema_version":"1.0","ok":true}' >"${exec_reply}"
    while IFS='|' read -r family action line; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/benign-${ordinal}"
        printf '%s\n' "${line}" >"${exec_stderr}"
        init_guest_evidence "${exec_root}" exact-vm
        if [[ "${family}" == vm ]]; then
            run cli_guest_evidence "${exec_root}" one-shot start true -- vm start --platform macos
        else
            run cli_guest_evidence "${exec_root}" read-poll step true -- "${family}" "${action}" argument
        fi
        [[ "${status}" == 0 ]]
        [[ ! -e "${exec_root}/unavailable" ]]
    done <<'ROWS'
vm|start|VNC size wait: the first session read 1280x720. Session 2 read 1920x1080 after 0.26 s.
screen|size|testanyware: the Vision worker failed (response timeout); trying a new worker
agent|windows|warning: the guest gave no sign within 10 s that it read the input
ROWS
}

@test "a size wait that can hide a failed session stays unavailable" {
    local ordinal=0 line
    printf '%s\n' '{"schema_version":"1.0","ok":true}' >"${exec_reply}"
    while IFS= read -r line; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/size-wait-${ordinal}"
        printf 'progress\n%s\n' "${line}" >"${exec_stderr}"
        init_guest_evidence "${exec_root}" exact-vm
        run cli_guest_evidence "${exec_root}" one-shot start true -- vm start --platform macos
        [[ "${status}" == 125 ]]
        [[ -f "${exec_root}/unavailable" ]]
        jq -e '.outcome == "unavailable" and .cli_status == 0' "${exec_root}/000001/result.json"
        cmp "${exec_stderr}" "${exec_root}/000001/raw.stderr"
    done <<'ROWS'
VNC size wait: the first session read no size (connection refused). Session 2 read 1920x1080 after 0.26 s.
VNC size wait: the first session read 1280x720. Session 3 read 1920x1080 after 0.75 s.
VNC size wait: the first session read 1280x720. Session 12 read 1920x1080 after 3.01 s.
VNC size wait: the first session read 1280x720. Session 2 read 1920x1080 after 0.26 s. trailing
VNC size wait: a form that the pinned binary does not print
ROWS
}

@test "partial malformed duplicate and multiple JSON responses stay unavailable" {
    local ordinal=0 good
    good="$(cat "${exec_reply}")"
    for reply in '' '{"ok":true' 'not JSON' "${good}${good}" \
        "${good%\}},\"extra\":NaN}" "${good%\}},\"extra\":Infinity}" \
        "${good%\}},\"ok\":false,\"ok\":true}"; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/case-${ordinal}"
        printf '%s' "${reply}" >"${exec_reply}"
        init_guest_evidence "${exec_root}" exact-vm
        run exec_guest_evidence "${exec_root}" read-poll raw probe true
        [[ "${status}" == 125 ]]
        cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
    done
}

@test "nonzero CLI status never qualifies a clean envelope and never retries" {
    for exec_status in 7 255 1; do
        export exec_status
        exec_root="${BATS_TEST_TMPDIR}/status-${exec_status}"
        init_guest_evidence "${exec_root}" exact-vm
        run exec_guest_evidence "${exec_root}" one-shot launch probe true
        [[ "${status}" == 125 ]]
        [[ "$(cat "${exec_root}/000001/cli.exit")" == "${exec_status}" ]]
    done
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 3 ]]
}

@test "timeout with matching real retained output cannot qualify" {
    cp "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/persisted-01/trace-disabled-after.json" "${exec_reply}"
    init_guest_evidence "${exec_root}" exact-vm
    local command
    command="$(jq -r .command "${exec_reply}")"
    run exec_guest_evidence "${exec_root}" read-poll defaults "${command}" '.stdout == "KOINE_TRACE_DISABLED"'
    [[ "${status}" == 125 ]]
    cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
}

@test "missing command completion marker and invalid predicates latch unavailable" {
    local ordinal=0
    for predicate in '.stdout == "COMPLETE"' 'empty' 'true, true' 'true, false' 'null' 'not valid jq' 'halt' 'halt_error(0)'; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/predicate-${ordinal}"
        init_guest_evidence "${exec_root}" exact-vm
        run exec_guest_evidence "${exec_root}" read-poll inventory probe "${predicate}"
        [[ "${status}" == 125 && -f "${exec_root}/unavailable" ]]
    done
}

@test "competing writers latch unavailable before a second transport can dispatch" {
    init_guest_evidence "${exec_root}" exact-vm
    export exec_delay=1
    exec_guest_evidence "${exec_root}" read-poll context probe true >"${BATS_TEST_TMPDIR}/first.out" &
    local writer=$! ready=0
    for _ in $(seq 1 100); do
        if [[ -f "${exec_started}" ]]; then
            ready=1
            break
        fi
        sleep 0.02
    done
    if [[ "${ready}" != 1 ]]; then
        wait "${writer}"
        return 1
    fi
    # A checked read-only read is the only exec that the evidence class admits.
    run _guest_evidence_backend read "${exec_root}" evidence collection boot
    [[ "${status}" == 125 && -e "${exec_root}/unavailable" ]]
    [[ "$(cat "${exec_root}/unavailable")" == 'competing evidence writer' ]]
    wait "${writer}"
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
    run exec_guest_evidence "${exec_root}" read-poll state probe true
    [[ "${status}" == 125 ]]
}

@test "clean negative polling permits the next existing poll without a hidden retry" {
    init_guest_evidence "${exec_root}" exact-vm
    change_reply '.stdout = "ABSENT"'
    run exec_guest_evidence "${exec_root}" read-poll endpoint probe '.stdout == "ABSENT" or .stdout == "PRESENT"'
    [[ "${status}" == 0 && "${output}" == ABSENT ]]
    change_reply '.stdout = "PRESENT"'
    run exec_guest_evidence "${exec_root}" read-poll endpoint probe '.stdout == "ABSENT" or .stdout == "PRESENT"'
    [[ "${status}" == 0 && "${output}" == PRESENT ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 2 ]]
    jq -e '.ordinal == 2' "${exec_root}/000002/request.json"
    [[ ! -e "${exec_root}/unavailable" ]]
}

@test "failed poll latches across command substitution and prevents all later scenario dispatch" {
    init_guest_evidence "${exec_root}" exact-vm
    export exec_status=7
    local text
    text="$(exec_guest_evidence "${exec_root}" read-poll endpoint probe true)" || true
    [[ -z "${text}" ]]
    export exec_status=0
    run exec_guest_evidence "${exec_root}" read-poll endpoint probe true
    [[ "${status}" == 125 ]]
    run exec_guest_evidence "${exec_root}" one-shot reopen probe true
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
}

@test "disconnect followed by changed boot in collection stays unavailable and cannot relaunch" {
    init_guest_evidence "${exec_root}" exact-vm
    export exec_status=255
    run exec_guest_evidence "${exec_root}" one-shot restart probe true
    [[ "${status}" == 125 ]]
    cp "${exec_root}/unavailable" "${BATS_TEST_TMPDIR}/first-failure"
    export exec_status=0
    checked_boot_reply
    run _guest_evidence_backend read "${exec_root}" evidence boot-after boot
    [[ "${status}" == 0 ]]
    cmp "${BATS_TEST_TMPDIR}/first-failure" "${exec_root}/unavailable"
    run exec_guest_evidence "${exec_root}" one-shot launch probe true
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 2 ]]
}

@test "unfinished prior attempt blocks scenario input but allows evidence collection" {
    init_guest_evidence "${exec_root}" exact-vm
    mkdir "${exec_root}/000001"
    printf 'interrupted partial response' >"${exec_root}/000001/raw.stdout"
    run exec_guest_evidence "${exec_root}" one-shot launch probe true
    [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
    checked_boot_reply
    run _guest_evidence_backend read "${exec_root}" evidence context boot
    [[ "${status}" == 0 && -e "${exec_root}/unavailable" ]]
    [[ "$(cat "${exec_root}/000001/raw.stdout")" == 'interrupted partial response' ]]
}

@test "unknown class and missing initialized subject never dispatch" {
    init_guest_evidence "${exec_root}" exact-vm
    run exec_guest_evidence "${exec_root}" retry launch probe true
    [[ "${status}" != 0 ]]
    run exec_guest_evidence "${exec_root}-absent" one-shot launch probe true
    [[ "${status}" != 0 && ! -e "${exec_calls}" ]]
}

@test "argument failures latch initialized roots even when the status is ignored" {
    local ordinal=0
    for failure in unknown missing empty; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/arguments-${ordinal}"
        init_guest_evidence "${exec_root}" exact-vm
        case "${failure}" in
        unknown) exec_guest_evidence "${exec_root}" retry launch probe true || true ;;
        missing) exec_guest_evidence "${exec_root}" one-shot launch probe || true ;;
        empty) exec_guest_evidence "${exec_root}" one-shot '' probe true || true ;;
        esac
        [[ -s "${exec_root}/unavailable" ]]
        run exec_guest_evidence "${exec_root}" one-shot launch probe true
        [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
    done
}

@test "direct backend argument failures latch without the shell facade" {
    init_guest_evidence "${exec_root}" exact-vm
    run python3 "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec.py" run "${exec_root}" one-shot launch probe
    [[ "${status}" == 2 && -s "${exec_root}/unavailable" ]]
    run exec_guest_evidence "${exec_root}" one-shot launch probe true
    [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
}

@test "missing backend and unexpected backend exit leave a persistent facade latch" {
    local facade="${BATS_TEST_TMPDIR}/facade/vm-guest-exec-lib.sh"
    mkdir "${facade%/*}"
    cp "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh" "${facade}"
    for failure in missing unexpected; do
        exec_root="${BATS_TEST_TMPDIR}/${failure}"
        init_guest_evidence "${exec_root}" exact-vm
        if [[ "${failure}" == unexpected ]]; then
            printf 'raise SystemExit(120)\n' >"${facade%/*}/vm-guest-exec.py"
        fi
        run bash -c 'source "$1"; exec_guest_evidence "$2" one-shot launch probe true' _ "${facade}" "${exec_root}"
        [[ "${status}" != 0 && -s "${exec_root}/unavailable" ]]
        run exec_guest_evidence "${exec_root}" one-shot launch probe true
        [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
    done
}

@test "a backend exit of 1 is unavailable and keeps its original status as evidence (k168)" {
    local facade="${BATS_TEST_TMPDIR}/facade/vm-guest-exec-lib.sh"
    mkdir "${facade%/*}"
    cp "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh" "${facade}"
    init_guest_evidence "${exec_root}" exact-vm
    printf 'raise RuntimeError("uncaught backend failure")\n' >"${facade%/*}/vm-guest-exec.py"
    run bash -c 'source "$1"; exec_guest_evidence "$2" read-poll probe probe true' _ "${facade}" "${exec_root}"
    [[ "${status}" == 125 ]]
    [[ "$(cat "${exec_root}/unavailable")" == 'guest-exec backend exit 1' ]]
    [[ "$(cat "${exec_root}/facade-refusals.log")" == "backend_exit=1 argv=run ${exec_root} read-poll probe probe true " ]]
    # A later failure keeps the first reason and adds its own original status.
    printf 'raise SystemExit("uncaught backend exit")\n' >"${facade%/*}/vm-guest-exec.py"
    run bash -c 'source "$1"; record_guest_poll "$2" probe-state state 1 true' _ "${facade}" "${exec_root}"
    [[ "${status}" == 125 ]]
    [[ "$(cat "${exec_root}/unavailable")" == 'guest-exec backend exit 1' ]]
    [[ "$(grep -c '^backend_exit=1 ' "${exec_root}/facade-refusals.log")" == 2 ]]
    # Every other status keeps its value, a signal status included.
    for code in 2 120 130 143; do
        printf 'raise SystemExit(%s)\n' "${code}" >"${facade%/*}/vm-guest-exec.py"
        run bash -c 'source "$1"; exec_guest_evidence "$2" read-poll probe probe true' _ "${facade}" "${exec_root}"
        [[ "${status}" == "${code}" ]]
    done
    printf 'raise SystemExit(0)\n' >"${facade%/*}/vm-guest-exec.py"
    run bash -c 'source "$1"; exec_guest_evidence "$2" read-poll probe probe true' _ "${facade}" "${exec_root}"
    [[ "${status}" == 0 ]]
    # Without an initialised root there is no latch, and 1 is still no clean state.
    printf 'raise SystemExit(1)\n' >"${facade%/*}/vm-guest-exec.py"
    run bash -c 'source "$1"; exec_guest_evidence "$2" read-poll probe probe true' _ "${facade}" "${exec_root}-absent"
    [[ "${status}" == 125 && ! -e "${exec_root}-absent" ]]
}

@test "broken stdout delivery cannot publish a clean terminal receipt" {
    init_guest_evidence "${exec_root}" exact-vm
    run python3 - "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec.py" "${exec_root}" <<'PY'
import json
import subprocess
import sys
from pathlib import Path

backend, root = sys.argv[1], Path(sys.argv[2])
with (root / 'caller.stderr').open('wb') as errors:
    process = subprocess.Popen([sys.executable, backend, 'run', str(root),
                                'one-shot', 'launch', 'probe', 'true'],
                               stdout=subprocess.PIPE, stderr=errors)
    process.stdout.close()
    status = process.wait(timeout=5)
assert status != 0, status
receipt = json.loads((root / '000001/result.json').read_text())
assert receipt['outcome'] == 'unavailable', receipt
assert receipt['emission_status'] == 'failed', receipt
assert receipt['cli_status'] == 0, receipt
assert '000001' in (root / 'unavailable').read_text()
PY
    printf '%s\n' "${output}"
    [[ "${status}" == 0 ]]
    run exec_guest_evidence "${exec_root}" one-shot launch probe true
    [[ "${status}" == 125 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
}

@test "partial or unknown terminal receipts block later scenario dispatch" {
    local ordinal=0
    for receipt in '' '{"outcome":' '{}' '{"outcome":"unknown"}'; do
        ordinal=$((ordinal + 1))
        rm -f "${exec_calls}"
        exec_root="${BATS_TEST_TMPDIR}/receipt-${ordinal}"
        init_guest_evidence "${exec_root}" exact-vm
        mkdir "${exec_root}/000001"
        printf '%s' "${receipt}" >"${exec_root}/000001/result.json"
        run exec_guest_evidence "${exec_root}" one-shot launch probe true
        [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
        checked_boot_reply
        run _guest_evidence_backend read "${exec_root}" evidence context boot
        [[ "${status}" == 0 && -s "${exec_root}/unavailable" ]]
        [[ "$(cat "${exec_root}/000001/result.json")" == "${receipt}" ]]
    done
}

@test "interrupted receipt publication leaves only a partial file" {
    run python3 - "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec.py" "${BATS_TEST_TMPDIR}" <<'PY'
import importlib.util
import sys
from pathlib import Path

sys.path.insert(0, str(Path(sys.argv[1]).resolve().parent))
spec = importlib.util.spec_from_file_location('guest_exec', sys.argv[1])
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
target = Path(sys.argv[2]) / 'result.json'
def interrupt(value, stream, **kwargs):
    stream.write('{"outcome":')
    raise KeyboardInterrupt
module.json.dump = interrupt
try:
    module.write_json(target, {'outcome': 'clean'})
except KeyboardInterrupt:
    pass
assert not target.exists(), 'partial terminal file was published'
assert target.with_name('result.json.partial').read_text() == '{"outcome":'
PY
    printf '%s\n' "${output}"
    [[ "${status}" == 0 ]]
}

@test "killed adapter leaves its CLI holding the writer lock until completion" {
    run python3 - "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec.py" "${exec_root}" <<'PY'
import os
import signal
import subprocess
import sys
import time
from pathlib import Path

backend, base = sys.argv[1], sys.argv[2]
started, calls = Path(os.environ['exec_started']), Path(os.environ['exec_calls'])
for name in ('SIGTERM', 'SIGHUP', 'SIGKILL'):
    root = Path(base + '-' + name)
    subprocess.run([sys.executable, backend, 'init', str(root), 'exact-vm'], check=True)
    release = root / 'release'
    env = dict(os.environ, exec_release=str(release))
    started.unlink(missing_ok=True)
    started.with_suffix('.done').unlink(missing_ok=True)
    calls.unlink(missing_ok=True)
    process = subprocess.Popen([sys.executable, backend, 'run', str(root),
                                'read-poll', 'context', 'probe', 'true'],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env)
    try:
        for _ in range(250):
            if started.exists(): break
            time.sleep(.02)
        assert started.exists(), 'CLI did not start'
        process.send_signal(getattr(signal, name))
        assert process.wait(timeout=5) == -getattr(signal, name)
        second = subprocess.run([sys.executable, backend, 'read', str(root),
                                 'evidence', 'collection', 'boot'],
                                capture_output=True, env=dict(os.environ, exec_delay='0'))
        assert second.returncode == 125, (name, second.returncode)
        assert calls.read_text().count('\n') == 1
        assert (root / 'unavailable').read_text().strip() == 'competing evidence writer'
        assert not (root / '000001/result.json').exists()
    finally:
        release.touch()
        if process.poll() is None:
            process.kill()
            process.wait(timeout=5)
        for _ in range(250):
            if started.with_suffix('.done').exists(): break
            time.sleep(.02)
        assert started.with_suffix('.done').exists(), 'orphan CLI did not finish'
PY
    printf '%s\n' "${output}"
    [[ "${status}" == 0 ]]
}

@test "caught SIGINT records interruption and preserves the signal exit" {
    init_guest_evidence "${exec_root}" exact-vm
    run python3 - "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec.py" "${exec_root}" <<'PY'
import json
import os
import signal
import subprocess
import sys
import time
from pathlib import Path

signal.signal(signal.SIGINT, signal.SIG_DFL)
backend, root = sys.argv[1], Path(sys.argv[2])
started = Path(os.environ['exec_started'])
release = root / 'release'
process = subprocess.Popen([sys.executable, backend, 'run', str(root),
                            'one-shot', 'launch', 'probe', 'true'],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                           env=dict(os.environ, exec_release=str(release)))
try:
    for _ in range(250):
        if started.exists(): break
        time.sleep(.02)
    assert started.exists(), 'CLI did not start'
    process.send_signal(signal.SIGINT)
    assert process.wait(timeout=5) == -signal.SIGINT
    receipt = json.loads((root / '000001/result.json').read_text())
    assert receipt['outcome'] == 'interrupted', receipt
    assert (root / 'unavailable').exists()
finally:
    release.touch()
    if process.poll() is None:
        process.kill()
        process.wait(timeout=5)
PY
    printf '%s\n' "${output}"
    [[ "${status}" == 0 ]]
}

@test "nonexec caught SIGINT retains partial streams and a distinct signal outcome" {
    init_guest_evidence "${exec_root}" exact-vm
    run python3 - "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec.py" "${exec_root}" <<'PY'
import json
import os
import signal
import subprocess
import sys
import time
from pathlib import Path

signal.signal(signal.SIGINT, signal.SIG_DFL)
backend, root = sys.argv[1], Path(sys.argv[2])
started = Path(os.environ['exec_started'])
release = root / 'release'
process = subprocess.Popen([sys.executable, backend, 'cli', str(root),
                            'one-shot', 'click', 'true', '--', 'input', 'click', '10', '20'],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                           env=dict(os.environ, exec_release=str(release)))
try:
    for _ in range(250):
        if started.exists(): break
        time.sleep(.02)
    assert started.exists(), 'CLI did not start'
    process.send_signal(signal.SIGINT)
    assert process.wait(timeout=5) == -signal.SIGINT
    receipt = json.loads((root / '000001/result.json').read_text())
    assert receipt['outcome'] == 'interrupted', receipt
    assert receipt['emission_status'] == 'not-attempted', receipt
    assert (root / 'unavailable').exists()
    assert (root / '000001/raw.stdout').exists()
    later = subprocess.run([sys.executable, backend, 'cli', str(root), 'one-shot',
                            'click', 'true', '--', 'input', 'click', '10', '20'], capture_output=True)
    assert later.returncode == 125
    assert Path(os.environ['exec_calls']).read_text().count('\n') == 1
finally:
    release.touch()
    if process.poll() is None:
        process.kill()
        process.wait(timeout=5)
PY
    printf '%s\n' "${output}"
    [[ "${status}" == 0 ]]
}

# The root can hold KOINE_VM_PASSWORD. A permissive umask and a traversable
# parent must not let another local user enter it or read its receipts.
@test "init creates a root that only its owner can enter, whatever the umask" {
    local parent="${BATS_TEST_TMPDIR}/shared" mask
    mkdir "${parent}"
    chmod 755 "${parent}"
    for mask in 022 000 077; do
        (
            umask "${mask}"
            init_guest_evidence "${parent}/root-${mask}" exact-vm
            exec_guest_evidence "${parent}/root-${mask}" read-poll probe probe true >/dev/null
        )
        [[ "$(stat -f %Lp "${parent}/root-${mask}")" == 700 ]]
        [[ -s "${parent}/root-${mask}/000001/raw.stdout" ]]
    done
}

# start_reply VM [PORT [SPEC]]: the start reply of the tagged CLI. Its agent
# and spec path match declare_clone_spec VM PORT, unless SPEC names another path.
start_reply() {
    jq -cn --arg id "$1" --argjson port "${2:-8648}" \
        --arg spec "${3:-${XDG_STATE_HOME}/testanyware/vms/$1.json}" \
        '{schema_version: "1.0", ok: true, id: $id, agent: {host: "192.0.2.4", port: $port}, spec_path: $spec}'
}

# start_clone ROOT VM [PORT [SPEC]]: one clean VM start through the facade, as
# the scenario sends it. The default exec reply comes back afterwards.
start_clone() {
    cp "${exec_reply}" "${BATS_TEST_TMPDIR}/exec-reply"
    start_reply "${@:2}" >"${exec_reply}"
    cli_guest_evidence "$1" one-shot vm-start true -- vm start --platform macos >/dev/null
    cp "${BATS_TEST_TMPDIR}/exec-reply" "${exec_reply}"
}

@test "init refuses an undeclared, relative, linked or non-executable tool and creates no root (k180)" {
    local cli="${KOINE_TESTANYWARE_CLI}" case
    ln -s "${cli}" "${BATS_TEST_TMPDIR}/linked-cli"
    cp "${cli}" "${BATS_TEST_TMPDIR}/still-cli"
    chmod -x "${BATS_TEST_TMPDIR}/still-cli"
    for case in unset-cli relative-cli linked-cli still-cli unset-jq missing-jq; do
        (
            case "${case}" in
            unset-cli) unset KOINE_TESTANYWARE_CLI ;;
            relative-cli)
                # The relative path names the real CLI from here.
                cd "${BATS_TEST_TMPDIR}"
                export KOINE_TESTANYWARE_CLI=bin/testanyware
                ;;
            linked-cli) export KOINE_TESTANYWARE_CLI="${BATS_TEST_TMPDIR}/linked-cli" ;;
            still-cli) export KOINE_TESTANYWARE_CLI="${BATS_TEST_TMPDIR}/still-cli" ;;
            unset-jq) unset KOINE_JQ ;;
            missing-jq) export KOINE_JQ="${BATS_TEST_TMPDIR}/no-jq" ;;
            esac
            run init_guest_evidence "${exec_root}-${case}" exact-vm
            [[ "${status}" == 125 && ! -e "${exec_root}-${case}" ]]
        )
    done
    [[ ! -e "${exec_calls}" ]]
}

@test "each attempt runs the declared executables and its receipt names them (k180)" {
    cat >"${BATS_TEST_TMPDIR}/declared-jq" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"${BATS_TEST_TMPDIR}/declared-jq.log"
exec "${KOINE_JQ}" "\$@"
SH
    chmod +x "${BATS_TEST_TMPDIR}/declared-jq"
    export KOINE_JQ="${BATS_TEST_TMPDIR}/declared-jq"
    init_guest_evidence "${exec_root}" exact-vm
    exec_guest_evidence "${exec_root}" read-poll probe probe '.stdout == "READY\n"' >/dev/null
    jq -e --arg cli "${KOINE_TESTANYWARE_CLI}" --arg jq "${KOINE_JQ}" \
        '.argv[0] == $cli and .jq == $jq' "${exec_root}/000001/request.json"
    jq -e --arg cli "$(shasum -a 256 "${KOINE_TESTANYWARE_CLI}" | cut -d' ' -f1)" \
        --arg jq "$(shasum -a 256 "${KOINE_JQ}" | cut -d' ' -f1)" \
        '.executables.testanyware.sha256 == $cli and .executables.jq.sha256 == $jq
            and (.executables | map_values(keys) | .testanyware == .jq
            and .jq == ["bytes", "device", "inode", "path", "sha256"])' "${exec_root}/subject.json"
    grep -q '^-e \[(.stdout == "READY\\n")\] == \[true\]$' "${BATS_TEST_TMPDIR}/declared-jq.log"
}

@test "a changed, replaced or missing executable refuses the attempt before dispatch and latches (k180)" {
    local case
    for case in changed-cli replaced-jq missing-cli; do
        (
            cp "${KOINE_TESTANYWARE_CLI}" "${BATS_TEST_TMPDIR}/cli-${case}"
            export KOINE_TESTANYWARE_CLI="${BATS_TEST_TMPDIR}/cli-${case}"
            cp "${KOINE_JQ}" "${BATS_TEST_TMPDIR}/jq-${case}"
            export KOINE_JQ="${BATS_TEST_TMPDIR}/jq-${case}"
            init_guest_evidence "${exec_root}-${case}" exact-vm
            case "${case}" in
            changed-cli) printf '# changed\n' >>"${KOINE_TESTANYWARE_CLI}" ;;
            replaced-jq)
                cp "${KOINE_JQ}" "${KOINE_JQ}.new"
                mv "${KOINE_JQ}.new" "${KOINE_JQ}"
                ;;
            missing-cli) rm "${KOINE_TESTANYWARE_CLI}" ;;
            esac
            run exec_guest_evidence "${exec_root}-${case}" read-poll probe probe true
            [[ "${status}" == 125 && ! -e "${exec_calls}" ]]
            [[ ! -e "${exec_root}-${case}/000001/raw.stdout" ]]
            jq -e '.outcome == "unavailable" and .cli_status == null
                and (.reason | test("^the declared (testanyware|jq) executable"))' \
                "${exec_root}-${case}/000001/result.json"
            grep -q '^000001: the declared ' "${exec_root}-${case}/unavailable"
        )
    done
}

@test "the clone provenance records the spec, its digest, the endpoint and the resolving paths once (k180)" {
    local spec="${XDG_STATE_HOME}/testanyware/vms/exact-vm.json"
    init_guest_evidence "${exec_root}" exact-vm
    start_clone "${exec_root}" exact-vm 51234
    declare_clone_spec exact-vm 51234
    record_guest_provenance "${exec_root}" clone-provenance
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
    jq -e '.transport == "provenance" and .argv == [] and .class == "read-poll"
        and .operation == "clone-provenance" and (has("jq") | not)' "${exec_root}/000002/request.json"
    jq -e '.outcome == "clean" and .emission_status == "not-attempted"' "${exec_root}/000002/result.json"
    jq -e --arg spec "${spec}" --arg sha "$(shasum -a 256 "${spec}" | cut -d' ' -f1)" \
        --arg state "${XDG_STATE_HOME}/testanyware" --arg config "${TESTANYWARE_CONFIG}" \
        --arg csha "$(shasum -a 256 "${TESTANYWARE_CONFIG}" | cut -d' ' -f1)" '
        .ordinal == 2 and .vm == "exact-vm" and .spec.path == $spec and .spec.sha256 == $sha
        and .agent == {host: "192.0.2.4", port: 51234} and .state_dir == $state
        and .state_source == "XDG_STATE_HOME"
        and .config == {path: $config, state: "empty", sha256: $csha}
        and .environment.XDG_STATE_HOME == env.XDG_STATE_HOME
        and .environment.TESTANYWARE_APP_SOCKET == null
        and .start == {ordinal: 1, agent: .agent, spec_path: $spec}' "${exec_root}/provenance.json"
    # A second record refuses even before any guest transport.
    run record_guest_provenance "${exec_root}" clone-provenance-again
    [[ "${status}" == 125 ]]
    jq -e '.outcome == "unavailable" and (.reason | test("[Ff]ile exists"))' "${exec_root}/000003/result.json"
    [[ "$(jq -r .ordinal "${exec_root}/provenance.json")" == 2 ]]
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 1 ]]
}

@test "provenance refuses before a VM start and after a guest transport (k180)" {
    declare_clone_spec exact-vm
    init_guest_evidence "${exec_root}-early" exact-vm
    run record_guest_provenance "${exec_root}-early" clone-provenance
    [[ "${status}" == 125 && ! -e "${exec_root}-early/provenance.json" ]]
    jq -e '.reason == "no VM start precedes the clone provenance"' "${exec_root}-early/000001/result.json"
    init_guest_evidence "${exec_root}-late" exact-vm
    exec_guest_evidence "${exec_root}-late" read-poll probe probe true >/dev/null
    start_clone "${exec_root}-late" exact-vm
    run record_guest_provenance "${exec_root}-late" clone-provenance
    [[ "${status}" == 125 && ! -e "${exec_root}-late/provenance.json" ]]
    jq -e '.reason == "a guest transport precedes the clone provenance"' "${exec_root}-late/000003/result.json"
}

@test "a guest transport after a VM start needs a provenance record, and VM lifecycle does not (k180)" {
    init_guest_evidence "${exec_root}" exact-vm
    start_clone "${exec_root}" exact-vm
    printf '%s\n' '{"schema_version":"1.0","ok":true,"vms":[]}' >"${BATS_TEST_TMPDIR}/list"
    cp "${exec_reply}" "${BATS_TEST_TMPDIR}/exec-reply"
    cp "${BATS_TEST_TMPDIR}/list" "${exec_reply}"
    cli_guest_evidence "${exec_root}" read-poll vm-after '.vms == []' -- vm list >/dev/null
    cp "${BATS_TEST_TMPDIR}/exec-reply" "${exec_reply}"
    run exec_guest_evidence "${exec_root}" read-poll probe probe true
    [[ "${status}" == 125 && "$(wc -l <"${exec_calls}" | tr -d ' ')" == 2 ]]
    jq -e '.reason == "no clone provenance precedes this guest transport" and .cli_status == null' \
        "${exec_root}/000003/result.json"
    grep -q '^000003: no clone provenance' "${exec_root}/unavailable"
    # The latch admits collection, but collection reaches the guest, so it refuses too.
    run cli_guest_evidence "${exec_root}" evidence failure-windows true -- agent windows
    [[ "${status}" == 125 && "$(wc -l <"${exec_calls}" | tr -d ' ')" == 2 ]]
    jq -e '.reason == "no clone provenance precedes this guest transport"' "${exec_root}/000004/result.json"
}

@test "a missing, changed or different spec refuses the next guest transport and latches (k180)" {
    local case spec
    for case in changed missing other-state; do
        (
            export XDG_STATE_HOME="${BATS_TEST_TMPDIR}/state-${case}"
            spec="${XDG_STATE_HOME}/testanyware/vms/exact-vm.json"
            init_guest_evidence "${exec_root}-${case}" exact-vm
            start_clone "${exec_root}-${case}" exact-vm
            declare_clone_spec exact-vm
            record_guest_provenance "${exec_root}-${case}" clone-provenance
            case "${case}" in
            changed) declare_clone_spec exact-vm 8649 ;;
            missing) rm "${spec}" ;;
            other-state)
                mkdir -p "${XDG_STATE_HOME}-other/testanyware/vms"
                cp "${spec}" "${XDG_STATE_HOME}-other/testanyware/vms/"
                export XDG_STATE_HOME="${XDG_STATE_HOME}-other"
                ;;
            esac
            local before
            before="$(wc -l <"${exec_calls}" | tr -d ' ')"
            run exec_guest_evidence "${exec_root}-${case}" read-poll probe probe true
            [[ "${status}" == 125 && "$(wc -l <"${exec_calls}" | tr -d ' ')" == "${before}" ]]
            jq -e '.outcome == "unavailable" and .cli_status == null
                and (.reason | startswith("the clone spec mapping"))' "${exec_root}-${case}/000003/result.json"
            run cli_guest_evidence "${exec_root}-${case}" evidence failure-windows true -- agent windows
            [[ "${status}" == 125 && "$(wc -l <"${exec_calls}" | tr -d ' ')" == "${before}" ]]
            # The exact stop is VM lifecycle, so the changed spec does not refuse it.
            cp "${exec_reply}" "${BATS_TEST_TMPDIR}/exec-reply"
            printf '%s\n' '{"schema_version":"1.0","ok":true,"id":"exact-vm"}' >"${exec_reply}"
            cli_guest_evidence "${exec_root}-${case}" evidence stop true -- vm stop exact-vm >/dev/null
            cp "${BATS_TEST_TMPDIR}/exec-reply" "${exec_reply}"
            grep -q '^000003: the clone spec mapping' "${exec_root}-${case}/unavailable"
        )
        : >"${exec_calls}"
    done
}

@test "a configuration or environment that the harness cannot evaluate refuses the provenance (k180)" {
    local case
    for case in setting quoted unclosed semicolon socket relative-state relative-config no-home agentless; do
        (
            # A case's file outlives its subshell, so each case starts clean.
            declare_config
            declare_clone_spec exact-vm
            case "${case}" in
            setting) printf '#{\n    state_dir: "/elsewhere",\n}\n' >"${TESTANYWARE_CONFIG}" ;;
            quoted) printf '#{ } // "\n"x"\n' >"${TESTANYWARE_CONFIG}" ;;
            unclosed) printf '/* /* */ #{ }\n' >"${TESTANYWARE_CONFIG}" ;;
            semicolon) printf '#{ };\n' >"${TESTANYWARE_CONFIG}" ;;
            socket) export TESTANYWARE_APP_SOCKET="${BATS_TEST_TMPDIR}/other.sock" ;;
            # Each relative path names the real file from here.
            relative-state) cd "${BATS_TEST_TMPDIR}" && export XDG_STATE_HOME=state ;;
            relative-config) cd "${BATS_TEST_TMPDIR}" && export TESTANYWARE_CONFIG=config.rhai ;;
            no-home) unset HOME ;;
            agentless)
                printf '{"vnc":{"host":"127.0.0.1","port":5901},"platform":"macos"}\n' \
                    >"${XDG_STATE_HOME}/testanyware/vms/exact-vm.json"
                ;;
            esac
            init_guest_evidence "${exec_root}-${case}" exact-vm
            start_clone "${exec_root}-${case}" exact-vm
            run record_guest_provenance "${exec_root}-${case}" clone-provenance
            [[ "${status}" == 125 && ! -e "${exec_root}-${case}/provenance.json" ]]
            jq -e '.outcome == "unavailable"' "${exec_root}-${case}/000002/result.json"
        )
    done
    for case in nested absent disabled; do
        (
            declare_config
            declare_clone_spec exact-vm
            case "${case}" in
            nested) printf '/* a /* nested */ comment */ #{\n} // end\n' >"${TESTANYWARE_CONFIG}" ;;
            absent) rm "${TESTANYWARE_CONFIG}" ;;
            disabled) export TESTANYWARE_CONFIG=none ;;
            esac
            init_guest_evidence "${exec_root}-${case}" exact-vm
            start_clone "${exec_root}-${case}" exact-vm
            record_guest_provenance "${exec_root}-${case}" clone-provenance
            jq -e --arg state "$([[ "${case}" == nested ]] && echo empty || echo "${case}")" \
                '.config.state == $state' "${exec_root}-${case}/provenance.json"
        )
    done
}

@test "the clone provenance must match the one start reply, and a mismatch refuses it (k182)" {
    local case ordinal
    for case in other-port other-path no-agent second-start; do
        (
            init_guest_evidence "${exec_root}-${case}" exact-vm
            ordinal=2
            case "${case}" in
            other-port) start_clone "${exec_root}-${case}" exact-vm 9999 ;;
            other-path) start_clone "${exec_root}-${case}" exact-vm 8648 /elsewhere/vms/exact-vm.json ;;
            no-agent)
                cp "${exec_reply}" "${BATS_TEST_TMPDIR}/exec-reply"
                start_reply exact-vm | jq -c 'del(.agent)' >"${exec_reply}"
                cli_guest_evidence "${exec_root}-${case}" one-shot vm-start true -- vm start --platform macos >/dev/null
                cp "${BATS_TEST_TMPDIR}/exec-reply" "${exec_reply}"
                ;;
            second-start)
                start_clone "${exec_root}-${case}" exact-vm
                start_clone "${exec_root}-${case}" exact-vm
                ordinal=3
                ;;
            esac
            declare_clone_spec exact-vm
            run record_guest_provenance "${exec_root}-${case}" clone-provenance
            [[ "${status}" == 125 && ! -e "${exec_root}-${case}/provenance.json" ]]
            jq -e '.outcome == "unavailable" and .cli_status == null
                and (.reason | test("start reply|VM starts precede"))' \
                "${exec_root}-${case}/00000${ordinal}/result.json"
            grep -q "^00000${ordinal}: " "${exec_root}-${case}/unavailable"
        )
    done
}

@test "a change during an attempt makes that attempt unavailable, before any clean result (k182)" {
    local case ordinal
    for case in spec cli jq; do
        (
            cp "${KOINE_JQ}" "${BATS_TEST_TMPDIR}/jq-${case}"
            export KOINE_JQ="${BATS_TEST_TMPDIR}/jq-${case}"
            # The CLI answers, then makes one change before jq reads its answer.
            cat >"${BATS_TEST_TMPDIR}/cli-${case}" <<SH
#!/bin/bash
"${BATS_TEST_TMPDIR}/bin/testanyware" "\$@"
status=\$?
[[ " \$* " == *" --vm "* ]] || exit "\${status}"
case "${case}" in
spec) printf '{"agent":{"host":"192.0.2.4","port":8649}}\n' >"${XDG_STATE_HOME}/testanyware/vms/exact-vm.json" ;;
cli) printf '# changed\n' >>"\$0" ;;
jq) cp "${KOINE_JQ}" "${KOINE_JQ}.new" && mv "${KOINE_JQ}.new" "${KOINE_JQ}" ;;
esac
exit "\${status}"
SH
            chmod +x "${BATS_TEST_TMPDIR}/cli-${case}"
            export KOINE_TESTANYWARE_CLI="${BATS_TEST_TMPDIR}/cli-${case}"
            init_guest_evidence "${exec_root}-${case}" exact-vm
            ordinal=1
            if [[ "${case}" == spec ]]; then
                start_clone "${exec_root}-${case}" exact-vm
                declare_clone_spec exact-vm
                record_guest_provenance "${exec_root}-${case}" clone-provenance
                ordinal=3
            fi
            run exec_guest_evidence "${exec_root}-${case}" read-poll probe probe true
            [[ "${status}" == 125 && "${output}" != *READY* ]]
            jq -e '.outcome == "unavailable" and .cli_status == 0
                and .emission_status == "not-attempted"
                and (.reason | startswith("after the attempt, "))' \
                "${exec_root}-${case}/00000${ordinal}/result.json"
            grep -q "^00000${ordinal}: after the attempt, " "${exec_root}-${case}/unavailable"
        )
    done
}
