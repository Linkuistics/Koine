#!/usr/bin/env python3
"""Runs inside the VM, for the grant-workflow acceptance run: the cases
scripts/vm-verify-enrollment-client.py does not carry — enrolling many clients
at once against the server's two limits, denying in bulk over GraphQL, probing
what a pending requester may not do, and holding one keep-alive connection
across a revocation made in Koine's window.

It knows only the endpoint descriptor. Every client's 32-byte secret is its own,
made into a 0600 file, and Koine is sent only its SHA-256 digest; no secret and
no digest is ever printed. Prints one JSON object on one line.

The TestAnyware agent repeats a command it falsely reports as timed out
(docs/verification/resident-app-vm.md), so every case here is safe to run again.
`batch` caches each enrolment's answer in a file beside that client's secret and
replays it without reaching Koine, which is what keeps the server-wide
enrollment budget spent exactly once per client however often the exec repeats.

usage: vm-verify-grant-workflow-client.py batch <dir> <prefix> <first> <count> [capability...]
       vm-verify-grant-workflow-client.py poll <dir> <label>
       vm-verify-grant-workflow-client.py deny-pending <secret file> [keep label...]
       vm-verify-grant-workflow-client.py forbidden <secret file> <request id>
       vm-verify-grant-workflow-client.py keepalive <secret file> <ready file> <go file> <out file>
"""
import base64, hashlib, json, os, sys, time, urllib.error, urllib.request
import http.client

ENROL = """mutation($input: KoineRequestGrantInput!) {
  koineRequestGrant(input: $input) { requestId comparisonCode }
}"""
POLL = """{ koineGrantRequest { requestId clientLabel comparisonCode requestedCapabilities state
  grant { grantId clientLabel capabilities state } } }"""
MANAGE = """{ koineManagement {
  requests { requestId clientLabel state }
  grants { grantId clientLabel capabilities state } } }"""
DENY = """mutation($id: ID!) { koineDenyGrantRequest(requestId: $id) { requestId state } }"""
APPROVE = """mutation($id: ID!, $capabilities: [String!]!) {
  koineApproveGrantRequest(requestId: $id, capabilities: $capabilities) { grantId state }
}"""
# Authorization is checked before the reference is resolved, so the reference
# needs only to be well formed: what is being asked is whether a pending
# requester reaches a provider operation at all.
PROVIDER = """{ desktopApplicationByReference(ref: "koine://desktop/application/1/0.0") { name } }"""
OWN = "{ koine { ownGrant { grantId clientLabel capabilities state } } }"


def endpoint():
    data = os.path.expanduser("~/Library/Application Support/Koine")
    with open(os.path.join(data, "endpoint.json")) as file:
        return json.load(file)


def ask(bearer, query, variables=None):
    """One request on a connection of its own. Returns status, body, headers."""
    where = endpoint()
    headers = {"Content-Type": "application/json"}
    if bearer is not None:
        headers["Authorization"] = "Bearer " + bearer
    request = urllib.request.Request(
        "http://127.0.0.1:%d%s" % (where["port"], where["path"]),
        data=json.dumps({"query": query, "variables": variables or {}}).encode(),
        headers=headers,
    )
    try:
        with urllib.request.urlopen(request, timeout=20) as response:
            return response.status, json.load(response), dict(response.headers)
    except urllib.error.HTTPError as error:
        raw = error.read()
        try:
            return error.code, json.loads(raw), dict(error.headers)
        except ValueError:
            return error.code, None, dict(error.headers)


def secret_bytes(path):
    """This client's own secret, made once: unpadded base64url in a 0600 file."""
    if not os.path.exists(path):
        encoded = base64.urlsafe_b64encode(os.urandom(32)).rstrip(b"=")
        descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(descriptor, "wb") as file:
            file.write(encoded)
    encoded = open(path, "rb").read().strip()
    return base64.urlsafe_b64decode(encoded + b"=" * (-len(encoded) % 4))


def enrol_once(directory, label, capabilities):
    """Cached: a replay of this exec reaches Koine for a label only once."""
    kept = os.path.join(directory, label + ".answer.json")
    if os.path.exists(kept):
        return json.load(open(kept))
    digest = hashlib.sha256(secret_bytes(os.path.join(directory, label + ".secret"))).hexdigest()
    status, response, headers = ask(
        None, ENROL,
        {"input": {"clientLabel": label, "credentialDigest": digest, "capabilities": capabilities}},
    )
    receipt = ((response or {}).get("data") or {}).get("koineRequestGrant") or {}
    answer = {
        "label": label,
        "status": status,
        "requestId": receipt.get("requestId"),
        "comparisonCode": receipt.get("comparisonCode"),
        # The two refusals this run exists to tell apart: 429 carries
        # Retry-After and no GraphQL error extensions; the pending cap is an
        # ordinary 200 carrying reason "pending-request-limit".
        "retryAfter": headers.get("Retry-After"),
        "reasons": [
            (error.get("extensions") or {}).get("reason")
            for error in (response or {}).get("errors") or []
        ],
        "messages": [error.get("message") for error in (response or {}).get("errors") or []],
    }
    with open(kept, "w") as file:
        json.dump(answer, file)
    return answer


