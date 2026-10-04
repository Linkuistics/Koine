#!/usr/bin/env python3
"""Disposable (k134) driver for the long-action prototype in an already prepared TestAnyware VM.

Records observations; exit 0 means a phase finished, never that a route passed.
Example: scripts/vm-probe-long-action.py --vm koine-k134 --output .build/k134-run fixtures acquire
"""

from __future__ import annotations

import argparse
import base64
import json
import subprocess
import tempfile
import time
import uuid
from pathlib import Path

PROBE = "/Applications/KoineK134Probe.app"
HOME = "/Users/admin"
ROOT = f"{HOME}/k134/lp"  # unprotected long-fixture root
DOCROOT = f"{HOME}/Documents/k134/lp"  # protected-folder long fixtures (first-use rows)
b64 = lambda s: base64.b64encode(s if isinstance(s, bytes) else s.encode()).decode()  # noqa: E731
unb64 = lambda s: base64.b64decode(s)  # noqa: E731


class VM:
    def __init__(self, vm: str, output: Path) -> None:
        self.vm, self.output = vm, output
        output.mkdir(parents=True, exist_ok=True)

    def ta(self, *args: str, timeout: int = 60) -> subprocess.CompletedProcess[str]:
        return subprocess.run(["testanyware", *args, "--vm", self.vm], capture_output=True, text=True, timeout=timeout, check=False)

    def sh(self, command: str, wait: float = 40.0) -> str:
        """Detached exec plus an atomic exit marker; the launcher's return is never the evidence."""
        prefix = f"/tmp/k134-r-{uuid.uuid4().hex}"
        script = f"({command}) >{prefix}.out 2>{prefix}.err; echo $? >{prefix}.tmp; mv {prefix}.tmp {prefix}.code"
        self.ta("file", "exec", "--detach", script)
        with tempfile.TemporaryDirectory() as d:
            deadline = time.monotonic() + wait
            while time.monotonic() < deadline:
                r = self.ta("file", "download", f"{prefix}.code", f"{d}/code")
                if r.returncode == 0:
                    break
                time.sleep(0.2)
            else:
                raise RuntimeError(f"guest command did not finish: {command[:100]}")
            self.ta("file", "download", f"{prefix}.out", f"{d}/out")
            self.ta("file", "download", f"{prefix}.err", f"{d}/err")
            code = Path(f"{d}/code").read_text().strip()
            out = Path(f"{d}/out").read_text() if Path(f"{d}/out").exists() else ""
            err = Path(f"{d}/err").read_text() if Path(f"{d}/err").exists() else ""
        if code != "0":
            raise RuntimeError(f"guest exit {code}: {command[:100]}\n{err}")
        return out

    def read_lines(self, remote: str) -> list[dict]:
        with tempfile.TemporaryDirectory() as d:
            r = self.ta("file", "download", remote, f"{d}/f")
            if r.returncode != 0:
                return []
            return [json.loads(x) for x in Path(f"{d}/f").read_text().splitlines() if x.strip()]

    def run_cases(self, name: str, cases: list[dict], timeout: float = 90.0, app: str = PROBE, kill: bool = True) -> list[dict]:
        out = f"/tmp/k134-{name}-{uuid.uuid4().hex[:6]}.jsonl"
        with tempfile.TemporaryDirectory() as d:
            Path(f"{d}/c.json").write_text(json.dumps(cases))
            self.ta("file", "upload", f"{d}/c.json", f"/tmp/k134-{name}.json")
        if kill:
            self.sh("pkill -x Koine || true; sleep 0.3")
        self.ta("file", "exec", "--detach", f"open -n {app} --args run /tmp/k134-{name}.json {out}")
        deadline = time.monotonic() + timeout
        rows: list[dict] = []
        while time.monotonic() < deadline:
            time.sleep(1.0)
            rows = self.read_lines(out)
            if any(r.get("id") == "__done__" for r in rows):
                break
        rows = [r for r in rows if r.get("id") != "__done__"]
        (self.output / f"{name}.jsonl").write_text("".join(json.dumps(r) + "\n" for r in rows))
        return rows


