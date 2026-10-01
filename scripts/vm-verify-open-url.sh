#!/bin/bash
# Verifies, on the signed Koine.app in a clone of the prepared launcher image
# (scripts/vm-prepare-launchers.sh, docs/verification/launcher-apps-vm.md: Gatekeeper
# ENFORCING, Safari the default browser, Dia installed and past its first run), that
# workspaceOpenURL under workspace:control AND desktop:control, and no read capability,
# opens a client-built URL in the DEFAULT browser, first with Safari the default and then
# with an alternate default, as the contract-only client (clients/contract-only) asks for
# it, with Accessibility never granted to Koine. The alternates are Dia, the named one, and a
# test browser (Fixtures/UrlBrowser) that the system treats as a browser and that records
# exactly the URLs it is handed. Dia cannot load a page in this image: its first run stops at
# an account gate that is never passed (docs/verification/launcher-apps-vm.md), so for Dia the
# run observes the delivery (acknowledgment, activation, the receipt equal to the kernel's
# identity, no other application receiving the URL) and records the page load as pending the
# account decision, which is Antony's.
#
# What the browser was asked to open is never inferred from Koine's acknowledgment. A
# page server in the guest (scripts/vm-url-witness-server.mjs, no Koine code) records the
# request-target and Host header exactly as the browser sent them, and the page it serves
# reports the browser's own `location.href`, hostname and fragment back, which is the only
# way the fragment (never sent to a server) is seen. Fixtures/LaunchWitness, an independent
# signed tool, reports who is in front, which instances run, the kernel's start instant of
# each, and every launch and activation, on the guest's clock.
#
# For each browser (Safari, the test browser, Dia), the page server and the witness above being
# the browser's own account of what it was handed (Safari: its page; the test browser: its log
# of the delivered strings; Dia: delivery only):
#   * an encoded path, query and fragment (cold browser, then warm), reaching the page byte
#     for byte as submitted;
#   * an ASCII IDNA host (xn--bcher-kva.test), seen as that host by the page server;
#   * a universal-link candidate (https://maps.apple.com/...): the browser must be the first
#     application to receive it from Koine (a plain `open` is recorded beside it; this image
#     cannot show the system's own dispatch diverting it, so the case does not by itself
#     discriminate the scheme-only lookup, which task check:launch-call-path inspects);
#   * the client's search flow with a suggestion source that refuses the connection and with
#     one that never answers: the typed-query URL is still opened, once.
# And once, with Safari the default: invalid escapes, raw Unicode, whitespace, backslashes,
# credentials and other schemes refused at the original path with nothing repaired or
# opened; either control alone and a revoked grant refused with nothing opened; the default
# Google search template's URL opened, with Koine's network system calls recorded from
# before the first open (fs_usage; the stronger packet-level check is
# scripts/vm-verify-network.sh); and Accessibility absent throughout.
#
# Nothing here runs an application on the host. The procedure and its recorded evidence:
# docs/verification/open-url-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
# KOINE_LAUNCHERS_IMAGE is the prepared image (default koine-launchers-prepared).
# KOINE_OPEN_URL_ONLY=<text>[,<text>...] runs only the sections whose name contains one of the
#   texts (Safari, UrlBrowser, Dia, refus), for iterating on a section.
# Exit status: 0 every case passed; 1 a case failed; 3 nothing failed but something is
# pending: an acknowledged open the witness did not see activate, or Dia's page load (the
# account gate), which go to Antony.
# shellcheck disable=SC2016  # guest-side $HOME
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

IMAGE="${KOINE_LAUNCHERS_IMAGE:-koine-launchers-prepared}"
tart list --quiet 2>/dev/null | grep -qx "${IMAGE}" || {
    echo "Error: no prepared image ${IMAGE}. Run: task launchers:prepare" >&2
    exit 1
}
KOINE_VM_BASE="${IMAGE}"
KOINE_VM_LOG_PREFIX="open-url-vm-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-launchers-lib.sh
source scripts/vm-launchers-lib.sh
# shellcheck source=scripts/vm-verify-contract-client-lib.sh
source scripts/vm-verify-contract-client-lib.sh

BUNDLE="clients/contract-only/dist/koine-client.mjs"
[ -f "${BUNDLE}" ] || { echo "Error: ${BUNDLE} does not exist. Run: task client" >&2; exit 1; }

# Everything this run reads or runs, digested now and again at the end: a run whose subjects
# changed under it (the script itself included, which the shell reads as it goes) measured
# nothing, and says so.
SUBJECTS=(scripts/vm-verify-open-url.sh scripts/vm-url-witness-server.mjs Fixtures/UrlBrowser/main.swift Fixtures/UrlBrowser/build.sh scripts/vm-verify-witness-lib.sh scripts/vm-verify-contract-client-lib.sh
    scripts/vm-verify-launch-lib.sh scripts/vm-launchers-lib.sh scripts/vm-default-browser.swift "${BUNDLE}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}")
subjects_digest() { shasum -a 256 "${SUBJECTS[@]}"; }
SUBJECTS_BEFORE="$(subjects_digest)"
echo "Subjects of this run:"
echo "${SUBJECTS_BEFORE}"

OTHER="TextEdit"
MAPS_ID="com.apple.Maps"
SAFARI_ID="com.apple.Safari"
DIA_ID="company.thebrowser.dia"
DIA_PATH="/Applications/Dia.app"
TEST_ID="dev.koine.test.UrlBrowser"
TEST_PATH="/Users/admin/Applications/UrlBrowser.app"
HOST="koine-url.test"
IDNA_HOST="xn--bcher-kva.test"
PORT=8765
BASE="http://${HOST}:${PORT}"
# The witness' watch log, the page server's log, the grants' secrets and the URL files.
{
    WATCH='$HOME/watch.jsonl'
    SERVER_LOG='$HOME/url-witness.jsonl'
    BOTH='$HOME/koine-secret-both'
    WORKSPACE_ONLY='$HOME/koine-secret-workspace'
    DESKTOP_ONLY='$HOME/koine-secret-desktop'
    REVOKED='$HOME/koine-secret-revoked'
    MANAGER='$HOME/koine-secret-manager'
    URLS='$HOME/urls'
    BROWSER_LOG='$HOME/url-browser.jsonl'
}
# shellcheck source=scripts/vm-verify-launch-lib.sh
source scripts/vm-verify-launch-lib.sh
# shellcheck source=scripts/vm-verify-witness-lib.sh
source scripts/vm-verify-witness-lib.sh

