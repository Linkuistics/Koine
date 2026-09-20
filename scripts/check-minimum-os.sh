#!/bin/bash
# Koine's deployment floor is one value, and it is stated in places no build step
# can reconcile: a Swift manifest the compiler reads, and two documents a person
# reads. App/Info.plist's LSMinimumSystemVersion is the source
# (scripts/signing-env.sh derives MINIMUM_OS from it, and the desktop provider's
# compiler target and manifest minimumOS from that). This compares every
# remaining site against it, so the floor cannot be narrowed — or widened — in
# one place alone. `task check:minimum-os` runs it; scripts/verify-app.sh runs it
# on the release path, and it also reads the assembled bundle when one is built.
#
# It is an instrument, so it has been seen to fail: mutating any one site below
# makes it report that site and exit 1 (docs/verification/latency-and-support-matrix.md).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

FAILED=0
# disagrees <site> <what was found> <what App/Info.plist says it should be>
disagrees() {
    echo "Error: $1 says $2; App/Info.plist's LSMinimumSystemVersion is ${MINIMUM_OS}, so it should say $3." >&2
    FAILED=1
}
# The source-of-truth value is printed whatever happens, so a run that finds
# nothing wrong still says which floor it checked everything against.
echo "App/Info.plist LSMinimumSystemVersion: ${MINIMUM_OS} (major ${MINIMUM_OS_MAJOR})"

# The Swift package's platform declaration. SwiftPM spells it .vNN for a whole
# major; a floor with a non-zero minor has no such spelling, and that is a
# refusal here rather than a silently unchecked site.
if [ "${MINIMUM_OS}" != "${MINIMUM_OS_MAJOR}.0" ]; then
    echo "Error: a floor of ${MINIMUM_OS} cannot be written as SwiftPM's .macOS(.v${MINIMUM_OS_MAJOR}); use a .0 minor." >&2
    FAILED=1
fi
# Every package manifest in the tree, found rather than listed: the root package
# and ProviderAPI's are two today, and a third must not be able to arrive
# unchecked. (.build holds whole copied trees of other revisions, and
# clients/ holds a npm package-lock; neither is Koine's source.)
while IFS= read -r manifest; do
    FOUND="$(sed -n 's/^ *platforms: \[\.macOS(\.v\([0-9]*\))\],$/\1/p' "${manifest}")"
    if [ -z "${FOUND}" ]; then
        echo "Error: ${manifest} has no 'platforms: [.macOS(.vNN)],' line to check." >&2
        FAILED=1
    elif [ "${FOUND}" != "${MINIMUM_OS_MAJOR}" ]; then
        disagrees "${manifest}" ".macOS(.v${FOUND})" ".macOS(.v${MINIMUM_OS_MAJOR})"
    fi
done < <(find . -name .build -prune -o -name clients -prune -o -name Package.swift -print)

# The provider framework's own bundle Info.plist, which is embedded in the
# application and is what a provider author reads the framework's floor from.
FRAMEWORK_FLOOR="$(plist_string LSMinimumSystemVersion ProviderAPI/Info.plist)"
[ "${FRAMEWORK_FLOOR}" = "${MINIMUM_OS}" ] ||
    disagrees "ProviderAPI/Info.plist" "${FRAMEWORK_FLOOR}" "${MINIMUM_OS}"

# The desktop provider's manifest is derived, not restated: what is checked is
# that it is still the placeholder Providers/DesktopProvider/build.sh substitutes.
grep -q '"minimumOS": "@MINIMUM_OS@"' Providers/DesktopProvider/manifest.json ||
    disagrees "Providers/DesktopProvider/manifest.json" \
        "$(sed -n 's/.*"minimumOS": "\(.*\)".*/\1/p' Providers/DesktopProvider/manifest.json)" "@MINIMUM_OS@"

# The prose. Each document states the floor in its own sentence, and the sentence
# is what a reader is held to; a grep for the exact phrase is what keeps it true.
prose() {
    grep -qF "$2" "$1" ||
        { echo "Error: $1 does not contain \"$2\"." >&2; FAILED=1; }
}
prose docs/specs/machine.md "It requires macOS ${MINIMUM_OS_MAJOR} or later on Apple Silicon."
prose README.md "on macOS ${MINIMUM_OS_MAJOR} or later, Apple Silicon"

# A stale floor anywhere above is a source problem; a stale floor in the bundle
# is a stale bundle, so the assembled one is checked when it is there. LC_*_VERSION
# minos is what the loader and dyld actually read.
if [ -d "${APP_BUNDLE}" ]; then
    BUNDLE_FLOOR="$(plist_string LSMinimumSystemVersion "${APP_BUNDLE}/Contents/Info.plist")"
    [ "${BUNDLE_FLOOR}" = "${MINIMUM_OS}" ] ||
        disagrees "${APP_BUNDLE}/Contents/Info.plist" "${BUNDLE_FLOOR}" "${MINIMUM_OS}"
    for image in "Contents/MacOS/${APP_NAME}" \
        "Contents/Frameworks/${PROVIDER_FRAMEWORK_NAME}.framework/Versions/A/${PROVIDER_FRAMEWORK_NAME}" \
        "Contents/PlugIns/Desktop.koineprovider/libDesktopProvider.dylib"; do
        MINOS="$(otool -l "${APP_BUNDLE}/${image}" | awk '/^ *minos /{print $2; exit}')"
        [ "${MINOS}" = "${MINIMUM_OS}" ] || disagrees "${image}" "minos ${MINOS}" "minos ${MINIMUM_OS}"
    done
    PROVIDER_FLOOR="$(sed -n 's/.*"minimumOS": "\(.*\)".*/\1/p' "${APP_BUNDLE}/Contents/PlugIns/Desktop.koineprovider/manifest.json")"
    [ "${PROVIDER_FLOOR}" = "${MINIMUM_OS}" ] ||
        disagrees "the bundled provider's manifest" "${PROVIDER_FLOOR}" "${MINIMUM_OS}"
    echo "Assembled bundle checked: ${APP_BUNDLE}"
else
    echo "No assembled bundle at ${APP_BUNDLE}; its Info.plist and Mach-O minos were not checked. Run: task app"
fi

[ "${FAILED}" = 0 ] || exit 1
echo "Every site states the macOS ${MINIMUM_OS} floor."
