# settings-call-order-k3

## Goal

Apply the activation-first Settings call order of commit `561dbf6c` again.
Record the happy-path scope of Antony in the documents that bind the repair.

## Context

- Commit `561dbf6c` holds the candidate. The show path requests activation once,
  and then the key and front window.
- Commit `06ccc06d` returned the code to the released order. Its file list maps
  the documents that state the current order.
- The running log of `plan-k1` holds the scope decisions of 2026-11-25.

## Done when

- The Settings show path requests activation once, and then the key and front
  window. Its comment cites the spec and issue 15.
- The build and the existing headless checks pass. They cannot observe focus.
- The "Current decision" section of the spec records the new scope. On
  2026-11-25, Antony chose the happy-path repair instead of a new run of the
  five-slot protocol.
- That section states the acceptance bar and its limit. One clean run of the
  menu-bar check accepts the candidate, and the claim covers only that run.
- Each living document that states the current call order states the
  activation-first order.

## Notes

Historical records stay unchanged. Examples are the evidence files of
`settings-released-call-order-k184` and the E01 results.

The dormant diagnostics stay in the product, as the spec records.

No review leaf exists in advance. At the end, cut one only if the change turns
out to need an adversarial read.

## Decisions (running log)

The show path uses the call order of commit `561dbf6c` again. The comment cites
the "Current decision" section of the spec, issue 15 and the two Apple pages. The
Apple documentation lists `activate()` from macOS 14 and neither call as
deprecated, so both calls suit the macOS 26 target.

The verification matches the precedent of k52 and k184. `task build` and
`task check:settings-activation-interval` pass. The full `task test` did not run,
because it also signs and approves fixture bundles, and no test there observes
focus.

The spec records the scope in two new paragraphs of its "Current decision"
section. One states the happy-path choice of 2026-11-25. The other states the
acceptance bar of one clean run and the 78% limit of that claim. The alternatives
table of the spec states that the code applies the candidate again.

The living documents are the spec, `docs/verification/menu-bar-vm.md`, the
settings-activation verification README, the architecture discussion README, its
two diagram manifests and two Mermaid sources. The application record
`ORDERING-APPLICATION-RESULTS.md` is a dated history file, so it stays unchanged.
The sentence in `README.md` names `activate()` before `makeKeyAndOrderFront`, so
it already agrees.

`task check:docs` fails on one link that this leaf did not write. The link in
`ORDERING-PROVENANCE-RESULTS.md` points into a grove tree that `finish-k11`
removed, and the failure is present at the parent commit `cd9f8679`.

No review leaf is cut. The call order is the one that the independent design
review of 2026-10 accepted, and the change is a reversible swap of two calls.
