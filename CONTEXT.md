# Koine language

Terms carried from ModalAnyware's glossary (commit d666016) when this project
was created. The carried documents say "Machine server" where this project
says Koine. A term a session here resolves differently is corrected here, and
ModalAnyware's glossary follows.

## Language

**Koine**: This project: the **Machine server**. The name was chosen by the
human on 2026-09-18 in place of the working name.
_Avoid_: MachineWare (the earlier working name)

**Machine abstraction**: The view of applications and the desktop as a lazy
graph of queryable state and executable commands, supplied by **providers**
and served by the **Machine server**.

**Machine package**: The independent Swift package containing the generic
mechanism and provider contracts behind the **Machine abstraction**. It is
the core of the **Machine server** and has no dependency on macOS, on a
concrete application or on any client. Its inherited concrete types and
provider protocol need reconciliation with the GraphQL and stable-ABI
requirements; the term does not fix those interfaces in their old form.

**Machine server**: The separate application that exposes the **Machine
abstraction** through a fully introspectable GraphQL API with a capability
model, hosts native **providers**, holds the OS permissions for their
operations. An LLM skill set is planned after the first deliverable unblocks
ModalAnyware. No project includes the server; ModalAnyware is one of its
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

**Provider**: A native Swift **Machine server** plugin contributing an
application's or the desktop's GraphQL schema and the implementation of its
state and commands; the desktop provider is the first. Providers and the
server can be upgraded independently through a stable binary interface.

**Resource reference**: A URI string, `koine://<provider>/<remainder>`,
returned with provider state and passed unchanged into a later query or
mutation. The engine routes by the authority; the **provider** re-resolves the
remainder on every use and reports if the resource is unavailable, retaining
no queried state. A provider's root is a reference with an empty remainder.
Opaque by contract; its exact GraphQL and client-binding representation
remains design work. The scheme follows the project's name, replacing the
inherited `machine` placeholder according to the existing naming rule.
_Avoid_: handle, id, key

**Snapshot**: State returned by one on-demand provider resolution, not
automatically cached or refreshed. The inherited `items/ref/fields` payload
does not prescribe the GraphQL wire shape.

## Example dialogue

**Developer:** Is the desktop provider part of the Machine package?

**Domain expert:** No. It uses the package's contracts to contribute desktop
state and commands to the Machine abstraction, and the server hosts it as a
plugin.

**Developer:** Where does a client's window reference come from, and can it
read it?

**Domain expert:** From a result the desktop provider returned, as a URI
string. Pass it back unchanged; what its remainder means is the provider's.
