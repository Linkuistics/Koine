#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Every test owns its environment.

setup() {
    bats_require_minimum_version 1.5.0
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    if [[ "${KOINE_CAPTURE_BASELINE:-0}" == 1 ]]; then
        # Bare legacy capture and while/sleep/ignored-failure keepalive semantics.
        # These test-only wrappers adapt the new signature, not the production API.
        # shellcheck disable=SC2329
        capture_guest_evidence() {
            if [[ $# == 5 ]]; then
                testanyware screen capture --region "$5" -o "$1/keepalive.png" --json
            else
                testanyware screen capture -o "$1/keepalive.png" --json
            fi
        }
        # shellcheck disable=SC2329
        keepalive_guest_evidence() {
            while sleep 20; do capture_guest_evidence "$1" read-poll keepalive >/dev/null 2>&1 || true; done
        }
    else
        # shellcheck source=scripts/vm-capture-evidence-lib.sh
        source "${BATS_TEST_DIRNAME}/../../scripts/vm-capture-evidence-lib.sh"
    fi
    export capture_root="${BATS_TEST_TMPDIR}/evidence"
    export capture_calls="${BATS_TEST_TMPDIR}/calls" capture_waits="${BATS_TEST_TMPDIR}/waits"
    export capture_ready="${BATS_TEST_TMPDIR}/ready"
    export capture_fixture="${BATS_TEST_DIRNAME}/fixtures/capture-cli.py"
    export capture_mode=clean capture_exit=0 capture_block=0
    mkdir "${BATS_TEST_TMPDIR}/bin" "${BATS_TEST_TMPDIR}/cwd"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
exec python3 "${capture_fixture}" "$@"
CLI
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    : >"${capture_calls}"
    : >"${capture_waits}"
    cd "${BATS_TEST_TMPDIR}/cwd" || return
    init_guest_evidence "${capture_root}" exact-capture-vm
}

reset_capture() {
    capture_root="${BATS_TEST_TMPDIR}/$1"
    init_guest_evidence "${capture_root}" exact-capture-vm
    : >"${capture_calls}"
}

assert_capture_latched() {
    local count
    count="$(wc -l <"${capture_calls}")"
    run cli_guest_evidence "${capture_root}" one-shot later '.key == "return" and .modifiers == []' -- input key return
    [[ "${status}" == 125 && -s "${capture_root}/unavailable" ]]
    [[ "$(wc -l <"${capture_calls}")" == "${count}" ]]
}

@test "full capture retains complete image raw bytes exact VM and artifact digest" {
    capture_guest_evidence "${capture_root}" read-poll first >"${BATS_TEST_TMPDIR}/actual"
    cmp "${BATS_TEST_TMPDIR}/actual" "${capture_root}/000001/raw.stdout"
    grep -qx 'synthetic capture diagnostic' "${capture_root}/000001/raw.stderr"
    jq -e --arg path "${capture_root}/000001/screen.png" '.path == $path and .width == 2 and .height == 2' "${BATS_TEST_TMPDIR}/actual"
    jq -e --arg digest "$(shasum -a 256 "${capture_root}/000001/screen.png" | cut -d ' ' -f 1)" \
        '.sha256 == $digest and .bytes > 0 and .width == 2 and .height == 2 and .format == "RGBA8 PNG"' "${capture_root}/000001/artifact.json"
    jq -e '.transport == "capture" and .class == "read-poll" and .payload_predicate != "true"' "${capture_root}/000001/request.json"
    jq -se --arg path "${capture_root}/000001/screen.png" '. == [["screen","capture","-o",$path,"--vm","exact-capture-vm","--json"]]' "${capture_calls}"
    [[ ! -e "${capture_root}/unavailable" ]]
}

@test "region and repeated operations use unique artifacts without extra reads" {
    capture_guest_evidence "${capture_root}" read-poll mark 1500,0,420,200 >/dev/null
    capture_guest_evidence "${capture_root}" read-poll mark >/dev/null
    [[ -s "${capture_root}/000001/screen.png" && -s "${capture_root}/000002/screen.png" ]]
    jq -e '.width == 420 and .height == 200' "${capture_root}/000001/artifact.json"
    jq -se 'length == 2 and .[0][2:4] == ["--region","1500,0,420,200"]' "${capture_calls}"
    jq -se 'map(.ordinal) == [1,2] and map(.operation) == ["mark","mark"]' "${capture_root}"/*/request.json
}

@test "missing empty malformed truncated corrupt and incomplete pixels latch without retry" {
    local mode
    for mode in missing empty signature crc truncated trailing zlib rows filter color directory symlink; do
        reset_capture "artifact-${mode}"
        export capture_mode="${mode}"
        run capture_guest_evidence "${capture_root}" read-poll broken
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${capture_calls}" | tr -d ' ')" == 1 ]]
        jq -e '.outcome == "unavailable" and .cli_status == 0 and .emission_status == "not-attempted"' "${capture_root}/000001/result.json"
        [[ ! -e "${capture_root}/000001/artifact.json" ]]
        assert_capture_latched
    done
}

@test "capture schema and image dimensions must match exact artifact and region" {
    local mode
    for mode in path dimensions width zero absent-field; do
        reset_capture "schema-${mode}"
        export capture_mode="${mode}"
        run capture_guest_evidence "${capture_root}" read-poll broken 1500,0,420,200
        [[ "${status}" == 125 ]]
        [[ "$(wc -l <"${capture_calls}" | tr -d ' ')" == 1 ]]
        assert_capture_latched
    done
}

@test "failed partial typed error and dry-run captures retain raw failure without output" {
    local mode
    for mode in nonzero partial error dry-run; do
        reset_capture "transport-${mode}"
        export capture_mode="${mode}" capture_exit=0
        if [[ "${mode}" == nonzero ]]; then capture_exit=7; fi
        run capture_guest_evidence "${capture_root}" read-poll broken
        [[ "${status}" == 125 ]]
        [[ -s "${capture_root}/000001/raw.stdout" && -s "${capture_root}/000001/raw.stderr" ]]
        jq -e '.outcome == "unavailable" and .emission_status == "not-attempted"' "${capture_root}/000001/result.json"
        assert_capture_latched
    done
}

@test "collection after failed image retains first latch and never restores eligibility" {
    capture_mode=missing
    run capture_guest_evidence "${capture_root}" read-poll first
    [[ "${status}" == 125 ]]
    cp "${capture_root}/unavailable" "${BATS_TEST_TMPDIR}/first-latch"
    capture_mode=clean
    capture_guest_evidence "${capture_root}" evidence failure-context >/dev/null
    cmp "${capture_root}/unavailable" "${BATS_TEST_TMPDIR}/first-latch"
    jq -e '.outcome == "clean"' "${capture_root}/000002/result.json"
    assert_capture_latched
}

@test "invalid roots do not dispatch or write cwd and invalid capture arguments latch" {
    local root arg
    for root in '' "${BATS_TEST_TMPDIR}/missing" "${BATS_TEST_TMPDIR}/cwd"; do
        run capture_guest_evidence "${root}" read-poll broken
        [[ "${status}" == 125 && ! -s "${capture_calls}" ]]
        [[ "$(find . -mindepth 1 -print | wc -l | tr -d ' ')" == 0 ]]
    done
    for arg in '1,2,0,3' '1,2,3' '-1,2,3,4' '1,2,3,4 --vm other'; do
        reset_capture "args-${RANDOM}"
        run capture_guest_evidence "${capture_root}" read-poll broken "${arg}"
        [[ "${status}" == 125 && ! -s "${capture_calls}" ]]
        [[ -s "${capture_root}/unavailable" ]]
    done
}

@test "PNG inspection still owns the shared lock after CLI completion" {
    local backend="${BATS_TEST_TMPDIR}/backend" child ready=0 competing
    mkdir "${backend}"
    cp "${BATS_TEST_DIRNAME}/../../scripts/"{vm-guest-exec.py,vm-guest-exec-lib.sh,vm_capture_artifact.py} "${backend}/"
    cat >>"${backend}/vm_capture_artifact.py" <<'PY'

# Test-only barrier at actual artifact inspection, after the CLI has exited.
import time
original_inspect = inspect_capture
def inspect_capture(path, width, height):
    ready = Path(os.environ['capture_ready'])
    ready.touch()
    while not ready.with_suffix('.release').exists():
        time.sleep(.02)
    return original_inspect(path, width, height)
PY
    python3 "${backend}/vm-guest-exec.py" capture "${capture_root}" read-poll decode >"${BATS_TEST_TMPDIR}/decode.out" 2>&1 &
    child=$!
    for _ in $(seq 1 200); do
        if [[ -f "${capture_ready}" ]]; then
            ready=1
            break
        fi
        sleep 0.02
    done
    if [[ "${ready}" != 1 ]]; then
        kill "${child}"
        wait "${child}" || :
        return 1
    fi
    run cli_guest_evidence "${capture_root}" one-shot later '.key == "return" and .modifiers == []' -- input key return
    competing="${status}"
    touch "${BATS_TEST_TMPDIR}/ready.release"
    wait "${child}"
    [[ "${competing}" == 125 && "$(wc -l <"${capture_calls}" | tr -d ' ')" == 1 ]]
    jq -e '.outcome == "clean"' "${capture_root}/000001/result.json"
    [[ -s "${capture_root}/unavailable" && -s "${capture_root}/000001/artifact.json" ]]
}

@test "capture shares ordinals in both directions and failed collection cannot overwrite" {
    cli_guest_evidence "${capture_root}" one-shot before '.key == "return" and .modifiers == []' -- input key return >/dev/null
    capture_guest_evidence "${capture_root}" read-poll context >/dev/null
    cp "${capture_root}/000002/screen.png" "${BATS_TEST_TMPDIR}/original.png"
    cli_guest_evidence "${capture_root}" one-shot after '.key == "return" and .modifiers == []' -- input key return >/dev/null
    capture_exit=255
    run capture_guest_evidence "${capture_root}" evidence failed-collection
    [[ "${status}" == 125 ]]
    cmp "${capture_root}/000002/screen.png" "${BATS_TEST_TMPDIR}/original.png"
    jq -se 'map(.ordinal) == [1,2,3,4] and map(.transport) == ["cli","capture","cli","capture"]' "${capture_root}"/*/request.json
    jq -e '.outcome == "unavailable" and .cli_status == 255' "${capture_root}/000004/result.json"
    assert_capture_latched
}

@test "caught capture SIGINT retains interruption partial streams and stops later input" {
    run python3 - "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec.py" "${capture_root}" <<'PY'
import json
import os
import signal
import subprocess
import sys
import time
from pathlib import Path

backend, root = sys.argv[1], Path(sys.argv[2])
process = subprocess.Popen([sys.executable, backend, 'capture', str(root), 'read-poll', 'interrupt'],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                           env=dict(os.environ, capture_block='1'), start_new_session=True)
try:
    for _ in range(250):
        if Path(os.environ['capture_ready']).exists(): break
        time.sleep(.02)
    assert Path(os.environ['capture_ready']).exists(), 'capture did not start'
    os.killpg(process.pid, signal.SIGINT)
    assert process.wait(timeout=5) == -signal.SIGINT
    result = json.loads((root / '000001/result.json').read_text())
    assert result['outcome'] == 'interrupted', result
    assert (root / '000001/raw.stderr').exists()
    assert not (root / '000001/artifact.json').exists()
finally:
    if process.poll() is None:
        os.killpg(process.pid, signal.SIGKILL)
        process.wait(timeout=5)
PY
    printf '%s\n' "${output}"
    [[ "${status}" == 0 ]]
    assert_capture_latched
}

@test "relative roots remain usable and invalid class operation options cannot dispatch" {
    init_guest_evidence relative-root exact-capture-vm
    capture_guest_evidence relative-root read-poll relative >/dev/null
    jq -e --arg path "$(pwd -P)/relative-root/000001/screen.png" '.path == $path' relative-root/000001/artifact.json
    local case_name
    for case_name in class empty-operation option extra-option; do
        reset_capture "bad-${case_name}"
        case "${case_name}" in
        class) run capture_guest_evidence "${capture_root}" one-shot bad ;;
        empty-operation) run capture_guest_evidence "${capture_root}" read-poll '' ;;
        option) run capture_guest_evidence "${capture_root}" read-poll bad --vm=other ;;
        extra-option) run capture_guest_evidence "${capture_root}" read-poll bad 1,2,3,4 --physical ;;
        esac
        [[ "${status}" != 0 && ! -s "${capture_calls}" && -s "${capture_root}/unavailable" ]]
    done
}

