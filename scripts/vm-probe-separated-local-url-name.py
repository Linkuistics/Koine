#!/usr/bin/env python3
"""k164-1: authorized separated-control eight-case collection (PTY preflight)."""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import secrets
import select
import shlex
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import Any

SPEC = importlib.util.spec_from_file_location(
    "k149_transport", "scripts/vm-probe-file-reference-url.py"
)
assert SPEC and SPEC.loader
OLD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(OLD)
ROOT = Path("docs/verification/separated-local-url-naming")
ARCHIVE = Path(".build/separated-local-url-naming.zip")
EXE = "/tmp/k164-bundle/K164Probe.app/Contents/MacOS/K164Probe"
SDK_HEADER = Path(
    "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Foundation.framework/Headers/NSURL.h"
)


def fixtures() -> list[dict[str, Any]]:
    result = []
    for size in (900, 1500):
        root = f"/Users/admin/k164/file-{size}"
        name = f"K164-original-{size}.txt"
        remaining = size - len(root) - len(name) - 1
        parts = []
        while remaining:
            n = min(246, remaining)
            if remaining - n == 1:
                n -= 1
            if n < 2:
                raise ValueError("fixture arithmetic")
            parts.append("d" * (n - 1))
            remaining -= n
        assert len("/".join([root, *parts, name]).encode()) == size
        assert len(parts) + 1 <= 32 and all(len(p) <= 245 for p in parts)
        result.append(
            {
                "root": root,
                "components": parts,
                "name": name,
                "bytes": size,
                "decoy": f"K164-decoy-{size}.txt",
                "marker": f"K164_ORIGINAL_{size}_ONLY\n",
                "decoyMarker": f"K164_DECOY_{size}_ONLY\n",
            }
        )
    return result


def read_response(fd: int, timeout: float) -> str:
    deadline = time.monotonic() + timeout
    response = bytearray()
    was_blocking = os.get_blocking(fd)
    os.set_blocking(fd, False)
    try:
        while time.monotonic() < deadline:
            readable, _, _ = select.select(
                [fd], [], [], max(0, deadline - time.monotonic())
            )
            if not readable:
                break
            try:
                value = os.read(fd, 1)
            except BlockingIOError:
                continue
            if not value:
                raise EOFError("supervisor input closed")
            if value == b"\n":
                return response.decode("ascii").strip()
            response.extend(value)
            if len(response) > 128:
                raise RuntimeError("supervisor response exceeds 128 bytes")
        raise TimeoutError("supervisor response deadline expired")
    finally:
        os.set_blocking(fd, was_blocking)


