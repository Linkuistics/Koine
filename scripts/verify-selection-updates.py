#!/usr/bin/env python3
"""Runs the selection acceptance's update rows against purpose-built signed hosts.

Machine's "Selection acceptance" table (docs/specs/machine.md) assigns the rows about
independent updates across binary generations to the native loader (N) and public GraphQL
(G). This driver runs them as `verify-selection-decisions.py` and
`verify-selection-failures.py` run theirs (scripts/selection_harness.py): each scenario, each
alternative order within it, and each restart is a fresh signed host process over a data
directory, a per-user root and a marker log of its own, and a scenario that asserts an image
never ran is paired with a control of the same compiled binary.

What is new here is the subject. The binaries are independently built generations:

  * the RELEASED revision's headless host (v0.1.0) and desktop provider, compiled from that
    release's own source, beside this tree's host and providers;
  * REAL first-party providers as well as fixtures: this tree's desktop and workspace, and
    newer releases of the same sources that state `first-party-selection-v1` in manifest and
    descriptor, compiled from a copy of Providers/ with two substitutions
    (scripts/build-selection-real.sh). A real provider writes no marker: it is seen loaded
    by its image being mapped into the host process, and served by its row being ACTIVE.

It exercises: an old host with an old desktop provider, and a selection-aware host over an
independently compiled old designated baseline; a separately approved newer desktop or
workspace update, alone and mixed; a host that predates the selection feature given newly
published updates, with the principal class kept and renamed; each trust refusal a per-user
update can meet, and the stage and quarantine recoveries; a provider claiming a reserved pair
under a fixture signing identifier; equal bytes and equal bundle names in both roots, in both
orders, across restarts, and a legacy shared staging entry; and mixed releases built from
reused helper source.

usage: verify-selection-updates.py <hosts> <fixtures> <results.json> --conformance <tool> [--only <substring>]

<hosts> is scripts/build-selection-hosts.py's output, <fixtures> is the output of
Fixtures/FixtureProvider/build-decisions.sh and scripts/build-selection-real.sh, and
<tool> is the KoineConformance tool. Needs the released host (`task compat:baseline`).
docs/verification/selection-updates.md records a run.
"""

import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import selection_harness as harness  # noqa: E402
from selection_harness import (  # noqa: E402
    ACTIVE, BASE_GREETING, FRESH, INCOMPATIBLE, NOT, REJECTED, SEL, SH, SK, UPDATE_GREETING, Phase, R, Scenario, U,
    content_digest,
)

SK_BASE_GREETING = "hello from the fixturesk provider"
SK_UPDATE_GREETING = "hello from the fixturesk provider, revision 2"
PROFILES = "docs/design/profiles/"
FEATURE_TEXT = "first-party-selection-v1"
# The architecture this Mac is not (the manifest claims it).
OTHER_ARCH = "x86_64" if __import__("platform").machine() == "arm64" else "arm64"

# Desktop operation results, by the host they came from, so that two hosts can be compared.
OPERATIONS = {}


# --- Checks that hold a phase to more than its rows ------------------------------------


def host_app(host):
    return os.path.join(host.suite.hosts, host.host_name, "KoineSelectionHost.app")


def unchanged_across_phases(label, compute):
    """A check that remembers what `compute(host)` said the first time it ran in a run, and holds every later
    phase of that run to it: the subject is what a later phase is compared with, not a constant."""

    def check_phase(host, check, context):
        value = compute(host)
        seen = context["record"].setdefault("remembered", {})
        if label not in seen:
            seen[label] = value
            check(f"{label}: recorded", True, value)
        else:
            check(f"{label}: unchanged since the first phase", seen[label] == value, [seen[label], value])

    return check_phase


def host_not_rebuilt():
    """The signed host application is one artifact across every update: byte for byte, seal intact."""

    def compute(host):
        app = host_app(host)
        verified = subprocess.run(["codesign", "--verify", "--strict", "--deep", app], capture_output=True, text=True)
        return {"digest": content_digest(app), "sealIntact": verified.returncode == 0}

    def check_phase(host, check, context):
        value = compute(host)
        check("the host's seal verifies", value["sealIntact"], value)
        unchanged_across_phases("the signed host application (every file, byte for byte)", lambda _: value["digest"])(
            host, check, context
        )

    return check_phase


def approval_unchanged(provider):
    """The approval record is one file, `{providerId, teamIdentifier}`, naming the host's own team, and it is
    not written again when a newer release replaces the bundle: a compatible release needs no new approval."""

    def compute(host):
        path = os.path.join(host.providers, provider + ".approval.json")
        with open(path, "rb") as file:
            raw = file.read()
        status = os.stat(path)
        # Bytes alone would pass a rewrite with the same bytes: the file itself is the same file, untouched.
        return {"bytes": raw.decode(), "digest": [harness.hashlib.sha256(raw).hexdigest(), status.st_ino, status.st_mtime_ns]}

    def check_phase(host, check, context):
        value = compute(host)
        record = json.loads(value["bytes"])
        check("the approval record names the provider and the host's own Team ID, and nothing else",
              record == {"providerId": provider, "teamIdentifier": host.ready["hostTeam"]}, record)
        unchanged_across_phases("the approval record (the file's bytes)", lambda _: value["digest"])(host, check, context)

    return check_phase


def no_approval_written_by_the_loader(host, check, context):
    """Koine writes no approval record itself: the per-user root holds only what the driver put there."""
    names = sorted(name for name in os.listdir(host.providers) if name.endswith(".approval.json"))
    written = sorted(f"{provider}.approval.json" for provider in
                     {context["suite"].manifest_of(case)["providerId"] for case in host.installed.values()})
    check("the per-user root holds no approval the driver did not place", set(names) <= set(written), [names, written])


def desktop_operations(tag):
    """The desktop operations, sent to the host as a client sends them, held to the desktop contract, and kept
    by `tag` so that two hosts can be shown to answer identically."""

    def check_phase(host, check, context):
        results = harness.desktop_operations(lambda q, v, c: host.post(q, c, v), host.create_grant)
        harness.check_desktop_expectations(results, check, tag)
        OPERATIONS[tag] = results

    return check_phase


def workspace_operation(host, check, context):
    """The workspace provider answers as itself: an application that is not installed is a prerequisite failure,
    not an error, and the action submits nothing."""
    status, reply = host.post(
        'mutation { workspaceLaunchApplication(application: { bundleIdentifier: "dev.antony.koine.no-such-application" }) '
        "{ status dependency { reason } } }"
    )
    served = ((reply or {}).get("data") or {}).get("workspaceLaunchApplication") or {}
    check("the workspace provider answers for an application that is not installed: DEPENDENCY_UNAVAILABLE, not installed",
          status == 200 and not (reply or {}).get("errors") and served.get("status") == "DEPENDENCY_UNAVAILABLE"
          and (served.get("dependency") or {}).get("reason") == "APPLICATION_NOT_INSTALLED", [status, reply])


