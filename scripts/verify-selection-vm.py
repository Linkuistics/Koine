#!/usr/bin/env python3
"""The V seam of the selection acceptance: the update and trust rows, run INSIDE a signed, isolated
TestAnyware macOS VM whose Gatekeeper is enforcing (scripts/vm-verify-selection.sh starts it and runs this).

Machine's "Selection acceptance" assigns these rows to N (the native loader), G (public GraphQL) and V. N
and G run on the build Mac (scripts/verify-selection-updates.py). This runs the same scenarios, with the
same harness (scripts/selection_harness.py), in a clean guest, changing exactly what V is for:

  * the hosts are the purpose-built signed hosts of Fixtures/SelectionHost, sealed with their catalogue and
    bundles and, for a closing run, notarized (scripts/build-selection-vm-hosts.py), and they are the
    copies the guest was given as a download: a zip carrying the quarantine attribute, unzipped;
  * a quarantined per-user install is a genuine download too (HostRun.download): the archive carries the
    attribute and the unarchiver gives it to everything it extracts. Nothing is written onto the tree, no
    verdict is injected (KOINE_FIXTURE_ASSESSMENT is never set) and the user-approved flag is not pre-set:
    Gatekeeper's own assessment of the image decides, and the driver asks the same question of every
    staged copy and records the answer beside the loaded paths;
  * the old host is the RELEASED, notarized Koine.app (v0.1.0), downloaded in the guest and launched as a
    user launches it, not a headless driver built from its source.

What is a scenario here is what N has: a fresh signed host process per scenario, per alternative discovery
order and per restart, a fresh marker log, and a control for every refused-marker assertion. Where the
expected verdict depends on Gatekeeper's notarization lookup, the driver reads `notarization.json`:
notarized hosts and updates are accepted under quarantine, and an un-notarized build is refused. A run on
hosts that are NOT notarized says so in its record and cannot close a row whose observation needs them.

usage: verify-selection-vm.py <hosts> <fixtures> <results.json> --conformance <tool>
                              --released-app <Koine.app> --released-credential <file> [--only <substring>]

Run from the tree scripts/vm-verify-selection.sh uploads: scripts/, Fixtures/SelectionHost/hosts.json,
docs/design, App/ProviderCatalogue.json. Needs python3 (3.9), the Command Line Tools (`nm`), and Finder.
"""

import importlib.util
import json
import os
import re
import subprocess
import sys
import tempfile
import time

# A quarantined install is a genuine download at V. Before the harness is read.
os.environ["KOINE_SELECTION_GENUINE_QUARANTINE"] = "1"
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import selection_harness as harness  # noqa: E402
from selection_harness import ACTIVE, INCOMPATIBLE, NOT, REJECTED, SEL, SH, SK, UPDATE_GREETING, Phase, R, Scenario, U  # noqa: E402

_spec = importlib.util.spec_from_file_location(
    "selection_updates", os.path.join(os.path.dirname(os.path.abspath(__file__)), "verify-selection-updates.py")
)
N = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(N)

FRESH = harness.FRESH
PROFILES = N.PROFILES
NOTARIZED = False  # set from <hosts>/../notarization.json in main()


# --- What the OS said, recorded ------------------------------------------------------------


def assessments(expect=None):
    """The native observation V adds to a phase: each staged copy, whether it carries the quarantine a download
    left, the verdict Gatekeeper gives its image when asked as the loader asks (`spctl --assess --type open
    --context context:primary-signature`), and the paths the host process actually mapped. `expect` is {label: accepted}:
    a staged copy whose verdict the phase states, which must be what the OS said.

    Recorded in the run's record under `assessments`, for the evidence document."""

    def check_phase(host, check, context):
        observed = {}
        for name, quarantined in sorted(host.staged_dirs().items()):
            images = sorted(harness.glob.glob(os.path.join(host.staging, name, "*.dylib")))
            verdicts = [harness.HostRun.assess(image) for image in images]
            observed[host.label_of(name)] = {
                "staged": name, "quarantined": quarantined,
                "accepted": all(ok for ok, _ in verdicts) if verdicts else None,
                "said": [text for _, text in verdicts],
            }
        loaded = [image["path"] for image in host.ready.get("images", []) if "/ProviderStaging/" in image["path"]]
        context["record"].setdefault("assessments", []).append({"assessed": observed, "loadedPaths": loaded})
        check("the loaded paths are staged copies, each a candidate's own",
              all("/ProviderStaging/" in path for path in loaded), loaded)
        for label, accepted in (expect or {}).items():
            seen = observed.get(label)
            check(f"Gatekeeper's verdict on the staged copy of {label} is {'accepted' if accepted else 'refused'}, as the loader judged it",
                  seen is not None and seen["quarantined"] and seen["accepted"] == accepted, seen)

    return check_phase


