#!/usr/bin/env python3
"""Captures what a headless host serves, for `task conformance`: the introspection
response, the `koineManagement.providers` rows and `Koine.schemaDigest`, read over
loopback HTTP in one session, as a client reads them.

usage: conformance-capture-headless.py <old-host|extension-host> <output directory> [debug|release]

  old-host         the RELEASED host (v0.1.0, or KOINE_BASELINE_REVISION), built from
                   its own source by scripts/build-baseline-host.sh, running the
                   desktop provider built from that same release as its bundled
                   provider: a host that predates the candidate fields, so the rows
                   it serves are the baseline's and the contract is the old-host
                   profile's
  extension-host   this tree's host, with the desktop provider as its bundled
                   provider (`Contents/PlugIns` stood in for by a directory), and
                   nothing else: the extension-host core + desktop profile's

Writes <output>/introspection.json, providers.json, digest and host.json. Nothing
here starts the signed application; core + desktop + workspace is served by it, in a
VM (scripts/vm-verify-conformance.sh).
"""
import importlib.util
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
kind, out = sys.argv[1], sys.argv[2]
configuration = sys.argv[3] if len(sys.argv) > 3 else "debug"

# verify-compat-pairs.py holds the headless host driver; it reads its configuration
# from argv[1] when imported.
sys.argv = ["verify-compat-pairs.py", configuration]
spec = importlib.util.spec_from_file_location("compat", os.path.join(HERE, "verify-compat-pairs.py"))
compat = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compat)

BASELINE_ROWS = "{ koineManagement { providers { provider version schemaVersion state diagnostic } } }"
DIGEST = "{ koine { contractVersion schemaDigest } }"

conformance = os.path.join(compat.products("newer"), "KoineConformance")
query = subprocess.run([conformance, "--print-query"], capture_output=True, text=True, check=True).stdout

if kind == "old-host":
    revision = "baseline"
    empty = tempfile.mkdtemp(prefix="koine-conformance-empty-")
    rows = BASELINE_ROWS
    host = compat.Host(revision, empty, bundled=os.path.join(compat.products("baseline"), "DesktopProviders"))
elif kind == "extension-host":
    revision = "newer"
    empty = tempfile.mkdtemp(prefix="koine-conformance-empty-")
    rows = compat.CANDIDATES
    host = compat.Host(revision, empty, bundled=os.path.join(compat.products("newer"), "DesktopProviders"))
else:
    sys.exit(f"unknown host kind {kind!r}: old-host or extension-host")

try:
    status, introspection = host.post(query)
    if status != 200 or introspection is None or introspection.get("errors"):
        sys.exit(f"introspection answered {status}: {json.dumps(introspection)[:400]}")
    served = host.data_of(DIGEST)["koine"]
    providers = host.data_of(rows)["koineManagement"]["providers"]
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, "introspection.json"), "w") as file:
        json.dump(introspection, file)
    with open(os.path.join(out, "providers.json"), "w") as file:
        json.dump(providers, file, indent=2)
    with open(os.path.join(out, "digest"), "w") as file:
        file.write(served["schemaDigest"])
    with open(os.path.join(out, "host.json"), "w") as file:
        json.dump({
            "kind": kind, "hostRevision": revision, "contractVersion": served["contractVersion"],
            "schemaDigest": served["schemaDigest"], "introspectionBytes": len(json.dumps(introspection)),
        }, file, indent=2)
    print(f"{kind}: {served['contractVersion']}, digest {served['schemaDigest']}")
    print("  providers: " + json.dumps([{k: r[k] for k in r if k != 'diagnostic'} for r in providers]))
finally:
    host.stop()
