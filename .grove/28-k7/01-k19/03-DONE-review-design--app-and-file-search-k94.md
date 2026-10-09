# app-and-file-search-k94

**Reviews:** app-and-file-search-k92

## Goal

Read the committed search design adversarially before implementation planning.
Challenge whether the public API, coverage, authority, scoped failure mapping
and native ownership contract can be implemented without contradicting the
accepted workflows, platform evidence or existing action/provider contracts.

## Context

- Producer commit named `app-and-file-search-k92`; inspect its complete diff.
- `docs/specs/workspace-search.md`, additive SDL and example operations in
  `docs/design/workspace-search-{schema,operations}.graphql`.
- Architecture viewer: current discussion, search coverage and search handoff
  sources/exports; the discovery and metadata views are evidence context.
- `docs/verification/search-discovery.md` and
  `docs/verification/protected-path-metadata.md`: bounded signed-host results,
  not acceptance of the new descriptor-relative adapter or arbitrary traversal.
- Workflow trace, Machine error/ABI contract, launch/open spec and unchanged
  action SDL; authority and first-party selection ADRs.
- `protected-home-search-k93`, `protected-default-open-k89` and
  `reveal-app-bundle-notice-k90` retain their distinct pending human decisions.

## Done when

The inspection-only findings identify concrete contradictions or missing
obligations with exact artifact/source coordinates and their consequences.
Try counterexamples involving complete versus partial empty results; mixed and
all-blocked roots; scope/value exhaustion; cancellation, blocked workers and
late completion; protected aliases, mount changes and unrepresentable names;
application identity/unknown metadata; and selection followed by replacement.
Assess the feature-gated minor-2 nil-consent mapping against current framework
constructors, publication errors and old-host refusal. Check every nested
read field, both-control action handoffs, unchanged action-only profiles,
independent composition and the three existing acceptance seams. Judge whether
the current spec/ADR set carries the durable decisions coherently. Record no
runtime/native guarantee on the strength of SDL or presentation checks.

## Notes

No in-session reviewer ran in the producer. `task design:search-check` and
`task design:workspace-check` passed their positive and negative schema controls;
they do not establish runtime branch invariants. Safari presentation checks
cover readable deep links, starts/branches and narrow discussion reflow.
Parent Tier-2 graph coverage used generation 2026-09-29T10:36:20Z; docs are
excluded, workspace-provider paths were untracked, and core files had changed
metadata/Engine's line-295 parse gap. The producer read current source directly
for those paths/ranges. Confirm current project/generation and coverage rather
than treating that earlier graph as fresh native/framework evidence.
Do not fix artifacts in this review. If actionable findings earn integration,
cut the next `integrate-review-design` at the review's sequencing boundary.

## Decisions (running log)

Reviewed producer commit `e6f5f16c7980` (`app-and-file-search-k92`), complete
diff. The working copy began as an empty change on it, so there was no drift to
reconcile. Findings only: no spec, SDL, ADR, diagram, Taskfile or code edits, and
no test, build, render, schema-check, conformance or VM command.

The graph is still generation 2026-09-29T10:36:20Z. `ProviderContribution`,
`Engine` (line-295 parse gap), `Authority` changed after it; `ConformanceProfile`
and the workspace provider are untracked. Every source claim below comes from
reading current source directly: `Resolution.swift`, `ProviderDescriptor.swift`,
`ProviderContribution.swift`, `Engine.swift`, `Authority.swift`,
`ConformanceProfile.swift`, the workspace manifest/descriptor and Modaliser's
`AppScanner.swift`. Platform facts come from read-only inspection of this Mac
(macOS 26.6.2 25G83): `ls -l`, `stat`, `mdfind` for application bundles, and
bounded names-only `find` counts. Nothing here is native acceptance of the
designed adapter.

These held under the requested counterexamples, so they are not findings:

- root canonicalization beneath protected roots: k73 measured `lstat`, `stat`
  and `realpath` inside Desktop/Documents/Downloads as prompt-free;
