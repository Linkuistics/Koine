# app-input-acceptance-k6

## Goal

Accept app input on the signed bundle with the N check, one happy-path VM run
and the scheduled check on Antony's Mac.

## Context

- The precedent is the acceptance of pointer and media:
  `docs/verification/desktop-pointer-media-compatibility.md`,
  `docs/verification/desktop-pointer-media-vm.md` and
  `task app:vm-verify-pointer-media`.
- `task compat:released-0.5.0` shows how the pairs build a released host from
  its tag.
- The root brief holds the agreed V cases and the host check under its test
  seams.

## Done when

- The compatibility pairs pass. The new host loads the signed input bundle,
  and the released 0.6.0 host refuses it before load.
- A new Taskfile task runs the V cases with independent witnesses, and one
  run passes.
- Antony approved the procedure and the chords of the host check, and he set
  its time. The check ran at that time, and it passed.
- A verification record holds the procedure, the evidence and what the runs
  do not claim.
- The trace rows link the evidence.

## Notes

- The host check sends one harmless chord each to Dia and Telegram. Propose a
  chord per app whose effect a witness can read, and a way to undo the effect.
- The host check leaves Antony's installed Koine, its grants and his apps as
  it found them. State how in the proposal.
- Until Antony sets the time, the leaf stays live. Ask him, and finish the
  turn while you wait.
- One V case sends a chord to Safari in the background. The probe sent a
  chord to Finder in the background only. If Safari ignores the chord, stop
  and ask Antony, because route A has no fallback.
