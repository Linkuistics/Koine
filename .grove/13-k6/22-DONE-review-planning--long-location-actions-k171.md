# long-location-actions-k171

**Reviews:** long-location-actions-k167
**Creator:** run d213efd4-5588-4bb4-9473-736d02a5f1ce

## Goal

Adversarially read `long-location-actions-k167`'s cut of the v1 long-location
action contract before any of it runs. Produce findings, not fixes.

## Context

- `long-location-actions-k167`'s commit, its decisions log, the new node
  `long-locations-k172`, its brief and its nine leaves, and the one paragraph
  added to the `launch-and-open-k6` brief.
- What the cut must cover, tested against the sources rather than against
  the node brief's own table:
  - `docs/specs/workspace-launch-and-open.md#long-location-action-boundary`,
    every bullet of "Subjects and versions" and the two acceptance rows added
    for it;
  - `docs/adr/filesystem-access-is-descriptor-relative.md`;
  - `docs/verification/long-action-native-boundary.md#compatibility-and-implementation-obligations`;
  - the k6 brief's integrations k168 and k170, and the long-location paragraphs
    of the `Design handoff` section.

## Done when

Each finding is recorded with the leaf or brief it concerns, or the review
states that it found none. An integration step is cut only if a finding is worth
acting on.

## Notes

These are the doubts the producer could not settle alone:

- Does every L, N, G and V bullet of "Subjects and versions" have exactly one
  named owning leaf, and is each owner able to observe it at that seam? In
  particular the real walk's *present* outcomes cannot be seen through a signed
  bundle on the host without opening or revealing something: the cut assumes a
  shared-source walk tested directly plus refusals that follow resolution. Is
  that an honest N, or does it quietly turn N into L?
- The first-use prompt question decides whether the ADR stands. The cut measures
  it inside the first walk leaf, before the rest of that leaf is built, and again
  in the signed app at V. Is that early enough, and is the stop rule (a prompt
  returns to Antony, no whole-path fallback) written where the executing session
  will meet it?
- The retained 1.0.0 workspace bundle must exist before any source change. Does
  `retained-workspace-baseline` really precede every leaf that edits the provider,
  and does its way of retaining the binary avoid the "rebuilt or relabelled
  baseline" the spec rules out?
- Each stage leaf leaves Koine working, but the 1.0.1 schema descriptions are
  appended only after all three stage leaves. Between them the served schema
  still says 1.0.0 while behaviour is already corrected. Is that a justified
  ordering, or should the release come earlier?
- `reveal-locations` carries the whole walk, every resolution row and the reveal
  limit. Is it more than one session at a seam the cut missed? So are
  `action-repair-release` and `action-repair-compat`, which re-pin the selection
  and conformance fixtures from workspace 1.0.0 to 1.0.1.
- Is the order right with respect to the consumers outside this node:
  `app-and-file-search` (k30/k120/k123) and the root leaves
  `baseline-acceptance-k17`, `protected-default-open-k89`,
  `reveal-app-bundle-notice-k90` and `protected-home-search-k93`? Does anything
  there still assume the 1.0.0 `ELOOP`/`ENAMETOOLONG`-as-absence mapping?

## Decisions (running log)

- Reviewed producer commit `5454ef59b00c42c359d6490f924a59db57031b72`
  (`long-location-actions-k167`), its nine-leaf node `long-locations-k172`,
  the governing action spec/ADR and k168/k170 integrations, compatibility
  obligations, current native adapter and selection/receipt consumers, and
  downstream search and root acceptance charters. The working copy began empty
  on that producer. Inspection only: no test, build, lint, format or native/VM
  experiment ran; production, tests and the reviewed plan remain unchanged.
- Graph evidence was unavailable: `codebase-memory-mcp cli list_projects`
  refused because a pre-coordination or unverified generation is active. No
  project/generation or coverage result could be established. Findings use
  targeted exact-source reads; no graph completeness claim is made.
- Retention ordering is sound: k173 precedes every provider edit and names a
  reproducible pre-repair revision or a recorded binary digest, distinct from
  released `v0.1.0`, which has no workspace. The prompt stop is encountered in
  k174's first done-when item and repeated in the node brief and signed-app V.
- The stage slices have useful L/G/native refusal outcomes without later
  siblings. Packaging after all stage changes is an explicit intermediate
  version trade-off in k167's log, rather than an accidental omission: final
  1.0.1 descriptions must be true when published. No finding on that ordering.
  Search's actual-result acceptance follows this entire node and remains owned
  by app-and-file-search; k89/k90/k93 and baseline acceptance preserve their
  separate pending decisions. They do not authorize the retained target errno
  mapping for the repaired provider.
- Four actionable findings below warrant an adjacent integration. Leaf size
  alone supplies no additional finding: k174 and k179 identify decomposition
  seams if execution exceeds one session. The review does not pre-empt that
  decision or create implementation/fix work itself.

## Findings

Coordinates below refer to producer commit `5454ef59` before the integration
insert renumbers the node; the leaf/node handles remain stable.

### R1 — Missing receipt executable-resolution owner (high)

**Concerns:** `discovered-applications-k177`,
`.grove/13-k6/23-k172/05-impl--discovered-applications-k177.md:42`, and the
ownership table in `long-locations-k172`.

