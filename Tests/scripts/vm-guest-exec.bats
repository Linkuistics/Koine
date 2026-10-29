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
    printf 'CLI diagnostic\n' >"${exec_stderr}"
    printf '%s\n' '{"schema_version":"1.0","command":"probe","ok":true,"exit_code":0,"timed_out":false,"stdout":"READY\n","stderr":"guest diagnostic\n"}' >"${exec_reply}"
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
    jq -e '.ordinal == 2 and .transport == "cli" and .vm == "exact-vm" and .argv == ["testanyware","input","click","10","20","--vm","exact-vm","--json"]' "${exec_root}/000002/request.json"
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
    for action in windows snapshot size download list stop; do
        case "${action}" in
        windows) set -- agent windows ;;
        snapshot) set -- agent snapshot --window TextEdit ;;
        size) set -- screen size ;;
        download) set -- file download /tmp/evidence local ;;
        list) set -- vm list --all ;;
        stop) set -- vm stop exact-vm ;;
        esac
        run cli_guest_evidence "${exec_root}" evidence "${action}" '.ok == true' -- "$@"
        [[ "${status}" == 0 ]]
    done
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 6 ]]
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

@test "nonexec start list upload and screen size retain explicit call payloads" {
    init_guest_evidence "${exec_root}" exact-vm
    printf '%s\n' '{"schema_version":"1.0","ok":true,"id":"exact-vm"}' >"${exec_reply}"
    cli_guest_evidence "${exec_root}" one-shot start '.id == "exact-vm"' -- vm start --platform macos --wait >/dev/null
    jq -e '.argv == ["testanyware","vm","start","--platform","macos","--wait","--id","exact-vm","--json"]' "${exec_root}/000001/request.json"
    printf '%s\n' '{"schema_version":"1.0","ok":true,"vms":[]}' >"${exec_reply}"
    cli_guest_evidence "${exec_root}" evidence stopped '.vms == []' -- vm list --all >/dev/null
    jq -e '.argv == ["testanyware","vm","list","--all","--json"]' "${exec_root}/000002/request.json"
    printf '%s\n' '{"schema_version":"1.0","ok":true,"marker":"complete"}' >"${exec_reply}"
    cli_guest_evidence "${exec_root}" one-shot upload '.marker == "complete"' -- file upload 'local file' '/tmp/guest file' >/dev/null
    cli_guest_evidence "${exec_root}" evidence size '.marker == "complete"' -- screen size >"${BATS_TEST_TMPDIR}/received"
    cmp "${exec_reply}" "${BATS_TEST_TMPDIR}/received"
    jq -e '.argv == ["testanyware","file","upload","local file","/tmp/guest file","--vm","exact-vm","--json"]' "${exec_root}/000003/request.json"
    jq -e '.argv == ["testanyware","screen","size","--vm","exact-vm","--json"]' "${exec_root}/000004/request.json"
    check_guest_evidence "${exec_root}"
    [[ "$(wc -l <"${exec_calls}" | tr -d ' ')" == 4 ]]
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
    jq -e '.argv == ["testanyware","vm","stop","exact-vm","--json"]' "${exec_root}/000001/request.json"
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
                 ['run', str(root), 'evidence', 'context', 'probe', 'true'],
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
        run exec_guest_evidence "${exec_root}" evidence raw probe true
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
    run exec_guest_evidence "${exec_root}" evidence defaults "${command}" '.stdout == "KOINE_TRACE_DISABLED"'
    [[ "${status}" == 125 ]]
    cmp "${exec_reply}" "${exec_root}/000001/raw.stdout"
}

@test "missing command completion marker and invalid predicates latch unavailable" {
    local ordinal=0
    for predicate in '.stdout == "COMPLETE"' 'empty' 'true, true' 'true, false' 'null' 'not valid jq' 'halt' 'halt_error(0)'; do
        ordinal=$((ordinal + 1))
        exec_root="${BATS_TEST_TMPDIR}/predicate-${ordinal}"
        init_guest_evidence "${exec_root}" exact-vm
        run exec_guest_evidence "${exec_root}" evidence inventory probe "${predicate}"
        [[ "${status}" == 125 && -f "${exec_root}/unavailable" ]]
    done
}

@test "competing writers latch unavailable before a second transport can dispatch" {
    init_guest_evidence "${exec_root}" exact-vm
    export exec_delay=1
    exec_guest_evidence "${exec_root}" evidence context probe true >"${BATS_TEST_TMPDIR}/first.out" &
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
    run exec_guest_evidence "${exec_root}" evidence collection probe true
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
    change_reply '.stdout = "CHANGED_BOOT"'
    run exec_guest_evidence "${exec_root}" evidence boot-after probe '.stdout == "CHANGED_BOOT"'
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
    run exec_guest_evidence "${exec_root}" evidence context probe true
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
        run exec_guest_evidence "${exec_root}" evidence context probe true
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
                                'evidence', 'context', 'probe', 'true'],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env)
    try:
        for _ in range(250):
            if started.exists(): break
            time.sleep(.02)
        assert started.exists(), 'CLI did not start'
        process.send_signal(getattr(signal, name))
        assert process.wait(timeout=5) == -getattr(signal, name)
        second = subprocess.run([sys.executable, backend, 'run', str(root),
                                 'evidence', 'collection', 'probe', 'true'],
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
