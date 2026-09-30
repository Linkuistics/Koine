# selection-updates-k65

## Goal

Accept independent updates across binary generations at N and G: real,
independently built old and new hosts and providers, the trust refusals that
fall back visibly, candidate-specific staging, and mixed releases.

## Context

- `docs/specs/machine.md`: the rows this node's brief assigns here.
- The reusable pre-extension host build from `additional-capabilities-k56`.

## Done when

- Old host with old desktop, and new host with an independently compiled old
  designated baseline: existing desktop operations, errors and grants work, and
  both core + desktop profiles pass.
- A selection-aware host with a separately approved newer desktop update, and
  one with a newer workspace update: exactly one image, factory and start marker
  per slot. The unselected bundle never loads. Management names the update, and
  real operations work without rebuilding the host.
- A pre-extension host is given newly published updates with normal and with
  renamed principals. It refuses `first-party-selection-v1` as `INCOMPATIBLE`
  before load, with no update marker, and bundled desktop stays usable. The
  extension host refuses a per-user update lacking the feature as
  `selection-feature-required`.
- Each trust refusal has no initializer marker and falls back to a visibly
  diagnosed lower or bundled selection:
  - missing approval or wrong Team ID;
  - unsigned, ad-hoc or tampered seal;
  - escaping location;
  - incompatible framework, feature, OS or architecture;
  - failed quarantine assessment.
  Stage and quarantine recovery is exercised. Real second-team signing passes
  only if a second team's certificate is available; otherwise its N and G parts
  stay pending for `alternate-team-signing`.
- An approved same-team fixture claims a reserved pair and a high release under
  a fixture signing identifier. The production catalogue refuses it as
  `signing-identifier-mismatch`, and the valid release stays selected. A test
  catalogue admits it. A correctly identified compatible release needs no new
  hash approval.
- Equal bytes and basenames in both roots stay candidate-specific when staged in
  both orders, including across restarts after the host catches up to an update.
  Bundled loading never inherits per-user quarantine. A legacy shared staging
  entry is never reused.
- Mixed desktop and workspace releases built from reused helper source have a
  disjoint private-image module and runtime-class inventory across identities
  and the host, except the single host framework. Each executes its own expected
  implementation.
- Conformance adds the selected-update profiles.
- Machine's table links the N and G evidence for these rows.
