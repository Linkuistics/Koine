"""Run deliberately broken pure ledger copies; never edit the real inputs."""
# pyright: strict

from __future__ import annotations

import hashlib
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory


def main() -> None:
    scripts = Path(__file__).resolve().parent
    model = scripts / "application_metadata_operation_ledger.py"
    tests = scripts / "test_application_metadata_operation_ledger.py"
    policy = scripts / "application_metadata_reader_plan.py"
    inputs = [model, tests, policy, Path(__file__)]
    before = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs}
    source = model.read_text()
    mutations = (
        ("missing read/copy charge", "self.spent_bytes += bytes_written",
         "self.spent_bytes += 0", "reusing_a_buffer"),
        ("free invoked call", "self.spent_attempts += 1\n        self.operations",
         "self.spent_attempts += 0\n        self.operations", "every_file_exit"),
        ("unreserved possible cleanup", "+ 1 + len(possible) > self.attempt_limit",
         "+ 1 > self.attempt_limit", "cleanup_capacity_is_required"),
        ("wrong listing owner disposal", 'Resource("dir", "closedir")',
         'Resource("dir", "close")', "listing_fd_transfers"),
        ("omitted parser error owner", 'outputs = ("error",)',
         "outputs = ()", "parser_result_and_error"),
        ("free duplicate selector slot", "for key in returned:",
         "for key in dict.fromkeys(returned):", "direct_return_duplicates"),
        ("dispose refunds spent gross", "item = self.resources.pop(name)",
         "item = self.resources.pop(name)\n        self.spent_bytes = 0",
         "allocation_copy_and_read"),
    )
    for label, old, new, selected in mutations:
        if source.count(old) != 1:
            raise RuntimeError(f"Mutation anchor is not unique: {label}")
        with TemporaryDirectory(prefix="koine-pure-ledger-control-") as directory:
            scratch = Path(directory)
            (scratch / model.name).write_text(source.replace(old, new, 1))
            (scratch / tests.name).write_bytes(tests.read_bytes())
            (scratch / policy.name).write_bytes(policy.read_bytes())
            run = subprocess.run(
                [sys.executable, "-m", "pytest", "-q", "--maxfail=1", tests.name,
                 "-k", selected],
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
        raise RuntimeError("Pure ledger mutation subjects changed during the check")


if __name__ == "__main__":
    main()
