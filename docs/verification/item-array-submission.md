# Item-array submission diagnostic (k146)

**Result: both named openers delivered the original file spelling at 900 and 1,023 bytes; both failed at the API with
status -41 at 1,024 bytes, and no event reached the recorder.** One signed throwaway helper and one signed short
recording application (`/Applications/K146Rec.app`, 25 bytes) in one disposable macOS 26.5 (25F71, arm64, APFS) guest
per collection. A diagnostic of two deprecated Launch Services submission calls only: not action or search acceptance,
no 1,500-byte acquisition, no native facts, no default binding, no long-copy registration, no Finder or real Zed
delivery, no receipt. Charter: [authorized diagnostic](long-action-route.md#proposed-item-array-submission-diagnostic).

Raw records: [`item-array-submission/results/`](item-array-submission/results/) (`run1/`, `run2/`: per-case JSONL, per-call
`*-recorder.jsonl`, `summary.json`, `driver-log.jsonl`, `guest-environment.txt`, before/after digests, end screenshot;
[`repair-reason.md`](item-array-submission/results/repair-reason.md)). Helper [`probe.m`](item-array-submission/probe.m),
recorder [`recorder.m`](item-array-submission/recorder.m), builder
[`build-item-array-probe.sh`](../../scripts/build-item-array-probe.sh), driver
[`vm-probe-item-array.py`](../../scripts/vm-probe-item-array.py); Taskfile `fixture:item-array-submission[-vm]`.

## Setup

Fresh `testanyware` macOS clone per collection; both apps signed Team `TA43A4RUP3` with Koine's empty entitlements
(hardened runtime), SDK 27.0, host clang; digests in `guest-environment.txt` and `subjects-*.json` (before/after equal
in both runs). Test data only, under `/Users/admin/k146`: three component-created text files (`mkdirat`/`openat`,
components of at most 245 bytes) of exactly 900, 1,023 and 1,024 path bytes with a same-parent `dec.txt` decoy.
Each opener call ran in its own helper process, which re-acquired the reference by k143's flat named-child walk from a
short root (never a long constructor or conversion), verified the short app reference independently (two
`FSPathMakeRef`s compare equal, catalog info, path round trip), then made one call with one document and
`kLSLaunchDefaults`: `LSOpenItemsWithRole(ref, 1, kLSRolesAll, NULL, &{version 0, flags, application}, &psn, 1)` or
`LSOpenFromRefSpec(&{appRef, 1, &ref, NULL, flags, NULL}, &launched)`. No usage keys, TCC change, protected read,
long-copy registration, default-handler change or dialog. Short controls passed in both runs (whole-path vs walked
reference compare 0, decoy differs, absent name completes with no match). The recorder logs each Apple Event in order;
the reader is Python, comparing observed bytes with the component-created spelling and the decoy.

## Observed (run 2, the repaired and final collection; run 1 agrees except where noted)

| Bytes | Opener | Status | Recorder events | Observed spelling vs fixture |
| --- | --- | --- | --- | --- |
| 900 | `LSOpenItemsWithRole` | 0 | launched, one `odoc` (1 item, type `bmrk`) | exact (coerced file URL, 907 URL bytes) |
| 900 | `LSOpenFromRefSpec` | 0 | same | exact |
| 1,023 | `LSOpenItemsWithRole` | 0 | same | exact (bookmark-stored path, 1,023 bytes) |
| 1,023 | `LSOpenFromRefSpec` | 0 | same | exact |
| 1,024 | `LSOpenItemsWithRole` | **-41** (~40 µs) | none (recorder never launched) | no delivery |
| 1,024 | `LSOpenFromRefSpec` | **-41** | none | no delivery |

The 900-byte calls proved listener detection in this corpus. The item arrives as a bookmark descriptor (`bmrk`), not a
file URL. The optional PSN output was zero and the launched-reference output is not a Koine receipt. Walks reached the
object at all three sizes (traversed lengths equal the targets); at 1,024 the walk succeeded and the failure is the
submission call. Each collection took about 95 s of the 15 minutes; no watchdog fired.

## Runs and the one repair

Run 1 (six calls) delivered at 900 and, for both openers, an `odoc` at 1,023 whose item the recorder could not read:
it kept only a file URL coerced from the descriptor and that coercion returned nothing, so the raw delivered bytes were
not retained and "unreadable bookmark" was indistinguishable from "wrong spelling". Run 1 therefore establishes **no
pass** at 1,023 (a delivery without exact observed spelling). The repair
([reason](item-array-submission/results/repair-reason.md)) retains the raw descriptor and Foundation's reading of the
bookmark's stored path; nothing else changed. Run 2 read both 1,023 items exactly. Run 1 is retained unmodified. Two
builds, two collections, one repair, twelve calls: the cap is spent.

## Reading, and what stays open

- **Boundary.** Delivery succeeds at 1,023 and the call fails at 1,024 for both openers before any launch. This matches
  k143's 1,023/1,024 boundary and `PATH_MAX` (1,024 including the NUL). The returned design's SDK read names -41
  `mFulErr`; that name is not a measured cause, and which Launch Services layer rejects the reference is unmeasured. The result is bounded to these two
  calls, one guest build and one subject type.
- **No pass for production.** Positive 900/1,023 deliveries show only that these openers deliver a bookmark carrying the
  original spelling to a short recorder. The retained 1,500-byte case was never reached: its reference is not
  obtainable (k143), and 1,024 already fails here. A negative at 1,024 closes only these tested opener paths.
- Not measured: other receivers, real Zed rendering, Finder selection, cancellation/grant parity, long registration
  or executable-identity receipts.

The [returned design](long-action-route.md#item-array-result-and-representation-assessment)
consumes both collections and Antony's directory-handle/component and
file-reference URL direction. Neither representation is credited as a complete
route. The separate [completed URL diagnostic](file-reference-url-acquisition-prototype.md)
passes acquisition/local reading/original bytes at 900/1,023 but fails acquisition
at 1,024/1,500. Preserve its instrument stop, correction and explicitly authorized
replacement; no long local-consumer pass follows. The [completed same-object diagnostic](same-object-namespace-prototype.md)
passes local identity/marker access at 900/1,500 bytes; long application/type
facts fail and a missed Zed trust stop leaves no compliant long receiver or
Finder-selection result. Antony accepted the incomplete report with no retry.
The separately completed
[focused Zed result and returned assessment](long-action-route.md#focused-zed-result-and-bookmark-question)
establish fresh reading of both originals by the exact short Zed copy after
restricted-mode choices. Native application/type acquisition still fails; the
long buffer shows an inode-only filename, exact delivery is opaque and saving
is untested. Antony accepted the [incomplete bookmark report](bookmark-name-resolution-prototype.md)
on 2026-10-06. Its sole collection stopped on supervisor-input EOF before any
fixture or case; all native stages/controls are unrun and its allowance is spent.
A [replacement local collection](focused-zed-route-assessment.md#replacement-bookmark-decision)
passed its input preflight but stopped at a trailing-slash bare-parent control
with ENAMETOOLONG before all eight cases. Antony accepted the
[incomplete local naming report](local-url-naming-prototype.md)
on 2026-10-07; its allowance is spent. The
[returned control assessment](focused-zed-route-assessment.md#local-naming-result-and-control-assessment)
separates that exact failure from the unrun naming candidates. A
[new separated collection](focused-zed-route-assessment.md#separated-local-naming-proposal)
was authorized on 2026-10-07 for one fresh-context prototype (k164),
followed by returned complete-route design k165. All eight cases remain unrun;
no repair/recollection or automatic next investigation is authorized.
No item-array repeat, production identity-spelled submission or complete route is commissioned
by these results. This report's measured corpus
and raw records remain intact.
