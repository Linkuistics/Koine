"""Break each k173 repair in a private copy, and record which controls fail."""
import concurrent.futures as futures, hashlib, json, os, re, shutil, subprocess, sys
from pathlib import Path

REPO = Path(sys.argv[1]); WORK = Path(sys.argv[2])
TOOL = "scripts/settings-ordering-sequence.py"
SUITES = ["vm-settings-sequence.bats", "vm-settings-containment.bats", "vm-settings-audits.bats"]
FILTER = "recover|recurrence|lost|partial|every clean|every phase|manual settle|hand-edited|corroborated"
M = [
 ("R1 recovery invents passed phases", 'missing = phase(\n        "unavailable", f"the caller ended before this phase (scenario file {state})"\n    )', 'missing = phase("passed", "invented")'),
 ("R1 recovery invents a task status", '"task": {"status": None},\n        **dict.fromkeys(RESULT_PHASES, missing),\n    }\n\n\ndef settle(', '"task": {"status": 0},\n        **dict.fromkeys(RESULT_PHASES, phase("passed", "invented")),\n    }\n\n\ndef settle('),
 ("R1 recovery confirms cleanup", '        **dict.fromkeys(RESULT_PHASES, missing),\n    }\n\n\ndef settle(', '        **dict.fromkeys(RESULT_PHASES, missing),\n        "stop": phase("passed", "invented"),\n        "inventory": phase("passed", "invented"),\n    }\n\n\ndef settle('),
 ("R1 verb accepts a phases file", 'settle_parser.add_argument("slot", choices=SLOT_NAMES)\n', 'settle_parser.add_argument("slot", choices=SLOT_NAMES)\n    settle_parser.add_argument("phases", type=Path, nargs="?")\n'),
 ("R1 collected-phases guard removed", 'if (output / CONTAINMENT / "phases.json").exists():\n            raise Refusal(f"{slot} has collected phases, so use settle-run")\n        phases = recovery_phases', 'phases = recovery_phases'),
 ("R2 decide ignores the subject", 'for name in ("subject", "screenshots")', 'for name in ("screenshots",)'),
 ("R2 subject omits system", '            ("system", system_check(root, declared, absent)["result"]),\n            ("gatekeeper"', '            ("gatekeeper"'),
 ("R2 subject omits gatekeeper", '            ("gatekeeper", gatekeeper_check(root, declared, absent)["result"]),\n', ''),
 ("R2 subject omits installed-before", '            (INSTALLED_BEFORE, before["result"]),\n', ''),
 ("R2 subject omits process arguments", '            ("process arguments", "failed" if different else "passed"),\n', ''),
 ("R2 later endpoint erases recurrence", 'for name in ("subject", "screenshots")', 'for name in ("subject", "screenshots", "endpoint")'),
 ("R2 later environment erases recurrence", 'for name in ("subject", "screenshots")', 'for name in ("subject", "screenshots", "environment")'),
 ("R2 later process read erases recurrence", 'rows, _ = observed_arguments(root)\n    different = any(row != frozen["process_arguments"] for row in rows)', 'rows, problems = observed_arguments(root)\n    different = bool(problems) or any(row != frozen["process_arguments"] for row in rows)'),
 ("R3 read owes no saved stdout", '"read": (*CLI_MEMBERS, "guest.stdout", "guest.stderr", "read.json")', '"read": (*CLI_MEMBERS, "guest.stderr", "read.json")'),
 ("R3 read owes no saved stderr", '"read": (*CLI_MEMBERS, "guest.stdout", "guest.stderr", "read.json")', '"read": (*CLI_MEMBERS, "guest.stdout", "read.json")'),
 ("R3 read owes no parsed record", '"read": (*CLI_MEMBERS, "guest.stdout", "guest.stderr", "read.json")', '"read": (*CLI_MEMBERS, "guest.stdout", "guest.stderr")'),
 ("R3 commands owe no exit record", 'CLI_MEMBERS = ("raw.stdout", "raw.stderr", "cli.exit")', 'CLI_MEMBERS = ("raw.stdout", "raw.stderr")'),
 ("R3 responses are not owed", 'CLI_MEMBERS = ("raw.stdout", "raw.stderr", "cli.exit")', 'CLI_MEMBERS = ("raw.stderr", "cli.exit")'),
 ("R3 upload owes no transfer record", '        "local-after.json",\n        "transfer.json",\n', '        "local-after.json",\n'),
 ("R3 a missing member does not fail", '"failed" if mismatched or missing else', '"failed" if mismatched else'),
 ("R3 failed attempts owe clean members", '            if clean:\n                if not isinstance(transport, str)', '            if True:\n                if not isinstance(transport, str)'),
 ("R3 partial response is unreadable", '        if clean or saved:\n            raise\n        return None, []', '        raise'),
]

def prepare(name):
    d = WORK / name
    shutil.rmtree(d, ignore_errors=True)
    (d / "Tests").mkdir(parents=True); (d / "App").mkdir()
    shutil.copytree(REPO / "scripts", d / "scripts")
    shutil.copytree(REPO / "Tests/scripts", d / "Tests/scripts")
    shutil.copy(REPO / "App/Info.plist", d / "App/Info.plist")
    return d

def bats(d, only):
    failed = []
    for suite in SUITES:
        args = ["bats", "--tap"] + (["--filter", FILTER] if only else []) + [str(d / "Tests/scripts" / suite)]
        out = subprocess.run(args, capture_output=True, text=True, cwd=d, timeout=420).stdout
        failed += [f"{suite}: {m}" for m in re.findall(r"^not ok \d+ (.+)$", out, re.M)]
    return failed

def one(item):
    index, (label, old, new) = item
    d = prepare(f"m{index:02d}")
    p = d / TOOL; t = p.read_text()
    if t.count(old) < 1:
        return {"mutation": label, "applied": False, "failed": []}
    p.write_text(t.replace(old, new, 1))
    failed = bats(d, True)
    shutil.rmtree(d, ignore_errors=True)
    return {"mutation": label, "applied": True, "caught": bool(failed), "failed": failed}

def digest():
    h = hashlib.sha256()
    for root in ("scripts", "Tests/scripts"):
        for f in sorted((REPO / root).rglob("*")):
            if f.is_file() and "__pycache__" not in f.parts:
                h.update(str(f.relative_to(REPO)).encode()); h.update(f.read_bytes())
    return h.hexdigest()

before = digest()
base = prepare("baseline"); clean = bats(base, False); shutil.rmtree(base, ignore_errors=True)
with futures.ThreadPoolExecutor(6) as pool:
    rows = list(pool.map(one, enumerate(M)))
after = digest()
out = {"subject_before": before, "subject_after": after, "unchanged": before == after, "baseline_failures": clean, "mutations": len(rows), "caught": sum(bool(r.get("caught")) for r in rows), "rows": rows}
(WORK / "mutations.json").write_text(json.dumps(out, indent=1))
print(json.dumps({k: out[k] for k in ("unchanged", "baseline_failures", "mutations", "caught")}))
for r in rows:
    print(("CAUGHT " if r.get("caught") else "SURVIVED " if r.get("applied") else "NOT-APPLIED ") + r["mutation"] + f"  ({len(r['failed'])})")
