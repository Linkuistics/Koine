#!/bin/bash
# The whole-contract conformance check of docs/specs/machine.md's "Public GraphQL
# contract", for the profile the SIGNED Koine.app serves: the core composed with its
# two bundled providers, desktop and workspace, held to
# docs/design/profiles/core-desktop-workspace-extension-host.json. The profile names
# the design SDL (the workspace design restricted to the implemented roots and the
# types they reach, verbatim) and, separately from it, the exact provider candidates
# the application runs, because an identical schema and digest cannot say which
# binary ran. The two profiles a headless host serves, old-host and extension-host
# core + desktop, are checked beside this one by scripts/conformance.sh, which runs
# this script last.
#
# Nothing here runs the application on the host: introspecting means launching
# Koine, so it is launched in a clean TestAnyware clone and the introspection
# response is brought back. The comparison itself is host-side (Tools/Conformance),
# so the controls re-run it against mutated copies of the design file and of the
# pins at no further VM cost (scripts/conformance-lib.sh).
#
# The check is two claims, and a green run needs both:
#   * the canonically printed design file has the digest Koine served, which
#     covers declared order and needs nothing from introspection;
#   * the difference report against the introspected schema is empty.
# Neither alone would do; Tools/Conformance/main.swift says why.
#
# The bundle must be the signed application; whether it is also notarized and
# stapled is recorded, and required only when KOINE_CONFORMANCE_REQUIRE_NOTARIZED=1.
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
# KOINE_CONFORMANCE_CAPTURE names a captured introspection response to re-run the
#   comparison against instead of starting a VM — for re-running against an earlier
#   run's evidence, never for producing new evidence. KOINE_CONFORMANCE_PROVIDERS names
#   the providers response captured with it and KOINE_CONFORMANCE_DIGEST the digest
#   (defaults: the files of .build/conformance/workspace).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

PROFILE="docs/design/profiles/core-desktop-workspace-extension-host.json"
OUT=".build/conformance/workspace"
mkdir -p "${OUT}"
CAPTURE="${OUT}/introspection.json"
PROVIDERS="${OUT}/providers.json"

# shellcheck source=scripts/conformance-lib.sh
source scripts/conformance-lib.sh

# The comparison, and the mutated-design controls, run against whatever capture
# is in hand. Built before the VM so a compile error costs no clone.
swift build --product KoineConformance >/dev/null
CHECK="$(swift build --show-bin-path)/KoineConformance"
"${CHECK}" --print-query > "${OUT}/introspection.graphql"

if [ -n "${KOINE_CONFORMANCE_CAPTURE:-}" ]; then
    CAPTURE="${KOINE_CONFORMANCE_CAPTURE}"
    PROVIDERS="${KOINE_CONFORMANCE_PROVIDERS:-${PROVIDERS}}"
    [ "${CAPTURE}" = "${OUT}/introspection.json" ] || cp "${CAPTURE}" "${OUT}/introspection.json"
    [ "${PROVIDERS}" = "${OUT}/providers.json" ] || cp "${PROVIDERS}" "${OUT}/providers.json"
    [ -z "${KOINE_CONFORMANCE_DIGEST:-}" ] || printf '%s' "${KOINE_CONFORMANCE_DIGEST}" > "${OUT}/digest"
    echo "Re-running the comparison against ${CAPTURE} — no VM, no new evidence."
    LOG="${OUT}/rerun.log"
