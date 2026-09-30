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
ADDITIONAL_GREETING = "hello from the fixture provider, revision 2, using additional capabilities"
FEATURE = "additional-capabilities-v1"

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

    def __init__(self, revision, root, bundled=None):
        """`bundled` stands in for Contents/PlugIns; only a host of this release takes one."""
        self.directory = tempfile.mkdtemp(prefix="koine-compat-")
        self.data = os.path.join(self.directory, "data")
        shutil.copytree(root, os.path.join(self.data, "Providers"), symlinks=True)
        os.chmod(self.data, 0o700)
        self.initializer_log = os.path.join(self.directory, "initializers.log")
        environment = dict(os.environ, KOINE_FIXTURE_INITIALIZER_LOG=self.initializer_log)
        self.process = subprocess.Popen(
            [host_binary(revision), self.data] + ([bundled] if bundled else []),
            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, env=environment, text=True,
        )
        line = self.process.stdout.readline()
        if not line:
            raise RuntimeError(f"The {revision} host exited: {self.process.stderr.read()}")
        self.ready = json.loads(line)
        if "error" in self.ready:
            raise RuntimeError(f"The {revision} host failed: {self.ready['error']}")

    def post(self, query, variables=None, timeout=30, bearer=None):
        """(HTTP status, decoded GraphQL response or None). `bearer` defaults to the host's own grant."""
        request = urllib.request.Request(
            f"http://127.0.0.1:{self.ready['port']}/graphql",
            data=json.dumps({"query": query, "variables": variables or {}}).encode(),
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {bearer or self.ready['credential']}",
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


def working_pair(name, plugin_root, plugin, host_revision, greeting, version, extra=None):
    """A pair that must load and work: every check the native binary seam names.

    `extra(host, case)` adds the checks one pair alone can make, after the shared ones
    that read the fixture's items, and before the ones that stop the host."""
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

        if extra:
            extra(host, case)

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
        # returns has cancelled the plugin's task. The held caller is answered
        # before the host exits.
        thread, held = in_background(lambda: host.post("{ fixtureAwaitCancellation }"))
        arrived = wait_for(lambda: host.calls().get("awaitCancellation", 0) == 2)
        stopped, code = host.stop()
        thread.join(timeout=10)
        host = None
        case.check(
            "stop: cancels the resolve outstanding in the plugin, waits for it, answers its caller and exits cleanly",
            arrived and code == 0 and stopped.get("stopped") and stopped.get("stopMilliseconds", 1e9) < 3000
            and held.get("value", (None,))[0] == 200 and held["value"][1].get("errors"),
            {"arrived": arrived, "exit": code, "host": stopped, "caller": held.get("value")},
        )
    finally:
        if host is not None:
            host.stop()
    return case


def enforce_additional(host, case):
    """What only a host that serves additional-capabilities-v1 can show of a provider using it."""
    def limited(capabilities):
        created = host.data_of(
            'mutation($c: [String!]!) { koineCreateGrant(input: { clientLabel: "limited", capabilities: $c }) { credential } }',
            {"c": capabilities},
        )
        return created["koineCreateGrant"]["credential"]

    checked = 'mutation { renamed: fixtureRenameItemChecked(ref: "koine://fixture/item/1", name: "checked") { ref } }'
    plain = 'mutation { fixtureRenameItem(ref: "koine://fixture/item/1", name: "plain") { ref } }'
    control_only = limited(["fixture:control"])
    before = host.calls().get("renameItem", 0)

    status, reply = host.post(checked, bearer=control_only)
    error = (reply.get("errors") or [{}])[0]
    extensions = error.get("extensions", {})
    case.check(
        "the additional read is required beside the field's own control: refused before any action, naming the first unmet member and the whole ordered set",
        status == 403 and error.get("path") == ["renamed"] and extensions.get("phase") == "authorization"
        and extensions.get("requiredCapability") == "fixture:read"
        and extensions.get("requiredCapabilities") == ["fixture:control", "fixture:read"],
        {"status": status, "error": error},
    )
    case.check(
        "no resolver ran for the refused action", host.calls().get("renameItem", 0) == before,
        host.calls().get("renameItem", 0),
    )

    status, reply = host.post(plain, bearer=limited(["fixture:read"]))
    extensions = (reply.get("errors") or [{}])[0].get("extensions", {})
    case.check(
        "a registration without the set keeps its baseline error exactly: no requiredCapabilities, the same keys",
        status == 403 and set(extensions) == {"kind", "permissionClass", "phase", "requiredCapability"}
        and extensions.get("requiredCapability") == "fixture:control",
        extensions,
    )

    status, reply = host.post(checked, bearer=limited(["fixture:control", "fixture:read"]))
    case.check(
        "with the whole set the action runs once",
        status == 200 and not reply.get("errors") and host.calls().get("renameItem", 0) == before + 1
        and reply["data"]["renamed"]["ref"] == "koine://fixture/item/1",
        {"status": status, "reply": reply, "calls": host.calls().get("renameItem", 0)},
    )


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


def refused_after_loading(name, plugin_root, plugin, host_revision, state, diagnostic):
    """A pair the host loads and then refuses: the bundle's code ran, and none of it is served."""
    case = Case(name, plugin, host_revision)
    host = Host(host_revision, plugin_root)
    try:
        providers = host.data_of(STATUS)["koineManagement"]["providers"]
        case.check(
            f"refused as {state}: {diagnostic}",
            len(providers) == 1 and providers[0]["state"] == state and diagnostic in (providers[0]["diagnostic"] or ""),
            providers,
        )
        staged = host.initializers()
        case.check(
            "control: the bundle was loaded, so the refusal is the host's judgement of what it loaded",
            len(staged) == 1 and "/ProviderStaging/" in staged[0], staged,
        )
        status, _ = host.post("{ fixtureInfo { greeting } }")
        case.check("the schema has no contribution: fixtureInfo does not validate", status == 400, status)
        _, reply = host.post("{ koine { availableCapabilities } }")
        available = reply["data"]["koine"]["availableCapabilities"]
        case.check(
            "no fixture capability is offered", not any(name.startswith("fixture:") for name in available), available,
        )
    finally:
        _, code = host.stop()
    case.check("the host stops cleanly", code == 0, code)
    return case


def desktop_pair(name, host_revision, conformance):
    """The desktop provider built from the released revision, in this release's host.

    It is bundled, as the application supplies it, so `desktop` is its to own. The
    served schema is held to docs/design/desktop-schema.graphql by the conformance
    check the release runs, with its own positive control: the same check against a
    design text with one description changed must come back red."""
    bundled = os.path.join(products("baseline"), "DesktopProviders")
    case = Case(name, "desktop provider built from the released revision (against 1.0)", host_revision)
    empty = tempfile.mkdtemp(prefix="koine-compat-empty-")
    host = Host(host_revision, empty, bundled=bundled)
    try:
        providers = host.data_of(STATUS)["koineManagement"]["providers"]
        case.check(
            "the released desktop provider is ACTIVE beside the new core",
            [(p["provider"], p["state"]) for p in providers] == [("desktop", "ACTIVE")], providers,
        )
        koine = host.data_of("{ koine { schemaDigest availableCapabilities } }")["koine"]
        case.check(
            "both of its capabilities are offered",
            {"desktop:read", "desktop:control"} <= set(koine["availableCapabilities"]), koine["availableCapabilities"],
        )
        absent = host.post(
            '{ desktopApplication(process: { pid: 999999, startedAt: "2001-01-01T00:00:00.000000Z" }) { ref } }'
        )
        case.check(
            "an absent process is null without an error, as the baseline contract says",
            absent[0] == 200 and absent[1].get("data") == {"desktopApplication": None} and not absent[1].get("errors"),
            absent,
        )
        query = subprocess.run([conformance, "--print-query"], capture_output=True, text=True, check=True).stdout
        status, introspection = host.post(query)
        directory = tempfile.mkdtemp(prefix="koine-compat-conformance-")
        capture = os.path.join(directory, "introspection.json")
        with open(capture, "w") as file:
            json.dump(introspection, file)
        design = os.path.join(REPOSITORY, "docs", "design", "desktop-schema.graphql")
        run = subprocess.run(
            [conformance, "--introspection", capture, "--design", design, "--served-digest", koine["schemaDigest"]],
            capture_output=True, text=True,
        )
        case.check(
            "the served schema is the baseline contract: no difference from docs/design/desktop-schema.graphql and the served digest is that text's",
            status == 200 and run.returncode == 0, {"exit": run.returncode, "output": (run.stdout + run.stderr)[-400:]},
        )
        with open(design) as file:
            text = file.read()
        mutated = os.path.join(directory, "mutated.graphql")
        with open(mutated, "w") as file:
            file.write(text.replace("Opaque koine:// URI string", "Opaque koine:// URI text", 1))
        red = subprocess.run(
            [conformance, "--introspection", capture, "--design", mutated, "--served-digest", koine["schemaDigest"]],
            capture_output=True, text=True,
        )
        case.check(
            "control: the same check is red against a design text with one description changed",
            text != open(mutated).read() and red.returncode == 1, {"exit": red.returncode},
        )
        shutil.rmtree(directory, ignore_errors=True)
    finally:
        _, code = host.stop()
        shutil.rmtree(empty, ignore_errors=True)
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
    later_names = [
        "revision2", "revision2-built-against-newer", "additional", "additional-feature-only",
        "additional-undeclared", "additional-manifest-omits",
    ]
    for name in later_names:
        subjects[f"later {name}"] = os.path.join(later(name), "Fixture.koineprovider", "libFixtureProvider.dylib")
    # The desktop provider of the released revision, and the conformance tool that reads the served schema.
    subjects["baseline desktop provider"] = os.path.join(
        products("baseline"), "DesktopProviders", "Desktop.koineprovider", "libDesktopProvider.dylib")
    conformance = os.path.join(products("newer"), "KoineConformance")
    subjects["newer conformance tool"] = conformance
    before = {name: digest(path) for name, path in subjects.items()}

    cases = [
        working_pair("old plugin, newer host", fixture["baseline"], "baseline fixture (built against 1.0)",
                     "newer", BASE_GREETING, "1.0.0"),
        working_pair("newer plugin, old host", later("revision2"), "fixture revision 2 (built against 1.0)",
                     "baseline", REVISION_2_GREETING, "1.1.0"),
        working_pair("control: newer plugin, newer host", later("revision2"), "fixture revision 2 (built against 1.0)",
                     "newer", REVISION_2_GREETING, "1.1.0"),
        # This minor adds no requirement to a protocol, so a plugin compiled against it
        # that uses nothing it added needs nothing of it: the old host runs it.
        working_pair("built against 1.1 and declaring 1.0, old host", later("revision2-built-against-newer"),
                     "fixture revision 2 (built against 1.1, declares 1.0)", "baseline", REVISION_2_GREETING, "1.1.0"),
        working_pair("control: built against 1.1 and declaring 1.0, newer host", later("revision2-built-against-newer"),
                     "fixture revision 2 (built against 1.1, declares 1.0)", "newer", REVISION_2_GREETING, "1.1.0"),
        # The feature, working: the whole set is required, and the baseline error is untouched.
        working_pair("additional-capabilities-v1: the provider using it, newer host", later("additional"),
                     "fixture revision 2 using additional capabilities (built against 1.1, declares 1.1 and the feature)",
                     "newer", ADDITIONAL_GREETING, "1.1.0", extra=enforce_additional),
        refusal("additional-capabilities-v1: the provider using it, released host", later("additional"),
                "fixture revision 2 using additional capabilities (built against 1.1, declares 1.1 and the feature)",
                "baseline", "INCOMPATIBLE", "requires provider framework 1.1 or later; this Koine supplies 1.0"),
        refusal("additional-capabilities-v1: refused by the feature alone, released host", later("additional-feature-only"),
                "the same provider declaring minimum minor 0 and the feature", "baseline",
                "INCOMPATIBLE", f"requires host features this Koine lacks: {FEATURE}"),
        # The feature named under a minimum minor that cannot carry it: refused before any code loads.
        refusal("additional-capabilities-v1: the feature under minimum minor 0 is an inconsistent manifest, newer host",
                later("additional-feature-only"), "the same provider declaring minimum minor 0 and the feature", "newer",
                "REJECTED", f"requires {FEATURE} but declares framework minimum minor 0"),
        refused_after_loading("undeclared use is refused, newer host", later("additional-undeclared"),
                "the same source with neither the manifest nor the descriptor declaring the feature", "newer",
                "REJECTED", f"does not declare {FEATURE}"),
        refused_after_loading("a descriptor declaring what its manifest does not is refused, newer host",
                later("additional-manifest-omits"),
                "the same source, the descriptor declaring the feature and the manifest not", "newer",
                "REJECTED", "disagrees with its manifest"),
        desktop_pair("the released desktop provider, newer host", "newer", conformance),
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
