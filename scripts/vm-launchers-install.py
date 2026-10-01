#!/usr/bin/python3
"""Runs in the guest (uploaded and started detached by scripts/vm-prepare-launchers.sh).

Installs the launchers named in the catalogue (argv[1], scripts/launcher-apps.json)
from their normal distribution, as a person would: a Homebrew cask is quarantined by
Homebrew itself as a download; a vendor zip is fetched with curl and quarantined here
the way a browser would (com.apple.quarantine, flags 0181, on every file). Nothing is
launched. Exits non-zero if any installation failed, after trying all of them.
"""

import json
import os
import subprocess
import sys
import time
import uuid

BREW = "/opt/homebrew/bin/brew"
ENV = dict(
    os.environ,
    HOMEBREW_NO_ANALYTICS="1",
    HOMEBREW_NO_AUTO_UPDATE="1",
    HOMEBREW_NO_INSTALL_CLEANUP="1",
    NONINTERACTIVE="1",
)


def run(*command, check=True):
    print("+", " ".join(command), flush=True)
    result = subprocess.run(command, env=ENV, check=False)
    if check and result.returncode != 0:
        raise RuntimeError(f"{command[0]} exited {result.returncode}")
    return result.returncode


def retried(action, label):
    # A download from a CDN that is far away fails now and then; once more is enough.
    for attempt in (1, 2):
        try:
            action()
            return True
        except Exception as error:  # noqa: BLE001 - reported, then the next application
            print(f"!! {label}: attempt {attempt} failed: {error}", flush=True)
            time.sleep(5)
    return False


def quarantine(path):
    value = f"0181;{int(time.time()):x};Safari;{uuid.uuid4()}"
    run("/usr/bin/xattr", "-w", "-r", "com.apple.quarantine", value, path)


def install_vendor_zip(app):
    archive = "/tmp/launcher-download.zip"
    run("/usr/bin/curl", "-fsSL", "-o", archive, app["install"]["url"])
    run("/usr/bin/shasum", "-a", "256", archive)
    run("/bin/rm", "-rf", app["path"])
    run("/usr/bin/ditto", "-x", "-k", archive, "/Applications")
    os.remove(archive)
    quarantine(app["path"])


def main():
    with open(sys.argv[1]) as handle:
        catalogue = json.load(handle)["apps"]
    failed = []
    # The golden image's Homebrew is months old; its casks point at downloads the
    # vendors have since withdrawn (Dia's was a 404).
    if not retried(lambda: run(BREW, "update"), "brew update"):
        print("!! brew update failed; casks may be stale", flush=True)
    for app in catalogue:
        install = app["install"]
        if install["via"] == "system":
            continue
        print(f"== {app['name']} ({install['via']})", flush=True)
        if install["via"] == "cask":
            action = lambda cask=install["cask"]: run(BREW, "install", "--cask", cask)
        else:
            action = lambda app=app: install_vendor_zip(app)
        if not retried(action, app["name"]) or not os.path.isdir(app["path"]):
            failed.append(app["name"])
    # The downloads are gigabytes the prepared image does not need to carry.
    run(BREW, "cleanup", "--prune=all", "-s", check=False)
    print("FAILED:" + ",".join(failed) if failed else "ALL INSTALLED", flush=True)
    sys.exit(1 if failed else 0)


main()
