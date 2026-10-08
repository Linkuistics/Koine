# search-tooling-k197

**Reviews:** search-tooling-k195
**Creator:** run 8cd00fa7-1115-499d-95c2-656ce65660de

## Goal

Adversarially review the concrete system-tool search design and its reconciliation
before the human permission decisions or existing search work consume it.

## Context

Find the producer commit by search-tooling-k195 and inspect its diff against the
current artifacts. Read docs/specs/workspace-search.md,
docs/verification/search-tooling.md, relevant requirements/ADRs, SDL/examples,
guide/glossary/workflow trace and all changed architecture views. Earlier native
reports retain bounded observations, not acceptance of this backend. The current
route is /usr/bin/find candidates, Foundation literal matching and native Bundle/
Launch Services/NSWorkspace facts/seeds; it is conditional on k196's explicit
system-child and protected-target/lookup-only decisions. No backend was implemented
or executed. Live search work was retained with revised charters, not pruned or
credited as passed. The parent's graph lookup refused an active unverified
generation; no implementation/coverage claim rests on that result.

## Done when

- Challenge the finite selection and smallest adapter: verify current primary
  command/library semantics, actual macOS availability and whether discovery and
  literal matching reuse existing facilities without a hidden custom walker,
  matcher, index or chooser. Check directory/link/package and default OS seed scope.
- Try to disprove the permission premise. Find may acquire metadata before prune
  or same-device refusal, and no-follow says nothing about every root component.
  Check whether the design exposes these limits rather than claiming pre-access
  protection. Child TCC responsibility, relocated targets, unknown cloud aliases,
  replacement races and lookup-only acquisition must remain concrete human
  choices in k196, without overriding k115 or presuming k190 answered them.
- Challenge healthy empty, COMPLETE/PARTIAL/UNKNOWN and aggregate status against
  real command exit/stderr/EOF semantics. OS seeds are not an exhaustive installed
  inventory; empty, stale, unavailable, refused and unchecked native answers must
  not establish negative registration or healthy empty. Check identity merging,
  distinct copies, source membership, byte-preserving locations and long records.
- Check the invocation/parsing and resource contract for contradictions: fixed
  executable/argv and escaped literal path tests; NUL framing and overlength
  draining; bounded copied values/diagnostics; both simultaneous pipes; sequential
  source/deadline behavior; atomic freeze, TERM/KILL/PID ownership, exactly one
  reap and retained capacity through unreaped child/native work. Reject inherited
  descriptor/memory/internal-health guarantees or omitted abrupt-parent limits.
- Audit the reconciliation against durable product requirements and action
  contracts. Distinguish obsolete custom ordering/frontier/witness mechanics from
  useful home/launcher, native fact, permission and serviceability obligations.
  Check each retained live search charter and node handoff; k93 still needs actual
  named omissions and a human decision. No ambiguous obligation is passed/pruned.
- Check finite G/N/V subjects, actual signed host/command attribution, independent
  dialog/hydration observers with positive controls, listener/store/action outcomes,
  useful named default/home witnesses and exact retained/new binary profiles.
  SDL/render/link checks are design evidence only; unavailable native subjects
  remain pending. Inspect changed views and meaningful prose/SDL agreement.
- Produce findings only. If actionable findings earn integration, insert an
  integrate-review-design leaf before the first later live sibling in this root
  directory (currently search-tool-permissions-k196), so integration also precedes
  app-and-file-search-k7. Create no integration if there are no actionable findings.

## Notes

Mandatory review of this producer, independent of the carried k193/k120 reviews.
No in-session reviewer, implementation, subprocess/native experiment or full
filesystem evidence program. Existing search work resumes only on the reconciled
reviewed mechanism and the subsequent explicit human permission contract.

## Decisions (running log)

