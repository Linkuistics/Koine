#!/usr/bin/env python3
"""Runs inside the VM: ONE sample of the keyboard workflow Koine serves, timed.

The workflow this stands in for is a client's, not a loop over the API: the user
is working in one window, invokes a switcher, the switcher lists an application's
choices, the user picks one, and that window takes focus. The next switch starts
from the window the last one landed on, which is why the caller drives these one
after another with real keystrokes in between rather than calling in a loop.

Two durations are what the spec asks for. Each is measured around its own request
alone, on a monotonic clock, in the process that makes it:

  queryToChoices    DesktopChoices sent -> its whole response parsed. The process
                    identity was captured first, as a client captures it at
                    interaction start; that capture is timed separately and
                    reported beside this rather than folded into it.
  selectionToFocus  FocusDesktopWindow sent -> its receipt parsed. The receipt is
                    not a proxy for the focus landing: the provider returns it
                    only after the target application reports itself frontmost
                    with that element as its focused window
                    (Providers/DesktopProvider/Sources/DesktopProvider.swift), so
                    this IS the focus landing. The probe then says so again, from
                    outside Koine, and that read is timed but not counted.

"Warm" is established here rather than assumed. The connection carries one
unmeasured request before either measured one, so neither pays for the TCP
handshake, and the caller's first sample of a run is marked --warmup so that the
provider's observation state and the first resolution of the application are
never inside a reported number. A cold login or a crash is a separate
availability case and is not measured.

The state is asserted BEFORE the act, never after: --from-window names the
window-server id the probe must report as focused for this sample to mean
anything, and a sample that does not find it measures nothing and says so. That
is what makes the command safe for TestAnyware to repeat after a false timeout —
a repeat finds the target focused instead, refuses, and the caller re-establishes
the state with --establish, which is untimed and recorded.

usage: vm-verify-latency-client.py <credential> <operations> <probe> --establish <ref>
       vm-verify-latency-client.py <credential> <operations> <probe>
           --application <name> --ref <reference> --class <label>
           --from-window <window-server id> [--warmup]
Prints one JSON object on one line, whatever happens.
"""
import argparse, ctypes, datetime, http.client, json, os, subprocess, time


def operation(path, name):
    """One named operation of a GraphQL document whose operations are separated
    by blank lines — the reader scripts/vm-verify-desktop-client.py uses, so the
    text sent is docs/design/desktop-operations.graphql's, unchanged."""
    for block in open(path).read().split("\n\n"):
        if block.split("(")[0].split()[1:2] == [name]:
            return block.strip() + "\n"
    raise SystemExit("no operation %s in %s" % (name, path))


def start_microseconds(pid):
    # struct proc_bsdinfo (<sys/proc_info.h>): pbi_start_tvsec and pbi_start_tvusec
    # are the two 64-bit fields at offsets 120 and 128 of its 136 bytes.
    buffer = ctypes.create_string_buffer(136)
    libproc = ctypes.CDLL("/usr/lib/libproc.dylib", use_errno=True)
    if libproc.proc_pidinfo(pid, 3, ctypes.c_uint64(0), buffer, 136) != 136:  # PROC_PIDTBSDINFO
        raise OSError(ctypes.get_errno(), "proc_pidinfo")
    seconds = int.from_bytes(buffer.raw[120:128], "little")
    return seconds * 1_000_000 + int.from_bytes(buffer.raw[128:136], "little")


