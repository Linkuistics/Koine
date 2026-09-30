# provider-selection-k57

## Goal

Make the native loader selection-aware. One invocation over both installation
roots and the sealed host catalogue discovers, stages, verifies and selects at
most one candidate per reserved identity before any provider code loads. Desktop
is enabled at its packaged values; workspace, input, menus, iterm and herdr are
reserved-only for now.

## Context

- `docs/specs/machine.md`, "First-party provider selection": "Reserved
  identities", "Eligibility and precedence" and "Selection before execution".
  Also "Loading and trust".
- `docs/adr/first-party-provider-selection.md`, and the selection and
  publication views in the architecture viewer.

## Done when

- The application seals a host catalogue. Desktop is enabled with its designated
  bundle, bundled release and schema versions, and release signing identifier.
  The other five identities are reserved-only.
- A malformed or conflicting catalogue publishes core management alone, with a
  catalogue diagnostic. The approval Team ID derives from the verified running
  host signature. An unsigned or ad-hoc host admits no shipped candidate.
- Selection follows the spec's precedence table:
  - only the exact identifier/prefix pair claims a slot;
  - reserved names are excluded from other claimants, including declarative
    SDL names;
  - the designated bundle must match its catalogue entry, and unexpected bundled
    candidates are refused.
- Per-user updates need all of:
  - the approval record;
  - the release signing identifier, read from the staged signature;
  - `first-party-selection-v1`;
  - a numerically greater release;
  - the same schema major, with a schema version at least the baseline's.
- A tied greatest group is refused and removed, and the calculation repeats.
  Aliases of one canonical bundle count once. Choices freeze before a batch
  principal-name check, and nothing is retried after freezing.
- Staging is candidate-specific: origin, canonical location and content. Legacy
  shared staging entries are never reused. Per-user quarantine assessment is
  never skipped by cache reuse or inherited by the bundled copy.
- The host supplies `first-party-selection-v1`. The selection calculation is
  separate from loading effects, so native tests can substitute candidate sets,
  orders and verdicts at a private seam while the real verifier and loader run.
  No public test API is added.
- Selections load in canonical order and reach the core as core, then shipped
  identities sorted by identifier, then ordinary per-user providers. Each
  candidate keeps one immutable report through every phase, carrying the
  spec's stable reason.
- N tests cover the principal decisions: numeric precedence, ties with lower or
  bundled fallback, equal and older copies, a missing selection feature, a
  signing-identifier mismatch, a reserved claimant, and no retry after a frozen
  failure. The signed application still loads desktop, and every existing suite
  passes.
- A Taskfile check compares each enabled catalogue entry with the signed
  packaged bundle's actual signing identifier and versions, not only its manifest.

## Notes

Unsigned test hosts have no team. Keep the existing suites meaningful by
supplying a catalogue and a verified team through the private seam. The full
matrix belongs to `selection-acceptance`. That includes purpose-built signed
hosts, fresh processes and marker controls.

The management GraphQL fields and window grouping are
`selection-diagnostics`'s. The reports produced here must already carry
everything that leaf will publish.

Selection replaces the baseline "external desktop is refused" rule for reserved
identities only. Other duplicate claims still refuse both claimants.
