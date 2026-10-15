# shellcheck shell=bash
# Sourced by the installation VM recipe; effects stay in its disposable guest.
# shellcheck disable=SC2016,SC2034

step "Build physical long copies without repeating previous registration routes"
testanyware file upload scripts/vm-long-application-fixtures.py /Users/admin/long-apps.py >/dev/null
testanyware file upload scripts/vm-long-location-fixtures.py /Users/admin/vm_long_location_fixtures.py >/dev/null
testanyware file upload scripts/vm-prefix-registration.py /Users/admin/vm_prefix_registration.py >/dev/null
guest 'mkdir $HOME/long-apps.started 2>/dev/null || exit 0; nohup bash -c "python3 \$HOME/long-apps.py /Users/admin/install-fx \$HOME/paths --no-registration > \$HOME/long-apps.log 2>&1; echo \$? > \$HOME/long-apps.exit" >/dev/null 2>&1 &' || true
for _ in $(seq 1 90); do
    testanyware file download /Users/admin/long-apps.exit "${OUT_DIR}/long-apps.exit" >/dev/null 2>&1 && break
    sleep 3
done
[ "$(tr -d '[:space:]' <"${OUT_DIR}/long-apps.exit")" = 0 ] || fail "long construction failed: $(guest_text 'cat $HOME/long-apps.log')"
# The mutating builder/state commands take one guard per invocation: exec retries
# cannot create another link, unregister again or perturb the observed order.
guest 'mkdir $HOME/prefix-build.started 2>/dev/null || exit 0; python3 $HOME/vm_prefix_registration.py build $HOME/paths /Users/admin/install-fx > $HOME/prefix-fixtures.json' || true
testanyware file download /Users/admin/prefix-fixtures.json "${OUT_DIR}/subjects.json" >/dev/null
PREFIX_FIXTURES="$(cat "${OUT_DIR}/subjects.json")"
jq -e '.routes | length == 2' >/dev/null <<<"${PREFIX_FIXTURES}" || fail "prefix construction failed"
printf '%s\n' "${PREFIX_FIXTURES}" >"${OUT_DIR}/subjects.json"
record --argjson o "${PREFIX_FIXTURES}" '{section: "prefix-registration", case: "one prefix route per physical length", status: "recorded", observed: $o}'

step "Control exact 1,023-byte delivery independently before any measured request"
quit_fixtures
guest 'rm -f $HOME/install-fixture.jsonl; date +%s > $HOME/control-sent.txt; open -n -a /Users/admin/install-fx/A/Fixture.app "$(cat $HOME/paths/doc-control.txt)"' || true
CONTROL_PATH="$(guest_text 'cat $HOME/paths/doc-control.txt')"
CONTROL_LOG=""
for _ in $(seq 1 30); do
    CONTROL_LOG="$(guest_text 'cat $HOME/install-fixture.jsonl 2>/dev/null')"
    jq -se --arg p "${CONTROL_PATH}" 'any(.[]; .event == "open" and .path == $p)' >/dev/null <<<"${CONTROL_LOG}" && break
    sleep 2
done
CONTROL_SENT="$(($(guest_text 'cat $HOME/control-sent.txt') * 1000))"
jq -se --arg p "${CONTROL_PATH}" --argjson sent "${CONTROL_SENT}" 'any(.[]; .event == "open" and .path == $p and (.path | utf8bytelength) == 1023 and .label == "A" and .bundlePath == "/Users/admin/install-fx/A/Fixture.app" and .atMs >= $sent and .atMs - $sent < 20000)' >/dev/null <<<"${CONTROL_LOG}" || fail "delivery observer not controlled within 20 seconds"
record --argjson o "$(jq -s . <<<"${CONTROL_LOG}")" '{section: "control", case: "independent exact 1023-byte delivery", status: "passed", observed: $o}'
quit_fixtures

