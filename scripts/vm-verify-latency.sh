#!/bin/bash
# Measures, on the release-configuration signed Koine.app in a clean TestAnyware
# macOS VM and with real applications, the two latencies the spec's "Test seams
# and acceptance" asks for: warm query-to-choices and warm selection-to-focus, in
# the keyboard workflow rather than in a loop over the API.
#
# The workflow is a switch: the user is working in one window, a switcher lists
# an application's choices, the user picks one, and that window takes focus — and
# the next switch starts from where the last one landed. That is what the rotation
# below drives, with real keystrokes into the focused window between switches
# (typing into the TextEdit document, arrow-key navigation in Finder), so that
# every sample follows genuine user activity in a genuinely different window.
# Each sample names the window-server id it must start from and refuses if the
# system is not there (scripts/vm-verify-latency-client.py); refusals and the
# untimed re-establishments that answer them are recorded, never counted.
#
# It is a REPORT, not a target. Nothing here passes or fails on a duration: the
# run fails only when the workflow did not happen. The distribution and the
# supported matrix it also records: docs/verification/latency-and-support-matrix.md
#
# KOINE_LATENCY_CYCLES sets the number of six-switch cycles (default 8, so 48
# counted samples).
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

KOINE_VM_LOG_PREFIX="latency-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh

PROBE="$(Fixtures/WindowIdentityProbe/build.sh .build/probe)"
SAMPLES="${LOG%.log}-samples.jsonl"
CYCLES="${KOINE_LATENCY_CYCLES:-8}"

# Every file this run reads, digested before and after. A measurement whose
# subject moved under it is not a measurement of the thing it reports on, and a
# run's subjects are everything it reads, not only what it executes.
SUBJECTS=(
    "${APP_BUNDLE}/Contents/Info.plist"
    "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
    "${APP_BUNDLE}/Contents/Frameworks/${PROVIDER_FRAMEWORK_NAME}.framework/Versions/A/${PROVIDER_FRAMEWORK_NAME}"
    "${APP_BUNDLE}/Contents/PlugIns/Desktop.koineprovider/libDesktopProvider.dylib"
    "${APP_BUNDLE}/Contents/PlugIns/Desktop.koineprovider/manifest.json"
    docs/design/desktop-operations.graphql
    scripts/vm-verify-latency.sh
    scripts/vm-verify-latency-client.py
    scripts/latency-report.py
    scripts/vm-verify-desktop-client.py
    scripts/vm-verify-lib.sh
    scripts/vm-verify-desktop-lib.sh
    scripts/signing-env.sh
    Fixtures/WindowIdentityProbe/main.swift
    "${PROBE}"
)
digests() { shasum -a 256 "${SUBJECTS[@]}"; }
BEFORE_DIGESTS="$(digests)"

step "The subjects of this measurement, digested before it"
echo "${BEFORE_DIGESTS}"

start_vm
install_app
testanyware file upload scripts/vm-verify-latency-client.py /Users/admin/vm-verify-latency-client.py >/dev/null
testanyware file upload scripts/vm-verify-desktop-client.py /Users/admin/vm-verify-desktop-client.py >/dev/null
testanyware file upload docs/design/desktop-operations.graphql /Users/admin/desktop-operations.graphql >/dev/null
testanyware file upload "${PROBE}" /Users/admin/WindowIdentityProbe >/dev/null
# shellcheck disable=SC2016  # guest-side $HOME
guest 'chmod +x $HOME/WindowIdentityProbe; printf "koine\n" > $HOME/latency-target.txt'
# shellcheck disable=SC2016  # guest-side $HOME, expanded by the guest's shell
PROBE_GUEST='$HOME/WindowIdentityProbe'
# shellcheck disable=SC2016  # guest-side $HOME, expanded by the guest's shell
CLIENT='python3 $HOME/vm-verify-latency-client.py'

step "The machine this is measured on"
guest 'sysctl -n machdep.cpu.brand_string; sysctl -n hw.ncpu; sysctl -n hw.memsize; sw_vers -productVersion; sw_vers -buildVersion; uname -m'
echo "Host: $(sysctl -n hw.model), $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo 'Apple Silicon'), $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
echo "tart/TestAnyware: $(testanyware --version 2>&1 | head -1)"

step "Launch Koine and create the one grant a switcher client holds"
launch
create_grant "vm-latency" "${CREDENTIAL_FILE}" desktop:read desktop:control

step "Real windows: two Finder windows with the same title, and a TextEdit document"
guest "open -a Finder" || true
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 2
testanyware input key n --modifiers cmd >/dev/null
sleep 2
# shellcheck disable=SC2016  # guest-side $HOME
guest 'open -a TextEdit $HOME/latency-target.txt' || true
sleep 4

step "Give Koine Accessibility consent in System Settings"
grant_accessibility

step "The three windows the workflow switches between"
choices Finder
expect '.response.data.desktopApplication.windows | length >= 2 and ([.[].ref] | unique | length) == length' \
    "Finder does not list at least two windows under distinct references"
A="$(jq -r '.response.data.desktopApplication.windows[0].ref' <<<"${ANSWER}")"
B="$(jq -r '.response.data.desktopApplication.windows[1].ref' <<<"${ANSWER}")"
choices TextEdit
expect '.response.data.desktopApplication.windows | length == 1 and .[0].title == "latency-target.txt"' \
    "TextEdit does not list its one document"
