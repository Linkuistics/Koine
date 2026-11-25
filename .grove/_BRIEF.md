# Koine.gh-issue-15 — brief

## Goal

Ship Koine 0.4.1 with the activation-first Settings call order. The grove answers
GitHub issue 15 with a happy-path repair instead of the closed five-slot protocol.

## Done when

- The positive setup of the shared Settings scenario judges the front application
  from the `focused` flag of the window list that it holds. It makes no System
  Events front read.
- The Settings show path requests activation once, and then the key and front
  window.
- One clean run of `task app:vm-verify-menu-bar` on the notarised 0.4.1 bundle
  accepts the candidate. Otherwise, the release leaf records why the candidate
  failed.
- After Antony approves, Koine 0.4.1 and its cask are published. If the candidate
  failed, nothing ships.
- Issue 15 carries the outcome, and the four follow-up issues exist.

## Decomposition

Four flat sibling leaves share the purpose and context of this root, so no leaf
needs a node. Their order encodes the dependencies.

1. `settings-setup-front` removes the read that stopped E01 from the positive
   setup. It comes first, because every later VM run makes that read.
2. `settings-call-order` applies the candidate order again and records the new
   scope in the spec.
3. `settings-menu-oracle` replaces the two open-menu checks, which failed on a
   real guest in attempt 1 of the release. Antony chose this repair on
   2026-11-25.
4. `release-0-4-1` notarises, accepts, publishes and closes the issue.

## Pointers

- Spec: `docs/specs/settings-activation-discrimination.md`. Its "Current
  decision" section binds the Settings repair.
- Glossary terms: Settings window, qualified recurrence, focused evaluation and
  ordinary acceptance (see `CONTEXT.md`). The last two name the closed protocol,
  which this grove does not run.
- No ADR binds the closed protocol. The ADR
  `docs/adr/settings-harness-takes-no-keepalive-captures.md` governs the waits of
  the harness.
- `docs/verification/settings-activation/ORDERING-QUALIFICATION-RESULTS.md`
  records the E01 stop. `docs/verification/menu-bar-vm.md` records the menu-bar
  check.
- Test seams, agreed with Antony:
  - `task check:vm-settings-scenario` tests the positive setup against a
    simulated backend.
  - `task app:vm-verify-menu-bar` on the notarised 0.4.1 bundle is the acceptance
    run. It is the only seam that observes focus.
  - The call order has no headless seam. The build and the headless checks
    cannot observe focus.

## Notes

The acceptance bar is one clean run of the menu-bar check. A clean run passes
every assertion of the check, apart from a resize that the script reports as NOT
RUN. In it, each of the four Settings selections over TextEdit returns one front,
focused Settings window. A stop or failure with a cause in the harness, the guest,
TextEdit or the test driver is not a Koine failure. The release leaf runs the
check again, with at most three attempts in total, and then asks Antony.

The claim stays limited to the happy path on the guest release that ran. On
0.4.0, the "not front" failure occurred in 2 of 9 runs. At that rate, one clean
run occurs about 78% of the time with no improvement. So a pass does not show
that the candidate removes the bug.

The tooling of the closed protocol stays in the repository, unused. A check that
breaks because the setup no longer makes the front read gets the narrowest repair
that keeps it green. Deleting the tooling is outside this grove.

The delivery rule of Antony applies: Koine ships small happy-path releases. A
review finding blocks the release only if it breaks the happy path. Hardening,
edge cases and coverage become GitHub issues.
