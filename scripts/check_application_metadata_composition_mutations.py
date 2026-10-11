"""Catch composition/admission defects in disposable copies, never native code."""
# pyright: strict
from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

from application_metadata_composition import INPUTS, hashes


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    before = hashes(root)
    model = "scripts/application_metadata_composition.py"
    tests = "scripts/test_application_metadata_composition.py"
    source = (root / model).read_text()
    mutations = (
        ("unknown-to-zero", "if any(value is None for value in values):", "if False:",
         "unknown_operand"),
        ("duplicate read charge", '"knownAttemptsUpper": api + local - reads,',
         '"knownAttemptsUpper": api + local,', "read_attempts_overlap"),
        ("missing initialization reservation", "gross_upper=capacity + writes)",
         "gross_upper=capacity)", "capacity_and_initialization"),
        ("missing input gross", '"knownGrossSubterms": gross,',
         '"knownGrossSubterms": 0,', "read_attempts_overlap"),
        ("omitted alias episode", 'spellings = texts(subject["episodeSpellings"])',
         'spellings = texts(subject["episodeSpellings"])[:-1]', "every_saved_association"),
        ("lost outside path", '"outsidePaths": outside,',
         '"outsidePaths": outside[:-1],', "every_saved_association"),
        ("invented fit", '"wholeJobGrossBytes": sum_terms([known_gross, None]),',
         '"wholeJobGrossBytes": known_gross,', "every_saved_association"),
        ("numeric ABI/minimum/post-call capacity admission",
         'if evidence != "EXPLICIT_REQUEST":', 'if False:', "numeric_payload"),
        ("missing owner/growth/initialization receipt disposition",
         'if set(replacements) != set(unbound):', 'if False:', "receipt_disposition"),
        ("dropped explicit runtime invocation",
         'return 0, 1', 'return 0, 0', "scoped_runtime_call"),
        ("unknown raw operand treated as excluded",
         'if amount is None or amount < 0:', 'if amount is not None and amount < 0:',
         "scoped_runtime_call"),
        ("cleanup raw write reservation dropped",
         'gross = sum(cost[0] for cost in work + cleanup)',
         'gross = sum(cost[0] for cost in work)', "scoped_reservation"),
        ("cleanup attempt reservation dropped",
         'attempts = sum(cost[1] for cost in work + cleanup)',
         'attempts = sum(cost[1] for cost in work)', "scoped_reservation"),
        ("raw owner fields and retired-state write dropped",
         'return requested + 64 + payload + 8, 5',
         'return requested + 32 + payload, 4', "raw_recipe"),
        ("provider publication moved to host",
         'if owner != "PROVIDER":', 'if False:', "scoped_runtime_call"),
        ("scoped unknown native input changed to zero",
         '"scopedWholeJobGrossBytes": sum_terms([scoped_gross, None]),',
         '"scopedWholeJobGrossBytes": scoped_gross,', "every_saved_association"),
        ("dropped controlled raw path projection",
         '"pathProjectionGross": path_projection_gross,',
         '"pathProjectionGross": 0,', "controlled_path_enclosure"),
    )
    for label, old, new, selected in mutations:
        if source.count(old) != 1:
            raise RuntimeError("non-unique mutation anchor: " + label)
        with TemporaryDirectory(prefix="koine-composition-control-") as directory:
            scratch = Path(directory)
            for item in INPUTS:
                target = scratch / item
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(root / item, target)
            (scratch / model).write_text(source.replace(old, new, 1))
            run = subprocess.run(
                [sys.executable, "-m", "pytest", "-q", "--maxfail=1", tests, "-k", selected],
                cwd=scratch, capture_output=True, text=True, check=False,
            )
            detected = any(marker in run.stdout for marker in (
                "AssertionError", "complete alias episode sequence changed", "DID NOT RAISE"))
            if run.returncode != 1 or "failed" not in run.stdout or not detected:
                raise RuntimeError(f"undetected mutation: {label}\n{run.stdout}\n{run.stderr}")
            print("Rejected: " + label)
    if hashes(root) != before:
        raise RuntimeError("composition inputs changed during mutation checks")


if __name__ == "__main__":
    main()
