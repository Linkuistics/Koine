#!/usr/bin/env python3
"""Runs the selection acceptance's decision rows against purpose-built signed hosts.

Machine's "Selection acceptance" table (docs/specs/machine.md) assigns the
pre-load decision rows to the native loader (N) and public GraphQL (G). This driver
runs each scenario as a client and a native observer at once:

  * each scenario, and each alternative order within it, is its own signed host
    process (Fixtures/SelectionHost, assembled and signed with its catalogue by
    scripts/build-selection-hosts.py) over a fresh data directory, a fresh
    per-user provider root and a fresh marker log;
  * G: it reads `koineManagement.providers` over loopback HTTP with the host's
    grant and compares every candidate and synthetic row with the row the spec
    requires, and the structural invariants every report must hold;
  * N: the fixture providers write a marker when their initializer, their factory
    and their start run (Fixtures/FixtureProvider/initializer.c). The log names
    which images ran which phases, and anything not named ran nothing;
  * a scenario asserting that an image never ran is paired with a control: the same
    compiled binary is seen writing all three markers in another scenario of the
    run. A refused-marker assertion with no such control is a failure.

The real verifier, staging and loader run in every scenario. The one private seam
in use is the discovery order, reversed for the alternative run.

usage: verify-selection-decisions.py <hosts> <fixtures> <results.json> [--only <substring>]

<hosts> is scripts/build-selection-hosts.py's output, <fixtures> is
Fixtures/FixtureProvider/build-decisions.sh's. Prints a line per scenario run and
its checks, then the pending rows; exits 1 if any check fails.
docs/verification/selection-decisions.md records a run.
"""

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import urllib.error
import urllib.request

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOSTS_SPEC = os.path.join(REPOSITORY, "Fixtures", "SelectionHost", "hosts.json")

PROVIDERS = (
    "{ koineManagement { providers { provider version schemaVersion state diagnostic "
    "candidateId origin selection selectedCandidateId reason } } }"
)
FULL = ("initializer", "factory", "start")
BASE_GREETING = "hello from the fixturesh provider"
UPDATE_GREETING = "hello from the fixturesh provider, revision 2"


# --- Scenario vocabulary ------------------------------------------------------------


class Install:
    """One entry of the per-user provider root: a fixture case installed as `name`."""

    def __init__(self, case, name, approved=True, alias_of=None):
        self.case, self.name, self.approved, self.alias_of = case, name, approved, alias_of


def U(case, name, approved=True):
    return Install(case, name, approved)


def Alias(name, target):
    return Install(None, name, True, alias_of=target)


def R(provider, version, origin, state, selection, reason, note=None):
    """An expected row. `origin` is B, U, or None for a synthetic row."""
    return (provider, version, origin, state, selection, reason, note)


class Scenario:
    def __init__(
        self, name, rows, host="slot", installs=(), ran=(), partial=None, serves=None,
        rename=False, absent_fields=(), order=None, rows_are_exact=True, rows_note=None,
    ):
        self.name, self.host, self.installs = name, host, list(installs)
        self.rows, self.rows_note = list(rows), rows_note
        # install name -> phases it reached; `ran` names reached every phase.
        self.markers = {name: FULL for name in ran}
        self.markers.update(partial or {})
        self.serves, self.rename = serves, rename
        self.absent_fields, self.order = list(absent_fields), order


# --- Environment --------------------------------------------------------------------


class Suite:
    def __init__(self, hosts, fixtures):
        self.hosts, self.fixtures = hosts, fixtures
        with open(HOSTS_SPEC) as file:
            self.spec = json.load(file)
        self.binary_of = {}
        with open(os.path.join(fixtures, "index.tsv")) as file:
            for line in file:
                case, binary = line.rstrip("\n").split("\t")
                self.binary_of[case] = binary
        self.controls = {}  # compiled binary -> scenario run that saw it write every marker
        self.team = self.team_of("baseline")

    def bundle(self, case):
        directory = os.path.join(self.fixtures, case)
        (name,) = [entry for entry in os.listdir(directory) if entry.endswith(".koineprovider")]
        return os.path.join(directory, name)

    def team_of(self, case):
        text = subprocess.run(["codesign", "-dvv", self.bundle(case)], capture_output=True, text=True).stderr
        return next(line.split("=", 1)[1] for line in text.splitlines() if line.startswith("TeamIdentifier="))

    def host_binary(self, host):
        return os.path.join(self.hosts, host, "KoineSelectionHost.app", "Contents", "MacOS", "KoineSelectionHost")

    def plugins(self, host):
        """(install name, case) of each bundle sealed inside the host."""
        out = []
        for plugin in self.spec["hosts"][host]["plugins"]:
            name = plugin.get("as") or os.path.basename(self.bundle(plugin["case"]))
            out.append((name[: -len(".koineprovider")], plugin["case"]))
        return out


