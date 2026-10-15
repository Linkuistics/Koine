#!/usr/bin/env python3
"""Holds the sealed provider catalogue to the signed bundles it designates.

The application seals a catalogue of the identities Koine ships
(App/ProviderCatalogue.json, copied to Contents/Resources). For every enabled
entry it names the designated bundle, the release and schema versions that bundle
carries and the code-signing identifier its release is signed under; the loader
refuses a bundle that disagrees (docs/specs/machine.md, "Reserved identities").
Nothing at build time makes the two agree, so this compares them, and reads the
SIGNED packaged bundle's own signature for the identifier rather than trusting its
manifest or its Info.plist:

  * every enabled entry's bundle is in Contents/PlugIns, its signature verifies
    and carries the entry's identifier, under the application's own Team ID;
  * its manifest claims the entry's identifier, prefix, release and schema;
  * nothing else is in Contents/PlugIns, and no bundle claims a reserved-only
    identity;
  * the catalogue itself is well formed and consistent (the loader's own rules).

It is an instrument, so it has been seen to fail: `--self-test` mutates the
catalogue's release, its signing identifier and a reserved-only claim in turn and
requires each to be reported.

usage: check-provider-catalogue.py [--self-test] [<Koine.app>]
"""

import copy
import json
import os
import re
import subprocess
import sys

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KNOWN = {"providerId", "graphQLPrefix", "bundle", "release", "schema", "signingIdentifier"}
ENABLED = {"bundle", "release", "schema", "signingIdentifier"}
VERSION = re.compile(r"^(0|[1-9][0-9]{0,9})\.(0|[1-9][0-9]{0,9})\.(0|[1-9][0-9]{0,9})$")


def version_ok(text):
    return bool(VERSION.match(text)) and all(int(part) <= 2147483647 for part in text.split("."))


def signature(path):
    """The Identifier and TeamIdentifier `codesign` reads from the code at `path`."""
    run = subprocess.run(["codesign", "-dvv", path], capture_output=True, text=True)
    found = {}
    for line in run.stderr.splitlines():
        for key in ("Identifier", "TeamIdentifier"):
            if line.startswith(key + "="):
                found[key] = line.split("=", 1)[1]
    return run.returncode == 0, found


def verifies(path):
    run = subprocess.run(["codesign", "--verify", "--strict", "--deep", path], capture_output=True, text=True)
    return run.returncode == 0, run.stderr.strip()


def names(entry):
    return [entry["providerId"], entry["graphQLPrefix"].lower()]


def overlap(left, right):
    return any(a.startswith(b) or b.startswith(a) for a in left for b in right)


def check_catalogue(catalogue):
    """The loader's own rules over the catalogue's text; a list of problems."""
    problems = []
    if not isinstance(catalogue, dict) or list(catalogue.keys()) != ["identities"]:
        return ["the catalogue is not an object holding an identities array"]
    entries = catalogue["identities"]
    for entry in entries:
        identifier = entry.get("providerId", "")
        for stray in sorted(set(entry) - KNOWN):
            problems.append(f"{identifier}: unknown key {stray}")
        if not re.fullmatch(r"[a-z][a-z0-9]*", identifier):
            problems.append(f"{identifier!r} is not a provider identifier")
        if not re.fullmatch(r"[A-Z][A-Za-z0-9]*", entry.get("graphQLPrefix", "")):
            problems.append(f"{identifier}: {entry.get('graphQLPrefix')!r} is not a prefix")
        present = ENABLED & set(entry)
        if present and present != ENABLED:
            problems.append(f"{identifier} states part of a baseline")
        if present == ENABLED:
            for key in ("release", "schema"):
                if not version_ok(entry[key]):
                    problems.append(f"{identifier}: {key} {entry[key]!r} is not major.minor.patch")
            if not entry["bundle"].endswith(".koineprovider") or "/" in entry["bundle"]:
                problems.append(f"{identifier}: {entry['bundle']!r} is not a bundle name")
        if overlap(names(entry), ["koine"]):
            problems.append(f"{identifier} claims a name the core owns")
    for index, entry in enumerate(entries):
        for other in entries[index + 1:]:
            if entry["providerId"] == other["providerId"]:
                problems.append(f"{entry['providerId']} is listed twice")
            elif overlap(names(entry), names(other)):
                problems.append(f"{entry['providerId']} and {other['providerId']} overlap")
    enabled = [entry for entry in entries if ENABLED <= set(entry)]
    for key in ("bundle", "signingIdentifier"):
        values = [entry[key] for entry in enabled]
        if len(values) != len(set(values)):
            problems.append(f"two enabled entries share a {key}")
    return problems


