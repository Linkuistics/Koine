# Koine language

Terms shared with ModalAnyware's glossary. ModalAnyware's documents say
"Machine server" where this project says Koine. Where the two glossaries
differ, this one governs and ModalAnyware's follows.

## Language

**Koine**: This project: the **Machine server**.
_Avoid_: MachineWare

**Machine abstraction**: The view of applications and the desktop as a lazy
graph of queryable state and executable commands, supplied by **providers**
and served by the **Machine server**.

**Machine package**: The independent Swift package containing the generic
mechanism and provider contracts behind the **Machine abstraction**. It is
the core of the **Machine server** and has no dependency on macOS, on a
concrete application or on any client. It uses the **provider framework** for
the native provider contract; the term does not prescribe the inherited
query/execute payload.

**Machine server**: The separate resident application that exposes the **Machine
abstraction** through a fully introspectable GraphQL API with a capability
model, hosts native **providers**, holds the OS permissions for their
operations. Its native management UI and **providers** run in the same process.
No project includes the server; ModalAnyware is one of its
**clients**.

**Client**: A program that reaches the **Machine server** over its transport
with a capability of its own: ModalAnyware through its Machine client module,
a third-party application, a script or an LLM agent.

**Capability**: Authority granted by Koine to a **client** to use approved
Koine functionality. It governs the client's access to the **Machine
server**; the server holds the OS permissions needed for **provider**
operations.

**Grant**: A persistent authorization for a **client** to exercise a set of
Koine **capabilities**. A grant remains valid across restarts until explicitly
revoked.

**Bearer credential**: An opaque secret whose possession lets a **client**
exercise one **grant**. The client stores it in Keychain or a protected file;
Koine checks the live grant on every request. Copying the secret transfers its
authority, and explicit revocation ends that authority.

**Contract version**: The name of the public GraphQL contract a Koine serves
and a **client** targets, `koine-desktop/1`, separate from Koine's release
version and from provider framework versions. It changes only for an
incompatible contract change.

**Schema digest**: `Koine.schemaDigest`, an equality token over the complete
schema one Koine serves. A **client** records the digest it was generated
against and compares it, to learn when to introspect again; it moves for changes
that do not change the **contract version**, such as a description or an
installed provider.
_Avoid_: schema version

**Provider**: A native Swift **Machine server** plugin contributing an
application's or the desktop's GraphQL schema and the implementation of its
state and commands; the desktop provider is bundled with Koine. Providers and the
server binaries can be upgraded independently through the **provider framework**
where the host's loading policy admits the provider identity. Replacing a shipped
provider requires a selection-aware host; Koine 0.1.0 refuses external desktop
replacement.

**Provider candidate**: One discovered native bundle offered for a **provider**
identity, with its physical installation origin and verification outcome. Several
candidates can name the same provider; selection admits at most one.

**Shipped provider slot**: A **provider** identity and GraphQL namespace reserved
by Koine's sealed catalogue, with a canonical composition position. An enabled
slot can be filled by its bundled or approved per-user **provider candidate**.

**Provider framework**: The shared resilient Swift binary framework defining
the types and protocols used by native **providers** and the **Machine server**.
Its public Swift contract is the binary compatibility promise for independent
provider/server upgrades.

**Resource reference**: A URI string, `koine://<provider>/<remainder>`,
returned with provider state and passed unchanged into a later query or
mutation. The engine routes by the authority; the **provider** re-resolves the
remainder on every use and reports if the resource is unavailable, retaining
no queried state. A provider's root is a reference with an empty remainder.
Opaque by contract; represented by the GraphQL `Reference` scalar and an opaque
string wrapper in client bindings. The scheme follows the project's name.
_Avoid_: handle, id, key

**Snapshot**: State returned by one on-demand provider resolution, not
automatically cached or refreshed. The inherited `items/ref/fields` payload
does not prescribe the GraphQL wire shape.

