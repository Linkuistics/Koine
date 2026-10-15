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
    alone, and no bundled copy is tried in its place;
  * the schema digest: the same SDL from either root keeps it and the identifier-sorted
    position of a shipped identity (whatever order the catalogue lists the slots in),
    changed SDL changes it, an extra ordinary provider changes it, and the management
    fields refuse a grant without `koine:manage`;
  * restart: removing an update, changing the host's baseline or changing the assessment
    verdict is recomputed and grants no authority (a grant held before is exactly what it
    was, and what became available is not added to it), and a per-user root the host
    cannot read stops startup before any provider runs.

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
SK_UPDATE_GREETING = "hello from the fixturesk provider, revision 2"
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
    # -- The schema digest ---------------------------------------------------------------------
    # The digest is of the canonical SDL of what is published: core first, shipped identities
    # sorted by identifier, then ordinary providers sorted by identifier, each field in its
    # declared order. So it moves with the content and with the position of a contribution, and
    # with nothing else: not the root a copy came from, its release, or the order the catalogue
    # lists the slots in. `two-slots` lists fixturesk before fixturesh, and `two-slots-sorted`
    # lists them in identifier order, so a digest they share is identifier order.
    sh_ok, sk_ok = R(SH, "1.0.0", "B", ACTIVE, SEL, None), R(SK, "1.0.0", "B", ACTIVE, SEL, None)
    sh_2 = R(SH, "2.0.0", "U", ACTIVE, SEL, None)
    sh_1_superseded = R(SH, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")
    sk_1_1 = R(SK, "1.1.0", "U", ACTIVE, SEL, None)
    sk_1_superseded = R(SK, "1.0.0", "B", REJECTED, NOT, "superseded-candidate")
    bare = [sh_ok, sk_ok]
    sh_updated = [sh_2, sh_1_superseded, sk_ok]
    both_updated = [sh_2, sh_1_superseded, sk_1_1, sk_1_superseded]
    add(Scenario(
        "the same SDL from either root keeps the digest and the shipped position",
        bare, host="two-slots", ran=[FRESH, SK_NAME], order=[FRESH, SK_NAME], digest="same", managed=True,
        then=[
            Phase(sh_updated, label="fixturesh from the per-user root, at another release",
                  actions=[("install", "r2.0.0", "sh-update")], ran=["sh-update", SK_NAME],
                  order=["sh-update", SK_NAME], digest="same",
                  serves=("fixtureShInfo", UPDATE_GREETING)),
            Phase(both_updated, label="both slots from the per-user root",
                  actions=[("install", "sk-r1.1.0", "sk-update")], ran=["sh-update", "sk-update"],
                  order=["sh-update", "sk-update"], digest="same",
                  serves=("fixtureSkInfo", SK_UPDATE_GREETING)),
            Phase(bare, label="both updates removed and the host restarted",
                  actions=[("remove", "sh-update"), ("remove", "sk-update")], ran=[FRESH, SK_NAME],
                  order=[FRESH, SK_NAME], digest="same",
                  serves=("fixtureShInfo", BASE_GREETING)),
        ],
    ))
    add(Scenario(
        "a catalogue listing the slots in another order publishes them in the same order",
        sh_updated, host="two-slots", installs=[U("r2.0.0", "sh-update")], ran=["sh-update", SK_NAME],
        order=["sh-update", SK_NAME],
        digest="update", rename=True,
        then=[
            Phase(sh_updated, label="the catalogue lists fixturesh first", host="two-slots-sorted",
                  ran=["sh-update", SK_NAME], order=["sh-update", SK_NAME], digest="update"),
            Phase(bare, label="the catalogue lists fixturesh first, the update removed", host="two-slots-sorted",
                  actions=[("remove", "sh-update")], ran=[FRESH, SK_NAME], order=[FRESH, SK_NAME], digest="bare"),
            Phase(bare, label="the catalogue lists fixturesk first, the update still removed", host="two-slots",
                  ran=[FRESH, SK_NAME], order=[FRESH, SK_NAME], digest="bare"),
        ],
    ))
    shipped_changed = [R(SH, "2.0.0", "U", ACTIVE, SEL, None), sh_1_superseded, sk_ok]
    add(Scenario(
        "changed SDL in a newer copy changes the digest, and only its own content does",
        bare, host="two-slots", ran=[FRESH, SK_NAME], order=[FRESH, SK_NAME], digest="base",
        differs=[("base", "extra"), ("base", "described"), ("extra", "described")],
        then=[
            Phase(shipped_changed, label="one type added", actions=[("install", "sdl-changed", "sh-update")],
                  ran=["sh-update", SK_NAME], order=["sh-update", SK_NAME], digest="extra"),
            Phase(shipped_changed, label="that type described otherwise",
                  actions=[("replace", "sh-update", "sdl-changed-description")], ran=["sh-update", SK_NAME],
                  order=["sh-update", SK_NAME],
                  digest="described"),
            Phase(shipped_changed, label="an update with the baseline's SDL again, at the same release",
                  actions=[("replace", "sh-update", "r2.0.0")], ran=["sh-update", SK_NAME],
                  order=["sh-update", SK_NAME], digest="base"),
        ],
    ))
    od_ok, unknown_ok = R(OD, "1.0.0", "U", ACTIVE, SEL, None), R(UNKNOWN, "1.0.0", "U", ACTIVE, SEL, None)
    add(Scenario(
        "an extra ordinary provider changes the digest, and leaves the shipped position alone",
        bare, host="two-slots", ran=[FRESH, SK_NAME], order=[FRESH, SK_NAME], digest="base", rename=True,
        differs=[("base", "with-od"), ("with-od", "with-od-unknown"), ("base", "unknown-only")],
        then=[
            Phase(bare + [od_ok], label="an ordinary provider added", actions=[("install", "ordinary", "first")],
                  ran=[FRESH, SK_NAME, "first"],
                  order=[FRESH, SK_NAME, "first"], digest="with-od", serves=("fixtureOdInfo", OD_GREETING)),
            # fixtureod sorts before fixturesh, so an update taken into the ordinary group by identifier
            # would move before it; it stays where the shipped identities are.
            Phase(sh_updated + [od_ok], label="the shipped update added beside it",
                  actions=[("install", "r2.0.0", "sh-update")], ran=["sh-update", SK_NAME, "first"],
                  order=["sh-update", SK_NAME, "first"],
                  digest="with-od", managed=True),
            Phase(sh_updated + [od_ok, unknown_ok], label="a second ordinary provider added",
                  actions=[("install", "unknown", "second")], ran=["sh-update", SK_NAME, "first", "second"],
                  order=["sh-update", SK_NAME, "first", "second"],
                  digest="with-od-unknown"),
            Phase(sh_updated + [unknown_ok], label="the first ordinary provider removed",
                  actions=[("remove", "first")], ran=["sh-update", SK_NAME, "second"],
                  order=["sh-update", SK_NAME, "second"], digest="unknown-only"),
            Phase(bare, label="everything removed", actions=[("remove", "sh-update"), ("remove", "second")],
                  ran=[FRESH, SK_NAME], order=[FRESH, SK_NAME], digest="base"),
        ],
    ))

    # -- Restart ------------------------------------------------------------------------------
    # Every start recomputes from what is in the roots and the host: removing an update rolls
    # back (there is no anti-rollback), a host shipped with a different baseline is another
    # catalogue over the same data, and none of it adds to a grant made before.
    update_1_5 = R(SH, "1.5.0", "U", ACTIVE, SEL, None)
    add(Scenario(
        "a restart after an update is removed recomputes, and grants nothing to a grant held before",
        [update_1_5, bundle, od_ok], installs=[U("r1.5.0", "update"), U("ordinary", "first")],
        ran=["update", "first"], serves=("fixtureShInfo", UPDATE_GREETING), rename=True,
        then=[
            Phase([healthy_bundle, od_ok], label="the update removed", actions=[("remove", "update")],
                  ran=[FRESH, "first"], serves=("fixtureShInfo", BASE_GREETING),
                  clients=[(1, "fixtureOdInfo", "served")]),
            Phase([healthy_bundle], label="the ordinary provider removed", actions=[("remove", "first")],
                  ran=[FRESH], absent_fields=["fixtureOdInfo"], no_capabilities=["fixtureod:read", "fixtureod:control"],
                  clients=[(1, "fixtureOdInfo", "unpublished")]),
            Phase([healthy_bundle, od_ok], label="the ordinary provider installed again",
                  actions=[("install", "ordinary", "first")], ran=[FRESH, "first"], capabilities=["fixtureod:read"],
                  # The credential made while it was absent holds no fixtureod capability, and is told so.
                  clients=[(3, "fixtureOdInfo", "denied"), (1, "fixtureOdInfo", "served")]),
            Phase([update_1_5, bundle, od_ok], label="the update installed again: nothing rolled it back for good",
                  actions=[("install", "r1.5.0", "update")], ran=["update", "first"],
                  serves=("fixtureShInfo", UPDATE_GREETING)),
        ],
    ))
    add(Scenario(
        "a restart under a host with a changed baseline recomputes, and an older host recomputes it back",
        [update_1_5, bundle], installs=[U("r1.5.0", "update")], ran=["update"],
        serves=("fixtureShInfo", UPDATE_GREETING),
        then=[
            Phase([R(SH, "1.7.0", "B", ACTIVE, SEL, "selected-with-refusals"), R(SH, "1.5.0", "U", REJECTED, NOT, "older-than-bundled")],
                  label="the host's designated baseline is release 1.7.0, above the update", host="slot-baseline-1.7.0",
                  ran=[FRESH], serves=("fixtureShInfo", BASE_GREETING)),
            Phase([update_1_5, bundle], label="the older host again: the update outranks its baseline once more",
                  host="slot", ran=["update"], serves=("fixtureShInfo", UPDATE_GREETING)),
        ],
    ))
    refused_update = R(SH, "2.0.0", "U", REJECTED, NOT, "quarantine-refused", "the injected verdict refuses it")
    refused_od = R(OD, "1.0.0", "U", REJECTED, NOT, "quarantine-refused", "the injected verdict refuses it")
    falls_back = R(SH, "1.0.0", "B", ACTIVE, SEL, "selected-with-refusals")
    accepted = [sh_2, sh_1_superseded, od_ok]
    add(Scenario(
        "a restart under a changed assessment verdict recomputes both ways, and remembers neither",
        accepted, installs=[U("r2.0.0", "update", quarantined=True), U("ordinary", "first", quarantined=True)],
        env={"KOINE_FIXTURE_ASSESSMENT": "accept"}, quarantine=True, ran=["update", "first"],
        serves=("fixtureShInfo", UPDATE_GREETING),
        then=[
            Phase([refused_update, falls_back, refused_od], label="the verdict now refuses", quarantine=True,
                  env={"KOINE_FIXTURE_ASSESSMENT": "refuse"}, ran=[FRESH], serves=("fixtureShInfo", BASE_GREETING),
                  absent_fields=["fixtureOdInfo"], no_capabilities=["fixtureod:read", "fixtureod:control"]),
            Phase(accepted, label="the verdict accepts again: the refusal was not kept", quarantine=True,
                  env={"KOINE_FIXTURE_ASSESSMENT": "accept"}, ran=["update", "first"],
                  serves=("fixtureShInfo", UPDATE_GREETING), capabilities=["fixtureod:read"],
                  # The grant made while the verdict refused never held the ordinary provider's capability.
                  clients=[(2, "fixtureOdInfo", "denied")]),
            Phase([refused_update, falls_back, refused_od], label="and refuses once more", quarantine=True,
                  env={"KOINE_FIXTURE_ASSESSMENT": "refuse"}, ran=[FRESH], serves=("fixtureShInfo", BASE_GREETING)),
        ],
    ))
    add(Scenario(
        "a per-user root the host cannot read stops startup, and giving it back recovers exactly",
        [healthy_bundle, od_ok], installs=[U("ordinary", "first")], ran=[FRESH, "first"],
        serves=("fixtureShInfo", BASE_GREETING),
        then=[
            Phase([], label="the per-user root unreadable", actions=[("chmod", "providers", 0)],
                  start_fails="permission"),
            Phase([healthy_bundle, od_ok], label="the per-user root given back",
                  actions=[("chmod", "providers", 0o700)], ran=[FRESH, "first"],
                  serves=("fixtureShInfo", BASE_GREETING)),
        ],
    ))
    return s


OWNED_REASONS = {
    "principal-collision", "principal-class-missing", "principal-class-invalid", "load-failed",
    "descriptor-mismatch", "invalid-sdl", "missing-prefix", "missing-capability-owner", "manifest-collision",
    "start-failed", "not-approved", "framework-incompatible", "signature-refused", "quarantine-refused",
}

PENDING = []

# The two whose SDL the core refuses load and register their factory, so they never start:
# the update built from the same source with a good schema is the control for `start`.
TWINS = {"sh-update-bad-sdl": "sh-update", "sh-update-outside-prefix": "sh-update"}

harness.main(scenarios, OWNED_REASONS, PENDING, __doc__, twins=TWINS)
