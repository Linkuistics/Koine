# homebrew-install-vm-k278

## Goal

Prove the published cask works for a real user: `brew install --cask
linkuistics/taps/koine` on a clean, Gatekeeper-enforcing VM downloads the
notarized release, Gatekeeper accepts it with its quarantine intact, Koine
launches, and `brew uninstall --cask` removes it. Then make the cask's `zap`
and the README's uninstall sentences match what the run measured. Cut from
`homebrew-distribution-k46`, which published everything else, when the host's
TestAnyware could not drive a macOS guest.

## Context

- **Published and not to be redone**: `Linkuistics/Koine` is public; `main` is at
  `ee471613`, the commit that deletes `.grove/` on top of the grove tip. Tag `v0.1.0` and
  its release carry `Koine-0.1.0-aarch64-apple-darwin.zip`, SHA-256
  `26b091d54af3095d4360c95efddb87eb8fdec2c43bd76af7f3cb78d4651603fb`.
  `Casks/koine.rb` is in `Linkuistics/homebrew-taps` at `7dd12d88`. k46's
  running log holds the reasoning.
- **The instrument is written**: `task app:vm-verify-homebrew`
  (`scripts/vm-verify-homebrew.sh`). It has never run, so expect to debug it —
  in particular the unattended Homebrew install (`SUDO_ASKPASS`), the detached
  `guest_long` polling, and whether Homebrew's quarantine value produces the
  "downloaded from the Internet" first-run dialog `first_launch_quarantined`
  waits for.
- **Why it was cut**: testanyware 2.1.0 started the macOS clone, but its agent
  client got "connection refused" from the guest's `:8648` while `curl` from
  the same host shell got `{"accessible":true}`, so `vm start` recorded no
  agent and every agent command failed. It is a host or TestAnyware problem,
  not Koine's; the human is resolving it. Check `testanyware agent health` on
  a started clone before running the script.

## Done when

- `task app:vm-verify-homebrew` passes on a Gatekeeper-enforcing clone
  (assessments and developer id both enabled, asserted in the run), and
  `docs/verification/homebrew-install-vm.md` records the run: the machine, OS
  and Homebrew version, the quarantine value, the assessment, the first-run
  dialog, and the `~/Library` footprint and `sfltool dumpbtm` entry at each of
  running, after a plain uninstall, and after `--zap`.
- The cask's `zap trash:` list matches the measured footprint — no missed path,
  no speculative one — and whatever the run shows about the login-item
  registration after uninstall is stated in the README's "Installing" section.
  If `zap` has to change, the tap commit is the same authorized kind as k46's
  (only `Casks/koine.rb`); run `brew style` and `brew audit --cask --online
  --strict` first.
- The README's "Installing" section links the evidence document, and `task
  check:docs` passes.

## Notes

**Do not let a Gatekeeper-disabled VM flatter the result.** The script asserts
the enforcing state; do not weaken that assertion to get a green run.

**Publishing rules still bind.** `main` never carries `.grove/` at its tip. To
publish README or doc changes, build another publish commit the way k46 did
(the grove tip with `.grove/` deleted) and confirm with the human before
pushing. Any tap push needs the same confirmation.
