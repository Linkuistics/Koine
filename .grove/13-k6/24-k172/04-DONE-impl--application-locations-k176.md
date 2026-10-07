# application-locations-k176

## Goal

A caller-supplied `applicationPath` (a constrained launch or a named open) is
resolved with the walk, refused at the hand-off limit before any registration or
other platform call, and compared with the registered candidates by device and
inode, so a long copy of the same application on disk never stops a workflow
whose selected copy is short. A long copy that is itself the selected one is
refused at the limit, never replaced by another.

## Context

- `docs/specs/workspace-launch-and-open.md#order-of-target-and-application-stages`
  (stage 2 and the paragraph after stage 4), `#application-hand-off-limit`.
- `Providers/WorkspaceProvider/Logic/Selection.swift` (`selectConstrained`),
  `NativeWorkspace.inspectApplication` and its `realpath`.
- `docs/verification/application-installations-vm.md` and its fixtures
  (`scripts/vm-installation-fixtures.sh`, `scripts/vm-registration-lookup.swift`):
  what Launch Services does with deleted, Trashed and unregistered copies.
- The walk from `reveal-locations-k174`.

## Done when

- `applicationPath` is resolved: absent is `APPLICATION_NOT_INSTALLED`, a
  resolution failure, a cycle or an impossible name included, is `failed`, and an
  over-limit spelling is refused before any registration lookup or metadata read.
  Then the chosen copy's bundle metadata is read: a present non-application is
  `APPLICATION_NOT_INSTALLED`, another or no identifier is
  `APPLICATION_IDENTITY_MISMATCH`.
- The identifier's registered copies, then its preferred copy if not among them,
  are each resolved and compared by device and inode alone, in that order,
  stopping at the first match, without reading their metadata. An absent candidate
  and an unequal one are skipped, wherever enumerated, including an unequal long
  one and an unequal one whose metadata cannot be read. A candidate reached before
  any match whose resolution fails leaves equality unknown and is `failed`; one
  after the match is not examined. A present chosen copy matching no candidate is
  unregistered, `APPLICATION_NOT_INSTALLED`. The limit never applies to an
  unequal candidate.
- The selected application's spellings are checked against the limit before its
  own metadata is needed, and submission addresses its registered location. All
  accepted constrained-launch outcomes (substitution forbidden, running-copy
  reuse for the unconstrained form, Trash, mismatch) are unchanged.
- L: every subject the spec lists for this stage: over-limit `applicationPath` with
  no metadata read and no registration lookup; a stale absent candidate, an
  unequal long candidate and an unequal candidate with unreadable metadata beside
  the present chosen copy, each enumerated before and after it; a candidate whose
  resolution fails before the match and after it; a cycle or impossible name at an
  application location.
- N: real acquisition at short and about 1,500-byte depth for the chosen copy
  through link spellings; G: `failed` with guidance at the response path for an
  over-limit constrained path, a dependency only for the dependency rows.
- The errno, Foundation and plist comments and mapping in
  `inspectApplication` and `isMissing` are reconciled: no whole-path call
  addresses the caller's location before the limit.

## Notes

- Registered candidates reached by `inspectApplication` for the unconstrained
  form remain until `discovered-applications-k177`.

## Decisions (running log)

- **The stage is its own file, `Logic/ApplicationStage.swift` (`selectSuppliedApplication`), beside `TargetStage.swift`.**
  `selectInstallation` keeps the unconstrained branch (registered location, `inspectApplication`) for
  `discovered-applications-k177`, and takes a new `forAction` ("launched", "opened", "revealed") so the refusal says
  what no request did. The guidance names "the application path" for the caller's copy and "the registered application
  path" for the matching registration, so the two refusals cannot be confused.
- **Chosen copy: walk, limit, then bundle, from the resolved spelling.** New native method
  `readApplicationBundle(of: ResolvedLocation) -> BundleRead` (`notApplication`, `application(identifier:)`,
  `unreadable`), with no absence case: the walk found the object, so any later platform answer, a missing-file one
  included, is `failed`. Its file identity is the walk's device and inode, so `volumeIdentifierKey` and
  `fileResourceIdentifierKey` are no longer read for a chosen copy.
- **An impossible name and a cycle at an application location are `failed`** (the walk reports them as absence; the stage
  reads `Absence.isImpossibleOrCycle`, which was written for exactly this). The same applies to a candidate reached before
  the match, where it is `failed` because equality is unknown.
- **Candidates are resolved only to compare, by `ObjectIdentity ==`.** Their metadata is never read, so the retained
  identity read that failed an unequal unreadable candidate is gone. The preferred copy outside the list is compared
  last, as before. The selected registration's spellings are limited; an unequal candidate's never.
- **The adapter's `fileSystemURL(of:)` is shared by `readPathFacts` and `readApplicationBundle`** (the URL from the
  resolved spelling's bytes). `inspectApplication` keeps its whole-path `realpath` for the registered and discovered
  locations Launch Services reports, and its comment now says it is not a caller's location and that only
  `ENOENT`/`ENOTDIR` are absence there; `k177` replaces it.
- **Found at N, not in the spec: a bundle's Info.plist is 20 bytes deeper than the bundle.** A bundle of 1,004 bytes or
  fewer is read; from 1,005 to 1,023 bytes the platform answers `ENAMETOOLONG` for `Contents/Info.plist` and the stage
  reports `failed` with that cause (never a refusal at the limit, absence or a mismatch). The retained route failed the
  same way. I added the observation to the spec's limit section and left the contract alone; it is for Antony to decide
  whether a bundle in that band should instead be refused at the limit, which would need a rule about bundle contents.
- **A bare folder named `X.app` is an application with no identifier to the platform**, so it is a mismatch, as a bundle
  with no Info.plist already was. (N rows built it first as a "not an application" case and were corrected.)
- **N cannot arrange registrations.** The candidate comparison is L and G; N shows the chosen copy's resolution, the
  limit, link-chain spellings and the bundle read through the real adapter, and `application-locations-vm-k181` shows the
  short workflows beside a long copy by effect.
- **The existing G stand-in (`Copies`) and the fake adapter resolve an arranged application as the object its file names**
  (one inode per file, the volume's device), so every earlier installation test keeps its meaning without a rewrite.
- **Review spent: one fresh-context read, no finding blocking.** It found nothing letting an over-limit location reach a
  pathname call, an extant copy read as missing, or a candidate mis-selected. Classified in
  `docs/verification/application-locations.md`: a `URL.path` String round trip for a registered URL and the Info.plist
  path is a visible trade-off (unreachable on APFS); the unconstrained form's whole-path `realpath` is
  `discovered-applications-k177`; the 1,023-byte directory handoff is noise, as k175 checked.
- **Mutations: all 21 seen.** Two first runs were my tests' fault (G enumerated the long copy after the match, and G cannot
  tell which of two limit gates refused a copy that is both chosen and selected); fixed and re-run, recorded in the
  verification document.
