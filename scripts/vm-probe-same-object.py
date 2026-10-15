#!/usr/bin/env python3
"""One k152 collection, with a preparation checkpoint and guaranteed teardown.

The checkpoint is for the supervising agent's ordinary first-run UI inspection,
not permission to add setup. No native helper is run on the host.
"""
from __future__ import annotations

import argparse
import importlib.util
import json
import shlex
import subprocess
import time
from pathlib import Path

SPEC = importlib.util.spec_from_file_location("k149_driver", "scripts/vm-probe-file-reference-url.py")
assert SPEC and SPEC.loader
OLD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(OLD)
ROOT = Path("docs/verification/same-object-namespace")
EXE = "/tmp/k152-bundle/K152Probe.app/Contents/MacOS/K152Probe"
ARCHIVE = Path(".build/same-object-namespace.zip")
ZED = Path(".build/k152-zed.zip")


def fixtures() -> list[dict[str, object]]:
    result = []
    for size in (900, 1500):
        for kind in ("file", "directory"):
            root = f"/Users/admin/k152/{kind}-{size}"
            name = f"target-{kind}-{size}" + (".txt" if kind == "file" else "")
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
            path = "/".join([root, *parts, name])
            assert len(path.encode()) == size
            assert len(parts) + 1 <= 32 and all(len(p) <= 245 for p in parts)
            result.append({"root": root, "components": parts, "name": name,
                           "kind": kind, "bytes": size, "decoy": f"decoy-{kind}-{size}",
                           "child": f"CHILD_K152_{size}.txt", "marker": f"K152_TARGET_{kind}_{size}\n",
                           "decoyMarker": f"K152_DECOY_{kind}_{size}\n"})
    return result


