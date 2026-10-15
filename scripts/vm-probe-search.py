#!/usr/bin/env python3
"""Bounded discovery measurement; exit zero is completion, not consent approval."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import shlex
import time
from pathlib import Path

# Reuse the established detached-exec/atomic-marker transport and UI tree walk.
spec = importlib.util.spec_from_file_location(
    "path_probe", Path(__file__).with_name("vm-probe-protected-path.py")
)
if spec is None or spec.loader is None:
    raise RuntimeError("Cannot load the existing VM transport")
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)
call = transport.call
remote = transport.remote


def consent(vm: str) -> str:
    sql = "select service,client,auth_value from access where client='dev.antony.Koine'"
    return remote(
        vm,
        "sqlite3 ~/Library/Application\\ Support/com.apple.TCC/TCC.db "
        + shlex.quote(sql)
        + "; sudo -n sqlite3 "
        + "/Library/Application\\ Support/com.apple.TCC/TCC.db "
        + shlex.quote(sql),
    )


def measure(
    vm: str, output: Path, name: str, mode: str, root: str
) -> dict[str, object]:
    remote(
        vm,
        "if pgrep -x Koine >/dev/null; then killall Koine; fi; "
        "tccutil reset All dev.antony.Koine; rm -f /tmp/k19-result.json",
    )
    before = consent(vm)
    if before.strip():
        raise RuntimeError(f"Consent not empty before {name}: {before}")
    config = output / "command.json"
    config.write_text(json.dumps({"case": name, "mode": mode, "root": root}))
    call(vm, "file", "upload", str(config), "/tmp/k19-command.json")
    call(vm, "file", "exec", "--detach", "open -n /Applications/Koine.app")
    prompts = []
    deadline = time.monotonic() + 35
    while time.monotonic() < deadline:
        time.sleep(0.4)
        snapshot = call(vm, "agent", "snapshot", "--mode", "interact")
        for window in snapshot.get("windows", []):
            if window.get("windowType") in ("menuBar", "standard"):
                continue
            text = json.dumps(window, ensure_ascii=False)
            if "would like to access files" not in text or "Koine" not in text:
                raise RuntimeError(f"Unexpected dialog: {text}")
            buttons = [
                n for n in transport.nodes(window) if n.get("label") == "Don’t Allow"
            ]
            if len(buttons) != 1:
                raise RuntimeError(f"No unique refusal button: {text}")
            button = buttons[0]
            call(vm, "screen", "capture", "-o", str(output / f"{name}-prompt.png"))
            prompts.append(window)
            call(
                vm,
                "input",
                "click",
                str(round(button["positionX"] + button["sizeWidth"] / 2)),
                str(round(button["positionY"] + button["sizeHeight"] / 2)),
            )
        finished = remote(
            vm, "if test -f /tmp/k19-result.json; then cat /tmp/k19-result.json; fi"
        )
        if not finished:
            continue
        record = json.loads(finished)
        if record["case"] != name or record["mode"] != mode or record["root"] != root:
            raise RuntimeError("Stale or mismatched completion")
        if record["ppid"] != 1 or record["bundleIdentifier"] != "dev.antony.Koine":
            raise RuntimeError("Not the independently launched Koine host")
        if mode == "content-control" and not prompts:
            raise RuntimeError("Content positive control did not prompt; reject run")
        record.update(
            prompt=bool(prompts),
            prompts=prompts,
            consentBefore=before,
            consentAfter=consent(vm),
        )
        return record
    raise RuntimeError(f"No matching completion for {name}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__,
        epilog="Only a disposable VM: resets Koine TCC, denies dialogs, and disables Spotlight. Example: --vm koine-k19 --output .build/k19-run",
    )
    parser.add_argument("--vm", required=True)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    vm, output = args.vm, args.output
    output.mkdir(parents=True, exist_ok=False)
    subjects = [
        Path(__file__),
        Path("scripts/vm-probe-protected-path.py"),
        Path("scripts/build-search-evidence.sh"),
        Path("docs/verification/search-discovery/probe.swift"),
        Path("App/Info.plist"),
        Path("App/Koine.entitlements"),
        Path(".build/search-evidence/Koine.zip"),
    ]
    digests = {
        str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in subjects
    }
    (output / "subjects-before.json").write_text(json.dumps(digests, indent=2) + "\n")
    guest_subjects = [
        "/Applications/Koine.app/Contents/MacOS/Koine",
        "/Applications/Koine.app/Contents/Info.plist",
        "/Applications/Koine.app/Contents/PlugIns/Workspace.koineprovider/libWorkspaceProvider.dylib",
        "/Users/admin/K19SearchEvidence/KoineNeedleA.txt",
        "/Users/admin/K19SearchEvidence/nested/KoineNeedleB.txt",
    ]
    guest_subjects += [
        f"/Users/admin/{scope}/k19/KoineNeedle.txt"
        for scope in ("Desktop", "Documents", "Downloads")
    ]
    guest_subjects.append("/Volumes/K19NoIndex/fixture/KoineNeedleNoIndex.txt")
    guest_command = "shasum -a 256 " + shlex.join(guest_subjects)
    fixtures = remote(vm, guest_command)
    (output / "fixtures-before.txt").write_text(fixtures)
    environment = {
        "os": remote(vm, "sw_vers"),
        "mounts": remote(vm, "mount"),
        "signature": remote(
            vm,
            "codesign --verify --strict --deep /Applications/Koine.app; codesign -d -vv --entitlements - /Applications/Koine.app 2>&1",
        ),
        "indexBefore": remote(vm, "mdutil -s /"),
        "noIndexVolume": remote(
            vm, "mdutil -s /Volumes/K19NoIndex; diskutil info /Volumes/K19NoIndex"
        ),
        "infoPlist": remote(
            vm, "plutil -p /Applications/Koine.app/Contents/Info.plist"
        ),
    }
    (output / "environment.json").write_text(json.dumps(environment, indent=2) + "\n")
    cases = [
        ("ordinary", "enumerate", "/Users/admin/K19SearchEvidence"),
        ("home-policy", "enumerate", "/Users/admin"),
        ("system-apps", "applications", "/System/Applications"),
        ("user-apps", "applications", "/Applications"),
        ("spotlight-enabled", "spotlight", "/Users/admin/K19SearchEvidence"),
        ("empty-enumerate", "enumerate", "/Users/admin/K19Empty"),
        ("spotlight-empty", "spotlight", "/Users/admin/K19Empty"),
        ("noindex-enumerate", "enumerate", "/Volumes/K19NoIndex/fixture"),
        ("spotlight-noindex", "spotlight", "/Volumes/K19NoIndex/fixture"),
    ]
    cases += [
        (f"{scope.lower()}-enumerate", "enumerate", f"/Users/admin/{scope}/k19")
        for scope in ("Desktop", "Documents", "Downloads")
    ]
    cases += [
        (
            "desktop-content-control",
            "content-control",
            "/Users/admin/Desktop/k19/KoineNeedle.txt",
        ),
        ("spotlight-protected", "spotlight", "/Users/admin/Desktop/k19"),
    ]
    with (output / "results.jsonl").open("w") as records:
        for name, mode, root in cases:
            record = measure(vm, output, name, mode, root)
            records.write(json.dumps(record, ensure_ascii=False) + "\n")
            records.flush()
            print(
                json.dumps(
                    {
                        key: record.get(key)
                        for key in ("case", "prompt", "error", "started", "count")
                    }
                ),
                flush=True,
            )
        environment["disableIndex"] = remote(vm, "sudo -n mdutil -i off /; mdutil -s /")
        for name, mode, root in [
            ("spotlight-disabled", "spotlight", "/Users/admin/K19SearchEvidence"),
            ("enumerate-disabled", "enumerate", "/Users/admin/K19SearchEvidence"),
            ("apps-disabled", "applications", "/System/Applications"),
        ]:
            record = measure(vm, output, name, mode, root)
            records.write(json.dumps(record, ensure_ascii=False) + "\n")
            records.flush()
            print(
                json.dumps(
                    {
                        key: record.get(key)
                        for key in ("case", "prompt", "error", "started", "count")
                    }
                ),
                flush=True,
            )
    after = {
        str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in subjects
    }
    (output / "subjects-after.json").write_text(json.dumps(after, indent=2) + "\n")
    fixtures_after = remote(vm, guest_command)
    (output / "fixtures-after.txt").write_text(fixtures_after)
    (output / "environment.json").write_text(json.dumps(environment, indent=2) + "\n")
    if after != digests or fixtures_after != fixtures:
        raise RuntimeError("Subjects changed during measurement; reject results")
    records = [
        json.loads(line) for line in (output / "results.jsonl").read_text().splitlines()
    ]
    by_name = {record["case"]: record for record in records}
    if by_name["ordinary"].get("paths") != by_name["enumerate-disabled"].get("paths"):
        raise RuntimeError("Enumeration changed with index disabled")
    if by_name["spotlight-enabled"].get("count") != 2:
        raise RuntimeError("Spotlight positive control did not find both indexed files")
    if by_name["empty-enumerate"].get("paths") != []:
        raise RuntimeError("Empty-directory control is not empty")
    if by_name["noindex-enumerate"].get("paths") != [
        "/Volumes/K19NoIndex/fixture/KoineNeedleNoIndex.txt"
    ]:
        raise RuntimeError("Nonindexed fixture was not enumerated")
    if any(
        by_name[name]["prompt"]
        for name in (
            "ordinary",
            "home-policy",
            "system-apps",
            "user-apps",
            "enumerate-disabled",
            "apps-disabled",
            "empty-enumerate",
            "noindex-enumerate",
        )
    ):
        raise RuntimeError("Selected route prompted; reject recommendation")
    print("Measurement complete; review individual results and limits.", flush=True)


if __name__ == "__main__":
    main()
