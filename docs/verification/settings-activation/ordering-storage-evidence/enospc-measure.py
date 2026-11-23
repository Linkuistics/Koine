#!/usr/bin/env python3
"""Run the real slot caller on a small real volume that runs out of space.

Each case attaches a new 16 MiB HFS+ disk image and declares a sequence on it. A
filler leaves the stated free bytes. The real caller then runs E01 with the fake
Task of the containment controls, and tries E02. No VM or guest is contacted.
The case without a filler is the positive control.

Usage: enospc-measure.py REPOSITORY WORK_DIRECTORY
"""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

LEAVES = (None, 2_097_152, 524_288, 262_144, 131_072, 65_536, 32_768, 16_384, 8_192, 0)
BOUNDS = "holder=0.8,term=0.8,kill=3,stop=8,inventory=8,audit=8"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tree(root: Path) -> set[str]:
    return {
        str(path.relative_to(root)) for path in root.rglob("*") if not path.is_dir()
    }


def fill(volume: Path, leave: int) -> Path:
    filler = volume / "unrelated-filler.bin"
    stats = os.statvfs(volume)
    size = max(stats.f_bavail * stats.f_frsize - leave, 0)
    with filler.open("wb") as stream:
        stream.write(b"\xa5" * size)
        stream.flush()
        os.fsync(stream.fileno())
    return filler


def case(repo: Path, work: Path, leave: int | None) -> dict[str, object]:
    label = "none" if leave is None else str(leave)
    base = work / f"case-{label}"
    base.mkdir()
    image, volume = base / "volume.dmg", base / "volume"
    volume.mkdir()
    subprocess.run(
        [
            "hdiutil",
            "create",
            "-quiet",
            "-size",
            "16m",
            "-fs",
            "HFS+",
            "-volname",
            "k176",
            str(image),
        ],
        check=True,
    )
    subprocess.run(
        [
            "hdiutil",
            "attach",
            "-quiet",
            "-nobrowse",
            "-owners",
            "on",
            "-mountpoint",
            str(volume),
            str(image),
        ],
        check=True,
    )
    try:
        return drive(repo, base, volume, leave)
    finally:
        subprocess.run(
            ["hdiutil", "detach", "-quiet", "-force", str(volume)], check=False
        )


