#!/usr/bin/env python3
# ruff: noqa: E501  (the mutation texts are verbatim lines of the Swift source)
"""Shows that the location-walk tests go red against a walk that is wrong.

A control that has never been seen to fail is not a control (grove's rule for a clean
read). The walk tests (`LocationWalkTests`, S), the planner tests (`RevealLocationTests`, L, and
`OpenLocationTests`, O), the supplied-application stage's planner tests (`ApplicationLocationTests`, A, and
`WorkspaceInstallationsCompositionTests`, G), the discovered-application stage's planner tests
(`DiscoveredApplicationTests`, D, and `WorkspaceCompositionTests`, C, for the browser, the default handler and Finder through
the public engine) and the signed-bundle tests (`WorkspaceLongLocationTests`, N, which
asks both a reveal and an open, and `WorkspaceApplicationLocationTests`, B, which asks a constrained launch and a
named open), the receipt's executable-identity rule (`ExecutableIdentityTests`, X, and `ObservationTests`, V, and the
signed-bundle-side `ReceiptExecutableIdentityTests`, R, which runs the shipped adapter's two identities in an independently
built probe) all pass against the walk as it is. This breaks one decision of the shipped source at a time, in a COPY of the tree
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
TARGET = LOGIC + "TargetStage.swift"
OPEN = LOGIC + "OpenPath.swift"
APPLICATION = LOGIC + "ApplicationStage.swift"
DISCOVERED = LOGIC + "DiscoveredStage.swift"
SELECTION = LOGIC + "Selection.swift"
NATIVE = "Providers/WorkspaceProvider/Sources/NativeWorkspace.swift"
EXECUTABLE = LOGIC + "ExecutableIdentity.swift"
OBSERVATION = LOGIC + "Observation.swift"

# S: the walk's own source; L: reveal's planner; O: open's planner; A: the supplied-application stage's planner;
# G: that stage through the public engine; N: the signed bundle, asked for a reveal and an open of a path;
# B: the signed bundle, asked for a constrained launch and a named open; D: the discovered-application stage's planner;
# C: the discovered default handler, browser and Finder through the public engine; X: the receipt's executable-identity
# rule on the shipped walk; V: the receipt's observation rule; R: the receipt's two identities, live and retained, run by
# the shipped adapter in the independently built probe (`task fixture:receipt-identity-probe`).
SUITES = {
    "S": "LocationWalkTests",
    "L": "RevealLocationTests",
    "O": "OpenLocationTests",
    "A": "ApplicationLocationTests",
    "G": "WorkspaceInstallationsCompositionTests",
    "N": "WorkspaceLongLocationTests",
    "B": "WorkspaceApplicationLocationTests",
    "D": "DiscoveredApplicationTests",
    "C": "WorkspaceCompositionTests",
    "X": "ExecutableIdentityTests",
    "V": "ObservationTests",
    "R": "ReceiptExecutableIdentityTests",
}

# name -> (file, text to replace, replacement, suites that must go red)
MUTATIONS = {
    "budget-allows-a-33rd-link": (
        WALK,
        "guard expansions.count < LocationWalk.linkBudget",
        "guard expansions.count <= LocationWalk.linkBudget",
        "SNXR",
    ),
    "budget-stops-at-31": (WALK, "static let linkBudget = 32", "static let linkBudget = 31", "SNXR"),
    "a-repeated-state-is-not-a-cycle": (
        WALK,
        "if visited.contains(state) {",
        "if false && visited.contains(state) {",
        "SN",
    ),
    "state-without-the-containing-directory": (
        WALK,
        "LinkState(directory: containing, text: text, suffix: Self.collapsingSlashes(rest))",
        "LinkState(directory: ObjectIdentity(device: 0, inode: 0), text: text, suffix: Self.collapsingSlashes(rest))",
        "SN",
    ),
    "state-without-the-pending-suffix": (
        WALK,
        "LinkState(directory: containing, text: text, suffix: Self.collapsingSlashes(rest))",
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
        "suffix: Array(rest))",
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
        "SLONABDC",
    ),
    "the-limit-ignores-expansions": (
        LIMIT,
        "where spelling.byteCount >= pathMax {",
        "where spelling.byteCount >= pathMax && kind != .expanded(number: 1) && kind != .expanded(number: 2) {",
        "SLONABD",
    ),
    "the-limit-counts-the-terminating-nul": (
        LIMIT,
        "static let pathMax = 1024",
        "static let pathMax = 1023",
        "SLONABDC",
    ),
    "an-impossible-name-or-cycle-is-failed": (
        TARGET,
        "    case .absent:\n        return .absent(",
        '    case .absent(let why) where why.isImpossibleOrCycle:\n        return .failed("x")\n    case .absent:\n        return .absent(',
        "LON",
    ),
    "a-failed-walk-is-a-missing-path": (
        TARGET,
        '    case .failed(let component, let cause):\n        return .failed("The path could not be resolved at \\(component.debugDescription): \\(cause).")',
        '    case .failed:\n        return .absent(guidance: "x")',
        "LON",
    ),
    "the-limit-is-not-applied": (
        TARGET,
        "if let refusal = HandOffLimit.refusal(of: location, forAction: unaccomplished) { return .failed(refusal) }",
        "",
        "LON",
    ),
    "an-open-reads-metadata-from-the-literal-spelling": (
        NATIVE,
        "let representation = location.resolved.bytes.map",
        "let representation = location.literal.bytes.map",
        "NB",
    ),
    "a-later-metadata-absence-is-absence": (
        OPEN,
        'return .failed("The path could not be inspected: it was resolved, but its metadata reports nothing there.")',
        'return .dependency(.pathNotFound, guidance: "x")',
        "O",
    ),
    "the-payload-policy-is-not-applied-to-the-resolved-object": (
        OPEN,
        "if let reason = refusalReason(for: facts, native: native) { return .refused(reason) }",
        "",
        "ON",
    ),
    "an-open-submits-the-resolved-spelling": (
        OPEN,
        "let target = URL(fileURLWithPath: path.text, isDirectory: facts.isDirectory)",
        "let target = URL(fileURLWithPath: location.resolved.text, isDirectory: facts.isDirectory)",
        "O",
    ),
    "an-application-limit-is-not-applied-to-the-chosen-copy": (
        APPLICATION,
        '        if let refusal = HandOffLimit.refusal(of: found, forAction: action, noun: "application path") {\n'
        "            return .failed(refusal)\n        }\n        chosen = found",
        "        chosen = found",
        "AB",
    ),
    "the-bundle-is-read-before-the-limit": (
        APPLICATION,
        '        if let refusal = HandOffLimit.refusal(of: found, forAction: action, noun: "application path") {\n'
        "            return .failed(refusal)\n        }\n        chosen = found\n    }\n"
        "    switch native.readApplicationBundle(of: chosen) {",
        "        chosen = found\n    }\n    let early = native.readApplicationBundle(of: chosen)\n"
        '    if let refusal = HandOffLimit.refusal(of: chosen, forAction: action, noun: "application path") { return .failed(refusal) }\n'
        "    switch early {",
        "A",
    ),
    "the-limit-is-not-applied-to-the-selected-copy": (
        APPLICATION,
        '            if let refusal = HandOffLimit.refusal(of: copy, forAction: action, noun: "registered application path") {\n'
        "                return .failed(refusal)\n            }\n",
        "",
        "AG",
    ),
    "the-limit-is-applied-to-an-unequal-candidate": (
        APPLICATION,
        "        case .present:\n            continue  // another copy, however long its spelling",
        "        case .present(let other):\n"
        '            if let refusal = HandOffLimit.refusal(of: other, forAction: action, noun: "registered application path") { return .failed(refusal) }\n'
        "            continue",
        "AG",
    ),
    "an-impossible-name-or-cycle-at-the-chosen-path-is-absence": (
        APPLICATION,
        "    case .absent(let absence) where absence.isImpossibleOrCycle:\n"
        '        return .failed("The application path could not be resolved: \\(explanation(of: absence)).")\n',
        "",
        "AB",
    ),
    "a-failed-walk-at-the-chosen-path-is-absence": (
        APPLICATION,
        'return .failed("The application path could not be resolved at \\(component.debugDescription): \\(cause).")',
        "return notInstalled(request)",
        "AB",
    ),
    "a-stale-candidate-stops-the-stage": (
        APPLICATION,
        "        case .absent:\n            continue  // a registration whose bundle is gone",
        "        case .absent:\n            return notInstalled(request)",
        "A",
    ),
    "an-unresolvable-candidate-is-skipped": (
        APPLICATION,
        "        case .failed(let component, let cause):\n"
        "            // Whether this is the chosen copy is unknown, and guessing either way is wrong.\n"
        '            return .failed(unknownEquality("it could not be resolved at \\(component.debugDescription): \\(cause)"))',
        "        case .failed:\n            continue",
        "A",
    ),
    "an-impossible-or-cyclic-candidate-is-skipped": (
        APPLICATION,
        "        case .absent(let absence) where absence.isImpossibleOrCycle:\n"
        '            return .failed(unknownEquality("\\(explanation(of: absence))"))\n',
        "",
        "A",
    ),
    "equality-ignores-the-device": (
        APPLICATION,
        "copy.identity == chosen.identity",
        "copy.identity.inode == chosen.identity.inode",
        "A",
    ),
    "equality-ignores-the-inode": (
        APPLICATION,
        "copy.identity == chosen.identity",
        "copy.identity.device == chosen.identity.device",
        "A",
    ),
    "a-candidates-metadata-is-read": (
        APPLICATION,
        "        switch native.resolveLocation(registered.path) {",
        "        let probed = native.resolveLocation(registered.path)\n"
        "        if case .present(let location) = probed { _ = native.readApplicationBundle(of: location) }\n"
        "        switch probed {",
        "A",
    ),
    "the-preferred-copy-is-not-compared": (APPLICATION, "        candidates.append(preferred)", "        _ = preferred", "A"),
    "candidates-are-compared-in-the-wrong-order": (
        APPLICATION,
        "    for registered in candidates {",
        "    for registered in candidates.reversed() {",
        "A",
    ),
    "a-discovered-limit-is-not-applied": (
        DISCOVERED,
        '        if let refusal = HandOffLimit.refusal(of: location, forAction: action, noun: "registered application path") {\n'
        "            return .failed(refusal)\n        }\n        found = location",
        "        found = location",
        "DCG",
    ),
    "a-discovered-bundle-is-read-before-the-limit": (
        DISCOVERED,
        '        if let refusal = HandOffLimit.refusal(of: location, forAction: action, noun: "registered application path") {\n'
        "            return .failed(refusal)\n        }\n        found = location\n    }\n"
        "    switch native.readApplicationBundle(of: found) {",
        "        found = location\n    }\n    let early = native.readApplicationBundle(of: found)\n"
        '    if let refusal = HandOffLimit.refusal(of: found, forAction: action, noun: "registered application path") { return .failed(refusal) }\n'
        "    switch early {",
        "D",
    ),
    "an-impossible-name-or-cycle-at-a-discovered-location-is-absence": (
        DISCOVERED,
        "    case .absent(let absence) where absence.isImpossibleOrCycle:\n"
        "        // Neither is a missing registration: the location cannot be what discovery reported.\n"
        "        return .failed(\n"
        '            "The registered application path could not be resolved: \\(explanation(of: absence)).")\n',
        "",
        "D",
    ),
    "a-failed-walk-at-a-discovered-location-is-absence": (
        DISCOVERED,
        'return .failed("The registered application path could not be resolved at \\(component.debugDescription): \\(cause).")',
        "return .absent",
        "D",
    ),
    "a-discovered-non-application-is-an-application": (
        DISCOVERED,
        "    case .notApplication: return .absent\n    case .unreadable",
        "    case .notApplication: return .application(identifier: nil)\n    case .unreadable",
        "D",
    ),
    "an-unreadable-discovered-bundle-is-absence": (
        DISCOVERED,
        "    case .unreadable(let reason): return .failed(unreadable(reason))\n    case .application(let identifier): return .application(identifier: identifier)",
        "    case .unreadable: return .absent\n    case .application(let identifier): return .application(identifier: identifier)",
        "D",
    ),
    "a-discovered-location-that-is-gone-is-failed": (
        DISCOVERED,
        "    case .absent: return .absent  // a registration whose bundle is gone",
        '    case .absent: return .failed("x")  // a registration whose bundle is gone',
        "D",
    ),
    "an-unconstrained-launch-does-not-check-the-identifier": (
        SELECTION,
        "        guard identifier == request.bundleIdentifier else { return mismatch(request) }\n        return .selected(registered, substituting: true)",
        "        return .selected(registered, substituting: true)",
        "D",
    ),
    "a-default-browser-must-declare-an-identifier": (
        SELECTION,
        "    case .application: return .selected(handler, substituting: true)\n    }\n}\n\nprivate func noDefaultHandler",
        "    case .application(let identifier):\n        guard identifier != nil else { return noDefaultHandler() }\n        return .selected(handler, substituting: true)\n    }\n}\n\nprivate func noDefaultHandler",
        "D",
    ),
    "an-unconstrained-launch-forbids-substitution": (
        SELECTION,
        "        guard identifier == request.bundleIdentifier else { return mismatch(request) }\n        return .selected(registered, substituting: true)",
        "        guard identifier == request.bundleIdentifier else { return mismatch(request) }\n        return .selected(registered, substituting: false)",
        "DG",
    ),
    "the-selected-copy-allows-substitution": (
        APPLICATION,
        "return .selected(registered, substituting: false)",
        "return .selected(registered, substituting: true)",
        "AG",
    ),
    "observation-applies-the-hand-off-limit": (
        EXECUTABLE,
        "        guard case .present(let location) = LocationWalk.resolve(path, using: system) else { return nil }\n",
        "        guard case .present(let location) = LocationWalk.resolve(path, using: system), path.count < HandOffLimit.pathMax else { return nil }\n",
        "XR",
    ),
    "an-absent-executable-has-an-identity": (
        EXECUTABLE,
        "        guard case .present(let location) = LocationWalk.resolve(path, using: system) else { return nil }\n        return location.identity\n",
        "        switch LocationWalk.resolve(path, using: system) {\n        case .present(let location): return location.identity\n        default: return ObjectIdentity(device: 0, inode: 0)\n        }\n",
        "XR",
    ),
    "a-relative-spelling-is-read-from-the-root": (
        EXECUTABLE,
        '        guard path.first == UInt8(ascii: "/") else { return nil }\n',
        "",
        "X",
    ),
    "an-unavailable-identity-matches-an-unavailable-one": (
        OBSERVATION,
        "    guard let claimed = application.executableIdentity, let live = native.liveExecutableIdentity(of: pid),\n        claimed == live\n    else { return nil }\n",
        "    guard application.executableIdentity == native.liveExecutableIdentity(of: pid) else { return nil }\n",
        "V",
    ),
    "the-live-identity-reads-another-process": (
        NATIVE,
        "proc_pidpath(pid, $0.baseAddress, UInt32($0.count))",
        "proc_pidpath(getppid(), $0.baseAddress, UInt32($0.count))",
        "R",
    ),
    "a-url-longer-than-the-limit-is-unavailable": (
        NATIVE,
        "    guard url.isFileURL else { return nil }\n",
        "    guard url.isFileURL, url.path.utf8.count < 1024 else { return nil }\n",
        "R",
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
            and run(["task", "fixture:receipt-identity-probe"], TREE, log) == 0
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
