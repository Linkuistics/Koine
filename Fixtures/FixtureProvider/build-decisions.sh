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
# The failure boundary (scripts/verify-selection-failures.py, docs/verification/
# selection-failures.md) adds cases of these binaries whose manifest names another
# principal class, whose descriptor disagrees with it, or whose schema is refused; two
# more binaries, one with a private dependency that will not load (`sh-update-private`,
# the same main image with a good and a bad `libFixturePrivate.dylib`) and two whose
# SDL the core refuses (`sh-update-bad-sdl`, `sh-update-outside-prefix`); and
# ordinary providers that claim another provider's, or the host's, principal class.
#
# The cascade and duplicates rows (scripts/verify-selection-failures.py, the sections
# of docs/verification/selection-failures.md that follow the freeze ones) add the
# dependants: a provider that additionally requires another's capability (framework
# minor 1, `additional-capabilities-v1`), so that one refused or removed provider strands
# another. `Sk` and `Sh` updates each name the other as an owner, `Od` names `Sk`, and so
# the fixtures can form a chain (sh <- sk <- od) and a cycle (sh <-> sk); a shipped
# update whose `start()` throws; and ordinary rivals of `fixtureod` that pre-load checks
# refuse (incompatible framework, an ad-hoc signature, a tampered seal) or that claim only
# its identifier or only its prefix.
#
# The digest and restart rows (scripts/verify-selection-failures.py, the sections of
# docs/verification/selection-failures.md that follow the cascade ones) add an update whose
# SDL differs from the baseline's only by one extra enum (`sdl-changed`), and one whose extra
# enum differs from that one only in its description (`sdl-changed-description`); and a
# designated baseline of a later release (`baseline-r1.7.0`), for a host whose baseline changed.
#
# The update rows (scripts/verify-selection-updates.py, docs/verification/selection-updates.md)
# add compatible newer releases of both slots and the same with another principal class (the
# renamed-principal variant an earlier host must refuse by feature alone), one refusal per
# trust check a per-user update can fail (unsigned, ad hoc, altered after its seal, another
# architecture, a newer OS, a feature this host lacks), two providers that claim the reserved
# pairs `desktop` and `workspace` and are signed under a fixture signing identifier (the
# bundle and release a production catalogue refuses, and the same compiled binary as the
# designated baseline of a test catalogue that admits that identifier). The host of the equal-bytes
# rows designates the very bundle `r1.5.0` as its baseline: one directory, copied into both roots.
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

