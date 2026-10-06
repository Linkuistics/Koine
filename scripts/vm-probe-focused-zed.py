#!/usr/bin/env python3
"""k155-1: one supervised two-request collection, always dispose within 15 minutes."""

from __future__ import annotations

import argparse
import importlib.util
import json
import select
import shlex
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
ROOT = Path("docs/verification/focused-zed-receiver")
EXE = "/tmp/k155-bundle/K155Probe.app/Contents/MacOS/K155Probe"
ARCHIVE = Path(".build/focused-zed-receiver.zip")
ZED = Path(".build/k152-zed.zip")


def fixtures() -> list[dict[str, Any]]:
    result = []
    for size in (900, 1500):
        root = f"/Users/admin/k155/file-{size}"
        name = f"K155-target-{size}.txt"
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
                "kind": "file",
                "bytes": size,
                "decoy": f"K155-decoy-{size}.txt",
                "marker": f"K155_TARGET_{size}_ONLY\n",
                "decoyMarker": f"K155_DECOY_{size}_ONLY\n",
            }
        )
    return result


class Run(OLD.Run):
    def snapshot(self, name: str) -> dict[str, Any]:
        r = self.ta("agent", "snapshot", "--mode", "full", timeout=25)
        (self.output / f"{name}-ui.json").write_text(r.stdout)
        self.ta("screen", "capture", "-o", str(self.output / f"{name}.png"), timeout=25)
        return json.loads(r.stdout)

    def checkpoint(self, name: str, choices: tuple[str, ...]) -> str:
        self.note("supervisor-checkpoint", name=name, choices=choices)
        print(
            f"INSPECT {name}; enter {' / '.join(choices)} (60-second bound):",
            flush=True,
        )
        ready, _, _ = select.select(
            [sys.stdin], [], [], min(60, max(0, 840 - (time.monotonic() - self.start)))
        )
        answer = sys.stdin.readline().strip() if ready else "STOP"
        self.note("supervisor-response", name=name, answer=answer)
        if answer.startswith("RESTRICT ") and "RESTRICT" in choices:
            xy = answer.split()
            if len(xy) != 3 or not all(v.isdigit() for v in xy[1:]):
                raise RuntimeError("invalid supervised restricted-choice coordinates")
            return answer
        if answer not in choices or answer == "STOP":
            raise RuntimeError(f"supervisor stop at {name}: {answer}")
        return answer

    def case(self, mode: str, c: dict[str, Any], name: str) -> list[dict[str, Any]]:
        local = self.output / f"{name}-input.json"
        local.write_text(json.dumps(c, sort_keys=True) + "\n")
        remote = f"/tmp/k155-{name}.json"
        self.ta("file", "upload", str(local), remote)
        command = (
            f"{EXE} {shlex.quote(mode)} {shlex.quote(remote)} & probe_pid=$!; "
            '(sleep 10; kill -TERM "$probe_pid" 2>/dev/null; sleep 3; '
            'kill -KILL "$probe_pid" 2>/dev/null) & guard_pid=$!; '
            'wait "$probe_pid"; probe_status=$?; kill "$guard_pid" 2>/dev/null; '
            'wait "$guard_pid" 2>/dev/null; exit "$probe_status"'
        )
        raw = self.shell(command, name)
        rows = [json.loads(line) for line in raw.splitlines() if line.strip()]
        if not rows or rows[-1].get("event") != "done":
            raise RuntimeError(f"incomplete helper at {name}")
        if any(r.get("event") in ("failure", "incomplete") for r in rows):
            raise RuntimeError(f"identity/instrument stop at {name}")
        if any(
            r.get("event") in ("nativeIDControl", "originalIdentity", "fixture")
            and not r.get("ok")
            for r in rows
        ):
            raise RuntimeError(f"failed identity at {name}")
        self.note("helper-completed", name=name, mode=mode)
        return rows


