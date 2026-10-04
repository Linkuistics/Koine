# Native reference acquisition diagnostic (k143)

**Result: flat enumeration returns references, but native facts and continued descent fail beyond 1,023 bytes.** `FSOpenIterator` +
`FSGetCatalogInfoBulk` return names, counts and a reference at traversed levels, but a reference whose original path
exceeds 1,023 bytes is rejected by the tested consumers: `FSGetCatalogInfo` answers -43 and the Launch Services reference calls answer
-41, and `FSOpenIterator` on such a directory reference answers -43, so the walk cannot descend to the 1,500-byte
subjects. One signed throwaway helper, one disposable macOS 26.5 (25F71, arm64, APFS) guest. This is a diagnostic
of the acquisition seam only: not action or search acceptance, no application/Finder submission, no route selected,
no served spec/SDL/version changed. Charter: [route evaluation](long-action-route.md#internal-native-reference-investigation).

Raw records: [`native-reference-acquisition/results/`](native-reference-acquisition/results/) (`run1/` and
`run2/`, each with per-case JSONL, `driver-log.jsonl`, `guest-environment.txt`, before/after digests and an end
screenshot); helper [`probe.m`](native-reference-acquisition/probe.m), builder
[`build-native-reference-probe.sh`](../../scripts/build-native-reference-probe.sh), driver
[`vm-probe-native-reference.py`](../../scripts/vm-probe-native-reference.py).

## Setup

Fresh `testanyware` macOS clone, helper signed Team `TA43A4RUP3` with Koine's entitlements, launched as an
accessory app by `open -n`, no usage keys. Volume `/System/Volumes/Data`, `apfs`, `VOL_CAP_FMT_64BIT_OBJECT_IDS`
valid and set, persistent object IDs valid and set (capability words in `run*/volume.jsonl`). SDK 27.0, clang 21.0.0
(host). Helper digests are in each run's `guest-environment.txt`. No protected tree, TCC change, private policy or
host document was touched; no dialog is visible in either end screenshot. Eight fixtures were made with
`mkdirat`/`openat` (245-byte-or-less ASCII components) under a short `/Users/admin/k143/f<N>-<kind>` root; walks
started from one `FSPathMakeRef` of that short root and followed only returned child references. Bounds held
(at most 8 entries/batch, 4 batches, one iterator; 6 levels). Run 1 took 57 s and run 2 41 s of the 15 minutes; no
watchdog fired.

## What was observed (identical in both runs unless stated)

| Subject | Object path bytes | Enumeration to the object | Reference consumers on the returned object reference |
| --- | --- | --- | --- |
| file, directory | 900 | complete, exact name + decoy matched | `FSGetCatalogInfo` 0; same-bytes compare 0; decoy compare -1420; `LSCopyItemInfoForRef` 0; content type `public.plain-text` / `public.folder`; `LSGetApplicationForItem` 0; `FSResolveNodeID` from the catalog volume/node 0 and compares equal; directory iterated inside, `inner.txt` found |
| file, directory | 1,023 | same | same as 900 |
| file, directory | 1,024 | complete, exact name + decoy matched (a reference was returned) | `FSGetCatalogInfo` **-43**; `LSCopyItemInfoForRef`, `LSCopyItemAttribute` and `LSGetApplicationForItem` **-41**; `FSResolveNodeID` not attempted (no native volume/node pair); same-bytes compare 0, decoy compare -1420; directory: `FSOpenIterator` **-43** |
| file, directory | 1,500 | levels 1-4 (≤1,012 bytes) complete; level 5 (1,257/1,258 bytes) returned a matching child but `FSGetCatalogInfo` on it answered -43; run 1 stopped at that probe gate, while run 2 reached `FSOpenIterator` on that child **-43**, so no batch ran at level 6 | none reachable |

Short controls passed in both runs: component walk and whole-path `FSPathMakeRef` of the same short object
compare equal (0); the same-parent decoy compares different (-1420); iterating a short directory for an absent name
completed with `errFSNoMoreItems` and no match; every consumer succeeded on the short references (`TextEdit` as
handler). No `containerChanged` was set anywhere.

## Runs and the one repair

Run 1 ended both 1,500-byte walks at a probe-added `FSGetCatalogInfo` gate after descent (-43), so it never
reached `FSOpenIterator`. That gate was not part of the charter's walk; [`repair-reason.md`](native-reference-acquisition/results/repair-reason.md)
records the repair (status logged, walk continues). Run 2 used the repaired build and reached the first iterator
failure above. Both runs are retained; 900/1,023/1,024 agree item by item, and run 1's 1,500 stage is the gated
one. Two builds, two collections, one repair: the cap is spent.

## Reading, and what stays open

- **Source-inferred vs native.** The failure point is the reference's original byte length (1,023 pass, 1,024
  fail, 1,258 fail), matching the k134 constructor boundary. This is an observation on one guest/OS build, not a
  theorem; -43 still cannot be read as absence.
- Enumeration returns an opaque reference past the boundary. Tested catalog info,
  Launch Services type/flags and exact-item handler lookup, and iteration below
  the returned directory reject it. Native same-byte/decoy comparison succeeds,
  without establishing another consumer's behavior. No native volume/node pair
  is obtainable there, so `FSResolveNodeID` was tested only on references at or
  below 1,023 bytes, as consumption, not as an acquisition route.
- Unmeasured and still owed: item-array openers (`LSOpenItemsWithRole`, `LSLaunchFSRefSpec.itemRefs`) fed a
  returned reference, receiver behaviour, long app-copy registration/identity, Finder selection, receipt identity.
  Nothing here submits any location. A positive acquisition result would have left those open; this negative one
  adds only that the flat-enumeration acquisition route does not remove the wall.

The [returned design](long-action-route.md#native-reference-result-and-remaining-gap)
consumes both runs and Antony's accepted reaction. Same-byte reference comparison
at 1,024 bytes is not an independent long same-object acquisition control;
collection completion is not consumer success. The
[finite item-array diagnostic](long-action-route.md#proposed-item-array-submission-diagnostic)
was authorized on 2026-10-05. It remains unexecuted and supplies no 1,500-byte
acquisition or action pass.