def rowmap(rows: list[dict]) -> dict[str, dict]:
    return {r["id"]: r["result"] for r in rows if "result" in r}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--vm", required=True)
    ap.add_argument("--output", required=True, type=Path)
    ap.add_argument("phases", nargs="+")
    args = ap.parse_args()
    vm = VM(args.vm, args.output)
    state = args.output / "state.json"
    st = json.loads(state.read_text()) if state.exists() else {}
    import hashlib

    subjects = [Path(__file__), Path("docs/verification/long-action-route/probe.m"), Path("scripts/build-long-action-probe.sh"),
                Path("App/Info.plist"), Path("App/Koine.entitlements"), Path(".build/long-action-route.zip")]
    digest = lambda: {str(x): hashlib.sha256(x.read_bytes()).hexdigest() for x in subjects}  # noqa: E731
    before = digest()
    (args.output / "subjects-before.json").write_text(json.dumps(before, indent=1) + "\n")
    for phase in args.phases:
        try:
            globals()[f"phase_{phase.replace('-', '_')}"](vm, st)
        finally:
            state.write_text(json.dumps(st, indent=1))
    (args.output / "subjects-after.json").write_text(json.dumps(digest(), indent=1) + "\n")
    if digest() != before:
        raise SystemExit("measurement subjects changed during the run; reject results")


def phase_install(vm: VM, st: dict) -> None:
    vm.ta("file", "upload", ".build/long-action-route.zip", "/tmp/lar.zip")
    vm.sh("rm -rf /tmp/lar && ditto -x -k /tmp/lar.zip /tmp/lar; pkill -x Koine; "
          "for a in Probe Witness Fixture; do rm -rf /Applications/KoineK134$a.app; ditto /tmp/lar/KoineK134$a.app /Applications/KoineK134$a.app; done; "
          "mkdir -p ~/Documents ~/k134; true")


SETS = [900, 1000, 1023, 1024, 1025, 1100, 1500]


def phase_fixtures(vm: VM, st: dict) -> None:
    vm.sh(f"chmod -R u+rwx {HOME}/k134 {DOCROOT} 2>/dev/null; rm -rf {HOME}/k134 {HOME}/Documents/k134 /Applications/KoineK134Fixture.app; "
          f"ditto /tmp/lar/KoineK134Fixture.app /Applications/KoineK134Fixture.app; mkdir -p {HOME}/k134/stage {HOME}/k134/short; "
          "printf 'short text\\n' > ~/k134/short/sample.txt; printf 'short witness\\n' > ~/k134/short/sample.k134w; mkdir -p ~/k134/short/Folder")
    st["sets"] = {}
    for n in SETS:
        vm.sh(f"for a in Fixture Witness; do rm -rf {HOME}/k134/stage/KoineK134$a.app; ditto /tmp/lar/KoineK134$a.app {HOME}/k134/stage/KoineK134$a.app; done")
        root = ROOT if n == 1500 else f"{HOME}/k134/t{n}"
        rows = vm.run_cases(f"fixtures-{n}", [
            {"id": "f", "mode": "fixtures", "rootb64": b64(root), "stage": f"{HOME}/k134/stage", "move": ["KoineK134Fixture.app", "KoineK134Witness.app"], "target": n}])
        res = rowmap(rows)["f"]
        st["sets"][str(n)] = res
        print(n, "sample.txt path length", res.get("longDirLength", 0) + 11, {k: v for k, v in res.items() if k.startswith("move") or k == "error"})
    st["plain"] = st["sets"]["1500"]
    phase_docfx(vm, st)


def phase_recover(vm: VM, st: dict) -> None:
    """Rebuild the fixture manifest from this output directory's per-set records."""
    st["sets"] = {}
    for n in SETS:
        for line in (vm.output / f"fixtures-{n}.jsonl").read_text().splitlines():
            st["sets"][str(n)] = json.loads(line)["result"]
    st["plain"] = st["sets"]["1500"]


