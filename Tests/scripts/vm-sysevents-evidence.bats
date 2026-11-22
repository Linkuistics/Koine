#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2016,SC1112 # Every test owns its environment; guest-side $HOME; osascript prints U+2019.

setup() {
    bats_require_minimum_version 1.5.0
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    if [[ "${KOINE_SYSEVENTS_BASELINE:-0}" == 1 ]]; then
        legacy_semantics
    else
        # shellcheck source=scripts/vm-sysevents-evidence-lib.sh
        source "${BATS_TEST_DIRNAME}/../../scripts/vm-sysevents-evidence-lib.sh"
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

# Legacy semantics of sysevents, its callers and enrol in scripts/vm-verify-lib.sh
# and scripts/vm-verify-menu-bar.sh. These test-only wrappers adapt the new
# signatures. A legacy `fail` returns 125 here instead of ending the run.
legacy_semantics() {
    KOINE_ITEM='menu bar item 1 of menu bar 2 of process "Koine"'
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
    guest_json() {
        local out status=0
        out="$(guest "$1" 2>&1)" || status=$?
        out="$(grep -v -e '^Process timed out after' -e '^guest exec kept timing out' <<<"${out}" | tail -1)"
        if jq -e . >/dev/null 2>&1 <<<"${out}"; then
            echo "${out}"
            return 0
        fi
        [ "${status}" != 0 ] || status=1
        return "${status}"
    }
    # shellcheck disable=SC2329
    sysevents() {
        local script="tell application \"System Events\" to $1"
        guest_text "osascript -e '${script}'" | tr -d '\r'
    }
    # shellcheck disable=SC2329
    expect_guest_system_events() { [ -n "$(sysevents 'get name of every process')" ]; }
    # shellcheck disable=SC2329
    expect_guest_menu_count() { [ "$(sysevents 'get count of menu bar items of menu bar 2 of process "Koine"')" = 1 ]; }
    # shellcheck disable=SC2329
    expect_guest_background_only() { [ "$(sysevents 'get background only of process "Koine"')" = true ]; }
    # shellcheck disable=SC2329
    expect_guest_no_dock_item() { ! grep -q Koine <<<"$(sysevents 'get name of every UI element of list 1 of process "Dock"')"; }
    # shellcheck disable=SC2329
    expect_guest_menu() {
        local expected
        shift 2
        expected="$(printf '%s, ' "$@")"
        [ "$(sysevents "get title of every menu item of menu 1 of ${KOINE_ITEM}")" = "${expected%, }" ]
    }
    # shellcheck disable=SC2329
    await_guest_menu_label() {
        local got=""
        for _ in $(seq 1 15); do
            got="$(sysevents "get description of ${KOINE_ITEM}")"
            [ "${got}" != "$3" ] || return 0
            sleep 2
        done
        return 125
    }
    # shellcheck disable=SC2329
    await_guest_menu_frame() {
        local frame="" tries=0
        if [[ $# == 2 ]]; then
            until [[ "${frame}" =~ ^[0-9] ]]; do
                tries=$((tries + 1))
                [ "${tries}" -lt 6 ] || return 125
                frame="$(sysevents "get {position, size} of ${KOINE_ITEM}")"
                [[ "${frame}" =~ ^[0-9] ]] || sleep 2
            done
        else
            for _ in $(seq 1 5); do
                frame="$(sysevents "get {position, size} of menu item \"$3\" of menu 1 of ${KOINE_ITEM}")"
                [[ "${frame}" =~ ^[0-9] ]]
                break
                sleep 1
            done
            [[ "${frame}" =~ ^[0-9] ]] || return 125
        fi
        echo "${frame}"
    }
    # shellcheck disable=SC2329
    submit_guest_enrolment() {
        guest_json "python3 \$HOME/vm-verify-enrollment-client.py \"$3\" enrol \"$4\" desktop:read" |
            jq -e '.status == 200 and ((.response.errors // []) | length == 0)' >/dev/null || return 125
    }
    # shellcheck disable=SC2329
    read_guest_exec() {
        case "$4" in
        menu-item-label) sysevents "get description of ${KOINE_ITEM}" ;;
        front-application) sysevents 'get name of first process whose frontmost is true' ;;
        menu-item-count) sysevents 'get count of menu bar items of menu bar 2 of process "Koine"' ;;
        *) sysevents 'get name of every process' ;;
        esac
    }
}

# answer TEXT [EXIT [TIMED_OUT [CLI]]]: the next guest answer of the fixture.
answer() {
    printf '%s' "$1" >"${read_stdout}"
    export read_exit_code="${2:-0}" read_timed_out="${3:-false}" read_cli_status="${4:-0}"
}

