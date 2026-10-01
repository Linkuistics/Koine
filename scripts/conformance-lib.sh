#!/bin/bash
# The check and its controls, for one conformance profile
# (docs/design/profiles/). Sourced by scripts/conformance.sh (the two profiles
# served by headless hosts) and scripts/vm-verify-conformance.sh (the profile
# served by the signed application); never run by itself.
#
# A profile is held to two claims a green run needs both of:
#   * the design SDL: the canonically printed file has the digest Koine served, which
#     covers declared order and needs nothing from introspection, and the difference
#     report against the introspected schema is empty;
#   * the candidates: the exact providers the host runs, pinned apart from the SDL,
#     because an identical schema and digest cannot say which binary ran.
# Neither alone would do; Tools/Conformance/main.swift says why.
#
# A difference report that finds nothing reads the same whether the schemas agree
# or the comparison never reached them. So every check is preceded by controls:
# mutated copies of the design file and mutated pins, each watched to turn the check
# red for the reason it names, before a clean run is believed.

step() { printf '\n== %s\n' "$*"; }
fail() { echo "FAILED: $*" >&2; exit 1; }

# conformance_design <profile.json>: the profile's design SDL as an absolute path (it
# is named relative to the profile file).
conformance_design() {
    python3 -c 'import json, os, sys
print(os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(sys.argv[1])), json.load(open(sys.argv[1]))["design"])))' "$1"
}

