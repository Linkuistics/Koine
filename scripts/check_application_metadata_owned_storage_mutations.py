"""Deliberately break one owned-storage contract at a time in a disposable copy."""
# pyright: strict

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

from application_metadata_owned_storage import INPUTS, hashes


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    before = hashes(root)
    model = "scripts/application_metadata_owned_storage.py"
    tests = "scripts/test_application_metadata_owned_storage.py"
    mutations = (
        ("free allocation capacity", "self.ledger.allocate(name, requested)",
         "self.ledger.allocate(name, 0)", "capacity_header"),
        ("free header initialization", "self.ledger.copy(header)",
         "self.ledger.copy(0)", "capacity_header"),
        ("free growth copy", "self.write(replacement, used * stride)",
         "self.write(replacement, 0)", "growing_vector"),
        ("hidden growth overlap", "self.peak = max(self.peak, self.live)",
         "self.peak = max(self.peak, requested)", "growing_vector"),
        ("refunded disposal", "self.live -= block.capacity",
         "self.live -= block.capacity\n        self.ledger.spent_bytes -= block.capacity",
         "growing_vector"),
        ("read charged only once", "self.ledger.read(size)",
         "self.ledger.read(0)", "immutable_inputs"),
        ("free EOF byte", "self.ledger.read(eof)",
         "self.ledger.read(0)", "immutable_inputs"),
        ("free partial conversion", 'self.write("conversion", size)',
         'self.write("conversion", 0)', "scalar_projection"),
        ("unknown-to-zero", "if any(value is None for value in values):",
         "if False:", "unknown_terms"),
        ("omitted alias episode", 'spellings = texts(subject["episodeSpellings"])',
         'spellings = texts(subject["episodeSpellings"])[:-1]', "every_saved_episode"),
        ("omitted outside path", 'objects(subject["queryPathsOutsideDirectorySubject"]),',
         'objects(subject["queryPathsOutsideDirectorySubject"])[:-1],', "every_saved_episode"),
        ("omitted saved input gross", 'sum(sizes) + len(sizes) + sum(reader_terms),',
         'len(sizes) + sum(reader_terms),', "every_saved_episode"),
        ("omitted direct selector key", 'sum(value[0] for value in selector_key_costs),',
         '0,', "every_saved_episode"),
    )
    for label, old, new, selected in mutations:
        source = (root / model).read_text()
        if source.count(old) != 1:
            raise RuntimeError(f"non-unique mutation anchor: {label}")
        with TemporaryDirectory(prefix="koine-owned-storage-control-") as directory:
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
                "AssertionError", "DID NOT RAISE", "saved distinct alias episodes changed"))
            if run.returncode != 1 or "1 failed" not in run.stdout or not detected:
                raise RuntimeError(f"control failed to detect {label}\n{run.stdout}\n{run.stderr}")
            print(f"Rejected: {label}")
    if hashes(root) != before:
        raise RuntimeError("owned-storage control inputs changed")


if __name__ == "__main__":
    main()