# se VALUE: osascript printed VALUE in source form and exited 0.
se() { printf '%s\nKOINE-OSASCRIPT-STATUS 0' "$1"; }
# se_error NUMBER: osascript printed one script error on stdout and exited 1.
# AppleScript writes -1719 with its "Invalid index." suffix and each other
# number without it, as the host formatter does.
se_error() {
    local suffix=''
    [[ "$1" != -1719 ]] || suffix=' Invalid index.'
    se_message "System Events got an error: Can’t get menu bar 2 of process \"Koine\".${suffix}" "$1"
}
# se_message MESSAGE NUMBER: one script error with that message and number.
se_message() { printf '12:80: execution error: %s (%s)\nKOINE-OSASCRIPT-STATUS 1' "$1" "$2"; }
# se_denied NUMBER: the denied Accessibility read of the review counterexample.
se_denied() { se_message 'System Events got an error: testanyware-agent is not allowed assistive access.' "$1"; }

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
    rm -f "${BATS_TEST_TMPDIR}/sleeps"
}

calls() { wc -l <"${read_calls}" | tr -d ' '; }
sleeps() { [[ -e "${BATS_TEST_TMPDIR}/sleeps" ]] && tr '\n' ' ' <"${BATS_TEST_TMPDIR}/sleeps" || :; }

# The root is latched, and a later scenario read refuses without dispatch.
assert_latched() {
    local count
    count="$(calls)"
    [[ -s "${read_root}/unavailable" ]]
    run read_guest_exec "${read_root}" read-poll later menu-item-count
    [[ "${status}" == 125 && "$(calls)" == "${count}" ]]
}

# A clean false state: status 1, one clean read and one clean state receipt.
assert_clean_false() {
    [[ "${status}" == 1 && ! -e "${read_root}/unavailable" ]]
    jq -e '.outcome == "clean"' "${read_root}/000001/result.json" "${read_root}/000002/result.json"
    jq -e '.transport == "poll-step" and .local_status == 1' "${read_root}/000002/request.json"
}

# refused REQUEST...: the request refuses before dispatch and latches.
refused() {
    reset_root "refused-$((++refusals))"
    run read_guest_exec "${read_root}" "$@"
    echo "diagnostic: request=$* status=${status} calls=$(calls)"
    [[ "${status}" != 0 && "$(calls)" == 0 && -s "${read_root}/unavailable" && ! -e "${read_root}/000001" ]]
}

ACCEPTED='{"case": "enrol", "status": 200, "response": {"data": {"koineRequestGrant": {"requestId": "r1", "comparisonCode": "123456"}}}}'
SYSEVENTS_READS=(sysevents-processes menu-item-count 'menu-item-label value' 'menu-item-label poll'
    menu-item-frame 'menu-row-frame Settings…' menu-titles dock-items background-only front-application
    front-process textedit-windows menu-bar-menus 'menu-row-enabled Settings…' koine-menus)

@test "System Events reads refuse the evidence class and the enrolment admits only one-shot" {
    local request
    refusals=0
    for request in "${SYSEVENTS_READS[@]}"; do
        read -r -a words <<<"${request}"
        refused evidence collect "${words[@]}"
        grep -q 'evidence class refuses read.*start System Events' "${read_root}/refusals.jsonl"
    done
    refused read-poll submit enrol '$HOME/koine-secret-first' vm-editor
    grep -q 'needs the one-shot class' "${read_root}/refusals.jsonl"
    refused evidence submit enrol '$HOME/koine-secret-first' vm-editor
    refused one-shot count menu-item-count
    grep -q 'read-poll or evidence class' "${read_root}/refusals.jsonl"
}

@test "row titles, label modes and enrolment arguments refuse before dispatch" {
    refusals=0
    refused read-poll row menu-row-frame
    refused read-poll row menu-row-frame 'Say "hi"'
    refused read-poll row menu-row-frame "Don't Allow"
    refused read-poll row menu-row-frame 'a\b'
    refused read-poll row menu-row-frame ' Settings…'
    refused read-poll row menu-row-frame 'Settings…' extra
    refused read-poll label menu-item-label
    refused read-poll label menu-item-label both
    refused read-poll titles menu-titles extra
    refused one-shot submit enrol /tmp/secret vm-editor
    refused one-shot submit enrol '$HOME/koine-secret-first' 'vm editor'
    refused one-shot submit enrol '$HOME/koine-secret-first' 'vm"x'
    refused one-shot submit enrol '$HOME/koine-secret-first'
}