def receipt(
    rows: list[dict[str, Any]], previous: dict[str, Any] | None = None
) -> dict[str, Any]:
    r = next((r for r in rows if r.get("event") == "receipt"), {})
    if not r.get("exact") or not r.get("stable"):
        raise RuntimeError("missing/mismatched executable or kernel-start receipt")
    if previous and any(
        r.get(k) != previous.get(k)
        for k in ("pid", "startSeconds", "startMicros", "liveIdentity")
    ):
        raise RuntimeError("receiver incarnation changed")
    return r


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    run = Run(args.output)
    corpus = fixtures()
    corpus_path = args.output / "corpus.json"
    corpus_path.write_text(json.dumps(corpus, indent=2) + "\n")
    inherited = sorted(Path("docs/verification/same-object-namespace").rglob("*"))
    inherited = [p for p in inherited if p.is_file()] + [
        Path("docs/verification/same-object-namespace-prototype.md"),
        Path("scripts/vm-probe-same-object.py"),
        Path("scripts/build-same-object-probe.sh"),
    ]
    subjects = [
        Path(__file__),
        Path("scripts/vm-probe-file-reference-url.py"),
        ROOT / "probe.m",
        ROOT / "plan.md",
        Path("scripts/build-focused-zed-probe.sh"),
        Path("scripts/signing-env.sh"),
        Path("App/Koine.entitlements"),
        Path("Taskfile.yml"),
        Path("docs/verification/long-action-route.md"),
        ARCHIVE,
        ZED,
        corpus_path,
        *inherited,
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
        "version": "k155-1",
        "complete": False,
        "builds": 2,
        "collections": 1,
        "repairs": 0,
        "attemptedRequests": 0,
        "requests": [],
        "remaining": [900, 1500],
    }
    run.start = time.monotonic()
    run.vm = "koine-k155"
    run.note("clone-start-request")
    try:
        started = subprocess.run(
            [
                "testanyware",
                "vm",
                "start",
                "--platform",
                "macos",
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
        run.ta("file", "upload", str(ARCHIVE), "/tmp/k155.zip")
        run.ta("file", "upload", str(ZED), "/tmp/k155-zed.zip", timeout=120)
        run.shell(
            "ditto -x -k /tmp/k155.zip /tmp/k155-bundle; ditto -x -k /tmp/k155-zed.zip /Applications; mkdir -p /Users/admin/k155; /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Zed.app",
            "install",
            wait=90,
        )
        run.shell(
            "sw_vers; uname -a; sysctl -n hw.model hw.machine; diskutil info /System/Volumes/Data; codesign --verify --strict /tmp/k155-bundle/K155Probe.app; codesign -dvv --entitlements - /tmp/k155-bundle/K155Probe.app 2>&1; shasum -a 256 "
            + EXE
            + "; codesign --verify --strict /Applications/Zed.app; codesign -dvv --entitlements - /Applications/Zed.app 2>&1",
            "guest-environment",
        )
        run.snapshot("preparation")
        run.checkpoint("preparation", ("READY", "STOP"))
        env = run.case("environment", {}, "native-environment")
        if not any(r.get("event") == "zed" and r.get("exact") for r in env):
            raise RuntimeError("short registered Zed copy unestablished")
        controls = {}
        for c in corpus:
            run.case("fixture", c, f"fixture-{c['bytes']}")
            controls[c["bytes"]] = run.case("inspect", c, f"inspect-{c['bytes']}")
        for c in corpus:
            size = c["bytes"]
            run.case("reset", {}, f"reset-{size}")
            time.sleep(1)
            running = run.case("running", {}, f"absent-process-{size}")
            if any(
                r.get("event") == "runningCount" and r.get("count") != 0
                for r in running
            ):
                raise RuntimeError("receiver disappearance unestablished")
            baseline = run.snapshot(f"before-{size}")
            baseline_text = json.dumps(baseline)
            if any(
                str(c[k]).strip() in baseline_text
                for k in ("name", "decoy", "marker", "decoyMarker")
            ):
                raise RuntimeError("fixture/decoy visible in baseline")
            run.checkpoint(f"before-{size}", ("READY", "STOP"))
            summary["attemptedRequests"] += 1
            rows = run.case("named", c, f"request-{size}")
            summary["remaining"].remove(size)
            callback = next((r for r in rows if r.get("event") == "callback"), {})
            if callback.get("error") or not any(
                r.get("event") == "request" and r.get("callbackWithinThreeSeconds")
                for r in rows
            ):
                raise RuntimeError("native acknowledgment failed")
            r = receipt(rows)
            process_input = {
                "pid": r["pid"],
                "callbackExecutableURL": callback["executableURL"],
            }
            time.sleep(1)
            receipt(
                run.case("incarnation", process_input, f"incarnation-before-ui-{size}"),
                r,
            )
            run.snapshot(f"after-request-{size}")
            answer = run.checkpoint(
                f"after-request-{size}", ("RESTRICT", "PASS", "STOP")
            )
            restricted = answer.startswith("RESTRICT")
            if restricted:
                # Only the supervisor's inspected exact fixture dialog authorizes this one choice.
                if answer.startswith("RESTRICT "):
                    _, x, y = answer.split()
                    press = run.ta("input", "click", x, y)
                else:
                    press = run.ta(
                        "agent",
                        "press",
                        "--role",
                        "button",
                        "--label",
                        "Stay in Restricted Mode",
                        "--window",
                        c["name"],
                    )
                (args.output / f"restricted-choice-{size}.json").write_text(
                    press.stdout
                )
                time.sleep(1)
                receipt(
                    run.case(
                        "incarnation", process_input, f"incarnation-after-choice-{size}"
                    ),
                    r,
                )
                run.snapshot(f"after-choice-{size}")
                run.checkpoint(f"after-choice-{size}", ("PASS", "STOP"))
            after = run.case("inspect", c, f"after-identity-{size}")
            initial = next(
                x for x in controls[size] if x.get("event") == "originalIdentity"
            )
            for row in [
                x for x in rows + after if x.get("event") == "originalIdentity"
            ]:
                if any(row[k] != initial[k] for k in ("parent", "target", "decoy")):
                    raise RuntimeError("fixture identity changed")
            summary["requests"].append(
                {
                    "bytes": size,
                    "receiver": "supervisor-confirmed fresh exact target marker",
                    "receipt": r,
                    "restrictedChoice": restricted,
                    "delivery": "opaque",
                }
            )
        summary["complete"] = len(summary["requests"]) == 2
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