def nominal_types(image):
    """[(module, type name)] for the nominal types and protocols `image` defines: the symbols ending `Mn` (nominal
    type descriptor) or `Mp` (protocol descriptor), which an optimised build keeps though it hides the rest. A
    module that merely has a thunk or an extension's method in the image is not a module the image defines."""
    out = subprocess.run(["nm", "-U", image], capture_output=True, text=True).stdout
    found = []
    for line in out.splitlines():
        symbol = line.split()[-1].lstrip("_") if line.split() else ""
        matched = re.match(r"\$s(\d+)(.*)(Mn|Mp)$", symbol)
        if matched:
            module = matched.group(2)[: int(matched.group(1))]
            rest = matched.group(2)[int(matched.group(1)):]
            named = re.match(r"(\d+)(.*)", rest)
            found.append((module, named.group(2)[: int(named.group(1))] if named else ""))
    return found


def swift_modules(image):
    """The Swift modules `image` defines types or protocols in."""
    return {module for module, _ in nominal_types(image)}


def swift_types(image, module):
    """The names of the types `module` defines in `image`."""
    return {name for owner, name in nominal_types(image) if owner == module and name}


def inventory_checks(named, modules, types, host_modules, host_classes, framework_images, expect_modules, reused_types):
    """The checks an inventory of mapped provider images has to pass, as (check, passed, observed): `named` is
    {label: {"path", "classes"}}, `modules` {label: Swift modules defined}, `types` {label: [(module, type)]}."""
    out = []
    add = lambda name, passed, observed=None: out.append((name, bool(passed), observed))
    add("the framework the host owns is mapped exactly once", len(framework_images) == 1, framework_images)
    add("at least one provider image was inspected, and each defines a type and a class", bool(named) and all(
        modules[label] and named[label]["classes"] for label in named), {label: [sorted(modules[label]), len(named[label]["classes"])] for label in named})
    for label in named:
        expected = (expect_modules or {}).get(label)
        add(f"{label}: defines Swift module {expected or 'its own'} and no module the framework or host owns",
            not (modules[label] & (host_modules | {"KoineProviderAPI"})) and (expected is None or expected in modules[label]),
            sorted(modules[label]))
    labels = sorted(named)
    for index, one in enumerate(labels):
        add(f"{one}: no Swift module is shared with the host", not (modules[one] & host_modules), sorted(modules[one] & host_modules))
        add(f"{one}: no Objective-C class is shared with the host", not (set(named[one]["classes"]) & host_classes),
            sorted(set(named[one]["classes"]) & host_classes))
        for other in labels[index + 1:]:
            add(f"{one} and {other}: disjoint Swift modules", not (modules[one] & modules[other]), sorted(modules[one] & modules[other]))
            shared = set(named[one]["classes"]) & set(named[other]["classes"])
            add(f"{one} and {other}: disjoint Objective-C classes", not shared, sorted(shared))
    everything = [name for image in named.values() for name in image["classes"]] + sorted(host_classes)
    add("no Objective-C class name is defined by two images of the process", len(everything) == len(set(everything)),
        sorted({n for n in everything if everything.count(n) > 1}))
    for name in reused_types:
        holding = sorted(label for label in named if any(type_name == name for _, type_name in types[label]))
        add(f"the helper source's {name} is compiled into more than one provider, each under its own module",
            len(holding) > 1 and len({module for label in holding for module, type_name in types[label] if type_name == name}) == len(holding),
            {label: sorted(modules[label]) for label in holding})
    return out


def image_inventory(expect_modules=None, reused_types=()):
    """What the provider images of this process brought with them, against each other and the host: their Swift
    modules (the ones they define types in) and their Objective-C runtime classes are disjoint from each other and
    from the host's, except the one framework the host owns, which no provider defines and which is mapped once.
    `expect_modules` is {image label: module}, `reused_types` the type names helper source defines in more than
    one provider.

    This is a native observation of what was mapped, not a claim that the loader is a sandbox."""

    def check_phase(host, check, context):
        images = [i for i in host.ready["images"] if "/ProviderStaging/" in i["path"]]
        executable = next(i for i in host.ready["images"] if i["path"].endswith("/MacOS/KoineSelectionHost"))
        framework = [i["path"] for i in host.ready["images"] if "KoineProviderAPI.framework" in i["path"]]
        named = {host.label_of(os.path.basename(os.path.dirname(i["path"]))): i for i in images}
        types = {label: nominal_types(image["path"]) for label, image in named.items()}
        modules = {label: {module for module, _ in found} for label, found in types.items()}
        host_modules = swift_modules(executable["path"])
        for name, passed, observed in inventory_checks(
            named, modules, types, host_modules, set(executable["classes"]), framework, expect_modules, reused_types
        ):
            check(name, passed, observed)
        context["record"].setdefault("inventory", []).append(
            {"images": {label: {"modules": sorted(modules[label]), "classes": named[label]["classes"]} for label in named},
             "hostModules": len(host_modules), "hostClasses": len(executable["classes"])}
        )

    return check_phase


def staged_copies(expect):
    """What the loader staged, and which copies carry the quarantine the user's download had. `expect` is a list
    of (label, quarantined): the staged directories exactly, each candidate's own. A copy left by an earlier host
    (another application path, so another name) keeps the plain install name as its label."""

    def check_phase(host, check, context):
        found = sorted((host.label_of(name), quarantined) for name, quarantined in host.staged_dirs().items())
        check("the staged copies, each candidate's own, and which of them carry the quarantine attribute",
              found == sorted(expect), {"observed": found, "wanted": sorted(expect)})

    return check_phase


def legacy_not_reused(host, check, context):
    """An entry of the earlier, content-only staging scheme is never reused: it is still there, byte for byte, and
    no image of the process was mapped from it; every mapped image came from the name the candidate's own
    origin, location and content give it now."""
    planted = getattr(host, "legacy", {})
    check("a legacy entry was planted", bool(planted), sorted(planted))
    mapped = [os.path.basename(os.path.dirname(i["path"])) for i in host.ready["images"] if "/ProviderStaging/" in i["path"]]
    expected = set(host.suite.bundled_stage(host.host_name).values()) | set(host.user_stage.values())
    for name, digest in planted.items():
        path = os.path.join(host.staging, name)
        check(f"the legacy entry {name} is left as it was", os.path.isdir(path) and content_digest(path) == digest,
              os.path.isdir(path))
        check(f"no image of the process was mapped from the legacy entry {name}", name not in mapped, mapped)
    check("every mapped image came from a candidate-specific name, formed from its origin, location and content",
          bool(mapped) and set(mapped) <= expected, {"mapped": mapped, "candidate-specific": sorted(expected)})