**Process incarnation**: The particular OS process a **client** captures at
interaction start, named as `{ pid, startedAt }`: the PID and the kernel's start
instant. Its lifetime ends when that process ends; a restored logical application with a new process is a different
incarnation. A PID, application name, bundle identifier or Process Manager
serial number alone does not establish this identity.

**Public Accessibility boundary**: The desktop transport uses macOS AX APIs for
listing, focus attempts and notifications. Koine checks the **process
incarnation** before AX work, but that check does not bind the AX destination:
AX data and effects may reach another process or window during reuse, and
notifications may be stale or misattributed. Framework AX reception has no Koine
hard bound before memory or Mach rights are acquired. Koine still bounds its own
state and work and enforces grants and consent.

**Reference withdrawal**: Permanently making a reference unavailable after
its process incarnation ends, a platform closure report or another locally established failure.
A platform report can be mistaken; withdrawal does not certify physical closure.
References never revive or get reused, even after bounded reason records are
reclaimed. Recovery issues new references under the reference lifetime rules.

**Grant/dispatch admission**: Koine's serialized live-grant and revocation
boundary.

**Additional capability requirement**: A provider field's immutable requirement
for a provider read/control **capability**, checked together with its own
authority; it adds no authority to the caller's **grant**.

**Dependency availability**: Whether an operation's required application,
handler or integration is usable, distinct from whether a selected **resource
reference** is still valid or a successful query has any results.

**Host association**: A provider's bounded, revalidated relationship between a
tool instance and its containing terminal session, not a shared **resource
reference** or an atomic snapshot across **providers**.

**Special location**: An OS-known location supplied by the **Machine server** as
a starting point for a **client**'s own filesystem search. Its value grants no
filesystem access or OS consent and is not a listing of its contents.

**Native catalogue**: A named collection of native metadata observations supplied
by a **provider**, with explicit discovery availability and completeness. In v1
it supplies category-specific application and runtime System Settings choices;
**clients** own name filtering and ranking. Source observation completeness is
separate from category completeness and internal native health.

**Application population**: The complete bounded source observations staged by
one application **native catalogue** job, including raw repeated URL slots,
distinct spellings, identifier groups and per-copy choices. A population-wide
owned-budget/deadline overflow invalidates publication instead of returning an
arbitrary source-order sample. Qualification on a finite populous subject remains
distinct from all-disk completeness.

**Application presentation facts**: Explicit optional bundle agent/background
declarations and observed running activation policies associated with checked
copy identity. They support client filtering; they do not define a universal
user-facing-app predicate or justify discarding unknown/helper choices.

**Catalogue preparation**: An explicit control-authorized operation that launches
a stopped System Settings target in the background and publishes only process
readiness. It grants no read authority and never performs catalogue discovery,
activation, reveal or Automation setup.

**Settings selection**: Exact opaque pane ID and optional anchor name supplied
by the app's runtime scripting interface and re-resolved for explicit reveal.
It is neither a filesystem path, arbitrary URL, executable script nor a resource
reference; query observation does not pin a later target.

**Settings quiescence**: Equality of two complete, ID-associated pane/name/anchor
response maps separated by a bounded interval. It detects observed changes;
it is no certificate of lazy extension initialization or catalogue completeness.
Process RUNNING is separate. Current Settings reads keep observation completeness
UNKNOWN, positive choices PARTIAL and unestablished empty anchors null. Finite
cold/warm qualification proves only its declared subject's useful observations.
Confirmation timeout can retain uncontradicted complete-first-map positives with
TIME_LIMIT/UNKNOWN; no incomplete prefix becomes a complete map. Lazy
no-such-object also proves no absence at a selected reveal pre-check.

**Diagnostic saturation**: Exhaustion of a native catalogue's bounded detail
records, reported with DIAGNOSTIC_LIMIT. It omits guidance, never valid choices;
fixed source summaries retain the underlying coverage/error outcomes. It does
not by itself set resultsTruncated or certify completeness.

