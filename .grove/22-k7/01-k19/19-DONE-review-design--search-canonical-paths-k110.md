# search-canonical-paths-k110

**Reviews:** search-canonical-paths-k108

## Goal

Independently challenge the lossless fsgetpath-based canonical-directory design
and its native size/identity/coverage subjects before planning relies on it.

## Context

Read the producer's focused commit by its stable handle, then reconcile that
diff with the current tree; the intervening native-resource producer may have
changed shared contracts. The artifact is:

- docs/specs/workspace-search.md, especially Canonical directory observation,
  Canonical path acceptance subjects, traversal accounting and acceptance.
- docs/verification/search-canonical-paths.md: public SDK/source analysis and
  planned fixture construction, explicitly no native measurement.
- docs/adr/application-search-uses-bundle-identity.md and
  docs/adr/search-coverage-describes-observations.md.
- Search SDL/examples, client guide, workflow trace, glossary and
  docs/design/architecture/search-canonical.d2 plus the revised traversal,
  coverage and handoff views/manifest/captions.

Preserve k103 transport/outcome/lifecycle compatibility, k104 canonical
spelling/policy/witness rules and k107 FIFO/current-prefix changes. The public
4,096/8,192-byte value ceilings, owned descriptor credits, signing posture,
consent/setup and three-second wait are unchanged. Opaque call/resource/error
and serviceability instruments belong to the separate k109 design/review.
Planning k30 waits for both chains and any earned integrations.

Tier 2 graph project:
Users-antony-Development-Koine.add-plugins-for-modaliser-requirements,
generation 2026-09-29T10:36:20Z, ready when the producer checked. Docs/scripts
are excluded and CONTEXT/Taskfile metadata changed, so the producer read the
relevant artifacts directly. Confirm freshness/coverage for your own claims.
The SDK and upstream Apple sources were read directly. The public-call probe
compiled/linked only; no native acceptance or graph completeness is supplied.

## Done when

- Re-derive the public call signatures/limits from the actual SDK and primary
  sources. Challenge fstat/fstatfs fsid/object inputs, birth/mount discriminators,
  fgetattrlist's fixed capability buffer/returned-length/valid-mask decoding and
  default firmlink spelling. Do observed checks detect what is claimed without
  asserting descriptor-bound lookup, a mount-generation token or ABA safety?
- Challenge the NUL-inclusive 8,192-byte syscall buffer versus unchanged public
  8,192 text-byte values. Does native 8,191 directory text / 8,192 joined file
  text remain coherent, with no silent shorter domain or accepted coverage loss?
  Is the canonical-parent/name pre-enqueue proof valid for an ordinary directory
  under case/Unicode/firmlink presentation and movement? Is any successful
  canonical path fabricated, truncated or selected by a fallback?
- Challenge before/after checks on success AND non-resource errors, cancellation
  and resource-stop precedence, and the fresh actual-parent/child association
  check before a size group. Test changed or unknown parents, checked-link
  targets with unestablished actual parents, ENOENT/reuse without mismatch and
  full-buffer ENOSPC after a previously fitting current/prefix/queued path.
  Can two temporary credits support component-relative long-path opening and
  parent/target checks without a third descriptor, retained ancestors,
  recursive parent requirements or uncharged scratch/state?
- Challenge refusal scope and finalization order: unresolved root size remainder,
  job-wide admission-witness failure, unfinalized actual-parent VALUE_LIMIT
  CHILD_GROUP, and a single changed/uncertain root stop for dependent queued work.
  No 512-task diagnostic fan-out, retroactive omission of a finalized directory
  name, unsupported resultsTruncated claim or further entry/child I/O after
  observed refusal. Non-size errors cannot establish absence or size.
- Challenge constructibility and witnessing independently at the private
  adapter, real provider/public GraphQL and signed macOS VM seams. A component-
  relative helper must reach the measured 4,096-byte root/4,224-byte tasks
  (79/80 byte boundary; 100 anchors and 21 refused descents when it completes),
  128-byte tasks (512/513 count boundary), 8,191/8,192 directory cases and an
  8,192-byte joined file. Short aliases must obey actual symlink component/hop
  limits; overlong absolute kernel arguments and synthetic 43/44 arithmetic
  cannot substitute. Check each retained/omitted marker against captured native
  order and each native check/charge event. Unreachable lengths or early
  deadline/resource stops stay pending.
