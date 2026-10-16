#!/bin/bash
# Verifies, on the signed Koine.app in a clone of the prepared launcher image, that Koine
# itself puts no packet on a network while it opens URLs and runs the client's search flow
# against the real search engine: the packets the system attributes to Koine are on the
# loopback interface only, while the browser Koine opened is the one that reaches the engine.
# This is the "Koine makes no Google request" half of docs/verification/open-url-vm.md, with
# an instrument that is shown to work before it is trusted.
#
# The instrument is `tcpdump -i pktap,all -k NPID`: every packet the system carries is
# written with the interface, the process whose socket carried it and the process it was
# carried for. It sees whatever stack a process uses (a connection made and closed included,
# URLSession's HTTP/3 and Network.framework's too), unlike a listing of open sockets, which
# misses a closed connection, or fs_usage's network calls, which showed a CFNetwork client's
# DNS lookup and not its TCP connection.
#
# Phase A, the controls, before Koine runs: curl, and a Swift program compiled in the guest
# under the name `Koine` (Fixtures/NetControl) that makes requests by URLSession and by
# Network.framework, must each be seen on a non-loopback interface under their names. A
# capture that cannot attribute those cannot be a witness for Koine.
# Phase B: the signed Koine runs; the contract-only client enrols a grant through its window
# and then sends the default-engine search (Google, the client's default) and a second search
# whose suggestion source refuses the connection, each opening the typed-query URL in Safari.
# The capture over those must show Koine's packets on loopback only (and some, so the
# instrument is not blind to it), Koine's pid in no external packet and in no DNS lookup made
# for it, and Safari's own network process reaching the engine.
#
# Nothing here runs an application on the host. KOINE_VM_KEEP=1 leaves the VM running.
# KOINE_LAUNCHERS_IMAGE is the prepared image (default koine-launchers-prepared).
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
KOINE_VM_LOG_PREFIX="open-url-network-"
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
BOTH='$HOME/koine-secret-both'
OUT_DIR=".build/open-url-network"
mkdir -p "${OUT_DIR}"

SUBJECTS=(scripts/vm-verify-network.sh scripts/vm-network-summary.py Fixtures/NetControl/main.swift scripts/vm-verify-contract-client-lib.sh
    scripts/vm-launchers-lib.sh "${BUNDLE}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}" "${APP_BUNDLE}/Contents/PlugIns/Workspace.koineprovider/libWorkspaceProvider.dylib")
subjects_digest() { shasum -a 256 "${SUBJECTS[@]}"; }
SUBJECTS_BEFORE="$(subjects_digest)"
echo "Subjects of this run:"
echo "${SUBJECTS_BEFORE}"

NODE_ARCHIVE="$(scripts/stage-node-runtime.sh)"

# capture_start <name>: the capture, as root, in the background; idempotent, since the
# agent's exec channel can run a command twice.
capture_start() {
    guest "pgrep -x tcpdump >/dev/null || { rm -f \$HOME/$1.txt; echo ${VM_PASSWORD} | sudo -S sh -c '(nohup tcpdump -i pktap,all -k NPID -n -l -tt > \$HOME/$1.txt 2>&1 &)'; }" || true
    sleep 4
    guest_text "pgrep -x tcpdump | wc -l" | grep -qx ' *1' || fail "the capture did not start"
}
capture_stop() {
    sleep 3
    guest "echo ${VM_PASSWORD} | sudo -S pkill tcpdump" || true
    sleep 2
    guest_text "pgrep -x tcpdump | wc -l" | grep -qx ' *0' || fail "the capture did not stop"
}
# summary <name> [dns substring...]: SUMMARY, the capture by process and interface.
summary() {
    local name="$1"
    shift
    SUMMARY="$(guest_json "python3 \$HOME/vm-network-summary.py \$HOME/${name}.txt $*")" || fail "the capture ${name} could not be summarised"
    echo "Capture ${name}: $(jq -c '{lines, unparsed}' <<<"${SUMMARY}")"
}
expect_summary() { jq -e "$1" >/dev/null <<<"${SUMMARY}" || fail "$2"; }

start_vm
install_app
step "Carry the client, the Node runtime, the summary and the control into the guest"
testanyware file upload "${NODE_ARCHIVE}" /Users/admin/node.tar.xz >/dev/null
testanyware file upload "${BUNDLE}" /Users/admin/koine-client.mjs >/dev/null
testanyware file upload scripts/vm-verify-contract-client-trim.py /Users/admin/trim.py >/dev/null
testanyware file upload scripts/vm-network-summary.py /Users/admin/vm-network-summary.py >/dev/null
testanyware file upload Fixtures/NetControl/main.swift /Users/admin/NetControl.swift >/dev/null
guest 'cd $HOME && rm -rf node && tar -xJf node.tar.xz && mv node-*-darwin-arm64 node && echo network > $HOME/launch-target.txt && ./node/bin/node --version'

