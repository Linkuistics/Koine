#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # Every test owns its environment.

setup() {
    bats_require_minimum_version 1.5.0
    # shellcheck source=scripts/vm-guest-exec-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-guest-exec-lib.sh"
    if [[ "${KOINE_FILE_LIFECYCLE_BASELINE:-0}" == 1 ]]; then
        # Legacy scenario semantics from scripts/vm-verify-lib.sh. These
        # test-only wrappers adapt the new signatures, not the production API.
        # shellcheck disable=SC2329
        upload_guest_file() { testanyware file upload "$3" "$4" >/dev/null; }
        # shellcheck disable=SC2329
        download_guest_file() { testanyware file download "$4" "$1/download.bin" --json; }
        # shellcheck disable=SC2329
        start_guest_vm() {
            testanyware vm start --platform macos --wait --id exact-lifecycle-vm --base "$3" >/dev/null
        }
        # shellcheck disable=SC2329
        stop_guest_vm() { testanyware vm stop exact-lifecycle-vm >/dev/null 2>&1 || true; }
        # shellcheck disable=SC2329
        inventory_guest_vms() { :; }
    else
        # shellcheck source=scripts/vm-file-evidence-lib.sh
        source "${BATS_TEST_DIRNAME}/../../scripts/vm-file-evidence-lib.sh"
        # shellcheck source=scripts/vm-lifecycle-evidence-lib.sh
        source "${BATS_TEST_DIRNAME}/../../scripts/vm-lifecycle-evidence-lib.sh"
    fi
    export lifecycle_root="${BATS_TEST_TMPDIR}/evidence"
    export lifecycle_calls="${BATS_TEST_TMPDIR}/calls"
    export lifecycle_guest="${BATS_TEST_TMPDIR}/guest"
    export lifecycle_state="${BATS_TEST_TMPDIR}/running"
    export lifecycle_ready="${BATS_TEST_TMPDIR}/ready"
    export lifecycle_fixture="${BATS_TEST_DIRNAME}/fixtures/file-lifecycle-cli.py"
    export lifecycle_mode=clean lifecycle_exit=0 lifecycle_block=0
    mkdir "${BATS_TEST_TMPDIR}/bin" "${BATS_TEST_TMPDIR}/cwd" "${lifecycle_guest}"
    cat >"${BATS_TEST_TMPDIR}/bin/testanyware" <<'CLI'
#!/bin/bash
exec python3 "${lifecycle_fixture}" "$@"
CLI
    chmod +x "${BATS_TEST_TMPDIR}/bin/testanyware"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    : >"${lifecycle_calls}"
    export local_input="${BATS_TEST_TMPDIR}/input file.zip"
    printf 'synthetic bundle archive bytes\n' >"${local_input}"
    cd "${BATS_TEST_TMPDIR}/cwd" || return
    init_guest_evidence "${lifecycle_root}" exact-lifecycle-vm
}

reset_root() {
    lifecycle_root="${BATS_TEST_TMPDIR}/$1"
    init_guest_evidence "${lifecycle_root}" exact-lifecycle-vm
    : >"${lifecycle_calls}"
}

digest() { shasum -a 256 "$1" | cut -d ' ' -f 1; }

calls() { wc -l <"${lifecycle_calls}" | tr -d ' '; }

# The root is latched, and a later scenario input refuses without dispatch.
assert_latched() {
    local count
    count="$(calls)"
    [[ -s "${lifecycle_root}/unavailable" ]]
    lifecycle_mode=clean run cli_guest_evidence "${lifecycle_root}" one-shot later \
        '.key == "return" and .modifiers == []' -- input key return
    [[ "${status}" == 125 && "$(calls)" == "${count}" ]]
}

@test "generic upload and download refuse every class without dispatch" {
    local kind command
    for command in upload download; do
        for kind in read-poll one-shot evidence; do
            reset_root "generic-${command}-${kind}"
            if [[ "${command}" == upload ]]; then
                set -- file upload "${local_input}" /Users/admin/input.zip
            else
                set -- file download /Users/admin/input.zip "${BATS_TEST_TMPDIR}/copy"
            fi
            run cli_guest_evidence "${lifecycle_root}" "${kind}" unchecked '.ok == true' -- "$@"
            [[ "${status}" == 125 && "$(calls)" == 0 && ! -e "${lifecycle_root}/000001" ]]
            [[ ! -e "${BATS_TEST_TMPDIR}/copy" ]]
            jq -se 'length == 1 and (.[0].reason | contains("checked transfer"))' "${lifecycle_root}/refusals.jsonl"
            assert_latched
        done
    done
}

