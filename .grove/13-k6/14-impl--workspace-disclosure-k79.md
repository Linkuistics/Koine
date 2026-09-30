# workspace-disclosure-k79

## Goal

Before workspace ships, disclose workspace control's reach wherever a person
grants or reviews it. The reach is:

- any registered installed application;
- document execution and redirects by handlers;
- the need for both `workspace:control` and `desktop:control` to launch, open or
  reveal.

## Context

- The workspace spec's disclosure sentences, the Authority/revocation and
  disclosure row, and the workflow spec's grant-disclosure row.
- `docs/adr/provider-authority-follows-effects.md` on disclosed reach.

## Done when

- The native create-grant view, request approval view and existing-grant list
  show the disclosure wherever workspace control is offered or held.
- Management clients receive the same disclosure. If management has no place to
  carry a capability's description, adding one is additive management metadata:
  record the choice, and keep conformance in step.
- The served GraphQL descriptions match the design file.
- A signed build in an isolated VM shows the disclosure for a new grant, a
  pending request and an existing grant, observed in the window.
- The Authority/revocation and disclosure row and the grant-disclosure trace row
  link the evidence.

## Notes

The disclosure of desktop control's expanded reach belongs to `window-layout`;
do not pre-empt it here.
