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

## Decisions (running log)

- Keep the accepted workspace + desktop control conjunction and existing four
  error kinds. Four root mutations cover launch, browser open, path open and
  reveal. Results and nested receipt fields use the same two control capabilities;
  no workspace/desktop read is silently required.
- Application selection uses a bundle identifier, with an optional registered
  application path to constrain duplicate installations. A display name, executable
  path, argv, environment or shell text is not an application selector. Without
  the constraint, Launch Services chooses the installed copy; it is not a captured
  process. Search can reuse the constrained form without a reference conversion.
- Native acceptance is the receipt boundary. Launch/open may return a reliably
  observed PID + exact kernel start instant; its absence does not erase a
  successful open. The client separately captures desktop state under desktop
  read. Reveal acknowledges Finder communication, not observed selection.
- HTTP(S) URLs go to the resolved default browser explicitly, preventing universal
  links from silently selecting a native app. Files/folders use a default or named
  installed application. Missing dependencies are typed, pre-effect outcomes;
  ambiguous failures after dispatch remain failed with no automatic replay.
- Extend the existing workflow trace and visual document; give the concrete API
  its own current-state workspace spec, provider SDL and client examples. No
  separate ADR is needed: the authority/selection ADRs
  already own the consequential architectural choices. Design does not implement
  or claim acceptance of the native/VM obligations.
- Preserve script editing in explicitly named apps while refusing direct native
  executables/application bundles and the default executable-script route.
  Koine passes documents, never interpreter argv or shell commands; the named
  app's reaction is not sandboxed. The SDL and acceptance cases state both sides.
- The API is load-bearing for planning, so `launch-and-open-k53` is the scheduled
  fresh-context design review ahead of `launch-and-open-k29`. No in-session
  reviewer duplicates it. Native promises, payload boundaries and selection
  handoff completeness are its explicit doubts.

## Evidence and verification

- Tier 2 graph verification used project
  `Users-antony-Development-Koine.add-plugins-for-modaliser-requirements`, generation
  `2026-09-29T10:36:20Z`. `processStart` has inbound callers `running`/`isRunning`
  in DesktopProvider; its exact source reads `PROC_PIDTBSDINFO` kernel seconds
  and microseconds. Coverage reported no gap and matching metadata for that
  source. It establishes the existing representation, not an atomic new launch
  receipt guarantee. The new provider must not share desktop's private references.
- Docs/scripts were excluded from indexing, and Taskfile metadata had changed;
  they were read directly. The desktop manifest/build definition says release
  and schema 1.0.0 and signing identifier dev.antony.Koine.provider.desktop.
  `codesign -d --verbose=2` on the installed desktop bundle confirmed that actual
  signing identifier. Workspace's matching release identifier is a design value,
  to be checked on its built bundle before enabling the slot.
- Apple NSWorkspace documentation and the installed SDK header establish the
  proposed launch/open acknowledgment, options and Finder boolean route. The
  prompt option leaves Gatekeeper active. Signed VM behavior remains pending;
  this design changes no entitlement, certificate class or consent policy.
- `task design:workspace-check` passed: standalone provider SDL, composition
  with the documented baseline and all five client operations validate. Unknown
  field and foreign-provider-type negative controls were rejected. SHA-256 of
  Taskfile, client package manifest/lock, baseline SDL, workspace SDL and examples
  matched before/after the final run. This is static design validation, not
  served-schema conformance or native acceptance.
- `task check:docs` passed. `task design:workspace-render` produced both exports
  with D2 0.9.0 / PlantUML 1.2026.8. Opened the new sequence deep link in a fresh
  browser tab and inspected its rendering/current-discussion markers; inspected
  the outcome SVG at readable size separately. Mobile/dark appearance was not
  independently exercised. The reusable serving task uses only the presentation
  directory; the session preview used port 8771.