else
    # Before a VM is spun: this evidence is about the signed application, and a bundle
    # whose signature does not verify would make the run say something else quietly.
    if ! codesign --verify --deep --strict "${APP_BUNDLE}" >/dev/null 2>&1; then
        {
            echo "Error: ${APP_BUNDLE} is not a validly signed application."
            echo "  The introspected schema must come from the signed application."
            echo "  Run: task app"
        } >&2
        exit 1
    fi
    if xcrun stapler validate "${APP_BUNDLE}" >/dev/null 2>&1; then
        NOTARIZATION="stapled"
    else
        NOTARIZATION="not stapled"
        if [ "${KOINE_CONFORMANCE_REQUIRE_NOTARIZED:-}" = 1 ]; then
            echo "Error: ${APP_BUNDLE} carries no stapled notarization ticket. Run: task app:notarize" >&2
            exit 1
        fi
    fi
    echo "The bundle under test: signed application, notarization ${NOTARIZATION}."
    codesign -dvv "${APP_BUNDLE}" 2>&1 | grep -E '^(Identifier|Authority|TeamIdentifier)=' || true

    # shellcheck disable=SC2034  # read by vm-verify-lib.sh
    KOINE_VM_LOG_PREFIX="conformance-"
    # shellcheck source=scripts/vm-verify-lib.sh
    source scripts/vm-verify-lib.sh
    # shellcheck source=scripts/vm-verify-desktop-lib.sh
    source scripts/vm-verify-desktop-lib.sh

    GRANT_LABEL="vm-conformance-script"
    # Guest-side, like DATA: $HOME is expanded by the guest's shell, never here.
    # shellcheck disable=SC2016
    GUEST_CAPTURE='$HOME/introspection.json'

    start_vm
    install_app
    step "The installed copy is the signed bundle"
    guest "codesign --verify --deep --strict ${INSTALLED} 2>&1" || fail "the installed copy's signature does not verify"
    if [ "${NOTARIZATION}" = stapled ]; then
        guest "xcrun stapler validate ${INSTALLED} 2>&1" || fail "the installed copy has no stapled ticket"
    fi
    launch

    step "A grant through the window"
    # Introspection needs no provider capability — "discovery is not execution
    # authority" — but the grant is made with the desktop ones so that the run
    # also records availableCapabilities as a client sees them.
    create_grant "${GRANT_LABEL}" "${CREDENTIAL_FILE}" "koine:manage" "desktop:read" "desktop:control"

    step "Both bundled providers are ACTIVE, so the composed schema is the one being checked"
    ask '{ koineManagement { providers { provider version schemaVersion state diagnostic candidateId origin selection selectedCandidateId reason } } }'
    sed -n 1p <<<"${RESPONSE}" |
        jq -e '[.data.koineManagement.providers[] | select(.provider == "desktop" or .provider == "workspace") | .state] == ["ACTIVE", "ACTIVE"]' >/dev/null ||
        fail "desktop and workspace are not both ACTIVE; a schema checked without them is not the composed contract"
    # The candidates the profile pins are read from the same session as the schema.
    sed -n 1p <<<"${RESPONSE}" | jq -e '.data.koineManagement.providers' >"${PROVIDERS}" ||
        fail "the run read no koineManagement.providers"
    echo "Providers served: $(jq -c '[.[] | {provider, version, state, origin, selection, reason}]' "${PROVIDERS}")"

    step "Capture the introspection response, as a code generator would ask for it"
    testanyware file upload "${OUT}/introspection.graphql" /Users/admin/introspection.graphql >/dev/null
    testanyware file upload scripts/vm-verify-introspect.py /Users/admin/vm-verify-introspect.py >/dev/null
    SUMMARY="$(guest_json "python3 \$HOME/vm-verify-introspect.py \"${CREDENTIAL_FILE}\" \$HOME/introspection.graphql ${GUEST_CAPTURE}")"
    echo "${SUMMARY}"
    jq -e '.status == 200' >/dev/null <<<"${SUMMARY}" || fail "introspection was refused: ${SUMMARY}"
    jq -e '.errors == []' >/dev/null <<<"${SUMMARY}" || fail "introspection answered with errors: ${SUMMARY}"
    SERVED_DIGEST="$(jq -r '.schemaDigest' <<<"${SUMMARY}")"
    [ -n "${SERVED_DIGEST}" ] && [ "${SERVED_DIGEST}" != null ] || fail "the run read no Koine.schemaDigest"
    echo "Contract version: $(jq -r '.contractVersion' <<<"${SUMMARY}")"
    echo "Koine.schemaDigest: ${SERVED_DIGEST}"
    printf '%s' "${SERVED_DIGEST}" > "${OUT}/digest"

    testanyware file download "/Users/admin/introspection.json" "${CAPTURE}" >/dev/null
    [ -s "${CAPTURE}" ] || fail "the introspection response did not come back"
    echo "Captured $(wc -c <"${CAPTURE}" | tr -d ' ') bytes to ${CAPTURE}"

    step "Quit Koine"
    quit_koine
fi

# From here the VM is no longer needed: the comparison is text against text.
conformance_controls "${PROFILE}" "${OUT}"
conformance_verdict "${PROFILE}" "${OUT}"

step "PASSED — transcript in ${LOG}"