- Challenge the firmlink/Preboot, case/Unicode, current/queued movement,
  deletion/identity-reuse, protected Library/Mail and component-alias subjects
  and their independent dialog/hydration observers. Are source/compile facts
  being misused as native or no-consent evidence? Check every durable summary,
  ADR citation, schema comment, example and view agrees with the actual design.
- Report actionable design findings against the producer/current artifacts,
  distinguishing defects from explicitly pending runtime evidence or disclosed
  platform races. Cut an integration only for findings worth triage, in the
  position required by the review procedure.

## Notes

This is inspection-only design review, not implementation or a native evidence
chain. Actual useful home/default coverage and any reduced workflow decision
remain Antony's k93 obligation. No entitlement, limit, signing/consent/setup or
domain change is authorized by a passing schema or diagram check.

## Decisions (running log)

- Adopt the mandate in the stated jj workspace. Producer is `2e41af85d44f`
  (`pwpwsnvy`); `@` is empty on top of `255b421e` (k113), after k111–k119.
  The k108 "Canonical directory observation" section and "Canonical path
  acceptance subjects" are byte-identical to the producer's but shifted
  (+27 and +582 lines). Coordinates below are the **current tree's**. k119's
  in-process call contract (spec:1163-1355) postdates the producer and is
  reconciled where it shares text. The graph server was unavailable this session;
  docs, SDK headers and the xnu sources were read directly. No graph claim is made.
- Inspection only. No task, build, test, render or probe was run, and no
  in-session reviewer was spent. Two read-only host observations, both labelled
  below, are not guest evidence. The xnu `main` sources (`bsd/vfs/vfs_cache.c`,
  `vfs_syscalls.c`, `vfs_attrlist.c`, `vfs_subr.c`) were downloaded for reading.
  They explain the API; they do not identify the guest kernel.
- Re-derived and confirmed, not findings:
  - SDK `sys/fsgetpath.h`:
    `ssize_t fsgetpath(char *, size_t, fsid_t *, uint64_t)`, macOS 10.13.
    `sys/syslimits.h:103` sets `PATH_MAX` to 1024, and `MAXPATHLEN` is
    `PATH_MAX`. `fgetattrlist` is declared in `unistd.h:761`, and
    `VOL_CAP_FMT_PATH_FROM_ID` is 0x4000.
  - `fsgetpath(2)`: the success count includes the NUL. EINVAL when buflen
    > 8192, ENOSPC when the buffer is too small, plus EACCES, EPERM, ENOENT,
    ENOTSUP, EIO and EFAULT.
  - xnu `fsgetpath_extended`: the buffer must be ≤ MAXLONGPATHLEN, only
    `fsid.val[0]` is passed on, then a MAC check and
    `build_path(... BUILDPATH_CHECK_MOVED)`. A non-superuser caller adds
    BUILDPATH_CHECKACCESS. EAGAIN retries ×16 end in ENOENT.
    `mount_lookupby_volfsid` requires MNTK_PATH_FROM_ID and returns ENOTSUP
    otherwise. `build_path` returns ENOSPC when a component does not fit.
  - The long-path iopolicy `IOPOL_TYPE_VFS_SUPPORT_LONG_PATHS` appears only in
    a `sys/attr.h:137` comment. It is absent from public `sys/resource.h`, so
    the producer's refusal to rely on it (verification:33-37) is right.
  - Arithmetic: 4,096 + 1 + 127 = 4,224; 4,224 + 512 = 4,736;
    79 × 4,736 = 374,144 ≤ 375,040 < 378,880, leaving 21 refused anchors.
    Also 43 × 8,704 and 512 × 640 = 327,680. The root listing reaches EOF
    before any dequeue (spec:850-851), so 79/80 is decided before any
    in-flight charge.
  - Two temporaries suffice for the walk, the child association and the
    parent canonical check: fsgetpath on a held fd needs no descriptor.
  - Host (macOS 26.6.2, not guest): `/System/Cryptexes/App` is a relative
    symlink to `../../System/Volumes/Preboot/Cryptexes/App`. The Preboot root,
    the Cryptex App directory, its Applications directory and `Safari.app`
    share `st_dev` 16777229. This is consistent with the same-mount premise
    (spec:222-226). It is not acceptance.
