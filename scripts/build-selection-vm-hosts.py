#!/usr/bin/env python3
"""Builds, signs and NOTARIZES the purpose-built hosts of the selection acceptance's V seam.

Machine's "Selection acceptance" says a V quarantine case uses an intact notarized host, and that a
purpose-built V host is signed and notarized first. This makes those hosts from the very bundles and
catalogues the N and G seams use (scripts/build-selection-hosts.py, Fixtures/SelectionHost/hosts.json),
with the one change notarization forces: a bundle sealed inside a host, or submitted on its own, needs a
secure timestamp and the hardened runtime, which the fixtures' seal.sh omits deliberately.

  1. The fixtures are copied, and the cases named in EMBEDDED and NOTARIZED are sealed again under the
     identity they already carry, nested images first, with a secure timestamp and the hardened runtime.
     Every other case is left exactly as the N and G seams have it, including each deliberately
     defective one: nothing here alters a seal to make a defect.
  2. The hosts are assembled and signed around the copied fixtures, catalogue and bundles before the
     seal, exactly as N assembles them.
  3. Each host is zipped, submitted to Apple's notary service, waited on, and stapled. The NOTARIZED
     bundles are submitted on their own: a provider bundle is shallow and cannot be stapled, so a Mac
     that meets one looks its ticket up (docs/verification/notarized-release-vm.md). A notary
     verdict other than Accepted fails the run; there is no fallback.

A bundle's notarization is a fact about its bytes (its code directory hash). A case that is embedded in
a notarized host, and an equal copy of it installed per user, are therefore both accepted, and a case that
is neither (`t-good`, the un-notarized update every refusal scenario uses) is refused: the
scenarios depend on that and assert it.

usage: build-selection-vm-hosts.py [--unnotarized] <products directory> <staged framework> <fixtures> <output>

<fixtures> is the output of `task selection:fixtures`. Writes <output>/fixtures, <output>/hosts and
<output>/notarization.json.

`--unnotarized` stops after step 2. It exists to develop and run the V drivers where no notary credential
is available; `notarization.json` then says `"notarized": false`, and the V acceptance run carries that
into its record, because a run on these hosts cannot close a row that Machine's table says needs an intact
notarized host. Without the flag a missing credential or a verdict other than Accepted is an error.
"""

import concurrent.futures
import glob
import json
import os
import re
import shutil
import subprocess
import sys

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IDENTITY = os.environ.get("KOINE_SIGNING_IDENTITY", "Developer ID Application: Antony Blakey (TA43A4RUP3)")
PROFILE = os.environ.get("KOINE_NOTARY_PROFILE", "koine-notary")

# The hosts a V scenario runs against, each a host of Fixtures/SelectionHost/hosts.json.
HOSTS = ["desktop-old", "production", "impostor-host", "slot", "two-slots-sorted", "slot-caught-up"]
# Cases sealed inside those hosts: their seal is made again with a timestamp and the runtime. That includes the
# released desktop provider: it is the v0.1.0 source built here and sealed by seal.sh (scripts/build-baseline-host.sh),
# not the released application's own copy, so it has no secure timestamp and notarization refuses it. Its binary,
# manifest and signing identifier are untouched; only the seal is made again.
EMBEDDED = [
    "released-desktop", "baseline", "sk-baseline", "r1.5.0", "current-desktop", "current-workspace", "desktop-impostor-baseline",
    "workspace-impostor-baseline",
]
# Real first-party updates, notarized on their own so that a genuinely quarantined download of one is
# accepted by Gatekeeper, as a published update would be.
NOTARIZED = ["desktop-update", "workspace-update"]


def run(*command, **more):
    return subprocess.run(command, check=True, capture_output=True, text=True, **more)


def signature(path):
    """(Identifier, flags text, Timestamp present) of a signed code object, or None where it is not signed by a team."""
    result = subprocess.run(["codesign", "-dvv", path], capture_output=True, text=True)
    if result.returncode != 0 or "TeamIdentifier=" not in result.stderr or "TeamIdentifier=not set" in result.stderr:
        return None
    lines = result.stderr.splitlines()
    identifier = next(line.split("=", 1)[1] for line in lines if line.startswith("Identifier="))
    flags = next((line for line in lines if line.startswith("CodeDirectory")), "")
    return identifier, flags, any(line.startswith("Timestamp=") for line in lines)


def reseal(bundle):
    """The bundle's seal made again, nested images first, under the identifier each object already carries,
    with a secure timestamp and the hardened runtime. Returns what it was sealed as."""
    main = subprocess.run(
        ["/usr/libexec/PlistBuddy", "-c", "Print :CFBundleExecutable", os.path.join(bundle, "Info.plist")],
        capture_output=True, text=True, check=True,
    ).stdout.strip()
    nested = sorted(
        path for path in glob.glob(os.path.join(bundle, "**", "*.dylib"), recursive=True)
        if os.path.realpath(path) != os.path.realpath(os.path.join(bundle, main))
    )
    for path in nested + [bundle]:
        found = signature(path)
        if found is None:
            raise SystemExit(f"{path} is not signed by a team: nothing to seal again")
        run("codesign", "--force", "--timestamp", "--options", "runtime", "--identifier", found[0], "--sign", IDENTITY, path)
    run("codesign", "--verify", "--strict", "--deep", bundle)
    sealed = signature(bundle)
    if "runtime" not in sealed[1] or not sealed[2]:
        raise SystemExit(f"{bundle} was sealed again without the hardened runtime and a timestamp: {sealed}")
    return sealed[0]


