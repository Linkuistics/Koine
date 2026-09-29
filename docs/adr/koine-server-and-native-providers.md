# koine-server-and-native-providers

## Decision

Koine is a standalone server that clients connect to rather than embed.
It exposes a fully introspectable GraphQL API over loopback HTTP, guarded by
Koine capabilities. Native provider plugins contribute application or desktop
types and operations to that schema. ModalAnyware is a client; no Koine
provider lives in ModalAnyware.

Providers are authored in Swift and have a stable binary interface
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
depends on a working server. Independent native upgrades also require an
explicit compatibility and loading policy; they give up the simplicity of
rebuilding all extensions together.

Koine provides the desktop path and the agreed native workflow support
ModalAnyware needs. Installed-application search, file search, launch/activate,
file and URL opening, reveal, and bounded prerequisite discovery/explicit setup
are in scope, as specified in [workflow providers](../specs/workflow-providers.md).
These reusable operations do not move client key maps, choosers, labels,
confirmation, MRU ordering or settings lifecycle into the server. Broader
installation/configuration discovery, a public arbitrary-shell-execution operation
and an LLM skill set remain out of scope. The
[provider authority decision](provider-authority-follows-effects.md) keeps
application input, menu invocation and desktop-window focus independently
grantable while assigning mixed effects their complete authority.

One resident process preserves desktop observation and a single OS-permission
owner without a privileged UI-to-service bootstrap connection. It also makes
native UI and providers share the server's failure domain; independently
restarting the management UI requires a different process design.

One loader means the product itself exercises the native seam on every launch,
and a first-party provider can be upgraded without the host. The cost is that
the desktop path depends on the loader, run path and signing being right in the
signed build.

The workflow extension uses a sealed host catalogue to reserve shipped identities
even when their bundles are missing or rejected. One pre-load calculation selects
the unique highest verified, compatible, explicitly approved per-user release
newer than the host's bundled baseline; otherwise it uses the eligible bundle.
An ambiguous highest update leaves that slot unavailable. A selected update keeps
the shipped identity's composition position. The
[Machine selection contract](../specs/machine.md#first-party-provider-selection)
defines version floors, candidate diagnostics and refusal boundaries. This is
designed extension behavior; the served baseline still refuses external desktop
replacement. The framework's independent-binary promise alone does not supply
this host selection feature.

Pre-load refusals remain visible even when an eligible lower release is selected.
After selection, a failure never triggers a retry of an older candidate. This
makes a failed update diagnosable and avoids loading two versions with conflicting
native class identities. It costs availability until the user repairs the installed
set and restarts. No highest-seen-version store is maintained: the host's sealed
baseline is the floor, not rollback protection across host releases. Existing
ID/Team-ID approval authorizes compatible releases of the identity; requiring a
new hash approval on every update would change that trust contract.

The catalogue and immutable candidate reports keep installation policy in the
loader. The core sees the chosen identity, its physical origin and composition
position separately; it retains schema validation and lifecycle ownership. This
adds one catalogue and explicit selection diagnostics, while callers still supply
roots once and consume provider status. No public caller chooses files, compares
versions or assembles a loading protocol.

## Rejected alternatives

**Always prefer the bundle, or reject every duplicate.** Both are deterministic
but make the first-party independent-update promise ineffective for shipped
identities. Reopen only if that product requirement is withdrawn.

**Load candidates and fall back until one starts.** This hides broken updates,
runs initializers from discarded versions and risks native-class collisions.
Reopen only with a separate isolation/restart design and an explicit rollback
contract; in-process descriptor rejection cannot undo load-time code.

**A pinned candidate/version manager.** A pin could resolve equal-version copies
and enforce persistent rollback policy, but adds mutable installation state and
approval/repair operations to a task whose existing approval is identity-based.
Revisit if users need intentional version pinning or cross-restart anti-rollback.

**Linking the bundled desktop provider into the host.** Simpler to build and
sign, but it leaves the plugin path exercised only by tests and third parties,
and makes the bundled provider's upgrade a host rebuild.

**A separate service and management application.** Independent UI lifetime
does not justify the authenticated IPC and permission-attribution work. A
requirement for independent UI restarts or stronger process isolation would
reopen this choice.

**Compiled-in modules as the only extension mechanism.** Updating an
extension would require rebuilding the server, which fails the independent
upgrade requirement. Open-source distribution does not remove that
requirement.

**A TypeScript entry module around every native provider.** Introduces a
script-hosting dependency that the Swift-native extension contract does not
require. Reuse of another framework must satisfy the native contract rather
than impose this wrapper.
