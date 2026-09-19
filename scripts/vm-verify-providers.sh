#!/bin/bash
# Verifies, on the signed Koine.app in a clean TestAnyware macOS VM, what a
# hardened process with no entitlement exceptions changes for native providers:
# an approved same-team fixture in the per-user root loads and serves its field,
# an ad-hoc signed one never loads, and one demanding an unavailable framework
# minor is INCOMPATIBLE. The fixture bundles are test material this script
# installs; none is part of the shipped bundle. Nothing here runs the
# application on the host. The procedure and its recorded evidence:
# docs/verification/signed-app-provider-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

PRODUCTS="$(swift build --show-bin-path)"
APPROVED_ROOT="${PRODUCTS}/FixtureProviders"
ADHOC_ROOT="${PRODUCTS}/FixtureVariants/adhoc-signed"
MINOR_ROOT="${PRODUCTS}/FixtureVariants/unavailable-minor"
for root in "${APPROVED_ROOT}" "${ADHOC_ROOT}" "${MINOR_ROOT}"; do
    if [ ! -d "${root}/Fixture.koineprovider" ]; then
        echo "Error: ${root}/Fixture.koineprovider does not exist. Run: task fixture:variants" >&2
        exit 1
    fi
done

KOINE_VM_LOG_PREFIX="providers-"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh

GRANT_LABEL="vm-provider-script"
Q_PROVIDERS='{ koineManagement { providers { provider version state diagnostic } grants { clientLabel state } } }'
Q_FIXTURE='{ fixtureInfo { greeting } }'
Q_ROOT_FIELDS='{ __schema { queryType { fields { name } } } }'

# install_root <host root>: replaces the per-user provider root with the root's
# bundle and approval record, as a user would place them.
install_root() {
    rm -f "${WORK}/root.zip"
    ditto -c -k "$1" "${WORK}/root.zip"
    testanyware file upload "${WORK}/root.zip" /Users/admin/koine-provider-root.zip >/dev/null
    guest "rm -rf \"${DATA}/Providers\" && mkdir -p \"${DATA}/Providers\" && ditto -x -k \$HOME/koine-provider-root.zip \"${DATA}/Providers\" && ls \"${DATA}/Providers\""
    guest "cat \"${DATA}/Providers/fixture.approval.json\"; echo"
    guest "codesign -dvv \"${DATA}/Providers/Fixture.koineprovider\" 2>&1 | grep -E '^(Identifier|Signature|TeamIdentifier|Authority=Developer)'"
}
launch() {
    guest "open ${INSTALLED}"
    place_window
    for _ in $(seq 1 12); do
        if guest "[ -e \"${DATA}/endpoint.json\" ]" >/dev/null 2>&1; then return; fi
        sleep 2
    done
    fail "no endpoint descriptor after launch"
}
# ask <query>: prints the response and leaves it in RESPONSE; HTTP 200 expected.
ask() {
    RESPONSE="$(client "$1")"
    echo "${RESPONSE}"
    grep -qx "HTTP 200" <<<"${RESPONSE}" || fail "expected HTTP 200 for: $1"
}
# provider_state: the fixture's state in the last RESPONSE.
provider_state() {
    sed -n 1p <<<"${RESPONSE}" | jq -r '.data.koineManagement.providers[] | select(.provider == "fixture") | .state'
}
expect_refused() {
    ask "${Q_PROVIDERS}"
    [ "$(provider_state)" = "$1" ] || fail "the fixture provider is not $1"
    [ -n "$(sed -n 1p <<<"${RESPONSE}" | jq -r '.data.koineManagement.providers[] | select(.provider == "fixture") | .diagnostic // empty')" ] ||
        fail "the $1 provider carries no diagnostic"
    # Management still works: the same response lists the grant made in the UI.
    grep -q "\"clientLabel\":\"${GRANT_LABEL}\"" <<<"${RESPONSE}" || fail "management did not list the grant"
    ask "${Q_ROOT_FIELDS}"
    ! grep -q '"fixture' <<<"${RESPONSE}" || fail "a fixture field is in the introspected schema"
    # Recorded: what the fixture query itself gets when its field does not exist.
    client "${Q_FIXTURE}"
    # No image of the refused bundle is mapped into the process.
    IMAGES="$(guest "lsof -p \$(pgrep -f ${INSTALLED}/Contents/MacOS) 2>/dev/null | grep -E 'KoineProviderAPI|Fixture' || true")"
    echo "${IMAGES}"
    ! grep -q 'libFixtureProvider' <<<"${IMAGES}" || fail "the refused provider's image is mapped"
}

