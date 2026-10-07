#!/usr/bin/env python3
# ruff: noqa: E501  (the mutation texts are verbatim lines of the Swift source)
"""Shows that the location-walk tests go red against a walk that is wrong.

A control that has never been seen to fail is not a control (grove's rule for a clean
read). The walk tests (`LocationWalkTests`, S), the planner tests (`RevealLocationTests`,
L) and the signed-bundle tests (`WorkspaceLongLocationTests`, N) all pass against the walk
as it is. This breaks one decision of the shipped source at a time, in a COPY of the tree
(.build/location-walk-mutations/tree, with its own build directory, so later runs are
incremental), rebuilds the copy's tests and its independently built, signed workspace
bundle from the mutated source, and runs each named suite. A mutation is seen when every
suite it names fails; a suite a mutation names as `-` is one it cannot reach (a
descriptor leak, or a change of link text between two reads, is invisible through the
bundle), and is stated rather than counted.

The working tree is never edited.

usage: check-location-walk-mutations.py [<output>] [<mutation> ...]
Writes <output>/mutations.json (default .build/location-walk-mutations/mutations.json);
exits 1 if any mutation is not seen.
"""

import json
import os
import subprocess
import sys

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORK = os.path.join(REPOSITORY, ".build", "location-walk-mutations")
TREE = os.path.join(WORK, "tree")
LOGIC = "Providers/WorkspaceProvider/Logic/"
WALK = LOGIC + "LocationWalk.swift"
LIMIT = LOGIC + "HandOffLimit.swift"
REVEAL = LOGIC + "RevealPath.swift"

SUITES = {"S": "LocationWalkTests", "L": "RevealLocationTests", "N": "WorkspaceLongLocationTests"}

# name -> (file, text to replace, replacement, suites that must go red)
MUTATIONS = {
    "budget-allows-a-33rd-link": (
        WALK,
        "guard expansions.count < LocationWalk.linkBudget",
        "guard expansions.count <= LocationWalk.linkBudget",
        "SN",
    ),
    "budget-stops-at-31": (WALK, "static let linkBudget = 32", "static let linkBudget = 31", "SN"),
    "a-repeated-state-is-not-a-cycle": (
        WALK,
        "if visited.contains(state) {",
        "if false && visited.contains(state) {",
        "SN",
    ),
    "state-without-the-containing-directory": (
        WALK,
        "LinkState(directory: containing, text: text, suffix: rest)",
        "LinkState(directory: ObjectIdentity(device: 0, inode: 0), text: text, suffix: rest)",
        "SN",
    ),
    "state-without-the-pending-suffix": (
        WALK,
        "LinkState(directory: containing, text: text, suffix: rest)",
        "LinkState(directory: containing, text: text, suffix: [])",
        "SN",
    ),
    "dot-dot-does-not-leave-the-directory": (
        WALK,
        "                    current = parent\n                    if !stack.isEmpty { stack.removeLast() }\n",
        "                    current = parent\n",
        "SN",
    ),
    "an-absolute-link-keeps-the-old-directory": (
        WALK,
        "            stack = []\n        }\n        pending = remainder",
        "        }\n        pending = remainder",
        "SN",
    ),
    "a-final-directory-is-opened": (
        WALK,
        "                // Examined and never opened: a final directory needs no search permission of its own.\n",
        "                if case .failure(let error) = system.openDirectory(in: handle, name: name) {\n"
        "                    return classify(error, component: name, in: handle)\n                }\n",
        "SN",
    ),
    "a-trailing-slash-demands-nothing": (
        WALK,
        "let demandsDirectory = !rest.isEmpty && isFinal",
        "let demandsDirectory = false",
        "SN",
    ),
    "slash-runs-are-distinct-states": (
        WALK,
        "suffix: Self.collapsingSlashes(rest))",
        "suffix: rest)",
        "SN",
    ),
    "a-changed-link-text-is-not-noticed": (
        WALK,
        "if let before = linkTexts[status.identity], before != text {",
        "if false {",
        "S",
    ),
    "a-non-ascii-name-can-be-impossible": (
        WALK,
        "if name.allSatisfy({ $0 < 0x80 }), name.count > limit {",
        "if name.count > limit {",
        "SN",
    ),
    "an-unreadable-name-limit-is-read-as-absence": (
        WALK,
        'return .failed(component: component, cause: "its name is too long and the filesystem\'s name limit cannot be read")',
        "return .absent(.impossibleComponent(component: component))",
        "S",
    ),
    "every-name-too-long-is-absent": (
        WALK,
        "            return .failed(component: component, cause: error.message)\n        default:",
        "            return .absent(.impossibleComponent(component: component))\n        default:",
        "SN",
    ),
    "a-denial-is-absence": (
        WALK,
        "        default: return .failed(component: component, cause: error.message)\n        }\n    }",
        "        default: return .absent(.missing(component: component))\n        }\n    }",
        "SN",
    ),
    "the-directory-handle-is-not-closed": (
        WALK,
        "                case .success(let next):\n                    system.close(handle)\n                    current = next\n                    stack.append(name)",
        "                case .success(let next):\n                    current = next\n                    stack.append(name)",
        "S-",
    ),
    "the-limit-is-one-byte-too-high": (
        LIMIT,
        "where spelling.byteCount >= pathMax",
        "where spelling.byteCount > pathMax",
        "SLN",
    ),
    "the-limit-ignores-expansions": (
        LIMIT,
        "where spelling.byteCount >= pathMax {",
        "where spelling.byteCount >= pathMax && kind != .expanded(number: 1) && kind != .expanded(number: 2) {",
        "SLN",
    ),
    "the-limit-counts-the-terminating-nul": (
        LIMIT,
        "static let pathMax = 1024",
        "static let pathMax = 1023",
        "SLN",
    ),
    "an-impossible-name-or-cycle-is-failed": (
        REVEAL,
        "    case .absent:\n        return .dependency(",
        '    case .absent(let why) where why.isImpossibleOrCycle:\n        return .failed("x")\n    case .absent:\n        return .dependency(',
        "LN",
    ),
    "a-failed-walk-is-a-missing-path": (
        REVEAL,
        '    case .failed(let component, let cause):\n        return .failed("The path could not be resolved at \\(component.debugDescription): \\(cause).")',
        '    case .failed:\n        return .dependency(.pathNotFound, guidance: "x")',
        "LN",
    ),
    "the-limit-is-not-applied": (
        REVEAL,
        'if let refusal = HandOffLimit.refusal(of: location, forAction: "revealed") { return .failed(refusal) }',
        "",
        "LN",
    ),
}


