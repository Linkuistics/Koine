# launch-and-open-k6 — brief

## Goal

A client can:

- launch or activate a named application;
- open a URL in the default browser;
- open a file or folder with its default application or a named one;
- reveal a path in Finder.

This first working increment is the pathfinder for adding provider work under
`provider-architecture`'s settled layout. It has the least native risk, so it
flushes out build, approval, conformance and acceptance plumbing early.

The layout now names `workspace`. Its launch/open/reveal fields require
`workspace:control` AND `desktop:control`, since activation is an allowed
effect. This increment implements the additive framework feature
`additional-capabilities-v1` alongside its first real operation, following
`docs/specs/machine.md#additional-capability-requirements`. It also starts the
concrete operation rows in `docs/specs/workflow-providers.md`.

Consume `first-party-provider-selection-k50` and its settled review chain before
packaging workspace, including integration `first-party-provider-selection-k52`.
`docs/specs/machine.md#first-party-provider-selection` and
`docs/adr/first-party-provider-selection.md` own
the sealed catalogue, approval/version precedence, pre-load selection, candidate
diagnostics and no late retry. Implement its complete selection-acceptance table
through the assigned three seams, using a fresh native host process/marker log
per scenario and purpose-built sealed test hosts for catalogue defects. Include
visible tie fallback, per-candidate staging/quarantine isolation (including legacy
staging), new-update `first-party-selection-v1` refusal on old hosts with renamed
principals, missing-bundle diagnostics during successful replacement, and mixed
releases with disjoint native module/class names. Platform outcomes predicted by
the review remain bounded native/VM evidence here. Replacements retain shipped composition
positions. Own the missing-capability-owner cascade and exact-candidate conformance
profiles, including old-host and extension-host core + desktop, selected updates
and explicit absent/rejected sets. Catalogue baselines must match packaged desktop
and workspace; reserve the four later identities without enabling them early.
Additional-capability denial reports the deterministic first unmet member and
complete set. Baseline desktop operations and error diagnostics remain unchanged;
management candidate metadata is additive. Independent old/new binaries exercise
the feature and refusal paths. Antony approved the catalogue's stable release
signing-identifier check in k52, with distinct fixture identifiers admitted only
by test catalogues; no entitlement or certificate-class change is authorized.

## Done when

- The named launchers for Dia, ChatGPT, Claude, Zed, Visual Studio Code, Jump
  Desktop, Kimi, iTerm, Mail, Notes, Obsidian and Zotero launch or activate from
  a standalone client, whether or not the application was running. An
  application that is not installed is reported as an absent dependency, never
  as success or a stale target.
- Web search's Koine part opens the resulting search URL in the default
  browser. Query entry, Google suggestions and the typed-query fallback are
  recorded as client responsibilities, and no Google proxy lives in Koine.
- Client settings: the configuration directory opens in Zed. Reload and
  relaunch are recorded as client-owned.
- Every operation carries the authority `provider-architecture` allocated.
  Denied and revoked grants are refused through the public operations. The
  operation-to-capability trace gains these rows.
- The three seams accept it:
  - Public GraphQL: the introspected schema and a client driven only by the
    documented contract.
  - Native binary interface: the native loader path, including a new bundled
    provider with its in-app approval, schema design file and conformance if
    the architecture calls for one.
  - Isolated TestAnyware macOS VMs: signed Koine against the real applications
    installed in the VM.
- `Taskfile.yml` gains the reusable build and VM verification tasks this
  increment needs.

## Decomposition

1. `design` — the operations, their inputs and results, and the not-installed
   and no-handler cases.
2. `planning` — cut implementation leaves from the settled design.

## Notes

The launchers' secondary actions belong to `app-and-file-search`: reveal, copy
path and copy bundle identifier. That increment reuses these operations.
Installing the twelve applications in a VM is preparation that later increments
repeat. If it proves costly, a reusable preparation task in the Taskfile earns
its place here.
