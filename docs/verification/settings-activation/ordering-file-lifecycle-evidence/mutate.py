"""Apply one named mutation to an isolated copy and run the suite there."""
import json, shutil, subprocess, sys, hashlib
from pathlib import Path

repo = Path.cwd()
MUTATIONS = {
    "M1-local-after": ("scripts/vm-guest-exec.py", "if local_after != local_before:", "if False:"),
    "M2-upload-match": ("scripts/vm-guest-exec.py", "elif expected is not None and (", "elif False and ("),
    "M3-generic-route": ("scripts/vm-guest-exec.py", '("file", "download")} and not (\n        checked_transfer\n    ):', '("file", "download")} and False:'),
    "M4-stop-flag": ("scripts/vm-lifecycle-evidence-lib.sh", "and .id == ${vm} and .stopped == true", "and .id == ${vm}"),
    "M5-list-complete": ("scripts/vm-lifecycle-evidence-lib.sh", "and .truncated == false and .returned == .total and (.items | length) == .total", ""),
    "M6-start-base": ("scripts/vm-lifecycle-evidence-lib.sh", 'and .base == \\"${base}\\"', ""),
    "M7-regular-file": ("scripts/vm-guest-exec.py", "if not stat.S_ISREG(before.st_mode):", "if not (stat.S_ISREG(before.st_mode) or stat.S_ISLNK(before.st_mode)):"),
    "M7b-regular-file-both-guards": ("scripts/vm-guest-exec.py", [
        ("if not stat.S_ISREG(before.st_mode):", "if not (stat.S_ISREG(before.st_mode) or stat.S_ISLNK(before.st_mode)):"),
        ("os.O_RDONLY | os.O_NOFOLLOW", "os.O_RDONLY"),
        ("if (before.st_dev, before.st_ino) != (opened.st_dev, opened.st_ino):", "if False:"),
    ]),
    "M8-download-size": ("scripts/vm-guest-exec.py", 'if copy["bytes"] != envelope["bytes"]:', "if False:"),
}
name = sys.argv[1]
spec = MUTATIONS[name]
target, pairs = spec[0], [spec[1:]] if isinstance(spec[1], str) else spec[1]
work = Path(sys.argv[2]) / name
shutil.rmtree(work, ignore_errors=True)
for part in ("scripts", "Tests/scripts"):
    shutil.copytree(repo / part, work / part, symlinks=True)
path = work / target
text = path.read_text()
for old, new in pairs:
    assert text.count(old) == 1, (name, text.count(old))
    text = text.replace(old, new)
path.write_text(text)
old = " | ".join(o for o, _ in pairs); new = " | ".join(n for _, n in pairs)
run = subprocess.run(["bats", str(work / "Tests/scripts/vm-file-lifecycle-evidence.bats")], capture_output=True, text=True)
failed = [l for l in run.stdout.splitlines() if l.startswith("not ok")]
print(json.dumps({"mutation": name, "file": target, "replace": old, "with": new,
                  "mutated_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                  "exit": run.returncode, "failed": failed}))
