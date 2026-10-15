#!/bin/bash
# Builds the RETAINED workspace 1.0.0 provider, the old side of every workspace
# old/new pair, from the revision scripts/retained-workspace-1.0.0.json pins, never
# from this working tree: the long-location repair changes the provider source, and
# a binary rebuilt from changed source and called 1.0.0 would retain nothing
# (docs/specs/workspace-launch-and-open.md#subjects-and-versions).
#
# The pinned revision's files are extracted into a tree of their own with a build
# directory of their own, and built there by that revision's own scripts, as
# scripts/build-baseline-host.sh does for the released desktop. The extraction is
# `git archive` against the git store behind this repository, which keeps the
# symlinks (the workspace provider links the desktop provider's start-instant
# helper as source) that `jj file show` would flatten, so no colocated git checkout
# is needed: `jj git root` names the store.
#
# Under .build/compat/<configuration>/workspace-1.0.0:
#   src/            the extracted revision and its .build
#   products        the tree's build products (host, framework, desktop provider)
#   bundled/        the sealed, approved Desktop and Workspace bundles: what the
#                   retained host bundles, and what a later pair installs
#   retained.json   the record: revision, release, signing identifier, digests
#
# usage: build-retained-workspace.sh [debug|release]   (prints the directory)
set -euo pipefail

cd "$(dirname "$0")/.."
CONFIGURATION="${1:-debug}"
PIN="scripts/retained-workspace-1.0.0.json"
COMMIT="$(jq -r .commit "${PIN}")"
TAG="$(jq -r .tag "${PIN}")"
RELEASE="$(jq -r .release "${PIN}")"
SCHEMA="$(jq -r .schemaVersion "${PIN}")"
IDENTIFIER="$(jq -r .signingIdentifier "${PIN}")"
DIRECTORY="$(pwd)/.build/compat/${CONFIGURATION}/workspace-1.0.0"
TREE="${DIRECTORY}/src"

# The pinned commit must be one this repository holds, and the tag, where this
# repository carries it, must still name it: a moved tag is a different baseline.
if [ -d .jj ]; then
    GIT_DIR="$(jj git root)"
    RESOLVED="$(jj log --ignore-working-copy --no-graph -r "${COMMIT}" -T 'commit_id' 2>/dev/null || true)"
    NAMED="$(jj log --ignore-working-copy --no-graph -r "tags(exact:\"${TAG}\")" -T 'commit_id' 2>/dev/null || true)"
else
    GIT_DIR="$(git rev-parse --absolute-git-dir)"
    RESOLVED="$(git rev-parse --verify "${COMMIT}^{commit}" 2>/dev/null || true)"
    NAMED="$(git rev-parse --verify "refs/tags/${TAG}^{commit}" 2>/dev/null || true)"
fi
if [ "${RESOLVED}" != "${COMMIT}" ]; then
    echo "Error: this repository holds no revision ${COMMIT} (the retained workspace ${RELEASE})." >&2
    exit 1
fi
if [ -n "${NAMED}" ] && [ "${NAMED}" != "${COMMIT}" ]; then
    echo "Error: tag ${TAG} names ${NAMED}, not the pinned ${COMMIT}." >&2
    exit 1
fi

# A tree already extracted at this commit is reused with its build directory.
if [ "$(cat "${TREE}/.koine-retained-commit" 2>/dev/null || true)" != "${COMMIT}" ]; then
    rm -rf "${TREE}"
    mkdir -p "${TREE}"
    git --git-dir "${GIT_DIR}" archive --format=tar "${COMMIT}" -- . ':(exclude).grove' | tar -x -C "${TREE}"
    echo "${COMMIT}" >"${TREE}/.koine-retained-commit"
fi
echo "retained workspace ${RELEASE}: ${COMMIT}" >&2

# The revision's own build of its host, framework, fixtures and desktop provider.
"${TREE}/scripts/build-compat-tree.sh" "${CONFIGURATION}" "${TREE}" "${DIRECTORY}"
PRODUCTS="$(cd "${DIRECTORY}/products" && pwd -P)"

# The workspace provider, by its own build definition against that framework, sealed
# and approved as the application seals it.
(
    cd "${TREE}"
    rm -rf "${PRODUCTS}/WorkspaceProviders"
    BUNDLE="$(Providers/WorkspaceProvider/build.sh "${PRODUCTS}/PackageFrameworks" "${PRODUCTS}/WorkspaceProviders")"
    Fixtures/FixtureProvider/seal.sh "${BUNDLE}" >&2
)

# Apart from the tree that built them: the host's in-application root, as
# Contents/PlugIns holds the two bundled providers.
rm -rf "${DIRECTORY}/bundled"
mkdir -p "${DIRECTORY}/bundled"
/usr/bin/ditto "${PRODUCTS}/DesktopProviders" "${DIRECTORY}/bundled"
/usr/bin/ditto "${PRODUCTS}/WorkspaceProviders" "${DIRECTORY}/bundled"
BUNDLE="${DIRECTORY}/bundled/Workspace.koineprovider"

# The record states what was built and checks it against the pin.
[ "$(jq -r .version "${BUNDLE}/manifest.json")" = "${RELEASE}" ] ||
    { echo "Error: the retained manifest does not say release ${RELEASE}." >&2; exit 1; }
[ "$(jq -r .schemaVersion "${BUNDLE}/manifest.json")" = "${SCHEMA}" ] ||
    { echo "Error: the retained manifest does not say schema ${SCHEMA}." >&2; exit 1; }
SEALED="$(codesign -dv "${BUNDLE}" 2>&1 | sed -n 's/^Identifier=//p')"
[ "${SEALED}" = "${IDENTIFIER}" ] ||
    { echo "Error: the sealed bundle's signing identifier is ${SEALED}, not ${IDENTIFIER}." >&2; exit 1; }
codesign --verify --strict "${BUNDLE}" >&2
sha() { shasum -a 256 "$1" | cut -d' ' -f1; }
jq -n --arg commit "${COMMIT}" --arg tag "${TAG}" --arg configuration "${CONFIGURATION}" \
    --arg release "${RELEASE}" --arg schema "${SCHEMA}" --arg identifier "${SEALED}" \
    --arg manifest "$(sha "${BUNDLE}/manifest.json")" --arg sdl "$(sha "${BUNDLE}/schema.graphql")" \
    --arg dylib "$(sha "${BUNDLE}/libWorkspaceProvider.dylib")" \
    --arg cdhash "$(codesign -dvvv "${BUNDLE}" 2>&1 | sed -n 's/^CDHash=//p')" \
    '{commit: $commit, tag: $tag, configuration: $configuration, release: $release,
      schemaVersion: $schema, signingIdentifier: $identifier,
      manifestSha256: $manifest, schemaSha256: $sdl, dylibSha256: $dylib, cdhash: $cdhash}' \
    >"${DIRECTORY}/retained.json"
echo "${DIRECTORY}"
