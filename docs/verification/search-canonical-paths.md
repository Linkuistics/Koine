# Canonical directory call analysis

The [pre-open boundary analysis](search-preopen-boundary.md) identifies missing
mount-bootstrap and symlinked-policy-target proofs in the selected call policy.
A metadata-policy decision, returned witness design and mandatory reviews
precede reliance on these subjects. The cached mount and target-following policy
metadata candidates are unapproved; no new call, native result or reduced
home/default workflow is selected here.

This is source/SDK analysis for the
[canonical directory contract](../specs/workspace-search.md#canonical-directory-observation),
not a native search measurement. Implementation, independent provider/GraphQL
and signed hardened macOS acceptance remain pending. The selected resolver,
pre-open policy and spelling/name contracts require mount/symlink witness and
replay/size-phase repairs with load-bearing reviews before classification design
and its review, then complete-resource review/planning. Long-result actions
require a separate design/review in the launch/open increment. No complete
two-temporary replay/metadata composition or long-result action pass is claimed.
The
[path-design dependencies](../specs/workspace-search.md#path-design-dependencies)
keep long-path classification/end-to-end reachability unresolved.
No shorter domain, consent/setup, entitlement or limit increase
is accepted. The [application identity decision](../adr/application-search-uses-bundle-identity.md)
owns the naming choice; the spec owns private calls, errors and subjects.

## Public calls and evidence boundary

The installed macOS SDK's public sys/fsgetpath.h declares fsgetpath with a
caller buffer, filesystem identity and 64-bit object number, available since
macOS 10.13. sys/syslimits.h defines PATH_MAX as 1,024. No private declaration
is required for the chosen route. The local fsgetpath manual agrees with
[Apple's published manual source](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/man/man2/fsgetpath.2):
fstatfs's f_fsid and fstat's st_ino are supported inputs; success counts the NUL;
buffers above 8,192 fail with EINVAL and insufficient buffers fail with ENOSPC.
Its volume capability check uses VOL_CAP_FMT_PATH_FROM_ID.

[Apple's syscall implementation](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/vfs/vfs_syscalls.c)
passes zero options for public fsgetpath, looks up the filesystem object,
performs a MAC check, and builds a path with movement checking. A movement retry
can terminate in ENOENT. This explains why lookup ENOENT alone does not establish
root absence, why the call can consult protected metadata, and why repeated
descriptor observations do not turn it into an atomic descriptor-path API.
The zero-options route allows default firmlink presentation. That is a design
premise to verify on each supported startup/Preboot layout, not native evidence
that alias spellings already agree.

[Apple's path builder](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/vfs/vfs_cache.c)
can copy vnode cached names. This is evidence against assuming that fsgetpath
must equal a canonical-parent/listed-name join, not a measured APFS mismatch.
Case/normalization cache-seeding subjects must record both spellings and identity.
Join length therefore does not prove native ENOSPC, and a same-identity byte
difference alone is not movement evidence. Holding the directory descriptor
prevents ordinary reuse while held; repeating its identity/fsid checks does not
detect movement. Parent association or separately established location evidence
can expose change. First roots/witnesses and unassociated link targets lack an
independent movement detector; the public lookup is not an atomic binding.

[Apple's public header source](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/fsgetpath.h)
places fsgetpath_ext and its private options outside the public declaration.
They are not a fallback. Likewise, current
[attribute path construction](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/vfs/vfs_attrlist.c)
has a separate long-path policy; a larger user attribute buffer does not prove
that ordinary full-path attribute queries escape PATH_MAX. The choice avoids
depending on such a policy or an unapproved private entitlement.

A minimal C declaration/call probe compiled and linked against the installed
macOS SDK/libSystem with clang -Wall -Wextra -Werror, including sys/attr.h,
sys/fsgetpath.h, sys/mount.h, sys/stat.h and unistd.h. It referenced fstat,
fstatfs, fgetattrlist and fsgetpath with the specified argument types and buffer
sizes; unistd.h supplies fgetattrlist's declaration. The probe was not executed
and is not a provider, race, consent or native-size test.

These upstream sources are explanatory; their main branch is not the running
guest kernel's identity. The native subjects must record OS/build, SDK and API
results for their actual signed host. This analysis ran no traversal or protected
lookup on the developer's machine. Graph project
Users-antony-Development-Koine.add-plugins-for-modaliser-requirements was ready at
generation 2026-09-29T10:36:20Z; docs are excluded and current CONTEXT/Taskfile
metadata differs. The relevant documents and SDK were read directly; no graph
completeness or current implementation claim is made.

## Constructible subjects and instruments

The [canonical acceptance subjects](../specs/workspace-search.md#canonical-path-acceptance-subjects)
name their own outcome witnesses. A disposable guest helper creates native
trees using component-relative mkdirat/openat, never an overlong absolute
mkdir argument. It records each actual component, fstat identity and fsgetpath
return count/errno. Construction failure is a pending/failed subject, not a
shortened substitute. It cannot declare provider correctness.

For the byte subject, measure a canonical ordinary root at exactly 4,096 UTF-8
bytes and give it 100 distinct 127-byte ASCII child-directory names, each with
a short marker. Paths charge 4,224 + 512 = 4,736 bytes/task: 79 consume 374,144
of the 375,040-byte queue-object allowance; 80 need 378,880. The arithmetic is
conditional on classification admitting those listed-location tasks; descent reports
are separate observations. The selected path-based resourceValues/Bundle calls conflict with the
long-path attribute prohibition; component-relative fixture creation alone does
not establish adapter reachability. The classification producer must re-derive
this subject. If reachable, the queue trace must observe byte refusal below 512
and preserve 100 anchors with 21 frontier refusals, selecting 79 marker subtrees
by captured native order. Metadata rejection, deadline or resource stop does
not pass the boundary.

The short-path subject instead pads a measured canonical root and names so
every task is 128 bytes, with 513 children and individual marker queries.
512 tasks charge 327,680 bytes: the count check binds first. The adapter trace
must distinguish that from byte refusal. Native directory text at 8,191 bytes,
text needing 8,192 bytes, and a longer chain separately test successful
canonicalization, full-buffer ENOSPC and public joined-value overflow. Construct
aliases component-wise when requestedPath must remain at most 4,096 bytes;
symlink targets and hop counts must satisfy the platform's measured limits.
The same specified 32-expansion/readlink/component rules apply at every source
and length; native construction must also obey actual per-call platform limits.
Do not presume a Foundation/full-path open or classification can reach them. If a length is
unreachable on the guest, record the failing call and leave that subject pending.

At the 8,192-byte public location ceiling, distinguish an ordinary directory,
package/bundle, depth-32 directory with no descent, file, final link and alias.
Native descent refusal does not establish that an anchor name must be omitted.
Size scopes must retain exact final-target SUBTREE and checked-link ENTRY
failures beneath an unchanged parent; only shared prefix/parent failure stops
the root. Native witness failure refuses dependent roots; only witness-account
overflow is job-wide. These design obligations need separate controls, including
one failed Cryptex/Preboot witness beside successful home/Applications roots.

Protected case/NFC/NFD component variants must be classified before child open,
not recognized only after fsgetpath. Dialog/hydration observers must include
Desktop/Documents/Downloads/Library/Mail and known cloud variants. Prior protected
metadata evidence supplies no acceptance for these openat/fsgetpath calls.

The 43/44-task shape uses controlled 8,192-byte adapter values only. A raw C
buffer is not a GraphQL path value and includes its terminator; an 8,193-byte
fsgetpath buffer is invalid. Native 8,191-byte directory values and 8,192-byte
joined file locations are different subjects. No capacity arithmetic establishes
latency, safe prompting behavior, independent resource serviceability or useful
home coverage. Actual omissions still feed the existing operator decision.

## Resolver and spelling subject construction

This is design construction, not executed evidence. The graph CLI in the
resolution session refused an active unverified generation; documents and
primary sources were read directly. No current graph/code claim or native
acceptance is added. Apple documents APFS's case/normalization behavior in its
[APFS FAQ](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/APFS_Guide/FAQ/FAQ.html).
That motivates native alias lookups, rather than treating search folding as
filesystem equivalence. Apple's
[readlink manual source](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/man/man2/readlink.2)
describes returned bytes without an added NUL. Its
[lookup source](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/vfs/vfs_lookup.c)
explains native absolute/parent and link processing. These explain APIs, not
the guest build or measured APFS cached names. The adapter's 32 expansions
and derived work accounting are selected bounds, not a new OS guarantee.

[Apple's open manual source](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/man/man2/open.2)
assigns ELOOP to O_NOFOLLOW finding a final symlink. In this single-component
walker, that error after a directory probe is the context's changed type/
association outcome, not evidence of a followed-link loop. Expansion 33 alone
uses bounded-hop guidance. A native barrier must place replacement between
probe and open; controlled errno injection proves mapping only, not that race.

The following subjects preserve selected bounds and name semantics, but their
pre-open witness and replay phases remain prerequisites under repair. Required
additional subjects are:

- No-follow device refusal before any unknown removable/network/image or nested
  foreign-mount open, across root/link/registration/dequeue/current sources;
  startup/home/bootstrap and fixed Preboot exceptions need independent proof.
  Observe dialogs/hydration throughout probes and late cleanup. Refused URLs
  cannot justify a registration negative.
- Cloud/iCloud policy links beneath established blocked Library and relocated
  Documents into ordinary Work/Docs, with case/NFC/NFD/Data aliases. The witness
  producer must define required target proofs and dependency-scoped outcomes;
  a literal spelling or unavailable volume is no passing substitute.
- Region replay before metadata and at finalization, root-stream conversion,
  and fresh current/prefix reports with cache-lengthened ENOSPC after unchanged
  association. The phase producer must supply coherent A/B/metadata brackets,
  copied-value/work charges and exact-versus-shared refusal outcomes. Separate
  real movement from controlled cache variation; queued siblings are witnesses.
- Take actual roughly 1,500-byte file and long bundle search results into default/
  Zed open, reveal and constrained launch. Independently record identity/presence,
  action inspection/submission/error and dialogs at provider/GraphQL/binary/VM
  seams; an injected action success is no native long-path pass. The launch/open
  producer owns the unresolved route and truthful overlength failure meaning.

Record sequence number, source/context, parent/child identities, raw input/
listed/reported/link bytes, return count/errno, hop/remaining/work counters,
live scratch occurrences and A/B ownership. Record policy decision **before**
open, then association checks, name finalization, queue charge/refusal, dequeue
report and descendant prefix. Every native call has its existing serviceability
envelope. Independent dialog/hydration observers start before Koine's read and
outlive late cleanup. Failure to build/observe a witness stays pending/failed.

| Subject | Controlled private adapter | Independent provider/GraphQL and signed VM construction |
| --- | --- | --- |
| One route/link bounds | Identical short/long root, link and registration sources take one walker. 31/32 expansions can finish; 33 refuses before readlink 33. Two-link cycle stops at the same bound with uncertainty, not absence or proven cycle. Buffers/counts 0, 1, 8,192, 8,193; invalid UTF-8/NUL and ENOENT/EIO/resource/freeze branches. | Component-relative helper makes short-target chains 31/32/33 and a two-link cycle without asking the kernel to follow a whole chain. Query roots and app candidates; registration fixtures use diagnostic result selection inside the real provider, labelled injection rather than real LS evidence. Record actual readlink counts/public scopes. Native oversized link text is a subject only if the guest permits creation; controlled large counts prove no native reachability. |
| Expanded suffix/work | Splice at 8,192/8,193 text bytes; readlink count and pending-splice overflow differ. Count dots/dot-dots and expansion: at most 135,168 consumed components plus 32 restarts. Cancellation at readlink/splice/restart/parent/child admits no subsequent inspection. No visited/component array. | Make short-target links containing next-link plus dot-component suffixes to accumulate pending text; pad to measured splice boundaries within native per-target limits. Helper independently records link bytes. Capture actual consumed components/pending text. Earlier native/time/resource failure stays pending for that boundary. Freeze beside retained root streams and candidate/registration values; record every scratch occurrence and at most A/B. |
| Absolute/parent transitions | Absolute link closes old pair and restarts at `/`; repeated/trailing slash and dot/dot-dot use native rules. Allowed startup firmlink transition, unsupported/unknown mount and root-parent identity. Fixed-anchor mode alone permits required Preboot transit. | Relative/absolute links in admitted temp/home; independent descriptor helper records native parent identities on `/`, startup/data mount roots and firmlinked Users/Applications. Exercise real Cryptex relative target before region listing; record every parent/mount. Unrelated Preboot sibling and file-search Cryptex root refuse. Real default Safari/Finder remains a separate required outcome. |
| Policy before child open | Parent passes, child is protected/cloud identity: refuse before child open/fsgetpath. Supplied variant and known component native lookups through one home have equal identity; distinct identities on case-sensitive volume are not aliases. Unknown/moved witness refuses dependencies. Include restart/dot-dot/expanded links. | Seed case and NFC/NFD lookup BEFORE parent listing and child/bundle canonicalization. Query Desktop/Documents/Downloads and Library/Mail variants through home/Data aliases, roots and app links; Library blocks before Mail lookup. Include actual known cloud routes with meaningful Unicode variants when present (ASCII names have no distinct NFC/NFD form). Independently observe no dialog/hydration or protected child open. Fixture Unicode policy names are private-seam evidence, never substituted real cloud acceptance. Renamed same-identity witnesses and symlink-component aliases use separate barriers. |
| Cached directory/bundle spelling | Same target/parent identity with differing listed and successive report bytes, longer/shorter NFC/NFD included: no false movement/size inference. Queue keeps parent/listed join; descent uses reported prefix. Current-turn A/B reacquisition compares independent identity; serial reported-path replay proves region-anchor membership without byte-prefix equality or recursive/third-descriptor work. Freeze retains charges. | Helper first opens alternate case/normalization lookup, then Koine lists parent/canonicalizes bundle/dequeues child. Capture helper/listed/adapter bytes and identities. Identical native output is no measured mismatch; differing branch remains controlled evidence only. Public checks preserve raw bytes/earlier locations, exact-string file dedup and first retained app spelling/membership, without global spelling-history promise. |
| Public name/native descent | Exactly 8,192-byte ordinary directory, depth-32 anchor, package/bundle, file, link and alias locations remain name candidates. No child canonical call for intrinsic/no-descent cases. Queued ENOSPC under unchanged parent gives VALUE_LIMIT SUBTREE/null count without name group/truncation. Public 8,193 join omits name with actual-parent group. | Helper creates measured parent/name pairs component-relatively; query each kind separately to avoid rank loss. Real-provider injected classification exercises finalization but is labelled substitution. K123 must establish real classification/registration reachability before native pass. Private seam also covers fitting join/longer cache report and overlong join/shorter report: join bytes never predict native size. |
| Scopes/errors/witnesses | Shared prefix/current location, independent target under stable parent, link and required policy witness changes have separate scopes. ENOSPC without change, EIO/ENOENT without absence proof and independent association mismatch. Native witness failure is dependency-scoped; account overflow job-wide. 512 dependent tasks create one stop. | Independent mover/barriers establish actual parent/target; no held-fd reuse claim. Successful unrelated roots/candidates accompany refused dependency. Freeze/late return uses fixed sink/serviceability controls. Wrong scope, post-refusal I/O, fallback spelling, lost representable name or dialog fails; synthetic events prove no native race outcome. |

The desired 4,224-byte queue subject uses **listed task locations**, not equality
between cached child canonical text and parent/name. Measured 4,096-byte parent
and 127-byte names produce 4,224-byte joins and unchanged 4,736-byte charges
(79 fit; 80 exceeds bytes); classification must still admit tasks and descendant
canonicalization must separately succeed. Controlled 43/44 and native 512/513
count subjects stay distinct. Current-turn location reacquisition adds prefix
work before reads, so the 496/15,872 dequeue-only figures are not total-work
measurements. Per-witness home/default outcomes and every measured omission
still go to the operator decision. No native measurement, shorter domain,
setup/account/limit change or consent is accepted here.