@test "each read sends the legacy AppleScript in source form with script errors on stdout" {
    local request name script expected index=0
    local -A scripts=(
        ["sysevents-processes"]='get name of every process'
        ["menu-item-count"]='get count of menu bar items of menu bar 2 of process "Koine"'
        ["menu-item-label"]='get description of menu bar item 1 of menu bar 2 of process "Koine"'
        ["menu-item-frame"]='get {position, size} of menu bar item 1 of menu bar 2 of process "Koine"'
        ["menu-row-frame"]='get {position, size} of menu item "Settings…" of menu 1 of menu bar item 1 of menu bar 2 of process "Koine"'
        ["menu-titles"]='get title of every menu item of menu 1 of menu bar item 1 of menu bar 2 of process "Koine"'
        ["dock-items"]='get name of every UI element of list 1 of process "Dock"'
        ["background-only"]='get background only of process "Koine"'
        ["front-application"]='get name of first process whose frontmost is true'
    )
    answer "$(se_error -1728)"
    for request in 'menu-item-label poll' menu-item-frame 'menu-row-frame Settings…'; do
        index=$((index + 1))
        read -r -a words <<<"${request}"
        name="${words[0]}" script="${scripts[${words[0]}]}"
        run read_guest_exec "${read_root}" read-poll command "${words[@]}"
        [[ "${status}" == 0 ]]
        expected="o=\$(osascript -s so -e 'tell application \"System Events\" to ${script}'); s=\$?; printf '%s\\nKOINE-OSASCRIPT-STATUS %s' \"\$o\" \"\$s\""
        jq -e --arg command "${expected}" --arg name "${name}" '.command == $command and .read == $name
            and .class == "read-poll" and .transport == "read"' "${read_root}/$(printf '%06d' "${index}")/request.json"
    done
    for name in sysevents-processes menu-item-count menu-titles dock-items background-only front-application; do
        reset_root "command-${name}"
        answer "$(se '"x"')"
        run read_guest_exec "${read_root}" read-poll command "${name}"
        jq -e --arg script "${scripts[${name}]}" \
            '.command | contains("osascript -s so -e '\''tell application \"System Events\" to " + $script + "'\''")' \
            "${read_root}/000001/request.json"
    done
}

@test "a source-form list keeps a title that holds the separator" {
    # The legacy human-readable form renders both lists as one string.
    answer "$(se '{"Review 1 Grant Request…", "a, b", "", "Quit Koine"}')"
    run expect_guest_menu "${read_root}" menu 'Review 1 Grant Request…' a b '' 'Quit Koine'
    echo "diagnostic: status=${status} output=${output}"
    assert_clean_false
    reset_root separator
    answer "$(se '{"Review 1 Grant Request…", "a, b", "", "Quit Koine"}')"
    run expect_guest_menu "${read_root}" menu 'Review 1 Grant Request…' 'a, b' '' 'Quit Koine'
    [[ "${status}" == 0 ]]
    jq -e '.value == ["Review 1 Grant Request…", "a, b", "", "Quit Koine"]' <<<"${output}"
    jq -e '.value | length == 4' "${read_root}/000001/read.json"
}

@test "an empty menu and a menu of one empty title are different lists" {
    answer "$(se '{}')"
    run expect_guest_menu "${read_root}" menu ''
    echo "diagnostic: status=${status} output=${output}"
    assert_clean_false
    reset_root one-empty
    answer "$(se '{""}')"
    run expect_guest_menu "${read_root}" menu ''
    [[ "${status}" == 0 ]]
}

@test "the Dock assertion reads item names, and a failed Dock read shows nothing" {
    # An error message names no Dock item, so it cannot show that Koine has none.
    answer "$(se_error -1728)"
    run expect_guest_no_dock_item "${read_root}" dock
    echo "diagnostic: status=${status} output=${output}"
    [[ "${status}" == 125 ]]
    grep -q 'only a poll admits' "${read_root}/unavailable"
    assert_latched
    reset_root dock-names
    answer "$(se '{"Finder", missing value, "TextEdit"}')"
    run expect_guest_no_dock_item "${read_root}" dock
    [[ "${status}" == 0 ]]
    reset_root dock-koine
    answer "$(se '{"Finder", missing value, "Koine"}')"
    run expect_guest_no_dock_item "${read_root}" dock
    assert_clean_false
}

