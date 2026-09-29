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
server can be upgraded independently through the **provider framework**.

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

## Example dialogue

**Developer:** Is the desktop provider part of the Machine package?

**Domain expert:** No. It uses the package's contracts to contribute desktop
state and commands to the Machine abstraction, and the server hosts it as a
plugin.

**Developer:** Where does a client's window reference come from, and can it
read it?

**Domain expert:** From a result the desktop provider returned, as a URI
string. Pass it back unchanged; what its remainder means is the provider's.
