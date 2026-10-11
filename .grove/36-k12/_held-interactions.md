# held-interactions-k12 — brief

## Goal

Koine owns multi-request interactions and their cleanup. Its first consumer is
Dia's recent-tab walk:

- Opening holds Control and advances once.
- Forward and backward steps operate the same interaction.
- Confirm releases Control to accept the highlighted tab.
- Cancel dismisses the chooser before release.

The walk stops and cleans up when any of these happens:

- the target loses foreground, except for declared client presentation;
- the owning grant is revoked;
- inactivity expires;
- Koine shuts down in an orderly way.

Abrupt crash recovery is defined and documented.

## Done when

- The Dia and interaction requirements' acceptance cases pass in VMs:
  - Confirm and cancel reach their distinct outcomes.
  - No Escape or cancel keystroke reaches a newly active application. Only
    Koine-owned modifier releases may reach it, and unrelated holds are left
    alone.
  - No new client action is admitted after revocation.
  - The documented inactivity bound and its renewal are verified.
  - Cleanup that cannot be confirmed is reported unconfirmed.
  - Abrupt termination follows the documented recovery path, and nothing is
    replayed automatically.
- Declared client presentation is defined without treating a client display
  label as an authenticated identity, and its acceptance includes activation
  changes the user did not cause.
- The lifecycle is designed so `context-menus` reuses it for opened menus.
- The admitting operation's static authority covers every supported cleanup
  mechanism, including input for Escape. Autonomous cleanup cannot select a new
  privileged fallback after revocation. Menu-only paths require native menu
  cleanup; preserve the owned-modifier-release exception and consent checks.
- Any framework or core change is a framework minor with a required feature,
  checked through the native binary seam with the compatibility pairs. An
  example is telling providers an interaction's owning grant and its
  revocation.
- Trace rows are added.

## Decomposition

1. `design` evidence: held modifiers, foreground loss and crash residue.
2. `design`: the interaction lifecycle.
3. `planning`: cut implementation leaves.

## Notes

The rules to preserve are grant/dispatch admission and live revocation.
Cleanup ends effects of an already admitted interaction. It admits nothing new,
bypasses no consent and reclaims no focus. The walk's keystrokes use
`app-input`'s delivery, so its stated check-to-delivery limit applies here
too. A limit that would weaken the no-Escape rule is Antony's decision.
