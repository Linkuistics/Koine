# reveal-locations-k174

## Goal

Reveal resolves its target location component by component, so an extant
location is never reported missing, and refuses a location of 1,024 bytes or more
at the application hand-off. This leaf lands the walk itself and every
resolution row, with reveal as its first consumer. It starts by measuring whether
the walk prompts, because the answer decides whether the ADR stands.

## Context

- `docs/specs/workspace-launch-and-open.md#resolving-an-action-location`,
  `#application-hand-off-limit`, `#obligations-from-earlier-descriptor-walks`,
  and the order of stages (stage 1, the target; and reveal's own root rule).
- `docs/adr/filesystem-access-is-descriptor-relative.md`.
- `Providers/WorkspaceProvider/Sources/NativeWorkspace.swift` `inspectPath`
  (whole-path `stat`, `lstat`, `realpath`; `unavailable` maps `ELOOP` and
  `ENAMETOOLONG` to absence, which is the defect) and
  `Providers/WorkspaceProvider/Logic/RevealPath.swift`, `Native.swift`.
- `docs/verification/protected-path-metadata.md` and the `fixture:protected-path-metadata`
  tasks for the first-use measurement harness; `docs/verification/long-action-route-prototype.md`
  for k134's walk, which prompted at Documents in read mode.
- `docs/verification/reveal-path-vm.md` for the retained reveal outcomes.

## Done when

- **First, before the rest is built:** the walk's own `openat(O_SEARCH)` /
  `fstatat` / `readlinkat` sequence is measured in an isolated VM on a fresh
  first-use Desktop, Documents and Downloads, through the existing protected-path
  probe harness, and either does not prompt (recorded in a verification note) or
  does. **If it prompts, stop, record it and return to Antony; build nothing else
  and add no whole-path fallback.**
- The walk follows the spec's table exactly: search-only handles, no listing, no
  file opened, one single-component call per step, at most two handles held and
  both closed before submission, `.` skipped, `..` physical, links expanded from
  their own text up to 32 times, trailing slash demanding a directory, the final
  link followed, the final component examined and never opened. It reports the
  literal spelling, each post-expansion remainder, the resolved spelling, the
  device and inode and the type. It lives in a form the real shipped code is
  tested through, not a copy of it.
- Planner mapping, at L with the substituted adapter: absent is `PATH_NOT_FOUND`;
  an established impossible component and an established cycle are absent;
  link budget, any other `ENAMETOOLONG`, `fpathconf` returning -1, a link read
  twice with different text and any denial are `failed`, naming component and
  cause. A later platform `ENOENT`, `ELOOP` or `ENAMETOOLONG` about a location the
  walk found is `failed`. The accepted reveal order, Finder check and
  acknowledgment are unchanged.
- The limit: after resolution the literal path, every expanded remainder and the
  resolved path are compared in pathname bytes without the NUL; 1,023 is handed
  over, 1,024 is refused, with guidance naming the stage, the spelling and its
  byte count. An over-limit target gets no further pathname call.
- Reveal's root rule keeps `lstat` on the literal text: `/`, `//`, `/.`, `/..`,
  `/var/..` and a link to `/`, with and without a trailing slash.
- Walk tests (supporting evidence, not N) exercise the walk's own shared source
  directly on host fixtures built component by component: every resolution row at
  short and about 1,500-byte depth; the 1,023/1,024 boundary for a literal path, a
  short literal with a long expansion and the resolved spelling; 31- and 32-link
  chains that resolve and a 33-link chain that is the budget; the retained
  two-link cycle and the finite repeated dot-link; a self-extending `a` to `a/x`
  link; one symlink inode with entries in two directories where the filesystem
  admits it; a final directory without search permission (mode 0600); the retained
  300-byte ASCII impossible component beside extant multibyte names over 255 UTF-8
  bytes where admitted and combining names. Each check is seen to fail against a
  mutated walk. The code under test is the code the provider ships, never a copy.
  These tests do not show that the built provider includes, invokes and consumes
  the walk, so they close no N subject.
- N, through the independently built provider's signed bundle on the host, where
  reveal makes no effect, observes what a result can show: every absent row; the
  established cycle and impossible component (`PATH_NOT_FOUND`); the 33-link and
  self-extending budget, denial and any other component failure (`failed`
  naming component and cause); and every present outcome that is followed by the
  limit's refusal, whose guidance names the literal, expanded or resolved
  spelling and its byte count. That covers the 1,023/1,024 boundary for the
  literal, the short-literal long-expansion and the resolved spelling, and the
  present rows at about 1,500-byte depth (a resolving link chain, the mode-0600
  final directory, the two-directory link inode, multibyte and combining names),
  each placed where its spelling is 1,024 bytes or more so the refusal proves the
  walk reached it. Each is seen to fail against a mutated provider.
- Present outcomes that no refusal exposes (a within-limit 31- or 32-link chain,
  the mode-0600 directory, the two-directory link, the multibyte names, and the
  reveal root decision for `/`, `//`, `/.`, `/..`, `/var/..` and a link to `/`) are
  not observable on the host without a reveal. This leaf records that gap in its
  log, and `target-locations-vm-k180` closes them at V with the effect, while L
  checks the planner's use of the root decision.
- G: a public request for an extant over-limit path returns `failed` with the
  guidance at the action's response path, never a dependency, and nothing is
  revealed. Existing 1.0.0 short-path outcomes are unchanged.
- Native comments and the call-path check (`task check:launch-call-path`) are
  reconciled with the new calls: no `realpath`, `stat` or `URL.path` addresses a
  caller's location before the limit.

## Notes

- Present outcomes cannot be seen through reveal on the host (nothing is revealed
  there). The signed bundle shows them only through a refusal that follows
  resolution; direct shared-source tests are supporting evidence and never
  stand in for N. Whatever a leaf cannot observe at N is named, with its V owner,
  in the leaf's log rather than counted as passed.
- Descriptor budget, no recovery branch and no spelling drift are the spec's
  obligations here; they are acceptance conditions, not nice-to-haves.
- This leaf may decompose at a genuine seam, for example the planner mapping
  apart from the real walk, if it proves bigger than one session.
