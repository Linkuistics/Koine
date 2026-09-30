# selection-failures-k64

## Goal

Accept selection's failure boundary after choices freeze, and the composition
consequences, at N and G.

## Context

- `docs/specs/machine.md`: the "Selection before execution" and "Additional
  capability requirements" cascade rules, and the rows this node's brief
  assigns here.
- The harness from `selection-decisions-k63`.

## Done when

- Freeze: a frozen update that fails its principal check, `dlopen`, descriptor
  or schema has healthy alternatives. None is loaded or started, and the choice
  stays identifiable. A principal refusal precedes load. A post-load refusal may
  leave images mapped. Recovery is repair or removal, then restart.
- Principal conflicts:
  - between shipped selections, both are refused symmetrically;
  - an ordinary claimant against a shipped owner is refused alone;
  - a conflict with a host class is refused.
  Nothing is retried, and the diagnostics agree with the capability-owner cascade.
- Ordinary duplicates: only pre-load-eligible rivals contest. Eligible duplicates
  are both refused as `manifest-collision`. A refused untrusted rival never
  evicts a valid provider.
- Cascade: desktop is rejected before publication, workspace depends on desktop,
  and a third provider depends on workspace. The fixed-point removal agrees with
  an exact absent/rejected conformance profile, capabilities and diagnostics.
  Management stays usable, and a valid cycle survives.
- Start failure: desktop is published but fails to start. Its schema and
  authority remain, its fields are unavailable, workspace is not removed for
  that alone, and no bundled copy is retried.
- Digest:
  - the same SDL from either root preserves the digest and the
    identifier-sorted shipped position;
  - changed SDL changes the digest;
  - management fields are denied without `koine:manage`.
- Restart: removing an update, changing the baseline or injecting a changed
  verdict is recomputed without granting new authority. An unreadable root stops
  startup instead of using a partial set.
- Machine's table links the evidence for these rows.
