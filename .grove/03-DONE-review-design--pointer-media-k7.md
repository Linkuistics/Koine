# pointer-media-k7

**Reviews:** pointer-media-k2

## Goal

Try to break the pointer and media design before two implementation leaves
build on it.

## Context

- The artifact is the design that `pointer-media-k2` committed:
  - `docs/design/desktop-pointer-media-schema.graphql` and
    `docs/design/desktop-pointer-media-operations.graphql`.
  - `task design:pointer-media-check` in `Taskfile.yml`.
  - The "Pointer and media" section and the 0.6.0 desktop disclosures under
    "Capability disclosures" in `docs/specs/machine.md`.
  - The two authority rows for the pointer and the media keys, and the trace
    rows "Media", "Pointer" and "Grant disclosure", in
    `docs/specs/workflow-providers.md`.
  - The "Media" row of `docs/requirements/modaliser-workflows.md`.
  - The new glossary terms in `CONTEXT.md`.
  - The new paragraphs of `docs/adr/desktop-automation-uses-public-accessibility.md`.
  - The Music check: `docs/verification/media-key-music-launch.md`,
    `scripts/vm-check-media-key-music.sh` and `Fixtures/MediaKeyProbe`.
- The contract that the design must meet is the root brief's "Done when". The
  running log of `plan-k1` holds the human's decisions and their reasons.
- Modaliser is the reference implementation (root brief, Pointers).
- The precedent review of a pointer move is
  `docs/verification/desktop-window-layout-design-review.md`.

## Done when

- Each finding names its location in the artifact, a concrete failure
  scenario, and the requirement or rule that it breaks.
- If a finding is worth acting on, the session cuts an
  `integrate-review-design` leaf as its last act. With no such finding, it
  cuts nothing.

## Notes

These are the doubts that earned the review. Each is a question, not a claim.

- Can a grant that holds `desktop:control` alone learn read data through the
  nudge, a media key, a receipt or an error?
- Can the nudge act as a drag or a click, or move the pointer while a button
  is held?
- Does the `desktop:control` disclosure state each new effect, with the
  reactions of applications and of macOS?
- Can any released host load desktop 1.0.2 and present a disclosure that
  leaves out the new reach, for example through a per-user update?
- Is the consent check the right one for the posted events?
- Is the position read correct on every display layout, and is its unknown
  form right?

## Decisions (running log)

**Consent finding.** The review identifies one material design gap. The producer
selects `AXIsProcessTrusted` as the posting guard, but Apple's privacy policy
schema treats Accessibility and PostEvent separately. The recorded probe
requires both to be true, so it does not establish their equivalence. The
review records the split-permission counterexample and its limits in
`docs/verification/desktop-pointer-media-design-review.md`. No design or code
fix belongs to this review.

**Integration placement.** An `integrate-review-design` sibling will run before
`pointer-k3`. It will triage the review's committed finding against the consent
requirement. This unblocks the posting contract that both implementation leaves
consume, within the root brief's existing scope.
