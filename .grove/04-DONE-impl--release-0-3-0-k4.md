# release-0-3-0-k4

## Goal

Ship Koine 0.3.0, the menu bar application, through the route 0.2.0 took, with
the human explicitly confirming each outward-facing step.

## Context

- How 0.2.0 shipped: a version-only commit to `App/Info.plist` ("Release
  0.2.0: …"); an annotated tag `v0.2.0` ("Koine 0.2.0"); a GitHub release on
  Linkuistics/Koine whose asset is `Koine-<version>-aarch64-apple-darwin.zip`;
  a docs commit naming the verified release; and a cask bump in
  `~/Development/homebrew-taps` (`Casks/koine.rb`: `version`, `sha256`) with
  the message "koine 0.2.0".
- Tasks: `task app`, `task app:notarize`, `task app:verify` (checks the
  version, signature, stapled ticket and Gatekeeper acceptance), then the
  release acceptance checks on the notarized build (`app:vm-verify-release`,
  `app:vm-verify-grant-workflows`, `app:vm-verify-notarized`) and
  `app:vm-verify-menu-bar`. After publishing, `app:vm-verify-homebrew`
  checks the published cask.
- Docs naming the verified release: the README's opening ("Koine 0.2.0
  implements…", "Koine 0.2.0 is notarized and verified…"), the opening and
  "Acceptance status" of `docs/specs/machine.md`, and the release evidence
  under `docs/verification/` (`release-acceptance-vm.md`,
  `notarized-release-vm.md`, `homebrew-install-vm.md`).

## Done when

- The notarized, stapled 0.3.0 bundle passes `task app:verify`, the release
  acceptance checks and the menu bar check on the notarized build, with the
  evidence recorded in current-state terms.
- The served schema is unchanged: the `koine-desktop/1` contract and the
  schema conformance check pass as before.
- After the human's explicit go-ahead for each step: `v0.3.0` is tagged and
  pushed, the GitHub release is published with the notarized zip, and the
  cask is bumped and pushed. `task app:vm-verify-homebrew` passes against the
  published cask.
- Docs name 0.3.0 as the verified release only for claims a 0.3.0 run
  re-established. A claim resting on 0.2.0 evidence alone keeps saying so; it
  is not relabelled.

## Notes

- Tagging, the GitHub release and the cask push are public and hard to take
  back. Stop before each one and ask the human. If nobody answers, end the
  session with the leaf live rather than publish.
- A check that fails on the notarized build is a defect: fix it here if the
  fix is small, otherwise cut a leaf ahead of this one with `leaf-insert`, and
  don't publish around it.

## Decisions (running log)

- **Notarization is not blocked.** An earlier session stopped believing there was
  no `koine-notary` profile; `xcrun notarytool history --keychain-profile
  koine-notary` answers from this session, and `task app:notarize` was Accepted
  (submission `a216930f-6424-4106-a4fb-31659ba17d9c`) and stapled. Nothing was
  missing on the human's side.
- **Verified on the notarized 0.3.0 bundle:** `task app:verify`;
  `app:vm-verify-notarized`; `app:vm-verify-menu-bar`; `app:vm-verify-release`
  and `app:vm-verify-grant-workflows` (the last two after the fixes below);
  `task conformance` (all three profiles, the served digest equal to the design
  file's, so `koine-desktop/1` is unchanged). `app:vm-verify-disclosure` and the
  other release routes were not rerun.
- **Two checks failed first, both for the check:** `vm-verify-release.sh` read
  the screen once, three seconds after the Request click, and reported no consent
  dialog while the capture taken right after shows macOS's dialog naming Koine; it
  now reads until the dialog shows. `vm-verify-grant-workflows.sh` swept the whole
  pending list, then looked for its chosen row from wherever the sweep ended; it
  now scrolls back to the top first. Koine reached all 16 rows by scrolling in the
  failing run.
- **Docs:** README and `docs/specs/machine.md` name 0.3.0 for what this run
  re-established; the provider-selection acceptance says "recorded before 0.3.0"
  because it was not re-run. `release-acceptance-vm.md` and `menu-bar-vm.md`
  carry the 0.3.0 runs; `notarized-release-vm.md` keeps its 0.1.0 transcript, which its table
  describes step for step, and says the current script also passes on 0.3.0.
  `homebrew-install-vm.md` carries the 0.3.0 runs (below).
- **Published, each after the human's explicit go-ahead:** annotated tag `v0.3.0`
  on `efcc0602` pushed to Linkuistics/Koine; GitHub release "Koine 0.3.0" (latest)
  with `Koine-0.3.0-aarch64-apple-darwin.zip`, whose reported digest equals the
  local zip's (`b6b6f085…0200`); cask bumped in Linkuistics/homebrew-taps as
  "koine 0.3.0" (`0e349da`, `Casks/koine.rb` version and sha256 only).
- **`task app:vm-verify-homebrew` passes against the published cask, on macOS 26.5
  and 27.0.1.** It could not run for a time: TestAnyware 2.1.0 and 2.2.0 left the
  agent out of the VM's connection spec (Linkuistics/TestAnyware#3; 2.3.0 no longer shows it),
  and 2.3.0 then showed the real block, that nothing launched from herdr has Local
  Network permission, so `testanyware` got "No route to host" while `curl` from the
  same shell did not. The check was run from a `.command` file opened with Terminal,
  once on the default golden (`testanyware-golden-macos-27`, macOS 27.0.1) and once
  with `KOINE_VM_BASE=testanyware-golden-macos-tahoe` (macOS 26.5, the supported
  floor). Each installed 0.3.0 from the published release, Gatekeeper accepted it as
  notarized with its quarantine intact, Koine launched and served, and uninstall and
  `--zap` removed it.
- **Two claims in `homebrew-install-vm.md` and the README changed with 0.3.0.** The
  saved-window-state helper reports none at any stage on both guests (the 0.2.0 run
  found files in talagent's container), so the README no longer says macOS keeps
  saved window state for Koine; the doc keeps the 0.2.0 finding labelled as such.
  The Background Task Management entry still survives uninstall and `--zap`. The cask's
  `zap` comment in homebrew-taps still says macOS 26 keeps an app's saved window
  state under a per-machine UUID; that is about macOS and was not touched (the cask
  is published).
- **Not changed:** `latency-and-support-matrix.md` says the only golden image is macOS
  26, which a macOS 27 golden now contradicts; the support claim (macOS 26) stands.
- **Commits (local):** the two check fixes and
  `Release 0.3.0: Koine becomes a menu bar application`. The docs and this note are
  uncommitted in the working copy and belong to the commit that retires the leaf.
