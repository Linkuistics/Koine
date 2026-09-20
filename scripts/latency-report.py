#!/usr/bin/env python3
"""Reads the samples one run of scripts/vm-verify-latency.sh wrote and prints the
distribution. It computes nothing the samples do not carry and writes nothing:
one measurement, one writer, and this is the reader.

Percentiles are NEAREST-RANK on the sorted samples — the p-th is the sample at
ceil(p/100 * n), an observed value rather than an interpolation between two. With
a few dozen samples an interpolated p95 is mostly an artefact of the formula, and
a reader comparing this against a re-run needs to be comparing readings.

A median and a tail are what is reported, never a mean: the mean of a latency
distribution with a slow tail describes no request that was actually made.

usage: latency-report.py <samples.jsonl> [--per-sample]
"""
import json, math, sys

METRICS = [
    ("queryToChoicesMicros", "query-to-choices"),
    ("selectionToFocusMicros", "selection-to-focus"),
    ("identityCaptureMicros", "process-identity capture (not part of either)"),
    ("witnessAfterMicros", "witness read after the receipt (not part of either)"),
]


def nearest_rank(values, percent):
    return values[min(len(values) - 1, max(0, math.ceil(percent / 100 * len(values)) - 1))]


def row(label, values):
    values = sorted(values)
    return "| %s | %d | %.1f | %.1f | %.1f | %.1f | %.1f | %.1f |" % (
        label, len(values),
        values[0] / 1000, nearest_rank(values, 50) / 1000, nearest_rank(values, 75) / 1000,
        nearest_rank(values, 90) / 1000, nearest_rank(values, 95) / 1000, values[-1] / 1000,
    )


def main():
    path = sys.argv[1]
    samples = [json.loads(line) for line in open(path) if line.strip()]
    counted = [s for s in samples if s.get("ok") and not s.get("warmup")]
    refused = [s for s in samples if not s.get("ok")]
    warmups = [s for s in samples if s.get("ok") and s.get("warmup")]

    print("Samples in %s: %d recorded, %d counted, %d warm-up, %d refused."
          % (path, len(samples), len(counted), len(warmups), len(refused)))
    for sample in refused:
        print("  refused: %s -> %s" % (sample.get("class"), sample.get("note")))
    if not counted:
        raise SystemExit("no counted samples")

    classes = sorted({s["class"] for s in counted})
    print("\nMilliseconds, nearest-rank percentiles over the counted samples.\n")
    for key, title in METRICS:
        print("**%s**\n" % title)
        print("| what | n | min | p50 | p75 | p90 | p95 | max |")
        print("|---|---:|---:|---:|---:|---:|---:|---:|")
        present = [s for s in counted if key in s]
        if len(classes) > 1:
            for kind in classes:
                values = [s[key] for s in present if s["class"] == kind]
                if values:
                    print(row(kind, values))
        if present:
            print(row("all", [s[key] for s in present]))
        print()

    choices = [s["choiceCount"] for s in counted if "choiceCount" in s]
    if choices:
        print("Choices returned per query: %s.\n" % ", ".join(
            "%d windows in %d samples" % (n, choices.count(n)) for n in sorted(set(choices))))

    if "--per-sample" in sys.argv:
        print("Every counted sample, in the order it was taken — the record a re-run is")
        print("compared against item by item, since two runs can agree on a total while")
        print("disagreeing about which sample did what.\n")
        print("| # | class | from window | to window | choices | query-to-choices | selection-to-focus |")
        print("|---:|---|---:|---:|---:|---:|---:|")
        for index, s in enumerate(counted, 1):
            print("| %d | %s | %s | %s | %d | %.1f | %.1f |" % (
                index, s["class"], s["before"]["windowId"], s["after"]["windowId"],
                s.get("choiceCount", 0),
                s["queryToChoicesMicros"] / 1000, s["selectionToFocusMicros"] / 1000))


main()
