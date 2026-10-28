# Settings activation design discussion

The [repair and evidence contract](../../../specs/settings-activation-discrimination.md)
records Antony's accepted scope: design a justified correction using one
activation request while leaving native cause and ownership unresolved. Repetition,
driver waits/retries, deferral and speculative yielding remain excluded.

The [correction assessment](../../../verification/settings-activation/CORRECTION-ASSESSMENT.md)
finds no qualifying candidate in the inspected path. Independent review must
challenge that bounded finding before the pending explicit scope decision.
An empirical activation-before-window-ordering design is proposed only; no new
scope, implementation, cap or guest is selected. Separate complete ordinary-VM
acceptance remains required. All six existing causal slots stay held/unstarted.

Run `mise exec -- task design:serve PORT=8801` from the repository root and open
[the current discussion](http://127.0.0.1:8801/settings-activation/#discussion).
The existing task serves only the architecture presentation directory.

Start each graph at the dark **Start here** node. The assessment view numbers
the existing application call order, then uses a dotted edge to enter reasoning.
The other views describe reasoning and decision alternatives. None is a measured
native event order or proven causal relationship.
The editable sources are Mermaid; the bundled viewer loads Mermaid 12.0.0 from
jsDelivr and needs network access. Reload after changes; no export build is used.
The local index is a relative symlink to the shared architecture viewer. The
[parent outline](../index.html#diagram-settings-activation-evidence-limit) also
loads these same sources; its other current discussion remains separate.

Current changes:

- [Correction → Current path and the unresolved correction choice](http://127.0.0.1:8801/settings-activation/#diagram-correction-assessment) — Adds the current one-request path, bounded no-candidate finding and pending scope branches.
- [Correction assessment](../../../specs/settings-activation-discrimination.md#correction-assessment) — Records the finding and distinguishes the new empirical-design proposal from the accepted API-use test.

Unchanged context is the [evidence limit](http://127.0.0.1:8801/settings-activation/#diagram-evidence-limit)
and [accepted scope](http://127.0.0.1:8801/settings-activation/#diagram-scope-choice).

The [review integration](../../../verification/settings-activation/DISCRIMINATION-REVIEW.md)
records the evidence corrections and presentation checks. The original
[verification receipt](../../../verification/settings-activation/discrimination-evidence/verification.json)
and [raw documentation output](../../../verification/settings-activation/discrimination-evidence/doc-links.txt)
describe the earlier presentation only; they are retained unchanged.
