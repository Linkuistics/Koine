# Settings activation design discussion

The [decision document](../../../specs/settings-activation-discrimination.md)
owns the evidence limits, proposed scope amendment and unchanged acceptance duties.
The current decision is to keep all route and modality guests unstarted. Antony's
scope choice remains pending.

Run `mise exec -- task design:serve PORT=8799` from the repository root and open
[the current discussion](http://127.0.0.1:8799/settings-activation/#discussion).
The existing task serves only the architecture presentation directory.

Start each graph at the dark **Start here** node. Arrows describe reasoning and
decision alternatives, not measured event order or proven causal relationships.
The editable sources are Mermaid; the bundled viewer loads Mermaid 12.0.0 from
jsDelivr and needs network access. Reload after changes; no export build is used.

- [Evidence → Why the current probe does not discriminate cause](http://127.0.0.1:8799/settings-activation/#diagram-evidence-limit) — Added the positive contrast, its uncertain causal direction and the one-sided modality falsifier.
- [Scope → Choose the proof required before repair evaluation](http://127.0.0.1:8799/settings-activation/#diagram-scope-choice) — Added the proposed amendment and two alternatives, with all existing slots held.
- [Scope decision for Antony](../../../specs/settings-activation-discrimination.md#scope-decision-for-antony) — Specifies exactly which prerequisite would change and which duties remain.
