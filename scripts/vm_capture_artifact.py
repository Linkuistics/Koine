"""Validate the tagged capture encoder's complete RGBA8 PNG, without dependencies."""

# pyright: strict
from __future__ import annotations

import hashlib
import os
import stat
import struct
import sys
import zlib
from pathlib import Path


def file_identity(value: os.stat_result) -> tuple[int, int, int, int, int]:
    return (
        value.st_dev,
        value.st_ino,
        value.st_size,
        value.st_mtime_ns,
        value.st_ctime_ns,
    )


def inspect_capture(path: Path, width: int, height: int) -> dict[str, object]:
    # The v2.7.0 encoder writes RgbaImage as PNG (8-bit, noninterlaced).
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-vm/src/capture.rs
    # PNG structure/CRC/filter rules: https://www.w3.org/TR/2025/REC-png-3-20250624/
    if not 0 < width <= 2147483647 or not 0 < height <= 2147483647:
        raise ValueError("capture dimensions outside PNG range")
    with os.fdopen(
        os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK), "rb"
    ) as stream:
        before = os.fstat(stream.fileno())
        if not stat.S_ISREG(before.st_mode):
            raise ValueError("capture artifact must be a regular non-symlink file")
        data = stream.read()
        after = os.fstat(stream.fileno())
    if file_identity(before) != file_identity(after) or file_identity(
        after
    ) != file_identity(path.lstat()):
        raise ValueError("capture artifact changed during reading")
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("capture artifact lacks PNG signature")
    offset = 8
    compressed = bytearray()
    seen_header = seen_data = ended_data = ended = False
    while offset < len(data):
        if len(data) - offset < 12:
            raise ValueError("truncated PNG chunk")
        length = int.from_bytes(data[offset : offset + 4], "big")
        kind = data[offset + 4 : offset + 8]
        end = offset + 12 + length
        if (
            length > 2147483647
            or end > len(data)
            or not all(65 <= c <= 90 or 97 <= c <= 122 for c in kind)
            or kind[2] >= 97
        ):
            raise ValueError("invalid PNG chunk length/type")
        payload = data[offset + 8 : end - 4]
        if zlib.crc32(kind + payload) != int.from_bytes(data[end - 4 : end], "big"):
            raise ValueError("PNG chunk checksum mismatch")
        if not seen_header and kind != b"IHDR":
            raise ValueError("PNG must begin with IHDR")
        if kind == b"IHDR":
            if seen_header or payload != struct.pack(
                ">IIBBBBB", width, height, 8, 6, 0, 0, 0
            ):
                raise ValueError("PNG dimensions/format do not match capture response")
            seen_header = True
        elif kind == b"IDAT":
            if ended_data:
                raise ValueError("nonconsecutive PNG image data")
            compressed.extend(payload)
            seen_data = True
        elif kind == b"IEND":
            if payload or not seen_data or end != len(data):
                raise ValueError("incomplete PNG end or trailing data")
            ended = True
        elif kind[0] < 97:
            raise ValueError("unexpected critical PNG chunk")
        if seen_data and kind != b"IDAT":
            ended_data = True
        offset = end
    if not ended:
        raise ValueError("PNG end missing")
    row_size = width * 4 + 1
    expected = row_size * height
    decoder = zlib.decompressobj()
    # Clamp the Python ssize_t argument even for impossible huge header claims.
    pixels = decoder.decompress(compressed, min(expected + 1, sys.maxsize))
    if (
        not decoder.eof
        or decoder.unused_data
        or decoder.unconsumed_tail
        or len(pixels) != expected
    ):
        raise ValueError("incomplete or oversized PNG pixel stream")
    if any(pixels[row * row_size] > 4 for row in range(height)):
        raise ValueError("invalid PNG row filter")
    return {
        "path": str(path),
        "format": "RGBA8 PNG",
        "width": width,
        "height": height,
        "bytes": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
    }
