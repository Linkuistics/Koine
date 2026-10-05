#!/usr/bin/env python3
"""k149 fixed diagnostic. One clone, eight cases, no automatic repair or retry.

The guest shell supplies each case's external 30-second watchdog and five-second
termination grace. The host limits the entire clone-through-teardown run to 15 minutes.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shlex
import subprocess
import tempfile
import time
from pathlib import Path
from typing import Any

ROOT = Path("docs/verification/file-reference-url-acquisition")
ARCHIVE = Path(".build/file-reference-url-acquisition.zip")
EXE = "/tmp/k149-bundle/K149Probe.app/Contents/MacOS/K149Probe"
BASE = "/Users/admin/k149"
SUBJECTS = [Path(__file__), ROOT / "probe.m", Path("scripts/build-file-reference-url-probe.sh"),
            Path("scripts/signing-env.sh"), Path("App/Koine.entitlements"), Path("Taskfile.yml"),
            Path("docs/verification/long-action-route.md"), ARCHIVE]


def hashes(paths: list[Path]) -> dict[str, str]:
    return {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}


def fixtures() -> list[dict[str, Any]]:
    result = []
    for size in (900, 1023, 1024, 1500):
        root = f"{BASE}/f{size}"
        name = "target.txt"
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
        c = {"root": root, "components": parts, "name": name, "decoy": "decoy.txt",
             "marker": f"k149-target-{size}\n", "bytes": size}
        assert len("/".join([root, *parts, name]).encode()) == size
        assert len(parts) + 1 <= 32 and all(len(p) <= 245 for p in parts)
        result.append(c)
    return result


class Run:
    def __init__(self, output: Path) -> None:
        output.mkdir(parents=True, exist_ok=False)
        self.output = output
        self.vm = ""
        self.start = 0.0
        self.sequence = 0

    def note(self, event: str, **values: Any) -> None:
        row = {"event": event, "utcEpoch": time.time(), "elapsed": round(time.monotonic() - self.start, 2), **values}
        with (self.output / "driver-log.jsonl").open("a") as f:
            f.write(json.dumps(row) + "\n")
        print(json.dumps(row), flush=True)

    def ta(self, *args: str, timeout: float = 45) -> subprocess.CompletedProcess[str]:
        if self.start and time.monotonic() - self.start > 840:
            raise TimeoutError("aggregate cap: reserve final minute for teardown")
        r = subprocess.run(["testanyware", *args, "--vm", self.vm, "--json"],
                           capture_output=True, text=True, timeout=timeout, check=False)
        if r.returncode:
            raise RuntimeError(f"testanyware {args[:2]}: {r.stderr[-500:]} {r.stdout[-500:]}")
        return r

    def download(self, remote: str, local: Path) -> bool:
        r = subprocess.run(["testanyware", "file", "download", remote, str(local),
                            "--vm", self.vm, "--json"], capture_output=True, text=True,
                           timeout=10, check=False)
        return r.returncode == 0 and local.exists()

    def shell(self, command: str, name: str, wait: float = 45) -> str:
        self.sequence += 1
        prefix = f"/tmp/k149-cmd-{self.sequence}"
        # No changing cwd. Preserve stdout/stderr and the completion exit code.
        wrapped = f"({command}) >{prefix}.out 2>{prefix}.err; echo $? >{prefix}.tmp; mv {prefix}.tmp {prefix}.code"
        launched = self.ta("file", "exec", "--detach", wrapped)
        (self.output / f"{name}-launch.json").write_text(launched.stdout)
        with tempfile.TemporaryDirectory() as tmp:
            code = Path(tmp) / "code"
            deadline = time.monotonic() + wait
            while time.monotonic() < deadline:
                if self.download(prefix + ".code", code):
                    break
                time.sleep(0.25)
            else:
                raise TimeoutError(f"guest command {name} did not complete")
            for suffix in ("out", "err"):
                if not self.download(prefix + "." + suffix, self.output / f"{name}.{suffix}"):
                    raise RuntimeError(f"missing {name}.{suffix}")
            status = code.read_text().strip()
        (self.output / f"{name}.code").write_text(status + "\n")
        if status != "0":
            raise RuntimeError(f"guest command {name}: exit {status}")
        return (self.output / f"{name}.out").read_text()

    def snapshot(self, name: str) -> None:
        r = self.ta("agent", "snapshot", "--mode", "full", timeout=30)
        (self.output / f"{name}-ui.json").write_text(r.stdout)
        tree = json.loads(r.stdout)
        # A dialog is an explicit stop, never clicked/approved.
        text = json.dumps(tree).lower()
        if any(token in text for token in ('axdialog', 'axsheet', 'axalert')):
            raise RuntimeError(f"unexpected dialog at {name}; diagnostic stopped")

    def case(self, mode: str, c: dict[str, Any], name: str) -> list[dict[str, Any]]:
        local = self.output / f"{name}-input.json"
        local.write_text(json.dumps(c, sort_keys=True) + "\n")
        remote = f"/tmp/k149-{name}.json"
        self.ta("file", "upload", str(local), remote)
        # Watchdog lives outside the helper. PID is this one invocation only.
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
            raise RuntimeError(f"incomplete helper records at {name}")
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
    subjects = [*SUBJECTS, corpus_path]
    before = hashes(subjects)
    (args.output / "subjects-before.json").write_text(json.dumps(before, indent=2) + "\n")
    host = subprocess.run(["xcrun", "clang", "--version"], capture_output=True, text=True, check=True).stdout
    host += subprocess.run(["xcrun", "--show-sdk-version"], capture_output=True, text=True, check=True).stdout
    (args.output / "host-build-environment.txt").write_text(host)
    summary: dict[str, Any] = {"complete": False, "acquisitionCases": [], "builds": 1, "collections": 1, "repairs": 0}
    run.start = time.monotonic()
    run.note("clone-start-request")
    try:
        vm = subprocess.run(["testanyware", "vm", "start", "--platform", "macos", "--json"],
                            capture_output=True, text=True, timeout=180, check=False)
        (args.output / "vm-start.json").write_text(vm.stdout)
        (args.output / "vm-start.err").write_text(vm.stderr)
        if vm.returncode:
            raise RuntimeError("clone start failed; no retry authorized")
        info = json.loads(vm.stdout)
        # CLI schema exposes the VM ID; keep the whole envelope as evidence.
        run.vm = info.get("vm_id") or info.get("id") or info.get("details", {}).get("vm_id") or ""
        if not run.vm:
            raise RuntimeError(f"no VM ID in start envelope: {vm.stdout[:500]}")
        run.note("vm-started", vm=run.vm)
        run.ta("file", "upload", str(ARCHIVE), "/tmp/k149.zip")
        run.shell("ditto -x -k /tmp/k149.zip /tmp/k149-bundle; mkdir -p /Users/admin/k149", "install")
        run.shell("sw_vers; uname -a; sysctl -n hw.model hw.machine; diskutil info /; "
                  f"codesign --verify --strict /tmp/k149-bundle/K149Probe.app; "
                  f"codesign -dvv --entitlements - /tmp/k149-bundle/K149Probe.app 2>&1; shasum -a 256 {EXE}", "guest-environment")
        run.snapshot("before")
        run.case("volume", {"root": BASE}, "volume")
        for c in corpus:
            rows = run.case("fixture", c, f"fixture-{c['bytes']}")
            if not any(r.get("event") == "fixture" and r.get("ok") and r.get("pathBytes") == c["bytes"] for r in rows):
                raise RuntimeError("fixture creation/control failure")
        missing = run.case("missing", corpus[0], "missing-control")
        mr = next((r for r in missing if r.get("stage") == "missingReference"), {})
        if mr.get("nonNull") is not False or not mr.get("error"):
            raise RuntimeError("missing-name reference control did not expose typed failure")
        for c in corpus:
            for mode in ("direct", "relative"):
                name = f"{mode}-{c['bytes']}"
                rows = run.case(mode, c, name)
                summary["acquisitionCases"].append({"name": name, "bytes": c["bytes"], "pattern": mode,
                    "result": next((r for r in rows if r.get("event") == "caseResult"), None)})
                if any(r.get("event") in ("failure", "incomplete") for r in rows):
                    raise RuntimeError(f"instrumentation/ownership/control failure in {name}")
                if not any(r.get("event") == "shortControl" and r.get("ok") for r in rows):
                    raise RuntimeError(f"short control failed in {name}")
                short_convert = [r for r in rows if r.get("event") == "conversionBytes"]
                if not short_convert or not short_convert[0].get("exact"):
                    raise RuntimeError(f"short conversion control failed in {name}")
                run.snapshot(name)
        summary["complete"] = len(summary["acquisitionCases"]) == 8
        run.ta("screen", "capture", "-o", str(args.output / "screen-end.png"))
    except (RuntimeError, TimeoutError, subprocess.SubprocessError, ValueError, OSError) as e:
        summary["stop"] = str(e)
        run.note("stopped", reason=str(e))
    finally:
        if run.vm:
            stopped = subprocess.run(["testanyware", "vm", "stop", run.vm, "--json"],
                                     capture_output=True, text=True, timeout=50, check=False)
            (args.output / "vm-stop.json").write_text(stopped.stdout)
            (args.output / "vm-stop.err").write_text(stopped.stderr)
            summary["teardownExit"] = stopped.returncode
            run.note("teardown", rc=stopped.returncode)
        summary["elapsedSeconds"] = round(time.monotonic() - run.start, 2)
        summary["withinAggregateCap"] = summary["elapsedSeconds"] <= 900
        after = hashes(subjects)
        (args.output / "subjects-after.json").write_text(json.dumps(after, indent=2) + "\n")
        summary["subjectsUnchanged"] = before == after
        output_files = sorted(p for p in args.output.iterdir() if p.is_file())
        (args.output / "output-digests.json").write_text(json.dumps(hashes(output_files), indent=2) + "\n")
        (args.output / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
        print(json.dumps(summary), flush=True)


if __name__ == "__main__":
    main()
