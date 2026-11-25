#!/usr/bin/env python3
"""Compare the complete Settings scenario with its protocol baseline.

The baseline is commit f019161b. The check runs a scenario against the simulated
guest of Tests/scripts/fixtures/settings-scenario-backend.py and derives one
ordered stream of inputs, window actions, submissions, uploads and waits. Each
case either completes the scenario or exhausts one poll, so a stream also pins
the bound of that poll.

The retained record, baseline.json, is derived from the baseline commit. The
reviewed classification.json names and cites each difference. It also pins each
baseline wait and assertion to its current source statement, and it holds the
ordered state predicates of the complete run. An unclassified difference, or a
classified difference that no longer occurs, is a finding.

Usage:
  check-settings-baseline.py [--tree DIR] [--case NAME]...
  check-settings-baseline.py --derive-baseline OUTPUT
  check-settings-baseline.py --print-predicates

Run it from the repository root. --tree names a copy of the repository to check.
Status 0 means no finding, 1 means a finding and 2 means that a case could not
run. A simulated pass establishes no native behaviour.
"""

# pyright: strict
from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import os
import re
import shutil
import stat
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import NamedTuple, cast

BASELINE = "f019161bbd3275ec12444a217a99a7a06da37176"
RECORD = Path(
    "docs/verification/settings-activation/ordering-baseline-evidence/baseline.json"
)
CLASSIFICATION = RECORD.with_name("classification.json")
BACKEND = Path("Tests/scripts/fixtures/settings-scenario-backend.py")
BASELINE_CLI = Path("Tests/scripts/fixtures/settings-baseline-cli.py")
SCENARIO = "scripts/vm-verify-menu-bar.sh"
SUBMISSIONS = {
    "open-koine",
    "open-textedit",
    "quit-textedit",
    "request-automation",
    "open-accessibility-pane",
    "extract-bundle",
    "restart",
}
# Each case is the model flags of one run. "complete" reaches PASSED. Every
# other case exhausts one poll or falsifies one assertion.
CASES: dict[str, str] = {
    "complete": "",
    "launch-endpoint": "endpoint-absent",
    "menu-label": "label-stuck",
    "menu-item-frame": "item-frame-absent",
    "menu-row": "row-absent",
    "quit-row": "quit-row-absent",
    "textedit-window": "textedit-no-window",
    "exact-allow": "allow-substring",
    "add-button": "add-absent",
    "window-count": "zero-window-alive",
    "reveal": "scroll-ignored",
    "restart-boot": "boot-stuck",
    "login-endpoint": "login-not-started",
    "resize": "resize-ignored",
    "menu-titles": "menu-title-wrong",
    "silent-launch": "silent-launch-window",
    "requests-on-screen": "requests-off-screen",
}
# The baseline helpers that the scenario reaches, for the assertion inventory.
HELPERS = {
    "scripts/vm-verify-lib.sh": (
        "click",
        "read_frame",
        "reveal",
        "grant_system_events_automation",
        "await_menu_item_label",
        "open_menu",
        "choose_menu_item",
        "await_windows",
    ),
    "scripts/vm-verify-desktop-lib.sh": ("grant_accessibility",),
}
BASELINE_FILES = (
    SCENARIO,
    "scripts/vm-verify-lib.sh",
    "scripts/vm-verify-desktop-lib.sh",
    "scripts/vm-menu-pointer-lib.sh",
    "scripts/vm-window-resize-lib.sh",
)
ASSERTION = re.compile(r'\bfail "((?:[^"\\]|\\.|\$\((?:[^()]|\([^()]*\))*\))*)"')
WAIT = re.compile(r"^\s*(?:.*\{ )?sleep (\d+)\b", re.MULTILINE)
SUFFIX = re.compile(r" \((?:evidence status \d+|outcome [a-z-]+)\)$")
ATTEMPT = re.compile(r"-\d+(?=-|$)")
SLEEP_STUB = """#!/bin/bash
# The keepalive loop of the baseline is the only 20-second wait. It ends here.
[[ "$1" == 20 ]] && exit 1
printf '{"event":"wait %s"}\\n' "$1" >>"${settings_sim}/calls.jsonl"
"""


