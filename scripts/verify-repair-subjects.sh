#!/bin/bash
# Repeats, against the 1.0.1 workspace bundle, every short-path subject the RETAINED 1.0.0 revision
# shipped with, so that no incompatible meaning and no short-workflow loss can pass unseen.
#
# The subjects are the retained revision's own suites, unedited: `WorkspaceProviderTests` (N: the
# signed bundle loaded by a host over loopback HTTP; every short-path workflow, a missing path, a
# dangling link, a loop, an application that is absent or the wrong one, every refusal) and
# `WorkspaceCompositionTests` and `WorkspaceInstallationsCompositionTests` (G). They run in a copy
# of the retained tree (never this tree's tests), built on their own, with the in-application root
# holding the retained desktop provider and the released Koine 0.3.0's workspace 1.0.1 as the
# sealed, approved bundle that application shipped (scripts/build-retained-workspace.sh with
# scripts/retained-workspace-1.0.1.json). It is not this tree's workspace 1.0.2: that bundle needs
# `workspace-native-disclosures-v1`, which no host the retained revision builds advertises, so
# 1.0.2 is refused by design and its short-path workflows are held by this tree's own suites.
#
# Two inputs of those suites name the release the bundle is, and are the repair's own changes:
# the shipped catalogue the suites hold the bundle to (App/ProviderCatalogue.json of the copy,
# whose workspace entry is moved to 1.0.1/1.0.1, as the repair's catalogue entry is), and, inside
# the suites, the one assertion that the loaded rows say release 1.0.0
# (`theSignedBundleLoadsBesideDesktopFromTheInApplicationRoot`, at WorkspaceProviderTests.swift:65).
# That test is expected to fail, naming that line, and nothing else is: any other failure is a
# finding. (`theServedSDLIsTheCompleteWorkspaceDesignVerbatim` holds the copy's own provider
# SOURCE to the 1.0.0 design file, not the bundle, so it says nothing of 1.0.1 and passes; what
# the bundle serves is held to the 1.0.1 design by the pairs of scripts/verify-compat-pairs.py.)
#
# The instrument is first seen red: a 1.0.1 provider with the missing-path rule broken (a missing
# component read as a failure, not as absence) must fail the missing-path subjects. Nothing here
# edits this tree's source: the broken provider is built from a copy.
#
# usage: verify-repair-subjects.sh [debug|release]
set -euo pipefail

cd "$(dirname "$0")/.."
CONFIGURATION="${1:-debug}"
REPOSITORY="$(pwd)"
PAIRS="${REPOSITORY}/.build/compat/${CONFIGURATION}"
RETAINED="${PAIRS}/workspace-1.0.0"
RELEASED="${PAIRS}/workspace-1.0.1"
SUBJECTS="${PAIRS}/workspace-1.0.1-subjects"
TREE="${SUBJECTS}/src"
PIN="scripts/retained-workspace-1.0.0.json"
OUT="${SUBJECTS}/verification"

step() { printf '\n== %s\n' "$*"; }
fail() { printf 'FAILED: %s\n' "$*" >&2; exit 1; }

[ -f "${RETAINED}/retained.json" ] || fail "${RETAINED}/retained.json does not exist. Run: task compat:workspace-baseline"
[ -f "${RELEASED}/retained.json" ] || fail "${RELEASED}/retained.json does not exist. Run: task compat:workspace-release"
[ -d "${RELEASED}/bundled/Workspace.koineprovider" ] ||
    fail "the released Koine 0.3.0's workspace bundle is not built. Run: task compat:workspace-release"
SHIPPED="${RELEASED}/bundled"
sha() { shasum -a 256 "$1" | cut -d' ' -f1; }

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT
mkdir -p "${SUBJECTS}"
rm -rf "${OUT}"
mkdir -p "${OUT}"

# The subject's digests, before and after every step that runs against it.
digest_of() { for f in manifest.json schema.graphql libWorkspaceProvider.dylib; do sha "${SHIPPED}/Workspace.koineprovider/${f}"; done | shasum -a 256 | cut -d' ' -f1; }
SUBJECT="$(digest_of)"
unchanged() { [ "$(digest_of)" = "${SUBJECT}" ] || fail "$1: the 1.0.1 bundle changed under the run"; }

step "Extract the retained revision's tree, tests unedited"
if [ "$(cat "${TREE}/.koine-retained-commit" 2>/dev/null || true)" != "$(jq -r .commit "${PIN}")" ]; then
    rm -rf "${TREE}"
fi
mkdir -p "${TREE}"
rsync -a --delete --exclude .build "${RETAINED}/src/" "${TREE}/"
[ "$(cat "${TREE}/.koine-retained-commit")" = "$(jq -r .commit "${PIN}")" ] || fail "the extracted tree is not the pinned revision"
diff -r "${RETAINED}/src/Tests" "${TREE}/Tests" >/dev/null || fail "the tests were edited"
echo "  revision $(jq -r .commit "${PIN}"), Tests identical to the retained tree's"

step "Move the copy's catalogue entry for workspace to the repair's release and schema"
python3 - "${TREE}/App/ProviderCatalogue.json" "${RELEASED}/src/App/ProviderCatalogue.json" <<'PY'
import json, sys
copy_path, shipped_path = sys.argv[1:3]
with open(copy_path) as file:
    copy = json.load(file)
with open(shipped_path) as file:
    shipped = json.load(file)
want = next(e for e in shipped["identities"] if e["providerId"] == "workspace")
entry = next(e for e in copy["identities"] if e["providerId"] == "workspace")
if (entry["release"], entry["schema"]) == (want["release"], want["schema"]):
    sys.exit("the copy's catalogue already says the repair's release: nothing would change")
