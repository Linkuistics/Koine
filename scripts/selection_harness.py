"""The signed-host harness of the selection acceptance (docs/specs/machine.md,
"Selection acceptance"), shared by the drivers that assert its rows:

  * scripts/verify-selection-decisions.py   the pre-load decision rows
  * scripts/verify-selection-failures.py    the failure boundary after choices freeze

Each scenario, and each alternative order within it, is its own signed host
process (Fixtures/SelectionHost, assembled and signed with its catalogue by
scripts/build-selection-hosts.py) over a fresh data directory, a fresh per-user
provider root and a fresh marker log. The driver is a client and a native
observer at once:

  * G: it reads `koineManagement.providers` over loopback HTTP with the host's
    grant and compares every candidate and synthetic row with the row the spec
    requires, and the structural invariants every report must hold;
  * N: the fixture providers write a marker when their initializer, their factory
    and their start run (Fixtures/FixtureProvider/initializer.c). The log names
    which images ran which phases, and anything not named ran nothing;
  * a scenario asserting that an image never ran is paired with a control: the same
    compiled binary is seen writing all three markers in another scenario of the
    run. A phase an image that did run never reached is paired the same way, by
    that binary or by a declared twin built from the same source without the defect.

A scenario may go on to further phases over the same data directory: an action
(a copy removed, replaced or added) and then a restart, which is a new host
process with a new marker log. Recovery from a failed choice is repair or removal,
then restart, and nothing else.

The real verifier, staging and loader run in every scenario. The one private seam
in use is the discovery order, reversed for the alternative run.
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

SH = "fixturesh"
SK = "fixturesk"
ACTIVE, REJECTED, INCOMPATIBLE, FAILED = "ACTIVE", "REJECTED", "INCOMPATIBLE", "FAILED"
SEL, NOT, UNAVAIL = "SELECTED", "NOT_SELECTED", "UNAVAILABLE"
FRESH = "FixtureSh"  # the bundled baseline's install name


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
    """An expected row. `origin` is B, U, or None for a synthetic row. `note` is a
    substring, or a list of them, the row's diagnostic must all contain."""
    return (provider, version, origin, state, selection, reason, note)


class Phase:
    """What one host process is expected to do, and the action that precedes it.

    `actions` are applied to the stopped host's data directory before it restarts:
    ("remove", name), ("install", case, name) or ("replace", name, case).
    """

    def __init__(
        self, rows, actions=(), ran=(), partial=None, serves=None, absent_fields=(), present_fields=(),
        order=None, rows_note=None, label=None,
    ):
        self.rows, self.rows_note, self.label = list(rows), rows_note, label
        self.actions = list(actions)
        # install name -> phases it reached; `ran` names reached every phase.
        self.markers = {name: FULL for name in ran}
        self.markers.update(partial or {})
        self.serves, self.order = serves, order
        self.absent_fields, self.present_fields = list(absent_fields), list(present_fields)


class Scenario(Phase):
    def __init__(
        self, name, rows, host="slot", installs=(), rename=False, then=(), env=None, reverse=True, **phase
    ):
        super().__init__(rows, **phase)
        self.name, self.host, self.installs = name, host, list(installs)
        self.rename, self.then, self.env, self.reverse = rename, list(then), env or {}, reverse


# --- Environment --------------------------------------------------------------------


