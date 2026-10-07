# long-search-result-actions-k169

**Reviews:** long-search-result-actions-k168
**Creator:** run 4fe4883f-90d0-49ba-b1d9-c81ea7f0fe70

## Goal

Load-bearing adversarial re-read of the v1 long-location action contract as
integration k168 left it, before planning k167 builds on it. Findings only; no
fixes.

## Context

- k168 applied review k166's eight findings, then its one in-session reviewer
  found seven more defects in the rewritten stages, which k168 also fixed. That
  second need is why this review exists: the fixes are substantive and were not
  re-read. Read k168's running log and its commit diff.
- `docs/specs/workspace-launch-and-open.md#long-location-action-boundary`
  (resolution table, name limits, cycles, reveal's root, "Order of target and
  application stages", hand-off limit, subjects),
  `docs/design/workspace-action-repair-schema.graphql` (three appended mutation
  descriptions), `docs/adr/filesystem-access-is-descriptor-relative.md`, the
  client guide, glossary and `workspace-long-locations` view.
- The retained short-path logic and tests are the contract the stages must keep
  below the limit: `Providers/WorkspaceProvider/Logic/Selection.swift`,
  `OpenPath.swift`, `RevealPath.swift`,
  `Providers/WorkspaceProvider/Sources/NativeWorkspace.swift` and
  `Tests/WorkspaceProviderLogicTests/`.
- Antony's v1 refusal and the descriptor-relative access decision are settled;
  review the design that implements them, not the decision.

## Done when

- Every finding names the artifact, the defect and its consequence. Attack these
  doubts in particular:
  - Below the limit, does any retained outcome or precedence still change —
    application-location cycles and impossible names now `failed`, candidates
    compared to the first match, a candidate's metadata no longer read,
    default-handler lookup back on the literal target, reveal's Finder mapping?
  - Is the cycle state (containing directory, link text, exact pending suffix)
    sound and sufficient, and is reporting a self-extending link as the budget
    an honest reading of the boundary's "demonstrably unresolvable cycle"?
  - Does examining the final component with `fstatat` from its parent match the
    accepted `stat` for permissions, trailing slashes, final `.`/`..` and the
    reveal `lstat` root rule, including `/Volumes/<link>/`?
  - Is the ASCII-only impossible-name proof the right conservative line?
  - Do the stage order, hand-off limit placement and SDL descriptions agree
    with each other and with the outcome table, guide and view?
- If findings warrant action, cut the integration where `pick` reaches it next
  (before long-location-actions-k167). Otherwise retire with none.

## Notes

Native, binary, public and signed-VM acceptance stay with planning k167. No hand-off
workaround, shorter search ceiling, consent/signing change or long-path
application support is authorized.
