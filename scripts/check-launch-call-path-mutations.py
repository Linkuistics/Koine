#!/usr/bin/env python3
# ruff: noqa: E501  (the mutation texts are verbatim lines of the Swift source)
"""Shows that the receipt-identity part of `task check:launch-call-path` goes red against a source that is wrong.

A control that has never been seen to fail is not a control (grove's rule for a clean read). This breaks one
decision of the receipt's two executable identities at a time, in a throwaway copy of just what the check reads
(the check's source section, scripts/signing-env.sh and App/Info.plist), runs the check on the copy, and requires
it to fail with the message that names the decision. The working tree is never edited, and the built bundle the
check also inspects is read, never changed.

usage: check-launch-call-path-mutations.py [bundle]   (default: .build/app/Koine.app)
Exits 1 if the unmutated copy fails or any mutation is not seen.
"""

import os
import shutil
import subprocess
import sys
import tempfile

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROVIDER = "Providers/WorkspaceProvider/"
NATIVE = PROVIDER + "Sources/NativeWorkspace.swift"
EXECUTABLE = PROVIDER + "Logic/ExecutableIdentity.swift"
SEAM = PROVIDER + "Logic/Native.swift"
OBSERVATION = PROVIDER + "Logic/Observation.swift"

# name -> (file, text to replace, replacement, message the check must fail with)
MUTATIONS = {
    "the-live-identity-resolves-symlinks-by-url": (
        NATIVE,
        "        guard length > 0 else { return nil }\n",
        "        guard length > 0 else { return nil }\n        _ = URL(fileURLWithPath: \"/\").resolvingSymlinksInPath()\n",
        "a receipt identity still uses the old identity type, a symlink-resolving call or a pathname resource value",
    ),
    "the-retained-identity-reads-a-resource-identifier": (
        NATIVE,
        "    guard url.isFileURL else { return nil }\n",
        "    guard url.isFileURL else { return nil }\n    _ = try? url.resourceValues(forKeys: [.fileResourceIdentifierKey])\n",
        "a receipt identity still uses the old identity type, a symlink-resolving call or a pathname resource value",
    ),
    "the-live-identity-is-not-acquired-by-the-walk": (
        NATIVE,
        "        return ExecutableIdentity.of(path: Array(buffer.prefix { $0 != 0 }))\n",
        "        return nil\n",
        "the live identity is not acquired by the walk",
    ),
    "the-retained-identity-is-not-acquired-by-the-walk": (
        NATIVE,
        "    return bytes.flatMap { ExecutableIdentity.of(path: $0) }\n",
        "    return nil\n",
        "the retained identity is not acquired by the walk",
    ),
    "the-live-path-is-decoded-to-a-string": (
        NATIVE,
        "        return ExecutableIdentity.of(path: Array(buffer.prefix { $0 != 0 }))\n",
        "        return ExecutableIdentity.of(path: Array(String(decoding: buffer.prefix { $0 != 0 }, as: UTF8.self).utf8))\n",
        "a receipt identity route decodes its path, addresses it by a whole-path call or applies the hand-off limit",
    ),
    "the-retained-path-is-the-urls-path-text": (
        NATIVE,
        "    let bytes = url.withUnsafeFileSystemRepresentation { pointer in\n        pointer.map { Array(UnsafeBufferPointer(start: UnsafeRawPointer($0).assumingMemoryBound(to: UInt8.self), count: strlen($0))) }\n    }\n",
        "    let bytes: [UInt8]? = Array(url.path.utf8) /* withUnsafeFileSystemRepresentation */\n",
        "a receipt identity route decodes its path, addresses it by a whole-path call or applies the hand-off limit",
    ),
    "the-live-path-is-read-twice": (
        NATIVE,
        "        guard length > 0 else { return nil }\n",
        "        guard length > 0 else { return nil }\n        _ = proc_pidpath(pid, nil, 0)\n",
        "the kernel's executable path is read other than once",
    ),
    "a-third-acquisition-appears": (
        NATIVE,
        "    guard url.isFileURL else { return nil }\n",
        "    guard url.isFileURL else { return nil }\n    _ = ExecutableIdentity.of(path: [])\n",
        "the walk is not the one acquisition of exactly the two receipt identities",
    ),
    "the-rule-applies-the-hand-off-limit": (
        EXECUTABLE,
        "        guard case .present(let location) = LocationWalk.resolve(path, using: system) else { return nil }\n",
        "        guard case .present(let location) = LocationWalk.resolve(path, using: system), path.count < HandOffLimit.pathMax else { return nil }\n",
        "the receipt identity rule applies a length or turns an outcome into a refusal",
    ),
    "the-rule-does-not-use-the-walk": (
        EXECUTABLE,
        "LocationWalk.resolve(path, using: system)",
        "LocationWalk.other(path, using: system)",
        "the receipt identity rule does not resolve by the walk",
    ),
    "the-rule-reads-an-absence-as-an-identity": (
        EXECUTABLE,
        "        guard case .present(let location) = LocationWalk.resolve(path, using: system) else { return nil }\n        return location.identity\n",
        "        switch LocationWalk.resolve(path, using: system) {\n        case .present(let location): return location.identity\n        default: return ObjectIdentity(device: 0, inode: 0)\n        }\n",
        "the receipt identity rule does not yield an identity for a present location alone",
    ),
    "one-side-is-another-representation": (
        SEAM,
        "    func liveExecutableIdentity(of pid: Int32) -> ObjectIdentity?\n",
        "    func liveExecutableIdentity(of pid: Int32) -> Int?\n",
        "the native seam does not declare exactly the two identities as ObjectIdentity",
    ),
    "observation-no-longer-compares": (
        OBSERVATION,
        "        claimed == live\n",
        "        true\n",
        "observation no longer compares the two identities",
    ),
}


