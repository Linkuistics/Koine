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

## Decisions (running log)

- **One stage for every discovered application, `Logic/DiscoveredStage.swift` (`settleDiscoveredApplication`).** The discovery
  read stays in each caller (`registeredApplication` for the preferred copy and Finder, `defaultApplication(forWebScheme:)`,
  `defaultApplication(toOpen:)`), because each stands for a different dependency when it reports nothing. The stage then runs
  resolve, limit, bundle read, in that order, and answers `application(identifier:)`, `absent` or `failed`. The caller maps `absent`
  to its own dependency (`APPLICATION_NOT_INSTALLED` or `NO_DEFAULT_HANDLER`), checks the identifier only where one was asked
  (an unconstrained launch or named open), and reveal maps every Finder dependency to `APPLICATION_NOT_INSTALLED` as before.
- **`inspectApplication`, `ApplicationInspection` and `ApplicationBundle` are deleted from the provider and the adapter.** No
  whole-path `realpath` addresses a registered location any more. What whole-path calls remain are the reveal root rule's two
  `lstat`s (after the limit on the literal) and the Info.plist's `stat` and `access` (on the resolved spelling, after the limit).
  Every caller was enumerated by grep and by the compiler: three (`selectInstallation`, `selectWebHandler`, `selectPathHandler`),
  all converted; the receipt's `liveExecutableIdentity`, `RunningApplication.executableIdentity` and `fileIdentity(ofPath:)` were
  not callers and are untouched (`receipt-executable-identity-k183`). The two vocabulary types survive only in the test targets,
  as the way a test arranges an application location.
- **`selectWebHandler` follows the same shape, and the spec was silent**, so it is a discovered application like any default
  handler: resolved, limited, then read, with no identifier check. Added one clause to stage 3 of the spec ("the default web
  browser for a URL open, found by its scheme alone"). It takes `forAction` like the others ("opened").
- **The wording is "the registered application path"** for every discovered location (a default handler is a registration too), so
  it cannot be confused with a caller's "application path". Same noun the supplied stage's matching registration already uses.
- **The fakes' `inspected` observation became `bundleReads`**, the resolved spelling whose bundle was read; that is what "no
  application was inspected" now means. Reveal's resolved list now ends with Finder's registered location, which the tests say.
- **N has no discovered row, and cannot.** A discovered location comes from Launch Services' registrations, which a host cannot
  arrange (as `application-locations-k176` found), and a present, registered, short application would be launched, opened or
  revealed on this host, which no N suite does. So the over-limit discovered application, the default handler's cycle, the Finder
  registration with another identifier and the long preferred copy are L and G here, and their effect is for
  `application-locations-vm-k181`, which the brief already names for them. The regression N still gives is the whole bundle
  rebuilt from this source passing the supplied-application and target suites.
- **`task check:launch-call-path` gained a discovered-application section** (stage order, exactly three callers, each after its own
  discovery read, no `inspectApplication`, the adapter's whole-path calls enumerated as four, no `ELOOP`/`ENAMETOOLONG` handling
  outside the walk), each new check seen to fail in a scratch copy; two first scratch mutations did not fail for the reason I meant
  (one never reached the checked lines, one only changed a call count) and were rewritten until each failed on its own check.
- **Review spent: one fresh-context read, no defect.** It found nothing letting an over-limit registry location reach a pathname
  call, substituting a copy, or returning a refusal as a dependency. Classified in `docs/verification/discovered-applications.md`:
  the handler's identifier read (and the 1,005 to 1,023-byte Info.plist band) is a trade-off the retained route shared and k176
  already recorded for Antony; `URL.path` and UTF-8 counting are the accepted trade-off of every stage; `Bundle(url:)` caching is
  noise. No code changed after the read.
- **Mutations: all seen.** Ten new plus the three limit mutations; one first run (limit ignoring expansions, naming C) was a fault
  of my claim, C has no expansion row, so C was removed from it and it was re-run.
