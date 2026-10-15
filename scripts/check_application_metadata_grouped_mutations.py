"""Run discarded accounting omissions against independent pure design controls."""
# pyright: strict
from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

ROOT = Path(__file__).resolve().parents[1]
MODULE = "application_metadata_grouped_storage.py"
MUTATIONS = {
    "unchanged control": ("class Group:", "class Group:"),
    "missing header": ('(f"header:{label}", 64)', '(f"header:{label}", 0)'),
    "missing pending pointer": ('("pending-backing", 8)', '("pending-backing", 0)'),
    "missing link": ('events.append((f"link:{kind}.previous.next", 8))',
                     'events.append((f"link:{kind}.previous.next", 0))'),
    "missing classification": ('("classification", 8)', '("classification", 0)'),
    "retirement refund": ('self.spent_gross += 8\n            self.spent_attempts += 2',
                          'self.spent_gross -= 8\n            self.spent_attempts += 2'),
    "grow frozen inventory": ('if self.frozen or self.failed or self.cancelled',
                              'if self.failed or self.cancelled'),
    "discard pending borrower": ('if self.pending:\n            raise ContractViolation',
                                 'if False:\n            raise ContractViolation'),
    "cleanup not reserved": ('8 * (len(self.blocks) + additional) + 8 + possible_freeze', '0'),
}


def main() -> None:
    source = (ROOT / "scripts" / MODULE).read_text()
    for name, (old, new) in MUTATIONS.items():
        if source.count(old) != 1:
            raise ValueError("mutation anchor not unique: " + name)
        with TemporaryDirectory(prefix="koine-grouped-mutation-") as directory:
            sandbox = Path(directory)
            (sandbox / MODULE).write_text(source.replace(old, new))
            shutil.copyfile(ROOT / "scripts/test_application_metadata_grouped_storage.py",
                            sandbox / "test_grouped.py")
            environment = dict(os.environ)
            environment["PYTHONPATH"] = str(sandbox) + os.pathsep + str(ROOT / "scripts")
            # The two full-subject cases run in the ordinary suite. Here independent
            # hand-computed/lifetime cases distinguish changed accounting mechanics.
            result = subprocess.run(
                [sys.executable, "-m", "pytest", "-q", str(sandbox / "test_grouped.py"),
                 "-k", "not saved_associations and not report_validator and not compact_storage"],
                cwd=sandbox, env=environment, capture_output=True, text=True, check=False)
            if name == "unchanged control":
                if result.returncode != 0 or "passed" not in result.stdout:
                    raise ValueError("unchanged subject did not pass: " + result.stdout)
                print("Unchanged subject passes the same instrument.")
                continue
            if result.returncode != 1 or "failed" not in result.stdout:
                raise ValueError("omission was not rejected: " + name + "\n" + result.stdout
                                 + result.stderr)
            print("Rejected accounting/lifetime omission: " + name)


if __name__ == "__main__":
    main()
