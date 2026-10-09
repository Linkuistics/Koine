# search-canonical-paths-k108

## Goal

Choose one buildable lossless canonical-directory-path contract for search
roots, streams, queued tasks, bundles and policy witnesses. Repair the native
path/value/group/queue-subject mismatch externalized by k107 without silently
narrowing the domain or accepting a shorter canonical-path limit.

## Context

- k106 T6 in review commit `64bcbf6a`, producer `6814ec741fa4`; k107's committed
  triage. F_GETPATH/F_GETPATH_NOFIRMLINK require MAXPATHLEN; the inspected SDK
  defines PATH_MAX 1,024. The 8,192-byte fsgetpath route takes filesystem/object
  identity, not a descriptor. It is a candidate, not an accepted fallback.
- Artifact: workspace-search spec, application identity/traversal ADRs, SDL and
  examples, glossary, guide, workflow trace and views/exports/captions. Caps stay
  4,096 requested/8,192 returned or scratch path bytes, 384 KiB traversal/root.
  Controlled 43/44 task arithmetic does not establish reachable native paths.
- Preserve k103 transport/outcome/lifecycle/compatibility, k104 single canonical
  spelling/policy/witness/ownership rules, and k107 turn-before-read checks,
  changed-prefix root remainder and target-only exact exceptions.
- Tier 2 project Users-antony-Development-Koine.add-plugins-for-modaliser-requirements,
  generation 2026-09-29T10:36:20Z. Docs/scripts excluded; SDK is outside the graph.
  Parent read these directly. Confirm coverage/freshness before code claims;
  no graph completeness or native acceptance is supplied.

## Done when

- Name actual public calls, identity rechecks/binding, buffers and native limits
  for the unified route. Weigh fsgetpath or another supported route against
  descriptor paths, including firmlink spelling, races and prompt risk.
- Distinguish known native size refusal from uncertain inspection, with truthful
  representable root/actual-parent coverage and bounded grouped omissions. Deep
  long-path trees must not allocate one INSPECTION_FAILED record per queued task
  solely because the chosen primitive has a smaller buffer. No truncated path.
- Construct private-adapter, independent real provider/GraphQL and signed VM
  subjects, naming the instrument observing each outcome. Separate controlled
  maximum-value arithmetic from reachable native lengths/count/byte boundaries.
  Include root admission, firmlink/case/Unicode, queued/current movement,
  protected aliases, long components and identity reuse.
- Reconcile every durable contract, summary and ADR citation. No narrower domain,
  signing/consent/setup change, entitlement, raised limit or incompatible version
  is authorized. Escalate any such prerequisite before reliance. Acceptance
  remains pending.
- Run task design:search-render, task design:search-check and task check:docs on
  frozen subjects. Cut mandatory load-bearing review-design as the last work
  act with **Reviews:** search-canonical-paths-k108 and specific residual doubts.
  Planning k30 waits for its review and any earned integration.

## Notes

Design only, not implementation or a native evidence chain. k109 separately
owns opaque resource errors/serviceability instruments; coordinate canonical
calls' descriptor costs with it. k93 owns reduced coverage decisions with Antony.
The producer cuts its review lazily once its artifact exists.

## Decisions (running log)

- Choose the public fsgetpath route, using a pinned directory's fstat object
  number and fstatfs filesystem identity, one fixed 8,192-byte native buffer,
  and identity/mount/path association rechecks. The syscall counts its NUL:
  successful native directory text is at most 8,191 bytes. This is an observed
  native size boundary, not a reduction of the 8,192-byte public value bound,
  eligible domain or accepted workflow coverage. No larger buffer, private API,
  entitlement or F_GETPATH/realpath fallback. Stable-parent target size refusals
  group at the actual parent; unestablished/current/prefix size refusals stop
  the root once. Error/identity uncertainty never establishes native size.
- Retain the existing private-adapter, independent provider/GraphQL and signed
  VM seams. Construct native paths component-wise, including a 4,096-byte
  root with 127-byte children (4,224-byte tasks: 79 fit, 80 byte-refused), and
  keep synthetic maximum-value 43/44 arithmetic explicitly separate. Actual
  prompt behavior, race outcomes, native reachability and runtime boundaries
  remain pending; the mandatory producer review precedes planning.
- Refine size/movement precedence: an ordinary directory's canonical-parent/
  observed-name join needing more than 8,192 bytes including NUL is diagnosed
  before matching/enqueue, while an ordinary file location can use all 8,192
  text bytes. If a formerly fitting current/prefix/queued path later receives
  full-buffer ENOSPC, that size change is movement evidence: one root
  CHANGED_DURING_SEARCH remainder, or INSPECTION_FAILED if its prior association
  was unestablished. Never retroactively put an already observed directory name
  into a name-omitting CHILD_GROUP.
