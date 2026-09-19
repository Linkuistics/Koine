#!/bin/bash
# Builds the binaries of the binary compatibility pairs
# (docs/verification/binary-compatibility.md) from two framework revisions, each
# in its own copy of the source tree with its own build directory:
#
#   baseline  this working tree as it is: framework 1.0, its host and its fixture
#   newer     the same tree with the evidence-only framework minor 1 applied
#             (Fixtures/CompatibilityPairs/Minor1.swift, a defaulted `Provider`
#             requirement, and a host that supplies 1.1) and its host
#   later     later revisions of the fixture, from the newer tree's source
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

# copy_tree <revision>: the sources alone; each copy keeps its own .build.
copy_tree() {
    mkdir -p "${PAIRS}/$1/src"
    rsync -a --delete --exclude .build --exclude .git --exclude .jj --exclude .grove \
        --exclude .playwright-mcp ./ "${PAIRS}/$1/src/"
}

# build_tree <revision>: the host, the staged framework, the plain fixture and
# the loader's variants, exactly as `task test` builds them.
build_tree() {
    (
        cd "${PAIRS}/$1/src"
        swift build -c "${CONFIGURATION}" --product KoineCompatibilityHost >&2
        FRAMEWORK="$(scripts/stage-provider-framework.sh "${CONFIGURATION}")"
        PRODUCTS="$(dirname "$(dirname "${FRAMEWORK}")")"
        Fixtures/FixtureProvider/build.sh "${PRODUCTS}/PackageFrameworks" \
            "${PRODUCTS}/FixtureProviders" >&2
        Fixtures/FixtureProvider/build-variants.sh "${PRODUCTS}/PackageFrameworks" \
            "${PRODUCTS}/FixtureProviders" "${PRODUCTS}/FixtureVariants" >&2
        # A release executable's run path is its own directory alone; a debug
        # one also has PackageFrameworks. Either way the host finds the staged framework.
        ln -sfn PackageFrameworks/KoineProviderAPI.framework "${PRODUCTS}/KoineProviderAPI.framework"
        rm -f "${PAIRS}/$1/products"
        ln -s "${PRODUCTS}" "${PAIRS}/$1/products"
    )
}

copy_tree baseline
copy_tree newer

# The newer revision. Each edit asserts what it replaces, so a source change
# that would make the overlay silently miss fails here instead.
cp Fixtures/CompatibilityPairs/Minor1.swift \
    "${PAIRS}/newer/src/ProviderAPI/Sources/KoineProviderAPI/Minor1.swift"
python3 - "${PAIRS}/newer/src" <<'PY'
import sys
tree = sys.argv[1]
def edit(path, old, new):
    path = f"{tree}/{path}"
    with open(path) as file:
        text = file.read()
    if text.count(old) != 1:
        sys.exit(f"Error: expected exactly one {old!r} in {path}.")
    with open(path, "w") as file:
        file.write(text.replace(old, new))
edit("Sources/KoineProviderLoader/ProviderLoader.swift",
     "public static let frameworkMinor = 0", "public static let frameworkMinor = 1")
edit("ProviderAPI/Sources/KoineProviderAPI/ProviderFactory.swift",
     "    func stop() async\n}",
     "    func stop() async\n    /// Added in framework minor 1; defaulted in Minor1.swift.\n"
     "    func describeInstance() -> String\n}")
edit("ProviderAPI/Info.plist", "<string>1.0.0</string>", "<string>1.1.0</string>")
PY

build_tree baseline
build_tree newer

# later_fixture <case> <framework revision> <swiftc flags> <python over the manifest `m`>:
# a later revision of the fixture, from the newer tree's source, compiled against
# the named revision's staged framework as a plugin author's SDK.
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

# Newer source for the baseline: compiled against framework 1.0, it uses no newer
# declaration and declares no newer requirement.
later_fixture revision2 baseline "-D FIXTURE_REVISION_2" 'm["version"] = "1.1.0"'
# The same source and the same claim, compiled against framework 1.1. Its
# conformance to `Provider` records the default of the requirement 1.1 added, so
# the binary needs 1.1 although its source uses nothing new: the manifest lies.
later_fixture revision2-built-against-newer newer "-D FIXTURE_REVISION_2" \
    'm["version"] = "1.1.0"'
# The same source using the newer declarations, which it declares.
later_fixture minor1 newer "-D FIXTURE_USES_MINOR_1" \
    'm["version"] = "1.1.0"; m["framework"]["minimumMinor"] = 1'

echo "${PAIRS}"
