# authenticated-endpoint-k4 — brief

## Goal

The first working Koine: a process embedding the Koine server binds loopback,
publishes its endpoint descriptor and answers authenticated GraphQL. A client
holding a grant can find the endpoint, read `Query.koine` and introspect the
whole served schema. Everything later — the resident application, providers,
the desktop path — embeds and extends this server.

## Done when

- A client that knows only the documented contract reads the endpoint
  descriptor, presents a bearer credential and receives `Query.koine` plus full
  standard introspection of the served schema.
- The first grant is created through the in-process local-console principal
  using the same GraphQL execution, authorization and storage path that HTTP
  callers use. Grants are durable; credentials are stored only as digests.
- The spec's version-1 HTTP, status-code, limit and descriptor-lifecycle rules
  hold at the public boundary.
- All of it is verified through the public GraphQL seam: tests drive the real
  listener over loopback HTTP; only grant bootstrap uses the console principal.
- Build and verification commands exist and are written down.

## Decomposition

1. `first-authenticated-query` — the walking skeleton: package, listener,
   descriptor, durable grant store, console principal, bearer authentication,
   `Query.koine` and introspection. It makes the library and tooling choices.
2. `transport-policy` — the remaining HTTP rules, request/response limits and
   descriptor lifecycle, hardening the path the first leaf opened.

The order is a dependency: the second leaf constrains a path that must exist.

## Pointers

- Spec sections: "Local transport and discovery", "Public GraphQL contract"
  (introduction), "Grants and management" (credential encoding, store,
  "Management authority and surface").
- ADR: `docs/adr/bearer-grants-and-live-revocation.md`.
- Seam: public GraphQL only. No UI, provider or VM work belongs here.

## Notes

**Serve only what is implemented.** The design SDL in
`docs/design/desktop-schema.graphql` is the target, not a stub list. Each stage
adds the fields it makes real; an introspectable field with no behaviour is an
inert layer. `release-acceptance-handoff-k11` checks the final composed schema
against the design SDL.

**The server is an embeddable library.** The resident application (stage
`resident-app-manual-grants-k7`) embeds it and supplies the console principal
to its UI; tests embed it the same way. Do not build a throwaway headless
product or an unauthenticated bootstrap path to make tests convenient.

**Package boundaries.** The Machine core stays free of macOS, client and
concrete-provider dependencies; platform services (Keychain, Accessibility,
AppKit, login items) live outside it. Keep the GraphQL library's types private
to the engine from the start: the later provider framework must not expose them.

**Tooling.** No build tooling exists yet. Choose libraries and build tooling
from verified primary sources, record the commands in the README. A root
`Taskfile.yml` was suggested in earlier sessions and the human has not
confirmed a workflow tool; once real commands exist, put that one question to
the human with a recommendation instead of adopting a tool silently.
The local toolchain observed during planning was Swift 6.4 / Xcode 27 on
macOS 26; the spec's deployment floor is macOS 13.
