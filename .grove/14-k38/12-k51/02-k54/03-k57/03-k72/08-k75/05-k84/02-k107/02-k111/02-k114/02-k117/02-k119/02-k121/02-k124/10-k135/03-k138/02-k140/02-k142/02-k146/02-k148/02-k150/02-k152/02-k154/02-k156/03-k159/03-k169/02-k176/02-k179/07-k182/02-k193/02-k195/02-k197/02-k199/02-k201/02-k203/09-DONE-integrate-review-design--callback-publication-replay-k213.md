# callback-publication-replay-k213

**Integrates:** callback-publication-replay-k212

## Goal
Triage k212's review of the k211 consumer policy and apply the findings that
hold, before k205 plans complete executable delivery and freezes the report
profile.

## Context
Read the findings in callback-publication-replay-k212's own committed leaf. They
are anchored to k211 commit `09a9703` and to current analyze.py, contract and
transport-lanes lines; re-check cited coordinates if an intervening commit
touched those files. Consume publication-replay.md, transport-evidence.md,
transport-lanes.md, publication-capacity.md, both recorder contracts (including
the causal state table), the assessment's k211 section, k205 and the replay/
claim/sample-state views. The k203 brief and every original ancestor criterion
still bind; neither k211 nor k212 is an assumption of correctness.

## Done when
- Every k212 finding has a recorded disposition in the assessment, with any
  qualification of the reviewer's reading stated.
- Accepted findings are reflected in publication-replay.md and, where they
  change a reviewed rule, in transport-evidence.md, transport-lanes.md, both
  recorder contract sections, the causal state vocabulary, capacity, assessment
  ownership, k205's handoff and any affected view. Each changed policy has a
  determinate expected report, an honest neighbour and an isolating mutant in
  the R inventory. Changed views are rendered and inspected in a disposable
  TestAnyware clone.
- Any change that amounts to a substantial redesign is externalised as a new
  producer with its own fresh review ahead of k205, never absorbed silently or
  left to implementation inference.
- V1–V26 inputs, limits, fixtures and reports remain unchanged. K205 keeps
  complete executable-delivery planning and the numeric report-profile freeze
  under k203's unchanged charter.

## Notes
Design integration only: no analyzer version, predicate extraction, corpus
renewal or native experiment. K180/k177/k143/k144/k126 keep their phase/sampler/
target/controller/native duties and every k124/k121 criterion. No ancestor
closes. One narrow in-session reviewer is allowed by the integrate-review
allowance; substantial redesign goes to a new producer/review chain instead.

## Decisions (running log)

- Read k212's own committed findings at 85799c2c against k211 09a9703b.
  Tier 2 graph lookup found sampled_evidence, but generation
  2026-09-24T05:52:56Z has stale offsets (its snippet starts in another
  function). Current source at analyze.py:1676–1698, 1723–1735 and 1779–1797
  supplies the acquisition, retention and state evidence; document rules were
  read directly. Do not treat graph offsets as current evidence.
- Findings 1, 2 and 4 require a coordinated producer repair: receipt dependency
  ownership/path selection, interpretation versus claim-local failures, and
  each acquisition absence/count/ALL domain. These change reported truth and
  scope and therefore go to a fresh design/review chain before k205. K212's
  finding 2 legacy comparison is conditional: sampled_evidence preserves scope
  only with trusted=True; the full controller check can reject an ordinary C
  post. That qualification does not remove the successor contract conflict.
- Repair bounded wording for finding 3 without changing state values: successor
  partial also includes unknown presence, and resource admission has a distinct
  report status outside the evidence classifier. For finding 5 retain raw
  assertion counting as a visible conservative trade-off, not proof of two
  physical events; distinguish armed receipt eligibility explicitly. Clarify
  finding 7's composite ownership with separate bare-AND and selected_callback
  controls. Finding 6 earns an explicit internal test-profile seam and production
  guard, with k205 retaining actual numeric derivation/freeze and coverage duties.

- Created callback-publication-replay-k214 and fresh review k215 immediately
  before k205. R34's counting results are fixed, but its interpretation outcome
  depends on the accepted finding 2 repair, so the producer owns its full-report
  result explicitly. No change to the original k203 criteria or higher owners.
- Document verification passed: complete diff is Markdown/Grove only; R01–R35
  and local links agree; k214/k215 precede k205; original k203 criteria and the
  frozen legacy state table are byte-identical. Deliberate preservation,
  inventory and criterion mutations are detected. Diagrams/assets are unchanged;
  k214 owns affected-view repair and disposable-clone inspection. No runtime
  rerun or native success is claimed. Retire only k213; live siblings prevent
  any parent-chain close.
