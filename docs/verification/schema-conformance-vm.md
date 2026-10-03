# Whole-contract schema conformance

The "Public GraphQL API" seam of `docs/specs/machine.md`, checked as a whole: the
schema a host actually serves, composed with the providers it bundles, against a
design SDL, by type, field, argument, nullability, default, deprecation and
description. The schema Koine serves is that file exactly. `task conformance` does
it for three profiles, each against the host that serves it.

## Profiles

A profile ([`docs/design/profiles/`](../design/profiles/)) is a design SDL and,
pinned separately from it, the exact provider candidates the host runs: an
identical schema and digest cannot say which binary ran.

| Profile | Design SDL | Candidates pinned | Served by |
|---|---|---|---|
| `core-desktop-old-host` | `desktop-schema.graphql`, unchanged since 0.1.0 | `desktop` 1.0.0 / 1.0.0, `ACTIVE` | the **released** v0.1.0 server, built from its own sources, with the desktop provider built from that release bundled |
| `core-desktop-extension-host` | `desktop-schema-extension-host.graphql` | `desktop` 1.0.0 / 1.0.0, `ACTIVE`, `BUNDLED`, `SELECTED` | this tree's headless host, desktop its only bundled provider |
| `core-desktop-workspace-extension-host` | `desktop-workspace-schema-extension-host.graphql`: the workspace design restricted to the implemented roots and the types they reach, verbatim | `desktop` and `workspace`, each 1.0.0 / 1.0.0, `ACTIVE`, `BUNDLED`, `SELECTED` | the **signed** `Koine.app`, in a clean TestAnyware VM |

Why each is served where it is. The signed application bundles workspace now, and a
bundle cannot be altered without breaking its signature, so a VM can serve only the
third. The first two need hosts that run alone: this tree's for the extension host,
and the **released** host for the old one, because only a host that predates the
candidate fields serves the original management schema. The released host's own
headless driver takes a data directory alone and so rejected the released desktop
provider as reserved (`desktop is reserved.`, seen before the fix);
`scripts/compat-released-host-main.swift` is that driver plus the bundled root the
released application has, copied over the driver in the extracted released tree by
`scripts/build-baseline-host.sh`. The released server code is untouched, and the
digest it serves is the released one.

The workspace profile's design file keeps to what is implemented. It is the
workspace design restricted to the implemented roots and the types they reach, never
reworded: `DesignContractConformanceTests` compares it with the desktop design plus
the complete workspace design and demands that the only differences are the roots
not yet implemented and the two types only they reach, so a root that lands is added
verbatim and a missing coordinate is always a difference. The same test file proves
the provider's own SDL, composed with the core through the engine, is that design
file, declared order included.

