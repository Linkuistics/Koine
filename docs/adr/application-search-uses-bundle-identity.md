# Native application discovery retains installation identity

Native application choices distinguish installations, including distinct copies
with the same bundle identifier. Established bundle-directory identity can relate
direct, linked and OS-reported observations of one installation; an identifier
alone cannot merge real copies. The returned
[native catalogue design](../specs/workspace-search.md) must settle its sources,
merging and selected-location semantics within the
[current ownership boundary](raw-filesystem-search-belongs-to-clients.md).

Path-only deduplication duplicates aliases; identifier-only deduplication loses
installation choice. Unestablished identity remains unknown or explicitly omitted
rather than an invented merge. Native inspection costs and uncertainty must be
bounded and reported, without a query-long identity pin or movement guarantee.
Clients own filtering, ranking and MRU. Existing explicit actions revalidate the
selected identifier and installation path under their own contracts.

The former raw-search proposal's first-finalized route, command-reported file
locations and exact matching rules are comparison input, not the new catalogue
API. Preserve useful native per-copy choices without introducing a raw walker.
Revisit identity semantics for a concrete alias-launch requirement or measured
native limitation that defeats required application choices.