def phase_docfx(vm: VM, st: dict) -> None:
    # protected-folder long fixture for the first-use rows
    vm.sh(f"mkdir -p {HOME}/Documents; rm -rf {HOME}/k134/stage/*; ditto /tmp/lar/KoineK134Fixture.app {HOME}/k134/stage/KoineK134Fixture.app")
    # Created by the preparing agent's own identity with plain directory-fd calls (it holds Full Disk Access, as
    # protected-path-metadata.md records); the measured launches run as the probe's own responsible identity.
    script = (
        "import os\nfd=os.open('/',os.O_RDONLY)\nfor p in %r.split('/')[1:]:\n    try: os.mkdir(p,0o755,dir_fd=fd)\n    except FileExistsError: pass\n    fd=os.open(p,os.O_RDONLY,dir_fd=fd)\n"
        "tot=len(%r)\npath=%r\nk=1\nwhile tot<%d-11:\n    room=%d-11-tot-1\n    sz=min(245,room)\n    n=('L%%d_'%%(k%%10)+'x'*sz)[:sz]\n    os.mkdir(n,0o755,dir_fd=fd); fd=os.open(n,os.O_RDONLY,dir_fd=fd); tot+=1+sz; path+='/'+n; k+=1\n"
        "g=os.open('sample.txt',os.O_WRONLY|os.O_CREAT,0o644,dir_fd=fd); os.write(g,b'protected long text\\n')\nprint(path)\n"
    ) % (DOCROOT, DOCROOT, DOCROOT, 1500, 1500)
    with tempfile.TemporaryDirectory() as d:
        Path(f"{d}/mk.py").write_text(script)
        vm.ta("file", "upload", f"{d}/mk.py", "/tmp/k134-mkdocs.py")
    path = vm.sh("python3 /tmp/k134-mkdocs.py").strip()
    st["docs"] = {"longDirLength": len(path), "longDirB64": b64(path)}
    vm.sh(f"mkdir -p {HOME}/Documents/k134/short; printf 'protected short text\\n' > {HOME}/Documents/k134/short/sample.txt")
    print("docs", {k: v for k, v in st["docs"].items() if k != "longDirB64"})


def phase_acquire(vm: VM, st: dict) -> None:
    longdir = unb64(st["plain"]["longDirB64"]).decode()
    cases = []
    names = ["sample.txt", "sample.k134w", "script.sh", "Pack.rtfd", "Folder", "link-to-sample", "link-dangling", "dotlink/dotlink/sample.txt", "dotlink/dotlink/dotlink/Folder",
             "cycle-a", "chain0", "link-below-file", "sample.txt/", "sample.txt/.", "sample.txt/..", "missing.txt", "KoineK134Fixture.app", "KoineK134Witness.app",
             "BadPlist.app", "NoPlist.app", "NoId.app", "Denied.app", "z" * 300]
    for n in names:
        cases.append({"id": f"long:{n[:40]}", "mode": "acquire", "pathb64": b64(f"{longdir}/{n}"), "followFinal": True})
    cases.append({"id": "long:link-to-sample(nofollow)", "mode": "acquire", "pathb64": b64(f"{longdir}/link-to-sample"), "followFinal": False})
    cases.append({"id": "long:link-dangling(nofollow)", "mode": "acquire", "pathb64": b64(f"{longdir}/link-dangling"), "followFinal": False})
    for n in ["sample.txt", "KoineK134Fixture.app", "Pack.rtfd", "link-to-sample", "script.sh", "BadPlist.app"]:
        cases.append({"id": f"alt:{n}", "mode": "alt", "dirb64": b64(longdir), "name": n})
    # short controls and every installed application: native layout parity
    cases.append({"id": "short:Fixture", "mode": "acquire", "pathb64": b64("/Applications/KoineK134Fixture.app"), "followFinal": True})
    cases.append({"id": "short:TextEdit", "mode": "acquire", "pathb64": b64("/System/Applications/TextEdit.app"), "followFinal": True})
    cases.append({"id": "short:missing", "mode": "acquire", "pathb64": b64("/Applications/Nope.app"), "followFinal": True})
    apps = vm.sh("ls -d /Applications/*.app /System/Applications/*.app /System/Applications/Utilities/*.app /Applications/Utilities/*.app 2>/dev/null; true").split("\n")
    for a in [x for x in apps if x]:
        cases.append({"id": f"app:{a}", "mode": "acquire", "pathb64": b64(a), "followFinal": True})
    rows = vm.run_cases("acquire", cases, timeout=240)
    st["acquire_ids"] = [r["id"] for r in rows]
    print(len(rows), "rows of", len(cases))