def catalogue_matches_packaged(provider):
    """The host's sealed catalogue states the packaged baseline: its entry for `provider` is the shipped
    catalogue's own, and the designated bundle carries what the entry says (signing identifier read from its
    signature, release and schema from its manifest), declares no `first-party-selection-v1`, and no new
    factory witness is asked of it."""

    def check_phase(host, check, context):
        with open(os.path.join(host_app(host), "Contents", "Resources", "ProviderCatalogue.json")) as file:
            sealed = {e["providerId"]: e for e in json.load(file)["identities"]}
        with open(os.path.join(harness.REPOSITORY, "App", "ProviderCatalogue.json")) as file:
            shipped = {e["providerId"]: e for e in json.load(file)["identities"]}
        entry = sealed[provider]
        check(f"the sealed catalogue's entry for {provider} is the shipped catalogue's", entry == shipped[provider],
              [entry, shipped[provider]])
        bundle = os.path.join(host_app(host), "Contents", "PlugIns", entry["bundle"])
        with open(os.path.join(bundle, "manifest.json")) as file:
            manifest = json.load(file)
        signed = subprocess.run(["codesign", "-dvv", bundle], capture_output=True, text=True).stderr
        identifier = next(line.split("=", 1)[1] for line in signed.splitlines() if line.startswith("Identifier="))
        check("the designated bundle carries the release, schema and signing identifier the catalogue states",
              (manifest["version"], manifest["schemaVersion"], identifier) == (entry["release"], entry["schema"], entry["signingIdentifier"]),
              [manifest["version"], manifest["schemaVersion"], identifier])
        check("the baseline predates the selection feature: it declares none, and needs framework minor 0",
              manifest["requiredFeatures"] == [] and manifest["framework"]["minimumMinor"] == 0, manifest)

    return check_phase


# --- The rows -----------------------------------------------------------------------


