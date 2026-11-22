#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2016 # Every test owns its environment; guest-side $HOME.

setup() {
    bats_require_minimum_version 1.5.0
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    if [[ "${KOINE_ONE_SHOT_BASELINE:-0}" == 1 ]]; then
        legacy_semantics
    else
        # shellcheck source=scripts/vm-exec-one-shot-evidence-lib.sh
        source "${BATS_TEST_DIRNAME}/../../scripts/vm-exec-one-shot-evidence-lib.sh"
    fi
    export read_root="${BATS_TEST_TMPDIR}/evidence"
    export read_calls="${BATS_TEST_TMPDIR}/calls"
    export read_stdout="${BATS_TEST_TMPDIR}/stdout"
    export read_fixture="${BATS_TEST_DIRNAME}/fixtures/exec-read-cli.py"
    mkdir "${BATS_TEST_TMPDIR}/bin"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
exec python3 "${read_fixture}" "$@"
CLI
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    : >"${read_calls}"
    answer ''
    init_guest_evidence "${read_root}" exact-one-shot-vm
}

# Legacy semantics of the one-shot callers in scripts/vm-verify-lib.sh,
# scripts/vm-verify-desktop-lib.sh and scripts/vm-verify-menu-bar.sh. These
# test-only wrappers adapt the new signatures. A legacy `fail` returns 125.
legacy_semantics() {
    DATA='$HOME/Library/Application Support/Koine'
    # shellcheck disable=SC2329
    guest() {
        local out status
        for _ in 1 2 3 4 5 6 7 8 9 10 11 12; do
            status=0
            out="$(testanyware file exec "$1" 2>&1)" || status=$?
            if [ "${status}" = 255 ] && grep -q 'Process timed out after 30s' <<<"${out}"; then
                continue
            fi
            if [ "${status}" = 7 ]; then
                sleep 5
                continue
            fi
            [ -z "${out}" ] || echo "${out}"
            return "${status}"
        done
        return 255
    }
    # shellcheck disable=SC2329
    guest_once() { testanyware file exec "$1" >/dev/null 2>&1 || true; }
    # shellcheck disable=SC2329
    submit_guest_once() {
        case "$3" in
        open-koine) guest_once "open /Applications/Koine.app" ;;
        extract-bundle) guest "ditto -x -k /tmp/Koine.zip /Applications" ;;
        open-textedit) guest "open -a TextEdit" || true ;;
        quit-textedit) guest "osascript -e 'tell application \"TextEdit\" to quit saving no'" || true ;;
        request-automation) guest "nohup osascript -e 'tell application \"System Events\" to get name of every process' >/dev/null 2>&1 &" || true ;;
        open-accessibility-pane) guest 'open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"' || true ;;
        restart) testanyware file exec 'echo admin | sudo -S shutdown -r now' >/dev/null 2>&1 || true ;;
        *) return 125 ;;
        esac
    }
    # shellcheck disable=SC2329
    submit_guest_extraction() { submit_guest_once "$1" "$2" extract-bundle; }
    # shellcheck disable=SC2329
    launch_guest_textedit() { submit_guest_once "$1" "$2" open-textedit; }
    # shellcheck disable=SC2329
    request_guest_automation() { submit_guest_once "$1" "$2" request-automation; }
    # shellcheck disable=SC2329
    open_guest_accessibility_pane() { submit_guest_once "$1" "$2" open-accessibility-pane; }
    # shellcheck disable=SC2329
    launch_guest_koine() { submit_guest_once "$1" "$2" open-koine; }
    # The legacy launch proof is a present descriptor (await_koine).
    # shellcheck disable=SC2329
    confirm_guest_launch() { guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1 || return 125; }
    # The legacy reopen has no process check.
    # shellcheck disable=SC2329
    confirm_guest_reopen() { :; }
    # shellcheck disable=SC2329
    quit_guest_textedit() { submit_guest_once "$1" "$2" quit-textedit; }
    # shellcheck disable=SC2329
    restart_guest() {
        local before after=""
        before="$(jq -r '"{ sec = \(.sec), usec = \(.usec) } \(.text)"' <<<"$3")"
        submit_guest_once "$1" "$2" restart
        sleep 30
        for _ in $(seq 1 60); do
            after="$(guest 'sysctl -n kern.boottime' 2>/dev/null || true)"
            if [ -n "${after}" ] && [ "${after}" != "${before}" ]; then break; fi
            sleep 5
        done
        [ -n "${after}" ] && [ "${after}" != "${before}" ] || return 125
    }
    # shellcheck disable=SC2329
    refuse_guest_trace_defaults() {
        guest 'defaults write dev.antony.Koine KoineSettingsActivationTrace -string /Users/admin/settings-activation.jsonl'
    }
}

