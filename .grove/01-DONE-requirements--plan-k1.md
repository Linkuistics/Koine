# plan-k1

## Goal

Set the scope of the issue-15 grove with Antony. The grove brings back the
Settings activation-order repair that the issue-14 grove closed as unresolved.

## Context

- GitHub issue 15 holds the deferred evaluation and five steps before a new run.
- GitHub issue 14 holds the intermittent failures of the menu-bar VM check.
- `docs/specs/settings-activation-discrimination.md`, section "Current decision".
- `docs/verification/settings-activation/ORDERING-QUALIFICATION-RESULTS.md`
  records the E01 stop.
- `settings_expect_setup` in `scripts/vm-settings-scenario-lib.sh` makes the
  front read that stopped E01.
- Commit `561dbf6c` holds the candidate call order. Commit `06ccc06d` returned
  `main` to the released order.

## Done when

- Antony agrees to the summarised scope.
- The brief records the goal, the done condition and the decomposition.
- The tree holds the leaves that the decomposition names.

## Notes

The memory of earlier sessions sets the delivery rule. Koine ships small
happy-path releases, and hardening becomes GitHub issues. Since v0.4.0, 143 of
the 155 leaves in the commit history were Settings leaves, and no Settings
selection ran under the closed protocol.

## Decisions (running log)

**Approach (2026-11-25).** Antony chose the happy-path repair. The full
five-slot protocol and a change to the release check alone were the other
choices. The grove replaces the System Events front read of the positive setup
with the `focused` flag of the list that the setup holds. It applies the
activation-first order of `561dbf6c` again, and the release check
`task app:vm-verify-menu-bar` accepts it in the VM. The two races, the Finder
window and any reliability study become GitHub issues.

The claim stays limited. A pass shows that the candidate keeps the happy path on
the guest release that ran. It does not show that the candidate removes the bug.

**Acceptance bar (2026-11-25).** Antony chose one clean run of
`task app:vm-verify-menu-bar` on the candidate. In that run, each of the four
Settings selections returns one front, focused Settings window. A resize that
the script reports as NOT RUN does not count against the pass. A harness stop is
unavailable evidence, not a Koine failure. The grove runs the check again, with
at most three attempts in total, and then asks Antony.

**Release (2026-11-25).** Antony chose a 0.4.1 patch release as the end of the
grove. The release procedure runs `task app:vm-verify-menu-bar` on the
notarised 0.4.1 bundle, and that run is the acceptance run. The tag, the GitHub
release and the cask update ask Antony first. If the candidate fails, nothing
ships, and the repair returns to an issue with the result.

**Test seams (2026-11-25).** Antony agreed to two existing seams.
`task check:vm-settings-scenario` tests the new setup check against a simulated
backend. `task app:vm-verify-menu-bar` on the notarised 0.4.1 bundle is the
acceptance run, and it is the only seam that observes focus. The call order has
no headless seam, and the grove adds no new seam.

**Shared understanding (2026-11-25).** Antony agreed to the summarised scope and
to three flat sibling leaves: the setup front check, the call order and the 0.4.1
release. Five points came with that agreement:

- No review leaf is cut in advance. Each producer can still cut one if it judges
  an adversarial read necessary. This drops the line in issue 15 that put an
  independent review before any guest run.
- The tooling of the closed protocol stays in the repository, unused.
- The release leaf files four follow-up issues. They cover the TextEdit quit
  race, the lost restart reply, the Finder window at first launch and a
  reliability study of both call orders.
- If the candidate fails, the release leaf returns the code to the released
  order. Nothing ships, the result goes on issue 15, and the setup change still
  merges.
- Issue 14 stays open, because this grove does not find the native cause.
