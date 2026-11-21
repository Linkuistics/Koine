"""Run the launch identity script with a fake libSystem.

Usage: identity-libproc-fake.py SCENARIO SCRIPT DESCRIPTOR

The script is the real IDENTITY_SCRIPT of scripts/vm_exec_reads.py, and the
descriptor is a real file. Only the three libproc answers are fake: the first
proc_pidinfo, the proc_pidpath and the second proc_pidinfo, in that order. A
host kernel cannot make a live process fail its path read on demand, so this
fake tests the script's decision about each answer. It proves no kernel or
guest behaviour.

xnu proc_pidpathinfo_internal returns ESRCH for a live process when the
executable vnode is missing, recycled or on a volume that unmounts. With flags
and arg zero, proc_pidinfo PROC_PIDTBSDINFO returns ESRCH only when proc_find
finds no process for the PID.
https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/proc_info.c
"""

from __future__ import annotations

import ctypes
import errno
import sys
from typing import Any

EXECUTABLE = b"/Applications/Koine.app/Contents/MacOS/Koine"
START_SEC = 1795270100
START_USEC = 250000

# Each answer in call order: "info" and "later-info" are complete records, the
# second with a later start. "path" is the executable path. An errno name is a
# failed call with that errno.
SCENARIOS: dict[str, tuple[str, str, str]] = {
    "live": ("info", "path", "info"),
    "path-esrch-live": ("info", "ESRCH", "info"),
    "path-eperm-live": ("info", "EPERM", "info"),
    "absent": ("ESRCH", "ESRCH", "ESRCH"),
    "exit-during-read": ("info", "ESRCH", "ESRCH"),
    "reuse-during-read": ("info", "path", "later-info"),
    "info-eperm": ("EPERM", "path", "info"),
}


class FakeLibproc:
    def __init__(self, answers: tuple[str, str, str]) -> None:
        self.answers = list(answers)
        self.calls = ["proc_pidinfo", "proc_pidpath", "proc_pidinfo"]

    def take(self, call: str) -> str:
        if not self.calls or self.calls.pop(0) != call:
            raise SystemExit(f"identity fake: unexpected call {call}")
        return self.answers.pop(0)

    def fail(self, answer: str) -> int:
        ctypes.set_errno(getattr(errno, answer))
        return 0

    def proc_pidinfo(
        self, pid: int, flavor: int, arg: int, record: Any, size: int
    ) -> int:
        answer = self.take("proc_pidinfo")
        if flavor != 3 or arg != 0:
            raise SystemExit("identity fake: expected PROC_PIDTBSDINFO with arg 0")
        if answer not in ("info", "later-info"):
            return self.fail(answer)
        value = record._obj
        value.pid = pid
        value.sec = START_SEC
        value.usec = START_USEC + (1 if answer == "later-info" else 0)
        return size

    def proc_pidpath(
        self, _pid: int, buffer: ctypes.Array[ctypes.c_char], size: int
    ) -> int:
        answer = self.take("proc_pidpath")
        if answer != "path":
            return self.fail(answer)
        if size < len(EXECUTABLE):
            raise SystemExit("identity fake: path buffer too small")
        ctypes.memmove(buffer, EXECUTABLE, len(EXECUTABLE))
        return len(EXECUTABLE)


def main() -> None:
    scenario, script, descriptor = sys.argv[1:]
    fake = FakeLibproc(SCENARIOS[scenario])

    def load(name: str, use_errno: bool = False) -> FakeLibproc:
        if name != "/usr/lib/libSystem.B.dylib" or not use_errno:
            raise SystemExit("identity fake: unexpected library load")
        return fake

    ctypes.CDLL = load
    sys.argv = ["-c", descriptor]
    # The fixture runs the real script text of scripts/vm_exec_reads.py.
    exec(compile(script, "<identity>", "exec"), {"__name__": "__main__"})  # noqa: S102


if __name__ == "__main__":
    main()
