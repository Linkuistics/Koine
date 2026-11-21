#!/usr/bin/env bats
# Each checked read runs its real command on this host through /bin/bash -c,
# as the tagged agent runs it in a guest. The fixture strips trailing
# whitespace as the agent does. This tests the grammars against real macOS
# output. It is host evidence, not guest evidence. It needs an installed
# /Applications/Koine.app. The assessment read is excluded, because spctl -a
# writes the assessment cache. The port read targets port 1 only.

setup() {
    bats_require_minimum_version 1.5.0
    # shellcheck source=scripts/vm-exec-read-evidence-lib.sh
    source "${BATS_TEST_DIRNAME}/../../scripts/vm-exec-read-evidence-lib.sh"
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
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
    [[ -d /Applications/Koine.app ]] || {
        echo 'host grammar evidence needs /Applications/Koine.app' >&2
        return 1
    }
}

@test "every state-free read parses the real output of this host" {
    local root="${BATS_TEST_TMPDIR}/host" ordinal=0 request
    init_guest_evidence "${root}" host-grammar
    for request in 'endpoint' 'process executable' 'process bundle' 'boot' 'defaults' \
        'installed-inventory' 'system' 'gatekeeper' 'quarantine' 'signature' 'signature-display'; do
        ordinal=$((ordinal + 1))
        read -r -a words <<<"${request}"
        read_guest_exec "${root}" evidence "host-${words[0]}" "${words[@]}" >/dev/null
        jq -e --arg name "${words[0]}" '.read == $name' "${root}/$(printf '%06d' "${ordinal}")/read.json"
    done
    read_guest_exec "${root}" read-poll host-port port-refusal 1 >/dev/null
    jq -e '.curl_exit == 7' "${root}/000012/read.json"
    jq -e '.valid == true' "${root}/000010/read.json"
    jq -e '(.files | length) > 0' "${root}/000006/read.json"
    [[ ! -e "${root}/unavailable" ]]
    for record in "${root}"/0000*/read.json; do
        printf '%s %s\n' "$(jq -r .read "${record}")" "$(jq -c 'del(.files, .symlinks, .text, .user)' "${record}" | cut -c1-240)"
    done
}

@test "a selected process that exits before ps makes the real process read unavailable" {
    # The pgrep stub replays one selection. The ps reads and the parser are real.
    local root="${BATS_TEST_TMPDIR}/membership" live other gone
    /bin/sleep 30 3>&- &
    live=$!
    /bin/sleep 30 3>&- &
    other=$!
    sleep 0 &
    gone=$!
    wait "${gone}" || true
    printf '#!/bin/bash\nprintf "%%s\\n" %s\n' "${live} ${gone}" >"${BATS_TEST_TMPDIR}/bin/pgrep"
    chmod +x "${BATS_TEST_TMPDIR}/bin/pgrep"
    init_guest_evidence "${root}" host-membership
    run read_guest_exec "${root}" evidence one-gone process executable
    echo "diagnostic: status=${status} output=${output} gone=${gone}"
    [[ "${status}" == 125 && ! -e "${root}/000001/read.json" && -e "${root}/unavailable" ]]
    # Both selected processes alive: a clean record of two real ps rows.
    root="${BATS_TEST_TMPDIR}/membership-live"
    printf '#!/bin/bash\nprintf "%%s\\n" %s\n' "${live} ${other}" >"${BATS_TEST_TMPDIR}/bin/pgrep"
    init_guest_evidence "${root}" host-membership-live
    read_guest_exec "${root}" evidence both-live process executable >/dev/null
    kill "${live}" "${other}" 2>/dev/null || true
    jq -e --argjson live "${live}" --argjson other "${other}" '.selected == [$live, $other]
        and ([.processes[].pid] | sort) == ([$live, $other] | sort)
        and all(.processes[]; .argv0 == "/bin/sleep" and .arguments == "/bin/sleep 30")' "${root}/000001/read.json"
}

@test "an any-user diagnostic default reaches the real defaults read" {
    # The defaults stub answers only the any-user application domain. Every
    # other export, the managed checks and the parser are real.
    local root="${BATS_TEST_TMPDIR}/any-user"
    cat >"${BATS_TEST_TMPDIR}/bin/defaults" <<'STUB'
#!/bin/bash
if [[ "$*" == "export /Library/Preferences/dev.antony.Koine -" ]]; then
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<plist version="1.0">\n<dict>\n<key>KoineSettingsActivationTrace</key><string>/tmp/t</string>\n</dict>\n</plist>\n'
    exit 0
fi
exec /usr/bin/defaults "$@"
STUB
    chmod +x "${BATS_TEST_TMPDIR}/bin/defaults"
    init_guest_evidence "${root}" host-any-user
    run read_guest_exec "${root}" evidence any-user defaults
    echo "diagnostic: status=${status} output=${output}"
    [[ "${status}" == 0 ]]
    jq -e '.diagnostics_disabled == false and ([.sources[]
        | select(.keys.KoineSettingsActivationTrace == "/tmp/t") | .source] == ["/Library/Preferences/dev.antony.Koine"])' \
        "${root}/000001/read.json"
}
