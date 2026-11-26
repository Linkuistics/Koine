#!/bin/bash
# Design input only: how the restart reply and the boot reads behave during a
# real guest restart. Two trials on one clone. Not the qualification.
set -uo pipefail
CLI=/opt/homebrew/Cellar/testanyware/3.0.0/bin/testanyware
VM=koine-restart-observe
OUT="$1"
mkdir "${OUT}"
trap '"${CLI}" vm stop "${VM}" >"${OUT}/vm-stop.log" 2>&1' EXIT
"${CLI}" vm start --platform macos --wait --base testanyware-golden-macos-27 --id "${VM}" >"${OUT}/vm-start.log" 2>&1 || exit 1
"${CLI}" file exec --vm "${VM}" -- sw_vers >"${OUT}/system.txt" 2>&1
now() { python3 -c 'import time; print(f"{time.time():.2f}")'; }
call() { # LABEL COMMAND: one JSON exec; prints time, status, code or stdout
    local label="$1" start end status=0 out
    start="$(now)"
    out="$("${CLI}" file exec --vm "${VM}" --json -- "$2" 2>"${OUT}/${label}.stderr")" || status=$?
    end="$(now)"
    printf '%s\n' "${out}" >"${OUT}/${label}.json"
    printf '%s\t%s\t%s\t%s\t%s\n' "${label}" "${start}" "${end}" "${status}" \
        "$(jq -rc 'if .ok then (.stdout // "") else .code end' <<<"${out}" 2>/dev/null || echo unparsed)" |
        tee -a "${OUT}/calls.tsv"
}
for trial in 1 2; do
    call "t${trial}-boot-before" 'sysctl -n kern.boottime'
    call "t${trial}-restart" 'echo admin | sudo -S shutdown -r now'
    for read in $(seq 1 60); do
        sleep 2
        call "t${trial}-boot-${read}" 'sysctl -n kern.boottime'
        if jq -e --slurpfile b "${OUT}/t${trial}-boot-before.json" \
            '.ok and .stdout != $b[0].stdout' "${OUT}/t${trial}-boot-${read}.json" >/dev/null 2>&1; then
            break
        fi
    done
    sleep 10
done