- Withdrawn candidate: whether volume attributes require a volume-root
  descriptor. Installed `getattrlist(2)` says EINVAL "if path does not
  reference the root of the volume". Current xnu `getvolattrlist`
  (vfs_attrlist.c:1043-1051) substitutes `VFS_ROOT` instead. The spec runs the
  capability check on mount-root witnesses (spec:371-375, 1839-1840), so it
  holds under either reading. The actual call outcome still belongs in the
  native trace.
- Nine findings warrant triage. The first sibling entry after this review that
  holds live work is the review `search-native-resources-k120`, so the
  integration `search-canonical-paths-k121` is inserted at its slot, ahead of
  it. It carries this review's handle only.

## Findings

Producer `2e41af85d44f` (`search-canonical-paths-k108`). `spec` is
`docs/specs/workspace-search.md`, and `verification` is
`docs/verification/search-canonical-paths.md`. Severity orders the list. Each
finding separates a design defect from runtime evidence that is still pending.

### C1 — The design forbids path-based attribute queries on long paths, but every classification it needs is path-based (high)

spec:414-417 (k108) says the adapter "must not feed an entire long absolute
path to a PATH_MAX-limited open, realpath, Foundation canonicalization or
path-based attribute query." Three passages contradict that:

- spec:1876-1877 already said "Bundle and type metadata remain path-based
  public calls". That text is present at the producer's own line 1294, so the
  conflict sits inside k108's artifact.
- Hidden/package exclusion needs native metadata (spec:267-269). k119 selects a
  fresh `URL.resourceValues` for package, hidden, alias and type
  (spec:1186). It also selects `Bundle(url:)` and registration URLs
  (spec:1187-1188).
- A failed classification "cannot authorize descent into a possibly
  hidden/package directory" (spec:1186).

The SDK supplies no public long-path policy (Decisions above).

- **Counterexample.** In the byte subject (spec:1752; verification:59-70), each
  4,224-byte child directory needs package and hidden classification before it
  can become an ordinary-directory task (spec:873-880). The call is either
  forbidden by spec:414-417 or made on a path over PATH_MAX.
  - If classification is unestablished, each anchor gets affecting inspection
    coverage and no task is queued.
  - Then the 79/80 byte boundary, "100 anchors and 21 refused descents" and
    "first 79 marker subtrees scheduled" cannot occur.
  - The same holds for descent from an 8,191-byte directory, for type metadata
    of the 8,192-byte joined file, and for the identifier and registration of
    any bundle beyond PATH_MAX.
- **Consequence.** The 1,024…8,191-byte band that the canonical route exists to
  keep (spec:388-395) becomes an omission band through classification. The
  canonical section, guide, SDL and ADRs do not disclose this.
  - It undercuts the stated reason for rejecting F_GETPATH: "reducing every
    buffer to PATH_MAX would add unaccepted omissions" (spec:471-472). The same
    omissions arrive through metadata.
  - "Unreachable lengths … stay pending" (spec:1750, 1752) and k119's "fail
    that workflow subject" (spec:1352-1354) defer to acceptance an outcome the
    design already determines.
- **Pending versus defect.** Whether one Foundation call refuses a particular
  length is runtime evidence. The conflict between spec:414-417 and
  spec:1186-1188/1876-1877 is a design defect now.
- **What needs settling:**
  - a descriptor-relative classification route consistent with k119's selected
    native facts, or a stated PATH_MAX classification limit with its own
    diagnostic;
  - re-derived subjects;
  - escalation to k93 if the band is lost.