# answer TEXT [EXIT [TIMED_OUT [CLI]]]: the next guest answer of the fixture.
answer() {
    printf '%s' "$1" >"${read_stdout}"
    export read_exit_code="${2:-0}" read_timed_out="${3:-false}" read_cli_status="${4:-0}"
}

# script ROW...: one guest answer per call, as `EXIT TIMED_OUT CLI TEXT`.
script() {
    local row rest code timed cli index=0
    export read_script="${BATS_TEST_TMPDIR}/script"
    : >"${read_script}"
    rm -f "${read_script}.used"
    for row in "$@"; do
        index=$((index + 1))
        code="${row%% *}" rest="${row#* }"
        timed="${rest%% *}" rest="${rest#* }"
        cli="${rest%% *}" rest="${rest#* }"
        printf '%s' "${rest}" >"${BATS_TEST_TMPDIR}/answer-${index}"
        printf '%s %s %s %s\n' "${code}" "${timed}" "${cli}" "${BATS_TEST_TMPDIR}/answer-${index}" >>"${read_script}"
    done
}

reset_root() {
    read_root="${BATS_TEST_TMPDIR}/$1"
    init_guest_evidence "${read_root}" exact-one-shot-vm
    : >"${read_calls}"
    unset read_script
    rm -f "${BATS_TEST_TMPDIR}/sleeps"
}

calls() { wc -l <"${read_calls}" | tr -d ' '; }
sleeps() { [[ -e "${BATS_TEST_TMPDIR}/sleeps" ]] && tr '\n' ' ' <"${BATS_TEST_TMPDIR}/sleeps" || :; }
# sent N: the guest command of the Nth call.
sent() { sed -n "$1p" "${read_calls}" | jq -r '.[-1]'; }

# The root is latched, and a later scenario submission refuses without dispatch.
assert_latched() {
    local count
    count="$(calls)"
    [[ -s "${read_root}/unavailable" ]]
    run submit_guest_once "${read_root}" later open-koine
    [[ "${status}" == 125 && "$(calls)" == "${count}" ]]
}

# refused CLASS OPERATION NAME [ARGUMENT...]: the backend read refuses before
# dispatch and latches a fresh root.
refused() {
    reset_root "refused-$((++refusals))"
    run _guest_evidence_backend read "${read_root}" "$@"
    echo "diagnostic: request=$* status=${status} calls=$(calls)"
    [[ "${status}" != 0 && "$(calls)" == 0 && -s "${read_root}/unavailable" && ! -e "${read_root}/000001" ]]
}

DESCRIPTOR='{"contractVersion": "koine-desktop/1", "descriptorVersion": 1, "instanceId": "inst-1", "path": "/graphql", "pid": 501, "port": 49152}'
KOINE=/Applications/Koine.app/Contents/MacOS/Koine
# identity SELECTED PROCESS [DESCRIPTOR]: a launch identity answer.
identity() {
    jq -cn --arg text "${3:-${DESCRIPTOR}}" --argjson process "$2" \
        '{descriptor_text: $text, process: $process}' |
        sed "1s/^/KOINE-SELECTED $1\n/"
}
# process PID SEC USEC EXECUTABLE: the kernel record of one process.
process() {
    jq -cn --argjson pid "$1" --argjson sec "$2" --argjson usec "$3" --arg executable "$4" \
        '{executable: $executable, pid: $pid, start_sec: $sec, start_usec: $usec}'
}
BOOT_BEFORE='{ sec = 1795270000, usec = 120001 } Sun Nov 22 00:06:40 2026'
BOOT_AFTER='{ sec = 1795271000, usec = 450002 } Sun Nov 22 00:23:20 2026'
BEFORE_RECORD='{"read": "boot", "arguments": [], "sec": 1795270000, "usec": 120001, "text": "Sun Nov 22 00:06:40 2026"}'
SHUTDOWN_OUT=$'Shutdown NOW!\n\r\nSystem shutdown time has arrived\a\a'