def witness_logs(vm: VM) -> dict:
    return {"witness": vm.read_lines("/tmp/koine-k134-witness.jsonl"), "self": vm.read_lines("/tmp/koine-k134-self.jsonl")}


def windows(vm: VM) -> str:
    return vm.ta("agent", "windows").stdout


def observe_pid(vm: VM, pid: int) -> dict:
    out = vm.sh(f"/usr/sbin/lsof -p {pid} -a -d txt -Fn 2>&1 | head -4; ps -p {pid} -o pid=,comm= 2>&1; true")
    return {"pid": pid, "lsof_ps": out}


def clear_logs(vm: VM) -> None:
    vm.sh("rm -f /tmp/koine-k134-witness.jsonl /tmp/koine-k134-self.jsonl")


def phase_register(vm: VM, st: dict) -> None:
    longdir = unb64(st["plain"]["longDirB64"]).decode()
    fx = f"{longdir}/KoineK134Fixture.app"
    wx = f"{longdir}/KoineK134Witness.app"
    cases = [
        {"id": "reg-pre-fixture", "mode": "registration", "identifier": "dev.antony.Koine.K134Fixture", "expectedb64": b64(fx)},
        {"id": "reg-pre-witness", "mode": "registration", "identifier": "dev.antony.Koine.K134Witness", "expectedb64": b64(wx)},
        {"id": "register-long-fixture", "mode": "register", "pathb64": b64(fx)},
        {"id": "register-long-witness", "mode": "register", "pathb64": b64(wx)},
        {"id": "reg-post-fixture", "mode": "registration", "identifier": "dev.antony.Koine.K134Fixture", "expectedb64": b64(fx), "pauseAfterMs": 2000},
        {"id": "reg-post-witness", "mode": "registration", "identifier": "dev.antony.Koine.K134Witness", "expectedb64": b64(wx)},
        {"id": "short-fixture-bundle", "mode": "registration", "identifier": "dev.antony.Koine.K134Fixture", "expectedb64": b64("/Applications/KoineK134Fixture.app")},
    ]
    rows = vm.run_cases("register", cases, timeout=60)
    for r in rows:
        print(r["id"], json.dumps(r["result"])[:400])


def submit(vm: VM, st: dict, name: str, case: dict, wait_ms: int = 4000) -> dict:
    clear_logs(vm)
    case = {**case, "id": name}
    rows = vm.run_cases(f"submit-{name.replace(':', '_')}", [case], timeout=60, kill=False)
    time.sleep(wait_ms / 1000)
    rec = {"case": name, "rows": rows, "logs": witness_logs(vm), "windows": windows(vm)}
    cb = (rows[0]["result"].get("callback") or {}) if rows else {}
    app = cb.get("app") if isinstance(cb, dict) else None
    if isinstance(app, dict) and app.get("pid"):
        rec["observer"] = observe_pid(vm, app["pid"])
    (vm.output / f"submit-{name.replace(':', '_')}.json").write_text(json.dumps(rec, indent=1))
    return rec


