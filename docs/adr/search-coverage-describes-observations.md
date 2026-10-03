# Search coverage describes observations

Workspace search exposes root observation summaries and counted exclusion
groups instead of a path-by-path traversal log. A complete eligible domain can
be called a searched subtree; partial observations and an unfinished remainder
cannot. The [search contract](../specs/workspace-search.md#coverage-and-aggregate-outcomes)
defines each extent, count and bound. This public vocabulary is costly to change
once clients use it and deliberately gives them less location detail than a
filesystem audit.

Per-directory searched records and per-entry intrinsic exclusions consume a
finite diagnostic budget before realistic application/home discovery finishes.
Root summaries, intrinsic anchor counts and independent root partitions
decouple ordinary-directory diagnostic volume from discovery. One reserved
root depth group counts encountered anchors themselves, including an empty
directory whose EOF was not observed; names remain matchable and counts never
describe omitted descendants. Exact invalid/overlong-name parents, exceptional
failures and permission targets stay visible. Exhaustion preserves an honest
remainder. Maximum-size match slots keep metadata growth out of diagnostics
and ranked eviction. This costs reserved capacity and withholds grouped identities.

Per-root FIFO breadth-first traversal finishes shallower admitted listings before
deeper ones with one current stream and a bounded pending queue. Queue overflow
increments one reserved FRONTIER_LIMIT root group, keeps anchor names matchable
and continues sibling examination; depth has its own group. DFS loses later
shallow home names in an early enormous branch. Iterative deepening repeats
shallower scans against the unchanged entry/wait budget and changing observations.
The queue deliberately costs pending-path capacity and can omit deep names in
wide trees, a visible trade-off whose actual workflow coverage remains unaccepted.
Revisit if measured per-witness omissions defeat the workflow and a bounded
alternative gives better coverage without unapproved budgets/domain/setup.

One process-lifetime search owner atomically reserves worker and owned-descriptor
credits shared by aliases/jobs/provider instances, below the inherited soft
limit with a non-search reserve. Root-local EMFILE cannot isolate listener,
store or action opens. Reserving complete job credits before inspection avoids
partial admission and held-resource wait cycles, at the cost of refusing jobs
whose full credits will not fit. Platform-internal descriptors and unrelated
demand remain native serviceability obligations, not a proved OS reservation.
No larger limit or smaller domain follows; its load-bearing review precedes
planning. The
[discovery obligations](../specs/workspace-search.md#discovery-obligations-before-planning)
keep the measured-scale witnesses and normally launched host serviceability live.

Worker-owned streams, queued paths and job credits remain charged through
cancellation until worker-only cleanup; another thread cannot close idle frames
under a blocked call.
Before descendant open, recheck the held parent's canonical location, identity
and policy. Observed movement refuses descent; the remaining check-to-open
window and the location call itself need prompt-free signed-host acceptance.
Admission/policy witnesses include protected and cloud paths with every retained
occurrence charged; failure of their pre-turn job account refuses every root,
rather than silently omitting a policy witness. The spec owns the enumerated
maximum shapes, not a claim about native memory or throughput.

A detailed traversal log still buys identities that the chooser does not need.
An exhaustive index or persistent paginated search adds lifetime, invalidation,
consent and availability contracts. The
[signed-host comparison](../verification/search-discovery.md#design-consequences-and-limits)
found no usable index-health signal and a prompting protected query. Reopen
that alternative only with a supported prompt-free mechanism and useful
coverage/availability evidence, or an expressly approved changed workflow.
Reopen detailed records for a consumer that needs exclusion identities.
Neither these observations nor accounting accept reduced home/application
coverage: the operator's existing baseline decision remains required.
