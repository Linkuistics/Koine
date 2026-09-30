# web-urls-k70 — brief

## Goal

Web search's Koine part. `workspaceOpenURL` opens a client-built search URL in
the default browser. Query entry, Google suggestions and the typed-query fallback
remain client-owned, and there is no Google proxy in Koine.

## Done when

- The Browser URL row passes at L, G, N and V. So do the URL parts of the Input
  boundary, Receipt, Bounded acknowledgment and Authority rows.
- The workspace conformance profile includes the URL root, and the contract-only
  client opens a typed-query URL.
- The Web search trace row links the evidence and records the client
  responsibilities.

## Decomposition

1. `open-url`: the operation, verified at L, G and N.
2. `open-url-vm`: V acceptance with real browsers.
