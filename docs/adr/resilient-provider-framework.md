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

Koine does not use a C-compatible function table with byte buffers, because
idiomatic Swift authoring matters more: its smaller shared type surface does not
justify the adapter and manual ownership contract for Swift-only providers.
Cross-language plugin authoring is not a requirement; requiring it would reopen
that trade-off. Compiling providers into the host alone still
fails the independent-upgrade requirement. Updating plugins may require a Koine
restart; independent upgrades do not promise live replacement or unload.
