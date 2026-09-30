# freeze-failures-k84

## Goal

Accept, at N and G, a frozen selection that fails after choices freeze, and the
principal conflicts among frozen selections; leave the shared harness library and
restart machinery the node's other two leaves reuse.

## Context

- The node brief `selection-failures-k64`: its "Freeze" and "Principal
  conflicts" conditions. Machine's rows "Frozen update fails principal check,
  dlopen, descriptor or schema with healthy alternatives" and "Shipped update
  principal conflicts with another shipped bundle; ordinary candidate conflicts
  with shipped selection or host class", and the later-failure part of
  "Diagnostic completeness".
- `scripts/verify-selection-decisions.py` and `docs/verification/selection-decisions.md`:
  the harness `selection-decisions-k63` built.
- `Sources/KoineProviderLoader/ProviderLoader.swift`: `principalCollisions`
  (before any `dlopen`) and `load` (`dlopen`, principal class, descriptor).
  `Sources/KoineCore/Composition.swift`: schema and registration refusals.

## Done when

- The decisions driver's reusable parts live in one library that both drivers
  import; `task selection:decisions` gives the same rows as before.
- The library can restart a host over the same data directory after an action
  (remove a copy, replace one), with a fresh marker log for every phase.
- A frozen shipped update that fails its principal check (a host class and a
  system class), `dlopen` (a private dependency that will not load), principal
  class (absent, not a factory), descriptor or schema (invalid SDL, a name
  outside its prefix) leaves its healthy alternatives (the bundled baseline and a
  lower update) unloaded and unstarted, stays `SELECTED` and identifiable, and
  recovers by removal or repair and restart.
- A shipped update against another shipped bundle (and two shipped updates) are
  refused symmetrically; an ordinary claimant of a shipped principal is refused
  alone, with the shipped owner running; ordinary claimants of one principal and
  of a host class are refused. Nothing is retried.
- A failed frozen selection's diagnostic keeps the earlier competing refusals.
- Machine's two rows and the later-failure part of the completeness row link the
  evidence in `docs/verification/selection-failures.md`.

## Decisions (running log)

**Decomposed from `selection-failures-k64`.** The node needed a shared harness library, about fifteen new fixture cases, cascade hosts, restart and verdict-injection machinery and conformance profiles; cut along Machine's rows into this leaf, `duplicates-cascade-k85` and `digest-restart-k86`.

**The harness is a library, not a copy.** `scripts/selection_harness.py` holds the scenario vocabulary, `HostRun`, the invariants, the per-phase checks and the control pairing; `verify-selection-decisions.py` keeps only its scenarios. The move was measured: the decisions run before and after gave the same per-run checks, unloaded installs and markers, with the three post-load claimants declared twins of `od`.

**A scenario has phases.** An action on the stopped host's data directory (`remove`, `replace`, `install`) then a restart, which is a new process and a new marker log. Recovery from a failed frozen choice is exactly that, and nothing else.

**A partly-run image is controlled by its binary or a twin.** A failing update that loaded and never started cannot be its own control. Where it is the healthy update's binary with an edited manifest the control exists already; the two whose SDL the core refuses are declared twins of the healthy update (`TWINS`).

**`dlopen` failure through a private dependency, not a second binary.** One main image, one bundle shape, two `libFixturePrivate.dylib`s: one loads, one links a `/usr/lib/…` library that does not exist. A `/usr/lib` path is a system path to the loader's dependency check, which does not look for the file, so only dyld refuses it and the loadable twin is a real control for the same compiled main image.

**The host class is a class in the host's own image.** `KoineSelectionHostClass` in `Fixtures/SelectionHost/main.swift`, beside `NSObject` for a system class.

**The cascade clause of the principal-conflict row moves to `duplicates-cascade-k85`.** Nothing here names another provider as an additional-capability owner. Machine's row says so.

**Instruments.** Five mutations of the loader, each seen red in every host run of each named scenario, added to `scripts/check-selection-mutations.py` (which now selects the driver per mutation).
