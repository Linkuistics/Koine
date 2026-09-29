# Koine.add-plugins-for-modaliser-requirements — brief

## Goal

Add one or more Koine plugins supporting the existing Modaliser requirements
that Antony actually uses in his active Modaliser configuration. These will
become ModalAnyware requirements when that project is restarted.

Also provide access to an application's full menu system, an explicit human
addition beyond Modaliser's currently configured workflows, so clients can
expose those menus and their actions.

Human request: "create a new jj workspace `jw switch
add-plugins-for-modaliser-requirements`, and start a grove there to add one or
more plugins to support the existing Modaliser requirements (according to what
I use in my modaliser config), which will become ModalAnyware requirements once
we restart that project."

## Done when

The requirements session establishes the configured workflows and the Koine
capabilities they require, including full application-menu access, with the
human, then the grove delivers the agreed plugin support. Plugin count and
boundaries follow those requirements.

## Decomposition

The human confirmed all active bindings as the workflow baseline and approved
`docs/requirements/modaliser-workflows.md`. `plan-k1` records the source evidence
and settled interview decisions. Menu access includes the menu bar and context
menus, with explicit opening, both context target modes, agreed metadata,
focus-loss cleanup and stale-selection refusal.

`plan-k2` reviews those requirements. `providers-k3` then decomposes the
workstream, commissioning scoped design and native evidence before dependent
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

## Notes

The preceding Koine grove was torn down at commit `fc3b22d3`. This workspace
starts from that commit. Homebrew was updated and Koine 0.1.0 was installed
locally at `/Applications/Koine.app` at the human's request.

This request starts Koine plugin work; restarting or editing ModalAnyware is
not part of it. Read sibling projects as evidence for requirements. Establish
the actual configured behavior before choosing plugin boundaries or adding
functionality.
