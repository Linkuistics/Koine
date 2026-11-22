#!/usr/bin/env python3
"""Replay a simulated scenario's ordered calls through the real receipt backend.

The simulated backend logs each call and writes no real receipts. This fixture
gives each logged call one real attempt, so a control reads the true receipt
schema with the true operation order. It proves nothing about a guest.
"""

# pyright: strict
from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path
from typing import Any, cast


def main() -> int:
    if len(sys.argv) != 5:
        print(
            "usage: settings-sequence-replay.py SCRIPTS CALLS ROOT VM", file=sys.stderr
        )
        return 2
    scripts, calls, root, vm = (
        Path(sys.argv[1]),
        Path(sys.argv[2]),
        Path(sys.argv[3]),
        sys.argv[4],
    )
    sys.path.insert(0, str(scripts))
    spec = importlib.util.spec_from_file_location(
        "vm_guest_exec", scripts / "vm-guest-exec.py"
    )
    if spec is None or spec.loader is None:
        print("the receipt backend could not be loaded", file=sys.stderr)
        return 2
    backend: Any = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(backend)
    backend.initialize(root, vm)
    for line in calls.read_text().splitlines():
        call = cast(dict[str, Any], json.loads(line))
        operation = call.get("operation")
        if not isinstance(operation, str):
            continue
        outcome = call.get("outcome")
        if outcome == "clean":
            backend.run(
                root, "evidence", operation, "state", "replayed", "poll-step", ["0"]
            )
        elif outcome == "state-failed":
            backend.run(
                root, "evidence", operation, "exhausted", "replayed", "poll-step", ["1"]
            )
        elif outcome in {"unavailable", "failed-confirmation"}:
            backend.run(
                root, "evidence", operation, "replayed failure", "", "confirmation"
            )
        elif outcome == "refused":
            backend.refuse(root, f"replayed refusal of {operation}")
        else:
            print(f"unknown replay outcome: {outcome}", file=sys.stderr)
            return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
