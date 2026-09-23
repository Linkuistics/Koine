# native-binding-triage-k77

**Integrates:** native-binding-triage-k76

## Goal
Triage the findings of review `native-binding-triage-k76` against the triage
that `native-binding-triage-k73` produced, and apply the ones that are real,
before `window-qualified-activation-k74` consumes the experiment handoff.

## Context

Read the findings in k76's own commit. The reviewed artifact is k73's commit,
together with the current survey, the adoption synthesis, the capture ADR, the
adoption view and the k74/k75 task bodies. The review is findings only. This
leaf owns every accept or reject decision and every fix.

## Done when

- Every k76 finding is classified with its reason: a contract that was stated
  unclearly, valid and actionable, a visible trade-off, or noise.
- Accepted findings are applied where they live, whether that is the durable
  documents, the adoption view or the k74/k75 charters. Nothing in the unchanged
  contract, the declined-candidate decision, or k52's position and evidence table
  is weakened.
- A finding that needs the human is put to the human as a specific question,
  with a recommendation and its evidence. It is not settled by inference.
- The changed documents and views are verified the way k73 verified them.

## Notes

This leaf is placed before k74 so that native work starts from the reconciled
handoff. Grade the findings on their evidence, not on agreement with the
reviewer.

## Decisions (running log)

- F1 — valid and actionable. AutoTerm activates itself and closes its window
  before TAL death. A live positive cannot establish sensitivity in every
  later state. Require non-frontmost preconditions, matched no-request and
  per-transition routing positives, declared observation bounds and separate
  window-close/death ordering. Distinguish native refusal from non-observation;
  a retired PSN makes the window-validation arm inconclusive.
- F2 — contract stated unclearly, with a real whole-path dependency. The
  recorded instruction to proceed authorizes finding a lead, but does not
  expressly settle spending native effort on a partial G2 lead with G1 still
  unsupported. Restore/main/raise still depend on target handlers. Asked the
  human whether to keep constraints and resolve that conflict first, explicitly
  run the partial diagnostic, or discuss a changed support/targeting contract.
  The human chose **discuss a narrower support or targeting contract before
  further native work**. This authorizes that discussion, not a specific
  restriction or weaker guarantee. Externalize the substantial redesign as a
  design leaf before k74, with a review required once its artifact exists.
- F3 — valid and actionable. Lead 2 can address the automatic-termination
  branch of activation if inhibition covers all admitted work; the previous
  ranking understated it. AX-free restoration has conditional relevance before
  AX contact or after an unestablished release. Reconcile the comparison and
  handoff rather than automatically adding an inhibition experiment.
- F4 — valid and actionable. An implementation argument must trace validation,
  queued work, service handoffs, restoration and actual activation. A
  WindowServer-only admission argument cannot close an unknown relaunch path.
- F5 — contract stated unclearly. ModalAnyware's agreed spec reads native
  AppKit foreground state in the leader callback; the survey's original-event
  witness is a stronger interpretation. Asked the human to settle that
  distinction. Record capture-source migration separately from replacing the
  timestamp field in the Koine-side handoff; do not edit ModalAnyware here.
  The human chose **capture the frontmost application when the native callback
  executes**. Original-event targeting is not required. A delayed callback after
  an application switch captures the new foreground application; a switch after
  the callback's capture preserves that capture. Establish actual sample
  freshness and liveness ordering rather than relying on callback delivery time.
- F6 — valid and actionable. Direct source reading confirms `--exec-run`
  calls the AX transition driver; its forked target also differs from the
  Launch Services fixture. Require a new AX-free diagnostic with its own live
  identity/window controls; reuse only the target-side exec idea.
- F7 — valid and actionable. The raw pinned XNU file matches the review's
  SHA-256; `ipc_task_init` spans 172–293. The web tool's extracted rendering
  compresses blank lines and reports different line numbers. Use raw bytes for
  GitHub anchors. Restore the complete range and correct the survey's claim.

## Verification

`task design:render-process-identity` passed. Inspected the adoption PNG and
fresh Safari deep links to the adoption view and discussion panel in disposable
TestAnyware clone `koine-k77-design`, at wide light and 650-pixel dark widths.
Current/Updated markers and responsive placement remain visible. Host and guest
hashes match for `index.html`, `diagrams.json`, `process-adoption.puml` and
`process-adoption.svg`; guest HTTP delivery matches the manifest and SVG hashes.
No mobile or new native-lifetime experiment was run.

All changed Markdown files passed relative target/anchor and table-shape checks;
all manifest source/export/group/discussion references resolved. Mutated missing
path, missing anchor and changed discussion ID were rejected. Hashes of the
checked Markdown and four viewer files stayed unchanged during that check.
The later Lead 3 clarification adds plain prose only. k52's diff adds only a
client-handoff paragraph; its position and evidence-renewal table are unchanged.

Tier 2 project `Users-antony-Development-Koine`, generation
`2026-09-23T05:21:38Z`: relevant documentation/fixture paths have matching
coverage metadata with no recorded issue. The graph lookup for the transition
driver returned no symbols; coverage marks `transition-probe.m` lines 1–364
partial, so those lines were read directly. PlantUML is not tracked and SVG is
excluded; direct source and rendered inspection supply the fallback. The
ModalAnyware specification was read directly as external contract prose.
Coverage remains best effort, not a completeness claim.

After the human answered F2 and F5, reconciled the survey, synthesis, capture
ADR, glossary, machine spec, client guide, view, briefs and handoffs. Created
`native-target-contract-k78` before k74, with its concrete discussion and
required later review. It does not adopt a support restriction or weaker
guarantee. All seven findings are dispositioned; no redesign is implemented here.

Final verification: reran the render task and the Markdown/manifest checks
with the same three negative controls and stable subject hashes. k52's table
rows are byte-identical to the parent commit. Inspected the final PNG and fresh
Safari discussion/adoption deep links in `koine-k77-final`, wide light and
650-pixel dark. The four viewer-file hashes match host/guest before and after,
and HTTP manifest/SVG bytes match. Both disposable verification clones were
stopped. No native-lifetime or mobile result is claimed. Coverage for the added
contract/glossary/client-guide paths and k78 reports matching metadata and no
recorded issue at generation `2026-09-23T05:35:28Z`.

k72 still has live k78/k74/k75 work, so no parent closes or promotion cascade
is due. Its ancestors retain their original completion obligations until an
explicit agreement changes them. Retiring k77 authorizes neither implementation
nor a first release.
