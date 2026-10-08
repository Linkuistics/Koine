# search-tooling-k198

**Integrates:** search-tooling-k197

## Goal

Triage the findings of `search-tooling-k197` against the tool-backed search design
from `search-tooling-k195`, then apply the real ones, so that
`search-tool-permissions-k196` puts to Antony only the choices the reviewed
mechanism actually leaves open — with their concrete alternatives — and later
search design consumes a coherent contract.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them. They are anchored to producer `ecaaf6de6fed`, whose coordinates
  equal the review's tree.
- The artifact: `docs/specs/workspace-search.md`, `docs/verification/search-tooling.md`,
  the search SDL/examples, `docs/adr/search-enumeration-reuses-system-find.md` and
  the other search ADRs, `docs/adr/filesystem-access-is-descriptor-relative.md`,
  the workflow trace's authority allocation, search rows and call-path seam,
  `scripts/check-launch-call-path.sh`, Machine's search notes, CONTEXT, the
  client guide's search section, the changed search views/README, and the root,
  k7, k19, k109 and k126 briefs plus the live k196/k191/k193/k127/k123/k120/k30/k93
  leaves that consume this design.
- Approval is unchanged. No child process, lookup-only exemption, consent,
  entitlement, usage key, setup, helper, signing or limit change, smaller domain
  or accepted workflow loss is authorized by integrating findings. Lost coverage
  goes to Antony (k196 or `protected-home-search-k93`), never silently into the
  contract.

## Done when

- Every finding is classified — a contract stated unclearly, valid and
  actionable, a visible accepted trade-off, or noise — with the reason recorded
  in this leaf's running log, and each actionable one is applied where it lives.
- The high findings are settled before k196 runs: the comparison and enumeration
  ADR weigh the in-process OS walkers with their real costs, and k196's refusal
  branch names a concrete alternative (T1); the home ordering consequence is
  stated and either resolved by a find-backed source structure or added to
  k196's choices (T2); the module/call-path and authority-allocation decision for
  spawn, signal and reap effects is made or chartered before implementation, and
  the call-path seam obligation is restored in k7/k30 (T3).
- k196's charter is updated for whatever the integration changes in its premises
  — anchor metadata contact, root spelling aliases, the materialization policy
  and ordering — without pre-answering Antony's choices.
