#!/bin/bash
# A bounded probe, not an acceptance. It qualifies the guest restart of the
# shared scenario (scripts/vm-verify-menu-bar.sh) on a real guest, after the
# repairs that accept a lost restart reply (k8) and a cancelled one (k9).
#
# The probe starts its own clone and installs nothing, because the restart does
# not depend on Koine. It makes KOINE_PROBE_TRIALS trials (default 2) in one
# evidence root, with the real backend. Each trial reads the boot record in the
# evidence class, as the scenario's boot-before read does. Then it calls
# restart_guest of scripts/vm-exec-one-shot-evidence-lib.sh unchanged. The
# summary prints, for each trial, the reply of the restart and the boot records
# before and after. The receipts in the evidence root are the evidence. The
# results and their limits: docs/verification/menu-bar-vm.md#the-lost-restart-reply
# and docs/verification/menu-bar-vm.md#the-cancelled-restart-reply
#
# KOINE_TESTANYWARE_CLI and KOINE_JQ are the absolute paths of the testanyware
# and jq executables. KOINE_VM_BASE names the golden image to clone. All three
# are required. KOINE_PROBE_VM names the clone (default
# koine-restart-reply-probe). KOINE_PROBE_TRIALS is a count from 1 to 9.
# KOINE_PROBE_OUT is a new output directory (default under .build/vm-verify).
# The probe stops its clone when it ends, also after a failure.
set -euo pipefail

cd "$(dirname "$0")/.."

CLI="${KOINE_TESTANYWARE_CLI:?set KOINE_TESTANYWARE_CLI to the testanyware executable}"
: "${KOINE_JQ:?set KOINE_JQ to the jq executable}"
BASE="${KOINE_VM_BASE:?set KOINE_VM_BASE to the golden image}"
VM="${KOINE_PROBE_VM:-koine-restart-reply-probe}"
TRIALS="${KOINE_PROBE_TRIALS:-2}"
[[ "${TRIALS}" =~ ^[1-9]$ ]] || {
    echo "set KOINE_PROBE_TRIALS to a count from 1 to 9" >&2
    exit 2
}
OUT="${KOINE_PROBE_OUT:-.build/vm-verify/restart-reply-$(date -u +%Y%m%dT%H%M%SZ)}"
ROOT="${OUT}/evidence"
export KOINE_TESTANYWARE_CLI KOINE_JQ

# shellcheck source=scripts/vm-exec-one-shot-evidence-lib.sh
source scripts/vm-exec-one-shot-evidence-lib.sh

mkdir "${OUT}"
STARTED=""

# stop_clone: the stop of the clone, if the probe started it.
stop_clone() {
    [[ -n "${STARTED}" ]] || return 0
    "${CLI}" vm stop "${VM}" >"${OUT}/vm-stop.log" 2>&1 || :
}
trap stop_clone EXIT

# attempt OPERATION: the attempt directory of the one request with OPERATION.
attempt() {
    grep -l "\"operation\": \"$1\"" "${ROOT}"/[0-9]*/request.json | xargs dirname
}

echo "Start the clone ${VM} from ${BASE}"
"${CLI}" vm start --platform macos --wait --base "${BASE}" --id "${VM}" >"${OUT}/vm-start.log" 2>&1
STARTED=1
"${CLI}" file exec --vm "${VM}" -- sw_vers | tee "${OUT}/system.txt"
"${CLI}" --version | tee "${OUT}/testanyware.txt"
shasum -a 256 scripts/vm-exec-one-shot-evidence-lib.sh scripts/vm-sysevents-evidence-lib.sh \
    scripts/vm-exec-read-evidence-lib.sh scripts/vm-guest-exec.py scripts/vm_exec_reads.py |
    tee "${OUT}/subjects.sha256"
init_guest_evidence "${ROOT}" "${VM}"

printf 'trial\treply\tcli status\tboot before\tboot after\n' >"${OUT}/trials.tsv"
for trial in $(seq 1 "${TRIALS}"); do
    echo "Trial ${trial}: read the boot record, then restart the guest"
    before="$(read_guest_exec "${ROOT}" evidence "boot-before-${trial}" boot)"
    status=0
    after="$(restart_guest "${ROOT}" "restart-${trial}" "${before}")" || status=$?
    restart="$(attempt "restart-${trial}")" || restart=/nonexistent
    reply="$(jq -r 'if .reply == "lost" then "lost (\(.code))" else .reply // "clean" end' \
        "${restart}/read.json" 2>/dev/null || echo unavailable)"
    printf '%s\t%s\t%s\t%s\t%s\n' "${trial}" "${reply}" "$(jq -r '.cli_status' "${restart}/result.json" 2>/dev/null || echo none)" \
        "$(jq -c '[.sec, .usec]' <<<"${before}")" \
        "$( ((status == 0)) && jq -c '[.sec, .usec]' <<<"${after}" || echo "none (status ${status})")" |
        tee -a "${OUT}/trials.tsv"
    if ((status != 0)); then
        echo "FAILED: restart ${trial} exited ${status}; see ${ROOT}" >&2
        exit "${status}"
    fi
done
echo "Trials and receipts: ${OUT}"
