#!/bin/bash
# Builds the binaries of the binary compatibility pairs
# (docs/verification/binary-compatibility.md) from two independent revisions,
# each in its own copy of the source tree with its own build directory:
#
#   baseline  the RELEASED revision (v0.1.0, or KOINE_BASELINE_REVISION): framework
#             1.0, before the additional-capabilities feature, with its host,
#             fixture and desktop provider (scripts/build-baseline-host.sh)
#   newer     this working tree as it is: framework 1.1, which serves
#             `additional-capabilities-v1`, with its host and fixture
#   later     later revisions of the fixture, from the newer tree's source, each
#             compiled against the framework its name says
#   workspace the newer tree's workspace provider (release/schema 1.0.1), sealed and
#             approved as the application seals it (newer/products/WorkspaceProviders),
#             and the same source stating first-party-selection-v1, which an earlier
#             host requires of a per-user update (newer/workspace-per-user). Its old
#             side is the RETAINED 1.0.0 bundle scripts/build-retained-workspace.sh
#             keeps apart under workspace-1.0.0: it must exist first, and is never
#             rebuilt here.
#
# Nothing built in one tree sees the other: a pair is put together only when
# scripts/verify-compat-pairs.py installs one tree's bundle under the other
# tree's host. Every bundle is sealed and approved as Fixtures/FixtureProvider
# does it, so signing needs the identity of scripts/signing-env.sh.
#
# usage: build-compat-pairs.sh [debug|release]   (prints the pairs directory)
set -euo pipefail

cd "$(dirname "$0")/.."
CONFIGURATION="${1:-debug}"
PAIRS="$(pwd)/.build/compat/${CONFIGURATION}"
mkdir -p "${PAIRS}"
[ -f "${PAIRS}/workspace-1.0.0/retained.json" ] || {
    echo "Error: ${PAIRS}/workspace-1.0.0/retained.json does not exist. Run: task compat:workspace-baseline" >&2
    exit 1
}

# The old side is the released source, never a copy of this tree with edits.
scripts/build-baseline-host.sh "${CONFIGURATION}" >/dev/null

# The new side: this tree's sources alone; the copy keeps its own .build.
mkdir -p "${PAIRS}/newer/src"
rsync -a --delete --exclude .build --exclude .git --exclude .jj --exclude .grove \
    --exclude .playwright-mcp ./ "${PAIRS}/newer/src/"
scripts/build-compat-tree.sh "${CONFIGURATION}" "${PAIRS}/newer/src" "${PAIRS}/newer"
# The conformance check the release runs, to read what the new host serves.
(cd "${PAIRS}/newer/src" && swift build -c "${CONFIGURATION}" --product KoineConformance >&2)

# later_fixture <case> <framework revision> <swiftc flags> <python over the manifest `m`>:
# a later revision of the fixture, from the newer tree's source, compiled against
# the named revision's staged framework as a plugin author's SDK. FIXTURE_ADDITIONAL
# (in the environment) also puts the additional-capability field in its schema.
later_fixture() {
    (
        cd "${PAIRS}/newer/src"
        ROOT="${PAIRS}/later/$1"
        rm -rf "${ROOT}"
        BUNDLE="$(FIXTURE_UNSEALED=1 FIXTURE_SWIFTC="$3" Fixtures/FixtureProvider/build.sh \
            "${PAIRS}/$2/products/PackageFrameworks" "${ROOT}")"
        python3 - "${BUNDLE}/manifest.json" "$4" <<'PY'
import json, sys
with open(sys.argv[1]) as file:
    m = json.load(file)
exec(sys.argv[2])
with open(sys.argv[1], "w") as file:
    json.dump(m, file, indent=2)
PY
        Fixtures/FixtureProvider/seal.sh "${BUNDLE}"
    )
}

FEATURE='additional-capabilities-v1'

# Newer source for the baseline: compiled against framework 1.0, it uses no newer
# declaration and declares no newer requirement.
later_fixture revision2 baseline "-D FIXTURE_REVISION_2" 'm["version"] = "1.1.0"'
# The same source and the same claim, compiled against framework 1.1. This minor
# adds no requirement to a protocol, so its conformance records no default for one
# and the binary needs nothing 1.1 added: the manifest does not lie.
later_fixture revision2-built-against-newer newer "-D FIXTURE_REVISION_2" \
    'm["version"] = "1.1.0"'
# The same source using the feature, which it declares in the manifest and the
# descriptor, with the minimum minor that carries it.
export FIXTURE_ADDITIONAL=1
later_fixture additional newer "-D FIXTURE_ADDITIONAL" \
    "m['version'] = '1.1.0'; m['framework']['minimumMinor'] = 1; m['requiredFeatures'] = ['${FEATURE}']"
# The feature declared but the minimum minor left at 0: an old host is refused by
# the feature alone, which is the refusal the minor check would otherwise pre-empt.
later_fixture additional-feature-only newer "-D FIXTURE_ADDITIONAL" \
    "m['version'] = '1.1.0'; m['requiredFeatures'] = ['${FEATURE}']"
# The use with no declaration in the descriptor or the manifest: a host that has
# the feature must refuse it, because ignoring the set would be a silent fallback.
later_fixture additional-undeclared newer "-D FIXTURE_ADDITIONAL -D FIXTURE_UNDECLARED" \
    "m['version'] = '1.1.0'; m['framework']['minimumMinor'] = 1"
# A descriptor that declares the feature under a manifest that does not.
later_fixture additional-manifest-omits newer "-D FIXTURE_ADDITIONAL" \
    "m['version'] = '1.1.0'; m['framework']['minimumMinor'] = 1"
unset FIXTURE_ADDITIONAL

# The workspace provider of the newer tree, by its own build definition against that tree's
# framework, sealed and approved as the application seals it; then the same source with the
# feature a per-user update must state. Nothing here is the retained bundle or built from it.
(
    cd "${PAIRS}/newer/src"
    WORK="$(mktemp -d)"
    trap 'rm -rf "${WORK}"' EXIT
    # shellcheck source=scripts/first-party-update-lib.sh
    source scripts/first-party-update-lib.sh
    PRODUCTS="$(cd "${PAIRS}/newer/products" && pwd -P)"
    rm -rf "${PRODUCTS}/WorkspaceProviders" "${PAIRS}/newer/workspace-per-user"
    BUNDLE="$(Providers/WorkspaceProvider/build.sh "${PRODUCTS}/PackageFrameworks" "${PRODUCTS}/WorkspaceProviders")"
    Fixtures/FixtureProvider/seal.sh "${BUNDLE}" >&2
    VARIANT_TREE="$(tree variant)"
    state_feature_in_workspace "${VARIANT_TREE}"
    VARIANT="$("${VARIANT_TREE}/Providers/WorkspaceProvider/build.sh" "${PRODUCTS}/PackageFrameworks" "${WORK}/variant")"
    edit "${VARIANT}" "m['requiredFeatures'] = m['requiredFeatures'] + ['${FEATURE}']"
    mkdir -p "${PAIRS}/newer/workspace-per-user"
    cp -R "${VARIANT}" "${PAIRS}/newer/workspace-per-user/"
    Fixtures/FixtureProvider/seal.sh "${PAIRS}/newer/workspace-per-user/Workspace.koineprovider" >&2
)

echo "${PAIRS}"
