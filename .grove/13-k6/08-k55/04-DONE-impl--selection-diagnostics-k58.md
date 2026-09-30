# selection-diagnostics-k58

## Goal

Publish selection to management clients and the native window.
`KoineManagement.providers` reports every candidate and every synthetic slot row
with the additive fields. The extension-host core + desktop conformance profile
stands beside the preserved old-host profile.

## Context

- `docs/specs/machine.md`, "Candidate diagnostics and schema identity".
- The loader's candidate reports from `provider-selection-k57`.

## Done when

- `KoineProviderStatus` gains nullable fields: `candidateId`, `origin`
  (`KoineProviderOrigin`), `selection` (`KoineProviderSelection`),
  `selectedCandidateId` and `reason`. Every existing field and
  `KoineProviderState` value keeps its meaning.
- Rows are ordered by provider, origin and candidate ID, with synthetic rows last.
- The synthetic `missing-bundled`, `no-eligible-candidate` and
  `catalogue-invalid` rows follow the spec. `(unknown)` stays distinct from a
  real provider named `unknown`.
- Existing trust and compatibility failures gain stable reasons. The cascade
  reports `missing-capability-owner`.
- The native window groups copies by identity. It shows physical origin,
  selection, and every refused or ignored update beside the running version. No
  success indication conceals a refusal.
- Management fields remain denied without `koine:manage`.
- The design contract for the management additions is updated, and the served
  schema matches it.
- G tests cover the published rows over substituted candidate reports.
- Conformance keeps the old-host core + desktop profile unchanged. It adds an
  extension-host core + desktop profile with the expanded management schema,
  pinning candidate versions separately from SDL and digest. An omitted required
  provider fails the profile rather than shrinking it.

## Notes

A client learns new coordinates by introspection. The contract version stays
`koine-desktop/1`. Adding these fields changes the digest, as designed.

## Decisions (running log)

**The loader already carried everything; this leaf publishes it.** `provider-selection-k57`'s reports, stable reasons, synthetic rows and ordering were complete, so the work here is the GraphQL fields (`CoreSchema`, `CoreFields`), the window, the design contract and the profiles. Two mutations were watched to fail the new G tests: dropping `origin` from the served object (6 issues) and putting synthetic rows first (14).

**Two design files, not one edited.** `docs/design/desktop-schema.graphql` is unchanged and is the old-host profile's SDL; `desktop-schema-extension-host.graphql` is that file plus exactly the five nullable fields and two enums, and a test names any other difference. The core's served SDL is the extension-host one. Names the released file keeps: the README, spec and client guide point at both.

**A profile is a JSON file pinning candidates apart from the SDL** (`docs/design/profiles/`, checked by `ConformanceProfile` in `KoineConformanceCheck`, wired to `KoineConformance --profile … --providers …`). The set is explicit: a required provider that is not served fails, and so does an unlisted row; an extension-host profile also needs the candidate fields on every row and a `SELECTED` row naming itself. Extra pinned keys are compared exactly, and a JSON null means the served field must be null.

**An empty installation is `missing-bundled`, not `no-eligible-candidate`.** The spec's "otherwise" applies only when the designated bundle is present but no candidate passed. The G tests cover both (`aPresentButRefusedBundleLeavesOneNoEligibleCandidateRow` uses an unsigned host). No test asserted the wrong reading; only my first draft did.

**The window groups by identity and never shows a plain success beside a refusal.** `ManagedProviderGroup` (in the client library, so it is tested without SwiftUI) leads with the `SELECTED` row, even a failed one, and lists every other row under it with physical origin, selection and stable reason. A running copy with anything refused beside it reads "Active, with refusals". `provider-<id>` stays the accessibility identifier and the text still contains "Active", which `vm-verify-accessibility.sh` reads.

**`task compat` now holds the newer host to the extension-host profile**, with an independently built released desktop provider bundled: schema, digest, the pinned candidate, and two controls (a design text with one description changed; a profile pinning another release). The old-host profile has no host to run against here (the released host cannot take a stand-in bundled root), so it is covered by the unchanged-file test and remains the V run's (`selection-acceptance`'s old-host row).

**Not done here, by design.** No notarized-application VM run: `task conformance` was exercised through its capture mode over a real independent host's introspection and providers (controls all red, final check green), which is not new VM evidence. The window's appearance was not observed in a VM; its grouping is tested at the client library. Both remain for the leaves that own VM acceptance.
