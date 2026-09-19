#!/bin/bash
# Assembles KoineProviderAPI.framework from the image and the textual module
# interface that `swift build` emitted. SwiftPM builds a dynamic library product
# as a bare dylib; its install name is the framework's, so every host image
# needs the framework on its run path. PackageFrameworks already is on the run
# path of everything SwiftPM links in debug, and it is the -F directory providers build
# against: they see the .swiftinterface and the binary, never the sources.
#
# usage: stage-provider-framework.sh [debug|release]   (prints the framework path)
set -euo pipefail

cd "$(dirname "$0")/.."
CONFIGURATION="${1:-debug}"
MODULE="KoineProviderAPI"

BIN_DIR="$(swift build -c "${CONFIGURATION}" --show-bin-path)"
IMAGE="${BIN_DIR}/lib${MODULE}.dylib"
if [ ! -f "${IMAGE}" ]; then
    echo "Error: ${IMAGE} does not exist. Run: swift build -c ${CONFIGURATION}" >&2
    exit 1
fi

# The interface is an intermediate of the build; its directory carries the
# configuration's name as the build system spells it (Debug, Release).
CONFIG_DIR="$(basename "${BIN_DIR}")"
# .build/compat holds whole trees of other revisions (scripts/build-compat-pairs.sh).
INTERFACES=()
while IFS= read -r found; do INTERFACES+=("${found}"); done < <(
    find .build -path .build/compat -prune -o \
        -path "*/${MODULE}.build/${CONFIG_DIR}/*" -name "${MODULE}.swiftinterface" -print
)
if [ "${#INTERFACES[@]}" -ne 1 ]; then
    echo "Error: expected one emitted ${MODULE}.swiftinterface for ${CONFIG_DIR}, found ${#INTERFACES[@]}." >&2
    echo "  The framework must be built with -emit-module-interface (ProviderAPI/Package.swift)." >&2
    exit 1
fi
if ! grep -q -- '-enable-library-evolution' "${INTERFACES[0]}"; then
    echo "Error: ${INTERFACES[0]} was not built with library evolution." >&2
    exit 1
fi

EXPECTED_ID="@rpath/${MODULE}.framework/Versions/A/${MODULE}"
if [ "$(otool -D "${IMAGE}" | tail -1)" != "${EXPECTED_ID}" ]; then
    echo "Error: ${IMAGE} does not have the install name ${EXPECTED_ID}." >&2
    exit 1
fi

# A resilient image exports accessors and dispatch thunks, never the direct
# field offsets a client could bake in. A non-resilient build exports them for
# any public class or struct with stored properties.
if nm -gU "${IMAGE}" | xcrun swift-demangle | grep -q 'field offset for'; then
    echo "Error: ${IMAGE} exports direct field offsets; it was not built with library evolution." >&2
    exit 1
fi

FRAMEWORK="${BIN_DIR}/PackageFrameworks/${MODULE}.framework"
VERSION_DIR="${FRAMEWORK}/Versions/A"
TRIPLE="$(uname -m)-apple-macos"
rm -rf "${FRAMEWORK}"
mkdir -p "${VERSION_DIR}/Modules/${MODULE}.swiftmodule" "${VERSION_DIR}/Resources"
cp "${IMAGE}" "${VERSION_DIR}/${MODULE}"
cp "${INTERFACES[0]}" "${VERSION_DIR}/Modules/${MODULE}.swiftmodule/${TRIPLE}.swiftinterface"
cp ProviderAPI/Info.plist "${VERSION_DIR}/Resources/Info.plist"
ln -s A "${FRAMEWORK}/Versions/Current"
ln -s "Versions/Current/${MODULE}" "${FRAMEWORK}/${MODULE}"
ln -s Versions/Current/Modules "${FRAMEWORK}/Modules"
ln -s Versions/Current/Resources "${FRAMEWORK}/Resources"

echo "${FRAMEWORK}"
