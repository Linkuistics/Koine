#!/usr/bin/env python3
"""Runs inside the VM: captures the running Koine's introspection response, as a
client with nothing but the endpoint descriptor, a protected credential file and
the query text would. The response is written to a file rather than printed,
because a full introspection answer is far larger than the agent's exec channel
carries reliably; the host downloads it. One JSON line is printed:
{"status", "bytes", "path", "errors", "contractVersion", "schemaDigest"}.

`Koine.schemaDigest` is read in the same session and over the same connection as
the introspection, so the digest the host checks the design contract against is
the digest of the schema that answered.

usage: vm-verify-introspect.py <credential file> <query file> <output file>
"""
import json, os, sys, urllib.request

KOINE = "{ koine { contractVersion schemaDigest } }"


def endpoint():
    data = os.path.expanduser("~/Library/Application Support/Koine")
    with open(os.path.join(data, "endpoint.json")) as file:
        return json.load(file)


def post(credential, query):
    descriptor = endpoint()
    request = urllib.request.Request(
        "http://127.0.0.1:%d%s" % (descriptor["port"], descriptor["path"]),
        data=json.dumps({"query": query, "variables": {}}).encode(),
        headers={"Content-Type": "application/json", "Authorization": "Bearer " + credential},
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return response.status, response.read()
    except urllib.error.HTTPError as error:  # a refusal is an answer worth keeping
        return error.code, error.read()


def main():
    credential = open(sys.argv[1]).read().strip()
    query = open(sys.argv[2]).read()
    status, body = post(credential, query)
    with open(sys.argv[3], "wb") as file:
        file.write(body)
    try:
        errors = [error.get("message") for error in (json.loads(body).get("errors") or [])]
    except ValueError:
        errors = ["the response is not JSON"]
    koine = {}
    try:
        _, metadata = post(credential, KOINE)
        koine = json.loads(metadata)["data"]["koine"]
    except Exception as failure:  # reported, never swallowed
        koine = {"error": str(failure)}
    print(json.dumps({
        "status": status, "bytes": len(body), "path": sys.argv[3], "errors": errors,
        "contractVersion": koine.get("contractVersion"), "schemaDigest": koine.get("schemaDigest"),
    }))


main()
