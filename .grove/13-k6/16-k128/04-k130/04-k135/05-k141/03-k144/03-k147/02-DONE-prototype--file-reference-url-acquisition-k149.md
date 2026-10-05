# file-reference-url-acquisition-k149


## Goal

Run the one authorized finite diagnostic: can public file-reference URL
factories acquire and locally consume original files at 900/1,023/1,024/1,500
UTF-8 bytes using direct creation or component-relative native references?



## Context

- file-reference-url-acquisition-k148 and the authorized charter in
  docs/verification/long-action-route.md#proposed-file-reference-url-acquisition-diagnostic.
  Antony answered "authorized" on 2026-10-05; do not ask for that permission again.
- Public SDK CFURL.h, NSURL.h and NSFileHandle.h. Distinguish supported
  CFURLCreateFileReferenceURL/CFURLCreateWithFileSystemPathRelativeToBase from
  unsupported CFURL/FSRef bridges and hand-built volfs/file-ID spellings.
- Historical CF-1153.18 append/absolute-URL conversion evidence is a risk to
  measure, not the current Darwin implementation or a universal negative.
  k134 proves relative local access; k143/k146 do not prove URL factory behavior.

## Done when

- Build one throwaway ordinary signed helper in one disposable TestAnyware
  macOS guest and unprotected fixture tree; change no Koine production code,
  SDL, grants, conformance or consent. Record OS/build/architecture, filesystem/
  capability bits, SDK/compiler, signature/entitlements and source/binary/input/
  output digests. No usage keys, protected reads, TCC reset/approval, private
  policy, app/default registration, external inquiry, cwd change, opener,
  Finder or external submission. An unexpected dialog stops the diagnostic.
- Component-create exactly four ordinary text files at 900/1,023/1,024/1,500
  original UTF-8 bytes excluding NUL, with valid ASCII components at most 245
  bytes, unique fixed markers at most 64 bytes and same-parent decoys.
  Independent openat/fstat controls establish full native target/decoy device
  and inode identity. Keep a short independently constructed same-object
  control and missing-name conversion control; no failed/error output becomes
  an absence or classification claim.
- Run exactly two acquisition cases per file, eight per collection. Direct:
  construct a URL with original path spelling, then CFURLCreateFileReferenceURL.
  Component-relative: acquire the short root's native reference, construct each
  child with CFURLCreateWithFileSystemPathRelativeToBase using its exact single
  component and known directory flag, and request a fresh native reference
  before advancing. Log each level's reference predicate, URL/base forms,
  cumulative original byte length and CFError. Do not advance after failure or
  a returned reference with a retained base chain; the latter is incomplete.
  Use no append convenience, FSRef, hand-built identity spelling, bookmark/fd
  namespace fallback or alternate acquisition API.
- A non-null URL/reference predicate alone passes nothing. For each acquired
  final reference, use the public NSFileHandle URL reader, fstat its descriptor
  against independent target/decoy identities, and read only the fixed marker.
  Separately attempt CFURLCreateFilePathURL and compare recovered original
  bytes. Conversion is not I/O; do not use recovered whole-path text in lookup
  to force success. Preserve first failed stage, typed native errors, control
  results, actual object access, byte spelling and instrument validity separately.
- Bound selected traversal at 32 levels and three live caller-owned descriptors
  (independent parent, target/control and URL consumer). Bound caller-owned URL
  objects at three: old base-free anchor, relative child input and replacement
  reference during a swap. Record then release child/old anchor before advancing.
  Serialize logging/path-conversion temporaries within that ceiling and inspect
  base URLs without retaining them. These do not bound opaque Foundation
  allocations. Limit recorded URL text to 8,192 bytes per value. Close resources;
  tooling, short-control, oversize or bound failure returns incomplete.
- Use an external 30-second watchdog per acquisition case plus at most five
  seconds termination grace. Permit at most two builds, two collections of the
  identical corpus and one proven instrumentation repair: at most sixteen
  acquisition cases. A second collection follows only that repair, never a
  changed API/subject/guest strategy. The 15-minute aggregate cap starts at
  clone-start request and includes teardown. Stop and retain every attempt on
  exhaustion; no alternate route, guest retry or automatic later experiment.
