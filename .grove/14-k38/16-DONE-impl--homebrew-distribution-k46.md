# homebrew-distribution-k46

## Goal

Publish Koine and make it installable: Apache-2.0, a public `Linkuistics/Koine`,
a tagged release carrying the notarized artifact, a cask in
`Linkuistics/homebrew-taps`, and `brew install --cask` seen working in a clean
VM.

## Context

- **The human decided this when the stage was planned**, and it settles the
  open-source distribution question the root brief and this stage's planning
  leaf both parked. The full reasoning is in `release-acceptance-handoff-k11`'s
  running log. Do not reopen it; do check anything it does not cover.
- The tap is `~/Development/homebrew-taps` → `Linkuistics/homebrew-taps`
  (public), and `Casks/modaliser.rb` is the shape to follow. **Minus its
  `postflight`**: Modaliser's artifact is ad-hoc signed, so the cask strips
  `com.apple.quarantine` to get past Gatekeeper. Koine's is Developer ID signed
  and notarized, so it must not need that — and keeping the stanza would hide a
  notarization failure rather than reveal it. Its `uninstall quit:` and `zap`
  stanzas are worth reading for how they were reasoned about.
- Koine today has **no git remote, no `LICENSE`, and no tags**. `jj` is the
  working-tree VCS (workspace root `/Users/antony/Development/Koine`); the
  repository is also a git repo.
- The version is `CFBundleShortVersionString` in `App/Info.plist`, made the
  single source by `notarized-release-build-k39`.
- Koine's data lives in the per-user data directory and its login item is
  registered through `SMAppService.mainApp` — both matter for `uninstall` and
  `zap`.

## Done when

- **`LICENSE` is Apache-2.0**, matching every public Linkuistics repository, with
  the copyright line the siblings use.
- **`Linkuistics/Koine` is public** and pushed, with the documentation
  `documentation-and-handoff-k45` made current — that leaf runs first precisely
  so the first public README is the right one. Check before pushing that nothing
  in the history or working tree is unfit to publish: credentials, the notary
  key, absolute paths naming the human's machine, and anything under `.grove/`
  that was written on the assumption of privacy.
- **A tagged release** carries the notarized, stapled artifact as a zip whose
  name includes the version and `aarch64-apple-darwin` or equivalent, with a
  recorded SHA-256.
- **`Casks/koine.rb`** is in the tap: version, sha256, the release URL, `name`,
  `desc`, `homepage`, `depends_on macos:` and `arch: :arm64` matching the
  **stated support matrix** from `support-matrix-and-latency-k44` — not a
  guess, and not Modaliser's `:sonoma` copied across — `app "Koine.app"`,
  `uninstall quit: "dev.antony.Koine"`, and a `zap` that takes away Koine's data
  directory and its login-item registration.
- **`brew install --cask linkuistics/taps/koine` is verified in a clean VM**:
  it downloads, Gatekeeper accepts the notarized bundle with no quarantine
  stripping, Koine launches, and `brew uninstall --cask` removes it. This is the
  end-to-end proof that the notarization in `k39` actually does its job for a
  real user, which is the whole reason the cask has no `postflight`.
- **The README says how to install it**, and
  `docs/verification/homebrew-install-vm.md` records the run.

## Notes

**This is the one authorized edit to a sibling repository.** The stage brief's
rule stands otherwise: Koine sessions do not edit sibling repositories, and
ModalAnyware in particular is hands-off — its handoff is a note. The human
explicitly asked for Koine to be added to `homebrew-taps`, so the cask commit
there is authorized and nothing else in that repository is.

**Publishing is irreversible and outward-facing.** Making a repository public
and cutting a release both distribute content that can be cached and indexed
even if deleted afterwards. Confirm with the human immediately before the push
and before the release, showing what will be published — the repository name,
its visibility, the licence, the tag and the artifact. A plan approved at
planning time is not approval to publish at execution time.

