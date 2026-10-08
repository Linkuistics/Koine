# shellcheck shell=bash
# Sourced by the installation VM recipe after its isolated guest and grants are ready.
# Adds k181 subjects; it never calls an application on the host.
# shellcheck disable=SC2016,SC2034  # guest HOME; shared request state

step "Build long copies by components; measure bounded native registration attempts"
testanyware file upload scripts/vm-long-application-fixtures.py /Users/admin/long-apps.py >/dev/null
testanyware file upload scripts/vm-long-location-fixtures.py /Users/admin/vm_long_location_fixtures.py >/dev/null
guest 'mkdir $HOME/long-apps.started 2>/dev/null || exit 0; nohup bash -c "python3 \$HOME/long-apps.py /Users/admin/install-fx \$HOME/paths > \$HOME/long-apps.log 2>&1; echo \$? > \$HOME/long-apps.exit" >/dev/null 2>&1 &' || true
for _ in $(seq 1 90); do
    guest '[ -e $HOME/long-apps.exit ]' >/dev/null 2>&1 && break
    sleep 3
done
[ "$(guest_text 'cat $HOME/long-apps.exit' | tr -d '[:space:]')" = 0 ] || fail "long fixture construction failed: $(guest_text 'cat $HOME/long-apps.log')"
LONG_SUBJECTS="$(guest_text 'cat $HOME/paths/long-applications.json')"
printf '%s\n' "${LONG_SUBJECTS}" >"${OUT_DIR}/subjects.json"
echo "Native registration attempts: $(jq -c '.attempts' <<<"${LONG_SUBJECTS}")"
record --argjson subjects "${LONG_SUBJECTS}" '{section: "registration", case: "component-created long copies and native registration attempts", status: "recorded", observed: $subjects}'

short_observation() {
    printf 'include "application-location-observations"; short_workflow("%s"; "%s"; "/Users/admin/install-fx/docs/note-1.koineinstall")' "$1" "$2"
}

step "Independent delivery control: the fixture receives the exact 1,023-byte document"
quit_fixtures

guest 'rm -f $HOME/install-fixture.jsonl; date +%s > $HOME/control-sent.txt; open -n -a /Users/admin/install-fx/A/Fixture.app "$(cat $HOME/paths/doc-control.txt)"' || true
CONTROL_LOG=""
for _ in $(seq 1 30); do
    CONTROL_LOG="$(guest_text 'cat $HOME/install-fixture.jsonl 2>/dev/null')"
    if jq -se 'any(.[]; .event == "open" and (.path | utf8bytelength) == 1023)' >/dev/null <<<"${CONTROL_LOG}"; then
        break
    fi
    sleep 2
done
CONTROL_PATH="$(guest_text 'cat $HOME/paths/doc-control.txt')"
jq -se --arg p "${CONTROL_PATH}" 'any(.[]; .event == "open" and .path == $p and .label == "A")' >/dev/null <<<"${CONTROL_LOG}" ||
    fail "the independent route did not control the delivery observer at 1,023 bytes"
CONTROL_SENT="$(($(guest_text 'cat $HOME/control-sent.txt') * 1000))"
jq -se --argjson sent "${CONTROL_SENT}" --arg p "${CONTROL_PATH}" 'any(.[]; .event == "open" and .path == $p and .atMs >= $sent and .atMs - $sent < 20000)' >/dev/null <<<"${CONTROL_LOG}" || fail "control took 20 seconds or more; refusal observation bound needs adjustment"
if jq -se --arg p "${CONTROL_PATH}.not-delivered" 'any(.[]; .event == "open" and .path == $p and .label == "A")' >/dev/null <<<"${CONTROL_LOG}"; then fail "delivery observer accepted a wrong-path mutation"; fi
record --argjson sent "${CONTROL_SENT}" --argjson log "$(jq -s . <<<"${CONTROL_LOG}")" '{section: "control", case: "independent 1023-byte document delivery", status: "passed", controlSentMs: $sent, wrongPathMutationRejected: true, log: $log}'
quit_fixtures

# Refused requests wait a minute, longer than the persistent control's effect took.
REQUEST_ENV="KOINE_INSTALLATION_NO_EFFECT_WAIT=60"
for length in 1024 1500; do
    LONG_PATH="$(jq -r --argjson n "${length}" '.subjects[] | select(.bytes == $n) | .path' <<<"${LONG_SUBJECTS}")"
    for kind in launch open; do
        for running in cold running; do
            quit_fixtures
            if [ "${running}" = running ]; then
                request launch "${ID}" app-A - yes
                jq -L scripts -e "$(short_observation A launch)" >/dev/null <<<"${OBS}" || fail "short running-copy precondition failed"
            fi
            case_begin "${kind}: ${length}-byte constrained application, ${running}; no substitution"
            request "${kind}" "${ID}" "app-long-${length}" doc-1 no
            check "${FAILED}" "not failed with no delivery or process change"
            check "$(jq -nr --arg p "${LONG_PATH}" --argjson n "${length}" --arg kind "${kind}" '
                "include \"application-refusal-observations\"; supplied_refusal(" + ($n | tostring) + "; " + ($kind | tojson) + "; " + ($p | tojson) + ")"')" \
                "literal selector, guidance, receipt or no-effect observation differs"
            check '.answer.dependency == null' "failure invented a dependency"
            case_end application-locations
        done
    done
