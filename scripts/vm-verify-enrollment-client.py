#!/usr/bin/env python3
"""Runs inside the VM: a client that enrols itself. It knows only the endpoint
descriptor. It generates its own 32-byte secret into a protected file, sends
Koine the secret's SHA-256 digest and never the secret, and afterwards presents
the unchanged secret as its bearer. Neither the secret nor its digest is ever
printed. Prints one JSON object on one line: {"case", "status", "response"}.

Every case is safe to run again, because the TestAnyware agent repeats a command
it falsely reports as timed out: enrol reuses the secret file, so Koine answers
the identical retry with the original receipt; approve keeps its first answer
beside the secret file and prints that again.

usage: vm-verify-enrollment-client.py <secret file> enrol <label> [capability...]
       vm-verify-enrollment-client.py <secret file> poll
       vm-verify-enrollment-client.py <secret file> own
       vm-verify-enrollment-client.py <secret file> manage
       vm-verify-enrollment-client.py <secret file> approve <request id> [capability...]
       vm-verify-enrollment-client.py <secret file> shown-in <file>
"""
import base64, hashlib, json, os, sys, urllib.error, urllib.request

ENROL = """mutation($input: KoineRequestGrantInput!) {
  koineRequestGrant(input: $input) { requestId comparisonCode }
}"""
POLL = """{ koineGrantRequest { requestId clientLabel comparisonCode requestedCapabilities state
  grant { grantId clientLabel capabilities state } } }"""
OWN = "{ koine { ownGrant { grantId clientLabel capabilities state } } }"
MANAGE = """{ koineManagement {
  requests { requestId clientLabel comparisonCode requestedCapabilities state }
  grants { grantId clientLabel capabilities state } } }"""
APPROVE = """mutation($id: ID!, $capabilities: [String!]!) {
  koineApproveGrantRequest(requestId: $id, capabilities: $capabilities) { grantId clientLabel capabilities state }
}"""


def ask(bearer, query, variables=None):
    data = os.path.expanduser("~/Library/Application Support/Koine")
    with open(os.path.join(data, "endpoint.json")) as file:
        endpoint = json.load(file)
    headers = {"Content-Type": "application/json"}
    if bearer is not None:
        headers["Authorization"] = "Bearer " + bearer
    request = urllib.request.Request(
        "http://127.0.0.1:%d%s" % (endpoint["port"], endpoint["path"]),
        data=json.dumps({"query": query, "variables": variables or {}}).encode(),
        headers=headers,
    )
    try:
        with urllib.request.urlopen(request, timeout=20) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        body = error.read()
        try:
            return error.code, json.loads(body)
        except ValueError:
            return error.code, None


def secret_bytes(path):
    """The client's own secret, made once: unpadded base64url in a 0600 file."""
    if not os.path.exists(path):
        encoded = base64.urlsafe_b64encode(os.urandom(32)).rstrip(b"=")
        descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(descriptor, "wb") as file:
            file.write(encoded)
    encoded = open(path, "rb").read().strip()
    return base64.urlsafe_b64decode(encoded + b"=" * (-len(encoded) % 4))


def main():
    path, case = sys.argv[1], sys.argv[2]
    if case == "enrol":
        digest = hashlib.sha256(secret_bytes(path)).hexdigest()
        variables = {"input": {"clientLabel": sys.argv[3], "credentialDigest": digest, "capabilities": sys.argv[4:]}}
        status, response = ask(None, ENROL, variables)
    elif case == "shown-in":
        # Whether the secret or its digest occurs in a file, answered here so
        # that neither leaves the guest.
        text = open(sys.argv[3], "rb").read()
        encoded = open(path, "rb").read().strip()
        digest = hashlib.sha256(secret_bytes(path)).hexdigest().encode()
        print(json.dumps({"case": case, "secret": encoded in text, "digest": digest in text, "bytes": len(text)}))
        return
    else:
        bearer = open(path).read().strip()
        if case == "approve":
            kept = "%s.approve-%s.json" % (path, sys.argv[3])
            if os.path.exists(kept):
                print(open(kept).read().strip())
                return
            status, response = ask(bearer, APPROVE, {"id": sys.argv[3], "capabilities": sys.argv[4:]})
            with open(kept, "w") as file:
                file.write(json.dumps({"case": case, "status": status, "response": response}))
        else:
            status, response = ask(bearer, {"poll": POLL, "own": OWN, "manage": MANAGE}[case])
    print(json.dumps({"case": case, "status": status, "response": response}))


main()
