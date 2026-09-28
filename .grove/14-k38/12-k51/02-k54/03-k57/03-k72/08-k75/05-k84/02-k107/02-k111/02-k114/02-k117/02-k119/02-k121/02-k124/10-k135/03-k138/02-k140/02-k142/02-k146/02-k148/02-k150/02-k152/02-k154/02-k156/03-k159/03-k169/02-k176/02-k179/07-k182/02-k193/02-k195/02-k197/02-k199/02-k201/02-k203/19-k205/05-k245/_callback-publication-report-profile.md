# callback-publication-report-profile-k245 — brief

## Goal
Repair the frozen `publication-report-profile/1` for k243 findings 2, 3 and 4:
a sidecar closed over its support, a resident bound that includes the parsed
legacy comparison, and a fit proof for every required stress construction —
re-derived and frozen before any k225–k242 implementation. This remains
k205's own numeric duty; nothing here passes to an implementer.

## Context
`docs/verification/callback-native-capture/publication-profile-review-k243.md`
findings 2–4 and the k244 running log (the triage and its evidence);
publication-capacity.md "Frozen profile publication-report-profile/1" and
"Per-dimension coverage"; publication_profile.py (the sidecar sum excludes
the `graph` term; the resident sum has no parsed-result term; `fit()` covers
only lifted bases and six k217 inputs); publication-replay.md "Report
admission and resource failure" (R31/R32 and the k205 fit duty),
"Detached legacy CLI comparison"; publication-lifecycle.md M01–M33;
the k225/k226/k227/k229/k240 leaf bodies. K224's own Done when still binds.

## Done when
- Sidecar: eligibility is a stated closure rule — a section is eligible only
  if every support record it references (edges, justifications, queries,
  paths, path references, receipt bundles, dependency witnesses, SCC records)
  is itself inside the sidecar and charged to max_diagnostic_bytes, or the
  section issues none. Classify each of the 27 sections against its family
  rows (milestones' 5/commit + 177 fixed queries; frame attribution's bundle
  masks) and either narrow the eligible set or charge the needed graph/support
  term. Re-derive max_diagnostic_bytes; state how R32's committed native
  contradiction and pending obligation stay inside the eligible set.
- Resident/comparison: a resident allowance, or a bounded streaming/archival
  representation with a lifetime argument, for the parsed legacy result and
  its parse workspace at the admitted stdout/stderr limits on the pinned
  CPython; re-derive max_resident_report_bytes and state what k240's resident
  control actually proves.
- Fit: enumerate every required stress/boundary construction (B01–B20
  including B12/B13/B18/B19 and both reserves, L/M/E/R/topology stress, the
  maximal-edge and exact-path generated files) with its V and per-base Q
  before any consumer leaf, and show each fits the admitted path-reference
  limit, or give a smaller-base construction preserving its boundary, or a
  tighter bound. No required control may be dropped, weakened to
  incomplete-resource, or deferred to k240 measurement.
- If any constant changes, publish a versioned profile (not an in-place edit
  of /1), rerun `design:check-publication-profile`, and update the coverage
  table and drift mutants.
- Update the k225 fit gate, k226 sidecar bullet, k227 capture/parse bullet,
  k229 envelope bullet and k240 coverage bullets to the repaired profile, and
  the k205 plan table in callback-capture-transfer.md.

## Notes
K243 findings 1 and 5 were repaired directly by k244 (W-input/W-enter moved
to k231; k226 map comparison through physical coordinates). K246 reviews this
leaf. Legacy fixtures, expected answers and k217 inputs stay frozen.

## Decomposition

The fit proof turned out to be its own design problem. The crude per-case
bound cannot cover the maximal-edge file at 2^23, and exact attainment of the
path limit needs its own argument. The node splits along the findings:

- callback-publication-sidecar-resident-k247: findings 2 and 3. Sidecar
  closure, the parsed-comparison resident allowance, and profile /2 with its
  census, coverage rows and k226/k227/k240 bullets.
- callback-publication-path-fit-k248: finding 4. The fit table for every
  required construction, the maximal-edge and exact-path boundaries, any
  further profile version, and the k225/k229/k240 path bullets.

K246 reviews both once this node closes.
