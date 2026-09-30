# selection-failures-k64 — brief

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

## Decomposition

This leaf proved bigger than one session: it needs a shared harness library
extracted from `scripts/verify-selection-decisions.py`, roughly fifteen new
fixture cases (principal, `dlopen`, descriptor and SDL failures; additional-
requirement dependants; a start failure; duplicates), cascade hosts, a restart
machinery over one data directory, injected assessment verdicts, and conformance
profiles. Cut along the Machine rows, each slice closing its rows end to end:

1. `freeze-failures` (N, G): the shared harness library and restart machinery;
   a frozen update failing principal check, `dlopen`, descriptor or schema with
   healthy alternatives, and repair/removal recovery on restart; the shipped /
   ordinary / host-class principal conflicts; the later-failure part of
   "Diagnostic completeness". Rows: "Frozen update fails later", "Shipped
   update principal conflicts…", and the part of "Diagnostic completeness" that
   `selection-decisions` left here.
2. `duplicates-cascade` (N, G): ordinary duplicates with untrusted rivals; the
   desktop-rejected cascade (workspace on desktop, a third provider on
   workspace, a surviving cycle) against exact absent/rejected conformance
   profiles; the desktop start failure. Rows: "Ordinary duplicate identities…",
   "Desktop rejected before publication…", "Desktop published but start fails".
3. `digest-restart` (N, G): same SDL from either root, changed SDL, an extra
   provider, management fields denied without `koine:manage`; restart after
   removal or a changed baseline, an injected changed verdict, and an
   unreadable root. Rows: "Same SDL across roots…", "Restart after update
   removal…".

Each slice adds its rows' evidence to `docs/verification/selection-failures.md`
and links it from Machine's table; the last one closes the node against the
"Machine's table links the evidence" condition above.

## Notes

Fixtures keep to the harness `selection-decisions-k63` built: `fixturesh` /
`fixturesk` stand in for the shipped slots and `fixtureod` for an ordinary
provider, so no production identity is touched.
