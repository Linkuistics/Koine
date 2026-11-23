#!/usr/bin/env python3
"""Run the affected harness checks once, between two digests of every tracked file.

This instrument reuses measure.py of the reconciliation evidence, and writes its
three outputs here. Usage: final-check.py REPOSITORY
"""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

HERE = "docs/verification/settings-activation/ordering-storage-evidence"
SOURCE = Path(__file__).resolve().parent.parent / "ordering-reconciliation-evidence"

spec = importlib.util.spec_from_file_location("measure", SOURCE / "measure.py")
assert spec is not None and spec.loader is not None
measure = importlib.util.module_from_spec(spec)
spec.loader.exec_module(measure)
measure.CHECKS = (*measure.CHECKS, "check:settings-baseline")
measure.EVIDENCE = HERE
measure.OUTPUTS = {
    f"{HERE}/final-verification.txt",
    f"{HERE}/final-verification.txt.json",
    f"{HERE}/final-verification.txt.subjects",
}
sys.exit(measure.main())
