#!/bin/bash
# The fixture provider's own build definition. It compiles against the staged
# KoineProviderAPI.framework alone (its textual module interface and its image),
# never the framework's sources or the root package, and links the host's
# framework image dynamically: the bundle embeds no copy.
#
# usage: build.sh <directory containing KoineProviderAPI.framework> <provider root>
set -euo pipefail

FRAMEWORKS="$(cd "$1" && pwd)"
mkdir -p "$2"
ROOT="$(cd "$2" && pwd)"
cd "$(dirname "$0")"

BUNDLE="${ROOT}/Fixture.koineprovider"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

{
    echo 'let fixtureSchemaSDL = #"""'
    cat schema.graphql
    echo '"""#'
} >"${WORK}/SchemaSDL.swift"

rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}"
swiftc -emit-library -module-name FixtureProvider -swift-version 6 \
    -target "$(uname -m)-apple-macos13.0" \
    -F "${FRAMEWORKS}" -framework KoineProviderAPI \
    -Xlinker -install_name -Xlinker @rpath/libFixtureProvider.dylib \
    -o "${BUNDLE}/libFixtureProvider.dylib" \
    FixtureProvider.swift "${WORK}/SchemaSDL.swift"
cp manifest.json schema.graphql "${BUNDLE}/"

echo "${BUNDLE}"
