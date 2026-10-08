#!/usr/bin/env python3
"""Guest-only application copies and bounded registration attempts for k181.

Copy from an already signed short fixture using a held current directory. No
whole pathname addresses a long subject during construction or presence checks.
Registration attempts deliberately give the platform the long value; their
failure is evidence, never absence or acceptance. Run after installation fixtures:
  vm-long-application-fixtures.py <installation root> <paths directory>
"""
from __future__ import annotations

import errno
import json
import os
import plistlib
import shutil
import subprocess
import sys
import time

from vm_long_location_fixtures import ancestors, build_long, ensure_dir

LSREGISTER = (
    "/System/Library/Frameworks/CoreServices.framework/Frameworks/"
    "LaunchServices.framework/Support/lsregister"
)
IDENTIFIER = "dev.koine.test.InstallationFixture"


def run(arguments: list[str]) -> dict:
    result = subprocess.run(arguments, capture_output=True, text=True, timeout=60, check=False)
    return {"exit": result.returncode, "stdout": result.stdout, "stderr": result.stderr}


def main() -> None:
    root, paths = sys.argv[1:3]
    source = root + "/A/Fixture.app"
    home = os.path.expanduser("~")
    saved = os.open(".", os.O_RDONLY | os.O_DIRECTORY)
    root_fd = os.open(root, os.O_RDONLY | os.O_DIRECTORY)
    subjects = []
    for length in (1024, 1500):
        name = f"long-{length}"
        fd = ensure_dir(root_fd, name)
        path = root + "/" + name
        for component in ancestors(length - len(path.encode()) - len("/Fixture.app")):
            child = ensure_dir(fd, component)
            os.close(fd)
            fd = child
            path += "/" + component
        full = path + "/Fixture.app"
        assert len(full.encode()) == length
        try:
            os.fchdir(fd)
            shutil.copytree(source, "Fixture.app", symlinks=True)
            identity = os.stat("Fixture.app")
            with open("Fixture.app/Contents/Info.plist", "rb") as handle:
                assert plistlib.load(handle)["CFBundleIdentifier"] == IDENTIFIER
        finally:
            os.fchdir(saved)
            os.close(fd)
        with open(paths + f"/app-long-{length}.txt", "wb") as handle:
            handle.write(full.encode())
        subjects.append({"path": full, "bytes": length, "device": identity.st_dev,
                         "inode": identity.st_ino, "identifier": IDENTIFIER})

    control = build_long(root, {"id": "control-document", "bytes": 1023,
                                "leaf": "control.koineinstall", "kind": "file"})
    with open(paths + "/doc-control.txt", "wb") as handle:
        handle.write(control.encode())

    # The same queries the provider consumes, after each independent registration
    # attempt. A short symbolic-link spelling is never mistaken for a long one.
    attempts = []
    lookup = home + "/lookup"
    for subject in subjects:
        path = subject["path"]
        for method in ("absolute", "relative-cwd", "short-link"):
            if method == "absolute":
                result = run([LSREGISTER, "-f", path])
            elif method == "relative-cwd":
                fd = os.open("/", os.O_RDONLY | os.O_DIRECTORY)
                try:
                    for component in path.split("/")[1:-1]:
                        child = os.open(component, os.O_RDONLY | os.O_DIRECTORY, dir_fd=fd)
                        os.close(fd)
                        fd = child
                    os.fchdir(fd)
                    result = run([LSREGISTER, "-f", "Fixture.app"])
                finally:
                    os.fchdir(saved)
                    os.close(fd)
            else:
                link = root + f"/registration-{subject['bytes']}.app"
                try:
                    os.symlink(path, link)
                except OSError as error:
                    if error.errno != errno.ENAMETOOLONG:
                        raise
                    result = {"exit": None, "phase": "short-link-construction",
                              "errno": error.errno, "stdout": "", "stderr": str(error)}
                else:
                    result = run([LSREGISTER, "-f", link])
            time.sleep(2)
            attempts.append({"bytes": subject["bytes"], "method": method,
                             "registration": result, "lookup": run([lookup, IDENTIFIER])})
    os.close(root_fd)
    os.close(saved)
    with open(paths + "/long-applications.json", "w", encoding="utf-8") as handle:
        json.dump({"subjects": subjects, "attempts": attempts}, handle, indent=2)


if __name__ == "__main__":
    main()
