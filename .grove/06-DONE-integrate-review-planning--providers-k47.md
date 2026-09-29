# providers-k47

**Integrates:** providers-k46

## Goal

Triage `providers-k46`'s review of the provider-work decomposition and apply
the real findings before `provider-architecture-k5` begins.

## Context

- Read the findings from `providers-k46`'s own commit. Its coordinates name
  the reviewed planning commit; resolve the stable handles for current paths.
- `providers-k3` is the planning producer. The agreed requirements and
  `plan-k4`'s integrated decisions govern the scope.

## Done when

Each finding is classified as a contract stated unclearly, valid and
actionable, a visible trade-off, or noise. Apply justified changes to the
planned subtree and its root coverage/decomposition, keeping their charters
consistent with the agreed requirements. Record the reasoning for findings
that are not applied. Complete the verification appropriate to those edits.

## Notes

This is planning integration, not provider design or implementation. Preserve
the human's agreed baseline and existing native limits. Do not treat the
reviewer's proposed remedies as a preapproved work list; assess the evidence
and choose the smallest coherent correction.

## Decisions (running log)

Findings read from `providers-k46`'s commit `d5933ccb`, anchored to planning
commit `95f41cd6`. The only intervening change is that commit's renumber
(`07-k6`→`08-k6` and so on); every cited line was re-read at its current path
and still says what the review quotes. No finding is noise.

**R1 — valid and actionable (the artifact).** `app-input` hands a
menu-invocation row to `menu-bar`, but neither `menu-bar`'s node nor
`menu-bar-k36` takes such a row as input or owns its outcome. Meanwhile
`app-input`'s own acceptance bullet still names every row for those apps. A row
whose item needs explicit opening can only be delivered by `context-menus`,
because `menu-bar` does not open menus. `app-input-k34` also sends "unverified"
rows to `account-acceptance`, which covers only the five account apps. The
unverified rows the requirements name are the Signal and Messages chords,
which are account rows anyway. The fix chains the handoff forward in the
order the evidence arrives. `app-input` closes on its keystroke rows and passes
menu rows to `menu-bar`. `menu-bar` accepts them, or passes a row needing
opening on to `context-menus`. Only account-dependent rows wait for
`account-acceptance`. `app-input` cannot decide at design time that a row needs
opening, because menu evidence arrives in the later `menu-bar` node, so
`menu-bar` makes that call. The root coverage rows carry the owners.

**R2 — valid and actionable (the artifact).** `baseline-acceptance-k17`'s goal
lets "listed as pending" close the baseline, while its `Done when` requires
every row demonstrated. The requirements say an untested limitation does not
pass. As written, the account node closes with pending cases and
`baseline-acceptance` then closes the baseline around them, so a pending case
could end the grove. The fix keeps the agreed late provisioning and the rule
that pending is not passed. The account node may close with cases recorded
pending. `baseline-acceptance` keeps each one as identifiable live work (a
leaf naming the account or data it needs), makes public status name it pending,
and treats dropping it as Antony's scope decision. That work is not queued
inside the account node, where it would block the AFK consolidation behind a
human-supplied account.

**R3 — valid and actionable (a contract stated unclearly).** `app-input`'s
first `Done when` promises that input never reaches a newly foreground
application. Its own evidence leaf allows the check-to-delivery race to be a
stated limit. The requirements (`:64-67`) and the spec's accepted-limits table
(`machine.md`: "a check-then-use race can … act on it") refuse to promise
more. The node now promises addressing, no deliberate retargeting, refusal of
a known mismatch, and the residual race as the limit its evidence establishes.
A limit that would reduce the baseline escalates to Antony. `app-input-k34`
states the race in its design. The same class appears in `held-interactions`,
which sends its keystrokes through `app-input`'s delivery. The requirement's
no-Escape rule stays unchanged, and one note there says the delivery limit
carries over and that weakening that rule is Antony's decision.

**No in-session reviewer.** The edits are charter wording whose consistency
is checked by reading the handoff chain end to end. There is no unexpected
claim that the compiler or tree verbs cannot check.