@test "count, agent flag, label and front application keep their exact types" {
    local value index=0
    # The legacy human-readable form prints the string "1" as 1.
    answer "$(se '"1"')"
    run expect_guest_menu_count "${read_root}" count
    echo "diagnostic: status=${status} output=${output}"
    [[ "${status}" == 125 ]]
    grep -q 'another type' "${read_root}/unavailable"
    reset_root count-one
    answer "$(se 1)"
    run expect_guest_menu_count "${read_root}" count
    [[ "${status}" == 0 ]]
    jq -e '.value == 1' <<<"${output}"
    reset_root count-two
    answer "$(se 2)"
    run expect_guest_menu_count "${read_root}" count
    assert_clean_false
    reset_root flag
    answer "$(se true)"
    run expect_guest_background_only "${read_root}" flag
    [[ "${status}" == 0 ]]
    reset_root flag-false
    answer "$(se false)"
    run expect_guest_background_only "${read_root}" flag
    assert_clean_false
    reset_root label-missing
    answer "$(se 'missing value')"
    run read_guest_exec "${read_root}" read-poll item menu-item-label value
    [[ "${status}" == 0 ]]
    jq -e '.absent == false and .value == null' <<<"${output}"
    reset_root front
    answer "$(se '"TextEdit"')"
    run read_guest_exec "${read_root}" read-poll front front-application
    [[ "${status}" == 0 ]]
    jq -e '.value == "TextEdit"' <<<"${output}"
    for value in 'menu-item-count "1"' 'menu-item-count -1' 'menu-item-count true' 'menu-item-count {1}' \
        'background-only "true"' 'background-only 1' 'front-application missing value' 'menu-titles "Quit Koine"'; do
        index=$((index + 1))
        reset_root "type-${index}"
        answer "$(se "${value#* }")"
        run read_guest_exec "${read_root}" read-poll typed "${value%% *}"
        echo "diagnostic: value=${value} status=${status} output=${output}"
        [[ "${status}" == 125 ]]
        grep -q 'another type' "${read_root}/unavailable"
    done
}

@test "a clean absence is a negative only in the label and frame polls" {
    local request
    answer "$(se_error -1728)"
    run read_guest_exec "${read_root}" read-poll label menu-item-label poll
    [[ "${status}" == 0 ]]
    jq -e '.absent == true and .error == -1728' <<<"${output}"
    for request in menu-item-frame 'menu-row-frame Quit Koine'; do
        reset_root "absent-${request%% *}"
        answer "$(se_error -1719)"
        read -r -a words <<<"${request}"
        [[ "${words[0]}" != menu-row-frame ]] || words=(menu-row-frame 'Quit Koine')
        run read_guest_exec "${read_root}" read-poll frame "${words[@]}"
        [[ "${status}" == 0 ]]
        jq -e '.absent == true and .error == -1719' <<<"${output}"
    done
    for request in 'menu-item-label value' menu-item-count menu-titles dock-items background-only \
        sysevents-processes front-application; do
        reset_root "required-${request%% *}"
        answer "$(se_error -1728)"
        read -r -a words <<<"${request}"
        run read_guest_exec "${read_root}" read-poll required "${words[@]}"
        echo "diagnostic: request=${request} status=${status} output=${output}"
        [[ "${status}" == 125 ]]
        grep -q 'only a poll admits' "${read_root}/unavailable"
        assert_latched
    done
}

@test "a denied or unformatted error with an absence number is unavailable in every poll" {
    local body request index=0
    for body in "$(se_denied -1719)" "$(se_denied -1728)" \
        "$(se_message 'System Events got an error: Can’t get menu bar 2 of process "Koine". Invalid index.' -1728)" \
        "$(se_message 'System Events got an error: Can’t get menu bar 2 of process "Koine".' -1719)" \
        "$(se_message 'Can’t get menu bar 2 of process "Koine". Invalid index.' -1719)" \
        "$(se_message "System Events got an error: Can't get menu bar 2 of process \"Koine\"." -1728)" \
        "$(se_message 'System Events got an error: Can’t get . Invalid index.' -1719)"; do
        for request in 'menu-item-label poll' menu-item-frame 'menu-row-frame Quit Koine'; do
            index=$((index + 1))
            reset_root "denied-${index}"
            answer "${body}"
            read -r -a words <<<"${request}"
            [[ "${words[0]}" != menu-row-frame ]] || words=(menu-row-frame 'Quit Koine')
            run read_guest_exec "${read_root}" read-poll poll "${words[@]}"
            echo "diagnostic: body=${body} request=${request} status=${status} output=${output}"
            [[ "${status}" == 125 && ! -e "${read_root}/000001/read.json" ]]
            grep -q 'does not report a missing element' "${read_root}/unavailable"
            assert_latched
        done
    done
}

@test "a denied label read stops the label poll at once and consumes no negative step" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script "0 false 0 $(se_denied -1719)" "0 false 0 $(se '"Koine"')"
    run await_guest_menu_label "${read_root}" label Koine
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
    [[ "${status}" == 125 && "$(calls)" == 1 && -z "$(sleeps)" ]]
    grep -q 'AppleScript error -1719 does not report a missing element' "${read_root}/unavailable"
    assert_latched
}

@test "a denied item frame read stops the item frame poll at once and consumes no negative step" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script "0 false 0 $(se_denied -1728)" "0 false 0 $(se '{{1500, 0}, {30, 24}}')"
    run await_guest_menu_frame "${read_root}" item
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
    [[ "${status}" == 125 && "$(calls)" == 1 && -z "$(sleeps)" ]]
    grep -q 'AppleScript error -1728 does not report a missing element' "${read_root}/unavailable"
    assert_latched
}

@test "a denied row frame read stops the row frame poll at once and consumes no negative step" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script "0 false 0 $(se_denied -1719)" "0 false 0 $(se '{{1490, 24}, {200, 22}}')"
    run await_guest_menu_frame "${read_root}" row 'Settings…'
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
    [[ "${status}" == 125 && "$(calls)" == 1 && -z "$(sleeps)" ]]
    grep -q 'AppleScript error -1719 does not report a missing element' "${read_root}/unavailable"
    assert_latched
}

