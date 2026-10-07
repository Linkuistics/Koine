#!/bin/bash
# Holds the retained workspace 1.0.0 bundle (scripts/build-retained-workspace.sh) to
# what it shipped with, each check preceded by the proof that it can fail:
#
#   identity      the sealed artifact is the pinned release, schema and signing
#                 identifier, is unchanged since it was recorded, carries the SDL of
#                 the pinned revision, and the working tree's retained contract files
#                 (the 1.0.0 SDL, its composed design and the 1.0.0 profile) are still
#                 the pinned revision's
#   host          the retained revision's own host bundling it serves the 1.0.0
#                 profile (docs/design/profiles/core-desktop-workspace-extension-host.json)
#                 over loopback HTTP: the complete design SDL and its digest, and the
#                 exact provider candidates; conformance controls from that revision's
#                 own scripts/conformance-lib.sh, then a copy of the bundle whose
#                 manifest says 1.0.1 and is resealed, which must turn the pin red
#   subjects      that revision's own workspace suites: the provider's logic (L), the
#                 composition (G) and installations composition, the schema and
#                 catalogue conformance, and WorkspaceProviderTests, the short-path N
#                 subjects, which load the kept-apart sealed bundle as the host's
#                 bundled root; first run against a provider whose missing-path rule is
#                 broken, which must fail, then against the artifact
#
# Nothing here reads the working tree's provider source: the tree under test is the
# extraction of the pinned revision.
#
# usage: verify-retained-workspace.sh [debug|release]
set -euo pipefail

cd "$(dirname "$0")/.."
CONFIGURATION="${1:-debug}"
REPOSITORY="$(pwd)"
DIRECTORY="${REPOSITORY}/.build/compat/${CONFIGURATION}/workspace-1.0.0"
TREE="${DIRECTORY}/src"
PIN="scripts/retained-workspace-1.0.0.json"
[ -f "${DIRECTORY}/retained.json" ] || {
    echo "Error: ${DIRECTORY}/retained.json does not exist. Run: task compat:workspace-baseline" >&2
    exit 1
}
BUNDLE="${DIRECTORY}/bundled/Workspace.koineprovider"
PRODUCTS="$(cd "${DIRECTORY}/products" && pwd -P)"
OUT="${DIRECTORY}/verification"
rm -rf "${OUT}"
mkdir -p "${OUT}"

# shellcheck source=scripts/conformance-lib.sh
source "${TREE}/scripts/conformance-lib.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

sha() { shasum -a 256 "$1" | cut -d' ' -f1; }
recorded() { jq -r ".$1" "${DIRECTORY}/retained.json"; }

# The subject's digests, read from the artifact and held to the record. Called before
# and after every step that runs against it: a subject that moved under a run is not
# what the run reports on.
subject_unchanged() {
    [ "$(sha "${BUNDLE}/manifest.json")" = "$(recorded manifestSha256)" ] || fail "$1: the artifact's manifest changed"
    [ "$(sha "${BUNDLE}/schema.graphql")" = "$(recorded schemaSha256)" ] || fail "$1: the artifact's SDL changed"
    [ "$(sha "${BUNDLE}/libWorkspaceProvider.dylib")" = "$(recorded dylibSha256)" ] || fail "$1: the artifact's binary changed"
    [ "$(codesign -dvvv "${BUNDLE}" 2>&1 | sed -n 's/^CDHash=//p')" = "$(recorded cdhash)" ] || fail "$1: the artifact's code directory changed"
    codesign --verify --strict "${BUNDLE}" 2>/dev/null || fail "$1: the artifact's seal no longer verifies"
}

# --- identity -----------------------------------------------------------------------

step "Identity: the artifact is the pinned release, sealed under the pinned identifier"
subject_unchanged "before identity"
[ "$(recorded commit)" = "$(jq -r .commit "${PIN}")" ] || fail "the artifact was built from another revision than the pin names"
[ "$(cat "${TREE}/.koine-retained-commit")" = "$(jq -r .commit "${PIN}")" ] || fail "the extracted tree is not the pinned revision"
[ "$(jq -r .version "${BUNDLE}/manifest.json")" = "$(jq -r .release "${PIN}")" ] || fail "the manifest does not say the pinned release"
[ "$(jq -r .schemaVersion "${BUNDLE}/manifest.json")" = "$(jq -r .schemaVersion "${PIN}")" ] || fail "the manifest does not say the pinned schema"
SEALED="$(codesign -dv "${BUNDLE}" 2>&1 | sed -n 's/^Identifier=//p')"
[ "${SEALED}" = "$(jq -r .signingIdentifier "${PIN}")" ] || fail "the sealed identifier is ${SEALED}"
echo "  $(jq -r .version "${BUNDLE}/manifest.json")/$(jq -r .schemaVersion "${BUNDLE}/manifest.json"), signed ${SEALED}, revision $(recorded commit)"