step "Phase A: the controls, before Koine runs"
guest 'cd $HOME && swiftc -O NetControl.swift -o Koine 2>&1 | tail -3; ls -l $HOME/Koine | cut -c1-60' || true
guest '[ -x $HOME/Koine ]' || fail "the control did not build in the guest"
capture_start control
guest "curl -s -o /dev/null -m 15 https://example.com/ || true"
guest 'cd $HOME && rm -f control.out && (nohup ./Koine > control.out 2>&1 &)' || true
for _ in $(seq 1 30); do
    guest_text 'cat $HOME/control.out' | grep -q 'NWConnection' && break
    sleep 3
done
echo "The control's own report: $(guest_text 'cat $HOME/control.out' | tr '\n' ' ')"
capture_stop
summary control example.com
echo "By process: $(jq -c '.by | with_entries(select(.key == "curl" or .key == "Koine"))' <<<"${SUMMARY}")"
expect_summary '.by.curl.external > 0' "the capture does not attribute curl's packets: it cannot witness anything"
expect_summary '.by.Koine.external > 0' "the capture does not attribute the control named Koine, whatever stack it used"
expect_summary '.lookups["example.com"].Koine > 0' "a DNS lookup made for the control named Koine is not attributed to it"
echo "Controls seen: curl and a process named Koine (URLSession and Network.framework) each attributed on a non-loopback interface, and the lookup made for the latter attributed to it."
guest 'rm -f $HOME/Koine'

step "Phase B: the signed Koine runs; the client enrols and sends two searches against the real engine"
launch
enrol "${BOTH}" network-client-both workspace:control desktop:control
KOINE_PID="$(guest_text 'pgrep -x Koine' | head -1)"
echo "Koine runs as process ${KOINE_PID}."
capture_start koine
OTHER="TextEdit"
guest "open -a ${OTHER} \$HOME/launch-target.txt" || true
contract_client_once "search --secret \"${BOTH}\" --query 'koine url acceptance'" >/dev/null
echo "The default-engine search: $(jq -c '{classification, search: .search.urlBuilt, status}' <<<"${ANSWER}")"
expect '.classification == "ok" and .search.urlBuilt == "https://www.google.com/search?q=koine%20url%20acceptance"' "the default-engine search was not opened"
contract_client_once "search --secret \"${BOTH}\" --query 'koine second search' --suggestions-url 'http://127.0.0.1:1/suggest?q=%s'" >/dev/null
echo "The search with a refusing suggestion source: $(jq -c '{classification, search}' <<<"${ANSWER}")"
expect '.classification == "ok" and .search.suggestions.outcome == "failed" and .search.urlBuilt == "https://www.google.com/search?q=koine%20second%20search"' "the second search was not opened with its failed suggestion source"
echo "Giving Safari time to reach the engine."
sleep 40
capture_stop
summary koine google
echo "By process: $(jq -c '.by' <<<"${SUMMARY}")"
echo "Lookups of google, by the process they were made for: $(jq -c '.lookups.google' <<<"${SUMMARY}")"
expect_summary '.by.Koine.loopback > 0' "the capture attributes no packet to Koine at all, even on loopback: it is blind to it"
expect_summary '(.by.Koine.external // 0) == 0' "Koine has packets on a non-loopback interface"
expect_summary '((.lookups.google // {}) | has("Koine") | not)' "a DNS lookup of the engine was made for Koine"
expect_summary '((.lookups.google // {}) | length) > 0' "no lookup of the engine is in the capture: nothing shows the browser reached it"
expect_summary '([.by | to_entries[] | select(.key | test("^(Safari|com.apple.WebKit)")) | .value.external] | add // 0) > 0' "Safari's own processes show no external traffic: the capture does not show the engine being reached"
echo "Observation: Koine's packets are on loopback only ($(jq -c '.by.Koine' <<<"${SUMMARY}")); the engine's lookups were made for $(jq -c '.lookups.google | keys' <<<"${SUMMARY}"), and Safari's processes carried the external traffic."

step "The subjects of the run are as they were at its start"
[ "$(subjects_digest)" = "${SUBJECTS_BEFORE}" ] || fail "a subject of this run changed while it ran; the run measured nothing"
echo "Unchanged: ${#SUBJECTS[@]} files, digested before and after."
jq -n --argjson control "$(guest_json "python3 \$HOME/vm-network-summary.py \$HOME/control.txt example.com")" --argjson koine "${SUMMARY}" \
    '{control: $control, koine: $koine}' >"${OUT_DIR}/summary.json"
echo "Written: ${OUT_DIR}/summary.json"

step "Quit Koine"
quit_koine_or_terminate

step "PASSED — transcript in ${LOG}"
