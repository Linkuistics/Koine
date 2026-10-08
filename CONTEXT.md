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

**Search domain**: The names eligible for a search beneath its effective roots,
after its declared intrinsic exclusions. It is narrower than all filesystem
contents and does not establish an exhaustive installed-application inventory.

**Search pre-open proof**: An observation required before native target access under search policy, separate from a post-access check. The [tool-backed permission contract](docs/specs/workspace-search.md#permission-boundary-and-required-decision) leaves relocated-target protection and lookup-only target acquisition as human choices. System-tool prune/no-follow/device flags supply no such proof; the earlier custom queued-walk witnesses are not the selected mechanism.

**Search coverage**: One effective source's completeness within the search domain: COMPLETE is established eligible filesystem-domain processing, PARTIAL means observations with omissions, UNKNOWN means useful observation/completeness was not established. The OS-reported application source is always UNKNOWN, never an exhaustive installation inventory.

**Search source**: One effective filesystem root or the separate OS-reported application seed source. Coverage-row indices name observed result provenance, not all lexically overlapping roots.

**Search remainder**: Unfinished or unlocalized work of a source, with or without candidate observations. It describes command/native processing uncertainty without asserting how many names or descendants were omitted.

**Search progress**: A complete candidate record actually considered, or established successful eligible empty filesystem processing. Empty native application-service responses alone are neither progress nor healthy empty.

**Prompt risk**: A known possibility that an inspection would request OS
consent, causing Koine to skip it under its read policy. It is not an observation
that Koine lacks consent; search reports a PROMPT_RISK skipped scope even in an
AVAILABLE result. It contributes to **Search policy blocking** only when no
root made progress and no failure-class reason exists.

**Search policy blocking**: The search BLOCKED outcome with no observed progress,
at least one **Prompt risk**, and no inspection/change/work/resource failure. Its consent
state is UNKNOWN, with no matches list and explicit **Search coverage**.

**Search location**: A lossless absolute filesystem location returned for later client selection. File locations preserve system-command bytes, including final links, without a unique canonical-parent/firmlink spelling promise. Application locations use established resolved target spelling. A later action resolves the location itself and may encounter another occupant; the search value ceiling is no actionability guarantee.

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

**Search application identity**: The established native bundle directory identity used to merge direct, checked-link and OS-reported routes while retained. Distinct copies sharing an identifier stay distinct. Its first finalized target name/path supplies matching and selection; source membership records observations only. It is neither a process incarnation nor a query-long pinned identity.

**Search native fact**: A checked result reported by a native metadata or
registration service. It does not certify internal platform health; undetected
failure or stale service state can make it incorrect. UNREGISTERED reports no
registration for the checked present **Search application identity** under the
documented negative branches. Nil identifier is unknown, never a missing-key
fact. Malformed/incomplete/conflicting results and observed resource errors do
not establish negatives; known incorrect witnesses still fail acceptance.

**Search serviceability evidence**: Applicable owned spawn/pipe/kill/reap/native-call events paired with independent listener, grant-store and authorized-action outcomes for a finite declared subject. It is empirical evidence: opaque native/tool acquisitions, peaks and internal health remain unproved.

## Example dialogue

**Developer:** Is the desktop provider part of the Machine package?

**Domain expert:** No. It uses the package's contracts to contribute desktop
state and commands to the Machine abstraction, and the server hosts it as a
plugin.

**Developer:** Where does a client's window reference come from, and can it
read it?

**Domain expert:** From a result the desktop provider returned, as a URI
string. Pass it back unchanged; what its remainder means is the provider's.

**Developer:** Search returned a 1,500-byte location and opening it came back
`failed`. Has the file gone?

**Domain expert:** No. Location resolution found it; a missing one would be
`PATH_NOT_FOUND`. It failed at the application hand-off limit: in v1 macOS
cannot be handed that spelling, so Koine asked no application. Keep the result
visible and let the user copy it.
