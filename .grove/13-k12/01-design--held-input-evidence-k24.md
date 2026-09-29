# held-input-evidence-k24

## Goal

Establish, from the signed hardened Koine in an isolated VM, how a held-modifier
interaction with Dia behaves. Establish what is observable when it is
interrupted or Koine dies.

## Context

- `app-input-evidence-k22` and `app-input-k34` for how input reaches a target.
- `menu-evidence-k23` for opened-menu behavior on foreground loss.
- Modaliser's Dia tree and input library show the walk's mechanics, and its
  self-healing modifier release on the next entry shows that stuck holds
  happen.

## Done when

A `docs/verification/` document answers:

- Can Koine's synthesized Control hold, steps, release and pre-release
  dismissal drive Dia's recent-tab chooser to its confirm and cancel outcomes?
- What does a newly active application observe when Koine releases its owned
  modifier?
- How is loss of target foreground observed, and with what latency? Can the
  observation be attributed to a declared client presentation without trusting
  labels?
- After abrupt Koine termination with a held modifier or open menu, what
  state remains? What recovery restores it without replaying the interrupted
  action?

It ends with inputs for `interaction-lifecycle-k38`.

## Notes

This question is bounded. A residue public API cannot clear becomes documented
recovery guidance, which is already an accepted case, not a deeper chain.