@test "other AppleScript errors, statuses and malformed answers are unavailable" {
    local body index=0
    for body in "$(se_error -1743)" "$(se_error -1712)" "$(se_error -600)" "$(se_error -10006)" \
        $'0:12: syntax error: A “error” can’t go after this identifier. (-2740)\nKOINE-OSASCRIPT-STATUS 1' \
        $'"Koine"\nKOINE-OSASCRIPT-STATUS 2' $'\nKOINE-OSASCRIPT-STATUS 0' \
        $'1:2: execution error: x (-1728)\n3:4: execution error: y (-1728)\nKOINE-OSASCRIPT-STATUS 1' \
        $'"Koine" "x"\nKOINE-OSASCRIPT-STATUS 0' $'"a\\q"\nKOINE-OSASCRIPT-STATUS 0' \
        $'"Koine\nKOINE-OSASCRIPT-STATUS 0' $'{a:1}\nKOINE-OSASCRIPT-STATUS 0' $'1.5\nKOINE-OSASCRIPT-STATUS 0' \
        '"Koine"' $'"Koine"\nKOINE-OSASCRIPT-STATUS 0\n' $'{"a","b"}\nKOINE-OSASCRIPT-STATUS 0'; do
        index=$((index + 1))
        reset_root "malformed-${index}"
        export read_keep_whitespace=1
        answer "${body}"
        run read_guest_exec "${read_root}" read-poll label menu-item-label poll
        echo "diagnostic: index=${index} status=${status} output=${output}"
        [[ "${status}" == 125 && ! -e "${read_root}/000001/read.json" ]]
        grep -q 'grammar' "${read_root}/unavailable"
        assert_latched
    done
}

@test "a timeout, a guest failure or a transport failure is unavailable even with a clean answer" {
    local failure index=0
    for failure in '1 false 0' '-1 true 0' '0 false 7' '0 false 255'; do
        index=$((index + 1))
        reset_root "failed-${index}"
        read -r code timed cli <<<"${failure}"
        answer "$(se '"Koine"')" "${code}" "${timed}" "${cli}"
        run read_guest_exec "${read_root}" read-poll label menu-item-label poll
        echo "diagnostic: failure=${failure} status=${status} calls=$(calls) output=${output}"
        [[ "${status}" == 125 && "$(calls)" == 1 && ! -e "${read_root}/000001/read.json" ]]
        assert_latched
    done
}

@test "the label poll keeps fifteen reads two seconds apart and ends in a state failure" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    answer "$(se '"Koine, Accessibility not granted"')"
    run await_guest_menu_label "${read_root}" label Koine
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
    [[ "${status}" == 125 && "$(calls)" == 15 && "$(sleeps)" == "$(printf '2 %.0s' {1..15})" ]]
    jq -e '.outcome == "state-failed"' "${read_root}/000031/result.json"
    jq -e '.operation == "label-exhausted"' "${read_root}/000031/request.json"
    assert_latched
}

@test "the label poll waits through an absence and a missing value and stops on the exact label" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script "0 false 0 $(se_error -1719)" "0 false 0 $(se 'missing value')" \
        "0 false 0 $(se '"Koine, 1 grant request waiting"')" "0 false 0 $(se '"Koine"')"
    run await_guest_menu_label "${read_root}" label Koine
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
    [[ "${status}" == 0 && "$(calls)" == 4 && "$(sleeps)" == '2 2 2 ' ]]
    jq -e '.value == "Koine" and .arguments == ["poll"]' <<<"${output}"
    jq -se 'map(.outcome) | all(. == "clean")' "${read_root}"/0000*/result.json
    [[ ! -e "${read_root}/unavailable" ]]
}

@test "a failed label read stops the poll at once and is never a negative" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script "0 false 0 $(se_error -1728)" "0 false 0 $(se_error -1743)" "0 false 0 $(se '"Koine"')"
    run await_guest_menu_label "${read_root}" label Koine
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
    [[ "${status}" == 125 && "$(calls)" == 2 && "$(sleeps)" == '2 ' ]]
    grep -q 'AppleScript error -1743 is unavailable' "${read_root}/unavailable"
    assert_latched
}

@test "the item frame poll keeps five reads two seconds apart and the legacy digit predicate" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    # An error line begins with a digit, so the legacy predicate stopped on it.
    script "0 false 0 $(se_error -1728)" "0 false 0 $(se '{{-3, 0}, {30, 24}}')" \
        "0 false 0 $(se '{{1500, 0}, {30, 24}}')"
    run await_guest_menu_frame "${read_root}" item
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
    [[ "${status}" == 0 && "$(calls)" == 3 && "$(sleeps)" == '2 2 ' ]]
    jq -e '.text == "1500, 0, 30, 24" and .value == [[1500, 0], [30, 24]]' <<<"${output}"
    reset_root frame-exhausted
    answer "$(se '{missing value, missing value}')"
    run await_guest_menu_frame "${read_root}" item
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
    [[ "${status}" == 125 && "$(calls)" == 5 && "$(sleeps)" == '2 2 2 2 2 ' ]]
    jq -e '.outcome == "state-failed" and .reason == "clean window poll exhausted"' "${read_root}/000011/result.json"
}

