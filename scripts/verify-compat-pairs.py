#!/usr/bin/env python3
"""Runs the binary compatibility pairs that scripts/build-compat-pairs.sh built.

A pair is one revision's provider bundle installed, with its approval record, in
the per-user provider root of another revision's headless host
(Fixtures/CompatibilityHost). Each case is its own host process over its own data
directory, driven as a client drives Koine: loopback HTTP with a grant. What a
case cannot see over HTTP it reads from the host's ready line (the mapped
framework images) and from the fixture's initializer log (whether any of the
bundle's code ran).

usage: verify-compat-pairs.py [debug|release]

Writes <pairs>/results.json and prints a summary. Exits 1 if any check fails.
docs/verification/binary-compatibility.md records a run.
"""

import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import time
import urllib.error
import urllib.request

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIGURATION = sys.argv[1] if len(sys.argv) > 1 else "debug"
PAIRS = os.path.join(REPOSITORY, ".build", "compat", CONFIGURATION)

BASE_GREETING = "hello from the fixture provider"
REVISION_2_GREETING = "hello from the fixture provider, revision 2"
MINOR_1_GREETING = "hello from the fixture provider, revision 2, using framework minor 1"

ITEMS = "{ fixtureItems { ref name note tags detail { size } } }"
CALLS = "{ fixtureCalls { resolver count } }"
STATUS = "{ koineManagement { providers { provider version state diagnostic } } }"


def products(revision):
    return os.path.realpath(os.path.join(PAIRS, revision, "products"))


def host_binary(revision):
    return os.path.join(products(revision), "KoineCompatibilityHost")


def framework_image(revision):
    return os.path.realpath(
        os.path.join(products(revision), "PackageFrameworks", "KoineProviderAPI.framework", "KoineProviderAPI")
    )


def digest(path):
    with open(path, "rb") as file:
        return hashlib.sha256(file.read()).hexdigest()


class Host:
    """One run of a revision's host over a fresh data directory holding `root`'s content."""

    def __init__(self, revision, root):
        self.directory = tempfile.mkdtemp(prefix="koine-compat-")
        self.data = os.path.join(self.directory, "data")
        shutil.copytree(root, os.path.join(self.data, "Providers"), symlinks=True)
        os.chmod(self.data, 0o700)
        self.initializer_log = os.path.join(self.directory, "initializers.log")
        environment = dict(os.environ, KOINE_FIXTURE_INITIALIZER_LOG=self.initializer_log)
        self.process = subprocess.Popen(
            [host_binary(revision), self.data], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, env=environment, text=True,
        )
        line = self.process.stdout.readline()
        if not line:
            raise RuntimeError(f"The {revision} host exited: {self.process.stderr.read()}")
        self.ready = json.loads(line)
        if "error" in self.ready:
            raise RuntimeError(f"The {revision} host failed: {self.ready['error']}")

    def post(self, query, variables=None, timeout=30):
        """(HTTP status, decoded GraphQL response or None)."""
        request = urllib.request.Request(
            f"http://127.0.0.1:{self.ready['port']}/graphql",
            data=json.dumps({"query": query, "variables": variables or {}}).encode(),
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {self.ready['credential']}",
            },
        )
        try:
            with urllib.request.urlopen(request, timeout=timeout) as response:
                return response.status, json.loads(response.read())
        except urllib.error.HTTPError as error:
            body = error.read()
            return error.code, json.loads(body) if body else None

    def data_of(self, query, variables=None):
        status, reply = self.post(query, variables)
        if status != 200 or reply.get("errors"):
            raise RuntimeError(f"{query} answered {status} {reply}")
        return reply["data"]

    def calls(self):
        return {call["resolver"]: call["count"] for call in self.data_of(CALLS)["fixtureCalls"]}

    def initializers(self):
        try:
            with open(self.initializer_log) as file:
                return file.read().split()
        except FileNotFoundError:
            return []

    def stop(self):
        """Ends standard input, which stops the server. Returns the host's last line."""
        self.process.stdin.close()
        line = self.process.stdout.readline()
        code = self.process.wait(timeout=30)
        shutil.rmtree(self.directory, ignore_errors=True)
        return (json.loads(line) if line else {}), code


