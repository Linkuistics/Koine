#!/usr/bin/env bats
# The launch identity read runs its real command on this host through
# /bin/bash -c, as the tagged agent runs it in a guest. A temporary HOME holds
# a descriptor that names a host process, so the real pgrep, python3, ctypes,
# proc_pidinfo and proc_pidpath answer. No submission runs here: each one would
# change host state, so only its bash syntax is checked. This is host evidence,
# not guest evidence. It launches no Koine. The tests that call fake_libproc
# keep the real command, pgrep and script, but a fake libSystem answers the
# three libproc calls, because no host process fails its path read on demand.

setup() {
    bats_require_minimum_version 1.5.0
    # shellcheck source=scripts/vm-exec-one-shot-evidence-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-exec-one-shot-evidence-lib.sh"
    export read_calls="${BATS_TEST_TMPDIR}/calls" read_mode=host
    export read_stdout="${BATS_TEST_TMPDIR}/unused"
    export read_fixture="${BATS_TEST_DIRNAME}/fixtures/exec-read-cli.py"
    : >"${read_stdout}"
    mkdir "${BATS_TEST_TMPDIR}/bin"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
exec python3 "${read_fixture}" "$@"
CLI
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    # Resolve the interpreter before a fake_libproc shim can shadow it.
    real_python3="$(command -v python3)"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    # shellcheck source=Tests/scripts/fixtures/declared-tools.sh
    source "${BATS_TEST_DIRNAME}/fixtures/declared-tools.sh"
    declare_tools "${BATS_TEST_TMPDIR}/bin/testanyware"
    export HOME="${BATS_TEST_TMPDIR}/home"
    mkdir -p "${HOME}/Library/Application Support/Koine"
}

teardown() {
    [[ -z "${holder:-}" ]] || kill "${holder}" 2>/dev/null || :
}

# describe PID: a version-1 descriptor that names PID.
describe() {
    printf '{"contractVersion":"koine-desktop/1","descriptorVersion":1,"instanceId":"host","path":"/graphql","pid":%s,"port":49152}\n' \
        "$1" >"${HOME}/Library/Application Support/Koine/endpoint.json"
}

@test "the real identity read names the kernel's executable and the start of a live host process" {
    local root="${BATS_TEST_TMPDIR}/host" record lstart
    /bin/sleep 300 &
    holder=$!
    describe "${holder}"
    init_guest_evidence "${root}" host-identity
    record="$(read_guest_exec "${root}" read-poll host-identity launch-identity)"
    echo "diagnostic: ${record}"
    # A sleep is not Koine, so the join fails cleanly on the executable.
    jq -e --argjson pid "${holder}" '.present and (.joined | not) and .process.pid == $pid
        and .process.executable == "/bin/sleep" and .selected == []' <<<"${record}"
    # The kernel start second is the second that ps prints.
    lstart="$(LC_ALL=C ps -o lstart= -p "${holder}" | sed 's/ *$//')"
    [[ "$(LC_ALL=C date -j -f '%a %b %e %T %Y' "${lstart}" +%s)" == "$(jq -r .process.start_sec <<<"${record}")" ]]
    jq -e '.process.start_usec | . >= 0 and . < 1000000' <<<"${record}"
}

@test "the real identity read reports an exited process as the clean fact no process" {
    local root="${BATS_TEST_TMPDIR}/host" record
    /bin/sleep 300 &
    holder=$!
    describe "${holder}"
    kill "${holder}"
    wait "${holder}" 2>/dev/null || :
    init_guest_evidence "${root}" host-identity
    record="$(read_guest_exec "${root}" read-poll host-identity launch-identity)"
    echo "diagnostic: ${record}"
    jq -e '.present and .process == null and (.joined | not)' <<<"${record}"
}

@test "the real identity read reports an absent descriptor as a clean fact" {
    local root="${BATS_TEST_TMPDIR}/host" record
    init_guest_evidence "${root}" host-identity
    record="$(read_guest_exec "${root}" read-poll host-identity launch-identity)"
    jq -e '.present == false and .joined == false' <<<"${record}"
}

@test "a descriptor without a PID makes the real identity read unavailable" {
    local root="${BATS_TEST_TMPDIR}/host"
    printf '{"pid": "x"}' >"${HOME}/Library/Application Support/Koine/endpoint.json"
    init_guest_evidence "${root}" host-identity
    run read_guest_exec "${root}" read-poll host-identity launch-identity
    echo "diagnostic: status=${status} output=${output}"
    [[ "${status}" == 125 ]]
    jq -e '.exit_code == 3' "${root}/000001/raw.stdout"
}

