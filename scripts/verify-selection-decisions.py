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

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import selection_harness as harness  # noqa: E402
from selection_harness import (  # noqa: E402
    ACTIVE, BASE_GREETING, FRESH, INCOMPATIBLE, NOT, REJECTED, SEL, SH, SK, UNAVAIL, UPDATE_GREETING,
    Alias, R, Scenario, U,
)

# --- The rows -----------------------------------------------------------------------

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


# The three claimants load and are refused after their factory ran, so none of them
# writes a `start` marker; the ordinary provider `od` is the same source without the defect.
TWINS = {"od-claim-sh": "od", "od-claim-input": "od", "od-describes-slot": "od"}

harness.main(scenarios, OWNED_REASONS, PENDING, __doc__, twins=TWINS)