def call_event(call: dict[str, object]) -> str | None:
    """The stream event of one logged call, or None for a read or a record."""
    if "event" in call:
        return str(call["event"])
    if call.get("outcome") != "clean":
        return None
    action = call.get("action")
    arguments = [str(item) for item in cast(list[object], call.get("arguments", []))]
    if action == "upload":
        return f"upload {arguments[1]}"
    if action == "read" and arguments:
        if arguments[0] in SUBMISSIONS:
            return f"submit {arguments[0]}"
        if arguments[0] == "enrol":
            return f"submit enrol {arguments[2]}"
        return None
    if action != "cli" or "--" not in arguments:
        return None
    command = arguments[arguments.index("--") + 1 :]
    if command[:2] == ["screen", "find-text"]:
        return " ".join(["bound find-text", command[2], *command[3:5]])
    if command[0] == "input":
        if command[1] == "key":
            rest = command[2:]
            modifiers = (
                rest[rest.index("--modifiers") + 1] if "--modifiers" in rest else ""
            )
            return " ".join(filter(None, ["input key", rest[0], modifiers]))
        return " ".join(command)
    if command[0] == "agent" and command[1].startswith("window-"):
        rest = command[2:]
        where = [
            item.split("=", 1)[1]
            for prefix in ("--x=", "--y=")
            for item in rest
            if item.startswith(prefix)
        ]
        window = rest[rest.index("--window") + 1]
        return " ".join(["window", command[1].removeprefix("window-"), window, *where])
    return None


class Run(NamedTuple):
    events: list[str]
    failure: str | None
    predicates: list[str]


def write_executable(path: Path, text: str) -> None:
    path.write_text(text)
    path.chmod(path.stat().st_mode | stat.S_IXUSR)


def prepare(work: Path, source: Path, tree: Path | None) -> Path:
    """A private repository copy: the baseline when tree is None."""
    repo = work / "repo"
    (repo / "bundle/Koine.app/Contents").mkdir(parents=True)
    (repo / "bundle/Koine.app/Contents/Info.plist").write_text("bundle\n")
    if tree is None:
        archive = subprocess.run(
            [
                "git",
                "-C",
                str(source),
                "archive",
                BASELINE,
                "scripts",
                "App/Info.plist",
            ],
            check=True,
            capture_output=True,
        )
        subprocess.run(["tar", "-x", "-C", str(repo)], input=archive.stdout, check=True)
    else:
        shutil.copytree(tree / "scripts", repo / "scripts")
        (repo / "App").mkdir()
        shutil.copy(tree / "App/Info.plist", repo / "App/Info.plist")
        shutil.copy(tree / BACKEND, repo / "scripts/vm-guest-exec.py")
    return repo


def failure_of(output: str) -> str | None:
    """The first failure message, without the current lane's status suffix."""
    for line in output.splitlines():
        if line.startswith("FAILED: "):
            return SUFFIX.sub("", line.removeprefix("FAILED: "))
    return None


def predicates_of(calls: list[dict[str, object]]) -> list[str]:
    """The ordered reads, payload contracts and state predicates of one run.

    A poll repeats one read and one state decision. Its attempts collapse to one
    pair, because the wait stream pins how many attempts run.
    """
    rows: list[str] = []
    for call in calls:
        arguments = [
            str(item) for item in cast(list[object], call.get("arguments", []))
        ]
        action = call.get("action")
        if action == "poll-step" and arguments[:1] == ["state"]:
            detail = arguments[2]
        elif action == "read" and call.get("outcome") == "clean":
            detail = " ".join(["read", *arguments])
        elif action == "cli" and call.get("outcome") == "clean" and "--" in arguments:
            split = arguments.index("--")
            if arguments[split + 1 : split + 3] != ["agent", "snapshot"]:
                continue
            detail = f"snapshot {arguments[split + 5]} {arguments[0]}"
        else:
            continue
        row = f"{ATTEMPT.sub('', str(call['operation']))} | {detail}"
        if row not in rows[-2:]:
            rows.append(row)
    return rows


def run_case(source: Path, tree: Path | None, flags: str) -> Run:
    """One run's ordered evidence. Raises RuntimeError when the run is unusable."""
    with tempfile.TemporaryDirectory(prefix="settings-baseline-") as name:
        work = Path(name)
        repo = prepare(work, source, tree)
        sim, bin_dir = work / "sim", work / "bin"
        sim.mkdir()
        bin_dir.mkdir()
        write_executable(bin_dir / "sleep", SLEEP_STUB)
        cli = (source / BASELINE_CLI).resolve()
        write_executable(
            bin_dir / "testanyware",
            f'#!/bin/bash\nexec python3 -I "{cli}" "$@"\n'
            if tree is None
            else '#!/bin/bash\necho "{\\"unsimulated\\":\\"legacy\\"}" >>"${settings_sim}/calls.jsonl"\nexit 97\n',
        )
        environment = {
            key: value
            for key, value in os.environ.items()
            if not key.startswith(("KOINE_", "settings_", "TESTANYWARE_"))
        }
        environment.update(
            PATH=f"{bin_dir}:{os.environ['PATH']}",
            settings_sim=str(sim),
            settings_backend=str((source / BACKEND).resolve()),
            settings_flags=flags,
            KOINE_APP_BUNDLE=str(repo / "bundle/Koine.app"),
            KOINE_VM_BASE="testanyware-golden-macos-27",
            KOINE_VM_ID="exact-settings-vm",
            # The current scenario runs its local jq decisions through KOINE_JQ.
            KOINE_TESTANYWARE_CLI=str(bin_dir / "testanyware"),
            KOINE_JQ=os.path.realpath(shutil.which("jq") or "jq"),
        )
        result = subprocess.run(
            [str(repo / SCENARIO)],
            cwd=repo,
            env=environment,
            capture_output=True,
            text=True,
            timeout=300,
            check=False,
        )
        calls = [
            cast(dict[str, object], json.loads(line))
            for line in (sim / "calls.jsonl").read_text().splitlines()
        ]
        if any("unsimulated" in call for call in calls):
            raise RuntimeError(f"flags {flags!r}: an unsimulated CLI call")
        passed = "== PASSED" in result.stdout
        if passed != (flags == ""):
            tail = "\n".join(result.stdout.splitlines()[-4:])
            raise RuntimeError(f"flags {flags!r}: status {result.returncode}\n{tail}")
        return Run(
            [event for event in map(call_event, calls) if event is not None],
            failure_of(result.stdout),
            predicates_of(calls),
        )


