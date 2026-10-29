"""Synthetic CLI only: no endpoint, VM or native screen is contacted."""

from __future__ import annotations

import json
import os
import struct
import sys
import time
import zlib
from pathlib import Path


def chunk(kind: bytes, data: bytes) -> bytes:
    return (
        struct.pack(">I", len(data))
        + kind
        + data
        + struct.pack(">I", zlib.crc32(kind + data))
    )


def main() -> int:
    args = sys.argv[1:]
    with Path(os.environ["capture_calls"]).open("a") as stream:
        stream.write(json.dumps(args) + "\n")
    print("synthetic capture diagnostic", file=sys.stderr)
    if args[:2] != ["screen", "capture"]:
        print(
            json.dumps(
                {"schema_version": "1.0", "ok": True, "key": "return", "modifiers": []}
            )
        )
        return 0
    if os.environ.get("capture_block") == "1":
        ready = Path(os.environ["capture_ready"])
        ready.touch()
        while not ready.with_suffix(".release").exists():
            time.sleep(0.02)
    path = Path(args[args.index("-o") + 1])
    width, height = 2, 2
    if "--region" in args:
        _, _, width, height = map(int, args[args.index("--region") + 1].split(","))
    mode = os.environ.get("capture_mode", "clean")
    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    pixels = (b"\x00" + bytes([255, 0, 50, 255]) * width) * height
    if mode == "color":
        header = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    if mode == "rows":
        pixels = pixels[:-1]
    if mode == "filter":
        pixels = b"\x05" + pixels[1:]
    compressed = zlib.compress(pixels)
    if mode == "zlib":
        compressed = compressed[:-2]
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", compressed)
        + chunk(b"IEND", b"")
    )
    if mode == "signature":
        png = b"not an image"
    elif mode == "crc":
        png = png[:-1] + bytes([png[-1] ^ 1])
    elif mode == "truncated":
        png = png[:-12]
    elif mode == "trailing":
        png += b"unrelated trailing content"
    elif mode == "empty":
        png = b""
    if mode == "directory":
        path.mkdir()
    elif mode == "symlink":
        target = path.with_suffix(".target")
        target.write_bytes(png)
        path.symlink_to(target)
    elif mode != "missing":
        path.write_bytes(png)
    response: dict[str, object] = {
        "schema_version": "1.0",
        "ok": True,
        "path": str(path),
        "width": width,
        "height": height,
    }
    if mode == "path":
        response["path"] = str(path) + "-other"
    elif mode == "dimensions":
        response["width"] = width + 1
    elif mode == "width":
        response["width"] = "2"
    elif mode == "zero":
        response["height"] = 0
    elif mode == "absent-field":
        del response["path"]
    elif mode == "error":
        response = {
            "schema_version": "1.0",
            "ok": False,
            "code": "IO_ERROR",
            "message": "synthetic failure",
        }
    elif mode == "dry-run":
        response["dry_run"] = False
    if mode == "partial":
        print('{"schema_version":')
    else:
        print(json.dumps(response))
    return int(os.environ.get("capture_exit", "0"))


if __name__ == "__main__":
    sys.exit(main())
