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
# Every bundle is sealed and approved in its root (seal.sh) once its content is
# final, so each of the first two groups is refused, or loads, for its own
# reason. The last group is what trust itself refuses. Every variant's content is
# its own (a `variant` key the manifest reader ignores): a staged copy is named
# by its content, and the tests tell variants apart by it.
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
# shellcheck source=../../scripts/signing-env.sh
source "${HERE}/../../scripts/signing-env.sh"
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
    edit_manifest "${VARIANTS}/$1/Fixture.koineprovider" "m['variant'] = '$1'; $2"
}

# compiled <case> <tag>: prints the bundle. FIXTURE_* pass through to build.sh.
compiled() {
    FIXTURE_UNSEALED=1 FIXTURE_TAG="$2" "${HERE}/build.sh" "${FRAMEWORKS}" "${VARIANTS}/$1"
}

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
# The bundle is loaded from a staged copy, so the way out is by way of the root
# directory: `..` at / is /.
from_plain library-outside-bundle \
    "m['library'] = '../' * 64 + '${PLAIN#/}/libFixtureProvider.dylib'"

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

for BUNDLE in "${VARIANTS}"/*/*.koineprovider; do "${HERE}/seal.sh" "${BUNDLE}"; done

# --- Refused by trust, before dlopen ---------------------------------------

TEAM="$(codesign -dvv "${PLAIN}" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
# approve <case> <team>: the record a user would place, for provider `fixture`.
approve() {
    printf '{ "providerId": "fixture", "teamIdentifier": "%s" }\n' "$2" \
        >"${VARIANTS}/$1/fixture.approval.json"
}

# Sealed by Koine's identity, and nobody approved it.
from_plain unapproved 'pass'
FIXTURE_UNAPPROVED=1 "${HERE}/seal.sh" "${VARIANTS}/unapproved/Fixture.koineprovider"

from_plain unsigned 'pass'
codesign --remove-signature "${VARIANTS}/unsigned/Fixture.koineprovider"
approve unsigned "${TEAM}"

# An ad-hoc signature is a different identity; no second certificate is needed.
from_plain adhoc-signed 'pass'
codesign --force --sign - "${VARIANTS}/adhoc-signed/Fixture.koineprovider" 2>/dev/null
approve adhoc-signed "${TEAM}"

# Good, and approved by a file, in a root whose approvals are not files.
from_plain bundled-unapproved 'pass'
"${HERE}/seal.sh" "${VARIANTS}/bundled-unapproved/Fixture.koineprovider"

# An update whose identity is not the one its record approved.
from_plain identity-mismatch 'pass'
FIXTURE_UNAPPROVED=1 "${HERE}/seal.sh" "${VARIANTS}/identity-mismatch/Fixture.koineprovider"
approve identity-mismatch ZZZZZZZZZZ

# A record whose identity is not a Team ID never reaches a requirement string.
from_plain malformed-approval 'pass'
FIXTURE_UNAPPROVED=1 "${HERE}/seal.sh" "${VARIANTS}/malformed-approval/Fixture.koineprovider"
approve malformed-approval '\" or anchor apple generic or \"'

# Changed after it was sealed.
from_plain tampered 'pass'
"${HERE}/seal.sh" "${VARIANTS}/tampered/Fixture.koineprovider"
edit_manifest "${VARIANTS}/tampered/Fixture.koineprovider" 'm["variant"] = "tampered with"'

# A link out of the root, to a bundle that is otherwise good and approved here.
from_plain escapes-root.elsewhere 'pass'
"${HERE}/seal.sh" "${VARIANTS}/escapes-root.elsewhere/Fixture.koineprovider"
mkdir -p "${VARIANTS}/escapes-root"
ln -s ../escapes-root.elsewhere/Fixture.koineprovider "${VARIANTS}/escapes-root/Fixture.koineprovider"
approve escapes-root "${TEAM}"

# A private dependency somebody else signed, inside a bundle Koine's identity sealed.
BUNDLE="$(FIXTURE_SWIFTC="-L${WORK}/private -Xlinker -needed-lFixturePrivate" \
    compiled unapproved-dependency Ud)"
cp "${WORK}/private/libFixturePrivate.dylib" "${BUNDLE}/"
"${HERE}/seal.sh" "${BUNDLE}"
codesign --force --sign - "${BUNDLE}/libFixturePrivate.dylib" 2>/dev/null
codesign --force --timestamp=none --sign "${SIGNING_IDENTITY}" "${BUNDLE}" 2>/dev/null

echo "${VARIANTS}"
