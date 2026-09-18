# Resilient provider framework

Native Swift providers and Koine dynamically link one host-supplied,
shared Swift framework for provider protocols and value types. Build that
framework with library evolution and module stability from its first release;
its published Swift interface is part of the permanent compatibility promise
within a supported major. Keep GraphQL-library implementation types private.

This gives plugin authors normal Swift values, ownership and asynchronous
calls while allowing compatible host/plugin binaries to be upgraded separately.
The cost is disciplined evolution of public types, protocol requirements,
concurrency contracts and semantics, plus a single framework identity at
runtime. A plugin may require newer framework symbols than an old host supplies;
its minimum version must be checked before loading, not negotiated afterward.
Swift's [library-evolution rules](https://www.swift.org/blog/library-evolution/)
support this direction; compatibility is demonstrated with independently built
old/new binary pairs through the native plugin seam.

A C-compatible function table with byte buffers was considered and rejected in
favor of idiomatic Swift authoring. Its smaller shared type surface does not
justify the adapter and manual ownership contract for the current Swift-only
scope. Cross-language plugin authoring could reopen that trade-off; it is not a
requirement of this version. Compiling providers into the host alone still
fails the independent-upgrade requirement. Updating plugins may require a Koine
restart; independent upgrades do not promise live replacement or unload.
