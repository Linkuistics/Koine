"""Offline regression: replay the actual k149 control without a guest or API call."""
import importlib.util
import json
from pathlib import Path

import pytest

DRIVER = Path(__file__).parents[1] / "vm-probe-file-reference-url.py"
spec = importlib.util.spec_from_file_location("k149_driver", DRIVER)
assert spec and spec.loader
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def test_actual_missing_name_record() -> None:
    raw = (Path(__file__).parents[2] / "docs/verification/file-reference-url-acquisition"
           / "results/run1/missing-control.out")
    rows = [json.loads(line) for line in raw.read_text().splitlines()]
    missing = next(row for row in rows if row.get("stage") == "missingReference")
    assert module.missing_reference_valid(missing)


@pytest.mark.parametrize("row", [{}, {"nonNull": 0}, {"nonNull": 1, "error": {"code": 260}},
                                 {"nonNull": "0", "error": {"code": 260}}])
def test_invalid_control_is_rejected(row: dict[str, object]) -> None:
    assert not module.missing_reference_valid(row)
