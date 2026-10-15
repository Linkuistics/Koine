#!/usr/bin/env python3
"""Measure the descriptor-relative walk's first-use prompts in a prepared, disposable VM."""

from __future__ import annotations

import argparse
import hashlib
import json
import shlex
import subprocess
import tempfile
import time
import uuid
from pathlib import Path
from typing import TypeAlias, cast

JSON: TypeAlias = None | bool | int | float | str | list["JSON"] | dict[str, "JSON"]
PROBE_ID = "dev.antony.Koine.K174Probe"
LOCATIONS = ("Desktop", "Documents", "Downloads")


def call(vm: str, *arguments: str) -> dict[str, JSON]:
    result = subprocess.run(
        ["testanyware", *arguments, "--vm", vm, "--json"],
        check=True,
        capture_output=True,
        text=True,
        timeout=45,
    )
    value = cast(dict[str, JSON], json.loads(result.stdout))
    if value.get("ok") is not True or value.get("exit_code", 0) != 0:
        raise RuntimeError(f"TestAnyware command failed: {value}")
    return value


def remote(vm: str, command: str) -> str:
    # The guest agent intermittently reports a completed shell as timed out. Use detached
    # execution plus an atomic exit marker and file transfer; the launcher's return never
    # serves as evidence that the command finished.
    prefix = f"/tmp/k174-remote-{uuid.uuid4().hex}"
    script = (
        f"(set -e; {command}) >{prefix}.out 2>{prefix}.err; "
        f"result=$?; printf '%s' \"$result\" >{prefix}.tmp; "
        f"mv {prefix}.tmp {prefix}.code"
    )
    call(vm, "file", "exec", "--detach", script)
    with tempfile.TemporaryDirectory(prefix="k174-collect-") as directory:
        local = Path(directory)
        deadline = time.monotonic() + 20
        while time.monotonic() < deadline:
            result = subprocess.run(
                [
                    "testanyware",
                    "file",
                    "download",
                    "--vm",
                    vm,
                    "--json",
                    f"{prefix}.code",
                    str(local / "code"),
                ],
                check=False,
                capture_output=True,
                text=True,
                timeout=25,
            )
            if result.returncode == 0:
                break
            failure = cast(dict[str, JSON], json.loads(result.stdout))
            if failure.get("code") != "DOWNLOAD_FAILED" or "no such file" not in result.stdout:
                raise RuntimeError(f"Exit-marker transfer failed: {failure}")
            time.sleep(0.1)
        else:
            raise RuntimeError(f"Guest command did not complete: {command}")
        for suffix in ("out", "err"):
            call(vm, "file", "download", f"{prefix}.{suffix}", str(local / suffix))
        if (local / "code").read_text() != "0":
            raise RuntimeError(f"Guest command failed: {command}: {(local / 'err').read_text()}")
        return (local / "out").read_text()


def nodes(value: JSON) -> list[dict[str, JSON]]:
    if isinstance(value, dict):
        return [value] + [node for child in value.values() for node in nodes(child)]
    if isinstance(value, list):
        return [node for child in value for node in nodes(child)]
    return []


def consent(vm: str) -> str:
    sql = f"select service,client,auth_value from access where client='{PROBE_ID}'"
    return remote(
        vm,
        "sqlite3 ~/Library/Application\\ Support/com.apple.TCC/TCC.db "
        + shlex.quote(sql)
        + "; sudo -n sqlite3 "
        + "/Library/Application\\ Support/com.apple.TCC/TCC.db "
        + shlex.quote(sql),
    )


def prepare_commands() -> list[str]:
    """Fixtures, built under the test agent and never by the probe (a separate identity)."""
    commands: list[str] = []
    for location in LOCATIONS:
        root = f"/Users/admin/{location}/k174"
        commands.append(
            f"rm -rf {root}; mkdir -p {root}/dir; "
            f"printf 'k174' > {root}/sample.txt; printf 'k174' > {root}/dir/inner.txt; "
            f"ln -s sample.txt {root}/link; ln -s missing {root}/dangling; "
            f"ln -s {root}/sample.txt {root}/absolute-link; ln -s dir {root}/dir-link"
        )
    return commands


def cases() -> list[tuple[str, str, str]]:
    result: list[tuple[str, str, str]] = []
    for location in LOCATIONS:
        protected = f"/Users/admin/{location}"
        root = f"{protected}/k174"
        walks = (
            f"{root}/sample.txt",
            f"{root}/link",
            f"{root}/absolute-link",
            f"{root}/dangling",
            f"{root}/missing",
            f"{root}/dir/",
            f"{root}/dir/inner.txt",
            f"{root}/dir-link/inner.txt",
            f"{root}/dir/../sample.txt",
            f"{root}/sample.txt/",
            root,
            protected,
        )
        for target in walks:
            result.append((location, "walk", target))
        result.append((location, "open-search", protected))
        # Controls: the read-mode open that prompted in k134, and a content read.
        result.append((location, "open-read", protected))
        result.append((location, "content-read-control", f"{root}/sample.txt"))
    return result


# A control that is not seen to prompt rejects the run: the probe could not have shown one.
CONTROLS = ("open-read", "content-read-control")