done
REQUEST_ENV=""

step "Short workflows beside the long copies, with actual registration recorded"
REGISTRATION_LONG="$(registration "${ID}")"
echo "Current native registration: ${REGISTRATION_LONG}"
LONG_REGISTERED=0
for length in 1024 1500; do
    LONG_PATH="$(jq -r --argjson n "${length}" '.subjects[] | select(.bytes == $n) | .path' <<<"${LONG_SUBJECTS}")"
    if grep -F "${LONG_PATH}" >/dev/null <<<"${REGISTRATION_LONG}"; then LONG_REGISTERED=1; fi
done
for copy in A B; do
    for kind in launch open; do
        quit_fixtures
        case_begin "${kind}: constrained short ${copy} beside long copies on disk"
        request "${kind}" "${ID}" "app-${copy}" doc-1 yes
        check "${ACK}" "short workflow was not acknowledged"
        check "$(short_observation "${copy}" "${kind}")" "wrong physical copy, kernel receipt or document delivery"
        case_end application-locations
    done
done
PREFERRED_LONG="$(cut -f2 <<<"${REGISTRATION_LONG}")"
case "${PREFERRED_LONG}" in
    */A/Fixture.app) SHORT_PREFERRED=A ;;
    */B/Fixture.app) SHORT_PREFERRED=B ;;
    *) SHORT_PREFERRED="" ;;
esac
if [ -n "${SHORT_PREFERRED}" ]; then
    for kind in launch open; do
        quit_fixtures
        case_begin "${kind}: unconstrained short preferred ${SHORT_PREFERRED} beside long copies on disk"
        request "${kind}" "${ID}" - doc-1 yes
        check "${ACK}" "short preferred workflow was not acknowledged"
        check "$(short_observation "${SHORT_PREFERRED}" "${kind}")" "wrong physical copy, kernel receipt or document delivery"
        case_end application-locations
    done
    record '{section: "registration", case: "preferred long copy refusal, cold and with a short copy running", status: "pending", notes: "The measured native preferred copy is short. Selected-short successes cannot pass this subject."}'
else
    record '{section: "registration", case: "preferred long copy refusal and short preferred successes", status: "pending", notes: "Registration state needs a dedicated continuation; no result is inferred from earlier snapshots."}'
fi
if [ "${LONG_REGISTERED}" = 0 ]; then
    record --arg r "${REGISTRATION_LONG}" '{section: "registration", case: "short selected beside registered long copy in both enumeration orders", status: "pending", registration: $r, notes: "None of six bounded attempts made NSWorkspace report the long spelling. Disk-only short successes do not pass registered-long subjects."}'
else
    record --arg r "${REGISTRATION_LONG}" '{section: "registration", case: "both enumeration orders with a registered long copy", status: "pending", registration: $r, notes: "Both actual orders must still be measured, not inferred from registration invocation order."}'
fi
quit_fixtures

step "Finder selection control at 1,023 bytes, then a short reveal beside long copies"
testanyware file upload scripts/vm-reveal-observe.applescript /Users/admin/finder-observe.applescript >/dev/null
# shellcheck source=scripts/vm-finder-observer-lib.sh
source scripts/vm-finder-observer-lib.sh
allow_observer
close_finder_windows
guest 'open -R "$(cat $HOME/paths/doc-control.txt)"' || true
for _ in $(seq 1 40); do
    observe
    jq -e --arg p "${CONTROL_PATH}" 'any(.selected[]; .path == $p)' >/dev/null <<<"${OBS}" && break
    sleep 2
done
jq -e --arg p "${CONTROL_PATH}" 'any(.selected[]; .path == $p)' >/dev/null <<<"${OBS}" || fail "Finder observer did not see the 1023-byte independent control"
record --argjson f "${OBS}" '{section: "control", case: "independent 1023-byte Finder selection", status: "passed", finder: $f}'
close_finder_windows
put_other_in_front
request reveal - - doc-1 no
expect '.classification == "ok" and .status == "AVAILABLE" and .dependency == null and ((.errors // []) | length == 0)' "short reveal beside long copies was not acknowledged"
REVEAL_REQUEST="${OBS}"
for _ in $(seq 1 40); do
    observe
    jq -e 'any(.selected[]; .path == "/Users/admin/install-fx/docs/note-1.koineinstall")' >/dev/null <<<"${OBS}" && break
    sleep 2
done
jq -e 'any(.selected[]; .path == "/Users/admin/install-fx/docs/note-1.koineinstall")' >/dev/null <<<"${OBS}" || fail "short reveal did not select its target"
record --argjson f "${OBS}" --argjson request "${REVEAL_REQUEST}" '{section: "application-locations", case: "short reveal finds Finder beside long copies", status: "passed", finder: $f, observed: $request}'
section_dialogs application-locations
