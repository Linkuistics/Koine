#!/usr/bin/env python3
"""Measure individual calls in an already prepared, disposable TestAnyware VM."""

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
PROBE_ID = "dev.antony.Koine.K73Probe"


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
    # The guest agent intermittently reports a completed shell as timed out.
    # Use detached execution plus an atomic exit marker and file transfer;
    # the launcher's return never serves as evidence that the command finished.
    prefix = f"/tmp/k73-remote-{uuid.uuid4().hex}"
    script = (
        f"(set -e; {command}) >{prefix}.out 2>{prefix}.err; "
        f"result=$?; printf '%s' \"$result\" >{prefix}.tmp; "
        f"mv {prefix}.tmp {prefix}.code"
    )
    call(vm, "file", "exec", "--detach", script)
    with tempfile.TemporaryDirectory(prefix="k73-collect-") as directory:
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
            if (
                failure.get("code") != "DOWNLOAD_FAILED"
                or "no such file" not in result.stdout
            ):
                raise RuntimeError(f"Exit-marker transfer failed: {failure}")
            time.sleep(0.1)
        else:
            raise RuntimeError(f"Guest command did not complete: {command}")
        for suffix in ("out", "err"):
            call(vm, "file", "download", f"{prefix}.{suffix}", str(local / suffix))
        if (local / "code").read_text() != "0":
            raise RuntimeError(
                f"Guest command failed: {command}: {(local / 'err').read_text()}"
            )
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


def cases() -> list[tuple[str, str, str, str]]:
    result: list[tuple[str, str, str, str]] = []
    for location in ("Desktop", "Documents", "Downloads"):
        root = f"/Users/admin/{location}/k73"
        app = f"Fixture{location}.app"
        identifier = f"dev.antony.Koine.K73Fixture{location}"
        for mode in ("lstat", "stat"):
            for target in ("sample.txt", app, "link", "dangling", "missing"):
                result.append((location, mode, f"{root}/{target}", identifier))
        for mode in ("realpath", "resolve-url"):
            for target in ("link", "dangling"):
                result.append((location, mode, f"{root}/{target}", identifier))
        for mode in (
            "resource-application",
            "resource-type",
            "resource-volume",
            "resource-file",
            "resource-alias",
        ):
            for target in ("sample.txt", app, "sample.alias"):
                result.append((location, mode, f"{root}/{target}", identifier))
        for mode in ("bundle", "registered-app"):
            result.append((location, mode, f"{root}/{app}", identifier))
        for target in ("sample.txt", "sample.alias", ""):
            result.append((location, "default-handler", f"{root}/{target}", identifier))
        result.append(
            (location, "content-read-control", f"{root}/sample.txt", identifier)
        )
    return result


