# document-paths-k74 — brief

## Goal

Documents, directories and client settings. `workspaceOpenPath` opens a literal
local path in its default or a named application under the narrow metadata
refusal policy, including opening the configuration directory in Zed.

## Done when

- The Documents/directories/settings row passes at G, N and V.
- So do the path parts of the Input boundary, Receipt, Bounded acknowledgment,
  Authority and Consent rows.
- Client settings opens the configuration directory in installed Zed. Reload and
  relaunch are recorded as client-owned.
- The workspace profile includes the path root. The contract-only client opens a
  document and a directory.
- The Client settings trace row links the evidence. So does the File search
  row's reuse of this action.

## Decomposition

1. `open-path`: the operation, verified at L, G and N. It uses the answer of
   `protected-path-metadata-k73`.
2. `open-path-vm`: V acceptance with real handlers and disposable fixtures.
