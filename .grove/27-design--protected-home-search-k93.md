# protected-home-search-k93


## Goal
Settle with Antony whether explicit partial home search under the current
protected-traversal policy satisfies the baseline, or whether protected home
discovery needs a separately approved consent/setup contract. The design can
return ordinary filenames honestly without that approval; the full baseline
must not close around an unaccepted platform limit.
Also settle whether the eventual default-search work bounds provide useful
coverage for the agreed application/home workflows. Protected-scope exclusion
and order-dependent sampling are different limits; approval of one does not
approve the other.



## Context
- `docs/specs/workspace-search.md`, roots/coverage and test seams.
- `docs/verification/search-discovery.md`: signed hardened Koine prompted on
  Desktop/Documents/Downloads directory traversal and on scoped Spotlight;
  neither query startup nor result count diagnosed index availability.
- `docs/verification/protected-path-metadata.md`: metadata permission does not
  establish traversal; handler lookup prompted. `protected-default-open-k89`
  settles document default opening, a different operation. Coordinate any
  chosen setup rather than inventing separate conflicting consent identities.
- Application/file search's implementation acceptance, available by this late
  leaf, and the cumulative workflow trace.
- `app-and-file-search-k94` findings S1/S2 and `app-and-file-search-k95` triage:
  the original 512-record DFS proposal can stop inside /Applications and never
  visit later defaults. Default discovery/resource design must be reworked
  before planning and acceptance; use its measured final coverage here, not
  one Mac's inspection counts as an acceptance result.

## Done when
- Antony chooses between accepting and disclosing the explicit partial home
  domain (the recommendation under unchanged posture) and requiring protected
  traversal through separately designed, prompt-free readiness plus explicit
  Koine-owned setup. Record the accepted boundary in durable requirements/spec.
- A setup choice fixes exact consent identifiers, scopes, acquisition and
  revocation diagnostics with Antony before relying on them; externalize its
  implementation and signed-VM acceptance through planning, not this leaf.
- The search acceptance/trace records the choice and its remaining live work;
  baseline acceptance cannot treat unknown/blocked scope as a complete pass.
- Any accepted weakening of application/home coverage states the actual searched
  domain and bound-driven omissions with Antony. Do not infer acceptance of an
  arbitrary bounded sample from the protected-traversal decision.

## Notes
This is the new protected-traversal limit, not a repeat of the earlier workflow
interview or the default-opener decision. No new consent, entitlement, usage key
or content-type handler substitution has been approved. An index alternative
does not remove the measured prompt or establish inventory coverage.
