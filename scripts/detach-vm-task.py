#!/usr/bin/env python3
"""Launch a VM Taskfile recipe in its own session; retain transcript and exit code."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def main() -> None:
    task_name, output = sys.argv[1:3]
    directory = Path(output).resolve()
    directory.mkdir(parents=True, exist_ok=True)
    done = directory / "done"
    done.unlink(missing_ok=True)
    log = directory / "detached.log"
    with log.open("w") as stream:
        child = subprocess.Popen(
            ["bash", "-c", 'task --exit-code "$1"; printf "%s\\n" "$?" > "$2"',
             "vm-task", task_name, str(done)],
            stdin=subprocess.DEVNULL, stdout=stream, stderr=subprocess.STDOUT,
            start_new_session=True,
        )
    print(f"pid {child.pid}; transcript {log}; wait for {done}")


if __name__ == "__main__":
    main()
