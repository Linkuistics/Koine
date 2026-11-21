#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2016 # Every test owns its environment; guest-side $HOME.

setup() {
    bats_require_minimum_version 1.5.0
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    if [[ "${KOINE_EXEC_READ_BASELINE:-0}" == 1 ]]; then
        legacy_semantics
    else
        # shellcheck source=scripts/vm-exec-read-evidence-lib.sh
        source "${BATS_TEST_DIRNAME}/../../scripts/vm-exec-read-evidence-lib.sh"
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
    init_guest_evidence "${read_root}" exact-read-vm
}

# Legacy scenario semantics from scripts/vm-verify-lib.sh and the scenario.
# These test-only wrappers adapt the new signatures, not the production API.
legacy_semantics() {
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
    guest_text() {
        local out
        out="$(guest "$1" 2>&1)" || true
        grep -v -e '^Process timed out after' -e '^guest exec kept timing out' -e '^\[Process timed out' <<<"${out}" || true
    }
    # shellcheck disable=SC2329
    read_guest_exec() {
        case "$4" in
        endpoint)
            if guest '[ -e "$HOME/Library/Application Support/Koine/endpoint.json" ]' >/dev/null 2>&1; then
                echo '{"present":true}'
            else
                echo '{"present":false}'
            fi
            ;;
        process)
            if guest '! pgrep -f /Applications/Koine.app/Contents/MacOS' >/dev/null; then
                echo '{"processes":[]}'
            else
                echo '{"processes":[{}]}'
            fi
            ;;
        boot) guest 'sysctl -n kern.boottime' 2>/dev/null || true ;;
        port-refusal) guest "curl -s -m 3 -o /dev/null http://127.0.0.1:$5/graphql; echo \$?" || true ;;
        installed-inventory) guest_text "set -euo pipefail; cd '/Applications/Koine.app'; echo KOINE_INVENTORY_COMPLETE" ;;
        system) guest 'sw_vers; uname -m' ;;
        gatekeeper) guest 'spctl --status' 2>&1 || true ;;
        quarantine) guest 'xattr -p com.apple.quarantine /Applications/Koine.app 2>&1 || true' ;;
        signature) guest 'codesign --verify --strict --deep --verbose=2 /Applications/Koine.app 2>&1' ;;
        signature-display) guest 'codesign --display --verbose=2 /Applications/Koine.app 2>&1' ;;
        assessment) guest 'spctl -a -vv /Applications/Koine.app 2>&1' || echo '(not accepted; recorded)' ;;
        defaults) : ;; # The legacy scenario reads no defaults.
        esac
    }
    # shellcheck disable=SC2329
    await_guest_endpoint() {
        local limit=15 delay=2
        [[ "$3" != login ]] || limit=24 delay=5
        for _ in $(seq 1 "${limit}"); do
            if guest '[ -e "$HOME/Library/Application Support/Koine/endpoint.json" ]' >/dev/null 2>&1; then return 0; fi
            sleep "${delay}"
        done
        [[ "$3" == login ]]
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
    init_guest_evidence "${read_root}" exact-read-vm
    : >"${read_calls}"
    unset read_script
}

calls() { wc -l <"${read_calls}" | tr -d ' '; }

# The root is latched, and a later scenario read refuses without dispatch.
assert_latched() {
    local count
    count="$(calls)"
    [[ -s "${read_root}/unavailable" ]]
    run read_guest_exec "${read_root}" read-poll later boot
    [[ "${status}" == 125 && "$(calls)" == "${count}" ]]
}

# The record that a clean read printed is its read.json, byte for byte.
assert_record() {
    local ordinal="$1"
    [[ "${status}" == 0 ]]
    jq -ce . "${read_root}/${ordinal}/read.json" >"${BATS_TEST_TMPDIR}/expected"
    printf '%s\n' "${output}" | jq -ce . >"${BATS_TEST_TMPDIR}/actual"
    cmp "${BATS_TEST_TMPDIR}/expected" "${BATS_TEST_TMPDIR}/actual"
    jq -e '.outcome == "clean" and .emission_status == "flushed"' "${read_root}/${ordinal}/result.json"
}

DESCRIPTOR='{"contractVersion":"1","descriptorVersion":1,"instanceId":"A1","path":"/graphql","pid":412,"port":49152}'

