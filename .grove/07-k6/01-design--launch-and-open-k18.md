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

- The packaging consequences, if the operations live in a new bundled
  provider: the in-app approval record, the schema design file,
  `task conformance` and the schema digest.
- The VM acceptance cases, and which applications each needs installed.
- Clients cannot supply an arbitrary executable or shell command through
  these operations.

## Notes

Search, its metadata and clipboard actions belong to `app-and-file-search`.
Keep operation shapes reusable by that increment's secondary actions.