def drive(repo: Path, base: Path, volume: Path, leave: int | None) -> dict[str, object]:
    tool = repo / "scripts/settings-ordering-sequence.py"
    fixtures = repo / "Tests/scripts/fixtures"
    stubs = base / "bin"
    stubs.mkdir()
    for name, line in (
        ("testanyware", 'exec python3 "${lifecycle_fixture}" "$@"'),
        ("task", 'exec bash "${run_fixture}" "$@"'),
    ):
        stub = stubs / name
        stub.write_text(f"#!/bin/bash\n{line}\n")
        stub.chmod(0o755)
    frozen = base / "frozen"
    frozen.mkdir()
    (base / "guest").mkdir()
    for name in ("calls", "task-calls"):
        (base / name).touch()
    environment = {
        key: value
        for key, value in os.environ.items()
        if not key.startswith(("KOINE_", "TESTANYWARE_"))
    }
    environment.update(
        PATH=f"{stubs}:{os.environ['PATH']}",
        run_repo=str(repo),
        tool=str(tool),
        frozen=str(frozen),
        guest_bundle=str(frozen / "guest-bundle"),
        lifecycle_calls=str(base / "calls"),
        lifecycle_guest=str(base / "guest"),
        lifecycle_state=str(base / "running"),
        lifecycle_ready=str(base / "ready"),
        lifecycle_fixture=str(fixtures / "file-lifecycle-cli.py"),
        run_fixture=str(fixtures / "settings-run-task.sh"),
        run_log=str(base / "task-calls"),
        run_ready=str(base / "task-ready"),
        run_holder=str(base / "holder"),
        lifecycle_mode="clean",
        lifecycle_exit="0",
        lifecycle_block="0",
        run_mode="complete",
        KOINE_SEQUENCE_BOUNDS=BOUNDS,
    )

    def seq(*arguments: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", "-I", str(tool), *arguments],
            env=environment,
            capture_output=True,
            text=True,
            timeout=120,
            check=False,
        )

    receipt = base / "ready.json"
    subprocess.run(
        [
            "bash",
            "-c",
            f'source "{fixtures}/settings-audit-frozen.sh"; frozen_prepare; frozen_receipt focused "{receipt}"',
        ],
        env=environment,
        check=True,
    )
    screens = base / "screens.json"
    screens.write_text('{"result":"passed","detail":"control"}\n')
    sequence = volume / "sequence"
    declared = seq("declare", str(sequence))
    if declared.returncode != 0:
        return {
            "leave": leave,
            "declare": declared.returncode,
            "detail": declared.stderr[-200:],
        }
    ready = seq("ready", str(sequence), "focused", str(receipt))
    filler = fill(volume, leave) if leave is not None else None
    filler_digest = digest(filler) if filler else None
    run = seq("run", str(sequence), "E01")
    settle = (
        seq("settle-run", str(sequence), "E01", str(screens))
        if run.returncode == 0
        else None
    )
    after_first = tree(sequence)
    tasks_before = len((base / "task-calls").read_text().splitlines())
    second = seq("run", str(sequence), "E02")
    tasks_after = len((base / "task-calls").read_text().splitlines())
    report = seq("report", str(sequence))
    state: object = None
    if report.returncode == 0:
        value = json.loads(report.stdout)
        state = {
            "outcome": value["outcome"],
            "E01": value["slots"]["E01"].get(
                "disposition", value["slots"]["E01"]["state"]
            ),
            "E02": value["slots"]["E02"].get(
                "disposition", value["slots"]["E02"]["state"]
            ),
        }
    result_file = sequence / "ordering-evaluation/E01/containment/result.json"
    record_errors: object = "no result.json"
    if result_file.is_file():
        try:
            record_errors = len(json.loads(result_file.read_text())["record_errors"])
        except ValueError:
            record_errors = "unreadable result.json"
    final = tree(sequence)
    calls = [json.loads(line) for line in (base / "calls").read_text().splitlines()]
    stops = sum(1 for call in calls if call[:2] == ["vm", "stop"])
    running_file = base / "running"
    running = running_file.read_text().split() if running_file.exists() else []
    filler_unchanged = None if filler is None else digest(filler) == filler_digest
    # The recovery: the owner frees unrelated space, and no evidence is deleted.
    recovery: dict[str, object] = {}
    if (
        filler is not None
        and report.returncode == 0
        and state["E01"] == "started-unsettled"
    ):  # type: ignore[index]
        filler.unlink()
        settled = seq("settle", str(sequence), "E01")
        retry = seq("run", str(sequence), "E02")
        again = json.loads(seq("report", str(sequence)).stdout)
        recovery = {
            "settle": settled.returncode,
            "E01": again["slots"]["E01"].get("disposition"),
            "cleanup": again["slots"]["E01"].get("cleanup"),
            "outcome": again["outcome"],
            "run_E02": retry.returncode,
            "E02": again["slots"]["E02"]["state"],
            "E02_tasks_started": len((base / "task-calls").read_text().splitlines())
            - tasks_after,
            "files_lost": sorted(final - tree(sequence)),
        }
    return {
        "stop_calls_both_runs": stops,
        "clone_running_after": running,
        "recovery": recovery,
        "leave": leave,
        "ready": ready.returncode,
        "run_E01": run.returncode,
        "settle_E01": None if settle is None else settle.returncode,
        "run_E02": second.returncode,
        "E02_tasks_started": tasks_after - tasks_before,
        "report": report.returncode,
        "state": state,
        "record_errors": record_errors,
        "partials": sorted(name for name in final if name.endswith(".partial")),
        "files_lost_after_E01": sorted(after_first - final),
        "filler_unchanged": filler_unchanged,
        "E01_stderr": run.stderr.replace(str(base), "<case>")[-160:],
        "E02_stderr": second.stderr.replace(str(base), "<case>")[-160:],
    }


def main() -> int:
    repo, work = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
    work.mkdir()
    results = [case(repo, work, leave) for leave in LEAVES]
    print(json.dumps(results, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
