#!/bin/bash
# The desktop provider's own build definition. Like any provider, it compiles
# against the staged KoineProviderAPI.framework alone (its textual module
# interface and its image), never the framework's sources or the root package,
# and links the host's framework image dynamically: the bundle embeds no copy.
#
# usage: build.sh <directory containing KoineProviderAPI.framework> <output directory>
#
# Prints the bundle, Desktop.koineprovider, which is left unsigned:
# scripts/build-app.sh places it in Contents/PlugIns and signs it there, before
# the application that seals it. It is a shallow code-signing bundle: Info.plist
# at its root names the dylib as its executable, so one signature seals the
# dylib, manifest and schema.
set -euo pipefail

FRAMEWORKS="$(cd "$1" && pwd)"
mkdir -p "$2"
BUNDLE="$(cd "$2" && pwd)/Desktop.koineprovider"
cd "$(dirname "$0")"

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT
{
    echo 'let desktopSchemaSDL = #"""'
    cat schema.graphql
    echo '"""#'
} >"${WORK}/SchemaSDL.swift"

rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}"
swiftc -emit-library -module-name DesktopProvider -swift-version 6 -O \
    -target "$(uname -m)-apple-macos13.0" \
    -F "${FRAMEWORKS}" -framework KoineProviderAPI \
    -Xlinker -install_name -Xlinker "@rpath/libDesktopProvider.dylib" \
    -o "${BUNDLE}/libDesktopProvider.dylib" \
    Logic/*.swift Sources/*.swift "${WORK}/SchemaSDL.swift"
sed "s/@ARCH@/$(uname -m)/" manifest.json >"${BUNDLE}/manifest.json"
cp schema.graphql "${BUNDLE}/"
cat >"${BUNDLE}/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>dev.antony.Koine.provider.desktop</string>
<key>CFBundleExecutable</key><string>libDesktopProvider.dylib</string>
<key>CFBundlePackageType</key><string>BNDL</string>
</dict></plist>
PLIST

echo "${BUNDLE}"
