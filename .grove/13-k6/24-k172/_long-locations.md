# long-locations-k172 — brief

## Goal

Koine's workspace launch, open and reveal resolve every action location
component by component, never report an extant location missing, and refuse at
the application hand-off, with `failed` and a stated cause, any location whose
spelling is `PATH_MAX` (1,024) bytes or more before any request is made. It
ships as the action-only workspace release/schema **1.0.1**, with the retained
1.0.0 bundle, SDL and profile independent of it.

This is the v1 contract in
`docs/specs/workspace-launch-and-open.md#long-location-action-boundary`, bound by
`docs/adr/filesystem-access-is-descriptor-relative.md`. Long-path application
support is out of scope ([Linkuistics/Koine#1](https://github.com/Linkuistics/Koine/issues/1)).

## Done when

- Every L, N, G and V subject the spec's "Subjects and versions" lists passes at
  its seam, including first-use prompt-free resolution in Desktop, Documents and
  Downloads. Every row of the spec's two long-location acceptance entries that
  this node owns carries an evidence link, and the spec's "Designed for v1;
  unimplemented" status is brought to what was actually accepted.
- The packaged workspace is release/schema 1.0.1 under `koine-desktop/1`, with
  unchanged shapes, enums and error kinds and the repair SDL's descriptions.
  Retained 1.0.0 binaries, SDL and profile pass unchanged and independent of it.
- Short launch, named open, open and reveal keep every accepted outcome.
- Reusable build, fixture and VM steps are in `Taskfile.yml`.
- Actual-search handoff rows stay with `app-and-file-search`.

## Decomposition

One leaf per increment that leaves Koine working and is verifiable alone. Each
stage leaf replaces whole-path inspection for one stage of the spec's order
(target, then supplied application, then discovered application) and runs at L,
G and N. The release and V come after, so acceptance rests on the shipped 1.0.1
artifact.

1. `retained-workspace-baseline`: keep the 1.0.0 workspace as an independently
   built binary before any source changes. It must come first.
2. `reveal-locations`: the descriptor-relative walk and every resolution row,
   with reveal's target stage and limit as its first consumer. It starts by
   measuring first-use prompting, which decides whether the ADR stands.
3. `open-path-locations`: the open-path target stage and its payload refusal on
   the resolved object, on the same walk.
4. `application-locations`: the supplied application stage (`applicationPath`
   for a constrained launch or named open) and registered-candidate comparison
   by device and inode.
5. `discovered-applications`: the discovered application stage (unconstrained
   launch, default handler, Finder) and the selected application's limit.
6. `receipt-executable-identity`: receipt observation's two executable identities
   (the live process's `proc_pidpath` and the retained object's executable) by the
   same walk and one representation, with observation's own null rule: the limit
   never applies after an acknowledged action.
7. `action-repair-release`: workspace 1.0.1 with the repair SDL, catalogue,
   manifest and conformance profile.
8. `action-repair-compat`: independent old/new pairs, the retained-host per-user
   1.0.1 variant, and the selection fixtures re-pinned.
9. `target-locations-vm`: V for the 1,023-byte documents and directories, the
   refused 1,024-byte and longer ones, the present walk outcomes only an effect
   shows, the missing long path, the root reveals and prompt-free first use.
10. `application-locations-vm`: V for the over-limit application path, short
    workflows beside a long copy of the same application, and a long preferred copy
    refused without substitution. Decomposed into `application-location-observations-k186`
    (supplied literal refusals and disk-only short effects/receipts) and
    `long-application-registration-k187` (one bounded prefix-link route for actual
    native registration/order/preference, then a requirements decision if still unavailable).

Subject ownership (the spec's bullets are the claim; each leaf names its own):

| Subject | Owners |
| --- | --- |
| L: over-limit target; target resolution outcomes | `reveal-locations`, `open-path-locations` |
| L: over-limit `applicationPath`; candidates (stale, unequal long, unreadable, before/after the match, failed before the match); cycle or impossible name at an application location | `application-locations` |
| L: over-limit discovered application or default handler (exactly the discovery read, then nothing); cycle or impossible name at a default handler; Finder registration with another identifier; a preferred long copy refused beside a short selected copy that works | `discovered-applications` |
| L, N: receipt executable identities (live `proc_pidpath` and retained object) by the walk, null rule that never refuses | `receipt-executable-identity` |
| N: every resolution row that a result or a post-resolution refusal can show, through the signed bundle at short and about 1,500-byte depth; 1,023/1,024; the 33-link and self-extending budget; cycle states; denial. Shared-source walk tests support these and close none | `reveal-locations` (the walk), repeated through the consumer each later leaf owns |
| N gap, closed at V by effect: within-limit 31/32-link chains, final directory without search permission, one link in two directories, multibyte/combining names, reveal root decision | `target-locations-vm` |
| G: `failed` with guidance, never a dependency, for an extant over-limit location | each stage leaf for its operation |
| Packaging, compatibility, profiles | `retained-workspace-baseline`, `action-repair-release`, `action-repair-compat` |
| V | `target-locations-vm`, `application-locations-vm` (receipt non-null at V for the short workflows) |

## Pointers

- `docs/specs/workspace-launch-and-open.md#long-location-action-boundary`
  (resolution table, stage order, hand-off limit, walk obligations, subjects and
  versions) and its acceptance rows.
- `docs/adr/filesystem-access-is-descriptor-relative.md`.
- `docs/verification/long-action-native-boundary.md#compatibility-and-implementation-obligations`
  and `docs/design/workspace-action-repair-schema.graphql`.
- `docs/verification/long-action-route-prototype.md` (k134's measurements) and
  `docs/research/long-pathname-applications.md#51-component-relative-resolution-for-presence-and-cause`.
- The code this replaces: `Providers/WorkspaceProvider/Sources/NativeWorkspace.swift`
  (`inspectPath`, `inspectApplication`, `unavailable`, `isMissing`) and the
  planners in `Providers/WorkspaceProvider/Logic/` (`OpenPath.swift`,
  `RevealPath.swift`, `Selection.swift`).

## Notes

- Application V's measured slice is recorded in
  `docs/verification/application-locations-vm.md`: 1,024/1,500-byte supplied
  refusals cold/running; exact short A/B and preferred A launch/open receipts;
  controlled Finder reveal. Native registered-long/both-order and preferred-long
  rows remain pending. `application-locations-vm-k181` stays open for k187.

- **A prompt stops the work.** If search-only resolution prompts in Desktop,
  Documents or Downloads, the slice stops and the question goes to Antony. There
  is no whole-path fallback, no shipped dialog and no new consent.
- **No new error kind or dependency reason.** The refusal is `failed` with
  guidance naming the application hand-off stage, the spelling and its byte
  count, and saying no request was made. Anything that needs an incompatible
  change goes to Antony first.
- **Counting.** Lengths are pathname bytes without the NUL: 1,023 is handed over,
  1,024 is refused. Only submission was measured at that boundary.
- **What N can see.** The signed bundle under test on the host launches and
  reveals nothing. A walk's outcomes are visible there when they are a result
  (absent, cycle, impossible name, budget, denial) or when a refusal follows
  resolution: an application bundle or Finder alias at the end of a link chain, or
  an over-limit spelling, whose guidance names the spelling and its byte count.
  Placing a present object where its spelling reaches 1,024 bytes makes the
  refusal show the walk reached it. Testing the walk's own shared source directly
  is supporting evidence, with the shipped code and never a copy and a mutation
  seen to fail, but it does not prove the built provider consumes the walk, so it
  never counts toward N. A present outcome that no refusal exposes is an N gap:
  the leaf names it in its log and `target-locations-vm` closes it at V with the
  effect. No new public diagnostic is implied.
- **Observers are controlled at the admitted length.** The positive control for a
  delivery or Finder-selection observer is a 1,023-byte subject opened or revealed
  by an independent non-Koine route. No over-limit delivery by any route is a
  prerequisite, because the v1 decision defers it.
- **No substitution.** A preferred long copy is refused with `failed`, never
  replaced by a short copy of the same application, running or not.
- **The retained 1.0.0 binary keeps its defect** (`ELOOP`/`ENAMETOOLONG` mapped
  to absence). It is rebuilt from no changed source and relabelled as nothing.
- Fixtures are built component by component, so no whole-path `mkdir` or `open`
  addresses a long location. The long-fixture scripts already in `scripts/`
  (`vm-installation-fixtures.sh`, `vm-open-path-fixtures.sh`,
  `vm-reveal-path-fixtures.sh`, `build-long-action-probe.sh`) are reusable.
- Reusable steps go into `Taskfile.yml`; a leaf that finds one wanted adds it.

- K187's bounded prefix-link matrix is complete: twelve native states, no long
  listed/preferred copy exposed, with exact physical identities and unchanged
  inputs. `docs/verification/prefix-registration-vm.md` records the gap and raw
  recipe-only reveal matcher failure without adding a Finder V pass. The original
  application V charter stays live in k181; `long-application-acceptance-k188`
  now owns Antony's acceptance-scope decision. No further automatic registration
  experiments or L/G-to-V relabelling are authorized by k187.