def bundle_of(case_directory):
    (name,) = [entry for entry in os.listdir(case_directory) if entry.endswith(".koineprovider")]
    return os.path.join(case_directory, name)


def submit(zip_path, label):
    """One submission, waited on; the verdict is read from the answer. Returns the submission id."""
    result = subprocess.run(
        ["xcrun", "notarytool", "submit", zip_path, "--keychain-profile", PROFILE, "--wait"],
        capture_output=True, text=True,
    )
    text = result.stdout + result.stderr
    found = re.search(r"^\s*id: (\S+)", text, re.M)
    identifier = found.group(1) if found else None
    if result.returncode != 0 or not re.search(r"^\s*status: Accepted", text, re.M):
        reasons = ""
        if identifier:
            reasons = subprocess.run(["xcrun", "notarytool", "log", identifier, "--keychain-profile", PROFILE],
                                     capture_output=True, text=True).stdout
        return None, f"{label}: notarization did not return Accepted (profile {PROFILE!r}).\n{text}\n{reasons}"
    return identifier, None


def cdhash(path):
    text = subprocess.run(["codesign", "-dvvv", path], capture_output=True, text=True).stderr
    return next((line.split("=", 1)[1] for line in text.splitlines() if line.startswith("CDHash=")), None)


def main():
    arguments = sys.argv[1:]
    unnotarized = "--unnotarized" in arguments
    arguments = [argument for argument in arguments if argument != "--unnotarized"]
    if len(arguments) != 4:
        raise SystemExit(__doc__)
    products, framework, fixtures, output = (os.path.abspath(argument) for argument in arguments)
    if not unnotarized:
        probe = subprocess.run(["xcrun", "notarytool", "history", "--keychain-profile", PROFILE], capture_output=True, text=True)
        if "No Keychain password item found" in probe.stdout + probe.stderr:
            raise SystemExit(f"no notary keychain profile {PROFILE!r}: see scripts/notarize-app.sh")
    shutil.rmtree(output, ignore_errors=True)
    os.makedirs(output)
    sealed_fixtures = os.path.join(output, "fixtures")
    shutil.copytree(fixtures, sealed_fixtures, symlinks=True)
    sealed = {}
    for case in EMBEDDED + NOTARIZED:
        bundle = bundle_of(os.path.join(sealed_fixtures, case))
        sealed[case] = {"identifier": reseal(bundle), "cdhash": cdhash(bundle)}
    hosts = os.path.join(output, "hosts")
    run(sys.executable, os.path.join(REPOSITORY, "scripts", "build-selection-hosts.py"), products, framework,
        sealed_fixtures, hosts, *HOSTS)

    if unnotarized:
        with open(os.path.join(output, "notarization.json"), "w") as file:
            json.dump({"notarized": False, "resealed": sealed, "hosts": HOSTS}, file, indent=2)
        print(f"UNNOTARIZED hosts (signed only): {hosts}")
        return
    submissions = {}
    work = os.path.join(output, "submissions")
    os.makedirs(work)
    jobs = []
    for host in HOSTS:
        app = os.path.join(hosts, host, "KoineSelectionHost.app")
        archive = os.path.join(work, f"host-{host}.zip")
        run("ditto", "-c", "-k", "--keepParent", app, archive)
        jobs.append((f"host {host}", archive))
    for case in NOTARIZED:
        archive = os.path.join(work, f"bundle-{case}.zip")
        run("ditto", "-c", "-k", "--keepParent", bundle_of(os.path.join(sealed_fixtures, case)), archive)
        jobs.append((f"bundle {case}", archive))
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(jobs)) as pool:
        futures = {label: pool.submit(submit, archive, label) for label, archive in jobs}
        failures = []
        for label, future in futures.items():
            identifier, failure = future.result()
            if failure:
                failures.append(failure)
                continue
            submissions[label] = identifier
            print(f"{label}: Accepted ({identifier})", flush=True)
        if failures:
            # Every verdict is printed before the run stops, so that one rejection does not hide the next.
            raise SystemExit("\n\n".join(failures))
    for host in HOSTS:
        app = os.path.join(hosts, host, "KoineSelectionHost.app")
        run("xcrun", "stapler", "staple", app)
        run("xcrun", "stapler", "validate", app)
        run("codesign", "--verify", "--strict", "--deep", app)
    shutil.rmtree(work)
    with open(os.path.join(output, "notarization.json"), "w") as file:
        json.dump({"notarized": True, "profile": PROFILE, "submissions": submissions, "resealed": sealed, "hosts": HOSTS}, file, indent=2)
    print(f"Notarized hosts: {hosts}")


main()