@test "generic evidence exec refuses without dispatch while read-poll and one-shot still dispatch" {
    answer 'READY'
    run exec_guest_evidence "${read_root}" evidence collection 'echo READY' '.stdout == "READY"'
    [[ "${status}" == 125 && "$(calls)" == 0 && ! -e "${read_root}/000001" ]]
    jq -se 'length == 1 and (.[0].reason | contains("checked read-only read"))' "${read_root}/refusals.jsonl"
    assert_latched
    reset_root generic-poll
    exec_guest_evidence "${read_root}" read-poll state 'echo READY' '.stdout == "READY"' >/dev/null
    exec_guest_evidence "${read_root}" one-shot action 'echo READY' '.stdout == "READY"' >/dev/null
    [[ "$(calls)" == 2 && ! -e "${read_root}/unavailable" ]]
}

@test "evidence class admits only read-only reads and never clears a latch" {
    local name
    for name in assessment port-refusal; do
        reset_root "refuse-${name}"
        set -- "${name}"
        [[ "${name}" != port-refusal ]] || set -- "${name}" 49152
        run read_guest_exec "${read_root}" evidence collect "$@"
        [[ "${status}" == 125 && "$(calls)" == 0 && ! -e "${read_root}/000001" ]]
        grep -q 'evidence class refuses read' "${read_root}/refusals.jsonl"
    done
    reset_root latched
    fail_guest_evidence "${read_root}" setup 'original failure' || :
    cp "${read_root}/unavailable" "${BATS_TEST_TMPDIR}/first"
    answer '{ sec = 1795248869, usec = 738891 } Sat Nov 21 19:14:29 2026'
    run read_guest_exec "${read_root}" evidence boot-after boot
    assert_record 000002
    answer 'ABSENT'
    run read_guest_exec "${read_root}" evidence endpoint-after endpoint
    assert_record 000003
    cmp "${BATS_TEST_TMPDIR}/first" "${read_root}/unavailable"
    run read_guest_exec "${read_root}" read-poll later boot
    [[ "${status}" == 125 && "$(calls)" == 2 ]]
}

@test "unknown reads, invalid arguments and the one-shot class refuse before dispatch" {
    local -a request
    local index=0
    for request in 'read-poll x nosuch' 'one-shot x boot' 'read-poll x process other' \
        'read-poll x port-refusal 0' 'read-poll x port-refusal 65536' 'read-poll x port-refusal 080' \
        'read-poll x boot extra' 'read-poll x endpoint now'; do
        index=$((index + 1))
        reset_root "invalid-${index}"
        read -r -a words <<<"${request}"
        run read_guest_exec "${read_root}" "${words[@]}"
        [[ "${status}" != 0 && "$(calls)" == 0 && -s "${read_root}/unavailable" ]]
    done
}

@test "endpoint absence is clean data and a present descriptor needs the exact schema" {
    answer 'ABSENT'
    run read_guest_exec "${read_root}" read-poll quit-endpoint endpoint
    assert_record 000001
    jq -e '.present == false' <<<"${output}"
    jq -e '.read == "endpoint" and .read_arguments == [] and .transport == "read"
        and (.command | contains("Application Support/Koine/endpoint.json"))
        and (.payload_predicate | startswith("checked read endpoint"))' "${read_root}/000001/request.json"
    jq -se --arg command "$(jq -r .command "${read_root}/000001/request.json")" \
        '. == [["file","exec","--vm","exact-read-vm","--json","--",$command]]' "${read_calls}"
    answer "PRESENT"$'\n'"${DESCRIPTOR}"
    run read_guest_exec "${read_root}" read-poll launch-endpoint endpoint
    assert_record 000002
    jq -e '.present == true and .descriptor.pid == 412 and .descriptor.port == 49152' <<<"${output}"
    [[ ! -e "${read_root}/unavailable" ]]
}

@test "a malformed descriptor is unavailable, never absent" {
    local body index=0
    for body in "${DESCRIPTOR%\}},\"extra\":1}" "${DESCRIPTOR/412/0}" "${DESCRIPTOR/49152/70000}" \
        "${DESCRIPTOR/graphql/other}" "${DESCRIPTOR/\"descriptorVersion\":1/\"descriptorVersion\":2}" \
        "${DESCRIPTOR%\}},\"pid\":413}" "${DESCRIPTOR}x" '[]' '' "${DESCRIPTOR/412/412.0}"; do
        index=$((index + 1))
        reset_root "descriptor-${index}"
        answer "PRESENT"$'\n'"${body}"
        run read_guest_exec "${read_root}" read-poll launch-endpoint endpoint
        [[ "${status}" == 125 && ! -e "${read_root}/000001/read.json" ]]
        grep -q 'grammar' "${read_root}/unavailable"
        assert_latched
    done
}