declare -gA LEGACY=(
    ["extract-bundle"]='ditto -x -k /tmp/Koine.zip /Applications'
    ["open-koine"]='open /Applications/Koine.app'
    ["open-textedit"]='open -a TextEdit'
    ["quit-textedit"]="osascript -e 'tell application \"TextEdit\" to quit saving no'"
    ["request-automation"]="nohup osascript -e 'tell application \"System Events\" to get name of every process' >/dev/null 2>&1 &"
    ["open-accessibility-pane"]='open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"'
    ["restart"]='echo admin | sudo -S shutdown -r now'
)

@test "submissions admit only the one-shot class and take no arguments" {
    local name
    refusals=0
    for name in "${!LEGACY[@]}"; do
        refused read-poll submit "${name}"
        grep -q 'needs the one-shot class' "${read_root}/refusals.jsonl"
        refused evidence submit "${name}"
        refused one-shot submit "${name}" extra
    done
    refused one-shot read launch-identity
    grep -q 'read-poll or evidence class' "${read_root}/refusals.jsonl"
    refused evidence read launch-identity
    grep -q 'Command Line Tools' "${read_root}/refusals.jsonl"
    # Seven submissions, three refusals each, and the two identity refusals.
    [[ "${refusals}" == 23 ]]
}

@test "each submission sends its legacy command once and keeps a clean receipt" {
    local name index=0
    for name in "${!LEGACY[@]}"; do
        index=$((index + 1))
        reset_root "submit-${index}"
        if [[ "${name}" == restart ]]; then answer "${SHUTDOWN_OUT}"; else answer ''; fi
        run submit_guest_once "${read_root}" "submit-${name}" "${name}"
        echo "diagnostic: name=${name} status=${status} calls=$(calls) output=${output}"
        [[ "${status}" == 0 && "$(calls)" == 1 && "$(sent 1)" == "${LEGACY[${name}]}" ]]
        jq -e --arg name "${name}" '.class == "one-shot" and .read == $name' "${read_root}/000001/request.json"
        jq -e '.outcome == "clean"' "${read_root}/000001/result.json"
        jq -e '.submitted == true' "${read_root}/000001/read.json"
        [[ ! -e "${read_root}/unavailable" ]]
    done
    [[ "${index}" == 7 ]]
}

@test "a timeout, a guest failure or a transport failure of a submission is unavailable and sent once" {
    local failure name index=0
    for name in open-koine extract-bundle open-textedit request-automation open-accessibility-pane restart; do
        for failure in '1 false 0' '-1 true 0' '0 false 7' '0 false 255'; do
            index=$((index + 1))
            reset_root "failed-${index}"
            read -r code timed cli <<<"${failure}"
            if [[ "${name}" == restart ]]; then
                answer "${SHUTDOWN_OUT}" "${code}" "${timed}" "${cli}"
            else
                answer '' "${code}" "${timed}" "${cli}"
            fi
            run submit_guest_once "${read_root}" "submit-${name}" "${name}"
            echo "diagnostic: name=${name} failure=${failure} status=${status} calls=$(calls)"
            [[ "${status}" == 125 && "$(calls)" == 1 && ! -e "${read_root}/000001/read.json" ]]
            assert_latched
        done
    done
}

@test "other stdout from a submission is unavailable" {
    local index=0 row name text
    for row in 'open-koine|LSOpenURLsWithRole() failed' 'quit-textedit|missing value' \
        'restart|Shutdown NOW!' $'restart|Shutdown NOW!\nSystem shutdown time has arrived'; do
        index=$((index + 1))
        reset_root "stdout-${index}"
        name="${row%%|*}" text="${row#*|}"
        answer "${text}"
        run submit_guest_once "${read_root}" "submit-${name}" "${name}"
        echo "diagnostic: row=${row} status=${status} calls=$(calls)"
        [[ "${status}" == 125 && "$(calls)" == 1 ]]
        grep -q "submission ${name} printed other stdout" "${read_root}/unavailable"
        assert_latched
    done
}

