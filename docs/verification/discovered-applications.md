# Applications the provider discovers (discovered-applications, k177)

**Result: every application the provider finds for itself (an unconstrained launch's or a named open's
preferred copy, the default handler of a document, the default web browser, and Finder for a reveal) is
resolved component by component after the read that found it, and refused at the application hand-off
limit before anything addresses it by path. No caller-influenced or registry-supplied location now reaches
a whole-path call before the limit.** It is accepted at **L and G**. There is no N row for this stage and
there cannot be one on a host, for the reason in [What N could not observe](#what-n-could-not-observe); its
effect is for `application-locations-vm`. Every check was seen to fail against a deliberately broken
provider.

The contract is the [workspace spec](../specs/workspace-launch-and-open.md#order-of-target-and-application-stages)
(stages 3 and 4) and the [descriptor-relative decision](../adr/filesystem-access-is-descriptor-relative.md).
The walk and the limit are [reveal's](reveal-locations.md), the target stage is [open's](open-path-locations.md)
and the supplied-application stage is [its own](application-locations.md); this stage is the same order for a
location nobody supplied.

## What was built

| Piece | Where | What it does |
| --- | --- | --- |
| The stage | `Providers/WorkspaceProvider/Logic/DiscoveredStage.swift` | `settleDiscoveredApplication`: resolve the location the discovery read reported (an established absence is `absent`; an impossible name, a cycle or a failure is `failed`), refuse an over-limit spelling naming it and its byte count, then read the bundle from the resolved spelling (a present non-application is `absent`, an unreadable one is `failed`). |
| The callers | `Selection.swift` (`selectInstallation`, `selectWebHandler`), `OpenPath.swift` (`selectPathHandler`) | Each makes its own discovery read, then the stage, and reports `absent` as the dependency its read stands for: `APPLICATION_NOT_INSTALLED` for a preferred copy and for Finder, `NO_DEFAULT_HANDLER` for a handler. Only an unconstrained launch and a named open check the identifier; reveal reports every Finder dependency, a mismatch included, as `APPLICATION_NOT_INSTALLED`. |
| What went | `WorkspaceNative.inspectApplication(at:)`, `ApplicationInspection`, `ApplicationBundle`, the adapter's `realpath` | The one whole-path read of a registered location. The bundle read is now `readApplicationBundle(of:)` for a location the caller supplied and for one Launch Services reported. |

The selected application's spellings are limited after the discovery read that found it and before its
metadata is read, and submission addresses the registered location as before. An unconstrained launch or
named open whose preferred copy is the long one discovers it, selects it and refuses it with `failed`
before any request: no other copy is substituted, and a short copy already running does not rescue it,
because the refusal precedes the platform.

## Evidence

| Seam | Where | What it holds |
| --- | --- | --- |
| L | `DiscoveredApplicationTests` | Each of the five forms (unconstrained launch, named open, document default handler, default browser, Finder) through the real provider over the substituted adapter. An over-limit discovered application of 1,024, 1,025, 1,500 and 4,000 bytes, and a long expansion or resolved spelling, is `failed` naming the spelling and its byte count and "No request was made", and the adapter records exactly the discovery read, then the walk of that location, no bundle read and no submission. 1,023 bytes is handed over and read. A cycle or an impossible name is `failed`, never a stale registration; a walk step that cannot be established is `failed` naming component and cause; an established absence, a present non-application and (for a launch and named open) another or no identifier are each the form's own dependency; an unreadable bundle is `failed`; a default handler or browser needs no identifier; a Finder registration with another identifier is `APPLICATION_NOT_INSTALLED`. A preferred copy that is long is refused with a short copy registered beside it (never consulted, never substituted, no launch); a long unequal copy beside a short preferred one is never resolved. A missing target is reported before any discovered application is resolved. |
| G | `WorkspaceInstallationsCompositionTests`, `WorkspaceCompositionTests` | The real provider through the engine over a stand-in: an over-limit preferred copy of 1,024, 1,025, 1,500 and 4,000 bytes is `failed` with guidance at the action's own response path for an unconstrained launch and a named open, no result and no dependency, nothing submitted though a short copy is registered; the same for the default handler of a document, the default browser and Finder, each recording exactly its discovery read; 1,023 bytes is submitted as registered in every form; a long unequal registered copy never stops an unconstrained launch or named open. |
| Call path | `task check:launch-call-path` | Passes with a new section: the stage is resolve, limit, bundle read in that order, reads one bundle and makes no path call of its own; exactly three callers, each after its own discovery read; no `inspectApplication` or `ApplicationInspection` anywhere in the provider; the adapter's whole-path calls are exactly four (the reveal root rule's two `lstat` and the Info.plist's `stat` and `access`, all after the limit) and no `realpath`; no `ELOOP`, `ENAMETOOLONG` or `ENOTDIR` is read as absence in the adapter or a stage. Each new check was seen to fail in a scratch copy of the source (below). |

`task test` passes with the bundle rebuilt from this source: the supplied-application, target and walk suites
(N) are unchanged.

## Mutation results

`task check:location-walk-mutations` gained suites D (`DiscoveredApplicationTests`) and C
(`WorkspaceCompositionTests`, for the browser, the default handler and Finder through the engine), reached the three
limit mutations with them, and added ten mutations of its own. All were seen.

| Broken decision | Red |
| --- | --- |
| the limit is not applied to a discovered application | D, C, G |
| the bundle is read before the limit | D |
| an impossible name or a cycle at a discovered location is absence | D |
| a failed walk at a discovered location is absence | D |
| a present non-application is an application | D |
| an unreadable discovered bundle is absence | D |
| a discovered location that is gone is `failed` | D |
| an unconstrained launch does not check the identifier | D |
| a default browser must declare an identifier | D |
| an unconstrained launch forbids substitution | D, G |
| the limit is one byte high, or counts the NUL | S, L, O, A, N, B, D, C |
| the limit ignores expansions | S, L, O, A, N, B, D |

C has no row for the expansion mutation: its stand-in varies only the literal spelling, and D carries every
spelling kind. The first run of that mutation named C and was not seen, which was a fault of the claim, so C was
removed from it and the mutation re-run.

`task check:launch-call-path` was seen to fail in a scratch copy for each of: the bundle read before the limit,
the limit before the resolution, a path call inside the stage, a caller that skips the stage, a caller that finds
its handler after the stage, `inspectApplication` reintroduced, `realpath` in the adapter, an extra whole-path
call, and `ELOOP` read as absence. Two first scratch mutations did not fail for the reason meant (one never
reached the lines the check reads, one changed only a count) and were rewritten until each failed on its own
check. The unmutated copy was seen to pass as the control.

## What N could not observe

A discovered location is the one Launch Services reports, and a host cannot arrange registrations
([the supplied stage found the same](application-locations.md#what-n-could-not-observe)). A registered
application that is present and short would be launched, opened or revealed on this host, and no N suite sends
that. So the over-limit discovered application, a cycle or an impossible name at a default handler, a Finder
registration with another identifier and a long preferred copy refused without substitution are shown at L and G,
with the decisions mutation-checked, and their effect on a real registration is left to
`application-locations-vm`, which already names the long preferred copy.

## Findings of the fresh-context read

One reviewer read the stage, its three callers and the adapter against the spec. It found no scenario where a
discovered application is substituted, a limit refusal comes back as a dependency, or an over-limit registry path reaches
a whole-path call before the limit. Classified:

- **A visible trade-off, unchanged by this leaf:** a default handler's or browser's identifier is read though it is not
  needed, so a bundle whose Info.plist is denied, or (1,005 to 1,023 bytes) too deep to stat, is `failed` rather than
  selected. The retained route did the same, the [band is already recorded](application-locations.md#the-bundles-own-infoplist-is-twenty-bytes-deeper)
  for Antony, and failing on metadata that cannot be read is what the spec asks of a read.
- **A visible trade-off, as for every earlier stage:** the Info.plist path and a registered URL pass through
  `URL.path` as a `String`, which could repair a name that is not valid UTF-8 (unreachable on APFS), and the limit counts
  the spelling as UTF-8 text.
- **Noise:** that `Bundle(url:)` may cache an identifier in a long-lived process is not shown, is not a discovered-stage
  concern, and the adapter reads afresh on every action as before.

## Not changed

- The default-handler lookup keeps the caller's literal target and, for a protected document, the pending decision of
  `protected-default-open` (it still prompts for Files and Folders consent on first-use Desktop, Documents and
  Downloads; the registered location it returns is now resolved by the walk like any other).
- The receipt's executable identities (`liveExecutableIdentity`, `RunningApplication.executableIdentity`,
  `fileIdentity(ofPath:)`) were not callers of the removed inspection and are left to
  `receipt-executable-identity`.
- A registered URL is walked by `URL.path` as a `String`, as for the supplied stage's registered copy: a visible
  trade-off, unreachable on APFS.