# fake_libproc SCENARIO: the guest's `python3 -I -c SCRIPT FILE` runs the real
# script under Tests/scripts/fixtures/identity-libproc-fake.py with SCENARIO.
# Every other python3 call, such as the CLI fixture, runs unchanged.
fake_libproc() {
    cat >"${BATS_TEST_TMPDIR}/bin/python3" <<SHIM
#!/bin/bash
if [[ "\$1" == -I && "\$2" == -c && \$# == 4 ]]; then
    exec "${real_python3}" "${BATS_TEST_DIRNAME}/fixtures/identity-libproc-fake.py" "$1" "\$3" "\$4"
fi
exec "${real_python3}" "\$@"
SHIM
    chmod +x "${BATS_TEST_TMPDIR}/bin/python3"
    describe 501
    init_guest_evidence "${BATS_TEST_TMPDIR}/host" host-identity
}

@test "the fake libproc answers the real identity script with a live process" {
    local record
    fake_libproc live
    record="$(read_guest_exec "${BATS_TEST_TMPDIR}/host" read-poll host-identity launch-identity)"
    echo "diagnostic: ${record}"
    jq -e '.present and .process == {executable: "/Applications/Koine.app/Contents/MacOS/Koine",
        pid: 501, start_sec: 1795270100, start_usec: 250000}' <<<"${record}"
}

@test "a path read that fails with ESRCH while the process lives makes the identity unavailable" {
    local root="${BATS_TEST_TMPDIR}/host" scenario
    # Each scenario and the script status that it must give.
    local -A expected=(["path-esrch-live"]=7 ["path-eperm-live"]=5 ["info-eperm"]=4 ["reuse-during-read"]=6)
    for scenario in path-esrch-live path-eperm-live info-eperm reuse-during-read; do
        rm -rf "${root}"
        fake_libproc "${scenario}"
        run confirm_guest_launch "${root}" launch-identity
        echo "diagnostic: ${scenario} status=${status} output=${output}"
        # A missing executable identity is unavailable and latches the root. It
        # is never the clean mismatch status 1 of an absent process.
        [[ "${status}" == 125 && -s "${root}/unavailable" ]]
        jq -e --argjson code "${expected[${scenario}]}" '.exit_code == $code' "${root}/000001/raw.stdout"
    done
}

@test "the identity script reports an absent process only from a process-info read" {
    local root="${BATS_TEST_TMPDIR}/host" scenario
    for scenario in absent exit-during-read; do
        rm -rf "${root}"
        fake_libproc "${scenario}"
        run confirm_guest_launch "${root}" launch-identity
        echo "diagnostic: ${scenario} status=${status} output=${output}"
        [[ "${status}" == 1 && ! -e "${root}/unavailable" ]]
        jq -e '.present and .process == null and (.joined | not)' "${root}/000001/read.json"
    done
}

@test "the real TextEdit process read parses this host's answer" {
    local root="${BATS_TEST_TMPDIR}/host"
    init_guest_evidence "${root}" host-textedit
    read_guest_exec "${root}" evidence host-textedit process textedit >/dev/null
    jq -e '.read == "process" and (.selected | type == "array")' "${root}/000001/read.json"
}

@test "each submission command is valid bash" {
    local name command
    for name in extract-bundle open-koine open-textedit quit-textedit request-automation \
        open-accessibility-pane restart; do
        command="$(PYTHONPATH="${BATS_TEST_DIRNAME}/../../scripts" python3 -c 'import sys, vm_exec_reads as r; print(r.command(sys.argv[1], "one-shot", []), end="")' \
            "${name}")"
        echo "diagnostic: ${name}: ${command}"
        /bin/bash -n -c "${command}"
    done
}

@test "the real PID identity read names a live host process and reports an exited one as no process" {
    local root="${BATS_TEST_TMPDIR}/pid-host" record lstart gone
    /bin/sleep 300 &
    holder=$!
    init_guest_evidence "${root}" host-pid-identity
    record="$(read_guest_exec "${root}" read-poll host-liveness process-identity "${holder}")"
    echo "diagnostic: ${record}"
    jq -e --argjson pid "${holder}" '.pid == $pid and .process.pid == $pid
        and .process.executable == "/bin/sleep"' <<<"${record}"
    lstart="$(LC_ALL=C ps -o lstart= -p "${holder}" | sed 's/ *$//')"
    [[ "$(LC_ALL=C date -j -f '%a %b %e %T %Y' "${lstart}" +%s)" == "$(jq -r .process.start_sec <<<"${record}")" ]]
    /bin/sleep 0.01 &
    gone=$!
    wait "${gone}"
    record="$(read_guest_exec "${root}" read-poll host-gone process-identity "${gone}")"
    jq -e --argjson pid "${gone}" '.pid == $pid and .process == null' <<<"${record}"
    [[ ! -e "${root}/unavailable" ]]
}
