# callback-publication-report-profile-k244

**Integrates:** callback-publication-report-profile-k243

## Goal
Triage the review of the frozen publication report profile and delivery plan,
apply the findings that hold, and establish a coherent planning handoff before
any k225–k242 implementation begins.

## Context
Read callback-publication-report-profile-k243's committed review and
`docs/verification/callback-native-capture/publication-profile-review-k243.md`.
The reviewed producers are callback-publication-report-profile-k224 and
callback-publication-delivery-plan-k223. The full k205 brief remains binding.

## Done when
- Every review finding has an evidence-based disposition; apply the real ones
  and explain rejected findings without turning the review into requirements.
- The profile, derivation, coverage table and ordered leaf contracts agree;
  required verification for accepted changes is recorded through pinned tasks.
- Every original k205 and ancestor obligation keeps its owner. Complete the
  planning-node retirement check only when its entire Done when holds; no
  implementation, native-readiness or release criterion closes from this plan.
- Any substantial redesign gets the appropriate producer/review chain before
  dependent implementation, following the integration skill.

## Notes
This leaf runs immediately after k243 inside k205. Legacy fixtures and expected
answers remain frozen. No successor execution is implied by planning evidence.

## Decisions (running log)

- Findings read from k243's commit `e133fe6a` and
  `publication-profile-review-k243.md`; each checked against the cited
  artifacts at k224 `972f7ce1` / k223 `488cdc98`.
- F1 real issue (plan). `publication-path-controls.md` item 5 gives every one of
  the six fixtures W-input/W-enter edges, and multi-cycle's sole SCC needs
  T35→B25 (W-input). So k231's SCC digests and k232's P-multi/G90→T34 mutant
  both need the witnesses before freeze. Their admission uses only stage-2 raw
  counting sets, replay eligibility and local R qualification
  (`publication-replay.md` "Selected successor edge rules", "Counting domains"),
  all available after k228/k230. Repair: k231 owns W-input/W-enter enumeration,
  observed-count admission and the edge-admission parts of R06/R07/R18/R33;
  k236 keeps closure, exact-count/at-least claims, window, interpretation,
  presence and Q01/Q02/Q16/Q34–Q37. Ownership table updated.
- F5 real issue (contract stated unclearly). `publication-files.md` lets
  input indices vary across permutations; k226 required its `maps` section
  byte-identical. Repair: compare maps through physical coordinates (the
  coordinate→vertex relation identical, raw-index→vertex consistent with each
  permutation's line→coordinate map); every other listed section byte-identical.
- F2 real issue. The sidecar sum in `publication_profile.py` excludes the
  `graph` term, while `milestones` (sidecar-eligible) issues 5/commit + 177
  fixed queries and frame attribution is masked by receipt bundles. The
  eligible set and `max_diagnostic_bytes` must be re-derived.
- F3 real issue. Resident setup charges raw capture buffers only; neither the
  parsed legacy result nor its parse workspace has a resident allowance or a
  bounded lifetime argument, though the contract requires both bounded.
- F4 real issue. Fit is proved for lifted bases and the six k217 inputs only;
  stress constructions are sent to k225 construction or k240 measurement,
  after consumers such as k229. Conservative 2Q(V−1) does not obviously fit
  at large target rows (20 tgt queries/row × 256 alone exceeds the limit at
  envelope V), so this needs enumeration, not an argument here.
- F2–F4 all require re-deriving the frozen numeric profile and new fit
  evidence: substantial redesign of k224's deliverable, not a repair. Cut a
  planning + review-planning chain (same slug) inside k205 after this leaf,
  so pick reaches it before k225. K226's hard-coded "first fourteen" and the
  k225/k229/k240 fit-gate wording are left for that chain to rewrite against
  its repaired profile; k226 now cites the capacity document's eligible set.