# --- The released application, as a user runs it ----------------------------------------------


class ReleasedApp:
    """The RELEASED, notarized Koine.app (v0.1.0) in the guest, launched with `open` as a user launches it.

    Its data directory is the user's (~/Library/Application Support/Koine); a credential with
    `koine:manage`, `desktop:read` and `desktop:control` was made in its window once, and is read from a file. Between
    runs the per-user provider root and the staging directory are emptied and the grants are left alone. Per-user bundles
    are placed with the approval record a user writes. It writes no markers, as no real provider does: what ran is what
    was mapped."""

    BASELINE_ROWS = harness.ReleasedHost.BASELINE_ROWS

    def __init__(self, suite, app, credential_file, installs=()):
        self.suite, self.app = suite, app
        with open(credential_file) as file:
            self.credential = file.read().strip()
        self.data = os.path.expanduser("~/Library/Application Support/Koine")
        self.providers = os.path.join(self.data, "Providers")
        self.staging = os.path.join(self.data, "ProviderStaging")
        self.installed = {}
        subprocess.run(["pkill", "-f", os.path.join(app, "Contents/MacOS")], capture_output=True)
        time.sleep(2)
        for path in (self.providers, self.staging, os.path.join(self.data, "endpoint.json")):
            if os.path.isdir(path):
                harness.make_writable(path)
                harness.shutil.rmtree(path)
            elif os.path.exists(path):
                os.remove(path)
        os.makedirs(self.providers)
        for case, name in installs:
            harness.shutil.copytree(suite.bundle(case), os.path.join(self.providers, name + ".koineprovider"), symlinks=True)
            provider = suite.manifest_of(case)["providerId"]
            with open(os.path.join(self.providers, provider + ".approval.json"), "w") as file:
                json.dump({"providerId": provider, "teamIdentifier": suite.team}, file)
            self.installed[name] = case
        self.endpoint = None
        for attempt in range(3):
            # LaunchServices is asked again where the first request produced no process: what is measured is what the
            # application does once it runs, not whether one `open` was honoured.
            subprocess.run(["open", app], check=True)
            deadline = time.time() + 45
            while time.time() < deadline and self.endpoint is None:
                try:
                    with open(os.path.join(self.data, "endpoint.json")) as file:
                        self.endpoint = json.load(file)
                except (OSError, ValueError):
                    time.sleep(2)
            if self.endpoint is not None:
                break
        if self.endpoint is None:
            running = subprocess.run(["pgrep", "-fl", os.path.join(app, "Contents/MacOS")], capture_output=True, text=True).stdout
            raise RuntimeError(f"the released application wrote no endpoint descriptor (running: {running.strip() or 'no'})")
        deadline = time.time() + 60
        while time.time() < deadline:  # the endpoint is written before the providers are all up
            try:
                status, reply = self.post(self.BASELINE_ROWS)
                if status == 200 and (reply.get("data") or {}).get("koineManagement"):
                    break
            except OSError:
                pass
            time.sleep(2)
        pids = subprocess.run(["pgrep", "-f", os.path.join(app, "Contents/MacOS")], capture_output=True, text=True).stdout.split()
        self.pid = int(pids[-1]) if pids else None
        self.ready = {"images": self.mapped_images()}

    def post(self, query, credential=None, variables=None):
        request = harness.urllib.request.Request(
            f"http://127.0.0.1:{self.endpoint['port']}{self.endpoint.get('path', '/graphql')}",
            data=json.dumps({"query": query, "variables": variables or {}}).encode(),
            headers={"Content-Type": "application/json", "Authorization": f"Bearer {credential or self.credential}"},
        )
        try:
            with harness.urllib.request.urlopen(request, timeout=30) as response:
                return response.status, json.loads(response.read())
        except harness.urllib.error.HTTPError as error:
            body = error.read()
            return error.code, json.loads(body) if body else None

    def data_of(self, query):
        status, reply = self.post(query)
        if status != 200 or reply.get("errors"):
            raise RuntimeError(f"{query} answered {status} {reply}")
        return reply["data"]

    def create_grant(self, capabilities):
        quoted = ", ".join('"%s"' % c for c in capabilities)
        return self.data_of(
            'mutation { koineCreateGrant(input: { clientLabel: "driver", capabilities: [%s] }) { credential } }' % quoted
        )["koineCreateGrant"]["credential"]

    def rows(self):
        return self.data_of(self.BASELINE_ROWS)["koineManagement"]["providers"]

    def mapped_images(self):
        """The images of the application's process that are provider bundles' (what `lsof` shows mapped), as the
        headless hosts report them: {"path"}."""
        if not self.pid:
            return []
        out = subprocess.run(["lsof", "-p", str(self.pid)], capture_output=True, text=True).stdout
        paths = sorted({line.split(None, 8)[-1] for line in out.splitlines() if "ProviderStaging" in line and ".dylib" in line})
        return [{"path": path, "classes": []} for path in paths]

    def staged(self):
        return sorted(os.listdir(self.staging)) if os.path.isdir(self.staging) else []

    def loaded_labels(self):
        return sorted(re.sub(r"-[0-9a-f]{32}$", "", os.path.basename(os.path.dirname(i["path"]))) for i in self.mapped_images())

    def stop(self):
        subprocess.run(["pkill", "-f", os.path.join(self.app, "Contents/MacOS")], capture_output=True)
        time.sleep(3)
        for path in (self.providers, self.staging):
            if os.path.isdir(path):
                harness.make_writable(path)
                harness.shutil.rmtree(path, ignore_errors=True)
        return {"stopped": True}, 0