@test "the launch confirmation joins the descriptor, the only selected process, its executable and its start" {
    answer "$(identity 501 "$(process 501 1795270100 250000 "${KOINE}")")"
    run confirm_guest_launch "${read_root}" first-launch-identity
    echo "diagnostic: status=${status} calls=$(calls) output=${output}"
    [[ "${status}" == 0 && "$(calls)" == 1 ]]
    jq -e '.joined and .process.start_usec == 250000 and .descriptor.instanceId == "inst-1"' <<<"${output}"
    jq -e '.operation == "first-launch-identity" and .read == "launch-identity" and .class == "read-poll"' \
        "${read_root}/000001/request.json"
    jq -e '.transport == "poll-step" and .local_status == 0' "${read_root}/000002/request.json"
}

@test "a stale descriptor, a second process or another executable is a clean mismatch" {
    local index=0 answer_text
    for answer_text in \
        "$(identity 501 null)" \
        "$(identity 501,777 "$(process 501 1795270100 250000 "${KOINE}")")" \
        "$(identity 777 "$(process 501 1795270100 250000 "${KOINE}")")" \
        "$(identity '' "$(process 501 1795270100 250000 "${KOINE}")")" \
        "$(identity 501 "$(process 501 1795270100 250000 /tmp/Koine.app/Contents/MacOS/Koine)")" \
        'ABSENT'; do
        index=$((index + 1))
        reset_root "mismatch-${index}"
        answer "${answer_text}"
        run confirm_guest_launch "${read_root}" launch-identity
        echo "diagnostic: index=${index} status=${status} calls=$(calls) output=${output}"
        [[ "${status}" == 1 && "$(calls)" == 1 && ! -e "${read_root}/unavailable" ]]
        jq -e '.outcome == "clean"' "${read_root}/000001/result.json" "${read_root}/000002/result.json"
    done
}

@test "a malformed identity answer is unavailable" {
    local index=0 answer_text
    for answer_text in \
        "$(identity 501 "$(process 777 1795270100 250000 "${KOINE}")")" \
        "$(identity 501 "$(process 501 1795270100 1000000 "${KOINE}")")" \
        "$(identity 501,501 "$(process 501 1795270100 250000 "${KOINE}")")" \
        "$(identity 501 "$(process 501 1795270100 250000 "${KOINE}")" '{"pid": 501}')" \
        "$(identity 501 '{"pid": 501}')" \
        'KOINE-SELECTED 501' \
        "PRESENT"; do
        index=$((index + 1))
        reset_root "malformed-${index}"
        answer "${answer_text}"
        run confirm_guest_launch "${read_root}" launch-identity
        echo "diagnostic: index=${index} status=${status} calls=$(calls)"
        [[ "${status}" == 125 && "$(calls)" == 1 ]]
        grep -q 'checked read launch-identity grammar' "${read_root}/unavailable"
    done
}

@test "a reopen keeps the same process: instance, PID, start and executable" {
    local first index=0 answer_text
    first="$(identity 501 "$(process 501 1795270100 250000 "${KOINE}")")"
    answer "${first}"
    first="$(confirm_guest_launch "${read_root}" silent-identity)"
    run confirm_guest_reopen "${read_root}" reopen-identity "${first}"
    echo "diagnostic: status=${status} calls=$(calls) output=${output}"
    [[ "${status}" == 0 && "$(calls)" == 2 ]]
    for answer_text in \
        "$(identity 502 "$(process 502 1795270100 250000 "${KOINE}")" "${DESCRIPTOR/501/502}")" \
        "$(identity 501 "$(process 501 1795270100 250001 "${KOINE}")")" \
        "$(identity 501 "$(process 501 1795270100 250000 "${KOINE}")" "${DESCRIPTOR/inst-1/inst-2}")"; do
        index=$((index + 1))
        reset_root "reopen-${index}"
        answer "${answer_text}"
        run confirm_guest_reopen "${read_root}" reopen-identity "${first}"
        echo "diagnostic: index=${index} status=${status} calls=$(calls) output=${output}"
        [[ "${status}" == 1 && "$(calls)" == 1 && ! -e "${read_root}/unavailable" ]]
    done
}

