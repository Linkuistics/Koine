"""Reject isolated source/root omissions; hash every input before and after."""
# pyright: strict

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

from application_metadata_source_root_certificate import INPUTS, hashes


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    before = hashes(root)
    model = "scripts/application_metadata_source_root.py"
    assessment = "scripts/application_metadata_source_root_certificate.py"
    tests = "scripts/test_application_metadata_source_root.py"
    mutations = (
        (model, "unknown capacity is zero", "if any(item.amount is None for item in owned):",
         "if False:", "unknown_capacity"),
        (model, "free duplicate URL slot", "for value in cf.urls:",
         "for value in cf.urls[:1]:", "duplicate_url"),
        (model, "omitted type-tree member", "for key in item.tree:",
         "for key in item.tree[:1]:", "indexed_projection"),
        (model, "registration error owner overlaps next batch", 'trace.release("cf-error")',
         'trace.invoke("omitted-error-retirement")', "registration_branches"),
        (model, "unpopulated pointer vector", 'self.write(label + ".population", 8 * count)',
         'self.write(label + ".population", 0)', "vector_population"),
        (model, "free ARC retention", 'if disposer.startswith("ARC."):',
         'if False:', "vector_population"),
        (model, "missing terminal named identity check", 'trace.invoke("fstatat.terminal-after")',
         'trace.invoke("omitted-terminal-check")', "two_walk_terminal"),
        (model, "suffix copy omitted", 'trace.bytes("walk.suffix-array", rest)',
         'trace.invoke("omitted-suffix-copy")', "expanded_visits"),
        (model, "long root resource call admitted", "ordinary = len(first.resolved) <= 1023",
         "ordinary = len(first.resolved) <= 1024", "long_finalized_root"),
        (assessment, "system ID reserve omitted",
         'len(ids) + len(("com.apple.Safari", "com.apple.finder"))',
         'len(ids)', "controlled_dimensions"),
        (assessment, "outside census paths dropped",
         'objects(subject["queryPathsOutsideDirectorySubject"])',
         'objects(subject["queryPathsOutsideDirectorySubject"])[:-1]', "controlled_dimensions"),
        (assessment, "unknown whole-job gross fabricated as zero", '"wholeJobGrossBytes": None,',
         '"wholeJobGrossBytes": 0,', "controlled_dimensions"),
    )
    for path, label, old, new, selected in mutations:
        source = (root / path).read_text()
        if source.count(old) != 1:
            raise RuntimeError(f"mutation anchor is not unique: {label}")
        with TemporaryDirectory(prefix="koine-source-root-control-") as directory:
            scratch = Path(directory)
            for item in INPUTS:
                target = scratch / item
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(root / item, target)
            (scratch / path).write_text(source.replace(old, new, 1))
            run = subprocess.run(
                [sys.executable, "-m", "pytest", "-q", "--maxfail=1", tests, "-k", selected],
                cwd=scratch, capture_output=True, text=True, check=False,
            )
            assertion = re.search(r"\nE\s+assert\b", run.stdout) is not None or any(
                marker in run.stdout for marker in (
                "AssertionError:", "DID NOT RAISE",
                "ValueError: system seed reserve omitted",
            ))
            if run.returncode != 1 or "1 failed" not in run.stdout or not assertion:
                raise RuntimeError(f"control did not detect {label}\n{run.stdout}\n{run.stderr}")
            print(f"Rejected: {label}")
    if hashes(root) != before:
        raise RuntimeError("source/root mutation inputs moved")


if __name__ == "__main__":
    main()
