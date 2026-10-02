#!/usr/bin/env python3
"""Run IN THE GUEST by scripts/vm-verify-installations.sh: how long Launch Services keeps a
registered copy that was moved into the Trash.

Each round makes a fresh copy under its own identifier, registers it, waits until Launch Services
reports it, moves it into the Trash (scripts/vm-installation-fixtures.sh trash), and then asks Launch
Services about it as fast as it can for four seconds, with the guest's own NSWorkspace calls
(scripts/vm-registration-lookup.swift). One JSON line is printed: for each round, the answer of the
first lookup after the move, the time of the first lookup that said "none", the last answer, and how
many lookups were made.

usage: vm-installation-trash-window.py <out file> <rounds>
"""
import json
import os
import subprocess
import sys
import time

out_path, rounds = sys.argv[1], int(sys.argv[2])
home = os.path.expanduser("~")
try:
    os.mkdir(out_path + ".started")
except FileExistsError:
    sys.exit(0)
identifier = "dev.koine.test.InstallationFixture.Trashed"


def lookup():
    fields = subprocess.run([f"{home}/lookup", identifier], capture_output=True, text=True).stdout.rstrip("\n").split("\t")
    return fields[1], fields[2]


results = []
for index in range(rounds):
    destination = f"{home}/.Trash/Window-{index}.app"
    subprocess.run(["rm", "-rf", destination])
    moved = subprocess.run(["bash", f"{home}/vm-installation-fixtures.sh", "trash", f"{home}/install-fx", destination])
    started = time.time()
    samples = []
    while time.time() - started < 4:
        lookup_answer = lookup()
        samples.append((round(time.time() - started, 3), lookup_answer))
    first_none = next((t for t, (one, _) in samples if one == "none"), None)
    results.append({
        "moved": moved.returncode == 0,
        "firstAnswer": {"afterSeconds": samples[0][0], "registeredCopy": samples[0][1][0], "everyCopy": samples[0][1][1]},
        "firstNoneAfterSeconds": first_none,
        "lastAnswer": {"registeredCopy": samples[-1][1][0], "everyCopy": samples[-1][1][1]},
        "lookups": len(samples),
        "everRegisteredAfterFirstNone": any(one != "none" for t, (one, _) in samples if first_none is not None and t > first_none),
    })
    subprocess.run(["rm", "-rf", destination])
with open(out_path + ".tmp", "w", encoding="utf-8") as handle:
    json.dump(results, handle)
os.rename(out_path + ".tmp", out_path)
