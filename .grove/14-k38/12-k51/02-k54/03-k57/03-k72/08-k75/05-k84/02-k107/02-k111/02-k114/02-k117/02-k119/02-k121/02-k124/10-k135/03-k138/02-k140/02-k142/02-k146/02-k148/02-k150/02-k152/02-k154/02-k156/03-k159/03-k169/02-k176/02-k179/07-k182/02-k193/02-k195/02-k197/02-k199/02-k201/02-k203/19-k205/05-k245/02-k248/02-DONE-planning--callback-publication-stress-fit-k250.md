# callback-publication-stress-fit-k250

## Goal
Show, in a census-checked table, that every other required stress or boundary
construction fits the admitted path-reference limit under k249's bound, before
any consumer leaf builds one.

## Context
The k248 brief and k249's running log and census bound function.
publication-capacity.md "Complete discriminator ledger" (B01–B20) and
"Frozen limits and reserve"; publication-lifecycle.md L01–L34 and M01–M33;
the topology table and E01–E24; publication-replay.md R01–R35 and "Report
admission"; the k225 and k229 bodies.

## Done when
- A census-checked row for every required construction: B01–B20 (B12, B13,
  B18, B19 and both reserves included), L/M/E/R and topology stress. Each row
  gives its base, anchor counts, V, per-base Q and path bound.
- Each bound fits, or the row gives a smaller-base construction that keeps its
  boundary, or a stated tighter bound. Base variants of lifted histories carry
  a per-base headroom.
- The k225 fit gate and the k229 envelope bullet cite the table rather than
  deferring to construction or k240 measurement.

## Notes
No control is dropped, weakened to incomplete-resource or deferred to k240.
Legacy fixtures, expected answers and k217 inputs stay frozen.
K249's bound is deliberately loose in two places, which a row may tighten with
a stated argument. The legacy activity→B-input call is charged cross even for
a B activity. Legacy pairs that repeat a successor activity comparison are
charged twice. Its lemma needs an acyclic segment, so cyclic constructions
keep V − 1 per witness. K225's gate text still names 2×Q×(V−1); rewrite it to
the census bound here.

## Decisions (running log)

- **No acyclicity premise anywhere in this table.** Every row is bounded
  with every witness at V − 1 (2Q(V−1) + V + H + D). Stress fragments add
  cycles freely (E20/E24, R09/R12/R13), so the same-lane lemma is not relied
  on. K249's two loose places therefore need no tightening here.
- **Fragments are lifted-base variants.** Topology, E, L, M, R and the small
  B histories are fragments on a legal base (the docs say K182 supplies the
  omitted legal rows). Each is charged as a lifted V11–V25 history plus a
  stated added-row vector, at the costliest per-kind rate: a target row 25
  queries on selected (16 legacy tgt + 4 cross + member + 4 comparisons), 19
  on active, 5 on startup; a controller row 3; a sampler row 2; a commit 5
  (milestones) with H+1 and D+3 for its receipt. The worst over every lifted
  history of the row's versions is the row's V, Q and bound.
- **Per-base headroom.** At a uniform worst rate per added row, v18/v24 leave
  50 rows, the other selected bases 85–86, active 125–139, startup 608–638.
- **Envelope-scale B boundaries go on the startup base.** B13, B14, B18, the
  B19 cap overflows, B20's ordinal 80/81 file and both reserves are
  transport-only boundaries. A startup ceiling (no legacy order site,
  controller semantic ≤ 257, sampler ≤ 24 rows all charged as acquisitions,
  B and C ≤ 6 rows each charged as members and activities, every transport
  kind at its /2 envelope value, λ surplus local rows) bounds all of them.
  Each such row names the boundary lane's kind vector and its λ.
- **Results.** Fragment classes on the worst lifted history (v18
  live-status): transport 4,519,395, semantic 4,799,919, attempts 4,444,373,
  queue 4,700,729. The startup ceiling is 7,449,812 at λ = 0 plus 2,189 per
  surplus local row, so λ ≤ 428. The envelope rows run from 7,452,001 (B13
  bytes) to 8,029,897 (B14's 2,048-row reserve lane, λ = 265). All 160 IDs fit.
  No profile constant changes and `/2` stands.
- **IDs are enumerated from the documents, then classified.** The census
  regex-extracts B, L (with L08a/b), M, E (table plus the E20–E24 bullets)
  and R IDs, plus the topology table rows. T01–T10 are those rows and T11 is
  the G40–G46 fragment. A new or removed ID fails the plan or the document
  table. R02/R10/R11/R13/R29–R31 also carry the six k217 files (27,388).
- **Attainability is split out to k252.** The path fit covers every vector
  whether or not it is reachable. Three limits are left open: B13/B18 app
  bytes reach 4 MiB only at 2,049-byte metadata rows; the full reserve tails
  cannot follow 1,536 ordinary rows inside the semantic and commit caps; and
  B14 needs surplus local rows. `callback-publication-share-reach-k252`
  (planning, under k205) owns these, and k229's Notes point to it.
- **Consumers.** K225's gate now uses the census `path_bound` and the
  fixture's fit-table row, and has no k240 deferral. K229's envelope bullet
  cites the table. Capacity's per-case bound and lane-class notes point to
  the new section. The transfer doc records k250, and the k205 plan-table row
  names k252. Evidence is now evidence/k250, and k249's record is restored
  unchanged.
- **Verification.** `task design:check-publication-profile` is green (ruff,
  format, pyright and census). On a scratch mirror I made twelve mutations,
  and each failed: an ID-table number, a dropped B17 row, a headroom value, a
  λ, a renamed class, a new L35, a new topology row, a commit over the lane
  cap, B14 one row short, a ceiling below the C = 7 skeleton, an oversized
  queue class, a plan missing L08b, and a supervisor lane at 2,222 rows over
  the limit.
