# pointer-media-acceptance-k5

## Goal

Accept pointer and media on the signed bundle with the N check and one
happy-path VM run.

## Context

- The precedent is the acceptance of window layout:
  `docs/verification/desktop-window-layout-compatibility.md`,
  `docs/verification/desktop-window-layout-vm.md` and
  `task app:vm-verify-window-layout`.
- The root brief holds the agreed V cases under its test seams.

## Done when

- The compatibility pairs pass. The new host loads the signed bundle, and the
  released 0.5.0 host treats it as the design states.
- A new Taskfile task runs the V cases with an independent witness, and one
  run passes.
- The run settles which codes for next and previous a player honours. If
  Modaliser's codes fail, this leaf changes them, and the passing run uses the
  settled codes.
- A verification record holds the procedure, the evidence and what the run
  does not claim.
- The trace rows link the evidence.

## Notes

- The tracks are silent, because the sound of the guest reaches the speakers
  of the host.
- If the VM cannot keep a player playing, or no witness can see a hidden
  pointer appear again, follow the notes of the root brief.
