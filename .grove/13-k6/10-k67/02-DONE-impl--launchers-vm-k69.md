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

## Decisions (running log)

- Acceptance is `task launchers:vm` / `scripts/vm-verify-launchers.sh`, one clone of `koine-launchers-prepared`, evidence `docs/verification/launchers-vm.md` and `launchers-vm/results.json`. Every launch is made by the contract-only client (enrolled in the window; both controls, no read), so the "contract-only client drives a launch per run" criterion holds for all of them. The witness is the existing `Fixtures/LaunchWitness`.
- A cold launch passes on the kernel's start instant of the one instance being after the request, not on the system's `launched` notification: the notification was absent for ChatGPT in one run and Kimi in the final one although each was activated with a fresh instance.
- The shared `contract_client_once` retried on the agent's status 7 even after the command had started, turning a cold launch into a reactivation (send instant 45 s after the process start). The recipe has its own once-wrapper that never repeats a run whose answer file exists.
- An application's own permission request (Kimi's local-network prompt, on some launches only) is recorded with its words and declined; only Gatekeeper's dialog or a request naming Koine fails a case. This is onboarding, not a Koine consent; no signing or consent posture changed.
- Gatekeeper case: the archived quarantined Obsidian is extracted to its own path, registered, and launched by path; held past the bound, declined in one pass and accepted in a second on a fresh extraction. "No late result" is observed through the public surface (one answer, no second launch, next request normal); the late-callback handling itself stays L's.
- The deleted-application case deletes Zotero after it was launched; the registration is left as it is.
- Controls-only activation did not fail for any launcher, so nothing goes to Antony.