class Case:
    def __init__(self, name, plugin, host):
        self.record = {"case": name, "plugin": plugin, "host": host, "checks": []}

    def check(self, name, passed, observed):
        self.record["checks"].append({"check": name, "passed": bool(passed), "observed": observed})
        return passed

    @property
    def passed(self):
        return all(check["passed"] for check in self.record["checks"])


def in_background(function):
    result = {}

    def run():
        try:
            result["value"] = function()
        except Exception as error:  # reported as the check's observation
            result["value"] = ("exception", repr(error))

    thread = threading.Thread(target=run)
    thread.start()
    return thread, result


def wait_for(predicate, seconds=10):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        if predicate():
            return True
        time.sleep(0.02)
    return False


def working_pair(name, plugin_root, plugin, host_revision, greeting, version):
    """A pair that must load and work: every check the native binary seam names."""
    case = Case(name, plugin, host_revision)
    host = Host(host_revision, plugin_root)
    try:
        providers = host.data_of(STATUS)["koineManagement"]["providers"]
        case.check(
            "factory cast, descriptor and start: the provider is ACTIVE",
            [(p["provider"], p["state"], p["version"]) for p in providers] == [("fixture", "ACTIVE", version)],
            providers,
        )
        images = [os.path.realpath(image) for image in host.ready["frameworkImages"]]
        case.check(
            "shared framework identity: one KoineProviderAPI image, the host's own",
            images == [framework_image(host_revision)], images,
        )
        staged = host.initializers()
        case.check(
            "control: the bundle's initializer ran, from the staged copy",
            len(staged) == 1 and "/ProviderStaging/" in staged[0], staged,
        )
        info = host.data_of("{ fixtureInfo { greeting } }")["fixtureInfo"]
        case.check("resolve: this revision's greeting", info["greeting"] == greeting, info)

        # Owned values in both directions: argument values into the plugin, value
        # trees out of it, nested resolvers handed the parent the plugin returned.
        first = host.data_of(ITEMS)["fixtureItems"]
        expected_first = {
            "ref": "koine://fixture/item/1", "name": "first", "note": "the first item",
            "tags": ["fixture", "item-1"], "detail": {"size": 10},
        }
        case.check("value trees out: lists, objects, null, references", first[0] == expected_first and first[1]["note"] is None, first)
        renamed = host.data_of(
            "mutation($ref: Reference!, $name: String!) { fixtureRenameItem(ref: $ref, name: $name) { ref affected { name } } }",
            {"ref": "koine://fixture/item/2", "name": "renamed across the boundary"},
        )["fixtureRenameItem"]
        case.check(
            "argument values in: a reference and a string reach the plugin",
            renamed == {"ref": "koine://fixture/item/2", "affected": [{"name": "renamed across the boundary"}]},
            renamed,
        )
        after = host.data_of(ITEMS)["fixtureItems"]
        workers = [in_background(lambda: [host.data_of(ITEMS)["fixtureItems"] for _ in range(50)]) for _ in range(8)]
        for thread, _ in workers:
            thread.join()
        same = all(result["value"] == [after] * 50 for _, result in workers)
        case.check(
            "ARC ownership: 400 overlapping resolutions return equal trees and the host survives",
            same and host.process.poll() is None,
            "all equal" if same else [result["value"] for _, result in workers][:1],
        )

        kinds = {}
        for outcome in ["UNAVAILABLE", "FAILED", "OS_PERMISSION"]:
            _, reply = host.post("query($o: FixtureOutcome!) { fixtureProbe(outcome: $o) }", {"o": outcome})
            kinds[outcome] = reply["errors"][0]["extensions"].get("kind")
        _, reply = host.post('{ fixtureItem(ref: "koine://fixture/item/9") { name } }')
        kinds["stale reference"] = reply["errors"][0]["extensions"].get("kind")
        case.check(
            "structured failures cross the boundary",
            kinds == {"UNAVAILABLE": "unavailable", "FAILED": "failed", "OS_PERMISSION": "permission", "stale reference": "unavailable"},
            kinds,
        )

        # Async resolution: a resolve suspended inside the plugin blocks no other.
        before = host.calls().get("info", 0)
        host.data_of('mutation { fixtureCloseGate(resolver: "info") }')
        thread, held = in_background(lambda: host.post("{ fixtureInfo { greeting } }"))
        arrived = wait_for(lambda: host.calls().get("info", 0) == before + 1)
        overlapped = host.data_of(ITEMS)["fixtureItems"] == after
        still_held = thread.is_alive()
        host.data_of("mutation { fixtureOpenGate }")
        thread.join(timeout=10)
        case.check(
            "async resolution: a held resolve suspends in the plugin while another completes, then resumes",
            arrived and overlapped and still_held and held.get("value", (None,))[0] == 200
            and held["value"][1]["data"]["fixtureInfo"]["greeting"] == greeting,
            {"arrived": arrived, "overlapped": overlapped, "held while gated": still_held, "reply": held.get("value")},
        )

        # Cancellation by the execution deadline: the caller is answered, and the
        # plugin's resolver, which returns only on cancellation, counts having seen it.
        began = time.monotonic()
        status, reply = host.post("{ fixtureAwaitCancellation }")
        waited = time.monotonic() - began
        seen = wait_for(lambda: host.calls().get("awaitCancellation.cancelled", 0) == 1)
        case.check(
            "cancellation: the deadline's cancellation reaches the plugin's task",
            seen and reply.get("errors"),
            {"status": status, "seconds": round(waited, 2), "errors": reply.get("errors"), "plugin saw cancellation": seen},
        )

        # Stop: cancellation requested, outstanding work awaited. This resolver
        # returns only on cancellation and stop waits for it, so a stop that
        # returns has cancelled the plugin's task. Whether the held caller is
        # still answered is recorded, not required: the listener does not wait
        # for a response in flight before the host exits.
        thread, held = in_background(lambda: host.post("{ fixtureAwaitCancellation }"))
        arrived = wait_for(lambda: host.calls().get("awaitCancellation", 0) == 2)
        stopped, code = host.stop()
        thread.join(timeout=10)
        host = None
        case.check(
            "stop: cancels the resolve outstanding in the plugin, waits for it and exits cleanly",
            arrived and code == 0 and stopped.get("stopped") and stopped.get("stopMilliseconds", 1e9) < 3000,
            {"arrived": arrived, "exit": code, "host": stopped, "caller": held.get("value")},
        )
    finally:
        if host is not None:
            host.stop()
    return case


