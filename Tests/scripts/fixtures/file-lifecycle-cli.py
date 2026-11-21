"""Synthetic CLI only: no endpoint, VM, guest or golden image is contacted.

The payload shapes follow the tagged v2.7.0 handlers in
cli-rs/crates/testanyware-cli/src/commands/file.rs and commands/vm.rs.
A directory stands in for the guest file system and a file for the clone list.
"""

from __future__ import annotations

import json
import os
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
    if mode == "download-symlink":
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


def main() -> int:
    args = sys.argv[1:]
    with Path(os.environ["lifecycle_calls"]).open("a") as stream:
        stream.write(json.dumps(args) + "\n")
    print("synthetic lifecycle diagnostic", file=sys.stderr)
    mode = os.environ.get("lifecycle_mode", "clean")
    if os.environ.get("lifecycle_block") == "1":
        ready = Path(os.environ["lifecycle_ready"])
        ready.touch()
        while not ready.with_name(ready.name + ".release").exists():
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
    else:
        payload = {"key": "return", "modifiers": []}
    response: dict[str, object] = {"schema_version": "1.0", "ok": True, **payload}
    if mode == "extra-field":
        response["note"] = "unexpected field"
    elif mode == "dry-run":
        response["dry_run"] = False
    elif mode == "error":
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
    return int(os.environ.get("lifecycle_exit", "0"))


if __name__ == "__main__":
    sys.exit(main())
