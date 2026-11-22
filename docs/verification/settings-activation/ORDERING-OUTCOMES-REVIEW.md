# Settings scenario outcome review

Review `settings-scenario-outcomes-k161` finds two issues that need integration
before k62 consumes this scenario. The reviewed producer is
`settings-scenario-outcomes-k67`, commit
`7564ed77587e7467a831d71a3d899b6a58aea56c`. Its implementation and controls
are unchanged in the reviewed working tree.

This is an inspection-only review against the k67 charter, the k36 brief,
the archived k53/k56/k61 charters, the
[ordering protocol](ORDERING-EVALUATION-PLAN.md) and its
[review amendments](ORDERING-REVIEW.md). No test, build, lint or format command
ran. No guest, candidate or freeze was created. No finding establishes native
behaviour, callback delivery or cause.

## F1 — P1: selection state does not establish the required menu observation

**Locations:** `scripts/vm_exec_reads.py:586–592`,
`scripts/vm-settings-scenario-lib.sh:610–612` and
`scripts/vm-settings-scenario-lib.sh:646–649`.

The `open-menus` script reads the names and `selected` values of TextEdit's
menu-bar items, plus `selected` of Koine's one item. The setup accepts all
false values. The post-click check likewise accepts `selected == false` as
proof of closure. Neither script enumerates the exposed menus or records a
menu count for each item.

This breaks the "No open menu" row of the protocol's "Matched observable
setup" section. That row requires enumeration of the menus under the TextEdit
and Koine items, each item's count and completion of the enumeration. The
"Input and observation qualification" section also requires a closed menu
before a selection can qualify as a recurrence.

