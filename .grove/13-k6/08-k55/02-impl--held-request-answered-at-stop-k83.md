# held-request-answered-at-stop-k83

## Goal

A request that is in flight in a provider when the server stops is always
answered, as the loopback listener's contract says: "A request already received
is answered first, on a connection that then closes." Today the `stop` check of
the binary compatibility pairs fails intermittently because the held caller is
sometimes dropped without a response.

## Context

- `task compat:verify`, the `stop` check in `scripts/verify-compat-pairs.py`:
  "stop: cancels the resolve outstanding in the plugin, waits for it, answers its
  caller and exits cleanly". Observed on failure: the held call raises
  `RemoteDisconnected('Remote end closed connection without response')`, the
  host exits 0, and `stopMilliseconds` is 0.
- It is not caused by `additional-capabilities-k56`. Run 25 times alone, the same
  case failed once against the **released** 0.1.0 host and zero times against the
  new one; a full `task compat:verify` failed in roughly one run in five while
  that leaf was built.
- `KoineServer.stop()` (providers first, then the listener) and
  `LoopbackListener.stop()` in `Sources/KoineHTTP`, which closes every connection
  that is not `busy`.

## Done when

- The cause is found, not guessed: the window in which a received request is not
  yet counted as busy, or a response flushed after the channel closes, is named
  with the evidence that shows it.
- The fix is covered by a test that forces the order rather than sampling it, in
  the way `RevocationOrderingTests` forces its orders.
- `task compat:verify` passes 25 times in a row on the new host, and the check
  is unchanged.
- If the released host's behaviour is the same defect, the binary compatibility
  document says the released side of the pair still has it.

## Notes

Cut from `additional-capabilities-k56`, whose acceptance needed a stable pair
run. It sits ahead of `provider-selection-k57` because that leaf reuses the pairs.
