# process-identity-without-time-k52

## Goal

Implement the non-time process identity `process-identity-without-time-k51`
designed: provider, served schema, reference encoding, tests, the published
operations, the documentation and the evidence that cites what changed.

## Context

- k104 selects **non-time capture with public AX**. Wrong-target data/effects
  during process/window reuse, stale notifications, mistaken withdrawal and
  framework AX reception without Koine's hard acquisition bound are accepted.
  Capture identity is never rebound; known-dead refusal, grants, Koine consent,
  permanent local withdrawal/non-reuse and bounded Koine-owned state/work remain.
  k75 must deliver the full reviewed capture/transfer/reference/restart and public
  attempt protocol before implementation. No private AX exchange is required.

- The design, its ADR and the decision's record are k51's; read them first. If
  k51 left this body short of a concrete list, that is the first thing to fix.
- Files that carry the time-based identity today, found in k45 by grepping for
  `startedAt`, `startMicroseconds` and `DesktopProcessStart` across the whole
  tree (re-grep the claim rather than trusting this list):
  `Providers/DesktopProvider/{schema.graphql,Logic/ProcessStart.swift,Logic/DesktopReference.swift,Sources/ProcessIdentity.swift,Sources/DesktopProvider.swift}`,
  `Tests/KoineServerTests/DesktopProviderTests.swift`,
  `Tests/DesktopProviderLogicTests/LogicTests.swift`,
  `docs/design/desktop-schema.graphql`, `docs/specs/machine.md`, `README.md`,
  `Taskfile.yml`, `scripts/vm-verify-desktop.sh`,
  `scripts/vm-verify-desktop-client.py`, `scripts/vm-verify-latency-client.py`,
  `clients/contract-only/` (its C helper exists only because of the old
  mechanism), and the client guide `documentation-and-handoff-k45` wrote.
- The schema digest moves. Every document citing
  `ee17dfd16a7d00079a9dd1e7523954dba8ced0052096e75d2dc7bdaacb5e2baf` states what
  was served at that run; decide per document whether it is re-run or marked as
  evidence about the superseded form, and say which in each.

## Done when

- The served schema matches the design SDL under `task conformance`, on a
  rebuilt, notarized bundle.
- A client resolves a running application by the new mechanism with no runtime
  compiler, no guessed precision and no private API in the client.
- Ended captures and old references refuse under the agreed lifetime policy,
  including actual PID reuse. Distinguish this local refusal from accepted AX
  routing races and from k42's simulated timestamp mismatch.
- No document still describes the start instant as the current mechanism.

## Notes

Anything that launches Koine runs in a TestAnyware VM, never on the host.

## Implementation impact identified during k51

The human has confirmed **client-event capture must be preserved**. A delayed
`desktopFrontmostApplication` lookup in Koine cannot replace it. The identity
representation is still under discussion; this list is independent of that
choice and does not authorize one of the draft mechanisms.

The human also requires **strict OS-process lifetime**, including expiry on
automatic termination. PSN plus platform boot identity has been ruled out by
`docs/verification/process-serial-lifetime.md`: the same pair selected a new
process after restoration. The remaining native protocol belongs to
`retained-process-identity-k54` within k51. Do not implement a PSN-only replacement
or treat retained rights as sufficient to bind a PID-based action.

The held-AX PID-reuse counterexample explains k104's accepted public-AX limits;
it is not an implementation of the new capture protocol. The private endpoint
investigation was rejected for the first deliverable. Read the current capture
and public Accessibility ADRs, not old diagnostic quotas or private ABI entry
points as a plan. k84–k87 retain capture/transfer, lifecycle, public AX consent/
ownership and the complete client contract; the timestamp mechanism is not
approved for first release.

- Provider and native observation: replace the timestamp comparison in
  `Sources/ProcessIdentity.swift` and every resolution path in
  `Sources/DesktopProvider.swift`; update the process key used by
  `Logic/HeldWindows.swift`, `Sources/WindowTable.swift` and
  `Sources/WindowObservation.swift` (all beneath `Providers/DesktopProvider`).
  Retain exact incarnation data through focus confirmation, retirement and
  delayed callbacks. A retained Mach right does not pin a PID: validation then
  `AXUIElementCreateApplication(pid)` is not an atomic identity-bound action.
  Implement k104's explicit public-AX boundary and k75's final protocol: retain
  the captured identity separately, validate it before work, and keep local
  callback/registration lifetimes safe. Do not implement an owned AX receive loop
  or private per-reply authentication. Describe reads/focus reports as framework
  observations; stale reports can wrongly withdraw records, which never revive.
  Cancellation or failure after a possible call preserves effect uncertainty.
