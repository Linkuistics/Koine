#!/bin/bash
# Builds the bundles the first-party selection tests choose between
# (Tests/KoineServerTests/ProviderSelectionTests.swift), each sealed by Koine's
# identity as an installed provider is, and kept apart: <output>/<case>/<bundle>.
# Every bundle is a real signed binary; a case differs from the plain one only in
# what the selection decision reads (release, schema, declared features,
# identity claims, signing identifier).
#
# Two families, each under its own tag so its Objective-C class names are its own:
#
#   Sl  the decisions. Nothing here is ever loaded in the test process: the tests
#       reach the loader's private seam, which records which frozen selections
#       would load, so the real staging, verification and selection all run and
#       no principal class of this family is ever registered.
#   Sm  the end to end. An independently compiled old designated baseline (no
#       selection feature, first revision) and an independently compiled update
#       (revision 2, declaring the feature), both signed under the one release
#       identifier of the slot. One test loads the update for real.
#
# The catalogue that admits them is the test's own: fixture identifiers are
# distinct from every production provider's, and only a test catalogue lists them.
#
# usage: build-selection.sh <directory containing KoineProviderAPI.framework> <output>
set -euo pipefail

FRAMEWORKS="$(cd "$1" && pwd)"
rm -rf "$2"
mkdir -p "$2"
OUT="$(cd "$2" && pwd)"
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

edit() { # edit <bundle> <python statements over the manifest dict `m`>
    python3 - "$1/manifest.json" "$2" <<'PY'
import json, sys
path, statements = sys.argv[1], sys.argv[2]
with open(path) as file:
    m = json.load(file)
exec(statements)
with open(path, "w") as file:
    json.dump(m, file, indent=2)
PY
}

