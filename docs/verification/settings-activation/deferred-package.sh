#!/bin/bash
# Package even failed acquisition, preserving acquisition and packaging separately.
set -euo pipefail
out="${1:?output directory}" archive="${2:?archive path}" status="${3:?acquisition status}"
printf '%s\n' "${status}" >"${out}/acquisition.exit"
package_status=0
tar -czf "${archive}" -C "$(dirname "${out}")" "$(basename "${out}")" || package_status=$?
printf '%s\n' "${package_status}" >"${out}/package.exit"
[ "${status}" -ne 0 ] || status="${package_status}"
if [ "${status}" -eq 0 ]; then
    printf '%s\n' KOINE_DEFERRED_COMPLETE >"${out}/complete.txt"
    echo KOINE_DEFERRED_COMPLETE
fi
exit "${status}"
