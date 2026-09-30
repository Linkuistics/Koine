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
