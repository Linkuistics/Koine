# first-party-provider-selection-k50

## Goal

Settle how the workflow extension selects a shipped provider and an independently
updated first-party copy before launch-and-open packages the second bundled
provider. Preserve one loader, explicit approval, independent compatible updates
and the existing signing posture.

## Context

- `provider-architecture-k48`'s D7 in review commit `e968bdd97123`; the integration
  `provider-architecture-k49` repairs canonical order and failure-cascade prose
  but deliberately leaves replacement selection to this bounded design.
- `docs/specs/machine.md`, composition and loading/trust; and
  `docs/specs/workflow-providers.md`, the six shipped identities and compatibility.
- ADRs `koine-server-and-native-providers`, `resilient-provider-framework` and
  `provider-authority-follows-effects`.
- The baseline composes bundled providers first, then per-user providers, each
  group by identifier. It refuses external desktop replacement, and other
  duplicate identifiers/prefixes contest both claims. These rules do not deliver
  independent updates for an identity present in both roots.

## Done when

The spec and minimal ADR set define one deterministic policy for:

- reserved shipped identifiers and prefixes, including a shipped provider that
  is absent or rejected, without letting an external claimant evict it;
- precedence between bundled and explicitly approved same-team per-user copies,
  version/compatibility eligibility, multiple installed candidates, and invalid,
  older or rejected updates;
- which checks and selection occur before `dlopen`, and what may remain mapped
  if descriptor/schema rejection occurs later; no silent downgrade/retry that
  conceals a failed update;
- canonical composition position for the selected replacement, published schema
  and digest, and management diagnostics for selected and refused candidates;
- compatibility with existing desktop operations and conformance profiles, plus
  missing-owner rejection cascades and startup failure;
- concrete old/new bundle, approval, collision and rejection acceptance cases
  through the existing binary/public/VM seams, owned by launch-and-open.

Keep existing signing and approval checks. A changed signing posture or
incompatible `koine-desktop/1` promise is Antony's decision. Reconcile the server
ADR's independent-upgrade statement and all related spec/brief citations.

This is a load-bearing selection/trust design: cut its `review-design` sibling
before the launch-and-open node once the artifact exists; the review commissions
integration there if warranted. The design/review chain must settle before
launch-and-open consumes it. Do not implement loader changes in this leaf.

## Notes

One bounded question, not a new provider manager or installation UI. Use the
existing install roots and explicit approval artifacts. The extension's six
provider responsibilities and static effect conjunction are inputs, not reopened
layout questions.
