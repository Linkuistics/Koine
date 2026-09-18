#!/bin/bash
# Verifies the assembled bundle: a strict signature check, the hardened runtime,
# and the designated requirement the rest of the system will hold it to.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

if [ ! -d "${APP_BUNDLE}" ]; then
    echo "Error: ${APP_BUNDLE} does not exist. Run: task app" >&2
    exit 1
fi

codesign --verify --strict --deep --verbose=2 "${APP_BUNDLE}"

DETAILS="$(codesign --display --verbose=2 "${APP_BUNDLE}" 2>&1)"
if ! grep -q '^CodeDirectory.*flags=.*runtime' <<<"${DETAILS}"; then
    echo "Error: the hardened runtime flag is not set." >&2
    exit 1
fi

# The team is the identity's, read from the signature rather than assumed.
TEAM_ID="$(sed -n 's/^TeamIdentifier=//p' <<<"${DETAILS}")"
if [ -z "${TEAM_ID}" ] || [ "${TEAM_ID}" = "not set" ]; then
    echo "Error: the signature has no team identifier (ad-hoc or self-signed?)." >&2
    exit 1
fi
if [[ "${SIGNING_IDENTITY}" != *"(${TEAM_ID})"* ]]; then
    echo "Error: signed by team ${TEAM_ID}, which \"${SIGNING_IDENTITY}\" does not name." >&2
    exit 1
fi

echo "Designated requirement:"
codesign --display --requirements - "${APP_BUNDLE}" 2>/dev/null | sed -n 's/^designated => /  /p'

# The bundle must satisfy the requirement clients of its identity rely on.
codesign --verify --strict \
    -R="identifier \"${BUNDLE_ID}\" and anchor apple generic and certificate leaf[subject.OU] = \"${TEAM_ID}\"" \
    "${APP_BUNDLE}"

echo "Verified ${APP_BUNDLE}: ${BUNDLE_ID}, team ${TEAM_ID}, hardened runtime."