@test "a partial frame passes the legacy predicate and keeps its rendering for click_centre" {
    answer "$(se '{{1500, 0}, missing value}')"
    run await_guest_menu_frame "${read_root}" item
    [[ "${status}" == 0 && "$(calls)" == 1 ]]
    jq -e '.text == "1500, 0, missing value"' <<<"${output}"
}

@test "the row frame poll names its row and keeps five reads one second apart" {
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    answer "$(se_error -1719)"
    run await_guest_menu_frame "${read_root}" row 'Settings…'
    echo "diagnostic: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
    [[ "${status}" == 125 && "$(calls)" == 5 && "$(sleeps)" == '1 1 1 1 1 ' ]]
    jq -e '.read_arguments == ["Settings…"] and (.command | contains("menu item \"Settings…\" of menu 1 of"))' \
        "${read_root}/000001/request.json"
    jq -e '.outcome == "state-failed"' "${read_root}/000011/result.json"
}

@test "each deferred menu poll keeps its bound and leaves the exhaustion receipt to the caller (k166)" {
    [[ "${KOINE_SYSEVENTS_BASELINE:-0}" != 1 ]] || skip 'new deferred interface only'
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    local kind reads waits predicate
    for kind in label item row; do
        reset_root "deferred-${kind}"
        rm -f "${BATS_TEST_TMPDIR}/sleeps"
        answer "$(se_error -1719)"
        case "${kind}" in
        label)
            run await_guest_menu_label "${read_root}" poll Koine deferred
            reads=15 waits='2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 '
            predicate="$(menu_label_predicate Koine)"
            [[ "${predicate}" == '(.absent | not) and .value == "Koine"' ]]
            ;;
        item)
            run await_guest_menu_frame "${read_root}" poll '' deferred
            reads=5 waits='2 2 2 2 2 '
            predicate="$(menu_frame_predicate)"
            ;;
        row)
            run await_guest_menu_frame "${read_root}" poll 'Settings…' deferred
            reads=5 waits='1 1 1 1 1 '
            predicate="$(menu_frame_predicate)"
            jq -e '.read_arguments == ["Settings…"]' "${read_root}/000001/request.json"
            ;;
        esac
        echo "diagnostic ${kind}: status=${status} calls=$(calls) sleeps=$(sleeps) output=${output}"
        [[ "${status}" == 1 && "$(calls)" == "${reads}" && "$(sleeps)" == "${waits}" && -z "${output}" ]]
        [[ ! -e "${read_root}/unavailable" ]]
        jq -se 'all(.[]; .outcome == "clean")' "${read_root}"/0000*/result.json
        run record_guest_poll "${read_root}" poll-exhausted exhausted 1 "${predicate}"
        [[ "${status}" == 125 ]]
        assert_latched
    done
    [[ "$(menu_frame_predicate)" == '(.absent | not) and (.value[0] | type == "array" and .[0] >= 0)' ]]
}

@test "a deferred menu poll keeps the positive, the failed read and the argument refusals (k166)" {
    [[ "${KOINE_SYSEVENTS_BASELINE:-0}" != 1 ]] || skip 'new deferred interface only'
    # shellcheck disable=SC2329
    sleep() { printf '%s\n' "$1" >>"${BATS_TEST_TMPDIR}/sleeps"; }
    script "0 false 0 $(se_error -1719)" "0 false 0 $(se '{{1500, 0}, {30, 24}}')"
    run await_guest_menu_frame "${read_root}" item '' deferred
    [[ "${status}" == 0 && "$(calls)" == 2 ]]
    jq -e '.text == "1500, 0, 30, 24"' <<<"${output}"
    reset_root deferred-failed
    script "0 false 0 $(se_error -1719)" "0 false 0 $(se_error -1743)"
    # The fixture keeps its cursor beside the script file.
    echo 0 >"${read_script}.used"
    run await_guest_menu_label "${read_root}" label Koine deferred
    [[ "${status}" == 125 && "$(calls)" == 2 ]]
    assert_latched
    # Three arguments stay a row title, even when the title is the mode's word.
    reset_root deferred-title
    answer "$(se '{{1500, 0}, {30, 24}}')"
    run await_guest_menu_frame "${read_root}" row deferred
    [[ "${status}" == 0 ]]
    jq -e '.read_arguments == ["deferred"]' "${read_root}/000001/request.json"
    reset_root deferred-word-frame
    run await_guest_menu_frame "${read_root}" row 'Settings…' later
    [[ "${status}" == 125 && "$(calls)" == 0 ]]
    assert_latched
    reset_root deferred-word-label
    run await_guest_menu_label "${read_root}" label Koine later
    [[ "${status}" == 125 && "$(calls)" == 0 ]]
    assert_latched
}

