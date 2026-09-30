# application-launchers-k67 — brief

## Goal

Every named launcher passes at V, on a reusable prepared VM. Later increments
reuse its application inventory: Dia as the alternate default browser, Zed for
settings and documents, and the terminal and messaging applications.

## Done when

- Each of the twelve launchers launches while stopped and reactivates while
  running, with another application frontmost and Koine inactive: Dia, ChatGPT,
  Claude, Zed, Visual Studio Code, Jump Desktop, Kimi, iTerm, Mail, Notes,
  Obsidian and Zotero. Activation is observed. Identifiers, versions, paths and
  callback latency are recorded.
- An application that is not installed reports dependency absence.
- The Gatekeeper case is closed: a quarantined application's dialog stays
  outstanding past the three-second bound and yields `failed` without replay.
  Dismissing it publishes no late result.
- Preparation is a reusable Taskfile recipe. A missing installation is live
  preparation work, never a passing absence test.
- The Twelve launchers, Bounded acknowledgment and Consent and prompts rows (for
  onboarding and Gatekeeper) link the evidence.

## Decomposition

1. `launcher-apps`: reusable preparation, covering installation, first-run and
   Gatekeeper approval, the application inventory and the default browsers.
2. `launchers-vm`: acceptance across all twelve, plus the Gatekeeper-pending case.
