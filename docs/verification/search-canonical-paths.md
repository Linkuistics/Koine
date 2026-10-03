# Canonical directory call analysis

This is source/SDK analysis for the
[canonical directory contract](../specs/workspace-search.md#canonical-directory-observation),
not a native search measurement. Implementation, independent provider/GraphQL
and signed hardened macOS acceptance remain pending. The canonical review found
[path-design dependencies](../specs/workspace-search.md#path-design-dependencies)
that require producer/review work before the complete-resource review/planning:
resolver/pre-open policy, cached spelling, representable directory names and
long-path classification. No shorter domain, consent/setup, entitlement or limit increase
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
conditional on classification and canonical spelling actually establishing those
tasks. The selected path-based resourceValues/Bundle calls conflict with the
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
The adapter's own hop/readlink/expanded-work and dot-dot/firmlink rules are not
yet specified; the resolver producer owns them for every path length and source.
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
