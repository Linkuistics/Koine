#!/bin/bash
# The workspace provider's own build definition. Like any provider, it compiles
# against the staged KoineProviderAPI.framework alone (its textual module
# interface and its image), never the framework's sources or the root package,
# and links the host's framework image dynamically: the bundle embeds no copy.
#
# usage: build.sh <directory containing KoineProviderAPI.framework> <output directory>
#
# Prints the bundle, Workspace.koineprovider, which is left unsigned:
# scripts/build-app.sh places it in Contents/PlugIns and signs it there, before
# the application that seals it. It is a shallow code-signing bundle: Info.plist
# at its root names the dylib as its executable, so one signature seals the
# dylib, manifest and schema.
#
# Logic/ProcessStart.swift and Logic/ProcessIdentity.swift are the desktop provider's
# kernel start-instant helper, linked in as source: they compile into this module and
# no image is shared with desktop. Logic/ also builds as a package target, so
# `swift test` reaches it with a substituted native adapter.
set -euo pipefail

# MINIMUM_OS: the deployment floor, stated once in App/Info.plist. The
# compiler target and the manifest's minimumOS are the same value by
# construction here, because the loader refuses a provider whose binary is
# built for a newer OS than its manifest declares
# (Sources/KoineProviderLoader/ProviderLoader.swift).
# shellcheck source=../../scripts/signing-env.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/signing-env.sh"

FRAMEWORKS="$(cd "$1" && pwd)"
mkdir -p "$2"
BUNDLE="$(cd "$2" && pwd)/Workspace.koineprovider"
cd "$(dirname "$0")"

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT
{
    echo 'let workspaceSchemaSDL = #"""'
    cat schema.graphql
    echo '"""#'
} >"${WORK}/SchemaSDL.swift"

rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}"
swiftc -emit-library -module-name WorkspaceProvider -swift-version 6 -O \
    -target "$(uname -m)-apple-macos${MINIMUM_OS}" \
    -F "${FRAMEWORKS}" -framework KoineProviderAPI \
    -Xlinker -install_name -Xlinker "@rpath/libWorkspaceProvider.dylib" \
    -o "${BUNDLE}/libWorkspaceProvider.dylib" \
    Logic/*.swift Sources/*.swift "${WORK}/SchemaSDL.swift"
sed -e "s/@ARCH@/$(uname -m)/" -e "s/@MINIMUM_OS@/${MINIMUM_OS}/" manifest.json >"${BUNDLE}/manifest.json"
cp schema.graphql "${BUNDLE}/"
cat >"${BUNDLE}/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>dev.antony.Koine.provider.workspace</string>
<key>CFBundleExecutable</key><string>libWorkspaceProvider.dylib</string>
<key>CFBundlePackageType</key><string>BNDL</string>
</dict></plist>
PLIST

echo "${BUNDLE}"
