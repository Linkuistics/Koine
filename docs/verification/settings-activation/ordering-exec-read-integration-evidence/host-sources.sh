#!/bin/bash
# Record the primary sources and the host observations behind the k154 dispositions.
# It fetches Apple's open-source CF and adv_cmds files, prints their digests and
# the decisive lines, and observes this Mac. This Mac is the host, not the
# pinned guest, so no line here is guest evidence. Usage: host-sources.sh SCRATCH
set -euo pipefail
scratch="$1"
mkdir "${scratch}"
base=https://raw.githubusercontent.com/apple-oss-distributions
fetch() {
    curl -sSfL -o "${scratch}/$2" "${base}/$1"
    printf '## %s/%s\nsha256 %s\n' "${base}" "$1" "$(shasum -a 256 "${scratch}/$2" | cut -d' ' -f1)"
}
printf '# started: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
sw_vers
fetch CF/main/CFApplicationPreferences.c CFApplicationPreferences.c
sed -n '426,433p' "${scratch}/CFApplicationPreferences.c"
fetch CF/main/CFPreferences.c CFPreferences.c
sed -n '207,214p;494,496p' "${scratch}/CFPreferences.c"
fetch adv_cmds/main/ps/ps.c ps.c
sed -n '671,675p;758,759p' "${scratch}/ps.c"
fetch adv_cmds/main/ps/print.c print.c
sed -n '200,201p;221,222p' "${scratch}/print.c"
fetch adv_cmds/main/ps/keyword.c keyword.c
sed -n '101,102p' "${scratch}/keyword.c"

printf '## ps with one live and one exited PID\n'
sleep 0 &
gone=$!
wait "${gone}" || true
status=0
LC_ALL=C ps -ww -o pid= -p "$$,${gone}" || status=$?
printf 'selected %s,%s exit %s\n' "$$" "${gone}" "${status}"
status=0
LC_ALL=C ps -ww -o pid= -p "${gone}" || status=$?
printf 'selected %s exit %s\n' "${gone}" "${status}"

printf '## comm is argv[0]\n'
(exec -a k154-argv0 /bin/sleep 5) &
named=$!
sleep 1
LC_ALL=C ps -ww -o comm=,command= -p "${named}"
kill "${named}" 2>/dev/null || true
wait "${named}" 2>/dev/null || true
wait "${named}" 2>/dev/null || true

printf '## any-user exports\n'
for path in /Library/Preferences/dev.antony.Koine /Library/Preferences/Network/dev.antony.Koine \
    /Library/Preferences/.GlobalPreferences /Library/Preferences/Network/.GlobalPreferences; do
    status=0
    out="$(defaults export "${path}" -)" || status=$?
    keys="$(printf '%s\n' "${out}" | grep -c '<key>' || true)"
    printf '%s exit %s keys %s exists %s\n' "${path}" "${status}" "${keys}" "$([[ -e "${path}.plist" ]] && echo yes || echo no)"
done
if cmp -s <(defaults export /Library/Preferences/.GlobalPreferences -) \
    <(plutil -convert xml1 -o - /Library/Preferences/.GlobalPreferences.plist); then
    echo 'export of /Library/Preferences/.GlobalPreferences matches its file'
fi
printf 'raw C0 control characters in that export: %s\n' \
    "$(defaults export /Library/Preferences/.GlobalPreferences - | LC_ALL=C tr -d '\t\n\r' | LC_ALL=C tr -dc '\001-\037' | wc -c | tr -d ' ')"

printf '## UserDefaults reads an any-user-only global key\n'
key=MultipleSessionEnabled
printf 'in /Library/Preferences/.GlobalPreferences: %s\n' "$(defaults export /Library/Preferences/.GlobalPreferences - | grep -c "<key>${key}</key>" || true)"
printf 'in the current-user global domain: %s\n' "$(defaults export -g - | grep -c "<key>${key}</key>" || true)"
printf 'in the current-user current-host global domain: %s\n' "$(defaults -currentHost export -g - | grep -c "<key>${key}</key>" || true)"
printf 'managed preferences directory exists: %s\n' "$([[ -e '/Library/Managed Preferences' ]] && echo yes || echo no)"
cat >"${scratch}/probe.swift" <<SWIFT
import Foundation
let defaults = UserDefaults.standard
print("UserDefaults.standard ${key}:", defaults.object(forKey: "${key}").map { "\(\$0)" } ?? "nil")
print("UserDefaults.standard KoineK154AbsentControl:", defaults.object(forKey: "KoineK154AbsentControl").map { "\(\$0)" } ?? "nil")
print("volatileDomainNames:", defaults.volatileDomainNames.sorted())
SWIFT
swiftc -o "${scratch}/probe" "${scratch}/probe.swift" 2>&1
"${scratch}/probe"
printf '# ended: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
