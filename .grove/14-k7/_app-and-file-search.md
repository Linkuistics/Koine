# app-and-file-search-k7 — brief

## Goal

A client can find installed applications, and files under configured roots,
and act on a selection. Application actions are launch or activate, reveal in
Finder, copy path and copy bundle identifier. File actions are open with the
default application, reveal, copy path and open in Zed.

## Done when

- Installed-application search returns the metadata these choices need.
  File search covers client-specified roots, currently the home directory.
  Results are bounded and ordering is stated; MRU ordering stays client-owned.
- An unavailable search mechanism, such as a disabled or missing index, is
  distinguishable from an empty result. Search reaches protected folders only
  as far as Koine's documented permissions allow, and says so.
- Every requested root has explicit complete/partial/unknown coverage, searched
  and skipped scopes and reasons. Partial empty is not complete empty;
  permission-blocked scope retains OS-permission classification, while a missing
  index is a dependency. First access to protected scope must not prompt through
  a read. Define the new consent diagnostics without changing desktop fields;
  raise any new consent/entitlement with Antony before relying on it.
- Selections act through `launch-and-open`'s operations. Clipboard writes
  follow `provider-architecture`'s allocation.
- Authority, trace rows and VM acceptance as in `launch-and-open`.

## Decomposition

1. `design` — the mechanism, with a bounded VM evidence check, and the API.
2. `planning` — cut implementation leaves.

## Notes

The search design is `docs/specs/workspace-search.md`, with the separate additive
`docs/design/workspace-search-schema.graphql` and client examples beside it.
Every search root/output field needs workspace read only; existing action
receipts keep both controls. Planning consumes the design reviews and producer decisions before cutting
implementation. The revised discovery contract has fixed-region Preboot admission
without read-only dependence, per-root FIFO breadth-first work with cyclic
64-entry/32-transition turns, one current stream/root and a 512-task/384 KiB
pending queue. Separate reserved depth/frontier groups count observed matchable
anchors; frontier overflow omits descent while sibling names continue. Canonical
target names/paths and native bundle identity keep route-independent ranking.
`search-traversal-k105` supplies atomic process-wide worker/descriptor admission:
roots + 2 credits/job from min(72, max(0, soft RLIMIT_NOFILE − 128)), no limit
change. Four maximum-root jobs hold at most 72 owned credits. Its review integration and the k108/k109 native producers/reviews must retire before planning. Normally launched host
listener/store/action serviceability, opaque metadata opens, real Safari/Finder,
protected Library-link calls and useful home coverage remain pending. Invalid/overlong children keep actual-parent groups; depth uses one root
group with matchable anchors. Stops use REMAINDER with or without progress.
Prompt-risk transport is reviewed typed BLOCKED success/null data, with k103's
changed/uncertain-root precedence, lifecycle-error exemptions and explicit
verification-consumer migration. Search 1.1.0 declares both authority/selection
features; current search checks/newer fixtures and retained action-only subjects
stay separate, with binary/runtime acceptance pending.
k104's worker-only cleanup, fresh parent-location checks, unified canonical
paths, charged policy witnesses and unknown Preboot failure wording remain.
FIFO queued tasks use fresh checked component walks and retain path/identity
charges across freeze; job credits release only after worker cleanup. Bound-driven
omissions are explicit, not accepted workflow weakening. Fixed framework meanings stay unchanged and no diagnostic
ABI addition is needed.
Preserve action-only conformance against
an independently retained workspace 1.0.0 compatibility host while adding a
separate exact search-required profile for the upgraded host.
`protected-home-search-k93` keeps Antony's partial-home versus explicit-setup
decision live before baseline acceptance, including eventual bound-driven
omissions; arbitrary bounded samples have not been accepted. Default opening and app reveal keep
their existing separate decisions. The mechanism report does not accept the
new stream adapter, arbitrary protected traversal or unsupported volumes.

This extension deliberately lifts the desktop contract's exclusions of
non-running applications and broad discovery for these workflows only.
`provider-architecture` records the reconciliation this node relies on.


k107's integration repairs listing-turn revalidation, shared changed-prefix
scope, repeated-walk costs, measured-shape/same-level loss subjects, cohort
guidance and the summed-reservation lowered-limit predicate. Current streams
check before the next read even in file-only listings; only target change under
an established unchanged parent has an exact SUBTREE exception. The public
coverage and traversal ADRs are separate; descriptor/cleanup mechanics stay
private in the spec. search-canonical-paths-k108 must settle actual canonical
calls and native size/group/queue subjects. search-native-resources-k109 must
settle opaque success/error signals and an instrument for transient descriptor
events plus suppressed listener accept/backoff. Both producers require mandatory
load-bearing reviews before k30 planning. Errorless empty/nil, periodic counts
or eventual replies do not clear them. Native/binary/useful-coverage acceptance
and k93's actual omissions decision remain pending.

k110/k121's canonical review/integration keeps the public fsgetpath proposal
with a fixed NUL-inclusive 8,192-byte buffer and unchanged public ceilings/domain.
It repairs target/link versus shared-prefix scopes, dependency-scoped native
witness failures versus job-wide account overflow, and held-descriptor detector
claims. ENOSPC alone is not change; native descent refusal alone does not omit a
representable directory name. Resolver/pre-open child policy, cached spelling,
size-name finalization and long-path classification require new producers/reviews
before k120/k30. Native 79/80 arithmetic is conditional on classified canonical
tasks, separate from synthetic 43/44 values. All native/binary/no-dialog/useful
coverage and k93's per-witness omissions decision remain pending.

`search-path-resolution-k122` and `search-path-classification-k123` are the
ordered continuations from k121. Their producers cut mandatory reviews before
the next consumer; k120 and k30 wait on both chains and earned integrations.

k118 independently selects the durable
[observation boundaries](../../docs/specs/workspace-search.md#observation-boundary-decision-questions)
under Antony's "you decide" delegation. These scoped fact/evidence choices
do not claim native acceptance, compatibility or k93's measured omissions
decision. k119 finalizes allocation/copy bounds/two-temporary freeze/recovery; k113
completes instrument/subject construction. Mandatory complete-resource review
search-native-resources-k120 remains live before planning; native acceptance
and k93's measured omissions decision remain pending.