def dispose(vm: str, output: Path) -> dict[str, Any]:
    result: dict[str, Any] = {"disposed": False, "teardownExit": None}
    if vm:
        try:
            stopped = subprocess.run(
                ["testanyware", "vm", "stop", vm, "--json"],
                capture_output=True,
                text=True,
                timeout=50,
                check=False,
            )
            (output / "vm-stop.json").write_text(stopped.stdout)
            (output / "vm-stop.err").write_text(stopped.stderr)
            result["teardownExit"] = stopped.returncode
        except (subprocess.SubprocessError, OSError) as error:
            result["teardownFailure"] = str(error)
            (output / "vm-stop.json").write_text(
                json.dumps({"ok": False, "error": str(error)}) + "\n"
            )
    try:
        inventory = subprocess.run(
            ["testanyware", "vm", "list", "--json"],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        (output / "vm-list-after.json").write_text(inventory.stdout)
        (output / "vm-list-after.err").write_text(inventory.stderr)
        data = json.loads(inventory.stdout)
        absent = (
            inventory.returncode == 0
            and data.get("ok") is True
            and not data.get("truncated")
            and isinstance(data.get("items"), list)
            and all(
                item.get("name") != vm and item.get("id") != vm
                for item in data["items"]
            )
        )
        result["inventoryConfirmedAbsent"] = absent
        result["disposed"] = absent and (not vm or result["teardownExit"] == 0)
    except (subprocess.SubprocessError, OSError, ValueError, TypeError) as error:
        result["inventoryFailure"] = str(error)
    return result


class Run(OLD.Run):
    def preflight(self) -> None:
        token = "PREFLIGHT-" + secrets.token_hex(8)
        prompt = (
            f"TRANSPORT CHECK: reply {token} within 60 seconds; no guest allocated."
        )
        facts = {
            "stdinIsTTY": sys.stdin.isatty(),
            "stdoutIsTTY": sys.stdout.isatty(),
            "ttyName": os.ttyname(sys.stdin.fileno()) if sys.stdin.isatty() else None,
            "term": os.environ.get("TERM"),
            "prompt": prompt,
            "token": token,
        }
        started = time.monotonic()
        print(prompt, flush=True)
        answer = ""
        if facts["stdinIsTTY"] and facts["stdoutIsTTY"]:
            try:
                answer = read_response(sys.stdin.fileno(), 60)
            except (TimeoutError, EOFError, RuntimeError, UnicodeError) as error:
                facts["inputFailure"] = str(error)
        facts.update(
            {
                "received": answer,
                "elapsedSeconds": time.monotonic() - started,
                "success": answer == token and time.monotonic() - started <= 60,
            }
        )
        (self.output / "preflight.json").write_text(json.dumps(facts, indent=2) + "\n")
        self.note("preflight", **facts)
        if not facts["success"]:
            raise RuntimeError("preclone transport preflight failed; no clone or retry")

    def ta(self, *args: str, timeout: float = 45) -> subprocess.CompletedProcess[str]:
        remaining = 840 - (time.monotonic() - self.start)
        if remaining <= 0:
            raise TimeoutError("aggregate cap: final minute reserved for disposal")
        return super().ta(*args, timeout=min(timeout, remaining))

    def download(self, remote: str, local: Path) -> bool:
        remaining = 840 - (time.monotonic() - self.start)
        if remaining <= 0:
            raise TimeoutError("aggregate cap during evidence transfer")
        r = subprocess.run(
            [
                "testanyware",
                "file",
                "download",
                remote,
                str(local),
                "--vm",
                self.vm,
                "--json",
            ],
            capture_output=True,
            text=True,
            timeout=min(10, remaining),
            check=False,
        )
        return r.returncode == 0 and local.exists()

    def checkpoint(self, name: str) -> None:
        self.note("supervisor-checkpoint", name=name, choices=["READY", "STOP"])
        print(f"INSPECT {name}; READY or STOP (60-second bound):", flush=True)
        answer = read_response(
            sys.stdin.fileno(), min(60, max(0, 840 - (time.monotonic() - self.start)))
        )
        self.note("supervisor-response", name=name, answer=answer)
        if answer != "READY":
            raise RuntimeError(f"supervisor stop at {name}: {answer}")

    def observe(self, name: str) -> None:
        r = self.ta("agent", "snapshot", "--mode", "full", timeout=25)
        (self.output / f"{name}-ui.json").write_text(r.stdout)
        envelope = json.loads(r.stdout)
        if not envelope.get("ok") or envelope.get("truncated"):
            raise RuntimeError("unusable agent observer")
        self.ta("screen", "capture", "-o", str(self.output / f"{name}.png"), timeout=25)
        self.checkpoint(name)

    def case(self, mode: str, c: dict[str, Any], name: str) -> list[dict[str, Any]]:
        local = self.output / f"{name}-input.json"
        remote = f"/tmp/k164-{name}.json"
        self.ta("file", "upload", str(local), remote)
        command = (
            f"{EXE} {shlex.quote(mode)} {shlex.quote(remote)} & probe_pid=$!; "
            '(sleep 30; kill -TERM "$probe_pid" 2>/dev/null; sleep 5; '
            'kill -KILL "$probe_pid" 2>/dev/null) & guard_pid=$!; '
            'wait "$probe_pid"; probe_status=$?; kill "$guard_pid" 2>/dev/null; '
            'wait "$guard_pid" 2>/dev/null; exit "$probe_status"'
        )
        raw = self.shell(command, name)
        rows = [json.loads(line) for line in raw.splitlines() if line.strip()]
        if not rows or rows[-1].get("event") != "done":
            raise RuntimeError(f"incomplete helper at {name}")
        if any(r.get("event") == "incomplete" for r in rows):
            raise RuntimeError(f"instrument/control failure at {name}")
        if rows[-1]["descriptorPeak"] > 3 or rows[-1]["descriptorsRemaining"]:
            raise RuntimeError("descriptor cap/leak")
        controls = [r for r in rows if r.get("event") == "controls"]
        before_failed = any(
            r.get("event") == "parentControl" and r["phase"] == "before" and not r["ok"]
            for r in rows
        )
        expected = 1 if mode == "fixture" or before_failed else 2
        if len(controls) != expected:
            raise RuntimeError(f"missing shared file controls at {name}")
        self.note("helper-completed", name=name, mode=mode)
        return rows


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    run = Run(args.output)
    builds = 1
    preserved_build2 = args.output / "build-2.txt"
    if Path(".build/k164-build-2.txt").exists():
        builds = 2
        shutil.copyfile(".build/k164-build-2.txt", preserved_build2)
    preserved_checks = args.output / "instrument-check.txt"
    shutil.copyfile(".build/k164-instrument-check.txt", preserved_checks)
    corpus = fixtures()
    corpus_path = args.output / "corpus.json"
    corpus_path.write_text(json.dumps(corpus, indent=2) + "\n")
    preserved_build = args.output / "build-1.txt"
    shutil.copyfile(".build/k164-build-1.txt", preserved_build)
    preserved_archive = args.output / "probe.zip"
    shutil.copyfile(ARCHIVE, preserved_archive)
    inputs = []
    for c in corpus:
        for mode in ("fixture", "original", "bare", "parent-public", "parent-bare"):
            path = args.output / f"{mode}-{c['bytes']}-input.json"
            path.write_text(json.dumps(c, sort_keys=True) + "\n")
            inputs.append(path)
    retained = [
        p
        for directory in (
            "native-reference-acquisition",
            "item-array-submission",
            "file-reference-url-acquisition",
            "same-object-namespace",
            "focused-zed-receiver",
            "bookmark-name-resolution",
            "local-url-naming",
        )
        for p in Path(f"docs/verification/{directory}").rglob("*")
        if p.is_file() and "__pycache__" not in p.parts
    ]
    subjects = [
        Path(__file__),
        ROOT / "probe.m",
        ROOT / "plan.md",
        Path("scripts/build-separated-local-url-name-probe.sh"),
        Path("scripts/vm-probe-file-reference-url.py"),
        Path("scripts/signing-env.sh"),
        Path("App/Koine.entitlements"),
        Path("Taskfile.yml"),
        Path("docs/verification/focused-zed-route-assessment.md"),
        SDK_HEADER,
        SDK_HEADER.parents[2] / "CoreFoundation.framework/Headers/CFURL.h",
        ROOT / "test_supervisor.py",
        ARCHIVE,
        Path(
            ".build/separated-local-url-naming/K164Probe.app/Contents/MacOS/K164Probe"
        ),
        Path(".build/k164-build-1.txt"),
        corpus_path,
        *inputs,
        *retained,
        Path("scripts/vm-probe-local-url-name.py"),
        Path("scripts/build-local-url-name-probe.sh"),
        Path("docs/verification/local-url-naming-prototype.md"),
        Path("docs/verification/local-url-naming-technical-evidence.md"),
        Path("scripts/vm-probe-bookmark-name.py"),
        Path("scripts/build-bookmark-name-probe.sh"),
        Path("docs/verification/bookmark-name-resolution-prototype.md"),
        Path("docs/verification/bookmark-name-resolution-technical-evidence.md"),
        Path("docs/verification/same-object-namespace-prototype.md"),
        Path("docs/verification/focused-zed-receiver-prototype.md"),
        Path("docs/verification/focused-zed-receiver-technical-evidence.md"),
        Path("scripts/vm-probe-same-object.py"),
        Path("scripts/build-same-object-probe.sh"),
        Path("scripts/vm-probe-focused-zed.py"),
        Path("scripts/build-focused-zed-probe.sh"),
        preserved_build,
        *([preserved_build2, Path(".build/k164-build-2.txt")] if builds == 2 else []),
        preserved_checks,
        Path(".build/k164-instrument-check.txt"),
        preserved_archive,
    ]
    before = OLD.hashes(subjects)
    (args.output / "subjects-before.json").write_text(
        json.dumps(before, indent=2) + "\n"
    )
    host = subprocess.run(
        ["xcrun", "clang", "--version"], capture_output=True, text=True, check=True
    ).stdout
    host += subprocess.run(
        ["xcrun", "--show-sdk-version"], capture_output=True, text=True, check=True
    ).stdout
    (args.output / "host-build-environment.txt").write_text(host)
    summary: dict[str, Any] = {
        "version": "k164-1",
        "complete": False,
        "builds": builds,
        "collections": 0,
        "repairs": 0,
        "externalRequests": 0,
        "cases": [],
        "attemptedCases": 0,
        "firstFailure": None,
        "remaining": [
            f"{mode}-{size}"
            for modes in (("original", "bare"), ("parent-public", "parent-bare"))
            for size in (900, 1500)
            for mode in modes
        ],
    }
    run.start = time.monotonic()
    try:
        run.preflight()
        run.start = time.monotonic()
        run.vm = "koine-k164"
        summary["collections"] = 1
        run.note("clone-start-request", base="koine-launchers-prepared")
        started = subprocess.run(
            [
                "testanyware",
                "vm",
                "start",
                "--platform",
                "macos",
                "--base",
                "koine-launchers-prepared",
                "--id",
                run.vm,
                "--json",
            ],
            capture_output=True,
            text=True,
            timeout=180,
            check=False,
        )
        (args.output / "vm-start.json").write_text(started.stdout)
        (args.output / "vm-start.err").write_text(started.stderr)
        if started.returncode:
            raise RuntimeError("clone failed; no retry")
        run.ta("file", "upload", str(ARCHIVE), "/tmp/k164.zip")
        run.shell(
            "ditto -x -k /tmp/k164.zip /tmp/k164-bundle; mkdir /Users/admin/k164",
            "install",
        )
        run.shell(
            "sw_vers; uname -a; diskutil info /System/Volumes/Data; spctl --status; "
            "codesign --verify --strict /tmp/k164-bundle/K164Probe.app; "
            "codesign -dvv --entitlements - /tmp/k164-bundle/K164Probe.app 2>&1; "
            f"shasum -a 256 {EXE}",
            "guest-environment",
        )
        run.observe("preparation")
        baseline = {}
        for c in corpus:
            rows = run.case("fixture", c, f"fixture-{c['bytes']}")
            baseline[c["bytes"]] = next(r for r in rows if r.get("event") == "controls")
        blocked: dict[int, str] = {}
        for modes in (("original", "bare"), ("parent-public", "parent-bare")):
            for c in corpus:
                for mode in modes:
                    name = f"{mode}-{c['bytes']}"
                    if mode.startswith("parent") and c["bytes"] in blocked:
                        # Unsuffixed bare-parent open/fstat failed: unrun, not negative.
                        summary["cases"].append(
                            {
                                "name": name,
                                "bytes": c["bytes"],
                                "mode": mode,
                                "result": {
                                    "relativeName": "unrun",
                                    "absoluteName": "unrun",
                                    "read": "unrun",
                                    "firstFailure": "parentControlBlocked",
                                    "blockedBy": blocked[c["bytes"]],
                                },
                            }
                        )
                        summary["remaining"].remove(name)
                        continue
                    run.observe(f"before-{name}")
                    summary["attemptedCases"] += 1
                    rows = run.case(mode, c, name)
                    for r in rows:
                        if r.get("event") == "bookmarkData" and not run.download(
                            r["rawFile"], args.output / f"{name}.bookmark"
                        ):
                            raise RuntimeError("raw bookmark evidence unavailable")
                        if r.get("event") == "controls" and any(
                            r[key] != baseline[c["bytes"]][key]
                            for key in ("parent", "target", "decoy", "bare")
                        ):
                            raise RuntimeError(
                                "fixture identity changed against initial controls"
                            )
                    for r in rows:
                        if r.get("event") == "parentControl" and not r["ok"]:
                            blocked[c["bytes"]] = (
                                f"{r['phase']}-{r['stage']}-errno-{r['errno']}"
                            )
                    result = next(r for r in rows if r.get("event") == "caseResult")
                    summary["cases"].append(
                        {
                            "name": name,
                            "bytes": c["bytes"],
                            "mode": mode,
                            "result": result,
                        }
                    )
                    summary["remaining"].remove(name)
                    if (
                        summary["firstFailure"] is None
                        and result["firstFailure"] is not None
                    ):
                        summary["firstFailure"] = {
                            "case": name,
                            "stage": result["firstFailure"],
                        }
                    run.observe(f"after-{name}")
        summary["complete"] = len(summary["cases"]) == 8 and not blocked
    except (
        RuntimeError,
        TimeoutError,
        subprocess.SubprocessError,
        ValueError,
        OSError,
        EOFError,
        KeyboardInterrupt,
    ) as e:
        summary["stop"] = str(e)
        if summary["firstFailure"] is None:
            summary["firstFailure"] = {"stage": "supervisionOrControl", "cause": str(e)}
        run.note("stopped", reason=str(e))
    finally:
        summary.update(dispose(run.vm, args.output))
        summary["elapsedSeconds"] = round(time.monotonic() - run.start, 2)
        summary["withinAggregateCap"] = summary["elapsedSeconds"] <= 900
        if not summary["disposed"] or not summary["withinAggregateCap"]:
            summary["complete"] = False
            summary["disposalOrBudgetIncomplete"] = True
        after = OLD.hashes(subjects)
        (args.output / "subjects-after.json").write_text(
            json.dumps(after, indent=2) + "\n"
        )
        summary["subjectsUnchanged"] = before == after
        if before != after:
            summary["complete"] = False
        (args.output / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
        outputs = sorted(p for p in args.output.iterdir() if p.is_file())
        (args.output / "output-digests.json").write_text(
            json.dumps(OLD.hashes(outputs), indent=2) + "\n"
        )
        print(json.dumps(summary), flush=True)


if __name__ == "__main__":
    main()