T="$(jq -r '.response.data.desktopApplication.windows[0].ref' <<<"${ANSWER}")"

# establish <reference>: focus it without timing anything, and print the
# window-server id the system then reports. This is how the run learns which id
# each reference is, and how it puts the workflow back after a refusal.
ESTABLISHED=""
establish() {
    local out
    out="$(guest_json "${CLIENT} \"${CREDENTIAL_FILE}\" \"${OPERATIONS}\" ${PROBE_GUEST} --establish '$1'")"
    echo "${out}"
    jq -e '(.errors | length) == 0' >/dev/null <<<"${out}" || fail "could not establish focus on $1"
    ESTABLISHED="$(jq -r '.focused.windowId' <<<"${out}")"
    [ "${ESTABLISHED}" != null ] || fail "the witness reported no focused window after establishing $1"
}
step "Which window-server id each reference is, as the system reports it"
establish "${A}"; A_ID="${ESTABLISHED}"
establish "${B}"; B_ID="${ESTABLISHED}"
establish "${T}"; T_ID="${ESTABLISHED}"
[ "${A_ID}" != "${B_ID}" ] || fail "the two Finder references are the same window (${A_ID})"
echo "A = ${A_ID}, B = ${B_ID} (Finder, same title), T = ${T_ID} (TextEdit)"
CURRENT_ID="${T_ID}"

# work <window id>: the user working in the window the last switch landed on.
# Real keystrokes, and the reason this is a keyboard workflow rather than a loop:
# typing into the document, arrow-key navigation in Finder.
work() {
    if [ "$1" = "${T_ID}" ]; then
        testanyware input type "koine " >/dev/null
    else
        testanyware input key down >/dev/null
        sleep 1
        testanyware input key up >/dev/null
    fi
    sleep 2
}

# sample <target reference> <target window id> <application> <class> [--warmup]
# One switch. Refusals are answered by re-establishing the state the switch
# starts from — untimed, recorded, and never counted — and the switch is retried.
sample() {
    local ref="$1" target_id="$2" application="$3" kind="$4" warmup="${5:-}" out tries=0
    while true; do
        out="$(guest_json "${CLIENT} \"${CREDENTIAL_FILE}\" \"${OPERATIONS}\" ${PROBE_GUEST} \
            --application ${application} --ref '${ref}' --class ${kind} \
            --from-window ${CURRENT_ID} ${warmup}")" || out=""
        if [ -n "${out}" ] && jq -e '.ok == true' >/dev/null <<<"${out}"; then break
        fi
        # Only a parseable refusal joins the record; an exec that answered
        # nothing at all is a fact about TestAnyware, and it goes to the
        # transcript rather than into the samples the report reads.
        if [ -n "${out}" ] && jq -e . >/dev/null 2>&1 <<<"${out}"; then
            echo "${out}" | tee -a "${SAMPLES}"
        else
            echo "(the guest answered nothing)"
        fi
        echo "refused or unanswered; re-establishing the window this switch starts from"
        tries=$((tries + 1))
        [ "${tries}" -lt 4 ] || fail "four switches in a row from window ${CURRENT_ID} did not happen"
        establish "${FROM_REF}"
        [ "${ESTABLISHED}" = "${CURRENT_ID}" ] ||
            fail "re-establishing left window ${ESTABLISHED}, not ${CURRENT_ID}"
    done
    echo "${out}" | tee -a "${SAMPLES}"
    jq -e ".after.windowId == ${target_id}" >/dev/null <<<"${out}" ||
        fail "the switch reported a receipt but the system shows window $(jq -r .after.windowId <<<"${out}") focused, not ${target_id}"
    CURRENT_ID="${target_id}"
    FROM_REF="${ref}"
}

step "Warm up: the first resolution of each application and the first focus of each window are never counted"
: >"${SAMPLES}"
FROM_REF="${T}"
sample "${A}" "${A_ID}" Finder cross-application --warmup
work "${A_ID}"
sample "${T}" "${T_ID}" TextEdit cross-application --warmup
work "${T_ID}"

step "${CYCLES} cycles of six switches, with real keystrokes between them"
for cycle in $(seq 1 "${CYCLES}"); do
    echo "-- cycle ${cycle} of ${CYCLES}"
    sample "${A}" "${A_ID}" Finder   cross-application;      work "${A_ID}"
    sample "${B}" "${B_ID}" Finder   same-application-window; work "${B_ID}"
    sample "${T}" "${T_ID}" TextEdit cross-application;      work "${T_ID}"
    sample "${B}" "${B_ID}" Finder   cross-application;      work "${B_ID}"
    sample "${A}" "${A_ID}" Finder   same-application-window; work "${A_ID}"
    sample "${T}" "${T_ID}" TextEdit cross-application;      work "${T_ID}"
done

step "Quit Koine"
quit_koine

step "The subjects, digested again"
AFTER_DIGESTS="$(digests)"
echo "${AFTER_DIGESTS}"
[ "${BEFORE_DIGESTS}" = "${AFTER_DIGESTS}" ] ||
    fail "a file this run read changed while it ran; the measurement is of nothing in particular"

step "The distribution"
scripts/latency-report.py "${SAMPLES}" --per-sample

step "PASSED — this is a report, not a target. Transcript ${LOG}, samples ${SAMPLES}"
