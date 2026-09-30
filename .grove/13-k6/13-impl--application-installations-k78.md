# application-installations-k78

## Goal

Accept the Multiple copies and installation row at G, N and V for both
application launch and named-application document opening.

## Context

- The workspace spec's application-selection paragraphs and the Multiple copies
  and installation row.
- The shared application input implemented in `workspace-launch-k59` and reused
  by `open-path-k75`.

## Done when

- A fixture application is registered at two locations by a reusable recipe.
- Unconstrained launch and named-application opening reuse a running copy at the
  other location. An installation path addresses exactly the chosen copy, even
  while the other runs.
- The failure cases each produce their specified result:
  - a missing or unregistered copy;
  - stale registration after deletion;
  - an identifier mismatch;
  - a registered present copy in the Trash, which stays eligible.
- Symlinked and Unicode-variant spellings are compared by native file identity.
- Metadata denial is `failed`.
- A bundle-less program has no named-selector route, and default-handler use
  remains distinct from it.
- Any L gap for inspection failures that the earlier leaves left is closed here.
- The spec row links the evidence. It is the constrained form that
  `app-and-file-search` will use for a chosen installation.
