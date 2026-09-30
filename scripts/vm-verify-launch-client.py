#!/usr/bin/env python3
"""Runs inside the VM: a workspace client that knows only the endpoint descriptor,
a protected credential file and the operations of docs/design/workspace-operations.graphql,
sent as that file has them, text unchanged (comments dropped, and the fragment an
operation spreads sent with it). Prints one JSON object per line. Every request
is stamped with the guest's clock in milliseconds since the epoch before it is sent
and when its answer arrives, the same clock scripts' LaunchWitness stamps its
observations with, so the witness's activation is placed between the two.

usage: vm-verify-launch-client.py <credential file> <operations file> launch <bundle identifier> [<application path>]
       vm-verify-launch-client.py <credential file> <operations file> capture <pid> <startedAt>
       vm-verify-launch-client.py <credential file> <operations file> capture-plain <pid> <startedAt>
       vm-verify-launch-client.py <credential file> <operations file> raw <operation name> <variables as JSON>
       vm-verify-launch-client.py <credential file> - grant <label> <new credential file> <capability>...
       vm-verify-launch-client.py <credential file> - revoke <grant id>
The last two are koine:manage operations (koineCreateGrant, koineRevokeGrant): the
window's grant form scrolls out of reach once several grants are listed, so the
grants a run needs beyond its first are made by that first one, as the window's
own client makes them. A new credential goes to its file, mode 0600, and is not printed.
"""
import json, os, re, sys, time, urllib.error, urllib.request


def blocks(path):
    """The document's definitions: blank-line separated, comment lines dropped."""
    found = {}
    for block in open(path).read().split("\n\n"):
        text = "\n".join(line for line in block.splitlines() if not line.lstrip().startswith("#")).strip()
        match = re.match(r"(fragment|query|mutation)\s+(\w+)", text)
        if match:
            found[match.group(2)] = text + "\n"
    return found


def operation(path, name):
    """The named operation with every fragment it spreads."""
    found = blocks(path)
    if name not in found:
        raise SystemExit("no operation %s in %s" % (name, path))
    text = found[name]
    for fragment in re.findall(r"\.\.\.(\w+)", text):
        text += "\n" + found[fragment]
    return text


def ask(credential, query, variables):
    data = os.path.expanduser("~/Library/Application Support/Koine")
    with open(os.path.join(data, "endpoint.json")) as file:
        endpoint = json.load(file)
    request = urllib.request.Request(
        "http://127.0.0.1:%d%s" % (endpoint["port"], endpoint["path"]),
        data=json.dumps({"query": query, "variables": variables}).encode(),
        headers={"Content-Type": "application/json", "Authorization": "Bearer " + credential},
    )
    sent = round(time.time() * 1000)
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            status, body = response.status, json.load(response)
    except urllib.error.HTTPError as error:
        # A refusal before execution (401 for a revoked credential, 403 for a missing
        # capability) carries its body as a JSON error object, or none.
        status, body = error.code, error.read().decode(errors="replace")
        try:
            body = json.loads(body) if body else None
        except ValueError:
            pass
    return {"httpStatus": status, "sentMs": sent, "receivedMs": round(time.time() * 1000), "response": body}


def main():
    credential = open(sys.argv[1]).read().strip()
    path, case = sys.argv[2], sys.argv[3]
    if path == "-" and case not in ("grant", "revoke"):
        raise SystemExit(__doc__)
    if case == "launch":
        application = {"bundleIdentifier": sys.argv[4]}
        if len(sys.argv) > 5:
            application["applicationPath"] = sys.argv[5]
        answer = ask(credential, operation(path, "LaunchInstalledApplication"), {"application": application})
    elif case == "capture":
        process = {"pid": int(sys.argv[4]), "startedAt": sys.argv[5]}
        answer = ask(credential, operation(path, "CaptureOpenedApplication"), {"process": process})
    elif case == "capture-plain":
        # The same call without the windows field, which is what needs Accessibility consent.
        process = {"pid": int(sys.argv[4]), "startedAt": sys.argv[5]}
        answer = ask(credential, """query($process: DesktopProcessIdentity!) {
  desktopApplication(process: $process) { ref name bundleIdentifier }
}""", {"process": process})
    elif case == "grant":
        label, target, capabilities = sys.argv[4], sys.argv[5], sys.argv[6:]
        answer = ask(credential, """mutation($label: String!, $capabilities: [String!]!) {
  koineCreateGrant(input: { clientLabel: $label, capabilities: $capabilities }) { credential grant { grantId clientLabel capabilities state } }
}""", {"label": label, "capabilities": capabilities})
        created = (answer["response"].get("data") or {}).get("koineCreateGrant") if isinstance(answer["response"], dict) else None
        if created:
            descriptor = os.open(os.path.expanduser(target), os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
            with os.fdopen(descriptor, "w") as file:
                file.write(created.pop("credential"))
    elif case == "revoke":
        answer = ask(credential, """mutation($id: ID!) { koineRevokeGrant(grantId: $id) { grantId clientLabel capabilities state } }""",
                     {"id": sys.argv[4]})
    elif case == "raw":
        answer = ask(credential, operation(path, sys.argv[4]), json.loads(sys.argv[5]))
    else:
        raise SystemExit(__doc__)
    print(json.dumps({"case": case, **answer}))


main()