# conformance_controls <profile.json> <capture dir>
#   <capture dir> holds introspection.json, providers.json and digest (the
#   Koine.schemaDigest read in the same session as the introspection).
# Needs CHECK (the KoineConformance binary) in the environment.
conformance_controls() {
    local profile="$1" dir="$2"
    local capture="${dir}/introspection.json" providers="${dir}/providers.json"
    local digest design
    digest="$(cat "${dir}/digest")"
    design="$(conformance_design "${profile}")"
    [ -f "${design}" ] || fail "the profile's design SDL ${design} does not exist"
    local work="${dir}/controls"
    mkdir -p "${work}"

    step "The positive control: a mutated contract must turn this check red ($(jq -r .name "${profile}"))"
    # How many differences the unmutated contract has, so that a control's count is
    # the mutation's own rather than the baseline's. It is read, not asserted: the
    # contract's own verdict is the last step, and the controls have to run first.
    # `|| true` because a non-conformant contract is exactly the case this reads,
    # and under `set -o pipefail` its exit status would end the run here.
    local baseline
    baseline="$({ "${CHECK}" --introspection "${capture}" --design "${design}" 2>/dev/null || true; } |
        sed -n 's/^\([0-9][0-9]*\) difference(s) between.*/\1/p')"
    baseline="${baseline:-0}"
    echo "  (the unmutated contract reports ${baseline} difference(s); each control is judged against that)"

    # control <what> <python expression over the design text `s`, returning the mutated text>
    control() {
        local what="$1" file="${work}/control.graphql"
        python3 - "${design}" "${file}" "$2" <<'PY'
import sys
s = open(sys.argv[1]).read()
mutated = eval(sys.argv[3])
if mutated == s:
    raise SystemExit("the control changes nothing in %s" % sys.argv[1])
open(sys.argv[2], "w").write(mutated)
PY
        if "${CHECK}" --introspection "${capture}" --design "${file}" \
            ${digest:+--served-digest "${digest}"} >"${work}/control.log" 2>&1; then
            sed 's/^/  /' "${work}/control.log"
            fail "the check passed a contract with ${what}; it cannot be trusted when it passes"
        fi
        # Which half caught it, said plainly: the transposed case is caught by the
        # digest alone, because declared order is what the introspected text cannot
        # carry, and a control that did not say so would look like a weaker result.
        local caught="" count
        count="$(sed -n 's/^\([0-9][0-9]*\) difference(s) between.*/\1/p' "${work}/control.log")"
        count="${count:-0}"
        [ "${count}" -le "${baseline}" ] || caught="the report (${count} against ${baseline})"
        if grep -q 'they differ' "${work}/control.log"; then
            caught="${caught:+${caught} and }the digest"
        fi
        # A control that goes red because the mutated file no longer parses has
        # proved nothing about the comparison, so the reason is asserted, not printed.
        [ -n "${caught}" ] || {
            sed 's/^/  /' "${work}/control.log"
            fail "${what} made the check fail without reaching a comparison"
        }
        echo "  ${what}: red, caught by ${caught}"
    }
    control "a description removed" \
        "s.replace('\"Equality token for the served schema; compare, do not interpret.\"\n  schemaDigest', 'schemaDigest', 1)"
    control "a nullability marker removed" "s.replace('contractVersion: String!', 'contractVersion: String', 1)"
    control "an argument default introduced" \
        "s.replace('koineRevokeGrant(grantId: ID!)', 'koineRevokeGrant(grantId: ID! = \"x\")', 1)"
    control "two root fields transposed" \
        "s.replace('  \"Authenticated caller metadata. No provider capability required.\"\n  koine: Koine!\n  \"Proof of the submitted secret, or its resulting active grant; own request only.\"\n  koineGrantRequest: KoineGrantRequest', '  \"Proof of the submitted secret, or its resulting active grant; own request only.\"\n  koineGrantRequest: KoineGrantRequest\n  \"Authenticated caller metadata. No provider capability required.\"\n  koine: Koine!', 1)"
    if jq -e '[.providers[].provider] | index("workspace")' "${profile}" >/dev/null; then
        # A workspace coordinate that is missing is a difference, never silently omitted.
        control "the workspace launch root removed" \
            "__import__('re').sub(r'  \"\"\"Requires workspace:control AND desktop:control\\. Launch or request[^\n]*\"\"\"\n  workspaceLaunchApplication[^\n]*\n', '', s, count=1)"
        control "the workspace URL root removed" \
            "__import__('re').sub(r'  \"\"\"Requires workspace:control AND desktop:control\\. Accept the ASCII[^\n]*\"\"\"\n  workspaceOpenURL[^\n]*\n', '', s, count=1)"
        control "a workspace type's description changed" \
            "s.replace('Closed reason for not submitting this action.', 'Closed reason for not submitting this action!', 1)"
        control "the workspace launch field moved before desktop's" \
            "__import__('re').sub(r'(  \"desktop:control\\. Focuses exactly[^\n]*\n  desktopFocusWindow[^\n]*\n)(  \"\"\"Requires workspace:control AND desktop:control\\. Launch or request[^\n]*\"\"\"\n  workspaceLaunchApplication[^\n]*\n)', r'\\2\\1', s, count=1)"
    fi
    rm -f "${work}/control.graphql" "${work}/control.log"

    step "The positive control for the candidates: a mutated profile must turn the pin red"
    # The schema and its digest are unmoved by which binary ran, so the pin is its own
    # claim and gets its own controls: a wrong release, a required provider that is
    # not served, and a row the profile did not expect. Each must fail for its stated
    # reason, not because the mutated file no longer parses.
    profile_control() {
        local what="$1" expression="$2" expected="$3" file="${work}/control-profile.json"
        jq --arg design "${design}" ".design = \$design | ${expression}" "${profile}" >"${file}"
        if "${CHECK}" --introspection "${capture}" --profile "${file}" --providers "${providers}" \
            >"${work}/control.log" 2>&1; then
            sed 's/^/  /' "${work}/control.log"
            fail "the check passed a profile with ${what}; it cannot be trusted when it passes"
        fi
        grep -q "${expected}" "${work}/control.log" || {
            sed 's/^/  /' "${work}/control.log"
            fail "${what} turned the check red without the profile problem it should name (${expected})"
        }
        echo "  ${what}: red, naming '${expected}'"
    }
    profile_control "a different release pinned" '.providers[0].version = "9.9.9"' 'is not served as expected'
    profile_control "a required provider that is not served" \
        '.providers += [{"provider": "input", "version": "1.0.0", "schemaVersion": "1.0.0", "state": "ACTIVE"}]' 'is missing'
    profile_control "a served row the profile does not expect" '.providers = []' 'unexpected row desktop'
    if jq -e '[.providers[].provider] | index("workspace")' "${profile}" >/dev/null; then
        profile_control "workspace left out of the pin" \
            '.providers |= map(select(.provider != "workspace"))' 'unexpected row workspace'
        profile_control "another workspace release pinned" \
            '.providers |= map(if .provider == "workspace" then .version = "9.9.9" else . end)' 'is not served as expected'
    fi
    rm -f "${work}/control-profile.json" "${work}/control.log"
    rmdir "${work}" 2>/dev/null || true
}

# conformance_verdict <profile.json> <capture dir> [--sdl-out <file>]
conformance_verdict() {
    local profile="$1" dir="$2" sdl_out="${3:-${2}/served.graphql}"
    local digest design
    digest="$(cat "${dir}/digest")"
    design="$(jq -r .design "${profile}")"
    step "The contract as it stands ($(jq -r .name "${profile}"))"
    "${CHECK}" --introspection "${dir}/introspection.json" --profile "${profile}" --providers "${dir}/providers.json" \
        ${digest:+--served-digest "${digest}"} --sdl-out "${sdl_out}" || {
        echo
        echo "The served schema is not ${design}. Classify every difference above:"
        echo "  * the served schema is wrong  -> a finding; cut a repair leaf, do not edit the SDL"
        echo "  * the contract moved during implementation -> reconcile into ${design} AND"
        echo "    docs/specs/machine.md, where the contract is described"
        exit 1
    }
    echo "Canonical served SDL written to ${sdl_out}"
}