@test "the TextEdit quit needs a clean submission and then one clean absence read" {
    script '0 false 0 ' '0 false 0 NONE'
    run quit_guest_textedit "${read_root}" textedit-quit
    echo "diagnostic: status=${status} calls=$(calls) output=${output}"
    [[ "${status}" == 0 && "$(calls)" == 2 ]]
    [[ "$(sent 2)" == *"pgrep -f '/System/Applications/TextEdit.app/Contents/MacOS'"* ]]
    jq -e '.operation == "textedit-quit-absence" and .read == "process"' "${read_root}/000002/request.json"
    reset_root presence
    script '0 false 0 ' $'0 false 0 KOINE-SELECTED 612\n612 Sun Nov 22 00:10:00 2026 /System/Applications/TextEdit.app/Contents/MacOS/TextEdit\n---\n612 Sun Nov 22 00:10:00 2026 /System/Applications/TextEdit.app/Contents/MacOS/TextEdit'
    run quit_guest_textedit "${read_root}" textedit-quit
    echo "diagnostic: status=${status} calls=$(calls) output=${output}"
    [[ "${status}" == 1 && "$(calls)" == 2 && ! -e "${read_root}/unavailable" ]]
}

@test "a failed TextEdit quit reads nothing, and an absence cannot make it clean" {
    local failure index=0
    for failure in '1 false 0' '-1 true 0' '0 false 7'; do
        index=$((index + 1))
        reset_root "quit-${index}"
        script "${failure} " '0 false 0 NONE'
        run quit_guest_textedit "${read_root}" textedit-quit
        echo "diagnostic: failure=${failure} status=${status} calls=$(calls)"
        [[ "${status}" == 125 && "$(calls)" == 1 ]]
        assert_latched
    done
}

@test "the restart waits 30 seconds and polls the boot five seconds apart until it changes" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script "0 false 0 ${SHUTDOWN_OUT}" "0 false 0 ${BOOT_BEFORE}" "0 false 0 ${BOOT_BEFORE}" "0 false 0 ${BOOT_AFTER}"
    run restart_guest "${read_root}" restart "${BEFORE_RECORD}"
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
    [[ "${status}" == 0 && "$(calls)" == 4 && "$(sleeps)" == "30 5 5 " ]]
    [[ "$(sent 1)" == 'echo admin | sudo -S shutdown -r now' && "$(sent 2)" == 'sysctl -n kern.boottime' ]]
    jq -e '.sec == 1795271000 and .usec == 450002' <<<"${output}"
    [[ ! -e "${read_root}/unavailable" ]]
}

@test "a failed restart submission is unavailable even if the boot later changes" {
    local failure index=0
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    for failure in '-1 true 0' '0 false 7' '0 false 255' '1 false 0'; do
        index=$((index + 1))
        reset_root "restart-${index}"
        script "${failure} ${SHUTDOWN_OUT}" "0 false 0 ${BOOT_AFTER}"
        run restart_guest "${read_root}" restart "${BEFORE_RECORD}"
        echo "diagnostic: failure=${failure} status=${status} calls=$(calls) sleeps=$(sleeps)"
        [[ "${status}" == 125 && "$(calls)" == 1 && -z "$(sleeps)" ]]
        assert_latched
    done
}

@test "a refused connection during the boot poll stops it at once, even before a changed boot" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script "0 false 0 ${SHUTDOWN_OUT}" "0 false 0 ${BOOT_BEFORE}" "0 false 7 ${BOOT_BEFORE}" "0 false 0 ${BOOT_AFTER}"
    run restart_guest "${read_root}" restart "${BEFORE_RECORD}"
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps)"
    [[ "${status}" == 125 && "$(calls)" == 3 && "$(sleeps)" == "30 5 " ]]
    assert_latched
}

