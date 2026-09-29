# plan-k4

**Integrates:** plan-k2

## Goal

Triage `plan-k2`'s review of the agreed requirements and apply the real
findings to `docs/requirements/modaliser-workflows.md` before `providers-k3`
plans from it. Apply the scope change Antony made during that review as well.

## Context

- Read the findings and the running decision log from `plan-k2`'s own commit.
  This body names the review and does not restate them.
- `plan-k1` holds the configuration evidence and the settled interview
  decisions the findings are graded against.

## Done when

The requirements document reflects the human scope change recorded in
`plan-k2`'s running log. Each finding is classified as a contract stated
unclearly, a real issue, a visible trade-off, or noise, with the document
changed accordingly. Findings whose answer is Antony's are settled with him,
or explicitly left open for design with his agreement. The root brief's
decomposition and pointers stay consistent with the narrowed baseline.

## Notes

Several findings ask Antony for a scope or risk decision rather than an
edit, so expect to stop and ask. Frame each as a trade-off with a
recommendation. The design questions listed in the review are planning's and
design's, not this leaf's; carry them forward rather than answering them here.

The scope change reaches beyond the requirements document. The root brief
still says "all active bindings" (`_BRIEF.md:28`). `providers-k3`'s notes still
ask how to design VS Code parts/Grove and the nested Zellij/Neovim chain.
Align both with the narrowed baseline.
