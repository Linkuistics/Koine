#!/usr/bin/python3
"""Runs in the guest: what is actually installed, as the system reports it.

argv[1] is the catalogue (scripts/launcher-apps.json); stdout is one JSON document.
Everything is read from the bundles and from the system's own tools, never from the
catalogue's expectations: the bundle identifier, version, resolved path, signature,
Gatekeeper's verdict and the quarantine state are the application's, as found.
"""

import json
import os
import plistlib
import re
import subprocess
import sys


def out(*command):
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    return (result.stdout + result.stderr).strip()


def stdout_of(*command):
    # For a value whose absence is an answer: xattr prints its "No such xattr" to
    # stderr, and folding that into the value read an unquarantined system app as quarantined.
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    return result.stdout.strip() if result.returncode == 0 else ""


def inspect(app):
    path = app["path"]
    info_path = os.path.join(path, "Contents", "Info.plist")
    if not os.path.isdir(path):
        return {"name": app["name"], "path": path, "installed": False}
    with open(info_path, "rb") as handle:
        info = plistlib.load(handle)
    executable = os.path.join(
        path, "Contents", "MacOS", info.get("CFBundleExecutable", "")
    )
    signature = out("/usr/bin/codesign", "--display", "--verbose=2", path)
    assessment = out("/usr/sbin/spctl", "-a", "-vv", path)
    quarantine = stdout_of("/usr/bin/xattr", "-p", "com.apple.quarantine", path)
    flags = re.match(r"^([0-9a-f]{4});", quarantine)
    team = re.search(r"^TeamIdentifier=(.*)$", signature, re.MULTILINE)
    authority = re.search(r"^Authority=(.*)$", signature, re.MULTILINE)
    source = re.search(r"^source=(.*)$", assessment, re.MULTILINE)
    return {
        "name": app["name"],
        "installed": True,
        "path": path,
        "realPath": os.path.realpath(path),
        "bundleIdentifier": info.get("CFBundleIdentifier"),
        "version": info.get("CFBundleShortVersionString"),
        "build": info.get("CFBundleVersion"),
        "minimumSystemVersion": info.get("LSMinimumSystemVersion"),
        "architectures": out("/usr/bin/lipo", "-archs", executable).split(),
        "teamIdentifier": team.group(1) if team else None,
        "signingAuthority": authority.group(1) if authority else None,
        "gatekeeper": {
            "accepted": assessment.startswith(f"{path}: accepted"),
            "source": source.group(1) if source else None,
        },
        # Bit 0x40 of the flags is "the user approved opening it"; a download that has
        # never been opened is 0181, and one that has is 01c1. A system application has none.
        "quarantine": {
            "present": bool(quarantine),
            "flags": flags.group(1) if flags else None,
            "approved": bool(flags and int(flags.group(1), 16) & 0x40),
            "agent": quarantine.split(";")[2] if quarantine.count(";") >= 2 else None,
        },
        "running": bool(out("/usr/bin/pgrep", "-f", path + "/Contents/MacOS/")),
    }


def main():
    with open(sys.argv[1]) as handle:
        catalogue = json.load(handle)["apps"]
    browser = {}
    handler = os.path.expanduser("~/vm-default-browser")
    if os.path.exists(handler):
        for line in out(handler, "get").splitlines():
            scheme, _, rest = line.partition(" -> ")
            path, _, identifier = rest.rpartition(" ")
            browser[scheme] = {"path": path, "bundleIdentifier": identifier}
    pending = os.path.expanduser("~/gatekeeper-pending")
    print(
        json.dumps(
            {
                "system": {
                    "productVersion": out("/usr/bin/sw_vers", "-productVersion"),
                    "buildVersion": out("/usr/bin/sw_vers", "-buildVersion"),
                    "architecture": out("/usr/bin/uname", "-m"),
                    "gatekeeper": out(
                        "/usr/sbin/spctl", "--status", "--verbose"
                    ).splitlines(),
                    "homebrew": out("/opt/homebrew/bin/brew", "--version").splitlines()[
                        :1
                    ],
                },
                "defaultBrowser": browser,
                "gatekeeperPendingArchives": sorted(os.listdir(pending))
                if os.path.isdir(pending)
                else [],
                "apps": [inspect(app) for app in catalogue],
            },
            indent=2,
            sort_keys=True,
        )
    )


main()
