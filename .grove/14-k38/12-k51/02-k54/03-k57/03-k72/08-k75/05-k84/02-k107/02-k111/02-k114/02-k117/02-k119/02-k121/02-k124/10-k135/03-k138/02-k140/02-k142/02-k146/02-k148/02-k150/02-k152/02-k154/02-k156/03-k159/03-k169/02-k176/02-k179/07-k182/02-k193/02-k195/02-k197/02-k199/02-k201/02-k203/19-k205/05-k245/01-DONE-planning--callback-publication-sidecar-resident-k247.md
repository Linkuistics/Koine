# callback-publication-sidecar-resident-k247

## Goal
Repair k243 findings 2 and 3 in the frozen report profile: a sidecar
eligibility rule closed over support, and a resident bound that covers the
parsed legacy comparison and its parse workspace. Publish the result as a
versioned profile with its census, coverage rows and consumer contracts.

## Context
The k245 brief (its Context and Done when, sidecar and resident/comparison
bullets); `publication-profile-review-k243.md` findings 2–3; the k244 log;
publication-capacity.md "Frozen profile" (`/1` at the start of this leaf);
publication_profile.py; publication-replay.md "Report admission and resource
failure" and "Detached legacy CLI comparison"; the k226, k227 and k240 bodies.

## Done when
- A stated closure rule for sidecar eligibility, with each of the section IDs
  classified by the support its family rows reference. The eligible set is
  narrowed or its support charged, `max_diagnostic_bytes` is re-derived, and
  the note says how R32's native contradiction and pending obligation stay
  inside the eligible set.
- The parsed legacy result and its parse workspace have a resident allowance
  derived from a CPython object model at the admitted stdout limit and checked
  against adversarial parses, plus a lifetime and archival argument.
  `max_resident_report_bytes` is re-derived, and the note states what k240's
  resident control proves.
- Changed constants are published as `publication-report-profile/2`, with
  /1 kept as superseded history. `design:check-publication-profile` is green
  and the coverage table and drift mutants are updated.
- The k226 sidecar bullet, the k227 capture/parse bullet, the k240 resident
  and sidecar coverage bullets and the k205 plan table agree with /2.

## Notes
Path-reference fit (finding 4) is k248's. This leaf leaves the admitted path
limit unchanged. It does not claim any construction fits.

## Decisions (running log)

- **Decomposed k245.** Finding 4 needs its own design argument. At V = 4,138 a
  startup-base maximal-edge file needs Q = 1,020, and the crude bound is then
  8,439,480, above 2^23. Exact attainment of the limit is not evident either.
  K248 owns that. This leaf keeps the path limit unchanged.
- **Sidecar closure rule (finding 2).** Each family row now declares a support
  class. `local` rows reference only observations (raw index or vertex,
  resolved by `maps`), interned strings, and records of their own section or an
  earlier eligible section. `graph` rows may reference a query, path, edge,
  justification, bundle, dependency witness, SCC record or order-dependent claim.
  A section is eligible only if every family in it is local. The census
  derives the set and checks it: the first twelve IDs plus `strings`.
- **Reclassified or moved families.** Milestones (5 queries per commit, 177
  fixed) and controller-rules (guards are masked usable-truth claims) are not
  eligible. Frame attribution/causal status/cross-role credit moves into
  `receipt-bundles`. M32/M33 pending obligations are local and move into
  `lifecycle`. Local receipt grades (R, O/J/E/D, qualification, decision),
  preheld/helper joins and FIFO ordinal checks stay in `frame-grades`, now
  eligible. Replay stage 2 needs no causal claim for these.
- **New section `ordered-rules` (28 IDs).** A migrated legacy check whose
  operands include an order claim places its records here. The only legacy
  graph caller is analyze.py: the sampler_*, source_calls, native_ownership and
  pending_native modules call no order helper or Trace graph method (grep).
  The census charges the whole legacy check capacity once, to `source-rules`.
  That is the upper bound for either section and for the sidecar.
- **R32.** The native contradiction is a `source-rules` raw-consistency
  record from the shared source_calls/native_ownership predicates. The pending
  obligation is a `source-rules` pending resource/lease or a `lifecycle` M32
  record. Both commit at the end of stage 2, before graph freeze, so they survive
  exhaustion of any later dimension.
- **Parse allowance (finding 3).** The costliest JSON token per input byte on
  CPython 3.14.7 is a nested one-element list: a 64-byte list object plus a
  32-byte four-slot item array per two bytes, 48 B/byte. Adding the decoded
  ASCII copy gives a model of 49 B per stdout byte plus 65,536 fixed. At
  262,144 bytes the allowance is 12,910,592. A 21-shape adversarial battery
  peaks at 44.92 B/byte (nested-list-500), below the model, and the costliest
  shape is the modelled one. Stderr is never parsed.
- **Lifetime and archive.** The parse is admitted against the reserved
  allowance after capture completes. The objects live only through stage-6
  difference extraction and are released before encoding. The report's
  `parsed` value is legacy's own stdout JSON text spliced verbatim, embedded
  only when it is ASCII strict JSON. That text is already charged to the capture
  buffer and `max_comparison_bytes`, so no parsed object outlives stage 6.
- **Profile /2.** Resident 46,759,025 → 59,669,617 (+ parse allowance);
  report 76,429,180 → 76,429,244 (+64 framing for `ordered-rules`); diagnostic
  27,627,148 → 26,871,702 (milestones, controller-rules and frame attribution
  leave; M32/M33 join). The other eleven values are unchanged.
- **Verification.** `design:check-publication-profile` is green with the
  record in evidence/k247, and the other publication checks are unchanged
  and green. I ran each new check against a deliberate mutation on a scratch
  copy and saw it fail. Marking both milestone rows local changed the
  eligible set. Moving frame attribution back into frame-grades left
  `receipt-bundles` unclassified. A one-slot list model put two nested-list
  shapes over the model. A ±1 document drift in the diagnostic or resident
  value was reported as a profile mismatch.
