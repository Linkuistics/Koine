# foreground-entry-paths-k113

## Goal

Inspect the two public foreground/mapping pairs on the exact guest build and
record what their implementation establishes and leaves unresolved.

## Context

Use the capture assessment's callback witness protocol. Inspection is a separate
instrument from native callback schedules; method entry is not an observation.

## Done when

- Freeze a narrow read-only own-image inspector, queries and build inputs through
  the root Taskfile; execute only in a disposable TestAnyware clone.
- Record guest OS and loaded image identities, bounded instruction ranges,
  dependencies and missing-symbol controls for NSWorkspace.frontmostApplication,
  NSRunningApplication.processIdentifier, GetFrontProcess and GetProcessPID.
- Follow the concrete cache/IPC/mapping leads within this inspection; explicitly
  bound any unresolved observation point without asserting freshness.
- Preserve raw output, exact exits and before/after digests; update the capture
  assessment, sampling view and separate source-migration note.
- Leave the causal fixture, callback schedules and every original parent
  obligation live. No private entry is invoked as a capture source.

## Decisions (running log)

- The own-image scan establishes AppKit helper/property-preservation paths and
  LaunchServices shared-memory/reply paths. Neither the public getter's entry
  nor its field consumption dates the underlying observation. Keep both pairs
  conditional; do not choose a replacement source from this evidence alone.
- Record unresolved helper updates, foreground publication and PID-handler
  coherence explicitly in the existing assessment. The witness and native
  schedules remain k114/k115, with lifetime attribution in k112; no permission,
  targeting or complete-protocol change is proposed.

## Verification

The inspector built with warnings treated as errors. Three frozen guest scan
phases exited 0 without timeout, all real queries read 3072 bytes, and the
missing-symbol control reported missing each time. Host source/binary/query
digests and guest binary/query digests matched before/after item by item; all
saved instructions decoded with Capstone 5.0.7. The Taskfile measured during the
scan is archived because the final decoder task adds the last scan. Image UUIDs
and code bytes identify inspected native dependencies, not entire frameworks.

Tier 2 graph generation 2026-09-23T13:49:01Z had matching metadata. The new
Objective-C inspector had partial coverage over lines 1–79, so its complete
source and included scanner were read directly. No exhaustive graph claim.
One bounded fresh-context review checked scanner, code interpretation, offsets,
controls and provenance; it reported no substantive findings. No second reviewer.

The updated sampling view rendered and passed XML/digest checks; its PNG and
Safari diagram/discussion deep links were inspected in the disposable clone.
Mobile/dark presentation and all native callback schedules remain untested.
