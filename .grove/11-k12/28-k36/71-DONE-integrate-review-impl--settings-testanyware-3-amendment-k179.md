# settings-testanyware-3-amendment-k179

**Integrates:** settings-testanyware-3-amendment-k178

## Decisions (running log)

- 2026-11-23: F1 is a real issue. The tagged `wait_for_size` returns `Waited`
  after a failed session, and the adapter accepted that line. The line also
  omits a failure after the first session.
- 2026-11-23: the adapter keeps one completed form clean: a first size, then the
  target at session 2. Both sessions returned a size, so neither failed. Each
  other form is unavailable. This adds no read, wait, retry or tolerance.
- 2026-11-23: a clean start that needs a third session is now unavailable. This
  is an accepted trade-off, because the line cannot separate it from a hidden
  failure. The upstream measurement read the target at session 2 on 7 of 7
  guests, and it gives no rate for k54.
- 2026-11-23: N1 is an accepted limit. No k54 path sends `--open-menu` through
  the one-shot class, and the evidence class refuses it. The results record
  states the limit.
- 2026-11-23: N2 is a real wording error. The tagged handler covers only SIGINT
  and SIGTERM, so SIGHUP also leaves the temporary file. The results record and
  the adapter comment now say so.
- 2026-11-24: this repair earns no further review round. It only adds an
  unavailable outcome, and its control failed before the change. The affected
  harness checks and the closed ledger check pass again. k54 stays next.
