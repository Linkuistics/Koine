# Machine abstraction

> Inherited design from ModalAnyware (`docs/specs/machine.md` at commit
> d666016, plugin-packages-k6). Koine's confirmed requirements now call for
> native Swift extensions with a stable binary interface and a fully
> introspectable GraphQL API; see [the current server boundary](../adr/koine-server-and-native-providers.md).
> The interface examples, hosting assumptions and test details below still
> need design reconciliation. They do not require a second query/execute
> public API, TypeScript provider wrappers or OS permissions in ModalAnyware.
> The URI scheme follows the project's name and is now `koine://`.

## Purpose and boundary

Applications and the desktop expose queryable state and executable commands
through a uniform interface. The resulting graph is lazy: some state and
relationships are expensive to discover, so obtaining one part must not require
constructing the entire graph.

The independent Machine package contains the generic lazy graph, query/command
machinery and provider contracts. Desktop and application providers are
separate consumers of that package. The package has no dependency on macOS,
concrete applications, or ModalAnyware's runtime, configuration, presentation
and plugin-loading infrastructure. AGREED in plugin-packages-k6 as the human
directed: the package is the core of a separate **Machine server**, its own
project, which exposes this contract over a transport with a capability model
of its own design, hosts providers as its plugins through the shared plugin
framework, and ships an LLM skill set; ModalAnyware is one client of that
server from its first increment, with no in-process interim.

This boundary and the use of opaque provider-owned references are agreed. The
Machine package remains a Swift package after considering Rust. It publishes
Swift provider contracts for its consumers. ModalAnyware uses these behind its
public TypeScript boundary, adapting plugin provider contributions internally;
native plugin components do not have to implement them. A plugin's TypeScript
library can obtain data from its own native component through a private
contract. Process loading and communication do not become dependencies of the
Machine mechanism.

Configuration accesses Machine functionality through the first-party plugin's
public TypeScript facade, whose private route to the Machine engine is the
in-process resident bridge agreed in
[configuration execution and UI hosting](../../../ModalAnyware/docs/specs/configuration-ui.md). The first-party
plugin's packaging is agreed in the [plugin boundary](../../../ModalAnyware/docs/specs/native-plugins.md) spec.

## Agreed behavior

- Query and command calls are uniform, while each provider owns its state
  schema and command vocabulary. The desktop is a provider alongside
  applications; it can expose windows, layout operations and chip overlays.
- Queries resolve the requested nodes, fields and relationships on demand and
  return snapshots. A later query resolves its requested data again. The initial
  mechanism does not maintain a graph cache or refresh snapshots automatically.
- Snapshots carry opaque provider-owned references. Callers pass them unchanged
  into later queries or commands; the provider interprets the reference and
  reports when its target is unavailable. A reference identifies the selected
  resource without requiring the caller to understand provider-specific
  addressing rules. It does not retain the resource's queried state or guarantee
  that the resource still exists when used.
- The graph supplies state and command execution. The configured interaction
  decides which options to offer. Preparing options can require a query before
  presenting choices, and navigation can require another query without issuing
  a native command. ModalAnyware's interaction state is a stack of windows;
  forward navigation and generic go-back recreate the destination window's
  contents. Reconstruction makes on-demand queries when its option derivation
  needs machine state. The window stack and reconstruction policy are outside
  the Machine package.
- Concrete Swift providers use the package's provider contracts. A plugin's
  public provider contribution is adapted by the host; neither its TypeScript
  library nor its native component must implement the Swift contracts.

## AGREED: The initial interface

Agreed by the human in plugin-packages-k6 as the smallest interface the agreed
chooser example needs: list the windows of the application recorded at the
leader, then focus the chosen one. The
[interface view](../design/architecture/machine-interface.d2) and the
[reference sequence](../design/architecture/addressing.puml) show it.

**A reference is a URI string.** Its form is
`machine://<provider>/<provider-owned remainder>`. The engine reads only the
authority, the provider name, to route a call; everything after it, path and
query, is text the provider alone produces and interprets, percent-encoded as
URIs require, and re-resolved on every use. That is what makes a reference
JSON by construction, one value that travels inside a stack entry's inputs
(the constraint configuration-ui-k5 handed to this leaf), an effect, a page
attribute or a log line, and what makes it survive a provider restart: a
remainder whose scheme is stable re-resolves, and one whose target is gone
reports unavailable. A provider's root is its authority with an empty
remainder, `machine://desktop/`, so every target of a query or command is a
reference and there is no second target type. A provider emits one canonical
string per resource, so equality within a provider's snapshot is identity;
identity across providers remains open. The desktop provider's window
reference carries the owner's process identifier, the window number and the
title, because Modaliser re-finds a window by the first two and falls back
to the title where the window number is unreliable; its scheme is its own and
may change without touching any caller. The scheme name `machine` is a
placeholder that follows the Machine project's eventual name.