start_vm
install_app

step "The signed bundle: entitlements, and the framework inside it"
echo "Entitlements: $(guest "codesign -d --entitlements - --xml ${INSTALLED} 2>/dev/null" || true)"
guest "find ${INSTALLED}/Contents/Frameworks ${INSTALLED}/Contents/PlugIns -maxdepth 1"
guest "codesign --verify --strict --verbose=2 ${INSTALLED}/Contents/Frameworks/${PROVIDER_FRAMEWORK_NAME}.framework 2>&1"
guest "codesign -dvv ${INSTALLED}/Contents/Frameworks/${PROVIDER_FRAMEWORK_NAME}.framework 2>&1 | grep -E '^(Identifier|CodeDirectory|TeamIdentifier|Authority=Developer)'"
echo "The fixture links (host side; the VM has no otool), and the frameworks it bundles:"
otool -L "${APPROVED_ROOT}/Fixture.koineprovider/libFixtureProvider.dylib" | sed -n '2,$p'
echo "bundled frameworks: $(find "${APPROVED_ROOT}/Fixture.koineprovider" -name '*.framework' | wc -l | tr -d ' ')"

step "An approved same-team fixture in the per-user root"
install_root "${APPROVED_ROOT}"
launch
click '.id=="grant-label"'
testanyware input type "${GRANT_LABEL}" >/dev/null
sleep 1
click '.id=="capability-koine:manage"'
click '.id=="capability-fixture:read"'
click '.role=="button" and .label=="Create Grant"'
[ -n "$(value_of '.id=="grant-credential"')" ] || fail "the credential sheet did not appear"
click '.role=="button" and .label=="Copy"'
guest "umask 077; pbpaste > \"${CREDENTIAL_FILE}\"; ls -l \"${CREDENTIAL_FILE}\""
click '.role=="button" and .label=="Done"'
ask ''
ask "${Q_PROVIDERS}"
[ "$(provider_state)" = ACTIVE ] || fail "the fixture provider is not ACTIVE"
ask "${Q_FIXTURE}"
grep -q '"greeting":"' <<<"${RESPONSE}" || fail "the fixture field was not served"
# Which images the hardened process mapped: the framework from the application's
# own Frameworks directory, once, and the plugin from Koine's staged copy.
IMAGES="$(guest "lsof -p \$(pgrep -f ${INSTALLED}/Contents/MacOS) 2>/dev/null | grep -E 'KoineProviderAPI|Fixture'")"
echo "${IMAGES}"
grep -q 'libFixtureProvider' <<<"${IMAGES}" || fail "the plugin image is not mapped"
FRAMEWORK_IMAGES="$(grep 'KoineProviderAPI' <<<"${IMAGES}" | awk '{print $NF}' | sort -u)"
[ "${FRAMEWORK_IMAGES}" = "${INSTALLED}/Contents/Frameworks/${PROVIDER_FRAMEWORK_NAME}.framework/Versions/A/${PROVIDER_FRAMEWORK_NAME}" ] ||
    fail "the framework image is not exactly the host's: ${FRAMEWORK_IMAGES}"

step "An ad-hoc signed fixture instead, under the same approval record"
quit_koine
install_root "${ADHOC_ROOT}"
launch
expect_refused REJECTED

step "An approved same-team fixture whose manifest demands framework minor 99"
quit_koine
install_root "${MINOR_ROOT}"
launch
expect_refused INCOMPATIBLE

step "Quit Koine"
quit_koine

step "PASSED — transcript in ${LOG}"
