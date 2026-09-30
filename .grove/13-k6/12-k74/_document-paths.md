# document-paths-k74 — brief

## Goal

Consume `docs/verification/protected-path-metadata.md` for the native inspection
limit. Named-app opening can use the measured metadata route. File-URL
default-handler lookup prompts on first protected-document access even after
metadata succeeds. Protected default opening remains live work: settle its
consent/semantics trade-off with Antony before relying on that call; do not
accept it through an implicit consent request or a silently changed handler rule.

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
