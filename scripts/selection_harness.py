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

A phase can also assert what the whole host serves: the capabilities it makes available,
the Query and Mutation fields it publishes, fields that are published and unavailable, and
a conformance profile (docs/design/profiles/) held to the schema and the candidate rows it
served, with the profile's own controls seen red (`conformance=`).

A scenario may go on to further phases over the same data directory: an action
(a copy removed, replaced or added) and then a restart, which is a new host
process with a new marker log. Recovery from a failed choice is repair or removal,
then restart, and nothing else. A phase can also restart the data directory under a
different signed host (`host=`, a changed baseline or catalogue order), change the
assessment verdict the host is given (`env=`, for a copy quarantined with the
user-approved flag, which the OS then asks nothing about), make the per-user root
unreadable so that startup stops (`start_fails=`), and record the served schema digest
(`digest=`), which must be the same wherever a tag recurs and differ where the scenario
says it must (`differs=`).

The real verifier, staging and loader run in every scenario. The one private seam
in use is the discovery order, reversed for the alternative run.
"""

import glob
import hashlib
import json
import os
import re
import stat
import shutil
import subprocess
import sys
import tempfile
import threading
import urllib.error
import urllib.request

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOSTS_SPEC = os.path.join(REPOSITORY, "Fixtures", "SelectionHost", "hosts.json")

# The V seam: a quarantined install is a genuine download (HostRun.download) and the verdict on it is
# Gatekeeper's own, in a guest whose Gatekeeper is enforcing; no verdict is injected.
GENUINE_QUARANTINE = os.environ.get("KOINE_SELECTION_GENUINE_QUARANTINE") == "1"

PROVIDERS = (
    "{ koineManagement { providers { provider version schemaVersion state diagnostic "
    "candidateId origin selection selectedCandidateId reason } } }"
)
FULL = ("initializer", "factory", "start")
BASE_GREETING = "hello from the fixturesh provider"
UPDATE_GREETING = "hello from the fixturesh provider, revision 2"

SH = "fixturesh"
SH_READ = "fixturesh:read"
SK = "fixturesk"
ACTIVE, REJECTED, INCOMPATIBLE, FAILED = "ACTIVE", "REJECTED", "INCOMPATIBLE", "FAILED"
SEL, NOT, UNAVAIL = "SELECTED", "NOT_SELECTED", "UNAVAILABLE"
FRESH = "FixtureSh"  # the bundled baseline's install name


# --- Staging names, as the loader forms them ---------------------------------------


def content_digest(bundle):
    """ProviderStaging.digest(of:): SHA-256 over every entry's path, kind and content, and whether a
    file is executable, in path order; the first 16 bytes as hex."""
    entries = []
    for directory, names, files in os.walk(bundle):
        for name in names + files:
            entries.append(os.path.relpath(os.path.join(directory, name), bundle))
    digest = hashlib.sha256()
    for entry in sorted(entries):
        path = os.path.join(bundle, entry)
        mode = os.lstat(path).st_mode
        digest.update(f"{entry}\0".encode())
        if stat.S_ISDIR(mode):
            digest.update(b"d\0")
        elif stat.S_ISLNK(mode):
            digest.update(f"l{os.readlink(path)}\0".encode())
        elif stat.S_ISREG(mode):
            with open(path, "rb") as file:
                content = file.read()
            digest.update(f"f{'-' if mode & 0o111 == 0 else 'x'}{len(content)}\0".encode())
            digest.update(content)
        else:
            raise ValueError(f"{path} is neither a file, a directory nor a link")
    return digest.hexdigest()[:32]


def staged_name(origin, installed, bundle):
    """ProviderStaging.stagedName(of:from:origin:): the bundle's name, then a digest of its physical
    origin (BUNDLED, PER_USER), its canonical installed location and its content. `installed` is the
    canonical path (realpath) and `bundle` the directory whose content is digested."""
    name = os.path.basename(installed)
    name = name[: -len(".koineprovider")] if name.endswith(".koineprovider") else name
    identity = hashlib.sha256(f"{origin}\0{installed}\0{content_digest(bundle)}".encode()).hexdigest()[:32]
    return f"{name}-{identity}"


def legacy_staged_name(installed, bundle):
    """The name the earlier, content-only scheme gave a copy: `<bundle name>-<content digest>`."""
    name = os.path.basename(installed)
    name = name[: -len(".koineprovider")] if name.endswith(".koineprovider") else name
    return f"{name}-{content_digest(bundle)}"


def make_writable(directory):
    """Staged copies are read-only; a driver that damages or removes one has to undo that first."""
    for root, names, files in os.walk(directory):
        for entry in [root] + [os.path.join(root, n) for n in names + files]:
            if not os.path.islink(entry):
                os.chmod(entry, os.lstat(entry).st_mode | 0o200)


# --- Scenario vocabulary ------------------------------------------------------------


class Install:
    """One entry of the per-user provider root: a fixture case installed as `name`.

    `team` is the Team ID the approval record names (default: the team that signs the fixtures), and
    `approved=False` writes none; `outside` places the bundle outside the root and links to it from
    inside, as a location that resolves out of the root; `keep_approval` leaves the approval record as
    it is (a newer release replacing an older one, approved once)."""

    def __init__(self, case, name, approved=True, alias_of=None, quarantined=False, team=None, outside=False,
                 keep_approval=False):
        self.case, self.name, self.approved, self.alias_of = case, name, approved, alias_of
        self.quarantined, self.team, self.outside, self.keep_approval = quarantined, team, outside, keep_approval


def U(case, name, approved=True, quarantined=False, **more):
    return Install(case, name, approved, quarantined=quarantined, **more)


def Alias(name, target):
    return Install(None, name, True, alias_of=target)


def R(provider, version, origin, state, selection, reason, note=None):
    """An expected row. `origin` is B, U, or None for a synthetic row. `note` is a
    substring, or a list of them, the row's diagnostic must all contain."""
    return (provider, version, origin, state, selection, reason, note)


class Phase:
    """What one host process is expected to do, and the action that precedes it.

    `actions` are applied to the stopped host's data directory before it restarts:
    ("remove", name), ("install", case, name[, quarantined]), ("replace", name, case) or
    ("chmod", "providers", mode). `host` names the signed host this phase runs as (default: the
    scenario's), `env` is added to the scenario's environment for this phase alone,
    `quarantine` says a copy is quarantined and the verdict is the injected one,
    `start_fails` that startup must stop with that text, `digest` tags the served schema
    digest, `managed` has the phase show that koine:manage alone opens the management
    fields, and `clients` are (phase of a credential, root field, verdict) for a credential an
    earlier phase was given: its verdict is "denied", "served" or "unpublished". `actions` also
    include ("put", Install), ("replace-keep-approval", name, case), ("unquarantine", name),
    ("unstage", label-or-None), ("damage-staged", label), ("chmod-staging", mode) and
    ("plant-legacy", name, case[, quarantined]).
    """

    def __init__(
        self, rows, actions=(), ran=(), partial=None, serves=None, absent_fields=(), present_fields=(),
        order=None, rows_note=None, label=None, capabilities=(), no_capabilities=(), mutations=(),
        no_mutations=(), unavailable=(), conformance=None, host=None, env=None, quarantine=False,
        start_fails=None, digest=None, managed=False, clients=(), images=None, extra=(), operations=None,
    ):
        self.rows, self.rows_note, self.label = list(rows), rows_note, label
        self.actions = list(actions)
        # install name -> phases it reached; `ran` names reached every phase.
        self.markers = {name: FULL for name in ran}
        self.markers.update(partial or {})
        self.serves, self.order = serves, order
        self.absent_fields, self.present_fields = list(absent_fields), list(present_fields)
        # Capabilities `koine.availableCapabilities` lists, and ones it does not; Mutation fields
        # published, and not; (root field, text) of a published Query field whose resolution
        # fails with that text; a conformance profile file to hold the served schema and rows to.
        self.capabilities, self.no_capabilities = list(capabilities), list(no_capabilities)
        self.mutations, self.no_mutations = list(mutations), list(no_mutations)
        self.unavailable, self.conformance = list(unavailable), conformance
        self.host, self.env, self.quarantine, self.start_fails = host, env or {}, quarantine, start_fails
        self.digest, self.managed, self.clients = digest, managed, list(clients)
        # The provider images this phase's host process has mapped, by label (the install name, or
        # `<name>@bundled` / `<name>@user` where a bundle of one name is in both roots): what a real
        # first-party provider, which writes no marker, is seen loaded by. None: not asserted.
        self.images = images
        # Further checks of this phase, each called as `check(host, check, context)`; and the stem of
        # the fixture whose operations (items, errors, grants) are exercised, e.g. "FixtureSh".
        self.extra, self.operations = list(extra), operations


