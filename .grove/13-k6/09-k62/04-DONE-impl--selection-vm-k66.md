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

## Decisions (running log)

**V reuses the N harness and runs in the guest.** `scripts/verify-selection-vm.py` imports `selection_harness` and the N driver's checks (its `main()` is now guarded) and runs inside the clone, so a V scenario is an N scenario with the same fresh host process, marker log and control pairing. What V changes is only what V is for: a quarantined install is a genuine download (`HostRun.download`: the archive carries `0181;…;Safari;<uuid>`, `ditto -x -k` gives it to the bundle), nothing is injected or pre-approved, and the driver records Gatekeeper's verdict on every staged copy beside the mapped paths. The old host is the released, notarized Koine.app downloaded in the guest, not a headless driver.

**Expectations follow `notarization.json`.** A notarized host and notarized update are accepted under quarantine; an un-notarized build is refused. The driver states both and selects, so the closing run needs no edit; an un-notarized run lists the rows it cannot close as PENDING, never as passing.

**The real workspace update is refused by the released host for framework 1.1, not for the feature.** Its stand-ins (`sk-r1.1.0`, kept and renamed) need no framework minor and isolate the feature.

**Blocked: no notary credential in this session.** `xcrun notarytool history --keychain-profile koine-notary` finds no item. Not explored further. The leaf is NOT retired: its Done-when requires purpose-built V hosts "signed and notarized first". `task selection:vm-hosts -- --unnotarized` and `task selection:vm` ran green (133 host runs, 2 022 checks, no dialog) and are recorded in `docs/verification/selection-vm.md` as observed on un-notarized hosts. To close: store the profile, `task selection:vm-hosts && task selection:vm`, then update the evidence and retire.

**Unblocked and closed.** The notary profile was stored; `task selection:vm-hosts` notarized and stapled six hosts and two real updates (the released-desktop bundle needed its seal made again with a timestamp, as every embedded bundle does), and `task selection:vm` ran green on notarized hosts: 133 host runs, 2 050 checks, no dialog. A notarized host is a download, so its bundled providers' staged copies inherit its attribute; the V driver holds them to the host's own state. Fixtures now build for macOS 26 (`MINIMUM_OS`), the loader test reads 26.0. Machine's V cells link `docs/verification/selection-vm.md`; only the second-team parts stay pending, in `alternate-team-signing`.