class HostRun:
    """One signed host process over a fresh data directory, marker log and per-user root."""

    def __init__(self, suite, scenario, reversed_order, renames):
        self.suite = suite
        self.directory = tempfile.mkdtemp(prefix="koine-selection-")
        self.data = os.path.join(self.directory, "data")
        providers = os.path.join(self.data, "Providers")
        os.makedirs(providers)
        os.chmod(self.data, 0o700)
        self.renames = renames
        approved = set()
        for install in scenario.installs:
            name = renames.get(install.name, install.name)
            destination = os.path.join(providers, name + ".koineprovider")
            if install.alias_of:
                os.symlink(renames.get(install.alias_of, install.alias_of) + ".koineprovider", destination)
                continue
            shutil.copytree(suite.bundle(install.case), destination, symlinks=True)
            if install.approved:
                try:
                    with open(os.path.join(destination, "manifest.json")) as file:
                        approved.add(json.load(file)["providerId"])
                except ValueError:
                    pass  # a manifest that names no provider has nothing to approve
        # The assessment verdict is one constant across runs because nothing is quarantined.
        self.quarantined = subprocess.run(
            ["xattr", "-rl", self.data], capture_output=True, text=True
        ).stdout.count("com.apple.quarantine")
        for provider in approved:
            with open(os.path.join(providers, provider + ".approval.json"), "w") as file:
                json.dump({"providerId": provider, "teamIdentifier": suite.team}, file)
        self.marker_log = os.path.join(self.directory, "markers.log")
        environment = dict(os.environ, KOINE_FIXTURE_MARKER_LOG=self.marker_log)
        command = [suite.host_binary(scenario.host), self.data] + (["--reverse-discovery"] if reversed_order else [])
        self.process = subprocess.Popen(
            command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=environment, text=True
        )
        watchdog = threading.Timer(90, self.process.kill)
        watchdog.start()
        try:
            line = self.process.stdout.readline()
        finally:
            watchdog.cancel()
        if not line:
            raise RuntimeError(f"The host exited before it was ready: {self.process.stderr.read()}")
        self.ready = json.loads(line)
        if "error" in self.ready:
            raise RuntimeError(f"The host failed to start: {self.ready['error']}")

    def post(self, query):
        request = urllib.request.Request(
            f"http://127.0.0.1:{self.ready['port']}/graphql",
            data=json.dumps({"query": query, "variables": {}}).encode(),
            headers={"Content-Type": "application/json", "Authorization": f"Bearer {self.ready['credential']}"},
        )
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                return response.status, json.loads(response.read())
        except urllib.error.HTTPError as error:
            body = error.read()
            return error.code, json.loads(body) if body else None

    def data_of(self, query):
        status, reply = self.post(query)
        if status != 200 or reply.get("errors"):
            raise RuntimeError(f"{query} answered {status} {reply}")
        return reply["data"]

    def rows(self):
        return self.data_of(PROVIDERS)["koineManagement"]["providers"]

    def query_fields(self):
        fields = self.data_of('{ __type(name: "Query") { fields { name } } }')["__type"]["fields"]
        return [field["name"] for field in fields]

    def markers(self):
        """[(install name, phase)] in the order written, from the staged image each line names."""
        try:
            with open(self.marker_log) as file:
                lines = [line.rstrip("\n").split("\t") for line in file if line.strip()]
        except FileNotFoundError:
            return []
        out = []
        for phase, image in lines:
            staged = os.path.basename(os.path.dirname(image))
            name = re.sub(r"-[0-9a-f]{32}$", "", staged)
            name = re.sub(r"^p\d\d-", "", name) if self.renames else name
            out.append((name, phase))
        return out

    def stop(self):
        self.process.stdin.close()
        line = self.process.stdout.readline()
        code = self.process.wait(timeout=60)
        shutil.rmtree(self.directory, ignore_errors=True)
        return (json.loads(line) if line else {}), code


# --- Checks -------------------------------------------------------------------------


def normalise(row):
    origin = {"BUNDLED": "B", "PER_USER": "U", None: None}[row["origin"]]
    return (row["provider"], row["version"], origin, row["state"], row["selection"], row["reason"])


def order_key(row):
    return (row["provider"], row["origin"] or "~", row["candidateId"] or "")


