"""Synthetic CLI only: no endpoint, VM, guest or golden image is contacted.

The payload shapes follow the tagged v3.0.0 handlers in
cli-rs/crates/testanyware-cli/src/commands/file.rs and commands/vm.rs.
A directory stands in for the guest file system and a file for the clone list.
"""

from __future__ import annotations

import base64
import hashlib
import json
import os
import plistlib
import signal
import sys
import time
from pathlib import Path


def guest_path(remote: str) -> Path:
    return Path(os.environ["lifecycle_guest"]) / remote.lstrip("/")


def running() -> list[str]:
    state = Path(os.environ["lifecycle_state"])
    return state.read_text().split() if state.exists() else []


def set_running(names: list[str]) -> None:
    Path(os.environ["lifecycle_state"]).write_text("".join(f"{n}\n" for n in names))


def upload(args: list[str], mode: str) -> dict[str, object]:
    local, remote = args[2], args[3]
    data = Path(local).read_bytes()
    target = guest_path(remote)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data[: len(data) // 2] if mode == "upload-short" else data)
    if mode == "upload-mutate":
        with Path(local).open("ab") as stream:
            stream.write(b"changed during the transfer\n")
    response: dict[str, object] = {"local": local, "remote": remote, "bytes": len(data)}
    if mode == "upload-bytes":
        response["bytes"] = len(data) + 1
    elif mode == "upload-path":
        response["remote"] = remote + "-other"
    return response


def download(args: list[str], mode: str) -> dict[str, object]:
    remote, local = args[2], args[3]
    data = guest_path(remote).read_bytes()
    if mode == "download-corrupt":
        data = bytes([data[0] ^ 1]) + data[1:] if data else b"x"
    target = Path(local)
    if mode in {"download-stream-error", "download-killed"}:
        # The tagged client streams into `.NAME.testanyware-PID.SEQ.tmp` and
        # deletes it on a failure. SIGKILL skips that deletion.
        # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-agent-client/src/lib.rs#L559-L589
        partial = target.with_name(f".{target.name}.testanyware-{os.getpid()}.0.tmp")
        partial.write_bytes(data[: max(1, len(data) // 2)])
        if mode == "download-killed":
            os.kill(os.getpid(), signal.SIGKILL)
        partial.unlink()
    elif mode == "download-symlink":
        other = target.with_name("elsewhere")
        other.write_bytes(data)
        target.symlink_to(other)
    elif mode != "download-missing":
        # The tagged client renames a complete sibling temporary file into place.
        partial = target.with_name(target.name + ".fixture-temporary")
        partial.write_bytes(data)
        partial.rename(target)
    response: dict[str, object] = {"remote": remote, "local": local, "bytes": len(data)}
    if mode == "download-bytes":
        response["bytes"] = len(data) + 1
    elif mode == "download-path":
        response["local"] = local + "-other"
    return response


def start(args: list[str], mode: str) -> dict[str, object]:
    vm = args[args.index("--id") + 1]
    base = args[args.index("--base") + 1]
    set_running([*running(), vm])
    # The tagged start writes the clone's spec once, where `--vm` resolves it.
    if os.environ.get("XDG_STATE_HOME") and mode != "start-no-spec":
        specs = Path(os.environ["XDG_STATE_HOME"], "testanyware", "vms")
        specs.mkdir(parents=True, exist_ok=True)
        agent = {"host": "192.0.2.4", "port": 8648}
        spec = {"vnc": {"host": "127.0.0.1", "port": 5901}, "agent": agent}
        (specs / f"{vm}.json").write_text(json.dumps({**spec, "platform": "macos"}))
    response: dict[str, object] = {
        "id": "other-vm" if mode == "start-id" else vm,
        "platform": "macos",
        "base": base + "-other" if mode == "start-base" else base,
        "vnc": {"host": "127.0.0.1", "port": 0 if mode == "start-port" else 5901},
        "agent": None if mode == "start-agent" else {"host": "192.0.2.4", "port": 8648},
        "spec_path": f"/fixture/vms/{vm}.json",
        "meta_path": f"/fixture/vms/{vm}.meta.json",
    }
    if mode == "start-tpm":
        response["tpm"] = {"attached": False, "reason": "guest_does_not_need_one"}
    elif mode == "start-tpm-invalid":
        response["tpm"] = {"attached": False}
    return response


def stop(args: list[str], mode: str) -> dict[str, object]:
    vm = args[2]
    if mode != "stop-keeps":
        set_running([name for name in running() if name != vm])
        if os.environ.get("XDG_STATE_HOME"):
            Path(
                os.environ["XDG_STATE_HOME"], "testanyware", "vms", f"{vm}.json"
            ).unlink(missing_ok=True)
    return {"id": vm, "stopped": mode != "stop-false"}


def inventory(mode: str) -> dict[str, object]:
    names = running()
    if mode == "list-duplicate":
        names = names + names
    items: list[dict[str, object]] = [
        {
            "kind": "golden",
            "name": "testanyware-golden-macos-27",
            "platform": "macos",
            "backend": "tart",
            "pid": None,
            "vnc": None,
            "agent": None,
        }
    ]
    for name in names:
        items.append(
            {
                "kind": "running",
                "name": name,
                "platform": "macos",
                "backend": "tart",
                "pid": "77" if mode == "list-pid" else 77,
                "vnc": "127.0.0.1:5901",
                "agent": "192.0.2.4:8648",
            }
        )
    if mode == "list-field":
        del items[0]["agent"]
    response: dict[str, object] = {
        "items": items,
        "returned": len(items),
        "total": len(items),
        "truncated": False,
    }
    if mode == "list-truncated":
        response.update(total=len(items) + 1, truncated=True)
    return response


def installed_text() -> str:
    """The exact rows of the installed inventory, from a local directory."""
    bundle = Path(os.environ["guest_bundle"])
    files: list[str] = []
    links: list[str] = []
    for path in bundle.rglob("*"):
        name = f"./{path.relative_to(bundle)}"
        if path.is_symlink():
            links.append(f"{name} -> {os.readlink(path)}")
        elif path.is_file():
            files.append(f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {name}")
    return "\n".join([*sorted(files), *sorted(links), "KOINE_INVENTORY_COMPLETE"])


def defaults_text() -> str:
    """Every section of the defaults read. One key can be present in the first."""
    domain, managed = "dev.antony.Koine", "/Library/Managed Preferences"
    key = os.environ.get("guest_defaults_key")
    empty = plistlib.dumps({}).decode().strip()
    first = plistlib.dumps({key: True}).decode().strip() if key else empty
    rows = [f"KOINE-DOMAIN {domain} any", first]
    for section in (f"{domain} current", "-g any", "-g current"):
        rows += [f"KOINE-DOMAIN {section}", empty]
    for name in (f"{domain}.plist", ".GlobalPreferences.plist"):
        rows += [
            f"KOINE-ABSENT {managed}/{name}",
            f"KOINE-ABSENT {managed}/admin/{name}",
        ]
    for path in (
        f"/Library/Preferences/{domain}",
        f"/Library/Preferences/Network/{domain}",
        "/Library/Preferences/.GlobalPreferences",
        "/Library/Preferences/Network/.GlobalPreferences",
    ):
        rows += [f"KOINE-ANY-USER {path}", empty]
    return "\n".join([*rows, "KOINE-DEFAULTS-COMPLETE"])


def process_text() -> str:
    if os.environ.get("guest_process") == "none":
        return "NONE"
    executable = "/Applications/Koine.app/Contents/MacOS/Koine"
    arguments = os.environ.get("guest_arguments", executable)
    start = "Mon Nov 23 10:00:00 2026"
    return (
        f"KOINE-SELECTED 501\n  501 {start} {executable}\n---\n"
        f"  501 {start} {arguments}"
    )


def exec_read(command: str) -> tuple[str, str]:
    """The name and the exact guest text of one checked read."""
    if command == "sw_vers; uname -m":
        version = os.environ.get("guest_version", "27.0.1")
        build = os.environ.get("guest_build", "26A434")
        return "system", (
            f"ProductName:\t\tmacOS\nProductVersion:\t\t{version}\n"
            f"BuildVersion:\t\t{build}\narm64"
        )
    if command == "spctl --status":
        return (
            "gatekeeper",
            f"assessments {os.environ.get('guest_gatekeeper', 'enabled')}",
        )
    if "KOINE_INVENTORY_COMPLETE" in command:
        return "inventory", installed_text()
    if "KOINE-DEFAULTS-COMPLETE" in command:
        return "defaults", defaults_text()
    if "TextEdit.app" in command:
        return "textedit", "NONE"
    if "pgrep -f" in command:
        return "process", process_text()
    return "other", ""


def guest_exec(args: list[str]) -> dict[str, object]:
    command = args[-1]
    name, stdout = exec_read(command)
    failed = name in os.environ.get("guest_fail", "").split(",")
    guest_stdout = "" if failed else stdout
    guest_stderr = "synthetic guest failure" if failed else ""
    return {
        "command": command,
        "exit_code": 1 if failed else 0,
        "timed_out": False,
        "stdout": guest_stdout,
        "stderr": guest_stderr,
        "exec_id": "synthetic-exec",
        "record": "agent",
        "legacy_projection": "macos",
        "outcome": {"kind": "exited", "exit_code": 1 if failed else 0},
        "evidence": {
            "stdout": stream_evidence(guest_stdout),
            "stderr": stream_evidence(guest_stderr),
        },
    }


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


def main() -> int:
    args = sys.argv[1:]
    with Path(os.environ["lifecycle_calls"]).open("a") as stream:
        stream.write(json.dumps(args) + "\n")
    print("synthetic lifecycle diagnostic", file=sys.stderr)
    mode = os.environ.get("lifecycle_mode", "clean")
    exit_status = int(os.environ.get("lifecycle_exit", "0"))
    block = os.environ.get("lifecycle_block") == "1"
    # lifecycle_only=stop or list applies the fault to that one vm command.
    only = os.environ.get("lifecycle_only")
    if only and args[:2] != ["vm", only]:
        mode, exit_status, block = "clean", 0, False
    if block:
        if os.environ.get("lifecycle_ignore_term") == "1":
            signal.signal(signal.SIGTERM, signal.SIG_IGN)
        ready = Path(os.environ["lifecycle_ready"])
        ready.touch()
        # The bound ends a blocked call that a failed control never released.
        end = time.monotonic() + 30
        while (
            not ready.with_name(ready.name + ".release").exists()
            and time.monotonic() < end
        ):
            time.sleep(0.02)
    command = tuple(args[:2])
    payload: dict[str, object]
    if command == ("file", "upload"):
        payload = upload(args, mode)
    elif command == ("file", "download"):
        payload = download(args, mode)
    elif command == ("vm", "start"):
        payload = start(args, mode)
    elif command == ("vm", "stop"):
        payload = stop(args, mode)
    elif command == ("vm", "list"):
        payload = inventory(mode)
    elif command == ("file", "exec"):
        payload = guest_exec(args)
    else:
        payload = {"key": "return", "modifiers": []}
    response: dict[str, object] = {"schema_version": "1.0", "ok": True, **payload}
    if mode == "extra-field":
        response["note"] = "unexpected field"
    elif mode == "dry-run":
        response["dry_run"] = False
    elif mode in {"error", "download-stream-error"}:
        response = {
            "schema_version": "1.0",
            "ok": False,
            "code": "IO_ERROR",
            "message": "synthetic failure",
        }
    if mode == "partial":
        print('{"schema_version":')
    else:
        print(json.dumps(response))
    return exit_status


if __name__ == "__main__":
    sys.exit(main())
