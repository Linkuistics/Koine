#!/usr/bin/env python3
"""Assembles and signs the purpose-built hosts of the selection acceptance.

Each host in Fixtures/SelectionHost/hosts.json is Fixtures/SelectionHost's
executable as a real application: the catalogue it names is put in
Contents/Resources/ProviderCatalogue.json and its bundles in Contents/PlugIns
before anything is signed, then the framework, then the application, inside-out
as scripts/build-app.sh does. A catalogue defect is therefore content that was
wrong when the seal was made; no seal is altered afterwards, and no notarized
application is touched.

usage: build-selection-hosts.py <products directory> <staged framework>
                                <decision fixtures> <output> [<host> ...]

<products directory> holds KoineSelectionHost (`swift build --product KoineSelectionHost`),
<staged framework> is scripts/stage-provider-framework.sh's, <decision fixtures> is
Fixtures/FixtureProvider/build-decisions.sh's output. Builds every host, or the
named ones, into <output>/<host>/KoineSelectionHost.app and prints each path.
"""

import json
import os
import shutil
import subprocess
import sys

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOSTS = os.path.join(REPOSITORY, "Fixtures", "SelectionHost", "hosts.json")
IDENTITY = os.environ.get("KOINE_SIGNING_IDENTITY", "Developer ID Application: Antony Blakey (TA43A4RUP3)")


def run(*command):
    subprocess.run(command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)


def rpaths(executable):
    lines = subprocess.run(["otool", "-l", executable], check=True, capture_output=True, text=True).stdout.splitlines()
    return [lines[i + 2].split()[1] for i, line in enumerate(lines) if "cmd LC_RPATH" in line]


def catalogue_of(definition, identities):
    if "catalogue" in definition:
        catalogue = definition["catalogue"]
    else:
        catalogue = {"identities": [identities[name] for name in definition["identities"]]}
    return catalogue if isinstance(catalogue, str) else json.dumps(catalogue, indent=2)


def production_names():
    """Every identifier, prefix and signing identifier the shipped catalogue holds."""
    with open(os.path.join(REPOSITORY, "App", "ProviderCatalogue.json")) as file:
        identities = json.load(file)["identities"]
    return {
        value.lower() for identity in identities for key, value in identity.items()
        if key in ("providerId", "graphQLPrefix", "signingIdentifier")
    }


def check_fixture_identities(name, definition, identities):
    """A test catalogue never admits a production name: fixtures are only ever admitted by test catalogues."""
    catalogue = definition.get("catalogue") or {"identities": [identities[n] for n in definition["identities"]]}
    if isinstance(catalogue, str):
        return
    taken = production_names()
    for identity in catalogue["identities"]:
        for key in ("providerId", "graphQLPrefix", "signingIdentifier"):
            if identity.get(key, "").lower() in taken:
                raise SystemExit(f"{name}: test catalogue uses the production {key} {identity[key]!r}")


def build(name, definition, identities, products, framework, fixtures, output):
    check_fixture_identities(name, definition, identities)
    app = os.path.join(output, name, "KoineSelectionHost.app")
    shutil.rmtree(os.path.dirname(app), ignore_errors=True)
    contents = os.path.join(app, "Contents")
    for directory in ("MacOS", "Resources", "Frameworks", "PlugIns"):
        os.makedirs(os.path.join(contents, directory))
    executable = os.path.join(contents, "MacOS", "KoineSelectionHost")
    shutil.copy(os.path.join(products, "KoineSelectionHost"), executable)
    shutil.copytree(framework, os.path.join(contents, "Frameworks", "KoineProviderAPI.framework"), symlinks=True)
    # Its module interface is for building providers, not for a shipped application.
    for modules in ("Modules", os.path.join("Versions", "A", "Modules")):
        path = os.path.join(contents, "Frameworks", "KoineProviderAPI.framework", modules)
        if os.path.islink(path):
            os.remove(path)
        else:
            shutil.rmtree(path, ignore_errors=True)
    # The build's run paths name the build tree; the application supplies its own.
    for rpath in rpaths(executable):
        run("install_name_tool", "-delete_rpath", rpath, executable)
    run("install_name_tool", "-add_rpath", "@executable_path/../Frameworks", executable)
    with open(os.path.join(contents, "Info.plist"), "w") as file:
        file.write(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
            "<plist version=\"1.0\"><dict>\n"
            f"<key>CFBundleIdentifier</key><string>dev.antony.Koine.selectionhost.{name}</string>\n"
            "<key>CFBundleExecutable</key><string>KoineSelectionHost</string>\n"
            "<key>CFBundlePackageType</key><string>APPL</string>\n"
            "<key>LSUIElement</key><true/>\n"
            "</dict></plist>\n"
        )
    with open(os.path.join(contents, "Resources", "ProviderCatalogue.json"), "w") as file:
        file.write(catalogue_of(definition, identities))
    for plugin in definition["plugins"]:
        source = os.path.join(fixtures, plugin["case"])
        (bundle,) = [entry for entry in os.listdir(source) if entry.endswith(".koineprovider")]
        # A copy keeps the signature the fixture was sealed with; only the host's own is new.
        shutil.copytree(
            os.path.join(source, bundle), os.path.join(contents, "PlugIns", plugin.get("as", bundle)), symlinks=True
        )
    run("xattr", "-cr", app)
    if definition["signing"] == "developer-id":
        run("codesign", "--force", "--options", "runtime", "--sign", IDENTITY,
            os.path.join(contents, "Frameworks", "KoineProviderAPI.framework"))
        run("codesign", "--force", "--options", "runtime", "--sign", IDENTITY, app)
    elif definition["signing"] == "ad-hoc":
        run("codesign", "--force", "--sign", "-", os.path.join(contents, "Frameworks", "KoineProviderAPI.framework"))
        run("codesign", "--force", "--sign", "-", app)
    else:
        raise SystemExit(f"{name}: signing is {definition['signing']!r}")
    run("codesign", "--verify", "--strict", app)
    team = subprocess.run(["codesign", "-dvv", app], capture_output=True, text=True).stderr
    team = next((line.split("=", 1)[1] for line in team.splitlines() if line.startswith("TeamIdentifier=")), "")
    if (definition["signing"] == "developer-id") != (team not in ("", "not set")):
        raise SystemExit(f"{name}: signed {definition['signing']} but its Team ID reads {team!r}")
    return app


def main():
    if len(sys.argv) < 5:
        raise SystemExit(__doc__)
    products, framework, fixtures, output = (os.path.abspath(argument) for argument in sys.argv[1:5])
    with open(HOSTS) as file:
        spec = json.load(file)
    wanted = sys.argv[5:] or list(spec["hosts"])
    for name in wanted:
        print(build(name, spec["hosts"][name], spec["identities"], products, framework, fixtures, output))


main()
