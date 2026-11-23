# settings-testanyware-3-amendment-k177

## Goal

Amend the ordering protocol and the shared harness to TestAnyware 3.0.0. Recheck
each cited payload format against that release before k54 freezes a subject.

## Context

The owner chose 3.0.0 on 2026-11-23. The decisions log of
`settings-ordering-qualification-k54` holds that choice. The harness cites 17
TestAnyware source files at tag v2.7.0.

The installed tool is `/opt/homebrew/Cellar/testanyware/3.0.0/bin/testanyware`.
Its SHA-256 is
`4587ab560fd77877cd9a21b683ab004dc365e1f603084e1c5dc6e5fdb42eb47e`. Tag v3.0.0
is commit `097ed8f7337ed9142c1aa8cda926a513c03108a4`.

Read the tagged sources with `git -C` and `git show v3.0.0:<path>` from
`../TestAnyware.gh-issue-13`. Another session owns that worktree, so do not edit
it or depend on its working files.

These eight cited files changed between v2.7.0 and v3.0.0:

- `agents/macos/Sources/TestAnywareAgent/ProcessRunner.swift`
- `cli-rs/crates/testanyware-agent-client/src/lib.rs`
- `cli-rs/crates/testanyware-cli/src/commands/file.rs`
- `cli-rs/crates/testanyware-cli/src/commands/screen.rs`
- `cli-rs/crates/testanyware-cli/src/commands/vm.rs`
- `cli-rs/crates/testanyware-cli/src/main.rs`
- `cli-rs/crates/testanyware-cli/src/output.rs`
- `cli-rs/crates/testanyware-vm/src/tart.rs`

## Done when

- Each of the 17 citations names v3.0.0, after a recheck of the format or
  behaviour that the harness takes from that file. Record each result.
- The harness and its controls match each changed format. Repair a mismatch
  without a weaker check, a retry or a wider tolerance.
- Each behaviour change in the v3.0.0 release notes has a recorded disposition
  against the protocol. These changes need an explicit answer:
  - `vm start` ends with a VNC size wait. After 30 seconds, it prints a warning
    and still succeeds.
  - OCR replaces a failed Vision worker and sends the request once more. Check
    this internal retry against the one-attempt rule.
  - `screen capture` crops by the size of the captured frame.
  - `agent snapshot` can return the menu bar when a background helper has focus.
  - The VNC keeper no longer exists.
- `ORDERING-EVALUATION-PLAN.md` names TestAnyware 3.0.0. Leave its guest macOS
  release for k54, because the final golden image decides that fact.
- `task check:settings-duty-ledger -- --require-closed` passes. Recheck each
  ledger row whose source or control changed.
- The harness checks pass, including `task check:vm-settings-sequence`.

## Notes

Start no guest, clone or golden build. Do not stop `testanyware-setup-dbf7834f`.

If a release behaviour conflicts with a reviewed protocol rule and no strict
repair exists, ask the owner. Do not relax the rule.

A changed harness reopens the affected checks and earned reviews. If the changes
to a transport or an evidence class are load-bearing, cut a `review-impl` leaf
for this handle before k54.