@test "the System Events check after the grant needs a complete nonempty process list" {
    # A refusal prints an error line, which is not a process list.
    answer "$(se_error -1743)"
    run expect_guest_system_events "${read_root}" granted
    echo "diagnostic: status=${status} output=${output}"
    [[ "${status}" == 125 ]]
    grep -q 'AppleScript error -1743 is unavailable' "${read_root}/unavailable"
    assert_latched
    reset_root granted
    answer "$(se '{"loginwindow", "Dock"}')"
    run expect_guest_system_events "${read_root}" granted
    [[ "${status}" == 0 ]]
    reset_root empty
    answer "$(se '{}')"
    run expect_guest_system_events "${read_root}" granted
    assert_clean_false
}

@test "the enrolment needs one complete JSON line and keeps the legacy predicate" {
    local refusal index=0
    answer "${ACCEPTED}"
    run submit_guest_enrolment "${read_root}" enrol-first '$HOME/koine-secret-first' vm-editor
    [[ "${status}" == 0 ]]
    jq -e '.status == 200 and .response.data.koineRequestGrant.requestId == "r1"' <<<"${output}"
    jq -e '.class == "one-shot" and .read == "enrol"
        and .command == "python3 $HOME/vm-verify-enrollment-client.py \"$HOME/koine-secret-first\" enrol \"vm-editor\" desktop:read"' \
        "${read_root}/000001/request.json"
    for refusal in '{"case": "enrol", "status": 403, "response": {"errors": [{"message": "no"}]}}' \
        '{"case": "enrol", "status": 200, "response": {"errors": [{"message": "no"}]}}' \
        '{"case": "enrol", "status": 400, "response": null}'; do
        index=$((index + 1))
        reset_root "refusal-${index}"
        answer "${refusal}"
        run submit_guest_enrolment "${read_root}" enrol-first '$HOME/koine-secret-first' vm-editor
        echo "diagnostic: refusal=${refusal} status=${status}"
        assert_clean_false
    done
}

@test "a malformed enrolment answer is unavailable" {
    local body index=0
    for body in $'Traceback (most recent call last):\n'"${ACCEPTED}" "${ACCEPTED} extra" \
        '{"case": "enrol", "case": "enrol", "status": 200, "response": null}' \
        '{"case": "enrol", "status": 200, "response": null, "secret": "s"}' '{"case": "enrol", "status": 200}' \
        '{"case": "poll", "status": 200, "response": null}' '{"case": "enrol", "status": "200", "response": null}' \
        '{"case": "enrol", "status": 99, "response": null}' '{"case": "enrol", "status": NaN, "response": null}' \
        '{"case": "enrol", "status": 200, "response": []}' '[]' ''; do
        index=$((index + 1))
        reset_root "malformed-${index}"
        answer "${body}"
        run submit_guest_enrolment "${read_root}" enrol-first '$HOME/koine-secret-first' vm-editor
        echo "diagnostic: index=${index} status=${status} output=${output}"
        [[ "${status}" == 125 && ! -e "${read_root}/000001/read.json" ]]
        grep -q 'grammar' "${read_root}/unavailable"
        assert_latched
    done
}

@test "a failed enrolment submission is unavailable, and no later answer makes it clean" {
    local failure index=0 count
    for failure in '1 false 0' '-1 true 0' '0 false 7'; do
        index=$((index + 1))
        reset_root "failed-${index}"
        read -r code timed cli <<<"${failure}"
        answer "${ACCEPTED}" "${code}" "${timed}" "${cli}"
        run submit_guest_enrolment "${read_root}" enrol-first '$HOME/koine-secret-first' vm-editor
        echo "diagnostic: failure=${failure} status=${status} calls=$(calls)"
        [[ "${status}" == 125 && "$(calls)" == 1 ]]
        # A second submission with a clean answer refuses without dispatch.
        answer "${ACCEPTED}"
        count="$(calls)"
        run submit_guest_enrolment "${read_root}" enrol-again '$HOME/koine-secret-first' vm-editor
        [[ "${status}" == 125 && "$(calls)" == "${count}" ]]
    done
}

# --- the reads of the positive setup and the route (k67) -------------------

@test "the setup and route reads send their fixed AppleScript in source form" {
    local request name expected index=0
    local -A scripts=(
        ["front-process"]='get {name, unix id} of first process whose frontmost is true'
        ["textedit-windows"]='tell process "TextEdit" to get {subrole of every window, role of every sheet of every window}'
        ["menu-bar-menus"]='get {name of every menu bar item of menu bar 1 of process "TextEdit", name of every menu of every menu bar item of menu bar 1 of process "TextEdit", name of every menu of menu bar item 1 of menu bar 2 of process "Koine"}'
        ["menu-row-enabled"]='get enabled of menu item "Settings…" of menu 1 of menu bar item 1 of menu bar 2 of process "Koine"'
        ["koine-menus"]='get name of every menu of menu bar item 1 of menu bar 2 of process "Koine"'
    )
    answer "$(se 'true')"
    for request in front-process textedit-windows menu-bar-menus 'menu-row-enabled Settings…' koine-menus; do
        index=$((index + 1))
        read -r -a words <<<"${request}"
        name="${words[0]}"
        run read_guest_exec "${read_root}" read-poll command "${words[@]}"
        expected="o=\$(osascript -s so -e 'tell application \"System Events\" to ${scripts[${name}]}'); s=\$?; printf '%s\\nKOINE-OSASCRIPT-STATUS %s' \"\$o\" \"\$s\""
        jq -e --arg command "${expected}" --arg name "${name}" '.command == $command and .read == $name
            and .class == "read-poll"' "${read_root}/000001/request.json"
        reset_root "setup-command-${index}"
    done
    refusals=0
    refused read-poll row menu-row-enabled
    refused read-poll row menu-row-enabled "Don't Allow"
    refused read-poll menus menu-bar-menus extra
    refused read-poll menus koine-menus extra
    # The selection reads are gone (k162).
    refused read-poll menus open-menus
    refused read-poll menus menu-item-selected
}

