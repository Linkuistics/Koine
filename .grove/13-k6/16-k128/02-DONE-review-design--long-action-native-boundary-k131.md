# long-action-native-boundary-k131


**Reviews:** long-action-native-boundary-k129

## Goal
Adversarially inspect the committed native boundary, proposed error correction
and independent subjects before the remaining supported-route producer consumes
them. This is a mandatory load-bearing review, not route completion or fixes.



## Context

- Parent `long-search-result-actions-k128` retains the original full mandate;
  `long-action-route-k130` is live immediately after this review.
- `docs/verification/long-action-native-boundary.md`, its public declaration
  probe and `Taskfile.yml` are source/SDK evidence, not executed native acceptance.
- `docs/specs/workspace-launch-and-open.md#long-location-action-boundary`, search
  handoff, guide, workflow trace, glossary, action SDL/examples and viewer.
- Existing `NativeWorkspace.swift` inspection, selection/planning and submission
  code. Graph CLI refused the active unverified generation in the producer;
  no graph coverage verdict was obtained. Establish current graph evidence if
  available, and otherwise verify the exact relevant source directly.

## Done when

- Challenge the separation of supplied, expanded/native, classification and
  submitted limits against exact code and public SDK/primary sources. Historical
  realpath/kernel source and compile/link success must not become proof of the
  guest's behavior, modern API support or a complete/impossible route.
- Try to disprove failed-versus-absence meaning for POSIX/Foundation, link limits,
  nil/malformed type or identifier facts and uncertain registered candidates.
  Demand relevant stage/cause provenance; check the retained action-only 1.0.0
  contract and new description/digest/profile for incompatible meaning hidden
  by unchanged enums, coordinates or version. Flag any needed human decision.
- Challenge original-byte/selected-copy preservation, native payload refusals,
  controls before inspection, cancellation, deadlines, acknowledgment/no replay,
  handler policy and no new prompt/consent/private policy. A presence lookup
  cannot silently stand in for native classification or registration equality.
- Verify actual roughly 1,500-byte search-result file/default/Zed/reveal and
  constrained-app subjects, independent copy/delivery/selection observers and
  distinct L/G/N/V/binary profiles. Construction or earlier-stage failure cannot
  close the intended subject; retained short-path evidence cannot close it.
- Verify artifact/viewer consistency, deterministic check limits and the live
  parent/route/final-review chain before search consumers. Do not demand route
  completion from this bounded child or approve a shorter/copy-only baseline.
- Produce anchored findings under the review skill and schedule any earned
  integration before `long-action-route-k130`. Leave design fixes to integration.

## Notes

The producer executed no native action, protected read, independent binary or
signed-macOS subject. Its isolated Ubuntu Firefox checks concern presentation.
No complete replacement route, unsupported conversion, new entitlement/setup,
workflow loss or new consent was selected. Those boundaries are review targets,
not evidence that every public route is impossible.

## Decisions (running log)

- Adopt the mandate in the stated jj workspace. Producer is `d57d2bae7837`
  (`qzsyntxp`); `@` is empty on top of it, so every coordinate below is both the
  producer's and the current tree's. `boundary` is
  `docs/verification/long-action-native-boundary.md`, `spec` is
  `docs/specs/workspace-launch-and-open.md`, `guide` is `docs/client-guide.md`,
  `native` is `Providers/WorkspaceProvider/Sources/NativeWorkspace.swift`, and
  `N-tests` is `Tests/KoineServerTests/WorkspaceProviderTests.swift`.
- The codebase-memory server failed to connect this session, so no graph,
  freshness or coverage claim is made. Code and documents were read directly.
- The harness's `grep` is a ugrep wrapper (`-I`, `--ignore-files`). It skipped
  the ISO-8859 SDK header `Files.h` and printed nothing, so a missing declaration
  looked like a clean read. Every repo-wide or SDK claim below was re-run with
  `/usr/bin/grep`. Positive controls: the re-run found the known `loop-a`
  fixture lines, and it found `FSMakeFSRefUnicode` in `Files.h`, where the
  wrapper had found nothing.