class Suite:
    def __init__(self, hosts, fixtures, twins=None):
        self.hosts, self.fixtures = hosts, fixtures
        with open(HOSTS_SPEC) as file:
            self.spec = json.load(file)
        self.binary_of = {}
        with open(os.path.join(fixtures, "index.tsv")) as file:
            for line in file:
                case, binary = line.rstrip("\n").split("\t")[:2]
                self.binary_of[case] = binary
        # A binary that can never write every marker (it is built to fail after it
        # loads) -> the binary built from the same source without that defect.
        self.twins = dict(twins or {})
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
    """Signed host processes over one data directory, per-user root and (per process) marker log."""

    def __init__(self, suite, scenario, reversed_order, renames):
        self.suite = suite
        self.scenario = scenario
        self.reversed_order = reversed_order
        self.directory = tempfile.mkdtemp(prefix="koine-selection-")
        self.data = os.path.join(self.directory, "data")
        self.providers = os.path.join(self.data, "Providers")
        os.makedirs(self.providers)
        os.chmod(self.data, 0o700)
        self.renames = renames
        self.installed = {}  # install name (unrenamed) -> case, for what is in the per-user root now
        self.phase = 0
        for install in scenario.installs:
            self.install(install)
        self.process = None
        self.start()

    # -- the per-user root

    def _place(self, name):
        return os.path.join(self.providers, self.renames.get(name, name) + ".koineprovider")

    def install(self, install):
        destination = self._place(install.name)
        if install.alias_of:
            os.symlink(self.renames.get(install.alias_of, install.alias_of) + ".koineprovider", destination)
            return
        shutil.copytree(self.suite.bundle(install.case), destination, symlinks=True)
        self.installed[install.name] = install.case
        if install.approved:
            try:
                with open(os.path.join(destination, "manifest.json")) as file:
                    provider = json.load(file)["providerId"]
            except ValueError:
                return  # a manifest that names no provider has nothing to approve
            with open(os.path.join(self.providers, provider + ".approval.json"), "w") as file:
                json.dump({"providerId": provider, "teamIdentifier": self.suite.team}, file)

    def apply(self, actions):
        for action in actions:
            kind = action[0]
            if kind == "remove":
                shutil.rmtree(self._place(action[1]), ignore_errors=False)
                self.installed.pop(action[1], None)
            elif kind == "install":
                self.install(U(action[1], action[2]))
            elif kind == "replace":
                shutil.rmtree(self._place(action[1]))
                self.installed.pop(action[1], None)
                self.install(U(action[2], action[1]))
            else:
                raise ValueError(f"unknown action {action!r}")

    # -- the process

    def start(self):
        self.phase += 1
        # The assessment verdict is one constant across runs because nothing is quarantined.
        self.quarantined = subprocess.run(
            ["xattr", "-rl", self.data], capture_output=True, text=True
        ).stdout.count("com.apple.quarantine")
        self.marker_log = os.path.join(self.directory, f"markers-{self.phase}.log")
        environment = dict(os.environ, KOINE_FIXTURE_MARKER_LOG=self.marker_log, **self.scenario.env)
        command = [self.suite.host_binary(self.scenario.host), self.data] + (
            ["--reverse-discovery"] if self.reversed_order else []
        )
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

    def stop_process(self):
        """Ends the current host process: (what it printed on stopping, its exit code)."""
        self.process.stdin.close()
        line = self.process.stdout.readline()
        code = self.process.wait(timeout=60)
        return (json.loads(line) if line else {}), code

    def stop(self):
        result = self.stop_process()
        shutil.rmtree(self.directory, ignore_errors=True)
        return result


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


def _notes(expected):
    note = expected[6]
    return [] if not note else ([note] if isinstance(note, str) else list(note))


def check_phase(host, phase, check, suite, installed, record, controls_tag, tag=""):
    """Asserts one host process against its phase; returns nothing, records through `check`."""
    rows = host.rows()
    markers = host.markers()
    check("no installed copy is quarantined, so every assessment verdict is the same", host.quarantined == 0,
          host.quarantined)
    check("hostTeam", (host.ready["hostTeam"] is not None) == (suite.spec["hosts"][host.scenario.host]["signing"] == "developer-id"),
          host.ready["hostTeam"])
    for failure in invariants(rows):
        check("report invariant", False, failure)
    actual = sorted(normalise(row) for row in rows)
    wanted = sorted(row[:6] for row in phase.rows)
    check("rows", actual == wanted, {"actual": actual, "wanted": wanted})
    for expected in phase.rows:
        for note in _notes(expected):
            matching = [row for row in rows if normalise(row) == expected[:6]]
            text = " ".join(row["diagnostic"] or "" for row in matching)
            check(f"diagnostic of {expected[:6]} names {note!r}", note in text, text)
    # N: exactly the images the phase names ran, and only the phases it names.
    observed = {}
    for name, step in markers:
        observed.setdefault(name, []).append(step)
    wanted_markers = {name: list(steps) for name, steps in phase.markers.items()}
    check("markers", observed == wanted_markers, {"observed": observed, "wanted": wanted_markers})
    if phase.order:
        firsts = [name for name, step in markers if step == "start"]
        check("start order", firsts == phase.order, firsts)
    if phase.serves:
        root, greeting = phase.serves
        data = host.data_of("{ %s { greeting } }" % root)
        check(f"{root} is answered by the selected binary", data[root]["greeting"] == greeting, data)
    if phase.absent_fields or phase.present_fields:
        served = host.query_fields()
        if phase.absent_fields:
            check("no provider field is published", not [f for f in phase.absent_fields if f in served], served)
        if phase.present_fields:
            check("the surviving provider fields are published", all(f in served for f in phase.present_fields), served)
    # Controls: which compiled binary each install that did not run every phase would
    # have been, and which was seen to run every phase.
    for name, steps in observed.items():
        if tuple(steps) == FULL and name in installed:
            suite.controls.setdefault(suite.binary_of[installed[name]], controls_tag)
    record.setdefault("unloaded", {}).update(
        {name + tag: suite.binary_of[case] for name, case in installed.items() if name not in observed}
    )
    record.setdefault("partial", {}).update(
        {
            name + tag: {"binary": suite.binary_of[installed[name]], "reached": steps}
            for name, steps in observed.items()
            if name in installed and tuple(steps) != FULL
        }
    )
    record.setdefault("phases", []).append({"rows": rows, "markers": observed})
    record["rows_observed"] = record.get("rows_observed", []) + rows
    record["markers_observed"] = observed


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
    phases = [scenario] + scenario.then
    try:
        for index, phase in enumerate(phases):
            if index:
                stopped, code = host.stop_process()
                check(f"phase {index}: the host stops cleanly", code == 0 and stopped.get("stopped") is True, [code, stopped])
                host.apply(phase.actions)
                host.start()
            installed = dict(host.installed)
            installed.update(dict(suite.plugins(scenario.host)))
            prefix = "" if len(phases) == 1 else f"[phase {index + 1}{': ' + phase.label if phase.label else ''}] "
            phase_check = lambda name, passed, observed=None, prefix=prefix: check(prefix + name, passed, observed)
            check_phase(host, phase, phase_check, suite, installed, record, label, f" (phase {index + 1})" if index else "")
    except Exception as error:  # noqa: BLE001
        check("the scenario runs", False, repr(error))
    finally:
        stopped, code = host.stop()
        check("the host stops cleanly", code == 0 and stopped.get("stopped") is True, [code, stopped])
    ok = all(entry["passed"] for entry in record["checks"])
    print(f"  {'ok  ' if ok else 'FAIL'} {label}")