entry["release"], entry["schema"] = want["release"], want["schema"]
for key in ("bundle", "signingIdentifier", "graphQLPrefix"):
    if entry[key] != want[key]:
        sys.exit(f"the copy's workspace entry differs from this tree's in {key}: {entry[key]} / {want[key]}")
with open(copy_path, "w") as file:
    json.dump(copy, file, indent=2)
print(f"  workspace {entry['release']} / schema {entry['schema']}, signed {entry['signingIdentifier']}")
PY

step "Build the copy's host, framework, fixtures and tests"
"${TREE}/scripts/build-compat-tree.sh" "${CONFIGURATION}" "${TREE}" "${SUBJECTS}" >/dev/null
PRODUCTS="$(cd "${SUBJECTS}/products" && pwd -P)"
(cd "${TREE}" && swift build -c "${CONFIGURATION}" --build-tests >/dev/null)

SUITES='WorkspaceProviderTests|WorkspaceCompositionTests|WorkspaceInstallationsCompositionTests'
# install_bundled <workspace bundle's directory>: the in-application root the suites' host loads, which
# the test bundle finds beside itself. The desktop provider is the retained revision's own.
install_bundled() {
    rm -rf "${PRODUCTS}/BundledProviders"
    mkdir -p "${PRODUCTS}/BundledProviders"
    /usr/bin/ditto "${RETAINED}/bundled/Desktop.koineprovider" "${PRODUCTS}/BundledProviders/Desktop.koineprovider"
    cp "${RETAINED}/bundled/desktop.approval.json" "${PRODUCTS}/BundledProviders/"
    /usr/bin/ditto "$1/Workspace.koineprovider" "${PRODUCTS}/BundledProviders/Workspace.koineprovider"
    cp "$1/workspace.approval.json" "${PRODUCTS}/BundledProviders/"
}
run_suites() { (cd "${TREE}" && swift test -c "${CONFIGURATION}" --skip-build --filter "$1" 2>&1); }

step "Control: a 1.0.1 provider that reads a missing component as a failure must fail the missing-path subjects"
mkdir -p "${WORK}/mutated-tree/scripts" "${WORK}/mutated-tree/App"
cp -R "${RELEASED}/src/Providers" "${WORK}/mutated-tree/Providers"
cp "${RELEASED}/src/scripts/signing-env.sh" "${WORK}/mutated-tree/scripts/"
cp "${RELEASED}/src/App/Info.plist" "${WORK}/mutated-tree/App/"
python3 - "${WORK}/mutated-tree/Providers/WorkspaceProvider/Logic/LocationWalk.swift" <<'PY'
import sys
path = sys.argv[1]
text = open(path).read()
broken = text.replace("case ENOENT: return .absent(.missing(component: component))",
                      "case ENOENT: return .failed(component: component, cause: error.message)")
if broken == text:
    raise SystemExit("the mutation changes nothing in the provider")
open(path, "w").write(broken)
PY
MUTATED="$("${WORK}/mutated-tree/Providers/WorkspaceProvider/build.sh" "${RELEASED}/products/PackageFrameworks" "${WORK}/mutated-out")"
(cd "${RELEASED}/src" && Fixtures/FixtureProvider/seal.sh "${MUTATED}")
install_bundled "${WORK}/mutated-out"
if run_suites 'WorkspaceProviderTests' >"${OUT}/mutated.log"; then
    tail -20 "${OUT}/mutated.log" | sed 's/^/  /'
    fail "the subjects passed a 1.0.1 provider that reads a missing component as a failure; they cannot be trusted when they pass"
fi
grep -q 'aMissingPathADanglingLink' "${OUT}/mutated.log" || {
    tail -30 "${OUT}/mutated.log" | sed 's/^/  /'
    fail "the mutated provider failed the suite without failing the missing-path subjects"
}
echo "  red: $(grep -m1 'Test run with' "${OUT}/mutated.log" | sed 's/^[^T]*//')"

step "Subjects: the retained suites against the 1.0.1 bundle"
unchanged "before the subjects"
install_bundled "${SHIPPED}"
run_suites "${SUITES}" >"${OUT}/subjects.log" || true
unchanged "after the subjects"
grep -E 'Test run with [0-9]+ tests?' "${OUT}/subjects.log" | sed 's/^/  /'
EXPECTED='theSignedBundleLoadsBesideDesktopFromTheInApplicationRoot()'
FAILED="$(sed -n 's/^.* Test \([A-Za-z0-9_]*()\) failed after .*$/\1/p' "${OUT}/subjects.log" | sort -u)"
if [ "${FAILED}" != "${EXPECTED}" ]; then
    tail -40 "${OUT}/subjects.log" | sed 's/^/  /'
    printf 'failed:\n%s\nexpected:\n%s\n' "${FAILED}" "${EXPECTED}" >&2
    fail "the subjects that failed are not exactly the one that pins the release (${OUT}/subjects.log)"
fi
grep -q 'WorkspaceProviderTests.swift:65:13: Expectation failed: row\["version"\] as? String == "1.0.0"' "${OUT}/subjects.log" ||
    fail "that test did not fail on the release assertion it pins"
for suite in WorkspaceProviderTests WorkspaceCompositionTests WorkspaceInstallationsCompositionTests; do
    grep -q "${suite}" "${OUT}/subjects.log" || fail "${suite} did not run"
done
echo "  failed, as expected, and only these: $(echo "${FAILED}" | tr '\n' ' ')"

step "PASSED: every retained short-path subject passes against workspace 1.0.1 but the one assertion that names release 1.0.0"
