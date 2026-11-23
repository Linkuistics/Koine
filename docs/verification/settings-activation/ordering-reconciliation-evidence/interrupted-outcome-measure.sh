#!/bin/bash
# Record the k174 failing run, the classifier comparison and the guard mutations.
# Usage: interrupted-outcome-measure.sh BEFORE RED OUTPUT
# BEFORE is the classifier at e72a9aaf. RED is the saved run of the new controls
# on that classifier. Each mutation runs on a private copy of the repository.
set -euo pipefail

before="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
red="$2"
output="$3"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "${here}/../../../.." && pwd)"
sequence=scripts/settings-ordering-sequence.py
suite=Tests/scripts/vm-settings-sequence.bats
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT

copy() {
    rm -rf "${work}/repo"
    mkdir -p "${work}/repo"
    cp -R "${repo}/scripts" "${repo}/Tests" "${repo}/App" "${work}/repo/"
}

# replace FILE OLD NEW: change exactly one occurrence, or stop.
replace() {
    python3 -I - "$@" <<'PY'
import sys
from pathlib import Path

path, old, new = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
text = path.read_text()
if text.count(old) != 1:
    raise SystemExit(f"expected one occurrence, saw {text.count(old)}: {old}")
path.write_text(text.replace(old, new))
PY
}

# mutation NAME FILE OLD NEW TEST: the named control must fail on the mutant.
mutation() {
    local result
    copy
    (cd "${work}/repo" && bats -f "^$5\$" "${suite}" | grep -q '^ok 1 ') || {
        echo "the control did not pass before mutation ${1}: $5"
        return 1
    }
    replace "${work}/repo/$2" "$3" "$4"
    if (cd "${work}/repo" && bats -f "^$5\$" "${suite}" >/dev/null 2>&1); then
        result="SURVIVED"
    else
        result="caught"
    fi
    printf '%s: %s by "%s"\n' "$1" "${result}" "$5"
    [[ "${result}" == caught ]]
}

{
    echo "# k174 interrupted outcome record"
    echo
    echo "## Failing run of the new controls on the classifier at e72a9aaf"
    grep -E '^[0-9a-f]{64}  |^1\.\.|^(not )?ok ' "${red}"
    echo
    echo "## Exhaustive classifier comparison"
    python3 -I "${here}/interrupted-outcome-differential.py" "${before}" "${repo}/${sequence}"
    echo
    echo "## Guard mutations on private copies"
    mutation any-interrupted-failure "${sequence}" \
        'if first["outcome"] == "interrupted" or (' \
        'if any(a["outcome"] == "interrupted" for a in essential) or (' \
        "an interrupted receipt after another first failure keeps that failure's kind"
    mutation supplemental-counts "${sequence}" \
        'essential = [a for a in failures if not is_supplemental(a["operation"])]' \
        'essential = failures' \
        'an interrupted supplemental capture alone stays unavailable'
    mutation before-the-class "${sequence}" \
        $'    if classified:\n        # Receipts after' \
        $'    if any(a["outcome"] == "interrupted" for a in failures):\n        result["kind"] = "interrupted"\n        return result\n    if classified:\n        # Receipts after' \
        'a classified assertion keeps its kind after an interrupted receipt'
    mutation interrupted-qualifies "${sequence}" \
        $'kind == "complete"\n        and classification["pointer"]' \
        $'kind in {"complete", "interrupted"}\n        and classification["pointer"]' \
        'a scenario zero and passed phases cannot qualify an interrupted receipt'
    mutation wider-signal-range scripts/vm-guest-exec.py \
        'if 128 < local_status <= 192:' \
        'if local_status != 0:' \
        'only a local status in the signal range makes a wait interrupted'
    echo
    echo "## Comparison control: the first mutation must report violations"
    copy
    replace "${work}/repo/${sequence}" \
        'if first["outcome"] == "interrupted" or (' \
        'if any(a["outcome"] == "interrupted" for a in essential) or ('
    if python3 -I "${here}/interrupted-outcome-differential.py" "${before}" "${work}/repo/${sequence}" >"${work}/control"; then
        echo "the comparison missed the mutation"
        exit 1
    fi
    grep -E '^(cases|changed|unchanged|violations) ' "${work}/control"
} >"${output}"
