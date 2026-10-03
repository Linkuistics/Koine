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
describe omitted descendants. Exact invalid/size-refused child parents, exceptional
failures and permission targets stay visible. Exhaustion preserves an honest
remainder. Maximum-size match slots keep metadata growth out of diagnostics
and ranked eviction. This costs reserved capacity and withholds grouped identities.

The separate [traversal decision](search-traversal-preserves-shallow-names.md)
owns FIFO order and its frontier/repeated-work costs. Private descriptor
admission, worker cleanup, revalidation and witness accounting live in the
[resource contract](../specs/workspace-search.md#resource-accounting-and-scheduling),
where their reversible mechanics and native evidence obligations can change
without hiding them beneath this public-vocabulary slug. Changed queued
prefixes use one root remainder; only independent exact failures can fan out
into diagnostic exhaustion. No record/byte accounting certifies throughput.

A detailed traversal log still buys identities that the chooser does not need.
An exhaustive index or persistent paginated search adds lifetime, invalidation,
consent and availability contracts. The
[signed-host comparison](../verification/search-discovery.md#design-consequences-and-limits)
found no usable index-health signal and a prompting protected query. Reopen
that alternative only with a supported prompt-free mechanism and useful
coverage/availability evidence, or an expressly approved changed workflow.
Reopen detailed records for a consumer that needs exclusion identities.
The [canonical directory contract](../specs/workspace-search.md#canonical-directory-observation)
distinguishes known native/public size refusals from uncertainty and preserves
actual-parent groups and one root stop for dependent queued work.
Neither these observations nor accounting accept reduced home/application
coverage: the operator's existing baseline decision remains required.
