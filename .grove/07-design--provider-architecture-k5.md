# provider-architecture-k5

## Goal

Settle the cross-cutting architecture that every increment builds on:

- which providers exist, and how their capabilities keep keystroke delivery,
  menu invocation and window focus separately grantable;
- who authorizes each other effect in the agreed inventory;
- how a client tells an absent dependency from a stale target, an empty result
  and a permission refusal;
- how the served spec and the server-boundary ADR admit the agreed launch,
  search and setup extension.

## Context

- `docs/requirements/modaliser-workflows.md`: "Ownership and existing
  constraints", the separate-grant requirement and the acceptance table.
- `docs/specs/machine.md`:
  - "Composition and operation placement". A field whose arguments hold
    another provider's reference also requires that owner's capability of the
    field's own class. Under that rule, a menu or input mutation taking a
    desktop application or window reference would also need `desktop:control`,
    which is window focus.
  - "Grants and management": capabilities are `<provider>:read` and
    `<provider>:control`.
  - "Errors and partial data": the closed `extensions.kind` set.
  - "Native extensions": framework minors and required features.
  - "Scope".
- The framework's field authority is only `read` or `control`.
- ADRs `koine-server-and-native-providers` (broader discovery excluded),
  `resilient-provider-framework`, `machine-references-as-uris` (cross-provider
  identity open) and `bearer-grants-and-live-revocation`.

## Done when

- An ADR records the provider layout and capability model, with rejected
  alternatives. Candidates include one provider per authority, finer named
  capabilities in the framework, or another mechanism. It shows how an
  operation on an application or window can run with only input or menu
  authority, without also requiring `desktop:control`. The alternative is to
  change the composition rule deliberately.
- An authority allocation covers every inventory row and every effect the
  requirements name. The effects are window geometry, Space switching, display
  focus, pointer movement, media, launch/activate, file and URL opening,
  reveal, file and application search, and clipboard writes, allocated to
  Koine or the client. They also include keystrokes, held-modifier
  interactions, explicit menu opening, menu invocation, iTerm and herdr
  actions, and prerequisite setup. The allocation names the client
  responsibilities. It lives where each increment extends it with its concrete
  operations, forming the operation-to-capability acceptance trace.
- The spec states how these four cases stay distinguishable: an absent
  dependency or unavailable integration, a stale target, an empty successful
  result, and a permission refusal. The mechanisms are schema-level results, an
  additive provider-reported reason, or a contract-version change. The last is
  Antony's decision; stop and ask with a recommendation before choosing it.
- The spec's Scope and the server-boundary ADR admit the agreed launch,
  installed-application search, file search and prerequisite discovery/setup.
  Every other exclusion stays in force. Cross-provider identity is decided here
  or left to the `herdr` increment, with the constraint it must meet stated.
- The spec set's shape is decided: whether new providers extend `machine.md` or
  get their own specs. The contract-version, schema-conformance and
  framework-minor consequences are stated.

## Notes

This is an agreement point for months of increments; judge an adversarial
`review-design` read as your last act. Settle authority, boundaries and
classification only. Each increment's own design owns its API shape, so do not
design launch, menus or terminal operations here beyond what allocation needs.
The interaction lifecycle belongs to `held-interactions`.

Reuse the current framework unless a concrete requirement proves it
insufficient; new mandatory behavior is a framework minor with a required
feature. Do not reopen workflow scope, menu choices or test seams. Use
`linkuistics:codebase-design`; add new terms to `CONTEXT.md`.