def released_app_run(name, installs, rows, update_label, profile=None, compared=None):
    """One launch of the released application with these per-user bundles: the rows it serves (provider, version,
    state, text the diagnostic names), that the update it was given was refused before anything of it was staged or
    mapped, that its own desktop provider still answers as the contract says, and the conformance profile where one
    is named."""

    def run(suite, results, only):
        if only is not None and only not in name:
            return
        record, check = harness.recorder(results, name, f"{name} [the released application, notarized v0.1.0]",
                                         "released Koine.app")
        record["seam"] = "V"
        try:
            host = ReleasedApp(suite, ARGS["released_app"], ARGS["released_credential"], installs)
        except Exception as error:  # noqa: BLE001
            check("the released application starts", False, str(error))
            harness.finish_record(record)
            return
        try:
            served = host.rows()
            actual = sorted((r["provider"], r["version"], r["state"]) for r in served)
            check("the rows the released application serves", actual == sorted(r[:3] for r in rows),
                  {"actual": actual, "wanted": sorted(r[:3] for r in rows)})
            for provider, version, state, text in rows:
                if text:
                    diagnostic = " ".join(r["diagnostic"] or "" for r in served
                                          if (r["provider"], r["version"], r["state"]) == (provider, version, state))
                    check(f"{provider} {version} is {state}, naming {text!r}", text in diagnostic, diagnostic)
            staged = host.staged()
            mapped = host.loaded_labels()
            record["observed"] = {"staged": staged, "mapped": mapped, "images": [i["path"] for i in host.mapped_images()]}
            # The released host stages a per-user copy before it judges it (what it staged is recorded), and judges it before
            # anything is loaded: the image of the update is never mapped.
            check("only the bundled desktop provider's image is mapped: no image of the update is",
                  mapped == ["Desktop"], {"staged": staged, "mapped": mapped})
            ok = subprocess.run(["codesign", "--verify", "--strict", "--deep", host.app], capture_output=True, text=True)
            check("the released application's seal verifies, never altered", ok.returncode == 0, ok.stderr)
            assessed = subprocess.run(["spctl", "-a", "-t", "execute", "-vv", host.app], capture_output=True, text=True)
            check("Gatekeeper accepts the released application as notarized Developer ID",
                  assessed.returncode == 0 and "source=Notarized Developer ID" in assessed.stderr, assessed.stderr)
            operations = harness.desktop_operations(lambda q, v, c: host.post(q, c, v), host.create_grant)
            harness.check_desktop_expectations(operations, check, name)
            if compared:
                N.OPERATIONS[compared] = operations
            if profile:
                harness.check_conformance(host, profile, suite, check, record)
            record["rows_observed"] = []
            record.setdefault("unloaded", {})
            record.setdefault("partial", {})
            if update_label:
                case = dict((n, c) for c, n in installs)[update_label]
                record["unloaded"][update_label] = suite.binary_of[case]
            if all(entry["passed"] for entry in record["checks"]) and "Desktop" in mapped:
                suite.controls.setdefault("real-desktop-released", record["label"])
            stopped, code = host.stop()
            check("the released application is stopped", code == 0, [code, stopped])
        except Exception as error:  # noqa: BLE001
            check("the run completes", False, repr(error))
            try:
                host.stop()
            except Exception:  # noqa: BLE001
                pass
        harness.finish_record(record)

    return run


