# pointer-media-k8

**Integrates:** pointer-media-k7

## Goal

Triage the committed pointer and media design review and apply the warranted
design repairs before `pointer-k3` builds on the contract.

## Context

- Read the findings from the commit of `pointer-media-k7`. Its durable review
  artifact is `docs/verification/desktop-pointer-media-design-review.md`.
- The producer is `pointer-media-k2`. Its design and root-brief contract are
  unchanged by the review. The review changes no production or test code.
- This is a flat sibling in the existing review chain. It runs immediately
  before `pointer-k3`, so implementation does not move the reviewed artifact
  before triage.

## Done when

- Each committed finding is checked against its sources and classified as an
  unclear contract, a real issue, a visible trade-off or noise.
- Warranted bounded design repairs and their affected citations are coherent.
  Accepted trade-offs and rejected findings have concrete reasons recorded.
- Verification appropriate to any repaired design is recorded, with native
  acceptance and implementation work left with their existing owners.

## Notes

- Preserve the agreed scope and consent posture. A substantial redesign uses
  the Grove integration procedure rather than becoming an unreviewed change.

## Decisions (running log)

**F1, the consent check for posted events: a real issue, repaired.** The
finding holds. The design checks `AXIsProcessTrusted` alone before the nudge
and the media keys post. The contract says that this check makes a dropped
post visible. The decision record says that posting needs only the
Accessibility consent.

<!-- tc: depart spelling because the comment of the SDK header is quoted word for word -->
Two primary sources establish a separate access. The SDK header `CGEvent.h`
declares `CGPreflightPostEventAccess`, which "checks whether the current
process already has event synthesizing access". It also declares
`CGRequestPostEventAccess`, which can prompt. Apple's privacy policy schema,
`com.apple.TCC.configuration-profile-policy.yaml`, has separate `Accessibility`
and `PostEvent` policies.

So a managed Mac can allow Accessibility and deny `PostEvent`. The design's
check then passes, and macOS can drop both posts. Koine still reports `NUDGED`
or a key receipt, which is the case that the check claims to make visible.

The Music check does not exclude that case. Its probe recorded both values,
and its script required both. The TestAnyware agent started the probe, and no
step gave the probe a consent of its own. So the run says nothing about the
signed Koine. The Apple forum thread that the review cites refused an automated
read, and this triage does not rely on it.

The finding meets the threshold. It is a material risk to the consent item of
the root brief and to a failure contract that clients code against. The repair
is bounded, so it needs no producer step and no second review.

**The repair.** The nudge and the media keys check `AXIsProcessTrusted` and
`CGPreflightPostEventAccess` before any other step. When either is false, the
error is `permission`, `os-permission`, `accessibility`, and Koine posts
nothing. Neither check asks for consent. No operation calls
`CGRequestPostEventAccess`, so the agreed consent posture holds.

The error keeps the identifier `accessibility`. Koine owns that one OS
permission. The contract requires Antony's decision for a new consent
identifier ("Workflow extension — consent identifiers" in
`docs/specs/machine.md`). The message of the error names the access that macOS
withholds.

**A visible trade-off.** When only the posting access is missing,
`koineManagement.osPermissions` still reports Accessibility as granted, and the
error names `accessibility`. The message, not the identifier, tells a client
which access is missing. Koine also refuses when it has the posting access
without Accessibility, because it posts under its one consent. The contract
states both.

**Acceptance owns the posting posture.** No evidence yet establishes that the signed
Koine has posting access under the Accessibility consent that a user gives in
System Settings. After the repair, `NUDGED` and a key receipt mean that both
checks passed. So the VM run of `pointer-media-acceptance-k5` establishes the
posture. A refusal with Accessibility on, or a new dialog, is a stop for
Antony under the root brief's consent note.

**Display focus stays as released.** Desktop 1.0.1 display focus posts one
mouse-moved event after its warp, under the Accessibility check alone. A
change to that released behaviour is outside the scope of this grove. The
release leaf files it as an issue, beside the other findings that do not break
the happy path.

**The other artifacts stay unchanged.** The schema descriptions, the example
operations, the trace rows, the requirements row, the glossary and the
disclosure text state no consent check. The root brief's consent item still
holds, because the second check asks for no new consent. The review record and
the finished task files are history.

**Verification after the repair.** `task design:pointer-media-check` passed,
and it still rejected its 9 mutated subjects. A sweep for the old consent
claims found 7 lines in the pre-repair commit `9131c243`. In the repaired
tree, it found only the qualified opening sentence of the contract and the
finished log of `pointer-media-k2`. A second sweep listed every line that
joins posting with consent, and each line is repaired, history or unrelated.
The technical-communication checker reports no hard finding in any changed
prose.

This is design evidence only. No build, test or GUI step ran. The checks in
code stay with `pointer-k3` and `media-keys-k4`, and the posting posture of the
signed Koine stays with `pointer-media-acceptance-k5`.
