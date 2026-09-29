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

## Decisions (running log)

- **The agent fault is narrowed to the `testanyware` binary under this
  session's sandbox; the run is still blocked.** With testanyware 2.1.0
  (`doctor` clean) a fresh macOS clone at `192.168.64.2` again recorded
  `agent=-`. From the same sandboxed shell, `curl` (with `--noproxy '*'`),
  `nc -z`, and a raw TCP connect from both `/usr/bin/python3` and Homebrew's
  `python3` all reach `:8648`, and `curl` gets `{"accessible":true}`.
  `testanyware agent health --agent 192.168.64.2:8648` gets
  `CONNECTION_REFUSED`, yet it reaches a local `127.0.0.1` HTTP server.
  There are no proxy variables in the environment and no macOS system proxy
  (`scutil --proxy`). `RUST_LOG=trace` prints nothing, and the unified log
  shows no denial. testanyware reports every failed connect as
  `CONNECTION_REFUSED`, so the underlying errno is unknown. Running it outside
  the sandbox was refused by the permission classifier, so this session could
  not test whether the sandbox is the cause. The human then restarted the
  host, which has cleared a fault like this before. Next session: start a
  clone and run `testanyware agent health` first. If it answers, the fault is
  gone; proceed with `task app:vm-verify-homebrew`. If it still refuses while
  `curl` reaches `:8648`, do not re-investigate. Ask the human to run
  `! testanyware agent health` outside the sandbox. If that works, the sandbox
  is the cause, and the task needs a permission rule to run unsandboxed (or
  the human runs it).
- **The host restart cleared the agent fault.** A fresh clone
  (`testanyware-465aae89`, macOS 26.5 25F71, arm64) recorded
  `agent=192.168.64.3:8648` and `testanyware agent health` answered `OK` from
  this session's sandboxed shell, so the run proceeds with
  `task app:vm-verify-homebrew` and no sandbox permission rule is needed.
- **The first run passed but is not the evidence run: its reinstall never
  happened.** `homebrew-20260929T185757.log` shows the cask installed from the
  published release (quarantine `0181;…;Homebrew\x20Cask;…`, `accepted` /
  `source=Notarized Developer ID`, the notarized first-run dialog), but the
  reinstall before `--zap` logged only "Not upgrading koine, the latest version
  is already installed". Done by hand in the same guest, install → uninstall →
  install works and the Caskroom is empty in between, so the fault is
  `guest_long`: `guest()` silently retries an exec that falsely times out, which
  can launch the detached script twice and let the loser truncate the log. The
  launch is made idempotent with a guard directory and the reinstall is
  asserted.
- **Homebrew's "Trashing files:" listing is not evidence a path existed.**
  Homebrew 6.0.3's `uninstall_trash` prints `resolved_paths.map(&:first)`, the
  declared paths, whether or not `Pathname.glob` found them. The first run's
  footprint was `~/Library/Application Support/Koine` alone, cfprefsd had no
  `dev.antony.Koine` domain and the guest had no `Saved Application State`
  directory. Koine's code writes no defaults and has no status item, but the
  guest ran macOS's default "close windows when quitting", under which AppKit
  saves no window state. So the evidence run turns window restoration on
  (`NSQuitAlwaysKeepsWindows`) before launch and asks cfprefsd for the domain,
  and the zap list follows the maximal footprint that run measures.
- **Koine's saved window state lives where no zap can name it.** Run
  `homebrew-20260929T191236.log` passed with the reinstall asserted, and its
  name search again found only `Application Support/Koine`, with no defaults
  domain. A search of the guest for any `.savedState` found that on macOS 26
  AppKit writes `<uuid>.savedState` in talagent's Daemon Container, mapped to
  `dev.antony.Koine` (team `TA43A4RUP3`) by `ApplicationMapping.plist` beside it.
  Koine's was still there after `--zap`, holding a window titled "Koine". A
  hand probe with the global setting deleted (macOS's default) showed the
  directory re-created but empty. So the cask's
  `~/Library/Saved Application State/dev.antony.Koine.savedState` and
  `~/Library/Preferences/dev.antony.Koine.plist` are both paths nothing on the
  supported matrix writes, and `zap` shrinks to `Application Support/Koine`.
  `scripts/vm-verify-saved-state.sh` resolves the state through the mapping,
  seen to find it and, with the identifier mutated, to find nothing. The run
  reports it rather than asserting on it. Making the management window
  non-restorable would stop Koine writing the state, but it is a code change
  and a new release, so it is left to the human rather than cut here.
- **Evidence run and the human's three answers.** `homebrew-20260929T195105.log`
  passed on the final instrument and is the run
  `docs/verification/homebrew-install-vm.md` records. The human agreed to:
  push the tap commit shrinking `zap` to `Application Support/Koine` (`brew
  style` clean; `brew audit --cask --online --strict` exit 0, and 1 on a
  mutated copy, run in a throwaway local tap because audit refuses paths);
  publish to `Linkuistics/Koine` `main` as a merge of `ee471613` and the grove
  tip with `.grove/` deleted, so the push fast-forwards and `v0.1.0` does not
  move; and leave the saved window state documented rather than cutting a
  non-restorable-window leaf.
