# native-observation-resource-boundary-k104


## Goal

Resolve the concrete resource-admission conflict with the human before the
owned AX exchange resumes. Establish an actionable boundary or leave this work
live; do not turn another source-only result into exchange completion.



## Original context

Read `docs/verification/native-observation-receive.md#pre-copyout-admission-assessment`
and the admission view at `http://127.0.0.1:8772/#diagram-process-receive-admission`
(serve `docs/design/architecture` if needed). k103 completed its bounded
evidenced-conflict branch, not the runtime exchange. k102's local message mapped
128 KiB before a 64 KiB parser cap rejected it. k103's inspected peek, queue-limit
and overwrite interfaces establish no replacement acquisition envelope. Other
mechanisms are not proved absent, and 64 KiB is not an agreed product budget.

The existing constraints are finite usable resource admission in resident Koine,
public clients, no helper/injection/target cooperation/application restriction,
Koine-owned consent and the unchanged retained-endpoint/read-attribution contract.
Do not reopen them as if undecided; seek explicit agreement only for a concrete
proposed change. A helper by itself does not bound kernel queues or resources.

## Done when

- Present the precise trade-off and evidence, with the recommendation to retain
  current constraints and require a named enforcement lead before native sends.
  Make the consequence explicit: the exchange and first release remain unresolved.
- Establish what acquisition/failure budget is acceptable and its threat scope,
  without equating trusted sender identity, parser caps, rapid cleanup or finite
  integer widths with pre-copyout enforcement. If the human wants to reconsider
  process composition or resource guarantees, record exactly what changes and
  which original constraints remain; do not promise that isolation solves it.
- Record an actionable next direction: a concrete mechanism to investigate with
  a bounded discriminator, an explicitly authorized constraint change requiring
  design, or an explicit human decision about the path. If constraints remain
  and no lead is selected, say so and keep this leaf live rather than commissioning
  a generic survey or another identical exchange leaf. Pruning requires the
  human's explicit decision, never inferred from the conflict.
- Reconcile any agreed durable change into the existing spec/ADR set and hand
  the precise decision to `native-observation-complete-exchange-k105`. No product
  implementation or native success is implied by the agreement.

## Notes

The initial charter preserved every private-exchange criterion. During this
interview the human explicitly reconsidered and rejected that route for the first
deliverable, as recorded below. That scope decision permits pruning its remaining
leaves and closing only the private branch. It does not complete k75 or its
ancestors, capture/transfer feasibility, k52 implementation or release acceptance.

## Decisions (running log)

- The human chose **retain the existing hard admission requirement** after
  considering over-budget acquisition from an authenticated target. Memory and
  Mach rights must be bounded before acquisition; sender authentication, later
  validation and cleanup do not substitute for enforcement. This retains the
  existing constraints, including no helper or application restriction. The
  exchange and first release remain unresolved until a concrete enforcement
  lead is established. This answer selects neither numerical product budgets
  nor a mechanism; keep this leaf live while those and an actionable next
  direction remain unsettled.

- Checked the named `MPO_FILTER_MSG` candidate against the same pinned XNU
  revision as k103. Its inspected sandbox callback has no message-body size or
  right-count input, and invocation depends on sender filtering policy. That
  interface supplies no evidenced receiver-selected resource quota. The receive
  report and source manifest preserve exact paths and hashes. No native test
  ran, no usable mechanism was selected, and this bounded finding does not
  commission another survey or satisfy the exchange criteria.

- After asking where the limits apply and whether this work still serves
  non-time process identity, the human agreed to **review whether the private
  native Accessibility transport scope remains justified before choosing
  numerical limits**. Perform that scope review against the existing evidence
  and identify the precise guarantees a smaller path would change. This does
  not approve a weaker targeting/read contract, abandon a leaf, or reverse the
  retained hard-admission requirement. The numerical-budget question remains
  unanswered while the scope decision comes first.

- The human chose **adopt the smaller public-AX contract** after reviewing the
  explicit consequences: retain non-time callback capture and expiry; use public
  Accessibility for listing, focus and notifications; accept wrong-target data
  or effects during process/window reuse, stale notifications and mistaken
  invalidation; and rely on framework-managed AX receipt without Koine's hard
  pre-acquisition memory/right bound, including possible resource pressure or
  Koine failure. This changes the preceding hard-bound decision only for that
  framework-managed AX path. Koine still enforces grants, owns consent, rejects
  known-dead captures and bounds its own records/work. Capture/right transfer
  and its resource contract remain to be designed and evidenced. The private
  AX endpoint/wire protocol is no longer part of the first deliverable; update
  the durable contract and task tree to that decision. No native capture/transfer
  feasibility, implementation or release acceptance is implied.

## Scope review (accepted direction; detailed design remains)

The first deliverable is the captured-application → list windows → focus path
that unblocks ModalAnyware. Replacing the time-based process identity does not
itself require an owned Accessibility wire protocol. The additional endpoint,
read-attribution and observation guarantees led to that protocol. The current
provider already checks process identity and then uses public AX operations;
the check-to-use interval exists in that implementation too.

The existing evidence identifies a real distinction: a continuously held task
right preserves process identity, while a held AX window can read from or affect
a replacement after actual PID reuse. A public-AX direction therefore cannot
be presented as preserving the current endpoint/read contract. The experiment
deliberately used an old AX object after known task death; it establishes that
platform behavior, not the probability of a race in ordinary Koine use.