# same_file <what> <pinned revision's file> <working tree's file>: byte-equal, and the
# comparison is first shown to see a difference.
same_file() {
    local what="$1" pinned="$2" current="$3"
    cp "${pinned}" "${WORK}/control-file"
    echo "# mutated" >>"${WORK}/control-file"
    ! cmp -s "${WORK}/control-file" "${current}" || fail "the comparison saw no difference in a mutated copy of ${what}"
    cmp -s "${pinned}" "${current}" || fail "${what} is no longer the pinned revision's"
    echo "  ${what}: unchanged"
}

step "Identity: the artifact serves the pinned revision's SDL and the contract files are unchanged"
same_file "the bundle's SDL" "${TREE}/Providers/WorkspaceProvider/schema.graphql" "${BUNDLE}/schema.graphql"
same_file "the 1.0.0 profile" "${TREE}/docs/design/profiles/core-desktop-workspace-extension-host.json" \
    docs/design/profiles/core-desktop-workspace-extension-host.json
same_file "the composed 1.0.0 design" "${TREE}/docs/design/desktop-workspace-schema-extension-host.graphql" \
    docs/design/desktop-workspace-schema-extension-host.graphql
# The retained 1.0.0 SDL may carry header comments planning added; its definitions
# are held byte-for-byte.
definitions() { sed '/^#/d' "$1"; }
definitions "${TREE}/docs/design/workspace-schema.graphql" >"${WORK}/pinned-sdl"
definitions docs/design/workspace-schema.graphql >"${WORK}/current-sdl"
same_file "the 1.0.0 workspace SDL's definitions" "${WORK}/pinned-sdl" "${WORK}/current-sdl"

# --- host ---------------------------------------------------------------------------

step "Host: build the revision's own conformance check"
(cd "${TREE}" && swift build -c "${CONFIGURATION}" --product KoineConformance >/dev/null)
CHECK="$(cd "${TREE}" && swift build -c "${CONFIGURATION}" --show-bin-path)/KoineConformance"
PROFILE="${TREE}/docs/design/profiles/core-desktop-workspace-extension-host.json"

step "Host: serve the 1.0.0 profile from the revision's host bundling the retained bundle"
subject_unchanged "before the host"
python3 scripts/capture-retained-workspace.py "${CONFIGURATION}" "${DIRECTORY}/bundled" "${OUT}/served" "${CHECK}"
subject_unchanged "after the host"
conformance_controls "${PROFILE}" "${OUT}/served"
conformance_verdict "${PROFILE}" "${OUT}/served"

step "Host: a copy whose manifest says 1.0.1, resealed, must turn the pin red"
cp -R "${DIRECTORY}/bundled" "${WORK}/mutated-root"
jq '.version = "1.0.1"' "${WORK}/mutated-root/Workspace.koineprovider/manifest.json" >"${WORK}/manifest.json"
cp "${WORK}/manifest.json" "${WORK}/mutated-root/Workspace.koineprovider/manifest.json"
(cd "${TREE}" && Fixtures/FixtureProvider/seal.sh "${WORK}/mutated-root/Workspace.koineprovider")
python3 scripts/capture-retained-workspace.py "${CONFIGURATION}" "${WORK}/mutated-root" "${OUT}/mutated" "${CHECK}"
if "${CHECK}" --introspection "${OUT}/mutated/introspection.json" --profile "${PROFILE}" \
    --providers "${OUT}/mutated/providers.json" --served-digest "$(cat "${OUT}/mutated/digest")" \
    >"${OUT}/mutated/verdict.log" 2>&1; then
    sed 's/^/  /' "${OUT}/mutated/verdict.log"
    fail "the profile passed a bundle that says 1.0.1; it cannot be trusted when it passes"
fi
grep -q 'workspace 1.0.0 (schema 1.0.0, ACTIVE) is not served as expected; the host serves workspace 1.0.1' "${OUT}/mutated/verdict.log" || {
    sed 's/^/  /' "${OUT}/mutated/verdict.log"
    fail "the mutated bundle turned the check red without the pin problem it should name"
}
echo "  red: $(grep -m1 'is not served as expected' "${OUT}/mutated/verdict.log" | sed 's/^ *//')"
subject_unchanged "after the mutated host"

