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
mechanism and provider contracts behind the **Machine abstraction**: the
engine, the `Provider` contract, `Reference`, `Snapshot`, `MachineError` and
its own JSON value type. It is the core of the **Machine server** and has no
dependency on macOS, on a concrete application or on any client.

**Machine server**: The separate application that exposes the Machine
contract over its transport with a capability model, hosts **providers** as
its plugins through the plugin framework (PluginAnyware), and ships an LLM
skill set. No project includes it; ModalAnyware is one of its **clients**.

**Client**: A program that reaches the **Machine server** over its transport
with a capability of its own: ModalAnyware through its Machine client module,
a third-party application, a script or an LLM agent.

**Provider**: A **Machine server** plugin exposing an application's or the
desktop's state and commands through the **Machine package** contracts, with
its own schema and command vocabulary; the desktop provider is the first.

**Resource reference**: A URI string, `machine://<provider>/<remainder>`,
returned in a **snapshot** and passed unchanged into a later query or
command. The engine routes by the authority; the **provider** re-resolves the
remainder on every use and reports if the resource is unavailable, retaining
no queried state. A provider's root is a reference with an empty remainder.
Opaque by contract, typed as a branded string. The scheme name `machine` was
agreed as a placeholder that follows this project's eventual name.
_Avoid_: handle, id, key

**Snapshot**: What one Machine query returns: the items a relation resolves
to, each with its **resource reference** and provider-defined fields; one
provider resolution, never cached or refreshed.

## Example dialogue

**Developer:** Is the desktop provider part of the Machine package?

**Domain expert:** No. It uses the package's contracts to contribute desktop
state and commands to the Machine abstraction, and the server hosts it as a
plugin.

**Developer:** Where does a client's window reference come from, and can it
read it?

**Domain expert:** From a snapshot the desktop provider returned, as a URI
string. Pass it back unchanged; what its remainder means is the provider's.