- Adopt the mandate in the stated jj workspace. Producer k195 is `ecaaf6de6fed`
  (`lusmwrqy`); `@` is empty on top of it, so producer and current coordinates
  coincide. `spec` is `docs/specs/workspace-search.md`, `tooling` is
  `docs/verification/search-tooling.md`, `SDL`/`examples` are the two
  `docs/design/workspace-search-*.graphql` files, `trace` is
  `docs/specs/workflow-providers.md` and `guard` is
  `scripts/check-launch-call-path.sh`, all at that commit. The codebase-memory
  server failed to connect, so no graph or code-coverage claim is made; documents,
  the guard script and the k94/k98/k192 findings were read directly.
- Inspection only. No task, render, check, build, probe, backend or native call
  was run and no in-session reviewer was spent. Command and library semantics
  below come from the local find(1), fts(3) and setiopolicy_np(3) manuals and
  the SDK's fts/resource headers on this host (macOS 26.6.2, 25G83, not the
  26.5 acceptance build), plus two `ls -l` reads (`/usr/bin/find` is present;
  `/Applications/Safari.app` is a symlink into the App cryptex). They are
  reasoning offered for triage, not guest evidence. No Apple source was fetched.
- Fourteen findings warrant triage, three of them high. The first later sibling
  entry in the root directory holding live work is
  `search-tool-permissions-k196`; integration `search-tooling` is inserted at its
  slot carrying this review's handle only, so it also precedes
  `app-and-file-search-k7`. Retiring this review closes no node.

## Findings

Producer `ecaaf6de6fed` (`search-tooling-k195`). Severity orders the list. The
three high findings change what the human is asked in k196 or what later design
must decide before implementation; the rest are contract corrections the
integration can apply in place.

### T1 — The finite comparison omits the in-process OS walkers that find itself wraps, and k196's refusal branch therefore has no named alternative (high)