- Representation: retire `Logic/ProcessStart.swift`, replace
  `Logic/DesktopReference.swift`'s grammar, update the provider SDL,
  `docs/design/desktop-schema.graphql` and
  `docs/design/desktop-operations.graphql`. Match malformed-input, ordinary
  absent-process null, stale-reference `unavailable`, capability and OS-consent
  behavior to the eventual agreed contract. The engine must still route only
  by URI authority.
- Tests: migrate `Tests/DesktopProviderLogicTests/LogicTests.swift` and
  `Tests/KoineServerTests/DesktopProviderTests.swift`; cover actual incarnation
  mismatch, stale native identity, parser round trips, noncanonical encodings,
  boot/provider restart boundaries and late retirement callbacks. Exercise the
  chosen mechanism through the existing public GraphQL and VM seams. Avoid
  preserving timestamp tests through renamed timestamp-like fixtures.
- Clients: change `clients/contract-only/src/adapter/process-identity.ts`,
  `src/cli.ts`, `codegen.ts` and `test/run.mjs`; regenerate `src/generated/`
  from the new introspection response and update the captured schema under
  `capture/`. A prebuilt native capture component is acceptable only if agreed
  by the final design; compilation on a user's first run is not. Migrate
  `scripts/vm-verify-desktop-client.py`, `scripts/vm-verify-latency-client.py`
  and `scripts/vm-verify-desktop.sh`, then inspect every consumer of those
  shared clients. Refresh affected Taskfile descriptions.
  Carry k77's agreed callback-time foreground capture into the ModalAnyware
  owner handoff. Original-event targeting is not required. Its current agreed spec
  samples AppKit foreground in the leader callback; any required capture-source
  change is distinct from replacing `startedAt`. Document sampling/provenance
  and delayed-callback behavior without editing ModalAnyware from this repo.
- Current documentation: reconcile README, the spec, `docs/client-guide.md`,
  the held-window ADR and architecture addressing view with k51's final ADR.
  Historical acceptance reports keep their original captured responses and
  digest; explicitly mark what is superseded rather than substituting a new
  digest into an old run. Grove decision logs remain historical records.

## Evidence renewal

Run these against the rebuilt, signed and notarized application after k51's
contract is settled. Each report must identify the new build and the schema it
actually observed:

| Reusable task | Evidence document to renew | Reason |
|---|---|---|
| `task conformance` | `docs/verification/schema-conformance-vm.md` | Changed input types, descriptions and digest |
| `task app:vm-verify-contract-client` | `docs/verification/contract-only-client.md` | New capture path, regenerated operations, no runtime compiler |
| `task app:vm-verify-desktop` | `docs/verification/desktop-application-and-windows-vm.md` and `desktop-references-and-permission-vm.md` | Resolution, old identity/reference refusal and error distinctions |
| `task app:vm-verify-desktop-focus` | `docs/verification/desktop-focus-vm.md` | Capture expiry, known-dead refusal, ordinary focus attempts and framework-reported observations; uncertainty and accepted routing limits |
| `task app:vm-verify-desktop-remembered` | `docs/verification/desktop-remembered-windows-vm.md` | New incarnation keys, locally safe callbacks, irreversible withdrawal and best-effort remembered rows, including mistaken-withdrawal semantics |
| `task app:vm-verify-release` | `docs/verification/release-acceptance-vm.md` | PID reuse, app/provider restart, consent and signed-build behavior |
| `task app:vm-verify-latency` | `docs/verification/latency-and-support-matrix.md` | Capture cost and keyboard interaction path changed |

`docs/verification/desktop-window-identity.md` and
`docs/verification/contract-only-client-gaps.md` describe earlier experiments.
Keep their observed results as historical evidence, label their old process
encoding as such, and point to the new acceptance reports. The held-element
window result can still be cited with its limits; it is not by itself evidence
that a native endpoint stays bound across process-incarnation changes.

The old PID-reuse evidence was a live PID paired with a deliberately incorrect
start time, **not a genuinely recycled PID**. Report a deterministic mismatch
test and an actual native reuse experiment separately. Never promote one to
the other by changing the caption. The broader release's documented limits
(OS versions, signing identities and other open cases) stay explicit.