def invariants(rows):
    """What every report holds, whatever the scenario: the spec's structural rules."""
    failures = []
    identities = [row["candidateId"] for row in rows if row["candidateId"]]
    if len(identities) != len(set(identities)):
        failures.append("candidate identifiers are not unique")
    by_provider = {}
    for row in rows:
        by_provider.setdefault(row["provider"], []).append(row)
    if [row["provider"] for row in rows] != sorted(row["provider"] for row in rows):
        failures.append("rows are not sorted by provider")
    for provider, group in by_provider.items():
        real = [row for row in group if row["candidateId"]]
        synthetic = [row for row in group if not row["candidateId"]]
        if [order_key(row) for row in real] != sorted(order_key(row) for row in real):
            failures.append(f"{provider}: rows are not sorted by origin and candidate identifier")
        if group[len(real):] != synthetic:
            failures.append(f"{provider}: a synthetic row is not last")
        for row in synthetic:
            if row["origin"] is not None or row["selection"] != "UNAVAILABLE":
                failures.append(f"{provider}: a synthetic row has an origin or is not UNAVAILABLE")
        for row in real:
            if row["origin"] is None or row["selection"] is None:
                failures.append(f"{provider}: a candidate row lacks its origin or selection")
        chosen = [row for row in real if row["selection"] == "SELECTED"]
        if len(chosen) > 1:
            failures.append(f"{provider}: more than one SELECTED row")
        for row in chosen:
            if row["selectedCandidateId"] != row["candidateId"]:
                failures.append(f"{provider}: a SELECTED row does not name itself")
        expected = chosen[0]["candidateId"] if chosen else None
        for row in group:
            if row["selectedCandidateId"] != expected:
                failures.append(f"{provider}: a row's selectedCandidateId is {row['selectedCandidateId']}, not {expected}")
        for row in group:
            if row["state"] == "ACTIVE" and row["selection"] != "SELECTED":
                failures.append(f"{provider}: an ACTIVE row that is not SELECTED")
            if row["state"] in ("ACTIVE", "FAILED") and not row["candidateId"]:
                failures.append(f"{provider}: a synthetic row is {row['state']}")
    return failures


def run_scenario(suite, scenario, reversed_order, renamed, results):
    label = f"{scenario.name} [{scenario.host}; {'reversed' if reversed_order else 'forward'} discovery{'; paths renamed' if renamed else ''}]"
    renames = {}
    if renamed:
        names = sorted(install.name for install in scenario.installs)
        renames = {name: f"p{len(names) - index:02d}-{name}" for index, name in enumerate(names)}
    record = {"scenario": scenario.name, "label": label, "host": scenario.host, "checks": []}
    results.append(record)

    def check(name, passed, observed=None):
        record["checks"].append({"check": name, "passed": bool(passed), "observed": observed})
        if not passed:
            print(f"    FAIL {name}: {observed}")
        return passed

    try:
        host = HostRun(suite, scenario, reversed_order, renames)
    except Exception as error:  # noqa: BLE001 - a host that will not start is a failed check
        check("the host starts", False, str(error))
        print(f"  FAIL {label}")
        return
    try:
        rows = host.rows()
        markers = host.markers()
        check("no installed copy is quarantined, so every assessment verdict is the same", host.quarantined == 0,
              host.quarantined)
        check("hostTeam", (host.ready["hostTeam"] is not None) == (suite.spec["hosts"][scenario.host]["signing"] == "developer-id"),
              host.ready["hostTeam"])
        for failure in invariants(rows):
            check("report invariant", False, failure)
        actual = sorted(normalise(row) for row in rows)
        wanted = sorted(row[:6] for row in scenario.rows)
        check("rows", actual == wanted, {"actual": actual, "wanted": wanted})
        for expected in scenario.rows:
            if expected[6]:
                matching = [
                    row for row in rows
                    if normalise(row) == expected[:6]
                ]
                text = " ".join(row["diagnostic"] or "" for row in matching)
                check(f"diagnostic of {expected[:6]} names {expected[6]!r}", expected[6] in text, text)
        # N: exactly the images the scenario names ran, and only the phases it names.
        observed = {}
        for name, phase in markers:
            observed.setdefault(name, []).append(phase)
        wanted_markers = {name: list(phases) for name, phases in scenario.markers.items()}
        check("markers", observed == wanted_markers, {"observed": observed, "wanted": wanted_markers})
        if scenario.order:
            firsts = [name for name, phase in markers if phase == "start"]
            check("start order", firsts == scenario.order, firsts)
        if scenario.serves:
            root, greeting = scenario.serves
            data = host.data_of("{ %s { greeting } }" % root)
            check(f"{root} is answered by the selected binary", data[root]["greeting"] == greeting, data)
        if scenario.absent_fields:
            served = host.query_fields()
            check("no provider field is published", not [f for f in scenario.absent_fields if f in served], served)
        # Controls: which compiled binary each unloaded install would have been, and
        # which was seen to run.
        installed = {install.name: install.case for install in scenario.installs if install.case}
        installed.update(dict(suite.plugins(scenario.host)))
        for name, phases in observed.items():
            if tuple(phases) == FULL and name in installed:
                suite.controls.setdefault(suite.binary_of[installed[name]], label)
        record["unloaded"] = {
            name: suite.binary_of[case] for name, case in installed.items() if name not in observed
        }
        record["rows_observed"] = rows
        record["markers_observed"] = observed
    except Exception as error:  # noqa: BLE001
        check("the scenario runs", False, repr(error))
    finally:
        stopped, code = host.stop()
        check("the host stops cleanly", code == 0 and stopped.get("stopped") is True, [code, stopped])
    ok = all(entry["passed"] for entry in record["checks"])
    print(f"  {'ok  ' if ok else 'FAIL'} {label}")


# --- The rows -----------------------------------------------------------------------

