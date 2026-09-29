# Koine.add-plugins-for-modaliser-requirements — brief

## Goal

Add one or more Koine plugins supporting the existing Modaliser requirements
that Antony actually uses in his active Modaliser configuration. These will
become ModalAnyware requirements when that project is restarted.

Also provide access to application menu bars and context menus, an explicit
human addition beyond Modaliser's currently configured workflows, so clients
can expose those menus and their actions. Status-item and Dock menus are
deferred by agreement.

Human request: "create a new jj workspace `jw switch
add-plugins-for-modaliser-requirements`, and start a grove there to add one or
more plugins to support the existing Modaliser requirements (according to what
I use in my modaliser config), which will become ModalAnyware requirements once
we restart that project."

## Done when

The requirements session establishes the configured workflows and the Koine
capabilities they require, including the agreed application-menu access, with the
human, then the grove delivers the agreed plugin support. Plugin count and
boundaries follow those requirements.

## Decomposition

The human approved `docs/requirements/modaliser-workflows.md` from the active
bindings, then narrowed the baseline during `plan-k2`: Zellij and Neovim support
are removed; VS Code screen workflows are deferred, retaining its launcher.
`plan-k1` records the source evidence and initial interview decisions;
`plan-k2` records the scope change and `plan-k4` integrates it and the review.
Menu access includes the application menu bar and context menus, with explicit
opening, both context target modes, agreed metadata, cleanup and stale-selection
refusal. Status-item and Dock menus are deferred. `plan-k4` also settles separate
grants for input, menu invocation and window focus; bounded cleanup on
revocation, inactivity and orderly shutdown; foreground-loss cleanup with the
owned-modifier-release exception; and explicit abrupt-crash recovery limits.
Account-dependent acceptance uses dedicated test accounts/data in isolated VMs;
unavailable accounts leave affected cases pending.

`providers-k3` decomposes the workstream using the integrated requirements,
commissioning scoped design and native evidence before dependent
implementation. Provider count, boundaries and exact APIs remain design work.
Reuse public GraphQL, the native binary interface and isolated TestAnyware
macOS VMs as agreed acceptance seams. Demonstrate Koine's support without
implementing or restarting ModalAnyware.

## Pointers

- Existing application: `/Users/antony/Development/Modaliser`.
- Eventual client: `/Users/antony/Development/ModalAnyware`.
- Locate and read Antony's active Modaliser config; sample configs alone are
  not evidence of what he uses.
- Koine's current contract: `docs/specs/machine.md`, `docs/client-guide.md`,
  `docs/adr/`, and `CONTEXT.md`.
- Agreed extension requirements: `docs/requirements/modaliser-workflows.md`.
- Current scope and review integration: `plan-k2` and `plan-k4`; the source
  config still contains removed/deferred workflows and is not the scope by itself.

## Notes

The preceding Koine grove was torn down at commit `fc3b22d3`. This workspace
starts from that commit. Homebrew was updated and Koine 0.1.0 was installed
locally at `/Applications/Koine.app` at the human's request.

This request starts Koine plugin work; restarting or editing ModalAnyware is
not part of it. Read sibling projects as evidence for requirements. Establish
the actual configured behavior before choosing plugin boundaries or adding
functionality.
