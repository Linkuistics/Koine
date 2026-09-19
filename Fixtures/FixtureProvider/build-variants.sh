#!/bin/bash
# Builds the deliberately bad bundles the native loader must refuse, and the few
# good ones that exercise what it must allow. Each case is its own provider
# root, <variants>/<case>/, holding exactly the bundle the case is about, since
# every refusal needs a real binary or a real manifest.
#
# A case the loader refuses before dlopen reuses the plain fixture's binary: it
# is never loaded. A case that reaches dlopen is compiled under its own tag, so
# its Objective-C class names and provider identifier are its own and several
# can load into one test process.
#
# usage: build-variants.sh <directory containing KoineProviderAPI.framework> \
#                          <root holding Fixture.koineprovider> <variants directory>
set -euo pipefail

FRAMEWORKS="$(cd "$1" && pwd)"
PLAIN="$(cd "$2" && pwd)/Fixture.koineprovider"
rm -rf "$3"
mkdir -p "$3"
VARIANTS="$(cd "$3" && pwd)"
HERE="$(cd "$(dirname "$0")" && pwd)"
API_SOURCES="${HERE}/../../ProviderAPI/Sources/KoineProviderAPI"
HOST_ARCH="$(uname -m)"
if [ "${HOST_ARCH}" = arm64 ]; then OTHER_ARCH=x86_64; else OTHER_ARCH=arm64; fi
TARGET="${HOST_ARCH}-apple-macos13.0"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

# edit_manifest <bundle> <python statements over the dict `m`>
edit_manifest() {
    python3 - "$1/manifest.json" "$2" <<'PY'
import json, sys
path, statements = sys.argv[1], sys.argv[2]
with open(path) as file:
    m = json.load(file)
exec(statements)
with open(path, "w") as file:
    json.dump(m, file, indent=2)
PY
}

# from_plain <case> <python statements>: the plain bundle with another manifest.
from_plain() {
    mkdir -p "${VARIANTS}/$1"
    cp -R "${PLAIN}" "${VARIANTS}/$1/"
    edit_manifest "${VARIANTS}/$1/Fixture.koineprovider" "$2"
}

# compiled <case> <tag>: prints the bundle. FIXTURE_* pass through to build.sh.
compiled() { FIXTURE_TAG="$2" "${HERE}/build.sh" "${FRAMEWORKS}" "${VARIANTS}/$1"; }

# --- Refused before dlopen -------------------------------------------------

from_plain malformed-manifest 'del m["framework"]'
from_plain unsupported-major 'm["framework"]["major"] = 2'
from_plain unavailable-minor 'm["framework"]["minimumMinor"] = 99'
from_plain missing-feature 'm["requiredFeatures"] = ["time-travel"]'
from_plain foreign-architecture "m['architectures'] = ['${OTHER_ARCH}']"
from_plain newer-os 'm["minimumOS"] = "99.0"'
from_plain newer-runtime 'm["minimumSwiftRuntime"] = "99.0"'
from_plain understated-os 'm["minimumOS"] = "12.0"'
from_plain principal-collision 'm["principalClass"] = "NSObject"'
from_plain library-outside-bundle \
    'm["library"] = "../../../FixtureProviders/Fixture.koineprovider/libFixtureProvider.dylib"'

# The manifest says the host's architecture; the binary holds the other one.
from_plain architecture-mismatch 'pass'
echo 'int koine_fixture_other_architecture(void) { return 0; }' >"${WORK}/other.c"
clang -dynamiclib -arch "${OTHER_ARCH}" -o \
    "${VARIANTS}/architecture-mismatch/Fixture.koineprovider/libFixtureProvider.dylib" "${WORK}/other.c"

# A copy of the framework inside the bundle.
from_plain bundled-framework 'pass'
mkdir -p "${VARIANTS}/bundled-framework/Fixture.koineprovider/Frameworks"
cp -R "${FRAMEWORKS}/KoineProviderAPI.framework" \
    "${VARIANTS}/bundled-framework/Fixture.koineprovider/Frameworks/"

