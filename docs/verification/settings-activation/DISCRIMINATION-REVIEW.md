# Settings discrimination design review integration

The [decision document](../../specs/settings-activation-discrimination.md) now
states the proposed repair classes and justification test, accounts for the
omitted positive native rows, and separates necessity, sufficiency and finite
statistical rejection. Antony's scope choice remains pending. No candidate is
selected, all six existing slots stay unstarted, and no causal or repair duty
is discharged.

This integrates settings-causal-discrimination-k43 at review commit
`d5f8f8058e9fb7776a1fdf9ad3dc6280c7631d9c`, against the producer at
`8c7c7b9e1e5dfb99e1408d869d9764e0d96598c5`. The review's own committed leaf is
the source of the findings. Its severity labels are retained below.

## Dispositions

| Finding | Classification and resolution |
|---|---|
| P1-1: undefined repair classes and justification | Contract stated unclearly. The pending amendment permits design of a single-request correction to a concrete, evidenced API-use mismatch. A different public activation API must meet that test and its preconditions. Application repetition, driver waits/retries/repeated input, deferral and speculative yield remain excluded; reconsidering those classes requires another explicit scope proposal. No candidate has been justified. A narrow fresh reader of this clause and the original contract found no material gap. The existing experiment subject remains unchanged and excludes all alternate APIs/yield/async/repetition. |
| P2-1: omitted positive rows | Real issue. The full saved rendering confirms the rows below. The current evidence summary accounts for their interleaving, shared forms and unknown connection ownership. Historical CAUSAL-RESULTS and raw evidence stay unchanged. Neither the expanded contrast nor an unidentified counterpart supplies causal direction or native refusal semantics. |
| P2-2: Choice B understates its revisit condition | Contract stated unclearly. An unrestricted possibility admits every finite result. The scope table now requires supported outcome-excluding predictions for logical falsification. A supported rate bound/trial model could instead permit statistical rejection, which needs an explicitly agreed standard. Neither is established or promised. The review's suggestion that a rate model supplies literal finite falsification is not adopted. Intermittence itself does not prove that every narrower causal hypothesis is untestable. |
| P3-1: no prediction claimed for competing interaction | Real issue. A key-reclaim necessity hypothesis predicts that every failure requires reclaim. A qualified failure with reclaim independently excluded would refute it. The missing pieces are qualified exclusion, an isolated matched intervention and the rival's falsifier, not the existence of any prediction. |
| P3-2: marker necessity omitted | Real issue. Successful counterexamples refute sufficiency, not necessity. The candidate table now considers removing the marked condition, its one-sided falsifier, lack of a supported matched setter/remover and the rival's unrestricted outcomes. Missing marker logs cannot establish absence. |
| P3-3: spec membership and presentation | Real issues. Session review/resumption instructions move to the scope task; historical verification references move to the presentation README. The duplicate viewer becomes a relative symlink to the parent viewer, both diagrams enter the parent outline, and one dark start node reaches every evidence branch. Final spec membership after the actual choice remains explicitly owned by settings-activation-scope-k42, as the review permits. This preserves the pending agreement document until that decision and avoids inventing its accepted form. |

The no-runtime conclusion survives the corrected arguments. The present hold is
reversible and the scope amendment remains unaccepted, so neither earns an ADR
under the hard-to-reverse, surprising, real-trade-off AND test. No existing ADR
decision changes.

## Native-row comparison

The source is the complete retained
[rendering](causal-evidence/persisted-input-context.jsonl.gz), parsed through its
completion object: 1,061 events, then `count: 1061, finished: 1`. The positions
below are one-based source lines. They extend the historical
[paired summary](CAUSAL-RESULTS.md#independent-saved-input-context); the source
bytes, clocks, old strict false joins and classifications are unchanged.

| Observation | Success-adjacent source | Failure-adjacent source | Interpretation limit |
|---|---|---|---|
| Actual client call | 365, tick 4338579225, Koine PID 814 | 970, tick 4476843871, same PID | Native-only sequence, not a retroactive join to buffered application rows |
| Token checks and front/resume processing | Checks 372–373; setFrontmostProcess/Making front 374–375; LS/CAS success 376; resume 388–389 | Checks 975–976, followed by TextEdit appearance 977; no matching front/resume row identified in 970–988 | Missing counterparts prove no absent event; -50 appears in success too |
| Active key and another window's main resignation | Koine connection 403fb requests window 28 active key at 499, then window 33 main resignation at 500/502/503 | TextEdit connection 53ea7 requests window 32 active key at 977 and window 38 main resignation at 978 | Line 978 is TextEdit's request, not connection 2d503's. Resignation also occurs in success |
| Other connection's main appearance | 2d503 sets window 33 inactive main at 534; later sets window 36 active main and requests window 28 resign key/main at 547–550 | 2d503 sets window 38 active main at 832, asks window 32 to resign key/main at 833–835, then sets window 38 inactive main at 991 | Owner of 2d503 is not established here. A competing appearance request alone is not proof of a failure-causing action |
| Koine remote-menu tracking-end rules | 419, tick 4339031161, about 18.831 ms after 365 | 986, tick 4476939850, about 3.999 ms after 970 | Present after both calls; elapsed native ticks use the retained 125/3 ns scale, not a new application-clock calibration |
| Immediate endUserInteraction, nil source | 521, tick 4343144001 | 996, tick 4477304826 | Same form in both outcomes |
| TextEdit viewbridge rules | 427–428 after success; the earlier FOCUS comparison independently has the marker before successful native activations | ViewBridge termination 812; rules 813–816 before failure; terminal chain 947 | A marker can precede success without being unnecessary for failure |

The observed request interleaving is stronger than a summary of final window
appearance alone. It still does not establish a public setter for the relevant
interaction, the owner of every involved connection, complete native decision
coverage, or a positive failed disposition. A matched causal intervention cannot
be obtained merely by closing TextEdit or deleting a row from a fixture.

## Preserved boundary and verification

The [protocol](CAUSAL-PLAN.md), recorder and readers retain their original bytes.
The direct highlight and expected nonce, positive mouse pair, strict Return
identity, launch-prefix/all-ordinal accounting, exact containment classes and
failed-control policy are unchanged. The full original-duty comparison remains
in the [decision document](../../specs/settings-activation-discrimination.md#original-duty-comparison).
Historical candidates, archives, failed transports, partials, NOT RUN phases and
closed caps remain historical. No guest, product, test or Taskfile change runs
in this integration; document checks do not qualify native behavior.

The [original receipt](discrimination-evidence/verification.json) describes the
producer's earlier presentation only. The integration's
[verification receipt](discrimination-review-evidence/verification.json) records
the current document/presentation check and its limits. No causal ancestor closes.
