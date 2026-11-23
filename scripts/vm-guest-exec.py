#!/usr/bin/env python3
"""Record single-attempt exec and CLI evidence in one VM writer domain."""

# pyright: strict
from __future__ import annotations

import argparse
import base64
import fcntl
import hashlib
import json
import os
import re
import signal
import stat
import subprocess
import sys
import time
import zlib
from datetime import UTC, datetime
from pathlib import Path
from typing import cast

import vm_exec_reads
from vm_capture_artifact import inspect_capture

UNAVAILABLE = 125
# Each stderr line below accompanies CLI status 0, but the attempt did not
# establish its result. The size wait expired or did not run, OCR repeated a
# failed request, or the guest did not confirm that it read the input.
# https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-vm/src/lifecycle.rs
# https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-vm/src/vnc_size_wait.rs
# https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-ocr-client/src/engine.rs
# https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/mod.rs
UNQUALIFIED_DIAGNOSTICS: dict[tuple[str, str | None], tuple[bytes, ...]] = {
    ("vm", "start"): (b"warning: VNC size wait:", b"VNC size wait skipped:"),
    ("screen", "find-text"): (b"testanyware: the Vision worker failed",),
    ("input", None): (
        b"warning: the guest gave no sign",
        b"warning: the guest connection ended before",
    ),
}


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
    root.mkdir(mode=0o700)  # Refuse reuse, overwrites and implicit parent creation.
    # The root can hold KOINE_VM_PASSWORD in argv, predicates and responses. The
    # umask can only narrow the mkdir mode, so no wider mode ever exists. chmod
    # sets the exact mode before the first write: only the owner can enter.
    os.chmod(root, 0o700)
    write_json(root / "subject.json", {"vm": vm})
    return 0


def inspect_file(path: Path) -> dict[str, object]:
    """Digest one regular non-symlink file whose identity stays stable while read."""
    before = os.lstat(path)
    if not stat.S_ISREG(before.st_mode):
        raise ValueError(f"expected a regular non-symlink file: {path}")
    descriptor = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
    try:
        opened = os.fstat(descriptor)
        digest = hashlib.sha256()
        count = 0
        while block := os.read(descriptor, 1 << 20):
            digest.update(block)
            count += len(block)
        after = os.fstat(descriptor)
    finally:
        os.close(descriptor)

    def identity(value: os.stat_result) -> tuple[int, ...]:
        return (
            value.st_dev,
            value.st_ino,
            value.st_size,
            value.st_mtime_ns,
            value.st_ctime_ns,
        )

    if (before.st_dev, before.st_ino) != (opened.st_dev, opened.st_ino):
        raise ValueError(f"file replaced while opening: {path}")
    if identity(opened) != identity(after) or count != after.st_size:
        raise ValueError(f"file changed while read: {path}")
    return {
        "path": str(path),
        "bytes": count,
        "sha256": digest.hexdigest(),
        "device": after.st_dev,
        "inode": after.st_ino,
        "mtime_ns": after.st_mtime_ns,
        "ctime_ns": after.st_ctime_ns,
    }


def upload_record(root: Path, ordinal: str, remote: str) -> dict[str, object]:
    """Return the qualified upload of REMOTE at ORDINAL, under the writer lock."""
    attempt = root / ordinal
    try:
        request = read_object(attempt / "request.json")
        result = read_object(attempt / "result.json")
        transfer = read_object(attempt / "transfer.json")
    except (OSError, ValueError, UnicodeError) as error:
        raise ValueError(
            f"{ordinal} does not name upload of {remote}: {error}"
        ) from None
    if not (
        request.get("transport") == "upload"
        and result.get("outcome") == "clean"
        and transfer.get("direction") == "upload"
        and transfer.get("remote") == remote
    ):
        raise ValueError(f"{ordinal} does not name upload of {remote}")
    return transfer


