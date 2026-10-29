#!/usr/bin/env python3
"""Record single-attempt exec and CLI evidence in one VM writer domain."""

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


def refuse(root: Path, reason: str) -> int:
    latch(root, reason)
    record = (
        json.dumps(
            {
                "source": "backend",
                "at": timestamp(),
                "arguments": sys.argv[1:],
                "reason": reason,
            },
            ensure_ascii=True,
        )
        + "\n"
    ).encode("utf-8")
    # Refused contenders cannot acquire the writer lock. Append one escaped
    # record in one write, independently of dispatched-attempt ordinals.
    with (root / "refusals.jsonl").open("ab", buffering=0) as stream:
        if stream.write(record) != len(record):
            raise OSError("incomplete refusal record")
        os.fsync(stream.fileno())
    print(f"guest evidence refused: {reason}", file=sys.stderr)
    return UNAVAILABLE


def initialize(root: Path, vm: str) -> int:
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*", vm):
        raise ValueError("expected an exact plain VM identity")
    root.mkdir()  # Refuse reuse, overwrites and implicit parent creation.
    write_json(root / "subject.json", {"vm": vm})
    return 0


def validate_response(
    attempt: Path,
    command: str,
    cli_status: int,
    predicate: str,
    lock_fd: int,
    transport: str = "exec",
) -> str:
    try:
        envelope = read_object(attempt / "raw.stdout")
    except (ValueError, UnicodeError) as error:
        return f"invalid exec envelope: {error}"
    # Preserve supplied guest streams even on failure; they are not qualified output.
    for field in ("stdout", "stderr") if transport == "exec" else ():
        value = envelope.get(field)
        if isinstance(value, str):
            (attempt / f"guest.{field}").write_bytes(value.encode("utf-8"))
    # v2.7.0 puts these fields at top level; CLI zero only proves clean spawn.
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/file.rs
    if cli_status != 0:
        return f"CLI exit {cli_status}"
    # Non-exec commands share only this base envelope; callers must validate the
    # actual command payload, then verify any artifact/downstream consequence.
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/output.rs
    if not (
        envelope.get("schema_version") == "1.0"
        and envelope.get("ok") is True
        and "dry_run" not in envelope
    ):
        return "missing, invalid or unsuccessful envelope fields"
    if transport == "exec" and not (
        envelope.get("command") == command
        and envelope.get("timed_out") is False
        and type(envelope.get("exit_code")) is int
        and envelope["exit_code"] == 0
        and isinstance(envelope.get("stdout"), str)
        and isinstance(envelope.get("stderr"), str)
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


def cli_argv(arguments: list[str], vm: str, kind: str) -> list[str]:
    if arguments[:1] == ["--"]:
        arguments = arguments[1:]
    if "--" in arguments:
        raise ValueError("embedded option terminator would bypass pinned CLI flags")
    forbidden = {"--connect", "--vm", "--agent", "--vnc", "--json", "--dry-run", "--id"}
    if arguments[:2] == ["vm", "start"]:
        forbidden.update({"--viewer", "--keep-on-failure"})
    else:
        forbidden.add("--platform")
    if any(arg.split("=", 1)[0] in forbidden for arg in arguments):
        raise ValueError("caller cannot override VM, output mode or live execution")
    if len(arguments) < 2:
        raise ValueError("expected a supported TestAnyware command and subcommand")
    family, action = arguments[:2]
    if kind == "evidence":
        collection_actions = {
            ("agent", "windows"),
            ("agent", "snapshot"),
            ("screen", "capture"),
            ("screen", "size"),
            ("file", "download"),
            ("vm", "list"),
            ("vm", "stop"),
        }
        # Snapshot's --open-menu sends VNC clicks before reading the tree.
        # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs
        if (family, action) not in collection_actions or any(
            arg.split("=", 1)[0] == "--open-menu" for arg in arguments
        ):
            raise ValueError("evidence class permits only collection and exact VM stop")
    # Lifecycle commands use positional IDs/--id, not ConnectionOptions. Bind
    # those explicitly; endpoint commands instead receive the pinned --vm.
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/main.rs
    if family == "vm":
        if action == "start":
            return ["testanyware", *arguments, "--id", vm, "--json"]
        if action == "stop" and arguments[2:] == [vm]:
            return ["testanyware", *arguments, "--json"]
        if action == "list":
            return ["testanyware", *arguments, "--json"]
        raise ValueError("expected pinned vm stop, vm start or vm list")
    if family not in {"agent", "input", "screen", "file"} or (
        family == "file" and action not in {"upload", "download"}
    ):
        raise ValueError("unsupported non-exec transport; use run for guest exec")
    return ["testanyware", *arguments, "--vm", vm, "--json"]


def run_locked(
    root: Path,
    kind: str,
    operation: str,
    command: str,
    predicate: str,
    lock_fd: int,
    transport: str,
    arguments: list[str],
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
        return refuse(root, "unavailable latch prevents scenario dispatch")
    if transport == "check":
        return 0  # Inspection is not a reservation for a later unlocked input.
    if transport == "cli":
        argv = cli_argv(arguments, vm, kind)
    elif transport == "confirmation":
        argv = []
    else:
        # Explicit --vm wins over ambient VM/agent flags. No --connect is admitted.
        # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/resolve.rs
        argv = ["testanyware", "file", "exec", "--vm", vm, "--json", "--", command]
    ordinal = int(prior[-1].name) + 1 if prior else 1
    if ordinal > 999999:
        raise ValueError("attempt ordinal exhausted")
    attempt = root / f"{ordinal:06d}"
    attempt.mkdir()
    started = time.monotonic_ns()
    write_json(
        attempt / "request.json",
        {
            "ordinal": ordinal,
            "vm": vm,
            "class": kind,
            "operation": operation,
            "transport": transport,
            "command": command,
            "reason": command if transport == "confirmation" else "",
            "argv": argv,
            "payload_predicate": predicate,
            "started": timestamp(),
        },
    )
    cli_status: int | None = None
    interrupted = False
    emission_status = "not-attempted"
    reason = command if transport == "confirmation" else ""
    try:
        if transport == "confirmation":
            latch(root, f"{attempt.name}: {reason}")
        else:
            with (
                (attempt / "raw.stdout").open("xb") as output,
                (attempt / "raw.stderr").open("xb") as errors,
            ):
                cli_status = subprocess.run(
                    argv, stdout=output, stderr=errors, check=False, pass_fds=(lock_fd,)
                ).returncode
            (attempt / "cli.exit").write_text(f"{cli_status}\n")
            reason = validate_response(
                attempt, command, cli_status, predicate, lock_fd, transport
            )
    except (OSError, ValueError, UnicodeError) as error:
        reason = str(error)
    except KeyboardInterrupt:
        reason = "interrupted transport; completion unavailable"
        interrupted = True
    if not reason:
        try:
            stream_name = "guest.stdout" if transport == "exec" else "raw.stdout"
            sys.stdout.buffer.write((attempt / stream_name).read_bytes())
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
        print(f"guest evidence unavailable ({attempt.name}): {reason}", file=sys.stderr)
        return UNAVAILABLE
    return 0


def run(
    root: Path,
    kind: str,
    operation: str,
    command: str,
    predicate: str,
    transport: str = "exec",
    arguments: list[str] | None = None,
) -> int:
    if kind not in {"read-poll", "one-shot", "evidence"}:
        raise ValueError("class must be read-poll, one-shot or evidence")
    if not operation.strip():
        raise ValueError("operation must name this call site")
    if transport == "confirmation" and not command.strip():
        raise ValueError("failed confirmation requires a reason")
    # Non-blocking lock covers the whole dispatch, including evidence collection.
    with (root / ".writer").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return refuse(root, "competing evidence writer")
        # The CLI/validator keep this same lock if the adapter is killed. Do not
        # unlock explicitly: their inherited descriptors share its lifetime.
        return run_locked(
            root,
            kind,
            operation,
            command,
            predicate,
            lock.fileno(),
            transport,
            arguments or [],
        )


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__,
        epilog=(
            "Internal shell-helper backend. init requires a new directory. "
            "run prints qualified guest stdout only; raw data and JSON receipts stay in ROOT. "
            "cli prints qualified raw JSON; check inspects eligibility without reserving input; "
            "fail records a failed confirmation and always returns nonzero. "
            "Exit 0: clean individual attempt (evidence collection does not clear an old latch); "
            "2: argument error (an identifiable initialized evidence root is latched); "
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
    check_parser = commands.add_parser(
        "check", help="inspect eligibility; does not reserve input"
    )
    check_parser.add_argument("root", type=Path)
    fail_parser = commands.add_parser(
        "fail", help="record failed downstream confirmation; always 125"
    )
    fail_parser.add_argument("root", type=Path)
    fail_parser.add_argument("operation")
    fail_parser.add_argument("reason")
    cli_parser = commands.add_parser(
        "cli", help="one non-exec TestAnyware attempt; emits raw JSON"
    )
    cli_parser.add_argument("root", type=Path)
    cli_parser.add_argument("kind", choices=["read-poll", "one-shot", "evidence"])
    cli_parser.add_argument("operation")
    cli_parser.add_argument(
        "predicate", help="required command-specific jq payload predicate"
    )
    cli_parser.add_argument(
        "arguments", nargs=argparse.REMAINDER, help="-- command subcommand args"
    )
    try:
        args = parser.parse_args()
    except SystemExit as error:
        if (
            error.code
            and len(sys.argv) > 2
            and sys.argv[1] in {"run", "cli", "check", "fail"}
        ):
            root = Path(sys.argv[2])
            if (root / "subject.json").is_file():
                refuse(root, "invalid evidence arguments")
        raise
    root = cast(Path, args.root)
    try:
        if args.action == "init":
            return initialize(root, cast(str, args.vm))
        if args.action == "check":
            return run(root, "read-poll", "eligibility", "", "", "check")
        if args.action == "fail":
            return run(
                root,
                "evidence",
                cast(str, args.operation),
                cast(str, args.reason),
                "",
                "confirmation",
            )
        if args.action == "cli":
            return run(
                root,
                cast(str, args.kind),
                cast(str, args.operation),
                "",
                cast(str, args.predicate),
                "cli",
                cast(list[str], args.arguments),
            )
        return run(
            root,
            cast(str, args.kind),
            cast(str, args.operation),
            cast(str, args.command),
            cast(str, args.predicate),
        )
    except (OSError, ValueError, UnicodeError) as error:
        print(f"guest evidence: {error}", file=sys.stderr)
        if args.action != "init" and root.is_dir():
            return refuse(root, str(error))
        return UNAVAILABLE


if __name__ == "__main__":
    sys.exit(main())