- Inspection only. No task, build, render, check, probe or native call was run,
  and no in-session reviewer was spent. Primary-source reads:
  - SDK 27.0 headers: `CFURL.h`, `LSInfoDeprecated.h`, `Files.h`, `syslimits.h`,
    `attr.h`, `resource.h` and `fsgetpath.h`;
  - Apple's published `realpath.c`.

  The boundary's citations hold. `realpath` mallocs PATH_MAX for a null
  destination, its scratch buffers are PATH_MAX, and it never checks a component
  against NAME_MAX. The FSRef and LS item APIs are deprecated, and the LS ones
  point to URL resource properties as the replacement. `CFURLCreateFromFSRef` is
  "Not supported". None of these sources is guest evidence.
- Ten findings warrant triage. The first sibling entry after this review that
  holds live work is `long-action-route-k130`. An integration is inserted at its
  slot and carries this review's handle only.

## Findings

Producer `d57d2bae7837` (`long-action-native-boundary-k129`). The list is in
severity order. No finding asks this child to complete the route, or approves a
shorter, copy-only or disabled baseline. Each finding names a defect in the
committed design and what needs settling. Runtime outcomes stay pending
throughout.

### B1: The repair reverses accepted short-path outcomes without reconciling them (high)

The repair's scope:

- It makes "native path-size refusal and unresolved link-limit exhaustion"
  `failed` (spec:246-248; boundary:48-57).
- That covers every ELOOP and every ENAMETOOLONG. It is not limited to long
  search locations.

The 1.0.0 artifacts still accept the opposite for short inputs:

- **Spec acceptance rows.** They still say "a symlink loop and a name too long
  to exist are `PATH_NOT_FOUND`" for open (spec:536-540). The reveal row says
  the same (spec:604-606). The reveal N row records the signed bundle reporting
  "a loop as `PATH_NOT_FOUND`" (spec:624). None of these rows is marked
  superseded or retained-baseline-only.
- **N tests.** Both assert `PATH_NOT_FOUND` for a two-link cycle (`loop-a` ↔
  `loop-b`) and a 300-byte single component (N-tests:478-500, 619-636).
- **Contract-only client.** It documents "a link loop" as `PATH_NOT_FOUND`
  coverage (`clients/contract-only/src/adapter/workspace-open.ts:30-34`). Its
  findings record the guide sentence the producer has now rewritten
  (`docs/verification/open-path-contract-client-findings.md:160-185`).
- **Native comment.** It still justifies the mapping
  (native:128-136).
- **Recorded decision.** The mapping was a reviewed decision.
  `open-path-k75`'s reviewer moved ELOOP and ENAMETOOLONG from `failed` to
  absent "since nothing is there to open"
  (`.grove/13-k6/12-k74/01-DONE-impl--open-path-k75.md:90-95`). The boundary
  reverses that decision without saying so or answering its rationale.

The guide has already changed:

- It calls the N-accepted behaviour a "known defect" (guide:724-727).
- Its reveal item drops loops and long names (guide:779-784).

So the guide and the spec now disagree about what the served 1.0.0 contract
does.

The boundary's claim is false as stated. It says "existing short-path evidence
stays valid for its actual subjects" (boundary:58-61). The actual N subjects
(the cycle and the 300-byte name) get a different expected outcome from the
repaired provider.

The rationale is also only half wrong:

- It fails for an extant target. A chain longer than 32 links and an overlong
  whole or expanded path can both reach something openable.
- It may hold for a genuine cycle and for a component over NAME_MAX.

The subjects table lists "component overlength" as a separate outcome but never
says which outcome it is (boundary:116).

What needs settling:

- Whether cycle, link-bound and component-overlength cases each keep
  `PATH_NOT_FOUND` or move to `failed`. If they move, record the reversal of
  k75's decision with its new rationale.