- mount change and classification uncertainty, which block descent;
- late completion after the frozen snapshot;
- selection followed by replacement, which keeps the action contract's
  revalidation and promises no identity;
- the nested `matches` refusal, since a nested resolver receives its parent
  value unchanged (`machine.md:928`);
- read-only registration of every new output type, with no type shared with
  control-only action outputs;
- independent composition under the `Workspace` prefix;
- the both-control handoff inputs, apart from S2.

S1, S2, S9 and S10 change what application/file search returns for the
configured workflows. S1 may need Antony's decision, because the agreed
baseline does not license a bounded sample. S3, S5 and S6 change what the
framework and conformance work in planning would build. An
`integrate-review-design` leaf is warranted before `app-and-file-search-k30`.
No sibling after this review holds live work, so it is appended to this node.

## Findings

Coordinates are at the producer commit; the working copy is identical. `spec` is
`docs/specs/workspace-search.md`, `SDL` is `docs/design/workspace-search-schema.graphql`,
`action SDL` is `docs/design/workspace-schema.graphql`, `launch` is
`docs/specs/workspace-launch-and-open.md`, `machine.md` and `workflow-providers.md`
are under `docs/specs/`, `evidence` is `docs/verification/search-discovery.md`.

### S1 — The bounds turn default searches into order-dependent samples on a real Mac (high)

Every listed directory costs one `searched` record, because searched scopes are only
`DIRECT_CHILDREN`/`PARTIAL_CHILDREN` (spec:133-137, SDL:20-25). Every
hidden, package or symlink entry costs a `skipped` record (spec:90-93, 141). There are
**512 records per root field across all roots** (spec:270-272). Traversal is DFS
in native order (spec:266-268, 304-315). Unvisited roots receive only their
reserved `DIAGNOSTIC_LIMIT` fallback (spec:276-280).

On this Mac (`find`-based counts; package detection by extension is
approximate), `/Applications` alone holds about 2,996 non-hidden, non-package
directories, plus 227 packages, 72 hidden entries and 4 symlinks. That is
roughly 3,300 records against 512. So the **default application search** exhausts
its budget inside an arbitrary DFS slice of `/Applications`. `/System/Applications`
is the second default root (spec:68-70), holding Mail, Calendar, Notes and the rest
of the 65 system apps, and it is never examined. For files,
`~/Development` alone has 910 visible directories and 302 hidden entries
within depth 3. The default home search therefore examines a few hundred
directories in hash order.

Coverage reports this honestly as PARTIAL/`DIAGNOSTIC_LIMIT`. But "find installed
applications" and "find files under … the home directory"
(requirements:106-107) become effectively random subsets. Modaliser's
intended result is every application bundle Spotlight knows
(`AppScanner.swift:16-20`). The acceptance seam cannot detect this. The VM
installs only the required apps (spec:377), and k91 measured one level of two
nearly empty roots (evidence:31-32, 60-64). The design never quantifies expected
coverage against a real installation. `protected-home-search-k93` puts only
the *protected-scope* partiality to Antony, not this bound-driven partiality.

### S2 — Safari and Finder are unreachable by default application search, with COMPLETE coverage (high)

On macOS 26.6.2, `/Applications/Safari.app` is a symlink to
`../System/Cryptexes/App/System/Applications/Safari.app`. Finder is
`/System/Library/CoreServices/Finder.app`. `mdfind` returns both. The design
excludes descendants of symlinks and inspects no symlink target (spec:90-93,
247-248). An application candidate must be a bundle whose own native identity
is registered (spec:230-231). None of the default roots contains Finder
(spec:68-70). The k91 probe reported Koine as the only candidate in
`/Applications` (evidence:32), which is consistent with skipping the symlink.