@test "the setup and route reads parse their complete values" {
    local case name text expected index=0
    for case in \
        'front-process|{"TextEdit", 909}|["TextEdit",909]' \
        'textedit-windows|{{"AXStandardWindow"}, {{}}}|[["AXStandardWindow"],[[]]]' \
        'textedit-windows|{{"AXStandardWindow", "AXDialog"}, {{"AXSheet"}, {}}}|[["AXStandardWindow","AXDialog"],[["AXSheet"],[]]]' \
        'textedit-windows|{{}, {}}|[[],[]]' \
        'menu-bar-menus|{{"Apple", missing value, "File"}, {{}, {}, {"File"}}, {}}|[["Apple",null,"File"],[[],[],["File"]],[]]' \
        'menu-bar-menus|{{"Apple"}, {{}}, {missing value}}|[["Apple"],[[]],[null]]' \
        'menu-row-enabled|false|false' \
        'koine-menus|{}|[]' \
        'koine-menus|{missing value}|[null]'; do
        IFS='|' read -r name text expected <<<"${case}"
        index=$((index + 1))
        reset_root "setup-parse-${index}"
        answer "$(se "${text}")"
        args=("${name}")
        [[ "${name}" != menu-row-enabled ]] || args+=('Settings…')
        run read_guest_exec "${read_root}" read-poll parse "${args[@]}"
        echo "diagnostic: case=${case} status=${status} output=${output}"
        [[ "${status}" == 0 ]]
        jq -e --argjson value "${expected}" '.absent == false and .value == $value' <<<"${output}"
    done
}

@test "the menu reads retain the count of menus under each item (k162)" {
    reset_root menu-counts
    answer "$(se '{{"Apple", "File"}, {{}, {"File"}}, {missing value}}')"
    run read_guest_exec "${read_root}" read-poll counts menu-bar-menus
    echo "diagnostic: status=${status} output=${output}"
    [[ "${status}" == 0 ]]
    jq -e '.counts == [0, 1] and .koine_count == 1' <<<"${output}"
    reset_root koine-count
    answer "$(se '{}')"
    run read_guest_exec "${read_root}" read-poll count koine-menus
    [[ "${status}" == 0 ]]
    jq -e '.count == 0' <<<"${output}"
}

@test "a missing value, an incomplete enumeration or a script error in a setup read is unavailable" {
    local case name text index=0
    for case in \
        'front-process|{missing value, 909}' \
        'front-process|{"TextEdit", 0}' \
        'front-process|{"TextEdit"}' \
        'textedit-windows|{{missing value}, {{}}}' \
        'textedit-windows|{{"AXStandardWindow"}, {}}' \
        'textedit-windows|{{"AXStandardWindow"}, {{missing value}}}' \
        'menu-bar-menus|{{"Apple", "File"}, {{}, missing value}, {}}' \
        'menu-bar-menus|{{"Apple", "File"}, {{}}, {}}' \
        'menu-bar-menus|{{"Apple"}, {{}}, missing value}' \
        'menu-bar-menus|{{"Apple", "File"}, {}, {}}' \
        'menu-bar-menus|{{"Apple"}, {"File"}, {}}' \
        'menu-bar-menus|{{}, {}, {}}' \
        'menu-bar-menus|{{"Apple"}, {{false}}, {}}' \
        'menu-row-enabled|missing value' \
        'koine-menus|missing value' \
        'koine-menus|false' \
        'koine-menus|ERROR'; do
        IFS='|' read -r name text <<<"${case}"
        index=$((index + 1))
        reset_root "setup-missing-${index}"
        if [[ "${text}" == ERROR ]]; then answer "$(se_error -1728)"; else answer "$(se "${text}")"; fi
        args=("${name}")
        [[ "${name}" != menu-row-enabled ]] || args+=('Settings…')
        run read_guest_exec "${read_root}" read-poll missing "${args[@]}"
        echo "diagnostic: case=${case} status=${status} output=${output}"
        [[ "${status}" == 125 ]]
        assert_latched
    done
}
