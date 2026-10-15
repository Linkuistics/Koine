#!/usr/bin/env python3
"""Captures what the RETAINED workspace 1.0.0 host serves, for
scripts/verify-retained-workspace.sh: the introspection response, the
`koineManagement.providers` rows and `Koine.schemaDigest`, read over loopback HTTP in
one session, as a client reads them.

The host is the retained revision's own KoineCompatibilityHost
(scripts/build-retained-workspace.sh), and the root it bundles stands in for
Contents/PlugIns: the desktop and workspace bundles sealed and approved there.

usage: capture-retained-workspace.py <debug|release> <bundled root> <output directory> <KoineConformance>

Writes <output>/introspection.json, providers.json and digest.
"""
import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
configuration, bundled, out, conformance = sys.argv[1:5]

# verify-compat-pairs.py holds the headless host driver; it reads its configuration
# from argv[1] when imported, and finds a revision's products under .build/compat.
sys.argv = ["verify-compat-pairs.py", configuration]
spec = importlib.util.spec_from_file_location("compat", os.path.join(HERE, "verify-compat-pairs.py"))
compat = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compat)

DIGEST = "{ koine { contractVersion schemaDigest } }"
query = subprocess.run([conformance, "--print-query"], capture_output=True, text=True, check=True).stdout

empty = tempfile.mkdtemp(prefix="koine-retained-empty-")
host = compat.Host("workspace-1.0.0", empty, bundled=bundled)
try:
    status, introspection = host.post(query)
    if status != 200 or introspection is None or introspection.get("errors"):
        sys.exit(f"introspection answered {status}: {json.dumps(introspection)[:400]}")
    served = host.data_of(DIGEST)["koine"]
    providers = host.data_of(compat.CANDIDATES)["koineManagement"]["providers"]
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, "introspection.json"), "w") as file:
        json.dump(introspection, file)
    with open(os.path.join(out, "providers.json"), "w") as file:
        json.dump(providers, file, indent=2)
    with open(os.path.join(out, "digest"), "w") as file:
        file.write(served["schemaDigest"])
    print(f"retained host: {served['contractVersion']}, digest {served['schemaDigest']}")
    print("  providers: " + json.dumps([{k: r[k] for k in r if k != 'diagnostic'} for r in providers]))
finally:
    host.stop()
    shutil.rmtree(empty, ignore_errors=True)
