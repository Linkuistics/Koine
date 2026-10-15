#!/usr/bin/env python3
"""Check the retained finite matrix item by item; exit 3 means native subjects pending."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path


def main() -> None:
    root = Path("docs/verification/prefix-registration-vm")
    manifest = root / "artifacts.sha256"
    hashes = dict(line.split("  ", 1)[::-1] for line in manifest.read_text().splitlines())
    assert set(hashes) == {path.name for path in root.iterdir() if path.is_file() and path != manifest}
    assert all(hashlib.sha256((root / name).read_bytes()).hexdigest() == value
               for name, value in hashes.items()), "retained artifact digest differs"
    subjects = json.loads((root / "subjects.json").read_text())
    inputs = [*[root / name for name in hashes], manifest, Path(__file__)]
    def digest() -> dict[str, str]:
        return {str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs}
    before = digest()
    expected = {(n, order) for n in (1024, 1500) for order in subjects["orders"]}
    assert subjects["orders"] == ["ABL", "ALB", "BAL", "BLA", "LAB", "LBA"]
    known = {(subject["device"], subject["inode"]): subject for subject in subjects["subjects"]}
    assert len(known) == 4
    for route in subjects["routes"]:
        assert route["targetBytes"] == len(route["target"].encode()) < 1024
        assert route["argumentBytes"] == len(route["argument"].encode()) < 1024
        assert route["plistBytes"] == len((route["argument"] + "/Contents/Info.plist").encode()) < 1024
        observation = route["observed"]
        physical = known[(observation["device"], observation["inode"])]
        assert observation["knownPhysicalPath"] == physical["path"]
        assert observation["expandedPath"] == physical["path"]
        assert observation["expandedBytes"] == physical["bytes"] in (1024, 1500)
    assert sorted(route["observed"]["expandedBytes"] for route in subjects["routes"]) == [1024, 1500]
    for path in sorted(root.glob("state-*.json")):
        state = json.loads(path.read_text())
        expected.remove((state["length"], state["orderInvoked"]))
        assert len(state["operations"]) == 7
        assert [op["flag"] for op in state["operations"]] == ["-u"] * 4 + ["-f"] * 3
        short = {copy: f"/Users/admin/install-fx/{copy}/Fixture.app" for copy in "AB"}
        routes = [route["argument"] for route in subjects["routes"]]
        selected = next(route["argument"] for route in subjects["routes"]
                        if route["observed"]["expandedBytes"] == state["length"])
        paths = {**short, "L": selected}
        assert [op["argument"] for op in state["operations"]] == [
            *short.values(), *routes, *[paths[copy] for copy in state["orderInvoked"]]]
        for snapshot in [op["snapshot"] for op in state["operations"]] + [state["snapshot"]]:
            assert snapshot["native"]["exit"] == 0
            identifier, preferred, listed = snapshot["native"]["stdout"].strip().split("\t")
            assert identifier == "dev.koine.test.InstallationFixture"
            assert preferred == (snapshot["preferred"]["path"] if snapshot["preferred"] else "none")
            assert ([] if listed == "none" else listed.split("|")) == [v["path"] for v in snapshot["listed"]]
            for value in snapshot["listed"] + ([snapshot["preferred"]] if snapshot["preferred"] else []):
                physical = known[(value["device"], value["inode"])]
                assert value["knownPhysicalPath"] == value["expandedPath"] == physical["path"]
                assert value["identifier"] == physical["identifier"]
                assert value["expandedBytes"] == physical["bytes"] < 1024
        long = [op for op in state["operations"]
                if op["flag"] == "-f" and "/prefix-" in op["argument"]]
        assert len(long) == 1 and long[0]["command"]["exit"] == 1
        assert ": -37" in long[0]["command"]["stderr"]
        final = state["snapshot"]
        assert [v["knownPhysicalPath"] for v in final["listed"]] == [
            "/Users/admin/install-fx/A/Fixture.app", "/Users/admin/install-fx/B/Fixture.app"]
        assert final["preferred"]["knownPhysicalPath"] == "/Users/admin/install-fx/A/Fixture.app"
        print(f"Verified {state['length']}/{state['orderInvoked']}: scan -37, only A/B, A preferred")
    assert not expected, expected
    evaluation = json.loads((root / "evaluated.json").read_text())
    assert evaluation["rawRunExit"] == 1
    assert evaluation["registeredLongBothOrders"] == evaluation["preferredLongColdAndRunning"] == "pending"
    provenance = json.loads((root / "input-verification.json").read_text())
    assert len(provenance["files"]) == 55
    assert all(row["unchanged"] and row["before"] == row["after"] for row in provenance["files"])
    assert before == digest(), "evaluator inputs changed during evaluation"
    print("PENDING: registered-long/both-order and preferred-long/cold/running native preconditions")
    raise SystemExit(3)


if __name__ == "__main__":
    main()
