#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Every test owns its environment.
# The start path of a VM verification script, with stubbed testanyware and guest
# commands. The stub records each screen capture. The first file upload stops the
# script, after one capture or after a bounded wait. No VM starts.

setup() {
    bats_require_minimum_version 1.5.0
    local root="${BATS_TEST_DIRNAME}/../.."
    export start_repo="${BATS_TEST_TMPDIR}/repo"
    export start_captures="${BATS_TEST_TMPDIR}/captures"
    mkdir -p "${start_repo}/App" "${start_repo}/bundle/Koine.app" "${BATS_TEST_TMPDIR}/bin"
    cp -R "${root}/scripts" "${start_repo}/scripts"
    cp "${root}/App/Info.plist" "${start_repo}/App/Info.plist"
    : >"${start_captures}"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
case "$1 ${2-}" in
"screen capture")
    printf '%s\n' "$*" >>"${start_captures}"
    ;;
"file upload")
    # A capture loop takes its first capture within 0.1 s under the sleep stub.
    for _ in $(seq 1 40); do
        [[ -s "${start_captures}" ]] && break
        /bin/sleep 0.05
    done
    exit 1
    ;;
"file exec")
    echo stub-guest
    ;;
esac
exit 0
CLI
    # The capture loop sleeps 20 s. The stub keeps its cadence observable.
    cat >"${BATS_TEST_TMPDIR}/bin/sleep" <<'SLEEP'
#!/bin/bash
exec /bin/sleep 0.05
SLEEP
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware" "${BATS_TEST_TMPDIR}/bin/sleep"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    export KOINE_APP_BUNDLE="${start_repo}/bundle/Koine.app"
    unset KOINE_VM_BASE KOINE_VM_DISPLAY KOINE_VM_KEEP KOINE_VM_ID KOINE_SETTINGS_TRACE TESTANYWARE_VM_ID VNC_KEEPALIVE_PID
}

# Runs one script to its first upload, and then waits so that a surviving loop shows.
run_start_path() {
    run -1 "${start_repo}/scripts/$1"
    /bin/sleep 0.3
    start_count="$(wc -l <"${start_captures}" | tr -d ' ')"
    /bin/sleep 0.3
    [[ "$(wc -l <"${start_captures}" | tr -d ' ')" == "${start_count}" ]]
}

@test "the Settings scenario start path starts no background screen capture" {
    run_start_path vm-verify-menu-bar.sh
    [[ "${output}" == *'== Start a clean VM'* && "${output}" == *stub-guest* ]]
    [[ ! -s "${start_captures}" ]] || {
        cat "${start_captures}"
        return 1
    }
}

@test "an inherited VNC_KEEPALIVE_PID neither starts a capture nor stops a process in the Settings scenario" {
    /bin/sleep 30 &
    local bystander=$!
    export VNC_KEEPALIVE_PID="${bystander}"
    run_start_path vm-verify-menu-bar.sh
    local alive=0
    kill -0 "${bystander}" 2>/dev/null && alive=1
    kill "${bystander}" 2>/dev/null || :
    wait "${bystander}" 2>/dev/null || :
    [[ "${alive}" == 1 && ! -s "${start_captures}" ]]
}

# The instrument detects a loop: another caller keeps it, and cleanup stops it.
@test "another start_vm caller still starts the background capture loop" {
    run_start_path vm-verify.sh
    [[ "${output}" == *'== Start a clean VM'* ]]
    [[ "${start_count}" -ge 1 ]]
    grep -q -- '-o .*/keepalive\.png$' "${start_captures}"
}
