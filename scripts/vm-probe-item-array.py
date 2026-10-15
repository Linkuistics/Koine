#!/usr/bin/env python3
"""Disposable (k146) driver: one disposable guest, short controls, three component-created long text files,
then six opener calls (LSOpenItemsWithRole / LSOpenFromRefSpec at 900, 1023, 1024 bytes) with an independent reader.

Limits enforced here: external 30 s watchdog per helper case (+5 s termination grace) and a 15-minute cap from
the clone-start request through teardown. Exit 0 means the run finished, never that delivery passed.
Example: scripts/vm-probe-item-array.py --output docs/verification/item-array-submission/results/run1
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import subprocess
import tempfile
import time
import urllib.parse
import uuid
from pathlib import Path

HELPER = "/Applications/K146Probe.app"
HEXE = "K146Probe"
REC = "/Applications/K146Rec.app"
REXE = "K146Rec"
RECLOG = "/tmp/k146-rec.jsonl"
BASE = "/Users/admin/k146"
SIZES = [900, 1023, 1024]
APIS = ["LSOpenItemsWithRole", "LSOpenFromRefSpec"]
D = "docs/verification/item-array-submission"
SUBJECTS = [Path(__file__), Path(f"{D}/probe.m"), Path(f"{D}/recorder.m"), Path("scripts/build-item-array-probe.sh"),
            Path("App/Info.plist"), Path("App/Koine.entitlements"), Path(".build/item-array-submission.zip")]
CAP_SECONDS = 15 * 60
LATE_WAIT = 8.0  # seconds to keep listening after the opener returns and the helper exits


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
        prefix = f"/tmp/k146-r-{uuid.uuid4().hex}"
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
        out = f"/tmp/k146-{name}-{uuid.uuid4().hex[:6]}.jsonl"
        with tempfile.TemporaryDirectory() as d:
            Path(f"{d}/c.json").write_text(json.dumps([case]))
            self.ta("file", "upload", f"{d}/c.json", f"/tmp/k146-{name}.json")
        self.sh(f"pkill -x {HEXE} || true; sleep 0.3")
        self.ta("file", "exec", "--detach", f"open -n {HELPER} --args run /tmp/k146-{name}.json {out}")
        start, rows, state = time.monotonic(), [], "done"
        while time.monotonic() - start < 30.0:
            time.sleep(0.7)
            rows = self.rows(out)
            if any(r.get("id") == "__done__" for r in rows):
                break
        else:
            state = "watchdog-term"
            self.sh(f"pkill -TERM -x {HEXE} || true")
            time.sleep(5)
            try:
                self.sh(f"pkill -KILL -x {HEXE} || true")
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


def spelling(m: dict, name: str) -> bytes:
    """The component-created fixture's original byte spelling (root + created components + object name)."""
    parts = [base64.b64decode(m["rootB64"])] + [base64.b64decode(c) for c in m["componentsB64"]] + [m[name].encode()]
    return b"/".join(parts)


def decode_url(raw: bytes) -> bytes | None:
    if not raw.startswith(b"file://"):
        return None
    rest = raw[len(b"file://"):]
    if rest.startswith(b"localhost/"):
        rest = rest[len(b"localhost"):]
    return urllib.parse.unquote_to_bytes(rest.decode("ascii", "replace"))