### C2 — The design assumes fsgetpath spells a path as canonical parent plus listed name, but the kernel builds it from each vnode's cached name (high)

Several passages depend on the two spellings being equal:

- File-entry locations join the canonical parent and the observed name
  (spec:343-344).
- Successful canonical paths are compared with established frame/task paths
  (spec:410-411), and a path mismatch is CHANGED_DURING_SEARCH
  (spec:427-428).
- An ordinary-directory join of 8,192 or more is treated as proof of native
  refusal (spec:434-440).
- ENOSPC on a formerly fitting path stops the root (spec:461-466).
- Bytes, case and Unicode are preserved (spec:384-386).

xnu `main` shows where the spelling comes from:

- `fsgetpath_internal` calls `build_path` (vfs_syscalls.c).
- `build_path_with_parent` copies `vp->v_name` for each non-hardlink component
  (vfs_cache.c:629-660) and asks the filesystem only when name or parent is
  missing.
- `cache_enter_create` seeds `v_name` from the lookup's componentname
  (vfs_cache.c:2795-2812).

No cited source establishes whether APFS, which is case- and
normalization-insensitive, supplies the on-disk entry spelling or the spelling
of whichever lookup instantiated the vnode.

- **Counterexample.** `~/Development/Café` is stored NFD, or `Notes` was earlier
  opened by a tool as `~/Development/notes`. The listing yields the on-disk
  bytes, and the queued task path is the join.
  - At dequeue, fsgetpath may return the cached NFC or lowercase spelling. The
    comparison then reports CHANGED_DURING_SEARCH and stops the home root
    (spec:902-904), although nothing moved.
  - Without that comparison, the directory's published location and its
    descendants' prefixes use different spellings. That splits k104's single
    canonical spelling and exact-path deduplication (spec:345-346).
  - Near 8,192 bytes, a longer cached spelling turns a fitting join into a
    dequeue-time ENOSPC root stop. A shorter one makes the proof at
    spec:434-440 omit a directory that fsgetpath could canonicalize.
- **Subjects.** spec:1753 seeds differing spellings only for link routes and
  preliminary root spellings. No subject first seeds a lookup with an alternate
  case or normalization spelling, then lists the parent, then descends or
  canonicalizes a listed bundle.
- **What needs settling:**
  - which observation decides change: identity/association or bytes;
  - which spelling a directory location and its descendants use;
  - how a same-identity spelling difference is classified;
  - a native subject that seeds alternate spellings.

### C3 — The size rules stop the whole root for target-level outcomes, contradicting the exact-target rule kept from k107 (medium-high)

The k108 rules escalate to a root stop:

- spec:454: "Target's parent/association is changed or uncertain, including a
  checked-link target whose actual parent is unestablished" leads to "one root
  CHANGED_DURING_SEARCH or INSPECTION_FAILED REMAINDER".
- spec:461-466: when the final target "unexpectedly returns ENOSPC", stop the
  root once.

The rules they collide with stay at target or candidate level:

- spec:907-910 (k107) gives an absent or replaced final target under an
  established unchanged parent an exact CHANGED_DURING_SEARCH SUBTREE. An
  uncertain target under such a parent gets an exact INSPECTION_FAILED
  SUBTREE. Unrelated tasks continue.
- The traversal caption (`docs/design/architecture/diagrams.json:126`) says
  "target-only change under stable parent is exact".
- Checked links refuse only the candidate (spec:281-282) and record an affecting
  ENTRY diagnostic (spec:293-295).

Counterexamples:

- **Moved target.** A dequeued target `b` is opened through its unchanged parent
  `a`, then moved deep before fsgetpath, which returns ENOSPC. The required
  recheck (spec:401-403) finds `a` unchanged and `fstatat(a, "b")` absent.
  k107 says exact SUBTREE and continue; k108 says stop the root. One
  observation gets two scopes.
- **Link target.** A user-made `/Applications/Tool.app` symlink targets a bundle
  in a deep admitted temporary directory, or is replaced mid-inspection.
  spec:454 stops the `/Applications` root and loses every later application name.
  The link rule would refuse one candidate.