# --- Scenarios ------------------------------------------------------------------------------


def v_staged_copies(expect):
    """N.staged_copies for a guest whose hosts are downloads: a staged copy of a host's own bundle inherits the attribute
    of the application it came from, so it is quarantined exactly when the host is and is judged by the host's ticket.
    Every other staged copy is what the scenario says. The bundled copies are held to that inheritance, and then
    compared as the N expectation reads (not quarantined) so one set of expectations serves both seams."""

    def check_phase(host, check, context):
        own = host.suite.all_bundled_stage_names()
        host_quarantined = host.suite.host_quarantined(host.host_name)
        found = []
        for name, quarantined in sorted(host.staged_dirs().items()):
            if name in own:
                check(f"the staged copy of the host's own bundle {name} carries the host's download attribute exactly when the host does",
                      quarantined == host_quarantined, [quarantined, host_quarantined])
                found.append((host.label_of(name), False))
            else:
                found.append((host.label_of(name), quarantined))
        check("the staged copies, each candidate's own, and which of them carry the quarantine attribute",
              sorted(found) == sorted(expect), {"observed": sorted(found), "wanted": sorted(expect)})

    return check_phase


N.staged_copies = v_staged_copies


def find(table, prefix):
    (one,) = [scenario for name, scenario in table.items() if name.startswith(prefix)]
    return one


def downloaded(scenario, *names):
    """The installs of `names` are genuine downloads: each is quarantined, and the scenario says so."""
    for install in scenario.installs:
        if install.name in names:
            install.quarantined = True
    scenario.quarantine = True
    scenario.env = {}
    scenario.extra.append(assessments())
    return scenario


