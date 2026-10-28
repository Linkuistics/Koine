"""Report positive actual-path joins; unmatched intervals never prove no request."""

import argparse
import json
from datetime import datetime
from pathlib import Path
from typing import Any


def join_intervals(snapshot: dict[str, Any], native_path: Path) -> dict[str, Any]:
    """Join exact PID and wall-clock call intervals, retaining every selection."""
    records = snapshot["records"]
    if snapshot["dropped"] != 0:
        raise ValueError("buffer lost records")
    clients: list[dict[str, Any]] = []
    ignored_headers: list[str] = []
    loss_records: list[dict[str, Any]] = []
    for number, line in enumerate(native_path.read_text().splitlines(), 1):
        if number == 1 and line.startswith("Filtering the log data using "):
            ignored_headers.append(line)
            continue
        if not line.strip():
            continue
        row = json.loads(line)
        if row.get("eventType") == "lossEvent":
            loss_records.append(row)
        if (
            "SLSSetFrontProcessWithInfo" in row.get("eventMessage", "")
            and row.get("processImagePath", "").endswith("/Koine")
        ):
            # datetime preserves fractional seconds and the guest's numeric UTC offset.
            row["unixTime"] = datetime.fromisoformat(row["timestamp"]).timestamp()
            clients.append(row)
    intervals: list[dict[str, Any]] = []
    callbacks = [r for r in records if r["event"] == "callback.settings"]
    if not callbacks:
        raise ValueError("no Settings callback intervals")
    for callback in callbacks:
        selection = callback["selection"]
        bounds = {
            event: [r for r in records if r["selection"] == selection and r["event"] == event]
            for event in ("application.activate.before", "application.activate.after")
        }
        if any(len(rows) != 1 for rows in bounds.values()):
            raise ValueError(f"incomplete activation interval for {selection}")
        before = bounds["application.activate.before"][0]
        after = bounds["application.activate.after"][0]
        if before["unixTime"] > after["unixTime"] or before["pid"] != after["pid"]:
            raise ValueError(f"invalid activation interval for {selection}")
        matches = [
            row for row in clients
            if row["processID"] == before["pid"]
            and before["unixTime"] <= row["unixTime"] <= after["unixTime"]
        ]
        intervals.append({
            "selection": selection, "pid": before["pid"],
            "beforeUnixTime": before["unixTime"], "afterUnixTime": after["unixTime"],
            "clientCalls": matches,
        })
    joined = [r["selection"] for r in intervals if r["clientCalls"]]
    return {
        "qualified": bool(joined), "joinedSelections": joined, "intervals": intervals,
        "lossRecords": loss_records, "ignoredHeaders": ignored_headers,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("snapshot", type=Path)
    parser.add_argument("native", type=Path)
    args = parser.parse_args()
    print(json.dumps(join_intervals(json.loads(args.snapshot.read_text()), args.native), indent=2))


if __name__ == "__main__":
    main()