@test "upload records exact argv raw receipt and stable local identity before and after dispatch" {
    local expected
    expected="$(digest "${local_input}")"
    upload_guest_file "${lifecycle_root}" install-archive "${local_input}" /tmp/Koine.zip >"${BATS_TEST_TMPDIR}/actual"
    cmp "${BATS_TEST_TMPDIR}/actual" "${lifecycle_root}/000001/raw.stdout"
    grep -qx 'synthetic lifecycle diagnostic' "${lifecycle_root}/000001/raw.stderr"
    jq -se --arg local "${local_input}" \
        '. == [["file","upload",$local,"/tmp/Koine.zip","--vm","exact-lifecycle-vm","--json"]]' "${lifecycle_calls}"
    jq -e --arg local "${local_input}" '.transport == "upload" and .class == "one-shot"
        and .operation == "install-archive" and .vm == "exact-lifecycle-vm"
        and (.payload_predicate | contains($local) and contains(".bytes == 31"))' "${lifecycle_root}/000001/request.json"
    jq -e --arg digest "${expected}" --arg local "${local_input}" \
        '.path == $local and .bytes == 31 and .sha256 == $digest' "${lifecycle_root}/000001/local-before.json"
    cmp "${lifecycle_root}/000001/local-before.json" "${lifecycle_root}/000001/local-after.json"
    jq -e --arg digest "${expected}" '.direction == "upload" and .remote == "/tmp/Koine.zip"
        and .bytes == 31 and .sha256 == $digest' "${lifecycle_root}/000001/transfer.json"
    jq -e '.outcome == "clean" and .cli_status == 0 and .emission_status == "flushed"' "${lifecycle_root}/000001/result.json"
    [[ ! -e "${lifecycle_root}/unavailable" ]]
}

@test "download qualifies guest bytes against the upload record at a backend-owned path" {
    upload_guest_file "${lifecycle_root}" install-archive "${local_input}" /tmp/Koine.zip >/dev/null
    download_guest_file "${lifecycle_root}" read-poll archive-identity /tmp/Koine.zip 000001 >"${BATS_TEST_TMPDIR}/actual"
    local copy="${lifecycle_root}/000002/download.bin"
    cmp "${local_input}" "${copy}"
    jq -e --arg path "${copy}" '.local == $path and .remote == "/tmp/Koine.zip" and .bytes == 31' "${BATS_TEST_TMPDIR}/actual"
    jq -se --arg path "${copy}" \
        '.[1] == ["file","download","/tmp/Koine.zip",$path,"--vm","exact-lifecycle-vm","--json"]' "${lifecycle_calls}"
    jq -e --arg digest "$(digest "${local_input}")" '.direction == "download" and .matches_upload == "000001"
        and .sha256 == $digest and .bytes == 31' "${lifecycle_root}/000002/transfer.json"
    jq -e '.transport == "download" and .class == "read-poll"' "${lifecycle_root}/000002/request.json"
    [[ ! -e "${lifecycle_root}/unavailable" ]]
}

@test "a short guest write is unavailable even though the upload receipt was clean" {
    lifecycle_mode=upload-short upload_guest_file "${lifecycle_root}" install-archive "${local_input}" /tmp/Koine.zip >/dev/null
    [[ ! -e "${lifecycle_root}/unavailable" ]]
    run download_guest_file "${lifecycle_root}" read-poll archive-identity /tmp/Koine.zip 000001
    [[ "${status}" == 125 && -z "${output//guest evidence unavailable*/}" ]]
    jq -e '.outcome == "unavailable" and (.reason | contains("differ from upload 000001"))' "${lifecycle_root}/000002/result.json"
    [[ -s "${lifecycle_root}/000002/download.bin" && ! -e "${lifecycle_root}/000002/transfer.json" ]]
    assert_latched
}

@test "a local input that changes during the transfer is unavailable and keeps both records" {
    lifecycle_mode=upload-mutate run upload_guest_file "${lifecycle_root}" install-archive "${local_input}" /tmp/Koine.zip
    [[ "${status}" == 125 ]]
    jq -e '.outcome == "unavailable" and (.reason | contains("changed during the transfer"))' "${lifecycle_root}/000001/result.json"
    jq -e '.bytes == 31' "${lifecycle_root}/000001/local-before.json"
    jq -e '.bytes == 59' "${lifecycle_root}/000001/local-after.json"
    [[ ! -e "${lifecycle_root}/000001/transfer.json" ]]
    assert_latched
}