A symlink exclusion is intrinsic (`affectsCoverage: false`, spec:145-147). So a
query for "Safari" on a small installation, such as the acceptance VM, returns
AVAILABLE, an empty list and COMPLETE `/Applications` coverage. That is a false
complete-empty, which the node brief forbids. The action contract already
accepts the symlink spelling by native identity after resolution
(action SDL:9, launch:365). Search's no-target-inspection rule withholds an
input the launch route would accept. Safari and Finder are configured
applications (root brief coverage table).

### S3 — The minor-2 mapping changes a fixed version-1 meaning and leaves most combinations undefined (high)

`ProviderFailure.Kind.osPermission` means "Koine lacks the platform consent
named by `permission`" (`Resolution.swift:58-59`; machine.md:929). Version-1
meanings are fixed (machine.md:922). The design reuses that case with nil
`permission` to mean "a known prompting operation was not attempted; consent
state unknown" (spec:186-190, 207-209), which is a new meaning on a fixed case.

The nil combination is also already constructible by every existing provider:
`init(kind:message:)` is public and `permission` is a public `var`
(`Resolution.swift:74-79`). Today's host maps it to `osPermission: ""`
(`ProviderContribution.swift:164-167`). The spec keeps that mapping for old
registrations (spec:211-213). machine.md:557-560 says the absent/malformed
combination is *not* mapped to an empty consent string. The two disagree on
the undeclared-provider nil case.

The spec defines exactly one combination of the new accessors: nil
permission, nonblank target, `prompt-risk`, feature declared. It leaves
undefined:

- a named consent with a target, which machine.md:536-541 already promises for
  later increments' consent diagnostics;
- a named consent with a reason;
- a target without a reason;
- reason values other than `prompt-risk`;
- `failed`/`unavailable` carrying either accessor.

"Malformed" is therefore unspecified, and the host validation cannot be written
from the spec. Because the accessors are permanent major-1 ABI, a narrow
definition now forces a second feature onto the app-input/menu consent work.

### S4 — No-progress mixtures of prompt risk with absent or excluded roots become `failed` (medium)

FAILED includes "a mixture of prompt risk with other blocked/failing roots"
(spec:163; `search-coverage.d2:13`). The outcomes are then non-monotone:
`[~/Desktop]` is BLOCKED (`permission`), `[/Volumes/USB]` or `[~/Dropbox]` is
DEPENDENCY_UNAVAILABLE, but `[~/Desktop, /Volumes/USB]`, `[~/Desktop, ~/Dropbox]`
and `[~/Desktop, /missing]` raise `failed`. Yet no OS operation failed, timed
out or returned malformed output, which is `failed`'s whole classification
(machine.md:598). Consent-related scope is never a dependency
(workflow-providers.md:321). A client shows "search failed" and may retry
forever. The precedence among BLOCKED, DEPENDENCY_UNAVAILABLE and FAILED needs
a rule that does not invent a native failure.

### S5 — The durable error/ABI choice has no ADR and no weighed alternative (medium)

