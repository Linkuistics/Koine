#!/usr/bin/env python3
"""Count the evidence attempts of each Settings scenario case, without a VM.

The instrument runs the two real scenario entries against the simulated guest
of Tests/scripts/fixtures/settings-scenario-backend.py. It counts the logged
backend calls and the screenshot calls of each case. The simulated guest writes
no real response bytes, so this output is a count and not a size.

Usage: measure-volume.py REPOSITORY
"""

from __future__ import annotations

import concurrent.futures
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ENTRIES = {
    "focused": "scripts/vm-verify-menu-bar-prefix.sh",
    "ordinary": "scripts/vm-verify-menu-bar.sh",
}


def run_case(source: Path, module: object, entry: str, flags: str) -> dict[str, int]:
    with tempfile.TemporaryDirectory(prefix="storage-volume-") as name:
        work = Path(name)
        repo = module.prepare(work, source, source)  # type: ignore[attr-defined]
        sim, bin_dir = work / "sim", work / "bin"
        sim.mkdir()
        bin_dir.mkdir()
        module.write_executable(bin_dir / "sleep", "#!/bin/bash\nexit 0\n")  # type: ignore[attr-defined]
        module.write_executable(bin_dir / "testanyware", "#!/bin/bash\nexit 97\n")  # type: ignore[attr-defined]
        environment = {
            key: value
            for key, value in os.environ.items()
            if not key.startswith(("KOINE_", "settings_", "TESTANYWARE_"))
        }
        environment.update(
            PATH=f"{bin_dir}:{os.environ['PATH']}",
            settings_sim=str(sim),
            settings_flags=flags,
            KOINE_APP_BUNDLE=str(repo / "bundle/Koine.app"),
            KOINE_VM_BASE="testanyware-golden-macos-27",
            KOINE_VM_ID="exact-settings-vm",
        )
        subprocess.run(
            [str(repo / entry)],
            cwd=repo,
            env=environment,
            capture_output=True,
            timeout=300,
            check=False,
        )
        calls = [
            json.loads(line) for line in (sim / "calls.jsonl").read_text().splitlines()
        ]
    captures = sum(
        1 for call in calls if str(call.get("operation", "")).startswith("screenshot-")
    )
    return {"attempts": len(calls), "captures": captures}


def main() -> int:
    source = Path(sys.argv[1]).resolve()
    spec = importlib.util.spec_from_file_location(
        "baseline", source / "scripts/check-settings-baseline.py"
    )
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules["baseline"] = module
    spec.loader.exec_module(module)
    jobs = [
        (entry_name, case, flags)
        for entry_name in ENTRIES
        for case, flags in module.CASES.items()
    ]
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        results = list(
            pool.map(
                lambda job: run_case(source, module, ENTRIES[job[0]], job[2]), jobs
            )
        )
    table: dict[str, dict[str, dict[str, int]]] = {name: {} for name in ENTRIES}
    for (entry_name, case, _), result in zip(jobs, results, strict=True):
        table[entry_name][case] = result
    summary = {
        name: {
            "complete": cases["complete"],
            "max_attempts": max(item["attempts"] for item in cases.values()),
            "max_captures": max(item["captures"] for item in cases.values()),
        }
        for name, cases in table.items()
    }
    print(json.dumps({"summary": summary, "cases": table}, indent=1, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
