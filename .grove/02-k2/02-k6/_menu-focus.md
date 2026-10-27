# menu-focus-k6 — brief

## Goal

Establish why the Settings action can open Koine's window behind TextEdit, repair
any diagnosed local defect, and complete the parent menu-interaction acceptance
criteria. Do not hide a failed first action with another action or a guessed wait.

## Context

Read the parent brief and the 2026-10-28 section of
`docs/verification/menu-bar-vm.md`, including its retained diagnostic evidence.
The source-only pointer repair and focused Taskfile checks landed in
menu-pointer-k5. The diagnostic Settings action opened a previously absent
window, but TextEdit remained first/focused in the agent, Koine's AXFocused was
false and the screenshot agreed. The individual System Events front-process
query also returned TextEdit. This is a real observed focus failure; its cause
is not yet established. The diagnostic's combined process query was malformed
and is explicitly excluded as evidence. Menu titles alone did not prove visible
menu dismissal.

The diagnostic guest was stopped. Use TestAnyware, the released 0.4.0 zip with
the documented checksum, the project's Taskfile and machine environment contract.
No host GUI run or release is required. Preserve all attempts and interventions.
The graph CLI refused access due to another active generation; do not stop other
sessions to get graph access.

## Done when

- Capture input delivery, visible menu dismissal, window appearance and ordering,
  and independent native keyboard-focus/activation evidence around one action.
  Separate Koine activation behavior from the VNC/menu route and observer errors.
  Establish the cause before changing application code or choosing a polling
  bound. Consult official version-matched framework sources for API decisions.
- Repair any established local cause and verify its actual seam. If a historical
  symptom stays unexplained, preserve a precise remaining task rather than
  labelling it fixed. Decompose again if needed.
- The scenario checks every intended reopen (each Settings iteration, request
  review, Accessibility line, explicit application reopen and the window opened
  before Command-Q) independently. A window count alone proves no focus. Send
  each action once; poll observations only when evidence justifies the bound.
  In particular, use a single exec for explicit reopening, and preserve silent
  launch as a separate, unrepeated operation.
- Run the complete `task app:vm-verify-menu-bar` scenario against frozen subjects,
  with scripts/bundle/environment identity and all failures and NOT RUN results
  retained. Resize remains window-resize-k3's responsibility; no resize acceptance
  comes from frame assignment or scroll reachability at the default size.
- Reconcile the existing verification record and Taskfile as needed, and check
  the original menu-interaction-k2 Done when criteria before closing its node.

## Evidence precision

For the next full scenario, hash every file of the actual extracted app bundle
before and after the run, as well as every sourced script, Taskfile and client
fixture. Hashing only the original release zip plus checking code signatures is
a weaker inventory; do not describe it as a complete per-file freeze of the
installed subject. The predecessor's exploratory attempt records that limit.

## Decisions (running log)

- CBM again refused `list_projects` because an unverified generation is active.
  Use bounded source reads; do not stop other sessions.
- Diagnose the unchanged released 0.4.0 bundle first. The retained release zip's
  SHA-256 matches the brief. Guest `koine-menu-k6-diagnosis` uses the macOS 27
  golden and TestAnyware 2.7.0. Setup installed and verified the bundle and
  answered Automation consent, then the exploratory wrapper failed because it
  called `await_koine`, which belongs to the scenario rather than either shared
  library. A second wrapper also made that mistaken assumption before any
  action. Both logs are retained; neither is an acceptance run.
- Apple documents `NSApplication.activate()` (available since macOS 14) as an
  activation request with no guarantee. This is a hypothesis lead, not proof of
  the observed cause. Compare a single pointer menu action with native
  NSWorkspace frontmost-process and CoreGraphics window-order sampling, System
  Events AX focus attributes, the agent's windows and screenshots before repair.
- A controlled action with TextEdit explicitly active and no Koine window
  succeeded: a fresh native process reported Koine active and first in
  CoreGraphics window order before keyboard input; the keyboard witness then
  reached Koine. System Events continued to name TextEdit and report Koine's
  AXFocused false. Those System Events reads are not a reliable independent
  focus oracle here. The initial polling monitor did not service AppKit's event
  loop; exclude its cached activation field. Its raw trace is exploratory.
- The historical screenshot-confirmed failure still has no established cause.
  Decompose: the first child preserves this observer qualification, strengthens
  every-reopen/one-action scenario coverage, and records one frozen full attempt.
  A following child owns remaining activation diagnosis and any justified repair.
