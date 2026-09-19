# koine-server-and-native-providers

## Decision

Koine is a standalone server that clients connect to rather than embed.
It exposes a fully introspectable GraphQL API over loopback HTTP, guarded by
Koine capabilities. Native provider plugins contribute application or desktop
types and operations to that schema. ModalAnyware is a client from its first
increment; no Koine provider lives in ModalAnyware.

Providers are authored in Swift initially and have a stable binary interface
so compatible plugin and server releases can be upgraded independently,
without rebuilding the other side. Native Swift dylibs use a
[shared resilient provider framework](resilient-provider-framework.md), whose
published Swift contract is evolved compatibly across supported versions.
There is no required TypeScript wrapper or assumed PluginAnyware dependency.
OS-specific provider work stays separate from APIAnyware.

There is one native loader. A provider Koine ships, the desktop provider
included, is a plugin bundle in a provider root sealed inside the application
and loads exactly as a per-user installed provider does; it is not a target
linked into the host.

Koine holds the OS permissions needed by its providers. Clients receive
Koine capabilities and need OS permissions only for their own functions.
One resident, per-user Koine application contains the native macOS management
UI, server and providers; clients do not own its lifetime. Closing a management
window leaves the server and provider observation running. Native management
uses in-process authority, and Koine's own GraphQL interface exposes management
under its capability model. Grants persist until explicitly revoked.

## Trade-off

One server owns native application access and the OS permissions it needs,
while clients consume a typed, discoverable contract. ModalAnyware therefore
depends on a working server from its first increment. Independent native
upgrades also require an explicit compatibility and loading policy; they
give up the simplicity of rebuilding all extensions together. GraphQL changes
the client wire contract, so the client handoff must be revised accordingly.

The first deliverable is the desktop path that unblocks ModalAnyware.
Broader discovery and an LLM skill set remain future work.

One resident process preserves desktop observation and a single OS-permission
owner without a privileged UI-to-service bootstrap connection. It also makes
native UI and providers share the server's failure domain; independently
restarting the management UI requires a different process design.

One loader means the product itself exercises the native seam on every launch,
and a first-party provider can be upgraded without the host. The cost is that
the desktop path depends on the loader, run path and signing being right in the
signed build.

## Rejected alternatives

**Linking the bundled desktop provider into the host.** Simpler to build and
sign, but it leaves the plugin path exercised only by tests and third parties,
and makes the first provider's upgrade a host rebuild.

**A separate service and management application.** Independent UI lifetime
does not justify the authenticated IPC and permission-attribution work for the
first desktop deliverable. A later requirement for independent UI restarts or
stronger process isolation would reopen this choice.

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