def phase_submit_docs(vm: VM, st: dict) -> None:
    longdir = unb64(st["plain"]["longDirB64"]).decode()
    wit = "/Applications/KoineK134Witness.app"
    sd = f"{HOME}/k134/short"
    plan = {
        "doc-short-witness-control": {"mode": "open", "pathb64": b64(f"{sd}/sample.k134w"), "apppathb64": b64(wit), "substitute": 1},
        "doc-long-witness-shortapp": {"mode": "open", "pathb64": b64(f"{longdir}/sample.k134w"), "apppathb64": b64(wit), "substitute": 1},
        "doc-long-witness-longapp": {"mode": "open", "pathb64": b64(f"{longdir}/sample.k134w"), "apppathb64": b64(f"{longdir}/KoineK134Witness.app"), "substitute": 1},
        "doc-short-default-control": {"mode": "open", "pathb64": b64(f"{sd}/sample.txt"), "substitute": 1},
        "doc-long-default": {"mode": "open", "pathb64": b64(f"{longdir}/sample.txt"), "substitute": 1},
        "doc-long-zed": {"mode": "open", "pathb64": b64(f"{longdir}/sample.txt"), "apppathb64": b64("/Applications/Zed.app"), "substitute": 1},
        "doc-long-link-default": {"mode": "open", "pathb64": b64(f"{longdir}/link-to-sample"), "substitute": 1},
        "doc-long-package-default": {"mode": "open", "pathb64": b64(f"{longdir}/Pack.rtfd"), "substitute": 1},
    }
    only = st.get("only")
    for name, case in plan.items():
        if only and name not in only:
            continue
        rec = submit(vm, st, name, case)
        print(name, json.dumps(rec["rows"][0]["result"] if rec["rows"] else None)[:600])
        print("   logs", json.dumps(rec["logs"])[:500])
        print("   windows", rec["windows"][:300].replace("\n", " | "))


def phase_thresholds(vm: VM, st: dict) -> None:
    wit = "/Applications/KoineK134Witness.app"
    out = []
    for n in SETS:
        longdir = unb64(st["sets"][str(n)]["longDirB64"]).decode()
        doc, wdoc = f"{longdir}/sample.txt", f"{longdir}/sample.k134w"
        acq = vm.run_cases(f"thr-acq-{n}", [{"id": "a", "mode": "acquire", "pathb64": b64(doc), "followFinal": True},
                                            {"id": "h", "mode": "defaulthandler", "pathb64": b64(doc)}], timeout=60)
        r = rowmap(acq)
        sub = submit(vm, st, f"thr-open-{n}", {"mode": "open", "pathb64": b64(wdoc), "apppathb64": b64(wit), "substitute": 1})
        cb = sub["rows"][0]["result"].get("callback", {}) if sub["rows"] else {}
        rec = {"length": len(doc), "stat": r["a"]["wholePathControls"]["stat"], "FSPathMakeRef": r["a"]["wholePathControls"]["FSPathMakeRef"],
               "chainError": r["a"].get("refChain", {}).get("error"), "handlerNil": r["h"]["handler"] is None,
               "openError": cb.get("error"), "delivered": [w["deliveredLength"] for w in sub["logs"]["witness"]]}
        print(json.dumps(rec))
        out.append(rec)
    st["thresholds"] = out


def phase_launch(vm: VM, st: dict) -> None:
    longdir = unb64(st["plain"]["longDirB64"]).decode()
    sfx, lfx = "/Applications/KoineK134Fixture.app", f"{longdir}/KoineK134Fixture.app"
    vm.sh("pkill -x Koine; sleep 1; true")
    plan = [
        ("launch-short-cold", {"mode": "launch", "apppathb64": b64(sfx), "substitute": 0}),
        ("launch-long-while-short-running", {"mode": "launch", "apppathb64": b64(lfx), "substitute": 0}),
        ("launch-short-again-while-both-running", {"mode": "launch", "apppathb64": b64(sfx), "substitute": 0}),
    ]
    for name, case in plan:
        rec = submit(vm, st, name, case, wait_ms=3000)
        print(name, json.dumps(rec["rows"][0]["result"].get("callback"))[:700] if rec["rows"] else None)
        print("   self", json.dumps(rec["logs"]["self"])[:600], "\n   observer", rec.get("observer"))
    print("running", vm.sh("pgrep -lx Koine; true"))
    vm.sh("pkill -x Koine; sleep 1; true")
    rec = submit(vm, st, "launch-long-cold", {"mode": "launch", "apppathb64": b64(lfx), "substitute": 0}, wait_ms=3000)
    print("launch-long-cold", json.dumps(rec["rows"][0]["result"].get("callback"))[:700], "\n   self", json.dumps(rec["logs"]["self"])[:600])
    vm.sh("pkill -x Koine; true")