The accepted smaller direction keeps callback-time capture, non-time process
identity and its ownership/expiry, public client APIs, client-owned adapters,
Koine consent, capabilities and the no-helper/no-cooperation constraints. It
uses public AX APIs for desktop operations and observation. It explicitly changes these preceding promises:

| Preceding promise | Accepted consequence |
|---|---|
| Every operation uses the continuously retained admitted endpoint | Let the public AX framework route calls; checking identity cannot prove its destination remained unchanged. |
| Replies and notifications authenticate against the captured process and window lifetime, with separately established freshness | Accept framework-reported data as best effort, without independently established read freshness or notification age. Process/window replacement can make data or effects belong to a different target during races. |
| Authenticated, fresh, lifetime-attributed closure causes permanent retirement and governs remembered-window state | Preserve irreversible local invalidation and token non-reuse, but public callbacks alone do not prove authenticated closure. Stale or misattributed delivery may invalidate a still-live window reference or remove it from remembered results. This is withdrawal based on platform reports, not a claim of authenticated closure. |
| Enforce a hard memory/right envelope before AX receipt | Rely on the framework's native receive handling. Koine cannot claim its own pre-acquisition bound for that path; resource pressure or resident-process failure remains possible. Bounds on Koine-owned records, work and accepted values still apply. |

Capture attribution, actual right transfer, reference/restart semantics,
AX-contact lifecycle consequences and public receipt/error descriptions still
need design and evidence, followed by rebuilt signed/notarized acceptance.
Choosing public AX does not complete those obligations. In particular, any proposed capture-transfer channel must
have an explicit resource contract; moving the AX receiver into a framework does
not automatically solve or waive that separate channel's admission obligation.
This option is a smaller design direction, not a feasible completed protocol or
permission for k52 to implement it.

The alternative presented was retaining the stronger guarantees and leaving the
exchange/release unresolved until a concrete lead exists. The bounded source
results do not prove no lead can exist. The recommendation was the smaller
public-AX direction for the capture/list/focus deliverable, with the consequences
above explicit. The human accepted it; this specifically revises the initially
retained hard bound for framework AX receipt. Capture/transfer and the complete
client contract remain real work.

One in-session adversarial reviewer found that the initial comparison omitted
independent freshness and the possibility of false invalidation or remembered-
window removal. Classified as valid, actionable omissions in the stated
trade-off; the table now makes them explicit. The finding changes the proposal's
disclosure, not a native mechanism or evidence claim. No additional reviewer or
native experiment is needed to record the trade-off the human then accepted.

Evidence: the capture ADR and the reconciled public Accessibility ADR;
`docs/verification/retained-ax-binding.md` (held-only experiment);
`docs/verification/native-observation-receive.md` (framework receive behavior
and the acquisition conflict); and exact current provider source for
`resolveAndAct`, `act`, `held`, `processStart` and `WindowObservation`.
Tier 2 graph coverage reports matching metadata and no recorded gap for those
Swift paths and cited documents; call edges were heuristic and verified against
the exact snippets, not treated as native OS evidence.

## Reconciliation and handoff

The current spec, ADR set, glossary, README/client guide, evidence conclusions
and architecture views now state the accepted public-AX scope. k105 receives the
explicit decision to abandon its private exchange; k91/k95/k96/k92 are rejected
for the same first-deliverable scope. The k101/k99/k94/k90/k83 original native
criteria were not delivered and are labelled historical, not marked satisfied.
Their surviving local ownership/non-revival concerns move into k86/k87, and the
capture-channel acquisition requirement remains in k84. k75 and every ancestor
above it remain live with capture/transfer, lifecycle, consent and full agreement
work before k52. No private runtime result or shipping authorization is claimed.

## Verification and close check

- `task design:render-process-identity design:render-receive-admission
  design:render-receive-budget` completed; all render subjects (Taskfile,
  manifest, PlantUML sources and renderer launcher) had matching before/after
  digests item by item. Inspected the seven changed PNG exports. No fresh browser
  or native/product run; earlier UI evidence retains its original byte scope.
- Checked tracked Markdown relative links/headings, manifest IDs/groups and
  source/export/discussion/update references, and parsed SVG XML. Deliberately
  missing file/heading controls were rejected; real targets passed. The old ADR
  slug was absent in a hidden-inclusive repository sweep that first detected a
  deliberately dirty scratch control; new ADR citations and historical endpoint
  wording were positive/cross-tree controls. Both new primary-source hashes
  match the inspected pinned downloads.
- The served schema/authorization material between the coordinate table and
  reference behavior is byte-identical to the parent; production code and served
  SDL were not changed. No Swift/native test result is claimed by these checks.
- Final Tier 2 coverage generation `2026-09-23T13:04:13Z` reports matching metadata
  and no recorded gap for the relied-on Swift files and current Markdown/JSON
  surfaces. PlantUML and checksum text are not tracked by the graph; SVGs are
  excluded. Direct source reads and generated-image inspection cover those
  surfaces, without treating a clean graph result as completeness proof.
- The explicit public-AX decision satisfies this leaf's authorized-constraint-
  change branch. Original private runtime criteria remain undelivered and are
  recorded as such. On this leaf's retirement, k101/k99/k94/k90/k83 contain only
  DONE evidence and ABANDONED private investigations; their scope disposition and
  surviving obligations are promoted to k75 and the current ADR/spec. k75 and
  k72/k57/k54/k51 remain live; k84 is the next existing design responsibility.