def main(scenarios, owned_reasons, pending, doc, twins=None, own_reason_note="", argv=None):
    """The whole driver: `<hosts> <fixtures> <results.json> [--only <substring>]`."""
    arguments = list(sys.argv[1:] if argv is None else argv)
    only = None
    if "--only" in arguments:
        index = arguments.index("--only")
        only = arguments[index + 1]
        del arguments[index : index + 2]
    if len(arguments) != 3:
        raise SystemExit(doc)
    hosts, fixtures, output = (os.path.abspath(argument) for argument in arguments)
    suite = Suite(hosts, fixtures, twins)
    results = []
    chosen = [scenario for scenario in scenarios() if only is None or only in scenario.name]
    print(f"{len(chosen)} scenarios")
    for scenario in chosen:
        print(scenario.name)
        for reversed_order in (False, True):
            if reversed_order and not scenario.reverse:
                continue
            run_scenario(suite, scenario, reversed_order, False, results)
        if scenario.rename:
            run_scenario(suite, scenario, False, True, results)

    # A refused-marker assertion is paired with a control: the same compiled binary
    # seen writing every marker in another run. A phase an image that did run never
    # reached is controlled by that binary or by its declared twin.
    controls = []
    for record in results:
        for name, binary in record.get("unloaded", {}).items():
            controls.append((record["label"], name, binary, suite.controls.get(binary)))
        for name, entry in record.get("partial", {}).items():
            binary = entry["binary"]
            controls.append(
                (record["label"], name, binary, suite.controls.get(binary) or suite.controls.get(suite.twins.get(binary)))
            )
    uncontrolled = [entry for entry in controls if entry[3] is None]
    for label, name, binary, control in uncontrolled:
        print(f"  FAIL {label}: {name} ({binary}) never ran every phase, and no run shows that binary or its twin writing its markers")
    print(f"{len(controls)} never-ran assertions; controls by binary: {json.dumps(suite.controls, indent=1)}")

    observed = {row["reason"] for record in results for row in record.get("rows_observed", []) if row["reason"]}
    unseen = sorted(owned_reasons - observed) if only is None else []
    for reason in unseen:
        print(f"  FAIL no run produced the stable reason {reason}")
    print(f"stable reasons observed: {', '.join(sorted(observed))}")
    failed = [record for record in results if not all(check["passed"] for check in record["checks"])]
    with open(output, "w") as file:
        json.dump(
            {"runs": results, "controls": suite.controls, "twins": suite.twins,
             "uncontrolled": [list(entry[:3]) for entry in uncontrolled], "reasonsObserved": sorted(observed),
             "reasonsUnseen": unseen, "pending": [{"row": row, "reason": reason} for row, reason in pending]},
            file, indent=1, default=str,
        )
    print(f"{len(results)} host runs, {len(failed)} failed, {len(uncontrolled)} without a control, {len(unseen)} owned reasons unseen")
    for row, reason in pending:
        print(f"PENDING {row}: {reason}")
    sys.exit(1 if failed or uncontrolled or unseen else 0)