def scenarios():
    table = {scenario.name: scenario for scenario in N.scenarios()}
    chosen = []
    add = chosen.append
    # What Gatekeeper says of bytes it has a ticket for: accepted, where the hosts and updates are notarized.
    accepts = NOTARIZED

    # -- The old host and the new host over the old baseline --------------------------------------
    add(find(table, "a selection-aware host over an independently compiled old designated baseline"))

    # -- Compatible newer updates: the host is not rebuilt, the update is a genuine download ------
    update_installs = lambda scenario, *names: downloaded(scenario, *names) if accepts else scenario
    add(update_installs(find(table, "a newer desktop release over the released baseline"), "desktop-update"))
    add(find(table, "the shipped catalogue around this tree's desktop and workspace: the generation before any update"))
    add(update_installs(find(table, "a mixed release: a newer desktop beside the workspace baseline"), "desktop-update"))
    add(update_installs(find(table, "a mixed release: a newer workspace beside the desktop baseline"), "workspace-update"))
    add(update_installs(find(table, "both real providers updated independently"), "desktop-update", "workspace-update"))
    add(find(table, "both real updates under another principal class are selected like the others"))
    add(find(table, "real updates that do not state the feature are refused before they load"))
    add(find(table, "real updates that do not state the feature, under another principal class"))

    # The stand-ins the old host is given below are shown loading where the feature is supplied (the control pairing).
    add(find(table, "a compatible newer workspace update beside the desktop baseline"))
    add(find(table, "a workspace update under another principal class is selected like the others"))

    # -- A provider claiming a reserved pair under a fixture signing identifier -------------------
    add(find(table, "the same compiled binaries load as the designated baselines of a test catalogue"))
    add(find(table, "an approved same-team provider claiming the reserved pairs"))

    # -- Each trust refusal, for the desktop and the workspace stand-ins: the refused copy is a
    #    genuine download, the healthy lower update is not ----------------------------------------
    for name, scenario in table.items():
        if re.match(r"(desktop|workspace): ", name):
            downloaded(scenario, "bad", "escape")
            if "a failed quarantine assessment" in name:
                # The one case whose refusal IS Gatekeeper's: the OS is asked of the staged copy, and says no.
                scenario.extra.append(assessments({"bad": False}))
            chosen.append(scenario)

    # -- A quarantine refusal, recovered as its diagnostic says, under Gatekeeper's own verdict ---
    # An update no notarized host holds, so that Gatekeeper has no ticket for it: release 1.6.0.
    held = [R(SH, "1.6.0", "U", REJECTED, NOT, "quarantine-refused", "staged copy"),
            R(SH, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 1.6.0")]
    recovered = [R(SH, "1.6.0", "U", ACTIVE, SEL, None), R(SH, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")]
    add(Scenario(
        "a quarantine refusal is recovered as its diagnostic says: clear the attribute, delete the staged copy, restart",
        held, host="slot", installs=[U("r1.6.0", "update", quarantined=True)], quarantine=True, ran=[FRESH], images=["FixtureSh"],
        extra=[N.staged_copies([("FixtureSh", False), ("update", True)]), assessments({"update": False})],
        then=[
            Phase(held, actions=[("unquarantine", "update")], quarantine=True, ran=[FRESH], images=["FixtureSh"],
                  extra=[N.staged_copies([("FixtureSh", False), ("update", True)]), assessments({"update": False})],
                  label="the installed bundle cleared, its staged copy kept: still refused"),
            Phase(recovered, actions=[("unstage", "update")], ran=["update"], images=["update"],
                  serves=("fixtureShInfo", UPDATE_GREETING),
                  extra=[N.staged_copies([("FixtureSh", False), ("update", False)]), assessments()],
                  label="the staged copy deleted too: a fresh copy, carrying no attribute, loads"),
        ],
    ))

    # -- Equal bytes in both roots, a genuinely quarantined per-user copy, a legacy entry, restarts
    both = lambda user, bundled: [("FixtureSh@user", user), ("FixtureSh@bundled", bundled)]
    user_equal = [R(SH, "1.5.0", "B", ACTIVE, SEL, "selected-with-refusals"), R(SH, "1.5.0", "U", REJECTED, NOT, "equal-to-bundled")]
    user_refused = [R(SH, "1.5.0", "B", ACTIVE, SEL, "selected-with-refusals"), R(SH, "1.5.0", "U", REJECTED, NOT, "quarantine-refused")]
    caught_up = user_equal if accepts else user_refused
    verdict = {"FixtureSh@user": accepts}
    add(Scenario(
        "equal bytes in both roots, the per-user copy staged first: the host catches up and each copy stays its own",
        [R(SH, "1.5.0", "U", ACTIVE, SEL, None), R(SH, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")] if accepts else
        [R(SH, "1.5.0", "U", REJECTED, NOT, "quarantine-refused", "staged copy"),
         R(SH, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 1.5.0")],
        host="slot", installs=[U("r1.5.0", "FixtureSh", quarantined=True)], quarantine=True,
        ran=["FixtureSh@user"] if accepts else ["FixtureSh@bundled"],
        images=["FixtureSh@user"] if accepts else ["FixtureSh@bundled"],
        serves=("fixtureShInfo", UPDATE_GREETING) if accepts else None,
        extra=[N.staged_copies(both(True, False)), assessments({"FixtureSh@user": accepts})],
        then=[
            Phase(caught_up, host="slot-caught-up", quarantine=True, ran=["FixtureSh@bundled"], images=["FixtureSh@bundled"],
                  serves=("fixtureShInfo", UPDATE_GREETING),
                  extra=[N.staged_copies(both(True, False) + [("FixtureSh", False)]), assessments(verdict)],
                  label="the host catches up: the per-user copy is assessed again, on this start"),
        ],
    ))
    add(Scenario(
        "equal bytes in both roots, the bundled copy staged first: the per-user copy's assessment is not skipped",
        [R(SH, "1.5.0", "B", ACTIVE, SEL, None)], host="slot-caught-up", ran=["FixtureSh"], images=["FixtureSh"],
        serves=("fixtureShInfo", UPDATE_GREETING), extra=[N.staged_copies([("FixtureSh", False)]), assessments()],
        then=[
            Phase(caught_up, actions=[("put", U("r1.5.0", "FixtureSh", quarantined=True))], quarantine=True,
                  ran=["FixtureSh@bundled"], images=["FixtureSh@bundled"],
                  extra=[N.staged_copies(both(True, False)), assessments(verdict)],
                  label="the per-user copy arrives, a genuine download, after the bundled copy was staged"),
        ],
    ))
    add(find(table, "a legacy shared staging entry is never reused for an update"))
    quarantined_legacy = find(table, "a quarantined legacy entry is never inherited by the bundled copy of equal bytes")
    quarantined_legacy.env = {}
    for phase in quarantined_legacy.then:
        phase.env = {}
    add(quarantined_legacy)
    return chosen


# --- The run -------------------------------------------------------------------------------


ARGS = {}

# The released application's runs, each a per-user update a pre-extension host is given.
EXTRA = [
    released_app_run(
        "old host: the released application and its desktop provider", [], [("desktop", "1.0.0", "ACTIVE", None)], None,
        profile=PROFILES + "core-desktop-old-host.json", compared="old host, released desktop"),
    released_app_run(
        "old host: a newly published desktop update, the principal class kept", [("desktop-update", "upd")],
        [("desktop", "1.0.0", "ACTIVE", None), ("desktop", "1.1.0", "INCOMPATIBLE", N.INCOMPATIBLE_FEATURE)], "upd",
        profile=PROFILES + "core-desktop-old-host-update-refused.json"),
    released_app_run(
        "old host: a newly published desktop update, the principal class renamed", [("desktop-update-renamed", "upd")],
        [("desktop", "1.0.0", "ACTIVE", None), ("desktop", "1.1.0", "INCOMPATIBLE", N.INCOMPATIBLE_FEATURE)], "upd"),
    # The REAL workspace update needs provider framework 1.1, which the released host lacks: it is refused before load
    # for that reason, the first it meets. The feature is shown to be the only thing missing by the stand-in below.
    released_app_run(
        "old host: a newly published workspace update, the principal class kept", [("workspace-update", "upd")],
        [("desktop", "1.0.0", "ACTIVE", None), ("workspace", "1.1.0", "INCOMPATIBLE", "requires provider framework 1.1 or later")], "upd"),
    released_app_run(
        "old host: a newly published workspace update, the principal class renamed", [("workspace-update-renamed", "upd")],
        [("desktop", "1.0.0", "ACTIVE", None), ("workspace", "1.1.0", "INCOMPATIBLE", "requires provider framework 1.1 or later")], "upd"),
    released_app_run(
        "old host: a newly published workspace stand-in update, the principal class kept", [("sk-r1.1.0", "upd")],
        [("desktop", "1.0.0", "ACTIVE", None), (SK, "1.1.0", "INCOMPATIBLE", N.INCOMPATIBLE_FEATURE)], "upd"),
    released_app_run(
        "old host: a newly published workspace stand-in update, the principal class renamed", [("sk-r1.1.0-renamed", "upd")],
        [("desktop", "1.0.0", "ACTIVE", None), (SK, "1.1.0", "INCOMPATIBLE", N.INCOMPATIBLE_FEATURE)], "upd"),
    N.operations_preserved,
    N.instrument_self_tests,
]

OWNED_REASONS = {
    "not-approved", "approval-team-mismatch", "signature-refused", "location-outside-root", "framework-incompatible",
    "feature-unavailable", "os-incompatible", "architecture-incompatible", "quarantine-refused",
    "signing-identifier-mismatch", "selection-feature-required", "superseded-candidate", "selected-with-refusals",
}

PENDING = [
    ("Trust refusal and the alternate-team host, at V: a bundle signed by a second real Developer ID team",
     "needs a second real Developer ID team's certificate, which this keychain does not hold; no mock closes it. "
     "Owned by `alternate-team-signing`, at N, G and V."),
]


def main():
    global NOTARIZED
    arguments = list(sys.argv[1:])
    for flag in ("--released-app", "--released-credential"):
        if flag not in arguments:
            raise SystemExit(__doc__)
        index = arguments.index(flag)
        ARGS[flag[2:].replace("-", "_")] = os.path.abspath(arguments[index + 1])
        del arguments[index : index + 2]
    hosts = os.path.abspath(arguments[0])
    with open(os.path.join(os.path.dirname(hosts), "notarization.json")) as file:
        notarization = json.load(file)
    NOTARIZED = bool(notarization.get("notarized"))
    owned = set(OWNED_REASONS)
    pending = list(PENDING)
    if NOTARIZED:
        owned.add("equal-to-bundled")
    else:
        pending.append((
            "Every V row that needs an intact NOTARIZED purpose-built host",
            "this run's hosts and real updates were signed with the Developer ID identity and NOT notarized (no notary "
            "credential was available when they were built), so Gatekeeper has no ticket for any of them: a genuinely "
            "quarantined notarized update is not accepted here, and equal bytes in both roots are refused rather than "
            "equal-to-bundled. The refusals, the old host and the signing-identifier rows are observed; these are not closed."))
    harness.main(scenarios, owned_reasons=owned, pending=pending, doc=__doc__, extra_runs=EXTRA, argv=arguments)


main()