# make <case> <binary name> <manifest statements> [<signing identifier> | adhoc | unsigned]:
# a copy of the compiled binary's bundle with its manifest changed, sealed.
make() {
    local dir="${OUT}/$1"
    mkdir -p "${dir}"
    local source
    source="$(echo "${WORK}/$2"/*.koineprovider)"
    cp -R "${source}" "${dir}/"
    local bundle="${dir}/$(basename "${source}")"
    [ -z "${INCLUDE:-}" ] || cp "${INCLUDE}" "${bundle}/"
    edit "${bundle}" "$3"
    if [ "${4:-}" != "" ] && [ "${4:-}" != "adhoc" ] && [ "${4:-}" != "unsigned" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $4" "${bundle}/Info.plist"
    fi
    FIXTURE_UNAPPROVED=1 "${HERE}/seal.sh" "${bundle}" >/dev/null
    if [ "${4:-}" = "adhoc" ]; then
        codesign --force --sign - "${bundle}" 2>/dev/null
    fi
    if [ "${4:-}" = "unsigned" ]; then
        codesign --remove-signature "${bundle}" 2>/dev/null
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

# A private dependency inside the bundle, in two forms of one install name: one that
# loads, and one whose own dependency is a system-path library that does not exist (a
# path under /usr/lib is a system path to the loader's checks, so only dyld refuses it).
TARGET="$(uname -m)-apple-macos13.0"
mkdir -p "${WORK}/private/good" "${WORK}/private/bad" "${WORK}/private/absent"
echo 'int koine_fixture_private(void) { return 0; }' >"${WORK}/private/private.c"
echo 'int koine_fixture_absent(void) { return 0; }' >"${WORK}/private/absent.c"
clang -dynamiclib -target "${TARGET}" -install_name @loader_path/libFixturePrivate.dylib \
    -o "${WORK}/private/good/libFixturePrivate.dylib" "${WORK}/private/private.c"
clang -dynamiclib -target "${TARGET}" -install_name /usr/lib/libkoine_fixture_absent.dylib \
    -o "${WORK}/private/absent/libkoine_fixture_absent.dylib" "${WORK}/private/absent.c"
clang -dynamiclib -target "${TARGET}" -install_name @loader_path/libFixturePrivate.dylib \
    -L"${WORK}/private/absent" -Wl,-needed-lkoine_fixture_absent \
    -o "${WORK}/private/bad/libFixturePrivate.dylib" "${WORK}/private/private.c"
cat >"${WORK}/broken-sdl.graphql" <<'SDL'
type FixtureShBroken {
  note: String
SDL
cat >"${WORK}/outside-prefix.graphql" <<'SDL'
"A type outside the provider's prefix."
type OtherThing {
  note: String
}
SDL

cat >"${WORK}/extra-valid.graphql" <<'SDL'
"An additional enum in the slot's own namespace; an enum needs no resolver."
enum FixtureShExtra {
  ALPHA
  BETA
}
SDL
sed 's/An additional enum in/An additional enum, described otherwise, in/' "${WORK}/extra-valid.graphql" \
    >"${WORK}/extra-valid-described.graphql"

binary sh-baseline Sh ""
binary sh-update Sh "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION"
binary sk-baseline Sk ""
binary sk-update Sk "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION"
binary sh-update-private Sh "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION -L${WORK}/private/good -Xlinker -needed-lFixturePrivate"
binary sh-update-bad-sdl Sh "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION" "${WORK}/broken-sdl.graphql"
binary sh-update-outside-prefix Sh "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION" "${WORK}/outside-prefix.graphql"
binary sh-update-extra-sdl Sh "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION" "${WORK}/extra-valid.graphql"
binary sh-update-extra-sdl-described Sh "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION" "${WORK}/extra-valid-described.graphql"
binary od Od ""
binary od-claim-sh Od "" "${WORK}/claim-sh.graphql"
binary od-claim-input Od "" "${WORK}/claim-input.graphql"
binary od-describes-slot Od "-D FIXTURE_DESCRIBES_SLOT"
binary unknown stem:Unknown ""
# Dependants, and a start that fails. FIXTURE_ADDITIONAL (the environment) adds the field
# that carries the requirement to the schema; the define registers it.
ADDITIONAL='-D FIXTURE_ADDITIONAL'
FIXTURE_ADDITIONAL=1 binary sh-update-needs-sk Sh "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION ${ADDITIONAL} -D FIXTURE_NEEDS_SK"
FIXTURE_ADDITIONAL=1 binary sk-update-needs-sh Sk "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION ${ADDITIONAL} -D FIXTURE_NEEDS_SH"
FIXTURE_ADDITIONAL=1 binary od-needs-sk Od "${ADDITIONAL} -D FIXTURE_NEEDS_SK"
binary sh-update-fails-start Sh "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION -D FIXTURE_FAILS_START"
# The update rows: the same update under another principal class, and providers named for the
# reserved pairs of the production catalogue (their module and class names are the real ones').
binary sh-update-renamed Sh "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION -D FIXTURE_RENAMED_PRINCIPAL"
binary sk-update-renamed Sk "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION -D FIXTURE_RENAMED_PRINCIPAL"
binary desktop-impostor stem:Desktop "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION"
binary workspace-impostor stem:Workspace "-D FIXTURE_REVISION_2 -D FIXTURE_SELECTION"

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

# A frozen update that fails after its choice is made, at release 2.0.0 so that it
# outranks a lower update (1.5.0) and the bundled baseline, both healthy.
FAIL="m['version'] = '2.0.0'; ${SCHEMA}; ${UPDATE}"
#   its principal class is a class the host already has: one of the host image's own, and
#   one of the system's. Refused before any dlopen.
make f-principal-host-class sh-update "${FAIL}; m['principalClass'] = 'KoineSelectionHostClass'"
make f-principal-system-class sh-update "${FAIL}; m['principalClass'] = 'NSObject'"
#   its principal class is another shipped provider's: the loader refuses both, before load.
make f-principal-sk sh-update "${FAIL}; m['principalClass'] = 'KoineFixtureSkProviderFactory'"
#   its image loads and registers no class of that name, and one that is no factory.
make f-principal-missing sh-update "${FAIL}; m['principalClass'] = 'KoineFixtureShAbsentFactory'"
make f-principal-not-factory sh-update "${FAIL}; m['principalClass'] = 'KoineFixtureShNotAFactory'"
#   its descriptor says less than its manifest: the manifest requires a feature the
#   descriptor does not declare, so the loader refuses the disagreement after loading.
make f-descriptor-mismatch sh-update \
    "${FAIL}; m['requiredFeatures'] = ['${FEATURE}', 'additional-capabilities-v1']; m['framework']['minimumMinor'] = 1"
#   its schema is refused by the core: SDL that does not parse, and a type outside its prefix.
make f-schema-invalid-sdl sh-update-bad-sdl "${FAIL}"
make f-schema-outside-prefix sh-update-outside-prefix "${FAIL}"
#   dlopen: one binary, one private dependency that loads and one that does not.
INCLUDE="${WORK}/private/good/libFixturePrivate.dylib" make f-dlopen-good sh-update-private "${FAIL}"
INCLUDE="${WORK}/private/bad/libFixturePrivate.dylib" make f-dlopen-unloadable sh-update-private "${FAIL}"
#   an update whose SDL is the baseline's plus one type, and that type described otherwise.
make sdl-changed sh-update-extra-sdl "${FAIL}"
make sdl-changed-description sh-update-extra-sdl-described "${FAIL}"
#   a release that loads: the repair every recovery installs.
make f-repaired sh-update "${FAIL}"

# A shipped update that publishes and then fails its start.
make sf-start-fails sh-update-fails-start "${FAIL}"

# Dependants: the capability owner is named in the descriptor and the manifest requires the
# feature that carries it (framework minor 1). An update also declares the selection feature.
ADD="m['requiredFeatures'] = ['additional-capabilities-v1']; m['framework']['minimumMinor'] = 1"
ADD_SELECTION="m['requiredFeatures'] = ['${FEATURE}', 'additional-capabilities-v1']; m['framework']['minimumMinor'] = 1"
#   a fixturesk update and a fixturesh update that additionally require the other's read capability.
make dep-sk-needs-sh sk-update-needs-sh "m['version'] = '1.1.0'; ${ADD_SELECTION}"
make dep-sh-needs-sk sh-update-needs-sk "m['version'] = '2.0.0'; ${SCHEMA}; ${ADD_SELECTION}"
#   an ordinary provider that additionally requires fixturesk's read capability.
make dep-od-needs-sk od-needs-sk "${ADD}"

# The designated bundle as a purpose-built host seals it, and the ways it can be wrong.
make baseline-release-mismatch sh-baseline "m['version'] = '1.0.1'; ${SCHEMA}"
make baseline-other-identifier sh-baseline "${SCHEMA}" dev.antony.Koine.provider.fixturesh.impostor
make baseline-adhoc sh-baseline "${SCHEMA}" adhoc
make baseline-framework-future sh-baseline "m['framework']['minimumMinor'] = 99; ${SCHEMA}"
#   a later designated release, for a host whose baseline changed (release 1.7.0 outranks an update 1.5.0).
make baseline-r1.7.0 sh-baseline "m['version'] = '1.7.0'; ${SCHEMA}"

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
# Rivals of `ordinary` (fixtureod / FixtureOd). Two that are eligible and claim half of its
# identity, and three that a pre-load check refuses though they claim all of it: a framework
# minor the host lacks (honest, so INCOMPATIBLE), an ad-hoc signature, and a seal broken after
# it was made (the only bundle here altered after signing).
make ordinary-same-prefix od "m['providerId'] = 'fixtureother'"
make ordinary-same-identifier od "m['graphQLPrefix'] = 'FixtureOdOther'"
make ordinary-framework-future od "m['framework']['minimumMinor'] = 99"
make ordinary-adhoc od "pass" adhoc
make ordinary-tampered od "pass"
printf '\n# altered after it was sealed\n' >>"${OUT}/ordinary-tampered/FixtureOd.koineprovider/schema.graphql"
# Ordinary providers that claim a principal class that is not theirs: a shipped
# provider's, the host's own, and another ordinary provider's.
make ordinary-principal-sh od "m['principalClass'] = 'KoineFixtureShProviderFactory'"
make ordinary-principal-host-class od "m['principalClass'] = 'KoineSelectionHostClass'"
make unknown-principal-od unknown "m['principalClass'] = 'KoineFixtureOdProviderFactory'"
# A bundle whose manifest cannot be read names no provider at all.
make unidentified od "pass"
printf '{ not a manifest' >"${OUT}/unidentified/FixtureOd.koineprovider/manifest.json"
FIXTURE_UNAPPROVED=1 "${HERE}/seal.sh" "${OUT}/unidentified/FixtureOd.koineprovider" >/dev/null

# --- The update rows (scripts/verify-selection-updates.py) -----------------------------

# Compatible newer releases of both slots, and the same with another principal class. A host
# that predates `first-party-selection-v1` must refuse the renamed one by the feature alone,
# as the one that keeps the principal name (which an earlier host could also meet as a
# duplicate of a factory it had already run).
make r1.6.0 sh-update "m['version'] = '1.6.0'; ${SCHEMA}; ${UPDATE}"
make sk-r1.2.0 sk-update "m['version'] = '1.2.0'; ${UPDATE}"
make r1.5.0-renamed sh-update-renamed \
    "m['version'] = '1.5.0'; ${SCHEMA}; ${UPDATE}; m['principalClass'] = 'KoineFixtureShProviderFactoryRenamed'"
make sk-r1.1.0-renamed sk-update-renamed \
    "m['version'] = '1.1.0'; ${UPDATE}; m['principalClass'] = 'KoineFixtureSkProviderFactoryRenamed'"
#   and one that does not state the feature at all, in both principal forms.
make r2.0.0-no-feature-renamed sh-update-renamed \
    "m['version'] = '2.0.0'; ${SCHEMA}; m['principalClass'] = 'KoineFixtureShProviderFactoryRenamed'"
make sk-r1.1.0-no-feature sk-update "m['version'] = '1.1.0'"
make sk-r1.1.0-no-feature-renamed sk-update-renamed \
    "m['version'] = '1.1.0'; m['principalClass'] = 'KoineFixtureSkProviderFactoryRenamed'"

# One refusal per trust check a per-user update can fail, each at release 2.0.0 so that it
# outranks a healthy lower update and the designated baseline: `trust_cases <prefix> <binary>
# <manifest statements of the release>`. Approval (none, or another Team ID) and the location
# are the driver's, because they are not in the bundle; the framework minor is r4.0.0-
# framework-future's, in decisions above.
# The architecture this Mac is not: the manifest claims it, and the host refuses before it reads an image.
if [ "$(uname -m)" = arm64 ]; then OTHER_ARCH=x86_64; else OTHER_ARCH=arm64; fi
trust_cases() {
    local tag="$1" binary="$2" release="$3"
    make "${tag}t-unsigned" "${binary}" "${release}" unsigned
    make "${tag}t-adhoc" "${binary}" "${release}" adhoc
    make "${tag}t-tampered" "${binary}" "${release}"
    printf '\n# altered after it was sealed\n' >>"${OUT}/${tag}t-tampered/$(ls "${OUT}/${tag}t-tampered")/schema.graphql"
    make "${tag}t-architecture" "${binary}" "${release}; m['architectures'] = ['${OTHER_ARCH}']"
    make "${tag}t-os" "${binary}" "${release}; m['minimumOS'] = '99.0'"
    make "${tag}t-feature" "${binary}" \
        "${release}; m['requiredFeatures'] = ['${FEATURE}', 'time-travel']"
    make "${tag}t-framework" "${binary}" "${release}; m['framework']['minimumMinor'] = 99"
    make "${tag}t-good" "${binary}" "${release}"
}
trust_cases "" sh-update "m['version'] = '2.0.0'; ${SCHEMA}; ${UPDATE}"
trust_cases "sk-" sk-update "m['version'] = '2.0.0'; ${UPDATE}"

# Providers named for the production catalogue's reserved pairs, signed under a fixture signing
# identifier (never the production one): refused by a production catalogue as a release of a
# slot it does not admit, and the same compiled binary loads as the designated baseline of a
# test catalogue that admits that identifier.
make desktop-impostor-9.0.0 desktop-impostor "m['version'] = '9.0.0'; ${UPDATE}" \
    dev.antony.Koine.provider.desktop.impostor
make desktop-impostor-baseline desktop-impostor "m['version'] = '1.0.0'; ${UPDATE}" \
    dev.antony.Koine.provider.desktop.impostor
make workspace-impostor-9.0.0 workspace-impostor "m['version'] = '9.0.0'; ${UPDATE}" \
    dev.antony.Koine.provider.workspace.impostor
make workspace-impostor-baseline workspace-impostor "m['version'] = '1.0.0'; ${UPDATE}" \
    dev.antony.Koine.provider.workspace.impostor

echo "${OUT}"
