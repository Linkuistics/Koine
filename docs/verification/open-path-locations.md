# Open's target location (open-path-locations, k175)

**Result: `workspaceOpenPath` resolves its target component by component, never
reports an extant location missing, refuses a location of 1,024 bytes or more at the
application hand-off before any metadata or handler read, and applies the payload
refusal to the resolved object at any depth.** It is accepted at **L, G and N**.
Every check was seen to fail against a deliberately broken provider; the table below
says where a mutation cannot be reached. What the host cannot show is named in
[What N could not observe](#what-n-could-not-observe), not counted as passed.

The contract is the [workspace spec](../specs/workspace-launch-and-open.md#resolving-an-action-location)
and the [descriptor-relative decision](../adr/filesystem-access-is-descriptor-relative.md).
This leaf is stage 1 for open (the [order of stages](../specs/workspace-launch-and-open.md#order-of-target-and-application-stages)).
The default handler and a named application keep their present inspection until
`application-locations` and `discovered-applications`. The walk and the limit are
[reveal's](reveal-locations.md), reused unchanged.

## What was built

| Piece | Where | What it does |
| --- | --- | --- |
| The target stage | `Providers/WorkspaceProvider/Logic/TargetStage.swift` | `settleTarget`: resolve the caller's path by the walk, then apply the limit. Absent (an impossible component and an established cycle included) is `PATH_NOT_FOUND`; a resolution failure and an over-limit spelling are `failed`. Reveal's inline copy of this moved here, so the two operations share one stage. |
| Open's plan | `Logic/OpenPath.swift` `planPathOpen` | Target stage, then the type, application and alias flags read from the resolved spelling, then the payload policy, then the default handler or the named installation. The default-handler lookup and the submission still use the caller's literal target. |
| The metadata read | `WorkspaceNative.readPathFacts(of:)`, real adapter in `NativeWorkspace.swift` | Replaces `inspectPath`. The three measured resource values of the resolved object, from a URL built on the resolved spelling's bytes, with the type taken from the walk. No whole-path `stat` or `realpath` addresses the caller's location, and the literal `stat` that guarded `file.txt/` is the walk's trailing-slash rule now. A read that reports nothing there, about an object the walk had just found, is `failed`, never absence. |

## Evidence

| Seam | Where | What it holds |
| --- | --- | --- |
| L | `OpenLocationTests` | The planner over the substituted adapter, for the default handler and a named application: every absence kind is `PATH_NOT_FOUND` with nothing else asked; every unestablished step is `failed` naming component and cause; a later metadata absence is `failed`; 1,023 bytes is handed over and 1,024, 1,500, an expansion and the resolved spelling are refused naming the spelling and byte count, with no metadata read, handler lookup, application lookup or submission recorded; an over-limit target is refused before a payload, before a named application that is also missing and before a handler lookup that would answer `NO_DEFAULT_HANDLER`; the metadata is read from the resolved spelling while the handler is asked about, and the open submitted at, the caller's literal path; the payload refusal holds on a resolved object at 0, 1,000 and 1,023 bytes for every refused kind. `OpenPathTests` keeps every accepted short outcome. |
| G | `WorkspaceCompositionTests` | A public open of an extant path of 1,024, 1,025, 1,500 and 4,000 bytes, default and named, is `failed` with the guidance at the action's own response path, no result and no dependency, and nothing is read or opened; 1,023 bytes is opened as before. |
| N | `WorkspaceLongLocationTests` | The independently built, signed bundle, loaded by the real loader and asked over loopback HTTP. Every reveal row is now asked of both operations (absent rows, `failed` rows, and every present row shown by the refusal that follows resolution, at short and about 1,500-byte depth). Open-only rows are below. |
| Call path | `task check:launch-call-path` | Passes with the new checks: the target stage is resolve then limit and makes no path call of its own; open's order is target stage, metadata, payload policy, then the installation or handler; the open planner makes no `realpath`, `stat` or resource-value call; the adapter's read takes the resolved spelling's bytes and nothing from the literal. |

### N, for open

An open from this host must never reach a handler, so the suite names every open to
`com.example.koine.k175.unregistered`, an application nobody registered. Whatever a
broken decision let through would end in `APPLICATION_NOT_INSTALLED` and open nothing.
That answer is also a result for the rows below: it shows the target resolved, was
within the limit, had its metadata read and passed the payload policy. This closes,
for open at N, what a reveal could not show.

- **Settles (`APPLICATION_NOT_INSTALLED`):** files of exactly 1,022 and 1,023 bytes; 31-
  and 32-link chains at about 900 bytes; a final directory with mode 0600 (its accepted
  outcome is kept); one link inode with entries in two directories; the finite repeated
  dot-link; 300-byte multibyte, combining-character and emoji names.
- **Refused as an input error, on the resolved object:** an application bundle, a Mach-O
  executable and a Finder alias, each about 900 bytes down, reached directly and through
  a 32-link chain from a short literal.
- **Refused at the limit, `failed`:** an extant over-limit file or directory, a short
  literal with a long expansion, a long resolved spelling, chains and the other present
  rows at about 1,500 bytes, as for reveal.

## Mutation results

`task check:location-walk-mutations` breaks one decision of the shipped source at a time
in a copy of the tree and runs the named suites against the copy's own tests and signed
bundle (S `LocationWalkTests`, L `RevealLocationTests`, O `OpenLocationTests`, N
`WorkspaceLongLocationTests`). All 30 were seen. This leaf moved the reveal planner's
three mutations into the shared stage and added O to every one that reaches it, and
added four of open's own:

| Broken decision | Red | Not reachable |
| --- | --- | --- |
| open reads its metadata from the literal spelling | N | S, L, O |
| a later metadata absence is absence | O | S, L, N |
| the payload policy is not applied to the resolved object | O, N | S, L |
| open submits the resolved spelling instead of the literal | O | S, L, N |
| the limit is not applied; a walk failure is absence; an impossible name or cycle is failed | L, O, N | S |
| the limit is one byte high, ignores expansions or counts the NUL | S, L, O, N | — |

"Not reachable" names suites that cannot observe the decision: the planner mutations do
not touch the walk's own tests, and a later platform absence about a found object cannot
be provoked through the bundle. The other 19 mutations of the walk itself are unchanged
and were all seen again. Two of them, the cycle state without its containing directory
and without its pending suffix, had stopped applying because k174's slash-collapse fix
changed the text they replace; their texts were corrected and both were seen.

## What N could not observe

- A present target within the limit opened by its handler, and the default handler's
  protected-document lookup. Not sent from this host; `target-locations-vm-k180` closes
  them by effect. A default open of a protected document stays the pending decision of
  `protected-default-open-k89`: nothing here adds consent or a fallback.
- A later platform absence about an object the walk found. It is tested at L only.
- A handle the walk leaks and a link whose text changes between two reads (see reveal's
  record).
- First-use prompts through the shipped bundle, and other macOS builds, removable and
  network volumes (see reveal's record).

## Findings of the fresh-context read

One reviewer read the target stage, the open planner and the adapter. It found nothing
that lets an over-limit target reach a whole-path call, metadata read, handler lookup or
request. Classified:

- **Valid, outside this leaf:** the walk's cost is quadratic in path length, because it
  shifts and copies its pending array per component; a 1 MiB path of `./` components
  holds the queue before it is refused. Cut as `walk-linear-cost-k184`.
- **A visible trade-off, as before this leaf:** a literal containing `..` after a link is
  resolved physically by the walk, while the handler lookup and submission receive the
  caller's literal text, as the accepted contract fixes ("location-based"). Foundation
  keeps `..` in the URL (checked).
- **Unreachable here:** a resolved name that is not valid UTF-8 or is stored precomposed
  on a filesystem that distinguishes forms. APFS admits neither a non-UTF-8 name nor a
  normalization difference, and a different name would read as absent and be `failed`,
  never another object.
- **Checked and noise:** a 1,023-byte directory literal handed over at 1,024. The file
  system representation of such a URL measured 1,023 bytes.
- **A stale comment**, fixed.
