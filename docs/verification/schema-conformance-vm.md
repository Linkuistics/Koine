# Whole-contract schema conformance on the notarized build

The "Public GraphQL API" seam of `docs/specs/machine.md`, checked as a whole for
the first time: the schema the **notarized** `Koine.app` actually serves —
composed with the desktop provider it `dlopen`s out of `Contents/PlugIns` —
against `docs/design/desktop-schema.graphql`, by type, field, argument,
nullability, default, deprecation and description. Every stage before this one
served the fields it made real and left the rest of the design SDL as a target;
this is where the target comes due.

## Procedure

```sh
task app && task app:notarize   # on the host; .build/app/Koine.app, stapled
task conformance                # scripts/vm-verify-conformance.sh
```

The clean clone, the transcript (`.build/vm-verify/conformance-<timestamp>.log`),
`KOINE_VM_KEEP=1` and the TestAnyware workarounds are those of
[resident-app-vm.md](resident-app-vm.md). Nothing runs the application on the
host: introspecting means launching Koine, so the response is captured in the
guest and brought back, and the comparison is text against text
(`Tools/Conformance`).

| Step | How | Expectation checked |
|---|---|---|
| The bundle under test | `xcrun stapler validate`, on the host before a clone is spun and again on the installed copy | both pass; an unstapled bundle refuses the run rather than quietly checking a different build |
| Composition | `koineManagement.providers` | `desktop` is `ACTIVE`, so the schema being checked is the composed one and not the core alone |
| Capture | `scripts/vm-verify-introspect.py`, the query `KoineConformance --print-query` prints | HTTP 200, no `errors`, and `Koine.schemaDigest` read over the same connection in the same session |
| Control | four mutated copies of the design SDL | the check goes **red** on each, and says which half caught it |
| Digest | the design file, canonically printed, against `Koine.schemaDigest` | equal — and this half is what sees declared order |
| Report | the introspected schema against the design file | empty |

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

## What this run found

One thing, and it is the served schema's rather than the contract's.
`Providers/DesktopProvider/schema.graphql` puts the description the spec gives
`DesktopFocusReceipt.ref` — "The submitted target, under the mutation's control
authority" — on the **type**, and states the type's own fact — "it does not
expose a window's read fields" — nowhere. A client's generated types carry the
first and not the second.

Three other differences were reconciled rather than repaired, because a reader of
`docs/specs/machine.md` would have predicted each served shape:

| Coordinate | Reconciled how |
|---|---|
| `Koine.schemaDigest` | the design SDL gains the served description; the spec's "Schema digest" already calls it an equality token clients compare and do not recompute |
| `KoineManagement.osPermissions` | the design SDL gains the served description; the spec already states that a read cannot trigger an OS consent dialog |
| `Mutation.desktopFocusWindow` | the design SDL takes the served text, which is the spec's own row for that coordinate ("focus exactly this target or report failure", "never focus a substitute"); the mutation-preflight sentence it carried is a property of every mutation, stated under "Mutation preflight and revocation", not of this one field |

The design SDL also now declares its root fields in **composition order** — the
core's own, then the bundled provider's — because the digest is taken over a text
that keeps declared order and composition is what fixes it.

The remaining difference is `desktop-receipt-descriptions-k48`'s, cut with the
human's decision recorded in it: both sentences return, each where the spec puts
them. Until it lands, `task conformance` reports two differences (the type's
description and `ref`'s), and
`DesignContractConformanceTests.theServedSchemaIsTheDesignContract` carries them
as a `withKnownIssue` naming that leaf — Swift Testing fails a known issue that
stops happening, so the suite says when the wrapper can go.

## What this does and does not show

- **The fast guard and the real bundle agree exactly.** `DesignContractConformanceTests`
  composes `Providers/DesktopProvider/schema.graphql` in process as the bundled
  provider and gets the digest **`19615f51…`** — the same value the notarized
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
- **The digest recorded below belongs to the pre-repair bundle.**
  `desktop-receipt-descriptions-k48` changes two descriptions and therefore the
  digest; it re-notarizes and re-runs this check, and updates this document so
  the handoff and every leaf after it cite exactly one value.

## Evidence

Run of 2026-09-20, transcript `conformance-20260920T213041.log`, against
`.build/app/Koine.app` version **0.1.0**, signed `Developer ID Application:
Antony Blakey (TA43A4RUP3)`, notarized and stapled (submission
`f50a0c8d-eaf4-4094-90fd-a7cd02b70fc6`). VM: clone of
`testanyware-golden-macos-tahoe`, macOS 26.5 (25F71), arm64. Contract version
`koine-desktop/1`. Introspection response 38601 bytes; the canonical served SDL
it prints is 189 lines (`.build/conformance/served.graphql`).

**`Koine.schemaDigest` served by this build:
`19615f511f244fcc0ae9f9de5f9db3af8fc595ee6816575f0bf265d083186f7f`** — superseded
by `desktop-receipt-descriptions-k48`.

```
== The bundled desktop provider is ACTIVE, so the composed schema is the one being checked
{"data":{"koineManagement":{"providers":[{"provider":"desktop","version":"1.0.0",
  "schemaVersion":"1.0.0","state":"ACTIVE","diagnostic":null}]}}}

== Capture the introspection response, as a code generator would ask for it
{"status": 200, "bytes": 38601, "path": "/Users/admin/introspection.json", "errors": [],
 "contractVersion": "koine-desktop/1",
 "schemaDigest": "19615f511f244fcc0ae9f9de5f9db3af8fc595ee6816575f0bf265d083186f7f"}

== The positive control: a mutated contract must turn this check red
  (the unmutated contract reports 2 difference(s); each control is judged against that)
  a description removed: red, caught by the report (3 against 2) and the digest
  a nullability marker removed: red, caught by the report (3 against 2) and the digest
  an argument default introduced: red, caught by the report (3 against 2) and the digest
  two root fields transposed: red, caught by the digest

== The contract as it stands
digest of docs/design/desktop-schema.graphql, canonically printed: ee17dfd1…
digest Koine served (Koine.schemaDigest):                          19615f51…
  they differ: the design file is not the schema Koine hashed.

2 difference(s) between the served schema and docs/design/desktop-schema.graphql:

DesktopFocusReceipt — description
    served: "The submitted target, under the action's desktop:control."
    design: "Control-authorized output; it does not expose read-protected window state."
DesktopFocusReceipt.ref — description
    served: none
    design: "The submitted target, under the mutation's control authority."
```

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