What needs settling: route on the parent/association recheck.

- Parent changed: root stop.
- Parent unchanged, association broken or uncertain: k107's exact SUBTREE.
- Checked-link target: the existing per-candidate ENTRY/CHANGED rule.

### C4 — One witness's canonicalization failure now fails every root of the job, described as existing behaviour (medium-high)

spec:451 says a witness that "cannot supply a canonical path" triggers "the
existing pre-turn witness refusal": all roots UNKNOWN with INSPECTION_FAILED.
The existing job-wide refusal (spec:1851-1855, unchanged since the producer's
parent) covers only a witness or value that "cannot fit" the account.

- The fixed witness set is per job (spec:1837-1842). It includes CoreServices,
  the Cryptex region, the temporary directory and three mount roots including
  Preboot, although file search gains neither special region (spec:233-234).
- Elsewhere uncertainty is per root:
  - an uncertain Cryptex anchor refuses with INSPECTION_FAILED
    (spec:208-213);
  - unknown Preboot identity or classification is INSPECTION_FAILED
    (spec:216-218);
  - a missing PATH_FROM_ID capability leaves that volume INSPECTION_FAILED
    and pending (spec:375-378).
- **Counterexample.** Preboot's mount-root fsgetpath returns ENOTSUP or EIO, or
  the Cryptex anchor path is uncertain. `workspaceSearchFiles` over home, which
  uses neither region, becomes FAILED with every root UNKNOWN. Application
  search loses `/Applications` as well.
- **What needs settling:** which witnesses each search kind requires, and whether
  a native witness failure refuses the job, only the dependent roots, or only
  that region's root. Reconcile spec:451 with spec:208-219.

### C5 — The pre-enqueue size rule drops directory names that are publicly representable (medium)

Under spec:434-440 and row spec:455, an ordinary-directory join of 8,192 bytes
gets VALUE_LIMIT CHILD_GROUP with "no finalized match", so its name is omitted.

- Other descent-only bounds keep the name. spec:874-876 runs "lossless path
  checks" before descent accounting, yet depth-32 directories "remain
  matchable" and are never opened. spec:508 keeps bound-driven anchor names
  matchable.
- **Counterexample, file search.** An ordinary directory's joined location is
  exactly 8,192 bytes. That is within the public bound (spec:388-391).
  Locations are joins, so publishing it needs no fsgetpath (spec:343-344).
  Only descent is natively impossible, yet its name is dropped while an
  equal-length file, symlink or alias is returned (spec:439).
- **At depth 32,** the native rule removes a name the depth rule would keep,
  for a directory that would never be canonicalized.
- **Package and bundle locations** at 8,192 bytes in file search fall in
  neither list at spec:438-439.
- **Consequence:** an undisclosed one-byte narrowing for directory names. The
  guide says only that "Joined file locations can use that last byte"
  (`docs/client-guide.md:443-444`).
- **What needs settling:** keep the name matchable and diagnose only the descent
  at a representable scope, or state the narrowing with its trade-off and a
  subject. Settle package locations too.

### C6 — The post-call identity and mount recheck compares the held descriptor with itself (medium)

spec:397-400 repeats `fstat` and `fstatfs` after fsgetpath. spec:421-424
credits "comparing identity/association observations" with guarding reuse and
detecting change. spec:1754 injects "identity/mount … mismatches … reused
inode/fsid values" and compares the helper's before/after identities. The
caption (diagrams.json:117) repeats the claim.

Why the identity recheck cannot fire:

- An open descriptor's `st_dev`, `st_ino` and `f_fsid` cannot change.
- Its inode cannot be reused while it is held. Holding prevents reuse; the
  comparison does not detect it.
- Only an owner-set birth time or remount flags could differ, and neither is
  movement.
- fsgetpath resolves the held object's own id (`vnode_getfromid`). The working
  detectors are the established-path comparison, the parent `fstatat`
  association and ENOSPC after a fit.

Contexts with no detector at all:

- First observations (unresolved roots and admission/home/mount witnesses) and
  checked-link targets have no established path and no parent association.
