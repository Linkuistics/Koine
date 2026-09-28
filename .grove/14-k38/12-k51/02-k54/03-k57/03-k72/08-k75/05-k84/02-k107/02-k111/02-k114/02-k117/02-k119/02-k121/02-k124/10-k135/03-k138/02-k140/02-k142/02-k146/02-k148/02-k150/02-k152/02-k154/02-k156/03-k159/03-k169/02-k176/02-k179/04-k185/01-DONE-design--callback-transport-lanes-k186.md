# callback-transport-lanes-k186

## Goal
Settle transport ownership, auxiliary framing, original coordinates and the
legacy projection boundary for the publication successor, with independently
inspectable histories and a rendered view.

## Context
Consume k185's complete charter, k183 findings 3/5/11 and k184 dispositions.
Current Trace and partial_history use four protocol-role streams; no successor
schema or executable semantics are implemented here.

## Done when
- Account for every app/supervisor auxiliary route on the shared sockets,
  including activation/helper results and admission-to-candidate provenance.
- Specify app and broker lane ownership, start/end/PID rules, exact joins,
  loss cuts, projection coordinates and collector permutation behavior.
- Give concrete normal, stalled-auxiliary, substituted-origin/candidate,
  transport-gap and observable reply-before-result histories, preserving
  remaining cross-hop status and lifecycle policy for the named children.
- Reconcile both contract pointers, assessment and viewer; render and inspect
  the changed view in a disposable TestAnyware clone. Preserve all V1–V26 bytes.
- Hand unresolved evidence/milestone/lifecycle/budget criteria to k187–k189;
  k189 must reconcile all original k185 criteria and commission its exact-stem
  review before k182. No ancestor or native criterion closes on this slice.

## Decisions (running log)

- Include auxiliary traffic in the same framed transport and directed-connection
  ordinals. Separate sockets would add connections, admission and cross-channel
  joins without removing candidate provenance obligations. Preserve four
  protocol roles while allowing supervisor-owned auxiliary endpoints.
- Use one observation lane per app and one globally sequenced supervisor lane.
  Serialize append/sequence allocation, never blocking I/O under that lock.
  Different connection workers may progress concurrently. Keep actual broker
  observation order; collector permutations preserve coordinates, whereas
  changing supervisor sequence numbers describes a different execution.
- Keep original producer coordinates explicitly inside semantic observation
  rows. A logical send shares its frame-commit vertex and a receive shares its
  complete-frame vertex. Cut physical lanes before projection; never compact
  over a lost transport row. Frozen producers remain compatibility evidence,
  not the transport successor's completion oracle.

- Preserve app semantic receipt at the selected producer's permitted socket
  callout. Supervisor concurrency does not authorize a new app background reader
  to consume cancellation during synchronous work. Exact metadata joins add no
  owned native references and do not grant cross-role provenance on missing hops.

## Verification

- Direct source fallback for stale graph generation confirmed the relevant
  Trace.create/join_messages/partial_history constraints. The design names the
  new adapter boundary without changing those readers or V1–V26 inputs.
- Final viewer/manifest/source bytes matched both local/guest-facing HTTP URLs
  before and after reads; changed IDs, sources and contract links validated.
- TestAnyware Safari inspection reached the three cited deep links, readable
  final topology branches, reply sequence and captions, and correct discussion
  markers. The semicolon parse failure was corrected and rendered again.
  Evidence/k186 records exact scope, screenshots and limitations; clone stop
  returned success. No native, executable-version or full-corpus result claimed.
- This child delivers topology/coordinates and discriminating histories only.
  K187–k189 retain every remaining k185 criterion and its final exact-stem
  review before k182. Parent k185 and all ancestors still have live work.
  Product ADRs and CONTEXT.md remain unchanged because no product decision moved.
