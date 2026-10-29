#!/usr/bin/env python3
"""Record one guest exec at the shell helper seam; never retry a transport."""

# pyright: strict
from __future__ import annotations

import argparse
import fcntl
import json
import os
import re
import signal
import subprocess
import sys
import time
from datetime import UTC, datetime
from pathlib import Path
from typing import cast

UNAVAILABLE = 125


def timestamp() -> str:
    return datetime.now(UTC).isoformat()


def write_json(path: Path, value: object) -> None:
    partial = path.with_name(path.name + ".partial")
    with partial.open("x") as stream:
        json.dump(value, stream, indent=2, ensure_ascii=True)
        stream.write("\n")
        stream.flush()
        os.fsync(stream.fileno())
    # Publish a complete file atomically without replacing any existing receipt.
    os.link(partial, path)
    partial.unlink()


def unique_object(pairs: list[tuple[str, object]]) -> dict[str, object]:
    result: dict[str, object] = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON field: {key}")
        result[key] = value
    return result


def reject_constant(value: str) -> object:
    raise ValueError(f"non-JSON numeric constant: {value}")


def read_object(path: Path) -> dict[str, object]:
    value: object = json.loads(
        path.read_bytes(),
        object_pairs_hook=unique_object,
        parse_constant=reject_constant,
    )
    if not isinstance(value, dict):
        raise ValueError("invalid JSON envelope: expected one object")  # noqa: TRY004
    return cast(dict[str, object], value)


def latch(root: Path, reason: str) -> None:
    try:
        with (root / "unavailable").open("x") as stream:
            stream.write(reason + "\n")
    except FileExistsError:
        pass  # The first failure remains the reason, including during collection.


def initialize(root: Path, vm: str) -> int:
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*", vm):
        raise ValueError("expected an exact plain VM identity")
    root.mkdir()  # Refuse reuse, overwrites and implicit parent creation.
    write_json(root / "subject.json", {"vm": vm})
    return 0


def validate_response(
    attempt: Path, command: str, cli_status: int, predicate: str, lock_fd: int
) -> str:
    try:
        envelope = read_object(attempt / "raw.stdout")
    except (ValueError, UnicodeError) as error:
        return f"invalid exec envelope: {error}"
    # Preserve supplied guest streams even on failure; they are not qualified output.
    for field in ("stdout", "stderr"):
        value = envelope.get(field)
        if isinstance(value, str):
            (attempt / f"guest.{field}").write_bytes(value.encode("utf-8"))
    # v2.7.0 puts these fields at top level; CLI zero only proves clean spawn.
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/file.rs
    if cli_status != 0:
        return f"CLI exit {cli_status}"
    if not (
        envelope.get("schema_version") == "1.0"
        and envelope.get("command") == command
        and envelope.get("ok") is True
        and envelope.get("timed_out") is False
        and type(envelope.get("exit_code")) is int
        and envelope["exit_code"] == 0
        and isinstance(envelope.get("stdout"), str)
        and isinstance(envelope.get("stderr"), str)
        and "dry_run" not in envelope
    ):
        return "missing, invalid or unsuccessful exec fields"
    with (
        (attempt / "raw.stdout").open("rb") as source,
        (attempt / "payload.stdout").open("xb") as output,
        (attempt / "payload.stderr").open("xb") as errors,
    ):
        result = subprocess.run(
            ["jq", "-e", f"[({predicate})] == [true]"],
            stdin=source,
            stdout=output,
            stderr=errors,
            check=False,
            pass_fds=(lock_fd,),
        )
    return (
        ""
        if result.returncode == 0
        and (attempt / "payload.stdout").read_bytes() == b"true\n"
        else "command payload predicate did not yield true"
    )


