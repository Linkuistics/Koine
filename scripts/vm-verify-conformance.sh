#!/bin/bash
# The whole-contract conformance check of docs/specs/machine.md's "Public GraphQL
# contract": the schema the NOTARIZED Koine.app actually serves, composed with
# its bundled desktop provider, against docs/design/desktop-schema.graphql.
#
# Nothing here runs the application on the host — introspecting means launching
# Koine, so it is launched in a clean TestAnyware clone and the introspection
# response is brought back. The comparison itself is host-side
# (Tools/Conformance), so the positive control below re-runs it against mutated
# copies of the design file at no further VM cost.
#
# The check is two claims, and a green run needs both:
#   * the canonically printed design file has the digest Koine served, which
#     covers declared order and needs nothing from introspection;
#   * the difference report against the introspected schema is empty.
# Neither alone would do; Tools/Conformance/main.swift says why.
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
# KOINE_CONFORMANCE_CAPTURE reuses a captured introspection response instead of
#   starting a VM — for re-running the comparison against an earlier run's
#   evidence, never for producing new evidence.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

DESIGN="docs/design/desktop-schema.graphql"
OUT=".build/conformance"
mkdir -p "${OUT}"
CAPTURE="${OUT}/introspection.json"
SERVED_SDL="${OUT}/served.graphql"

# The comparison, and the mutated-design controls, run against whatever capture
# is in hand. Built before the VM so a compile error costs no clone.
swift build --product KoineConformance >/dev/null
CHECK="$(swift build --show-bin-path)/KoineConformance"
"${CHECK}" --print-query > "${OUT}/introspection.graphql"

if [ -n "${KOINE_CONFORMANCE_CAPTURE:-}" ]; then
    CAPTURE="${KOINE_CONFORMANCE_CAPTURE}"
    SERVED_DIGEST="${KOINE_CONFORMANCE_DIGEST:-}"
    echo "Re-running the comparison against ${CAPTURE} — no VM, no new evidence."
    step() { printf '\n== %s\n' "$*"; }
    fail() { echo "FAILED: $*" >&2; exit 1; }
    LOG="${OUT}/rerun.log"
else
    # Before a VM is spun: this leaf's evidence is about the notarized build, and
    # an unstapled bundle would make the run say something else quietly.
    if ! xcrun stapler validate "${APP_BUNDLE}" >/dev/null 2>&1; then
        {
            echo "Error: ${APP_BUNDLE} carries no stapled notarization ticket."
            echo "  The introspected schema must come from the notarized application."
            echo "  Run: task app && task app:notarize"
        } >&2
        exit 1
    fi

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
    step "The installed copy is the notarized, stapled bundle"
    guest "xcrun stapler validate ${INSTALLED} 2>&1" || fail "the installed copy has no stapled ticket"
    launch

    step "A grant through the window"
    # Introspection needs no provider capability — "discovery is not execution
    # authority" — but the grant is made with the desktop ones so that the run
    # also records availableCapabilities as a client sees them.
    create_grant "${GRANT_LABEL}" "${CREDENTIAL_FILE}" "koine:manage" "desktop:read" "desktop:control"

    step "The bundled desktop provider is ACTIVE, so the composed schema is the one being checked"
    ask '{ koineManagement { providers { provider version schemaVersion state diagnostic } } }'
    sed -n 1p <<<"${RESPONSE}" |
        jq -e '[.data.koineManagement.providers[] | select(.provider == "desktop")] | .[0].state == "ACTIVE"' >/dev/null ||
        fail "the desktop provider is not ACTIVE; a schema checked without it is not the composed contract"

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

    testanyware file download "/Users/admin/introspection.json" "${CAPTURE}" >/dev/null
    [ -s "${CAPTURE}" ] || fail "the introspection response did not come back"
    echo "Captured $(wc -c <"${CAPTURE}" | tr -d ' ') bytes to ${CAPTURE}"

    step "Quit Koine"
    quit_koine
fi

