# native-reference-acquisition-k143


## Goal
Resolve the finite public-API question: can flat catalog enumeration acquire
and consume the exact original long file/directory reference beyond the
tested constructor boundary? Produce a cheap diagnostic and obtain Antony's
reaction to its observed result; ship no provider code.

## Context

The complete charter and SDK/source disposition are in
`docs/verification/long-action-route.md#internal-native-reference-investigation`.
Read k141's inherited retained-route obligations, k142's committed source
disposition, k134's prototype report/source/raw results and the reviewed k132
boundary. The public Files.h comment requires kFSIterateFlat for bulk iteration;
its FSResolveNodeID input is a native Carbon volume/UInt32 catalog node pair,
not a cast APFS inode. SDK and guest versions are separate evidence subjects.

Antony authorized continued internal investigation, including a focused
disposable-guest diagnostic, under the original bytes/cases/privacy posture.
This is not another broad survey or replay of the complete k134 action matrix.

## Done when

- Build one minimal diagnostic against verified public SDK declarations and
  execute it in one disposable macOS guest, using the ordinary signed-helper
  posture from k134. Record actual OS/build, SDK/compiler, architecture,
  filesystem, signing/entitlements, volume valid/capability bits and source/
  binary digests. No protected Documents/Desktop tree, TCC reset/approval,
  private policy, special entitlement or host document access.
- Create eight independent fixtures by mkdirat/openat: file and directory at
  each of 900, 1023, 1024 and 1500 original UTF-8 bytes, excluding NUL. Use valid
  ASCII components. Start from a short fixture-root FSRef, open only flat
  iterators, match returned names exactly and descend via the returned child
  FSRef. No long path constructor/conversion silently advances the walk.
- Preserve short same-object constructor/comparison, same-parent decoy and
  completed missing-name iteration controls. Record every iterator/bulk/native
  consumer status, actual count, name, containerChanged, cumulative original
  byte length and first failed stage. Process valid returned entries with
  errFSNoMoreItems. Error, changed contents, unknown cause or an exhausted bound
  means failed/incomplete, not absent. FSRef bytes stay opaque.
- Bound each subject to 32 selected-directory levels, eight entries per batch,
  four batches per fixture directory and one live iterator. Keep fixture
  directories small and close every iterator/descriptor on success/failure.
  Do not grow the corpus or scan the volume to work around failure.
- Cap the whole diagnostic at two builds, two collection attempts of the same
  fixed corpus and one instrumentation repair. Preserve every attempted run's
  raw records and repair reason; never combine runs into a cleaner observation.
  Use an external 30-second per-native-case watchdog with at most five seconds
  of termination grace. Cap clone-start request through guest teardown at
  15 elapsed minutes. A blocked call, exhausted cap or uncorrected short control
  ends incomplete, with no alternate guest/API route or automatic later retry.
- For actually acquired references, independently record FSGetCatalogInfo,
  FSCompareFSRefs, reference-based item flags/content type and exact-item
  preferred-handler lookup. Verify the exact API/declaration before use; do not
  invent flags, default booleans or no-type/no-handler results. Test
  FSResolveNodeID only with successful native catalog volume/node outputs and
  compare the result to the enumerated reference. Label this as consumption,
  not an independent node-ID acquisition route. Never truncate st_ino or use
  undefined descriptor-derived 32-bit IDs.
- Save reproducible helper/source, complete bounded raw records and a concise
  result report linked from the route evaluation. Distinguish native outcomes
  from source inference, diagnostic controls from working action acceptance,
  and subject-local no-dialog evidence from all protected-read behavior. Stop
  the guest. Present the result for Antony's reaction and record it here.
- Submit no application/Finder action or production content read, register no
  new app copy and change no served spec/SDL/version. No shortened identity
  spelling, handmade reference, copy substitution or native fact/receipt rule
  change. A positive acquisition result leaves all unmeasured route stages open.

## Notes

One native diagnostic is commissioned. A tooling or short-control failure is
recorded; at most one proven instrumentation defect may be repaired within the
aggregate limits above, without changing platform, API route, process/privacy
posture or subjects. Exhaustion returns incomplete. Do not add another
probe/research series. A remaining gap is consumed
by long-action-route-k144; do not retire k141 or cut k128's final review here.
Production implementation and full native/binary acceptance remain planning's
work. The probe's throwaway nature does not relax evidence/provenance.
