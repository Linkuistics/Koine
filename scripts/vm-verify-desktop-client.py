#!/usr/bin/env python3
"""Runs inside the VM: a desktop client that knows only the endpoint descriptor,
a protected credential file and an application's name. It captures the process
identity as any client must: the PID, and the kernel's start instant for it
(proc_pidinfo PROC_PIDTBSDINFO, whole microseconds) in the contract's canonical
UTC form. Prints one JSON object per line: {"case", "pid", "startedAt", "response"}.
A reference it was given is passed back unchanged: {"case", "ref", "response"}.
With --operations, DesktopChoices and FocusDesktopWindow are sent as that file
has them, text unchanged (docs/design/desktop-operations.graphql); the file's
other operations name fields a later stage serves, so each is sent alone.

usage: vm-verify-desktop-client.py <credential file> <application name> [exact|plain|later|malformed|absent]
       vm-verify-desktop-client.py <credential file> --ref application|application-plain|window <reference>
       vm-verify-desktop-client.py <credential file> --operations <file> choices <application name>
       vm-verify-desktop-client.py <credential file> --operations <file> focus <reference>
       vm-verify-desktop-client.py <credential file> --type <GraphQL type name>
"""
import ctypes, datetime, json, os, subprocess, sys, urllib.request

QUERY = """query($process: DesktopProcessIdentity!) {
  desktopApplication(process: $process) { ref name bundleIdentifier windows { ref title observation } }
}"""

# The application fields that need no Accessibility consent.
PLAIN = """query($process: DesktopProcessIdentity!) {
  desktopApplication(process: $process) { ref name bundleIdentifier }
}"""
BY_REFERENCE = {
    "application": """query($ref: Reference!) {
  desktopApplicationByReference(ref: $ref) { ref name bundleIdentifier windows { ref title observation } }
}""",
    "application-plain": "query($ref: Reference!) { desktopApplicationByReference(ref: $ref) { ref name bundleIdentifier } }",
    "window": "query($ref: Reference!) { desktopWindow(ref: $ref) { ref title observation } }",
}


def operation(path, name):
    """One named operation of a GraphQL document whose operations are separated by blank lines."""
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


def ask(credential, query, variables):
    data = os.path.expanduser("~/Library/Application Support/Koine")
    with open(os.path.join(data, "endpoint.json")) as file:
        endpoint = json.load(file)
    request = urllib.request.Request(
        "http://127.0.0.1:%d%s" % (endpoint["port"], endpoint["path"]),
        data=json.dumps({"query": query, "variables": variables}).encode(),
        headers={"Content-Type": "application/json", "Authorization": "Bearer " + credential},
    )
    with urllib.request.urlopen(request, timeout=20) as response:
        return json.load(response)


def main():
    credential = open(sys.argv[1]).read().strip()
    if sys.argv[2] == "--ref":
        kind, ref = sys.argv[3], sys.argv[4]
        print(json.dumps({"case": kind, "ref": ref, "response": ask(credential, BY_REFERENCE[kind], {"ref": ref})}))
        return
    if sys.argv[2] == "--type":
        query = "query($name: String!) { __type(name: $name) { fields { name } } }"
        print(json.dumps({"case": "type", "response": ask(credential, query, {"name": sys.argv[3]})}))
        return
    if sys.argv[2] == "--operations" and sys.argv[4] == "focus":
        ref = sys.argv[5]
        response = ask(credential, operation(sys.argv[3], "FocusDesktopWindow"), {"ref": ref})
        print(json.dumps({"case": "focus", "ref": ref, "response": response}))
        return
    designed = sys.argv[2] == "--operations"
    name, case = (sys.argv[5], "choices") if designed else (sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else "exact")
    pid = int(subprocess.check_output(["pgrep", "-x", name]).split()[0])
    micros = start_microseconds(pid)
    if designed:
        process = {"pid": pid, "startedAt": canonical(micros)}
        response = ask(credential, operation(sys.argv[3], "DesktopChoices"), {"process": process})
        print(json.dumps({"case": case, **process, "response": response}))
        return
    process = {
        "exact": {"pid": pid, "startedAt": canonical(micros)},
        "plain": {"pid": pid, "startedAt": canonical(micros)},
        # The same live PID, claimed one microsecond later: a different process.
        "later": {"pid": pid, "startedAt": canonical(micros + 1)},
        "malformed": {"pid": pid, "startedAt": canonical(micros)[:-8] + "Z"},  # whole seconds
        "absent": {"pid": 1_000_000, "startedAt": canonical(micros)},
    }[case]
    print(json.dumps({"case": case, **process, "response": ask(credential, PLAIN if case == "plain" else QUERY, {"process": process})}))


main()