- Downstream charters (k191 root qualification, k127 spawn attributes and
  stopping rule, k123 recognition bound, k93's two separate acceptances) carry
  the obligations the integration assigns rather than applies.
- Frozen design:search-render, design:search-check and check:docs pass on the
  changed inputs, and changed views are inspected. A substantive redesign
  beyond triage is externalized as a new design leaf with its own mandatory
  review before k196, not absorbed here.

## Notes

At most one narrow in-session reviewer. No native experiment, backend run or
implementation. The review's confirmations section lists what it re-derived as
sound; do not reopen those without new evidence.

## Decisions (running log)

- Adopt the mandated leaf in the stated jj workspace. Read findings from review
  commit `d718227b`, against producer `ecaaf6de6fed`; the working change was empty.
  The graph CLI refused an active pre-coordination/unverified generation. Exact
  document and guard-script reads supply the evidence here; no graph completeness,
  implementation or native acceptance claim is made.
- T1 — valid and actionable. The finite comparison omitted FileManager enumeration
  and libc fts, both genuine OS reuse. Add their local-error/pruning advantages and
  blocking/long-path costs to the comparison and enumeration ADR. Keep find the
  conditional recommendation; k196's concrete refusal alternative is FileManager
  enumeration with Foundation matching, requiring returned design/review and
  long-path/useful-coverage acceptance, with fts/FTS_NOCHDIR the lower-level option.
- T2 — valid and actionable. Unsorted preorder DFS plus the existing time/record
  bounds can repeatedly omit later shallow home siblings. Do not select a new source
  scheduler inside integration. k196 must choose between that explicit loss and a
  reviewed find-backed shallow pass or immediate-child source structure before
  implementation; k93 separately decides actual order/bound omissions. No loss is
  accepted here.
- T3 — valid and actionable. The whole-workspace source/binary guard forbids the
  proposed process calls. Allocate only fixed search-child spawn, owned-group
  signalling and reap to workspace:read, including admitted cleanup. Charter k127
  to settle the binary/call-path boundary with failing controls before implementation;
  preserve the accepted action guard meanwhile. Restore the obligation in k7/k30.
- T4 — valid and actionable. Exit 0 and no records cannot distinguish an empty
  directory from a non-descended file/link root. Require an in-stream depth-zero
  directory marker, separate from candidate counts, and returned k191 qualification
  for link/file/trailing-slash/replacement and withheld dataless listings. The marker
  is a command observation, not identity pinning or an atomic snapshot.
- T5 — contract stated unclearly. Prune and same-device tests can follow metadata
  contact; byte-exact path tests do not cover case/Unicode/Data aliases. Correct the
  claim that anchors see no metadata and carry these limits into k196/k191 and the
  finite signed subjects. Known local metadata measurements prove no cloud/mount case.
- T6 — valid and actionable. Specify spawn descriptor allowlisting, default
  SIGPIPE/SIGTERM, an empty signal mask and an owned new process group. k127 owns
  actual supported-SDK construction and cross-job EOF/orphan controls. Only fds 0–2
  survive exec; there is still no bound on a blocked orphan's lifetime.
- T7 — valid and actionable. The local setiopolicy_np manual documents process
  inheritance and a default OFF dataless policy; Apple's TN3150 documents OFF and
  EDEADLK handling. Do not mutate all Koine's policy under this leaf. k196 chooses
  explicit process-wide OFF versus verification/refusal of inherited policy;
  k191 specifies effective native/child policy, failure and withheld-listing coverage.
  No policy value proves absence of hydration for opaque services or cloud aliases.
- T8 — valid and actionable. URL/copy bounds alone do not bound recognition calls.
  k123 must state the directory/link/OS candidate admission filter and finite per-job
  native-call budget, including resolution and registration expansion, with ENTRY_LIMIT
  omissions and real launcher/link controls. Do not invent suffix-based identity or
  approve a reduced application domain here.
- T9 — valid and actionable. Restore a complete reason/producer/extent/coverage/status
  mapping. CHANGED_DURING_SEARCH is reserved for independently observed identity/type
  contradictions in root/target qualification, never inferred from command stderr.
  Native lookup errors can supply localized root/access reasons; find cannot.
- T10 — contract stated unclearly. Retain full processing within existing work/time
  bounds even after limit+1, so later source membership/coverage can be observed;
  result retention alone never causes a stop. k127 must preserve this rule or return
  a reviewed change. Tell clients to cancel superseded queries; cleanup may still
  hold all four slots and cause CAPACITY_LIMIT.
- T11 — valid and actionable. Scope the descriptor-relative ADR to Koine-owned
  resolution, separate from find's enumeration, and correct the Machine summary and
  k109 observation citation. Retarget k120 to the complete current design node k19
  and move it beside that producer, before k30, so the session finishing k19 supplies
  its actual Creator run. Historic k109 is not that artifact's producer.
- T12 — valid and actionable. Restore separate k93 answers for protected-policy
  omissions and time/work/native/order omissions; approval of either approves neither
  the other nor a changed backend/setup.
- T13 — contract stated unclearly. Use exact UTF-8 bytes for path merging and
  component-delimited source-prefix validation; Swift canonical String equality is
  unsuitable. Add overlapping NFC/NFD source controls; native application identity
  merging remains separate.
- T14 — valid and actionable. Remove the unshipped responsibleIdentity field and
  its example selection. accessProcess identifies the adapter; actual TCC responsibility
  stays OS/build/signing/launch-specific acceptance evidence and guidance, not a
  runtime string inferred from a prior VM.
- Apply the verified repairs in place and charter returned detail in k191/k127/k123,
  each under its existing mandatory review. Move k120 beside k19 and retarget its
  Reviews line to k19's complete closing commit; k30 follows it. No substantive new
  backend/source design, native experiment, implementation, permission, signing,
  setup, raised limit or accepted workflow loss occurs here. No in-session reviewer
  was needed. Inspect the six changed rendered views; shorten the canonical view's
  file/target edge labels after detecting a box overlap before final validation.
- Final verification: design:search-render, design:search-check and check:docs all
  exit 0 on frozen inputs. The SDL/examples validate independently and composed
  with current actions; removed-root, wrong-input/output and foreign-type controls
  are rejected. All twenty skip reasons have exactly one producer-table row; a
  deliberately removed row fails that check. The earlier one-off table check was
  corrected to bound its scan to the reason section rather than also collecting
  aggregate-status rows; no artifact correction was needed for that instrument.
  Before/after SHA-256 records cover 701 tracked non-.grove Markdown, SDL, D2,
  JSON, HTML, Python, JS/TS and YAML inputs (including Taskfile/checker/package
  sources); all remain unchanged. Generated SVGs are outputs, visually inspected
  separately. Changed task/brief links resolve, and k120's new target/placement is
  verified. No native, binary-runtime, permission or useful-coverage pass is claimed.
- Completion closes no parent node: this is a root-level leaf and other root work
  remains live. No live review names search-tooling-k198, so no Creator line is
  written. Retire this leaf and seal the focused jj change, then send the required
  dispatch exit signal as the session's last action.

## Current citation

The enumeration-record pathname and source coordinates above describe the
original producer, retained as historical comparison. Its current ownership
record is docs/adr/raw-filesystem-search-belongs-to-clients.md; k196 moves raw
filesystem search to clients and requires returned native discovery design.
