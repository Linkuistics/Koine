#!/bin/bash
# Re-evaluate immutable VM observations; never starts a guest or sends a request.
set -euo pipefail
cd "$(dirname "$0")/.."
evidence=docs/verification/application-locations-vm
subjects=("${evidence}/results.json" "${evidence}/subjects.json" "${evidence}/reveal-request.json"
    scripts/reevaluate-application-locations.sh scripts/reevaluate-application-locations.jq
    scripts/application-location-observations.jq scripts/application-refusal-observations.jq)
before="$(shasum -a 256 "${subjects[@]}")"
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
jq -n -L scripts --slurpfile raw "${evidence}/results.json" \
    --slurpfile subjects "${evidence}/subjects.json" \
    --slurpfile reveal "${evidence}/reveal-request.json" \
    -f scripts/reevaluate-application-locations.jq >"${work}/reevaluated.json"
test "$(shasum -a 256 "${subjects[@]}")" = "${before}"
cp "${work}/reevaluated.json" "${evidence}/reevaluated.json"
printf '%s\n' "${before}" >"${evidence}/reevaluation-inputs.sha256"
shasum -a 256 "${evidence}/reevaluated.json" >"${evidence}/reevaluation-output.sha256"
jq .counts "${evidence}/reevaluated.json"
jq -e 'all(.results[]; .status != "failed")' "${evidence}/reevaluated.json" >/dev/null
if jq -e 'any(.results[]; .status == "pending")' "${evidence}/reevaluated.json" >/dev/null; then
    exit 3
fi
