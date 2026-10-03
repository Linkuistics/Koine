# Search coverage describes observations

Workspace search exposes root observation summaries and counted exclusion
groups instead of a path-by-path traversal log. A complete eligible domain can
be called a searched subtree; partial observations and an unfinished remainder
cannot. The [search contract](../specs/workspace-search.md#coverage-and-aggregate-outcomes)
defines each extent, count and bound. This public vocabulary is costly to change
once clients use it and deliberately gives them less location detail than a
filesystem audit.

A per-directory searched record and per-entry intrinsic exclusion consume a
finite diagnostic budget before a realistic application/home tree can be
searched. Increasing that shared budget merely moves the cutoff and permits
one root to starve later roots. Root summaries, intrinsic anchor counts and
independent root partitions decouple ordinary-directory/intrinsic diagnostic
volume from name discovery and prevent one root spending another's credits.
Exact exceptional parents and permission targets remain visible, but
parent-keyed frontier/depth groups can still exhaust diagnostics and stop deeper
discovery. The [open discovery obligations](../specs/workspace-search.md#discovery-obligations-before-planning)
require a fresh traversal/aggregation design and review before planning; this
granularity choice does not settle that schedule or accept its sample.
Resource exhaustion preserves an honest remainder. Match slots reserve their
maximum size separately so metadata growth cannot consume diagnostics or
change which ranked names fit. The four admitted jobs can retain about 157 MiB
of charged coverage/frontier/match/wrapper values plus bounded scratch, including
while native calls block; this is an accounting ceiling, not allocated memory
or RSS. This costs reserved capacity and withholds the
identities of grouped exclusions. It provides neither a reproducible partial
sample nor an exhaustive installed-app inventory.

An exhaustive index or persistent paginated search would retain more history,
but adds lifetime, invalidation, consent and availability contracts. The
[signed-host comparison](../verification/search-discovery.md#design-consequences-and-limits)
found no usable index-health signal and a prompting protected query. Reopen
that alternative only with a supported prompt-free mechanism and useful
coverage/availability evidence, or an expressly approved changed workflow.
Reopen detailed traversal records if a real consumer needs exclusion identities
rather than name search. Neither this choice nor the bounds accept reduced
home/application coverage: that needs the operator's existing baseline decision.