- Movement during or after their fsgetpath is undetectable, and the spec does
  not name this limit.
- The controlled reuse and identity-mismatch injections test a branch that no
  native run can reach (spec:1754: "controlled reuse discriminator still must
  pass"). Passing them certifies nothing about the native route.

What needs settling:

- the movement detector for each context;
- re-scoping the self-comparison claim in the spec, caption, ADR and subjects;
- naming the contexts with no detector as limits.

### C7 — The component-wise link resolver has no specified bounds or semantics (medium)

k108 resolves "supplied and expanded long paths … component-wise with bounded
no-follow openat and checked readlinkat steps" (spec:414-416). Registration
URLs reuse it (spec:1260). Older text still says "Native resolution itself
precedes canonical-target policy classification" (spec:298) and "Normalize
./.. through native resolution" (spec:328-329).

Unspecified:

- the hop limit, and the reason or class for a loop;
- the readlinkat buffer;
- how an absolute target restarts at `/`, and how `/` and its prefixes are
  policy-checked;
- `..` at mount roots and firmlinked directories;
- the bound and scratch charge for the expanded remaining path (spec:794,
  1849-1850);
- whether short paths still use kernel resolution, which would give two routes
  with different semantics.

The fixtures must obey the platform's measured limits (verification:81-82), but
the adapter's own limits are undefined.

- **Loop counterexample.** For root `/tmp/a` with `a → b` and `b → a`, kernel
  resolution gives ELOOP. The adapter's only stated bound is 4,096 components
  per walk (spec:869-871), each a checked open plus canonical and policy calls,
  and no outcome reason is stated.
- **Cryptex anchor.** The default anchor's first component is itself a relative
  `..` symlink (host observation above), so admission depends on this
  unspecified rule.
- **What needs settling:** one resolver rule for roots, link targets and
  registration URLs, with these semantics, outcome reasons, and controlled and
  native subjects.

### C8 — A case- or normalization-variant spelling of a protected component can be opened before policy recognizes it (medium)

The policy rules check spellings and parents:

- recognized protected and cloud spellings are checked before resolution
  (spec:301-302);
- components and identities are compared "for known exclusions"
  (spec:330-331);
- synthetic protected targets are never opened (spec:346-349);
- the walker opens a child "after the pre-open canonical parent check"
  (spec:1872-1873).

Nothing requires the walker to classify the child it is about to open against
the protected and cloud witnesses before `openat`, either by `fstatat` identity
or under the volume's case and normalization rules. k108 routes supplied roots
and link targets through this walker (spec:414-416).

- **Counterexample.** The root `~/documents` or `~/LIBRARY/Mail`, or a link
  target spelled `library/…`, is not the recognized byte spelling. The walk
  opens the protected directory and runs fsgetpath on it before the canonical
  spelling reveals the policy.
- **Evidence gap.** The prompt-free evidence covers lstat, stat, realpath and
  resource values on fixtures inside Desktop, Documents and Downloads
  (`docs/verification/protected-path-metadata.md:24-39`). It does not cover
  `openat(O_DIRECTORY)` or fsgetpath on those directories themselves, nor
  Library/Mail.
- **Subjects.** spec:1753 watches link aliases, not case or NFD variants.
- **What needs settling:** a pre-open classification rule for the child, and a
  dialog-witnessed subject that uses case and normalization variants of each
  protected component.

### C9 — An ADR now carries review status and private call mechanics (low)

`docs/adr/application-search-uses-bundle-identity.md:26-31` (k108) names the
private operation, fsgetpath and descriptor-derived identity. It adds "Its
load-bearing review and signed-host acceptance remain required before
planning/acceptance respectively".

- ADR-FORMAT keeps records current-state, with no status line.
- The coverage ADR (`docs/adr/search-coverage-describes-observations.md:22-27`)
  keeps private mechanics in the spec so they can change without the public
  slug.
- The status sentence goes stale when this review retires. The only content
  that belongs in the ADR is the public consequence: the default firmlink
  presentation and no alternate spelling.
