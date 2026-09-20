# desktop-receipt-descriptions-k48

## Goal

Make the desktop provider serve the two `DesktopFocusReceipt` descriptions the
contract states, re-notarize, and leave `task conformance` green with one
recorded digest for the leaves that follow.

## Context

Cut by `schema-conformance-k40`, which ran the whole-contract check for the first
time and found exactly one difference the served schema could not be reconciled
to. The provider puts the **field's** fact on the **type** and states the type's
own fact nowhere:

```graphql
# Providers/DesktopProvider/schema.graphql, as served
"The submitted target, under the action's desktop:control."
type DesktopFocusReceipt { ref: Reference! }
```

`docs/specs/machine.md`, "Public GraphQL contract", puts one sentence on each:
the table row for `DesktopFocusReceipt.ref` is "The submitted target, under the
mutation's control authority", and the prose is "The receipt is a distinct output
type authorized by `desktop:control`; it does not expose a window's read fields."
A client's generated types currently carry the first fact and not the second.

**The human chose this shape** when `schema-conformance-k40` put the three
options to them, and `docs/design/desktop-schema.graphql` already states it:

```graphql
"Control-authorized output; it does not expose read-protected window state."
type DesktopFocusReceipt {
  "The submitted target, under the mutation's control authority."
  ref: Reference!
}
```

- The check and how to run it: `task conformance`
  (`scripts/vm-verify-conformance.sh`), and its evidence in
  `docs/verification/schema-conformance-vm.md`, which records the digest this
  leaf supersedes.
- `DesignContractConformanceTests.theServedSchemaIsTheDesignContract` is the same
  check without a VM. It currently wraps its expectation in `withKnownIssue`
  naming this leaf; **remove that wrapper** — Swift Testing fails a known issue
  that stops happening, so the suite will tell you when it is time.

## Done when

- `Providers/DesktopProvider/schema.graphql` carries both descriptions, each
  where the spec puts it, and nothing else about the provider changes.
- `DesignContractConformanceTests` passes with no `withKnownIssue` wrapper, and
  `task test` is green.
- A rebuilt, re-signed, re-notarized and stapled bundle (`task app`,
  `task app:notarize`, `task app:verify`) serves it: `task conformance` reports
  no differences **and** agreeing digests, with all four positive controls red.
- `docs/verification/schema-conformance-vm.md` records that run — its date,
  transcript and the **new** `Koine.schemaDigest` — and says plainly that the
  earlier digest belonged to the pre-repair bundle, so the handoff and the
  leaves after this one cite exactly one value.

## Notes

This is a description-only change to one SDL file, but it moves the schema
digest, which is why it runs **before** `contract-only-client-k41` rather than
after: every later leaf's evidence is written against one bundle and cites one
digest, and a repair landing after them would invalidate both.

Nothing here reopens the contract. The target text is already in the design SDL
and in the spec; this leaf only makes the server agree with them.

## Decisions (running log)

- The repair is exactly the two description strings on
  `Providers/DesktopProvider/schema.graphql`'s `DesktopFocusReceipt`, copied from
  `docs/design/desktop-schema.graphql`. Nothing else in the provider changes, and
  the type was reformatted from a one-liner into a block only because a field
  description needs a line of its own — `CanonicalSDL.text` sorts types by name
  and keeps fields in declared order, so neither the reformat nor where the type
  sits in the file can move the digest.
- **The digest this leaf produces is predicted before the VM run**:
  `ee17dfd16a7d00079a9dd1e7523954dba8ced0052096e75d2dc7bdaacb5e2baf`, the digest
  of the canonically printed design file that `schema-conformance-k40` already
  recorded as *differing* from what the pre-repair bundle served. That is the
  point of the prediction: if the repaired bundle serves anything else, the
  change was not description-only, and the run says so rather than the document
  recording whatever came back.
- The prediction held: the re-notarized bundle (submission
  `ed3ef82e-f0dc-479d-9e99-65125e6f2b3e`) served
  `ee17dfd16a7d00079a9dd1e7523954dba8ced0052096e75d2dc7bdaacb5e2baf`, the design
  file's own digest, with **0** differences and all four controls red. So the
  repair was description-only in fact and not only in intent.
- **The `withKnownIssue` wrapper's scaffolding went with it, not just the
  wrapper.** The assertion outside it — that the two receipt differences were
  *exactly* what the known issue covered — existed to stop the wrapper hiding
  unrelated drift. With `found.isEmpty` asserted directly it would be a weaker
  restatement of the same claim, and a list of coordinates that must still be
  wrong, so it is gone rather than inverted.
- **No in-session reviewer was materialised, and the leaf-wide allowance is
  unspent.** The one claim worth doubting — that this change is description-only
  and lands the digest on the design file's value — is settled by two independent
  instruments rather than by judgment: the in-package
  `DesignContractConformanceTests` and the VM run, each asserting the digest
  equality, with the digest written down *before* either was run.
- `docs/verification/schema-conformance-vm.md` now reads as current state rather
  than as a first run plus a pending repair: the three reconciliations stay,
  because they are why the design SDL says what it says; the fourth difference is
  recorded as repaired; and `19615f51…` survives in exactly one sentence, the one
  that names it superseded. It is cited nowhere else in any live document —
  enumerated by extracting every hex-like token from `docs`, `README.md` and
  `.grove` and classifying each, with the instrument watched going red against a
  digest planted in `README.md`, the one file the enumeration otherwise found
  nothing in.
