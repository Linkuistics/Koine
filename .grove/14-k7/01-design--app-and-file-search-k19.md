# app-and-file-search-k19

## Goal

Consume `docs/verification/protected-path-metadata.md` before choosing native
inspection calls. The measured metadata route is prompt-free on the three
protected home roots; document file-URL default-handler lookup prompts.
Handler metadata stays unknown/blocked where a prompt-free route is unestablished.
This result does not establish traversal/content-search consent, and approves no
new entitlement, consent identifier or type-only handler substitution.

Design installed-application search and file search, and how a result feeds
`launch-and-open`'s operations and the clipboard allocation.

## Context

- `provider-architecture-k5` and `launch-and-open-k18`.
- Requirement rows Application search and File search, and the empty-result
  versus failure rule in "Ownership and existing constraints".
- Modaliser's launcher constructors show the secondary actions a selection
  offers.

## Done when

Evidence is recorded under `docs/verification/`. It is a bounded check in an
isolated VM, under the signed hardened Koine:

- which public mechanism discovers installed applications, and which finds
  files under a root;
- how TCC-protected folders affect results, and whether Koine needs consent it
  does not hold;
- how the index-unavailable case shows itself.

A guarantee the platform does not give becomes a stated limit.

The spec states:

- query semantics;
- result metadata, including unknown values;
- bounds and ordering;
- how a result becomes an input to the launch, open and reveal operations;
- clipboard behavior or its client allocation;
- authority and errors.

## Notes

Do not chase exhaustive filesystem coverage. The requirement is the configured
roots and an honest report of what the mechanism cannot see.
