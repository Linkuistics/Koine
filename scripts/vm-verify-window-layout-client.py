#!/usr/bin/env python3
"""Runs inside the VM: a window layout client that knows only the endpoint
descriptor, a protected credential file and the example operations of the
window layout design. It sends each operation with the text that
docs/design/desktop-window-layout-operations.graphql has for it, unchanged.
Prints one JSON object on one line: {"case", "variables", "response"}.

usage: vm-verify-window-layout-client.py <credential file> <operations file> list
       vm-verify-window-layout-client.py <credential file> <operations file> displays
       vm-verify-window-layout-client.py <credential file> <operations file> frame <window reference>
       vm-verify-window-layout-client.py <credential file> <operations file> set-frame <window reference> <x> <y> <width> <height>
       vm-verify-window-layout-client.py <credential file> <operations file> on-top <window reference> <x> <y>
       vm-verify-window-layout-client.py <credential file> <operations file> focus-display <display reference>
       vm-verify-window-layout-client.py <credential file> <operations file> disclosures
       vm-verify-window-layout-client.py <credential file> <operations file> grants
The last two are management reads under a koine:manage grant, outside the operations file.
"""
import json, os, sys, urllib.request


def operation(path, name):
    """One named operation of a GraphQL document whose operations are separated by
    blank lines. Comment lines before an operation are not part of its text."""
    for block in open(path).read().split("\n\n"):
        lines = [line for line in block.strip().splitlines() if not line.startswith("#")]
        if not lines:
            continue
        words = lines[0].replace("(", " ").replace("{", " ").split()
        if words[:1] in (["query"], ["mutation"]) and words[1:2] == [name]:
            return "\n".join(lines) + "\n"
    raise SystemExit("no operation %s in %s" % (name, path))


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


DISCLOSURES = "{ koineManagement { capabilityDisclosures { capability disclosure } } }"
GRANTS = "{ koineManagement { grants { grantId clientLabel capabilities state } } }"


def main():
    credential = open(sys.argv[1]).read().strip()
    operations, case, rest = sys.argv[2], sys.argv[3], sys.argv[4:]
    if case == "list":
        name, variables = "DesktopWindowList", {}
    elif case == "displays":
        name, variables = "DesktopDisplayList", {}
    elif case == "frame":
        name, variables = "DesktopWindowFrame", {"ref": rest[0]}
    elif case == "set-frame":
        x, y, width, height = (float(value) for value in rest[1:5])
        name, variables = "SetDesktopWindowFrame", {"ref": rest[0], "frame": {"x": x, "y": y, "width": width, "height": height}}
    elif case == "on-top":
        name, variables = "DesktopWindowOnTopAt", {"ref": rest[0], "point": {"x": float(rest[1]), "y": float(rest[2])}}
    elif case == "focus-display":
        name, variables = "FocusDesktopDisplay", {"ref": rest[0]}
    elif case in ("disclosures", "grants"):
        query = DISCLOSURES if case == "disclosures" else GRANTS
        print(json.dumps({"case": case, "variables": {}, "response": ask(credential, query, {})}))
        return
    else:
        raise SystemExit("unknown case %s" % case)
    print(json.dumps({"case": case, "variables": variables, "response": ask(credential, operation(operations, name), variables)}))


main()
