# callback-publication-report-profile-k243

**Reviews:** callback-publication-report-profile-k224 (and the plan it froze
numbers for, callback-publication-delivery-plan-k223).

## Goal
A fresh-context adversarial read of the frozen `publication-report-profile/1`,
its per-dimension coverage table and the k225–k242 plan that consumes them,
before any impl leaf under k203 runs. Findings only; no fixes.

## Context
publication-capacity.md "Frozen profile publication-report-profile/1" and
`task design:check-publication-profile` (publication_profile.py, record in
evidence/k224/profile-census.json); publication-replay.md "Report admission and
resource failure" and "Internal test profile and production isolation"; the
k223 and k224 decision logs; the k225–k242 leaf bodies under k203 (k225, k226,
k227, k229, k232 and k240 were amended by k224).

## Done when
Findings, each with a concrete counterexample or the exact argument that fails,
cover at least these doubts:
- **Envelope.** Is the recorder-attainable envelope (4,138 rows: 257 semantic
  per app, 161 commits/receipts/completes, 1,281 begins, 1,282 results, 64
  local rows) a sound domain? Does any required topology/E/L/M/B/R/P/Q control,
  B19 overflow or reserve tail fall outside it and so risk a spurious
  incomplete-resource?
- **Family table.** Is any successor rule family, anchor or multiplicity
  missing or undercounted against transport-evidence, lanes, lifecycle, files,
  auxiliary, protocol and replay? The M01–M33 counts were inferred from row
  text; check them.
- **Legacy census.** Does "each check site is at most one claim per anchor"
  bound the successor's migrated rules? Are the exclusions (outer schema,
  logical-edge construction, V1–V10 orchestrators) right? Is resolution of
  calls by name sound? Is every ITERABLES classification right (e.g. `body`
  and `observed` as one target stream, `peers.items()` as 32)?
- **Paths.** Does the admitted 8,388,608-reference limit, with the k225 fit gate
  and the lifted-corpus argument, genuinely show required-case fit? Is
  incomplete-resource on overflow consistent with R30–R32 and "no silent cap"?
- **Workspace and resident.** Is the CPython 3.14 Trace object model sound as a
  bound, with simultaneous lifetimes stated correctly? Is charging preallocated
  resident bytes once per run a faithful reading of the replay contract?
- **Encoding.** Do the record widths, copied-string list, 27-ID enum,
  sidecar-eligible split and comparison capture bound (~160 KB stdout source
  bound for projections) hold? Is the emergency header verification complete?
- **Coverage.** Are the attainable/infeasible calls right? Can the named stress
  files isolate one dimension each? Are the generated maximal-edge and
  exact-path-reference files feasible?
- **Plan.** Do the k225–k242 bodies still assign every dimension and control
  once, with no numeric choice left to an implementer?

## Notes
Planning review only: no successor implementation exists and the frozen values
are expected controls. An integration is cut only if findings warrant it.

## Decisions (running log)

- Review is findings-only against k224 commit `972f7ce1` and k223 commit
  `488cdc98`. No test, build, lint, format, census or successor execution is
  performed. The graph generation is `2026-09-24T05:52:56Z`; recent publication
  files are not tracked by its metadata and analyze.py has changed, so findings
  use current direct source/document inspection.
- The k232 split-cycle control needs W-input before k236, and the frozen
  sidecar/serialization promises need integration. Record durable findings in
  `docs/verification/callback-native-capture/publication-profile-review-k243.md`
  and cut a same-parent integrate-review-planning leaf, keeping k205 live and
  ahead of k225. No plan, profile, source or existing evidence is repaired here.
- Five findings are recorded in the durable review. Integration is
  `callback-publication-report-profile-k244`, next in this directory. K205
  therefore retains live work; no parent-chain close or product ADR change
  follows from retiring this review.
