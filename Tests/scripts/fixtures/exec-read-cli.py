"""Synthetic CLI only: no endpoint, VM, agent or guest is contacted.

It answers `file exec` in the shapes of the tagged v3.0.0 handler: JSON mode
prints one envelope and exits 0 on a clean spawn, and text mode passes the
streams through and exits with the guest status.
https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/file.rs
The tagged agent strips trailing whitespace from both streams.
https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/agents/macos/Sources/TestAnywareAgent/ProcessRunner.swift
Each call takes the next line of `read_script` when it exists, so a poll can
see a sequence of guest answers. A line is `EXIT TIMED_OUT CLI STDOUT-FILE`.
TIMED_OUT is `true` or `false`. It can also be `cancelled` or
`cancelled-before`: the agent cancelled the command after or before its start,
as the agent does at its own SIGTERM. The record then has exit code -1 and the
note `Process cancelled` in stderr. `read_stderr` replaces the guest stderr,
so an empty value leaves the note alone, as in the restart of release attempt 6.
`read_envelope` names a file of a real CLI reply. JSON mode then prints its
bytes unchanged and exits 0.
https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-protocol/src/exec_record.rs
CLI is a status, or `STATUS:CODE` for a failure that prints the CLI error
envelope with that code in JSON mode. The envelope has the four fields that the
tagged CLI always prints, and the optional fields are left out.
https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/output.rs
"""

from __future__ import annotations

import base64
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path


def strip(text: str) -> str:
    return re.sub(r"\s+$", "", text)


def stream_evidence(text: str) -> dict[str, object]:
    data = text.encode("utf-8")
    return {
        "base64": base64.b64encode(data).decode("ascii"),
        "bytes": len(data),
        "file_bytes": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
        "capture": "complete",
        "reason": None,
    }


def next_answer() -> tuple[int, str, str, str]:
    script = Path(os.environ.get("read_script", "/nonexistent"))
    if script.exists():
        counter = Path(str(script) + ".used")
        used = int(counter.read_text()) if counter.exists() else 0
        rows = script.read_text().splitlines()
        counter.write_text(str(used + 1))
        exit_code, timed_out, cli, stdout_file = rows[min(used, len(rows) - 1)].split(
            " ", 3
        )
        return (
            int(exit_code),
            timed_out,
            cli,
            # Bytes, so a CR in an answer survives, as in the agent's file.
            Path(stdout_file).read_bytes().decode("utf-8"),
        )
    stdout = Path(os.environ["read_stdout"]).read_bytes().decode("utf-8")
    return (
        int(os.environ.get("read_exit_code", "0")),
        os.environ.get("read_timed_out", "false"),
        os.environ.get("read_cli_status", "0"),
        stdout,
    )


def main() -> int:
    args = sys.argv[1:]
    with Path(os.environ["read_calls"]).open("a") as calls:
        calls.write(json.dumps(args) + "\n")
    if args[:2] != ["file", "exec"]:
        print(f"unsupported fixture command: {args}", file=sys.stderr)
        return 2
    command = args[-1]
    envelope_file = os.environ.get("read_envelope")
    if envelope_file and "--json" in args:
        sys.stdout.buffer.write(Path(envelope_file).read_bytes())
        return 0
    exit_code, ending, cli, stdout = next_answer()
    timed_out = ending == "true"
    cancelled = ending in {"cancelled", "cancelled-before"}
    stderr = os.environ.get("read_stderr", "synthetic guest diagnostic")
    if os.environ.get("read_mode") == "host":
        # Run the real command on this host, as the agent runs it in a guest.
        done = subprocess.run(
            ["/bin/bash", "-c", command], check=False, capture_output=True, text=True
        )
        exit_code, timed_out, stdout, stderr = (
            done.returncode,
            False,
            done.stdout,
            done.stderr,
        )
    # The baseline wrappers send the legacy test commands. Their status comes
    # from the same guest answer, so a legacy run sees the same guest state.
    if exit_code == 0 and command.startswith("[ -e "):
        # A launch identity answer also names a present descriptor.
        present = stdout.startswith(("PRESENT", "KOINE-SELECTED"))
        exit_code, stdout = (0 if present else 1), ""
    elif exit_code == 0 and command.startswith("! pgrep -f "):
        exit_code, stdout = (0 if stdout == "NONE" else 1), ""
    elif exit_code == 0 and command == "sysctl -n kern.boottime":
        # A successful sysctl writes nothing to stderr, and the legacy guest
        # merges stderr into the boot value it compares.
        stderr = ""
    elif (
        exit_code == 0
        and command.startswith("osascript -e ")
        and "\nKOINE-OSASCRIPT-STATUS " in stdout
    ):
        # The legacy sysevents command prints the default human-readable form
        # and a script error on stderr. The real osascript renders the same
        # source-form answer from a literal, so no Apple event is sent.
        value, _, status = stdout.rpartition("\nKOINE-OSASCRIPT-STATUS ")
        if status == "0":
            # A successful osascript writes nothing to stderr.
            stderr = ""
            stdout = subprocess.run(
                ["/usr/bin/osascript", "-e", value],
                check=True,
                capture_output=True,
                text=True,
            ).stdout
        else:
            exit_code, stdout, stderr = int(status), "", value
    if os.environ.get("read_keep_whitespace") != "1":
        stdout, stderr = strip(stdout), strip(stderr)
    if timed_out:
        exit_code = -1
        note = "Process timed out after 30s"
        stderr = note if not stderr else f"{stderr}\n[{note}]"
    if cancelled:
        exit_code = -1
        note = "Process cancelled"
        stderr = note if not stderr else f"{stderr}\n[{note}]"
    status, _, code = cli.partition(":")
    if code and "--json" in args:
        # A failure with the CLI error envelope, such as a dropped connection.
        envelope = {
            "schema_version": "1.0",
            "ok": False,
            "code": code,
            "message": "synthetic transport failure",
        }
        print(json.dumps(envelope, indent=2))
        return int(status)
    if int(status):
        # A transport failure, such as the CLI's connection timeout (7).
        print("synthetic transport failure", file=sys.stderr)
        return int(status)
    if "--json" not in args:
        if stdout:
            sys.stdout.write(stdout)
        if stderr:
            sys.stderr.write(stderr + "\n")
        return (
            0
            if exit_code == 0 and not timed_out
            else (255 if exit_code < 0 else exit_code)
        )
    envelope = {
        "schema_version": "1.0",
        "ok": True,
        "command": os.environ.get("read_command", command),
        "exit_code": exit_code,
        "stdout": stdout,
        "stderr": stderr,
        "timed_out": timed_out,
        "exec_id": "synthetic-exec",
        "record": "agent",
        "legacy_projection": "macos",
        "outcome": (
            {"kind": "timed_out", "timeout_seconds": 30}
            if timed_out
            else {"kind": "cancelled", "before_start": ending == "cancelled-before"}
            if cancelled
            else {"kind": "exited", "exit_code": exit_code}
        ),
        "evidence": {
            "stdout": stream_evidence(stdout),
            "stderr": stream_evidence(stderr),
        },
    }
    print(json.dumps(envelope))
    return 0


if __name__ == "__main__":
    sys.exit(main())