The final conversion sweep enumerates callers of `inspectApplication`, but the
spec also requires receipt observation to resolve the live executable's kernel
path with this same walk (`docs/specs/workspace-launch-and-open.md:323`). This
is a separate route: `NativeWorkspace.liveExecutableIdentity` takes
`proc_pidpath`'s up-to-4,096-byte result into `fileIdentity(ofPath:)`
(`Providers/WorkspaceProvider/Sources/NativeWorkspace.swift:274`), which uses
`URL.resolvingSymlinksInPath` and pathname resource values at line 286.
`RunningApplication.executableIdentity` uses that helper too (line 303), and
`Observation.swift:37` compares both identities. Neither route calls
`inspectApplication`; none of the nine leaves assigns its conversion or real
acquisition subjects. k181's note that length-caused null is a defect is not an
implementation owner or an observation plan.

The stages can therefore finish while receipt identity still uses the forbidden
whole-path access primitive, or compares an old Foundation identity with the
new device/inode representation. A within-limit bundle path does not establish
that the executable path, or a reused running copy's executable path, fits that
limit. Assign the executable identity route and compatible comparison to a
named slice, with retained null/mismatch/start-sample semantics and real native
acquisition coverage. Receipt observation needs its own resolution/null rule;
it must not retroactively apply a pre-submission hand-off refusal after an
acknowledged action.

### R2 — Preferred-long application acceptance contradicts the selected-copy gate (high)

**Concerns:** `application-locations-vm-k181`,
`.grove/13-k6/23-k172/09-impl--application-locations-vm-k181.md:24`, and
`discovered-applications-k177` at its lines 39–41.

k181 requires unconstrained launch to work when the long registered copy is
preferred. k177 also suggests another eligible copy can keep that workflow
working. The current contract instead discovers the identifier's preferred
copy, makes that location the selected application, then refuses its over-limit
spelling before submission (`docs/specs/workspace-launch-and-open.md:355–370`).
The retained `Selection.swift:63–74` likewise chooses only the preferred copy
for the unconstrained form; it has no search for a shorter alternative. A
short copy already running cannot rescue a request that is refused before the
platform receives it.

This makes k181 unable to pass against k177's correct limit implementation,
unless execution adds an unapproved copy-substitution route. The older native
boundary subject table still asks for success when the preferred copy is long
(`docs/verification/long-action-native-boundary.md:180`), which explains the
drift but does not settle it. Separate the success case (a short selected copy
beside an unequal long candidate) from the preferred-long refusal case, and
reconcile the contradictory acceptance instructions before implementation.
Any decision to substitute another copy needs contract authority; it is not a
fixture repair.

### R3 — VM observer prerequisite still requires the deferred over-limit delivery (high)

**Concerns:** `target-locations-vm-k180`,
`.grove/13-k6/23-k172/08-impl--target-locations-vm-k180.md:23`.

Before observing any Koine result, this leaf requires each observer to see the
same long subject independently opened and revealed. Read with its 1,024-byte
and roughly 1,500-byte negative subjects and its cited boundary record, that
requires the very over-limit delivery the v1 decision deferred. k134 found
submission failing there, and the leaf supplies no supported independent route
that delivers those same bytes. Its observer-limit rule would thus keep correct
v1 refusals permanently pending rather than accepting them.

The current spec explicitly chooses a 1,023-byte successful document as the
positive control and then observes no delivery/selection for the refused
1,024/~1,500 subjects (`docs/specs/workspace-launch-and-open.md:500–503`).
The boundary record's earlier same-long-subject control requirement remains
at `docs/verification/long-action-native-boundary.md:190–194`. State the v1
control and absence-observation protocol consistently in the leaf and its
cited evidence obligations; do not make an unsupported over-limit open/reveal
a prerequisite for this refusal-only release. The leaf's goal also still
promises that long documents/directories open and are revealed without
qualifying the admitted length.

### R4 — Shared-source walk tests do not close the independent native binary subject (medium)

**Concerns:** `reveal-locations-k174`,
`.grove/13-k6/23-k172/02-impl--reveal-locations-k174.md:74`, and
`long-locations-k172` brief at lines 98–103.

The plan permits every present walk outcome to be tested directly through
shared source as an alternative to the signed bundle, while its table counts
those results toward N. The governing spec defines N as independently built
provider/host binaries and L as supporting substituted-adapter planner tests
(`docs/specs/workspace-launch-and-open.md:651–658`); the boundary record makes
the same distinction at lines 186–189. Direct tests of the actual walk source
are valuable real-filesystem evidence, but they do not prove the built provider
includes, invokes and consumes that walk or maps its facts correctly.

Refusals after resolution can establish selected binary outcomes, but the
plan does not map all its remaining N subjects to an observable result in that
seam: e.g. the present mode-0600 final directory, finite repeated dot-link and
root/no-follow decisions. Testing those only through shared source leaves the
native subject unclosed while the brief says every N subject passes. Keep
shared-source checks as supporting evidence and explicitly assign binary
observations for the promised N outcomes (and VM observations where effects
are needed). If a subject cannot be observed under the host's no-effects rule,
record the gap and settle its acceptance assignment rather than silently
redefining N. No new public diagnostic API is implied.
