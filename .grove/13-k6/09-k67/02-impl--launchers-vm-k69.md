# launchers-vm-k69

## Goal

Accept all twelve named launchers, and the pending-Gatekeeper timeout, in the
prepared VM through the signed build.

## Context

- The workspace spec's acceptance rows: Twelve launchers, Bounded
  acknowledgment and Consent and prompts.
- `launch-vm-k60`'s recipe and witness, and `launcher-apps-k68`'s prepared state
  and inventory.

## Done when

- Each launcher is launched cold and reactivated while running, with another
  application frontmost and Koine inactive. The witness observes activation, and
  any returned identity is checked.
- Each application's callback latency is recorded next to its version.
  Acknowledgment without activation fails its case. A controls-only activation
  failure stays pending and goes to Antony.
- A separately quarantined application's Gatekeeper dialog is held open past the
  three-second bound. The result is `failed`, never dependency absence, with no
  replay. After the dialog is dismissed, no late result is published.
- Not-installed and uninstalled cases report `APPLICATION_NOT_INSTALLED`.
- The contract-only client drives at least one launch per run.
- The Named launchers trace row and the three spec rows link the evidence
  document.
