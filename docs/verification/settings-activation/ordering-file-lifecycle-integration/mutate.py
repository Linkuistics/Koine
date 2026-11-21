"""Apply one named mutation to an isolated copy and run the suite there.

Usage: python3 mutate.py NAME WORKDIR, from the repository root.
"""

import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

repo = Path.cwd()
MUTATIONS = {
    # The backend deletes a leftover partial download after a failure.
    "N1-backend-deletes-partial": (
        "scripts/vm-guest-exec.py",
        '    if reason:\n        latch(root, f"{attempt.name}: {reason}")\n',
        "    if reason:\n"
        '        for leftover in attempt.glob(".*.tmp"):\n'
        "            leftover.unlink()\n"
        '        latch(root, f"{attempt.name}: {reason}")\n',
    ),
    # The fixture keeps its prefix after a streaming error.
    "N2-fixture-keeps-errored-prefix": (
        "Tests/scripts/fixtures/file-lifecycle-cli.py",
        "        partial.unlink()\n",
        "",
    ),
}
name = sys.argv[1]
target, old, new = MUTATIONS[name]
work = Path(sys.argv[2]) / name
shutil.rmtree(work, ignore_errors=True)
for part in ("scripts", "Tests/scripts"):
    shutil.copytree(repo / part, work / part, symlinks=True)
path = work / target
text = path.read_text()
assert text.count(old) == 1, (name, text.count(old))
path.write_text(text.replace(old, new))
run = subprocess.run(
    ["bats", str(work / "Tests/scripts/vm-file-lifecycle-evidence.bats")],
    capture_output=True,
    text=True,
)
failed = [line for line in run.stdout.splitlines() if line.startswith("not ok")]
print(
    json.dumps(
        {
            "mutation": name,
            "file": target,
            "replace": old,
            "with": new,
            "mutated_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "exit": run.returncode,
            "failed": failed,
        }
    )
)
