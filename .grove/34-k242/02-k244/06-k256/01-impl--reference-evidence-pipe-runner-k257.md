# reference-evidence-pipe-runner-k257

## Goal

Implement the actual concurrent process runner and lossless NUL framing, qualified
on scratch emitters with true terminal/reap and failure observations.

## Context

Consume the durable fixed source protocol and replay-k250's source schema/oracle.
Packaging will use /usr/bin/mdfind with exactly -0 and the fixed application-bundle
predicate; this leaf must never invoke that command.

## Work and verification

1. Author a pure emitter under Fixtures/ReferenceEvidence/source-emitter with frozen
bytes/expected events: empty stdout; trailing/consecutive NULs; repeats; embedded
newlines/non-UTF-8 spellings; outside/malformed slots; unterminated suffix.
2. Implement SourceRunner.swift and package tests with internal executable/pipe
composition for the emitter. Drain stdout and stderr concurrently through actual
pipes, preserve both immutable raw streams and read errors, and reap the launched
child. Large interleaved streams demonstrate both pipes drain without blocking.
3. Each NUL closes one ordinal slot; trailing NUL creates no extra slot; actual
empty slots survive. No decoding/trimming/line split/sort/set/deduplication occurs.
Retain an unterminated suffix as an explicit fragment, never a complete slot.
4. Inject launch/read failure, stdout EOF before process termination, nonzero exit,
signal, missing reap and incomplete stream closure. Require no acquisition contact
until both streams close and reaped normal zero status with complete framing exists.
Retain stderr on zero exit and source observations on all failures.
5. Add/verify task evidence:reference-source-check using only the emitter and pure
fault seams. Independent per-case expected streams/slots/terminal facts/contact
traces and before/after tool/input digests are saved, with intended failures observed.

## Done when

The real runner preserves all emitted bytes and terminal facts and disallows contents
contact on every incomplete/error outcome. Frozen large-pipe and framing positives
pass independently; prior replay/decoder checks remain usable.

## Notes

Do not expose an arbitrary runner/predicate as a packaging flag. Test composition
is not target permission. Normal zero/empty output proves no all-disk completeness.
