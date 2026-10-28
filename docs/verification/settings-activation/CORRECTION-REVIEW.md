# Settings correction assessment review integration

The bounded no-candidate finding survives review. The
[assessment](CORRECTION-ASSESSMENT.md), [contract](../../specs/settings-activation-discrimination.md#scope-after-no-candidate)
and [presentation](../../design/architecture/settings-activation/README.md) now
state the limits of the pending empirical-ordering proposal. Antony's scope
choice remains pending; no candidate, cap, implementation or runtime is selected.

This integrates settings-activation-correction-k47 at review commit
`8d0b3981`, against producer settings-activation-correction-k45 at `99d16b5a`.
The findings were read from the review's own committed leaf. Its severity labels
are retained below.

## Dispositions

| Finding | Classification and resolution |
|---|---|
| P2-1: undefined finite acceptance limit | Contract stated unclearly. With no supported failure-rate bound or trial model, a finite acceptance bound would be a convention requiring Antony's explicit agreement. The proposal rejects reversal as the repair on one qualified recurrence during its evaluation or separate ordinary acceptance. Required evidence that is missing or fails transport prevents acceptance; it does not automatically establish product failure. All required ordinary assertions must pass. A passing fixed bound establishes only that sample's result. A later reviewed design must choose the bound and qualification/stop/failure rules before runtime; this integration chooses none. |
| P2-2: feasibility evidence loses its instrument and symmetry | Real issue. [ORDER-RESULTS](ORDER-RESULTS.md) records reversed B02/B03 and original A04 success, all with synchronous file tracing. Moving the calls also moved those writes. The proposal and its summaries now carry both limits. This comparison establishes neither instrument-free feasibility nor reduced failure risk from reversal. |
| P3-1: collection behavior lacks a disposition | Real issue. AppDelegate line 126 inserts `moveToActiveSpace`. The checked Apple contract describes where the window moves when active; it supplies no activation prerequisite or guarantee. No cited failure evidence establishes a Spaces transition or second-Space condition to correct. The assessment adds a contract row and candidate disposition, without claiming all Spaces configurations are correct. |
| P3-2: public web sources are not retained | Real issue. The original receipt has source/SDK digests but no web retrievals. The new [Apple contract record](correction-evidence/apple-contracts.json) retains retrieval metadata, response digests and short checked excerpts for the eight cited pages, the WWDC transcript and the added Spaces contract. These are fresh integration reads, not recovered producer/reviewer responses. Full web bodies are not retained. |

The review's contract paraphrases agree with the fresh Apple reads. The bounded
finding remains that no qualifying correction was established in the inspected
path. It is not an exhaustive AppKit/Spaces audit, proof that no correction
exists, or an attribution to the operating system. These reversible repairs and
the unaccepted proposal earn no ADR and change no existing ADR decision.

## Narrow outcome review

The single permitted in-session reviewer received only the proposed acceptance
clause and its contract. It derived an outcome table to look for false acceptance
or confusion between behavioral evidence and causal proof, and found no material
issue. This was an aimed clause review, not a second whole-design review.

| Outcome | Consequence under the proposed convention |
|---|---|
| One qualified recurrence | Reject reversal as the repair; cause and ownership remain unresolved |
| Fixed bound and complete ordinary acceptance pass with all required evidence | Supports success for that sample only, not elimination, mechanism or general reliability |
| Failed transport or missing required observations, without a qualified recurrence | No acceptance; unresolved, not automatically a product failure |
| Another required ordinary assertion fails | No acceptance; does not itself establish the Settings recurrence or attribute cause to reversal |

This table describes a proposal. Antony has not accepted the convention or the
empirical-design scope. His answer can authorize concrete design only; its review
and every earned integration still precede implementation or runtime.

## Preserved boundary and verification

The [complete original-duty comparison](../../specs/settings-activation-discrimination.md#original-duty-comparison)
remains binding. One selection must return one front/focused window with one
activation request. Repetition, driver waits/retries/repeated input, deferral and
speculative yielding remain excluded. A useful failing product seam where
feasible, signed/all-input/completed-golden freeze, every attempt/failed transport/
partial/NOT RUN outcome, audits, exact stop and separate complete ordinary
acceptance with diagnostics disabled remain required. Native cause and ownership
stay unresolved.

The six route/modality slots remain held and unstarted with their criteria and
caps unchanged. Historical candidates, archives, classifications, strict false
joins and closed caps remain unchanged. No guest, product, test or Taskfile
change runs in this leaf. Document and presentation checks establish no native
behavior, repair or ordinary acceptance. No causal or product ancestor closes.

The [original receipt](correction-evidence/verification.json) and its
[documentation output](correction-evidence/doc-links.txt) remain unchanged.
The [integration receipt](correction-review-evidence/verification.json) records
the current document checks, input digests, presentation inspection and limits.
The graph service refused startup before project/generation discovery; there is
no graph coverage claim. Source verification used the named AppDelegate range
and retained evidence directly.