**Automation setup**: An explicit human action in Koine’s local explaining UI
through a private local-console seam, never a GraphQL/bearer operation. Its OS
authorization request is preflighted for a
fixed System Settings read or reveal event only where the qualified host posture
needs it. OS Automation consent covers the Koine-host/System Settings pair,
not one event; all trusted providers share that process permission.
It grants no Koine capability; a late OS answer can outlive the caller's wait.
Ordinary native reads, preparation and reveal never request it implicitly.

**Discovery coverage**: The stated availability and completeness of observations
from a **native catalogue**'s declared sources. A successful response or an empty
list alone does not establish an exhaustive inventory.

**Prompt risk**: A known possibility that an inspection would request OS consent,
causing Koine to decline it under its read policy. It establishes neither missing
consent nor a healthy empty discovery result.

**Observed location**: A filesystem location supplied as native metadata or found
by a **client**. It grants no access and pins no occupant; a later Koine action
resolves the location under its own contract. A representable value is no
actionability guarantee.

**Location resolution**: Koine's own component-by-component walk of a literal
absolute path from held, search-only directory handles, following links with
the kernel's semantics. It alone establishes that a location is absent, and it
yields the object's device and inode and its literal, link-expanded and resolved
spellings ([decision](docs/adr/filesystem-access-is-descriptor-relative.md)).
_Avoid_: realpath check, path inspection (for the whole-path calls it replaced)

