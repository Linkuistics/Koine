# open-path-locations-k175

## Goal

`workspaceOpenPath` resolves its target with the walk `reveal-locations` landed,
so an extant location of any length is never reported missing, an over-limit
target is refused before any metadata or default-handler read, and the payload
refusal applies to the resolved object at any depth.

## Context

- `docs/specs/workspace-launch-and-open.md#order-of-target-and-application-stages`
  (stage 1 for open), `#application-hand-off-limit`,
  `#obligations-from-earlier-descriptor-walks` (no depth-evading checks).
- `Providers/WorkspaceProvider/Logic/OpenPath.swift` (`planPathOpen`,
  `refusalReason`, `selectPathHandler`), `NativeWorkspace.inspectPath`.
- `docs/verification/open-path-vm.md` and the `reveal-locations-k174` walk.
- Integration k170: an over-limit target gets no metadata or discovery read.

## Done when

- The target is resolved first. Absent is `PATH_NOT_FOUND`, a resolution failure is
  `failed`, an over-limit spelling is refused with the same guidance, and only
  then are the target's type, application and alias flags read from the resolved
  spelling and the payload policy applied. The accepted refusal order, a source
  script's default editor and the default-handler lookup on the caller's literal
  target stand for paths within the limit.
- L: an over-limit target records no metadata read, no handler lookup and no
  submission; the resolution rows map as for reveal. A default open of a protected
  document stays the pending decision of `protected-default-open-k89`: nothing here
  adds consent or a fallback.
- N: through the signed bundle, an application bundle, an alias and an executable
  at the end of link chains and at about 1,500-byte depth are refused or absent as
  the rows say, nothing opens, and an over-limit extant file is `failed`.
  A final directory without search permission keeps its accepted open outcomes.
- G: `failed` with guidance, never a dependency, for an over-limit extant target.
  Short-path outcomes are unchanged.

## Notes

- Only the target stage is here. The default handler and any named application
  keep their present inspection until `application-locations-k176` and
  `discovered-applications-k177`.
