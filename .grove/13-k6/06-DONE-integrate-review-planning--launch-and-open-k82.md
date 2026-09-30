# launch-and-open-k82

**Integrates:** launch-and-open-k81

## Goal

Triage `launch-and-open-k81`'s findings against the implementation decomposition
produced by `launch-and-open-k29`. Apply the real ones so implementation starts
from a coherent plan.

## Context

- Read the findings in the review leaf and its own commit; this charter does
  not restate them as mandatory work.
- The artifact is k29's committed decomposition: the increment briefs and
  leaves under `launch-and-open-k6`, its node brief, and the root-level
  `alternate-team-signing-k80`.
- The workspace and Machine acceptance matrices, both cited ADRs and the root
  brief govern the plan. Review insertion shifted sibling positions while
  preserving their bodies and stable handles; the review's links use the
  shifted paths.

## Done when

- Each finding is classified as applied, rejected with a reason, or an explicit
  accepted trade-off. A finding is not mandatory merely because the review
  raised it.
- Accepted changes are reconciled across every affected leaf, brief, owner table
  and handoff, while preserving the agreed acceptance and live-pending rules.
- The task tree remains well formed and implementation follows this integration.
  Plan-only changes are checked by reading the resulting tree and diff; they
  do not imply runtime acceptance.

## Notes

This integration owns plan fixes. A change to the settled product design belongs
in a new design/review chain at the appropriate boundary, rather than being
quietly adopted as a planning correction.

## Decisions (running log)

Bootstrapped from an empty working change on `43a3072d` (k81). Read the root and
node briefs, k81's committed findings, k29's decisions, the selection node and its
four leaves, k80, the launch-path brief, k59, k60, k73, the document-paths
brief, Machine's selection-acceptance table and host-team rule, and the workspace
spec's Operations, native policy and Acceptance sections.

**F1 — applied (a contract stated unclearly).** Reproduced. The selection brief
lets only a certificate-dependent V case stay pending, while k63 and k65 leave
their second-team N/G parts pending for k80. Machine's trust-refusal row already
keeps "real second-team signing" pending at every seam, and the launch-and-open
brief's closure rule does not depend on seam. The narrowing therefore sits only
in the selection brief. Its exception now covers the certificate-dependent part
at any assigned seam, and its owner table names `alternate-team-signing` in
the N/G column for both rows. A leaf that already holds the certificate closes
its own part. k65's pending clause now matches k63's conditional form. No case is
waived: every other part of both rows still closes in the node. k80 already
runs pending N, G and V, and baseline acceptance still cannot close around them.
Machine's "N, G; V for alternate team" can be read as including N/G for the
alternate-team host or not. The plan reads it inclusively, which satisfies
either reading, so the spec is left unchanged.

**F2 — applied (a real issue), as a reorder.** Reproduced. k59's selection
resolves an optional installation path's symlinks, compares its file identity
and reads the bundle's identifier and presence. The workspace spec's Consent row
requires the first protected-path inspection "before path/search consumers".
k29's log counted only path opening and search, but constrained launch takes a
path too. The probe is good work that is still ours, only placed too late, so
it moves by hand without rejecting anything. k73 now sits ahead of
`launch-path`, keeping its handle and body, and its question names launch
selection's calls. Running it first matches the root brief's order
of evidence, then design, then implementation. It also costs nothing extra: in
its old slot the alias, content-type and handler primitives already needed a
purpose-built signed probe, because only launch existed. The alternative was a V
check inside `launch-vm`, which would leave k59 built on an unanswered question.
It was rejected. The settled complete input and SDL stay unchanged. k59 now
consumes k73's answer, and a prompting call remains Antony's decision, as k73
already states.

The review's "Other reviewed choices" are endorsements, not findings, and need
no change. After the reorder, k81's position-prefixed links are off by one
sibling; its stable handles still name the right leaves, and no live file
carries a position-prefixed path. Checked by reading the tree: brief chains and
handles resolve, and positions are gapless. This is a plan-only change and
claims no runtime acceptance. The certificate and prompt answers stay live work.
