#!/usr/bin/env python3
"""Runs inside the VM: reads the contract-only client's one JSON line on stdin
and prints it again with the `response` field replaced by its size. Only the
introspection answer needs this: it is about 39 kB, far more than the
TestAnyware agent's exec channel carries reliably, and a truncated line would
not parse at all. The response itself is written to a file by the client and
downloaded whole, so nothing is lost by not printing it.
"""
import json
import sys

answer = json.load(sys.stdin)
answer["responseBytes"] = len(json.dumps(answer.get("response")))
answer["response"] = None
print(json.dumps(answer))