- The reuse requirement is "existing OS facilities or established search tools"
  (requirements:51-58; k190's recorded wording "incorporate other O/S tools").
  The comparison (tooling:12-20) weighs Spotlight, system find, rg/fzf, fd/fzf
  and "custom in-process traversal" — the old FIFO walker. It never weighs the
  existing in-process walkers: Foundation's `FileManager` directory enumerator
  (native hidden/package skipping, `skipDescendants()`, per-URL error handler)
  and libc `fts(3)`, the facility `/usr/bin/find` is built on. The ADR's
  alternatives paragraph (search-enumeration-reuses-system-find:19-23) omits them
  too.
- The omission matters because the spec makes that route the refusal branch:
  "Refusal requires another existing engine within the in-process posture"
  (spec:120), without naming one. k196 would ask Antony to approve a child
  process against k115's in-process posture with no concrete alternative or cost
  on the other side.
- The trade-off is real in both directions and belongs in the record. In
  process: no child permission question, no TCC child attribution, no pipes,
  NUL framing, reaping, PID reuse or orphans; per-entry errno and path
  (restoring the ACCESS_DENIED/PATH_NOT_FOUND localization that the stderr route
  gives up at spec:216-217); per-entry identity at preorder, before descent, for
  policy decisions. Against: a blocked readdir/lstat holds a Koine thread with
  no kill, whereas a non-uninterruptible child can be killed; and `fts` in a
  multithreaded server must use `FTS_NOCHDIR` (the SDK's fts_new.h/fts_compat.h
  offer no descriptor-relative mode), so its whole-path lstat inherits the
  1,024-byte `PATH_MAX` limit the descriptor-relative ADR documents, which find's
  own chdir-based walk escapes. FileManager's long-path and error behaviour is
  unmeasured.
- **Consequence.** The selection may well survive, but it has not been compared
  against the nearest reuse route, and the human choice it creates is framed
  without its alternative. Add the in-process walkers to the comparison and ADR
  with their long-path and isolation costs, and give k196 that concrete branch.
  Note T3: the workspace guard forbids listing imports too, so either route
  needs the module/call-path decision.

### T2 — Home search is predictably a depth-first sample in directory order, which k93 is forbidden to accept (high)

- find passes no comparison to fts unless `-s` is given, and fts(3) says a NULL
  comparison visits entries "in the order listed in the directory"; fts is
  preorder depth-first. The design keeps that order (spec:146-149), rejects
  `-s` and any max-depth (tooling:79-80), and caps each filesystem root at
  100,000 records inside one three-second wait (spec:252-259). The default file
  search has exactly one source, the home.
- So the first large subtree in directory order can consume the root's whole
  record or time budget, and every later home child — including shallow ones —
  is omitted on every query. Earlier inspection on this Mac counted 9,558
  visible directories at depth 7 alone under `~/Development` (k98:136-143),
  before files. That is the k94 S1 failure shape (k94:104-131) the FIFO design
  existed to prevent, now on the default home source.
- The design defers it: useful coverage "needs measurement and human
  acceptance" (spec:256-257), the subject list names "the formerly starved
  Development shape" (tooling:129) and the ADR revisits only "if measured
  system-tool omissions defeat required workflows" (ADR:24). But k93 must not
  accept "an arbitrary native-order sample" (k93:13), which is what a binding cap
  over hash-ordered DFS yields. The route is therefore headed for a k93 refusal
  after implementation and signed-VM measurement.
- **Consequence.** State the consequence now and decide before implementation.
  Find-backed options exist without a custom walker — for example a bounded
  shallow pass (`-maxdepth`) before the deep pass, or each immediate home child
  as its own source under the existing source scheduler — at the cost of
  revisiting tooling:79-80. Otherwise put the ordering trade-off to Antony in
  k196 beside process and protection, so k93 is not the first place it surfaces.

### T3 — The child process's effects are absent from the authority allocation and collide with the accepted workspace call-path guard (high)

- Search is served by the workspace provider (spec:319, workspace 1.1.0). The
  guard scans `Providers/WorkspaceProvider/{Logic,Sources}` and the whole built
  `libWorkspaceProvider.dylib` (guard:34-35). It fails on `posix_spawn`,
  `Process()`, `_posix_spawn*`, `_kill` and `_execv*` (guard:43-44, 392-393), and
  on any `opendir`/`readdir`/`fdopendir`/`getdirentries` import (guard:388-389).
  Its stated invariant is "no ... process-spawning call" on the launch paths
  (guard:21-22). The selected adapter needs exactly `posix_spawn`, TERM/KILL and
  reaping (spec:245-281).
- The trace "allocates every Koine-requested effect, including hidden
  preparation and fallback calls" (trace:185-186); cleanup mechanisms are
  declared at admission (trace:164-171). The search rows still allocate plain
  `workspace:read` (trace:198-199, 277-279), with no spawn, signal or reap
  effect and no extension of the call-path seam (trace:466). The rewritten node
  brief also dropped the old k7 obligation "Authority, trace rows and VM
  acceptance as in `launch-and-open`" (old k7 Done when; new
  `_app-and-file-search.md`:17-20).
- **Consequence.** At implementation either the accepted guard fails, or it is
  narrowed ad hoc and loses its binary-level "no process call" guarantee for
  launch paths. Decide the module boundary (a separate search module or dylib
  versus a call-path inspection that can tell launch paths from search), allocate
  spawn and signal cleanup under `workspace:read` in the trace, and restore the
  call-path seam obligation in k7/k30.

### T4 — find's exit 0 with empty output can yield a false COMPLETE healthy empty (medium-high)

- With `-P` and `-mindepth 1` (tooling:68, 79), a root that is a symlink is
  examined as the link itself and not descended (find(1) `-P`; `-H` alone
  follows command-line links), so find prints nothing and exits 0. A file root
  does the same. A trailing slash flips this, because pathname resolution
  follows the link (`/tmp` versus `/tmp/`).
- COMPLETE and healthy empty need only "a qualified filesystem root, normal
  exit 0, fully drained pipes, no warning" (spec:206-209). Qualification happens
  before spawn (tooling:78-79) and is deferred (spec:135). A root replaced by a
  link or file between qualification and find's own lstat therefore produces
  exactly the healthy-empty signature. The ordinary/empty subject row
  (tooling:124) lists missing roots but not link, file, trailing-slash or
  replaced roots.
