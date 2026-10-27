# menu-bar-samples-k4

## Goal

Measure the repaired menu-bar scenario over a declared, bounded comparison and
leave an accurate verification record for issue 14, including every failure and
any assertion that did not run.

## Context

- `docs/verification/menu-bar-vm.md` and the preceding menu-interaction-k2 and
  window-resize-k3 artifacts.
- `Taskfile.yml`, `app:vm-verify-menu-bar`, and the scenario's sourced helpers.
- Issue 14's historical 0.4.0 5/9 and 0.3.0 3/3 results are small historical
  samples, not proof of a release regression.

## Done when

- Before sampling, record the exact bundle subjects, script/input identities,
  guest image, OS/build, TestAnyware version, display configuration, run order,
  attempt cap and stopping rule. Use matched fresh-guest conditions for the
  released 0.3.0 and 0.4.0 bundles where available. If an application repair was
  necessary, identify its candidate bundle separately rather than calling it
  the released 0.4.0 image. No new release is required to collect these samples.
- Declare a finite diagnostic sample, not a statistical reliability promise.
  End at the cap or a finding that requires a new repair. Never rerun until only
  green outcomes remain, or pool results across a mid-run script/bundle edit.
- Record each started attempt, exit outcome, completed assertions, NOT RUN
  assertions and interruption. Keep per-attempt logs/screenshots and one writer
  per result. Hash the actual subjects before and after the measurement.
- Preserve complete scenario coverage, including first launch, repeated menu
  reopening, requests, consent, shortcuts, silent launch, login restart and Quit.
  Resize success is credited only when that assertion actually ran.
- Update the existing verification record and any directly affected public
  claims. Explain what the finite sample establishes and what remains unknown.
  Make any residual failure actionable without declaring it repaired or silently
  closing an unresolved issue.

## Notes

The preceding leaves must leave their scripts settled before this measurement.
If this sample reveals a new cause, retain its failed evidence and cut the
specific repair before a fresh measurement. An outcome requiring a future
release remains explicit; it does not authorize releasing one here.