NODE_ARCHIVE="$(scripts/stage-node-runtime.sh)"
WITNESS_BIN="$(Fixtures/LaunchWitness/build.sh .build/witness)"
URL_BROWSER="$(Fixtures/UrlBrowser/build.sh .build/url-browser)"
RESULTS="${WORK}/results.jsonl"
: >"${RESULTS}"
OUT_DIR=".build/open-url-vm"
mkdir -p "${OUT_DIR}"

# --- the URL files: the exact bytes each case submits -------------------------------
# One file per URL, carried into the guest in one archive and read there with
# --url-file, so that no shell, exec channel or terminal can repair, trim or re-encode
# what is sent. A trailing newline would be part of the submission, so none is written
# unless the case is about one.
mkdir -p "${WORK}/urls"
url_file() { printf '%s' "$2" >"${WORK}/urls/$1.txt"; }
url_file encoded "${BASE}/search/a%20b?q=caf%C3%A9+%E6%97%A5%E6%9C%AC&x=%26%23%25&e=%3D#frag%20ment-%C3%A9"
url_file encoded-warm "${BASE}/second/%E6%97%A5?k=%2B%2F%3F&v=a%20b#%E2%9C%93-frag"
url_file idna "http://${IDNA_HOST}:${PORT}/idna?label=b%C3%BCcher#top"
url_file universal "https://maps.apple.com/?q=Koine%20URL%20acceptance"
# Refused, each class by its own bytes.
url_file bad-escape-letters "${BASE}/a%zz"
url_file bad-escape-truncated "${BASE}/a%2"
url_file bad-escape-query "${BASE}/?q=%G1"
url_file unicode-path "${BASE}/café"
url_file unicode-query "${BASE}/?q=日本"
url_file unicode-host "http://bücher.test:${PORT}/"
url_file space "${BASE}/a b"
url_file leading-space " ${BASE}/"
url_file trailing-newline "${BASE}/
"
url_file tab "${BASE}/a	b"
url_file control "${BASE}/a"$'\001'"b"
url_file backslash-path "${BASE}/a\\b"
url_file backslash-authority "http://${HOST}:${PORT}\\a"
url_file credentials "http://user:secret@${HOST}:${PORT}/"
url_file scheme-file "file:///etc/hosts"
url_file scheme-javascript "javascript:alert(1)"
url_file scheme-custom "koine-test://example/x"
url_file empty ""
ditto -c -k "${WORK}/urls" "${WORK}/urls.zip"

# --- the browsers and the pages ------------------------------------------------------
# open_client <command...>: the contract-only client, once, its answer in ANSWER.
open_client() { contract_client_once "$@" >/dev/null; }
server_read() { SERVER_EVENTS="$(guest_text "cat ${SERVER_LOG}")"; }
# server_requests <host> <after ms>: the distinct request-targets the page server received
# from a browser for this host since the request was sent, as a JSON array.
server_requests() {
    jq -cs --arg h "$1" --argjson t "$2" '[.[] | select(.kind == "request" and .atMs >= $t and (.host | startswith($h + ":"))) | .target] | unique' <<<"${SERVER_EVENTS}"
}
# server_hosts <host> <after ms>: the distinct Host headers of those requests, exactly as sent.
server_hosts() {
    jq -cs --arg h "$1" --argjson t "$2" '[.[] | select(.kind == "request" and .atMs >= $t and (.host | startswith($h + ":"))) | .host] | unique' <<<"${SERVER_EVENTS}"
}
# page_wait <host> <after ms>: PAGE, the browser's own report for that host, or empty after 40 s.
page_wait() {
    PAGE=""
    for _ in $(seq 1 20); do
        server_read
        PAGE="$(jq -cs --arg h "$1" --argjson t "$2" '[.[] | select(.kind == "report" and .atMs >= $t and .report.hostname == $h) | .report][0] // empty' <<<"${SERVER_EVENTS}")"
        [ -z "${PAGE}" ] || return 0
        sleep 2
    done
    return 1
}
# quit_browser <name> <bundle identifier>: Command-Q as a user quits; a force-kill is recorded.
quit_browser() {
    local name="$1" id="$2"
    # Command-Q goes to whatever is in front, so only a running browser is brought forward.
    [ "$(instance_count "${id}")" != 0 ] || return 0
    testanyware agent window-focus --window "${name}" >/dev/null 2>&1 || true
    sleep 1
    testanyware input key q --modifiers cmd >/dev/null
    sleep 4
    if [ "$(instance_count "${id}")" != 0 ]; then
        guest "pkill -x '${name}'" || true
        sleep 3
        echo "${name} did not quit on Command-Q; terminated."
        QUIT_NOTE="${name} was terminated, not quit; "
    fi
    [ "$(instance_count "${id}")" = 0 ] || fail "${name} still runs"
}

# one_open <label> <browser id> <client arguments...>: with ${OTHER} in front and Koine
# inactive, sends one request and watches the system and the page server. Leaves in
# globals: ACK_CLASS, SENT, RECEIVED, PROCESS ({pid, startedAt} or null), ACTIVATED_MS
# (empty if the witness never saw the browser activated), EVENTS, SERVER_EVENTS.
one_open() {
    local label="$1" browser="$2"
    shift 2
    put_other_in_front >/dev/null
    watch_start
    open_client "$@"
    ACK_CLASS="$(jq -r .classification <<<"${ANSWER}")"
    SENT="$(jq -r .sentMs <<<"${ANSWER}")"
    RECEIVED="$(jq -r .receivedMs <<<"${ANSWER}")"
    PROCESS="$(jq -c 'if .process then (.process | {pid, startedAt}) else null end' <<<"${ANSWER}")"
    ACTIVATED_MS=""
    if [ "${ACK_CLASS}" = ok ]; then activation_wait "${browser}" "${SENT}" || true; else sleep 5; fi
    watch_read
    echo "Witness events: $(jq -c -s '[.[] | select(.event == "launched" or .event == "activated") | {event, atMs, id: .application.bundleIdentifier, pid: .application.pid}]' <<<"${EVENTS}")"
    echo "${label}: ${ACK_CLASS}; answer $((RECEIVED - SENT)) ms after the request; activation $([ -n "${ACTIVATED_MS}" ] && echo "$((ACTIVATED_MS - SENT)) ms after it" || echo "NOT SEEN"); process ${PROCESS}"
}

