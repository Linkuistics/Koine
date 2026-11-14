# settings-keepalive-lifecycle-k97

## Goal
Specify the cooperative worker lifecycle from exact ownership through stop,
terminal evidence and confirmed reap, including dispatch races and containment.

## Context
Read KEEPALIVE-DESIGN.md and the parent k96 charter. The existing source cannot
express a clean planned stop. This is the first independently reviewable design
slice, not a complete or implemented coordinator.

## Done when
- Define supervisor, command-owner and worker responsibilities, exact VM/root
  and process identity, single-writer handoff and a bounded submission interface.
- Specify dispatch commitment, failure priority, queued cancellation and the
  complete sleep/pending/capture/validation/publication/stop race table.
- Specify distinct lifecycle records, exact stop/exit/reap matching and terminal
  publication/trust boundary. No fake capture ordinal, relabelled signal, prior
  latch reset or clean result without the required evidence.
- Preserve signals, inherited/orphan-holder limits, untouched observer/window/
  screenshot order, partial retention, exact clone stop plus independent inventory
  and both held-pointer cases. Define meaningful controls at the agreed seam.
- Update the durable design and visual discussion, reconcile existing holds,
  and cut independent review before k98 consumes this contract. Retain all k96
  numerical timing, producer/resource and full-design duties in k98. No runtime,
  source behavior change, planning or implementation occurs in this slice.

## Decisions (running log)

- 2026-10-30: Keep a single command owner with one active operation, at most one
  pending synchronous scenario submission and one pending tick. Lifecycle events
  have their own sequence and never allocate capture attempt ordinals. Stop is
  cooperative control, not a signal disguised as a successful sleep.
- 2026-10-30: Normal stop closes dispatch before acknowledgement, cancels only
  uncommitted work and drains already committed work through its original
  qualification/publication. A missing terminal or worker-reap record prevents
  acceptance. Numerical deadlines and enforceable resources remain k98's work;
  missing profile values prohibit startup rather than imply infinite waits.
- 2026-10-30: Record proposed command commitment separately from confirmed
  external launch and separate lifecycle sequence from attempt ordinals. The
  owner holds the original writer; blocking command/validation work is observed
  through owned children, with a private already-held-lock adapter entry point.
  Collection-only takeover after owner loss cannot resume the scenario.
- 2026-10-30: Use independent tree review for the dispatch/stop/publication
  contract before k98 consumes it; no in-session reviewer duplicates that read.
  No ADR is added for this incomplete, unimplemented profile. The durable spec
  owns proposed semantics; existing historical evidence remains unchanged.
- 2026-10-30: Final documentation validation reports only the two known k23
  archive targets; all measured documentation/source hashes and target-existence
  facts are unchanged during the check. Manifest references resolve. Browser
  inspection checks both new diagrams and the lifecycle containment tail after
  correcting semicolon-created stray states. No coordinator/native test ran.

## Completion comparison

The durable spec covers ownership/interface, commitment versus external launch,
stop-race table, separate intent/acknowledgement/reap records, final receiver
boundary, failure/holder recovery and both held-pointer controls. The new views
and linked verification receipts make this slice reviewable. Numerical deadline,
arbitration and enforceable-resource completion remains explicitly k98; the
parent k96 and all ancestors remain open. Current code is unchanged.