@test "an unchanged boot for sixty reads is a state failure" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script "0 false 0 ${SHUTDOWN_OUT}" "0 false 0 ${BOOT_BEFORE}"
    run restart_guest "${read_root}" restart "${BEFORE_RECORD}"
    echo "diagnostic: status=${status} calls=$(calls)"
    [[ "${status}" == 125 && "$(calls)" == 61 && "$(sleeps)" == "30 $(printf '5 %.0s' {1..60})" ]]
    grep -rl '"operation": "restart-boot-exhausted"' "${read_root}"/*/request.json
    assert_latched
}

@test "the restart refuses a boot argument that is not a boot record, before it sends anything" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    run restart_guest "${read_root}" restart "${BOOT_BEFORE}"
    echo "diagnostic: status=${status} calls=$(calls)"
    [[ "${status}" == 125 && "$(calls)" == 0 && -s "${read_root}/unavailable" ]]
}

@test "the diagnostic defaults write is refused and latches without dispatch" {
    run refuse_guest_trace_defaults "${read_root}" trace-defaults
    echo "diagnostic: status=${status} calls=$(calls)"
    [[ "${status}" == 125 && "$(calls)" == 0 ]]
    grep -q 'permits no enabling diagnostic defaults write' "${read_root}/unavailable"
    assert_latched
}

# --- the liveness read of a zero-window return (k67) -----------------------

# pid_identity PID PROCESS: an answer of the PID identity read.
pid_identity() {
    jq -cn --arg text "{\"pid\": $1}" --argjson process "$2" '{descriptor_text: $text, process: $process}'
}

@test "the PID identity read pipes the PID to the launch identity script and parses its answer" {
    answer "$(pid_identity 501 "$(process 501 1795270100 250000 "${KOINE}")")"
    run check_guest_read "${read_root}" read-poll liveness \
        ".process == $(process 501 1795270100 250000 "${KOINE}")" process-identity 501
    echo "diagnostic: status=${status} output=${output}"
    [[ "${status}" == 0 ]]
    jq -e '.pid == 501 and .process.start_usec == 250000' <<<"${output}"
    jq -e '.command | startswith("printf '\''{\"pid\": 501}'\'' | python3 -I -c '\''import ctypes")
        and endswith("'\'' /dev/stdin")' "${read_root}/000001/request.json"
    # No process, or another start under the same PID, is a clean mismatch.
    local index=0 answer_text
    for answer_text in "$(pid_identity 501 null)" \
        "$(pid_identity 501 "$(process 501 1795270100 250001 "${KOINE}")")"; do
        index=$((index + 1))
        reset_root "liveness-${index}"
        answer "${answer_text}"
        run check_guest_read "${read_root}" read-poll liveness \
            ".process == $(process 501 1795270100 250000 "${KOINE}")" process-identity 501
        [[ "${status}" == 1 && ! -e "${read_root}/unavailable" ]]
    done
}

@test "a malformed PID identity answer or argument is unavailable and the evidence class refuses it" {
    local index=0 answer_text
    for answer_text in \
        "$(pid_identity 777 "$(process 777 1795270100 250000 "${KOINE}")")" \
        "$(pid_identity 501 "$(process 777 1795270100 250000 "${KOINE}")")" \
        "$(pid_identity 501 "$(process 501 1795270100 1000000 "${KOINE}")")" \
        "$(pid_identity 501 null)"$'\n'"$(pid_identity 501 null)" \
        '{"descriptor_text": "{\"pid\": 501}"}'; do
        index=$((index + 1))
        reset_root "pid-malformed-${index}"
        answer "${answer_text}"
        run read_guest_exec "${read_root}" read-poll liveness process-identity 501
        echo "diagnostic: index=${index} status=${status}"
        [[ "${status}" == 125 && "$(calls)" == 1 ]]
        grep -q 'checked read process-identity grammar' "${read_root}/unavailable"
    done
    for answer_text in 0 012 1234567890 x; do
        reset_root "pid-argument-${answer_text}"
        run read_guest_exec "${read_root}" read-poll liveness process-identity "${answer_text}"
        [[ "${status}" != 0 && "$(calls)" == 0 && -s "${read_root}/unavailable" ]]
    done
    reset_root pid-evidence
    run read_guest_exec "${read_root}" evidence liveness process-identity 501
    [[ "${status}" != 0 && "$(calls)" == 0 ]]
    grep -q 'evidence class refuses read process-identity' "${read_root}/refusals.jsonl"
}
