#!/usr/bin/env python3
"""Run IN THE GUEST by scripts/vm-verify-installations.sh: one request to Koine, observed.

The guest agent's exec channel costs seconds per command and falsely reports a timeout for a
quarter of them, so everything one case needs is done here, in one process, and its one JSON
answer is read back once:

  1. another application is put in front and Koine is confirmed inactive;
  2. every instance of the fixture's identifier and every fixture process is read;
  3. the contract-only client sends ONE request (never repeated);
  4. the fixture copies' own logs are read, awaited when something is expected and given time to
     show that nothing happened when it is not;
  5. the kernel's and the system's account of the process the receipt names is read.

Two environment variables make a case hold at the instant of the request and show that it did.
KOINE_TRASH=<destination>:<identifier> makes a fresh copy, registers it, and moves it into the
Trash, a moment before the request: Launch Services was seen to report a registered copy at its
Trash path for a second or two after the move and then drop it, so the case is only produced
inside that window, and the answer it gives right after the move is recorded.
KOINE_UNREGISTER=<bundle path>:<identifier> is the other: KOINE_UNREGISTER=<bundle path>:<identifier> unregisters the copy
(Launch Services registers a bundle it finds under the home folder on its own, some time after it
appears), requires that Launch Services then reports nothing for the identifier, and records that
answer and the one after the request.

usage: vm-installation-request.py <out file> <launch|open|reveal> <bundle identifier or -> <path file or ->
                                  <document file or -> <yes|no> <identifier of the fixture> <Koine's identifier>
"""
import json
import os
import re
import subprocess
import sys
import time

out_path, kind, ident, app, doc, effect, fixture_id, koine_id = sys.argv[1:9]
home = os.path.expanduser("~")
# A request is sent once. The host starts this script again when the agent falsely reports a timeout for
# the exec that started it, so the first start takes the lock and a second one leaves at once.
try:
    os.mkdir(out_path + ".started")
except FileExistsError:
    sys.exit(0)
witness = f"{home}/LaunchWitness"
client = [f"{home}/node/bin/node", f"{home}/koine-client.mjs"]
secret = f"{home}/koine-secret-both"
paths = f"{home}/paths"
fixture_log = f"{home}/install-fixture.jsonl"
process_pattern = re.compile(r"/Contents/MacOS/(Fixture|Anonymous)( |$)")


def sh(args, timeout=60):
    return subprocess.run(args, capture_output=True, text=True, timeout=timeout)


def witness_json(*args):
    try:
        return json.loads(sh([witness, *args]).stdout)
    except (json.JSONDecodeError, subprocess.TimeoutExpired):
        return None


def instances():
    found = witness_json("instances", fixture_id) or {"instances": []}
    return [{"pid": i["pid"], "startedAt": i["startedAt"], "bundle": i["bundle"]} for i in found["instances"]]


def fixture_processes():
    listing = sh(["ps", "-axo", "pid=,command="]).stdout.splitlines()
    return sorted(line.strip() for line in listing if process_pattern.search(line))


def log_since(sent_ms):
    entries = []
    try:
        with open(fixture_log, encoding="utf-8") as handle:
            for line in handle:
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if entry.get("atMs", 0) >= sent_ms:
                    entries.append(entry)
    except FileNotFoundError:
        pass
    return entries


# 0. An unregistered copy is unregistered now, and Launch Services is asked whether it is.
registration_before = registration_after = None
unregister = os.environ.get("KOINE_UNREGISTER")
lookup = f"{home}/lookup"
lsregister = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if unregister:
    bundle_path, registered_id = unregister.split(":", 1)
    for _ in range(6):
        sh([lsregister, "-u", bundle_path])
        time.sleep(2)
        registration_before = sh([lookup, registered_id]).stdout.strip()
        if registration_before.endswith("\tnone\tnone"):
            break
    else:
        json.dump({"error": f"the copy stays registered: {registration_before}"}, open(out_path, "w"))
        sys.exit(0)

# 1. Another application in front, Koine inactive.
other = "Calculator"
for attempt in range(15):
    sh(["open", "-a", other])
    time.sleep(1.5)
    front = witness_json("frontmost")
    koine = (witness_json("instances", koine_id) or {"instances": []})["instances"]
    if front and (front.get("application") or {}).get("name") == other and len(koine) == 1 and not koine[0]["isActive"]:
        break
else:
    json.dump({"error": f"{other} did not come to the front with Koine inactive"}, open(out_path, "w"))
    sys.exit(0)

# 2. Before.
before = instances()
procs_before = fixture_processes()

# 2b. A registered copy moved into the Trash, immediately before the request.
trash = os.environ.get("KOINE_TRASH")
if trash:
    destination, registered_id = trash.split(":", 1)
    sh(["rm", "-rf", destination])
    moved = sh(["bash", f"{home}/vm-installation-fixtures.sh", "trash", f"{home}/install-fx", destination], timeout=60)
    registration_before = sh([lookup, registered_id]).stdout.strip()
    if moved.returncode != 0:
        json.dump({"error": f"the copy was not moved into the Trash: {moved.stderr[-300:]}"}, open(out_path, "w"))
        sys.exit(0)

# 3. One request, never repeated.
if kind == "launch":
    command = client + ["launch", "--secret", secret, "--bundle-identifier", ident]
elif kind == "reveal":
    command = client + ["reveal-path", "--secret", secret, "--path-file", f"{paths}/{doc}.txt"]
else:
    command = client + ["open-path", "--secret", secret, "--path-file", f"{paths}/{doc}.txt"]
    if ident != "-":
        command += ["--bundle-identifier", ident]
if app != "-":
    with open(f"{paths}/{app}.txt", "rb") as handle:
        command += ["--application-path", handle.read().decode("utf-8")]
result = sh(command, timeout=120)
try:
    answer = json.loads(result.stdout.strip().splitlines()[-1])
except (json.JSONDecodeError, IndexError):
    json.dump({"error": "the client printed no JSON", "stdout": result.stdout[-500:], "stderr": result.stderr[-500:]},
              open(out_path, "w"))
    sys.exit(0)
sent = int(answer.get("sentMs") or 0)

# 4. After.
log = []
if effect == "yes":
    for _ in range(20):
        log = log_since(sent)
        if log:
            break
        time.sleep(1.5)
    # Anything else the request did lands within a moment of the first event.
    time.sleep(3)
else:
    time.sleep(float(os.environ.get("KOINE_INSTALLATION_NO_EFFECT_WAIT", "8")))
log = log_since(sent)
after = instances()
procs_after = fixture_processes()

# 5. The process the receipt names, as the kernel and the system report it.
process = answer.get("process")
receipt_witness = None
if process:
    found = witness_json("process", str(process["pid"]))
    if found:
        receipt_witness = {"pid": found["pid"], "startedAt": found["startedAt"],
                           "bundle": (found.get("application") or {}).get("bundle")}

if unregister or trash:
    registration_after = sh([lookup, registered_id]).stdout.strip()

wanted = ("classification", "status", "dependency", "errors", "process", "actionEffect", "application",
          "path", "selectionObserved")
observed = {
    "answer": {key: answer.get(key) for key in wanted},
    "before": before, "after": after, "log": log,
    "procsBefore": procs_before, "procsAfter": procs_after, "witness": receipt_witness,
    "registrationBefore": registration_before, "registrationAfter": registration_after,
}
with open(out_path + ".tmp", "w", encoding="utf-8") as handle:
    json.dump(observed, handle)
os.rename(out_path + ".tmp", out_path)