**`.grove/` is in the working tree and will be published with it.** Decide
deliberately whether it should be — it is legible notes by design (constraint 6)
and contains the human's decisions and this project's reasoning, which is
defensible to publish, but it has never been written for an audience. This is a
question for the human, not a default either way.

**`brew audit --cask` and `brew style`** are the tap's own checks; run them
before committing, since a cask that fails audit is the tap's problem
afterwards.

**Do not let a Gatekeeper-disabled VM flatter the result.** The install
verification only means something on a clone whose assessments are enabled —
the same condition `notarized-release-build-k39` had to establish. If that run
found the condition impossible and the human accepted a weaker claim, carry the
same caveat here rather than implying the cask was proven on a stock machine.

## Decisions (running log)

- `LICENSE` is byte-identical to Modaliser's, AgentAnyware's, TestAnyware's and
  grove's (all one digest, "Copyright 2026 Linkuistics").
- The release zip is `Koine-<version>-aarch64-apple-darwin.zip`, named in
  `scripts/signing-env.sh`'s `RELEASE_ARTIFACT`. `task version` had never run:
  Task's own shell leaves `BASH_SOURCE` empty, so `signing-env.sh` resolved the
  repository as its parent; the task now sources it under bash.
- Pre-publication audit of the whole history (`git log --all -p`, 2.2 GB): no
  private key, AWS/GitHub/OpenAI/Slack token, `.p8`/`.p12`/`.pem` file, or App
  Store Connect key material — the `AuthKey_`, issuer and `store-credentials`
  hits are all placeholder instructions. Control: the team ID is found, a
  mutated one is not. Only one author email (the human's own). Absolute paths
  are `/Users/antony/Development/Koine` and `/Users/antony/.cache/uv` in
  verification evidence — the username only, already public in the bundle
  identifier. Largest blob 19 MB, under GitHub's limits.
- Homebrew's `uninstall login_item:` deletes System Events login items by
  AppleScript (`cask/artifact/abstract_uninstall.rb`, Homebrew 7.0.6) and needs
  Automation consent; Koine registers through `SMAppService.mainApp`, a
  Background Task Management entry, so what `zap` can do about it is measured in
  the VM rather than assumed.
- `task app` → `task app:notarize` → `task app:verify` at `999a12c5` produced
  `.build/app/Koine-0.1.0-aarch64-apple-darwin.zip`: Accepted, stapled, and
  assessed `source=Notarized Developer ID`. It is not published yet. Rebuild it
  from whatever commit is finally tagged.
- **Blocked on `compact-verification-evidence-k276`, cut ahead of this leaf.**
  Asked how to publish (full history, ~600 MB of blobs, `.grove/` in every
  commit), the human answered on 2026-09-29:
  - On `.grove/`: *"Stop tracking going forward."* This conflicts with grove,
    whose commit procedure depends on jj snapshotting a tracked `.grove/`. Past
    commits also still contain it. Untracking it would stop the loop driving
    this project. The reconciling option, not yet put to the human: keep it
    tracked locally and leave it out of a separate public history. Raise it
    again before pushing anything.
  - On size: *"We should not publish those 600MB blobs"* and the evidence needs
    analysing for a more compact form. That is k276.
  - Proposed and not chosen: a separate public history, i.e. a snapshot
    without `.grove/` and the two heavy evidence directories, with this repo
    staying private. It remains a candidate once k276 reports. Nothing has been
    pushed, no repository has been created, and nothing is tagged.
- The README's "Installing" section is already committed at `999a12c5`, ahead
  of the cask and of `docs/verification/homebrew-install-vm.md`. Its uninstall
  and `zap` sentences (login item forgotten, preferences removed) are
  provisional until the VM run measures them. Correct them from that run.
- On 2026-09-29 the human settled `.grove/`: it stays committed and tracked,
  because grove's `finish` deletes it; untracking is off the table. What the
  public history carries of the ~600 MB of past evidence blobs is still to settle.
- The human chose to rewrite the local history with `git-filter-repo`, keeping
  only the paths the tip has (28 MB of blobs across all commits, against the
  580 MB in removed paths), `.grove/` included. A bundle of the pre-rewrite
  repository is kept outside the tree. Local and public then share one
  history, so later publishes are an ordinary push.
- History rewritten: `git-filter-repo --paths-from-file` (tip paths) ran in a
  scratch bare repository, and the result came back as the `main` bookmark with `@`
  rebased onto it. Filtering in place would have rewritten jj's `refs/jj/keep`
  under its op log and `.jj/grove`'s driver state. The tip tree is identical (`088c9ef0`),
  176 commits are kept, and the pack is 3.65 MiB. The old commits were abandoned, the op log truncated,
  reflogs expired and gc'd. The pre-rewrite repository is
  `~/Development/Koine-pre-filter-2026-09-29.bundle` (136 MB, verified).
- The human's rule: `main` never carries `.grove/` at its tip. Grove works on a
  branch, and `main` moves only once `.grove/` is gone. The rewrite's `main` bookmark is
  renamed `grove`. For this leaf the human chose a publish commit: `main` is a
  commit on top of the grove tip that deletes `.grove/`, and it is pushed and
  tagged `v0.1.0`. At finish, the grove branch merges into `main`, as
  AgentAnyware's did. Earlier public commits still contain `.grove/`, as
  UIAnyware's do.
- Published on 2026-09-29 with the human's go-ahead: `Linkuistics/Koine` created
  public, `main` pushed at the publish commit `ee471613`, annotated tag `v0.1.0`
  on it, release `v0.1.0` carrying `Koine-0.1.0-aarch64-apple-darwin.zip`, built
  from the `grove` tip `fd4cc56b` (same source tree), SHA-256
  `26b091d54af3095d4360c95efddb87eb8fdec2c43bd76af7f3cb78d4651603fb`. The
  downloaded asset hashes the same.
- `Casks/koine.rb` is committed to the tap and pushed (`7dd12d88`, "koine 0.1.0").
  It has `depends_on arch: :arm64` and `macos: :tahoe` (a bare symbol means `>=`,
  read in `cask/dsl/depends_on.rb`), no `postflight`, `uninstall quit:`, and a `zap`
  of Application Support, the preferences plist and saved state, provisional
  until the VM measures what Koine writes. `brew style` is clean and
  `brew audit --cask --online --strict` passes. `--new` fails only on
  homebrew/cask's notability rule, which does not apply to a personal tap.
- `task app:vm-verify-homebrew` (`scripts/vm-verify-homebrew.sh`) is the
  install proof. It runs on a Gatekeeper-enforcing clone and installs Homebrew
  unattended through `SUDO_ASKPASS` if the golden lacks it. It checks
  `brew install --cask` of the published cask, Homebrew's quarantine intact, the
  notarized assessment and the first-run dialog. It then turns on login launch,
  runs a plain uninstall with Koine running, reinstalls and runs `--zap`,
  enumerating `~/Library` and `sfltool dumpbtm` after each step. Long guest steps
  run detached and are polled, because a retried exec must never repeat an install.
- **Blocked on the host's TestAnyware.** testanyware 2.1.0 (the Rust CLI)
  starts the macOS clone, but its agent client gets "connection refused" from
  `192.168.64.3:8648` while `curl` from the same shell gets
  `{"accessible":true}`, so `vm start` records no agent. Every agent command
  fails, which blocks every macOS VM run. Diagnosing that on the host needs the
  human.
- The human chose to split the VM proof into `homebrew-install-vm-k278` and
  retire k46. The README's "Installing" paragraph linked the not-yet-written
  evidence document (`task check:docs` failed on it) and made unmeasured
  login-item claims. It now states only what the cask declares, and k278 adds the
  measured sentences and the link. The published `main` still carries the old
  paragraph until the next publish commit.