Opacity is a contract backed by the type: in TypeScript a reference is a
branded string, so configuration cannot pass an arbitrary string where a
reference is expected without saying so, and the facade exposes no parse. The
rejected alternatives are the compound `{ provider, key }` object this
replaced, which code had to build and compare; a handle table in the engine
mapping opaque tokens to live objects, state the engine would have to keep in
step with a graph it does not observe and which no process restart survives;
and a structured JSON key, which would invite callers to read it.

**Two uniform calls.** From the first-party facade, in JSON shapes:

```ts
type Reference = string & { readonly __machineReference: unique symbol };
type Snapshot = { items: { ref: Reference; fields: JsonObject }[] };

machine.query(target: Reference, relation: string, args?: JsonValue): Promise<Snapshot>
machine.execute(target: Reference, command: string, args?: JsonValue): Promise<JsonValue>

type MachineError =
  | { kind: "unknown-provider" | "unknown-relation" | "unknown-command"; name: string }
  | { kind: "unavailable"; ref: Reference; detail: string }
  | { kind: "permission"; detail: string }
  | { kind: "failed"; detail: string };
```

Both calls reject with a `MachineError`, which is the JSON form of the Swift
error below and is what crosses the bridge; `args` defaults to `{}`.

A query names a target and a relation in that provider's vocabulary, and
returns the items that relation resolves to, each with its reference and its
fields as the provider defines them. A single-valued relation returns zero or
one item. Nested state is another query from an item's reference; nothing is
resolved that was not asked for. A command names a target, a command in the
provider's vocabulary and arguments, and returns the provider's result. The
chooser example is `query("machine://desktop/", "application", { pid })` to
convert the interaction context on first use, `query(app, "windows")` to
list, and `execute(window, "focus")` to act.

**In Swift, inside the Machine package:**

```swift
public struct Reference: Hashable, Codable {
    public let uri: String            // the JSON form
    public var provider: String { get } // the authority
    public var remainder: String { get } // opaque to everything but the provider
}
public struct Item: Codable { public let ref: Reference; public let fields: JSON }
public struct Snapshot: Codable { public let items: [Item] }

public protocol Provider: Sendable {
    var name: String { get }
    func query(_ target: Reference, relation: String, args: JSON) async throws -> Snapshot
    func execute(_ target: Reference, command: String, args: JSON) async throws -> JSON
}

public enum MachineError: Error {
    case unknownProvider(String), unknownRelation(String), unknownCommand(String)
    case unavailable(Reference, String), permission(String), failed(String)
}
```

The engine registers providers by name (a second registration under a name is
a programming error), parses only the authority of a target and routes to
that provider, rejecting a malformed URI or an unknown provider itself; every
other error is the provider's to raise from the closed set above. A relation
or command that the target's kind does not have is `unknown-relation` or
`unknown-command`; a remainder that is malformed or no longer resolves is
`unavailable`; a platform permission the provider lacks, such as
Accessibility, is `permission`, so the app can prompt for it rather than
report a failure, and it is also where a capability refusal would surface if
Machine later runs as a capability-guarded server. `JSON` is the package's own
value type. **Retaining nothing** is a rule about references and snapshots:
the engine keeps no cache and refreshes nothing, and a provider does not hold
queried state on a caller's behalf or make a reference depend on it. A
provider may keep observation state its platform requires, as Modaliser's
desktop code remembers windows seen on other spaces because Accessibility
enumerates only the current one; that is the provider's private business and
preserves that capability. Consistency is per call: one query is one provider
resolution, and nothing establishes an atomic instant across two calls or two
providers. A command reports its outcome or its failure once; the engine
retries nothing.

**Providers are the server's plugins.** A provider is written against the
Swift contract above and hosted by the Machine server through the shared
plugin framework; how the server loads, sandboxes and authorises them is the
server project's design. The desktop provider is the first, and the first
increment's only, provider. ModalAnyware plugins contribute actions and
events, not providers; the [plugin boundary](../../../ModalAnyware/docs/specs/native-plugins.md) spec records
that.

## Test seams

Exercise the package's engine and contracts through its public interfaces with
a fake provider: routing, the root target, the error set, and that references
pass through unchanged. Exercise the desktop provider against real
applications in isolated TestAnyware VMs: list, focus, and an unavailable key
after a window closes. Keep validation proportionate to a non-critical
application, as agreed for the project.

## Open contracts

Cross-provider identity, an atomic instant across providers, command atomicity
and retry, and field selection within a query remain open, as do the server's
transport and capability model, which are the Machine server project's.
Reference encoding, restart lifetime and the failure set are agreed above.