SH = "fixturesh"
SK = "fixturesk"
ACTIVE, REJECTED, INCOMPATIBLE = "ACTIVE", "REJECTED", "INCOMPATIBLE"
SEL, NOT, UNAVAIL = "SELECTED", "NOT_SELECTED", "UNAVAILABLE"
FRESH = "FixtureSh"  # the bundled baseline's install name


def scenarios():
    s = []
    add = s.append
    baseline_selected = R(SH, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals")
    baseline_healthy = R(SH, "1.0.0", "B", ACTIVE, SEL, None)
    superseded = lambda version, origin: R(SH, version, origin, REJECTED, NOT, "superseded-candidate")

    # -- Version rows ---------------------------------------------------------------
    add(Scenario(
        "1.10.0 exceeds 1.9.0 numerically, not as text",
        [R(SH, "1.10.0", "U", ACTIVE, SEL, None), superseded("1.9.0", "U"), superseded("1.0.0", "B")],
        installs=[U("r1.9.0", "older"), U("r1.10.0", "newer")], ran=["newer"], serves=("fixtureShInfo", UPDATE_GREETING),
    ))
    add(Scenario(
        "a malformed triple is REJECTED and the bundle stays selected",
        [R(SH, "2.0", "U", REJECTED, NOT, "invalid-version"), baseline_selected],
        installs=[U("r2.0-malformed", "update")], ran=[FRESH], serves=("fixtureShInfo", BASE_GREETING),
    ))
    add(Scenario(
        "a leading zero is a malformed triple",
        [R(SH, "01.0.0", "U", REJECTED, NOT, "invalid-version"), baseline_selected],
        installs=[U("r01.0.0-leading-zero", "update")], ran=[FRESH],
    ))
    add(Scenario(
        "equal and older copies never override the bundle",
        [R(SH, "1.0.0", "U", REJECTED, NOT, "equal-to-bundled"), R(SH, "0.9.0", "U", REJECTED, NOT, "older-than-bundled"), baseline_selected],
        installs=[U("r1.0.0", "equal"), U("r0.9.0", "older")], ran=[FRESH], serves=("fixtureShInfo", BASE_GREETING),
    ))
    add(Scenario(
        "a schema major the slot cannot take is INCOMPATIBLE",
        [R(SH, "1.9.0", "U", INCOMPATIBLE, NOT, "schema-incompatible"), baseline_selected],
        installs=[U("r1.9.0-schema2", "update")], ran=[FRESH],
    ))
    add(Scenario(
        "a schema regression within the major is INCOMPATIBLE",
        [R(SH, "1.9.0", "U", INCOMPATIBLE, NOT, "schema-incompatible"), baseline_selected],
        installs=[U("r1.9.0-schema-regressed", "update")], ran=[FRESH],
    ))
    add(Scenario(
        "a higher release that is ineligible falls back visibly to the next eligible release",
        [
            R(SH, "4.0.0", "U", INCOMPATIBLE, NOT, "framework-incompatible"),
            R(SH, "2.0.0", "U", INCOMPATIBLE, NOT, "selection-feature-required"),
            R(SH, "1.5.0", "U", ACTIVE, SEL, "selected-with-refusals", "claims release 4.0.0"),
            superseded("1.0.0", "B"),
        ],
        installs=[U("r4.0.0-framework-future", "high"), U("r2.0.0-no-feature", "middle"), U("r1.5.0", "lower")],
        ran=["lower"], serves=("fixtureShInfo", UPDATE_GREETING),
    ))
    add(Scenario(
        "a higher release that is ineligible falls back visibly to the bundle",
        [
            R(SH, "4.0.0", "U", INCOMPATIBLE, NOT, "framework-incompatible"),
            R(SH, "9.0.0", "U", REJECTED, NOT, "signing-identifier-mismatch"),
            R(SH, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 9.0.0"),
        ],
        installs=[U("r4.0.0-framework-future", "high"), U("r9.0.0-other-identifier", "impostor")], ran=[FRESH],
    ))

    # -- Ties -----------------------------------------------------------------------
    tied = R(SH, "2.0.0", "U", REJECTED, NOT, "ambiguous-update")
    add(Scenario(
        "a tied greatest group is refused and a unique lower update is chosen",
        [tied, tied, R(SH, "1.5.0", "U", ACTIVE, SEL, "selected-with-refusals", "ambiguous-update"), superseded("1.0.0", "B")],
        installs=[U("r2.0.0", "first"), U("r2.0.0", "second"), U("r1.5.0", "lower")], ran=["lower"], rename=True,
    ))
    add(Scenario(
        "a tie falls back to the verified bundle",
        [tied, tied, R(SH, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", "installed more than once")],
        installs=[U("r2.0.0", "first"), U("r2.0.0", "second")], ran=[FRESH], rename=True,
    ))
    three = R(SH, "3.0.0", "U", REJECTED, NOT, "ambiguous-update")
    two = R(SH, "2.0.0", "U", REJECTED, NOT, "ambiguous-update")
    add(Scenario(
        "successive tied groups are refused in turn",
        [three, three, two, two, R(SH, "1.5.0", "U", ACTIVE, SEL, "selected-with-refusals"), superseded("1.0.0", "B")],
        installs=[U("r3.0.0", "aaa-three-a"), U("r3.0.0", "aaa-three-b"), U("r2.0.0", "aaa-two-a"),
                  U("r2.0.0", "aaa-two-b"), U("r1.5.0", "zzz-unique")],
        ran=["zzz-unique"], rename=True,
    ))
    add(Scenario(
        "successive tied groups leave the bundle when no unique release remains",
        [three, three, two, two, R(SH, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals")],
        installs=[U("r3.0.0", "aaa-three-a"), U("r3.0.0", "aaa-three-b"), U("r2.0.0", "aaa-two-a"), U("r2.0.0", "aaa-two-b")],
        ran=[FRESH], rename=True,
    ))
    add(Scenario(
        "lower duplicates do not contest a unique higher winner",
        [R(SH, "2.0.0", "U", ACTIVE, SEL, None), superseded("1.5.0", "U"), superseded("1.5.0", "U"), superseded("1.0.0", "B")],
        installs=[U("r2.0.0", "winner"), U("r1.5.0", "dup-a"), U("r1.5.0", "dup-b")], ran=["winner"], rename=True,
    ))
    add(Scenario(
        "a canonical-directory alias is one candidate, not a tie",
        [R(SH, "2.0.0", "U", ACTIVE, SEL, None), superseded("1.0.0", "B")],
        installs=[U("r2.0.0", "real"), Alias("alias", "real")], ran=["real"],
    ))
    add(Scenario(
        "a tie with no lower update and no bundle reports the missing slot",
        [tied, tied, R(SH, "unknown", None, REJECTED, UNAVAIL, "missing-bundled")],
        host="slot-no-bundle", installs=[U("r2.0.0", "first"), U("r2.0.0", "second")], rename=True,
    ))
    add(Scenario(
        "distinct canonical directories of equal bytes are a tie, not one candidate",
        [tied, tied, R(SH, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", "installed more than once")],
        installs=[U("r2.0.0", "copy-a"), U("r2.0.0", "copy-b")], ran=[FRESH],
    ))

    # -- Reserved identity, prefix and SDL claimants ---------------------------------
    claim = lambda provider, version: R(provider, version, "U", REJECTED, NOT, "reserved-identity")
    claimants = [
        ("claims-other-prefix", SH, "5.0.0"),
        ("claims-other-identifier", "fixtureother", "5.0.0"),
        ("claims-overlapping-prefix", "fixtureshx", "5.0.0"),
        ("claims-shorter-prefix", "fixture", "5.0.0"),
    ]
    for case, provider, version in claimants:
        # A refused copy under the slot's own identifier makes its healthy choice
        # `selected-with-refusals`; another identifier's claimant is not the slot's.
        owner = baseline_selected if provider == SH else baseline_healthy
        add(Scenario(
            f"{case}: refused alone before load, the owner present",
            [claim(provider, version), owner], installs=[U(case, "claimant")], ran=[FRESH],
        ))
        add(Scenario(
            f"{case}: refused alone before load, the owner absent",
            [claim(provider, version), R(SH, "unknown", None, REJECTED, UNAVAIL, "missing-bundled")],
            host="slot-no-bundle", installs=[U(case, "claimant")],
        ))
        add(Scenario(
            f"{case}: refused alone before load, the owner rejected",
            [claim(provider, version), R(SH, "1.0.0", "B", REJECTED, NOT, "signing-identifier-mismatch"),
             R(SH, "unknown", None, REJECTED, UNAVAIL, "no-eligible-candidate")],
            host="slot-bundle-other-identifier", installs=[U(case, "claimant")],
        ))
    add(Scenario(
        "a reserved-only identity cannot load from the per-user root and is not enabled",
        [R("fixtureinput", "5.0.0", "U", REJECTED, NOT, "reserved-only"), baseline_healthy],
        installs=[U("claims-reserved-only", "early")], ran=[FRESH],
    ))
    add(Scenario(
        "a reserved-only identity stays unloadable whatever else is missing",
        [R("fixtureinput", "5.0.0", "U", REJECTED, NOT, "reserved-only"), R(SH, "unknown", None, REJECTED, UNAVAIL, "missing-bundled")],
        host="slot-no-bundle", installs=[U("claims-reserved-only", "early")],
    ))
    add(Scenario(
        "an overlapping claim on a reserved-only identity is refused alone",
        [R("fixtureinputx", "5.0.0", "U", REJECTED, NOT, "reserved-identity"), baseline_healthy],
        installs=[U("claims-overlapping-reserved-only", "claimant")], ran=[FRESH],
    ))
    mismatch = lambda: R("fixtureod", "1.0.0", "U", REJECTED, SEL, "descriptor-mismatch")
    add(Scenario(
        "after loading, a descriptor naming the slot's identity under another manifest is refused alone, the owner present",
        [mismatch(), baseline_healthy], installs=[U("ordinary-describes-slot", "claimant")], ran=[FRESH],
        partial={"claimant": ("initializer", "factory")},
    ))
    add(Scenario(
        "after loading, a descriptor naming the slot's identity under another manifest is refused alone, the owner absent",
        [mismatch(), R(SH, "unknown", None, REJECTED, UNAVAIL, "missing-bundled")],
        host="slot-no-bundle", installs=[U("ordinary-describes-slot", "claimant")],
        partial={"claimant": ("initializer", "factory")},
    ))
    add(Scenario(
        "after loading, a descriptor naming the slot's identity under another manifest is refused alone, the owner rejected",
        [mismatch(), R(SH, "1.0.0", "B", REJECTED, NOT, "signing-identifier-mismatch"),
         R(SH, "unknown", None, REJECTED, UNAVAIL, "no-eligible-candidate")],
        host="slot-bundle-other-identifier", installs=[U("ordinary-describes-slot", "claimant")],
        partial={"claimant": ("initializer", "factory")},
    ))
    post = lambda: R("fixtureod", "1.0.0", "U", REJECTED, SEL, "reserved-identity")
    for case, label in (
        ("ordinary-claims-shipped-namespace", "a shipped slot's names"),
        ("ordinary-claims-reserved-only-namespace", "a reserved-only identity's names"),
    ):
        add(Scenario(
            f"after loading, an ordinary provider claiming {label} is refused alone, the owner present",
            [post(), baseline_healthy], installs=[U(case, "claimant")], ran=[FRESH],
            partial={"claimant": ("initializer", "factory")},
        ))
        add(Scenario(
            f"after loading, an ordinary provider claiming {label} is refused alone, the owner absent",
            [post(), R(SH, "unknown", None, REJECTED, UNAVAIL, "missing-bundled")],
            host="slot-no-bundle", installs=[U(case, "claimant")], partial={"claimant": ("initializer", "factory")},
        ))
        add(Scenario(
            f"after loading, an ordinary provider claiming {label} is refused alone, the owner rejected",
            [post(), R(SH, "1.0.0", "B", REJECTED, NOT, "signing-identifier-mismatch"),
             R(SH, "unknown", None, REJECTED, UNAVAIL, "no-eligible-candidate")],
            host="slot-bundle-other-identifier", installs=[U(case, "claimant")],
            partial={"claimant": ("initializer", "factory")},
        ))

    # -- The designated bundle ------------------------------------------------------
    missing = R(SH, "unknown", None, REJECTED, UNAVAIL, "missing-bundled")
    none = R(SH, "unknown", None, REJECTED, UNAVAIL, "no-eligible-candidate")
    add(Scenario("a missing designated bundle leaves the slot reserved and unavailable", [missing], host="slot-no-bundle",
                 absent_fields=["fixtureShInfo"]))
    add(Scenario(
        "a designated bundle whose release the catalogue does not state is refused",
        [R(SH, "1.0.1", "B", REJECTED, NOT, "catalogue-bundle-mismatch"), none], host="slot-bundle-release-mismatch",
    ))
    add(Scenario(
        "a designated bundle signed under another identifier is refused",
        [R(SH, "1.0.0", "B", REJECTED, NOT, "signing-identifier-mismatch"), none], host="slot-bundle-other-identifier",
    ))
    add(Scenario(
        "a designated bundle signed ad hoc is refused",
        [R(SH, "1.0.0", "B", REJECTED, NOT, "signature-refused"), none], host="slot-bundle-adhoc",
    ))
    add(Scenario(
        "a designated bundle needing a framework this host lacks is INCOMPATIBLE",
        [R(SH, "1.0.0", "B", INCOMPATIBLE, NOT, "framework-incompatible"), none], host="slot-bundle-framework-future",
    ))
    filled = R(SH, "1.10.0", "U", ACTIVE, SEL, "selected-with-refusals")
    for host, bundle_row, extra in (
        ("slot-no-bundle", None, [missing]),
        ("slot-bundle-release-mismatch", R(SH, "1.0.1", "B", REJECTED, NOT, "catalogue-bundle-mismatch"), []),
        ("slot-bundle-other-identifier", R(SH, "1.0.0", "B", REJECTED, NOT, "signing-identifier-mismatch"), []),
        ("slot-bundle-adhoc", R(SH, "1.0.0", "B", REJECTED, NOT, "signature-refused"), []),
        ("slot-bundle-framework-future", R(SH, "1.0.0", "B", INCOMPATIBLE, NOT, "framework-incompatible"), []),
    ):
        add(Scenario(
            f"a valid newer update fills the slot of a bundle that is missing or refused ({host})",
            [filled] + extra + ([bundle_row] if bundle_row else []), host=host,
            installs=[U("r1.10.0", "update")], ran=["update"], serves=("fixtureShInfo", UPDATE_GREETING),
            rows_note="The missing-bundle synthetic row persists while an update is active." if host == "slot-no-bundle" else None,
        ))
    add(Scenario(
        "equal and older copies cannot fill a missing designated bundle",
        [R(SH, "1.0.0", "U", REJECTED, NOT, "equal-to-bundled"), R(SH, "0.9.0", "U", REJECTED, NOT, "older-than-bundled"), missing],
        host="slot-no-bundle", installs=[U("r1.0.0", "equal"), U("r0.9.0", "older")],
    ))
    add(Scenario(
        "equal and older copies cannot fill a refused designated bundle",
        [R(SH, "1.0.0", "U", REJECTED, NOT, "equal-to-bundled"), R(SH, "0.9.0", "U", REJECTED, NOT, "older-than-bundled"),
         R(SH, "1.0.0", "B", REJECTED, NOT, "signing-identifier-mismatch"), none],
        host="slot-bundle-other-identifier", installs=[U("r1.0.0", "equal"), U("r0.9.0", "older")],
    ))
    add(Scenario(
        "an unexpected in-application claimant is refused and never substituted",
        [R(SH, "9.0.0", "B", REJECTED, NOT, "unexpected-bundled-candidate"),
         R("fixtureod", "1.0.0", "B", REJECTED, NOT, "unexpected-bundled-candidate"), baseline_selected],
        host="slot-unexpected-bundle", ran=["FixtureSh"],
    ))
    add(Scenario(
        "an unexpected in-application claimant does not fill a missing designated bundle",
        [R(SH, "9.0.0", "B", REJECTED, NOT, "unexpected-bundled-candidate"), missing],
        host="slot-missing-with-unexpected",
    ))
    add(Scenario(
        "an unexpected in-application claimant does not stop a valid update filling the slot",
        [R(SH, "9.0.0", "B", REJECTED, NOT, "unexpected-bundled-candidate"), filled, missing],
        host="slot-missing-with-unexpected", installs=[U("r1.10.0", "update")], ran=["update"],
    ))

    # -- The catalogue and the host's team ------------------------------------------
    invalid = R("(unknown)", "unknown", None, REJECTED, UNAVAIL, "catalogue-invalid")
    for host in ("catalogue-malformed", "catalogue-conflicting", "catalogue-partial-baseline", "catalogue-truncated"):
        add(Scenario(
            f"a defective catalogue runs no provider ({host})", [invalid], host=host,
            installs=[U("r1.10.0", "update"), U("ordinary", "ordinary")], absent_fields=["fixtureShInfo", "fixtureOdInfo"],
        ))
    hostless = lambda version, origin, reason: R(SH, version, origin, REJECTED, NOT, reason)
    add(Scenario(
        "an ad-hoc host admits no shipped candidate, and still loads an ordinary provider",
        [hostless("1.0.0", "B", "host-team-unavailable"), hostless("1.10.0", "U", "host-team-unavailable"),
         R(SH, "unknown", None, REJECTED, UNAVAIL, "no-eligible-candidate"), R("fixtureod", "1.0.0", "U", ACTIVE, SEL, None)],
        host="adhoc-host", installs=[U("r1.10.0", "update"), U("ordinary", "ordinary")], ran=["ordinary"],
        absent_fields=["fixtureShInfo"],
    ))

    # -- Composition order, and the whole report ------------------------------------
    add(Scenario(
        "identifier order, not catalogue order, is the order shipped identities load and start",
        [R(SH, "1.0.0", "B", ACTIVE, SEL, None), R(SK, "1.0.0", "B", ACTIVE, SEL, None)],
        host="two-slots", ran=["FixtureSh", "FixtureSk"], order=["FixtureSh", "FixtureSk"],
    ))
    add(Scenario(
        "a second slot's update is selected on its own",
        [R(SH, "1.0.0", "B", ACTIVE, SEL, None), R(SK, "1.0.0", "B", REJECTED, NOT, "superseded-candidate"),
         R(SK, "1.1.0", "U", ACTIVE, SEL, None)],
        host="two-slots", installs=[U("sk-r1.1.0", "sk-update")], ran=["FixtureSh", "sk-update"],
    ))
    add(Scenario(
        "the report is complete: every candidate, the unidentified bundle and a real provider named unknown",
        [
            R(SH, "1.10.0", "U", ACTIVE, SEL, "selected-with-refusals", "signing-identifier-mismatch"),
            R(SH, "1.0.0", "B", REJECTED, NOT, "superseded-candidate"),
            R(SH, "1.0.0", "U", REJECTED, NOT, "equal-to-bundled"),
            R(SH, "0.9.0", "U", REJECTED, NOT, "older-than-bundled"),
            R(SH, "9.0.0", "U", REJECTED, NOT, "signing-identifier-mismatch"),
            R(SH, "2.0", "U", REJECTED, NOT, "invalid-version"),
            R(SH, "1.9.0", "U", INCOMPATIBLE, NOT, "schema-incompatible"),
            R(SH, "2.0.0", "U", INCOMPATIBLE, NOT, "selection-feature-required"),
            R("fixtureother", "5.0.0", "U", REJECTED, NOT, "reserved-identity"),
            R("fixtureinput", "5.0.0", "U", REJECTED, NOT, "reserved-only"),
            R("fixtureod", "1.0.0", "U", ACTIVE, SEL, None),
            R("unknown", "1.0.0", "U", ACTIVE, SEL, None),
            R("(unknown)", "unknown", "U", REJECTED, NOT, "manifest-invalid"),
        ],
        installs=[
            U("r1.10.0", "u-newest"), U("r1.0.0", "u-equal"), U("r0.9.0", "u-older"),
            U("r9.0.0-other-identifier", "u-impostor"), U("r2.0-malformed", "u-malformed"),
            U("r1.9.0-schema2", "u-schema"), U("r2.0.0-no-feature", "u-nofeature"),
            U("claims-other-identifier", "u-claimant"), U("claims-reserved-only", "u-reserved-only"),
            U("ordinary", "u-ordinary"), U("unknown", "u-unknown"), U("unidentified", "u-unidentified"),
        ],
        ran=["u-newest", "u-ordinary", "u-unknown"],
    ))
    add(Scenario(
        "a real provider named unknown is distinct from the unidentified bundle's (unknown)",
        [R("unknown", "1.0.0", "U", ACTIVE, SEL, None), R("(unknown)", "unknown", "U", REJECTED, NOT, "manifest-invalid"),
         baseline_healthy],
        installs=[U("unknown", "real"), U("unidentified", "broken")], ran=["real", FRESH],
    ))
    return s


# The stable reasons this leaf's rows must each produce at least once; the collision,
# cascade and failure reasons belong to `selection-failures`.
OWNED_REASONS = {
    "older-than-bundled", "equal-to-bundled", "superseded-candidate", "reserved-identity", "reserved-only",
    "ambiguous-update", "invalid-version", "schema-incompatible", "missing-bundled", "catalogue-bundle-mismatch",
    "unexpected-bundled-candidate", "catalogue-invalid", "host-team-unavailable", "signing-identifier-mismatch",
    "selection-feature-required", "no-eligible-candidate", "selected-with-refusals", "framework-incompatible",
    "signature-refused", "manifest-invalid", "descriptor-mismatch",
}

PENDING = [
    (
        "The alternate-team host: a differently team-signed host derives its own Team ID, and its N and G parts",
        "needs a real second Developer ID team's certificate. `security find-identity` here lists one Developer ID "
        "identity, of the team that signs every fixture; nothing else can claim a second team. Owned by "
        "`alternate-team-signing`.",
    ),
]


def main():
    arguments = sys.argv[1:]
    only = None
    if "--only" in arguments:
        index = arguments.index("--only")
        only = arguments[index + 1]
        del arguments[index : index + 2]
    if len(arguments) != 3:
        raise SystemExit(__doc__)
    hosts, fixtures, output = (os.path.abspath(argument) for argument in arguments)
    suite = Suite(hosts, fixtures)
    results = []
    chosen = [scenario for scenario in scenarios() if only is None or only in scenario.name]
    print(f"{len(chosen)} scenarios")
    for scenario in chosen:
        print(scenario.name)
        for reversed_order in (False, True):
            run_scenario(suite, scenario, reversed_order, False, results)
        if scenario.rename:
            run_scenario(suite, scenario, False, True, results)

    # A refused-marker assertion is paired with a control: the same compiled binary
    # seen writing every marker in another run.
    controls = []
    for record in results:
        for name, binary in record.get("unloaded", {}).items():
            controls.append((record["label"], name, binary, suite.controls.get(binary)))
    uncontrolled = [entry for entry in controls if entry[3] is None]
    for label, name, binary, control in uncontrolled:
        print(f"  FAIL {label}: {name} ({binary}) never ran, and no run shows that binary writing its markers")
    print(f"{len(controls)} never-ran assertions; controls by binary: {json.dumps(suite.controls, indent=1)}")

    observed = {row["reason"] for record in results for row in record.get("rows_observed", []) if row["reason"]}
    unseen = sorted(OWNED_REASONS - observed) if only is None else []
    for reason in unseen:
        print(f"  FAIL no run produced the stable reason {reason}")
    print(f"stable reasons observed: {', '.join(sorted(observed))}")
    failed = [record for record in results if not all(check["passed"] for check in record["checks"])]
    with open(output, "w") as file:
        json.dump(
            {"runs": results, "controls": suite.controls, "uncontrolled": [list(entry[:3]) for entry in uncontrolled], "reasonsObserved": sorted(observed),
             "reasonsUnseen": unseen,
             "pending": [{"row": row, "reason": reason} for row, reason in PENDING]},
            file, indent=1, default=str,
        )
    print(f"{len(results)} host runs, {len(failed)} failed, {len(uncontrolled)} without a control, {len(unseen)} owned reasons unseen")
    for row, reason in PENDING:
        print(f"PENDING {row}: {reason}")
    sys.exit(1 if failed or uncontrolled or unseen else 0)


main()
