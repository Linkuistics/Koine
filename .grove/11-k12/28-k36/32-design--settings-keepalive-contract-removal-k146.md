# settings-keepalive-contract-removal-k146

## Goal

Amend the accepted Settings contract documents as far as the ADR
`settings-harness-takes-no-keepalive-captures` reaches, and no further. Each
withdrawn keepalive or k96 requirement cites the ADR. Every other duty stays
binding.

## Context

- `docs/adr/settings-harness-takes-no-keepalive-captures.md` holds the decision.
- The running log of settings-keepalive-removal-k145 lists the withdrawn and the
  retained duties. Read it in the commit that retired that leaf.
- `docs/verification/settings-activation/KEEPALIVE-DESIGN.md`, section
  "Original duties and handoff", maps each keepalive duty to its origin.

## Done when

- In `docs/specs/settings-activation-discrimination.md`, these passages drop
  their keepalive or k96 requirement and cite the ADR:
  - "Current decision": driver waits are excluded in full again.
  - "Keepalive coordination hold": the hold, the owner design, the ownership
    delays, the resource profile and the cooperative stop are withdrawn. The
    retained capture duties stay in that section.
  - "Scope decision for Antony" and "Correction assessment": the later
    keepalive agreement is withdrawn, so the excluded classes apply in full.
  - "Ownership and existing test seams": the keepalive-only test seams are
    withdrawn. Signal handling, both held-pointer cases, failure ordering,
    original and partial retention and the TestAnyware VM workflow stay.
  - "Original-duty comparison": the introduction and each row that names the
    keepalive, the owner or the k96 sequence.
- The retained capture duties are one writer and ordinal domain, required
  capture validation before later scenario dispatch and first-failure
  eligibility. Unique private originals and partials, and no second writer,
  UI-conditioned delay, input retry or latch reset, stay too.
- In `docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`, the
  keepalive hold in "Fixed sets and subject" and the keepalive work and
  ownership waits in "Diagnostics and timing" are withdrawn.
- The spec and the plan record the host pin from the ADR in their freeze rules.
  The pin is macOS 27.2.1 (26B131) with Tart 2.42.0. They also record the
  residual test-driver risk. A crash during a slot is a test-driver failure
  that stops every later slot. It is never a Koine failure or a pass, and it
  permits no retry.
- Each link to the spec anchor `#keepalive-coordination-hold` still resolves.
  Do not edit retained evidence, such as `ORDERING-CAPTURE-RESULTS.md`, to
  repair a link.
- In `CONTEXT.md`, remove each term that names only the rejected owner design.
  The block runs from **Settings command owner** to **Resource settlement**.
  Rewrite **Settings sequence caller** without the owner design, because k57's
  finite caller still uses the term. Before you remove a term, check that no
  live brief, live task, spec section or plan section still uses it.
- Add a history note that cites the ADR at the head of these documents:
  `docs/specs/settings-keepalive-owner.md`,
  `docs/specs/settings-keepalive-records.md`,
  `docs/specs/settings-capture-resource-contract.md` and
  `docs/verification/settings-activation/KEEPALIVE-DESIGN.md`. They are now
  historical records. Do not convert them. Put their existing text in an `off`
  region.
- Convert each touched `pending` section first, as its own commit, by the
  technical-communication procedure. Keep every handle, link and named term.
- The conversion rewrites binding contract text. Decide whether that change
  needs an independent read. If it does, cut `review-design` as the last act.

## Notes

- The ADR is the decision. This leaf records it in the contract and does not
  reopen it.
- This leaf changes no script and authorises no VM, slot, freeze, acceptance or
  release.
- settings-keepalive-loop-removal-k147 removes the code after this leaf.
- Post nothing on TestAnyware issue 13.
