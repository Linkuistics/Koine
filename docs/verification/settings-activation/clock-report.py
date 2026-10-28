"""Offline clock evidence; numerical enclosure never qualifies a cross-clock join."""

import argparse
import json
import math
import plistlib
import re
from decimal import Decimal
from pathlib import Path
from typing import Any


def report(
    snapshot: dict[str, Any], native: list[dict[str, Any]], dump: str, boot: str,
) -> dict[str, Any]:
    """Use Apple's saved timesync rendering, without parsing undocumented bytes."""
    # This is the installed Apple decoder's output, not a host timebase query.
    # See clock-evidence/timesync.{txt,json} and decoder-subjects.sha256.
    blocks = dump.split("== boot\n")[1:]
    matching = [b for b in blocks if re.search(rf"^uuid:\s+{re.escape(boot)}$", b, re.M)]
    if len(matching) != 1:
        raise ValueError("missing or ambiguous native boot")
    scales = re.findall(r"^timebase:\s+(\d+) / (\d+)$", matching[0], re.M)
    if len(scales) != 1 or any(int(n) <= 0 for n in scales[0]):
        raise ValueError("missing or invalid native timebase")
    numerator, denominator = (int(n) for n in scales[0])
    records = snapshot["records"]
    if (snapshot["format"] != "koine-settings-events/1" or snapshot["dropped"] != 0
            or not records or len(records) > snapshot["capacity"]
            or [r["sequence"] for r in records] != list(range(1, len(records) + 1))):
        raise ValueError("invalid or incomplete buffer")
    clients = [r for r in native if r.get("processImagePath", "").endswith("/Koine")
               and "SLSSetFrontProcessWithInfo" in r.get("eventMessage", "")]
    if not clients or any(r["bootUUID"] != boot for r in clients):
        raise ValueError("client boot does not match archive boot")
    if any(type(r["machTimestamp"]) is not int or r["machTimestamp"] < 0 for r in clients):
        raise ValueError("invalid native tick")
    callbacks = [r for r in records if r["event"] == "callback.settings"]
    selections = [r["selection"] for r in callbacks]
    if not selections or len(set(selections)) != len(selections):
        raise ValueError("missing or duplicate callbacks")
    intervals = []
    candidates = []
    for callback in callbacks:
        bounds = [[r for r in records if r["selection"] == callback["selection"]
                   and r["event"] == event]
                  for event in ("application.activate.before", "application.activate.after")]
        if any(len(rows) != 1 for rows in bounds):
            raise ValueError("incomplete activation interval")
        before, after = (rows[0] for rows in bounds)
        if (before["pid"] != after["pid"] or callback["pid"] != before["pid"]
                or not callback["sequence"] < before["sequence"] < after["sequence"]
                or any(not math.isfinite(r["uptime"]) for r in (before, after))
                or not 0 <= before["uptime"] <= after["uptime"]):
            raise ValueError("invalid activation interval")
        intervals.append({"selection": callback["selection"], "pid": before["pid"],
                          "beforeUptime": before["uptime"], "afterUptime": after["uptime"]})
        for client in clients:
            # Apple specifies tick * numerator / denominator -> nanoseconds:
            # https://developer.apple.com/documentation/kernel/1462446-mach_absolute_time
            seconds = (Decimal(client["machTimestamp"]) * numerator / denominator
                       / Decimal(1_000_000_000))
            if (client["processID"] == before["pid"]
                    and Decimal(str(before["uptime"])) <= seconds
                    <= Decimal(str(after["uptime"]))):
                candidates.append({
                    "selection": callback["selection"], "pid": before["pid"],
                    "machTimestamp": client["machTimestamp"], "continuousSeconds": str(seconds),
                    "secondsAfterBefore": str(seconds - Decimal(str(before["uptime"]))),
                    "secondsBeforeAfter": str(Decimal(str(after["uptime"])) - seconds),
                })
    return {
        "qualified": False, "joinedSelections": [],
        "nativeBootUUID": boot,
        "nativeTimebase": {"numerator": numerator, "denominator": denominator},
        "gaps": [
            "buffer has no boot UUID; same-guest provenance is indirect",
            "buffer has no paired absolute/continuous reading or measured sleep offset",
            "systemUptime excludes sleep; native continuous time includes sleep",
            "numeric enclosure under zero offset is conditional, not independent calibration",
        ],
        "intervals": intervals, "conditionalZeroSleepCandidates": candidates,
        "lossRecords": [r for r in native if r.get("eventType") == "lossEvent"],
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("snapshot", type=Path)
    parser.add_argument("native", type=Path)
    parser.add_argument("timesync", type=Path)
    parser.add_argument("info", type=Path)
    args = parser.parse_args()
    info = plistlib.loads(args.info.read_bytes())
    result = report(
        json.loads(args.snapshot.read_text()),
        [json.loads(line) for line in args.native.read_text().splitlines() if line.strip()],
        args.timesync.read_text(), info["EndTimeRef"]["UUID"],
    )
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