# --- subjects -----------------------------------------------------------------------

SUITES='WorkspaceProviderTests|WorkspaceCompositionTests|WorkspaceInstallationsCompositionTests|SchemaConformanceTests|ProviderCatalogueTests|WorkspaceProviderLogicTests'

step "Subjects: build the revision's tests"
(cd "${TREE}" && swift build -c "${CONFIGURATION}" --build-tests >/dev/null)

# install_bundled <root>: the bundled providers the tests' host loads, which the test
# bundle finds beside itself (Tests/KoineServerTests/DesktopProviderTests.swift).
install_bundled() {
    rm -rf "${PRODUCTS}/BundledProviders"
    /usr/bin/ditto "$1" "${PRODUCTS}/BundledProviders"
}
run_suites() { (cd "${TREE}" && swift test -c "${CONFIGURATION}" --skip-build --filter "$1" 2>&1); }

step "Subjects: the short-path N subjects must fail against a provider that reads a missing path (ENOENT) as unreadable"
# A copy of what the provider's build definition reads, with the one rule broken.
mkdir -p "${WORK}/mutated-tree/scripts" "${WORK}/mutated-tree/App"
cp -R "${TREE}/Providers" "${WORK}/mutated-tree/Providers"
cp "${TREE}/scripts/signing-env.sh" "${WORK}/mutated-tree/scripts/"
cp "${TREE}/App/Info.plist" "${WORK}/mutated-tree/App/"
python3 - "${WORK}/mutated-tree/Providers/WorkspaceProvider/Sources/NativeWorkspace.swift" <<'PY'
import sys
path = sys.argv[1]
text = open(path).read()
# `stat` failing with ENOENT is how a missing path is classified; take it out of absence.
broken = text.replace("case ENOENT, ENOTDIR, ELOOP, ENAMETOOLONG: return .absent", "case ENOTDIR, ELOOP, ENAMETOOLONG: return .absent")
if broken == text:
    raise SystemExit("the mutation changes nothing in the provider")
open(path, "w").write(broken)
PY
MUTATED="$("${WORK}/mutated-tree/Providers/WorkspaceProvider/build.sh" "${PRODUCTS}/PackageFrameworks" "${WORK}/mutated-out")"
(cd "${TREE}" && Fixtures/FixtureProvider/seal.sh "${MUTATED}")
mkdir -p "${WORK}/mutated-bundled"
/usr/bin/ditto "${DIRECTORY}/bundled" "${WORK}/mutated-bundled"
rm -rf "${WORK}/mutated-bundled/Workspace.koineprovider"
cp -R "${MUTATED}" "${WORK}/mutated-bundled/"
install_bundled "${WORK}/mutated-bundled"
if run_suites 'WorkspaceProviderTests' >"${OUT}/mutated-subjects.log"; then
    tail -20 "${OUT}/mutated-subjects.log" | sed 's/^/  /'
    fail "the short-path subjects passed a provider that reads a missing path (ENOENT) as unreadable; they cannot be trusted when they pass"
fi
grep -q 'aMissingPathADanglingLink' "${OUT}/mutated-subjects.log" || {
    tail -30 "${OUT}/mutated-subjects.log" | sed 's/^/  /'
    fail "the mutated provider failed the suite without failing the missing-path subjects"
}
echo "  red: $(grep -m1 'Test run with' "${OUT}/mutated-subjects.log" | sed 's/^[^T]*//')"

step "Subjects: the retained bundle, as the host's bundled root"
subject_unchanged "before the subjects"
install_bundled "${DIRECTORY}/bundled"
run_suites "${SUITES}" >"${OUT}/subjects.log" || {
    tail -40 "${OUT}/subjects.log" | sed 's/^/  /'
    fail "the retained bundle failed a subject it shipped with (${OUT}/subjects.log)"
}
subject_unchanged "after the subjects"
grep -E 'Test run with [0-9]+ tests? .*passed|Executed [0-9]+ tests' "${OUT}/subjects.log" | sed 's/^/  /'
grep -qE 'Test run with [1-9][0-9]* tests? .*passed' "${OUT}/subjects.log" || fail "no Swift Testing run was recorded as passed"
for suite in WorkspaceProviderTests WorkspaceCompositionTests; do
    grep -q "${suite}" "${OUT}/subjects.log" || fail "${suite} did not run"
done

step "PASSED: the retained workspace $(recorded release) bundle serves its SDL and profile and passes the subjects it shipped with"
