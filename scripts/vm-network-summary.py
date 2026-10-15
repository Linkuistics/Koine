#!/usr/bin/env python3
"""Runs inside the VM, for scripts/vm-verify-network.sh: reads a `tcpdump -i pktap,all
-k NPID -n -l -tt` capture and prints one JSON line saying, for every process the system
attributes packets to, how many it attributed on the loopback interface and how many on any
other interface.

A line looks like
    1790915549.015377 (en0, proc mDNSResponder:200, eproc curl:566, out) IP6 ... A? example.com.
`proc` is the process whose socket carried the packet; `eproc` is the process on whose behalf
it was sent (a DNS lookup is carried by mDNSResponder for the application that asked). A
packet counts for both names. The pid is dropped, so a process that ran twice counts once.

usage: vm-network-summary.py <capture file> [<substring a DNS query must contain>]...
With substrings, each one's lookups are also reported by the process they were made for.
"""
import json
import re
import sys
from collections import defaultdict

LINE = re.compile(r"^\S+ \((?P<iface>[^,]+), proc (?P<proc>[^,)]*)(?:, eproc (?P<eproc>[^,)]*))?, (?P<dir>[a-z]+)\)")


def name(attribution):
    # "Koine:815" -> "Koine"; an empty or pid-only attribution is the kernel's.
    base = attribution.rsplit(":", 1)[0] if attribution else ""
    return base or "(none)"


def main():
    path, needles = sys.argv[1], sys.argv[2:]
    by = defaultdict(lambda: {"loopback": 0, "external": 0})
    lookups = {needle: defaultdict(int) for needle in needles}
    lines = unparsed = 0
    with open(path, errors="replace") as capture:
        for text in capture:
            match = LINE.match(text)
            if not match:
                if re.match(r"^\d+\.\d+ ", text):
                    unparsed += 1
                continue
            lines += 1
            kind = "loopback" if match["iface"] == "lo0" else "external"
            names = {name(match["proc"])}
            if match["eproc"] is not None:
                names.add(name(match["eproc"]))
            for each in names:
                by[each][kind] += 1
            for needle in needles:
                if needle in text and "?" in text:
                    owner = name(match["eproc"]) if match["eproc"] else name(match["proc"])
                    lookups[needle][owner] += 1
    print(json.dumps({"lines": lines, "unparsed": unparsed, "by": by, "lookups": lookups}, sort_keys=True))


main()
