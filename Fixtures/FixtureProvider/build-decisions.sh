#!/bin/bash
# Builds the bundles the selection acceptance's decision rows install
# (scripts/verify-selection-decisions.py, docs/verification/selection-decisions.md),
# each a real signed binary that the host really loads when it selects it and that
# writes its initializer, factory and start markers (initializer.c) when it runs.
# Every bundle is sealed by Koine's identity and left unapproved: the driver writes
# the approval a scenario needs. Kept apart, <output>/<case>/<bundle>, with
# <output>/index.tsv naming the compiled binary each case was made from.
#
# Unlike build-selection.sh's decision family, which is never loaded and so can
# edit one binary's manifest into many releases, an update here declares the
# selection feature in its descriptor as well as its manifest, so the loader's own
# descriptor agreement check passes when the host loads it for real. So there are
# two compiled binaries per shipped slot, an old designated baseline and an update:
#
#   Sh  the slot most rows contest.   fixturesh / FixtureSh,  baseline 1.0.0, schema 1.1.0
#   Sk  a second slot, for identifier order against catalogue order.
#                                      fixturesk / FixtureSk,  baseline 1.0.0, schema 1.0.0
#   Od  an ordinary provider (fixtureod); two that claim, after loading, the names of
#       a shipped slot (FixtureShClaimed) and of a reserved-only identity
#       (FixtureInputClaimed) in their SDL although their manifest claims neither;
#       and one whose runtime descriptor names the slot's identity under a manifest
#       that names fixtureod.
#   Unknown  an ordinary provider whose identifier really is `unknown`.
#
# Every fixture signing identifier is distinct from every production one and is
# admitted only by the test catalogues of scripts/build-selection-hosts.py.
#
# usage: build-decisions.sh <directory containing KoineProviderAPI.framework> <output>
set -euo pipefail

FRAMEWORKS="$(cd "$1" && pwd)"
rm -rf "$2"
mkdir -p "$2"
OUT="$(cd "$2" && pwd)"
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

FEATURE='first-party-selection-v1'
UPDATE='m["requiredFeatures"] = ["'"${FEATURE}"'"]'
SCHEMA='m["schemaVersion"] = "1.1.0"'
: >"${OUT}/index.tsv"

# binary <name> <stem tag or stem> <extra swiftc flags> [<extra sdl file>]: one compiled,
# unsealed provider under ${WORK}/<name>.
binary() {
    local name="$1" flags="$3" sdl="${4:-}"
    if [[ "$2" == stem:* ]]; then
        FIXTURE_UNSEALED=1 FIXTURE_STEM="${2#stem:}" FIXTURE_SWIFTC="${flags}" \
            FIXTURE_EXTRA_SDL="${sdl}" "${HERE}/build.sh" "${FRAMEWORKS}" "${WORK}/${name}" >/dev/null
    else
        FIXTURE_UNSEALED=1 FIXTURE_TAG="$2" FIXTURE_SWIFTC="${flags}" \
            FIXTURE_EXTRA_SDL="${sdl}" "${HERE}/build.sh" "${FRAMEWORKS}" "${WORK}/${name}" >/dev/null
    fi
}

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

