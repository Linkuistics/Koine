#!/usr/bin/env python3
"""Settle one started slot with supplied phases, for the decision controls.

The caller's settle verb takes no phases, because a recovery cannot report audits
that never ran. These controls still reach each row of the decision table, so
this fixture calls the same writer, slot check and settlement record.
"""

# pyright: strict
from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path
from typing import Any


def main() -> int:
    if len(sys.argv) != 5:
        print(
            "usage: settings-sequence-settle.py TOOL DIRECTORY SLOT PHASES",
            file=sys.stderr,
        )
        return 2
    tool, directory, slot, phases_path = (
        Path(sys.argv[1]),
        Path(sys.argv[2]),
        sys.argv[3],
        Path(sys.argv[4]),
    )
    spec = importlib.util.spec_from_file_location("settings_ordering_sequence", tool)
    if spec is None or spec.loader is None:
        print("the caller could not be loaded", file=sys.stderr)
        return 2
    caller: Any = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(caller)

    def step(sequence: Any) -> Any:
        sequence.check_settle(slot)
        phases = caller.read_phases(phases_path)
        classification = caller.settled_classification(sequence.slots[slot])
        return caller.record_settlement(sequence, slot, phases, classification)

    try:
        print(json.dumps(caller.with_writer(directory, "settle", step), indent=2))
    except caller.Refusal as error:
        print(f"refused: {error}", file=sys.stderr)
        return 3
    return 0


if __name__ == "__main__":
    sys.exit(main())
