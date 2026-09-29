# plan-k2

**Reviews:** plan-k1

## Goal

Adversarially review the agreed configured-workflow and application-menu
requirements before planning uses them. Inspect and report findings; do not
implement fixes or reopen settled preferences merely to choose a mechanism.

## Context

- `docs/requirements/modaliser-workflows.md` is the agreed contract.
- Resolve `plan-k1` for the configuration evidence and the running decision log.
- The source baseline is Antony's `~/.config/modaliser/config.scm` and its
  sixteen included `app-trees/*.scm` files, plus the actions supplied by bound
  constructors in the installed/mirrored Scheme libraries.
- `docs/specs/machine.md`, `docs/client-guide.md`, the cited ADRs and `CONTEXT.md`
  carry the existing Koine contract and vocabulary.

## Done when

A finding report anchored to the producer's committed artifacts distinguishes
requirements defects from design questions and accepted trade-offs. The report
tests the doubts below against the source and the human's recorded decisions.
Any worthwhile findings are handed to an adjacent integration leaf through
the review kind's normal procedure; an empty review creates no integration.

## Notes

The artifact is load-bearing across multiple integrations. In particular:

- Check reachable behavior, including launcher secondary actions, Google
  suggestions, generated pane/list choices and integration setup, rather than
  only counting top-level keys. Distinguish unreachable helpers and a
  conditional screen from the agreed active baseline.
- Check the Paneru evidence boundary: the current derived-path installation
  probe is reproducible, but the running engine's cached branch was not read.
  Do not turn that limitation into an unsupported exhaustive claim.
- Check that intended application results are preserved without treating the
  annotated Signal/Messages chords or outdated comments as proof of behavior.
- Check the agreed menu semantics together: both menu types and context target
  modes, explicit opening, required metadata without icons, focus-loss cleanup
  and rejection of unverifiable stale selections. Look for contradictions with
  read purity, authorization, reference identity or the accepted public AX
  limits, especially cleanup after the foreground app changes.
- Check that the client/server allocation and acceptance remain sufficient to
  demonstrate the baseline without implementing or restarting ModalAnyware.
  A future design question is not itself a missing behavioral requirement.

Graph evidence in the producer used Tier 2. Koine generation was
`2026-09-29T10:36:20Z` (fast); Modaliser was `2026-09-16T05:15:24Z`.
Koine docs are excluded and were read directly. User configuration and installed
libraries are outside those indexes; Scheme library paths had untracked
freshness, so direct installed source and mirror comparisons were used.
Refresh project/generation and exact coverage before new structural claims.