class Scenario(Phase):
    def __init__(
        self, name, rows, host="slot", installs=(), rename=False, then=(), env=None, reverse=True, differs=(),
        **phase
    ):
        super().__init__(rows, host=host, env=env, **phase)
        self.name, self.installs = name, list(installs)
        self.rename, self.then, self.reverse = rename, list(then), reverse
        # Pairs of digest tags the scenario's phases must have served different digests for.
        self.differs = list(differs)


# --- Environment --------------------------------------------------------------------


class Suite:
    def __init__(self, hosts, fixtures, twins=None, conformance=None):
        self.hosts, self.fixtures, self.conformance = hosts, fixtures, conformance
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

    def is_real(self, case):
        """Whether a case is a real first-party provider, which writes no marker: it is seen loaded by
        its image being mapped into the host process, and served by its state being ACTIVE."""
        return self.binary_of[case].startswith("real-")

    def manifest_of(self, case):
        with open(os.path.join(self.bundle(case), "manifest.json")) as file:
            return json.load(file)

    def bundled_stage(self, host):
        """{install name: staged directory name} of the bundles sealed inside a host, as the loader
        will name their staged copies."""
        cache = self.__dict__.setdefault("_bundled_stage", {})
        if host not in cache:
            plugins = os.path.join(self.hosts, host, "KoineSelectionHost.app", "Contents", "PlugIns")
            cache[host] = {}
            for name, _ in self.plugins(host):
                path = os.path.join(plugins, name + ".koineprovider")
                cache[host][name] = staged_name("BUNDLED", os.path.realpath(path), path)
        return cache[host]

    def all_bundled_stage_names(self):
        """The staged names of every bundle sealed inside any host of this suite: what a staged copy of a host's own
        bundle is called, whichever host staged it (a data directory outlives the host that began it)."""
        if "_all_bundled" not in self.__dict__:
            names = set()
            for host in self.spec["hosts"]:
                if os.path.isdir(os.path.join(self.hosts, host)):
                    names |= set(self.bundled_stage(host).values())
            self._all_bundled = names
        return self._all_bundled

    def host_quarantined(self, host):
        """Whether the host application itself carries a download's quarantine attribute (the V seam's notarized
        hosts arrive as a download)."""
        app = os.path.join(self.hosts, host, "KoineSelectionHost.app")
        return subprocess.run(["xattr", "-p", "com.apple.quarantine", app], capture_output=True).returncode == 0

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
        self.user_stage = {}  # install name -> the staged directory name the loader will give its copy
        self.collision_labels = {}  # staged directory -> label, where a bundle name is in both roots
        self.phase = 0
        self.credentials = []  # the credential each phase's host process gave, in phase order
        self.granted = []  # the capabilities each of those held when it was given
        for install in scenario.installs:
            self.install(install)
        self.process = None
        self.start(scenario)

    # -- the per-user root

    def _place(self, name):
        return os.path.join(self.providers, self.renames.get(name, name) + ".koineprovider")

    def install(self, install):
        destination = self._place(install.name)
        if install.alias_of:
            os.symlink(self.renames.get(install.alias_of, install.alias_of) + ".koineprovider", destination)
            return
        bundle = destination
        if install.outside:
            # The bundle lives beside the data directory; the root holds a link to it.
            bundle = os.path.join(self.directory, "elsewhere", os.path.basename(destination))
            os.makedirs(os.path.dirname(bundle), exist_ok=True)
            shutil.copytree(self.suite.bundle(install.case), bundle, symlinks=True)
            os.symlink(bundle, destination)
        else:
            shutil.copytree(self.suite.bundle(install.case), destination, symlinks=True)
        self.installed[install.name] = install.case
        self.user_stage[install.name] = staged_name("PER_USER", os.path.realpath(destination), bundle)
        if install.quarantined:
            self.quarantine(bundle)
        if install.approved and not install.keep_approval:
            try:
                with open(os.path.join(bundle, "manifest.json")) as file:
                    provider = json.load(file)["providerId"]
            except ValueError:
                return  # a manifest that names no provider has nothing to approve
            with open(os.path.join(self.providers, provider + ".approval.json"), "w") as file:
                json.dump({"providerId": provider, "teamIdentifier": install.team or self.suite.team}, file)

    @property
    def staging(self):
        return os.path.join(self.data, "ProviderStaging")

    def staged_dirs(self):
        """{staged directory name: does it carry com.apple.quarantine} for what the loader has staged."""
        found = {}
        if os.path.isdir(self.staging):
            for name in sorted(os.listdir(self.staging)):
                path = os.path.join(self.staging, name)
                attributes = subprocess.run(["xattr", "-l", path], capture_output=True, text=True).stdout
                images = glob.glob(os.path.join(path, "*.dylib"))
                for image in images:
                    attributes += subprocess.run(["xattr", "-l", image], capture_output=True, text=True).stdout
                found[name] = "com.apple.quarantine" in attributes
        return found

    def label_of(self, staged):
        """What a staged directory is called: the install's name, with a `@bundled` / `@user` suffix where
        one bundle name is in both roots (their staged names differ, which is the point)."""
        if staged in self.collision_labels:
            return self.collision_labels[staged]
        name = re.sub(r"-[0-9a-f]{32}$", "", staged)
        return re.sub(r"^p\d\d-", "", name) if self.renames else name

    def refresh_labels(self):
        bundled = self.suite.bundled_stage(self.host_name)
        both = set(bundled) & set(self.user_stage)
        self.collision_labels = {}
        for name in both:
            self.collision_labels[bundled[name]] = name + "@bundled"
            self.collision_labels[self.user_stage[name]] = name + "@user"

    def loaded_labels(self):
        """The provider images mapped into the current host process, by label: a bundle the loader
        refused, or never selected, left no image."""
        out = []
        for image in self.ready.get("images", []):
            if "/ProviderStaging/" in image["path"]:
                out.append(self.label_of(os.path.basename(os.path.dirname(image["path"]))))
        return sorted(out)

    @staticmethod
    def quarantine(bundle):
        """Marks each image of an installed bundle as downloaded and already approved by the user.

        The flags' 0x40 bit is the user's approval, which the OS takes as settled: dlopen of a
        quarantined image that Gatekeeper has not notarized would otherwise put up a dialog. The
        loader asks for a verdict whenever the attribute is present, so the verdict the host
        injects (KOINE_FIXTURE_ASSESSMENT) is the only one there is.

        With GENUINE_QUARANTINE (the V seam, in a Gatekeeper-enforcing guest) nothing is injected and
        nothing is pre-approved: see `download`."""
        if GENUINE_QUARANTINE:
            HostRun.download(bundle)
            return
        for image in glob.glob(os.path.join(bundle, "*.dylib")):
            subprocess.run(["xattr", "-w", "com.apple.quarantine", "00c3;65000000;KoineTest;", image], check=True)

    @staticmethod
    def download(bundle):
        """Makes the bundle what a downloaded and unzipped one is: the archive carries the attribute a browser
        writes (flags 0181, the agent, a UUID; not yet approved by the user) and the unarchiver gives it to
        everything it extracts, the bundle, its files and its images. The bundle is replaced by the
        extracted copy, so the attribute arrived the way a download's does and was not written onto the
        tree. The OS, not this driver, then decides what Gatekeeper says of each image."""
        parent = os.path.dirname(bundle)
        work = tempfile.mkdtemp(prefix="koine-download-")
        try:
            archive = os.path.join(work, os.path.basename(bundle) + ".zip")
            subprocess.run(["ditto", "-c", "-k", "--keepParent", bundle, archive], check=True)
            value = "0181;%x;Safari;%s" % (int(__import__("time").time()), __import__("uuid").uuid4())
            subprocess.run(["xattr", "-w", "com.apple.quarantine", value, archive], check=True)
            extracted = os.path.join(work, "extracted")
            os.makedirs(extracted)
            subprocess.run(["ditto", "-x", "-k", archive, extracted], check=True)
            (name,) = os.listdir(extracted)
            make_writable(bundle)
            shutil.rmtree(bundle)
            os.rename(os.path.join(extracted, name), os.path.join(parent, os.path.basename(bundle)))
        finally:
            shutil.rmtree(work, ignore_errors=True)

    @staticmethod
    def assess(path):
        """Gatekeeper's verdict on one image, asked as the loader asks it (`spctl --assess --type open --context
        context:primary-signature`): (accepted, the text it printed)."""
        result = subprocess.run(
            ["/usr/sbin/spctl", "--assess", "--type", "open", "--context", "context:primary-signature", "-v", path],
            capture_output=True, text=True,
        )
        return result.returncode == 0, (result.stdout + result.stderr).strip()

    def apply(self, actions):
        for action in actions:
            kind = action[0]
            if kind == "remove":
                shutil.rmtree(self._place(action[1]), ignore_errors=False)
                self.installed.pop(action[1], None)
                self.user_stage.pop(action[1], None)
            elif kind == "chmod":
                # The per-user root, made unreadable (0) or given back (0o700).
                assert action[1] == "providers"
                os.chmod(self.providers, action[2])
            elif kind == "install":
                self.install(U(action[1], action[2], quarantined=len(action) > 3 and action[3]))
            elif kind == "put":
                self.install(action[1])
            elif kind == "replace":
                shutil.rmtree(self._place(action[1]))
                self.installed.pop(action[1], None)
                self.install(U(action[2], action[1]))
            elif kind == "replace-keep-approval":
                shutil.rmtree(self._place(action[1]))
                self.installed.pop(action[1], None)
                self.install(U(action[2], action[1], keep_approval=True))
            elif kind == "unquarantine":
                subprocess.run(["xattr", "-dr", "com.apple.quarantine", self._place(action[1])], check=True)
            elif kind == "unstage":
                # With the host stopped: the user's second step in the diagnostic's own recovery.
                for name in list(os.listdir(self.staging)) if os.path.isdir(self.staging) else []:
                    if action[1] is None or self.label_of(name) == action[1]:
                        make_writable(os.path.join(self.staging, name))
                        shutil.rmtree(os.path.join(self.staging, name))
            elif kind == "damage-staged":
                (name,) = [n for n in os.listdir(self.staging) if self.label_of(n) == action[1]]
                directory = os.path.join(self.staging, name)
                make_writable(directory)
                (image,) = glob.glob(os.path.join(directory, "*.dylib"))
                with open(image, "ab") as file:
                    file.write(b"\0damaged after it was staged\0")
            elif kind == "chmod-staging":
                os.makedirs(self.staging, exist_ok=True)
                os.chmod(self.staging, action[1])
            elif kind == "plant-legacy":
                # ("plant-legacy", content case, for case, bundle name[, quarantined]): an entry of the
                # earlier content-only scheme, named for `for case`'s bytes and holding `content case`'s.
                _, content, named_for, bundle_name = action[:4]
                os.makedirs(self.staging, exist_ok=True)
                name = legacy_staged_name(bundle_name + ".koineprovider", self.suite.bundle(named_for))
                destination = os.path.join(self.staging, name)
                shutil.copytree(self.suite.bundle(content), destination, symlinks=True)
                if len(action) > 4 and action[4]:
                    self.quarantine(destination)
                self.legacy = getattr(self, "legacy", {})
                self.legacy[name] = content_digest(destination)
            else:
                raise ValueError(f"unknown action {action!r}")

    # -- the process

    def start(self, phase):
        """Starts the signed host this phase names over the data directory; raises if it stops."""
        self.phase += 1
        self.host_name = phase.host or self.scenario.host
        self.refresh_labels()
        self.env = dict(self.scenario.env, **phase.env)
        # Unless a phase quarantines a copy on purpose, nothing is, so every assessment verdict is the same.
        listing = subprocess.run(["xattr", "-rl", self.data], capture_output=True, text=True).stdout
        if GENUINE_QUARANTINE:
            # A staged copy of a host's OWN bundle inherits the attribute of the download the host arrived as:
            # that is the host's, not an installed copy's, and is judged by the host's ticket.
            own = tuple(f"/ProviderStaging/{name}" for name in self.suite.all_bundled_stage_names())
            self.quarantined = sum(
                1 for line in listing.splitlines()
                if "com.apple.quarantine" in line and not any(mark in line for mark in own)
            )
        else:
            self.quarantined = listing.count("com.apple.quarantine")
        self.marker_log = os.path.join(self.directory, f"markers-{self.phase}.log")
        environment = dict(os.environ, KOINE_FIXTURE_MARKER_LOG=self.marker_log, **self.env)
        command = [self.suite.host_binary(self.host_name), self.data] + (
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
            message = f"The host exited before it was ready: {self.process.stderr.read()}"
            self.process = None
            raise RuntimeError(message)
        self.ready = json.loads(line)
        if "error" in self.ready:
            self.process.wait(timeout=60)
            self.process = None
            raise RuntimeError(f"The host failed to start: {self.ready['error']}")
        self.credentials.append(self.ready["credential"])
        self.granted.append(self.own_capabilities())

    def post(self, query, credential=None, variables=None):
        request = urllib.request.Request(
            f"http://127.0.0.1:{self.ready['port']}/graphql",
            data=json.dumps({"query": query, "variables": variables or {}}).encode(),
            headers={"Content-Type": "application/json", "Authorization": f"Bearer {credential or self.ready['credential']}"},
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

    def type_fields(self, name):
        fields = self.data_of('{ __type(name: "%s") { fields { name } } }' % name)["__type"]["fields"]
        return [field["name"] for field in fields]

    def query_fields(self):
        return self.type_fields("Query")

    def capabilities(self):
        return self.data_of("{ koine { availableCapabilities } }")["koine"]["availableCapabilities"]

    def create_grant(self, capabilities):
        """A credential holding exactly these capabilities, made with the host's own grant."""
        quoted = ", ".join('"%s"' % c for c in capabilities)
        return self.data_of(
            'mutation { koineCreateGrant(input: { clientLabel: "driver", capabilities: [%s] }) { credential } }' % quoted
        )["koineCreateGrant"]["credential"]

    def own_capabilities(self, credential=None):
        """What the grant behind `credential` (by default this phase's) holds, as it says itself."""
        status, reply = self.post("{ koine { ownGrant { capabilities } } }", credential)
        return sorted(((reply or {}).get("data") or {}).get("koine", {}).get("ownGrant", {}).get("capabilities", []))

    def digest(self):
        return self.data_of("{ koine { schemaDigest } }")["koine"]["schemaDigest"]

    def markers(self):
        """[(install name, phase)] in the order written, from the staged image each line names."""
        try:
            with open(self.marker_log) as file:
                lines = [line.rstrip("\n").split("\t") for line in file if line.strip()]
        except FileNotFoundError:
            return []
        out = []
        for phase, image in lines:
            out.append((self.label_of(os.path.basename(os.path.dirname(image))), phase))
        return out

    def stop_process(self):
        """Ends the current host process: (what it printed on stopping, its exit code)."""
        self.process.stdin.close()
        line = self.process.stdout.readline()
        code = self.process.wait(timeout=60)
        return (json.loads(line) if line else {}), code

    def stop(self):
        # A host that never started has nothing to stop, and its data directory is given back.
        result = self.stop_process() if self.process else ({"stopped": True}, 0)
        if os.path.isdir(self.providers):
            os.chmod(self.providers, 0o700)
        # Staged copies are read-only: without this the directory is left behind, run after run.
        make_writable(self.directory)
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
    if phase.quarantine and GENUINE_QUARANTINE:
        check("a quarantined copy is judged by Gatekeeper's own verdict: nothing is injected",
              host.quarantined > 0 and "KOINE_FIXTURE_ASSESSMENT" not in host.env
              and "KOINE_FIXTURE_ASSESSMENT" not in os.environ, [host.quarantined, host.env])
    elif phase.quarantine:
        check("a quarantined copy is judged by the injected verdict alone",
              host.quarantined > 0 and host.env.get("KOINE_FIXTURE_ASSESSMENT") in ("accept", "refuse"),
              [host.quarantined, host.env.get("KOINE_FIXTURE_ASSESSMENT")])
    else:
        check("no installed copy is quarantined, so every assessment verdict is the same", host.quarantined == 0,
              host.quarantined)
    check("hostTeam", (host.ready["hostTeam"] is not None) == (suite.spec["hosts"][host.host_name]["signing"] == "developer-id"),
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
    loaded = host.loaded_labels()
    if phase.images is not None:
        check("the provider images mapped into the process", loaded == sorted(phase.images),
              {"observed": loaded, "wanted": sorted(phase.images)})
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
    if phase.capabilities or phase.no_capabilities:
        available = host.capabilities()
        if phase.capabilities:
            check("the capabilities of these providers are available", all(c in available for c in phase.capabilities), available)
        if phase.no_capabilities:
            check("no capability of these providers is available", not [c for c in phase.no_capabilities if c in available], available)
    if phase.mutations or phase.no_mutations:
        served = host.type_fields("Mutation")
        if phase.mutations:
            check("these Mutation fields are published", all(f in served for f in phase.mutations), served)
        if phase.no_mutations:
            check("none of these Mutation fields is published", not [f for f in phase.no_mutations if f in served], served)
    for root, text in phase.unavailable:
        status, reply = host.post("{ %s { greeting } }" % root)
        errors = (reply or {}).get("errors") or []
        check(f"{root} is published and its resolution fails as unavailable with {text!r}",
              bool(errors) and all(text in (e.get("message") or "") and (e.get("extensions") or {}).get("kind") == "unavailable"
                                   for e in errors) and not (reply.get("data") or {}).get(root),
              [status, reply])
    if phase.operations:
        check_operations(host, phase.operations, check)
    for extra in phase.extra:
        extra(host, check, {"suite": suite, "installed": installed, "rows": rows, "record": record})
    if phase.conformance:
        check_conformance(host, phase.conformance, suite, check, record)
    if phase.digest:
        served = host.digest()
        first = record.setdefault("digests", {}).setdefault(phase.digest, served)
        check(f"the schema digest {phase.digest!r} is the same wherever it recurs in this run", served == first,
              [served, first])
        if phase.order:
            check_composition(host, phase.order, installed, suite, check)
    if phase.managed:
        check_management(host, check)
    # Authority is only ever what a grant was given. A credential from an earlier phase still holds
    # exactly what it held, whatever this restart made available, and each verdict the phase names
    # for one is what it serves now.
    for number, (credential, held) in enumerate(zip(host.credentials[:-1], host.granted[:-1]), 1):
        now = host.own_capabilities(credential)
        check(f"the grant behind phase {number}'s credential is unchanged by the restart: no authority is added",
              now == held, [now, held])
    for number, root, verdict in phase.clients:
        check_client(host, host.credentials[number - 1], number, root, verdict, check)
    # Controls: which compiled binary each install that did not run every phase would
    # have been, and which was seen to run every phase. A real first-party provider writes no
    # marker: it is seen to run by its image being mapped while a row for its release is ACTIVE.
    active = {(row["provider"], row["version"]) for row in rows if row["state"] == ACTIVE}
    fixtures = {name: case for name, case in installed.items() if not suite.is_real(case)}
    real = {name: case for name, case in installed.items() if suite.is_real(case)}
    for name, steps in observed.items():
        if tuple(steps) == FULL and name in fixtures:
            suite.controls.setdefault(suite.binary_of[fixtures[name]], controls_tag)
    record.setdefault("unloaded", {}).update(
        {name + tag: suite.binary_of[case] for name, case in fixtures.items() if name not in observed}
    )
    record.setdefault("partial", {}).update(
        {
            name + tag: {"binary": suite.binary_of[fixtures[name]], "reached": steps}
            for name, steps in observed.items()
            if name in fixtures and tuple(steps) != FULL
        }
    )
    for name, case in real.items():
        if phase.images is None:
            continue  # a phase that states no images asserts nothing of a real install's
        manifest = suite.manifest_of(case)
        binary = suite.binary_of[case]
        if name in loaded and (manifest["providerId"], manifest["version"]) in active:
            suite.controls.setdefault(binary, controls_tag)
        elif name in loaded:
            record["partial"][name + tag] = {"binary": binary, "reached": ["image"]}
        else:
            record["unloaded"][name + tag] = binary
    record.setdefault("phases", []).append({"rows": rows, "markers": observed})
    record["rows_observed"] = record.get("rows_observed", []) + rows
    record["markers_observed"] = observed


CORE_DESIGN = os.path.join(REPOSITORY, "docs", "design", "core-schema-extension-host.graphql")
EXTENSION = re.compile(r"^extend type (Query|Mutation) \{\n(.*?)\n\}\n", re.S | re.M)


def composed_design(suite, order, installed):
    """The core's design SDL with each named provider's contribution added in `order`: what a host that
    composes them in that order serves, written out so the conformance tool can print it and take its digest."""
    with open(CORE_DESIGN) as file:
        text = file.read()
    bodies = {"Query": [], "Mutation": []}
    rest = []
    for name in order:
        with open(os.path.join(suite.bundle(installed[name]), "schema.graphql")) as file:
            schema = file.read() + "\n"
        for root, body in EXTENSION.findall(schema):
            bodies[root].append(body)
        rest.append(EXTENSION.sub("", schema).strip())
    for root, added in bodies.items():
        opening = f"\ntype {root} {{\n"
        start = text.index(opening) + len(opening)
        end = text.index("\n}\n", start)
        text = text[:end] + "".join("\n" + body for body in added) + text[end:]
    return text + "\n" + "\n\n".join(part for part in rest if part) + "\n"


def check_composition(host, order, installed, suite, check):
    """Holds the served schema and its digest to the design written out in the start order the phase
    asserts, and shows the same contributions in the reverse order turn the digest half red: the digest
    is of declared order, so that is where a contribution's position is read."""
    if not suite.conformance:
        check("the conformance tool is given (--conformance)", False, None)
        return
    query = subprocess.run([suite.conformance, "--print-query"], capture_output=True, text=True, check=True).stdout
    status, introspection = host.post(query)
    served = host.digest()
    work = tempfile.mkdtemp(prefix="koine-selection-order-")
    try:
        with open(os.path.join(work, "introspection.json"), "w") as file:
            json.dump(introspection, file)

        def hold(names):
            design = os.path.join(work, "design.graphql")
            with open(design, "w") as file:
                file.write(composed_design(suite, names, installed))
            return subprocess.run(
                [suite.conformance, "--introspection", os.path.join(work, "introspection.json"), "--design", design,
                 "--served-digest", served], capture_output=True, text=True,
            )

        clean = hold(order)
        check(f"the served schema and digest are the core with {', '.join(order)} composed in that order: CONFORMANT",
              clean.returncode == 0 and "CONFORMANT" in clean.stdout, clean.stdout[-600:])
        if len(order) > 1:
            red = hold(list(reversed(order)))
            check("control: the same contributions composed in the reverse order are not the served digest",
                  red.returncode != 0 and "they differ" in red.stdout, red.stdout[-600:])
    finally:
        shutil.rmtree(work, ignore_errors=True)


def check_management(host, check):
    """A grant without koine:manage reads the digest, and the management fields refuse it."""
    created = host.data_of(
        'mutation { koineCreateGrant(input: { clientLabel: "no manage", capabilities: ["%s"] }) '
        "{ credential grant { grantId capabilities } } }" % SH_READ
    )["koineCreateGrant"]
    weak = created["credential"]
    check("the grant made for the check holds no koine:manage", "koine:manage" not in created["grant"]["capabilities"],
          created["grant"])
    status, reply = host.post("{ koine { schemaDigest } }", weak)
    check("without koine:manage the digest is still served, and is the one koine:manage reads",
          status == 200 and not (reply or {}).get("errors")
          and reply["data"]["koine"]["schemaDigest"] == host.digest(), [status, reply])
    required = "This operation requires the koine:manage capability."
    for name, query in (
        ("koineManagement.providers", "{ koineManagement { providers { provider } } }"),
        ("koineManagement.grants", "{ koineManagement { grants { grantId } } }"),
        ("koineManagement.osPermissions", "{ koineManagement { osPermissions { permission } } }"),
        ("koineCreateGrant", 'mutation { koineCreateGrant(input: { clientLabel: "x", capabilities: [] }) { credential } }'),
        ("koineRevokeGrant", 'mutation { koineRevokeGrant(grantId: "%s") { grantId } }' % created["grant"]["grantId"]),
    ):
        status, reply = host.post(query, weak)
        errors = (reply or {}).get("errors") or []
        check(f"{name} refuses a grant without koine:manage",
              bool(errors) and all(required in (e.get("message") or "")
                                   and (e.get("extensions") or {}).get("requiredCapability") == "koine:manage"
                                   for e in errors), [status, reply])
        check(f"{name} returned nothing to it", not any(((reply or {}).get("data") or {}).values()), reply)
    status, reply = host.post("{ koineManagement { providers { provider } } }")
    check("the same field answers a grant with koine:manage",
          status == 200 and not reply.get("errors") and bool(reply["data"]["koineManagement"]["providers"]), reply)


def check_client(host, credential, number, root, verdict, check):
    """What a credential given in an earlier phase is told of `root` now."""
    status, reply = host.post("{ %s { greeting } }" % root, credential)
    errors = (reply or {}).get("errors") or []
    data = ((reply or {}).get("data") or {}).get(root)
    if verdict == "denied":
        passed = bool(errors) and data is None and all(
            (e.get("extensions") or {}).get("kind") == "permission" for e in errors
        )
    elif verdict == "served":
        passed = not errors and bool(data)
    else:  # "unpublished"
        passed = bool(errors) and data is None and all(
            (e.get("extensions") or {}).get("kind") != "permission" for e in errors
        )
    check(f"phase {number}'s credential is {verdict} at {root}", passed, [status, reply])


def check_conformance(host, profile, suite, check, record):
    """Holds the served schema and provider rows to a conformance profile with the same
    tool `task conformance` uses (Tools/Conformance), then shows the check red against
    mutated copies of the pin: a profile that cannot fail proves nothing."""
    if not suite.conformance:
        check("the conformance tool is given (--conformance)", False, None)
        return
    query = subprocess.run([suite.conformance, "--print-query"], capture_output=True, text=True, check=True).stdout
    status, introspection = host.post(query)
    served = host.data_of("{ koine { schemaDigest } }")["koine"]["schemaDigest"]
    work = tempfile.mkdtemp(prefix="koine-selection-profile-")
    try:
        files = {"introspection.json": introspection, "providers.json": host.rows()}
        for name, value in files.items():
            with open(os.path.join(work, name), "w") as file:
                json.dump(value, file)
        path = os.path.join(REPOSITORY, profile)
        with open(path) as file:
            pinned = json.load(file)

        def hold(pin, extra=(), design=None):
            copy = os.path.join(work, "profile.json")
            document = dict(pinned, design=design or os.path.join(os.path.dirname(path), pinned["design"]), providers=pin)
            with open(copy, "w") as file:
                json.dump(document, file)
            return subprocess.run(
                [suite.conformance, "--introspection", os.path.join(work, "introspection.json"), "--profile", copy,
                 "--providers", os.path.join(work, "providers.json"), "--served-digest", served, *extra],
                capture_output=True, text=True,
            )

        clean = hold(pinned["providers"])
        check(f"the host holds the profile {profile}: CONFORMANT", clean.returncode == 0 and "CONFORMANT" in clean.stdout,
              clean.stdout[-600:])
        controls = {}
        if pinned["providers"]:
            first = pinned["providers"][0]
            if pinned.get("management") == "baseline":
                # A baseline row has no reason or selection to be wrong about: the row's release and state are.
                wrong_reason = [dict(first, version="9.9.9")] + pinned["providers"][1:]
                wrong_selection = [dict(first, state="REJECTED" if first.get("state") != "REJECTED" else "ACTIVE")] + pinned["providers"][1:]
            else:
                wrong_reason = [dict(first, reason="a-reason-nobody-gives")] + pinned["providers"][1:]
                wrong_selection = [dict(first, selection="NOT_SELECTED" if first.get("selection") == "SELECTED" else "SELECTED")] + pinned["providers"][1:]
            for what, pin, expected in (
                ("a reason that is not served", wrong_reason, "is not served as expected"),
                ("a selection that is not served", wrong_selection, "is not served as expected"),
                ("a row left out of the pin", pinned["providers"][1:], "unexpected row"),
                ("a provider the host does not serve", pinned["providers"]
                 + [{"provider": "absentprovider", "version": "1.0.0", "schemaVersion": "1.0.0", "state": "ACTIVE"}], "is missing"),
            ):
                red = hold(pin)
                controls[what] = red.returncode
                check(f"control: a profile with {what} turns the check red, naming {expected!r}",
                      red.returncode != 0 and expected in red.stdout, red.stdout[-600:])
            # Each workspace row pinned at the RETAINED release instead: the repair is 1.0.1/1.0.1, and a pin
            # that still said 1.0.0 must not be able to pass for it.
            for index, row in enumerate(pinned["providers"]):
                moved = {key: "1.0.0" for key in ("version", "schemaVersion") if row.get("provider") == "workspace" and row.get(key) == "1.0.1"}
                if not moved:
                    continue
                red = hold(pinned["providers"][:index] + [dict(row, **moved)] + pinned["providers"][index + 1:])
                what = f"the workspace row {index + 1} ({row['origin']} {row['version']}) pinned at the retained 1.0.0"
                controls[what] = red.returncode
                check(f"control: a profile with {what} turns the check red, naming 'is not served as expected'",
                      red.returncode != 0 and "is not served as expected" in red.stdout, red.stdout[-600:])
        # The design half is seen red too: the wrong design (another host's, with a provider in
        # it) and this design with one nullability marker removed.
        own = os.path.join(os.path.dirname(path), pinned["design"])
        with open(own) as file:
            text = file.read()
        marker = "koine: Koine!"
        if marker not in text:
            check("the design control has something to mutate", False, marker)
        mutated = os.path.join(work, "mutated.graphql")
        with open(mutated, "w") as file:
            file.write(text.replace(marker, "koine: Koine", 1))
        # Every other composed design: the desktop one, the retained 1.0.0 desktop + workspace one and the
        # repaired 1.0.1 one, which differs from it in three descriptions alone. Each must turn the check red.
        designs = [os.path.join(REPOSITORY, "docs", "design", name) for name in
                   ("desktop-schema-extension-host.graphql", "desktop-workspace-schema-extension-host.graphql",
                    "desktop-workspace-repair-schema-extension-host.graphql")]
        others = [design for design in designs if os.path.realpath(design) != os.path.realpath(own)]
        for what, design in [(f"the design {os.path.basename(design)}", design) for design in others] + [
                ("a design with a nullability marker removed", mutated)]:
            red = hold(pinned["providers"], design=design)
            controls[what] = red.returncode
            check(f"control: {what} turns the check red", red.returncode != 0 and "difference(s) between" in red.stdout and "they differ" in red.stdout,
                  red.stdout[-600:])
        record.setdefault("conformance", []).append({"profile": profile, "controls": controls, "digest": served})
    finally:
        shutil.rmtree(work, ignore_errors=True)


def check_failed_start(host, phase, failure, suite, check, record):
    """A host that must not start: it stops with the phase's text, before any provider code ran."""
    check(f"startup stops, naming {phase.start_fails!r}", failure is not None and phase.start_fails in failure,
          failure)
    check("no provider image ran, the designated baselines included", host.markers() == [], host.markers())
    installed = dict(host.installed)
    installed.update(dict(suite.plugins(host.host_name)))
    record.setdefault("unloaded", {}).update(
        {f"{name} (a startup that stops)": suite.binary_of[case] for name, case in installed.items()}
    )


# --- Operations of a provider, as any client exercises them --------------------------


def _errors(reply):
    return (reply or {}).get("errors") or []


def _kind(error):
    return (error.get("extensions") or {}).get("kind")


def check_operations(host, stem, check):
    """A fixture's operations work in the selected binary: its items are served, its failures arrive as their
    kinds, a control action runs and is seen, and a grant holds exactly what it was given (a read-only
    grant reads and is refused the action, naming the capability it lacks)."""
    head = stem[0].lower() + stem[1:]
    lower = stem.lower()
    items = host.data_of("{ %sItems { ref name } }" % head)[f"{head}Items"]
    check(f"{stem}: its items are served", [item["name"] for item in items] == ["first", "second"], items)
    status, reply = host.post("{ %sProbe(outcome: UNAVAILABLE) }" % head)
    check(f"{stem}: an unavailable outcome arrives as unavailable",
          bool(_errors(reply)) and all(_kind(e) == "unavailable" for e in _errors(reply)), [status, reply])
    status, reply = host.post('{ %sItem(ref: "koine://%s/item/99") { name } }' % (head, lower))
    check(f"{stem}: a reference to an item that is gone is unavailable",
          bool(_errors(reply)) and all(_kind(e) == "unavailable" for e in _errors(reply)), [status, reply])
    weak = host.data_of(
        'mutation { koineCreateGrant(input: { clientLabel: "read only", capabilities: ["%s:read"] }) '
        "{ credential grant { capabilities } } }" % lower
    )["koineCreateGrant"]
    status, reply = host.post("{ %sItems { name } }" % head, weak["credential"])
    check(f"{stem}: a read-only grant reads", status == 200 and not _errors(reply), [status, reply])
    rename = 'mutation { %sRenameItem(ref: "koine://%s/item/1", name: "renamed") { ref affected { name } } }' % (head, lower)
    status, reply = host.post(rename, weak["credential"])
    check(f"{stem}: it is refused the action, naming the capability it lacks",
          bool(_errors(reply)) and all(_kind(e) == "permission" and
                                       (e.get("extensions") or {}).get("requiredCapability") == f"{lower}:control"
                                       for e in _errors(reply)), [status, reply])
    status, reply = host.post(rename)
    check(f"{stem}: the host's own grant runs the action", status == 200 and not _errors(reply)
          and reply["data"][f"{head}RenameItem"]["ref"] == f"koine://{lower}/item/1", [status, reply])
    items = host.data_of("{ %sItems { name } }" % head)[f"{head}Items"]
    check(f"{stem}: the action's effect is read back from the running binary",
          [item["name"] for item in items] == ["renamed", "second"], items)
    calls = {c["resolver"]: c["count"] for c in host.data_of("{ %sCalls { resolver count } }" % head)[f"{head}Calls"]}
    check(f"{stem}: the binary counted the calls it served", calls.get("items", 0) >= 2 and calls.get("renameItem") == 1, calls)


def process_identity(pid):
    """(pid, start instant) in the contract's canonical form, from the kernel's record of the process
    (proc_pidinfo PROC_PIDTBSDINFO, whole microseconds), as a client captures it."""
    import ctypes
    import datetime

    buffer = ctypes.create_string_buffer(136)
    libproc = ctypes.CDLL("/usr/lib/libproc.dylib", use_errno=True)
    if libproc.proc_pidinfo(pid, 3, ctypes.c_uint64(0), buffer, 136) != 136:
        raise OSError(ctypes.get_errno(), "proc_pidinfo")
    micros = int.from_bytes(buffer.raw[120:128], "little") * 1_000_000 + int.from_bytes(buffer.raw[128:136], "little")

    def canonical(value):
        instant = datetime.datetime.fromtimestamp(value // 1_000_000, datetime.timezone.utc)
        return instant.strftime("%Y-%m-%dT%H:%M:%S") + ".%06dZ" % (value % 1_000_000)

    return {"pid": pid, "startedAt": canonical(micros)}, canonical(micros + 1)


APPLICATION = "query($process: DesktopProcessIdentity!) { desktopApplication(process: $process) { ref name bundleIdentifier } }"
WINDOWS = "query($process: DesktopProcessIdentity!) { desktopApplication(process: $process) { windows { ref title observation } } }"


def desktop_operations(post, create_grant):
    """The desktop operations that need no window to exist, sent to a host that serves the desktop provider, and
    what each answered, normalised so that two hosts can be compared: `post(query, variables, credential)`
    returns (HTTP status, reply) and `create_grant(capabilities)` a credential holding exactly those.

    The steps are an application running here (this process's own, so that one always exists), a different
    process claimed at its PID, an absent process, a malformed process identity, a reference that is stale,
    and the same operations under a read-only grant and under a control-only one."""
    own, later = process_identity(os.getpid())
    absent = {"pid": 1_000_000, "startedAt": own["startedAt"]}
    # An application that is running, when this Mac's session has Finder (a desktop session always does).
    found = subprocess.run(["pgrep", "-x", "Finder"], capture_output=True, text=True).stdout.split()
    finder = process_identity(int(found[0]))[0] if found else None
    stale = "koine://desktop/window/1/2"
    malformed = {"pid": os.getpid(), "startedAt": own["startedAt"][:-8] + "Z"}
    read, control = create_grant(["desktop:read"]), create_grant(["desktop:control"])

    def normalise(status, reply):
        errors = [
            {"kind": _kind(e), "message": e.get("message"), "path": e.get("path"),
             "requiredCapability": (e.get("extensions") or {}).get("requiredCapability")}
            for e in _errors(reply)
        ]
        return {"status": status, "data": (reply or {}).get("data"), "errors": errors}

    def go(query, variables=None, credential=None):
        return normalise(*post(query, variables or {}, credential))

    steps = {
        "application, this process": go(APPLICATION, {"process": own}),
        "application, the same PID a microsecond later": go(APPLICATION, {"process": {"pid": own["pid"], "startedAt": later}}),
        "application, an absent process": go(APPLICATION, {"process": absent}),
        "application, a malformed process identity": go(APPLICATION, {"process": malformed}),
        "windows, this process": go(WINDOWS, {"process": own}),
        "window, a stale reference": go("query($ref: Reference!) { desktopWindow(ref: $ref) { ref } }", {"ref": stale}),
        "focus, a stale reference": go("mutation($ref: Reference!) { desktopFocusWindow(ref: $ref) { ref } }", {"ref": stale}),
        "read-only grant reads an absent process": go(APPLICATION, {"process": absent}, read),
        "read-only grant is refused focus": go("mutation($ref: Reference!) { desktopFocusWindow(ref: $ref) { ref } }", {"ref": stale}, read),
        "control-only grant is refused a read": go(APPLICATION, {"process": absent}, control),
        "control-only grant reaches focus": go("mutation($ref: Reference!) { desktopFocusWindow(ref: $ref) { ref } }", {"ref": stale}, control),
    }
    if finder:
        steps["application, a running one (Finder)"] = go(APPLICATION, {"process": finder})
        steps["windows, a running application (Finder)"] = go(WINDOWS, {"process": finder})
    return steps


def check_desktop_expectations(results, check, where):
    """What the desktop contract promises of those operations (docs/design/desktop-schema.graphql): an absent
    process and a process that is not the one claimed are ordinary nulls, a malformed identity and a stale
    reference are errors of the kinds the contract names, and a grant holds exactly its capability."""
    def no_errors(name):
        return results[name]["status"] == 200 and not results[name]["errors"]

    check(f"{where}: an absent process is an ordinary null",
          no_errors("application, an absent process") and results["application, an absent process"]["data"] == {"desktopApplication": None},
          results["application, an absent process"])
    check(f"{where}: the same PID claimed a microsecond later is a different process, an ordinary null",
          no_errors("application, the same PID a microsecond later")
          and results["application, the same PID a microsecond later"]["data"] == {"desktopApplication": None},
          results["application, the same PID a microsecond later"])
    check(f"{where}: a malformed process identity is refused, naming the instant's form",
          bool(results["application, a malformed process identity"]["errors"])
          and all("process.startedAt must be the process start instant" in (e["message"] or "")
                  for e in results["application, a malformed process identity"]["errors"])
          and results["application, a malformed process identity"]["data"] == {"desktopApplication": None},
          results["application, a malformed process identity"])
    finder = results.get("application, a running one (Finder)")
    # The positive path needs an application: without one a provider that answered null everywhere would pass.
    check(f"{where}: a running application (Finder) was there to exercise the positive path", finder is not None, None)
    if finder is not None:
        served = ((finder["data"] or {}).get("desktopApplication") or {})
        check(f"{where}: a running application is served by name and bundle identifier",
              finder["status"] == 200 and not finder["errors"] and served.get("name") == "Finder"
              and served.get("bundleIdentifier") == "com.apple.finder", finder)
    for name in ("window, a stale reference", "focus, a stale reference"):
        check(f"{where}: {name} is unavailable",
              bool(results[name]["errors"]) and all(e["kind"] == "unavailable" for e in results[name]["errors"]),
              results[name])
    check(f"{where}: a read-only grant reads", no_errors("read-only grant reads an absent process"),
          results["read-only grant reads an absent process"])
    for name, needs in (("read-only grant is refused focus", "desktop:control"), ("control-only grant is refused a read", "desktop:read")):
        check(f"{where}: {name}, naming {needs}",
              bool(results[name]["errors"]) and all(e["kind"] == "permission" and e["requiredCapability"] == needs
                                                     for e in results[name]["errors"]), results[name])
    check(f"{where}: a control-only grant reaches the action, and the stale reference is what fails",
          bool(results["control-only grant reaches focus"]["errors"])
          and all(e["kind"] == "unavailable" for e in results["control-only grant reaches focus"]["errors"]),
          results["control-only grant reaches focus"])


class ReleasedHost:
    """The RELEASED headless host (v0.1.0, scripts/build-baseline-host.sh; its driver is
    scripts/compat-released-host-main.swift): a host that predates selection, its catalogue and the
    candidate fields. One process over a fresh data directory, a per-user root and a bundled root that
    stands in for `Contents/PlugIns`, each bundle with the approval record the released application
    gives its own. Markers come from the fixture images, as in every host of this harness."""

    BASELINE_ROWS = "{ koineManagement { providers { provider version schemaVersion state diagnostic } } }"

    def __init__(self, suite, bundled, installs=()):
        """`bundled` is the cases standing in for Contents/PlugIns (their own names), `installs` (case, name)
        for the per-user root; each is approved for the team that signs the fixtures."""
        self.suite = suite
        self.directory = tempfile.mkdtemp(prefix="koine-released-")
        self.data = os.path.join(self.directory, "data")
        self.providers = os.path.join(self.data, "Providers")
        self.plugins = os.path.join(self.directory, "PlugIns")
        os.makedirs(self.providers)
        os.makedirs(self.plugins)
        os.chmod(self.data, 0o700)
        self.installed = {}  # name -> case, per-user
        self.bundled = {}  # name -> case
        for case in bundled:
            self._place(case, self.plugins, None)
        for case, name in installs:
            self._place(case, self.providers, name)
        self.marker_log = os.path.join(self.directory, "markers.log")
        binary = os.path.join(REPOSITORY, ".build", "compat", "debug", "baseline", "products", "KoineCompatibilityHost")
        self.process = subprocess.Popen(
            [binary, self.data, self.plugins], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            env=dict(os.environ, KOINE_FIXTURE_MARKER_LOG=self.marker_log), text=True,
        )
        watchdog = threading.Timer(90, self.process.kill)
        watchdog.start()
        try:
            line = self.process.stdout.readline()
        finally:
            watchdog.cancel()
        if not line:
            raise RuntimeError(f"The released host exited before it was ready: {self.process.stderr.read()}")
        self.ready = json.loads(line)
        if "error" in self.ready:
            raise RuntimeError(f"The released host failed to start: {self.ready['error']}")

    def _place(self, case, root, name):
        source = self.suite.bundle(case)
        label = name or os.path.basename(source)[: -len(".koineprovider")]
        shutil.copytree(source, os.path.join(root, label + ".koineprovider"), symlinks=True)
        manifest = self.suite.manifest_of(case)
        with open(os.path.join(root, manifest["providerId"] + ".approval.json"), "w") as file:
            json.dump({"providerId": manifest["providerId"], "teamIdentifier": self.suite.team}, file)
        (self.installed if root == self.providers else self.bundled)[label] = case

    def post(self, query, credential=None, variables=None):
        request = urllib.request.Request(
            f"http://127.0.0.1:{self.ready['port']}/graphql",
            data=json.dumps({"query": query, "variables": variables or {}}).encode(),
            headers={"Content-Type": "application/json", "Authorization": f"Bearer {credential or self.ready['credential']}"},
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

    def create_grant(self, capabilities):
        quoted = ", ".join('"%s"' % c for c in capabilities)
        return self.data_of(
            'mutation { koineCreateGrant(input: { clientLabel: "driver", capabilities: [%s] }) { credential } }' % quoted
        )["koineCreateGrant"]["credential"]

    def rows(self):
        return self.data_of(self.BASELINE_ROWS)["koineManagement"]["providers"]

    def markers(self):
        try:
            with open(self.marker_log) as file:
                lines = [line.rstrip("\n").split("\t") for line in file if line.strip()]
        except FileNotFoundError:
            return []
        return [(re.sub(r"-[0-9a-f]{32}$", "", os.path.basename(os.path.dirname(image))), phase) for phase, image in lines]

    def loaded_labels(self):
        return sorted(re.sub(r"-[0-9a-f]{32}$", "", os.path.basename(os.path.dirname(i["path"])))
                      for i in self.ready.get("images", []) if "/ProviderStaging/" in i["path"])

    def stop(self):
        self.process.stdin.close()
        line = self.process.stdout.readline()
        code = self.process.wait(timeout=60)
        make_writable(self.directory)
        shutil.rmtree(self.directory, ignore_errors=True)
        return (json.loads(line) if line else {}), code



def installed_by_label(host, suite):
    """{label: case} for what the current host process could have run: the per-user installs and the bundles sealed
    inside the host. A bundle name in both roots is two candidates, `<name>@user` and `<name>@bundled`: keyed by the
    bare name the bundled case would replace the per-user one, and a control would be credited to the wrong binary."""
    bundled = dict(suite.plugins(host.host_name))
    out = {}
    for name, case in host.installed.items():
        out[name + "@user" if name in bundled else name] = case
    for name, case in bundled.items():
        out[name + "@bundled" if name in host.installed else name] = case
    return out


def recorder(results, scenario, label, host):
    """A run the scenario vocabulary does not describe (the released host, a differential of two hosts):
    its record, in the shape every other run leaves, and the `check` that writes to it."""
    record = {"scenario": scenario, "label": label, "host": host, "checks": []}
    results.append(record)

    def check(name, passed, observed=None):
        record["checks"].append({"check": name, "passed": bool(passed), "observed": observed})
        if not passed:
            print(f"    FAIL {name}: {observed}")
        return passed

    return record, check


def finish_record(record):
    ok = all(entry["passed"] for entry in record["checks"])
    print(f"  {'ok  ' if ok else 'FAIL'} {record['label']}")


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
            prefix = "" if len(phases) == 1 else f"[phase {index + 1}{': ' + phase.label if phase.label else ''}] "
            phase_check = lambda name, passed, observed=None, prefix=prefix: check(prefix + name, passed, observed)
            if index:
                if host.process:
                    stopped, code = host.stop_process()
                    check(f"phase {index}: the host stops cleanly", code == 0 and stopped.get("stopped") is True, [code, stopped])
                host.apply(phase.actions)
                failure = None
                try:
                    host.start(phase)
                except RuntimeError as error:
                    failure = str(error)
                if phase.start_fails:
                    check_failed_start(host, phase, failure, suite, phase_check, record)
                    continue
                if failure:
                    raise RuntimeError(failure)
            elif phase.start_fails:
                raise ValueError("the first phase of a scenario must start")
            installed = installed_by_label(host, suite)
            check_phase(host, phase, phase_check, suite, installed, record, label, f" (phase {index + 1})" if index else "")
        digests = record.get("digests", {})
        for one, other in scenario.differs:
            check(f"the schema digest {one!r} differs from {other!r}",
                  one in digests and other in digests and digests[one] != digests[other],
                  [digests.get(one), digests.get(other)])
    except Exception as error:  # noqa: BLE001
        check("the scenario runs", False, repr(error))
    finally:
        stopped, code = host.stop()
        check("the host stops cleanly", code == 0 and stopped.get("stopped") is True, [code, stopped])
    ok = all(entry["passed"] for entry in record["checks"])
    print(f"  {'ok  ' if ok else 'FAIL'} {label}")


def check_digests_across_runs(scenario, runs, results):
    """Discovery order and path names decide nothing: each tagged digest is one value across every run."""
    tags = {tag for record in runs for tag in record.get("digests", {})}
    if not tags or len(runs) < 2:
        return
    observed = {tag: sorted({record["digests"][tag] for record in runs if tag in record.get("digests", {})}) for tag in tags}
    failing = {tag: values for tag, values in observed.items() if len(values) != 1}
    record = {"scenario": scenario.name, "label": f"{scenario.name} [digests across discovery orders and path names]",
              "host": scenario.host, "derived": True, "checks": [{
                  "check": "each tagged digest is the same in every run of the scenario", "passed": not failing,
                  "observed": failing or observed}]}
    results.append(record)
    if failing:
        print(f"    FAIL digests differ between runs: {failing}")


def main(scenarios, owned_reasons, pending, doc, twins=None, own_reason_note="", argv=None, extra_runs=()):
    """The whole driver: `<hosts> <fixtures> <results.json> [--only <substring>] [--conformance <tool>]`."""
    arguments = list(sys.argv[1:] if argv is None else argv)
    conformance = None
    if "--conformance" in arguments:
        index = arguments.index("--conformance")
        conformance = os.path.abspath(arguments[index + 1])
        del arguments[index : index + 2]
    only = None
    if "--only" in arguments:
        index = arguments.index("--only")
        only = arguments[index + 1]
        del arguments[index : index + 2]
    if len(arguments) != 3:
        raise SystemExit(doc)
    hosts, fixtures, output = (os.path.abspath(argument) for argument in arguments)
    suite = Suite(hosts, fixtures, twins, conformance)
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
        check_digests_across_runs(scenario, [r for r in results if r["scenario"] == scenario.name], results)
    # Runs the scenario vocabulary does not describe, each called as `run(suite, results, only)`.
    for run in extra_runs:
        run(suite, results, only)

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
    print(f"{len([r for r in results if not r.get('derived')])} host runs, {len(failed)} failed, {len(uncontrolled)} without a control, {len(unseen)} owned reasons unseen")
    for row, reason in pending:
        print(f"PENDING {row}: {reason}")
    sys.exit(1 if failed or uncontrolled or unseen else 0)