The two extension-host design files and the workspace profile's carry
`KoineManagement.capabilityDisclosures` and `KoineCapabilityDisclosure`
([capability disclosures](../specs/machine.md#capability-disclosures)); the
old-host design file does not, and `ConformanceProfileTests` holds the difference
to the candidate fields and exactly these two coordinates.

## Procedure

```sh
task app                        # on the host; .build/app/Koine.app, signed (notarization is not required)
task conformance                # scripts/conformance.sh: the three profiles
task conformance:headless       # the two profiles a headless host serves, no VM
task conformance:vm             # scripts/vm-verify-conformance.sh: the signed application's profile
```

The clean clone, the transcript (`.build/vm-verify/conformance-<timestamp>.log`),
`KOINE_VM_KEEP=1` and the TestAnyware workarounds are those of
[resident-app-vm.md](resident-app-vm.md). Nothing runs the application on the
host: introspecting means launching Koine, so the response is captured in the
guest and brought back, and the comparison is text against text
(`Tools/Conformance`). The two headless profiles are served over loopback HTTP by
hosts that run alone (`scripts/conformance-capture-headless.py`).

| Step | How | Expectation checked |
|---|---|---|
| The bundle under test | `codesign --verify --deep --strict`, on the host before a clone is spun and again on the installed copy | both pass; whether the ticket is stapled is recorded, and required only under `KOINE_CONFORMANCE_REQUIRE_NOTARIZED=1` |
| Composition | `koineManagement.providers` | `desktop` and `workspace` are `ACTIVE`, so the schema being checked is the composed one and not the core alone |
| Capture | `scripts/vm-verify-introspect.py`, the query `KoineConformance --print-query` prints | HTTP 200, no `errors`, and `Koine.schemaDigest` read over the same connection in the same session |
| Design controls | mutated copies of the design SDL (`scripts/conformance-lib.sh`) | the check goes **red** on each, and says which half caught it |
| Pin controls | mutated copies of the profile | the check goes **red** on each, naming the profile problem |
| Digest | the design file, canonically printed, against `Koine.schemaDigest` | equal — and this half is what sees declared order |
| Report | the introspected schema against the design file | empty |
| Pin | the served `koineManagement.providers` rows against the profile | every pinned candidate served as pinned, and no row the profile did not expect |

## What a green run is, and why it is two things

**The digest half.** `KoineCore/CanonicalSDL.swift` is the one implementation of
the spec's "Schema digest" rule; `Koine.schemaDigest` is computed with it, and so
is the digest of the design file. So `digest(design) == Koine.schemaDigest` says
the design file *is* the schema Koine hashed, and it needs nothing from
introspection — including the declared order of fields, which the introspected
text cannot carry at all.

**The report half.** The same claim from the public seam, and the one that says
*where* when it fails. It is made against a schema rebuilt from the introspection
response and printed through that same canonical printer, so a difference is a
difference in the documents rather than in how they were printed.

Neither alone would do, and together they cannot be satisfied by a lossy
capture: anything introspection drops that the design declares is reported as a
difference, and anything the design lacks that Koine serves moves the digest.

**Three limits of the seam** were measured against a running engine rather than
read out of the library, and are recorded in the spec's "Public GraphQL
contract" and pinned by `SchemaConformanceTests`: `__Type.fields` and
`inputFields` come back **sorted by name**; `__InputValue.isDeprecated` is served
as null against a non-null declaration, so selecting it fails the position; and
an **input-object field's default** is not reported, while an argument's is.
Koine's contract exercises none of the three, and the introspection query a
standard code generator sends is unaffected.

## Where the design SDL follows the served schema

**`DesktopFocusReceipt` states each fact where the spec puts it.** The type
carries its own ("Control-authorized output; it does not expose read-protected
window state.") and `DesktopFocusReceipt.ref` the one the spec gives the field
("The submitted target, under the mutation's control authority."), so a
client's generated types carry both. `Providers/DesktopProvider/schema.graphql`
and the design SDL agree on both.

**Three coordinates carry the served text**, because a reader of
`docs/specs/machine.md` would predict each served shape:

| Coordinate | Why the design SDL reads as it does |
|---|---|
| `Koine.schemaDigest` | the design SDL carries the served description; the spec's "Schema digest" calls it an equality token clients compare and do not recompute |
| `KoineManagement.osPermissions` | the design SDL carries the served description; the spec states that a read cannot trigger an OS consent dialog |
| `Mutation.desktopFocusWindow` | the design SDL takes the served text, which is the spec's own row for that coordinate ("focus exactly this target or report failure", "never focus a substitute"); mutation preflight is a property of every mutation, stated under "Mutation preflight and revocation", not of this one field |

The design SDL also declares its root fields in **composition order** — the
core's own, then the bundled provider's — because the digest is taken over a text
that keeps declared order and composition is what fixes it.

## What this does and does not show

- **The fast guard and the real bundle agree exactly.** `DesignContractConformanceTests`
  composes `Providers/DesktopProvider/schema.graphql` in process as the bundled
  provider and gets the digest **`ee17dfd1…`** — the same value the notarized
  application, having `dlopen`ed its own sealed provider bundle in a VM, served.
  That is what makes the in-package check usable as a first line: the shipped
  bundle's SDL is the file in the tree.
- **The controls are the reason a clean half can be believed.** A difference
  report that finds nothing reads the same whether the schemas agree or the
  comparison never reached them. Each control mutates one class the check claims
  to report and is watched to go red, and the transcript names which half caught
  it — the transposed pair is caught by **the digest alone**, which is the
  demonstration that declared order is not in the introspected text.
- **This is not a Gatekeeper run.** The clone is the ordinary golden, whose
  assessments are disabled (`override=security disabled` in the transcript), and
  the bundle is installed unquarantined. What is under test here is the schema,
  and the bundle is the notarized, stapled one; the enforcing posture and the
  quarantined first launch are [notarized-release-vm.md](notarized-release-vm.md)'s
  and are not re-established here.
- **It does not show a per-user provider's contribution.** Only the bundled
  `desktop` provider is loaded, which is what the shipped contract is. A schema
  composed with a third-party provider is that provider's to check, through the
  same `task conformance` against its own SDL.
- **There is one digest, and it is the one below.** Any change to the served
  schema moves it, and this check is then re-run against the new bundle; citing
  a digest an earlier bundle served is the failure this rule exists for.

## Evidence

**Run of 2026-09-30 (launch-contract):** the three profiles, against the schemas
their hosts served, with the digests, the candidates and every control's result, are
recorded in [launch-contract.md](launch-contract.md). The VM run for the signed
application's profile is `conformance-20260930T230050.log`, with desktop and
workspace both `ACTIVE`, `BUNDLED` and `SELECTED`, digest
`a56a3387c7bef91758e31713fd9a7f632855c2b3a9eaaf5f8e5cce1b66d49aea` equal to the
design file's, no differences. The original 0.1.0 run follows, made against the
original file and unchanged.

Run of 2026-09-20, transcript `conformance-20260920T214349.log`, against
`.build/app/Koine.app` version **0.1.0**, signed `Developer ID Application:
Antony Blakey (TA43A4RUP3)`, notarized and stapled (submission
`ed3ef82e-f0dc-479d-9e99-65125e6f2b3e`). VM: clone of
`testanyware-golden-macos-tahoe`, macOS 26.5 (25F71), arm64. Contract version
`koine-desktop/1`. Introspection response 38677 bytes; the canonical served SDL
it prints is 192 lines (`.build/conformance/served.graphql`).

**`Koine.schemaDigest` served by this build:
`ee17dfd16a7d00079a9dd1e7523954dba8ced0052096e75d2dc7bdaacb5e2baf`** — the one
value other documents cite.

```
== The bundled desktop provider is ACTIVE, so the composed schema is the one being checked
{"data":{"koineManagement":{"providers":[{"provider":"desktop","version":"1.0.0",
  "schemaVersion":"1.0.0","state":"ACTIVE","diagnostic":null}]}}}

== Capture the introspection response, as a code generator would ask for it
{"status": 200, "bytes": 38677, "path": "/Users/admin/introspection.json", "errors": [],
 "contractVersion": "koine-desktop/1",
 "schemaDigest": "ee17dfd16a7d00079a9dd1e7523954dba8ced0052096e75d2dc7bdaacb5e2baf"}

== The positive control: a mutated contract must turn this check red
  (the unmutated contract reports 0 difference(s); each control is judged against that)
  a description removed: red, caught by the report (1 against 0) and the digest
  a nullability marker removed: red, caught by the report (1 against 0) and the digest
  an argument default introduced: red, caught by the report (1 against 0) and the digest
  two root fields transposed: red, caught by the digest

== The contract as it stands
digest of docs/design/desktop-schema.graphql, canonically printed: ee17dfd16a7d…
digest Koine served (Koine.schemaDigest):                          ee17dfd16a7d…
  they agree: the design file is exactly the schema Koine hashed.

The served schema matches docs/design/desktop-schema.graphql exactly.

CONFORMANT: the schema Koine serves is docs/design/desktop-schema.graphql.
```

The baseline the controls are judged against is read from the unmutated
contract rather than assumed, so a conformant contract makes every control prove
itself against **0** differences. The transposed pair is caught by the digest
alone — the standing demonstration that declared order is not in the
introspected text.

## Tooling note

`scripts/vm-verify-introspect.py` writes the response to a file in the guest and
prints one summary line; the host downloads the file. A full introspection answer
is 38 kB, far more than the agent's exec channel carries reliably, and a
truncated capture would look exactly like a schema that lost fields.
`Koine.schemaDigest` is read in the same script over the same connection, so the
digest the design file is checked against is the digest of the schema that
answered, not of a later launch.

`KOINE_CONFORMANCE_CAPTURE=<file>` re-runs the comparison and the controls
against a capture already in hand, with no VM. It is for reading an earlier run's
evidence again; it produces none.
