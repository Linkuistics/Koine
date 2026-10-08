#!/usr/bin/env python3
"""Exercise the real V recipe's guest launch under concurrent and completed retries."""

import shlex
import subprocess
import tempfile
from pathlib import Path


def main() -> None:
    recipe = Path(__file__).with_name("vm-verify-selection.sh")
    launch = next(
        line
        for line in recipe.read_text().splitlines()
        if line.startswith('guest "mkdir \\$HOME/selection-run.started')
    )
    # Capture the argument at the real guest() boundary, without booting a VM.
    command = subprocess.run(
        ["bash", "-c", 'guest() { printf "%s" "$1"; }\n' + launch],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    with tempfile.TemporaryDirectory(prefix="selection-vm-launch-") as directory:
        root = Path(directory)
        # A real shell action records each invocation and returns a failing status.
        (root / "run-selection.sh").write_text(
            '#!/bin/bash\ncd "$(dirname "$0")"\n'
            "printf 'started\\n' >> launches\nsleep 0.1\n"
            "printf 'driver output\\n'\nexit 37\n"
        )
        invocation = command.replace("$HOME", shlex.quote(directory)) + "\nwait"
        processes = [
            subprocess.Popen(
                ["bash", "-c", invocation],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            for _ in range(2)
        ]
        for process in processes:
            process.communicate(timeout=5)
            assert process.returncode == 0, "launch retry must return successfully"
        subprocess.run(
            ["bash", "-c", invocation], check=True, capture_output=True, timeout=5
        )
        launches = (root / "launches").read_text().splitlines()
        assert launches == ["started"], f"retry launched {len(launches)} result writers"
        assert (root / "selection-run.exit").read_text().strip() == "37"
        assert (root / "selection-run.log").read_text() == "driver output\n"
    print(
        "Selection V launch: concurrent and completed retries keep one result writer and its exit status"
    )


if __name__ == "__main__":
    main()
