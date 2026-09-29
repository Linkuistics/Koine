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

## Decisions (running log)

**Authority follows effects, with six provider identities.** Keep `desktop`
for windows/displays, pointer and system media; add `workspace` for installed
applications/files and launch/open/reveal; `input` for keystrokes and owned
holds; `menus` for application menus; and `iterm` and `herdr` for their addressed
native commands. Clipboard writes stay client-owned. Separating workspace
discovery avoids giving existing desktop-read grants file-search access.
Input and menus obtain their own targets from an externally captured process
incarnation, so their ordinary mutations need no desktop reference or control.
The existing foreign-reference rule is retained, including its cost when a
client actually passes another provider's reference.

**A small additive authorization extension is necessary for mixed effects.**
Launch/open/reveal can activate applications, and an integration command may
also focus a desktop window. Merely putting those operations in another plugin
would bypass the effect boundary. Add an immutable, unconditional list of
additional provider capabilities to field registration, enforced by the host
in preflight and at dispatch/publication. Retain each field's existing own
read/control authority and foreign-reference checks. This requires a framework
minor and required feature, not finer capability names or a new public contract
version. A dummy reference argument solely to smuggle an extra grant into
preflight is rejected. The detailed interaction-lifetime extension remains
`held-interactions`' work.

**Dependency absence uses typed results.** New provider fields use documented
availability/result objects for unavailable prerequisites, with no successful
value or effect. Stale selections keep `unavailable`; successful empty lists
remain successful; capability/native-consent refusals keep `permission`. No
new error kind or provider-failure case is needed. Dependency checks are
repeated on the action path; an earlier readiness query is not authorization
or a promise the prerequisite still exists.

**Two specs, one current contract family.** Keep `machine.md` for shared
transport, composition, authorization, errors, native extensions and desktop;
add `workflow-providers.md` for extension ownership and the cumulative
operation-to-capability trace. Future increments extend these by topic rather
than adding a spec per plugin. Mark extension obligations as designed and
pending implementation, preserving 0.1.0's served evidence. Keep
`koine-desktop/1`; additive SDL moves the schema digest. General cross-provider
identity remains excluded. The herdr design owns a bounded, revalidated host
association without treating a reference from one provider as another's.

**Verification instruments and review route.** The bounded source path is
field metadata → provider contribution → mutation preflight and resolver
admission. Its tests already demonstrate foreign-reference authority and zero
calls after preflight denial. Tier-2 graph evidence was checked against index
generation `2026-09-29T10:36:20Z`; docs are excluded and were read directly, and
Engine.swift's missed line 295 was read directly. The graph's heuristic call
edges included unrelated same-name functions, so those edges are not relied on.
The proposed set union and dependency closure are explicit contracts to test in
the pathfinder. No formal model is commissioned: the difficult remaining
question is completeness of the effect allocation, better contested by a fresh
design reviewer and then real native evidence. An adversarial `review-design`
leaf will read this artifact before dependent work, replacing an in-session
reviewer rather than duplicating one. It must challenge target independence,
mixed effects, compatibility, dependency classification and coverage.

**Effect boundary includes hidden native calls, not application sandboxing.**
The grant authorizes Koine's requested native primitive and its documented
semantics. An app may open a window because its menu item was invoked, or switch
Spaces because input was delivered. That response is inherent to general
menu/input authority; it does not permit Koine to add an activation/focus call.
Workspace open/launch explicitly permits activation and therefore declares
desktop control. The review must contest this boundary against the independent
grant requirement rather than assume all application consequences can be known
before invocation.

**Presentation verification limit.** `task design:workflow-render` generated
the three exports, inspected as raster previews. `task check:docs` passes;
the manifest, all source/export URLs and the served HTML passed structural/HTTP
checks. An inventory extraction matched every requirement row to the trace and
detected a deliberately removed Integration setup row. The requirements, spec,
manifest and referenced source/export digests stayed unchanged during that
check. Browser surfaces were unavailable (`iab` absent, browser inventory
empty, native Safari access timed out), so the actual viewer's deep-link,
mobile and dark-mode rendering is not verified in this session. The review
should inspect that presentation when browser access is available. This is not
native acceptance evidence; no real application workflow was exercised.