def run(command, cwd, log):
    with open(log, "ab") as out:
        out.write(("\n$ " + " ".join(command) + "\n").encode())
        return subprocess.run(command, cwd=cwd, stdout=out, stderr=subprocess.STDOUT).returncode


def sync():
    os.makedirs(TREE, exist_ok=True)
    subprocess.run(
        [
            "rsync",
            "-a",
            "--delete",
            "--exclude",
            "/.build",
            "--exclude",
            "/.grove",
            "--exclude",
            "/.jj",
            "--exclude",
            "/.git",
            REPOSITORY + "/",
            TREE + "/",
        ],
        check=True,
    )


def main():
    args = sys.argv[1:]
    output = args[0] if args and args[0] not in MUTATIONS else os.path.join(WORK, "mutations.json")
    names = [a for a in args if a in MUTATIONS] or list(MUTATIONS)
    os.makedirs(WORK, exist_ok=True)
    log = os.path.join(WORK, "run.log")
    results = {}
    for name in names:
        file, old, new, suites = MUTATIONS[name]
        sync()
        path = os.path.join(TREE, file)
        text = open(path).read()
        if text.count(old) != 1:
            results[name] = {
                "seen": False,
                "error": f"expected one occurrence of the text, found {text.count(old)}",
            }
            print(f"{name}: NOT APPLIED ({results[name]['error']})", flush=True)
            continue
        open(path, "w").write(text.replace(old, new))
        built = (
            run(["swift", "build", "--build-tests"], TREE, log) == 0
            and run(["task", "bundled-providers"], TREE, log) == 0
        )
        record = {"suites": {}}
        if not built:
            record["error"] = "the mutated tree did not build"
        else:
            for key, suite in SUITES.items():
                if key not in suites:
                    continue
                red = run(["swift", "test", "--skip-build", "--filter", suite], TREE, log) != 0
                record["suites"][suite] = "red" if red else "green"
        record["seen"] = built and all(state == "red" for state in record["suites"].values())
        record["unreachable"] = [SUITES[k] for k in SUITES if k not in suites]
        results[name] = record
        print(f"{name}: {'seen' if record['seen'] else 'NOT SEEN'} {record['suites']}", flush=True)
    os.makedirs(os.path.dirname(output), exist_ok=True)
    with open(output, "w") as out:
        json.dump(results, out, indent=2)
        out.write("\n")
    if not all(r["seen"] for r in results.values()):
        sys.exit(1)


if __name__ == "__main__":
    main()
