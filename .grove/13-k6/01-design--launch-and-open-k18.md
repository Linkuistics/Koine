# launch-and-open-k18

## Goal

Design these operations within `provider-architecture`'s layout: launch or
activate an application, open a URL in the default browser, open a file or
folder with its default application or a named application, and reveal a path
in Finder.

## Context

- `provider-architecture-k5`'s ADR, authority allocation and error
  classification.
- Requirement rows Named application launchers, Web search and Client
  settings.
- Modaliser's installed launcher and web-search libraries record the intended
  results: launch-or-activate, the typed-query fallback and the
  open-in-default-browser step. They are not a mechanism to copy.

## Done when

The spec states each operation's input, result, authority and error
classification:

- how an application is named when it is not running, such as a bundle
  identifier;
- what activation does for a running application;
- whether the result names the process incarnation, so a client can continue
  with desktop operations;
- a not-installed application, an absent default handler for a URL or file,
  and a missing path, each distinguishable from success.

Also settled:

- The concrete workspace schema uses typed dependency-unavailable results and
  an unconditional workspace-control plus desktop-control requirement. The
  shared additional-capability contract is the architecture's input, not an
  invitation to redesign grants in this increment.

- The packaging consequences, if the operations live in a new bundled
  provider: the in-app approval record, the schema design file,
  `task conformance` and the schema digest.
- Consume `first-party-provider-selection-k50` and its settled review chain:
  `docs/specs/machine.md#first-party-provider-selection` defines reserved
  identities, version/approval selection, additive candidate diagnostics and the
  no-retry boundary. Carry the complete selection acceptance table into planning,
  including signed desktop/workspace updates and exact-candidate profiles, along
  with the missing-owner cascade and complete capability-denial set. Record the
  workspace catalogue baseline with its packaged version/schema version.
  Integration `first-party-provider-selection-k52` assigns each case to native,
  public and/or VM evidence. Carry fresh host processes and marker controls,
  purpose-built sealed catalogue fixtures, visible tie fallback, candidate-specific
  staging/quarantine, renamed-principal old-host refusal under
  `first-party-selection-v1`, complete diagnostics and disjoint native module/class
  publication into planning. The selection trade-offs are in
  `docs/adr/first-party-provider-selection.md`; platform predictions remain to be
  confirmed here through the bounded assigned seams.
  Antony approved the additional stable release signing-identifier check in k52.
  Record each enabled catalogue value with the packaged provider's actual signing
  identifier; use separate fixture identifiers and purpose-built test catalogues.
- The VM acceptance cases, and which applications each needs installed.
- Clients cannot supply an arbitrary executable or shell command through
  these operations.

## Notes

Search, its metadata and clipboard actions belong to `app-and-file-search`.
Keep operation shapes reusable by that increment's secondary actions.
