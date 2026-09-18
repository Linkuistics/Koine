# koine-server-and-native-providers

## Decision

Koine is a standalone server that clients connect to rather than embed.
It exposes a fully introspectable GraphQL API over loopback HTTP, guarded by
Koine capabilities. Native provider plugins contribute application or desktop
types and operations to that schema. ModalAnyware is a client from its first
increment; no Koine provider lives in ModalAnyware.

Providers are authored in Swift initially and have a stable binary interface
so compatible plugin and server releases can be upgraded independently,
without rebuilding the other side. Swift dylibs are the proposed loading
mechanism; the exact ABI and supported-version policy remain design work.
There is no required TypeScript wrapper or assumed PluginAnyware dependency.
OS-specific provider work stays separate from APIAnyware.

Koine holds the OS permissions needed by its providers. Clients receive
Koine capabilities and need OS permissions only for their own functions.
Koine remains resident or is activated by the OS when its endpoint is
accessed; clients do not own its lifetime. A native macOS UI and Koine's own
GraphQL API manage access, with grants persisting until explicitly revoked.

## Trade-off

One server owns native application access and the OS permissions it needs,
while clients consume a typed, discoverable contract. ModalAnyware therefore
depends on a working server from its first increment. Independent native
upgrades also require an explicit compatibility and loading policy; they
give up the simplicity of rebuilding all extensions together. GraphQL changes
the client wire contract, so the client handoff must be revised accordingly.

The first deliverable is the desktop path that unblocks ModalAnyware.
Broader discovery and an LLM skill set remain future work.

## Rejected alternatives

**Embedding the server in ModalAnyware temporarily.** Avoids the initial
server dependency but creates a migration the agreed boundary excludes.

**Compiled-in modules as the only extension mechanism.** Updating an
extension would require rebuilding the server, which fails the independent
upgrade requirement. Open-source distribution does not remove that
requirement and remains a separate product decision.

**A TypeScript entry module around every native provider.** Introduces a
script-hosting dependency that the Swift-native extension contract does not
require. Any future framework reuse must satisfy the native contract rather
than impose this wrapper.
