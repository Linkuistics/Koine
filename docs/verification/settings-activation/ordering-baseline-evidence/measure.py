#!/usr/bin/env python3
"""Run the k171 instrument with the baseline check, into this directory.

Usage: measure.py REPOSITORY
"""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location(
    "reconciliation_measure",
    HERE.parent / "ordering-reconciliation-evidence/measure.py",
)
assert SPEC is not None and SPEC.loader is not None
measure = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(measure)
measure.CHECKS = (*measure.CHECKS, "check:settings-baseline")
measure.EVIDENCE = "docs/verification/settings-activation/ordering-baseline-evidence"
measure.OUTPUTS = {
    f"{measure.EVIDENCE}/final-verification.txt",
    f"{measure.EVIDENCE}/final-verification.txt.json",
    f"{measure.EVIDENCE}/final-verification.txt.subjects",
}
sys.exit(measure.main())
