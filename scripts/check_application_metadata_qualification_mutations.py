"""Discarded guard/eligibility defects must fail the same independent pure controls."""
# pyright: strict
from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

ROOT = Path(__file__).resolve().parents[1]
MODULE = "check_application_metadata_reconciliation.py"
MUTATIONS = {
    "unchanged control": ("terms = (spent, cleanup, failure,", "terms = (spent, cleanup, failure,"),
    "missing live cleanup": ("terms = (spent, cleanup, failure,", "terms = (spent, failure,"),
    "missing failure envelope": ("terms = (spent, cleanup, failure,", "terms = (spent, cleanup,"),
    "missing possible cleanup": (", possible_cleanup)\n", ")\n"),
    "unknown or frozen work admitted": (
        "if frozen or any(value is None for value in work):\n        return False",
        "if frozen or any(value is None for value in work):\n        return True",
    ),
    "failure prefix refund": (
        "return spent[0] + actual[0], spent[1] + actual[1]",
        "return spent[0] - actual[0], spent[1] - actual[1]",
    ),
    "omitted whole review": (
        '"DESIGN", "WHOLE_REVIEW_INTEGRATION", "SOURCE_ACCESS_REVIEW",',
        '"DESIGN", "SOURCE_ACCESS_REVIEW",',
    ),
    "partial evidence releases": (
        "private_ready and all(evidence.get(key) is True for key in RELEASE_EVIDENCE)",
        "private_ready and any(evidence.get(key) is True for key in RELEASE_EVIDENCE)",
    ),
    "unreserved terminal evaluation": (
        "terms += (terminal_guard,)", "terms += ()",
    ),
    "free refused evaluation": (
        "charged = settle_prefix(spent, actual, credit)", "charged = spent",
    ),
    "terminal credit reused": (
        "return charged, credit if admitted else (0, 0), not admitted",
        "return charged, credit, False",
    ),
    "weaker eligibility prose accepted": (
        'errors.append(f"{path}: abbreviated private eligibility")', "pass",
    ),
}


def main() -> None:
    source = (ROOT / "scripts" / MODULE).read_text()
    for name, (old, new) in MUTATIONS.items():
        if source.count(old) != 1:
            raise ValueError("mutation anchor not unique: " + name)
        with TemporaryDirectory(prefix="koine-qualification-mutation-") as directory:
            sandbox = Path(directory)
            (sandbox / MODULE).write_text(source.replace(old, new))
            shutil.copyfile(ROOT / "scripts/test_application_metadata_qualification.py",
                            sandbox / "test_qualification.py")
            environment = dict(os.environ)
            environment["PYTHONPATH"] = str(sandbox) + os.pathsep + str(ROOT / "scripts")
            result = subprocess.run(
                [sys.executable, "-m", "pytest", "-q", str(sandbox / "test_qualification.py"),
                 "-k", "not incomplete_guard and not guard_cannot_omit"],
                cwd=sandbox, env=environment, capture_output=True, text=True, check=False,
            )
            expected = 0 if name == "unchanged control" else 1
            marker = "passed" if expected == 0 else "failed"
            if result.returncode != expected or marker not in result.stdout:
                raise ValueError("control did not discriminate: " + name + "\n"
                                 + result.stdout + result.stderr)
            print("Unchanged control passes." if expected == 0 else "Rejected defect: " + name)


if __name__ == "__main__":
    main()