@test "a failed descriptor read is unavailable, never absent" {
    local index=0 failure
    for failure in '1 false 0' '-1 true 0' '0 false 7' '0 false 255'; do
        index=$((index + 1))
        reset_root "failed-${index}"
        read -r code timed cli <<<"${failure}"
        answer 'ABSENT' "${code}" "${timed}" "${cli}"
        run read_guest_exec "${read_root}" read-poll quit-endpoint endpoint
        [[ "${status}" == 125 && "$(calls)" == 1 && ! -e "${read_root}/000001/read.json" ]]
        assert_latched
    done
}

@test "a timeout with a complete grammatical answer stays unavailable for every read" {
    local name
    for name in endpoint boot installed-inventory system; do
        reset_root "timeout-${name}"
        case "${name}" in
        endpoint) answer 'ABSENT' -1 true ;;
        boot) answer '{ sec = 1, usec = 2 } Thu Jan  1 00:00:01 1970' -1 true ;;
        installed-inventory) answer "$(printf '%064d  ./Contents/Info.plist\nKOINE_INVENTORY_COMPLETE' 0)" -1 true ;;
        system) answer $'ProductName:\t\tmacOS\nProductVersion:\t\t27.2.1\nBuildVersion:\t\t26B131\narm64' -1 true ;;
        esac
        run --separate-stderr read_guest_exec "${read_root}" read-poll timed "${name}"
        [[ "${status}" == 125 && -z "${output}" ]]
        assert_latched
    done
}

@test "stdout with trailing whitespace is not an agent answer" {
    export read_keep_whitespace=1
    local entry index=0
    # JSON and line grammars alone would accept the last two answers.
    for entry in $'endpoint\tABSENT\n' $'endpoint\tPRESENT\n'"${DESCRIPTOR}"$'\n' \
        $'signature-display\tExecutable=/Applications/Koine.app/Contents/MacOS/Koine\nIdentifier=i\nCodeDirectory v=1\nAuthority=A\nTeamIdentifier=T\n'; do
        index=$((index + 1))
        reset_root "whitespace-${index}"
        answer "${entry#*$'\t'}"
        run read_guest_exec "${read_root}" read-poll trailing "${entry%%$'\t'*}"
        [[ "${status}" == 125 ]]
        grep -q 'trailing whitespace\|expected ABSENT' "${read_root}/unavailable"
        assert_latched
    done
}

@test "launch poll keeps fifteen reads two seconds apart and ends in a state failure" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    answer 'ABSENT'
    run await_guest_endpoint "${read_root}" launch-poll launch
    echo "diagnostic: status=${status} calls=$(calls) output=${output}"
    [[ "${status}" == 125 && "$(calls)" == 15 ]]
    [[ "$(sort -u "${BATS_TEST_TMPDIR}/sleeps")" == 2 && "$(wc -l <"${BATS_TEST_TMPDIR}/sleeps" | tr -d ' ')" == 15 ]]
    jq -e '.outcome == "state-failed"' "${read_root}/000031/result.json"
    jq -e '.operation == "launch-poll-exhausted"' "${read_root}/000031/request.json"
    assert_latched
}

@test "launch poll stops on a present descriptor and prints its record" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script '0 false 0 ABSENT' '0 false 0 ABSENT' "0 false 0 PRESENT"$'\n'"${DESCRIPTOR}"
    run await_guest_endpoint "${read_root}" launch-poll launch
    echo "diagnostic: status=${status} calls=$(calls) output=${output}"
    [[ "${status}" == 0 && "$(calls)" == 3 ]]
    jq -e '.present == true and .descriptor.instanceId == "A1"' <<<"${output}"
    [[ "$(wc -l <"${BATS_TEST_TMPDIR}/sleeps" | tr -d ' ')" == 2 && ! -e "${read_root}/unavailable" ]]
}

@test "a failed poll read stops at once and is never a negative" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script '0 false 0 ABSENT' '1 false 0 ABSENT' '0 false 0 ABSENT'
    run await_guest_endpoint "${read_root}" launch-poll launch
    echo "diagnostic: status=${status} calls=$(calls) output=${output}"
    [[ "${status}" == 125 && "$(calls)" == 2 ]]
    [[ "$(wc -l <"${BATS_TEST_TMPDIR}/sleeps" | tr -d ' ')" == 1 ]]
    assert_latched
}