- The acceptance rows, N fixtures, contract client, findings record, native
  comment and guide, reconciled to that choice. Mark which rows describe only
  the retained 1.0.0 baseline.

### B2: "Inconclusive" type or identifier facts collide with accepted nil meanings, and a long route could bypass payload refusal (high)

The repair says that "an inconclusive native type, identifier, identity or
registration inspection also means failed" and "cannot establish identity
mismatch" (spec:248-250). The boundary adds "incomplete/malformed native
metadata" (boundary:49-51). Neither defines how an inconclusive nil differs
from an established one. The accepted contract gives nil two established
meanings:

- **No content type.** A nil content type is "not refused" (spec:526).
  `refusalReason` refuses executables only by content-type conformance, and
  `conforms` answers false for nil (`Providers/WorkspaceProvider/Logic/OpenPath.swift:61-77`).
  `inspectPath` passes `contentType` through as optional, while it turns nil
  `isApplication` or `isAliasFile` into unreadable (native:116-124).
- **No identifier.** A nil `Bundle(url:)` identifier with no Info.plist denial
  is "declares no identifier", so `APPLICATION_IDENTITY_MISMATCH` (native:45-49).
  V accepts that outcome for a plist-less registration and a no-identifier
  bundle (`docs/verification/application-installations-vm.md:136, 198-199`).
  The existing code cannot tell a readable but unparseable plist from one that
  lacks the key.

Consequences:

- **The broad reading** turns these accepted outcomes into `failed`.
- **The narrow reading** lets any long-location route that cannot get a content
  type return nil. A long Mach-O program would then not be refused, and would
  go to its default handler (Terminal executes it). A nil identifier from a
  failed long-path read would likewise invent a mismatch.

This is an interface defect in the sense of the codebase-design review. The
seam's `PathFacts.contentType: String?` and `ApplicationBundle.bundleIdentifier`
put "platform says none" and "could not acquire" in one value. The contract's
failure semantics are therefore absent from the interface that has to carry
them.

What needs settling:

- A provenance rule for each nil fact (content type, identifier, identity),
  stating which acquisition establishes "none".
- The accepted no-type and no-identifier outcomes, kept or explicitly changed.
- For any long route, a requirement that an unacquired type refuses as `failed`
  and never reaches the "not refused" branch.

### B3: Search-dependent acceptance sits in an increment that runs before search exists (medium-high)

Both V rows require that "an actual search returns it" and that "no search-result
injection closes this row". The constrained app gets "the actual search
identifier AND applicationPath" (boundary:114-115; spec:274-283).

The schedule conflicts with that:

- The boundary routes "implementation/native acceptance through planning in
  this increment", meaning launch-and-open (`.grove/13-k6/_launch-and-open.md`
  Design handoff).
- The briefs place "the entire launch-and-open chain" before the search
  consumers k123, k120 and k30 (`.grove/_BRIEF.md`;
  `.grove/14-k7/_app-and-file-search.md`).
- No search implementation exists. `workspaceSearch` appears nowhere under
  `Providers`, `Sources` or `Tests`, and `app-and-file-search-k30` has not cut it.

As written, the acceptance leaves launch-and-open's planning will cut cannot
close until search ships. Search planning waits on this chain. Either pick
blocks on a leaf that cannot complete, or the rows get quietly deferred.

What needs settling: which rows close where.

- Action-time long-location acceptance can use fixtures built independently of
  search, and close in launch-and-open.
- The search-to-action row can be owned by app-and-file-search acceptance. The
  workflow trace's "search-to-action G/N/V pending" already sits in the search
  rows.

Under either split, a search-result provenance requirement must stay with
whichever leaf closes the search-to-action row.

### B4: The repaired provider's compatibility, version and digest are asserted but unspecified (medium-high)

The repaired release "retains the contract version, input/result shapes and
error kinds, with its own exact descriptions/digest and candidate profile"
(spec:285-289; boundary:58-61; `docs/design/workspace-schema.graphql:2-4`).

