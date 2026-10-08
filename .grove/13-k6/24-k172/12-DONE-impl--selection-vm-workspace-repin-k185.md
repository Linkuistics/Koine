# selection-vm-workspace-repin-k185

## Goal

Re-run the selection acceptance's V seam against workspace 1.0.1, so that the
record `docs/verification/selection-vm.md` says what the signed, notarized hosts did
with the repaired workspace as the real baseline and as the designated bundle, and not
only with 1.0.0.

## Context

- Found by `action-repair-compat-k179`. That leaf re-pinned every N and G selection
  fixture to 1.0.1 (`task selection:updates`, `selection:decisions` and
  `selection:failures` pass, and `selection:mutation` sees every mutation) but did not
  run `task selection:vm`: it needs `task selection:vm-hosts`, which signs, **submits to
  Apple's notary service** and staples each host and update, and a Gatekeeper-enforcing
  TestAnyware VM. `selection-vm.md`, and the "V established" statements in
  `docs/specs/machine.md#selection-acceptance`, are for the 1.0.0 workspace.
- `scripts/verify-selection-vm.py` takes its scenarios from the table of
  `scripts/verify-selection-updates.py`, so the real-provider rows already expect
  workspace 1.0.1 and its profiles `core-desktop-workspace-*-extension-host`; the V
  fixtures (`.build/selection-vm`) are built from the same sources, so they need
  rebuilding.
- `docs/verification/workspace-compatibility.md` ("What this does not claim").

## Done when

- `task selection:vm-hosts` and `task selection:vm` pass with workspace 1.0.1 as the
  bundled baseline and the 1.1.0 update of it, on notarized hosts, and
  `selection-vm.md` and the V statements of the affected rows of the Machine spec say so.

## Notes

- **Ask Antony before notarizing.** The notary submissions are outward-facing and the
  stored credential is his; confirm that spending them on this is wanted, or that the
  V seam for the first-party workspace is to be left at 1.0.0 with the compatibility
  pairs standing in for it.

## Decisions (running log)

- **Prepare before requesting notarization.** Run the existing
  `task selection:vm-hosts -- --unnotarized` recipe to build and sign the six
  purpose-built hosts and two real updates. This preparation submits nothing to
  the notary service and supplies no V acceptance. The next outward-facing step
  is the normal recipe's eight notary submissions using `koine-notary`, subject
  to Antony's explicit approval as required above.
- **Keep the existing scenarios and pins.** The V driver imports the re-pinned
  N/G scenarios; the production catalogue designates workspace 1.0.1/schema
  1.0.1 and its real update is 1.1.0/schema 1.0.1. The matching repair profiles
  already exist. A full V run, rather than a filtered subset, owns the acceptance.
- **Signed preparation verified on 2026-10-08.** The signed-only recipe exited
  successfully; `.build/selection-vm/notarization.json` records six hosts and
  `notarized: false`. The built production catalogue and workspace manifest
  both pin 1.0.1/schema 1.0.1; the update manifest pins 1.1.0/schema 1.0.1 and
  declares `first-party-selection-v1`. `testanyware doctor --json` passed and
  the macOS golden image is available. Approval for the eight Apple submissions
  and the subsequent full VM run was requested; no submission has been made.
- **Antony approved the submissions and full V run.** His reply, "yes", authorizes
  the eight Apple notary submissions using `koine-notary` and the subsequent
  unfiltered isolated selection VM run. Proceed with the existing recipes.
- **All eight submissions accepted.** `task selection:vm-hosts` exited 0;
  `.build/selection-vm/notarization.json` records `notarized: true`, the eight
  submission IDs, and the resealed code-directory hashes. All six hosts were
  stapled, their tickets validated and their strict signatures checked by the
  recipe. Transcript: `.build/selection-vm-hosts-k185.log`.
- **Measure unchanged inputs in the build tree and the guest.** The unfiltered V
  run uses macOS 26.5 (25F71), arm64, with both Gatekeeper assessments and
  Developer ID enabled. Digest 908 source/artifact files before and after V;
  also digest the 669 staged guest inputs (App/Fixtures metadata, design/profile
  files, Python drivers, conformance tool/framework, fixture bundles, host
  bundles and notarization record) before the scenario driver, checking them
  again when the driver writes its exit file. The digest check has its own
  output, separate from the scenario transcript and results.
- **Discard the first V attempt: two concurrent result writers.** The wrapper
  reported `mkdir: .../selection-run.started: File exists`; a guest `pgrep`
  showed two live `verify-selection-vm.py` processes (1452 and 1997), both
  targeting `vm/results.json`. The main launch lacked the `|| exit 0` guard
  that `guest_bg` already uses, so a false agent timeout retried the launch.
  Stop the clone and retain the transcript
  `.build/vm-verify/selection-vm-20261008T172939.log` as invalid measurement,
  regardless of green partial checks. Make that same directory guard govern
  the scenario launch, prove retry/concurrent launch idempotence with a local
  executable regression check, then restart the full V run using the existing
  notarized hosts and updates. No further notary submissions are needed.
- **Launch repair verified red then green.** The executable regression check
  ran the recipe's actual `guest()` argument with two concurrent calls and a
  completed retry, using a real shell action. Before repair it observed three
  result writers; after adding the existing `mkdir ... || exit 0` guard it
  observed one writer and retained that driver's nonzero exit status and log.
  `task selection:vm-check` runs this check, `bash -n` and ShellCheck and passes;
  it is now a dependency of `selection:vm`. No provider or fixture binary
  changed, and the next full run reuses the accepted notarization record.
- **The restarted full V run is accepted.** `task selection:vm` exited 0 on
  macOS 26.5 (25F71), arm64: 133 host runs, 2,090 passing checks, all 182
  never-ran assertions controlled, all owned reasons observed, no unexpected
  system dialog, and one live scenario driver observed. The 124 scenario/order
  runs and nine extra runs match the full recipe item by item. Exported JSON
  equals the independently downloaded record. All 909 build-tree and 669 guest
  input digests match before/after. The clone was stopped. Evidence is in
  `docs/verification/selection-vm.md#workspace-101-rerun`; the second-team
  certificate row remains pending in its existing root leaf.
- **The close cascade reaches launch-and-open-k6.** The long-locations-k172
  subtree delivers its charter: the retained independent 1.0.0, each action
  stage and receipt identity, the shipped 1.0.1 and its compatibility pairs,
  the target/application V subjects under k188's scoped native coverage limit,
  reusable tasks, and now the selection V repin. Launch-and-open-k6's other
  subtrees deliver the twelve launchers, URL/path/reveal operations, installation
  selection, grants/disclosure, binary/profile and VM acceptance. Its explicitly
  externalized protected-default-open-k89, reveal-app-bundle-notice-k90,
  alternate-team-signing-k80 and account-owned dia-url-page-load-k88 remain live.
  Promote the action-only release/selection evidence and these boundaries to
  the root brief; actual-search handoff stays with app-and-file-search. The
  existing authority, selection and descriptor-relative ADRs remain current.
- **No in-session reviewer spent.** The narrow launcher repair is conclusively
  checked by its red/green executable seam and the successful full V rerun;
  the remaining changes record the observed evidence and close the tree.
