# callback-transport-evidence-k187

## Goal
Complete cross-hop publication feasibility, decisive closure and justified Trace edges.

## Context
Consume transport-lanes.md (k186), both publication proposals, k183 findings
1/2/4/6/11 and k184 dispositions. One app lane per role, one global supervisor
lane, shared auxiliary bytes and original semantic coordinates are the baseline.

## Done when
- Specify non-circular decisive closure for each directed writer and the lane;
  account for outstanding calls at end/loss and the trusted-prefix boundary.
- Define origin-hop, ingress/relay, egress and destination aggregation for every
  feasible/impossible/unverified combination, including decisive origin
  contradiction with missing broker ingress. Include supervisor-origin traffic
  and admission/table/receipt/acquisition provenance.
- Specify exactly which local/join/contributing-begin edges enter Trace for
  each status; preserve independently detectable cycles and contradictions.
  Keep local controller decisions independent from cross-role attribution.
- Extend k186 histories with both commit-only/N-1 truncated-tail discriminators,
  excluded late results, mixed-hop statuses, multiple begins/FIFO and the
  observable broker reply-ingress-before-egress-result cycle. No schedule edges.
- Reconcile both contracts, assessment and affected views; render/inspect changed
  views in a disposable clone. Preserve V1–V26 and leave executable work k182.
  Hand lifecycle/milestone requirements to k188 and final budget/review to k189.

## Notes
Design only. Use the existing Trace seam. No new public seam, permission change
or native readiness. K126 retains all native exits/containment and original
k124/k121 obligations. K177/k144 retain full sampler/protocol work.

## Decisions (running log)

- Close missing-attempt evidence only from trusted local writer replay: a
  lane end seals future begins for its owner, and terminal direction loss seals
  only that writer. Neither cancels an outstanding call's possible bytes.
  No reachability through the disputed receipt establishes its own closure.
- Compute origin supply, ingress/relay joins, egress supply and destination
  observations independently, then combine with impossible dominating unverified.
  A later claimed frame can identify an origin contradiction even when ingress
  is missing; it cannot manufacture an ingress vertex or byte-source edge.
- Build Trace edges from exact local facts and individual contributing intervals,
  before aggregate grading. Preserve supported fragments on impossible/unverified
  paths and diagnose cycles without deleting their evidence. Keep local controller
  decisions and sampler argument checks independent of cross-role attribution.
  K188 retains lifecycle/milestones, k189 final budgets/review, and k182 executable
  semantics. No new public seam, producer version or product ADR is needed.

## Verification

- Both contract sections, transport-lanes.md, the new transport-evidence.md,
  assessment and current visual discussion carry the same closure/grade/edge
  rules. The assessment maps every Done when above and k183 findings 1/2/4/6/11.
- Final checks validate 67 document links, unique complete E01–E24 enumeration,
  manifest/source references, four changed view IDs and matching hashes for six
  viewer/manifest/source assets at both serving URLs. Both pre-proposal contract
  sections match the parent commit byte for byte. The enumerated diff contains
  only documentation, diagrams, k187 presentation evidence and this task/parent
  brief; no executable or earlier fixture/report path changed. No corpus rerun
  or executable transport validation is claimed.
- Safari inspection via VNC in disposable clone koine-k187-view reached fresh
  deep links and rendered the affected views, with light and narrow dark checks.
  The discussion's relevant and changed markers agree. The clone stopped and
  was absent from the final inventory. Evidence and limits are recorded under
  docs/verification/callback-native-capture/evidence/k187/; no independent guest
  hashes, frozen browser dependencies or native recorder evidence is claimed.
- Parent k185 retains live k188/k189. Its handoff names lifecycle/milestones,
  budgets and mandatory fresh review; k182 retains executable versioning and
  full-corpus preservation/renewal. No ancestor closes on this leaf.