def canonical(microseconds):
    instant = datetime.datetime.fromtimestamp(microseconds // 1_000_000, datetime.timezone.utc)
    return instant.strftime("%Y-%m-%dT%H:%M:%S") + ".%06dZ" % (microseconds % 1_000_000)


def capture(name):
    """The process identity, as any client captures it at interaction start."""
    pid = int(subprocess.check_output(["pgrep", "-x", name]).split()[0])
    return {"pid": pid, "startedAt": canonical(start_microseconds(pid))}


class Endpoint:
    """One keep-alive connection to Koine, found through the endpoint descriptor."""

    def __init__(self, credential):
        data = os.path.expanduser("~/Library/Application Support/Koine")
        with open(os.path.join(data, "endpoint.json")) as file:
            descriptor = json.load(file)
        self.path = descriptor["path"]
        self.headers = {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + credential,
            "Connection": "keep-alive",
        }
        self.connection = http.client.HTTPConnection("127.0.0.1", descriptor["port"], timeout=30)

    def ask(self, query, variables):
        """Returns (response, microseconds). The clock spans the request and the
        parse of its whole body, which is what a client waits for."""
        body = json.dumps({"query": query, "variables": variables}).encode()
        started = time.monotonic_ns()
        self.connection.request("POST", self.path, body=body, headers=self.headers)
        answer = json.loads(self.connection.getresponse().read())
        return answer, (time.monotonic_ns() - started) // 1000


def focused(path):
    """What the system says has focus. Koine is never asked."""
    seen = json.loads(subprocess.check_output([path, "focused"]))
    if not seen.get("trusted"):
        raise SystemExit("the witness cannot read the focused window")
    window = seen.get("window") or {}
    application = seen.get("application") or {}
    return {
        "pid": application.get("pid"),
        "name": application.get("name"),
        "windowId": window.get("privateWindowId"),
        "title": window.get("title"),
    }


def errors(answer):
    return answer.get("errors") or []


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("credential")
    parser.add_argument("operations")
    parser.add_argument("probe")
    parser.add_argument("--establish")
    parser.add_argument("--application")
    parser.add_argument("--ref")
    parser.add_argument("--class", dest="kind")
    parser.add_argument("--from-window", type=int)
    parser.add_argument("--warmup", action="store_true")
    options = parser.parse_args()

    focus_text = operation(options.operations, "FocusDesktopWindow")
    endpoint = Endpoint(open(options.credential).read().strip())

    # Untimed, and the only thing here that moves focus without measuring it:
    # putting the workflow back where the caller expects it after a repeat.
    if options.establish:
        answer, _ = endpoint.ask(focus_text, {"ref": options.establish})
        time.sleep(0.5)
        print(json.dumps({
            "establish": options.establish,
            "errors": errors(answer),
            "focused": focused(options.probe),
        }))
        return

    choices_text = operation(options.operations, "DesktopChoices")
    sample = {
        "class": options.kind,
        "application": options.application,
        "ref": options.ref,
        "warmup": options.warmup,
        "ok": False,
    }

    def done(note=None):
        if note is not None:
            sample["note"] = note
        print(json.dumps(sample))

    # The connection is warm before anything is measured: this request pays for
    # the handshake, and it is never one of the two the sample reports.
    _, sample["warmupRequestMicros"] = endpoint.ask("query { koine { schemaDigest } }", {})

    # The state, asserted before the act. A sample that starts anywhere but the
    # window the caller left focused is not the switch it claims to be.
    sample["before"] = focused(options.probe)
    if sample["before"]["windowId"] != options.from_window:
        return done("the workflow was at window %s, not the expected %s"
                    % (sample["before"]["windowId"], options.from_window))

    started = time.monotonic_ns()
    process = capture(options.application)
    sample["identityCaptureMicros"] = (time.monotonic_ns() - started) // 1000

    answer, sample["queryToChoicesMicros"] = endpoint.ask(choices_text, {"process": process})
    if errors(answer):
        return done("DesktopChoices: %s" % json.dumps(errors(answer)))
    windows = ((answer.get("data") or {}).get("desktopApplication") or {}).get("windows") or []
    sample["choiceCount"] = len(windows)
    # The selection comes out of the query, not out of the caller's memory: the
    # reference submitted below is one this very response listed.
    if options.ref not in [window["ref"] for window in windows]:
        return done("the target is not among the choices this query returned")

    answer, sample["selectionToFocusMicros"] = endpoint.ask(focus_text, {"ref": options.ref})
    if errors(answer):
        return done("FocusDesktopWindow: %s" % json.dumps(errors(answer)))
    receipt = (answer.get("data") or {}).get("desktopFocusWindow")
    if receipt != {"ref": options.ref}:
        return done("the receipt was %s" % json.dumps(receipt))

    # Not part of either duration — the receipt already means the focus landed —
    # and timed so that the reader can see what asking the system separately cost.
    started = time.monotonic_ns()
    sample["after"] = focused(options.probe)
    sample["witnessAfterMicros"] = (time.monotonic_ns() - started) // 1000
    sample["ok"] = True
    done()


main()
