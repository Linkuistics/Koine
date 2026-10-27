# release-0-4-0-k5

## Goal

Ship Koine 0.4.0, the first cut of app and file search, by the route that 0.3.0
took. The human explicitly approves each public step.

## Context

- How 0.3.0 shipped: a version-only commit to `App/Info.plist`, "Release 0.3.0:
  Koine becomes a menu bar application" (`efcc0602`). Then an annotated tag
  `v0.3.0` with the message "Koine 0.3.0". Then a GitHub release, "Koine 0.3.0",
  on Linkuistics/Koine, whose asset is `Koine-0.3.0-aarch64-apple-darwin.zip`.
  Then a docs commit that names the verified release (`8fe3d933`). Last, a cask
  bump in `~/Development/homebrew-taps`, in `Casks/koine.rb` (`version`,
  `sha256`).
- The tasks are `task app`, `task app:notarize` and `task app:verify`. The
  release acceptance checks on the notarised build are
  `app:vm-verify-release`, `app:vm-verify-grant-workflows`,
  `app:vm-verify-notarized`, `app:vm-verify-menu-bar` and
  `app:vm-verify-disclosure`. The discovery check from `discovery-acceptance-k4`
  runs with them. After publishing, `app:vm-verify-homebrew` checks the
  published cask.
- The docs that name the verified release: the README's opening, the opening
  and "Acceptance status" of `docs/specs/machine.md`, and the release evidence
  under `docs/verification/`.

## Done when

- The human approved the final `workspace:read` disclosure text before
  anything is published.
- The notarised, stapled 0.4.0 bundle passes `task app:verify`, the release
  acceptance checks and the discovery check on the notarised build. The
  evidence is recorded in current-state terms.
- The `koine-desktop/1` contract still holds, and the conformance tasks pass.
- After the human's explicit approval of each step: `v0.4.0` is tagged and
  pushed, and the GitHub release is published with the notarised zip. The cask
  is bumped and pushed, and `task app:vm-verify-homebrew` passes against it.
- The docs name 0.4.0 as the verified release only for the claims that a 0.4.0
  run established again. A claim that rests on older evidence keeps saying so.
- With the human's approval, issue 10 is closed with a link to the release, and
  its item in issue 11 is ticked.

## Notes

- A tag, a GitHub release, a cask push and an issue edit are public and hard to
  take back. Stop before each one and ask the human. If nobody answers, end the
  session with the leaf live rather than publish.
- A check that fails on the notarised build is a defect. Fix it here if the fix
  is small. Otherwise, cut a leaf ahead of this one with `leaf-insert`. Do not
  publish around it.

## Decisions (running log)

- The human approved the `workspace:read` disclosure text after the first
  version changed. It names mounted network volumes and a remote home
  folder, as issue 13 asked. The text, its test and the four documents that
  repeat it changed together (`e6a24e03`).
- The release commit is `8429aecd`, and it built the notarised bundle. The tag
  `v0.4.0` points at it. The zip SHA-256 is
  `e1cd1481195e41a042a49cc2131d35fb12e34c0655c3e78375a965f7438af4e8`. The
  CDHash, the zip digest and the file digest did not change across any run.
- `task app` re-signs the bundle and drops the staple. `app:vm-verify-discovery`
  depends on it. The task `app:vm-verify-discovery-notarized` skips the rebuild
  and refuses an unstapled bundle. After a rebuild, `ditto` restores the bundle
  from the zip.
- Three check scripts were wrong, not Koine. The disclosure check expected one
  disclosure. The release check lost the consent dialog to OCR over stacked
  windows, and now falls back to the accessibility tree. The menu-bar check
  cannot resize by a drag in the macOS 27.0.1 guest, and now records that as
  NOT RUN. The released 0.3.0 bundle fails the last two in the same way.
- The menu-bar check passed on 5 of 9 runs of 0.4.0 and 3 of 3 runs of 0.3.0.
  The human chose to take more samples, log the finding, and continue. Issue 14
  holds it. The delivery rule says a finding blocks a release only if it breaks
  the happy path, and this one does not.
- The human approved each public step separately. The steps were the tag and
  push, the GitHub release, the cask bump, and the closing of issue 10 with the
  tick in issue 11.
  The cask is at `21f59c1` in `Linkuistics/homebrew-taps`. The repository is
  `~/Development/Delivery/homebrew-taps`, not the path in this leaf.
- `task app:vm-verify-homebrew` passed against the published cask on macOS 27.0.1
  (`homebrew-20261028T004952.log`). No 0.4.0 run used macOS 26.5, so the docs
  keep the 26.5 evidence under 0.3.0.
- The human also asked for the host to take the update. `brew upgrade` installed
  0.4.0 in `/Applications`, and the app was started.
