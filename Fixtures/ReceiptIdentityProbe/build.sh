#!/bin/bash
# Builds the receipt-identity probe: the workspace provider's own sources, compiled exactly as
# Providers/WorkspaceProvider/build.sh compiles them (same flags, same staged KoineProviderAPI.framework, same
# deployment floor), linked with main.swift as an executable instead of as the provider's dylib. It is how a
# host test reaches the shipped adapter's receipt acquisition without a launch (see main.swift).
#
# usage: build.sh <directory containing KoineProviderAPI.framework> <output directory>
# Prints the executable. Test material: scripts/build-app.sh does not build or ship it.
set -euo pipefail

# shellcheck source=../../scripts/signing-env.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/signing-env.sh"

FRAMEWORKS="$(cd "$1" && pwd)"
mkdir -p "$2"
OUTPUT="$(cd "$2" && pwd)/receipt-identity-probe"
PROVIDER="${KOINE_ROOT}/Providers/WorkspaceProvider"

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT
{
    echo 'let workspaceSchemaSDL = #"""'
    cat "${PROVIDER}/schema.graphql"
    echo '"""#'
} >"${WORK}/SchemaSDL.swift"

rm -f "${OUTPUT}"
swiftc -module-name ReceiptIdentityProbe -swift-version 6 -O \
    -target "$(uname -m)-apple-macos${MINIMUM_OS}" \
    -F "${FRAMEWORKS}" -framework KoineProviderAPI \
    -Xlinker -rpath -Xlinker "${FRAMEWORKS}" \
    -o "${OUTPUT}" \
    "${PROVIDER}"/Logic/*.swift "${PROVIDER}"/Sources/*.swift "${WORK}/SchemaSDL.swift" \
    "${KOINE_ROOT}/Fixtures/ReceiptIdentityProbe/main.swift"

echo "${OUTPUT}"
