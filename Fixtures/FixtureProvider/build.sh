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
#   FIXTURE_UNSEALED  leaves the bundle unsigned and unapproved; build-variants.sh
#                     seals every variant itself, once its content is final
#   FIXTURE_ADDITIONAL  adds additional.graphql to the schema; with
#                     FIXTURE_SWIFTC="-D FIXTURE_ADDITIONAL" it registers that
#                     field's additional requirement (framework minor 1)
#   FIXTURE_STEM      names the provider outright instead of `Fixture<TAG>`: the type
#                     and root-field prefix (`Unknown`, `unknownInfo`), the provider
#                     identifier (`unknown`), the bundle and image names. The selection
#                     acceptance uses it for a real provider named `unknown`.
#   FIXTURE_EXTRA_SDL a file of SDL appended to the schema, after the tagging: a
#                     descriptor that claims names the manifest does not.
# Both argument lists are split on spaces: this is test material built under .build.
#
# The bundle is a shallow code-signing bundle: Info.plist at its root names the
# dylib as its executable, so one signature seals the dylib, manifest and schema.
set -euo pipefail

FRAMEWORKS="$(cd "$1" && pwd)"
mkdir -p "$2"
ROOT="$(cd "$2" && pwd)"
cd "$(dirname "$0")"

TAG="${FIXTURE_TAG:-}"
STEM="${FIXTURE_STEM:-Fixture${TAG}}"
LOWER_STEM="$(echo "${STEM}" | tr '[:upper:]' '[:lower:]')"
HEAD_STEM="$(echo "${STEM:0:1}" | tr '[:upper:]' '[:lower:]')${STEM:1}"
BUNDLE="${ROOT}/${STEM}.koineprovider"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

# Type names and root fields carry the prefix (FixturePd, fixturePdInfo); the
# provider identifier, alone, is lower case (fixturepd).
tagged() {
    sed -e "s/Fixture/${STEM}/g" -e "s/fixture\([A-Z]\)/${HEAD_STEM}\1/g" \
        -e "s/fixture\([^A-Za-z]\)/${LOWER_STEM}\1/g" "$1"
}

tagged FixtureProvider.swift >"${WORK}/FixtureProvider.swift"
tagged schema.graphql >"${WORK}/schema.graphql"
if [ -n "${FIXTURE_ADDITIONAL:-}" ]; then
    printf '\n' >>"${WORK}/schema.graphql"
    tagged additional.graphql >>"${WORK}/schema.graphql"
fi
if [ -n "${FIXTURE_EXTRA_SDL:-}" ]; then
    printf '\n' >>"${WORK}/schema.graphql"
    cat "${FIXTURE_EXTRA_SDL}" >>"${WORK}/schema.graphql"
fi
{
    echo "let ${HEAD_STEM}SchemaSDL = #\"\"\""
    cat "${WORK}/schema.graphql"
    echo '"""#'
} >"${WORK}/SchemaSDL.swift"
clang -c -target "$(uname -m)-apple-macos13.0" -o "${WORK}/initializer.o" initializer.c

rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}"
# shellcheck disable=SC2086  # both are argument lists
swiftc -emit-library -module-name "${STEM}Provider" -swift-version 6 \
    -target "$(uname -m)-apple-macos13.0" \
    ${FIXTURE_FRAMEWORK:--F ${FRAMEWORKS} -framework KoineProviderAPI} \
    -Xlinker -install_name -Xlinker "@rpath/lib${STEM}Provider.dylib" \
    ${FIXTURE_SWIFTC:-} \
    -o "${BUNDLE}/lib${STEM}Provider.dylib" \
    "${WORK}/FixtureProvider.swift" "${WORK}/SchemaSDL.swift" "${WORK}/initializer.o"
tagged manifest.json | sed "s/@ARCH@/$(uname -m)/" >"${BUNDLE}/manifest.json"
cp "${WORK}/schema.graphql" "${BUNDLE}/"
cat >"${BUNDLE}/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>dev.antony.Koine.provider.${LOWER_STEM}</string>
<key>CFBundleExecutable</key><string>lib${STEM}Provider.dylib</string>
<key>CFBundlePackageType</key><string>BNDL</string>
</dict></plist>
PLIST
[ -n "${FIXTURE_UNSEALED:-}" ] || ./seal.sh "${BUNDLE}" >/dev/null

echo "${BUNDLE}"
