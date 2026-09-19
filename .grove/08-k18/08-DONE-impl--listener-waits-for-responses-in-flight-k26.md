# listener-waits-for-responses-in-flight-k26

## Goal

`KoineServer.stop()` answers a request already in flight before it returns, as
its own comment says it does, or the comment and the contract say plainly that
it does not.

## Context

Found by `binary-compatibility-evidence-k24`. `LoopbackListener` serves each
accepted connection in an unstructured `Task`
(`Sources/KoineHTTP/LoopbackListener.swift`, the accept loop), and `stop()`
closes the listening channel and awaits only the accept loop. `KoineServer.stop()`
stops providers first "because the listener waits for requests in flight"; it
does not. A process that exits right after `stop()` — the headless
`KoineCompatibilityHost`, and the resident application on quit — can drop the
response of a request whose resolver was just cancelled by the stop.

Reproduction: `task compat`; the `stop:` check of every working pair records the
held caller's outcome under `caller` in `.build/compat/debug/results.json`. In
about one run in three it is `RemoteDisconnected` and not the
`The fixture saw cancellation.` error. The check does not fail on it, because
the spec promises only that stop cancels and waits for provider work.

## Done when

- A request in flight when `stop()` begins is answered before `stop()` returns,
  with a test at the public HTTP seam that holds a resolver, stops, and reads the
  response. Idle keep-alive connections must not keep `stop()` from returning.
- Or, if the human prefers, the comment in `KoineServer.stop()` and the spec say
  that a response in flight may be dropped at stop.
- `scripts/verify-compat-pairs.py` then requires the held caller's answer, and
  its comment about the listener goes.

## Notes

This is a composition question for the human only if the second option is
wanted; the first is a repair of stated behaviour.

## Decisions (running log)

- Took the first option, the repair; nothing was asked of the human.
- "In flight" is a request the listener has received whole (`.end`). At stop a
  connection holding one writes its response and then closes; a connection
  between requests, or part-way through receiving one, is closed at once, so an
  idle keep-alive connection cannot hold `stop()`.
- Connections stay unstructured tasks, tracked in a locked registry
  (`Connections` in `LoopbackListener.swift`). A task group was rejected: the
  package's floor is macOS 13, a discarding group needs 14, and a plain group
  keeps every finished connection's result for the listener's life.
- The HTTP-seam test asserts "answered, then closed", not `Connection: close`.
  `KoineServer.stop()` cancels providers before it stops the listener, so the
  answer is sometimes written, as keep-alive, before the listener is stopping;
  the connection is then idle and stop closes it. Seen as one failure in six
  runs of the first form of the test.
- In process the old listener also delivered the answer, since nothing exits;
  only the closes distinguished it there. The dropped response needs a process
  that exits after `stop()`, which is what `task compat` now requires.