def phase_reveal(vm: VM, st: dict) -> None:
    """Finder is observed through the accessibility window list (no Automation consent is requested for an observer)."""
    longdir = unb64(st["plain"]["longDirB64"]).decode()
    for name, path in [("short", f"{HOME}/k134/short/sample.txt"), ("long", f"{longdir}/sample.txt"), ("long-folder", f"{longdir}/Folder")]:
        vm.ta("agent", "window-close", "--window", "Finder")
        time.sleep(1)
        rec = submit(vm, st, f"reveal-{name}", {"mode": "reveal", "pathb64": b64(path)}, wait_ms=3000)
        finder = [w for w in rec["windows"].splitlines() if 'app:"Finder"' in w]
        rec["finderWindows"] = finder
        print(name, json.dumps(rec["rows"][0]["result"])[:200], "| finder windows:", [f[:80] for f in finder])
        (vm.output / f"reveal-{name}.json").write_text(json.dumps(rec, indent=1))


def nodes(value):
    if isinstance(value, dict):
        return [value] + [n for v in value.values() for n in nodes(v)]
    if isinstance(value, list):
        return [n for v in value for n in nodes(v)]
    return []


def phase_prompts(vm: VM, st: dict) -> None:
    """First-use inspection and handler lookup on a ~1500-byte file under Documents; every dialog is denied and recorded."""
    longdir = unb64(st["docs"]["longDirB64"]).decode()
    doc = f"{longdir}/sample.txt"
    out = []
    short = f"{HOME}/Documents/k134/short/sample.txt"
    for mode, kind, target in [("control-defaulthandler-short", "defaulthandler", short), ("control-acquire-short", "acquire", short),
                               ("acquire", "acquire", doc), ("lsbind", "lsbind", doc), ("defaulthandler", "defaulthandler", doc), ("acquire-after", "acquire", doc)]:
        case = {"id": mode, "mode": kind, "pathb64": b64(target), "followFinal": True}
        vm.sh("pkill -x Koine; tccutil reset All dev.antony.Koine.K134Probe; true")
        remote = f"/tmp/k134-prompt-{mode}.jsonl"
        vm.sh(f"rm -f {remote}")
        with tempfile.TemporaryDirectory() as d:
            Path(f"{d}/c.json").write_text(json.dumps([case]))
            vm.ta("file", "upload", f"{d}/c.json", "/tmp/k134-prompt.json")
        vm.ta("file", "exec", "--detach", f"open -n {PROBE} --args run /tmp/k134-prompt.json {remote}")
        prompts, rows = [], []
        deadline = time.monotonic() + 40
        while time.monotonic() < deadline and not any(r.get("id") == "__done__" for r in rows):
            time.sleep(0.8)
            snap = vm.ta("agent", "snapshot", "--mode", "interact", "--json")
            try:
                data = json.loads(snap.stdout)
            except ValueError:
                data = {}
            for w in data.get("windows", []) if isinstance(data, dict) else []:
                text = json.dumps(w, ensure_ascii=False)
                if w.get("windowType") in ("menuBar", "standard") or "would like to access" not in text:
                    continue
                btn = [n for n in nodes(w) if n.get("label") in ("Don’t Allow", "Don't Allow")]
                if btn:
                    b = btn[0]
                    x = round(b["positionX"] + b["sizeWidth"] / 2); y = round(b["positionY"] + b["sizeHeight"] / 2)
                    vm.ta("screen", "capture", "-o", str(vm.output / f"prompt-{mode}-{len(prompts)}.png"))
                    prompts.append(text[:400])
                    vm.ta("input", "click", str(x), str(y))
                    time.sleep(0.5)
            rows = vm.read_lines(remote)
        rec = {"mode": mode, "prompts": prompts, "rows": [r for r in rows if r.get("id") != "__done__"]}
        out.append(rec)
        print(mode, "prompts:", len(prompts), json.dumps(rec["rows"])[:500])
    (vm.output / "prompts.json").write_text(json.dumps(out, indent=1))


if __name__ == "__main__":
    main()
