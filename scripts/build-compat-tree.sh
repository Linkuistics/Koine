#!/bin/bash
# Builds one revision's binaries for the binary compatibility pairs, from that
# revision's own source tree and into its own build directory, exactly as
# `task test` builds them: the headless host, the staged framework, the plain
# fixture, the loader's variants and the desktop provider, each sealed and
# approved with the identity of scripts/signing-env.sh. Everything it runs is the
# TREE's own script, so a tree of an older release builds as that release did.
#
# usage: build-compat-tree.sh <debug|release> <tree directory> <link directory>
#
# Links <link directory>/products at the tree's build products.
set -euo pipefail

CONFIGURATION="$1"
TREE="$(cd "$2" && pwd)"
mkdir -p "$3"
LINKS="$(cd "$3" && pwd)"

cd "${TREE}"
swift build -c "${CONFIGURATION}" --product KoineCompatibilityHost >&2
FRAMEWORK="$(scripts/stage-provider-framework.sh "${CONFIGURATION}")"
PRODUCTS="$(dirname "$(dirname "${FRAMEWORK}")")"
Fixtures/FixtureProvider/build.sh "${PRODUCTS}/PackageFrameworks" \
    "${PRODUCTS}/FixtureProviders" >&2
Fixtures/FixtureProvider/build-variants.sh "${PRODUCTS}/PackageFrameworks" \
    "${PRODUCTS}/FixtureProviders" "${PRODUCTS}/FixtureVariants" >&2
# The desktop provider, built by its own definition against this tree's framework
# and sealed as the application seals it: "the existing desktop" of a pair.
DESKTOP="$(Providers/DesktopProvider/build.sh "${PRODUCTS}/PackageFrameworks" \
    "${PRODUCTS}/DesktopProviders")"
Fixtures/FixtureProvider/seal.sh "${DESKTOP}" >&2
# A release executable's run path is its own directory alone; a debug
# one also has PackageFrameworks. Either way the host finds the staged framework.
ln -sfn PackageFrameworks/KoineProviderAPI.framework "${PRODUCTS}/KoineProviderAPI.framework"
rm -f "${LINKS}/products"
ln -s "${PRODUCTS}" "${LINKS}/products"
