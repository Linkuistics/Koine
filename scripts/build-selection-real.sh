#!/bin/bash
# Adds the REAL first-party providers to the bundles the selection acceptance installs
# (scripts/verify-selection-updates.py, docs/verification/selection-updates.md), beside
# the fixture providers Fixtures/FixtureProvider/build-decisions.sh builds: cases of the
# same <output>/<case>/<bundle> layout, and lines in <output>/index.tsv, so the harness
# tells a real bundle from a fixture only by what it is.
#
#   released-desktop        the desktop provider of the RELEASED revision (v0.1.0), built
#                           against framework 1.0 by scripts/build-baseline-host.sh and
#                           sealed under dev.antony.Koine.provider.desktop: the old
#                           designated baseline a selection-aware host is given
#   current-desktop         this tree's desktop provider (release 1.0.0), sealed the same
#   current-workspace       this tree's workspace provider (release/schema 1.0.1, the action-only repair)
#   desktop-update          a NEWER release of the same source: 1.1.0, and the feature
#   workspace-update        `first-party-selection-v1` stated in its manifest AND its
#                           descriptor, as every newly published first-party update must
#   desktop-update-renamed  the same update under another principal class, which an
#   workspace-update-renamed  earlier host must still refuse by the feature alone
#   desktop-update-no-feature   the same binary as desktop-update with a manifest that
#   workspace-update-no-feature   does not state the feature: refused before it loads
#
# An update is compiled from a COPY of Providers/ with two substitutions (the descriptor's
# required features, and for the renamed one the principal class), each checked to have
# changed the copy, and the manifest's release edited to 1.1.0: the product source is never edited, and no build flag exists in it. The
# workspace update reuses the desktop provider's kernel start-instant helper as source, as
# the workspace provider always does, so a mixed release is built from reused helper source.
#
# Every bundle is sealed with the identity of scripts/signing-env.sh and left unapproved:
# the driver writes the approval a scenario needs. Nothing here is approved, and a bundle
# in the application's own root needs no approval.
#
# usage: build-selection-real.sh <directory containing KoineProviderAPI.framework> <fixtures>
set -euo pipefail

cd "$(dirname "$0")/.."
FRAMEWORKS="$(cd "$1" && pwd)"
OUT="$(cd "$2" && pwd)"
REPOSITORY="$(pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

# shellcheck source=scripts/first-party-update-lib.sh
source scripts/first-party-update-lib.sh
RELEASED="${REPOSITORY}/.build/compat/debug/baseline/products/DesktopProviders/Desktop.koineprovider"
if [ ! -d "${RELEASED}" ]; then
    echo "Error: ${RELEASED} does not exist. Run: task compat:baseline" >&2
    exit 1
fi

# place <case> <built bundle> <binary name> [as-released]: the bundle as <OUT>/<case>/<bundle>,
# sealed here unless it is already the released revision's own, whose seal is left as it is.
place() {
    local dir="${OUT}/$1"
    rm -rf "${dir}"
    mkdir -p "${dir}"
    cp -R "$2" "${dir}/"
    [ -n "${4:-}" ] || FIXTURE_UNAPPROVED=1 Fixtures/FixtureProvider/seal.sh "${dir}/$(basename "$2")" >/dev/null
    printf '%s\t%s\n' "$1" "$3" >>"${OUT}/index.tsv"
}

# --- The bundles of this tree and of the released revision ------------------------------

CURRENT="$(tree current)"
place current-desktop "$("${CURRENT}/Providers/DesktopProvider/build.sh" "${FRAMEWORKS}" "${WORK}/out/current-desktop")" real-desktop-current
place current-workspace "$("${CURRENT}/Providers/WorkspaceProvider/build.sh" "${FRAMEWORKS}" "${WORK}/out/current-workspace")" real-workspace-current
place released-desktop "${RELEASED}" real-desktop-released as-released

# --- Newer releases of the same sources -------------------------------------------------

UPDATE_TREE="$(tree update)"
substitute "${UPDATE_TREE}/Providers/DesktopProvider/Sources/DesktopProvider.swift" \
    'requiredFeatures: []' "requiredFeatures: [\"${FEATURE}\"]"
state_feature_in_workspace "${UPDATE_TREE}"
RENAMED_TREE="$(tree renamed)"
cp "${UPDATE_TREE}/Providers/DesktopProvider/Sources/DesktopProvider.swift" \
    "${RENAMED_TREE}/Providers/DesktopProvider/Sources/DesktopProvider.swift"
cp "${UPDATE_TREE}/Providers/WorkspaceProvider/Logic/WorkspaceProvider.swift" \
    "${RENAMED_TREE}/Providers/WorkspaceProvider/Logic/WorkspaceProvider.swift"
substitute "${RENAMED_TREE}/Providers/DesktopProvider/Sources/DesktopProvider.swift" \
    '@objc(KoineDesktopProviderFactory)' '@objc(KoineDesktopProviderFactoryRenamed)'
substitute "${RENAMED_TREE}/Providers/WorkspaceProvider/Sources/Factory.swift" \
    '@objc(KoineWorkspaceProviderFactory)' '@objc(KoineWorkspaceProviderFactoryRenamed)'

UPDATE='m["version"] = "1.1.0"; m["requiredFeatures"] = m["requiredFeatures"] + ["'"${FEATURE}"'"]'
NO_FEATURE='m["version"] = "1.1.0"; m["requiredFeatures"] = [f for f in m["requiredFeatures"] if f != "'"${FEATURE}"'"]'

for provider in Desktop Workspace; do
    lower="$(echo "${provider}" | tr '[:upper:]' '[:lower:]')"
    for form in update renamed; do
        root="${UPDATE_TREE}"
        [ "${form}" = "update" ] || root="${RENAMED_TREE}"
        bundle="$("${root}/Providers/${provider}Provider/build.sh" "${FRAMEWORKS}" "${WORK}/out/${lower}-${form}")"
        statements="${UPDATE}"
        if [ "${form}" = "renamed" ]; then
            statements="${UPDATE}; m['principalClass'] = 'Koine${provider}ProviderFactoryRenamed'"
        fi
        edit "${bundle}" "${statements}"
        name="${lower}-update"
        [ "${form}" = "update" ] || name="${lower}-update-renamed"
        place "${name}" "${bundle}" "real-${name}"
        # The same binary with a manifest that does not state the feature.
        copy="${WORK}/out/${name}-no-feature"
        mkdir -p "${copy}"
        cp -R "${bundle}" "${copy}/"
        no_feature="${NO_FEATURE}"
        if [ "${form}" = "renamed" ]; then
            no_feature="${NO_FEATURE}; m['principalClass'] = 'Koine${provider}ProviderFactoryRenamed'"
        fi
        edit "${copy}/${provider}.koineprovider" "${no_feature}"
        place "${name}-no-feature" "${copy}/${provider}.koineprovider" "real-${name}"
    done
done
