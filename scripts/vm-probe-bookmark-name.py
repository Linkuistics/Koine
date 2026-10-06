#!/usr/bin/env python3
"""k158-1: one local-only collection; always dispose; never repair or repeat."""

from __future__ import annotations

import argparse
import importlib.util
import json
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
ROOT = Path("docs/verification/bookmark-name-resolution")
ARCHIVE = Path(".build/bookmark-name-resolution.zip")
EXE = "/tmp/k158-bundle/K158Probe.app/Contents/MacOS/K158Probe"
SDK_HEADER = Path(
    "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Foundation.framework/Headers/NSURL.h"
)


def fixtures() -> list[dict[str, Any]]:
    result = []
    for size in (900, 1500):
        root = f"/Users/admin/k158/file-{size}"
        name = f"K158-original-{size}.txt"
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
                "decoy": f"K158-decoy-{size}.txt",
                "marker": f"K158_ORIGINAL_{size}_ONLY\n",
                "decoyMarker": f"K158_DECOY_{size}_ONLY\n",
            }
        )
    return result


class Run(OLD.Run):
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
        ready, _, _ = select.select(
            [sys.stdin], [], [], min(60, max(0, 840 - (time.monotonic() - self.start)))
        )
        answer = sys.stdin.readline().strip() if ready else "STOP"
        self.note("supervisor-response", name=name, answer=answer)
        if answer != "READY":
            raise RuntimeError(f"supervisor stop at {name}: {answer}")

    def observe(self, name: str) -> None:
        r = self.ta("agent", "snapshot", "--mode", "full", timeout=25)
        (self.output / f"{name}-ui.json").write_text(r.stdout)
        envelope = json.loads(r.stdout)
        if not envelope.get("ok"):
            raise RuntimeError("unusable agent observer")
        self.ta("screen", "capture", "-o", str(self.output / f"{name}.png"), timeout=25)
        self.checkpoint(name)

    def case(self, mode: str, c: dict[str, Any], name: str) -> list[dict[str, Any]]:
        local = self.output / f"{name}-input.json"
        remote = f"/tmp/k158-{name}.json"
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
        if len(controls) != (1 if mode == "fixture" else 2):
            raise RuntimeError(f"missing controls at {name}")
        self.note("helper-completed", name=name, mode=mode)
        return rows


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    run = Run(args.output)
    corpus = fixtures()
    corpus_path = args.output / "corpus.json"
    corpus_path.write_text(json.dumps(corpus, indent=2) + "\n")
    preserved_build = args.output / "build-1.txt"
    shutil.copyfile(".build/k158-build-1.txt", preserved_build)
    preserved_archive = args.output / "probe.zip"
    shutil.copyfile(ARCHIVE, preserved_archive)
    inputs = []
    for c in corpus:
        for mode in ("fixture", "original", "bare"):
            path = args.output / f"{mode}-{c['bytes']}-input.json"
            path.write_text(json.dumps(c, sort_keys=True) + "\n")
            inputs.append(path)
    retained = [
        p
        for directory in ("same-object-namespace", "focused-zed-receiver")
        for p in Path(f"docs/verification/{directory}").rglob("*")
        if p.is_file()
    ]
    subjects = [
        Path(__file__),
        ROOT / "probe.m",
        ROOT / "plan.md",
        Path("scripts/build-bookmark-name-probe.sh"),
        Path("scripts/vm-probe-file-reference-url.py"),
        Path("scripts/signing-env.sh"),
        Path("App/Koine.entitlements"),
        Path("Taskfile.yml"),
        Path("docs/verification/focused-zed-route-assessment.md"),
        SDK_HEADER,
        ARCHIVE,
        Path(".build/bookmark-name-resolution/K158Probe.app/Contents/MacOS/K158Probe"),
        Path(".build/k158-build-1.txt"),
        corpus_path,
        *inputs,
        *retained,
        Path("docs/verification/same-object-namespace-prototype.md"),
        Path("docs/verification/focused-zed-receiver-prototype.md"),
        Path("docs/verification/focused-zed-receiver-technical-evidence.md"),
        Path("scripts/vm-probe-same-object.py"),
        Path("scripts/build-same-object-probe.sh"),
        Path("scripts/vm-probe-focused-zed.py"),
        Path("scripts/build-focused-zed-probe.sh"),
        preserved_build,
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
        "version": "k158-1",
        "complete": False,
        "builds": 1,
        "collections": 1,
        "repairs": 0,
        "externalRequests": 0,
        "cases": [],
        "attemptedCases": 0,
        "firstFailure": None,
        "remaining": ["original-900", "bare-900", "original-1500", "bare-1500"],
    }
    run.start = time.monotonic()
    run.vm = "koine-k158"
    run.note("clone-start-request", base="koine-launchers-prepared")
    try:
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
        run.ta("file", "upload", str(ARCHIVE), "/tmp/k158.zip")
        run.shell(
            "ditto -x -k /tmp/k158.zip /tmp/k158-bundle; mkdir /Users/admin/k158",
            "install",
        )
        run.shell(
            "sw_vers; uname -a; diskutil info /System/Volumes/Data; spctl --status; "
            "codesign --verify --strict /tmp/k158-bundle/K158Probe.app; "
            "codesign -dvv --entitlements - /tmp/k158-bundle/K158Probe.app 2>&1; "
            f"shasum -a 256 {EXE}",
            "guest-environment",
        )
        run.observe("preparation")
        baseline = {}
        for c in corpus:
            rows = run.case("fixture", c, f"fixture-{c['bytes']}")
            baseline[c["bytes"]] = next(r for r in rows if r.get("event") == "controls")
        for c in corpus:
            for mode in ("original", "bare"):
                name = f"{mode}-{c['bytes']}"
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
                result = next(r for r in rows if r.get("event") == "caseResult")
                summary["cases"].append(
                    {"name": name, "bytes": c["bytes"], "mode": mode, "result": result}
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
        summary["complete"] = len(summary["cases"]) == 4
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
        run.note("stopped", reason=str(e))
    finally:
        stopped = subprocess.run(
            ["testanyware", "vm", "stop", run.vm, "--json"],
            capture_output=True,
            text=True,
            timeout=50,
            check=False,
        )
        (args.output / "vm-stop.json").write_text(stopped.stdout)
        (args.output / "vm-stop.err").write_text(stopped.stderr)
        summary["teardownExit"] = stopped.returncode
        summary["elapsedSeconds"] = round(time.monotonic() - run.start, 2)
        summary["withinAggregateCap"] = summary["elapsedSeconds"] <= 900
        inventory = subprocess.run(
            ["testanyware", "vm", "list", "--json"],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        (args.output / "vm-list-after.json").write_text(inventory.stdout)
        (args.output / "vm-list-after.err").write_text(inventory.stderr)
        after = OLD.hashes(subjects)
        (args.output / "subjects-after.json").write_text(
            json.dumps(after, indent=2) + "\n"
        )
        summary["subjectsUnchanged"] = before == after
        (args.output / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
        outputs = sorted(p for p in args.output.iterdir() if p.is_file())
        (args.output / "output-digests.json").write_text(
            json.dumps(OLD.hashes(outputs), indent=2) + "\n"
        )
        print(json.dumps(summary), flush=True)


if __name__ == "__main__":
    main()
