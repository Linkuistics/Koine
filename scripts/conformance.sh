#!/bin/bash
# `task conformance`: the whole-contract conformance check of docs/specs/machine.md's
# "Public GraphQL contract", for each of the three profiles (docs/design/profiles/),
# every one against the schema a host actually serves and with its exact provider
# candidates pinned apart from the SDL and the digest:
#
#   core-desktop-old-host              the RELEASED host (v0.1.0, built from its own
#                                      source by scripts/build-baseline-host.sh) with
#                                      its own desktop provider bundled; preserved
#                                      unchanged, and served by the host that predates
#                                      the candidate fields
#   core-desktop-extension-host        this tree's host with the desktop provider as
#                                      its only bundled provider
#   core-desktop-workspace-extension-host
#                                      the signed Koine.app, in a clean TestAnyware VM,
#                                      with desktop and workspace bundled
#                                      (scripts/vm-verify-conformance.sh)
#
# The first two are served by headless hosts over loopback HTTP and need no VM. Each
# check runs only after its controls have been seen to turn it red
# (scripts/conformance-lib.sh).
#
# KOINE_COMPAT_CONFIGURATION (debug|release, default debug) selects the headless hosts'
# build; KOINE_BASELINE_REVISION names another released revision for the old host.
# KOINE_CONFORMANCE_SKIP_VM=1 checks the two headless profiles alone.
set -euo pipefail

cd "$(dirname "$0")/.."
CONFIGURATION="${KOINE_COMPAT_CONFIGURATION:-debug}"
OUT=".build/conformance"
mkdir -p "${OUT}"

# shellcheck source=scripts/conformance-lib.sh
source scripts/conformance-lib.sh

swift build --product KoineConformance >/dev/null
CHECK="$(swift build --show-bin-path)/KoineConformance"

step "The released host and this tree's host, each built from its own source"
scripts/build-compat-pairs.sh "${CONFIGURATION}" >/dev/null

for kind in old-host extension-host; do
    profile="docs/design/profiles/core-desktop-${kind}.json"
    step "Serve the $(jq -r .name "${profile}") contract from a ${kind}"
    python3 scripts/conformance-capture-headless.py "${kind}" "${OUT}/${kind}" "${CONFIGURATION}"
    conformance_controls "${profile}" "${OUT}/${kind}"
    conformance_verdict "${profile}" "${OUT}/${kind}"
done

if [ "${KOINE_CONFORMANCE_SKIP_VM:-}" = 1 ]; then
    step "PASSED for the two headless profiles; the signed application's profile was skipped"
    exit 0
fi
scripts/vm-verify-conformance.sh
step "PASSED for all three profiles"
