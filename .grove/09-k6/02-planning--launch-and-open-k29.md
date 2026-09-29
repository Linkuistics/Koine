# launch-and-open-k29

## Goal

Cut `launch-and-open`'s implementation from its settled design into vertical
leaves that each leave Koine working and verifiable through the three seams.

## Context

- `launch-and-open-k18`'s design, and `provider-architecture-k5`'s ADR and
  allocation.
- The node brief's `Done when` is the acceptance to cover.

## Done when

The node holds ordered `impl` leaves that cover the brief's `Done when`. The
first leaf delivers one real launch path end to end, from provider through
loader, schema and client to the VM. Later leaves widen it and add no dead
layer. Any review judgment is recorded.

## Notes

If the design adds a bundled provider, the first leaf carries the packaging,
approval and conformance changes together with the first working operation.
Neither half is a working increment alone.

That same first slice carries the framework minor and required feature
`additional-capabilities-v1`, the full preflight/dispatch requirement set, and
old/new native binary acceptance from `provider-architecture-k5`. Preserve the
baseline desktop conformance profile and add the exact workspace profile;
missing required providers must fail that profile rather than weaken it.