The host's dictionary at
`/System/Library/CoreServices/System Events.app/Contents/Resources/SystemEvents.sdef`
defines a menu-bar item's `menu` elements at lines 1099–1103. Its `selected`
property at lines 1445–1448 describes selection and admits missing values.
Apple's [selected attribute](https://developer.apple.com/documentation/appkit/nsaccessibility-swift.struct/attribute/selected)
also describes selection, without defining menu visibility. The
[Carbon Accessibility attributes](https://developer.apple.com/documentation/applicationservices/carbon_accessibility/attributes)
describe `kAXSelectedAttribute` for selectable rows and columns. These sources
do not supply the equivalence that the scenario uses.

A concrete source-level counterexample is an exposed menu whose item reports
false for selection. Both predicates accept that value: setup permits the next
menu-opening input, and a failed return can be recorded as a closed-menu
recurrence candidate. The source contains no independent menu observation
that excludes this case. This is not a claim that a guest has exhibited it.
Conversely, an unsupported selection attribute makes a clean closed-menu
state unavailable. The parser correctly refuses missing values, but that does
not validate the meaning of a present boolean.

The producer already records this uncertainty in
[its results](ORDERING-OUTCOMES-RESULTS.md#primary-sources-and-unverified-oracles).
That disclosure does not amend the required oracle. E01 qualifies availability
in successful states; a successful false-valued read cannot establish that the
same field detects an open menu. Supplemental screenshots cannot replace this
required structured observation. The simulated backend equates its `menu`
flag with selection, so its green controls establish that assumed mapping only.

## F2 — P2: a false front predicate can replace an unavailable title outcome

**Locations:** `scripts/vm-settings-scenario-lib.sh:736–747` and
`scripts/vm-settings-scenario-lib.sh:562–565`.

Both callers run the title audit and save its status, then handle a false
front predicate before checking whether the audit was unavailable. The
app-reopen route has no subsequent menu read to expose the failure latch.
It therefore calls `settings_fail_as not-front` and exits 1 even when the title
audit returned 125. The resize front assertion has the same precedence.

For example, let the reopen count poll see one Koine window. Its original
front list then contains a focused Finder window followed by one unfocused
Koine window with the required geometry/type/focus fields but no `title`.
This is an admitted window-list shape: `read_guest_windows` permits an omitted
title. The old front predicate returns 1. `settings_title_audit` records the
missing title as unavailable and returns 125. The branch at line 737 takes
failure observations and calls `settings_return_classify` with route `reopen`.
That function skips the menu check, records `scenario-assertion-not-front`
and exits 1. The unavailable audit is still in the receipts, but the terminal
class and status describe a clean assertion failure. At resize, line 563
performs that same conversion directly.

This breaks the protocol's "Input and observation qualification" rule that
missing title fields are unavailable evidence, and k36's required distinction
between assertion failure and unavailable evidence. It also contradicts the
producer's description of `settings_require_as`: a non-1 failure keeps its
own status. A downstream caller must not have to undo a terminal clean-failure
classification by rediscovering an earlier unavailable audit.

The current missing-title control in
`Tests/scripts/vm-settings-scenario.bats:617–628` tests a front predicate that
holds at the first selection. The wrong-title controls explicitly require the
front predicate to hold. Neither covers the combined false-front/unavailable-
title branch at app reopen or resize. This finding follows from the source;
no simulated or guest run was performed in this review.

## Disposition of the eight chartered doubts

| Doubt | Result of this bounded inspection |
|---|---|
| 1. System Events oracle semantics | F1. The dictionary supports the process PID, window subrole, sheet and enabled-property vocabulary. No additional source defect was found in those four observations. Guest availability remains unqualified. |
| 2. Missing values, partial enumeration and errors | The new parsers reject malformed shapes, unequal enumeration lengths, missing required attributes and script errors. F1 leaves the menu fact unestablished even for a correctly typed value. F2 loses an unavailable title outcome in the caller. This is not a claim that equal lengths prove native completeness. |
| 3. Deferred count poll | No additional defect found. The existing ten reads and ten negative waits remain. A failed read stops immediately. The final clean list is returned on deferred exhaustion; the current caller performs failure observations and records exhaustion before it can reach more input. |
| 4. Failed-return order and outcome distinctions | F2. On clean count exhaustion, the source orders zero-window liveness before the observer, evidence window list and screenshot, then the applicable menu read and exhaustion receipt. Process loss skips the menu read. Failed liveness remains unresolved with its status. Later collection failures remain in the raw receipts and cannot themselves qualify acceptance. |
| 5. Same-list title audit | No replacement front list is used for the audit. Both predicates consume `SETTINGS_LIST`. F2 concerns the handling of their outcomes. Count exhaustion exits before the separate front assertion; its retained final count list and failure-observation list remain distinct. |
| 6. Positive setup | Apart from F1, no defect found. The source uses the retained zero-count list, the prepared TextEdit PID and frame, and the fixed window/sheet predicates. Failed setup exits before menu input. The added operations are observations and local receipts, with no added wait. |
| 7. Preserved successful paths | No additional defect found in the producer diff. The menu-opening and row-click route and its post-click wait remain; the new observations surround them. Later ordinary actions remain. Exact E/A prefix extraction and whole-duty reconciliation remain k62's work. |
| 8. Controls and red evidence | No new control was found to pass regardless of the scenario in the inspected cases. The revised missing-title test demands its own refusal. The backend still assumes the semantic mapping in F1, and the combined branch in F2 is uncovered. Red failures demonstrate sensitivity to the earlier source, not native correctness. |

## Evidence and limits

The recorded `red.txt` has 24 failures among 108 tests. The separate
`red-title.txt` fails the tightened missing-title control. The recorded final
transcript reports eighteen Taskfile checks and 314 passing tests. These are
the producer's recorded runs, not fresh test results from this review.

A read-only SHA-256 comparison in this review confirmed the transcript and
subject-manifest hashes against all three JSON summaries. Each of the ten
reviewed implementation/control files matches its entry in the final subject
manifest: the four production files, the scenario Bats file, its simulated
backend and the four other changed Bats files named in the charter. That check
binds the saved evidence to the inspected bytes; it establishes no guest result.

Graph verification used project
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14`, generation
`2026-11-22T16:02:12Z`, at Tier 2. The one-hop trace of
`settings_expect_return` reports one scenario caller and fourteen callees,
with no further page. The graph resolves `jq` to an unrelated document symbol,
so direct source supplies the shell semantics. Coverage reports
partial parsing in the scenario library at lines 225, 331, 543 and 594, the
window library at line 130 and the System Events facade at line 28. Direct
reads covered those ranges and the relevant functions. Bats files and text
evidence have no tracked coverage metadata and were read directly. A clean
coverage result is not a completeness proof.

The integration belongs immediately before `settings-focused-prefix-k62`.
It must read these findings from this review's commit and apply the normal
acceptance/material-risk threshold. This review changes no implementation,
protocol, historical result, finite slot or ancestor acceptance.
