#!/usr/bin/env python3
"""Guest-only bounded public prefix-link registration matrix and identity observer.

build creates exactly one prefix link per existing physical long copy. state takes
one length/order from the declared six-permutation matrix. snapshot is read-only
and runs immediately before a Koine request. No application delivery uses a link.
"""
from __future__ import annotations

import itertools
import json
import os
import plistlib
import stat
import subprocess
import sys
import time

IDENTIFIER = "dev.koine.test.InstallationFixture"
LSREGISTER = (
    "/System/Library/Frameworks/CoreServices.framework/Frameworks/"
    "LaunchServices.framework/Support/lsregister"
)
ORDERS = ["".join(order) for order in itertools.permutations("ABL")]


def run(arguments: list[str]) -> dict:
    result = subprocess.run(arguments, capture_output=True, text=True, timeout=60, check=False)
    return {"exit": result.returncode, "stdout": result.stdout, "stderr": result.stderr}


def inspect_path(path: str, known: list[dict]) -> dict:
    """Observe components and expand links; this fixture admits no dot-dot paths."""
    if not path.startswith("/") or ".." in path.split("/"):
        raise ValueError("fixture observer needs an absolute path without dot-dot")
    pending = [part for part in path.split("/") if part and part != "."]
    traversed: list[str] = []
    expansions: list[dict] = []
    fd = os.open("/", os.O_RDONLY | os.O_DIRECTORY)
    try:
        while pending:
            part = pending.pop(0)
            identity = os.stat(part, dir_fd=fd, follow_symlinks=False)
            if stat.S_ISLNK(identity.st_mode):
                if len(expansions) == 32:
                    raise ValueError("fixture link budget")
                target = os.readlink(part, dir_fd=fd)
                if ".." in target.split("/"):
                    raise ValueError("fixture observer does not admit dot-dot link text")
                prefix = [] if target.startswith("/") else traversed
                pending = prefix + [p for p in target.split("/") if p and p != "."] + pending
                expanded = "/" + "/".join(pending)
                expansions.append({"path": expanded, "bytes": len(expanded.encode())})
                traversed = []
                os.close(fd)
                fd = os.open("/", os.O_RDONLY | os.O_DIRECTORY)
                continue
            child = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            os.close(fd)
            fd = child
            traversed.append(part)
        identity = os.fstat(fd)
        plist_fd = os.open("Contents/Info.plist", os.O_RDONLY, dir_fd=fd)
        with os.fdopen(plist_fd, "rb") as handle:
            identifier = plistlib.load(handle).get("CFBundleIdentifier")
    finally:
        os.close(fd)
    matches = [subject for subject in known
               if (subject["device"], subject["inode"]) == (identity.st_dev, identity.st_ino)]
    expanded = "/" + "/".join(traversed)
    return {"path": path, "bytes": len(path.encode()), "device": identity.st_dev,
            "inode": identity.st_ino, "identifier": identifier, "expansions": expansions,
            "expandedPath": expanded, "expandedBytes": len(expanded.encode()),
            "knownPhysicalPath": matches[0]["path"] if len(matches) == 1 else None}


def make_prefix(root: str, subject: dict) -> dict:
    parts = subject["path"].split("/")[1:]
    candidates = []
    link = root + f"/prefix-{subject['bytes']}"
    for split in range(1, len(parts)):
        target = "/" + "/".join(parts[:split])
        argument = link + "/" + "/".join(parts[split:])
        if len(target.encode()) < 1024 and len((argument + "/Contents/Info.plist").encode()) < 1024:
            candidates.append((abs(len(target.encode()) - subject["bytes"] // 2), target, argument))
    _, target, argument = min(candidates)
    os.symlink(target, link)
    observed = inspect_path(argument, [subject])
    assert observed["knownPhysicalPath"] == subject["path"] and observed["identifier"] == IDENTIFIER
    assert observed["expandedBytes"] == subject["bytes"]
    return {"link": link, "target": target, "targetBytes": len(target.encode()),
            "argument": argument, "argumentBytes": len(argument.encode()),
            "plistBytes": len((argument + "/Contents/Info.plist").encode()), "observed": observed}


def snapshot(paths: str) -> dict:
    with open(paths + "/prefix-fixtures.json", encoding="utf-8") as handle:
        fixtures = json.load(handle)
    lookup = run([os.path.expanduser("~/lookup"), IDENTIFIER])
    if lookup["exit"] != 0:
        raise RuntimeError(f"native lookup failed: {lookup}")
    fields = lookup["stdout"].strip().split("\t")
    if len(fields) != 3 or fields[0] != IDENTIFIER:
        raise ValueError(f"malformed native lookup: {lookup}")
    def observe(path: str) -> dict | None:
        if path == "none":
            return None
        try:
            return inspect_path(path, fixtures["subjects"])
        except OSError as error:
            return {"path": path, "errno": error.errno, "error": str(error)}
    return {"atMs": int(time.time() * 1000), "native": lookup,
            "preferred": observe(fields[1]),
            "listed": [] if fields[2] == "none" else [observe(path) for path in fields[2].split("|")]}


def main() -> None:
    mode, paths = sys.argv[1:3]
    if mode == "build":
        root = sys.argv[3]
        with open(paths + "/long-applications.json", encoding="utf-8") as handle:
            subjects = json.load(handle)["subjects"]
        for copy in "AB":
            subjects.append(inspect_path(root + f"/{copy}/Fixture.app", []))
        routes = [make_prefix(root, subject) for subject in subjects if subject["bytes"] >= 1024]
        fixtures = {"subjects": subjects, "routes": routes, "orders": ORDERS}
        with open(paths + "/prefix-fixtures.json", "w", encoding="utf-8") as handle:
            json.dump(fixtures, handle, indent=2)
        print(json.dumps(fixtures))
    elif mode == "snapshot":
        print(json.dumps(snapshot(paths)))
    elif mode == "state":
        length, order = int(sys.argv[3]), sys.argv[4]
        if length not in (1024, 1500) or order not in ORDERS:
            raise ValueError("outside declared matrix")
        with open(paths + "/prefix-fixtures.json", encoding="utf-8") as handle:
            fixtures = json.load(handle)
        short = {copy: next(s["path"] for s in fixtures["subjects"]
                            if s["path"].endswith(f"/{copy}/Fixture.app")) for copy in "AB"}
        long_routes = [route["argument"] for route in fixtures["routes"]]
        selected = next(r["argument"] for r in fixtures["routes"]
                        if r["observed"]["expandedBytes"] == length)
        arguments = {**short, "L": selected}
        operations = []
        for flag, path in [("-u", p) for p in [*short.values(), *long_routes]] + [
                ("-f", arguments[copy]) for copy in order]:
            result = run([LSREGISTER, flag, path])
            time.sleep(2)
            operations.append({"flag": flag, "argument": path, "command": result,
                               "snapshot": snapshot(paths)})
        print(json.dumps({"length": length, "orderInvoked": order, "operations": operations,
                          "snapshot": snapshot(paths)}))
    else:
        raise ValueError("unknown mode")


if __name__ == "__main__":
    main()
