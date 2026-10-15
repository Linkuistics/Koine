#!/usr/bin/env python3
"""Controls for fixture identity/expanded spelling; never runs an application."""
import importlib.util
import os
import plistlib
import tempfile
from pathlib import Path

spec = importlib.util.spec_from_file_location("prefix", "scripts/vm-prefix-registration.py")
if spec is None or spec.loader is None:
    raise RuntimeError("missing prefix fixture module")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

with tempfile.TemporaryDirectory() as scratch:
    root = Path(scratch).resolve()
    path = str(root)
    saved = os.open(".", os.O_RDONLY | os.O_DIRECTORY)
    try:
        os.chdir(root)
        for _ in range(10):
            os.mkdir("d" * 150)
            os.chdir("d" * 150)
            path += "/" + "d" * 150
        os.makedirs("Fixture.app/Contents")
        with open("Fixture.app/Contents/Info.plist", "wb") as handle:
            plistlib.dump({"CFBundleIdentifier": module.IDENTIFIER}, handle)
    finally:
        os.fchdir(saved)
        os.close(saved)
    bundle = path + "/Fixture.app"
    physical = module.inspect_path(str(bundle), [])
    assert physical["bytes"] > 1500
    route = module.make_prefix(str(root), physical)
    observed = module.inspect_path(route["argument"], [physical])
    assert observed["knownPhysicalPath"] == str(bundle)
    assert observed["device"] == physical["device"] and observed["inode"] == physical["inode"]
    assert observed["bytes"] < 1024 and observed["expandedBytes"] == physical["bytes"]
    assert route["targetBytes"] < 1024 and route["plistBytes"] < 1024
    wrong = {**physical, "inode": physical["inode"] + 1}
    assert module.inspect_path(route["argument"], [wrong])["knownPhysicalPath"] is None
    try:
        module.inspect_path(str(root / "missing.app"), [physical])
    except FileNotFoundError:
        pass
    else:
        raise AssertionError("missing path accepted")
print("prefix controls passed: short values, expanded length, identity and wrong-identity/missing controls")
