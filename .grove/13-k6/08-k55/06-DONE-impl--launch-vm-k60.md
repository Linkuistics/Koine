# launch-vm-k60

## Goal

Accept the launch path at the V seam. Signed Koine in an isolated TestAnyware
macOS VM launches and reactivates one real required launcher application under
workspace and desktop control. The measured outcomes are recorded.

## Context

- The workspace spec's acceptance rows, in their V parts:
  - Twelve launchers, for one application;
  - Receipt/failure boundary;
  - Bounded acknowledgment, for timing;
  - Authority/revocation;
  - Consent and prompts, for Accessibility.
- The existing desktop VM recipes and their independent native witness.

## Done when

- The chosen application has completed first run and Gatekeeper approval in the
  VM. Its actual bundle identifier, version and path are recorded.
- A cold launch and a reactivation while running each happen with another
  application frontmost and Koine inactive. An independent witness observes
  activation. Acknowledgment without activation fails the case. Callback latency
  is recorded for both.
- Reactivation creates no new instance: the running copy is reused. The launch
  call path's actual native primitives and parameters are inspected and recorded
  against the authority trace. This keeps Koine's own activation separate from
  the application's reaction.
- A returned process identity matches the witness's kernel identity. It is
  accepted by `desktopApplication(process:)` under `desktop:read`. The process's
  real exit is then observed.
- Either control alone, and a revoked grant, cause no launch and no focus
  change. Both controls without any read capability suffice.
- With Accessibility absent, and again after it is revoked, launch still works
  and raises no consent prompt.
- The client's optional recovery is exercised separately: a desktop read plus an
  explicit focus, each under its own grants.
- If controls-only activation fails the requirement, the case stays pending. The
  measured limit goes to Antony before the case closes.
- A reusable Taskfile VM recipe exists. An evidence document lands under
  `docs/verification/`, and the spec rows link it.

## Notes

Nothing drives an application on the host. The acknowledgment is not a focus
guarantee, and the workspace path must never silently require a client yield or
a desktop read.

## Decisions (running log)

**Application: Notes (`com.apple.Notes`), macOS 26.5's own 4.13.** It ships with the system, needs no account and its first run is one welcome sheet (Continue), which the recipe completes by the window's own button. Gatekeeper: the clone starts with assessments disabled, so the recipe runs `spctl --global-enable` and records `spctl -a -vv` as `accepted, source=Apple System` with no override. Only that switch is set (not the Developer ID one `enforce_gatekeeper` also needs), because Notes is Apple's, and Koine is installed without quarantine.

**The independent witness is a new fixture, `Fixtures/LaunchWitness`, not the window probe.** It needs no Accessibility (so the absent-consent phase can be observed at all) and holds no Koine code: NSWorkspace/NSRunningApplication for who is in front, which instances run and their bundle/executable; libproc for the kernel start instant; kqueue for exit; and a `watch` of launch/activate/terminate notifications stamped on the guest clock, which the client's send/answer stamps share. Activation is placed between the two stamps from it.

**A launch request runs once.** `guest` retries the agent's false "timed out" answer, which would turn a cold launch into a reactivation. `call` in the recipe runs the client once, has it write its answer to a file, and reads the file back; only "agent not reached" (status 7) is run again.

**Grants beyond the first are made by the first, through `koineCreateGrant`.** The window scrolls; once four grants were listed the Create button sat below the window's frame and a click at its reported position hit the wallpaper (the run then showed the desktop widgets). The first grant, reader + manager, is made in the window; the rest, and the revocation, are GraphQL calls by it, as the window's own client makes them. The desktop-only grant is also the explicit-focus grant.

**Refusals are HTTP 403, not a 200 with errors.** A missing capability is refused at authorization (`extensions.phase: "authorization"`, `permissionClass: "capability"`, first unmet `desktop:control` for a workspace-only grant), a revoked credential 401 with no body. The recipe asserts those, and nothing launched or activated in any refused case.

**Finding: the receipt's process was null on most cold launches of the release build (three of the first four).** With the Notes cold launch acknowledged in ~100 ms and Notes plainly in front, the process came back `null`. A debug build (never committed) logged each step of the observation rule: every step passed except the fifth. The first fresh `NSRunningApplication(processIdentifier:)` was not `isEqual:` to the retained object, and a lookup at most 5 ms later always was (0 or 1 retries of 5 ms in five runs). A standalone probe that checked the same steps in the callback never saw it, so it is a race in the system's record of a new application, not a mismatch of process. Fixed in `Observation.swift`: only step 5 is retried every 5 ms for at most `settle` (default 250 ms, about fifty times the largest wait seen); every other step, and a lookup still unequal after `settle`, is null as before. L: an equal-on-a-later-try case yields the identity (seen to fail with `settle: .zero`), and a lookup that settles only after the bound is null. Not a design change to the rule's meaning: an unequal object is still a mismatch.

**`WorkspaceCompositionTests.denialInsideADependencyWithholdsItsNonNullFieldAndSoTheDependency` failed once in three full `task test` runs**, in the G suite the `workspace-launch` leaf already records as concurrency-sensitive. It passes on rerun; not touched here.