# From here the VM is no longer needed: the comparison is text against text.
step "The positive control: a mutated contract must turn this check red"
# A difference report that finds nothing reads the same whether the schemas agree
# or the comparison never reached them. Each mutation is a class the check claims
# to report — a description, a nullability marker, an argument default — and each
# is watched to appear before a clean run is believed. The declared-order case is
# the one only the digest can see, which is why it is here too.
# How many differences the unmutated contract has, so that a control's count is
# the mutation's own rather than the baseline's. It is read, not asserted: the
# contract's own verdict is the last step, and the controls have to run first.
# `|| true` because a non-conformant contract is exactly the case this reads,
# and under `set -o pipefail` its exit status would end the run here.
BASELINE="$({ "${CHECK}" --introspection "${CAPTURE}" --design "${DESIGN}" 2>/dev/null || true; } |
    sed -n 's/^\([0-9][0-9]*\) difference(s) between.*/\1/p')"
BASELINE="${BASELINE:-0}"
echo "  (the unmutated contract reports ${BASELINE} difference(s); each control is judged against that)"

control() {
    # $2 and $3 are read by the heredoc below as arguments, not as shell words.
    local what="$1" file="${OUT}/control.graphql"
    python3 - "$2" "$3" "${DESIGN}" "${file}" <<'PY'
import sys
source = open(sys.argv[3]).read()
if sys.argv[1] not in source:
    raise SystemExit("the control's anchor is not in %s: %r" % (sys.argv[3], sys.argv[1]))
open(sys.argv[4], "w").write(source.replace(sys.argv[1], sys.argv[2], 1))
PY
    if "${CHECK}" --introspection "${CAPTURE}" --design "${file}" \
        ${SERVED_DIGEST:+--served-digest "${SERVED_DIGEST}"} >"${OUT}/control.log" 2>&1; then
        sed 's/^/  /' "${OUT}/control.log"
        fail "the check passed a contract with ${what}; it cannot be trusted when it passes"
    fi
    # Which half caught it, said plainly: the transposed case is caught by the
    # digest alone, because declared order is what the introspected text cannot
    # carry, and a control that did not say so would look like a weaker result.
    local caught="" count
    count="$(sed -n 's/^\([0-9][0-9]*\) difference(s) between.*/\1/p' "${OUT}/control.log")"
    count="${count:-0}"
    [ "${count}" -le "${BASELINE}" ] || caught="the report (${count} against ${BASELINE})"
    if grep -q 'they differ' "${OUT}/control.log"; then
        caught="${caught:+${caught} and }the digest"
    fi
    # A control that goes red because the mutated file no longer parses has
    # proved nothing about the comparison, so the reason is asserted, not printed.
    [ -n "${caught}" ] || {
        sed 's/^/  /' "${OUT}/control.log"
        fail "${what} made the check fail without reaching a comparison"
    }
    echo "  ${what}: red, caught by ${caught}"
}
control "a description removed" \
    '"Equality token for the served schema; compare, do not interpret."
  schemaDigest' 'schemaDigest'
control "a nullability marker removed" 'contractVersion: String!' 'contractVersion: String'
control "an argument default introduced" \
    'koineRevokeGrant(grantId: ID!)' 'koineRevokeGrant(grantId: ID! = "x")'
control "two root fields transposed" \
    '  "Authenticated caller metadata. No provider capability required."
  koine: Koine!
  "Proof of the submitted secret, or its resulting active grant; own request only."
  koineGrantRequest: KoineGrantRequest' \
    '  "Proof of the submitted secret, or its resulting active grant; own request only."
  koineGrantRequest: KoineGrantRequest
  "Authenticated caller metadata. No provider capability required."
  koine: Koine!'
rm -f "${OUT}/control.graphql" "${OUT}/control.log"

step "The contract as it stands"
"${CHECK}" --introspection "${CAPTURE}" --design "${DESIGN}" \
    ${SERVED_DIGEST:+--served-digest "${SERVED_DIGEST}"} --sdl-out "${SERVED_SDL}" || {
    echo
    echo "The served schema is not ${DESIGN}. Classify every difference above:"
    echo "  * the served schema is wrong  -> a finding; cut a repair leaf, do not edit the SDL"
    echo "  * the contract moved during implementation -> reconcile into ${DESIGN} AND"
    echo "    docs/specs/machine.md, where the contract is described"
    exit 1
}
echo "Canonical served SDL written to ${SERVED_SDL}"

step "PASSED — transcript in ${LOG}"