def main():
    case = sys.argv[1]
    if case == "batch":
        directory, prefix, first, count = sys.argv[2], sys.argv[3], int(sys.argv[4]), int(sys.argv[5])
        capabilities = sys.argv[6:]
        os.makedirs(directory, exist_ok=True)
        results = [
            enrol_once(directory, "%s-%02d" % (prefix, index), capabilities)
            for index in range(first, first + count)
        ]
        print(json.dumps({"case": case, "results": results}))

    elif case == "poll":
        directory, label = sys.argv[2], sys.argv[3]
        bearer = open(os.path.join(directory, label + ".secret")).read().strip()
        status, response, _ = ask(bearer, POLL)
        print(json.dumps({"case": case, "label": label, "status": status, "response": response}))

    elif case == "deny-pending":
        # Every pending request but the ones named, denied over GraphQL by a
        # koine:manage bearer.
        #
        # What this REPORTS is the state of every request afterwards, not the
        # set it changed. The agent repeats an exec it falsely reports as timed
        # out, and a second run of this has nothing left to deny: reporting the
        # change made the repeat say "denied nothing" about work the first run
        # had already done, and a run died on that. The states are the same
        # whichever run prints them, so every assertion is made against those.
        keep = set(sys.argv[3:])
        bearer = open(sys.argv[2]).read().strip()

        def listing():
            status, response, _ = ask(bearer, MANAGE)
            management = ((response or {}).get("data") or {}).get("koineManagement")
            return status, (management or {}).get("requests") or [], (response or {}).get("errors") or []

        status, requests, errors = listing()
        denied = []
        for request in requests:
            if request["state"] != "PENDING" or request["clientLabel"] in keep:
                continue
            answer_status, answer, _ = ask(bearer, DENY, {"id": request["requestId"]})
            denied.append({
                "label": request["clientLabel"], "status": answer_status,
                "state": (((answer or {}).get("data") or {}).get("koineDenyGrantRequest") or {}).get("state"),
            })
        after_status, after, after_errors = listing()
        print(json.dumps({
            "case": case, "denied": denied,
            # The read's own status and errors, so that an empty listing is
            # never mistaken for an empty set of requests.
            "listStatus": [status, after_status],
            "listErrors": [error.get("message") for error in errors + after_errors],
            "states": {request["clientLabel"]: request["state"] for request in after},
            "pending": len([request for request in after if request["state"] == "PENDING"]),
        }))

    elif case == "forbidden":
        # What a pending requester's secret may and may not do. It reads its own
        # request; it approves nothing, enumerates nothing, and reaches no
        # provider operation.
        bearer = open(sys.argv[2]).read().strip()
        probes = {}
        for name, query, variables in (
            ("own-request", POLL, None),
            ("approve-itself", APPROVE, {"id": sys.argv[3], "capabilities": ["desktop:read"]}),
            ("enumerate", MANAGE, None),
            ("provider", PROVIDER, None),
            ("own-grant", OWN, None),
        ):
            status, response, _ = ask(bearer, query, variables)
            probes[name] = {
                "status": status,
                "data": (response or {}).get("data"),
                "kinds": [
                    (error.get("extensions") or {}).get("kind")
                    for error in (response or {}).get("errors") or []
                ],
            }
        print(json.dumps({"case": case, "probes": probes}))

    elif case == "keepalive":
        # One TCP connection held across a revocation made in Koine's window.
        # The local port is recorded on both sides of it: equal ports are the
        # witness that the second request did not open a new connection.
        secret, ready, go, out = sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
        if os.path.exists(out):
            print(open(out).read().strip())
            return
        bearer = open(secret).read().strip()
        where = endpoint()
        connection = http.client.HTTPConnection("127.0.0.1", where["port"], timeout=20)
        headers = {"Content-Type": "application/json", "Authorization": "Bearer " + bearer}
        body = json.dumps({"query": OWN}).encode()

        def send():
            # The local port is read from the socket the request was written
            # on, before the response is consumed, so it describes that request
            # and not whatever the connection became afterwards. A server that
            # closed the connection is reported as the error it raises here
            # rather than papered over by reconnecting: reconnecting would
            # answer a different question than the one being asked.
            try:
                connection.request("POST", where["path"], body=body, headers=headers)
                port = connection.sock.getsockname()[1]
                response = connection.getresponse()
                payload = response.read()
            except Exception as error:  # noqa: BLE001 - reported, not handled
                return {"error": "%s: %s" % (type(error).__name__, error)}
            try:
                parsed = json.loads(payload)
            except ValueError:
                parsed = None
            return {
                "status": response.status,
                "port": port,
                "connection": response.getheader("Connection"),
                "authenticate": response.getheader("WWW-Authenticate"),
                "data": (parsed or {}).get("data"),
            }

        before = send()
        open(ready, "w").write("ready\n")
        # The host revokes the grant in the window and then touches `go`.
        deadline = time.time() + 300
        while not os.path.exists(go) and time.time() < deadline:
            time.sleep(1)
        after = send()
        answer = json.dumps({
            "case": case, "before": before, "after": after,
            "sameConnection": "port" in before and before.get("port") == after.get("port"),
        })
        with open(out, "w") as file:
            file.write(answer)
        print(answer)

    else:
        raise SystemExit("unknown case: " + case)


main()
