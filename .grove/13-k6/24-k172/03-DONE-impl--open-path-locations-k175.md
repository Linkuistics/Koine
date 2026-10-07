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

## Decisions (running log)

- **One shared target stage.** `settleTarget` (`Logic/TargetStage.swift`) is stage 1 for both operations: resolve,
  then the limit. Reveal's inline copy moved into it, so the two cannot drift, and the walk mutations that touched
  reveal's planner now name it. Open's wording differs only in the past tense ("opened"), passed in.
- **`inspectPath` is replaced by `readPathFacts(of: ResolvedLocation)`.** It reads the three resource values from a URL
  built from the resolved spelling's own bytes (`URL(fileURLWithFileSystemRepresentation:)`), and takes the type from the
  walk. The old literal `stat` (which guarded `file.txt/` against `realpath`'s forgiveness) and the `realpath` are gone:
  the walk's trailing-slash rule and followed final link do that work. `PathInspection.absent` stays as the answer of a
  read that reports nothing there; the planner reads it as `failed` (a later platform absence about a found location).
- **N for open is named to an unregistered application.** An open the signed bundle on the host cannot be allowed to
  complete, so every N open names `com.example.koine.k175.unregistered`. A present target within the limit that the
  payload policy lets through then answers `APPLICATION_NOT_INSTALLED`, which proves the walk resolved it and its
  metadata was read. That makes the 1,023-byte file, the 31/32-link chains, the mode-0600 final directory, the
  two-directory link, the repeated dot-link and the multibyte names observable for open on the host, an N gap that
  reveal could not close. Reveal's gap is unchanged and stays with `target-locations-vm-k180`; open's V is the effect.
- **Payload rows at depth use the resolved object about 900 bytes down**, reached directly and through a 32-link chain
  from a short literal, for an application bundle, a Mach-O executable and a Finder alias.
- **The retained default-handler lookup and the literal submission are untouched**, as the leaf's notes say; the lookup
  still prompts for protected documents and `protected-default-open-k89` still owns that.