# accessibility_is <true|false>: Koine's own account of the consent, read under the manager grant.
accessibility_is() {
    local since
    since="$(date +%s)"
    until MANAGED="$(guest_json "bash \$HOME/vm-verify-client.sh \"${MANAGER}\" '{ koineManagement { osPermissions { permission owner granted } } }' | grep -m1 '^{'")" &&
        jq -e ".data.koineManagement.osPermissions[0].granted == $1" >/dev/null <<<"${MANAGED}"; do
        [ $(($(date +%s) - since)) -lt 60 ] || fail "osPermissions did not report granted: $1 within 60s"
        sleep 2
    done
    echo "Observation: Koine's own account (osPermissions): accessibility granted is $1."
}

# fixture_check <expected URL>: in the calling case (its `status` and `notes`): the test
# browser was handed this exact string since the request was sent, and nothing else.
fixture_check() {
    local expected="$1" records
    for _ in $(seq 1 20); do
        FIXTURE_EVENTS="$(guest_text "cat ${BROWSER_LOG} 2>/dev/null; true")"
        records="$(jq -cs --argjson t "${SENT}" '[.[] | select(.atMs >= $t)]' <<<"${FIXTURE_EVENTS}")"
        [ "$(jq 'length' <<<"${records}")" -gt 0 ] && break
        sleep 2
    done
    echo "The test browser was handed: $(jq -c '[.[] | {route, url}]' <<<"${records}")"
    jq -e --arg u "${expected}" 'length >= 1 and all(.[]; .url == $u)' >/dev/null <<<"${records}" ||
        { status="failed"; notes="${notes}the test browser was not handed exactly ${expected}; "; }
}