- Preserve minimal raw records and a bounded result report. Reusable mechanics
  belong in the existing Taskfile and are verified before reliance. Stop the
  guest and present the result for Antony's reaction under the prototype skill.
  long-action-route-k150 consumes the committed report and reaction.

## Notes

A positive earns only measured acquisition/local URL consumption and identity
controls. It supplies no flags/type/bundle facts, exact-item default binding,
long registration/copy selection, original-byte external delivery, real default/
Zed rendering, Finder acknowledgment/selection, grant/cancellation parity or
executable receipt. Sending a reference URL externally is outside the charter.
A negative is bounded to these two patterns and local consumer on that guest.
Keep k147/k144/k141/k135/k130/k128 live. Production implementation/full acceptance
remain planning's work; no final review or automatic evidence chain is earned.

## Decisions (running log)

- Adopt k149 and the already authorized acquisition/local-consumer charter. Use
  one signed throwaway helper, four component-created targets and decoys, and
  the fixed direct/relative cases. No production or public-contract edit.
- Graph CLI startup refuses the active unverified/pre-coordination generation;
  no project, generation or coverage verdict is available. Use exact bounded
  document/SDK/source reads and make no exhaustive graph claim.
- Execute the existing approved design: add helper/build/driver mechanics and
  Taskfile entries; compile and verify before starting the clone cap; freeze
  inputs, run controls then eight cases under watchdogs; retain raw records,
  stop the guest and present the bounded result for the human reaction.
  Prototype authorization supplies the throwaway-code scope; no production
  implementation, separate speculative plan or further experiment is needed.
- One host build compiles cleanly with Apple clang 21.0.0 / SDK 27.0 and
  verifies its ordinary hardened-runtime Developer ID signature with empty
  entitlements. Python syntax/lint and Bash syntax/source-aware shellcheck pass;
  fixture arithmetic yields the four exact lengths within depth/component bounds.
  The driver preserves stdout/stderr/code verbatim and uses an external guest
  watchdog; it runs no automatic repair or second collection.
- The sole clone completed fixture creation and the missing-name control, then
  the driver stopped before all eight acquisition cases: native JSON numeric
  zero failed a Python Boolean identity check. Raw native records show a null
  reference with Cocoa 260/POSIX 2 and successful ordinary path conversion;
  this is instrument failure, not URL acquisition evidence. Guest teardown
  succeeded at 19.69 seconds; no guest retry is authorized.
- Preserve the exact executed driver and all raw records/digests. The offline
  regression reproduced the faulty check, then passed with the single predicate
  correction and four rejection controls. No native repair/second collection
  ran. Present the incomplete result and corrected reviewable recipe for the
  human reaction; do not retire or signal while that reaction is pending.
- Antony answered "authorized" to one replacement guest with the identical
  corpus, APIs and bounds after the verified driver correction. This explicitly
  overrides the no-guest-retry rule for this replacement only. Preserve run1;
  reuse its signed binary, run one corrected collection as run2, and commission
  no other retry or experiment.
- The authorized replacement completed all eight acquisition cases in 22.20
  seconds with the unchanged signed binary and identical corpus. Direct and
  component-relative patterns acquire/read/convert exact original bytes at
  900/1,023. Direct 1,024/1,500 returns Cocoa 258; relative 1,024 fails at
  its final file and relative 1,500 at the 1,253-byte directory prefix, also
  Cocoa 258. Short same-object/decoy/marker/conversion controls pass throughout.
  No returned base chain, dialog, watchdog or ownership-bound failure occurred
  in the recorded observations. Preserve typed errors and unrun long consumers.
- Both raw output manifests and frozen subject sets verify; corpus files are
  identical, and both guests report disposal. One build, two collections, one
  correction and eight total acquisition cases were used. The human-authorized
  replacement has its fresh bounded interval; do not claim one continuous cap
  across the decision pause. Present the completed bounded report for reaction;
  k150 still owns all complete-route/reconciliation obligations.
- Antony's human reaction is explicit: working around the path limit is an
  absolute requirement and Koine's raison d'etre depends on it. Record that
  direction durably and in k150/the parent brief. This completes the prototype's
  measured-result/reaction deliverable, not the long-route requirement. Retire
  only k149; k150 and every route ancestor remain live. No new native diagnostic
  or changed contract is inferred.