def scenarios():
    s = []
    add = s.append
    sh_base = R(SH, "1.0.0", "B", ACTIVE, SEL, None)
    sh_sup = lambda version, origin: R(SH, version, origin, REJECTED, NOT, "superseded-candidate")
    sk_base = R(SK, "1.0.0", "B", ACTIVE, SEL, None)
    sk_sup = lambda version, origin: R(SK, version, origin, REJECTED, NOT, "superseded-candidate")

    # -- A separately approved newer update is the one image that runs ---------------------
    add(Scenario(
        "both slots at their designated baselines: the generation before any update",
        [sh_base, sk_base], host="two-slots-sorted", ran=[FRESH, "FixtureSk"], images=["FixtureSh", "FixtureSk"],
        serves=("fixtureSkInfo", SK_BASE_GREETING), operations="FixtureSk", extra=[image_inventory()],
    ))
    operations = "FixtureSh"
    shared = [host_not_rebuilt(), approval_unchanged("fixturesh")]
    add(Scenario(
        "a separately approved newer desktop update: one image, factory and start, the host not rebuilt",
        [sh_base], host="slot", ran=[FRESH], images=["FixtureSh"], serves=("fixtureShInfo", BASE_GREETING),
        operations=operations, extra=[host_not_rebuilt()], reverse=True,
        then=[
            Phase([R(SH, "1.5.0", "U", ACTIVE, SEL, None), sh_sup("1.0.0", "B")],
                  actions=[("put", U("r1.5.0", "update"))], ran=["update"], images=["update"],
                  serves=("fixtureShInfo", UPDATE_GREETING), operations=operations, label="the update, approved",
                  extra=shared + [no_approval_written_by_the_loader]),
            # A newer release with different bytes: the approval record is the one already there.
            Phase([R(SH, "1.6.0", "U", ACTIVE, SEL, None), sh_sup("1.0.0", "B")],
                  actions=[("replace-keep-approval", "update", "r1.6.0")], ran=["update"], images=["update"],
                  serves=("fixtureShInfo", UPDATE_GREETING), operations=operations,
                  label="a newer release under the same approval", extra=shared),
            Phase([sh_base], actions=[("remove", "update")], ran=[FRESH], images=["FixtureSh"],
                  serves=("fixtureShInfo", BASE_GREETING), operations=operations, label="the update removed",
                  extra=[host_not_rebuilt()]),
        ],
    ))
    add(Scenario(
        "a compatible newer workspace update beside the desktop baseline",
        [sh_base, R(SK, "1.2.0", "U", ACTIVE, SEL, None), sk_sup("1.0.0", "B")], host="two-slots-sorted",
        installs=[U("sk-r1.2.0", "workspace-update")], ran=[FRESH, "workspace-update"],
        images=["FixtureSh", "workspace-update"], serves=("fixtureSkInfo", SK_UPDATE_GREETING), operations="FixtureSk",
        extra=[image_inventory(), approval_unchanged("fixturesk"), host_not_rebuilt()],
    ))
    # The renamed-principal variants: a selection-aware host takes them like any other update.
    add(Scenario(
        "a desktop update under another principal class is selected like the others",
        [R(SH, "1.5.0", "U", ACTIVE, SEL, None), sh_sup("1.0.0", "B")], host="slot", installs=[U("r1.5.0-renamed", "update")],
        ran=["update"], images=["update"], serves=("fixtureShInfo", UPDATE_GREETING), operations="FixtureSh",
        extra=[approval_unchanged("fixturesh")],
    ))
    add(Scenario(
        "a workspace update under another principal class is selected like the others",
        [sh_base, R(SK, "1.1.0", "U", ACTIVE, SEL, None), sk_sup("1.0.0", "B")], host="two-slots-sorted",
        installs=[U("sk-r1.1.0-renamed", "workspace-update")], ran=[FRESH, "workspace-update"],
        images=["FixtureSh", "workspace-update"], serves=("fixtureSkInfo", SK_UPDATE_GREETING), operations="FixtureSk",
        extra=[image_inventory(), approval_unchanged("fixturesk")],
    ))
    add(Scenario(
        "both shipped slots updated independently: exactly one image per slot, in identifier order",
        [R(SH, "1.5.0", "U", ACTIVE, SEL, None), sh_sup("1.0.0", "B"), R(SK, "1.2.0", "U", ACTIVE, SEL, None), sk_sup("1.0.0", "B")],
        host="two-slots-sorted", installs=[U("r1.5.0", "desktop-update"), U("sk-r1.2.0", "workspace-update")],
        ran=["desktop-update", "workspace-update"], images=["desktop-update", "workspace-update"],
        order=["desktop-update", "workspace-update"], serves=("fixtureShInfo", UPDATE_GREETING), operations="FixtureSh",
        extra=[image_inventory()],
    ))

    # -- An extension host refuses a per-user update that does not state the feature --------
    for tag, host, case, provider_row, baseline, release, schema_note in (
        ("desktop", "slot", "r2.0.0-no-feature", SH, sh_base, "2.0.0", None),
        ("desktop, another principal class", "slot", "r2.0.0-no-feature-renamed", SH, sh_base, "2.0.0", None),
        ("workspace", "two-slots-sorted", "sk-r1.1.0-no-feature", SK, sk_base, "1.1.0", None),
        ("workspace, another principal class", "two-slots-sorted", "sk-r1.1.0-no-feature-renamed", SK, sk_base, "1.1.0", None),
    ):
        healthy = [sh_base] if provider_row == SK else []
        ran = [FRESH] if provider_row == SH else [FRESH, "FixtureSk"]
        add(Scenario(
            f"a {tag} update that does not state {FEATURE_TEXT} is refused before it loads",
            healthy + [R(provider_row, release, "U", INCOMPATIBLE, NOT, "selection-feature-required", FEATURE_TEXT),
                       R(provider_row, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", f"claims release {release}")],
            host=host, installs=[U(case, "update")], ran=ran, images=["FixtureSh"] + ([] if provider_row == SH else ["FixtureSk"]),
            serves=("fixtureShInfo" if provider_row == SH else "fixtureSkInfo", BASE_GREETING if provider_row == SH else SK_BASE_GREETING),
        ))

    # -- Each trust refusal falls back visibly, and the image never runs -------------------
    # (title, install, state, reason, notes the refused row's diagnostic names, quarantine)
    def refusals(prefix):
        return [
            ("missing approval", U(prefix + "t-good", "bad", approved=False), REJECTED, "not-approved", "is not approved", False),
            ("an approval naming another Team ID", U(prefix + "t-good", "bad", team="ZZZZZZZZZZ"), REJECTED,
             "approval-team-mismatch", "ZZZZZZZZZZ", False),
            ("an unsigned bundle", U(prefix + "t-unsigned", "bad"), REJECTED, "signature-refused", "not signed", False),
            ("an ad-hoc signed bundle", U(prefix + "t-adhoc", "bad"), REJECTED, "signature-refused", "ad-hoc signed", False),
            ("a seal altered after it was made", U(prefix + "t-tampered", "bad"), REJECTED, "signature-refused", "not valid", False),
            ("an incompatible framework", U(prefix + "t-framework", "bad"), INCOMPATIBLE, "framework-incompatible", "framework", False),
            ("a feature this host lacks", U(prefix + "t-feature", "bad"), INCOMPATIBLE, "feature-unavailable", "time-travel", False),
            ("a newer operating system", U(prefix + "t-os", "bad"), INCOMPATIBLE, "os-incompatible", "99.0", False),
            ("another architecture", U(prefix + "t-architecture", "bad"), INCOMPATIBLE, "architecture-incompatible", OTHER_ARCH, False),
            ("a failed quarantine assessment", U(prefix + "t-good", "bad", quarantined=True), REJECTED, "quarantine-refused",
             "staged copy", True),
        ]

    for slot, host, prefix, provider, version, lower_case, lower_version, serves, others in (
        ("desktop", "slot", "", SH, "2.0.0", "r1.5.0", "1.5.0", ("fixtureShInfo", UPDATE_GREETING), []),
        ("workspace", "two-slots-sorted", "sk-", SK, "2.0.0", "sk-r1.2.0", "1.2.0", ("fixtureSkInfo", SK_UPDATE_GREETING), [sh_base]),
    ):
        baseline_name = "FixtureSh" if provider == SH else "FixtureSk"
        bundle_ran = [FRESH] if provider == SH else [FRESH, "FixtureSk"]
        baseline_greeting = (serves[0], BASE_GREETING if provider == SH else SK_BASE_GREETING)
        for title, install, state, reason, note, quarantined in refusals(prefix):
            env = {"KOINE_FIXTURE_ASSESSMENT": "refuse"} if quarantined else None
            refused = R(provider, version, "U", state, NOT, reason, note)
            shared_record = reason in ("not-approved", "approval-team-mismatch")
            if shared_record:
                # An approval is a record per provider, not per bundle: what refuses one per-user copy
                # refuses every one, so the lower update cannot be chosen and the bundle keeps the slot.
                lower_refused = R(provider, lower_version, "U", state, NOT, reason, note)
                add(Scenario(
                    f"{slot}: {title} refuses every per-user copy of the provider; the bundle keeps the slot",
                    others + [refused, lower_refused, R(provider, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", f"claims release {version}")],
                    host=host, installs=[U(lower_case, "lower", approved=install.approved, team=install.team), install],
                    ran=bundle_ran, images=(["FixtureSh"] if provider == SK else []) + [baseline_name], serves=baseline_greeting,
                ))
            else:
                # With a healthy lower update present, it is chosen and says what it passed over.
                add(Scenario(
                    f"{slot}: {title} is refused before load; the lower update is chosen",
                    others + [refused, R(provider, lower_version, "U", ACTIVE, SEL, "selected-with-refusals", f"claims release {version}"),
                              R(provider, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")],
                    host=host, installs=[U(lower_case, "lower"), install],
                    ran=(["FixtureSh"] if provider == SK else []) + ["lower"],
                    images=(["FixtureSh"] if provider == SK else []) + ["lower"],
                    serves=serves, env=env, quarantine=quarantined,
                ))
            # With none, the verified bundle keeps the slot, and the diagnostic is on the refused row and the choice.
            add(Scenario(
                f"{slot}: {title} is refused before load; the bundle keeps the slot",
                others + [refused, R(provider, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", f"claims release {version}")],
                host=host, installs=[install], ran=bundle_ran, images=(["FixtureSh"] if provider == SK else []) + [baseline_name],
                serves=baseline_greeting, env=env, quarantine=quarantined,
            ))

    # An install whose location resolves out of the root is refused before it is staged, read or approved.
    for slot, host, prefix, provider, lower_case, lower_version, serves, others in (
        ("desktop", "slot", "", SH, "r1.5.0", "1.5.0", ("fixtureShInfo", UPDATE_GREETING), []),
        ("workspace", "two-slots-sorted", "sk-", SK, "sk-r1.2.0", "1.2.0", ("fixtureSkInfo", SK_UPDATE_GREETING), [sh_base]),
    ):
        escaped = R("(unknown)", "unknown", "U", REJECTED, NOT, "location-outside-root", "outside its provider root")
        add(Scenario(
            f"{slot}: a bundle whose location resolves outside the root is refused before load; the lower update is chosen",
            others + [escaped, R(provider, lower_version, "U", ACTIVE, SEL, None), R(provider, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")],
            host=host, installs=[U(lower_case, "lower"), U(prefix + "t-good", "escape", outside=True)],
            ran=(["FixtureSh"] if provider == SK else []) + ["lower"], serves=serves,
        ))
        add(Scenario(
            f"{slot}: a bundle whose location resolves outside the root is refused before load; the bundle keeps the slot",
            others + [escaped, R(provider, "1.0.0", "B", ACTIVE, SEL, None)],
            host=host, installs=[U(prefix + "t-good", "escape", outside=True)],
            ran=[FRESH] if provider == SH else [FRESH, "FixtureSk"],
            # Refused before it is staged: nothing of it was copied into the staging directory.
            extra=[staged_copies([("FixtureSh", False)] + ([] if provider == SH else [("FixtureSk", False)]))],
        ))

    # -- Stage and quarantine recovery --------------------------------------------------------
    verdict = {"KOINE_FIXTURE_ASSESSMENT": "refuse"}
    held = [R(SH, "1.5.0", "U", REJECTED, NOT, "quarantine-refused", "staged copy"),
            R(SH, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 1.5.0")]
    add(Scenario(
        "a quarantine refusal is recovered as its diagnostic says: clear the attribute, delete the staged copy, restart",
        held, host="slot", installs=[U("r1.5.0", "update", quarantined=True)], env=verdict, quarantine=True,
        ran=[FRESH], images=["FixtureSh"], extra=[staged_copies([("FixtureSh", False), ("update", True)])],
        then=[
            # Clearing the installed bundle alone is not enough: the content-named staged copy is reused and keeps it.
            Phase(held, actions=[("unquarantine", "update")], quarantine=True, ran=[FRESH], images=["FixtureSh"],
                  extra=[staged_copies([("FixtureSh", False), ("update", True)])],
                  label="the installed bundle cleared, its staged copy kept"),
            Phase([R(SH, "1.5.0", "U", ACTIVE, SEL, None), sh_sup("1.0.0", "B")], actions=[("unstage", "update")],
                  ran=["update"], images=["update"], serves=("fixtureShInfo", UPDATE_GREETING),
                  extra=[staged_copies([("FixtureSh", False), ("update", False)])], label="the staged copy deleted too"),
        ],
    ))
    nothing_staged = [R("(unknown)", "unknown", "B", REJECTED, NOT, "staging-failed", "could not be staged"),
                      R("(unknown)", "unknown", "U", REJECTED, NOT, "staging-failed", "could not be staged"),
                      R(SH, "unknown", None, REJECTED, "UNAVAILABLE", "no-eligible-candidate")]
    add(Scenario(
        "a staging directory that cannot be written refuses every candidate and runs nothing; restoring it recovers",
        [sh_base], host="slot", ran=[FRESH], images=["FixtureSh"],
        then=[
            Phase(nothing_staged, actions=[("put", U("r1.5.0", "update")), ("chmod-staging", 0o500)], ran=[], images=[],
                  label="staging unwritable"),
            Phase([R(SH, "1.5.0", "U", ACTIVE, SEL, None), sh_sup("1.0.0", "B")], actions=[("chmod-staging", 0o700)],
                  ran=["update"], images=["update"], serves=("fixtureShInfo", UPDATE_GREETING), label="staging restored"),
        ],
    ))
    add(Scenario(
        "a staged copy damaged after it was made is refused by its signature on the next start; deleting it recovers",
        [R(SH, "1.5.0", "U", ACTIVE, SEL, None), sh_sup("1.0.0", "B")], host="slot",
        installs=[U("r1.5.0", "update")], ran=["update"], images=["update"],
        then=[
            Phase([R(SH, "1.5.0", "U", REJECTED, NOT, "signature-refused"),
                   R(SH, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 1.5.0")],
                  actions=[("damage-staged", "update")], ran=[FRESH], images=["FixtureSh"], label="the staged copy damaged"),
            Phase([R(SH, "1.5.0", "U", ACTIVE, SEL, None), sh_sup("1.0.0", "B")], actions=[("unstage", "update")],
                  ran=["update"], images=["update"], serves=("fixtureShInfo", UPDATE_GREETING), label="the staged copy deleted"),
        ],
    ))

    # -- A provider named for a reserved pair, signed under a fixture signing identifier --------
    add(Scenario(
        "the same compiled binaries load as the designated baselines of a test catalogue that admits their identifiers",
        [R("desktop", "1.0.0", "B", ACTIVE, SEL, None), R("workspace", "1.0.1", "B", ACTIVE, SEL, None)],
        host="impostor-host", ran=["Desktop", "Workspace"], images=["Desktop", "Workspace"],
    ))
    add(Scenario(
        "an approved same-team provider claiming the reserved pairs at a high release under a fixture identifier is refused "
        "by the production catalogue",
        [R("desktop", "9.0.0", "U", REJECTED, NOT, "signing-identifier-mismatch", "dev.antony.Koine.provider.desktop.impostor"),
         R("desktop", "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 9.0.0"),
         R("workspace", "9.0.0", "U", REJECTED, NOT, "signing-identifier-mismatch", "dev.antony.Koine.provider.workspace.impostor"),
         R("workspace", "1.0.2", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 9.0.0")],
        host="production", installs=[U("desktop-impostor-9.0.0", "desktop-impostor"), U("workspace-impostor-9.0.0", "workspace-impostor")],
        ran=[], images=["Desktop", "Workspace"], extra=[desktop_operations("production, impostors refused")],
    ))
    add(Scenario(
        "a test catalogue admits its own distinct fixture identifier, and refuses the one it does not name",
        [R(SH, "9.0.0", "U", ACTIVE, SEL, "selected-with-refusals", "signing-identifier-mismatch"),
         R(SH, "1.5.0", "U", REJECTED, NOT, "signing-identifier-mismatch", "fixturesh"),
         R(SH, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")],
        host="slot-impostor-admitted", installs=[U("r9.0.0-other-identifier", "impostor-update"), U("r1.5.0", "correct-id-update")],
        ran=["impostor-update"], images=["impostor-update"], serves=("fixtureShInfo", UPDATE_GREETING),
    ))

    # -- Equal bytes and the same bundle name in both roots, staged in both orders --------------
    accept = {"KOINE_FIXTURE_ASSESSMENT": "accept"}
    both_staged = lambda user, bundled_copy: [("FixtureSh@user", user), ("FixtureSh@bundled", bundled_copy)]
    user_caught_up = [R(SH, "1.5.0", "B", ACTIVE, SEL, "selected-with-refusals"), R(SH, "1.5.0", "U", REJECTED, NOT, "quarantine-refused")]
    user_equal = [R(SH, "1.5.0", "B", ACTIVE, SEL, "selected-with-refusals"), R(SH, "1.5.0", "U", REJECTED, NOT, "equal-to-bundled")]
    add(Scenario(
        "equal bytes in both roots, the per-user copy staged first: the host catches up and each copy stays its own",
        [R(SH, "1.5.0", "U", ACTIVE, SEL, None), R(SH, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")], host="slot",
        installs=[U("r1.5.0", "FixtureSh", quarantined=True)], env=accept, quarantine=True, ran=["FixtureSh@user"],
        images=["FixtureSh@user"], serves=("fixtureShInfo", UPDATE_GREETING), extra=[staged_copies(both_staged(True, False))],
        then=[
            # The host now ships the update's bytes. Its copy in the application is staged beside the per-user one, and is
            # not judged by a verdict that only the per-user copy's quarantine brings.
            Phase(user_caught_up, host="slot-caught-up", env=verdict, quarantine=True, ran=["FixtureSh@bundled"],
                  images=["FixtureSh@bundled"], serves=("fixtureShInfo", UPDATE_GREETING),
                  extra=[staged_copies(both_staged(True, False) + [("FixtureSh", False)])],
                  label="the host catches up; the verdict now refuses the per-user copy"),
            Phase(user_equal, host="slot-caught-up", env=accept, quarantine=True, ran=["FixtureSh@bundled"],
                  images=["FixtureSh@bundled"], extra=[staged_copies(both_staged(True, False) + [("FixtureSh", False)])],
                  label="the verdict now accepts it: it is assessed again and is equal to the bundle"),
        ],
    ))
    add(Scenario(
        "equal bytes in both roots, the bundled copy staged first: the per-user copy's assessment is not skipped",
        [R(SH, "1.5.0", "B", ACTIVE, SEL, None)], host="slot-caught-up", env=verdict, ran=["FixtureSh"], images=["FixtureSh"],
        serves=("fixtureShInfo", UPDATE_GREETING), extra=[staged_copies([("FixtureSh", False)])],
        then=[
            Phase(user_caught_up, actions=[("put", U("r1.5.0", "FixtureSh", quarantined=True))], quarantine=True,
                  ran=["FixtureSh@bundled"], images=["FixtureSh@bundled"],
                  extra=[staged_copies(both_staged(True, False))], label="the per-user copy arrives, quarantined"),
            Phase(user_equal, env=accept, quarantine=True, ran=["FixtureSh@bundled"], images=["FixtureSh@bundled"],
                  extra=[staged_copies(both_staged(True, False))], label="the verdict now accepts it"),
        ],
    ))
    add(Scenario(
        "a legacy shared staging entry is never reused for an update",
        [sh_base], host="slot", ran=[FRESH], images=["FixtureSh"],
        then=[Phase([R(SH, "1.5.0", "U", ACTIVE, SEL, None), sh_sup("1.0.0", "B")],
                    actions=[("plant-legacy", "baseline", "r1.5.0", "update"), ("put", U("r1.5.0", "update"))],
                    ran=["update"], serves=("fixtureShInfo", UPDATE_GREETING), extra=[legacy_not_reused],
                    label="an entry named for the update's bytes, holding the baseline's")],
    ))
    add(Scenario(
        "a quarantined legacy entry is never inherited by the bundled copy of equal bytes",
        [R(SH, "1.5.0", "B", ACTIVE, SEL, None)], host="slot-caught-up", env=verdict, ran=["FixtureSh"],
        images=["FixtureSh"], serves=("fixtureShInfo", UPDATE_GREETING),
        then=[Phase([R(SH, "1.5.0", "B", ACTIVE, SEL, None)],
                    actions=[("plant-legacy", "r1.5.0", "r1.5.0", "FixtureSh", True)], quarantine=True, ran=["FixtureSh"],
                    serves=("fixtureShInfo", UPDATE_GREETING), extra=[legacy_not_reused],
                    label="an entry of the old scheme, the same bytes, quarantined")],
    ))

    # -- The real first-party providers: the old baseline, updates, and mixed releases ---------
    d_base = R("desktop", "1.0.0", "B", ACTIVE, SEL, None)
    w_base = R("workspace", "1.0.2", "B", ACTIVE, SEL, None)
    d_sup = R("desktop", "1.0.0", "B", REJECTED, NOT, "superseded-candidate")
    w_sup = R("workspace", "1.0.2", "B", REJECTED, NOT, "superseded-candidate")
    d_upd = R("desktop", "1.1.0", "U", ACTIVE, SEL, None)
    w_upd = R("workspace", "1.1.0", "U", ACTIVE, SEL, None)
    modules = {"Desktop": "DesktopProvider", "desktop-update": "DesktopProvider", "desktop-update-renamed": "DesktopProvider",
               "Workspace": "WorkspaceProvider", "workspace-update": "WorkspaceProvider",
               "workspace-update-renamed": "WorkspaceProvider"}
    both_loaded = lambda: image_inventory(expect_modules=modules, reused_types=["ProcessStart"])
    add(Scenario(
        "a selection-aware host over an independently compiled old designated baseline",
        [R("desktop", "1.0.0", "B", ACTIVE, SEL, None)], host="desktop-old", images=["Desktop"],
        extra=[catalogue_matches_packaged("desktop"), desktop_operations("new host, released baseline"),
               image_inventory(expect_modules=modules)],
        conformance=PROFILES + "core-desktop-extension-host.json",
    ))
    add(Scenario(
        "a newer desktop release over the released baseline, without rebuilding the host",
        [R("desktop", "1.1.0", "U", ACTIVE, SEL, None), d_sup], host="desktop-old",
        installs=[U("desktop-update", "desktop-update")], images=["desktop-update"],
        extra=[desktop_operations("new host, desktop update"), image_inventory(expect_modules=modules),
               approval_unchanged("desktop"), host_not_rebuilt()],
        conformance=PROFILES + "core-desktop-update-extension-host.json",
    ))
    add(Scenario(
        "the shipped catalogue around this tree's desktop and workspace: the generation before any update",
        [d_base, w_base], host="production", images=["Desktop", "Workspace"],
        extra=[both_loaded(), desktop_operations("production, baselines"), workspace_operation],
        conformance=PROFILES + "core-desktop-workspace-discovery-extension-host.json",
    ))
    add(Scenario(
        "a mixed release: a newer desktop beside the workspace baseline",
        [d_upd, d_sup, w_base], host="production", installs=[U("desktop-update", "desktop-update")],
        images=["desktop-update", "Workspace"],
        extra=[both_loaded(), desktop_operations("production, desktop update"), workspace_operation, approval_unchanged("desktop")],
        conformance=PROFILES + "core-desktop-workspace-desktop-update-extension-host.json",
    ))
    add(Scenario(
        "a mixed release: a newer workspace beside the desktop baseline",
        [d_base, w_upd, w_sup], host="production", installs=[U("workspace-update", "workspace-update")],
        images=["Desktop", "workspace-update"],
        extra=[both_loaded(), desktop_operations("production, workspace update"), workspace_operation,
               approval_unchanged("workspace")],
        conformance=PROFILES + "core-desktop-workspace-workspace-update-extension-host.json",
    ))
    add(Scenario(
        "both real providers updated independently, without rebuilding the host",
        [d_upd, d_sup, w_upd, w_sup], host="production",
        installs=[U("desktop-update", "desktop-update"), U("workspace-update", "workspace-update")],
        images=["desktop-update", "workspace-update"],
        extra=[both_loaded(), desktop_operations("production, both updated"), workspace_operation, host_not_rebuilt()],
        conformance=PROFILES + "core-desktop-workspace-update-extension-host.json",
    ))
    add(Scenario(
        "both real updates under another principal class are selected like the others",
        [d_upd, d_sup, w_upd, w_sup], host="production",
        installs=[U("desktop-update-renamed", "desktop-update-renamed"), U("workspace-update-renamed", "workspace-update-renamed")],
        images=["desktop-update-renamed", "workspace-update-renamed"],
        extra=[both_loaded(), desktop_operations("production, both updated, principal renamed"), workspace_operation],
        conformance=PROFILES + "core-desktop-workspace-update-extension-host.json",
    ))
    refused_desktop = R("desktop", "1.1.0", "U", INCOMPATIBLE, NOT, "selection-feature-required", FEATURE_TEXT)
    refused_workspace = R("workspace", "1.1.0", "U", INCOMPATIBLE, NOT, "selection-feature-required", FEATURE_TEXT)
    add(Scenario(
        "real updates that do not state the feature are refused before they load, and the baselines run",
        [refused_desktop, R("desktop", "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 1.1.0"),
         refused_workspace, R("workspace", "1.0.2", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 1.1.0")],
        host="production", installs=[U("desktop-update-no-feature", "desktop-update"), U("workspace-update-no-feature", "workspace-update")],
        images=["Desktop", "Workspace"], extra=[desktop_operations("production, updates refused")],
        conformance=PROFILES + "core-desktop-workspace-update-refused-extension-host.json",
    ))
    add(Scenario(
        "real updates that do not state the feature, under another principal class, are refused the same way",
        [refused_desktop, R("desktop", "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 1.1.0"),
         refused_workspace, R("workspace", "1.0.2", "B", ACTIVE, SEL, "selected-with-refusals", "claims release 1.1.0")],
        host="production",
        installs=[U("desktop-update-renamed-no-feature", "desktop-update"), U("workspace-update-renamed-no-feature", "workspace-update")],
        images=["Desktop", "Workspace"],
    ))

    return s


# --- The pre-extension host: the released revision's headless host -----------------------------


INCOMPATIBLE_FEATURE = f"requires host features this Koine lacks: {FEATURE_TEXT}"


def released_run(name, bundled, installs, rows, update_label, profile=None, compared=None, baseline_markers=()):
    """One run of the RELEASED host (v0.1.0): which bundles it is given in place of Contents/PlugIns and in the
    per-user root, the rows (provider, version, state) it serves, and what of its update it ran.

    `rows` is a list of (provider, version, state, text the diagnostic names); `update_label` the install name
    of a per-user update the host must have refused before loading it, or None; `baseline_markers` the fixture
    baselines bundled beside the desktop provider, each of which must have run every phase."""

    def run(suite, results, only):
        if only is not None and only not in name:
            return
        record, check = harness.recorder(results, name, f"{name} [the released host]", "released host (v0.1.0)")
        try:
            host = harness.ReleasedHost(suite, bundled, installs)
        except Exception as error:  # noqa: BLE001 - a host that will not start is a failed check
            check("the released host starts", False, str(error))
            harness.finish_record(record)
            return
        try:
            served = host.rows()
            actual = sorted((r["provider"], r["version"], r["state"]) for r in served)
            check("the rows the released host serves", actual == sorted(r[:3] for r in rows), {"actual": actual, "wanted": sorted(r[:3] for r in rows)})
            for provider, version, state, text in rows:
                if text:
                    diagnostic = " ".join(r["diagnostic"] or "" for r in served if (r["provider"], r["version"], r["state"]) == (provider, version, state))
                    check(f"{provider} {version} is {state}, naming {text!r}", text in diagnostic, diagnostic)
            loaded = host.loaded_labels()
            wanted = sorted(["Desktop"] + [n for n in baseline_markers])
            check("the provider images the released host mapped: its bundled providers, and none of the update's", loaded == wanted,
                  {"observed": loaded, "wanted": wanted})
            observed = {}
            for label, step in host.markers():
                observed.setdefault(label, []).append(step)
            for baseline in baseline_markers:
                check(f"the bundled {baseline} ran its initializer, factory and start", observed.get(baseline) == list(harness.FULL), observed)
            check("no marker was written for an image the host did not run", set(observed) == set(baseline_markers), observed)
            record["rows_observed"] = []
            # Controls: the update's binary is shown loading and answering where the feature is supplied.
            record.setdefault("unloaded", {})
            if update_label:
                case = dict((n, c) for c, n in installs)[update_label]
                record["unloaded"][update_label] = suite.binary_of[case]
            record.setdefault("partial", {})
            record["loaded"] = loaded
            # A control is only credited to a run whose own checks have all held so far.
            if all(entry["passed"] for entry in record["checks"]):
                if "Desktop" in loaded:
                    suite.controls.setdefault("real-desktop-released", record["label"])
                for baseline in baseline_markers:
                    case = next(c for c in bundled if suite.manifest_of(c)["providerId"] == baseline.lower())
                    suite.controls.setdefault(suite.binary_of[case], record["label"])
            results_ops = harness.desktop_operations(lambda q, v, c: host.post(q, c, v), host.create_grant)
            harness.check_desktop_expectations(results_ops, check, name)
            if compared:
                OPERATIONS[compared] = results_ops
            if profile:
                harness.check_conformance(host, profile, suite, check, record)
            stopped, code = host.stop()
            check("the released host stops cleanly", code == 0 and stopped.get("stopped") is True, [code, stopped])
        except Exception as error:  # noqa: BLE001
            check("the run completes", False, repr(error))
            try:
                host.stop()
            except Exception:  # noqa: BLE001
                pass
        harness.finish_record(record)

    return run


# A running application's windows change between two runs minutes apart; everything else is the provider's answer.
VOLATILE_STEPS = {"windows, a running application (Finder)"}


def operations_differences(old, new):
    """The steps two hosts did not answer identically (status, data and errors, compared whole), but for the ones
    that report the desktop's own state from one moment to the next."""
    return [step for step in sorted((set(old) | set(new)) - VOLATILE_STEPS) if old.get(step) != new.get(step)]


def operations_preserved(suite, results, only):
    """The old host and the selection-aware host over the old baseline answer the desktop operations identically."""
    old, new = OPERATIONS.get("old host, released desktop"), OPERATIONS.get("new host, released baseline")
    if old is None or new is None:
        if only is not None:
            return  # a subset run that left one side out says nothing of the pair
        old, new = old or {}, new or {}
    record, check = harness.recorder(results, "old host and new host: existing desktop operations preserved",
                                     "old host and new host: existing desktop operations preserved [differential]", "released host and desktop-old")
    check("the same steps were run against both, and there were steps", sorted(old) == sorted(new) and len(old) >= 11, [sorted(old), sorted(new)])
    check("every step was answered identically: status, data, errors with their kinds, messages and paths",
          operations_differences(old, new) == [], operations_differences(old, new))
    harness.finish_record(record)


def instrument_self_tests(suite, results, only):
    """Each instrument of this driver that is not a host run, seen RED against a subject that is wrong: a control
    that has never been seen to fail is not a control."""
    if only is not None:
        return
    import copy
    import tempfile

    record, check = harness.recorder(results, "instruments", "instruments: each seen red against a subject that is wrong", "none")

    def red(what, problems):
        check(f"{what}: red", bool(problems), problems)

    with tempfile.TemporaryDirectory() as directory:
        bundle = os.path.join(directory, "Name.koineprovider")
        os.makedirs(bundle)
        path = os.path.join(bundle, "image")
        with open(path, "wb") as file:
            file.write(b"one")
        first = content_digest(bundle)
        with open(path, "wb") as file:
            file.write(b"two")
        second = content_digest(bundle)
        os.chmod(path, 0o755)
        third = content_digest(bundle)
        check("the content digest moves with a byte of content, and with the executable bit", len({first, second, third}) == 3,
              [first, second, third])
        check("a staged name differs by origin and by location, not only by content",
              len({harness.staged_name("BUNDLED", bundle, bundle), harness.staged_name("PER_USER", bundle, bundle),
                   harness.staged_name("PER_USER", bundle + "2", bundle)}) == 3)
        check("the earlier scheme's name is the content digest alone, the current one is not",
              harness.legacy_staged_name(bundle, bundle) == f"Name-{third}" and harness.staged_name("BUNDLED", bundle, bundle) != f"Name-{third}")

    good = {
        "a": {"classes": ["A.one"]}, "b": {"classes": ["B.two"]},
    }
    healthy = inventory_checks(good, {"a": {"ModA"}, "b": {"ModB"}}, {"a": [("ModA", "T")], "b": [("ModB", "T")]}, {"Host"}, {"HostClass"},
                               ["/fw"], {"a": "ModA"}, ["T"])
    check("a healthy inventory passes every check", all(passed for _, passed, _ in healthy), [c for c in healthy if not c[1]])
    red("two images that define one Swift module",
        [c for c in inventory_checks(good, {"a": {"Shared"}, "b": {"Shared"}}, {"a": [], "b": []}, {"Host"}, set(), ["/fw"], None, []) if not c[1]])
    red("two images that define one Objective-C class",
        [c for c in inventory_checks({"a": {"classes": ["C"]}, "b": {"classes": ["C"]}}, {"a": {"A"}, "b": {"B"}}, {"a": [], "b": []},
                                     {"Host"}, set(), ["/fw"], None, []) if not c[1]])
    red("an image that defines a class the host defines",
        [c for c in inventory_checks({"a": {"classes": ["HostClass"]}}, {"a": {"A"}}, {"a": []}, {"Host"}, {"HostClass"}, ["/fw"], None, []) if not c[1]])
    red("an image that defines a module the host defines",
        [c for c in inventory_checks({"a": {"classes": []}}, {"a": {"Host"}}, {"a": []}, {"Host"}, set(), ["/fw"], None, []) if not c[1]])
    red("an image that defines the framework's module",
        [c for c in inventory_checks({"a": {"classes": []}}, {"a": {"KoineProviderAPI"}}, {"a": []}, {"Host"}, set(), ["/fw"], None, []) if not c[1]])
    red("a process that mapped the framework twice",
        [c for c in inventory_checks(good, {"a": {"A"}, "b": {"B"}}, {"a": [], "b": []}, {"Host"}, set(), ["/fw", "/fw2"], None, []) if not c[1]])
    red("helper source that is not compiled into more than one provider",
        [c for c in inventory_checks(good, {"a": {"A"}, "b": {"B"}}, {"a": [("A", "T")], "b": [("B", "U")]}, {"Host"}, set(), ["/fw"], None, ["T"]) if not c[1]])

    real = OPERATIONS.get("old host, released desktop")
    if real is None:
        check("the desktop operations of the old host are available to hold the expectations to", False, None)
    else:
        def problems(mutate):
            mutated = copy.deepcopy(real)
            mutate(mutated)
            seen = []
            harness.check_desktop_expectations(mutated, lambda name, passed, observed=None: seen.append(name) if not passed else None, "self-test")
            return seen

        clean = []
        harness.check_desktop_expectations(real, lambda name, passed, observed=None: clean.append(name) if not passed else None, "self-test")
        check("the desktop expectations hold of the old host's answers", clean == [], clean)
        red("an absent process that is not null", problems(lambda r: r["application, an absent process"].update(data={"desktopApplication": {"ref": "x"}})))
        red("a stale reference that is not unavailable", problems(lambda r: r["window, a stale reference"]["errors"][0].update(kind="failed")))
        red("a read-only grant that names the wrong capability",
            problems(lambda r: r["read-only grant is refused focus"]["errors"][0].update(requiredCapability="desktop:read")))
        red("a control-only grant that is let read", problems(lambda r: r["control-only grant is refused a read"].update(errors=[])))
        red("a differential between two hosts that answer one step differently",
            operations_differences(real, {**real, "application, an absent process": {"status": 200, "data": None, "errors": []}}))
        check("a differential between two identical answers is empty", operations_differences(real, copy.deepcopy(real)) == [])
    harness.finish_record(record)


EXTRA = [
    released_run(
        "old host: the released host and its desktop provider", ["released-desktop"], [],
        [("desktop", "1.0.0", "ACTIVE", None)], None, profile=PROFILES + "core-desktop-old-host.json",
        compared="old host, released desktop"),
    released_run(
        "old host: a newly published desktop update, the principal class kept", ["released-desktop"], [("desktop-update", "upd")],
        [("desktop", "1.0.0", "ACTIVE", None), ("desktop", "1.1.0", "INCOMPATIBLE", INCOMPATIBLE_FEATURE)], "upd",
        profile=PROFILES + "core-desktop-old-host-update-refused.json"),
    released_run(
        "old host: a newly published desktop update, the principal class renamed", ["released-desktop"],
        [("desktop-update-renamed", "upd")],
        [("desktop", "1.0.0", "ACTIVE", None), ("desktop", "1.1.0", "INCOMPATIBLE", INCOMPATIBLE_FEATURE)], "upd"),
    released_run(
        "old host: a newly published workspace update, the principal class kept", ["released-desktop", "sk-baseline"],
        [("sk-r1.1.0", "upd")],
        [("desktop", "1.0.0", "ACTIVE", None), (SK, "1.0.0", "ACTIVE", None), (SK, "1.1.0", "INCOMPATIBLE", INCOMPATIBLE_FEATURE)],
        "upd", baseline_markers=["FixtureSk"]),
    released_run(
        "old host: a newly published workspace update, the principal class renamed", ["released-desktop", "sk-baseline"],
        [("sk-r1.1.0-renamed", "upd")],
        [("desktop", "1.0.0", "ACTIVE", None), (SK, "1.0.0", "ACTIVE", None), (SK, "1.1.0", "INCOMPATIBLE", INCOMPATIBLE_FEATURE)],
        "upd", baseline_markers=["FixtureSk"]),
    operations_preserved,
    instrument_self_tests,
]

PENDING = [
    ("Missing approval, wrong Team ID, unsigned/ad-hoc/tampered seal: a bundle signed by a second real Developer ID team, and the "
     "alternate-team host", "needs a second real Developer ID team's certificate. `security find-identity` here lists one Developer ID "
     "identity, the team that signs every fixture; an approval record naming another Team ID (closed here) is not a bundle another team "
     "signed, and no mock closes it. Owned by `alternate-team-signing`, at N and G as at V."),
]

OWNED_REASONS = {
    "not-approved", "approval-team-mismatch", "signature-refused", "location-outside-root", "framework-incompatible",
    "feature-unavailable", "os-incompatible", "architecture-incompatible", "quarantine-refused", "staging-failed",
    "signing-identifier-mismatch", "selection-feature-required", "superseded-candidate", "equal-to-bundled",
    "selected-with-refusals",
}


def main():
    harness.main(scenarios, owned_reasons=OWNED_REASONS, pending=PENDING, doc=__doc__, extra_runs=EXTRA)


if __name__ == "__main__":
    main()