- **Consequence.** Permission denial, absence and healthy empty must stay
  distinct (requirements:86-87). Require positive evidence from find's own
  traversal that the root was a directory — for example let the root be emitted
  as the first record (find's `-depth n` primary can confine a root-only rule)
  and treat a missing root record as UNKNOWN. Add the four root shapes to the
  subjects and to k191's root qualification.

### T5 — The tooling note claims no anchor metadata access, but find stats every anchor and mount point before it can prune them (medium)

- tooling:80-82 says "no blocked-anchor metadata or descendant access is
  permitted". fts stats each entry while listing its parent; fts(3) notes that
  even under `FTS_NOSTAT` "directories encountered during traversal ... are
  still fully populated", and find's `-type`/`-x` need that information. The
  expression, and so `-prune`, sees the entry only afterwards. Under `FTS_XDEV`
  only descent is refused, so a mount-point directory is still visited and
  stat'ed, and being `-type d` it is printed as a candidate — despite
  "Enumeration stays on its starting device" (spec:85).
- The policy tests are byte-exact `-path` patterns (tooling:69, 77-78),
  case-sensitive and normalization-sensitive, while APFS is usually neither. A
  client root spelled `/users/antony`, in another Unicode form, or via
  `/System/Volumes/Data` would not match a test built for `/Users/antony` and
  find would list Desktop. The limit list (spec:121-123) names relocation, cloud
  aliases, root-component links and replacement races, but not root spelling
  aliases. The prompt subject row does carry "Data/case/NFC/NFD variants"
  (tooling:127), and k191 is chartered for root qualification.
- **Consequence.** The k196 protection question must not rest on a pre-access
  premise at the anchors. Local Desktop/Documents/Downloads lstat was measured
  prompt-free (protected-path-metadata); cloud, FileProvider and automount
  anchors were not. Correct tooling:80-82, add anchor and mount-point metadata
  contact to the stated limits and subjects, and name root spelling aliases.

### T6 — The spawn contract leaves descriptor and signal inheritance unspecified, coupling jobs and weakening the orphan limit (medium)

- tooling:57-62 fixes executable, argv, environment, locale, working directory
  and stdin, but not which descriptors, signal mask, ignored dispositions or
  process group the child inherits. `posix_spawn` passes every descriptor not
  marked close-on-exec, and Darwin has no `pipe2`, so marking is a separate step
  that races a concurrent spawn.
- With four concurrent jobs (spec:252), a child spawned while another job's
  pipe write end is open in Koine inherits it. That job's completion needs
  "both EOFs" (spec:272-273), so it then waits on an unrelated child — and
  indefinitely if that child is blocked — contradicting "one live or unreaped
  child/job". An orphan holding an inherited listener socket can keep Koine's
  port bound after an abrupt death.
- SIGPIPE at its default ends an orphan at its first write after Koine dies. If
  Koine ignores or blocks it, those settings survive exec. The orphan then
  depends on find's own write-error handling, which the design does not examine,
  and the 100,000-record cap is enforced in Koine, not in find. spec:285-287
  states the orphan limit without this bound.
- **Consequence.** Specify the spawn attributes: close-on-exec by default with
  only stdin/stdout/stderr passed (Apple's `POSIX_SPAWN_CLOEXEC_DEFAULT` plus
  file actions), default SIGPIPE/SIGTERM and an empty mask
  (`POSIX_SPAWN_SETSIGDEF`/`SETSIGMASK`), and the process group the TERM/KILL
  wording (spec:277) already implies. State the orphan bound. Add G/N controls:
  the child sees only fds 0-2, and one job's EOF is independent of another's
  blocked child.

### T7 — The documented, inheritable dataless-materialization policy is not considered (medium)

- "Ordinary search never ... deliberately hydrates content" (spec:109-110) is
  enforced only by policy paths and a hydration observer (tooling:127).
  setiopolicy_np(3) documents `IOPOL_TYPE_VFS_MATERIALIZE_DATALESS_FILES` (also
  in the SDK's sys/resource.h) and says "New processes inherit the policy of
  their parent process". It could therefore govern both Koine's in-process
  native calls and the find child.
- Unknown cloud aliases and FileProvider directories outside the policy list
  (spec:121-123) are where find's readdir meets dataless items. Whether that
  materializes, fails or returns an empty listing under the effective policy is
  unexamined. An empty listing would also be a false healthy empty (T4).
- **Consequence.** Decide whether search pins the policy (process scope
  reaches the child but also all of Koine; thread scope does not reach a
  spawned process), record the residual limit, and add the setting and its
  failure or empty-listing outcome to the hydration subject and k196/k191's
  framing.

### T8 — Native application recognition and link resolution have no candidate filter or call bound (medium)

- Application search "receives the same stream, then performs native
  application recognition" (tooling:82-83). Matching uses the resolved target
  bundle filename (spec:142-143), and a link supplies no comparison name of its
  own (application-search-uses-bundle-identity:10-11). So every link record must
  be resolved, and possibly Bundle-read, before matching can decide.
- The resource contract bounds seeds and registration URLs (1,000 per job) and
  copied values (spec:259-266). It bounds neither which records enter
  recognition nor how many resourceValues/Bundle/resolution calls a job makes.
  These are in-process, blocking and not interrupted by the freeze
  (spec:40-41, 283). With explicit roots, native work scales with the
  100,000-record stream rather than with matches.
- **Consequence.** State the recognition candidate set (with native
  confirmation, never suffix-inferred identity), a per-job native-call bound and
  its coverage reason. Name the obligation in k123, whose charter covers copied
  results and branches but not call count.

### T9 — The public skip-reason vocabulary lost its definitions; CHANGED_DURING_SEARCH has no producer but still drives FAILED (medium-low)

- The SDL keeps twenty `WorkspaceSearchSkipReason` values. Of the reasons the
  new spec defines, only VALUE_LIMIT, UNREPRESENTABLE_NAME, MOUNT_BOUNDARY and
  UNSUPPORTED_VOLUME are named (spec:166, 222-223), with a few more implied
  (TIME_LIMIT, CAPACITY_LIMIT, DOMAIN_EXCLUSION). CHANGED_DURING_SEARCH appeared
  twenty times in the pre-k195 spec and now nowhere in the spec, tooling note or
  guide. Under find nothing produces it: stderr is not parsed (spec:216-217) and
  a vanished entry is an unlocalized error. Yet examples:66 still classifies
  "No-progress PROMPT_RISK plus CHANGED_DURING_SEARCH/INSPECTION_FAILED" as
  FAILED.
- ROOT_NOT_FOUND, OPTIONAL_ROOT_ABSENT, ROOT_NOT_DIRECTORY, ACCESS_DENIED,
  ENTRY_LIMIT, DIAGNOSTIC_LIMIT, CLOUD_SCOPE, UNSUPPORTED_SCOPE, PROMPT_RISK,
  BACKEND_UNAVAILABLE and NATIVE_SOURCE_UNAVAILABLE have no stated condition,
  extent, `affectsCoverage` value or failure/prompt/absence class. The aggregate
  precedence (spec:226-235) depends on that partition.
- **Consequence.** The coverage ADR calls this granularity costly to reverse.
  Give each value a producer under the selected route, or remove it before the
  schema ships, and repair examples:66.

### T10 — The result-limit stopping rule and its as-you-type capacity consequence are unstated (low-medium)

- "The requested result limit ... does not itself stop enumeration"
  (spec:268-270). Every query therefore runs to root completion, 100,000
  records or the three-second wait. Jobs are capped at four process-wide, with
  slots held until reap (spec:252, 278-279).
- A chooser that queries per keystroke and does not cancel superseded requests
  will meet CAPACITY_LIMIT, which is FAILED. Neither the spec nor the guide's
  search section says whether a job may stop once the (limit+1)th distinct match
  is observed (and with which coverage reason), or tells clients to cancel
  superseded queries.
- **Consequence.** State the stopping rule and its coverage outcome, and add
  the cancellation guidance to the client guide.

### T11 — Several retained contracts still describe the replaced walker (low)

- filesystem-access-is-descriptor-relative still lists "search traversal" among
  Koine's descriptor-relative work (:3-5), says "Search's listing streams still
  read the directories they list" (:35), and describes serial lookup-only
  witness acquisition (:47-50). Under find, enumeration is a child's whole-path
  fts; only root qualification and individual targets may use the walk. The
  enumeration ADR does not state this supersession.
- machine.md:559 says the contract "refuses known prompting traversal before
  attempting it". Find can refuse roots and prune known spellings, not traversal
  in general (T5).
- The k109 brief's "observation boundaries" link (:48) now points at the
  permission section, which is not where k118's native-fact/evidence choice
  lives (the native-fact ADR, spec:172-195 and test seams do).
- k120's `**Reviews:**` names terminal k109, whose design its own brief now
  calls non-authoritative, while the material k120 is chartered to review is
  k191/k127/k123's output. A future `**Creator:**` line would name the run
  that finished k109, not those producers. Consider whether the handle still
  says what k120 reviews.

### T12 — k93 now offers one acceptance where two distinct limits need separate answers (low)

- The pre-k195 k93 kept protected-scope exclusion and bound/order-driven
  sampling apart: "approval of one does not approve the other". The rewrite
  asks one question, "accept/disclose useful partial coverage as measured, or
  approve a ... change" (k93:14). Accepting the protected-folder policy could
  then be read as accepting T2's ordering losses.
- **Consequence.** Restore the two answers in k93's Done when.

### T13 — "Equal retained paths merge" needs byte equality (low)

- Paths preserve find's bytes and normalization affects only matching
  (spec:151-154), so NFC and NFD spellings are distinct strings. Swift `String`
  equality and `hasPrefix` use canonical equivalence and would merge them. The
  same applies to the root-prefix protocol check (tooling:88-89).
- **Consequence.** State byte (UTF-8 scalar) equality for merging and the
  prefix check, and add an overlapping NFC/NFD root control.

### T14 — `responsibleIdentity` has no format or runtime source (low)

- SDL:53-55 adds a public `responsibleIdentity: String`, "Null until the
  actual OS-responsible identity is established". TCC responsibility is
  observed at acceptance, not per query (spec:104-106). A non-null value would
  therefore be a constant learned in a VM, published as if it were an
  observation. A later release would change null to that constant without any
  per-query evidence.
- **Consequence.** Define the format (signing identifier, bundle identifier or
  path) and say whether the value is static, or drop the field in favour of
  `accessProcess` plus guidance.

### Re-derived and confirmed, not findings

- The local find(1) documents every selected option: `-P`, `-x`, `-f`,
  `-print0`, `-prune`, `-name` escaping, and `-mindepth` as a global rule (the
  root is never evaluated, so an explicit hidden or package-named root is not
  pruned by its own name). The argv outline uses no shell, `-exec` or `-delete`.
  Safari is reached only through a link in `/Applications`, so the
  link/direct/OS identity merge is load-bearing, as the spec assumes.
- Foundation folding plus literal range comparison is library reuse, not a
  hidden matcher. No index, chooser or ranking returns to Koine.
- OS-reported coverage stays UNKNOWN, and empty, stale, refused or unchecked
  native answers establish neither registration negatives nor healthy empty.
  Distinct same-identifier copies stay separate.
- k196 restates k115's refusal and k190's limits without overriding or
  presuming them, and it asks process and protection separately. Obsolete
  FIFO/frontier/witness mechanics are labelled, never passed or pruned. The
  rewritten k191/k193/k127/k123/k120/k30 charters carry the retained
  obligations, and k93 still requires actual named omissions and a human
  decision.
- Glossary entries and the discovery, preopen, traversal and resources view
  sources agree with the prose. The SDL enum reductions match the removed
  custom concepts.

## Current citation

The enumeration-record pathname and source coordinates above describe the
original producer, retained as historical comparison. Its current ownership
record is docs/adr/raw-filesystem-search-belongs-to-clients.md; k196 moves raw
filesystem search to clients and requires returned native discovery design.