@test "keepalive preserves twenty-second ticks unique paths and exact local interruption" {
    # shellcheck disable=SC2329
    sleep() {
        echo "$*" >>"${capture_waits}"
        [[ "$(wc -l <"${capture_waits}" | tr -d ' ')" -le 2 ]] || return 143
    }
    run keepalive_guest_evidence "${capture_root}"
    [[ "${status}" == 143 ]]
    [[ "$(cat "${capture_waits}")" == $'20\n20\n20' ]]
    [[ "$(wc -l <"${capture_calls}" | tr -d ' ')" == 2 ]]
    jq -se 'map(.operation) == ["keepalive-1","keepalive-2","keepalive-sleep-3"]' "${capture_root}"/*/request.json
    jq -e '.poll_phase == "sleep" and .local_status == 143' "${capture_root}/000003/request.json"
    jq -e '.outcome == "interrupted"' "${capture_root}/000003/result.json"
    [[ -s "${capture_root}/000001/screen.png" && -s "${capture_root}/000002/screen.png" ]]
}

@test "keepalive failure stops before another sleep or capture and latches later input" {
    export capture_mode=missing
    # shellcheck disable=SC2329
    sleep() {
        echo "$*" >>"${capture_waits}"
        [[ "$(wc -l <"${capture_waits}" | tr -d ' ')" -le 1 ]] || return 143
    }
    run keepalive_guest_evidence "${capture_root}"
    [[ "${status}" == 125 ]]
    [[ "$(cat "${capture_waits}")" == 20 && "$(wc -l <"${capture_calls}" | tr -d ' ')" == 1 ]]
    assert_capture_latched
}

@test "capture holds shared lock through CLI and refuses competing scenario dispatch" {
    export capture_block=1
    capture_guest_evidence "${capture_root}" read-poll background >"${BATS_TEST_TMPDIR}/background.out" 2>&1 &
    local child=$! ready=0
    for _ in $(seq 1 200); do
        if [[ -f "${capture_ready}" ]]; then
            ready=1
            break
        fi
        sleep 0.02
    done
    if [[ "${ready}" != 1 ]]; then
        kill "${child}"
        wait "${child}" || :
        return 1
    fi
    run cli_guest_evidence "${capture_root}" one-shot later '.key == "return" and .modifiers == []' -- input key return
    local competing="${status}"
    touch "${BATS_TEST_TMPDIR}/ready.release"
    wait "${child}"
    [[ "${competing}" == 125 && "$(wc -l <"${capture_calls}" | tr -d ' ')" == 1 ]]
    [[ -s "${capture_root}/unavailable" && -s "${capture_root}/000001/artifact.json" ]]
    assert_capture_latched
}
