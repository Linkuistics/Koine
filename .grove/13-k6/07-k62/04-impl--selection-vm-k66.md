# selection-vm-k66

## Goal

Accept every V-assigned selection row in signed isolated TestAnyware macOS VMs.

## Context

- `docs/specs/machine.md`: the V rows this node's brief assigns here, and
  "Loading and trust" on quarantine.
- The N and G evidence from `selection-updates-k65`, and the existing notarized
  and provider VM recipes.

## Done when

- Old host with old desktop, and the new host with the old baseline, preserve
  desktop operations.
- The update rows are observed on signed hosts: a compatible newer desktop or
  workspace update is selected; the pre-extension host refuses both normal and
  renamed-principal updates; and the fixture signing identifier is refused.
- Trust refusals are observed on an intact notarized host with genuinely
  quarantined downloads. Each case shows the lower selection with its diagnostics
  and no unexpected dialog. Any purpose-built V host is signed and notarized
  first.
- Candidate-specific staging with quarantine and a legacy entry is observed
  across restart, with the actual assessment and loaded paths recorded.
- Mixed releases are recorded as native observations.
- Cases needing a second team's certificate are recorded pending with that
  prerequisite, unless the certificate is available here.
- Reusable Taskfile VM recipes exist. Evidence documents land under
  `docs/verification/`, and Machine's table and acceptance status link them.
