#!/bin/bash
# The fixture provider's own build definition. It compiles against the staged
# KoineProviderAPI.framework alone (its textual module interface and its image),
# never the framework's sources or the root package, and links the host's
# framework image dynamically: the bundle embeds no copy.
#
# usage: build.sh <directory containing KoineProviderAPI.framework> <provider root>
#
# build-variants.sh drives the same recipe through the environment:
#   FIXTURE_TAG       renames every Fixture/fixture identifier (FixturePd,
#                     fixturepd), so several variants can load into one process
#   FIXTURE_SWIFTC    extra swiftc arguments, space separated
#   FIXTURE_FRAMEWORK swiftc arguments that supply the KoineProviderAPI module and
#                     link it, in place of the staged framework's
# Both are split on spaces: this is test material built under .build.
set -euo pipefail

FRAMEWORKS="$(cd "$1" && pwd)"
mkdir -p "$2"
ROOT="$(cd "$2" && pwd)"
cd "$(dirname "$0")"

TAG="${FIXTURE_TAG:-}"
LOWER_TAG="$(echo "${TAG}" | tr '[:upper:]' '[:lower:]')"
BUNDLE="${ROOT}/Fixture${TAG}.koineprovider"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

# Type names and root fields carry the prefix (FixturePd, fixturePdInfo); the
# provider identifier, alone, is lower case (fixturepd).
tagged() {
    sed -e "s/Fixture/Fixture${TAG}/g" -e "s/fixture\([A-Z]\)/fixture${TAG}\1/g" \
        -e "s/fixture\([^A-Za-z]\)/fixture${LOWER_TAG}\1/g" "$1"
}

tagged FixtureProvider.swift >"${WORK}/FixtureProvider.swift"
tagged schema.graphql >"${WORK}/schema.graphql"
{
    echo "let fixture${TAG}SchemaSDL = #\"\"\""
    cat "${WORK}/schema.graphql"
    echo '"""#'
} >"${WORK}/SchemaSDL.swift"
clang -c -target "$(uname -m)-apple-macos13.0" -o "${WORK}/initializer.o" initializer.c

rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}"
# shellcheck disable=SC2086  # both are argument lists
swiftc -emit-library -module-name "Fixture${TAG}Provider" -swift-version 6 \
    -target "$(uname -m)-apple-macos13.0" \
    ${FIXTURE_FRAMEWORK:--F ${FRAMEWORKS} -framework KoineProviderAPI} \
    -Xlinker -install_name -Xlinker "@rpath/libFixture${TAG}Provider.dylib" \
    ${FIXTURE_SWIFTC:-} \
    -o "${BUNDLE}/libFixture${TAG}Provider.dylib" \
    "${WORK}/FixtureProvider.swift" "${WORK}/SchemaSDL.swift" "${WORK}/initializer.o"
tagged manifest.json | sed "s/@ARCH@/$(uname -m)/" >"${BUNDLE}/manifest.json"
cp "${WORK}/schema.graphql" "${BUNDLE}/"

echo "${BUNDLE}"
