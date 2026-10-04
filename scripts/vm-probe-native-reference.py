#!/usr/bin/env python3
"""Disposable (k143) driver: one disposable guest, one signed helper, short controls then eight long fixtures.

Limits enforced here: external 30 s watchdog per helper case (+5 s termination grace) and a 15-minute cap from
the clone-start request through teardown. Exit 0 means the run finished, never that a route passed.
Example: scripts/vm-probe-native-reference.py --output docs/verification/native-reference-acquisition/results/run1
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import subprocess
import tempfile
import time
import uuid
from pathlib import Path

APP = "/Applications/KoineK143Probe.app"
EXE = "KoineK143Probe"
BASE = "/Users/admin/k143"
TARGETS = [900, 1023, 1024, 1500]
SUBJECTS = [Path(__file__), Path("docs/verification/native-reference-acquisition/probe.m"),
            Path("scripts/build-native-reference-probe.sh"), Path("App/Info.plist"), Path("App/Koine.entitlements"),
            Path(".build/native-reference-acquisition.zip")]
CAP_SECONDS = 15 * 60


class Run:
    def __init__(self, output: Path) -> None:
        self.output, self.t0, self.vm = output, time.monotonic(), ""
        output.mkdir(parents=True, exist_ok=True)
        self.log = output / "driver-log.jsonl"

    def note(self, **kw) -> None:
        kw["at"] = time.time(); kw["elapsed"] = round(time.monotonic() - self.t0, 1)
        with self.log.open("a") as f:
            f.write(json.dumps(kw) + "\n")
        print(kw, flush=True)

    def over_cap(self) -> bool:
        return time.monotonic() - self.t0 > CAP_SECONDS

    def ta(self, *args: str, timeout: int = 60) -> subprocess.CompletedProcess[str]:
        return subprocess.run(["testanyware", *args, "--vm", self.vm], capture_output=True, text=True, timeout=timeout, check=False)

    def sh(self, command: str, wait: float = 30.0) -> str:
        prefix = f"/tmp/k143-r-{uuid.uuid4().hex}"
        self.ta("file", "exec", "--detach", f"({command}) >{prefix}.out 2>{prefix}.err; echo $? >{prefix}.tmp; mv {prefix}.tmp {prefix}.code")
        with tempfile.TemporaryDirectory() as d:
            deadline = time.monotonic() + wait
            while time.monotonic() < deadline:
                if self.ta("file", "download", f"{prefix}.code", f"{d}/code").returncode == 0:
                    break
                time.sleep(0.3)
            else:
                raise RuntimeError(f"guest command did not finish: {command[:100]}")
            self.ta("file", "download", f"{prefix}.out", f"{d}/out")
            code = Path(f"{d}/code").read_text().strip()
            out = Path(f"{d}/out").read_text() if Path(f"{d}/out").exists() else ""
        if code != "0":
            raise RuntimeError(f"guest exit {code}: {command[:100]}")
        return out

    def rows(self, remote: str) -> list[dict]:
        with tempfile.TemporaryDirectory() as d:
            if self.ta("file", "download", remote, f"{d}/f").returncode != 0:
                return []
            return [json.loads(x) for x in Path(f"{d}/f").read_text().splitlines() if x.strip()]

    def case(self, name: str, case: dict) -> dict:
        """One helper process per case under the 30 s watchdog; raw records are saved verbatim."""
        out = f"/tmp/k143-{name}-{uuid.uuid4().hex[:6]}.jsonl"
        with tempfile.TemporaryDirectory() as d:
            Path(f"{d}/c.json").write_text(json.dumps([case]))
            self.ta("file", "upload", f"{d}/c.json", f"/tmp/k143-{name}.json")
        self.sh(f"pkill -x {EXE} || true; sleep 0.3")
        self.ta("file", "exec", "--detach", f"open -n {APP} --args run /tmp/k143-{name}.json {out}")
        start, rows, state = time.monotonic(), [], "done"
        while time.monotonic() - start < 30.0:
            time.sleep(0.7)
            rows = self.rows(out)
            if any(r.get("id") == "__done__" for r in rows):
                break
        else:
            state = "watchdog-term"
            self.sh(f"pkill -TERM -x {EXE} || true")
            time.sleep(5)
            try:
                self.sh(f"pkill -KILL -x {EXE} || true")
            except RuntimeError:
                pass
            rows = self.rows(out)
        (self.output / f"{name}.jsonl").write_text("".join(json.dumps(r) + "\n" for r in rows))
        self.note(case=name, state=state, rows=len(rows), seconds=round(time.monotonic() - start, 1))
        res = [r["result"] for r in rows if r.get("id") not in ("", "__done__") and "result" in r]
        return {"state": state, "result": res[0] if res else None}


def b64(s: str) -> str:
    return base64.b64encode(s.encode()).decode()


def digest() -> dict:
    return {str(x): hashlib.sha256(x.read_bytes()).hexdigest() for x in SUBJECTS}


def control_ok(w: dict | None, missing: bool = False) -> bool:
    if not w:
        return False
    if missing:
        return w.get("objectOutcome") == "completed-no-match"
    sc = w.get("shortSameObjectControl", {})
    cons = w.get("consumers", {})
    return bool(w.get("objectAcquired") and sc.get("FSCompareFSRefs_wholePathVsEnumerated") == 0
                and cons.get("FSCompareFSRefs_sameParentDecoy") not in (0, None) and cons.get("FSGetCatalogInfo", {}).get("status") == 0)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", required=True, type=Path)
    args = ap.parse_args()
    run = Run(args.output)
    before = digest()
    (args.output / "subjects-before.json").write_text(json.dumps(before, indent=1) + "\n")
    summary: dict = {"complete": False}
    run.note(event="clone-start-request")
    vm = subprocess.run(["testanyware", "vm", "start", "--platform", "macos"], capture_output=True, text=True, check=False)
    run.vm = vm.stdout.strip().splitlines()[-1] if vm.stdout.strip() else ""
    run.note(event="vm-started", vm=run.vm, rc=vm.returncode, stderr=vm.stderr[-300:])
    try:
        if not run.vm or vm.returncode != 0:
            raise RuntimeError("guest did not start")
        env = run.sh("sw_vers; uname -a; sysctl -n hw.model hw.machine; diskutil info / | egrep 'File System|Volume Name' ; mount | head -3")
        run.ta("file", "upload", ".build/native-reference-acquisition.zip", "/tmp/nra.zip")
        run.sh(f"rm -rf /tmp/nra {APP}; ditto -x -k /tmp/nra.zip /tmp/nra && ditto /tmp/nra/KoineK143Probe.app {APP}; rm -rf {BASE}; mkdir -p {BASE}")
        env += run.sh(f"codesign -dvv --entitlements - {APP} 2>&1 | egrep -v '^Executable' ; shasum -a 256 {APP}/Contents/MacOS/{EXE}; spctl --status; uname -m")
        (args.output / "guest-environment.txt").write_text(env)
        run.note(event="prepared")
                # short controls: ordinary shell-made short subjects (no long path involved)
        run.sh(f"cd {BASE} && mkdir -p short && cd short && printf 's\\n' > obj.txt && printf 'd\\n' > dec.txt && mkdir -p obj dec && printf 'i\\n' > obj/inner.txt && printf 'i\\n' > dec/inner.txt")
        ctrl = {}
        ctrl["short-file"] = run.case("ctl-short-file", {"id": "c", "mode": "walk", "root": f"{BASE}/short", "kind": "file", "obj": "obj.txt", "decoy": "dec.txt", "componentsB64": [], "pathControl": f"{BASE}/short/obj.txt"})
        ctrl["short-dir"] = run.case("ctl-short-dir", {"id": "c", "mode": "walk", "root": f"{BASE}/short", "kind": "dir", "obj": "obj", "decoy": "dec", "componentsB64": [], "pathControl": f"{BASE}/short/obj"})
        ctrl["short-missing"] = run.case("ctl-short-missing", {"id": "c", "mode": "walk", "root": f"{BASE}/short", "kind": "file", "obj": "missing-name.txt", "decoy": "dec.txt", "componentsB64": []})
        ok = control_ok(ctrl["short-file"]["result"]) and control_ok(ctrl["short-dir"]["result"]) and control_ok(ctrl["short-missing"]["result"], missing=True)
        summary["controlsOk"] = ok
        run.note(event="controls", ok=ok)
        run.case("volume", {"id": "v", "mode": "volume", "path": BASE})
        if not ok:
            summary["stop"] = "uncorrected short-control failure; long subjects not run"
        else:
            for n in TARGETS:
                for kind in ("file", "dir"):
                    if run.over_cap():
                        summary["stop"] = "15-minute cap exhausted"; break
                    name = f"{kind}-{n}"
                    mk = run.case(f"mk-{name}", {"id": "mk", "mode": "mkfixture", "root": f"{BASE}/f{n}-{kind}", "kind": kind, "target": n})
                    m = mk["result"] or {}
                    if "error" in m or "componentsB64" not in m:
                        run.note(event="fixture-failed", name=name); continue
                    w = run.case(f"walk-{name}", {"id": "w", "mode": "walk", "root": f"{BASE}/f{n}-{kind}", "kind": kind, "obj": m["obj"], "decoy": m["decoy"],
                                                  "componentsB64": m["componentsB64"], "objectPathLength": m["objectPathLength"]})
                    summary[name] = {"state": w["state"], "objectPathLength": m["objectPathLength"], "acquired": (w["result"] or {}).get("objectAcquired"),
                                     "firstFailedStage": (w["result"] or {}).get("firstFailedStage")}
            summary["complete"] = "stop" not in summary
        run.ta("screen", "capture", "-o", str(args.output / "screen-end.png"))
    except Exception as e:  # noqa: BLE001 - recorded, never retried
        summary["error"] = repr(e)
        run.note(event="error", error=repr(e))
    finally:
        r = subprocess.run(["testanyware", "vm", "stop", run.vm], capture_output=True, text=True, check=False) if run.vm else None
        run.note(event="teardown", rc=r.returncode if r else None)
        summary["elapsedSeconds"] = round(time.monotonic() - run.t0, 1)
        (args.output / "summary.json").write_text(json.dumps(summary, indent=1) + "\n")
    after = digest()
    (args.output / "subjects-after.json").write_text(json.dumps(after, indent=1) + "\n")
    if after != before:
        raise SystemExit("measurement subjects changed during the run; reject results")


if __name__ == "__main__":
    main()
