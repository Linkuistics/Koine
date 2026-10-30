# Keepalive lifecycle review integration

K100 integrates k99's findings from commit `08808cc9` against k97's design at
`aa600318`. The [owner spec](../../specs/settings-keepalive-owner.md) holds the
current lifecycle contract. Commit `078f1d3b` converts its prose before the repairs.
The [scope agreement](KEEPALIVE-DESIGN.md#required-scope-decision) remains binding.

## Finding dispositions

| Finding | Classification and reason | Disposition |
|---|---|---|
| P2-1: implicit worker blocking and phases | Unclear contract. The current loop completes capture before its next sleep. A second sleep during pending admission would violate that sequence. | State the wait through complete disposition and enumerate worker phases. Separate reported worker phase from the owner's pending and committed state. |
| P2-2: missing commitment and terminal schema | Real issue. Immutable submission events cannot acquire an ordinal later. The retained backend currently allocates ordinals itself. | The owner reserves one ordinal and publishes commitment before child creation. The private backend consumes that binding. Separate launch, backend result, payload acknowledgement, terminal disposition and completion observations. |
| P3-1: exclusive-writer wording | Unclear contract. The backend writes receipts and the sticky latch. One authority does not imply one process performs every write. | State the authorised child writes and disjoint immutable records. Eligibility requires the owner's open state, no latch and complete predecessor evidence. |
| P3-2: topology and client identity | Real issue. A token without a bound scenario channel leaves the sender rule incomplete. Shared terminal groups leave signal propagation implicit. | Bind the scenario identity and channel. Specify separate owner session and owned child groups, actual signal observations and parent-loss failure. Never infer a grandchild reap. |
| P3-3: inaccessible control points | Real issue. CLI and sleep controls cannot stop an internal owner transition. A parent shell function does not reach a separate worker. | Map external controls to phases and name proposed internal barriers. Hand the unresolved seam choice to k98 below. |
| P3-4: rationale and vocabulary | Real issue in organisation and terminology. The spec format suggests headings rather than enforcing them, so a schema violation is not established. | Move rationale out of Remaining profile. Add scoped harness terms to the glossary and distinguish emission, receipt and completion. No ADR is earned yet. |

The review's separate concern about two ordinal allocators is a prospective
integration defect, not a demonstrated crash in an implemented owner. The repair
defines the private entry point that future implementation must supply. Current
production code, lock acquisition, cadence and ordinary callers remain unchanged.

## Source evidence and limits

The [capture library](../../../scripts/vm-capture-evidence-lib.sh) lines 22–43
place one complete capture after each sleep. The
[backend](../../../scripts/vm-guest-exec.py) lines 219–394 allocate the ordinal,
write request/result receipts, qualify artifacts and set the latch.
Its stdout flush is distinct from a future submitter's acknowledgement.
The [legacy loop](../../../scripts/vm-verify-lib.sh) lines 327–331 disowns its
worker and ignores capture failures. Those historical semantics do not supply
the proposed supervised lifecycle.

The [capture controls](../../../Tests/scripts/vm-capture-evidence.bats) contain
PATH-based CLI replacement, shell-function sleeps, a copied validator barrier
and a process-group SIGINT control. They support the seam analysis, not execution
of the proposed owner. No production test or guest runs for this documentation repair.

Tier 2 graph discovery found the exact backend and capture-loop symbols without
pagination. The backend trace also returned unrelated edges, which contribute
no evidence. Direct source reads resolved those ambiguities and the reported
shell ranges. Bats metadata was untracked. Changed documents and both partially
parsed Mermaid views were read directly. This is bounded verification, not an
exhaustive graph audit.

## Choice carried to k98

K98 must settle how to exercise internal owner transitions before treating its
control matrix as agreed. The recommendation is test-only barriers in copied
modules, following the existing validator technique. This preserves the public
helper seam but requires auditing that the copied transition code matches production.

An injected production callback would add a maintained interface and needs
explicit approval. External CLI and sleep controls alone leave the internal
commitment and publication schedules unqualified. No new seam approval follows
from this integration. The spec identifies the proposed points and their costs.

K98 retains every numerical deadline, arbitration, external-producer enforcement,
finite workload, retention and protected-cleanup duty. Whole-design review and
every earned integration still precede planning and implementation.
K89, k81 and k76 consumption remains held.

## Preserved duties

The [complete duty comparison](KEEPALIVE-DESIGN.md#original-duties-and-handoff)
and [ordering protocol](ORDERING-EVALUATION-PLAN.md) retain all original obligations.
K89 owns file, environment, lifecycle and collection helpers. K81 owns every exec
and one-shot consequence. K76 owns complete adoption, statuses, signals and both
held-pointer cases. K67 owns positive setup, title and liveness checks.

K62 retains exact focused-prefix correspondence. K57 retains finite calling,
private originals, collection and exact containment. K54 retains readiness and
the signed candidate, all-input and completed-golden freeze before runtime.
Snapshot-tree, empty-AXValue, OCR-substring and held-frame availability limits remain.
Every historical outcome, closed cap and held causal slot remains unchanged.

No VM, candidate, freeze, native acceptance, release or ancestor closure follows.
Local document checks cannot establish concurrency, useful native liveness or
repaired focus. The [integration receipts](ordering-keepalive-lifecycle-integration/)
retain each check and its actual outcome.

One narrow fresh-context reviewer inspected the repaired dispatch, result-delivery,
publication and stop joins. It found no material violation in that bounded scope.
This aimed review supplies no whole-design approval or runtime qualification.

Both changed diagrams and their revised captions render in the browser check.
It reports no browser errors. The documentation link check retains
exactly the two archived k23 missing targets already recorded by k97:
`context-predicate.txt` and `context-qualify-filter.sh`. No new missing target or
anchor appears. Each receipt records its subjects and actual result.
