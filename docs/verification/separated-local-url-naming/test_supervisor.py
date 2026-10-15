"""No guest allocation: guards for stalled input and failed disposal accounting."""

import importlib.util
import json
import os
import subprocess
import time

import pytest

SPEC = importlib.util.spec_from_file_location(
    "k164", "scripts/vm-probe-separated-local-url-name.py"
)
assert SPEC and SPEC.loader
DRIVER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DRIVER)


def test_partial_line_has_a_deadline():
    reader, writer = os.pipe()
    try:
        os.write(writer, b"PARTIAL")
        started = time.monotonic()
        with pytest.raises(TimeoutError):
            DRIVER.read_response(reader, 0.05)
        assert time.monotonic() - started < 0.5
    finally:
        os.close(reader)
        os.close(writer)


def test_complete_response_and_eof():
    reader, writer = os.pipe()
    try:
        os.write(writer, b"TOKEN\n")
        os.close(writer)
        writer = -1
        assert DRIVER.read_response(reader, 0.05) == "TOKEN"
        with pytest.raises(EOFError):
            DRIVER.read_response(reader, 0.05)
    finally:
        os.close(reader)
        if writer >= 0:
            os.close(writer)


@pytest.mark.parametrize("failure", ["timeout", "nonzero", "survives"])
def test_failed_disposal_is_incomplete_and_keeps_receipts(
    tmp_path, monkeypatch, failure
):
    def cli(command, **_kwargs):
        if command[2] == "stop":
            if failure == "timeout":
                raise subprocess.TimeoutExpired(command, 50)
            return subprocess.CompletedProcess(
                command, 5 if failure == "nonzero" else 0, '{"ok":true}', ""
            )
        return subprocess.CompletedProcess(
            command,
            0,
            json.dumps(
                {
                    "ok": True,
                    "items": [{"name": "koine-k164"}] if failure == "survives" else [],
                }
            ),
            "",
        )

    monkeypatch.setattr(DRIVER.subprocess, "run", cli)
    result = DRIVER.dispose("koine-k164", tmp_path)
    assert result["disposed"] is False
    assert (tmp_path / "vm-stop.json").is_file()
    assert (tmp_path / "vm-list-after.json").is_file()