def check(root, bundle):
    result = subprocess.run(
        ["bash", "scripts/check-launch-call-path.sh", bundle], cwd=root, capture_output=True, text=True
    )
    return result.returncode, result.stderr


def main():
    bundle = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(REPOSITORY, ".build/app/Koine.app"))
    seen = {}
    with tempfile.TemporaryDirectory() as work:

        def fresh():
            root = os.path.join(work, "tree")
            shutil.rmtree(root, ignore_errors=True)
            os.makedirs(os.path.join(root, "scripts"))
            os.makedirs(os.path.join(root, "App"))
            for name in ("check-launch-call-path.sh", "signing-env.sh"):
                shutil.copy(os.path.join(REPOSITORY, "scripts", name), os.path.join(root, "scripts", name))
            shutil.copy(os.path.join(REPOSITORY, "App/Info.plist"), os.path.join(root, "App/Info.plist"))
            shutil.copytree(
                os.path.join(REPOSITORY, PROVIDER), os.path.join(root, PROVIDER), symlinks=True
            )
            return root

        code, error = check(fresh(), bundle)
        print(f"unmutated copy: {'passes' if code == 0 else 'FAILS: ' + error.strip()}", flush=True)
        if code != 0:
            sys.exit(1)
        for name, (file, old, new, message) in MUTATIONS.items():
            root = fresh()
            path = os.path.join(root, file)
            text = open(path).read()
            if text.count(old) != 1:
                seen[name] = False
                print(f"{name}: NOT APPLIED (expected one occurrence, found {text.count(old)})", flush=True)
                continue
            open(path, "w").write(text.replace(old, new))
            code, error = check(root, bundle)
            seen[name] = code != 0 and message in error
            detail = "seen" if seen[name] else f"NOT SEEN (exit {code}: {error.strip()[-200:]})"
            print(f"{name}: {detail}", flush=True)
    sys.exit(0 if all(seen.values()) else 1)


if __name__ == "__main__":
    main()