**Application hand-off limit**: The `PATH_MAX` buffer size (1,024 bytes including
the NUL, so a pathname of at most 1,023 bytes) that bounds the whole pathnames
macOS opener, registration, type and handler services take; k134 measured the
exact boundary at submission. In v1 an action refuses an extant location whose
spelling is 1,024 bytes or more, not counting the NUL, with `failed`, before
asking any application
([boundary](docs/specs/workspace-launch-and-open.md#long-location-action-boundary)).
_Avoid_: overlength path, path too long (as an absence or input error)

**Application installation identity**: Established native bundle-directory
identity distinguishing application copies, including copies with the same bundle
identifier. It is neither a **process incarnation** nor a query-long pinned
identity; a later action revalidates its selected installation.

**Native application fact**: A checked native metadata or registration
observation. It does not certify internal platform health; failure or stale
service state can make it incorrect. Nil, malformed, incomplete or conflicting
observations do not establish negative facts. Known incorrect witnesses still
fail acceptance.

**Indexed application metadata**: The fixed path/type-tree/identifier/name tuple
from an actual item of the admitted application query. It can supply reported
facts at resolved bundle roots of at least 1,024 UTF-8 bytes, while lookup-only resolution
establishes a present directory's identity. It does not bind a cached index record
to that inode or prove current bundle contents; public metadataSource INDEXED_ITEM
retains UNKNOWN installation state and null bundle flags. Native long-source
qualification remains separate from disk construction and action refusal.

**Explicit application metadata reader**: The ordinary BUNDLE_RESOURCE episode:
a checked root resource-type observation at <=1,023 UTF-8 bytes followed by a
closed fixed-file and direct-localization plan through held directories. It has
no foreign Bundle/resource lookup or reconstructed descendant whole-path call.
Typed facts, provenance, native races and qualification limits remain explicit.
Its selected platform/plain information, strings and loctable semantics use
131,072-byte regular files with individual affected-fact refusal. The useful finite
certificate remains unestablished: the scoped conservative candidate exceeds its
gate and full native operands/final wire stay conditional. The grouped linked-slab refinement still fails its controlled enclosure.
The [selected qualification order](docs/adr/application-metadata-qualification-precedes-analytic-fit.md)
permits guarded private qualification before analytic useful fit, after complete
design, whole-producer review and earned integration. Advertisement/consumption
remain held until full useful native operands, actual complete responses, required
witnesses and independent serviceability qualify; required failed/refused/unknown
or missing subjects keep the affected work live. A checked
pathname/file plan alone is no useful-reader closure.

**Private application qualification**: The
[guarded construction](docs/specs/application-metadata-private-qualification.md)
composes source/reader/real-publication work with pre-call work, failure-envelope
and raw-cleanup reservations and true-return ownership. The design is complete
for whole review; implementation eligibility also requires whole-producer and
applicable downstream reviews/integrations and existing qualification placement.
Prerequisite design and qualification planning may use the reviewed design before
useful qualification; production advertisement and ordinary consumption remain
held until that qualification and independent obligations pass. A design bit or
pure control is no native evidence. Private eligibility also requires the reviewed
independent metadata-shape subject; cardinality alone cannot qualify usefulness. The
[canonical joint evidence boundary](docs/verification/application-population-metadata-shape.md)
owns the saved evidence inventory, reference/evidence decision and packet-integrity limits.
Its [complete reference-admission design](docs/verification/application-reference-evidence.md#whole-producer-obligation-comparison)
separates immutable issuance authority, independently accepted current corrections,
original evidence and verified derivatives. Actual contact/read/native-call proofs and
one-time provisioning remain unavailable; design closure supplies no finite subject.
The [review integration](docs/verification/application-reference-evidence.md#review-integration-and-required-decisions)
records Antony's accepted bounded contact evidence, closed pre-lookup rule and explicit
incomplete-evidence outcome, plus exact canonical status relocation. The
[obligation comparison](docs/verification/application-population-metadata-shape.md#line-by-line-original-obligation-comparison)
names those amendments; all other requirements remain. Full service/proxy/initial-right/
mapping coverage stays unknown, never no-contact proof. The bounded B1–B8 evidence and T1–T7/A1–A3 pre-lookup contracts separate
accepted unknown contact gaps from required native/identity/entry/control/freeze blockers.
The [chartered acceptance route](docs/verification/application-reference-evidence.md#chartered-independent-acceptance)
separates inspection-only review from Antony's own semantic acceptance/registration act,
using independently authored controls and an independent original-result executor. The
runner/producer/repairer cannot judge their own programme results; the distinct instrument
closer remains separate. K328 finds the k323 proposal incomplete; k330 decisions and complete k331/k332
replacement/review/every earned integration precede construction.
[Independent LIVE release](docs/verification/application-reference-evidence.md#independent-live-release-and-role-selection)
keeps provisioning/requalification disarmed through accepted audit and distinct instrument
close; only the commissioned supervisor originates one k245 LIVE invocation. Receipt/proof/
release possession and copied review/run/commit supply no role authority. The [enduring-input partition](docs/verification/application-reference-evidence.md#enduring-inputs-and-phase-specific-reports)
keeps changing observations in a separate unconsumed report; actual input changes still
disarm and requalify. The [practical admission design](docs/verification/application-reference-input-partition.md#coherent-k320-replacement)
is k320's historical proposal under actual k319, reviewed as defective by k321. The
[review integration](docs/verification/application-reference-input-partition.md#k321-integration-and-required-replacement)
records k322's historical publication/successor/composed-Safari/About/stream-holder
repair placement in k323. K328's current integration places k330/k331/k332 and every
earned integration before k269 construction planning. The
[historical k320 boundary](docs/verification/application-reference-input-partition.md#coherent-k320-replacement)
records the complete original-duty comparison and precise missing work. Independent
SCRATCH bootstrap/initializer-validator/close-publisher originals precede CP01 acceptance;
CP01-ROOT authorizes one initialization and CP02 accepts actual outputs. Every CP02–CP05
starts with independently anchored entry/engine/display/runtime/read continuity. Distinct
close uses its accepted close-only channel after CP03 and before CP04. An independent comparison/display tool with a short
inspectable bootstrap entry computes equality/audit/basis; Antony judges meaning in five
named own-terminal checkpoints outside agent harnesses. Original author/executor/producer/
repairer/runner exclusions, separate initializer/staged-final validator and distinct
instrument close remain. Final Q precedes CP03 acceptance/audit, distinct close precedes
CP04 eligible basis, and CP05 accepts exact entry then freshly appoints coexisting
supervisor/checker/acquirer through true return. Terminal metadata is cooperative context,
not human authentication. Durable disarm precedes changes/Q; records/images appoint nobody.
Finite System framework/version/helper/nested and Preboot cryptex productions retain
separate link/ancestor entries and the two exact checked held-root/immediate-prefix exceptions.
The [composed Safari rule](docs/verification/application-reference-evidence.md#composed-safari-walk-and-q01-specimens)
scopes each exception to its own operand, evaluates the admitted nested cryptex link,
then resumes the saved app suffix with two expansions against the shared 32 budget.
Every other outside step refuses. K328 finds k323 incomplete; k330 decisions and complete k331/k332 repair/review/every
earned integration remains before k269. Historical syntax proves no current link/TCC/presence
fact. Complete H/R exceptions with E default replace
individual fragments/report-driven refresh. Whole actual consumed-byte/original/basis/
read/phase/absence and retained original R duties remain; required missing actual identities
stay null with exact work before consumers. K295's required build/peer/terminal originals
remain Q/P work; source-child facts first belong to A. A required refusal stays incomplete,
never useful loss, finite-subject credit or private eligibility; both holds remain.

The [k328 integration and required replacement](docs/verification/application-reference-input-partition.md#k328-integration-and-required-replacement)
records every grounded finding against k323 at f4d399f3caa2. K330 records Antony's
approval of proven never-dispatched/no-provisioning bootstrap recovery and human-only
About host/session labels with explicit shared-OS/cooperative provenance limits.
Days/reboot/logout alone do not invalidate Q06 or force CP01; required changed-basis
requalification and every current per-invocation fact remain. No extra initialization,
attempt, checkpoint or observation authority follows. Complete k331, mandatory whole review
k332 and every earned integration precede k269. CP01 publisher wording and the glossary
are repaired; recovery placement, pre-tool selection/holder/fd trust, original launcher
records and repeatable trust slots remain design work. The
[integration-only documentary candidate](docs/verification/reference-practical-admission-integration-membership.json)
records k329's saved boundary and unresolved duties; later selected edits need k331's new membership. K323's membership is historical. No accepted
construction input, original, control, authority, qualification or finite subject follows.
Normative/actually consumed edits disarm and require affected requalification. K244/k242
stay live, pass unused and all useful/generated/supported-VM/native/private/product duties remain.

The application spec owns its transition protocol. Terminal guard evaluation is
pre-reserved; failed cleanup prevents successful publication. Instrumented receipts
qualify their image, with reviewed matched ordinary/disabled/enabled correspondence
and independent ordinary-image outcomes required for release.

**Reference Checkpoint Prelude**: The independently supplied read-only original trusted
directly by the inspected finite source/OS method before candidate tools. It selects
the current complete validated anchor through exact predecessor-bound reads, compares
the actual holder executable before launch and retains the selection/freeze inputs.
It creates no authority, acceptance or initialization. Its actual originals, required
identity/read/runtime evidence and controls remain unacquired; k331's whole replacement
and k332 review/every earned integration still precede construction.

**Reference Stream Holder**: The independently authored and reviewed retained original
whose executing copy the **Reference Checkpoint Prelude** compares before launch. It
opens only the fixed no-follow original/copy plan, checks identities, supplies serial
read-only descriptor pairs to the short entry and retains originals through true return.
The [continuity contract](docs/verification/application-reference-evidence.md#holder-execution-and-closed-descriptor-handoff)
fixes fd roles, offsets, generations and closure. A held file comparison is no atomic
executing-image proof; required independent correspondence still blocks its consumer.

**Reference Bootstrap Publisher**: The separately accepted bootstrap-only publisher
of CP01's earlier direct trust acts and supplied originals, under ROOT's same-invocation
authorization. It makes no semantic acceptance decision and grants no LIVE, receipt,
close or appointment authority. Antony's trust registrar has no implied bootstrap capability.

**Reference Publication Validator**: The separately owned factual validator that
checks completed earlier bootstrap publication. It may also perform accepted ancestry
and staged/final receipt checks where the ownership exclusions hold; it cannot accept
its own results, produce the receipt or exercise human trust authority.

**Reference anchor generation**: One immutable predecessor-bound `anchors/n` slot
for a proposed independent trust-original set and its CP01 binding. Use requires
completed publication, separate validation and acceptance; a partial/unaccepted tail
forbids fallback to an older anchor.

**Reference validation generation**: One immutable predecessor-bound `validation-events/n`
slot for exactly one permitted factual bootstrap-publication, staged-receipt or final-
receipt validation kind. It does not replace issuance or authorize initialization.

**Reference close generation**: One immutable predecessor-bound `closes/n` slot for
the distinct closer's acknowledged original-obligation close on the exact current
anchor/revision/disarm/CP03 basis, outside sealed revisions. An old close cannot answer
a new qualification or partial successor.

**Reference failure disposition**: Independently accepted immutable failed-tail
evidence preserving original extents, unknowns and unperformed work. It leaves DISARMED,
certifies no failed record's success and restores no permit. Its checkpoint/trust-base
placement remains required replacement work.

**Reference ROOT purpose**: `INITIALIZE_ONCE` authorizes only the named one-time
initialization from independently established never-initialized state in the live ROOT
continuation, including fresh bootstrap recovery only on independent original proof of
no initializer dispatch and no permission-subject provisioning. `REANCHOR_ONLY` authorizes
a successor anchor and affected validation/qualification suffix without initialization;
existing, partial, uncertain, dispatched or consumed permission remains unavailable for
initialization without new explicit authority.

**Reference About provenance**: Host is the machine Antony identifies manually and
session is his label for an About observation's work context, with each label's exact
meaning and human source recorded. These are human provenance, not independently
matchable terminal/login/boot identities or proof that host substitution is absent.

**Reference operation stage**: Q is earlier instrument qualification; P is fresh
invocation-specific validation before intent/consumption; A is evidence first obtained
inside the single authorized attempt. A successful target sample is no Q prerequisite.
Missing, failed or stale required Q/P evidence blocks its own stage.

**Reference evidence credit**: E credits the actual performed call with original
operands/results and image identity; M credits an independently checked logical-to-scratch
mapping; U records unavailable evidence. Credit is separate from Q/P/A stage and grants
no authority. M cannot replace a required actual-call fact, and accepted contact unknowns
cannot excuse a failed required control. These E/M/U values differ from the historical
statement inventory's enduring/historical/reporting classifications.

**Application explicit-work admission**: The application job's cumulative
20 MiB controlled raw requested/write gross and explicit-operation ledger under
the [accounting decision](docs/adr/application-metadata-accounting-covers-explicit-work.md).
Reuse/disposal refund nothing. Internal platform/Swift/compiler costs are excluded,
not known zero; unknown explicit operands are never excluded. Real public-value
publication remains provider-owned. This promises no total heap, hidden-copy gross,
runtime-attempt, RSS or peak bound and no useful finite fit by itself.

**Native serviceability evidence**: Applicable owned events paired with
independent listener, grant-store and authorized-action outcomes for a finite
declared subject. It is empirical evidence; opaque acquisitions, peaks and
internal health remain unproved.

## Example dialogue

**Developer:** Is the desktop provider part of the Machine package?

**Domain expert:** No. It uses the package's contracts to contribute desktop
state and commands to the Machine abstraction, and the server hosts it as a
plugin.

**Developer:** Where does a client's window reference come from, and can it
read it?

**Domain expert:** From a result the desktop provider returned, as a URI
string. Pass it back unchanged; what its remainder means is the provider's.

**Developer:** My client found a 1,500-byte location and Koine opening it came back
`failed`. Has the file gone?

**Domain expert:** No. Location resolution found it; a missing one would be
`PATH_NOT_FOUND`. It failed at the application hand-off limit: in v1 macOS
cannot be handed that spelling, so Koine asked no application. Keep the result
visible and let the user copy it.
