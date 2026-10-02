# application-installations-k78

## Goal

Accept the Multiple copies and installation row at G, N and V for both
application launch and named-application document opening.

## Context

- The workspace spec's application-selection paragraphs and the Multiple copies
  and installation row.
- The shared application input implemented in `workspace-launch-k59` and reused
  by `open-path-k75`.

## Done when

- A fixture application is registered at two locations by a reusable recipe.
- Unconstrained launch and named-application opening reuse a running copy at the
  other location. An installation path addresses exactly the chosen copy, even
  while the other runs.
- The failure cases each produce their specified result:
  - a missing or unregistered copy;
  - stale registration after deletion;
  - an identifier mismatch;
  - a registered present copy in the Trash, which stays eligible.
- Symlinked and Unicode-variant spellings are compared by native file identity.
- Metadata denial is `failed`.
- A bundle-less program has no named-selector route, and default-handler use
  remains distinct from it.
- Any L gap for inspection failures that the earlier leaves left is closed here.
- The spec row links the evidence. It is the constrained form that
  `app-and-file-search` will use for a chosen installation.

## Decisions (running log)

- **Observation by one guest process.** The guest agent costs seconds per exec and reports a false timeout for about a quarter of them, which made a first version (about fifteen execs a request) take ten minutes a case. Each case is now one detached guest script (`scripts/vm-installation-request.py`) that takes its own lock, so a retried exec cannot send a request twice, and its one JSON answer is read once.
- **Which copy ran is the copy's report.** `Fixtures/InstallationFixture` logs its own label and what it was handed; the witness supplies only the kernel identity and bundle path of the receipt's process. A receipt passes only if both agree.
- **Launch Services drops a registration the instant its bundle is deleted**, so "stale registration after deletion" cannot leave a listed-but-missing registration. The stale record that does survive is a bundle whose Info.plist is gone; the provider inspects the bundle rather than trusting the registration and reports `APPLICATION_IDENTITY_MISMATCH` (the bundle declares no identifier). Recorded in the spec and the verification document, not forced.
- **Launch Services re-registers a bundle it finds under the home folder on its own**, so each unregistered case unregisters the copy and reads the answer in the same guest process right before the request, failing the run if it will not stay so.
- **The constrained selection asks both registration answers.** The VM showed `urlForApplication` returning a copy moved into the Trash while `urlsForApplications` omits it, so a path-chosen Trash copy was refused. Fixed in `Selection.swift`, red at L and G first. Observed on macOS 26.5, not documented by Apple (cited in the code as such).
- **An unreadable Info.plist is `failed`, not a mismatch.** `Bundle(url:)` answers nil for both no-identifier and unreadable; the adapter now tells them apart by `stat` and `access` on the one path (no content read). Red at N first.
- **The Trash case is a platform limit, not produced at V.** Launch Services deregisters a registered copy within about 50 ms of its move into the Trash (three rounds, about 790 lookups each; running copies and `.Trashes` also dropped in unrecorded probes), so no request can meet it. V records the timeline and that requests after the move report `APPLICATION_NOT_INSTALLED`; eligibility is held at L and G with the answers arranged as observed. The spec says so. I did not cut a leaf: nothing in the platform lets a later leaf produce it, and the rule is held by tests.
- **A registration pointing into an unreadable folder or bundle** is likewise unreachable at V (Launch Services stops reporting it); denial is shown for the chosen path at V and for the registered path at L and G.
- **`denialInsideADependencyWithholdsItsNonNullFieldAndSoTheDependency` is flaky** (failed in one full run and one of three suite runs here; passes alone) and is already owned by `stabilise-dependency-denial-test-k87`. Not touched.