@test "upload schema failures retain raw failure and stop later input" {
    local mode
    for mode in upload-bytes upload-path extra-field dry-run partial error; do
        reset_root "upload-${mode}"
        lifecycle_exit=0
        [[ "${mode}" != error ]] || lifecycle_exit=5
        lifecycle_mode="${mode}" lifecycle_exit="${lifecycle_exit}" run upload_guest_file "${lifecycle_root}" install-archive "${local_input}" /tmp/Koine.zip
        [[ "${status}" == 125 && -z "${output//guest evidence unavailable*/}" ]]
        [[ -s "${lifecycle_root}/000001/raw.stdout" ]]
        jq -e '.outcome == "unavailable" and .emission_status == "not-attempted"' "${lifecycle_root}/000001/result.json"
        [[ ! -e "${lifecycle_root}/000001/transfer.json" ]]
        assert_latched
    done
}

@test "missing symlinked and directory local inputs never dispatch" {
    local kind
    for kind in missing symlink directory; do
        reset_root "local-${kind}"
        local subject="${BATS_TEST_TMPDIR}/subject-${kind}"
        case "${kind}" in
        symlink) ln -s "${local_input}" "${subject}" ;;
        directory) mkdir "${subject}" ;;
        esac
        run upload_guest_file "${lifecycle_root}" install-archive "${subject}" /tmp/Koine.zip
        [[ "${status}" == 125 && "$(calls)" == 0 ]]
        jq -e '.outcome == "unavailable" and .cli_status == null' "${lifecycle_root}/000001/result.json"
        assert_latched
    done
}

@test "download failures latch and never yield a qualified copy" {
    local mode
    for mode in download-bytes download-path download-missing download-symlink download-corrupt; do
        reset_root "download-${mode}"
        upload_guest_file "${lifecycle_root}" install-archive "${local_input}" /tmp/Koine.zip >/dev/null
        lifecycle_mode="${mode}" run download_guest_file "${lifecycle_root}" read-poll archive-identity /tmp/Koine.zip 000001
        [[ "${status}" == 125 && -z "${output//guest evidence unavailable*/}" ]]
        jq -e '.outcome == "unavailable"' "${lifecycle_root}/000002/result.json"
        [[ ! -e "${lifecycle_root}/000002/transfer.json" ]]
        assert_latched
    done
}

@test "download refuses an unmatched upload record and a scenario class before dispatch" {
    upload_guest_file "${lifecycle_root}" install-archive "${local_input}" /tmp/Koine.zip >/dev/null
    run download_guest_file "${lifecycle_root}" read-poll archive-identity /tmp/other.zip 000001
    [[ "${status}" == 125 && "$(calls)" == 1 && ! -e "${lifecycle_root}/000002" ]]
    jq -se 'length == 1 and (.[0].reason | contains("does not name upload"))' "${lifecycle_root}/refusals.jsonl"
    reset_root one-shot-download
    run download_guest_file "${lifecycle_root}" one-shot archive-identity /tmp/Koine.zip
    [[ "${status}" == 2 && "$(calls)" == 0 ]]
    assert_latched
}

@test "evidence-class download remains collection after a latch and keeps the first reason" {
    printf 'guest log\n' >"${lifecycle_guest}/log.txt"
    fail_guest_evidence "${lifecycle_root}" setup 'original failure' || :
    download_guest_file "${lifecycle_root}" evidence collect-log /log.txt >/dev/null
    cmp "${lifecycle_guest}/log.txt" "${lifecycle_root}/000002/download.bin"
    jq -e '.matches_upload == null and .bytes == 10' "${lifecycle_root}/000002/transfer.json"
    [[ "$(cat "${lifecycle_root}/unavailable")" == '000001: original failure' ]]
    run download_guest_file "${lifecycle_root}" read-poll scenario-read /log.txt
    [[ "${status}" == 125 && "$(calls)" == 1 ]]
}

@test "VM start pins the base wait and identity and qualifies the complete start payload" {
    start_guest_vm "${lifecycle_root}" clone-start testanyware-golden-macos-27 >"${BATS_TEST_TMPDIR}/actual"
    cmp "${BATS_TEST_TMPDIR}/actual" "${lifecycle_root}/000001/raw.stdout"
    jq -se '. == [["vm","start","--platform","macos","--wait","--base","testanyware-golden-macos-27","--id","exact-lifecycle-vm","--json"]]' \
        "${lifecycle_calls}"
    jq -e '.transport == "cli" and .class == "one-shot" and (.payload_predicate | contains("exact-lifecycle-vm"))' \
        "${lifecycle_root}/000001/request.json"
    reset_root start-display
    lifecycle_mode=start-tpm start_guest_vm "${lifecycle_root}" clone-start testanyware-golden-macos-27 1920x1080 >/dev/null
    jq -se '.[0][7:9] == ["--display","1920x1080"]' "${lifecycle_calls}"
    [[ ! -e "${lifecycle_root}/unavailable" ]]
}

