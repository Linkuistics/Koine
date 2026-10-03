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
to change after clients use it. Stable reported spelling permits route-independent
bounded top-N rank and
observed root membership. A retained identity keeps its first finalized reported
name/path when later same-identity spellings differ; discarded identities have
no global spelling history.

The naming contract uses the default firmlink presentation and never replaces
a refused path with an alternate spelling. The public value ceilings and eligible
domain remain unchanged; path-size diagnostics do not accept reduced workflow
coverage. The [search contract](../specs/workspace-search.md#path-design-dependencies)
owns its realization, spelling/change evidence, size scopes and native limits.

Exact-path deduplication duplicates Safari when a checked link and a canonical
root both discover it. Identifier deduplication merges real separate copies.
Choosing the best observed alias spelling/rank needs identity history for
discarded choices that can later improve and re-enter, including earlier root
membership; otherwise traversal order determines omitted metadata. Reopen alias
matching only for an agreed consumer requirement together with a bounded
history/continuation contract. Observed native changes remain partial coverage;
this decision supplies neither atomic identity nor an exhaustive inventory.