def derive(source: Path, tree: Path | None, names: list[str]) -> dict[str, Run]:
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        futures = {
            name: pool.submit(run_case, source, tree, CASES[name]) for name in names
        }
        return {name: future.result() for name, future in futures.items()}


def first_difference(left: list[str], right: list[str]) -> str:
    for index, (old, new) in enumerate(zip(left, right)):
        if old != new:
            return f"event {index + 1}: expected {old!r}, current {new!r}"
    if len(left) != len(right):
        index = min(len(left), len(right))
        extra = (left + [""])[index] if len(left) > len(right) else right[index]
        return (
            f"event {index + 1}: lengths {len(left)} and {len(right)}, next {extra!r}"
        )
    return "no difference"


def baseline_text(source: Path, path: str) -> str:
    return subprocess.run(
        ["git", "-C", str(source), "show", f"{BASELINE}:{path}"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout


def baseline_facts(source: Path) -> dict[str, object]:
    """The waits, assertions and file digests of the baseline source."""
    scenario = baseline_text(source, SCENARIO)
    assertions = [
        {"site": "scenario", "message": match.group(1)}
        for match in ASSERTION.finditer(scenario)
    ]
    for path, names in HELPERS.items():
        text = baseline_text(source, path)
        for name in names:
            body = re.search(rf"^{name}\(\) \{{.*?^\}}", text, re.MULTILINE | re.DOTALL)
            if body is None:
                raise ValueError(f"the baseline has no helper {name}")
            assertions += [
                {"site": name, "message": match.group(1)}
                for match in ASSERTION.finditer(body.group(0))
            ]
    digests = {
        path: hashlib.sha256(baseline_text(source, path).encode()).hexdigest()
        for path in BASELINE_FILES
    }
    waits = [int(seconds) for seconds in WAIT.findall(scenario)]
    return {"files": digests, "waits": waits, "assertions": assertions}


def flattened(text: str) -> str:
    return "\n".join(line.strip() for line in text.splitlines())


def slug(heading: str) -> str:
    kept = re.sub(r"[^\w\- ]", "", heading.strip().lower())
    return kept.replace(" ", "-")


def citation_problem(citation: str) -> str | None:
    path, _, anchor = citation.partition("#")
    try:
        text = Path(path).read_text(encoding="utf-8")
    except OSError:
        return f"citation file not found: {citation}"
    headings = {
        slug(line.lstrip("#")) for line in text.splitlines() if line.startswith("#")
    }
    if anchor and anchor not in headings:
        return f"citation heading not found: {citation}"
    return None


def anchors_of(row: dict[str, object]) -> list[dict[str, str]]:
    return cast(list[dict[str, str]], row.get("current", []))


def check_anchors(rows: list[dict[str, object]], tree: Path, label: str) -> list[str]:
    findings: list[str] = []
    cache: dict[str, str] = {}
    for index, row in enumerate(rows, 1):
        anchors = anchors_of(row)
        if not anchors:
            findings.append(f"{label} {index}: no current statement")
        for anchor in anchors:
            name = anchor["file"]
            if name not in cache:
                cache[name] = flattened((tree / name).read_text(encoding="utf-8"))
            if flattened(anchor["text"]) not in cache[name]:
                findings.append(f"{label} {index}: not in {name}: {anchor['text']!r}")
    return findings


def check_static(
    record: dict[str, object], review: dict[str, object], tree: Path
) -> list[str]:
    """The classification against the record and the current source."""
    findings: list[str] = []
    classes = cast(dict[str, dict[str, str]], review["classes"])
    for name, entry in classes.items():
        if not entry.get("reason"):
            findings.append(f"class {name}: no reason")
        problem = citation_problem(entry.get("citation", ""))
        if problem:
            findings.append(f"class {name}: {problem}")
    waits = cast(list[dict[str, object]], review["waits"])
    if [row["seconds"] for row in waits] != record["waits"]:
        findings.append("the wait table differs from the baseline waits")
    findings += check_anchors(waits, tree, "wait")
    assertions = cast(list[dict[str, object]], review["assertions"])
    pairs = [{"site": row["site"], "message": row["message"]} for row in assertions]
    if pairs != record["assertions"]:
        findings.append("the assertion table differs from the baseline assertions")
    findings += check_anchors(assertions, tree, "assertion")
    bounds = cast(list[dict[str, object]], review["read_bounds"])
    findings += check_anchors(bounds, tree, "read bound")
    for label in (
        "assertions",
        "event_differences",
        "failure_differences",
        "source_differences",
    ):
        for index, row in enumerate(cast(list[dict[str, str]], review[label]), 1):
            if row.get("class") not in classes:
                findings.append(f"{label} {index}: unknown class {row.get('class')}")
    return findings


def expected_events(
    name: str, stream: list[str], differences: list[dict[str, object]]
) -> tuple[list[str], list[str]]:
    """The baseline stream after the classified differences of one case.

    A row removes its "removed" events at its baseline index and puts its
    "added" events there. The focus step before each reopen (k6) is the
    first addition.
    """
    findings: list[str] = []
    result = list(stream)
    rows = [row for row in differences if row["case"] == name]
    for row in sorted(rows, key=lambda item: -cast(int, item["index"])):
        index = cast(int, row["index"])
        removed = cast(list[str], row.get("removed", []))
        added = cast(list[str], row.get("added", []))
        if result[index : index + len(removed)] != removed:
            findings.append(
                f"{name}: classified removal at {index} is not in the record"
            )
            continue
        result[index : index + len(removed)] = added
    return result, findings


def check_runs(
    record: dict[str, object], review: dict[str, object], current: dict[str, Run]
) -> list[str]:
    findings: list[str] = []
    streams = cast(dict[str, list[str]], record["cases"])
    failures = cast(dict[str, str | None], record["failures"])
    event_rows = cast(list[dict[str, object]], review["event_differences"])
    failure_rows = {
        cast(str, row["case"]): row
        for row in cast(list[dict[str, object]], review["failure_differences"])
    }
    for name, run in current.items():
        expected, problems = expected_events(name, streams.get(name, []), event_rows)
        findings += problems
        if expected != run.events:
            findings.append(f"{name}: {first_difference(expected, run.events)}")
        wanted = failures.get(name)
        row = failure_rows.get(name)
        if row is not None:
            if row["baseline"] != wanted:
                findings.append(f"{name}: the classified failure is not the record's")
            wanted = cast(str, row["current"])
        if wanted != run.failure:
            findings.append(
                f"{name}: failure: expected {wanted!r}, current {run.failure!r}"
            )
    if "complete" in current:
        pinned = cast(list[str], review["predicates"])
        found = current["complete"].predicates
        if pinned != found:
            findings.append(f"predicates: {first_difference(pinned, found)}")
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tree", type=Path, default=Path("."))
    parser.add_argument("--record", type=Path, default=RECORD)
    parser.add_argument("--classification", type=Path, default=CLASSIFICATION)
    parser.add_argument("--derive-baseline", type=Path)
    parser.add_argument("--print-predicates", action="store_true")
    parser.add_argument("--case", action="append", choices=sorted(CASES))
    arguments = parser.parse_args()
    source = Path.cwd()
    tree = arguments.tree.resolve()
    names: list[str] = arguments.case or list(CASES)
    try:
        if arguments.derive_baseline:
            runs = derive(source, None, list(CASES))
            document = {
                "baseline": BASELINE,
                **baseline_facts(source),
                "cases": {name: run.events for name, run in runs.items()},
                "failures": {name: run.failure for name, run in runs.items()},
            }
            arguments.derive_baseline.write_text(
                json.dumps(document, ensure_ascii=False, indent=0) + "\n",
                encoding="utf-8",
            )
            print(f"{len(runs)} baseline cases recorded")
            return 0
        if arguments.print_predicates:
            run = run_case(source, tree, CASES["complete"])
            print(json.dumps(run.predicates, ensure_ascii=False, indent=0))
            return 0
        record = json.loads(arguments.record.read_text(encoding="utf-8"))
        review = json.loads(arguments.classification.read_text(encoding="utf-8"))
        findings = check_static(record, review, tree)
        current = derive(source, tree, names)
        findings += check_runs(record, review, current)
    except (
        KeyError,
        OSError,
        RuntimeError,
        ValueError,
        subprocess.SubprocessError,
    ) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 2
    for finding in findings:
        print(finding)
    total = sum(len(run.events) for run in current.values())
    print(f"{len(current)} cases, {total} events, {len(findings)} findings")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