prefix_done() {
    jq -se --arg c "$1" 'any(.[]; .case == $c and (.status == "passed" or .status == "failed"))' "${RESULTS}" >/dev/null
}
prefix_request() {
    local name="$1" kind="$2" copy="$3" predicate="$4" outcome="$5"
    prefix_done "${name}" && return 0
    quit_fixtures
    case_begin "${name}"
    REQUEST_ENV="KOINE_PREFIX_REGISTRATION=1"
    [ "${outcome}" != no ] || REQUEST_ENV="${REQUEST_ENV} KOINE_INSTALLATION_NO_EFFECT_WAIT=60"
    request "${kind}" "${ID}" "${copy}" doc-1 "${outcome}"
    if ! jq -L scripts -e "include \"prefix-registration-observations\"; ${predicate}" >/dev/null <<<"${OBS}"; then
        CASE_STATUS=pending
        CASE_NOTES="Request-local native precondition differs; no acceptance inferred."
    elif [ "${outcome}" = yes ]; then
        check "include \"application-location-observations\"; short_workflow(\"${copy#app-}\"; \"${kind}\"; \"/Users/admin/install-fx/docs/note-1.koineinstall\")" "short copy, document or kernel receipt differs"
    else
        check '(.before | length == 0) and (.procsBefore | length == 0)' "cold precondition differs"
        check "include \"prefix-registration-observations\"; discovered_refusal(${length}; \"${kind}\")" "preferred-long guidance or no-substitution differs"
    fi
    case_end prefix-actions
}

for length in 1024 1500; do
    for order in ABL ALB BAL BLA LAB LBA; do
        quit_fixtures
        step "Public registration matrix: ${length} bytes, invocation order ${order}"
        guest "mkdir \$HOME/state-${length}-${order}.started 2>/dev/null || exit 0; nohup bash -c 'python3 \$HOME/vm_prefix_registration.py state \$HOME/paths ${length} ${order} > \$HOME/state-${length}-${order}.json 2> \$HOME/state-${length}-${order}.log; echo \$? > \$HOME/state-${length}-${order}.exit' >/dev/null 2>&1 &" || true
        for _ in $(seq 1 90); do
            testanyware file download "/Users/admin/state-${length}-${order}.exit" "${OUT_DIR}/state-${length}-${order}.exit" >/dev/null 2>&1 && break
            sleep 3
        done
        [ "$(tr -d '[:space:]' <"${OUT_DIR}/state-${length}-${order}.exit")" = 0 ] || fail "matrix state failed: $(guest_text "cat \$HOME/state-${length}-${order}.log")"
        testanyware file download "/Users/admin/state-${length}-${order}.json" "${OUT_DIR}/state-${length}-${order}.json" >/dev/null
        MATRIX_STATE="$(cat "${OUT_DIR}/state-${length}-${order}.json")"
        record --argjson o "${MATRIX_STATE}" --arg c "${length}/${order}" '{section: "prefix-registration", case: $c, status: "recorded", observed: $o}'
        echo "Actual native state: $(jq -c '.snapshot | {preferred, listed}' <<<"${MATRIX_STATE}")"
        for copy in A B; do
            for direction in before after; do
                predicate="registered_order(${length}; \"${copy}\"; \"${direction}\")"
                if jq -L scripts -e "include \"prefix-registration-observations\"; {nativeSelectionBefore: .snapshot} | ${predicate}" >/dev/null <<<"${MATRIX_STATE}"; then
                    for kind in launch open; do
                        prefix_request "${length}/${direction}/${copy}/${kind}" "${kind}" "app-${copy}" "${predicate}" yes
                    done
                fi
            done
            if jq -L scripts -e "include \"prefix-registration-observations\"; {nativeSelectionBefore: .snapshot} | registered_order(${length}; \"${copy}\"; \"before\") or registered_order(${length}; \"${copy}\"; \"after\") | ." >/dev/null <<<"${MATRIX_STATE}" &&
                jq -L scripts -e "include \"prefix-registration-observations\"; {nativeSelectionBefore: .snapshot} | preferred_short(\"${copy}\")" >/dev/null <<<"${MATRIX_STATE}"; then
                for kind in launch open; do
                    # The expected copy is used only by the observer; the selector is unconstrained.
                    name="${length}/short-preferred/${kind}"
                    if ! prefix_done "${name}"; then
                        quit_fixtures
                        case_begin "${name}"
                        REQUEST_ENV="KOINE_PREFIX_REGISTRATION=1"
                        request "${kind}" "${ID}" - doc-1 yes
                        if jq -L scripts -e "include \"prefix-registration-observations\"; preferred_short(\"${copy}\") and (registered_order(${length}; \"${copy}\"; \"before\") or registered_order(${length}; \"${copy}\"; \"after\"))" >/dev/null <<<"${OBS}"; then
                            check "include \"application-location-observations\"; short_workflow(\"${copy}\"; \"${kind}\"; \"/Users/admin/install-fx/docs/note-1.koineinstall\")" "short preferred receipt or delivery differs"
                        else
                            CASE_STATUS=pending
                            CASE_NOTES="Request-local short preference/registration changed; no acceptance inferred."
                        fi
                        case_end prefix-actions
                    fi
                done
            fi
        done
        if jq -L scripts -e "include \"prefix-registration-observations\"; {nativeSelectionBefore: .snapshot} | preferred_long(${length})" >/dev/null <<<"${MATRIX_STATE}"; then
            for kind in launch open; do
                prefix_request "${length}/preferred-long/cold/${kind}" "${kind}" - "preferred_long(${length})" no
                name="${length}/preferred-long/running/${kind}"
                if ! prefix_done "${name}"; then
                    quit_fixtures
                    REQUEST_ENV="KOINE_PREFIX_REGISTRATION=1"
                    request launch "${ID}" app-A - yes
                    jq -L scripts -e 'include "application-location-observations"; short_workflow("A"; "launch"; "")' >/dev/null <<<"${OBS}" || fail "short running-copy precondition failed"
                    RUNNING_PROCESS="$(jq -c .answer.process <<<"${OBS}")"
                    case_begin "${name}"
                    REQUEST_ENV="KOINE_PREFIX_REGISTRATION=1 KOINE_INSTALLATION_NO_EFFECT_WAIT=60"
                    request "${kind}" "${ID}" - doc-1 no
                    if jq -L scripts --argjson process "${RUNNING_PROCESS}" -e "include \"prefix-registration-observations\"; preferred_long(${length}) and running_short(\$process)" >/dev/null <<<"${OBS}"; then
                        check "include \"prefix-registration-observations\"; discovered_refusal(${length}; \"${kind}\")" "running short substituted, guidance or effect differs"
                    else
                        CASE_STATUS=pending
                        CASE_NOTES="Request-local long preference or exact running short incarnation unavailable; no preferred-long acceptance."
                    fi
                    case_end prefix-actions
                fi
            done
        fi
    done