def read_delivery(events: list[dict], fixture: dict) -> dict:
    """Independent reader: compare each observed odoc item with the fixture spelling and its decoy."""
    want, decoy = spelling(fixture, "obj"), spelling(fixture, "decoy")
    seen = []
    for e in events:
        if e.get("event") != "aevt/odoc":
            continue
        for it in e.get("items", []):
            raw = base64.b64decode(it["fileURLB64"]) if it.get("fileURLB64") else None
            got = decode_url(raw) if raw is not None else None
            via = "coerced-file-url"
            if got is None and it.get("bookmarkPathB64"):  # k146 repair 1: path stored in the delivered bookmark itself
                got, via = base64.b64decode(it["bookmarkPathB64"]), "bookmark-stored-path"
            seen.append({"seq": e["seq"], "via": via, "itemType": it.get("type"), "rawBytes": it.get("rawBytes"), "urlBytes": len(raw) if raw is not None else None,
                         "decodedBytes": len(got) if got is not None else None, "exact": got == want, "isDecoy": got == decoy,
                         "resolveError": it.get("resolveError")})
    exact = [s for s in seen if s["exact"]]
    return {"expectedBytes": len(want), "observedItems": seen, "odocEvents": sum(1 for e in events if e.get("event") == "aevt/odoc"),
            "verdict": "exact-delivery" if len(exact) == 1 and len(seen) == 1 else ("delivery-not-exact" if seen else "no-delivery-observed")}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", required=True, type=Path)
    args = ap.parse_args()
    run = Run(args.output)
    before = digest()
    (args.output / "subjects-before.json").write_text(json.dumps(before, indent=1) + "\n")
    summary: dict = {"complete": False, "calls": []}
    run.note(event="clone-start-request")
    vm = subprocess.run(["testanyware", "vm", "start", "--platform", "macos"], capture_output=True, text=True, check=False)
    run.vm = vm.stdout.strip().splitlines()[-1] if vm.stdout.strip() else ""
    run.note(event="vm-started", vm=run.vm, rc=vm.returncode, stderr=vm.stderr[-300:])
    try:
        if not run.vm or vm.returncode != 0:
            raise RuntimeError("guest did not start")
        env = run.sh("sw_vers; uname -a; sysctl -n hw.model hw.machine; diskutil info / | egrep 'File System|Volume Name' ; mount | head -3")
        run.ta("file", "upload", ".build/item-array-submission.zip", "/tmp/ias.zip")
        run.sh(f"rm -rf /tmp/ias {HELPER} {REC}; ditto -x -k /tmp/ias.zip /tmp/ias && ditto /tmp/ias/K146Probe.app {HELPER} && ditto /tmp/ias/K146Rec.app {REC}; rm -rf {BASE}; mkdir -p {BASE}")
        for app, exe in ((HELPER, HEXE), (REC, REXE)):
            env += run.sh(f"codesign -dvv --entitlements - {app} 2>&1 | egrep -v '^Executable' ; shasum -a 256 {app}/Contents/MacOS/{exe}")
        env += run.sh("spctl --status; uname -m")
        (args.output / "guest-environment.txt").write_text(env)
        run.note(event="prepared")
        run.sh(f"cd {BASE} && mkdir -p short && cd short && printf 's\\n' > obj.txt && printf 'd\\n' > dec.txt")
        ctrl = {
            "short-file": run.case("ctl-short-file", {"id": "c", "mode": "walk", "root": f"{BASE}/short", "kind": "file", "obj": "obj.txt", "decoy": "dec.txt", "componentsB64": [], "pathControl": f"{BASE}/short/obj.txt"}),
            "short-missing": run.case("ctl-short-missing", {"id": "c", "mode": "walk", "root": f"{BASE}/short", "kind": "file", "obj": "missing-name.txt", "decoy": "dec.txt", "componentsB64": []}),
        }
        ok = control_ok(ctrl["short-file"]["result"]) and control_ok(ctrl["short-missing"]["result"], missing=True)
        summary["controlsOk"] = ok
        run.note(event="controls", ok=ok)
        run.case("volume", {"id": "v", "mode": "volume", "path": BASE})
        if not ok:
            summary["stop"] = "short-control failure; long subjects not run"
        else:
            fixtures: dict[int, dict] = {}
            for n in SIZES:
                mk = run.case(f"mk-file-{n}", {"id": "mk", "mode": "mkfixture", "root": f"{BASE}/f{n}-file", "kind": "file", "target": n})
                m = mk["result"] or {}
                if "error" in m or "componentsB64" not in m or m.get("objectPathLength") != n:
                    run.note(event="fixture-failed", size=n); summary["stop"] = f"fixture {n} failed"; break
                fixtures[n] = m
            for n in SIZES if "stop" not in summary else []:
                for api in APIS:
                    if run.over_cap():
                        summary["stop"] = "15-minute cap exhausted"; break
                    m = fixtures[n]
                    name = f"submit-{api}-{n}"
                    run.sh(f"pkill -x {REXE} || true; rm -f {RECLOG}; sleep 0.5")
                    r = run.case(name, {"id": "s", "mode": "submit", "api": api, "appPath": REC, "root": f"{BASE}/f{n}-file", "kind": "file", "obj": m["obj"], "decoy": m["decoy"],
                                        "componentsB64": m["componentsB64"], "objectPathLength": m["objectPathLength"]})
                    time.sleep(LATE_WAIT)
                    events = run.rows(RECLOG)
                    (args.output / f"{name}-recorder.jsonl").write_text("".join(json.dumps(e) + "\n" for e in events))
                    run.sh(f"pkill -TERM -x {REXE} || true")
                    res = r["result"] or {}
                    call = res.get("call", {})
                    summary["calls"].append({"name": name, "size": n, "api": api, "state": r["state"], "status": call.get("status"), "seconds": call.get("seconds"),
                                             "firstFailedStage": res.get("firstFailedStage"), "reader": read_delivery(events, m),
                                             "recorderEvents": [e.get("event") for e in events]})
            summary["complete"] = "stop" not in summary and len(summary["calls"]) == 6
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
