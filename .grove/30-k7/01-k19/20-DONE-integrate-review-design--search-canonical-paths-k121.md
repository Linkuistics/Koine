# search-canonical-paths-k121

**Integrates:** search-canonical-paths-k110

## Goal

Triage the findings of `search-canonical-paths-k110` against the fsgetpath
canonical-directory design from `search-canonical-paths-k108`, then apply the
real ones. Planning must start from a canonical-path, size-refusal,
link-resolution and subject contract it can build and accept, without
rediscovering these defects in the adapter.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them.
  - They are anchored to the current tree at the review's commit. The k108
    sections there are byte-identical to producer `2e41af85d44f`, shifted by
    +27 lines (canonical observation) and +582 lines (subjects).
  - Some evidence comes from reading the SDK headers, the man pages and xnu
    `main` sources, plus one read-only host `stat` labelled as not guest
    evidence. None of it is native acceptance.
- The artifact:
  - `docs/specs/workspace-search.md`, including k119's in-process call
    contract, which the review found shares text with k108's rules;
  - `docs/verification/search-canonical-paths.md`;
  - both search ADRs and the traversal ADR;
  - the search SDL and examples, the search terms in `CONTEXT.md`, and the
    client guide's search section;
  - the workflow trace rows;
  - the canonical, traversal, coverage and handoff views with their exports,
    captions, manifest and README;
  - the brief chain.
- Keep k103's transport, outcome, lifecycle and compatibility meanings.
- Keep k104's canonical-parent policy checks, unified spelling, witness
  accounting and worker ownership, and k107's turn-before-read checks,
  changed-prefix root remainder and target-only exact exceptions. Depart from
  one only where a finding shows that it does not hold.
- Approval is unchanged. None of the following is authorized: a new consent,
  entitlement, usage key, setup, long-path iopolicy or private API; a raised
  limit; a smaller domain; a shorter public value ceiling; an incompatible
  version.
- Any lost workflow coverage goes to Antony through `protected-home-search-k93`,
  not into the design as accepted.

## Done when

- Classify every finding as one of:
  - a contract stated unclearly;
  - valid and actionable;
  - a visible trade-off;
  - noise.

  Record the verdict and reason in the running log, and apply the actionable
  repairs in place across every affected durable artifact and summary.
- Escalate before relying on any change that alters workflow coverage, approval
  posture or k119's selected call set.
- Regenerate the changed views, and run `task design:search-render`,
  `task design:search-check` and `task check:docs` on frozen inputs.
- A repair may amount to a substantive redesign, such as a new classification
  route or a resolver specification. If so, externalize it as a design producer
  that cuts its own load-bearing review, rather than absorbing it here.
- The complete-resource review `search-native-resources-k120` follows this leaf.
  Any shared k119 text this integration changes must be reconciled before it
  runs.
- Planning `app-and-file-search-k30` still waits on this integration, k120 and
  any chains they earn.

## Notes

This is design triage only: no implementation and no native evidence chain.
All native, binary, prompt and useful-coverage acceptance remains pending.

## Decisions (running log)

- Bootstrap adopts the mandated jj leaf on empty `kyvvklzu`, parent
  `b9a5d6401257a8b3f66973330edfdc065fbf3440`. Findings were read from that
  review commit, then checked against the unchanged current artifact. The graph
  CLI refuses to start while a pre-coordination/unverified generation is active;
  no graph result or completeness claim is used. Relevant documents were read
  directly. Apple's public fsgetpath manual and vnode path-builder source were
  checked as explanatory sources, not as guest/native acceptance.
- C1 — **valid and actionable**. The prohibition on long full-path attribute
  calls contradicts the selected URL/Bundle classification route. The queue
  fixture cannot be called constructible before classification is resolved.
  Changing k119's call set or accepting a lost length band exceeds this leaf:
  externalize classification and its re-derived subjects to a design producer
  with mandatory review. No alternate call or coverage loss is adopted here.
- C2 — **valid and actionable** as an unsupported spelling invariant, not a
  reproduced APFS outcome. Apple's path builder uses vnode cached names; the
  sources do not prove equality with the listed parent/name join. Byte mismatch
  alone therefore cannot certify movement or native-size impossibility. A
  producer must settle spelling, change evidence and alternate-cache subjects;
  do not silently introduce a canonical fallback in this integration.
