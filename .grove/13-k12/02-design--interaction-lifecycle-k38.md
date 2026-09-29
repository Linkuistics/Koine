# interaction-lifecycle-k38

## Goal

Design Koine-owned interactions: their public operations, ownership, cleanup
triggers, inactivity bound, reporting and crash recovery. Dia's walk and
`context-menus`' opened menus both use them.

## Context

- `held-input-evidence-k24` and `menu-evidence-k23`.
- `provider-architecture-k5`.
- The spec's "Mutation preflight and revocation" admission boundary, and the
  framework contract. Today the host gives providers no grant identity and no
  revocation signal.
- The requirements' "Interaction requirements" and the target-loses-foreground
  scenario.

## Done when

The spec and an ADR state:

- how an interaction is begun, stepped, confirmed and cancelled, and what each
  result reports;
- how ownership reconciles with grant/dispatch admission, so revocation ends
  the interaction without admitting a new client action. This includes any host
  signal to providers and the framework minor and required feature it needs.
- the inactivity bound and what renews it;
- orderly shutdown through provider stop;
- the foreground-loss trigger, and how expected client presentation is declared
  and recognized without authenticated identity;
- which cleanup keystrokes are permitted;
- unconfirmed cleanup reporting;
- the crash recovery mechanism and user guidance;
- the VM acceptance cases.

## Notes

This is load-bearing for two increments and touches the admission boundary;
judge a `review-design` read at the end. Any change that alters what
`koine-desktop/1` promises existing clients is Antony's decision.
