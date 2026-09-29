# pointer-and-media-k21

## Goal

Design pointer location, the reveal nudge and system play/pause, after a
bounded VM check of the public mechanisms.

## Context

- `provider-architecture-k5`'s allocation. It says which authority pointer
  movement and media keys need, and whether either counts as input.
- Requirement rows Media and Pointer.
- Modaliser's cursor library and its media-key sender show the configured
  behavior. `config.scm` binds a 1px nudge and the play-pause media key.

## Done when

Evidence is recorded under `docs/verification/` from the signed Koine in a VM:

- how a public route delivers system play/pause to the current media target.
  A synthesized media-key event under Accessibility is a candidate. The private
  media-remote framework conflicts with the public-API decision and needs an
  explicit decision if proposed.
- what a nudge must do to reveal an idle-hidden cursor: a pointer warp, a
  synthesized mouse move, or a return to the original position;
- whether a VM can observe the effect of each.

The spec states each operation, its coordinate space, results, authority and
errors. It records what Koine cannot confirm, such as whether anything was
playing.

## Notes

This question is bounded. An unconfirmable effect is reported as unconfirmed,
not proved by a deeper chain.
