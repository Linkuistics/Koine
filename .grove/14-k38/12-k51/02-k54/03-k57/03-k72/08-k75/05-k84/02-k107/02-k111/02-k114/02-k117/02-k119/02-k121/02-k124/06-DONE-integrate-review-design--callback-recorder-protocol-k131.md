# callback-recorder-protocol-k131

**Integrates:** callback-recorder-protocol-k130

## Goal
Triage k130's review of k129's version-2 recorder protocol and apply the valid
findings before callback-recorder-native-k126 builds and measures against it.

## Context
- The findings are in k130's own task file, anchored to producer commit `46b1f62`.
  Read them against that protocol, the causal contract/analyzer, the control
  generator and frozen k129 run, and the k118 route producer they cite.
- Several findings concern what an honest native producer would actually emit.
  Test those claims by regenerating honest-producer synthetic traces and running
  them through the analyzer, not by prose alone.
- The artifact is a labelled experiment contract. No native execution, product
  adoption, permission change or freshness claim follows from integration.

## Done when
- Every k130 finding is classified in the running log as valid and applied,
  unclear contract settled, visible accepted trade-off, or rejected with a reason.
- The contract, causal contract, assessment, recorder views, k126 charter and
  k124 brief agree on every applied change. Any analyzer or causal vocabulary
  change is versioned, has failing controls, preserves version-1 meanings, and
  renews the complete frozen corpus with itemwise maps.
- k126's charter names every new native obligation, control or escalation the
  integration assigns. Every k124/k121 criterion keeps a live owner; no parent
  closes on synthetic consistency.

## Notes
One narrow in-session reviewer is allowed. If a finding requires redesigning the
protocol rather than repairing it, externalise a new design → review chain beside
this leaf, before k126. Any rendering or inspection of the architecture viewer
runs only in a disposable TestAnyware clone, never on the host.

## Decisions (running log)

- Read k130 from commit `34298d16`; its task bytes equal the current task
  (SHA-256 cbb5ce0f56462c4e806c0e689b0d4f29703272bab7090b04aaccb7f18400387b).
  Tier 2 graph generation 2026-09-23T17:29:37Z reports matching metadata/no
  recorded gaps for analyzer, generators and k118 route sources. Pattern
  discovery returned no symbols, so exact source reads supply the evidence.
- Findings 1–3 are valid protocol-design issues: k118 waits for activation,
  the proposed v2 protocol does not; activity has no closed producer mapping;
  receipts and controller deviation policy are underspecified. Repairing these
  changes the protocol state machine, causal vocabulary/classification and full
  canonical corpus together. Apply Grove's substantial-redesign boundary: insert
  `callback-recorder-protocol-k132` before k126, carrying a mandatory fresh tree
  review before native use. Keep v1/v2 analyzer meanings and old evidence frozen
  here. k131's synthetic reproductions test the current defects, not a replacement.
- Finding 4 is an unclear contract, settled with one measured attempt per
  matrix cell per frozen suite, no retry after any outcome, all cells reported
  including not-run. A single incomplete is evidence of that attempt, not source
  impossibility; a new experiment requires an explicit recorded discriminator
  and new freeze, preserving the earlier suite. No best-of-N positive credit.
- Finding 5 is valid and applied as a prerequisite: no framework-private
  coverage mechanism is currently specified. k126 must resolve that conflict
  before constructing/running the full matrix. Recommend a bounded same-source-
  path nested-servicing discriminator, including the serviced custom-mode control;
  detection alone cannot establish completeness. Keep all parent criteria live.
- Finding 6: the inherited `thread: tap` label is not proof of execution on a
  non-main thread (the schema accepts an arbitrary string), and turn 1/default
  mode are not inherently contradictory. Accept the canonical-producer ambiguity
  and assign explicit main-thread/audit-conformant exemplars to k132 alongside
  its activity repair. Accept the redundant order guard as a visible harmless
  trade-off: it documents the required relation but is not an independent failing
  control; k132 must not claim it supplies additional evidence.
- Finding 7 is an unclear contract, applied: start precedes collector install
  and UI creation; supervisor activation and candidate-PID relay frames are
  audit-only with explicit bidirectional joins, outside the closed causal peers.
  No new product decision meets the ADR threshold; existing capture/public-AX
  records retain their meaning. No native capture or permission action here.

- Reproduction verified all 48 synthetic cases (six variants in each of eight
  matrix cells), with unchanged per-item input digests. An independent local-
  stream check confirmed one immediate ordinal send per input and one matching
  controller receipt, including surplus/misrouted key-downs. Baselines and absent
  activation observations pass; misroutes are exit 1, duplicate input exit 3,
  honest surplus exchanges exit 3, and hypothetical update-as-activity exit 2.
  These expose missing specification, not native occurrence or probability.
- Complete frozen rerun matched all 233 outcomes; every result is identical
  itemwise to k129. Only the two contract documents and Taskfile differ in the
  input maps. Analyzer/generators/canonical controls retain their bytes and all
  v1/v2 meanings. The existing check task passes 235 tests, lint, formatting and
  strict types; the new reproduction script separately passes those static
  checks. No causal vocabulary or classification changed in this integration.
- Decline the optional narrow in-session reviewer: executable reproduction plus
  independent receipt cardinality/local-order checks test the evidence claim,
  while k132's mandatory fresh tree review is the proper place to challenge the
  replacement protocol. This integration does not select that replacement.

- Recorder protocol/return/containment sources and viewer captions carry the
  same pending-redesign warning, coverage-before-matrix gate, one-attempt rule
  and startup/audit clarifications. The render task succeeded only in disposable
  TestAnyware clone `koine-k131-view`, after resolving a missing copied Java
  font-library dependency (failed attempt retained). Source, task, runtime and
  dependency maps stayed unchanged; all three local SVGs match guest output
  digests and parse as XML. No browser/visual reinspection is claimed. Clone
  stop succeeded and the backend list confirms that clone absent.
- Final verification rehashed every frozen analysis/reproduction subject from
  disk and checked itemwise results, viewer source/rendered links and live
  k132/k126 ownership. Retire only k131. k124 still has two live leaves; no
  ancestor closes or needs a completion cascade. No capture/public-AX ADR
  meaning changed, and no native capture, permission expansion or freshness
  claim follows from this integration.