# browser_case <section> <browser name> <browser id> <case> <file> <kind> [<expected target>]
# kind: page (the page server must see the URL byte for byte), universal (a universal-link
# candidate: stays in the browser, Maps never starts), search (client-built; see search_case).
# The expected Host is the file's own host. `cold` in $COLD stops the browser first.
browser_case() {
    local section="$1" name="$2" id="$3" case="$4" file="$5" kind="$6" expected_target="${7:-}"
    local status="passed" notes="" url host cb act same="n/a" count dialogs requests started_ms
    url="$(cat "${WORK}/urls/${file}.txt")"
    host="$(sed -E 's|^https?://([^/:?#]+).*|\1|' <<<"${url}")"
    step "${section}: ${case}"
    QUIT_NOTE=""
    if [ "${COLD:-0}" = 1 ]; then
        quit_browser "${name}" "${id}"
        notes="${notes}${QUIT_NOTE}"
        [ "$(instance_count "${id}")" = 0 ] || fail "${name} runs before a cold open"
    fi
    one_open "${case}" "${id}" "open-url --secret \"${BOTH}\" --url-file \"${URLS}/${file}.txt\""
    if [ "${ACK_CLASS}" != ok ]; then
        status="failed"
        notes="${notes}not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
        record --arg s "${section}" --arg c "${case}" --arg st "${status}" --arg n "${notes}" '{section: $s, case: $c, status: $st, notes: $n}'
        watch_stop
        return 0
    fi
    expect '.status == "AVAILABLE" and .dependency == null and .http.status == 200 and ((.errors // []) | length == 0)' "${case}: not an acknowledged open"
    cb=$((RECEIVED - SENT))
    if [ -n "${ACTIVATED_MS}" ]; then act=$((ACTIVATED_MS - SENT)); else act=null; fi
    if [ -z "${ACTIVATED_MS}" ]; then status="pending-activation"; notes="${notes}acknowledged but the witness never saw ${name} activated; "; fi
    # The receipt's process is the browser's, by the kernel's account.
    sleep 2
    quiet_instances "${id}"
    count="$(jq -r '.instances | length' <<<"${INSTANCES}")"
    [ "${count}" = 1 ] || { status="failed"; notes="${notes}${count} instances of ${name}; "; }
    if [ "${PROCESS}" != null ] && [ "${count}" = 1 ]; then
        same="$(jq -c --argjson p "${PROCESS}" '.instances[0] | {pid, startedAt} == $p' <<<"${INSTANCES}")"
        echo "Receipt ${PROCESS}; kernel, read by the witness: $(jq -c '.instances[0] | {pid, startedAt}' <<<"${INSTANCES}") — equal: ${same}"
        [ "${same}" = true ] || { status="failed"; notes="${notes}the receipt's process is not the kernel's identity; "; }
    else
        notes="${notes}no process in the receipt; "
    fi
    if [ "${COLD:-0}" = 1 ]; then
        started_ms="$(jq -r '.instances[0].startedAt | (.[0:19] + "Z" | fromdate) * 1000 + ((.[20:26] | tonumber) / 1000 | floor)' <<<"${INSTANCES}" 2>/dev/null || echo 0)"
        [ "${started_ms}" -ge "${SENT}" ] 2>/dev/null || { status="failed"; notes="${notes}${name} did not start after the request; "; }
    fi
    # What the browser was asked to open.
    case "${kind}" in
    page)
        case "${WITNESS}" in
        fixture) fixture_check "${url}" ;;
        delivered) notes="${notes}delivery only: ${name} shows no page in this image (${WITNESS_LIMIT}); " ;;
        *)
            if page_wait "${host}" "${SENT}"; then
                echo "The page reports: ${PAGE}"
                requests="$(server_requests "${host}" "${SENT}")"
                echo "Request-targets the page server received for ${host}: ${requests}"
                [ "${requests}" = "$(jq -cn --arg t "${expected_target}" '[$t]')" ] || { status="failed"; notes="${notes}the page server received ${requests}, not exactly [${expected_target}]; "; }
                [ "$(jq -r '.href' <<<"${PAGE}")" = "${url}" ] || { status="failed"; notes="${notes}the browser's location.href is $(jq -r .href <<<"${PAGE}"), not the submitted URL; "; }
                [ "$(jq -r '.hash' <<<"${PAGE}")" = "#${url#*#}" ] || { status="failed"; notes="${notes}the fragment the page saw is $(jq -r .hash <<<"${PAGE}"); "; }
                [ "$(server_hosts "${host}" "${SENT}")" = "[\"${host}:${PORT}\"]" ] ||
                    { status="failed"; notes="${notes}the Host header the browser sent is $(server_hosts "${host}" "${SENT}"), not ${host}:${PORT}; "; }
            else
                status="failed"
                notes="${notes}the page never reported: the browser did not load ${url}; "
            fi
            ;;
        esac
        ;;
    universal)
        sleep 10
        watch_read
        # The ORDER of what the system reports is what this case observes: the first
        # application launched or activated after the request is the browser, the one the URL
        # was submitted to, and no application is before it. Safari forwards Apple-domain links to Maps itself, so a
        # Maps event after the browser's activation is the browser's own handling, recorded as
        # such; a browser that does not (Dia) must show no Maps event at all.
        local first maps_after maps_before
        first="$(jq -rs "[.[] | select((.event == \"launched\" or .event == \"activated\") and .atMs >= ${SENT})] | sort_by(.atMs) | first | .application.bundleIdentifier // empty" <<<"${EVENTS}")"
        maps_before="$(jq -rs "[.[] | select((.event == \"launched\" or .event == \"activated\") and .application.bundleIdentifier == \"${MAPS_ID}\" and .atMs >= ${SENT} and .atMs < ${ACTIVATED_MS:-0})] | length" <<<"${EVENTS}")"
        maps_after="$(jq -rs "[.[] | select((.event == \"launched\" or .event == \"activated\") and .application.bundleIdentifier == \"${MAPS_ID}\" and .atMs >= ${SENT})] | length" <<<"${EVENTS}")"
        echo "First application the system reports after the request: ${first:-none}; Maps events before the browser's activation: ${maps_before}, in all: ${maps_after}"
        [ "${first}" = "${id}" ] && [ "${maps_before}" = 0 ] || { status="failed"; notes="${notes}the first application to receive the URL was ${first:-none}, not ${name}; "; }
        if [ "${id}" != "${SAFARI_ID}" ]; then
            [ "${maps_after}" = 0 ] && [ "$(instance_count "${MAPS_ID}")" = 0 ] || { status="failed"; notes="${notes}Maps launched although ${name} does not forward the link; "; }
            witness_front >/dev/null
            [ "$(jq -r '.application.bundleIdentifier' <<<"${FRONT}")" = "${id}" ] || { status="failed"; notes="${notes}${name} is not in front; "; }
        elif [ "${maps_after}" != 0 ]; then
            notes="${notes}${name} itself then handed the link to Maps (after its own activation), as it does for Apple-domain links; "
        fi
        [ "${WITNESS}" != fixture ] || fixture_check "${url}"
        guest "pkill -x Maps" || true
        ;;
    esac
    watch_stop
    dialogs="$(system_dialogs)"
    echo "Dialogs on screen: ${dialogs:-none}"
    judge_dialogs "open" "${dialogs}"
    record --arg s "${section}" --arg c "${case}" --arg f "${file}" --arg u "${url}" --arg st "${status}" --arg n "${notes}" --arg same "${same}" --arg id "${id}" --arg w "${WITNESS}" \
        --argjson cb "${cb}" --argjson act "${act}" --argjson cold "$([ "${COLD:-0}" = 1 ] && echo true || echo false)" \
        '{section: $s, case: $c, url: $u, browser: $id, witness: $w, cold: $cold, status: $st, answerMs: $cb, activationMs: $act, receiptIsKernelIdentity: $same, notes: $n}'
    echo "Result: ${section}: ${case}: ${status}${notes:+ — ${notes}}"
}

# The typed query, café included, as ASCII escapes of its UTF-8 bytes that the guest shell
# expands: the agent's exec channel hands a literal é to the guest decomposed (e + U+0301),
# which is not what the user typed and would make the client encode other bytes.
QUERY_ARG="\$'koine caf\\xc3\\xa9 & co #1'"

# search_case <section> <browser name> <browser id> <case> <suggestions url> <expected target>:
# the client's search flow, its suggestion source failing in the way named, the engine the
# page server. The typed-query URL must still be opened, once.
search_case() {
    local section="$1" name="$2" id="$3" case="$4" suggestions="$5" expected_target="$6"
    local status="passed" notes="" cb act requests expected_url dialogs hangs_before hangs
    expected_url="${BASE}${expected_target}"
    step "${section}: ${case}"
    server_read
    hangs_before="$(jq -cs '[.[] | select(.kind == "hang")] | length' <<<"${SERVER_EVENTS}")"
    one_open "${case}" "${id}" "search --secret \"${BOTH}\" --query ${QUERY_ARG} --engine-template '${BASE}/search?q=%s' --suggestions-url '${suggestions}'"
    if [ "${ACK_CLASS}" != ok ]; then
        status="failed"
        notes="${notes}not acknowledged: $(jq -c '{classification, errors, dependency}' <<<"${ANSWER}"); "
        record --arg s "${section}" --arg c "${case}" --arg st "${status}" --arg n "${notes}" '{section: $s, case: $c, status: $st, notes: $n}'
        watch_stop
        return 0
    fi
    cb=$((RECEIVED - SENT))
    if [ -n "${ACTIVATED_MS}" ]; then act=$((ACTIVATED_MS - SENT)); else act=null; fi
    echo "The client's search report: $(jq -c '.search' <<<"${ANSWER}")"
    jq -e --arg u "${expected_url}" '.search.suggestions.attempted == true and .search.suggestions.outcome == "failed" and .search.urlBuilt == $u' >/dev/null <<<"${ANSWER}" ||
        { status="failed"; notes="${notes}the client did not report a failed suggestion source and the typed-query URL ${expected_url}; "; }
    [ -n "${ACTIVATED_MS}" ] || { [ "${status}" = failed ] || status="pending-activation"; notes="${notes}no activation seen; "; }
    case "${WITNESS}" in
    fixture) fixture_check "${expected_url}" ;;
    delivered) notes="${notes}delivery only: ${name} shows no page in this image (${WITNESS_LIMIT}); " ;;
    *)
        if page_wait "${HOST}" "${SENT}"; then
            echo "The page reports: ${PAGE}"
            requests="$(server_requests "${HOST}" "${SENT}")"
            echo "Request-targets the page server received for ${HOST}: ${requests}"
            [ "${requests}" = "$(jq -cn --arg t "${expected_target}" '[$t]')" ] || { status="failed"; notes="${notes}the page server received ${requests}, not exactly [${expected_target}]; "; }
            [ "$(jq -r '.href' <<<"${PAGE}")" = "${expected_url}" ] || { status="failed"; notes="${notes}the browser's location.href is $(jq -r .href <<<"${PAGE}"); "; }
        else
            status="failed"
            notes="${notes}the page never reported: the typed-query URL was not opened; "
        fi
        ;;
    esac
    server_read
    # A source that never answers was actually asked, and the open did not wait for it forever.
    hangs="$(jq -cs '[.[] | select(.kind == "hang")] | length' <<<"${SERVER_EVENTS}")"
    case "${suggestions}" in
    */hang*)
        [ "${hangs}" -gt "${hangs_before}" ] || { status="failed"; notes="${notes}the hanging suggestion source was never asked; "; }
        [ "${cb}" -le 15000 ] || { status="failed"; notes="${notes}the open waited ${cb} ms on the suggestion source; "; }
        ;;
    esac
    watch_stop
    dialogs="$(system_dialogs)"
    echo "Dialogs on screen: ${dialogs:-none}"
    judge_dialogs "search" "${dialogs}"
    record --arg s "${section}" --arg c "${case}" --arg u "${expected_url}" --arg st "${status}" --arg n "${notes}" --arg id "${id}" --arg w "${WITNESS}" \
        --argjson cb "${cb}" --argjson act "${act}" \
        '{section: $s, case: $c, url: $u, browser: $id, witness: $w, status: $st, answerMs: $cb, activationMs: $act, notes: $n}'
    echo "Result: ${section}: ${case}: ${status}${notes:+ — ${notes}}"
}

# The witness of what a browser was handed: page (the page server and the browser's own
# report), fixture (the test browser's log of the strings delivered to it) or delivered (the
# acknowledgment, the activation and the receipt only: the browser shows no page).
WITNESS=page
WITNESS_LIMIT="its first run stops at an account gate that is never passed"

# The browser's whole section, with the browser the default.
browser_section() {
    local name="$1" id="$2" path="$3" version build section="$1 as the default browser"
    WITNESS="$4"
    version="$(bundle_value "${path}" CFBundleShortVersionString)"
    build="$(bundle_value "${path}" CFBundleVersion)"
    step "${section}: ${name} ${version} (build ${build}, ${id}) at ${path}"
    echo "Default browser now: $(default_browser)"
    default_browser | grep -q "${id}" || fail "${name} is not the default browser"
    [ -z "$(system_dialogs)" ] || fail "a system dialog is on screen before the section: $(system_dialogs)"
    record --arg n "${name}" --arg id "${id}" --arg v "${version}" --arg b "${build}" --arg p "${path}" --arg w "${WITNESS}" '{browser: $n, bundleIdentifier: $id, version: $v, build: $b, path: $p, witness: $w}'

    COLD=1 browser_case "${section}" "${name}" "${id}" "encoded path, query and fragment (cold browser)" encoded page \
        "/search/a%20b?q=caf%C3%A9+%E6%97%A5%E6%9C%AC&x=%26%23%25&e=%3D"
    COLD=0 browser_case "${section}" "${name}" "${id}" "encoded path, query and fragment (running browser)" encoded-warm page \
        "/second/%E6%97%A5?k=%2B%2F%3F&v=a%20b"
    COLD=0 browser_case "${section}" "${name}" "${id}" "ASCII IDNA host" idna page "/idna?label=b%C3%BCcher"

    # What the system's own dispatch of the same URL does, recorded beside the case and not
    # asserted. Only an application with a verified associated domain makes a URL a universal
    # link to LaunchServices, and no application of this image has one that resolves: a plain
    # `open` reaches the default browser (Dia) or, for Safari, Safari and then Maps by Safari's
    # own forwarding of Apple-domain links. So the case below cannot, at V, be told from the
    # scheme-only lookup by an app being diverted to; the difference is what the call-path
    # inspection (task check:launch-call-path) shows, and what the case does show is who
    # received the URL from Koine, first, and that nothing else did on Koine's account.
    step "${section}: where the system's own dispatch of the universal-link candidate goes (recorded)"
    put_other_in_front >/dev/null
    watch_start
    local plain_sent
    plain_sent="$(guest_text 'perl -MTime::HiRes=time -e "printf \"%d\", time()*1000"' | tail -1)"
    guest "open '$(cat "${WORK}/urls/universal.txt")'" || true
    sleep 10
    watch_read
    watch_stop
    local plain_first plain_maps plain_browser
    plain_first="$(jq -rs "[.[] | select((.event == \"launched\" or .event == \"activated\") and .atMs >= ${plain_sent:-0})] | sort_by(.atMs) | first | .application.bundleIdentifier // empty" <<<"${EVENTS}")"
    plain_maps="$(jq -rs "[.[] | select((.event == \"launched\" or .event == \"activated\") and .application.bundleIdentifier == \"${MAPS_ID}\" and .atMs >= ${plain_sent:-0})] | length" <<<"${EVENTS}")"
    plain_browser="$(jq -rs "[.[] | select(.event == \"activated\" and .application.bundleIdentifier == \"${id}\" and .atMs >= ${plain_sent:-0})] | length" <<<"${EVENTS}")"
    echo "Plain \`open\`: first application ${plain_first:-none}; ${name} activations ${plain_browser}; Maps launch or activation events ${plain_maps}"
    record --arg s "${section}" --arg first "${plain_first}" --argjson browser "${plain_browser}" --argjson maps "${plain_maps}" \
        '{section: $s, case: "recorded: plain open of the universal-link candidate", firstApplication: $first, browserActivations: $browser, mapsEvents: $maps}'
    guest "pkill -x Maps" || true
    sleep 3
    [ "$(instance_count "${MAPS_ID}")" = 0 ] || fail "Maps still runs after the plain open"

    COLD=0 browser_case "${section}" "${name}" "${id}" "universal-link candidate stays in the browser" universal universal

    search_case "${section}" "${name}" "${id}" "search, suggestion source refusing the connection" \
        'http://127.0.0.1:1/suggest?q=%s' "/search?q=koine%20caf%C3%A9%20%26%20co%20%231"
    search_case "${section}" "${name}" "${id}" "search, suggestion source that never answers" \
        "${BASE}/hang?q=%s" "/search?q=koine%20caf%C3%A9%20%26%20co%20%231"
}

# --- the guest ------------------------------------------------------------------------
start_vm
GATEKEEPER="$(guest 'spctl --status --verbose' 2>&1)"
echo "Gatekeeper in the clone: $(tr '\n' ';' <<<"${GATEKEEPER}")"
grep -qx 'assessments enabled' <<<"${GATEKEEPER}" ||
    fail "the clone is not Gatekeeper-enforcing; run: task launchers:prepare"
install_app
step "Carry the client, the Node runtime, the witnesses and the URL files into the guest"
testanyware file upload "${NODE_ARCHIVE}" /Users/admin/node.tar.xz >/dev/null
testanyware file upload "${BUNDLE}" /Users/admin/koine-client.mjs >/dev/null
testanyware file upload scripts/vm-verify-contract-client-trim.py /Users/admin/trim.py >/dev/null
testanyware file upload scripts/vm-verify-launch-client.py /Users/admin/vm-verify-launch-client.py >/dev/null
testanyware file upload scripts/vm-url-witness-server.mjs /Users/admin/vm-url-witness-server.mjs >/dev/null
testanyware file upload "${WITNESS_BIN}" /Users/admin/LaunchWitness >/dev/null
testanyware file upload "${WORK}/urls.zip" /Users/admin/urls.zip >/dev/null
ditto -c -k --keepParent "${URL_BROWSER}" "${WORK}/UrlBrowser.zip"
testanyware file upload "${WORK}/UrlBrowser.zip" /Users/admin/UrlBrowser.zip >/dev/null
guest 'cd $HOME && rm -rf node urls && tar -xJf node.tar.xz && mv node-*-darwin-arm64 node && chmod +x $HOME/LaunchWitness && echo open-url > $HOME/launch-target.txt && ditto -x -k urls.zip urls && ls urls | wc -l && ./node/bin/node --version'

step "The test browser: installed and registered, a browser to the system that records what it is handed"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister
guest "mkdir -p \$HOME/Applications && cd \$HOME/Applications && rm -rf UrlBrowser.app && ditto -x -k \$HOME/UrlBrowser.zip \$HOME/Applications && ${LSREGISTER} -f ${TEST_PATH} && codesign --verify --strict ${TEST_PATH}" ||
    fail "the test browser did not install"
echo "Test browser: $(bundle_value "${TEST_PATH}" CFBundleIdentifier), $(guest_text "codesign -dv ${TEST_PATH} 2>&1 | grep -E '^(Authority=Developer ID Application|TeamIdentifier)' | tr '\n' ' '"); no quarantine: $(guest_text "xattr -p com.apple.quarantine ${TEST_PATH} 2>&1 | head -1")"

step "The page server: two names that exist only in the guest's hosts file, answered on loopback"
guest "echo ${VM_PASSWORD} | sudo -S sh -c 'printf \"127.0.0.1 ${HOST} ${IDNA_HOST}\n\" >> /etc/hosts'" || true
guest "grep -c '${HOST}' /etc/hosts" | grep -qx 1 || fail "the hosts entries were not written"
# Idempotent: the agent's exec channel can run a command twice.
guest "lsof -nP -iTCP:${PORT} -sTCP:LISTEN >/dev/null || (nohup \$HOME/node/bin/node \$HOME/vm-url-witness-server.mjs ${PORT} ${SERVER_LOG} >/dev/null 2>&1 &)" || true
for _ in $(seq 1 20); do
    server_read
    grep -q '"kind":"listening"' <<<"${SERVER_EVENTS}" && break
    sleep 1
done
grep -q '"kind":"listening"' <<<"${SERVER_EVENTS}" || fail "the page server did not start"
guest "curl -s -o /dev/null -w '%{http_code}\n' '${BASE}/control?q=1'" | grep -qx 200 || fail "the page server does not answer by name"
echo "Page server up; Safari and Dia resolve ${HOST} and ${IDNA_HOST} to 127.0.0.1."

step "Launch Koine; a manager grant in the window, then the contract-only client enrols its own grants"
launch
create_grant "open-url-manager" "${MANAGER}" koine:manage
accessibility_is false
enrol "${BOTH}" open-url-client-both workspace:control desktop:control
expect '.grant.capabilities == ["desktop:control","workspace:control"] or .grant.capabilities == ["workspace:control","desktop:control"]' \
    "the grant is not exactly both controls"
enrol "${WORKSPACE_ONLY}" open-url-client-workspace workspace:control
enrol "${DESKTOP_ONLY}" open-url-client-desktop desktop:control
enrol "${REVOKED}" open-url-client-revoked workspace:control desktop:control
REVOKED_GRANT="$(jq -r '.grant.grantId' <<<"${ANSWER}")"
guest "python3 \$HOME/vm-verify-launch-client.py \"${MANAGER}\" - revoke \"${REVOKED_GRANT}\"" | tail -1 | jq -e '.response.data.koineRevokeGrant.state == "REVOKED"' >/dev/null ||
    fail "the grant to be revoked was not revoked"
echo "Accessibility is not granted to Koine in this image: every open below is by workspace:control and desktop:control alone."
KOINE_PID="$(guest_text 'pgrep -x Koine' | head -1)"
echo "Koine runs as process ${KOINE_PID}."

step "The witness of Koine's network system calls, started before the first open"
# fs_usage (as root) reports every network system call of the named processes, one line each,
# the process last. It sees what a socket listing cannot: a connection made and closed. Koine
# is named, and so is curl, which makes one control request below, so that the same capture
# shows an outbound connect when there is one.
guest "pgrep -x fs_usage >/dev/null || echo ${VM_PASSWORD} | sudo -S sh -c '(nohup fs_usage -w -f network Koine curl > \$HOME/fsusage.txt 2>&1 &)'" || true
sleep 3
guest "curl -s -o /dev/null -m 15 https://example.com/ || true"
sleep 3
guest "grep ' connect ' \$HOME/fsusage.txt | grep -c ' curl\\.[0-9]* *\$'" | grep -qE '^[1-9]' ||
    fail "the system-call witness did not see curl's outbound connect: it cannot witness Koine's absence of one"
echo "Control: the capture shows curl's outbound connect."

step "The default browser, and the tool that changes it"
install_default_browser_tool
DEFAULT_BEFORE="$(default_browser)"
echo "Default browser: ${DEFAULT_BEFORE}"
grep -q "${SAFARI_ID}" <<<"${DEFAULT_BEFORE}" || fail "Safari is not the default browser at the start"
SAFARI_PATH="${DEFAULT_BEFORE%% *}"

SECTIONS="${KOINE_OPEN_URL_ONLY:-}"
# wanted <section>: whether KOINE_OPEN_URL_ONLY (a comma-separated list of texts) names it.
wanted() {
    local word
    [ -z "${SECTIONS}" ] && return 0
    for word in ${SECTIONS//,/ }; do [[ "$1" == *"${word}"* ]] && return 0; done
    return 1
}

if wanted Safari; then browser_section Safari "${SAFARI_ID}" "${SAFARI_PATH}" page; fi

if wanted refus; then
    step "Refusals and denials with Safari the default browser: nothing is repaired, nothing opens"
    # Every case below must open nothing, so they are asked in one run in the guest under one
    # watch, with ${OTHER} in front: the agent's exec channel makes each round trip slow, and
    # a batch is also the stricter observation (not one browser launch, activation or page
    # request, and the front application never changes, from the first to the last).
    REFUSED="bad-escape-letters bad-escape-truncated bad-escape-query unicode-path unicode-query unicode-host space leading-space
        trailing-newline tab control backslash-path backslash-authority credentials scheme-file scheme-javascript scheme-custom empty"
    BATCH="mkdir -p \$HOME/refusals && rm -f \$HOME/refusals/*"
    for name in ${REFUSED}; do
        BATCH="${BATCH}; ${CLIENT} open-url --secret \"${BOTH}\" --url-file \"${URLS}/${name}.txt\" > \$HOME/refusals/${name}.json"
    done
    BATCH="${BATCH}; ${CLIENT} open-url --secret \"${WORKSPACE_ONLY}\" --url-file \"${URLS}/encoded.txt\" > \$HOME/refusals/authority-workspace-only.json"
    BATCH="${BATCH}; ${CLIENT} open-url --secret \"${DESKTOP_ONLY}\" --url-file \"${URLS}/encoded.txt\" > \$HOME/refusals/authority-desktop-only.json"
    BATCH="${BATCH}; ${CLIENT} open-url --secret \"${REVOKED}\" --url-file \"${URLS}/encoded.txt\" > \$HOME/refusals/authority-revoked.json"
    put_other_in_front >/dev/null
    witness_front >/dev/null
    FRONT_BEFORE="$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")"
    server_read
    REQUESTS_BEFORE="$(jq -cs '[.[] | select(.kind == "request" or .kind == "hang")] | length' <<<"${SERVER_EVENTS}")"
    watch_start
    # Nothing here can be harmed by a repeat: each client run is refused and opens nothing, and
    # a repeat that did open something is what the witness below would show.
    guest "${BATCH}" || true
    for _ in $(seq 1 20); do
        REFUSALS="$(guest_text 'cd $HOME/refusals && for f in *.json; do printf "%s " "${f%.json}"; cat "$f"; done')"
        [ "$(grep -c '^[a-z-]* {' <<<"${REFUSALS}")" = "$(($(wc -w <<<"${REFUSED}") + 3))" ] && break
        sleep 3
    done
    sleep 6
    watch_read
    watch_stop
    # answer_of <case>: that case's one JSON line, in ANSWER.
    answer_of() {
        ANSWER="$(grep "^$1 {" <<<"${REFUSALS}" | head -1)"
        ANSWER="${ANSWER#* }"
        jq -e . >/dev/null <<<"${ANSWER}" || fail "the client left no answer for $1"
    }
    for name in ${REFUSED}; do
        answer_of "${name}"
        echo "refused: ${name}: $(jq -c '{classification, actionEffect, errors: [.errors[] | {message, path, kind}]}' <<<"${ANSWER}")"
        expect '.classification == "input-error" and .actionEffect == "none" and .process == null and .receipt == null and .status == null' \
            "${name}: not refused as an input error with nothing done"
        expect '.http.status == 200 and (.errors | length) == 1 and (.errors[0] | .path == ["workspaceOpenURL"] and .kind == null)' "${name}: not an HTTP 200 error at the root's own path with no kind"
        record --arg n "${name}" --argjson e "$(jq -c '.errors[0]' <<<"${ANSWER}")" '{case: "refused", input: $n, status: "passed", error: $e}'
    done
    answer_of authority-workspace-only
    echo "workspace:control alone: $(jq -c '{classification, http, requiredCapability, requiredCapabilities, phase}' <<<"${ANSWER}")"
    expect '.classification == "capability-denied" and .http.status == 403 and .requiredCapability == "desktop:control" and .requiredCapabilities == ["workspace:control","desktop:control"] and .process == null' \
        "workspace:control alone was not refused with the first unmet capability and the complete set"
    record '{case: "authority: workspace:control alone", status: "passed"}'
    answer_of authority-desktop-only
    echo "desktop:control alone: $(jq -c '{classification, http, requiredCapability, requiredCapabilities, phase}' <<<"${ANSWER}")"
    expect '.classification == "capability-denied" and .http.status == 403 and .requiredCapability == "workspace:control" and .requiredCapabilities == ["workspace:control","desktop:control"] and .process == null' \
        "desktop:control alone was not refused with the first unmet capability and the complete set"
    record '{case: "authority: desktop:control alone", status: "passed"}'
    answer_of authority-revoked
    echo "a revoked grant: $(jq -c '{classification, http, errors}' <<<"${ANSWER}")"
    expect '.http.status == 401 and .process == null and .receipt == null' "the revoked grant was not refused with 401"
    record '{case: "authority: revoked grant", status: "passed"}'
    jq -e -s '[.[] | select(.event == "launched" or .event == "activated")] | length == 0' >/dev/null <<<"${EVENTS}" ||
        fail "a refused open launched or activated an application: $(jq -c -s '[.[] | select(.event == "launched" or .event == "activated")]' <<<"${EVENTS}")"
    server_read
    [ "$(jq -cs '[.[] | select(.kind == "request" or .kind == "hang")] | length' <<<"${SERVER_EVENTS}")" = "${REQUESTS_BEFORE}" ] ||
        fail "the page server received a request from a refused open"
    witness_front >/dev/null
    [ "$(jq -c '[.application.pid, .application.startedAt]' <<<"${FRONT}")" = "${FRONT_BEFORE}" ] || fail "focus moved during the refusals"
    echo "Observation: $(wc -w <<<"${REFUSED}") refused inputs and three denied grants: nothing opened, nothing launched, activated or moved, no request reached the page server."

    step "The default search engine's URL opens in the browser, and Koine itself contacts no one"
    # Google is the client's default engine; the browser, not Koine, makes the request. The
    # network use of every process is read from the system (nettop), not from Koine.
    ENGINE_URL='https://www.google.com/search?q=koine%20url%20acceptance'
    one_open "default engine search" "${SAFARI_ID}" "search --secret \"${BOTH}\" --query 'koine url acceptance'"
    watch_stop
    echo "The client's search report: $(jq -c '.search' <<<"${ANSWER}")"
    expect "(.classification == \"ok\") and .search.urlBuilt == \"${ENGINE_URL}\" and .search.suggestions.outcome == \"not-attempted\"" \
        "the default-engine search did not build and open the typed-query URL"
    sleep 15
    record --arg u "${ENGINE_URL}" --arg a "${ACTIVATED_MS}" '{case: "default engine", url: $u, status: "passed", browserActivated: ($a != "")}'
fi

if wanted UrlBrowser; then
    step "The test browser made the alternate default browser"
    set_default_browser "${TEST_PATH}" 'Use “UrlBrowser”'
    echo "Default browser now: $(default_browser)"
    browser_section UrlBrowser "${TEST_ID}" "${TEST_PATH}" fixture
    guest "pkill -x UrlBrowser" || true
fi

if wanted Dia; then
    step "Dia made the alternate default browser"
    set_default_browser "${DIA_PATH}" 'Use “Dia”'
    echo "Default browser now: $(default_browser)"
    browser_section Dia "${DIA_ID}" "${DIA_PATH}" delivered
    record --arg v "$(bundle_value "${DIA_PATH}" CFBundleShortVersionString)" \
        '{case: "Dia page load", status: "pending-account", notes: ("Dia " + $v + " delivered the URLs (acknowledged, activated, the receipt the kernel identity, nothing else receiving them) but shows no page: its first run stops at an account gate that is never passed. Whether delivery is enough for Dia, or Dia is to be signed in in the image, or another alternate is to stand in, is Antony\u0027s decision.")}'
fi

step "Koine's own network use: every network system call it made, from the capture started before the first open"
# The number after the process name in fs_usage's lines is the thread, not the process id.
FSU_KOINE="grep ' Koine\\.[0-9]* *\$' \$HOME/fsusage.txt"
echo "Koine's network system calls over the run, by call:"
guest "${FSU_KOINE} | awk '{print \$2}' | sort | uniq -c | sort -rn"
KOINE_CALLS="$(guest_text "${FSU_KOINE} | wc -l" | tr -d ' ')"
KOINE_CONNECTS="$(guest_text "${FSU_KOINE} | grep -c ' connect '" | tr -d ' ')"
CURL_CONNECTS="$(guest_text "grep ' connect ' \$HOME/fsusage.txt | grep -c ' curl\\.[0-9]* *\$'" | tr -d ' ')"
echo "Koine: ${KOINE_CALLS} network system calls, ${KOINE_CONNECTS} connect; the control, curl: ${CURL_CONNECTS} connect."
[ "${KOINE_CALLS}" -gt 0 ] || fail "the capture holds no Koine system call, so it cannot witness their absence"
[ "${CURL_CONNECTS}" -gt 0 ] || fail "the capture holds no outbound connect by the control"
[ "${KOINE_CONNECTS}" = 0 ] || fail "Koine made ${KOINE_CONNECTS} outbound connect call(s)"
echo "Koine's sockets now: $(guest "lsof -nP -a -p ${KOINE_PID} -i 2>&1 | tail -n +2 | awk '{print \$9, \$10}' | tr '\n' ';'")"
echo "External traffic of the processes that browsed, from the system's per-process counters:"
guest 'nettop -P -L 1 -x -t external -J bytes_in,bytes_out 2>&1 | grep -E "^(com.apple.WebKi|Dia|Safari)"' || true
echo "Observation: Koine made no outbound connection in the whole run, the capture seeing the control's; its only socket is its own loopback endpoint."
record --argjson calls "${KOINE_CALLS}" --argjson control "${CURL_CONNECTS}" '{case: "no request from Koine", koineNetworkCalls: $calls, koineConnects: 0, controlConnects: $control, status: "passed"}'

step "Accessibility was absent throughout, and no consent dialog is on screen"
accessibility_is false
no_consent_dialog "after every open"
record '{case: "accessibility absent throughout", status: "passed"}'

if ! default_browser | grep -q "${SAFARI_ID}"; then
    step "Safari restored as the default browser"
    set_default_browser "${SAFARI_PATH}" 'Use “Safari”'
    default_browser | grep -q "${SAFARI_ID}" || fail "Safari was not restored as the default browser"
    echo "Default browser: $(default_browser)"
fi

step "The subjects of the run are as they were at its start"
[ "$(subjects_digest)" = "${SUBJECTS_BEFORE}" ] || fail "a subject of this run changed while it ran; the run measured nothing"
echo "Unchanged: ${#SUBJECTS[@]} files, digested before and after."

step "Results"
jq -s '.' "${RESULTS}" >"${OUT_DIR}/results.json"
jq -r '.[] | select(.answerMs != null) | "\(.section // "-"): \(.case): \(.status) [\(.witness // "-")]; answer \(.answerMs) ms, activation \(.activationMs) ms; receipt = kernel: \(.receiptIsKernelIdentity // "n/a")"' "${OUT_DIR}/results.json"
jq -r '.[] | select(.case != null and .answerMs == null) | "\(.case)\(if .input then " " + .input else "" end): \(.status)"' "${OUT_DIR}/results.json"
echo "Written: ${OUT_DIR}/results.json"
FAILED="$(jq '[.[] | select(.status == "failed")] | length' "${OUT_DIR}/results.json")"
PENDING="$(jq '[.[] | select(.status == "pending-activation")] | length' "${OUT_DIR}/results.json")"
PENDING_ACCOUNT="$(jq '[.[] | select(.status == "pending-account")] | length' "${OUT_DIR}/results.json")"

step "Quit Koine"
for _ in 1 2 3; do
    testanyware agent window-focus --window "${APP_NAME}" >/dev/null 2>&1 || true
    sleep 1
    testanyware input key q --modifiers cmd >/dev/null || true
    sleep 3
    guest "! pgrep -f ${INSTALLED}" >/dev/null 2>&1 && break
done
guest "! pgrep -f ${INSTALLED}" >/dev/null 2>&1 || { echo "Koine did not quit on Command-Q three times; terminated (recorded, not an acceptance case)."; guest "pkill -f ${INSTALLED}" || true; }

if [ "${FAILED}" != 0 ]; then
    echo "FAILED: ${FAILED} case(s) failed, ${PENDING} pending — transcript in ${LOG}" >&2
    exit 1
fi
if [ "${PENDING}" != 0 ] || [ "${PENDING_ACCOUNT}" != 0 ]; then
    echo "PENDING: ${PENDING} acknowledged open(s) not seen activating, ${PENDING_ACCOUNT} page load(s) behind an account gate (Dia); they stay live and go to Antony — transcript in ${LOG}" >&2
    exit 3
fi
step "PASSED — transcript in ${LOG}"