def run_locked(
    root: Path, kind: str, operation: str, command: str, predicate: str, lock_fd: int
) -> int:
    subject = read_object(root / "subject.json")
    vm = subject.get("vm")
    if not isinstance(vm, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*", vm):
        raise ValueError("missing or invalid initialized VM identity")
    prior = sorted(
        path for path in root.iterdir() if re.fullmatch(r"[0-9]{6}", path.name)
    )
    for path in prior:
        try:
            receipt = read_object(path / "result.json")
            outcome = receipt.get("outcome")
            if outcome not in ("clean", "unavailable", "interrupted"):
                raise ValueError("unknown terminal outcome")
            if outcome != "clean":
                latch(root, f"{path.name}: prior {outcome} attempt")
        except (OSError, ValueError, UnicodeError) as error:
            latch(root, f"unfinished attempt: {path.name}: {error}")
    if (root / "unavailable").exists() and kind != "evidence":
        print("unavailable latch prevents scenario dispatch", file=sys.stderr)
        return UNAVAILABLE
    ordinal = int(prior[-1].name) + 1 if prior else 1
    if ordinal > 999999:
        raise ValueError("attempt ordinal exhausted")
    attempt = root / f"{ordinal:06d}"
    attempt.mkdir()
    # Explicit --vm wins over ambient VM/agent flags. No --connect is admitted.
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/resolve.rs
    argv = ["testanyware", "file", "exec", "--vm", vm, "--json", "--", command]
    started = time.monotonic_ns()
    write_json(
        attempt / "request.json",
        {
            "ordinal": ordinal,
            "vm": vm,
            "class": kind,
            "operation": operation,
            "command": command,
            "argv": argv,
            "payload_predicate": predicate,
            "started": timestamp(),
        },
    )
    cli_status: int | None = None
    interrupted = False
    emission_status = "not-attempted"
    try:
        with (
            (attempt / "raw.stdout").open("xb") as output,
            (attempt / "raw.stderr").open("xb") as errors,
        ):
            cli_status = subprocess.run(
                argv, stdout=output, stderr=errors, check=False, pass_fds=(lock_fd,)
            ).returncode
        (attempt / "cli.exit").write_text(f"{cli_status}\n")
        reason = validate_response(attempt, command, cli_status, predicate, lock_fd)
    except (OSError, ValueError, UnicodeError) as error:
        reason = str(error)
    except KeyboardInterrupt:
        reason = "interrupted exec; completion unavailable"
        interrupted = True
    if not reason:
        try:
            sys.stdout.buffer.write((attempt / "guest.stdout").read_bytes())
            sys.stdout.buffer.flush()
            emission_status = "flushed"
        except OSError as error:
            reason = f"stdout emission failed: {error}"
            emission_status = "failed"
            # Prevent a second buffered flush at interpreter exit (status 120).
            with open(os.devnull, "wb") as sink:
                os.dup2(sink.fileno(), sys.stdout.fileno())
        except KeyboardInterrupt:
            reason = "interrupted stdout emission; delivery unavailable"
            emission_status = "failed"
            interrupted = True
    if reason:
        latch(root, f"{attempt.name}: {reason}")
    write_json(
        attempt / "result.json",
        {
            "outcome": "interrupted"
            if interrupted
            else "unavailable"
            if reason
            else "clean",
            "reason": reason,
            "cli_status": cli_status,
            "emission_status": emission_status,
            "ended": timestamp(),
            "duration_ns": time.monotonic_ns() - started,
        },
    )
    if interrupted:
        signal.signal(signal.SIGINT, signal.SIG_DFL)
        signal.raise_signal(signal.SIGINT)
    if reason:
        print(f"guest exec unavailable ({attempt.name}): {reason}", file=sys.stderr)
        return UNAVAILABLE
    return 0


def run(root: Path, kind: str, operation: str, command: str, predicate: str) -> int:
    if kind not in {"read-poll", "one-shot", "evidence"}:
        raise ValueError("class must be read-poll, one-shot or evidence")
    if not operation.strip():
        raise ValueError("operation must name this call site")
    # Non-blocking lock covers the whole dispatch, including evidence collection.
    with (root / ".writer").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            latch(root, "competing evidence writer")
            return UNAVAILABLE
        # The CLI/validator keep this same lock if the adapter is killed. Do not
        # unlock explicitly: their inherited descriptors share its lifetime.
        return run_locked(root, kind, operation, command, predicate, lock.fileno())


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__,
        epilog=(
            "Internal shell-helper backend. init requires a new directory. "
            "run prints qualified guest stdout only; raw data and JSON receipts stay in ROOT. "
            "Exit 0: clean individual attempt (evidence collection does not clear an old latch); "
            "2: argument error (an identifiable initialized run root is latched); "
            "125: unavailable or invalid run values; SIGINT: interrupted. "
            "Every nonzero status is unavailable; do not retry or reset the root. "
            "Example: init .build/exec-evidence exact-vm; "
            "run .build/exec-evidence read-poll endpoint 'probe' '.stdout == \"ABSENT\"'. "
            "See scripts/vm-guest-exec-lib.sh and ORDERING-TRANSPORT-RESULTS.md."
        ),
    )
    commands = parser.add_subparsers(dest="action", required=True)
    init_parser = commands.add_parser(
        "init", help="create unused evidence root for one exact VM"
    )
    init_parser.add_argument("root", type=Path)
    init_parser.add_argument("vm")
    run_parser = commands.add_parser(
        "run", help="submit once; exit 125 means unavailable evidence"
    )
    run_parser.add_argument("root", type=Path)
    run_parser.add_argument("kind", choices=["read-poll", "one-shot", "evidence"])
    run_parser.add_argument(
        "operation", help="call-site identity retained in the request receipt"
    )
    run_parser.add_argument(
        "command", help="one exact guest command; no shell on the host"
    )
    run_parser.add_argument(
        "predicate", help="jq predicate on the complete envelope; exactly true"
    )
    try:
        args = parser.parse_args()
    except SystemExit as error:
        if error.code and len(sys.argv) > 2 and sys.argv[1] == "run":
            root = Path(sys.argv[2])
            if (root / "subject.json").is_file():
                latch(root, "invalid run arguments")
        raise
    root = cast(Path, args.root)
    try:
        if args.action == "init":
            return initialize(root, cast(str, args.vm))
        return run(
            root,
            cast(str, args.kind),
            cast(str, args.operation),
            cast(str, args.command),
            cast(str, args.predicate),
        )
    except (OSError, ValueError, UnicodeError) as error:
        print(f"guest evidence: {error}", file=sys.stderr)
        if args.action == "run" and root.is_dir():
            latch(root, str(error))
        return UNAVAILABLE


if __name__ == "__main__":
    sys.exit(main())