@test "login poll keeps twenty-four reads five seconds apart and its exhaustion latches nothing" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    answer 'ABSENT'
    run await_guest_endpoint "${read_root}" login-poll login
    echo "diagnostic: status=${status} calls=$(calls) output=${output}"
    [[ "${status}" == 1 && "$(calls)" == 24 && ! -e "${read_root}/unavailable" ]]
    [[ "$(sort -u "${BATS_TEST_TMPDIR}/sleeps")" == 5 && "$(wc -l <"${BATS_TEST_TMPDIR}/sleeps" | tr -d ' ')" == 24 ]]
    jq -se 'all(.[]; .outcome == "clean")' "${read_root}"/0000*/result.json
    [[ "$(find "${read_root}" -name result.json | wc -l | tr -d ' ')" == 48 ]]
}

@test "process absence is clean data and process rows keep identity and arguments" {
    answer 'NONE'
    run read_guest_exec "${read_root}" read-poll stopped process executable
    assert_record 000001
    jq -e '.processes == []' <<<"${output}"
    jq -r .command "${read_root}/000001/request.json" | grep -qF "pgrep -f '/Applications/Koine.app/Contents/MacOS'"
    answer $'  412 Sat Nov 21 23:37:39 2026     /Applications/Koine.app/Contents/MacOS/Koine\n---\n  412 /Applications/Koine.app/Contents/MacOS/Koine -AppleLanguages (en)'
    run read_guest_exec "${read_root}" read-poll login process bundle
    assert_record 000002
    jq -e '.processes == [{"pid":412,"started":"Sat Nov 21 23:37:39 2026",
        "executable":"/Applications/Koine.app/Contents/MacOS/Koine",
        "arguments":"/Applications/Koine.app/Contents/MacOS/Koine -AppleLanguages (en)"}]' <<<"${output}"
    jq -r .command "${read_root}/000002/request.json" | grep -qF "pgrep -f '/Applications/Koine.app'"
}

@test "malformed process rows and a failed pgrep are unavailable, never absence" {
    local body index=0
    for body in $'412 Sat Nov 21 23:37:39 2026 /x\n---' $'412 Sat Nov 21 23:37:39 2026 /x\n---\n413 /x' \
        $'412 21 Nov 23:37:39 2026 /x\n---\n412 /x' $'412 Sat Nov 21 23:37:39 2026 <defunct>\n---\n412 x' \
        $'412 Sat Nov 21 23:37:39 2026 /x\n412 Sat Nov 21 23:37:39 2026 /x\n---\n412 /x\n412 /x' '' 'none'; do
        index=$((index + 1))
        reset_root "process-${index}"
        answer "${body}"
        run read_guest_exec "${read_root}" read-poll stopped process executable
        [[ "${status}" == 125 ]]
        assert_latched
    done
    reset_root pgrep-error
    answer '' 2
    run read_guest_exec "${read_root}" read-poll stopped process executable
    [[ "${status}" == 125 ]]
    assert_latched
}

@test "boot identity parses exactly and a changed boot after a failed restart stays unavailable" {
    answer '{ sec = 1795248869, usec = 738891 } Sat Nov 21 19:14:29 2026'
    run read_guest_exec "${read_root}" read-poll boot-before boot
    assert_record 000001
    jq -e '.sec == 1795248869 and .usec == 738891' <<<"${output}"
    answer '' 0 false 255
    run exec_guest_evidence "${read_root}" one-shot restart 'echo admin | sudo -S shutdown -r now' 'true'
    [[ "${status}" == 125 ]]
    cp "${read_root}/unavailable" "${BATS_TEST_TMPDIR}/first"
    answer '{ sec = 1795249999, usec = 1 } Sat Nov 21 19:33:19 2026'
    run read_guest_exec "${read_root}" evidence boot-after boot
    assert_record 000003
    cmp "${BATS_TEST_TMPDIR}/first" "${read_root}/unavailable"
    local body
    for body in '{ sec = 1, usec = 1000000 } x' '{ sec = 1, usec = 2 }' 'sec=1'; do
        reset_root "boot-${#body}"
        answer "${body}"
        run read_guest_exec "${read_root}" read-poll boot-before boot
        [[ "${status}" == 125 ]]
    done
}

