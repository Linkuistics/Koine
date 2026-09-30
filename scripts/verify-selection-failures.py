#!/usr/bin/env python3
"""Runs the selection acceptance's failure-boundary rows against purpose-built signed hosts.

Machine's "Selection acceptance" table (docs/specs/machine.md) assigns what happens
after choices freeze to the native loader (N) and public GraphQL (G). The harness is
scripts/selection_harness.py's: each scenario, and each alternative order within it,
is its own signed host process over a fresh data directory, per-user provider root and
marker log, and a scenario that goes on (recovery) restarts a new host process over the
same data directory with a new marker log.

This driver owns, of those rows:

  * a frozen update that fails its principal check, `dlopen`, principal class,
    descriptor or schema, with healthy alternatives: no alternative is loaded or
    started, the choice stays identifiable, and repair or removal followed by a
    restart recovers;
  * a shipped update against another shipped selection (both refused, whatever their
    origin), an ordinary claimant of a shipped principal (refused alone), and claimants
    of a host class (refused), with nothing retried;
  * the later-failure part of diagnostic completeness: a failed frozen selection keeps
    its identity and the competing refusals in its diagnostic;
  * ordinary duplicates: only providers that pass every pre-load check contest; eligible
    duplicates are all refused as `manifest-collision`, and a refused rival (unapproved,
    incompatible, ad hoc, tampered) never evicts a valid provider;
  * the capability-owner cascade: a shipped provider refused before publication (by the
    loader or by the core) strands the provider that additionally requires its capability,
    and that one strands a third, to a fixed point, held to an exact absent/rejected
    conformance profile, the capabilities and the diagnostics; management stays usable
    and a valid dependency cycle survives;
  * a shipped provider that publishes and then fails to start: its schema and authority
    remain, its fields are unavailable, nothing that depends on it is removed for that
    alone, and no bundled copy is tried in its place.

usage: verify-selection-failures.py <hosts> <fixtures> <results.json> [--only <substring>] [--conformance <KoineConformance>]

<hosts> is scripts/build-selection-hosts.py's output, <fixtures> is
Fixtures/FixtureProvider/build-decisions.sh's. Prints a line per scenario run and
its checks; exits 1 if any check fails. `--conformance` is the built Tools/Conformance
tool (`task selection:failures` passes it); the cascade's conformance profile needs it. docs/verification/selection-failures.md
records a run.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import selection_harness as harness  # noqa: E402
from selection_harness import (  # noqa: E402
    ACTIVE, BASE_GREETING, FRESH, INCOMPATIBLE, NOT, REJECTED, SEL, SH, SK, UPDATE_GREETING, Phase, R, Scenario, U,
)

SK_NAME = "FixtureSk"  # the second slot's baseline install name
OD, UNKNOWN = "fixtureod", "unknown"
# A provider built with FIXTURE_ADDITIONAL greets with its second revision's additional-capabilities greeting.
SK_DEPENDANT_GREETING = "hello from the fixturesk provider, revision 2, using additional capabilities"
OD_GREETING = "hello from the fixtureod provider"
OD_DEPENDANT_GREETING = "hello from the fixtureod provider, revision 2, using additional capabilities"
SH_DEPENDANT_GREETING = "hello from the fixturesh provider, revision 2, using additional capabilities"
ALL_CAPABILITIES = ["fixturesh:read", "fixturesh:control", "fixturesk:read", "fixturesk:control",
                    "fixtureod:read", "fixtureod:control"]
CASCADE_PROFILE = "docs/design/profiles/selection-cascade-extension-host.json"


FAILURES = [
    # (case, stable reason, markers the failing image reached, what the diagnostic says, label)
    ("f-principal-host-class", "principal-collision", {}, "already registered", "its principal class is one the host's own image registered"),
    ("f-principal-system-class", "principal-collision", {}, "already registered", "its principal class is a system class"),
    ("f-dlopen-unloadable", "load-failed", {}, "dynamic loader refused", "dlopen refuses its private dependency"),
    ("f-principal-missing", "principal-class-missing", {"failing": ("initializer",)}, "registers no class named", "its image registers no principal class of that name"),
    ("f-principal-not-factory", "principal-class-invalid", {"failing": ("initializer",)}, "does not conform to ProviderFactory", "its principal class is no factory"),
    ("f-descriptor-mismatch", "descriptor-mismatch", {"failing": ("initializer", "factory")}, "disagrees with its manifest", "its descriptor disagrees with its manifest"),
    ("f-schema-invalid-sdl", "invalid-sdl", {"failing": ("initializer", "factory")}, "Invalid SDL", "its SDL does not parse"),
    ("f-schema-outside-prefix", "missing-prefix", {"failing": ("initializer", "factory")}, "does not start with", "it defines a type outside its prefix"),
]


def scenarios():
    s = []
    add = s.append
    lower = R(SH, "1.5.0", "U", REJECTED, NOT, "superseded-candidate")
    bundle = R(SH, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")
    healthy_bundle = R(SH, "1.0.0", "B", ACTIVE, SEL, None)

    # -- Controls: every binary the rows below say never ran is seen running here ----
    add(Scenario("control: the designated baseline loads", [healthy_bundle], ran=[FRESH],
                 serves=("fixtureShInfo", BASE_GREETING)))
    add(Scenario("control: a healthy shipped update loads", [R(SH, "2.0.0", "U", ACTIVE, SEL, None), bundle],
                 installs=[U("f-repaired", "update")], ran=["update"], serves=("fixtureShInfo", UPDATE_GREETING)))
    add(Scenario("control: a healthy update with a loadable private dependency loads",
                 [R(SH, "2.0.0", "U", ACTIVE, SEL, None), bundle],
                 installs=[U("f-dlopen-good", "update")], ran=["update"], serves=("fixtureShInfo", UPDATE_GREETING)))
    add(Scenario("control: two shipped baselines load", [healthy_bundle, R(SK, "1.0.0", "B", ACTIVE, SEL, None)],
                 host="two-slots", ran=[FRESH, SK_NAME]))
    add(Scenario("control: a second shipped slot's update loads",
                 [healthy_bundle, R(SK, "1.0.0", "B", REJECTED, NOT, "superseded-candidate"),
                  R(SK, "1.1.0", "U", ACTIVE, SEL, None)],
                 host="two-slots", installs=[U("sk-r1.1.0", "sk-update")], ran=[FRESH, "sk-update"]))
    add(Scenario("control: two ordinary providers load beside the baseline",
                 [healthy_bundle, R(OD, "1.0.0", "U", ACTIVE, SEL, None), R(UNKNOWN, "1.0.0", "U", ACTIVE, SEL, None)],
                 installs=[U("ordinary", "first"), U("unknown", "second")], ran=[FRESH, "first", "second"]))

    # -- A frozen update that fails after its choice is made ------------------------
    # Its lower update and the bundled baseline are healthy, and neither is loaded,
    # started or retried. The failed choice stays SELECTED, names itself, and every row
    # of the identity points at it. Recovery: repair it in place (a good 2.0.0 under the
    # same name), or remove it (the lower update is chosen).
    def failing(reason, note=None):
        return R(SH, "2.0.0", "U", REJECTED, SEL, reason, note)

    def recovery():
        return [
            Phase(
                [R(SH, "2.0.0", "U", ACTIVE, SEL, None), lower, bundle], label="repaired in place",
                actions=[("replace", "failing", "f-repaired")], ran=["failing"],
                serves=("fixtureShInfo", UPDATE_GREETING),
            ),
            Phase(
                [R(SH, "1.5.0", "U", ACTIVE, SEL, None), bundle], label="removed",
                actions=[("remove", "failing")], ran=["lower"], serves=("fixtureShInfo", UPDATE_GREETING),
            ),
        ]

    for case, reason, partial, says, label in FAILURES:
        add(Scenario(
            f"a frozen shipped update fails: {label}",
            [failing(reason, says), lower, bundle],
            installs=[U(case, "failing"), U("r1.5.0", "lower")], partial=partial,
            absent_fields=["fixtureShInfo"], then=recovery(),
        ))

    # The diagnostic of a failed frozen selection keeps the competing refusals that
    # preceded its choice, beside its own failure; their rows keep their own reasons.
    competing = [
        R(SH, "9.0.0", "U", REJECTED, NOT, "signing-identifier-mismatch"),
        R(SH, "2.0", "U", REJECTED, NOT, "invalid-version"),
    ]
    for case, reason, partial, own in (
        ("f-schema-invalid-sdl", "invalid-sdl", {"failing": ("initializer", "factory")}, "Invalid SDL"),
        ("f-principal-host-class", "principal-collision", {}, "already registered"),
    ):
        add(Scenario(
            f"a failed frozen selection keeps its identity and the competing refusals ({reason})",
            [failing(reason, [own, "is refused as signing-identifier-mismatch", "claims release 9.0.0",
                              "is refused as invalid-version", "claims release 2.0"]),
             lower, bundle] + competing,
            installs=[U(case, "failing"), U("r1.5.0", "lower"), U("r9.0.0-other-identifier", "impostor"),
                      U("r2.0-malformed", "malformed")],
            partial=partial, absent_fields=["fixtureShInfo"],
        ))

    # -- Principal conflicts among frozen selections ---------------------------------
    two = dict(host="two-slots")
    sh_update_claims_sk = R(SH, "2.0.0", "U", REJECTED, SEL, "principal-collision", "claimed by more than one selected provider")
    add(Scenario(
        "a shipped update and another shipped identity's bundle are refused symmetrically",
        [sh_update_claims_sk, bundle, R(SK, "1.0.0", "B", REJECTED, SEL, "principal-collision", "claimed by more than one selected provider")],
        installs=[U("f-principal-sk", "update")], absent_fields=["fixtureShInfo", "fixtureSkInfo"], rename=True, **two,
    ))
    add(Scenario(
        "two shipped updates are equal slot owners, and both are refused",
        [sh_update_claims_sk, bundle, R(SK, "1.1.0", "U", REJECTED, SEL, "principal-collision"),
         R(SK, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")],
        installs=[U("f-principal-sk", "sh-update"), U("sk-r1.1.0", "sk-update")],
        absent_fields=["fixtureShInfo", "fixtureSkInfo"], rename=True, **two,
    ))
    claim = R(OD, "1.0.0", "U", REJECTED, SEL, "principal-collision", "claimed by more than one selected provider")
    add(Scenario(
        "an ordinary claimant of a shipped principal is refused alone, the bundled owner running",
        [healthy_bundle, claim], installs=[U("ordinary-principal-sh", "claimant")], ran=[FRESH],
        serves=("fixtureShInfo", BASE_GREETING), absent_fields=["fixtureOdInfo"], rename=True,
    ))
    add(Scenario(
        "an ordinary claimant of a shipped principal is refused alone, the shipped update running",
        [R(SH, "1.10.0", "U", ACTIVE, SEL, None), R(SH, "1.0.0", "B", REJECTED, NOT, "superseded-candidate"), claim],
        installs=[U("r1.10.0", "update"), U("ordinary-principal-sh", "claimant")], ran=["update"],
        serves=("fixtureShInfo", UPDATE_GREETING), absent_fields=["fixtureOdInfo"], rename=True,
    ))
    both = "claimed by more than one selected provider"
    add(Scenario(
        "ordinary claimants of one principal are both refused, the shipped owner running",
        [healthy_bundle, R(OD, "1.0.0", "U", REJECTED, SEL, "principal-collision", both),
         R(UNKNOWN, "1.0.0", "U", REJECTED, SEL, "principal-collision", both)],
        installs=[U("ordinary", "first"), U("unknown-principal-od", "second")], ran=[FRESH],
        absent_fields=["fixtureOdInfo", "unknownInfo"], rename=True,
    ))
    add(Scenario(
        "an ordinary claimant of a host class is refused, the shipped owner running",
        [healthy_bundle, R(OD, "1.0.0", "U", REJECTED, SEL, "principal-collision", "already registered")],
        installs=[U("ordinary-principal-host-class", "claimant")], ran=[FRESH],
        serves=("fixtureShInfo", BASE_GREETING), absent_fields=["fixtureOdInfo"],
    ))

    # -- The capability-owner cascade -------------------------------------------------
    # fixturesh stands for the desktop provider, a fixturesk update that additionally
    # requires fixturesh's read capability for the workspace provider, and an ordinary
    # provider that additionally requires fixturesk's for the third. The shipped slots
    # sit in the `two-slots` host, whose baselines are the bundled copies.
    two = dict(host="two-slots")
    sk_bundle = R(SK, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")
    sk_dependant_ok = R(SK, "1.1.0", "U", ACTIVE, SEL, None)
    od_dependant_ok = R(OD, "1.0.0", "U", ACTIVE, SEL, None)
    chain = [U("dep-sk-needs-sh", "workspace"), U("dep-od-needs-sk", "third")]
    all_fields = ["fixtureShInfo", "fixtureSkInfo", "fixtureOdInfo"]
    add(Scenario(
        "control: a dependant whose capability owner is present loads, and so does its dependant",
        [healthy_bundle, sk_dependant_ok, sk_bundle, od_dependant_ok], installs=chain, ran=[FRESH, "workspace", "third"],
        serves=("fixtureSkInfo", SK_DEPENDANT_GREETING), present_fields=all_fields,
        mutations=["fixtureSkRenameItemChecked", "fixtureOdRenameItemChecked"], capabilities=ALL_CAPABILITIES, **two,
    ))
    add(Scenario(
        "control: a valid dependency cycle between two shipped providers survives, with a third on it",
        [R(SH, "2.0.0", "U", ACTIVE, SEL, None), bundle, sk_dependant_ok, sk_bundle, od_dependant_ok],
        installs=[U("dep-sh-needs-sk", "desktop"), U("dep-sk-needs-sh", "workspace"), U("dep-od-needs-sk", "third")],
        ran=["desktop", "workspace", "third"], serves=("fixtureShInfo", SH_DEPENDANT_GREETING),
        present_fields=all_fields, mutations=["fixtureShRenameItemChecked", "fixtureSkRenameItemChecked"],
        capabilities=ALL_CAPABILITIES, **two,
    ))

    # The desktop stand-in is refused before publication, by the loader (before load) or by
    # the core (after the factory), whatever the path. The provider that requires it is
    # removed with `missing-capability-owner`, and so is the one that requires that one.
    owner_missing = "which is not an admitted provider"
    for case, reason, partial, says, label in FAILURES:
        dependants = {"workspace": ("initializer", "factory"), "third": ("initializer", "factory")}
        add(Scenario(
            f"a refused desktop strands the provider that requires its capability, and the third on that: {label}",
            [R(SH, "2.0.0", "U", REJECTED, SEL, reason, says), bundle,
             R(SK, "1.1.0", "U", REJECTED, SEL, "missing-capability-owner", ["fixturesh", owner_missing]), sk_bundle,
             R(OD, "1.0.0", "U", REJECTED, SEL, "missing-capability-owner", ["fixturesk", owner_missing])],
            installs=[U(case, "failing")] + chain, partial=dict(partial, **dependants),
            absent_fields=all_fields, present_fields=["koine", "koineManagement"],
            no_mutations=["fixtureSkRenameItemChecked", "fixtureOdRenameItemChecked"],
            no_capabilities=ALL_CAPABILITIES,
            conformance=CASCADE_PROFILE if case == "f-schema-invalid-sdl" else None, **two,
        ))

    # -- A shipped provider that publishes and then fails to start ----------------------
    # Its schema and authority stay, its fields are unavailable, what requires its capability
    # is not removed for that alone, and neither its lower update nor its bundled copy is
    # tried in its place.
    add(Scenario(
        "a shipped provider that fails its start keeps its schema and authority, strands nothing, and is not replaced",
        [R(SH, "2.0.0", "U", "FAILED", SEL, "start-failed", "built to fail its start"), lower, bundle,
         sk_dependant_ok, sk_bundle, od_dependant_ok],
        installs=[U("sf-start-fails", "failing"), U("r1.5.0", "lower")] + chain,
        ran=["failing", "workspace", "third"], serves=("fixtureSkInfo", SK_DEPENDANT_GREETING),
        present_fields=all_fields, unavailable=[("fixtureShInfo", "provider is not running")],
        mutations=["fixtureSkRenameItemChecked", "fixtureOdRenameItemChecked"], capabilities=ALL_CAPABILITIES, **two,
    ))
    add(Scenario(
        "a shipped provider that fails its start and has no dependants is not replaced by its bundled copy",
        [R(SH, "2.0.0", "U", "FAILED", SEL, "start-failed", "built to fail its start"), bundle],
        installs=[U("sf-start-fails", "failing")], ran=["failing"],
        present_fields=["fixtureShInfo"], unavailable=[("fixtureShInfo", "provider is not running")],
        capabilities=["fixturesh:read", "fixturesh:control"],
    ))

    # -- Ordinary duplicates ---------------------------------------------------------------
    # Only providers that pass every pre-load check contest an identifier or prefix. Two
    # that do are both refused, none loads, and a refused rival never evicts a valid one.
    both_clash = "claims this identifier or prefix; both are refused"
    collided = lambda provider: R(provider, "1.0.0", "U", REJECTED, NOT, "manifest-collision", both_clash)
    add(Scenario(
        "two eligible copies of one ordinary provider are both refused, and none loads",
        [healthy_bundle, collided(OD), collided(OD)], installs=[U("ordinary", "first"), U("ordinary", "second")],
        ran=[FRESH], absent_fields=["fixtureOdInfo"], rename=True,
    ))
    add(Scenario(
        "three eligible copies of one ordinary provider are all refused",
        [healthy_bundle, collided(OD), collided(OD), collided(OD)],
        installs=[U("ordinary", "first"), U("ordinary", "second"), U("ordinary", "third")],
        ran=[FRESH], absent_fields=["fixtureOdInfo"],
    ))
    add(Scenario(
        "two eligible providers that share only a prefix are both refused",
        [healthy_bundle, collided(OD), collided("fixtureother")],
        installs=[U("ordinary", "first"), U("ordinary-same-prefix", "second")],
        ran=[FRESH], absent_fields=["fixtureOdInfo"], rename=True,
    ))
    add(Scenario(
        "two eligible providers that share only an identifier are both refused",
        [healthy_bundle, collided(OD), collided(OD)],
        installs=[U("ordinary", "first"), U("ordinary-same-identifier", "second")],
        ran=[FRESH], absent_fields=["fixtureOdInfo"], rename=True,
    ))
    add(Scenario(
        "a collision does not reach an unrelated provider",
        [healthy_bundle, collided(OD), collided(OD), R(UNKNOWN, "1.0.0", "U", ACTIVE, SEL, None)],
        installs=[U("ordinary", "first"), U("ordinary", "second"), U("unknown", "unrelated")],
        ran=[FRESH, "unrelated"], absent_fields=["fixtureOdInfo"], present_fields=["unknownInfo"],
    ))
    valid = R(OD, "1.0.0", "U", ACTIVE, SEL, None)
    rivals = [
        ("incompatible with this host's framework", U("ordinary-framework-future", "rival"),
         R(OD, "1.0.0", "U", INCOMPATIBLE, NOT, "framework-incompatible")),
        ("ad-hoc signed", U("ordinary-adhoc", "rival"), R(OD, "1.0.0", "U", REJECTED, NOT, "signature-refused")),
        ("tampered after it was sealed", U("ordinary-tampered", "rival"), R(OD, "1.0.0", "U", REJECTED, NOT, "signature-refused")),
        # An approval is by provider identifier and Team ID, so a copy that shares the valid
        # provider's identifier is approved as it is. An unapproved rival claims another identifier.
        ("unapproved, claiming only the prefix", U("ordinary-same-prefix", "rival", approved=False),
         R("fixtureother", "1.0.0", "U", REJECTED, NOT, "not-approved")),
    ]
    for label, install, refused in rivals:
        add(Scenario(
            f"a refused rival never evicts a valid ordinary provider: {label}",
            [healthy_bundle, valid, refused], installs=[U("ordinary", "valid"), install],
            ran=[FRESH, "valid"], serves=("fixtureOdInfo", OD_GREETING), rename=True,
        ))
    add(Scenario(
        "eligible duplicates are refused beside a refused rival, which keeps its own reason",
        [healthy_bundle, collided(OD), collided(OD), R(OD, "1.0.0", "U", INCOMPATIBLE, NOT, "framework-incompatible")],
        installs=[U("ordinary", "first"), U("ordinary", "second"), U("ordinary-framework-future", "rival")],
        ran=[FRESH], absent_fields=["fixtureOdInfo"],
    ))
    return s


OWNED_REASONS = {
    "principal-collision", "principal-class-missing", "principal-class-invalid", "load-failed",
    "descriptor-mismatch", "invalid-sdl", "missing-prefix", "missing-capability-owner", "manifest-collision",
    "start-failed", "not-approved", "framework-incompatible", "signature-refused",
}

PENDING = []

# The two whose SDL the core refuses load and register their factory, so they never start:
# the update built from the same source with a good schema is the control for `start`.
TWINS = {"sh-update-bad-sdl": "sh-update", "sh-update-outside-prefix": "sh-update"}

harness.main(scenarios, OWNED_REASONS, PENDING, __doc__, twins=TWINS)