# The framework's sources linked statically into the plugin, which also links
# the host's framework so that only the static copy is what is wrong with it.
mkdir -p "${WORK}/static"
swiftc -emit-object -parse-as-library -static -wmo -module-name KoineProviderAPI \
    -swift-version 6 -target "${TARGET}" -emit-module \
    -emit-module-path "${WORK}/static/KoineProviderAPI.swiftmodule" \
    -o "${WORK}/static/KoineProviderAPI.o" "${API_SOURCES}"/*.swift
FIXTURE_FRAMEWORK="-I ${WORK}/static ${WORK}/static/KoineProviderAPI.o -Xlinker -F${FRAMEWORKS} -Xlinker -needed_framework -Xlinker KoineProviderAPI" \
    compiled static-framework St >/dev/null

# A dependency that is neither the framework, a system library nor in the bundle.
mkdir -p "${WORK}/elsewhere"
echo 'int koine_fixture_elsewhere(void) { return 0; }' >"${WORK}/elsewhere.c"
clang -dynamiclib -target "${TARGET}" -install_name /opt/koine-fixture/libElsewhere.dylib \
    -o "${WORK}/elsewhere/libElsewhere.dylib" "${WORK}/elsewhere.c"
FIXTURE_SWIFTC="-L${WORK}/elsewhere -Xlinker -needed-lElsewhere" \
    compiled foreign-dependency Fd >/dev/null

# --- Reach dlopen ----------------------------------------------------------

# A validated private dependency inside the bundle: this one is good.
echo 'int koine_fixture_private(void) { return 0; }' >"${WORK}/private.c"
mkdir -p "${WORK}/private"
clang -dynamiclib -target "${TARGET}" -install_name @loader_path/libFixturePrivate.dylib \
    -o "${WORK}/private/libFixturePrivate.dylib" "${WORK}/private.c"
BUNDLE="$(FIXTURE_SWIFTC="-L${WORK}/private -Xlinker -needed-lFixturePrivate" \
    compiled private-dependency Pd)"
cp "${WORK}/private/libFixturePrivate.dylib" "${BUNDLE}/"

# Built against a framework with a declaration this host's does not have, under
# a manifest that still claims minor 0: the dynamic loader refuses it.
mkdir -p "${WORK}/newer"
echo 'public func koineProviderFrameworkFutureAddition() {}' >"${WORK}/newer/Future.swift"
swiftc -emit-library -parse-as-library -enable-library-evolution -wmo \
    -module-name KoineProviderAPI -swift-version 6 -target "${TARGET}" -emit-module \
    -emit-module-path "${WORK}/newer/KoineProviderAPI.swiftmodule" \
    -Xlinker -install_name \
    -Xlinker @rpath/KoineProviderAPI.framework/Versions/A/KoineProviderAPI \
    -o "${WORK}/newer/libKoineProviderAPI.dylib" "${API_SOURCES}"/*.swift "${WORK}/newer/Future.swift"
FIXTURE_FRAMEWORK="-I ${WORK}/newer -L${WORK}/newer -lKoineProviderAPI" \
    FIXTURE_SWIFTC="-D FIXTURE_NEEDS_NEWER_FRAMEWORK" compiled newer-framework Nf >/dev/null

BUNDLE="$(compiled missing-principal Mp)"
edit_manifest "${BUNDLE}" 'm["principalClass"] = "KoineFixtureMpAbsentFactory"'

BUNDLE="$(compiled not-a-factory Nt)"
edit_manifest "${BUNDLE}" 'm["principalClass"] = "KoineFixtureNtNotAFactory"'

BUNDLE="$(compiled descriptor-disagrees Dd)"
edit_manifest "${BUNDLE}" 'm["providerId"] = "somethingelse"'

FIXTURE_SWIFTC="-D FIXTURE_FAILS_START" compiled failed-start Fs >/dev/null

echo "${VARIANTS}"