@test "the port read keeps the legacy curl command and its exit status is data" {
    answer '7'
    run read_guest_exec "${read_root}" read-poll old-port port-refusal 49152
    assert_record 000001
    jq -e '.curl_exit == 7 and .arguments == ["49152"]' <<<"${output}"
    jq -e '.command == "curl -s -m 3 -o /dev/null http://127.0.0.1:49152/graphql; echo $?"' \
        "${read_root}/000001/request.json"
    answer '0'
    run read_guest_exec "${read_root}" read-poll old-port port-refusal 49152
    assert_record 000002
    local body
    for body in '' 'abc' '256' '07' $'7\n0'; do
        reset_root "port-${#body}-${body//[^a-z0-9]/}"
        answer "${body}"
        run read_guest_exec "${read_root}" read-poll old-port port-refusal 49152
        [[ "${status}" == 125 ]]
    done
}

# defaults_answer [EXTRA-APP-KEYS] [MANAGED-APP-BODY]
defaults_answer() {
    local empty=$'<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict/>\n</plist>'
    local app="${empty}" managed
    if [[ -n "${1:-}" ]]; then
        app=$'<?xml version="1.0" encoding="UTF-8"?>\n<plist version="1.0">\n<dict>\n'"$1"$'\n</dict>\n</plist>'
    fi
    managed='KOINE-ABSENT /Library/Managed Preferences/dev.antony.Koine.plist'
    if [[ -n "${2:-}" ]]; then
        managed=$'KOINE-MANAGED /Library/Managed Preferences/dev.antony.Koine.plist\n<?xml version="1.0" encoding="UTF-8"?>\n<plist version="1.0">\n<dict>\n'"$2"$'\n</dict>\n</plist>'
    fi
    answer "KOINE-DOMAIN dev.antony.Koine any"$'\n'"${app}"$'\n'"KOINE-DOMAIN dev.antony.Koine current"$'\n'"${empty}"$'\n'"KOINE-DOMAIN -g any"$'\n'"${empty}"$'\n'"KOINE-DOMAIN -g current"$'\n'"${empty}"$'\n'"${managed}"$'\nKOINE-ABSENT /Library/Managed Preferences/admin/dev.antony.Koine.plist\nKOINE-ABSENT /Library/Managed Preferences/.GlobalPreferences.plist\nKOINE-ABSENT /Library/Managed Preferences/admin/.GlobalPreferences.plist\nKOINE-DEFAULTS-COMPLETE'
}

@test "absent diagnostic defaults are a parsed fact across every effective source" {
    defaults_answer
    run read_guest_exec "${read_root}" evidence defaults-before defaults
    assert_record 000001
    jq -e '.diagnostics_disabled == true and .user == "admin" and (.sources | length) == 8
        and all(.sources[]; .keys == {})' <<<"${output}"
    defaults_answer '<key>KoineSettingsMenuProbe</key><false/><key>Other</key><date>2026-11-21T00:00:00Z</date>'
    run read_guest_exec "${read_root}" read-poll defaults-after defaults
    assert_record 000002
    jq -e '.diagnostics_disabled == true and .sources[0].keys == {"KoineSettingsMenuProbe":false}' <<<"${output}"
    defaults_answer '<key>KoineSettingsMenuProbe</key><string>0</string>'
    run read_guest_exec "${read_root}" read-poll defaults-after defaults
    assert_record 000003
    jq -e '.diagnostics_disabled == false' <<<"${output}"
    defaults_answer '' '<key>KoineSettingsActivationTrace</key><string>/tmp/t</string>'
    run read_guest_exec "${read_root}" read-poll defaults-after defaults
    assert_record 000004
    jq -e '.diagnostics_disabled == false and .sources[4].present == true
        and .sources[4].keys.KoineSettingsActivationTrace == "/tmp/t"' <<<"${output}"
}

@test "a malformed defaults answer is unavailable, never absence" {
    local index=0 body
    defaults_answer
    local good
    good="$(cat "${read_stdout}")"
    for body in "${good%$'\n'KOINE-DEFAULTS-COMPLETE}" "${good/dev.antony.Koine current/dev.antony.Koine any}" \
        "${good/<dict\/>/<dict>}" "${good/admin\/.GlobalPreferences/other\/.GlobalPreferences}" \
        "${good/KOINE-DOMAIN -g any/KOINE-DOMAIN -g current}" "${good}"$'\nextra' "${good/<dict\/>/<array\/>}"; do
        index=$((index + 1))
        reset_root "defaults-${index}"
        answer "${body}"
        run read_guest_exec "${read_root}" evidence defaults-before defaults
        [[ "${status}" == 125 ]]
        assert_latched
    done
}

