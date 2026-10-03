# Application search uses bundle identity

Application search merges checked-link and direct routes to one established
native bundle directory identity, and uses its filesystem-reported canonical
filename/path for matching, ranking and display. Distinct native copies with
the same bundle identifier stay distinct. The
[search contract](../specs/workspace-search.md#matches-ordering-and-bounds)
defines revalidation and observation limits; file results remain locations.

This makes one installation one chooser entry without retaining a history of
every discarded route. It also means an application link's alias name is not
an extra application comparison key, and copy/reveal uses the canonical target
rather than the link. That naming/selection contract is surprising and costly
to change after clients use it. Stable route-independent rank allows bounded
top-N eviction while retaining every observed rootIndex for the final choices
in unchanged native observations.

Admitted root/frame/witness paths use the same filesystem-reported directory-path
operation as bundle targets; preliminary link resolution is not their returned
canonical spelling. File entry paths join a canonical parent with the observed
name, preserving final symlink locations. Mixing realpath's Data-volume spelling
with descriptor-path presentation would duplicate unchanged file locations and
fabricate application path changes. Synthetic protected/cloud targets derive
from canonical-home components without opening excluded directories. Actual
firmlink, case and Unicode call behavior remains a signed-host obligation.

Exact-path deduplication duplicates Safari when a checked link and a canonical
root both discover it. Identifier deduplication merges real separate copies.
Choosing the best observed alias spelling/rank needs identity history for
discarded choices that can later improve and re-enter, including earlier root
membership; otherwise traversal order determines omitted metadata. Reopen alias
matching only for an agreed consumer requirement together with a bounded
history/continuation contract. Observed native changes remain partial coverage;
this decision supplies neither atomic identity nor an exhaustive inventory.
