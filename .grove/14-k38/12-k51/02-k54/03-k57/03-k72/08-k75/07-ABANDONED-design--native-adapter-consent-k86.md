# native-adapter-consent-k86

## Goal

Establish Koine-owned public Accessibility consent and local operational
ownership/bounds for k104's smaller contract, with concrete k52 acceptance
instructions. Private AX transport and ABI maintenance are out of scope.

## Context

Consume k84's capture/transfer and k85's lifecycle evidence, the public
Accessibility ADR and the machine spec's native targeting section. Existing
public-AX consent evidence is a baseline, not acceptance of an unbuilt replacement.
The framework receive exception does not waive capture-channel admission or
Koine-owned state/work limits. The old diagnostic quotas are not product budgets.

## Done when

- Account for public AX enumeration, registration, restore/main/raise/activation
  and confirmation calls. Specify known-dead capture refusal, cancellation and
  partial-progress uncertainty; do not infer native non-enqueue from an AX error
  or require independently authenticated framework replies.
- Establish local callback-context and registration ownership, delayed callbacks,
  cancellation, disconnects and bounded cleanup without use-after-free or revival
  of withdrawn references. Distinguish rejecting a locally obsolete callback from
  the accepted stale/misattributed target reports on a current registration.
- Propose global/per-capture bounds from the mechanism and measured ordinary
  workloads for records, registrations, accepted values, queued work, outstanding
  calls and waits. Bound churn/allocation and reason records; specify exhaustion,
  recovery and generic unavailable after reclamation without identifier reuse.
  Coordinate capture-channel acquisition bounds with k84; public AX's framework
  memory/right acquisition remains explicitly outside Koine's hard envelope.
- Exercise a separately launched signed/hardened Koine-equivalent app with its
  own identity and public AX path. Record launch provenance, entitlements and
  bytes. Distinguish capture policy, AX permission, platform/transport failure
  and capability denial. A client-consent/helper requirement is a conflict.
- Witness absent consent, Koine-owned grant, live revocation and regrant/restart
  with a live-target control and independent effect observations. Include ordinary
  windows, remembered-window behavior and local refusal/cleanup faults at the
  existing seams. Framework replies are observations, not exact-target proof.
- State supported public API/platform behavior and operational failure handling;
  no private wire/ABI profile or behavioral application restriction is adopted.
  Carry signed/notarized/quarantined verification on the final rebuilt bytes into
  k52. This design evidence cannot certify an unbuilt product.

## Notes

Native execution uses isolated TestAnyware clones and independent witnesses.
Choose only a concrete discriminator serving the retained requirements. k87
settles public fields, read/notification/recovery semantics, namespaces, restart
policy and the complete agreement; no implementation authorization follows here.
