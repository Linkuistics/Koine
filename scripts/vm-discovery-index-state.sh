#!/bin/bash
# Runs in the guest, never in Koine: what Spotlight says about its own index, as one JSON line.
# The V check of the discovery reads (scripts/vm-verify-discovery.sh) runs it BEFORE Koine reads the
# catalogue, so that an application missing from the catalogue can be told apart from an index that is
# still building. It asks the question the provider's fixed query asks, the application-bundle
# content-type-tree equality, and names where each expected bundle identifier is indexed.
#
# usage: vm-discovery-index-state.sh <bundle identifier>...
set -u
status="$(mdutil -s / 2>&1 | tr '\n' ' ')"
count="$(mdfind "kMDItemContentTypeTree == 'com.apple.application-bundle'" 2>/dev/null | wc -l | tr -d ' ')"
/usr/bin/python3 - "${status}" "${count}" "$@" <<'PY'
import json
import subprocess
import sys

status, count, *identifiers = sys.argv[1:]
present = {}
for identifier in identifiers:
    found = subprocess.run(
        ["mdfind", f"kMDItemCFBundleIdentifier == '{identifier}'"], capture_output=True, text=True
    ).stdout
    present[identifier] = [line for line in found.splitlines() if line]
print(json.dumps({"mdutil": status.strip(), "applicationBundles": int(count), "present": present}))
PY