- C3 — **valid and actionable**. Shared-prefix/current-parent failure stops one
  root; final-target failure beneath an established unchanged parent is exact
  SUBTREE, and checked-link failure stays per-candidate ENTRY. Rechecks choose
  scope on both success and non-resource error, including ENOSPC. Restore this
  existing distinction without retroactively omitting a finalized name.
- C4 — **valid and actionable**. Witness-account overflow is job-wide; native
  failure of an optional/special-region witness is not. State witness dependencies
  by search kind and admission/policy role; refuse only roots whose required
  policy/admission proof depends on a failed witness. File search does not inspect
  CoreServices/Cryptex/Preboot solely for application admission.
- C5 — **valid and actionable**. The NUL-inclusive syscall limit does not itself
  remove a publicly representable 8,192-byte directory/package name, especially
  when no descent is required. Its location and descent scope depend on C2's
  spelling decision, so externalize that design with C2/C7/C8. Withdraw the
  unsupported pre-enqueue native-size proof; public value overflow stays exact.
- C6 — **a contract stated unclearly**, with actionable overclaims. Holding the
  descriptor prevents its ordinary inode reuse; repeated fstat/fstatfs does not
  detect its movement or supply a generation token. Parent association and
  independently established location checks can expose change. First root,
  witness and unassociated link-target observations have no independent movement
  detector. Name those limits and separate injected branches from native
  after-close replacement subjects; same-identity spelling is C2's open design.
- C7 — **valid and actionable**. Hop/readlink/expanded-work bounds, absolute
  restarts, dot-dot/firmlink semantics and error scopes are absent. Specifying a
  resolver is substantial design work: externalize it with spelling and policy,
  and require a load-bearing review before the resource review/planning.
- C8 — **valid and actionable**. A pre-open parent check does not classify a
  case/normalization-variant child before opening it. Existing metadata evidence
  does not establish that opening/fsgetpath is prompt-free. The resolver producer
  must settle pre-open child policy and dialog-witnessed variant subjects under
  the unchanged posture; no new prompt-bearing route is approved here.
- C9 — **valid and actionable**. Keep native bundle identity and one public
  presentation/no-fallback naming decision in the ADR; private call mechanics
  and review/acceptance sequencing belong in the spec and tree.
- Applied bounded C3/C4/C6/C9 repairs in the spec, call analysis, application/
  coverage ADRs and affected glossary/guide/SDL/examples/trace/views/briefs.
  Removed the unsupported native-size join proof and same-identity-byte movement
  inference without selecting an unreviewed replacement. C1/C2/C5/C7/C8 remain
  explicit producer-owned design dependencies; k119's selected call set,
  authority/transport/lifecycle/compatibility and approval posture are unchanged.
- Final frozen-input `task design:search-render`, `task design:search-check` and
  `task check:docs` exit 0. All eight SVGs parse. Per-file SHA-256 comparison
  confirms each of 191 VCS-listed source inputs (all .md/.graphql/.d2/.json
  outside .grove, Taskfile.yml, scripts/check-doc-links.py, viewer index.html and
  client package inputs) unchanged through the final run; all eight search SVG
  export digests match individually. Temporary manifests are
  `/tmp/koine-k121-final-inputs.json` and
  `/tmp/koine-k121-exports-before-checks.json`. The GraphQL AST comparison against
  the review parent, excluding descriptions/locations, confirms unchanged SDL
  and example shapes. An initial supplemental comparison used a client-relative
  jj path; its corrected repository-root read passed. No browser/native/binary/
  consent/useful-coverage acceptance is claimed.
- Externalized substantive redesign beside this leaf as
  `search-path-resolution-k122` (C2/C5/C7/C8) then
  `search-path-classification-k123` (C1/re-derived end-to-end subjects), both
  inserted ahead of k120. Each charter requires its own load-bearing review
  before the next consumer and escalation before changed calls/coverage/posture
  become a dependency. K120's context now consumes these reconciled chains;
  k30 and k93 obligations remain live. No in-session reviewer was spent.
