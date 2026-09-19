#!/bin/bash
# Seals a fixture bundle as a provider is sealed for installation: every image
# and nested framework inside it, then the bundle, with Koine's identity
# (scripts/signing-env.sh). Then approves it in its root, unless
# FIXTURE_UNAPPROVED is set: <root>/<providerId>.approval.json names the
# identity's Team ID, as the README documents for a user.
#
# usage: seal.sh <bundle>
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../../scripts/signing-env.sh
source "${HERE}/../../scripts/signing-env.sh"
BUNDLE="$1"
MAIN="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "${BUNDLE}/Info.plist")"

sign() { codesign --force --timestamp=none --sign "${SIGNING_IDENTITY}" "$1" 2>/dev/null; }

find "${BUNDLE}" -type d -name '*.framework' -prune -print | while read -r nested; do sign "${nested}"; done
find "${BUNDLE}" -type f -name '*.dylib' ! -path '*.framework/*' ! -path "${BUNDLE}/${MAIN}" -print |
    while read -r nested; do sign "${nested}"; done
sign "${BUNDLE}"

[ -z "${FIXTURE_UNAPPROVED:-}" ] || exit 0
TEAM="$(codesign -dvv "${BUNDLE}" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
python3 - "${BUNDLE}" "${TEAM}" <<'PY'
import json, os, sys
bundle, team = sys.argv[1], sys.argv[2]
try:
    with open(os.path.join(bundle, "manifest.json")) as file:
        provider = json.load(file)["providerId"]
except (OSError, ValueError, KeyError):
    sys.exit(0)  # a manifest that names no provider has nothing to approve
record = os.path.join(os.path.dirname(bundle), provider + ".approval.json")
with open(record, "w") as file:
    json.dump({"providerId": provider, "teamIdentifier": team}, file, indent=2)
PY