k92's running log says no ADR is earned. The prompt-risk refusal is permanent
framework ABI, and it is an `os-permission` error without the consent
identifier machine.md:525-529 says OS errors carry. It also had a real
alternative. A schema-level BLOCKED status with null matches and coverage
permission objects needs no `ProviderFailure` change, the pattern machine.md:617
already adopts for dependency results. That alternative would require
amending workflow-providers.md:310, whose premise ("if consent blocks every
requested scope") assumed an *observed* consent block, not a prompt-risk policy
with unknown consent. So the decision passes all three tests in
`ADR-FORMAT.md`. The current set records neither the choice nor what it
rejected, so the integrator cannot weigh S3's cost against that route.

### S6 — "Retain the action-only profile unedited" has no subject, and the specs disagree (medium)

Profiles pin the exact design SDL and every candidate's version and selection
(`ConformanceProfile.swift:3-13`). The workspace profile is the complete action
design verbatim at workspace `1.0.0`/`1.0.0` (launch:712-721). Once the bundled
provider serves search with a new schema minor (spec:220-223), that profile
cannot match the shipped host on either SDL or pins. spec:376 says to retain it
and not edit its expected SDL, but names no host that would satisfy it, such as
a fixture host bundling workspace 1.0.0. The producer's own launch:25-28 says
implementation instead "extends the exact workspace conformance profile".
Planning gets contradictory instructions.

### S7 — The scope vocabulary cannot state per-directory exclusions without one record each or an overclaim (medium)

A skipped record has one `path` and an extent of `DIRECT_CHILDREN`,
`PARTIAL_CHILDREN` or `SUBTREE` (SDL:20-25, 77-87). Coalescing applies only
"where their scope is the same" (spec:278-279), which two hidden entries never
share. So every `.DS_Store`, `.git` or bundle needs its own record, driving S1.
The alternative is a parent-path record that claims all children were skipped.
`UNREPRESENTABLE_NAME` is recorded "at its representable parent scope"
(spec:342-346), and every available extent then misstates what was omitted.
Implementers must invent the semantics, and the GraphQL seam has no expected
value to test against.

### S8 — Value-budget arbitration between matches and required diagnostics is undefined (medium-low)

The 512 KiB budget covers matches and diagnostics together (spec:270-275). When
retained matches fill it, the next required searched-scope record either
evicts matches (`resultsTruncated`, spec:264-267) or stops traversal
(`VALUE_LIMIT`, spec:278-280). Both readings are licensed. The same input
yields a truncated-but-complete or an untruncated-but-partial answer depending
on the implementer. The per-match `defaultHandlerGuidance` string is constant
but charged for every match.

### S9 — An absent `~/Applications` default makes complete default app search unreachable (medium-low)

The home `Applications` default is "reported, not dropped" (spec:72-74). A
missing root is `ROOT_NOT_FOUND`, which affects coverage, and with no progress
the root is UNKNOWN (spec:145-149). Clients must check every coverage object
before calling an empty list complete (spec:160). On any Mac without
`~/Applications`, which includes the likely VM golden, the default application
search can never report a complete empty result for "no such app".

### S10 — Positively unregistered bundles vanish without a diagnostic (low-medium)

Unregistered bundles are omitted (spec:233-234), and no skip reason exists for
them, so the root can still read COMPLETE (spec:141). Launch Services registers
a newly copied app asynchronously, so a search right after installation reports
a complete-empty miss. Meanwhile identifier-less bundles appear as UNKNOWN for
reveal/path-copy (spec:234-236), and those two actions are also valid for an
unregistered bundle (requirements:106). The evidence asked for explicit
coverage/unknown outcomes for apps installed elsewhere (evidence:66-67).

### S11 — A permanently blocked worker set has no stated recovery (low-medium)

A job is counted until its native work finishes, cleanup never waits, and
capacity refusal fails before work (spec:288-291, 304-309). A metadata call
that never returns, such as the file-provider servicing spec:113-115 admits,
eventually exhausts all four workers. Every search then fails with
`CAPACITY_LIMIT` until… nothing stated. Whether a provider stop/restart gets a
fresh pool, leaking the blocked threads and descriptors, or stays exhausted is
unspecified. The acceptance row's "worker-capacity recovery" (spec:377)
presumes the jobs finish. One operation that aliases the root four times also
occupies every worker against other read clients.

### S12 — Application ranking makes the exact tier unreachable; Unicode matching is permissive (low)

Names include the extension (spec:57-58) and rank by exact, prefix, then
substring, with ties by folded name in scalar order (spec:260-262). "zed"
therefore never exactly matches `Zed.app`. `Zed Preview.app` outranks it
because U+0020 sorts before U+002E. "Canonically equivalent spelling *may* match"
(spec:62) leaves the G seam's "Unicode/literal matching" case without an
expected answer.

### S13 — New load-bearing vocabulary is not in the glossary (low)

The design relies on coverage (COMPLETE/PARTIAL/UNKNOWN), *progress*, *prompt
risk*, *search domain* and *location* (as distinct from a resource reference).
`CONTEXT.md` has none of them, although later increments and the baseline
acceptance trace will cite them.