def measure(vm: str, output: Path, index: int, case: tuple[str, str, str]) -> dict[str, JSON]:
    location, mode, path = case
    remote(
        vm,
        "if pgrep -x Koine >/dev/null; then killall Koine; fi; "
        f"tccutil reset All {PROBE_ID}; "
        "rm -f /tmp/koine-k174-begin.json /tmp/koine-k174-end.json",
    )
    before = consent(vm)
    if before.strip():
        raise RuntimeError(f"Probe consent not empty before {case}: {before}")
    # Detached exec submits only; the matching result below proves completion.
    call(
        vm,
        "file",
        "exec",
        "--detach",
        "open -n /Applications/KoineK174Probe.app --args " + shlex.join([mode, path]),
    )
    prompts: list[JSON] = []
    deadline = time.monotonic() + 20
    while time.monotonic() < deadline:
        time.sleep(0.4)
        snapshot = call(vm, "agent", "snapshot", "--mode", "interact")
        windows = snapshot.get("windows")
        if not isinstance(windows, list):
            raise TypeError("Snapshot has no windows")
        observed = [
            window
            for window in windows
            if isinstance(window, dict) and window.get("windowType") not in ("menuBar", "standard")
        ]
        for window in observed:
            text = json.dumps(window, ensure_ascii=False)
            if "would like to access files" not in text or "KoineK174Probe" not in text:
                raise RuntimeError(f"Unexpected dialog; inspect guest manually: {text}")
            buttons = [node for node in nodes(window) if node.get("label") == "Don’t Allow"]
            if len(buttons) != 1:
                raise RuntimeError(f"No unique refusal button in {text}")
            button = buttons[0]
            coordinates: list[str] = []
            for position, size in (("positionX", "sizeWidth"), ("positionY", "sizeHeight")):
                start, extent = button.get(position), button.get(size)
                if not isinstance(start, (int, float)) or not isinstance(extent, (int, float)):
                    raise TypeError("Refusal button has no bounds")
                coordinates.append(str(round(start + extent / 2)))
            call(vm, "screen", "capture", "-o", str(output / f"{index:03d}-{location}-{mode}.png"))
            prompts.append(window)
            call(vm, "input", "click", *coordinates)
            time.sleep(0.3)
        finished = remote(
            vm, "if test -f /tmp/koine-k174-end.json; then cat /tmp/koine-k174-end.json; fi"
        )
        if finished:
            record = cast(dict[str, JSON], json.loads(finished))
            if record.get("mode") != mode or record.get("path") != path:
                raise RuntimeError("Stale or wrong result")
            record.update(
                location=location,
                prompt=bool(prompts),
                prompts=prompts,
                consentBefore=before,
                consentAfter=consent(vm),
                caseIndex=index,
            )
            if mode in CONTROLS and not prompts:
                raise RuntimeError(f"Positive control {mode} did not prompt; reject this run")
            return record
    raise RuntimeError(f"No completion in 20 seconds for {case}; inspect guest manually")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Record prompt/error/value observations, not a passing acceptance verdict.",
        epilog="Prepare the VM as docs/verification/descriptor-walk-prompt.md describes. "
        "Example: %(prog)s --vm koine-k174 --output .build/k174-run. "
        "Exit 0 means measurement finished; 1 means tooling/control failure. "
        "Resets probe consent and denies dialogs. Use a new output directory per run.",
    )
    parser.add_argument("--vm", required=True)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    vm = cast(str, args.vm)
    output = cast(Path, args.output)
    output.mkdir(parents=True, exist_ok=False)
    subjects = [
        Path(__file__),
        Path("docs/verification/descriptor-walk-prompt/probe.swift"),
        Path("scripts/build-descriptor-walk-probe.sh"),
        Path("App/Info.plist"),
        Path("App/Koine.entitlements"),
        Path(".build/descriptor-walk-prompt.zip"),
    ]

    def digests() -> dict[str, str]:
        return {str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in subjects}

    before = digests()
    (output / "subjects-before.json").write_text(json.dumps(before, indent=2) + "\n")
    for command in prepare_commands():
        remote(vm, command)
    fixture_paths = [
        "/Applications/KoineK174Probe.app/Contents/MacOS/Koine",
        "/Applications/KoineK174Probe.app/Contents/Info.plist",
    ]
    for location in LOCATIONS:
        root = f"/Users/admin/{location}/k174"
        fixture_paths.extend([f"{root}/sample.txt", f"{root}/dir/inner.txt"])
    fixture_command = "shasum -a 256 " + shlex.join(fixture_paths)
    fixtures_before = remote(vm, fixture_command)
    (output / "fixtures-before.txt").write_text(fixtures_before)
    (output / "environment.json").write_text(
        json.dumps(
            {
                "os": remote(vm, "sw_vers"),
                "signature": remote(
                    vm, "codesign -d -vv --entitlements - /Applications/KoineK174Probe.app 2>&1"
                ),
                "mounts": remote(vm, "mount"),
                "fixtures": remote(
                    vm, "ls -lR " + " ".join(f"/Users/admin/{name}/k174" for name in LOCATIONS)
                ),
            },
            indent=2,
        )
        + "\n"
    )
    with (output / "results.jsonl").open("w") as results:
        for index, case in enumerate(cases(), 1):
            record = measure(vm, output, index, case)
            results.write(json.dumps(record, ensure_ascii=False) + "\n")
            results.flush()
            print(
                json.dumps(
                    {
                        key: record.get(key)
                        for key in ("caseIndex", "location", "mode", "path", "prompt", "outcome")
                    }
                ),
                flush=True,
            )
    after = digests()
    (output / "subjects-after.json").write_text(json.dumps(after, indent=2) + "\n")
    if before != after:
        raise RuntimeError("Measurement subjects changed during run; reject results")
    fixtures_after = remote(vm, fixture_command)
    (output / "fixtures-after.txt").write_text(fixtures_after)
    if fixtures_before != fixtures_after:
        raise RuntimeError("Guest fixtures changed during run; reject results")


if __name__ == "__main__":
    main()
