# long-search-result-actions-k168

**Integrates:** long-search-result-actions-k166

## Goal

Triage every finding from the load-bearing review of the v1 long-location
action design and apply the real design corrections before implementation
planning. Preserve Antony's settled v1 refusal and descriptor-relative access
decision.

## Context

- Review long-search-result-actions-k166: its findings and evidence are anchored
  to producer commit `21809e6b3a00` (final design session long-action-route-k165).
  Read that review, rather than treating this charter as a transcription.
- The action spec's long-location boundary and
  `docs/adr/filesystem-access-is-descriptor-relative.md`, with their current
  SDL, search handoff, guide, glossary, trace, editable architecture views and
  recorded native evidence.
- The retained provider sources/tests supply the established short-path and
  dependency meanings. The review ran no tests or native experiments and
  changed none of those sources or design artifacts.
- Next consumer long-location-actions-k167 is planning in this directory;
  search consumers k123/k120/k30 follow the reviewed/reconciled contract.

## Done when

- Every finding is classified with evidence. Apply actionable corrections and
  explain dismissed, clarified or accepted-trade-off items in the running log.
- Reconcile the design's affected current-state artifacts and exact SDL
  descriptions without changing public shapes, capabilities, enums or the
  independent 1.0.0 / action-repair 1.0.1 / search 1.1.0 profile contract.
- Preserve accepted short-path outcomes, unchanged selected inputs and copy
  constraints, truthful cause/fact distinctions, native acknowledgment and
  optional receipt meanings, grant/deadline/cancellation/no-replay obligations,
  independent action versus actual-search subjects and the first-use prompt
  acceptance condition.
- Verify the corrected design using applicable existing deterministic tasks.
  Update planning's acceptance subjects where the triage requires it. Native,
  binary, public runtime and signed-VM repair acceptance remains planning's.

## Notes

This is design integration, not implementation or a new native investigation.
No hand-off workaround, shorter search ceiling, consent/signing/private-policy
change or long-path application support is authorized. If substantial redesign
earns a new producer/review chain, place it ahead of k167 under Grove's normal
integration procedure; do not silently transfer an unresolved design into
implementation planning.

## Decisions (running log)

- Integrating review k166's eight findings R1–R8 as recorded in its own commit
  `7c274e43a42b` (`mumvpmmp`) against producer `21809e6b3a00`; the design files
  are unchanged since. This session started on an empty jj change. Antony's v1
  refusal and the descriptor-relative access decision are settled inputs, not
  re-litigated here.
- **R1 — real issue, fix the contract.** Verified from k134's frozen results:
  `submit-thr-open-1023.json` delivered a 1,023-byte pathname (1,024 with NUL)
  and `-1024` failed with Cocoa 256, so "needs `PATH_MAX` bytes or more including
  NUL" refuses the required positive. `state.json` thresholds measure stat,
  `FSPathMakeRef` and handler lookup on `sample.txt` at 1,021/1,022/1,023 (all
  succeed) beside the two-bytes-longer `sample.k134w` submission, with the next
  metadata negative at 1,098; `register.jsonl` has only short and ~1,500-byte
  registration. Correction: one convention everywhere — pathname bytes, NUL
  excluded, refuse at `>= PATH_MAX` (1,024), accept through 1,023 — and describe
  exact submission evidence separately from the other services' bounded
  observations. The v1 gate itself is kept.
- **R2 — real issue, fix the contract.** The only established meaning
  (`long-action-native-boundary.md` "component established to exceed its
  filesystem's native name limit", k134 row "Supported for ASCII; not a Unicode
  proof") is the 300-byte ASCII subject. The table's bare `fpathconf` row names
  no units, ordering or `-1` handling, so a byte precheck could call an extant
  HFS+ multibyte name missing. Correction: a successful lookup always
  establishes presence; impossibility needs the component's own lookup to fail
  with `ENAMETOOLONG` **and** a unit-independent excess — an ASCII component
  longer than its directory's returned `_PC_NAME_MAX` (for ASCII, bytes, UTF-16
  units and normal forms coincide). Any other `ENAMETOOLONG`, or an `fpathconf`
  that returns `-1`, is `failed`. No precheck before lookup, no probe creation.
  Multibyte/combining extant subjects join the retained ASCII subject.
- **R3 — real issue, fix the contract.** The counterexample is sound by
  construction: relative link text is read from its containing directory
  (search's resolver contract already retains "the containing directory as A"),
  so two directory entries for one symlink inode can repeat (link, suffix) on a
  finite path. A repeated resolver state is (containing directory identity, link
  identity, link text, exact pending suffix); the resolver is deterministic in
  it, so a repeat is a real cycle at any budget. Changed/unestablished
  observations stay `failed`. Add the same-inode/different-parent subject where
  a filesystem admits it; keep the two-link cycle and finite dot-link subjects.
- **R4 — contract stated unclearly, fix it.** "32 expansions without such a
  repeat" can fail an acyclic 32-link chain. Search's row (spec line 484) and
  the ADR already say 32 are allowed; the table now says needing a 33rd
  expansion is the budget failure, with 31/32/33 subjects.
- **R5 — real issue, fix the contract (repair, not redesign).** Unconstrained
  launch has only an identifier, default open learns its handler from lookup and
  reveal discovers Finder, yet the section said every location resolves "before
  any platform lookup" and a refused selected application had "no registration
  or handler lookup". Retained order (`OpenPath.swift` `planPathOpen`, spec line
  231, reveal guide "Finder ... is checked after the path") already puts the
  target first. Correction: staged order — target resolve/gate/classify, then
  the application stage (supplied `applicationPath` resolved; otherwise
  registration or handler discovery as reads, then resolution), candidate
  identity by the walk with no gate on unequal candidates, gate the selected
  application before its pathname metadata and submission. "No request" means
  no domain request. View redrawn to show the two stages.
