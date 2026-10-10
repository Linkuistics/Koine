"""Contest episode accounting in isolated copies, with unchanged saved inputs."""
# pyright: strict

from __future__ import annotations

import hashlib
import shutil
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    model = root / "scripts/application_metadata_episode_certificate.py"
    tests = root / "scripts/test_application_metadata_episode_certificate.py"
    inputs = [model, tests, Path(__file__), root / "Taskfile.yml"] + [
        root / path for path in (
            "scripts/application_metadata_reader_plan.py",
            "scripts/application_metadata_operation_ledger.py",
            "docs/design/application-metadata-subject.json",
            "docs/design/application-metadata-budget-proposal.json",
        )
    ]
    before = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs}
    source = model.read_text()
    mutations = (
        ("free file cleanup", "2 * probes + 7 * len(sizes)",
         "2 * probes + 6 * len(sizes)", "file_envelope_keeps_cleanup"),
        ("omitted EOF input", "sum(sizes) + len(sizes)",
         "sum(sizes)", "empty_file_still_reads"),
        ("reused input refunds reads", "sum(sizes) + len(sizes)",
         "max(sizes, default=0) + len(sizes)", "repeated_input_is_cumulative"),
        ("free duplicate return inspection", "+ 6 * selectors + 5 * returns",
         "+ 6 * selectors + 5 * min(returns, 1)", "explicit_calls_charge_duplicate"),
        ("unselected table values uninspected", "+ tables + 6 * table_keys",
         "+ tables + 5 * table_keys", "explicit_calls_charge_duplicate"),
        ("rejected locale omitted", "6 * (locales + rejected)",
         "6 * locales", "rejected_locale_is_charged"),
        ("wire aliases refunded", "occurrences * (6 * size + 2)",
         "(6 * size + 2)", "escaping_and_alias"),
        ("alias records omitted", '"commonRows": common,',
         '"commonRows": common[:-128],', "all_saved_episodes"),
        ("unknown gross certified as zero", '"grossBytes": None,',
         '"grossBytes": 0,', "all_saved_episodes"),
    )
    for label, old, new, selected in mutations:
        if source.count(old) != 1:
            raise RuntimeError(f"Mutation anchor is not unique: {label}")
        with TemporaryDirectory(prefix="koine-episode-certificate-control-") as directory:
            scratch = Path(directory)
            for path in inputs:
                target = scratch / path.relative_to(root)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
            (scratch / model.relative_to(root)).write_text(source.replace(old, new, 1))
            run = subprocess.run(
                [sys.executable, "-m", "pytest", "-q", "--maxfail=1",
                 str(tests.relative_to(root)), "-k", selected],
                cwd=scratch, capture_output=True, text=True, check=False,
            )
            assertion = any(marker in run.stdout for marker in (
                "E       assert", "E       AssertionError:", "DID NOT RAISE",
            ))
            if run.returncode != 1 or "1 failed" not in run.stdout or not assertion:
                raise RuntimeError(
                    f"Control did not fail an assertion: {label}\n{run.stdout}\n{run.stderr}"
                )
            print(f"Rejected: {label}")
    after = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs}
    if before != after:
        raise RuntimeError("Episode mutation inputs changed during the check")


if __name__ == "__main__":
    main()
