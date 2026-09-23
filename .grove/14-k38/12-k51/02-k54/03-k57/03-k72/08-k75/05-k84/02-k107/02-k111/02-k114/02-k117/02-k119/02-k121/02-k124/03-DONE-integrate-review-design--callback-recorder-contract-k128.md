# callback-recorder-contract-k128

**Integrates:** callback-recorder-contract-k127

## Goal
Triage k127's review of k125's native recorder contract. Apply the valid findings
before callback-recorder-native-k126 builds the instrument against it.

## Context
- The findings are in k127's own task file. Their line references are to k125's
  commit `ef77a75`. Read them together with that proposal, the causal transcript
  contract and `analyze.py`, and the route/exit sections of the capture assessment.
- Several findings concern whether the *specified* protocol can produce a
  transcript the unchanged analyzer accepts. Check that claim with executable
  synthetic traces, not by prose.
- The artifact is a labelled experiment contract. No native execution, product
  adoption, permission change or freshness claim follows from integration.

## Done when
- Every k127 finding is classified in the running log as one of: valid and
  applied, unclear contract settled, visible accepted trade-off, or rejected with
  a reason.
- The contract, capture assessment and recorder views agree on every applied
  change. Any causal vocabulary change is versioned, with failing controls and a
  renewed frozen control corpus.
- k126's charter names every new native obligation, control or escalation path
  the integration assigns it. Every k124/k121 criterion keeps a live owner, and
  no parent closes.

## Notes
One narrow in-session reviewer is allowed. If a finding needs the recorder to be
redesigned rather than repaired, externalise it as a new design → review chain
beside this leaf. Anything that renders or inspects the architecture viewer runs
in a disposable TestAnyware clone, never on the host.

## Decisions (running log)

- Findings read from review commit `a20fb3d5`, against producer `ef77a75`.
  Tier 2 graph discovery found analyze and Trace; exact source confirms fixed
  input cardinality and the activity reachability rule. The graph's unrelated
  HeldWindows.next edge is heuristic noise, not analyzer evidence.
- Findings 1 and 2 are valid. Selecting a trigger representation and completing
  startup/finish observation windows changes the four-role protocol, so it is
  substantial redesign under the integration procedure. Apply the consequence
  now: withhold native acceptance of the current proposal and insert
  `callback-recorder-protocol-k129` before k126, requiring a fresh tree review
  before native use. Preserve executable reproductions here; complete canonical
  traces and any vocabulary revision belong to k129. No findings are waived.
- Finding 3 is an unclear contract, settled and applied: both schedules need explicit loop coverage,
  and missing coverage withholds positive credit. Separate owned-handler reentry
  from unknown framework-private nesting without treating either as proved absent.
  A custom-mode control must acknowledge servicing, not merely return. k126 must
  surface an evidenced conflict if coverage cannot be established; k124/k121 stay
  live. This repair does not assert a native coverage mechanism exists.
- Finding 4 is an unclear contract, settled and applied: define combined outcome precedence while
  retaining both raw verifier results. Reuse the analyzer's causal graph for
  cross-role order; local audit-ledger checks do not imply a second ordering
  engine. No second engine exists yet, so that part is a prospective risk,
  not a reproduced implementation defect.
- Finding 5 is an unclear contract, settled and applied: name per-clone scripted Settings UI setup
  outside measurement, bound it, freeze it and record attribution/preflights.
  Native k126 must implement and falsify it before the matrix. Manual setup is
  not inherently irreproducible; the actual defect is unspecified, unrecorded
  preparation and cost. No consent is changed by this integration.
- Finding 6 is an unclear contract, settled and applied: preheld candidates originate in the
  supervisor's admitted kernel peer PIDs, relayed in bounded audit frames and
  joined to start PID and acquisition. No getter-derived candidate list.
- Finding 7 is valid and applied as an explicit callback-selection mutant:
  select queued B-marker/non-trigger delivery and require the audit to reject.
  Every tap delivery's marker remains recorded, with no acquisition on it.
- Finding 8 is valid and applied: reserve durable per-case clone ownership
  before creation, recover unresolved reservations before any later clone,
  bound boot/preparation separately, start execution deadline before first app
  launch, and account for supervisor launch/activation helpers with bounded waits.
  Host failure may leave a VM running until recovery; no crash-surviving watchdog
  or missing process status is inferred. These are experimental evidence records,
  not Grove session state.
- Ten minimal synthetic reproductions match the expected analyzer diagnostics:
  ordinary and after-callback baselines pass; extra trigger input and using the
  delayed-entry trigger event fail with exit 3; startup C and late B activity
  without ordering fail with exit 2. Named inputs are unchanged itemwise.
  These test the findings, not a corrected full protocol. k129 explicitly owns
  the complete schedule/source/construction matrix before native execution.
- Coverage reports generation 2026-09-23T16:32:50Z and no recorded gaps in the
  analyzer/contract evidence. Diagram sources are not tracked by the graph;
  both were read directly. This best-effort signal is not completeness proof.
- All 65 existing causal controls match, both arrival permutations agree, and
  each named before/after subject remains identical to the committed inputs.
  The new Taskfile single-trace command was verified on success and exit 3
  with --exit-code. No analyzer or causal vocabulary change was made.
- Presentation rendering and Safari inspection ran only in disposable clone
  koine-k128-view. Render exit 0, unchanged source/task maps and identical local,
  guest and served viewer/diagram subjects were verified. Both diagrams and
  discussion, captions and outline markers are readable at desktop size.
  The clone's stop succeeded and backend removal was confirmed. No native capture
  or permission-setup recipe ran; mobile/dark and full renderer dependencies are
  outside this presentation check.
- Completion check: all eight findings have a recorded disposition; the current
  contract/assessment/views carry the repairs and the withheld-acceptance rule.
  k129 carries the substantial protocol redesign and mandatory subsequent tree
  review; k126 carries every new native control/escalation alongside its original
  criteria. k124 still has k129 and k126 live, so retirement closes no parent.
  No durable product decision changed and the existing ADR set needs no rework.
