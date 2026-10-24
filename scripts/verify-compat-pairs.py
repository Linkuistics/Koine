#!/usr/bin/env python3
"""Runs the binary compatibility pairs that scripts/build-compat-pairs.sh built.

A pair is one revision's provider bundle installed, with its approval record, in
the per-user provider root of another revision's headless host
(Fixtures/CompatibilityHost). Each case is its own host process over its own data
directory, driven as a client drives Koine: loopback HTTP with a grant. What a
case cannot see over HTTP it reads from the host's ready line (the mapped
framework images) and from the fixture's initializer log (whether any of the
bundle's code ran).

The workspace pairs (docs/verification/workspace-compatibility.md) put the RETAINED 1.0.0
workspace bundle, the released Koine 0.3.0's 1.0.1 one and this tree's 1.0.2 one each under
the hosts that can serve them, and the per-user 1.0.1 and 1.0.2 variants under this tree's
host over a bundled 1.0.0; the released 0.3.0 host and the retained 1.0.0 host each refuse
1.0.2 before it loads, naming the feature they lack. The same fixtures are probed through
every pair that serves a release and the outcomes compared.

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
CANDIDATES = (
    "{ koineManagement { providers { provider version schemaVersion state diagnostic "
    "candidateId origin selection selectedCandidateId reason } } }"
)


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
    served schema and the candidates it runs are held to the extension-host
    core + desktop profile (docs/design/profiles/) by the conformance check the
    release runs, with its own positive controls: the same check against a design
    text with one description changed, and against a profile that pins another
    release, must come back red. The original core + desktop design file is the
    old-host profile's; only a released host serves it, and the V run owns that."""
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
        profile = os.path.join(REPOSITORY, "docs", "design", "profiles", "core-desktop-extension-host.json")
        with open(profile) as file:
            pinned = json.load(file)
        design = os.path.normpath(os.path.join(os.path.dirname(profile), pinned["design"]))
        providers_path = os.path.join(directory, "providers.json")
        _, candidates = host.post(CANDIDATES)
        with open(providers_path, "w") as file:
            json.dump(candidates, file)
        run = subprocess.run(
            [conformance, "--introspection", capture, "--profile", profile, "--providers", providers_path,
             "--served-digest", koine["schemaDigest"]],
            capture_output=True, text=True,
        )
        case.check(
            "the served schema is the extension-host contract and the candidate run is the profile's pin: "
            "no difference from the design SDL, the served digest is that text's, and desktop 1.0.0 is BUNDLED and SELECTED",
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
        wrong = dict(pinned, design=design)
        wrong["providers"] = [dict(pinned["providers"][0], version="9.9.9")]
        wrong_path = os.path.join(directory, "wrong-profile.json")
        with open(wrong_path, "w") as file:
            json.dump(wrong, file)
        pin_red = subprocess.run(
            [conformance, "--introspection", capture, "--profile", wrong_path, "--providers", providers_path,
             "--served-digest", koine["schemaDigest"]],
            capture_output=True, text=True,
        )
        case.check(
            "control: the same schema and digest are red against a profile that pins another release",
            pin_red.returncode == 1 and "is not served as expected" in pin_red.stdout,
            {"exit": pin_red.returncode, "output": pin_red.stdout[-300:]},
        )
        # Composition positions and origins as the host really reported them.
        served = candidates["data"]["koineManagement"]["providers"]
        case.check(
            "the desktop row is the bundled designated copy the host selected, and names itself",
            len(served) == 1 and served[0]["origin"] == "BUNDLED" and served[0]["selection"] == "SELECTED"
            and served[0]["candidateId"] == served[0]["selectedCandidateId"] and served[0]["reason"] is None,
            served,
        )
        shutil.rmtree(directory, ignore_errors=True)
    finally:
        _, code = host.stop()
        shutil.rmtree(empty, ignore_errors=True)
    case.check("the host stops cleanly", code == 0, code)
    return case


# --- The workspace pairs ---------------------------------------------------------------------------------------
#
# The old sides are the retained 1.0.0 bundle and the released Koine 0.3.0's 1.0.1 (scripts/build-retained-workspace.sh,
# one pin each), the new side this tree's 1.0.2 (scripts/build-compat-pairs.sh); a host is a retained revision's own,
# or this tree's. Each case is one headless host over a bundled root that stands in for Contents/PlugIns and a per-user
# root.

RETAINED = "workspace-1.0.0"
RELEASED = "workspace-1.0.1"
PROFILES = os.path.join(REPOSITORY, "docs", "design", "profiles")
RETAINED_PROFILE = "core-desktop-workspace-extension-host.json"
REPAIR_PROFILE = "core-desktop-workspace-repair-extension-host.json"
PER_USER_PROFILE = "core-desktop-workspace-repair-per-user-extension-host.json"
DISCOVERY_PROFILE = "core-desktop-workspace-discovery-extension-host.json"
DISCOVERY_PER_USER_PROFILE = "core-desktop-workspace-discovery-per-user-extension-host.json"
FEATURE_NATIVE_DISCLOSURES = "workspace-native-disclosures-v1"
RETAINED_DESIGN = os.path.join(REPOSITORY, "docs", "design", "desktop-workspace-schema-extension-host.graphql")
FEATURE_SELECTION = "first-party-selection-v1"
SELECTION_REFUSED = "requires host features this Koine lacks: " + FEATURE_SELECTION

# Every fixture below is absent, a refusal, or an extant over-limit directory: no probe can reach an application,
# so none launches, opens or reveals anything. A probe that came back AVAILABLE would have, and fails the case.
LONG_NAME = "d" * 200


def retained_bundled():
    return os.path.join(PAIRS, RETAINED, "bundled")


def released_bundled():
    return os.path.join(PAIRS, RELEASED, "bundled")


def released_per_user_variant():
    return os.path.join(PAIRS, RELEASED, "workspace-per-user")


def newer_desktop():
    return os.path.join(products("newer"), "DesktopProviders")


def newer_workspace():
    return os.path.join(products("newer"), "WorkspaceProviders")


def per_user_variant():
    return os.path.join(PAIRS, "newer", "workspace-per-user")


def compose(desktop_from, workspace_from):
    """A root as Contents/PlugIns holds the two bundled providers: `desktop_from`'s desktop (with its approval record)
    and `workspace_from`'s workspace (with its own). Returns the directory; the caller removes it."""
    root = tempfile.mkdtemp(prefix="koine-compat-bundled-")
    for source, names in ((desktop_from, ("Desktop.koineprovider", "desktop.approval.json")),
                          (workspace_from, ("Workspace.koineprovider", "workspace.approval.json"))):
        for name in names:
            path = os.path.join(source, name)
            if os.path.isdir(path):
                shutil.copytree(path, os.path.join(root, name), symlinks=True)
            else:
                shutil.copy(path, os.path.join(root, name))
    return root


def only(directory, name):
    """A root holding one bundle of `directory` and its approval record."""
    root = tempfile.mkdtemp(prefix="koine-compat-peruser-")
    for entry in (name + ".koineprovider", name.lower() + ".approval.json"):
        path = os.path.join(directory, entry)
        if os.path.isdir(path):
            shutil.copytree(path, os.path.join(root, entry), symlinks=True)
        else:
            shutil.copy(path, os.path.join(root, entry))
    return root


def build_probe_fixtures():
    """Locations whose outcomes the two releases must give alike, and the one whose they must not: an extant
    directory whose spelling is 1,024 bytes or more. Built component by component (a whole-path `mkdir` or `open`
    of it is what 1.0.0 mishandled). Returns (base directory, {name: spelling})."""
    base = tempfile.mkdtemp(prefix="koine-compat-probe-")
    base = os.path.realpath(base)
    paths = {}
    paths["missing"] = os.path.join(base, "missing")
    os.symlink("no-such-target", os.path.join(base, "dangling"))
    paths["dangling link"] = os.path.join(base, "dangling")
    os.symlink("loop-b", os.path.join(base, "loop-a"))
    os.symlink("loop-a", os.path.join(base, "loop-b"))
    paths["link cycle"] = os.path.join(base, "loop-a")
    paths["missing parent"] = os.path.join(base, "no-such-directory", "child")
    with open(os.path.join(base, "file"), "w") as file:
        file.write("x")
    paths["a file used as a directory"] = os.path.join(base, "file", "child")
    paths["a component of 256 bytes"] = os.path.join(base, "x" * 256)
    paths["a missing short path under an extant short directory"] = os.path.join(base, "nothing-here")
    # The deep directory, one component at a time through a directory descriptor.
    descriptor = os.open(base, os.O_RDONLY | os.O_DIRECTORY)
    spelling = base
    try:
        while len(spelling.encode()) < 1100:
            os.mkdir(LONG_NAME, dir_fd=descriptor)
            following = os.open(LONG_NAME, os.O_RDONLY | os.O_DIRECTORY, dir_fd=descriptor)
            os.close(descriptor)
            descriptor = following
            spelling = os.path.join(spelling, LONG_NAME)
    finally:
        os.close(descriptor)
    paths["an extant directory of 1,024 bytes or more"] = spelling
    return base, paths


def remove_deep(base):
    """Removes the fixtures, deepest first and by component: nothing addresses the long path whole."""
    stack = [os.open(base, os.O_RDONLY | os.O_DIRECTORY)]
    try:
        while True:
            try:
                stack.append(os.open(LONG_NAME, os.O_RDONLY | os.O_DIRECTORY, dir_fd=stack[-1]))
            except FileNotFoundError:
                break
        while len(stack) > 1:
            os.close(stack.pop())
            os.rmdir(LONG_NAME, dir_fd=stack[-1])
    finally:
        for descriptor in stack:
            os.close(descriptor)
    shutil.rmtree(base, ignore_errors=True)


def outcome(host, operation, path):
    """What one operation says of one location, as a client sees it: the status and dependency reason of a result,
    or the kind of an error; never anything that could have reached an application."""
    field = {"open": "workspaceOpenPath", "reveal": "workspaceRevealPath"}[operation]
    status, reply = host.post(
        'mutation($p: String!) { %s(path: $p) { status dependency { reason } } }' % field, {"p": path}, timeout=60)
    errors = (reply or {}).get("errors") or []
    if errors:
        return ["error", (errors[0].get("extensions") or {}).get("kind"), status]
    served = ((reply or {}).get("data") or {}).get(field) or {}
    return [served.get("status"), (served.get("dependency") or {}).get("reason"), status]


# case name -> release served -> {probe: {operation: outcome}}: compared by the last case
PROBED = {}


def hold_profile(host, case, conformance, profile, label):
    """What the host serves, held to a bundled profile by the check the release runs, with its own controls: the same
    schema and digest are red against a profile whose workspace rows pin another release, and against the composed
    design of the other release (when the profile's own is the repair's, the retained one, which differs in three
    descriptions alone)."""
    query = subprocess.run([conformance, "--print-query"], capture_output=True, text=True, check=True).stdout
    status, introspection = host.post(query)
    koine = host.data_of("{ koine { schemaDigest } }")["koine"]
    candidates = host.data_of(CANDIDATES)["koineManagement"]["providers"]
    directory = tempfile.mkdtemp(prefix="koine-compat-conformance-")
    try:
        capture = os.path.join(directory, "introspection.json")
        providers_path = os.path.join(directory, "providers.json")
        with open(capture, "w") as file:
            json.dump(introspection, file)
        with open(providers_path, "w") as file:
            json.dump(candidates, file)
        path = os.path.join(PROFILES, profile)
        with open(path) as file:
            pinned = json.load(file)

        def run(document, design=None):
            copy = os.path.join(directory, "profile.json")
            with open(copy, "w") as file:
                json.dump(dict(document, design=design or os.path.normpath(os.path.join(PROFILES, document["design"]))), file)
            return subprocess.run(
                [conformance, "--introspection", capture, "--profile", copy, "--providers", providers_path,
                 "--served-digest", koine["schemaDigest"]], capture_output=True, text=True)

        clean = run(pinned)
        case.check(f"{label}: the host holds {profile} (the served schema is its design's, the digest is that text's, "
                   "and the candidate rows are its pins)",
                   status == 200 and clean.returncode == 0 and "CONFORMANT" in clean.stdout,
                   {"exit": clean.returncode, "output": (clean.stdout + clean.stderr)[-400:]})
        rows = pinned["providers"]
        moved = [dict(r, version="9.9.9") if r["provider"] == "workspace" else r for r in rows]
        wrong = run(dict(pinned, providers=moved))
        case.check(f"{label}, control: the same schema, digest and rows are red against a profile pinning workspace 9.9.9",
                   wrong.returncode == 1 and "is not served as expected" in wrong.stdout,
                   {"exit": wrong.returncode, "output": wrong.stdout[-300:]})
        crossed = REPAIR_PROFILE if profile == RETAINED_PROFILE else RETAINED_PROFILE
        with open(os.path.join(PROFILES, crossed)) as file:
            cross = run(json.load(file))
        case.check(f"{label}, control: the same schema, digest and rows are red against {crossed}, the other release's pin",
                   cross.returncode == 1 and "is not served as expected" in cross.stdout,
                   {"exit": cross.returncode, "output": cross.stdout[-300:]})
        other_design = RETAINED_DESIGN if "repair" in pinned["design"] else os.path.normpath(
            os.path.join(PROFILES, "..", "desktop-workspace-repair-schema-extension-host.graphql"))
        other = run(pinned, design=other_design)
        case.check(f"{label}, control: the same schema and digest are red against the other release's composed design",
                   other.returncode == 1 and "difference(s) between" in other.stdout,
                   {"exit": other.returncode, "output": other.stdout[-300:]})
        return koine["schemaDigest"], candidates
    finally:
        shutil.rmtree(directory, ignore_errors=True)


def rows_of(candidates):
    return sorted(
        (c["provider"], c["version"], c["schemaVersion"], c["state"], c["origin"], c["selection"], c["reason"])
        for c in candidates)


def workspace_pair(name, plugin, host_revision, bundled, per_user, conformance, profile, release, expected_rows,
                   staged_binaries, probes, refused_for=None):
    """One host of `host_revision`, over `bundled` (Contents/PlugIns) and `per_user` (a root with the per-user
    bundle, or None), holding `release` of workspace as its serving candidate.

    `expected_rows` are the candidate rows, exactly; `staged_binaries` the SHA-256 of the workspace image the host
    must have mapped (it loads its staged copy, never the installed one), and no other: a candidate the host did
    not select is never loaded. `probes` is the
    (base, {name: spelling}) the locations are taken from. `refused_for` names a host feature the host lacks: the
    workspace row must then be INCOMPATIBLE with a diagnostic that names it, and no workspace image may be mapped."""
    case = Case(name, plugin, host_revision)
    per_user_root = per_user or tempfile.mkdtemp(prefix="koine-compat-empty-")
    host = Host(host_revision, per_user_root, bundled=bundled)
    try:
        providers = host.data_of(CANDIDATES)["koineManagement"]["providers"]
        case.check("the candidate rows are exactly the ones this pair is pinned to",
                   rows_of(providers) == sorted(expected_rows), {"served": rows_of(providers), "pinned": sorted(expected_rows)})
        if refused_for is not None:
            diagnostics = [p["diagnostic"] for p in providers if p["provider"] == "workspace" and p["state"] == "INCOMPATIBLE"]
            case.check(f"the refused candidate's diagnostic names the missing feature {refused_for} and says it is a requirement the host lacks",
                       len(diagnostics) == 1 and diagnostics[0] is not None and refused_for in diagnostics[0]
                       and "requires host features this Koine lacks" in diagnostics[0], diagnostics)
        if profile is not None:
            hold_profile(host, case, conformance, profile, name)
        images = [os.path.realpath(image) for image in host.ready["frameworkImages"]]
        case.check("shared framework identity: one KoineProviderAPI image, the host's own",
                   images == [framework_image(host_revision)], images)
        mapped = mapped_images(host, "libWorkspaceProvider.dylib")
        case.check("the workspace image the host mapped is exactly one, the expected binary, loaded from the host's own staging "
                   "(a candidate the host did not select is never loaded)" if staged_binaries else
                   "no workspace image is mapped: the refused bundle was never loaded",
                   sorted(digest(path) for path in mapped) == sorted(staged_binaries)
                   and all("/ProviderStaging/" in path for path in mapped),
                   {"mapped": [os.path.relpath(path, host.data) for path in mapped], "wanted": sorted(staged_binaries)})
        if release is not None:
            status, reply = host.post(
                'mutation { workspaceLaunchApplication(application: { bundleIdentifier: "dev.antony.koine.no-such-application" }) '
                "{ status dependency { reason } } }")
            result = ((reply or {}).get("data") or {}).get("workspaceLaunchApplication") or {}
            case.check("an application that is not installed is DEPENDENCY_UNAVAILABLE / APPLICATION_NOT_INSTALLED, as in either release",
                       status == 200 and not (reply or {}).get("errors") and result.get("status") == "DEPENDENCY_UNAVAILABLE"
                       and (result.get("dependency") or {}).get("reason") == "APPLICATION_NOT_INSTALLED", [status, reply])
            base, spellings = probes
            observed = {label: {operation: outcome(host, operation, spelling) for operation in ("open", "reveal")}
                        for label, spelling in spellings.items()}
            case.check("no probe reached an application: none came back AVAILABLE",
                       all(value[0] != "AVAILABLE" for per in observed.values() for value in per.values()), observed)
            PROBED.setdefault(release, {})[name] = observed
            case.record.setdefault("probes", observed)
    finally:
        _, code = host.stop()
        shutil.rmtree(per_user_root, ignore_errors=True)
        shutil.rmtree(bundled, ignore_errors=True)
    case.check("the host stops cleanly", code == 0, code)
    return case


def mapped_images(host, name):
    """The paths of the images called `name` that the host's process has mapped (`lsof` lists them as text segments)."""
    listing = subprocess.run(["lsof", "-p", str(host.process.pid)], capture_output=True, text=True).stdout
    return sorted({line.split(None, 8)[-1] for line in listing.splitlines()
                   if line.rstrip().endswith("/" + name) and " txt " in line})


def probes_agree(cases):
    """The outcomes of the probe fixtures through every pair: alike within a release, and between the releases alike
    but for the one documented class (an extant location whose spelling is 1,024 bytes or more)."""
    case = Case("the same locations through every pair: the releases differ in the long-location correction alone",
                "workspace 1.0.0, 1.0.1 and 1.0.2, in the hosts that serve each", "retained, released and newer")
    by_release = {}
    for release, named in PROBED.items():
        distinct = {json.dumps(value, sort_keys=True) for value in named.values()}
        case.check(f"release {release}: every pair that served it gave the same outcomes ({len(named)} of them)",
                   len(distinct) == 1 and len(named) >= 2, {"pairs": sorted(named), "distinct": len(distinct)})
        if named:
            by_release[release] = next(iter(named.values()))
    old, new, newest = by_release.get("1.0.0"), by_release.get("1.0.1"), by_release.get("1.0.2")
    if old is None or new is None or newest is None:
        case.check("all three releases were probed", False, sorted(by_release))
        return case
    case.check("1.0.2, which adds discovery reads and no action, gives every location the outcome 1.0.1 gives",
               newest == new, {k: [new[k], newest[k]] for k in new if new[k] != newest[k]})
    long_class = "an extant directory of 1,024 bytes or more"
    case.check("every other location has one outcome in both releases (absent, a cycle and an impossible name included)",
               {k: v for k, v in old.items() if k != long_class} == {k: v for k, v in new.items() if k != long_class},
               {k: [old[k], new[k]] for k in old if k != long_class and old[k] != new[k]})
    case.check("the retained 1.0.0 reads the extant long directory as absent: DEPENDENCY_UNAVAILABLE / PATH_NOT_FOUND for open and reveal",
               all(v[:2] == ["DEPENDENCY_UNAVAILABLE", "PATH_NOT_FOUND"] for v in old[long_class].values()), old[long_class])
    case.check("1.0.1 refuses it as failed, a kind it already had, with no dependency reason: the correction Antony accepted",
               all(v[0] == "error" and v[1] == "failed" for v in new[long_class].values()), new[long_class])
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
    # The workspace pairs' subjects: the retained 1.0.0 bundle and its host, the released 1.0.1 bundle, its per-user
    # variant and its host, this tree's 1.0.2 bundle and its variant.
    workspace_images = {
        "retained 1.0.0": os.path.join(retained_bundled(), "Workspace.koineprovider", "libWorkspaceProvider.dylib"),
        "released 1.0.1": os.path.join(released_bundled(), "Workspace.koineprovider", "libWorkspaceProvider.dylib"),
        "released 1.0.1 per-user variant": os.path.join(
            released_per_user_variant(), "Workspace.koineprovider", "libWorkspaceProvider.dylib"),
        "newer 1.0.2": os.path.join(newer_workspace(), "Workspace.koineprovider", "libWorkspaceProvider.dylib"),
        "newer 1.0.2 per-user variant": os.path.join(per_user_variant(), "Workspace.koineprovider", "libWorkspaceProvider.dylib"),
    }
    for label, path in workspace_images.items():
        subjects[f"workspace {label} image"] = path
        subjects[f"workspace {label} manifest"] = os.path.join(os.path.dirname(path), "manifest.json")
        subjects[f"workspace {label} SDL"] = os.path.join(os.path.dirname(path), "schema.graphql")
    subjects["retained host"] = host_binary(RETAINED)
    subjects["retained framework"] = framework_image(RETAINED)
    subjects["retained desktop provider"] = os.path.join(retained_bundled(), "Desktop.koineprovider", "libDesktopProvider.dylib")
    subjects["released host"] = host_binary(RELEASED)
    subjects["released framework"] = framework_image(RELEASED)
    subjects["released desktop provider"] = os.path.join(released_bundled(), "Desktop.koineprovider", "libDesktopProvider.dylib")
    subjects["newer desktop provider"] = os.path.join(newer_desktop(), "Desktop.koineprovider", "libDesktopProvider.dylib")
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

    # --- The workspace pairs: independently built old and new providers under each revision's host ---
    old_image, released_image, released_variant_image, new_image, variant_image = (
        digest(workspace_images[k]) for k in
        ("retained 1.0.0", "released 1.0.1", "released 1.0.1 per-user variant", "newer 1.0.2", "newer 1.0.2 per-user variant"))
    probes = build_probe_fixtures()
    D = ("desktop", "1.0.0", "1.0.0", "ACTIVE", "BUNDLED", "SELECTED", None)
    W100 = ("workspace", "1.0.0", "1.0.0", "ACTIVE", "BUNDLED", "SELECTED", None)
    W101 = ("workspace", "1.0.1", "1.0.1", "ACTIVE", "BUNDLED", "SELECTED", None)
    W101_USER = ("workspace", "1.0.1", "1.0.1", "ACTIVE", "PER_USER", "SELECTED", None)
    W102 = ("workspace", "1.0.2", "1.0.2", "ACTIVE", "BUNDLED", "SELECTED", None)
    W102_USER = ("workspace", "1.0.2", "1.0.2", "ACTIVE", "PER_USER", "SELECTED", None)
    W100_SUPERSEDED = ("workspace", "1.0.0", "1.0.0", "REJECTED", "BUNDLED", "NOT_SELECTED", "superseded-candidate")
    # The refused bundle keeps its own row, and the reserved slot, with no eligible candidate, is a row beside it.
    W102_REFUSED = ("workspace", "1.0.2", "1.0.2", "INCOMPATIBLE", "BUNDLED", "NOT_SELECTED", "feature-unavailable")
    W_SLOT_UNAVAILABLE = ("workspace", "unknown", "unknown", "REJECTED", None, "UNAVAILABLE", "no-eligible-candidate")
    try:
        retained_root = lambda: compose(retained_bundled(), retained_bundled())
        released_root = lambda: compose(released_bundled(), released_bundled())
        cases += [
            workspace_pair("the retained 1.0.0 workspace in the retained host (the old pair)",
                           "workspace 1.0.0, retained", RETAINED, retained_root(), None, conformance, RETAINED_PROFILE,
                           "1.0.0", [D, W100], [old_image], probes),
            workspace_pair("the retained 1.0.0 workspace, newer host",
                           "workspace 1.0.0, retained", "newer", compose(newer_desktop(), retained_bundled()), None,
                           conformance, RETAINED_PROFILE, "1.0.0", [D, W100], [old_image], probes),
            workspace_pair("the released 1.0.1 workspace in the released Koine 0.3.0 host (the 1.0.1 pair)",
                           "workspace 1.0.1, released with Koine 0.3.0", RELEASED, released_root(), None, conformance,
                           REPAIR_PROFILE, "1.0.1", [D, W101], [released_image], probes),
            workspace_pair("the released 1.0.1 workspace bundled, retained host",
                           "workspace 1.0.1, released with Koine 0.3.0", RETAINED,
                           compose(retained_bundled(), released_bundled()), None, conformance, REPAIR_PROFILE,
                           "1.0.1", [D, W101], [released_image], probes),
            workspace_pair("the released 1.0.1 workspace bundled, newer host",
                           "workspace 1.0.1, released with Koine 0.3.0", "newer",
                           compose(newer_desktop(), released_bundled()), None, conformance, REPAIR_PROFILE,
                           "1.0.1", [D, W101], [released_image], probes),
            workspace_pair("the approved per-user 1.0.1 variant over the bundled 1.0.0, retained host",
                           "workspace 1.0.1 stating first-party-selection-v1, approved per user", RETAINED,
                           retained_root(), only(released_per_user_variant(), "Workspace"), conformance, PER_USER_PROFILE,
                           "1.0.1", [D, W101_USER, W100_SUPERSEDED], [released_variant_image], probes),
            workspace_pair("the approved per-user 1.0.1 variant over the bundled 1.0.0, newer host",
                           "workspace 1.0.1 stating first-party-selection-v1, approved per user", "newer",
                           compose(newer_desktop(), retained_bundled()), only(released_per_user_variant(), "Workspace"),
                           conformance, PER_USER_PROFILE, "1.0.1", [D, W101_USER, W100_SUPERSEDED],
                           [released_variant_image], probes),
            workspace_pair("the shipped 1.0.1 bundle installed per user does not state the feature: refused, 1.0.0 keeps the slot, retained host",
                           "workspace 1.0.1 as shipped, approved per user", RETAINED, retained_root(),
                           only(released_bundled(), "Workspace"), conformance, None, "1.0.0",
                           [D, ("workspace", "1.0.1", "1.0.1", "INCOMPATIBLE", "PER_USER", "NOT_SELECTED", "selection-feature-required"),
                            ("workspace", "1.0.0", "1.0.0", "ACTIVE", "BUNDLED", "SELECTED", "selected-with-refusals")],
                           [old_image], probes),
            # This tree's 1.0.2: it loads in this tree's host, and the two older hosts refuse it before it loads.
            workspace_pair("the 1.0.2 workspace bundled, newer host: the new bundle loads in the new host",
                           "workspace 1.0.2, this tree's, sealed as the application seals it", "newer",
                           compose(newer_desktop(), newer_workspace()), None, conformance, DISCOVERY_PROFILE, "1.0.2",
                           [D, W102], [new_image], probes),
            workspace_pair("the approved per-user 1.0.2 variant over the bundled 1.0.0, newer host",
                           "workspace 1.0.2 stating first-party-selection-v1, approved per user", "newer",
                           compose(newer_desktop(), retained_bundled()), only(per_user_variant(), "Workspace"),
                           conformance, DISCOVERY_PER_USER_PROFILE, "1.0.2", [D, W102_USER, W100_SUPERSEDED],
                           [variant_image], probes),
            workspace_pair("the 1.0.2 workspace bundled, released Koine 0.3.0 host: refused before it loads",
                           "workspace 1.0.2, this tree's", RELEASED, compose(released_bundled(), newer_workspace()), None,
                           conformance, None, None, [D, W102_REFUSED, W_SLOT_UNAVAILABLE], [], probes,
                           refused_for=FEATURE_NATIVE_DISCLOSURES),
            workspace_pair("the 1.0.2 workspace bundled, retained 1.0.0 host: refused before it loads",
                           "workspace 1.0.2, this tree's", RETAINED, compose(retained_bundled(), newer_workspace()), None,
                           conformance, None, None, [D, W102_REFUSED, W_SLOT_UNAVAILABLE], [], probes,
                           refused_for=FEATURE_NATIVE_DISCLOSURES),
        ]
        cases.append(probes_agree(cases))
    finally:
        remove_deep(probes[0])

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