def exec_record_problem(envelope: dict[str, object]) -> str:
    """Name why an exec envelope is not a complete clean agent record."""
    # A legacy agent gives an unknown outcome, which never counts as success.
    # An incomplete stream is a prefix. The macOS projection turns a stream that
    # is not UTF-8 into empty text, so the exact bytes must decode.
    # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/docs/specs/guest-command-lifecycle.md
    if envelope.get("record") != "agent" or envelope.get("legacy_projection") != (
        "macos"
    ):
        return "exec reply is not a typed macOS agent record"
    outcome = envelope.get("outcome")
    if not (
        isinstance(outcome, dict)
        and set(cast(dict[str, object], outcome)) == {"kind", "exit_code"}
        and cast(dict[str, object], outcome)["kind"] == "exited"
        and type(cast(dict[str, object], outcome)["exit_code"]) is int
        and cast(dict[str, object], outcome)["exit_code"] == 0
    ):
        return "exec outcome is not a clean exit"
    evidence = envelope.get("evidence")
    if not isinstance(evidence, dict):
        return "exec record has no stream evidence"
    for name in ("stdout", "stderr"):
        stream = cast(dict[str, object], evidence).get(name)
        if not isinstance(stream, dict):
            return f"exec record has no {name} evidence"
        fields = cast(dict[str, object], stream)
        encoded = fields.get("base64")
        if fields.get("capture") != "complete" or not isinstance(encoded, str):
            return f"exec {name} capture is not complete"
        try:
            base64.b64decode(encoded, validate=True).decode("utf-8")
        except ValueError:
            return f"exec {name} bytes are not valid UTF-8"
    return ""


def diagnostic_problem(argv: list[str], stderr: bytes) -> str:
    """Name a stderr line that withdraws the result of a clean CLI status."""
    prefixes = UNQUALIFIED_DIAGNOSTICS.get(
        (argv[1], argv[2]), ()
    ) + UNQUALIFIED_DIAGNOSTICS.get((argv[1], None), ())
    for line in stderr.splitlines():
        if line.strip().startswith(prefixes):
            return f"CLI diagnostic withdraws the result: {line.strip()!r}"
    return ""


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
    for field in ("stdout", "stderr") if transport in {"exec", "read"} else ():
        value = envelope.get(field)
        if isinstance(value, str):
            (attempt / f"guest.{field}").write_bytes(value.encode("utf-8"))
    # v3.0.0 puts these fields at top level. CLI zero proves only a sound
    # transport and record, because a guest outcome never sets `ok` to false.
    # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/file.rs
    if cli_status != 0:
        return f"CLI exit {cli_status}"
    # Non-exec commands share only this base envelope; callers must validate the
    # actual command payload, then verify any artifact/downstream consequence.
    # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/output.rs
    if not (
        envelope.get("schema_version") == "1.0"
        and envelope.get("ok") is True
        and "dry_run" not in envelope
    ):
        return "missing, invalid or unsuccessful envelope fields"
    if transport in {"exec", "read"} and not (
        envelope.get("command") == command
        and envelope.get("timed_out") is False
        and type(envelope.get("exit_code")) is int
        and envelope["exit_code"] == 0
        and isinstance(envelope.get("stdout"), str)
        and isinstance(envelope.get("stderr"), str)
    ):
        return "missing, invalid or unsuccessful exec fields"
    if transport in {"exec", "read"}:
        problem = exec_record_problem(envelope)
        if problem:
            return problem
    if transport == "read":
        return ""  # run_locked parses the exact grammar of the checked read.
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