- **R6 — real issue, fix the SDL and spec text.** `Selection.swift` and
  `SelectionTests` (`anUnregisteredApplicationIsNotInstalled`,
  `aMissingOrNonApplicationPathIsNotInstalled`,
  `aPresentButUnregisteredCopyIsNotInstalledAndAnotherIsNotSubstituted`,
  `aBundleLessProgramHasNoRouteToTheNamedSelector`) retain non-walk
  `APPLICATION_NOT_INSTALLED` instances that the repair SDL's "means that
  resolution found nothing" contradicts; its open text folded application
  absence into `PATH_NOT_FOUND`. Rewrite the three appended descriptions only
  (same shapes/enums), and reconcile the spec's "later nil is failed" sentence
  with the retained established nils.
- **R7 — real issue, fix the contract.** `NativeWorkspace.inspectPath` decides
  `isFilesystemRoot` by `lstat` of the literal path, and `reveal-path-vm.md`
  accepted `/Volumes/<link to />` as a link, not the root. The walk records the
  final component's no-follow identity for reveal's root decision (kernel
  trailing-slash/dot following preserved) beside the followed identity used for
  presence and hand-off; the retained spellings stay regressions.
- **R8 — real issue, fix the contract.** `selectConstrained` skips `.absent` and
  `.notApplication` candidates (`aStaleRegistrationBesideThePresentChosenCopyIsSkipped`);
  the new rule failed every unresolved candidate. Established absence or
  unequal device/inode skips; only an unestablished walk is unknown equality
  and `failed`. Both enumeration orders join the subjects.
- **Applied.** Action spec (resolution table and its name-limit, cycle and
  reveal-root rules; new "Order of target and application stages"; hand-off
  limit count convention and separated k134 evidence; subjects and acceptance
  row), repair SDL's three appended descriptions only, ADR wording (relative
  link context; no name pre-judging; conservative name-limit reading), search
  spec/SDL, client guide, glossary, boundary status, route-evaluation table,
  one factual limit in the k134 report, architecture README/discussion/captions,
  and the redrawn long-location view; k167's context now names the added
  subjects. Verified Apple's HFS `pathconf` returns `kHFSPlusMaxFileNameChars`
  (255) for `_PC_NAME_MAX`. A stale absent registration cannot be staged in a VM
  (k78: Launch Services deregisters at once), so candidate-order subjects are L.
- **Checks.** `task design:workspace-render` (untouched inspection SVG
  byte-identical), `task check:docs` (exit 0; mutation control on the new
  stages anchor exited 1, file restored byte-identical), `task
  design:action-repair-check` with its `design:workspace-check` dependency
  (three appended descriptions, unchanged shape, baseline control rejected) and
  `task design:search-check`, all exit 0. A closing sweep for the superseded
  phrasing found three more diagram captions, now fixed; its pattern still
  matches the historical `.grove/` notes (control).
- **One narrow in-session reviewer spent** (integrate allowance) on the claim
  that the stage order preserves every accepted short-path outcome and its
  precedence against `Selection.swift`, `OpenPath.swift`, `RevealPath.swift`,
  `NativeWorkspace.swift` and their tests.
- **In-session reviewer: seven findings, all triaged against the source.**
  (1) Real: `inspectApplication` maps only ENOENT/ENOTDIR to absence and
  ELOOP/ENAMETOOLONG to `.unreadable`, so a cycle or impossible name at an
  application location, candidate or default handler stays `failed`; only
  target paths gain `PATH_NOT_FOUND` for them. (2) Real: `selectConstrained`
  returns at the first match, so comparison stops there and a later
  unresolvable candidate is not examined. (3) Contract unclear: candidate
  metadata is no longer read; an unequal candidate with unreadable metadata is
  skipped, because the retained failure existed only for unknown equality —
  stated explicitly as a consequence of the k166-accepted device/inode choice.
  (4) Real: the final component is examined with `fstatat` from its parent and
  never opened (a mode-0600 final directory stays present, as with `stat`).
  (5) Real: the root rule is whatever `lstat` of the literal path names, which
  follows a final link for a trailing slash (`/Volumes/<link>/` is the root).
  (6) Real: reveal maps every Finder dependency, mismatch included, to
  `APPLICATION_NOT_INSTALLED` (`RevealPath.swift`). (7) Contradictions fixed:
  submission addresses the registered application with the literal target;
  default-handler lookup returns to the literal target as retained (real
  change, reverted rather than accepted); one cycle state (directory, text,
  suffix) with link identity only for change detection; open SDL limits the
  `applicationPath`; reveal SDL names Finder's location; launch SDL separates
  unconstrained absence from constrained skipping. Accepted trade-off, stated in
  the spec: a self-extending link (`a` → `a/x`) never repeats a state and is
  the budget, `failed`. Subjects added at L and N for each.
- **Second need, so review escalates to the tree.** These were substantive,
  non-mechanical fixes to a load-bearing contract after the one allowed
  reviewer. Cut `long-search-result-actions-k169` (`review-design`, **Reviews:**
  k168, **Creator:** this run) with `leaf-insert` ahead of planning k167, which
  shifted only k167; k167's context, the node brief and the root brief name
  the integration and re-review. Re-ran `design:workspace-render`,
  `check:docs`, `design:action-repair-check` (with `design:workspace-check`)
  and `design:search-check` after the fixes: all exit 0, inspection SVG still
  byte-identical.
