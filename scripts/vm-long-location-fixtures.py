#!/usr/bin/env python3
"""Runs IN THE GUEST (scripts/vm-verify-target-locations.sh uploads and runs it).

Builds the subjects of the target-location V acceptance: long locations component by
component, and the short walk outcomes only an effect shows. Nothing here is part of Koine.

    vm-long-location-fixtures.py all <long root> <walk root> <paths dir>
    vm-long-location-fixtures.py check <paths dir>

Long locations are made with mkdir, open and symlink relative to a directory descriptor
(`dir_fd`), so no whole-path call ever addresses one, which the platform would refuse. Their
ancestors are names of at most 200 ASCII bytes, so every component is far inside NAME_MAX (255).
A subject's literal path is exactly the requested number of bytes (no NUL counted).

Every subject's exact path bytes are written to `<paths dir>/<id>.txt`, with no newline, so the
contract-only client reads them with --path-file and nothing re-encodes them. One JSON line per
subject (id, bytes, the path in base64) goes to `<paths dir>/manifest.jsonl` and to stdout.

Subject ids:
  <who>1023-<kind>   who is `c` (opened by an independent route, the observers' control) or `k`
                     (opened by Koine); kinds: txt-d txt-z wit dir-d dir-z rev-txt rev-dir
  r1024-<kind>, r1500-<kind>   kinds txt wit dir: extant, over the limit, never a control
  m1023, m1500       a missing file, in an extant long directory, whose literal path is that long
  w10, w11, w31, w32 the last link of a 10-, 11-, 31- and 32-link chain to a document
  closed             a directory with mode 0600 (a final directory without search permission)
  two-dir            a path through one link inode that has entries in two directories
  dot                a finite repeated dot-link
  mb300, comb, emoji extant documents whose names are multibyte, combining and emoji
  impossible         a 300-byte ASCII name, which cannot exist
"""
from __future__ import annotations

import base64
import json
import os
import sys

SEP = "/"


def ancestors(total: int) -> list[str]:
    """Directory names whose joined length, each preceded by a slash, is `total` bytes."""
    names: list[str] = []
    remaining = total
    index = 0
    while remaining > 0:
        want = min(200, remaining - 1)
        rest = remaining - 1 - want
        if 0 < rest < 5:  # never leave a remainder too short to be a name
            want -= 5 - rest
            rest = remaining - 1 - want
        names.append((f"d{index:02d}-" + "x" * want)[:want])
        remaining = rest
        index += 1
    return names


def ensure_dir(parent_fd: int, name: str) -> int:
    try:
        os.mkdir(name, 0o755, dir_fd=parent_fd)
    except FileExistsError:
        pass
    return os.open(name, os.O_RDONLY | os.O_DIRECTORY, dir_fd=parent_fd)


def build_long(root: str, subject: dict) -> str:
    """Builds one long subject under root/<id>/ and returns its literal path."""
    ident, total, leaf, kind = subject["id"], subject["bytes"], subject["leaf"], subject["kind"]
    base = root + SEP + ident
    dir_bytes = total - len(base) - 1 - len(leaf)
    assert dir_bytes >= 0, (ident, dir_bytes)
    rootfd = os.open(root, os.O_RDONLY | os.O_DIRECTORY)
    fd = ensure_dir(rootfd, ident)
    os.close(rootfd)
    path = base
    for name in ancestors(dir_bytes) if dir_bytes else []:
        child = ensure_dir(fd, name)
        os.close(fd)
        fd = child
        path += SEP + name
    if kind == "file":
        out = os.open(leaf, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o644, dir_fd=fd)
        os.write(out, f"{ident}\n".encode())
        os.close(out)
    elif kind == "dir":
        inner = ensure_dir(fd, leaf)
        out = os.open("inner.txt", os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o644, dir_fd=inner)
        os.write(out, f"inside {ident}\n".encode())
        os.close(out)
        os.close(inner)
    elif kind == "container":  # only the ancestors: the leaf is not made
        pass
    else:
        raise SystemExit(f"unknown kind {kind}")
    os.close(fd)
    path += SEP + leaf
    assert len(path.encode()) == total, (ident, len(path.encode()), total)
    return path


def long_subjects() -> list[dict]:
    subjects: list[dict] = []
    for who in ("c", "k"):
        for suffix, ext, kind in (
            ("txt-d", ".txt", "file"),
            ("txt-z", ".txt", "file"),
            ("wit", ".k134w", "file"),
            ("dir-d", "", "dir"),
            ("dir-z", "", "dir"),
            ("rev-txt", ".txt", "file"),
            ("rev-dir", "", "dir"),
        ):
            ident = f"{who}1023-{suffix}"
            subjects.append({"id": ident, "bytes": 1023, "leaf": ident + ext, "kind": kind})
    for length in (1024, 1500):
        kinds = (("txt", ".txt", "file"), ("wit", ".k134w", "file"), ("dir", "", "dir"))
        for suffix, ext, kind in kinds:
            ident = f"r{length}-{suffix}"
            subjects.append({"id": ident, "bytes": length, "leaf": ident + ext, "kind": kind})
    return subjects


def write_path(paths: str, ident: str, path: bytes, manifest: list[dict]) -> None:
    with open(f"{paths}/{ident}.txt", "wb") as out:
        out.write(path)
    manifest.append({"id": ident, "bytes": len(path), "path_b64": base64.b64encode(path).decode()})