# make <case> <binary name> <manifest statements> [<signing identifier> | adhoc]:
# a copy of the compiled binary's bundle with its manifest changed, sealed.
make() {
    local dir="${OUT}/$1"
    mkdir -p "${dir}"
    local source
    source="$(echo "${WORK}/$2"/*.koineprovider)"
    cp -R "${source}" "${dir}/"
    local bundle="${dir}/$(basename "${source}")"
    edit "${bundle}" "$3"
    if [ "${4:-}" != "" ] && [ "${4:-}" != "adhoc" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $4" "${bundle}/Info.plist"
    fi
    FIXTURE_UNAPPROVED=1 "${HERE}/seal.sh" "${bundle}" >/dev/null
    if [ "${4:-}" = "adhoc" ]; then
        codesign --force --sign - "${bundle}" 2>/dev/null
    fi
    printf '%s\t%s\n' "$1" "$2" >>"${OUT}/index.tsv"
}

cat >"${WORK}/claim-sh.graphql" <<'SDL'
"A type in a shipped slot's namespace, from a provider that is not that slot."
type FixtureShClaimed {
  note: String
}
SDL
cat >"${WORK}/claim-input.graphql" <<'SDL'
"A type in a reserved-only identity's namespace, from a provider that is not it."
type FixtureInputClaimed {
  note: String
}
SDL

binary sh-baseline Sh ""
binary sh-update Sh "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION"
binary sk-baseline Sk ""
binary sk-update Sk "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION"
binary od Od ""
binary od-claim-sh Od "" "${WORK}/claim-sh.graphql"
binary od-claim-input Od "" "${WORK}/claim-input.graphql"
binary od-describes-slot Od "-D FIXTURE_DESCRIBES_SLOT"
binary unknown stem:Unknown ""

# --- Sh: the designated baseline and what contests it ----------------------------

make baseline sh-baseline "${SCHEMA}"
for release in 0.9.0 1.0.0 1.5.0 1.9.0 1.10.0 2.0.0 3.0.0 9.0.0; do
    make "r${release}" sh-update "m['version'] = '${release}'; ${SCHEMA}; ${UPDATE}"
done
# A schema major the baseline's is not, and a schema below it in the same major.
make r1.9.0-schema2 sh-update "m['version'] = '1.9.0'; m['schemaVersion'] = '2.0.0'; ${UPDATE}"
make r1.9.0-schema-regressed sh-update "m['version'] = '1.9.0'; m['schemaVersion'] = '1.0.0'; ${UPDATE}"
# A version that is not major.minor.patch, whatever its number.
make r2.0-malformed sh-update "m['version'] = '2.0'; ${SCHEMA}; ${UPDATE}"
make r01.0.0-leading-zero sh-update "m['version'] = '01.0.0'; ${SCHEMA}; ${UPDATE}"
# An update that does not declare the selection feature in its manifest.
make r2.0.0-no-feature sh-update "m['version'] = '2.0.0'; ${SCHEMA}"
# A framework minor the host does not have: honest, so INCOMPATIBLE.
make r4.0.0-framework-future sh-update \
    "m['version'] = '4.0.0'; m['framework']['minimumMinor'] = 99; ${SCHEMA}; ${UPDATE}"
# Signed under another identifier than the slot's release identifier, while its
# manifest claims the reserved pair and a high release.
make r9.0.0-other-identifier sh-update "m['version'] = '9.0.0'; ${SCHEMA}; ${UPDATE}" \
    dev.antony.Koine.provider.fixturesh.impostor
# Claims of the reserved names by what is not the exact pair.
make claims-other-prefix sh-update \
    "m['version'] = '5.0.0'; m['graphQLPrefix'] = 'FixtureShOther'; ${SCHEMA}; ${UPDATE}"
make claims-other-identifier sh-update \
    "m['version'] = '5.0.0'; m['providerId'] = 'fixtureother'; ${SCHEMA}; ${UPDATE}"
make claims-overlapping-prefix sh-update \
    "m['version'] = '5.0.0'; m['providerId'] = 'fixtureshx'; m['graphQLPrefix'] = 'FixtureShTools'; ${SCHEMA}; ${UPDATE}"
make claims-shorter-prefix sh-update \
    "m['version'] = '5.0.0'; m['providerId'] = 'fixture'; m['graphQLPrefix'] = 'Fixture'; ${SCHEMA}; ${UPDATE}"
# The exact pair of an identity that is reserved and not yet shipped.
make claims-reserved-only sh-update \
    "m['version'] = '5.0.0'; m['providerId'] = 'fixtureinput'; m['graphQLPrefix'] = 'FixtureInput'; ${SCHEMA}; ${UPDATE}"
make claims-overlapping-reserved-only sh-update \
    "m['version'] = '5.0.0'; m['providerId'] = 'fixtureinputx'; m['graphQLPrefix'] = 'FixtureInputTools'; ${SCHEMA}; ${UPDATE}"

# The designated bundle as a purpose-built host seals it, and the ways it can be wrong.
make baseline-release-mismatch sh-baseline "m['version'] = '1.0.1'; ${SCHEMA}"
make baseline-other-identifier sh-baseline "${SCHEMA}" dev.antony.Koine.provider.fixturesh.impostor
make baseline-adhoc sh-baseline "${SCHEMA}" adhoc
make baseline-framework-future sh-baseline "m['framework']['minimumMinor'] = 99; ${SCHEMA}"

# --- Sk: a second shipped slot ---------------------------------------------------

make sk-baseline sk-baseline "m['version'] = '1.0.0'"
make sk-r1.1.0 sk-update "m['version'] = '1.1.0'; ${UPDATE}"

# --- Ordinary providers ----------------------------------------------------------

make ordinary od "pass"
make ordinary-claims-shipped-namespace od-claim-sh "pass"
make ordinary-claims-reserved-only-namespace od-claim-input "pass"
# A manifest that names an ordinary provider, over a descriptor that names the slot's identity.
make ordinary-describes-slot od-describes-slot "pass"
make unknown unknown "pass"
# A bundle whose manifest cannot be read names no provider at all.
make unidentified od "pass"
printf '{ not a manifest' >"${OUT}/unidentified/FixtureOd.koineprovider/manifest.json"
FIXTURE_UNAPPROVED=1 "${HERE}/seal.sh" "${OUT}/unidentified/FixtureOd.koineprovider" >/dev/null

echo "${OUT}"
