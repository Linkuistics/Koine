# Resilient provider framework

Native Swift providers and Koine dynamically link one host-supplied,
shared Swift framework for provider protocols and value types. That framework
is built with library evolution and module stability; its published Swift
interface is part of the permanent compatibility promise within a supported
major. GraphQL-library implementation types stay private.

This gives plugin authors normal Swift values, ownership and asynchronous
calls while allowing compatible host/plugin binaries to be upgraded separately.
The cost is disciplined evolution of public types, protocol requirements,
concurrency contracts and semantics, plus a single framework identity at
runtime. A plugin may require newer framework symbols than an old host supplies;
its minimum version must be checked before loading, not negotiated afterward.
Swift's [library-evolution rules](https://www.swift.org/blog/library-evolution/)
support this direction; compatibility is demonstrated with independently built
old/new binary pairs through the native plugin seam.

The workflow extension uses this policy for
[additional capability requirements](../specs/machine.md#additional-capability-requirements):
a compatible minor adds metadata while old registrations keep empty additional
sets. A required feature prevents an older host from silently dropping the new
authority. The extension's independently built binary pairs have been exercised
([binary-compatibility.md](../verification/binary-compatibility.md)): an old host
refuses the feature before loading, and a new host runs an old provider and the
released desktop provider unchanged. A shipped provider's use of it and the pair
under the signed application are still open.

Koine does not use a C-compatible function table with byte buffers, because
idiomatic Swift authoring matters more: its smaller shared type surface does not
justify the adapter and manual ownership contract for Swift-only providers.
Cross-language plugin authoring is not a requirement; requiring it would reopen
that trade-off. Compiling providers into the host alone still
fails the independent-upgrade requirement. Updating plugins may require a Koine
restart; independent upgrades do not promise live replacement or unload.
Replacing a shipped identity additionally requires the host's
[first-party selection policy](first-party-provider-selection.md).
A compatible binary alone does not make a pre-extension host support replacement.
New first-party updates declare `first-party-selection-v1` so old hosts refuse
them before load; this host feature adds no factory witness. Different provider
identities must not privately embed conflicting versions of the same native
module: helpers have provider-unique module/runtime names or one host-owned
framework image whose compatibility is maintained here.
