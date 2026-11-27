# app-input-k8

**Reviews:** app-input-k3

## Goal

Try to break the design of app input for Koine 0.7.0 before the
implementation leaves code against it.

## Context

- The design is in the commit of `app-input-k3`. Read its diff against the
  current tree.
- The artifacts:
  - `docs/design/input-schema.graphql` and
    `docs/design/input-operations.graphql`, with
    `task design:app-input-check` in `Taskfile.yml`.
  - `docs/specs/app-input.md`, the input contract.
  - `docs/specs/machine.md`: the `input:read` and `input:control` rows under
    "Capability disclosures", and the sentence on protected UI targets under
    "Errors and partial data".
  - `docs/specs/workflow-providers.md`: the paragraph "Protected UI targets",
    the authority rows "Application keystrokes" and "Control-digit Space
    switching", and the trace rows "Desktop windows", Safari to Zotero and
    "Grant disclosure".
  - `CONTEXT.md`: front app, input target, chord, protected target, Mission
    Control desktop and Space switch.
  - `docs/adr/desktop-automation-uses-public-accessibility.md`: the
    paragraphs from per-process posting to the count of Mission Control
    desktops.
  - `docs/design/app-input/`: the views, served by
    `task design:app-input-serve`.
- The contract:
  - The "Done when" of the root brief `.grove/_BRIEF.md`.
  - The "Done when" of `.grove/03-DONE-design--app-input-k3.md`.
  - Antony's rulings, in his own words, in the running logs of `plan-k1` and
    `app-input-k3`. In `app-input-k3`, he dropped the front check, chose the
    SkyLight count across all displays, and made every app a target under the
    capabilities.
- The evidence is `docs/verification/keystroke-route-vm.md`, the record of
  the route probe.

## Done when

- The review reports its findings against the contract. Each finding names
  the artifact, the line, the contract item and the evidence.
- The review changes no artifact. It cuts an integration step only for
  findings worth acting on, as the review procedure states.

## Notes

The review answers these questions, among others that it finds:

- Koine refuses only its own process as a target. Can a chord reach another
  surface of Koine, such as another Koine process, and approve a grant there?
- Koine recognises itself by its process identifier and its bundle
  identifier. Does that recognise every copy and build of Koine that can hold
  grants?
- A chord now reaches a target in the background. Does any statement of the
  contract, the disclosure, the descriptions or the views still assume the
  front check?
- Does the `input:control` disclosure state the whole reach of a chord, also
  for consent and security prompts and for System Settings?
- Koine counts the Spaces of type 0 on every display, in the order of the
  SkyLight reply. Does that count match the shortcut "Switch to Desktop N" in
  every display arrangement that macOS allows?
- Can any refusal or failure come after the first event of a chord or a Space
  switch, and leave a modifier key down?
- Is each refusal an outcome or an error by a rule that a client can follow?
- `inputTarget(process:)` gives null for a process that `NSRunningApplication`
  does not report. Does a configured app depend on such a process?
- Without the desktop provider, the missing-owner cascade removes the whole
  input contribution. Does the contract state that consequence where a client
  or a person sees it?
- Is the decision that input needs no disclosure feature of the host true for
  every released host, by "Reserved identities" in the machine contract?
- Antony's ruling changed the rule on protected UI targets in the workflow
  providers spec. Does that rule still bind menus in every other respect?