def cli_argv(
    arguments: list[str],
    vm: str,
    kind: str,
    *,
    checked_capture: bool = False,
    checked_transfer: bool = False,
) -> list[str]:
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
    if (family, action) == ("screen", "capture") and not checked_capture:
        raise ValueError("screen capture requires the checked capture backend")
    # Upload reports only the local size; download writes a caller path. The
    # checked transfer backend owns the identity checks and the output path.
    # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/file.rs
    if (family, action) in {("file", "upload"), ("file", "download")} and not (
        checked_transfer
    ):
        raise ValueError(f"file {action} requires the checked transfer backend")
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
        # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs
        if (family, action) not in collection_actions or any(
            arg.split("=", 1)[0] == "--open-menu" for arg in arguments
        ):
            raise ValueError("evidence class permits only collection and exact VM stop")
    # Lifecycle commands use positional IDs/--id, not ConnectionOptions. Bind
    # those explicitly; endpoint commands instead receive the pinned --vm.
    # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/main.rs
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
            if outcome not in ("clean", "state-failed", "unavailable", "interrupted"):
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
    elif transport == "capture":
        argv = []  # The exclusive attempt directory below owns the output path.
    elif transport in {"confirmation", "poll-step", "download"}:
        argv = []  # A download's exclusive attempt directory owns its output path.
    elif transport == "read":
        # The table owns every command that a checked read sends, and it admits
        # the evidence class only for a read that changes no guest state.
        command = vm_exec_reads.command(arguments[0], kind, arguments[1:])
        predicate = (
            f"checked read {arguments[0]}: exact grammar in scripts/vm_exec_reads.py"
        )
        argv = ["testanyware", "file", "exec", "--vm", vm, "--json", "--", command]
    elif transport == "upload":
        # The local path is absolute, so the CLI cannot read it as an option.
        argv = cli_argv(["file", "upload", *arguments], vm, kind, checked_transfer=True)
    else:
        # Explicit --vm wins over ambient VM/agent flags. No --connect is admitted.
        # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/resolve.rs
        argv = ["testanyware", "file", "exec", "--vm", vm, "--json", "--", command]
    expected: dict[str, object] | None = None
    if transport == "download" and len(arguments) == 2:
        expected = upload_record(root, arguments[1], arguments[0])
    ordinal = int(prior[-1].name) + 1 if prior else 1
    if ordinal > 999999:
        raise ValueError("attempt ordinal exhausted")
    attempt = root / f"{ordinal:06d}"
    attempt.mkdir()
    artifact_path = (attempt / "screen.png").absolute()
    download_path = (attempt / "download.bin").absolute()
    local_before: dict[str, object] | None = None
    pre_dispatch = ""
    if transport == "upload":
        # The tagged client stats the file, then streams it, and reports that
        # size as `bytes`. Digest it here, under the lock, before dispatch.
        # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-agent-client/src/lib.rs
        try:
            local_before = inspect_file(Path(arguments[0]))
        except (OSError, ValueError) as error:
            pre_dispatch = f"upload input unavailable: {error}"
        size = local_before["bytes"] if local_before else -1
        predicate = (
            'keys == ["bytes", "local", "ok", "remote", "schema_version"] and '
            f".local == {json.dumps(arguments[0])} and "
            f".remote == {json.dumps(arguments[1])} and .bytes == {size}"
        )
    if transport == "download":
        # The tagged client streams into a hidden sibling of download.bin. It
        # deletes that file on a failure, SIGINT or SIGTERM, so the failed bytes
        # are then unavailable. SIGKILL leaves the file, and this backend keeps it.
        # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-agent-client/src/lib.rs#L559-L589
        argv = cli_argv(
            ["file", "download", arguments[0], str(download_path)],
            vm,
            kind,
            checked_transfer=True,
        )
        predicate = (
            'keys == ["bytes", "local", "ok", "remote", "schema_version"] and '
            f".remote == {json.dumps(arguments[0])} and "
            f".local == {json.dumps(str(download_path))} and "
            '(.bytes | type == "number" and floor == . and . >= 0)'
        )
    if transport == "capture":
        capture_args = ["screen", "capture"]
        if arguments:
            capture_args += ["--region", arguments[0]]
        argv = cli_argv(
            [*capture_args, "-o", str(artifact_path)], vm, kind, checked_capture=True
        )
        # Validate actual capture fields and chosen path, not a constant predicate.
        # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/screen.rs
        predicate = (
            f".path == {json.dumps(str(artifact_path))} and "
            'all(.width, .height; type == "number" and floor == . and . > 0 and . <= 4294967295)'
        )
        if arguments:
            _, _, width, height = map(int, arguments[0].split(","))
            predicate += f" and .width == {width} and .height == {height}"
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
            **(
                {"read": arguments[0], "read_arguments": arguments[1:]}
                if transport == "read"
                else {}
            ),
            "argv": argv,
            "payload_predicate": predicate,
            "started": timestamp(),
            **(
                {
                    "poll_phase": command,
                    "state_predicate": predicate,
                    "local_status": int(arguments[0]),
                }
                if transport == "poll-step"
                else {}
            ),
        },
    )
    cli_status: int | None = None
    interrupted = False
    local_signal_status = 0
    state_failed = False
    emission_status = "not-attempted"
    reason = command if transport == "confirmation" else ""
    if local_before is not None:
        write_json(attempt / "local-before.json", local_before)
    try:
        if pre_dispatch:
            reason = pre_dispatch
        elif transport == "poll-step":
            local_status = int(arguments[0])
            state_failed = command == "exhausted"
            if state_failed:
                reason = "clean window poll exhausted"
            elif command == "sleep" or local_status not in (0, 1):
                reason = f"window poll {command} exit {local_status}"
                if 128 < local_status <= 192:
                    interrupted = True
                    local_signal_status = local_status
        elif transport == "confirmation":
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
            if not reason and transport == "cli":
                reason = diagnostic_problem(argv, (attempt / "raw.stderr").read_bytes())
            if not reason and transport == "read":
                envelope = read_object(attempt / "raw.stdout")
                try:
                    record = vm_exec_reads.parse(
                        arguments[0], cast(str, envelope["stdout"]), arguments[1:]
                    )
                except vm_exec_reads.ReadError as error:
                    reason = f"checked read {arguments[0]} grammar: {error}"
                else:
                    write_json(attempt / "read.json", record)
            if not reason and transport == "capture":
                envelope = read_object(attempt / "raw.stdout")
                artifact = inspect_capture(
                    artifact_path,
                    int(cast(int, envelope["width"])),
                    int(cast(int, envelope["height"])),
                )
                write_json(attempt / "artifact.json", artifact)
            if not reason and transport == "upload" and local_before is not None:
                local_after = inspect_file(Path(arguments[0]))
                write_json(attempt / "local-after.json", local_after)
                if local_after != local_before:
                    reason = "upload input changed during the transfer"
                else:
                    transfer = {
                        "direction": "upload",
                        "local": arguments[0],
                        "remote": arguments[1],
                        "bytes": local_before["bytes"],
                        "sha256": local_before["sha256"],
                    }
                    write_json(attempt / "transfer.json", transfer)
            if not reason and transport == "download":
                envelope = read_object(attempt / "raw.stdout")
                copy = inspect_file(download_path)
                if copy["bytes"] != envelope["bytes"]:
                    reason = "downloaded file size differs from the receipt"
                elif expected is not None and (
                    copy["bytes"],
                    copy["sha256"],
                ) != (expected["bytes"], expected["sha256"]):
                    reason = f"downloaded bytes differ from upload {arguments[1]}"
                else:
                    transfer = {
                        "direction": "download",
                        "remote": arguments[0],
                        "local": str(download_path),
                        "bytes": copy["bytes"],
                        "sha256": copy["sha256"],
                        "matches_upload": arguments[1] if expected else None,
                    }
                    write_json(attempt / "transfer.json", transfer)
    except (OSError, ValueError, UnicodeError, zlib.error) as error:
        reason = str(error)
    except KeyboardInterrupt:
        reason = "interrupted transport; completion unavailable"
        interrupted = True
    if not reason and transport != "poll-step":
        try:
            if transport == "read":
                # One compact line of the parsed record; the raw bytes stay.
                record = read_object(attempt / "read.json")
                data = (json.dumps(record, ensure_ascii=True) + "\n").encode("ascii")
            else:
                stream_name = "guest.stdout" if transport == "exec" else "raw.stdout"
                data = (attempt / stream_name).read_bytes()
            sys.stdout.buffer.write(data)
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
            else "state-failed"
            if state_failed
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
    if local_signal_status:
        return local_signal_status
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
    if transport == "capture" and not (
        kind in {"read-poll", "evidence"}
        and (
            not arguments
            or (
                len(arguments) == 1
                and re.fullmatch(r"[0-9]{1,10}(,[0-9]{1,10}){3}", arguments[0])
                and all(int(part) <= 4294967295 for part in arguments[0].split(","))
                and all(int(part) > 0 for part in arguments[0].split(",")[2:])
            )
        )
    ):
        raise ValueError(
            "expected read-poll|evidence capture with optional X,Y,WIDTH,HEIGHT"
        )
    if transport == "upload" and not (
        kind == "one-shot"
        and len(arguments or []) == 2
        and Path((arguments or ["", ""])[0]).is_absolute()
        and (arguments or ["", ""])[1].startswith("/")
    ):
        raise ValueError("expected one-shot upload of an absolute LOCAL to /REMOTE")
    if transport == "download" and not (
        kind in {"read-poll", "evidence"}
        and len(arguments or []) in {1, 2}
        and (arguments or [""])[0].startswith("/")
        and (
            len(arguments or []) == 1
            or re.fullmatch(r"[0-9]{6}", (arguments or ["", ""])[1]) is not None
        )
    ):
        raise ValueError("expected read-poll|evidence download of /REMOTE [ORDINAL]")
    if transport == "exec" and kind == "evidence":
        # The adapter cannot know whether a free guest command sends input, so
        # collection after a latch uses only the checked read-only reads.
        raise ValueError("evidence-class exec requires a checked read-only read")
    # The read table decides which class each name admits: a read takes
    # read-poll or evidence, and a checked submission takes only one-shot.
    if transport == "read" and not (
        kind in {"read-poll", "evidence", "one-shot"} and len(arguments or []) >= 1
    ):
        raise ValueError("expected a checked read NAME [ARGUMENT]")
    if transport == "confirmation" and not command.strip():
        raise ValueError("failed confirmation requires a reason")
    if transport == "poll-step" and not (
        command in {"state", "sleep", "exhausted"}
        and predicate.strip()
        and len(arguments or []) == 1
        and (arguments or [""])[0].isdigit()
        and 0 <= int((arguments or [""])[0]) <= 255
        and (command != "exhausted" or arguments == ["1"])
        and (command != "sleep" or arguments != ["0"])
    ):
        raise ValueError("expected a poll predicate, phase and shell status")
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
            "poll-step records a local window-poll decision or failure without dispatch. "
            "upload digests its local file before and after one dispatch; download writes "
            "a unique copy and compares a named upload record. "
            "read runs one checked guest read or submission from scripts/vm_exec_reads.py "
            "and prints its parsed record; run refuses the evidence class, which only checked reads admit. "
            "Exit 0: clean individual attempt (evidence collection does not clear an old latch); "
            "2: argument error (an identifiable initialized evidence root is latched); "
            "125: state failure, unavailable evidence or invalid run values; "
            "129-192: local poll interruption; SIGINT: interrupted backend. "
            "Every nonzero status stops scenario input; do not retry or reset the root. "
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
    poll_parser = commands.add_parser(
        "poll-step", help="record local window-poll state, failed sleep or exhaustion"
    )
    poll_parser.add_argument("root", type=Path)
    poll_parser.add_argument("operation")
    poll_parser.add_argument("phase", choices=["state", "sleep", "exhausted"])
    poll_parser.add_argument("status", type=int)
    poll_parser.add_argument("predicate")
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
    capture_parser = commands.add_parser(
        "capture",
        help="capture once to a unique path; validate complete PNG under the writer lock",
    )
    capture_parser.add_argument("root", type=Path)
    capture_parser.add_argument("kind", choices=["read-poll", "evidence"])
    capture_parser.add_argument("operation")
    capture_parser.add_argument("region", nargs="?")
    upload_parser = commands.add_parser(
        "upload",
        help="upload once; digest the local file under the writer lock before and after",
    )
    upload_parser.add_argument("root", type=Path)
    upload_parser.add_argument("kind", choices=["one-shot"])
    upload_parser.add_argument("operation")
    upload_parser.add_argument("local", type=Path)
    upload_parser.add_argument("remote")
    download_parser = commands.add_parser(
        "download",
        help="download once to a unique path; compare an upload record if named",
    )
    download_parser.add_argument("root", type=Path)
    download_parser.add_argument("kind", choices=["read-poll", "evidence"])
    download_parser.add_argument("operation")
    download_parser.add_argument("remote")
    download_parser.add_argument("upload", nargs="?")
    read_parser = commands.add_parser(
        "read",
        help="one checked guest read or submission; emit its parsed record as one JSON line",
    )
    read_parser.add_argument("root", type=Path)
    read_parser.add_argument("kind", choices=["read-poll", "evidence", "one-shot"])
    read_parser.add_argument("operation")
    read_parser.add_argument("name", choices=sorted(vm_exec_reads.READS))
    read_parser.add_argument("arguments", nargs="*")
    try:
        args = parser.parse_args()
    except SystemExit as error:
        if (
            error.code
            and len(sys.argv) > 2
            and sys.argv[1]
            in {
                "run",
                "cli",
                "capture",
                "upload",
                "download",
                "read",
                "check",
                "fail",
                "poll-step",
            }
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
        if args.action == "poll-step":
            return run(
                root,
                "evidence",
                cast(str, args.operation),
                cast(str, args.phase),
                cast(str, args.predicate),
                "poll-step",
                [str(args.status)],
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
        if args.action == "capture":
            region = cast(str | None, args.region)
            return run(
                root,
                cast(str, args.kind),
                cast(str, args.operation),
                "",
                "",
                "capture",
                [region] if region is not None else [],
            )
        if args.action == "upload":
            return run(
                root,
                cast(str, args.kind),
                cast(str, args.operation),
                "",
                "",
                "upload",
                [str(cast(Path, args.local).absolute()), cast(str, args.remote)],
            )
        if args.action == "read":
            return run(
                root,
                cast(str, args.kind),
                cast(str, args.operation),
                "",
                "",
                "read",
                [cast(str, args.name), *cast(list[str], args.arguments)],
            )
        if args.action == "download":
            upload = cast(str | None, args.upload)
            return run(
                root,
                cast(str, args.kind),
                cast(str, args.operation),
                "",
                "",
                "download",
                [cast(str, args.remote), *([upload] if upload is not None else [])],
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
