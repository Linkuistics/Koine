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