def build_walk(root: str, paths: str, manifest: list[dict]) -> None:
    """The short outcomes: chains, a closed directory, a two-directory link, a dot-link, names."""
    os.makedirs(root, exist_ok=True)
    os.chdir(root)

    def text(path: str, content: str) -> None:
        with open(path, "w", encoding="utf-8") as out:
            out.write(content)

    # Every link ends in .txt: the default handler is looked up for the literal name, as the accepted
    # short-path contract does, and a link named without an extension has no handler.
    for count in (10, 11, 31, 32):
        text(f"w{count}-target.txt", f"w{count}-target\n")
        os.symlink(f"w{count}-target.txt", f"w{count}-1.txt")
        for index in range(2, count + 1):
            os.symlink(f"w{count}-{index - 1}.txt", f"w{count}-{index}.txt")
        write_path(paths, f"w{count}", f"{root}/w{count}-{count}.txt".encode(), manifest)
    os.makedirs("closed-dir")
    text("closed-dir/inside.txt", "inside\n")
    os.chmod("closed-dir", 0o600)
    write_path(paths, "closed", f"{root}/closed-dir".encode(), manifest)
    # One symbolic-link inode with entries in two directories: dA/L and dB/L. dA/L/two-dir.txt is
    # dA/sub/two-dir.txt, a link to dB/L/two-dir.txt, which is dB/sub/two-dir.txt: L and its pending
    # suffix recur on a finite path, and only the containing directory differs.
    for directory in ("dA/sub", "dB/sub"):
        os.makedirs(directory)
    os.symlink("sub", "dA/L")
    os.link("dA/L", "dB/L", follow_symlinks=False)
    os.symlink("../../dB/L/two-dir.txt", "dA/sub/two-dir.txt")
    text("dB/sub/two-dir.txt", "two-dir\n")
    assert os.lstat("dA/L").st_ino == os.lstat("dB/L").st_ino
    write_path(paths, "two-dir", f"{root}/dA/L/two-dir.txt".encode(), manifest)
    os.makedirs("wdot")
    text("wdot/dot-f.txt", "dot-f\n")
    os.symlink(".", "wdot/dot")
    write_path(paths, "dot", f"{root}/wdot/dot/dot/dot/dot-f.txt".encode(), manifest)
    os.makedirs("names")
    names = {
        "mb300": "日" * 100 + "-mb300.txt",
        "comb": "café-" + "é" * 20 + "-comb.txt",
        "emoji": "\U0001f600-emoji.txt",
    }
    for ident, name in names.items():
        text(f"names/{name}", f"{ident}\n")
        write_path(paths, ident, f"{root}/names/{name}".encode(), manifest)
    write_path(paths, "impossible", f"{root}/names/{'z' * 300}".encode(), manifest)


def check(paths: str) -> None:
    """For every subject, what a walk by descriptors alone finds: present, absent or impossible.

    Every component but the last is opened relative to its parent's descriptor (search only for
    nothing: a directory is opened to descend) and the last is examined from its parent, so no
    whole-path call addresses a long location. This is the fixtures' own account, made by the
    kernel's resolution of one component at a time, and is not Koine's walk.
    """
    for line in open(f"{paths}/manifest.jsonl"):
        row = json.loads(line)
        path = open(f"{paths}/{row['id']}.txt", "rb").read()
        assert len(path) == row["bytes"], row["id"]
        fd = os.open("/", os.O_RDONLY)
        parts = [p for p in path.decode().split("/") if p]
        state = "present"
        for index, part in enumerate(parts):
            try:
                if index < len(parts) - 1:
                    child = os.open(part, os.O_RDONLY | os.O_DIRECTORY, dir_fd=fd)
                    os.close(fd)
                    fd = child
                else:
                    os.stat(part, dir_fd=fd, follow_symlinks=True)
            except FileNotFoundError:
                state = "absent"
                break
            except OSError as error:
                state = "impossible" if error.errno == 63 else f"errno-{error.errno}"
                break
        os.close(fd)
        print(row["id"], row["bytes"], state)


def main() -> None:
    if len(sys.argv) == 3 and sys.argv[1] == "check":
        check(sys.argv[2])
        return
    if len(sys.argv) != 5 or sys.argv[1] != "all":
        raise SystemExit(__doc__)
    long_root, walk_root, paths = sys.argv[2:5]
    os.makedirs(long_root, exist_ok=True)
    os.makedirs(paths, exist_ok=True)
    long_root, walk_root = os.path.realpath(long_root), os.path.realpath(walk_root)
    manifest: list[dict] = []
    for subject in long_subjects():
        write_path(paths, subject["id"], build_long(long_root, subject).encode(), manifest)
    # A missing file beside nothing: its directory is extant and long, the file is not made.
    for length in (1023, 1500):
        leaf = f"absent-{length}.txt"
        subject = {"id": f"m{length}", "bytes": length, "leaf": leaf, "kind": "container"}
        write_path(paths, subject["id"], build_long(long_root, subject).encode(), manifest)
    build_walk(walk_root, paths, manifest)
    with open(f"{paths}/manifest.jsonl", "w") as out:
        for row in manifest:
            out.write(json.dumps(row) + "\n")
            print(json.dumps({k: row[k] for k in ("id", "bytes")}))


if __name__ == "__main__":
    main()
