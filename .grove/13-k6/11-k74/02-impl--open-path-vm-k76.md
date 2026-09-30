# open-path-vm-k76

## Goal

Accept path opening at V with real handlers and disposable fixtures in the
prepared VM, and widen the public contract checks to the path root.

## Context

- The workspace spec's Documents/directories/settings and Input boundary rows.
- The prepared VM from `application-launchers`.

## Done when

- The fixtures are a temporary text file, a directory and a document package.
  Each opens with its default handler and with Zed named.
- The configuration directory opens in Zed.
- Missing file, parent, link, application and handler cases produce their typed
  results. Inspection denial is `failed`. Literal spaces, punctuation and
  symlinks are honored.
- No handler setting is changed.
- A source script opens in its default editor and in named Zed whatever its
  executable bits. Finder aliases to documents and to applications are refused
  before dispatch.
- In disposable fixtures, Terminal script and location-document reactions are
  observed and recorded as disclosed handler reactions, without claiming a
  sandbox.
- Accessibility is absent throughout, and the operation still works.
- The workspace profile includes the path root, and the contract-only client
  opens a document and a directory.
- The spec rows and the Client settings trace row link the evidence document.