What is missing:

- **Which descriptions change.** No SDL description encodes the loop, size or
  nil meanings (`docs/design/workspace-schema.graphql:16-34`; the
  `workspaceOpenPath` and `workspaceRevealPath` descriptions). An action-only
  repair could therefore be SDL-identical to 1.0.0, with the same digest. That
  contradicts "its own digest", and Machine says an identical digest cannot
  prove which binary ran (`docs/specs/machine.md:1497-1500`).
- **Which release or schema version carries the repair.** It could be the
  search-serving release or an action-only patch. Machine's version rules apply
  to whichever it is (`docs/specs/machine.md:1258-1267`).
- **Whether the change is compatible.** B1 and B2 move outcomes the 1.0.0
  documents publish, from dependency ("this action submitted no domain
  request") to `failed` ("effects may have begun", spec:226). The version stays
  1.0.0. The root brief requires that "an incompatible contract-version change"
  be raised with Antony.

What needs settling:

- The carrying version, the exact changed descriptions, and the expected digest
  and profile delta.
- A recorded compatibility judgement. If the meaning change is incompatible
  under the unchanged version, it is a concrete decision for Antony.

### B5: A registered long copy can make accepted short launches fail (medium)

The current selection fails a request when a registered candidate is unreadable.

- **Constrained launch.** `selectConstrained` returns `failed` on the first
  unreadable registered candidate. That happens before it reaches the chosen
  copy whenever the long copy comes first in `urlsForApplications`' undocumented
  order (`Providers/WorkspaceProvider/Logic/Selection.swift:98-107`).
- **Unconstrained launch.** If Launch Services prefers the long copy, the launch
  fails (Selection.swift:65-70). `inspectApplication`'s realpath maps
  ENAMETOOLONG to unreadable (native:26-29).

The boundary endorses the per-candidate rule (boundary:44-46). It does not name
the consequence:

- One registered copy over PATH_MAX can turn an accepted short-path launch into
  `failed`. That covers the twelve launchers, the multiple-copies row and the
  Finder check inside reveal.
- The long constrained V subject itself registers exactly such a copy
  (boundary:115).

The parent says this leaf "reopens only the long-result action seam, not prior
accepted launch workflows", and forbids accepted workflow loss without
escalation.

What needs settling:

- Subjects for short constrained and unconstrained launches, and a Finder
  reveal, while a long copy of the same identifier is registered.
- A route requirement that this cannot regress them. If it can, escalate the
  loss.

### B6: The default-handler lookup is a native path consumer the boundary omits (medium)

Default opening calls `urlForApplication(toOpen:)` on the target URL, and the
call answers only nil (OpenPath.swift:136-143; native:235-237). The spec
already warns that nil can mean a missing file or a missing handler
(spec:228-230).

What the boundary does not establish:

- **What nil means for a long URL.** The four-stage table never names this
  lookup (boundary:17-22). For a present long file, nil may be "no handler" or
  "could not process this URL". The repair's "cannot establish … no default
  handler" (spec:249-250) has no mechanism, because this API gives no error to
  attribute. Under current code and the repair as written, an unprocessable
  long URL reports an invented `NO_DEFAULT_HANDLER`.
- **Whether the lookup prompts for a long URL.** It is the call measured to
  prompt on protected documents. The new note in `protected-path-metadata.md`
  excludes only the component and native-reference mechanisms.

What needs settling:

- The handler stage added to the limits.
- A provenance rule for a nil handler on a present target.
- A long-URL handler-lookup prompt subject.

### B7: The launch route has two more native path consumers the boundary omits (medium)

The first omitted consumer is the submission spelling:

- A constrained launch or named open submits Launch Services' registered URL,
  not the supplied `applicationPath` (Selection.swift:101;
  `Providers/WorkspaceProvider/Logic/WorkspaceProvider.swift:117-124`).
- Its spelling, and so its length, can differ from the input.
- The boundary describes "one original-location native request"
  (`docs/design/architecture/workspace-long-locations.d2`, `Submit`) and a
  table that treats submission as the input bytes (boundary:22, 104-108).

The second omitted consumer is the receipt's process identity:

- The process identity compares `application.executableIdentity` with
  `liveExecutableIdentity` (`Providers/WorkspaceProvider/Logic/Observation.swift:38-40`).
- Both read file identity by path text: `proc_pidpath`, then
  `fileIdentity(ofPath:)`, which calls `resolvingSymlinksInPath()` and then
  reads resource values (native:274-292). That is the same whole-path route the
  boundary calls PATH_MAX-limited.
- A long constrained launch can therefore return `process: null` silently.
  Contract-legal null still loses the desktop handoff the receipt exists for
  (spec:206-209).
- No subject records the receipt's `process` for the long app.

What needs settling:

- Both stages added to the limits.
- The receipt's long-app process observation added as a recorded subject.
- An explicit statement of whether a systematic null for long apps is an
  accepted limit, which is an operator decision, or a defect.

### B8: The repair's core mapping sits below the L seam, so L cannot cover it (low-medium)

The L rows claim that a "real provider with WorkspaceNative substitution
distinguishes lookup, metadata refusal, absent and acknowledged stages"
(boundary:114; spec:274-276). The decision the repair changes sits inside the
real adapter:

- the errno mapping (`unavailable`, native:132-137);
- the Foundation mapping (`isMissing`, native:75-84);
- the plist-denial nil rule (native:49, 59-68).

The seam (`WorkspaceNative.inspectPath -> PathInspection`,
`Providers/WorkspaceProvider/Logic/Native.swift:58-104`) receives only the
result, `absent` or `unreadable(String)`.

A substituted adapter tests the planner's response to a chosen outcome, not the
classification. Only N and V can exercise the classification, and N runs host
fixtures. The boundary says no fixture ran on the developer machine
(boundary:142-144).

What needs settling, as a codebase-design point:

- Either move the cause-to-meaning classification into an in-process value
  function that L tests directly, with the adapter reporting a raw stage and
  cause;
- or state that the repair's deterministic coverage is N with
  component-created host fixtures, and drop the L claim.

### B9: The boundary view and outcome table omit dependency and refusal branches (low)

`docs/design/architecture/workspace-long-locations.d2` sends every non-presence
lookup result, and every classification problem, to one `Failure` node:

- No edge reaches a `DEPENDENCY_UNAVAILABLE` outcome for established absence.
  The node's own text says "dependency only for established missing
  prerequisite".
- No edge reaches the payload-refusal input error.

That view is the "Start here" for this boundary, and it shows absence as
impossible.

Two text defects go with it:

- The spec's outcome table (spec:217-226) has no row for size, link-bound or
  inconclusive metadata mapping to `failed`.
- The guide's reveal item lost its conjunction: "a link to nothing, a path below
  a file, a genuinely missing component are …" (guide:780-781).

### B10: The observers and the deterministic check claim more than they show (low)

The subjects require independent Finder-selection and handler-delivery
observers for long paths (boundary:114). The existing reveal observer is
AppleScript reading Finder's own account
(`docs/verification/reveal-path-vm.md:59-73`). It is itself unproven at over
1,024 bytes.

- A subject needs an observer that has been seen to read a long selection made
  by a non-Koine route, as a positive control.
- An observer limit must stay pending. It must never pass or fail Koine.

The deterministic check claims more than it reproduces:

- The `nm -u` import check (boundary:141-143) is not part of
  `design:long-action-api-check` (`Taskfile.yml`), so the recorded claim cannot
  be reproduced from the task.
- The link resolves against SDK `.tbd` stubs. "Symbol availability" there means
  the SDK's export list, not presence on the guest. The table should say so,
  rather than rely only on the probe's own comment.