def check(app, catalogue):
    problems = check_catalogue(catalogue)
    if problems:
        return problems
    plugins = os.path.join(app, "Contents", "PlugIns")
    ok, host = signature(app)
    host_team = host.get("TeamIdentifier")
    if not ok or not host_team:
        problems.append(f"{app} carries no Team ID; the approval of a shipped provider derives from it")
    present = sorted(name for name in os.listdir(plugins) if name.endswith(".koineprovider")) \
        if os.path.isdir(plugins) else []
    designated = {entry["bundle"] for entry in catalogue["identities"] if ENABLED <= set(entry)}
    for name in present:
        if name not in designated:
            problems.append(f"{name} is in Contents/PlugIns and no enabled entry designates it")
    for entry in catalogue["identities"]:
        identifier = entry["providerId"]
        if ENABLED <= set(entry):
            bundle = os.path.join(plugins, entry["bundle"])
            if not os.path.isdir(bundle):
                problems.append(f"{identifier}: the designated bundle {entry['bundle']} is not packaged")
                continue
            good, message = verifies(bundle)
            if not good:
                problems.append(f"{identifier}: {entry['bundle']} does not verify: {message}")
            _, found = signature(bundle)
            if found.get("Identifier") != entry["signingIdentifier"]:
                problems.append(
                    f"{identifier}: the signed bundle carries identifier {found.get('Identifier')!r}, "
                    f"the catalogue says {entry['signingIdentifier']!r}"
                )
            if host_team and found.get("TeamIdentifier") != host_team:
                problems.append(
                    f"{identifier}: signed by Team ID {found.get('TeamIdentifier')!r}, not the application's {host_team!r}"
                )
            try:
                with open(os.path.join(bundle, "manifest.json")) as file:
                    manifest = json.load(file)
            except (OSError, ValueError) as error:
                problems.append(f"{identifier}: manifest.json cannot be read: {error}")
                continue
            for key, expected in (
                ("providerId", identifier), ("graphQLPrefix", entry["graphQLPrefix"]),
                ("version", entry["release"]), ("schemaVersion", entry["schema"]),
            ):
                if manifest.get(key) != expected:
                    problems.append(f"{identifier}: the manifest's {key} is {manifest.get(key)!r}, the catalogue says {expected!r}")
        else:
            # Reserved-only: no packaged bundle may claim it.
            for name in present:
                try:
                    with open(os.path.join(plugins, name, "manifest.json")) as file:
                        manifest = json.load(file)
                except (OSError, ValueError):
                    continue
                if overlap([manifest.get("providerId", ""), manifest.get("graphQLPrefix", "").lower()], names(entry)):
                    problems.append(f"{name} claims the reserved-only identity {identifier}")
    return problems


def main():
    arguments = [argument for argument in sys.argv[1:] if not argument.startswith("--")]
    app = os.path.abspath(arguments[0] if arguments else os.environ.get("KOINE_APP_BUNDLE", ".build/app/Koine.app"))
    if not os.path.isdir(app):
        print(f"Error: no application bundle at {app}. Run `task app` first.", file=sys.stderr)
        return 1
    sealed = os.path.join(app, "Contents", "Resources", "ProviderCatalogue.json")
    source = os.path.join(REPOSITORY, "App", "ProviderCatalogue.json")
    with open(sealed) as file:
        catalogue = json.load(file)
    with open(source) as file:
        if json.load(file) != catalogue:
            print(f"Error: {sealed} is not App/ProviderCatalogue.json; rebuild the application.", file=sys.stderr)
            return 1
    problems = check(app, catalogue)
    if "--self-test" in sys.argv:
        # Each mutation must be seen to fail, or a clean read above proves nothing.
        enabled = next(entry for entry in catalogue["identities"] if ENABLED <= set(entry))
        reserved = next(entry for entry in catalogue["identities"] if not ENABLED <= set(entry))
        mutations = {
            "a release the bundle does not carry": lambda c: c["identities"][c["identities"].index(enabled)].update(release="9.9.9"),
            "a signing identifier the bundle does not carry": lambda c: c["identities"][c["identities"].index(enabled)].update(signingIdentifier="dev.example.other"),
            "a designated bundle that is not packaged": lambda c: c["identities"][c["identities"].index(enabled)].update(bundle="Absent.koineprovider"),
            "a reserved-only entry for an enabled identity": lambda c: c["identities"].append({"providerId": enabled["providerId"], "graphQLPrefix": "Other"}),
            "a reserved name the core owns": lambda c: c["identities"].append({"providerId": "koinex", "graphQLPrefix": "Koinex"}),
            "a malformed version": lambda c: c["identities"][c["identities"].index(enabled)].update(release="1.0"),
        }
        failed = False
        for label, mutate in mutations.items():
            mutated = copy.deepcopy(catalogue)
            mutate(mutated)
            if not check(app, mutated):
                print(f"Self-test FAILED: the check did not report {label}.", file=sys.stderr)
                failed = True
            else:
                print(f"Self-test: reported {label}.")
        del reserved
        if failed:
            return 1
    if problems:
        for problem in problems:
            print(f"Error: {problem}", file=sys.stderr)
        return 1
    enabled = [entry["providerId"] for entry in catalogue["identities"] if ENABLED <= set(entry)]
    reserved = [entry["providerId"] for entry in catalogue["identities"] if not ENABLED <= set(entry)]
    print(f"Provider catalogue agrees with the signed bundles: enabled {', '.join(enabled)}; reserved-only {', '.join(reserved)}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
