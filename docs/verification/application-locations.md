# The supplied application's location (application-locations, k176)

**Result: a constrained launch and an open named to an installation resolve `applicationPath`
component by component, never report an extant copy missing, refuse a copy of 1,024 bytes or
more at the application hand-off before any registration lookup or metadata read, and compare
the chosen copy with the registered candidates by device and inode, so a long copy of the same
application on disk never stops a workflow whose selected copy is short.** It is accepted at
**L, G and N**, with one limit on N: Launch Services' registrations cannot be arranged on a
host, so the candidate comparison is shown at L and G and its effect is left to
`application-locations-vm`. Every check was seen to fail against a deliberately broken
provider. What the host cannot show is named in [What N could not observe](#what-n-could-not-observe).

The contract is the [workspace spec](../specs/workspace-launch-and-open.md#order-of-target-and-application-stages)
(stage 2) and the [descriptor-relative decision](../adr/filesystem-access-is-descriptor-relative.md).
The walk and the limit are [reveal's](reveal-locations.md), reused unchanged; the target stage is
[open's](open-path-locations.md). The unconstrained form, a default handler and Finder keep their
present inspection until `discovered-applications`.

## What was built

| Piece | Where | What it does |
| --- | --- | --- |
| The stage | `Providers/WorkspaceProvider/Logic/ApplicationStage.swift` | `selectSuppliedApplication`: resolve `applicationPath` by the walk (absent is `APPLICATION_NOT_INSTALLED`; a failure, a cycle or an impossible name is `failed`), refuse an over-limit spelling, read the bundle, then resolve the registered copies and the preferred copy in turn, compare each by device and inode, stop at the first match, and refuse the match itself if it is over the limit. |
| The bundle read | `WorkspaceNative.readApplicationBundle(of:)`, real adapter in `NativeWorkspace.swift` | Replaces `inspectApplication` for a caller's path. `isApplicationKey` and the identifier from a URL built on the resolved spelling's bytes. Any error is `unreadable`: the walk had just found the object, so a read never decides absence. |
| The limit's wording | `HandOffLimit.refusal(of:forAction:noun:)` | The caller's copy is "the application path"; the matching registration is "the registered application path". |
| The callers | `selectInstallation(_:forAction:native:)` | Dispatches a path to the stage; says "launched", "opened" or "revealed" for what no request did. The unconstrained branch is unchanged. |

An unequal candidate's metadata is never read, so the retained read that failed an unequal
candidate it could not read is gone: equality is now settled by resolution.

## Evidence

| Seam | Where | What it holds |
| --- | --- | --- |
| L | `ApplicationLocationTests` | The planner over the substituted adapter. Every absence kind at the chosen path; an impossible name and a cycle are `failed`; every unestablished step is `failed` naming component and cause; a present non-application, another identifier and none, and an unreadable bundle, each with no candidate resolved; the bundle read from the resolved spelling. 1,023 bytes handed over and 1,024, 1,500, an expansion and the resolved spelling refused, naming the spelling and byte count, before any registration lookup, metadata read or submission, even for an object that is no application. Beside the chosen copy: a stale absent candidate, an unequal long one, an unequal one whose metadata cannot be read, an unequal short one and the same inode on another volume, each enumerated before the match (skipped, nothing of its metadata read) and after it (not examined); a candidate whose resolution fails, is impossible or cycles, before the match (`failed`, the match never reached) and after it (not examined); no match is unregistered; the preferred copy outside the list is compared last and is the registered location submitted; a long copy that is the selected one is refused at the limit, with a short copy that also matches never substituted. Through the provider: a long unequal copy does not stop a launch or a named open, and an over-limit path is `failed` with guidance for both; the target settles before the application. |
| G | `WorkspaceInstallationsCompositionTests` | The real provider through the engine over a stand-in: an over-limit constrained path of 1,024, 1,025, 1,500 and 4,000 bytes is `failed` with the guidance at the action's own response path for a launch and a named open, no result and no dependency, nothing submitted; 1,023 bytes is submitted as registered; a long registered copy enumerated first does not stop a launch or a named open of a short copy; a registered long copy that is the selected one is refused and the short spelling of it is not substituted. |
| N | `WorkspaceApplicationLocationTests` | The independently built, signed bundle, asked a constrained launch and a named open over loopback HTTP, at short and about 1,500-byte depth. Absent rows (a missing name, a dangling link, below a file, a trailing slash or dot, and a missing name at 1,022, 1,023, 1,024 and 1,025 bytes) are `APPLICATION_NOT_INSTALLED`; an impossible name and every cycle are `failed`, saying why; the budget, a self-extending link, a denial and a non-ASCII name the lookup refuses are `failed` naming component and cause. A bundle of 1,024, 1,025 and 1,500 bytes, a short literal with a long expansion or resolved spelling, and chains of 1, 31 and 32 links, are refused naming the spelling and byte count, under either identifier and even when the Info.plist is missing. Present rows within the limit show the bundle was read from the resolved spelling: chains of 1, 2, 31 and 32 links, a link to the folder, a `..` after a link, a repeated dot-link, one link inode in two directories, and multibyte and combining names, at short and about 900-byte depth, are a mismatch under another identifier and unregistered under the bundle's own. A bundle with no identifier is a mismatch, a program, a document and a folder are not installed, and a bundle whose contents nobody may read is `failed`. |
| Call path | `task check:launch-call-path` | Passes with the new checks: the stage is resolve, limit, bundle read, registered copies, candidates, selected limit, in that order; it makes no path call of its own and reads exactly one bundle; candidates are compared by the walk's device and inode; the adapter reads from the resolved spelling's bytes, one resource key, and never reads a missing file as absence. Each new check was seen to fail in a scratch copy of the source. |

## The bundle's own Info.plist is twenty bytes deeper

An application's identifier is read from `Contents/Info.plist`, a path 20 bytes longer than the
bundle's own. Measured through the signed bundle on this host (macOS 26.5), with a fixture at
exact lengths, asked under the bundle's own identifier and under another:

| Bundle path | Answer |
| --- | --- |
| 990 to 1,004 bytes | read: another identifier is a mismatch, its own is unregistered |
| 1,005 to 1,023 bytes | `failed`: "The application could not be inspected: File name too long." |
| 1,024 bytes or more | refused at the hand-off limit, before any read |

The 1,005 to 1,023 band is within the limit and is not refused at it. The platform cannot read the
plist, and the stage reports that cause rather than absence or a mismatch, which is what the spec
requires of a failed metadata read. The retained route failed the same way. Whether such a bundle
should instead be refused at the limit would need a rule about a bundle's contents, which the
spec does not state: it is Antony's to decide, and the spec records the observation
([limit section](../specs/workspace-launch-and-open.md#application-hand-off-limit)).

## Mutation results

`task check:location-walk-mutations` breaks one decision of the shipped source at a time in a copy
of the tree and runs the named suites against the copy's own tests and signed bundle. This leaf
added suites A (`ApplicationLocationTests`), G (`WorkspaceInstallationsCompositionTests`) and B
(`WorkspaceApplicationLocationTests`), reached the three limit mutations and the literal-spelling
mutation with them, and added seventeen of its own. All were seen, after two corrections below.

| Broken decision | Red | Not reachable |
| --- | --- | --- |
| the limit is not applied to the chosen copy | A, B | G |
| the bundle is read before the limit | A | B, G |
| the limit is not applied to the selected registration | A, G | B |
| the limit is applied to an unequal candidate | A, G | B |
| an impossible name or a cycle at the chosen path is absence; a failed walk there is absence | A, B | G |
| a stale candidate stops the stage; an unresolvable candidate, or an impossible or cyclic one, is skipped | A | G, B |
| equality ignores the device; equality ignores the inode | A | G, B |
| a candidate's metadata is read; the preferred copy is not compared; candidates are compared in the wrong order | A | G, B |
| the selected copy allows a running copy to substitute | A, G | B |
| the limit is one byte high, ignores expansions or counts the NUL | S, L, O, A, N, B | — |
| the adapter reads the literal spelling | N, B | S, L, O, A, G |

"Not reachable" names suites that cannot observe the decision. The signed bundle cannot arrange
registrations (so B sees no candidate decision), G's stand-in registers one copy per file and so
cannot tell which of two limit checks refused a copy that is both chosen and selected, and the
planner mutations do not touch the walk. Two first runs were not seen, and both were faults of
the tests: G's long copy was enumerated after the match and so never examined, and G named a
mutation it cannot distinguish. The first test now registers the long copy first, and the second
claim was removed.

## What N could not observe

- The candidate comparison against real registrations, a long copy beside a short one, and a
  long preferred copy refused without substitution: Launch Services' registrations cannot be
  arranged on a host. L and G show the planner's decision; `application-locations-vm-k181` shows
  the effect.
- A present application launched or opened by its registered location: nothing is sent from this
  host, so every N row ends at a dependency, a mismatch or a refusal.
- A handle the walk leaks and a link whose text changes between two reads, first-use prompts
  through the shipped bundle, other macOS builds and removable or network volumes (see
  [reveal's record](reveal-locations.md)).

## Findings of the fresh-context read

One reviewer read the stage, the adapter's bundle read and the walk against the spec. It found
nothing that lets an over-limit location reach a pathname call, report an extant copy missing,
mis-order or mis-select a candidate, or change the unconstrained, URL or reveal routes. Classified:

- **A visible trade-off, as for every earlier stage:** a registered URL is walked by `URL.path`
  as a `String`, and the Info.plist path is built the same way, so a name that is not valid UTF-8
  would be walked under repaired bytes. APFS admits no such name and a normalization difference
  resolves to the same object, so this is unreachable there. A filesystem that stored one could
  skip a real copy (`APPLICATION_NOT_INSTALLED`) where it should select it, or read a denied
  Info.plist as a mismatch.
- **Outside this leaf, and recorded in the spec:** the unconstrained launch, a default handler and
  Finder still make a whole-path `realpath` on the registered location. An over-limit one is
  `failed` with the platform's `File name too long`, not the hand-off refusal. That is
  `discovered-applications`.
- **Checked and noise:** a 1,023-byte directory target handed over with a trailing slash. The target
  route is unchanged, and its file system representation measured 1,023 bytes
  ([open's record](open-path-locations.md)).
