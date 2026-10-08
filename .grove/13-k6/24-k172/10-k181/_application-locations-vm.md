# application-locations-vm-k181 — brief

## Goal

Accept the application stages at V: an over-limit application path is refused
before any delivery, short launch, named open and reveal keep working beside a
long copy of the same application on disk, and a long copy that is the
identifier's preferred one is refused, never replaced by another.

Native registered-long ordering and preferred-long refusal remain unproved under
Antony's accepted coverage limit for workspace 1.0.1 on macOS 26.5 (25F71), arm64.
The exact scope and reopening evidence are in
`docs/verification/application-locations-vm.md#accepted-native-coverage-limit`.
The runtime contract remains required; the two unavailable native subjects no
longer block this increment's closure on that build.

## Context

- `docs/specs/workspace-launch-and-open.md#subjects-and-versions` (V) and
  `docs/verification/application-installations-vm.md`.
- `scripts/vm-installation-fixtures.sh`, `scripts/vm-installation-request.py`,
  `scripts/vm-registration-lookup.swift`; the prepared launcher VM
  (`docs/verification/launcher-apps-vm.md`).
- `docs/verification/long-action-native-boundary.md` (the v1 reading of its subject
  table: short workflows with long registered copies; long constrained
  installation).
- `target-locations-vm-k180` for the observers.

## Done when

- An over-limit constrained `applicationPath` is `failed` with guidance and no
  application is launched or opened.
- **Selected copy short, long copy beside it.** With a long copy of the same
  application on disk and registered, in either enumeration order, short
  constrained launch and named open (selecting the short copy by `applicationPath`)
  work; unconstrained launch and named open work where the guest makes the short
  copy the identifier's preferred one; reveal still finds Finder. An
  unavailable registered-long/both-order subject is covered only by the accepted
  native coverage limit on the tested build; it remains unproved and L does not pass it.
- **Preferred copy long.** Where the guest admits the long copy as the
  identifier's preferred one, an unconstrained launch and named open are `failed`
  with the guidance of the limit, name the long spelling and its byte count, and
  launch and open nothing, even with a short copy of the same application
  running. No other copy is substituted. If the guest will not make the long copy
  preferred, that subject remains unproved under the accepted native coverage
  limit on the tested build; the selected-short cases do not pass it.
- Receipts for the short workflows above carry a non-null process where the
  accepted short workflows do, observed through the kernel's identity for the
  returned process, so `receipt-executable-identity-k183` is seen to hold at V.
- Evidence is a verification document linked from the spec's rows; the
  long-location acceptance entries of the spec carry their final status.

## Accepted scope and test seams

Antony accepted the coverage limit on 2026-10-08 ("accepted"). The existing
public GraphQL, independently built native binary and isolated TestAnyware macOS
VM seams remain the agreement. Keep the substituted-adapter L/G checks and the
accepted supplied literal refusals and disk-only short effects/receipts. The
registered unequal long copy before/after the selected short copy and the long
preferred copy refused cold/running remain unproved at the native seams; the
accepted limit removes only those two closure prerequisites for workspace 1.0.1
on macOS 26.5 (25F71), arm64. The v1 refusal at every over-limit application
spelling and prohibition on substitution still bind. A concrete setup exposing
either physical long copy in the required actual native order or preference at
the request reopens the corresponding V measurement. No further automatic
registration experiments or production consent/signing changes are commissioned.

## Notes

