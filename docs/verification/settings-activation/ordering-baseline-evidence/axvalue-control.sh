#!/bin/bash
# shellcheck disable=SC2016 # The two edit strings are literal shell source.
# Run the k175 empty-field control on a private copy, then with a read that
# accepts a missing value. The second run must fail. Run from the repository root.
set -euo pipefail
copy="$(mktemp -d)"
trap 'rm -rf "${copy}"' EXIT
mkdir -p "${copy}/App" "${copy}/Tests"
cp -R scripts "${copy}/scripts"
cp App/Info.plist "${copy}/App/Info.plist"
cp -R Tests/scripts "${copy}/Tests/scripts"
name='omitted AXValue at shortcut-emptied'
echo '$ the control on the unchanged harness'
bats -f "${name}" "${copy}/Tests/scripts/vm-settings-scenario.bats"
old='element="$(settings_element "$1" "$2" value)"'
new='element="$(settings_element "$1" "$2" optional)"'
python3 -I - "${copy}/scripts/vm-settings-scenario-lib.sh" "${old}" "${new}" <<'PY'
import pathlib
import sys

path, old, new = sys.argv[1:]
target = pathlib.Path(path)
text = target.read_text()
assert text.count(old) == 1
target.write_text(text.replace(old, new))
PY
echo "\$ mutation: ${old} -> ${new}"
status=0
bats -f "${name}" "${copy}/Tests/scripts/vm-settings-scenario.bats" >"${copy}/red.txt" 2>&1 || status=$?
grep -E '^(1\.\.1|ok|not ok)' "${copy}/red.txt"
echo "bats status ${status}"
[[ "${status}" != 0 ]]
