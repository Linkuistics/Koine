# window-layout-acceptance-k6

## Goal

Accept the first cut with the N check and the one happy-path VM run.

## Context

- The root brief's Pointers list the V checks that the human agreed.
- The VM tasks `app:vm-verify-desktop`, `app:vm-verify-desktop-focus` and
  `app:vm-verify-desktop-remembered` hold the pattern, with an independent
  native witness.

## Done when

- The compatibility tasks pass. The new host loads the new desktop bundle.
  The released 0.4.1 host refuses it before load, because it lacks
  `desktop-disclosures-v1`, and the compatibility record states this.
- A new Taskfile task runs the V checks in a TestAnyware macOS VM on the
  signed bundle, and every check passes.
- A record in `docs/verification/` holds the run's evidence and states the
  one-display limit.

## Notes

- A permission dialog other than Accessibility is a stop (root brief,
  Notes).