@test "the installed inventory keeps the legacy command and needs its exact rows" {
    local hash
    hash="$(printf '%064d' 0)"
    answer "${hash}  ./Contents/Info.plist"$'\n'"${hash/0/a}  ./Contents/MacOS/Koine"$'\n'"./Contents/Current -> A"$'\nKOINE_INVENTORY_COMPLETE'
    run read_guest_exec "${read_root}" evidence installed-before installed-inventory
    assert_record 000001
    jq -e '(.files | length) == 2 and .symlinks == [{"path":"./Contents/Current","target":"A"}]' <<<"${output}"
    jq -r .command "${read_root}/000001/request.json" | grep -qF "find . -type f -exec shasum -a 256 {} + | LC_ALL=C sort"
    local body index=0
    for body in "${hash}  ./Contents/Info.plist" "./Contents/Current -> A"$'\n'"${hash}  ./x"$'\nKOINE_INVENTORY_COMPLETE' \
        "${hash}  ./x"$'\n'"${hash}  ./x"$'\nKOINE_INVENTORY_COMPLETE' 'KOINE_INVENTORY_COMPLETE' \
        "${hash:1}  ./x"$'\nKOINE_INVENTORY_COMPLETE'; do
        index=$((index + 1))
        reset_root "inventory-${index}"
        answer "${body}"
        run read_guest_exec "${read_root}" evidence installed-before installed-inventory
        [[ "${status}" == 125 ]]
    done
}

@test "setup records keep each documented clean status as data" {
    answer $'ProductName:\t\tmacOS\nProductVersion:\t\t27.2.1\nBuildVersion:\t\t26B131\narm64'
    run read_guest_exec "${read_root}" evidence system system
    assert_record 000001
    jq -e '.product_version == "27.2.1" and .build_version == "26B131" and .arch == "arm64"' <<<"${output}"
    answer 'assessments enabled'
    run read_guest_exec "${read_root}" evidence gatekeeper gatekeeper
    assert_record 000002
    answer 'ABSENT'
    run read_guest_exec "${read_root}" evidence quarantine quarantine
    assert_record 000003
    jq -e '.present == false' <<<"${output}"
    answer $'/Applications/Koine.app: a sealed resource is missing or invalid\nKOINE-CODESIGN-STATUS 1'
    run read_guest_exec "${read_root}" evidence signature signature
    assert_record 000004
    jq -e '.valid == false and .status == 1' <<<"${output}"
    answer $'/Applications/Koine.app: rejected\nsource=Unnotarized Developer ID\nKOINE-SPCTL-STATUS 3'
    run read_guest_exec "${read_root}" read-poll assessment assessment
    assert_record 000005
    jq -e '.accepted == false and .status == 3' <<<"${output}"
    answer $'Executable=/Applications/Koine.app/Contents/MacOS/Koine\nIdentifier=dev.antony.Koine\nCodeDirectory v=20500 size=1 flags=0x10000(runtime)\nAuthority=Developer ID Application: X (T)\nTeamIdentifier=T'
    run read_guest_exec "${read_root}" evidence display signature-display
    assert_record 000006
    jq -e '.shown == ["Identifier=dev.antony.Koine","CodeDirectory v=20500 size=1 flags=0x10000(runtime)",
        "Authority=Developer ID Application: X (T)","TeamIdentifier=T"]' <<<"${output}"
}

@test "undocumented statuses and missing result lines in setup records are unavailable" {
    local -a cases=(
        $'signature\t/Applications/Koine.app: error\nKOINE-CODESIGN-STATUS 2'
        $'signature\t/Applications/Koine.app: valid on disk\nKOINE-CODESIGN-STATUS 0'
        $'assessment\t/Applications/Koine.app: accepted\nKOINE-SPCTL-STATUS 1'
        $'assessment\t/Applications/Koine.app: accepted\nKOINE-SPCTL-STATUS 3'
        $'gatekeeper\tassessments unknown'
        $'quarantine\tPRESENT'
        $'system\tProductName:\t\tmacOS\nBuildVersion:\t\t26B131\narm64'
        $'signature-display\tIdentifier=dev.antony.Koine'
    )
    local entry index=0
    for entry in "${cases[@]}"; do
        index=$((index + 1))
        reset_root "setup-${index}"
        answer "${entry#*$'\t'}"
        run read_guest_exec "${read_root}" read-poll setup "${entry%%$'\t'*}"
        [[ "${status}" == 125 ]]
        assert_latched
    done
}