- A systematic length-caused `process: null` would be a defect, not an accepted loss.
- The preferred-long refusal is the v1 contract, not a regression: the 1.0.0 success
  for it that the native boundary record once asked for is superseded by the v1
  decision (Linkuistics/Koine#1).

## Decisions (running log)

- Reuse the installation VM recipe, its fixture delivery log and independent kernel
  receipt observer. Add a long-location section and component-created copies at
  1,024 and 1,500 bytes. Read actual NSWorkspace registrations after absolute,
  descriptor-relative-current-directory and short-link registration attempts;
  no assumed registration or local-adapter result closes V. Short workflows beside
  an unregistered long copy can be measured separately but cannot pass the
  registered-long or preferred-long subjects.
- The graph CLI refused to start because a pre-coordination or unverified generation
  is active. Relevant scripts and fixture source were read directly; no graph
  completeness claim is made.
- Spent the leaf's single fresh-context review on measurement validity: controls,
  registration preconditions, refusal observation and kernel-backed receipt
  assertions. Its first finding is actionable: the long copy retains A's label,
  so label/PID/start alone cannot prove the selected short copy or exact document.
  The guest records full fixture bundle paths, witness bundle paths and document
  paths; preserve the live run's inputs, then tighten the predicates and evaluate
  the retained observations with mutation controls before accepting those rows.
- The reviewer returned four actionable measurement findings: physical-copy and
  exact-document checks, an omitted `vm-verify-client.sh` digest input, and
  reveal's answer-file retry race. Stopped the first attempt before action
  measurements and stopped its clone. A fresh run follows all fixes: one shared
  predicate checked against a prior real observation plus wrong-copy/document,
  null-receipt, kernel-start and missing-delivery mutations; the missing digest
  input is included; reveal uses the installation request's existing atomic
  guest guard. No first-attempt result counts toward acceptance.
- The next attempt constructed the long copies, then macOS refused the optional
  short-link registration route's 1,024-byte target text with `ENAMETOOLONG`.
  Independently reproduced that limit. Record this specific construction refusal
  and still query registrations, instead of losing valid subject observations.
  The attempt ended before action measurements and its clone stopped. The detached
  launcher now uses Task's `--exit-code`; a disposable headless Taskfile control
  confirmed both survival after launcher exit and exact propagation of status 3.
- The completed bounded registration measurements report only short A and B, with
  A preferred, after every attempt. Absolute registration returns 0 at both lengths;
  relative-current-directory registration returns 0 at 1,024 bytes and 1 at 1,500;
  short-link construction is refused with errno 63 at both. A command's exit 0 does
  not establish registration. This is a genuine seam: decomposed k181 into the
  executable observations (k186, this session) and the human acceptance decision
  for the unconstructible native preconditions (k187). No registered-long or
  preferred-long V row is passed, and this node remains live.
- Identified one precise remaining construction that does not need a scope
  decision: a short link to an intermediate prefix (target text below the native
  limit), followed by the remaining components. The physical application can
  stay long even if its registration argument is short; every spelling is still
  subject to the production limit. K187 is now an impl leaf for this one bounded
  fixture route, rather than asking Antony for a coverage exception prematurely.
  It cuts a requirements leaf only if an actual native precondition remains
  unavailable after that finite route. This session still finishes only k186.
- K186 finished with `docs/verification/application-locations-vm.md` and linked
  spec status: eight supplied literal refusals, six short launch/open receipts,
  Finder reveal and controlled observers, 19 passed recorded observations after
  explicit canonical-guidance re-evaluation. The raw run's eight matcher failures
  remain preserved. Its inputs were unchanged and its clone is gone. Both native
  registration subjects remain pending; k187 is live, so this node does not close.
- K188 records Antony's explicit acceptance of the scoped native coverage limit.
  The raw measurements and pending verdicts remain unchanged. The accepted V
  slice, the retained L/G checks and the two precisely disclosed unproved native
  behaviors satisfy this node's amended charter; no additional experiment is
  required for its closure on the tested build.

## Decomposition

1. `application-location-observations-k186`: finish the finite VM recipe, measure
   over-limit constrained refusals cold and with short A running, short constrained
   and short-preferred launch/open receipts beside the long copies on disk, and
   Finder reveal. Publish exact native registration observations and pending rows.
2. `long-application-registration-k187`: one bounded prefix-link registration
   fixture, using short target text to an intermediate directory while the
   physical application remains long. Accept only actual native enumeration and
   preference preconditions; an unresolved residue then earns a requirements
   leaf for Antony. No local-adapter pass, inference from disk-only success,
   or automatic relaxation of the parent charter is permitted.

3. `long-application-acceptance-k188`: obtain Antony's explicit scope decision for
   the still-unavailable native subjects, using k187's complete measured matrix.
   This is the required human continuation, not another automatic experiment.

## Latest native evidence

K187 completed its one prefix route per physical length and twelve public
registration states on macOS 26.5/25F71. Every long scan returns -37, and every
final NSWorkspace query lists A then B and prefers A. All 55 recorded measurement
input entries remained unchanged before the subsequent recipe correction.
The full matrix and raw later reveal-matcher failure are preserved in
`docs/verification/prefix-registration-vm.md`; no new Finder selection V pass
is claimed. Both original native preconditions remain unproved under Antony's
accepted coverage limit, recorded with its reopening evidence in
`docs/verification/application-locations-vm.md#accepted-native-coverage-limit`.
The raw pending verdicts are retained; they no longer block this node's amended
closure criteria on the tested build.