@test "VM start schema failures are unavailable and stop later input" {
    local mode
    for mode in start-id start-base start-agent start-port start-tpm-invalid extra-field partial; do
        reset_root "start-${mode}"
        lifecycle_mode="${mode}" run start_guest_vm "${lifecycle_root}" clone-start testanyware-golden-macos-27
        [[ "${status}" == 125 ]]
        jq -e '.outcome == "unavailable"' "${lifecycle_root}/000001/result.json"
        assert_latched
    done
}

@test "VM start refuses an implicit base and caller options before dispatch" {
    local n=0
    for args in '' '--viewer' 'base extra 1920x1080' 'base not-a-display'; do
        n=$((n + 1))
        reset_root "start-arguments-${n}"
        # shellcheck disable=SC2086 # Each case is a deliberate word list.
        run start_guest_vm "${lifecycle_root}" clone-start ${args}
        [[ "${status}" == 125 && "$(calls)" == 0 ]]
        jq -e '.transport == "confirmation"' "${lifecycle_root}/000001/request.json"
        assert_latched
    done
}

@test "inventory reads the complete list and decides running and absent from clean data" {
    inventory_guest_vms "${lifecycle_root}" read-poll before-start absent >/dev/null
    start_guest_vm "${lifecycle_root}" clone-start testanyware-golden-macos-27 >/dev/null
    inventory_guest_vms "${lifecycle_root}" read-poll after-start running >/dev/null
    stop_guest_vm "${lifecycle_root}" exact-stop >/dev/null
    inventory_guest_vms "${lifecycle_root}" evidence after-stop absent >/dev/null
    jq -se '[.[] | select(.[0:2] == ["vm","list"])] == [["vm","list","--all","--json"],["vm","list","--all","--json"],["vm","list","--all","--json"]]' \
        "${lifecycle_calls}"
    jq -e '.argv == ["testanyware","vm","stop","exact-lifecycle-vm","--json"] and .class == "evidence"' \
        "${lifecycle_root}/000004/request.json"
    [[ ! -e "${lifecycle_root}/unavailable" ]]
}

@test "an unexpected inventory state or schema is unavailable and never a negative" {
    local mode expect
    for mode in clean list-truncated list-duplicate list-pid list-field extra-field; do
        reset_root "inventory-${mode}"
        printf 'exact-lifecycle-vm\n' >"${lifecycle_state}"
        expect=running
        [[ "${mode}" != clean ]] || expect=absent
        lifecycle_mode="${mode}" run inventory_guest_vms "${lifecycle_root}" evidence check "${expect}"
        [[ "${status}" == 125 ]]
        jq -e '.outcome == "unavailable"' "${lifecycle_root}/000001/result.json"
        assert_latched
    done
}

@test "exact stop is collection after a latch and a failed stop never passes" {
    printf 'exact-lifecycle-vm\n' >"${lifecycle_state}"
    fail_guest_evidence "${lifecycle_root}" setup 'original failure' || :
    stop_guest_vm "${lifecycle_root}" exact-stop >/dev/null
    jq -e '.id == "exact-lifecycle-vm" and .stopped == true' "${lifecycle_root}/000002/raw.stdout"
    [[ "$(cat "${lifecycle_root}/unavailable")" == '000001: original failure' ]]
    local mode
    for mode in stop-false error extra-field; do
        reset_root "stop-${mode}"
        printf 'exact-lifecycle-vm\n' >"${lifecycle_state}"
        lifecycle_exit=0
        [[ "${mode}" != error ]] || lifecycle_exit=1
        lifecycle_mode="${mode}" lifecycle_exit="${lifecycle_exit}" run stop_guest_vm "${lifecycle_root}" exact-stop
        [[ "${status}" == 125 ]]
        jq -e '.outcome == "unavailable"' "${lifecycle_root}/000001/result.json"
        assert_latched
    done
}

@test "upload holds the shared writer lock through the CLI and a competing dispatch refuses" {
    lifecycle_block=1 upload_guest_file "${lifecycle_root}" install-archive "${local_input}" /tmp/Koine.zip >/dev/null &
    local holder=$!
    until [[ -e "${lifecycle_ready}" ]]; do sleep 0.02; done
    run start_guest_vm "${lifecycle_root}" clone-start testanyware-golden-macos-27
    touch "${lifecycle_ready}.release"
    wait "${holder}"
    [[ "${status}" == 125 && "$(calls)" == 1 ]]
    jq -se 'length == 1 and (.[0].reason | contains("competing evidence writer"))' "${lifecycle_root}/refusals.jsonl"
    jq -e '.outcome == "clean"' "${lifecycle_root}/000001/result.json"
}
