# discovered-applications-k177

## Goal

Every application the provider discovers itself (the identifier's preferred copy
for an unconstrained launch or named open, a default handler for a target, a
default web browser, and Finder for a reveal) is resolved with the walk after the
read that found it, and is refused at the limit before anything addresses it by
path. After this leaf no caller-influenced or registry-supplied location reaches a
whole-path call before the limit.

## Context

- `docs/specs/workspace-launch-and-open.md#order-of-target-and-application-stages`
  (stages 3 and 4) and `#application-hand-off-limit`.
- Integration k170: an over-limit discovered application is refused after the
  discovery read that found it and before any metadata read or submission, so
  "no request" means no domain request and never zero reads.
- `Providers/WorkspaceProvider/Logic/Selection.swift` (`selectInstallation`,
  `selectWebHandler`), `OpenPath.swift` (`selectPathHandler`), `RevealPath.swift`.
- The walk from `reveal-locations-k174` and the stage 2 work of
  `application-locations-k176`.

## Done when

- A discovery read finds the location: no registration is
  `APPLICATION_NOT_INSTALLED`, a completed nil default-handler report is
  `NO_DEFAULT_HANDLER`. The discovered location is then resolved: established
  absence is that same dependency, as a stale registration is today, and a
  resolution failure, a cycle or impossible name included, is `failed`.
- The selected application's spellings are then checked against the limit, and
  only then is its metadata read: a present non-application is the stage 3
  dependency, a named selector's identifier is checked as before, and a reveal
  reports every Finder dependency, a mismatch included, as
  `APPLICATION_NOT_INSTALLED`.
- L: an over-limit discovered application or default handler records exactly the
  discovery read that found it and then no metadata read and no submission; a
  cycle or impossible name at a default handler is `failed`; a Finder registration
  with another identifier is `APPLICATION_NOT_INSTALLED`. Two cases stay apart.
  Where the **selected** copy is short (a constrained launch or named open choosing
  it by `applicationPath`, or an unconstrained one whose preferred copy is short)
  an unequal long registered copy, enumerated before or after it, never stops the
  workflow. Where the identifier's **preferred** copy is the long one, an
  unconstrained launch or named open discovers it, selects it and refuses its
  over-limit spelling with `failed` before any request: no other copy is
  substituted, and a short copy already running does not rescue it, because the
  refusal precedes the platform. A substitution route would need contract
  authority from Antony and is not a fixture repair.
- N and G as for `application-locations-k176`, for the discovered forms. Every
  caller of `inspectApplication` is enumerated and either converted or shown not to
  take a caller-influenced or registry-supplied location. The receipt's executable
  identities (`liveExecutableIdentity`, `RunningApplication.executableIdentity`,
  `fileIdentity(ofPath:)`) are not callers of it and are owned by
  `receipt-executable-identity-k183`; this leaf leaves them untouched. `selectWebHandler`
  has the same shape as a default handler; follow the spec if it states the rule,
  and if it is silent record the decision in this leaf's log and add the one line to
  the spec.
- The two defects named in the spec are gone from the action stages: no
  `ELOOP`/`ENAMETOOLONG` is mapped to absence anywhere in the provider, and no
  whole-path call addresses a stage location before the limit
  (`task check:launch-call-path` says so and is seen to fail against a mutated
  source). The receipt identity route is checked by its own leaf.

## Notes

- The default-handler lookup keeps the caller's literal target and, for a protected
  document, the pending decision of `protected-default-open-k89`.
