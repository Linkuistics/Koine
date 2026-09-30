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

## Decisions (running log)

**The catalogue is a sealed resource, not a Swift constant.**
`App/ProviderCatalogue.json` is copied to `Contents/Resources` and sealed by the
application signature. A purpose-built host with a malformed catalogue is then a
file changed before signing, and `task check:provider-catalogue` reads the same
file. The parser is strict: an unknown key, a partial baseline, a malformed
version, two entries overlapping in either direction on an identifier or prefix,
a claim on `koine`, or a shared bundle or signing identifier is a conflicting
catalogue. Absent or unreadable is as malformed as unparsable: nothing is
invented from the bundles found.

**One entry point, and the seam is `package`.** `ProviderLoader.selectAndLoad`
takes both roots, the catalogue and the staging directory. The private seam
(`ProviderLoader.Seam`: host team, discovery order, quarantine verdict, and a
substitute for the load step) has `package` access, so the package's tests and
test hosts reach it and no client of the library does. `ProviderRoot.bundled`
lost its `approvals`: the in-application root approves a designated bundle for
the running host's own Team ID, never by a file.

**Classification is from the claim alone, before trust.** In the sealed root a
bundle is the designated one (`catalogue-bundle-mismatch` if its claim or
versions differ) or `unexpected-bundled-candidate`, ordinary providers included.
In the per-user root the exact enabled pair contests a slot, the exact pair of a
reserved-only entry is `reserved-only`, and anything overlapping a reserved name
in either direction is `reserved-identity`. The core's koine namespace stays the
core's post-load refusal, as before.

**Version eligibility is release first, then schema.** An equal or older release
never overrides, whichever schema it claims; a greater release with another schema
major, or a schema below the baseline's, is `schema-incompatible` and
`INCOMPATIBLE` (an honest unsupported schema), not `REJECTED`.

**`selected-with-refusals` is for shipped slots only, and superseded is not a
refusal.** A shipped choice with a refused same-identifier copy or a missing
designated bundle carries it and names the refused copies, versions labelled as
claims. A unique update over a healthy bundle carries no reason. An ordinary
provider's healthy row has none (the existing suite asserts an `ACTIVE` row has no
diagnostic beside a refused rival).

**Unidentified bundles report as `(unknown)`, with the bundle's name in the
diagnostic.** They were reported under the bundle's directory name; the spec's
`(unknown)` cannot collide with a provider identifier. Two existing loader tests
changed their expected provider for the two unidentified cases.

**Stable reasons for the existing failures** are listed in the spec's candidate
diagnostics section; a later core refusal carries the kebab-case of its
diagnostic and a failed start carries `start-failed`.

**`ActiveProvider.Origin.bundled` now means a selected shipped identity, from
either root**, so a shipped update publishes in the shipped position and is
an owner of its reserved names. The core's reserved list is the catalogue's
(default: desktop, for a composition with no catalogue), so the post-load
refusal of a reserved name applies to workspace, input, menus, iterm and herdr as
well.

**Staging is `<name>-<digest of origin, canonical location, content>`.** The old
content-only names can never be produced again, so a legacy entry is never
reused. Per-user quarantine is assessed of the candidate's own staged copy on
every start; nothing is cached.

**Test design.** Decision cases run the real staging, verification and selection
over copies of sealed bundles (`Fixtures/FixtureProvider/build-selection.sh`),
with the seam standing in for `dlopen`: no principal class of the `Sl` family is
ever registered in the test process, so parallel tests cannot collide on it. One
test loads an independently compiled baseline and update (`Sm`) for real.
Verification blocks on work Security dispatches to the global queues, so the
loader runs on `Harness.constructing`, one at a time (a first attempt on the
cooperative pool hung the run). Each key decision was mutated and watched to
fail: string version comparison (18 issues), tie broken by the first copy (24),
signing-identifier check removed (6).

**Compatibility host.** `KoineCompatibilityHost` is purpose-built around its
second argument's bundles and approval records: the catalogue it seals names each
with the release, schema and signing identifier it carries, and the host's team is
the record's, as the host itself is unsigned. Its usage and the pairs script are
unchanged.

**Left to the leaves that own it.** The management GraphQL fields and native
window grouping (`selection-diagnostics`); purpose-built signed hosts, fresh host
processes with markers, quarantined downloads and the alternate-team cases
(`selection-acceptance`, `alternate-team-signing`).