done
REQUEST_ENV=""
quit_fixtures
# Finder's own selection observer is independently controlled at the admitted
# boundary, then paired with request-local registration for the short reveal.
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
jq -e --arg p "${CONTROL_PATH}" 'any(.selected[]; .path == $p)' >/dev/null <<<"${OBS}" || fail "Finder observer not controlled"
record --argjson o "${OBS}" '{section: "control", case: "independent 1023-byte Finder selection", status: "passed", observed: $o}'
close_finder_windows
REQUEST_ENV="KOINE_PREFIX_REGISTRATION=1"
request reveal - - doc-1 no
REVEAL_REQUEST="${OBS}"
expect '.classification == "ok" and .status == "AVAILABLE" and .dependency == null and ((.errors // []) | length == 0)' "short reveal failed"
for _ in $(seq 1 40); do
    observe
    jq -e 'any(.selected[]; .path == "/Users/admin/install-fx/docs/note-1.koineinstall")' >/dev/null <<<"${OBS}" && break
    sleep 2
done
jq -e 'any(.selected[]; .path == "/Users/admin/install-fx/docs/note-1.koineinstall")' >/dev/null <<<"${OBS}" || fail "short reveal selection differs"
REVEAL_STATUS=pending
if jq -e 'any(.nativeSelectionBefore.listed[]; .knownPhysicalPath != null and .expandedBytes >= 1024)' >/dev/null <<<"${REVEAL_REQUEST}"; then
    REVEAL_STATUS=passed
fi
record --arg st "${REVEAL_STATUS}" --argjson request "${REVEAL_REQUEST}" --argjson f "${OBS}" '{section: "prefix-actions", case: "short reveal beside registered long copy", status: $st, observed: $request, finder: $f, notes: "Only request-local native registration can pass this row."}'
REQUEST_ENV=""
# Enumerate obligations rather than inferring coverage from totals.
for length in 1024 1500; do
    for copy in A B; do
        for direction in before after; do
            for kind in launch open; do
                name="${length}/${direction}/${copy}/${kind}"
                prefix_done "${name}" || record --arg c "${name}" '{section: "prefix-actions", case: $c, status: "pending", notes: "The bounded matrix did not supply a request-local native precondition."}'
            done
        done
    done
    for kind in launch open; do
        for subject in short-preferred preferred-long/cold preferred-long/running; do
            name="${length}/${subject}/${kind}"
            prefix_done "${name}" || record --arg c "${name}" '{section: "prefix-actions", case: $c, status: "pending", notes: "Required native selection unavailable in the bounded matrix."}'
        done
    done
done
section_dialogs prefix-registration
