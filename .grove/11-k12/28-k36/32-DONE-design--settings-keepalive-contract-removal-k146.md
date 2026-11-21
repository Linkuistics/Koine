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

## Decisions (running log)

- 2026-11-21: The workspace parent is ahead of `main`, so no rebase is needed.
- 2026-11-21: This leaf records a settled ADR and has no design discussion. A
  new visual document earns no place. The existing visual README gets one
  changed sentence, because it calls the withdrawn hold binding.
- 2026-11-21: The goal sentence governs the scope, and the listed passages are
  a minimum. A sweep of both documents found more keepalive requirements. In
  the spec, the hold paragraph on helper adoption also goes. In the plan, these
  passages also go:
  - the admission-delay sentence in "Input and observation qualification"
  - the worker stop and the resource profile in "Required transport and
    evidence handling"
  - the coordinator inputs in "Freeze, audit and exact cleanup"
  - the k93 sentence in "Complete ordinary acceptance and preserved duties".
- 2026-11-21: "The new capture policy" in the spec came from k49, before the
  keepalive work. It names the protocol's own captures, and it stays.
- 2026-11-21: The conversion covers the blocks that the edit touches. It uses
  `on` and `pending` windows, as both documents already do. A table converts
  whole, because a marker line inside a table breaks it. This keeps the
  meaning risk and the review on the text that the ADR reaches. The skill
  lets a later edit convert more.
- 2026-11-21: In the spec, the hold section moves to the end of "Finite
  evaluation and ordinary acceptance". k92 inserted it above the evaluation
  text, so the evaluation paragraphs read as part of the hold. The heading text
  stays, so each `#keepalive-coordination-hold` link still resolves.
- 2026-11-21: The keepalive-only test seams are coordination, both overlap
  directions, races between a normal stop and dispatch, unexpected worker exits
  and resource limits. The locks, capture validation and records serve the
  retained capture duties, so their tests stay.
- 2026-11-21: The first glossary sweep read clean for every term, which was
  false. zsh does not split an unquoted variable into words, so each search
  read one nonexistent path. A positive control and an invented term exposed
  the fault. The repeated sweep runs under bash and on text with collapsed
  whitespace. Only "Keepalive tick" and "Resource profile" occur in live texts.
  After this leaf, both occur only in withdrawals, so all 33 owner terms go.
- 2026-11-21: Regions cannot nest, so `off` cannot contain `pending`.
  `KEEPALIVE-DESIGN.md` loses its three internal markers to become one `off`
  region. The history note sits above each title. The departure markers in
  the owner and records specs had no checked block in `off`, so they go too.
- 2026-11-21: A token comparison of the conversion found no lost link, handle,
  code span, heading or number. The only change is "reopens 2/3", which now
  reads "reopens 2 and 3". A mutated copy showed that the comparison detects a
  lost link and a lost handle.
- 2026-11-21: The withdrawal drops links only into the withdrawn design: its
  scope decision, its scheduling profile and its review integration. The list
  of evidence documents that nothing living cites is the same as at the parent
  commit.
- 2026-11-21: The conversion rewrites binding text, and the withdrawal reaches
  five consumers. The in-session checks cover the instruments, not the
  judgement calls above. So this leaf cuts `review-design` as
  settings-keepalive-contract-removal-k148. It sits before k147, because k147
  reads this contract.
- 2026-11-21: This launch has no provider evidence and no legacy run identity,
  so the review carries no Creator line.