def measure(
    vm: str, output: Path, index: int, case: tuple[str, str, str, str]
) -> dict[str, JSON]:
    location, mode, path, identifier = case
    remote(
        vm,
        "set -e; if pgrep -x Koine >/dev/null; then killall Koine; fi; "
        f"tccutil reset All {PROBE_ID}; "
        "rm -f /tmp/koine-k73-begin.json /tmp/koine-k73-end.json",
    )
    before = consent(vm)
    if before.strip():
        raise RuntimeError(f"Probe consent not empty before {case}: {before}")
    # Agent synchronous exec can retain launch-related pipes after open exits.
    # Detached exec submits only; the matching result below proves completion.
    call(
        vm,
        "file",
        "exec",
        "--detach",
        "open -n /Applications/KoineK73Probe.app --args "
        + shlex.join([mode, path, identifier]),
    )
    prompts: list[JSON] = []
    deadline = time.monotonic() + 20
    observed: list[JSON] = []
    while time.monotonic() < deadline:
        time.sleep(0.4)
        snapshot = call(vm, "agent", "snapshot", "--mode", "interact")
        windows = snapshot.get("windows")
        if not isinstance(windows, list):
            raise TypeError("Snapshot has no windows")
        observed = [
            window
            for window in windows
            if isinstance(window, dict)
            and window.get("windowType") not in ("menuBar", "standard")
        ]
        for window in observed:
            text = json.dumps(window, ensure_ascii=False)
            if "would like to access files" not in text or "KoineK73Probe" not in text:
                raise RuntimeError(f"Unexpected dialog; inspect guest manually: {text}")
            buttons = [
                node for node in nodes(window) if node.get("label") == "Don’t Allow"
            ]
            if len(buttons) != 1:
                raise RuntimeError(f"No unique refusal button in {text}")
            button = buttons[0]
            coordinates: list[str] = []
            for position, size in (
                ("positionX", "sizeWidth"),
                ("positionY", "sizeHeight"),
            ):
                start, extent = button.get(position), button.get(size)
                if not isinstance(start, (int, float)) or not isinstance(
                    extent, (int, float)
                ):
                    raise TypeError("Refusal button has no bounds")
                coordinates.append(str(round(start + extent / 2)))
            screenshot = output / f"{index:03d}-{location}-{mode}.png"
            call(vm, "screen", "capture", "-o", str(screenshot))
            prompts.append(window)
            call(vm, "input", "click", *coordinates)
            time.sleep(0.3)
        finished = remote(
            vm,
            "if test -f /tmp/koine-k73-end.json; then cat /tmp/koine-k73-end.json; fi",
        )
        if finished:
            record = cast(dict[str, JSON], json.loads(finished))
            if record.get("mode") != mode or record.get("path") != path:
                raise RuntimeError("Stale or wrong result")
            if mode == "registered-app" and record.get("value") != path:
                raise RuntimeError(
                    "Registered compatible fixture was not resolved; reject this run"
                )
            record.update(
                location=location,
                prompt=bool(prompts),
                prompts=prompts,
                consentBefore=before,
                consentAfter=consent(vm),
                caseIndex=index,
            )
            if mode == "content-read-control" and not prompts:
                raise RuntimeError(
                    "Positive control did not prompt; reject this measurement"
                )
            return record
    raise RuntimeError(
        f"No completion in 20 seconds for {case}; inspect guest manually"
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Record prompt/error/value observations, not a passing acceptance verdict.",
        epilog="Prepare the VM as documented in protected-path-metadata.md. "
        "Example: %(prog)s --vm koine-k73 --output .build/k73-run. "
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
        Path("docs/verification/protected-path-metadata/probe.swift"),
        Path("docs/verification/protected-path-metadata/make-alias.swift"),
        Path("scripts/build-protected-path-probe.sh"),
        Path("App/Info.plist"),
        Path("App/Koine.entitlements"),
        Path(".build/protected-path-metadata.zip"),
    ]
    before = {
        str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in subjects
    }
    (output / "subjects-before.json").write_text(json.dumps(before, indent=2) + "\n")
    fixture_paths = [
        "/Applications/KoineK73Probe.app/Contents/MacOS/Koine",
        "/Applications/KoineK73Probe.app/Contents/Info.plist",
    ]
    for location in ("Desktop", "Documents", "Downloads"):
        root = f"/Users/admin/{location}/k73"
        fixture_paths.extend(
            [
                f"{root}/Fixture{location}.app/Contents/MacOS/Koine",
                f"{root}/Fixture{location}.app/Contents/Info.plist",
                f"{root}/sample.txt",
                f"{root}/sample.alias",
            ]
        )
    fixture_command = "shasum -a 256 " + shlex.join(fixture_paths)
    fixtures_before = remote(vm, fixture_command)
    (output / "fixtures-before.txt").write_text(fixtures_before)
    (output / "environment.json").write_text(
        json.dumps(
            {
                "os": remote(vm, "sw_vers"),
                "signature": remote(
                    vm,
                    "codesign -d -vv --entitlements - "
                    "/Applications/KoineK73Probe.app 2>&1",
                ),
                "mounts": remote(vm, "mount"),
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
                        key: record[key]
                        for key in (
                            "caseIndex",
                            "location",
                            "mode",
                            "path",
                            "prompt",
                            "outcome",
                        )
                    }
                ),
                flush=True,
            )
    after = {
        str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in subjects
    }
    (output / "subjects-after.json").write_text(json.dumps(after, indent=2) + "\n")
    if before != after:
        raise RuntimeError("Measurement subjects changed during run; reject results")
    fixtures_after = remote(vm, fixture_command)
    (output / "fixtures-after.txt").write_text(fixtures_after)
    if fixtures_before != fixtures_after:
        raise RuntimeError("Guest fixtures changed during run; reject results")


if __name__ == "__main__":
    main()
