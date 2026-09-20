# shellcheck shell=bash
# shellcheck disable=SC2034  # variables the sourcing scripts use
# Sourced by build-app.sh, notarize-app.sh, verify-app.sh and the VM scripts: the
# one place the bundle's identity and version are stated. Every Koine bundle
# carries the same designated requirement from development to release, so TCC and
# login-item state survive rebuilds.
APP_NAME="Koine"
BUNDLE_ID="dev.antony.Koine"
SIGNING_IDENTITY="${KOINE_SIGNING_IDENTITY:-Developer ID Application: Antony Blakey (TA43A4RUP3)}"
APP_BUNDLE="${KOINE_APP_BUNDLE:-.build/app/${APP_NAME}.app}"
PROVIDER_FRAMEWORK_NAME="KoineProviderAPI"

# Apple's notary service authenticates through a keychain profile the human
# stores once from an App Store Connect API key. Overridable, and with no
# fallback, in the same shape as the signing identity: an unnotarized artifact is
# never an acceptable substitute for a notarized one.
NOTARY_PROFILE="${KOINE_NOTARY_PROFILE:-koine-notary}"

# The version is one value. App/Info.plist's CFBundleShortVersionString is the
# source; the release tag, the release artifact's name and the Homebrew cask all
# derive from it here rather than restating it. CFBundleVersion is held equal to
# it so the two keys cannot drift: they are checked, not assumed, because a
# bundle whose two version keys disagree is a bundle whose version is a question.
# Resolved from this file's own location, never from the caller's working
# directory: four Fixtures/** build scripts source this by relative path without
# cd-ing to the repository root, so a relative path here reads as "no version" in
# exactly those callers and fails them for a value they never asked for.
KOINE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INFO_PLIST="${KOINE_ROOT}/App/Info.plist"
# plist_string <key> <plist path>
plist_string() { /usr/libexec/PlistBuddy -c "Print :$1" "$2" 2>/dev/null; }

MARKETING_VERSION="$(plist_string CFBundleShortVersionString "${INFO_PLIST}")"
BUILD_VERSION="$(plist_string CFBundleVersion "${INFO_PLIST}")"
if [[ ! "${MARKETING_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: ${INFO_PLIST} CFBundleShortVersionString is \"${MARKETING_VERSION}\", not MAJOR.MINOR.PATCH." >&2
    exit 1
fi
if [ "${BUILD_VERSION}" != "${MARKETING_VERSION}" ]; then
    {
        echo "Error: ${INFO_PLIST}'s two version keys disagree."
        echo "  CFBundleShortVersionString = ${MARKETING_VERSION}"
        echo "  CFBundleVersion            = ${BUILD_VERSION}"
        echo "  Koine's version is one value: set both to ${MARKETING_VERSION}."
    } >&2
    exit 1
fi

# The minimum OS is one value in the same way. App/Info.plist's
# LSMinimumSystemVersion is the source, and the desktop provider's compiler
# target and its manifest's minimumOS are derived from it here rather than
# restating it. Package.swift's platform declaration and the prose in
# docs/specs/machine.md and README.md cannot be derived — a manifest the compiler
# reads and two documents a person reads — so scripts/check-minimum-os.sh
# compares every site against this value and `task check:minimum-os` runs it.
MINIMUM_OS="$(plist_string LSMinimumSystemVersion "${INFO_PLIST}")"
if [[ ! "${MINIMUM_OS}" =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "Error: ${INFO_PLIST} LSMinimumSystemVersion is \"${MINIMUM_OS}\", not MAJOR.MINOR." >&2
    exit 1
fi
MINIMUM_OS_MAJOR="${MINIMUM_OS%%.*}"

RELEASE_TAG="v${MARKETING_VERSION}"
RELEASE_ARTIFACT="${APP_NAME}-${MARKETING_VERSION}.zip"