class Run(OLD.Run):
    def ta(self, *args: str, timeout: float = 45) -> subprocess.CompletedProcess[str]:
        if self.start and time.monotonic() - self.start > 2640:
            raise TimeoutError("45-minute cap: reserve final minute for teardown")
        r = subprocess.run(["testanyware", *args, "--vm", self.vm, "--json"],
                           capture_output=True, text=True, timeout=timeout, check=False)
        if r.returncode:
            raise RuntimeError(f"testanyware {args[:2]}: {r.stderr[-500:]} {r.stdout[-500:]}")
        return r

    def snapshot(self, name: str) -> str:
        r = self.ta("agent", "snapshot", "--mode", "full", timeout=30)
        (self.output / f"{name}-ui.json").write_text(r.stdout)
        self.ta("screen", "capture", "-o", str(self.output / f"{name}.png"))
        text = r.stdout.lower()
        if any(t in text for t in ("would like to access", "would like to control", "privacy & security",
                                   "cannot be opened because", "malicious software")):
            raise RuntimeError(f"unexpected consent/security UI at {name}")
        return text

    def case(self, mode: str, c: dict[str, object], name: str) -> list[dict]:
        local = self.output / f"{name}-input.json"
        local.write_text(json.dumps(c, sort_keys=True) + "\n")
        remote = f"/tmp/k152-{name}.json"
        self.ta("file", "upload", str(local), remote)
        command = (f"{EXE} {shlex.quote(mode)} {shlex.quote(remote)} & probe_pid=$!; "
                   '(sleep 15; kill -TERM "$probe_pid" 2>/dev/null; sleep 3; '
                   'kill -KILL "$probe_pid" 2>/dev/null) & guard_pid=$!; '
                   'wait "$probe_pid"; probe_status=$?; kill "$guard_pid" 2>/dev/null; '
                   'wait "$guard_pid" 2>/dev/null; exit "$probe_status"')
        raw = self.shell(command, name)
        rows = [json.loads(line) for line in raw.splitlines() if line.strip()]
        if not rows or rows[-1].get("event") != "done":
            raise RuntimeError(f"incomplete helper records at {name}")
        if any(r.get("event") in ("failure", "incomplete") for r in rows):
            raise RuntimeError(f"identity/instrument stop at {name}")
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
    subjects = [Path(__file__), Path("scripts/vm-probe-file-reference-url.py"), ROOT / "probe.m",
                ROOT / "plan.md", Path("scripts/build-same-object-probe.sh"), Path("scripts/signing-env.sh"),
                Path("App/Koine.entitlements"), Path("Taskfile.yml"),
                Path("docs/verification/long-action-route.md"), ARCHIVE, ZED, corpus_path]
    before = OLD.hashes(subjects)
    (args.output / "subjects-before.json").write_text(json.dumps(before, indent=2) + "\n")
    env = subprocess.run(["xcrun", "clang", "--version"], capture_output=True, text=True, check=True).stdout
    env += subprocess.run(["xcrun", "--show-sdk-version"], capture_output=True, text=True, check=True).stdout
    (args.output / "host-build-environment.txt").write_text(env)
    summary = {"complete": False, "builds": 1, "collections": 1, "repairs": 0, "subjects": [], "requests": []}
    run.start = time.monotonic()
    run.note("clone-start-request")
    try:
        vm = subprocess.run(["testanyware", "vm", "start", "--platform", "macos", "--id", "koine-k152", "--json"],
                            capture_output=True, text=True, timeout=180, check=False)
        (args.output / "vm-start.json").write_text(vm.stdout)
        (args.output / "vm-start.err").write_text(vm.stderr)
        if vm.returncode:
            raise RuntimeError("clone start failed; no retry authorized")
        info = json.loads(vm.stdout)
        run.vm = info.get("vm_id") or info.get("id") or info.get("details", {}).get("vm_id") or ""
        if not run.vm:
            raise RuntimeError("no VM ID in start envelope")
        run.note("vm-started", vm=run.vm)
        run.ta("file", "upload", str(ARCHIVE), "/tmp/k152.zip")
        run.ta("file", "upload", str(ZED), "/tmp/k152-zed.zip", timeout=120)
        run.shell("ditto -x -k /tmp/k152.zip /tmp/k152-bundle; "
                  "ditto -x -k /tmp/k152-zed.zip /Applications; mkdir -p /Users/admin/k152; "
                  "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Zed.app",
                  "install", wait=90)
        run.shell("sw_vers; uname -a; sysctl -n hw.model hw.machine; diskutil info /; "
                  "codesign --verify --strict /tmp/k152-bundle/K152Probe.app; "
                  "codesign -dvv --entitlements - /tmp/k152-bundle/K152Probe.app 2>&1; "
                  f"shasum -a 256 {EXE}; codesign -dvv /Applications/Zed.app 2>&1", "guest-environment")
        run.shell("open -a /Applications/Zed.app", "zed-first-run")
        run.snapshot("preparation")
        run.note("preparation-checkpoint", vm=run.vm)
        if input("Inspect ordinary Zed/Finder first-run state; enter READY or STOP: ").strip() != "READY":
            raise RuntimeError("ordinary first-run preparation unavailable")
        environment = run.case("environment", {}, "native-environment")
        if not any(r.get("event") == "zed" and r.get("exact") for r in environment):
            raise RuntimeError("exact short registered Zed copy unestablished")
        for c in corpus:
            name = f"{c['kind']}-{c['bytes']}"
            rows = run.case("fixture", c, f"fixture-{name}")
            if not any(r.get("event") == "fixture" and r.get("ok") for r in rows):
                raise RuntimeError("fixture failed")
        for c in corpus:
            name = f"{c['kind']}-{c['bytes']}"
            rows = run.case("inspect", c, f"inspect-{name}")
            if not any(r.get("event") == "nativeIDControl" and r.get("ok") for r in rows):
                raise RuntimeError("native-ID/900-byte control failed")
            summary["subjects"].append({"name": name, "control": "passed"})
        for c in corpus:
            for mode in ("default", "named", "reveal"):
                name = f"{c['kind']}-{c['bytes']}-{mode}"
                run.case("reset", {}, f"reset-{name}")
                run.shell("open -a Finder", f"finder-baseline-{name}")
                run.ta("input", "key", "w", "--modifiers", "cmd,alt")
                time.sleep(1)
                baseline = run.snapshot(f"before-{name}")
                absent = all(str(c[k]).lower() not in baseline for k in ("name", "decoy", "marker", "child"))
                rows = run.case(mode, c, f"request-{name}")
                time.sleep(2)
                run.snapshot(f"after-{name}")
                summary["requests"].append({"name": name, "baselineFixtureNamesAbsent": absent,
                                            "native": [r for r in rows if r.get("event") in ("request", "callback")],
                                            "receiver": "requires independent UI grading; delivery opaque"})
        for c in corpus:
            name = f"{c['kind']}-{c['bytes']}"
            run.case("inspect", c, f"final-{name}")
        summary["complete"] = len(summary["requests"]) == 12
    except (RuntimeError, TimeoutError, subprocess.SubprocessError, ValueError, OSError, EOFError) as e:
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
        summary["withinAggregateCap"] = summary["elapsedSeconds"] <= 2700
        after = OLD.hashes(subjects)
        (args.output / "subjects-after.json").write_text(json.dumps(after, indent=2) + "\n")
        summary["subjectsUnchanged"] = before == after
        (args.output / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
        outputs = sorted(p for p in args.output.iterdir() if p.is_file())
        (args.output / "output-digests.json").write_text(json.dumps(OLD.hashes(outputs), indent=2) + "\n")
        print(json.dumps(summary), flush=True)


if __name__ == "__main__":
    main()