# case <name> <source bundle> <manifest statements> [<signing identifier>]:
# a copy of the source with its manifest changed, sealed.
make() {
    local dir="${OUT}/$1"
    mkdir -p "${dir}"
    cp -R "$2" "${dir}/"
    local bundle="${dir}/$(basename "$2")"
    edit "${bundle}" "$3"
    if [ -n "${4:-}" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $4" "${bundle}/Info.plist"
    fi
    FIXTURE_UNAPPROVED=1 "${HERE}/seal.sh" "${bundle}" >/dev/null
}

FEATURE='first-party-selection-v1'

# --- Sl: the decisions --------------------------------------------------------

SL="${WORK}/sl"
FIXTURE_UNSEALED=1 FIXTURE_TAG=Sl "${HERE}/build.sh" "${FRAMEWORKS}" "${SL}" >/dev/null
PLAIN="${SL}/FixtureSl.koineprovider"
UPDATE='m["requiredFeatures"] = ["'"${FEATURE}"'"]'
SCHEMA='m["schemaVersion"] = "1.1.0"'

# The designated baseline: an independently compiled older provider, so it
# declares no selection feature. Release 1.0.0, schema 1.1.0.
make baseline "${PLAIN}" "${SCHEMA}"
for release in 0.9.0 1.0.0 1.5.0 1.9.0 1.10.0 2.0.0 3.0.0; do
    make "r${release}" "${PLAIN}" "m['version'] = '${release}'; ${SCHEMA}; ${UPDATE}"
done
# A schema major the baseline's is not, and a schema below it in the same major.
make r1.9.0-schema2 "${PLAIN}" "m['version'] = '1.9.0'; m['schemaVersion'] = '2.0.0'; ${UPDATE}"
make r1.9.0-schema-regressed "${PLAIN}" "m['version'] = '1.9.0'; m['schemaVersion'] = '1.0.0'; ${UPDATE}"
# A version that is not major.minor.patch.
make r2.0-malformed "${PLAIN}" "m['version'] = '2.0'; ${SCHEMA}; ${UPDATE}"
make r01.0.0-leading-zero "${PLAIN}" "m['version'] = '01.0.0'; ${SCHEMA}; ${UPDATE}"
# An update that does not declare the selection feature.
make r2.0.0-no-feature "${PLAIN}" "m['version'] = '2.0.0'; ${SCHEMA}"
# Signed under another identifier than the slot's release identifier, while its
# manifest claims the reserved pair and a high release.
make r9.0.0-other-identifier "${PLAIN}" "m['version'] = '9.0.0'; ${SCHEMA}; ${UPDATE}" \
    dev.antony.Koine.provider.fixturesl.impostor
# Claims of the reserved names by what is not the exact pair.
make claims-other-prefix "${PLAIN}" \
    "m['version'] = '5.0.0'; m['graphQLPrefix'] = 'FixtureSlOther'; ${SCHEMA}; ${UPDATE}"
make claims-other-identifier "${PLAIN}" \
    "m['version'] = '5.0.0'; m['providerId'] = 'fixtureother'; ${SCHEMA}; ${UPDATE}"
make claims-overlapping-prefix "${PLAIN}" \
    "m['version'] = '5.0.0'; m['providerId'] = 'fixtureslx'; m['graphQLPrefix'] = 'FixtureSlTools'; ${SCHEMA}; ${UPDATE}"
make claims-shorter-prefix "${PLAIN}" \
    "m['version'] = '5.0.0'; m['providerId'] = 'fixture'; m['graphQLPrefix'] = 'Fixture'; ${SCHEMA}; ${UPDATE}"
# The exact pair of an identity that is reserved and not yet shipped.
make claims-reserved-only "${PLAIN}" \
    "m['version'] = '1.0.0'; m['providerId'] = 'fixtureinput'; m['graphQLPrefix'] = 'FixtureInput'; ${UPDATE}"
# A shipped update that names the principal class another shipped bundle names.
make r2.0.0-qz-principal "${PLAIN}" \
    "m['version'] = '2.0.0'; m['principalClass'] = 'KoineFixtureQzProviderFactory'; ${SCHEMA}; ${UPDATE}"
# A second shipped identity, its bundle and the principal class of its own.
make qz-baseline "${PLAIN}" \
    "m['providerId'] = 'fixtureqz'; m['graphQLPrefix'] = 'FixtureQz'; m['principalClass'] = 'KoineFixtureQzProviderFactory'" \
    dev.antony.Koine.provider.fixtureqz
# Ordinary providers: none of the reserved names, an approval each.
make ordinary-a "${PLAIN}" \
    "m['providerId'] = 'fixtureord'; m['graphQLPrefix'] = 'FixtureOrd'; m['principalClass'] = 'KoineFixtureOrdProviderFactory'" \
    dev.antony.Koine.provider.fixtureord
make ordinary-b "${PLAIN}" \
    "m['providerId'] = 'fixtureord'; m['graphQLPrefix'] = 'FixtureOrdB'; m['principalClass'] = 'KoineFixtureOrdBProviderFactory'; m['variant'] = 'b'" \
    dev.antony.Koine.provider.fixtureord
make ordinary-on-shipped-principal "${PLAIN}" \
    "m['providerId'] = 'fixtureord'; m['graphQLPrefix'] = 'FixtureOrd'" \
    dev.antony.Koine.provider.fixtureord

# --- Sm: the end to end -------------------------------------------------------

SM="${WORK}/sm"
FIXTURE_UNSEALED=1 FIXTURE_TAG=Sm "${HERE}/build.sh" "${FRAMEWORKS}" "${SM}/baseline" >/dev/null
FIXTURE_UNSEALED=1 FIXTURE_TAG=Sm FIXTURE_SWIFTC="-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION" \
    "${HERE}/build.sh" "${FRAMEWORKS}" "${SM}/update" >/dev/null
make sm-baseline "${SM}/baseline/FixtureSm.koineprovider" "m['version'] = '1.0.0'"
make sm-update "${SM}/update/FixtureSm.koineprovider" "m['version'] = '1.1.0'; ${UPDATE}"

echo "${OUT}"