def refusal(name, plugin_root, plugin, host_revision, state, diagnostic):
    """A pair the host must refuse, with none of the bundle's code having run."""
    case = Case(name, plugin, host_revision)
    host = Host(host_revision, plugin_root)
    try:
        providers = host.data_of(STATUS)["koineManagement"]["providers"]
        case.check(
            f"refused as {state}: {diagnostic}",
            len(providers) == 1 and providers[0]["state"] == state and diagnostic in (providers[0]["diagnostic"] or ""),
            providers,
        )
        case.check("no code of the bundle ran: its initializer log is empty", host.initializers() == [], host.initializers())
        images = [os.path.realpath(image) for image in host.ready["frameworkImages"]]
        case.check("the host still maps only its own framework image", images == [framework_image(host_revision)], images)
        status, _ = host.post("{ fixtureInfo { greeting } }")
        case.check("the schema has no contribution: fixtureInfo does not validate", status == 400, status)
    finally:
        _, code = host.stop()
    case.check("the host stops cleanly", code == 0, code)
    return case


def main():
    fixture = {revision: os.path.join(products(revision), "FixtureProviders") for revision in ["baseline", "newer"]}
    variants = {revision: os.path.join(products(revision), "FixtureVariants") for revision in ["baseline", "newer"]}
    later = lambda name: os.path.join(PAIRS, "later", name)

    # Everything a run executes or loads, frozen: a subject that moved under the
    # run is not a measurement of the binaries reported.
    subjects = {}
    for revision in ["baseline", "newer"]:
        subjects[f"{revision} host"] = host_binary(revision)
        subjects[f"{revision} framework"] = framework_image(revision)
        subjects[f"{revision} fixture"] = os.path.join(fixture[revision], "Fixture.koineprovider", "libFixtureProvider.dylib")
    for name in ["revision2", "revision2-built-against-newer", "minor1"]:
        subjects[f"later {name}"] = os.path.join(later(name), "Fixture.koineprovider", "libFixtureProvider.dylib")
    before = {name: digest(path) for name, path in subjects.items()}

    cases = [
        working_pair("old plugin, newer host", fixture["baseline"], "baseline fixture (built against 1.0)",
                     "newer", BASE_GREETING, "1.0.0"),
        working_pair("newer plugin, old host", later("revision2"), "fixture revision 2 (built against 1.0)",
                     "baseline", REVISION_2_GREETING, "1.1.0"),
        working_pair("control: newer plugin, newer host", later("revision2"), "fixture revision 2 (built against 1.0)",
                     "newer", REVISION_2_GREETING, "1.1.0"),
        working_pair("control: the minor-1 plugin works where 1.1 is supplied", later("minor1"),
                     "fixture revision 2 using minor 1 (built against 1.1, declares 1.1)", "newer", MINOR_1_GREETING, "1.1.0"),
        working_pair("control: built against 1.1 but declaring 1.0, where 1.1 is supplied",
                     later("revision2-built-against-newer"), "fixture revision 2 (built against 1.1, declares 1.0)",
                     "newer", REVISION_2_GREETING, "1.1.0"),
        refusal("newer declaration, old host", later("minor1"),
                "fixture revision 2 using minor 1 (built against 1.1, declares 1.1)", "baseline",
                "INCOMPATIBLE", "requires provider framework 1.1 or later; this Koine supplies 1.0"),
        refusal("lying manifest, old host", later("revision2-built-against-newer"),
                "fixture revision 2 (built against 1.1, declares 1.0)", "baseline",
                "REJECTED", "Symbol not found"),
    ]
    refused = [
        ("unsupported-major", "INCOMPATIBLE", "framework major 2"),
        ("unavailable-minor", "INCOMPATIBLE", "or later; this Koine supplies"),
        ("missing-feature", "INCOMPATIBLE", "requires host features this Koine lacks: time-travel"),
        ("identity-mismatch", "REJECTED", "not by the approved identity, Team ID ZZZZZZZZZZ"),
        ("adhoc-signed", "REJECTED", "it is ad-hoc signed, not by the approved identity"),
        ("unsigned", "REJECTED", "it is not signed"),
    ]
    for plugin_revision, host_revision in [("baseline", "newer"), ("newer", "baseline")]:
        for variant, state, diagnostic in refused:
            cases.append(refusal(
                f"{variant}: {plugin_revision} plugin, {host_revision} host",
                os.path.join(variants[plugin_revision], variant), f"{plugin_revision} variant {variant}",
                host_revision, state, diagnostic,
            ))

    after = {name: digest(path) for name, path in subjects.items()}
    results = {
        "configuration": CONFIGURATION,
        "subjects": {name: {"path": os.path.relpath(subjects[name], REPOSITORY), "sha256": before[name],
                            "unchanged": before[name] == after[name]} for name in subjects},
        "cases": [case.record for case in cases],
    }
    with open(os.path.join(PAIRS, "results.json"), "w") as file:
        json.dump(results, file, indent=2)

    failed = 0
    for case in cases:
        print(f"{'PASS' if case.passed else 'FAIL'}  {case.record['case']}  [{case.record['plugin']} in the {case.record['host']} host]")
        for check in case.record["checks"]:
            if not check["passed"]:
                failed += 1
                print(f"      FAILED: {check['check']}\n        observed: {json.dumps(check['observed'])}")
    moved = [name for name, subject in results["subjects"].items() if not subject["unchanged"]]
    if moved:
        failed += 1
        print(f"FAIL  binaries changed during the run: {', '.join(moved)}")
    print(f"{len(cases)} cases, {failed} failed checks. Details: {os.path.relpath(os.path.join(PAIRS, 'results.json'), REPOSITORY)}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
