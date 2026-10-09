# Raw filesystem search belongs to clients

Clients own raw filesystem search, including traversal, name filtering, ranking,
budgets and their search process's OS permissions. For v1, Koine supplies
**special locations** and named **native catalogues**, initially applications and
modern System Settings destinations on macOS 26+. A location value grants no
filesystem access or consent. The
[workflow requirements](../requirements/modaliser-workflows.md#ownership-and-existing-constraints)
define this boundary; the [native design](../specs/workspace-search.md) selects
interfaces and honest completeness. Mandatory review and native acceptance
precede delivery. V1 exposes no general OS metadata-query
API or hidden raw-search fallback.

Keeping generic traversal in Koine would make the server own filesystem search
ordering, worker lifetime and broad permission policy in addition to native
knowledge. Client ownership gives clients their choice of search engine and
permissions while Koine retains reusable native discovery and explicit actions.
Clients that need filesystem access must supply it themselves; returning a path
is not a filesystem proxy. Koine's own location and catalogue reads remain
prompt-free, with honest blocked/unavailable/incomplete observations.

The [system-find comparison](../verification/search-tooling.md) explains the cost
of the rejected server-owned raw-search direction. Its mechanism and permission
answers do not select a native catalogue backend. General metadata queries may be
reconsidered after v1 for a concrete need the named categories cannot serve;
bringing raw search back into Koine would require a new ownership decision.
