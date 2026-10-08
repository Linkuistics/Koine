# Filesystem access is descriptor-relative

Koine's own filesystem work — action-time presence and cause inspection, search
traversal, application-copy identity and the receipt's two executable identities —
resolves a location component by
component from held directory handles (`openat`, `fstatat`, `readlinkat`,
`fpathconf`), never by handing a whole absolute pathname to `realpath`, `stat`,
`FileManager`, `URL.path` or a joined absolute string. An absolute pathname is a
value Koine reports to clients and hands to applications; it is not the access
primitive. Koine's resolution mirrors the kernel's own semantics: literal
components, at most 32 symbolic-link expansions, relative link text read from
the link's own directory, physical `..` and trailing-slash directory demands. It
never pre-judges a name against a filesystem limit: a successful lookup is
presence, and a name-length refusal proves absence only where the comparison
cannot depend on the filesystem's unknown unit.

The trade-off is between a long location being misreported and Koine owning
resolution semantics. Whole-path calls stop at the SDK's `PATH_MAX` of 1,024
bytes including NUL, and the shipped action inspection mapped their
`ENAMETOOLONG`/`ELOOP` to "path not found". The
[k134 prototype](../verification/long-action-route-prototype.md#what-was-measured)
showed component-relative calls reaching about 1,500-byte items and
distinguishing missing, below-file, cycle, link-budget and impossible-component
causes that whole-path calls cannot. In exchange Koine carries its own link and
dot rules, which must match the kernel exactly, a conservative reading of
name-limit failures, and a descriptor budget. The [application survey](../research/long-pathname-applications.md#51-component-relative-resolution-for-presence-and-cause)
records how mature walks failed — descriptor exhaustion, broken recovery
branches, depth-evading security checks, reconstructed strings re-entering
whole-path calls, consent prompts and drifting spelling — and the
[action contract](../specs/workspace-launch-and-open.md#long-location-action-boundary)
answers each as an obligation.

Handles that only resolve a location are opened search-only (`O_SEARCH`): they
grant lookup, never listing, and resolution opens no file contents. Search's
listing streams still read the directories they list, under search's own
protected-scope policy. A read-mode walk prompted at the Documents component in
k134, where the accepted whole-path metadata route did not.
Search-only first-use behaviour in Desktop, Documents and Downloads was
[measured](../verification/descriptor-walk-prompt.md) on macOS 26.5: the walk's
`openat(O_SEARCH)`, `fstatat` and `readlinkat` did not prompt, where the
read-mode control did. It remains an acceptance obligation for the VM rows and
other OS builds, not an assumption. If it ever prompts, the prompt-free read
rule and this decision conflict; that goes to Antony rather than reintroducing
whole-path primitives or shipping a prompt.

Lookup-only access does not authorize a search-policy exemption. Search's
[pre-open boundary](../specs/workspace-search.md#pre-open-proof-boundary)
evaluates serial lookup-only acquisition of relocated policy-target identities,
but its strict no-target-open witness rule awaits an explicit inspection-policy
decision. The measured real-folder transit does not establish relocated-target
listing behavior or Library/cloud/foreign-volume safety. Component resolution
also cannot guarantee that a mounted-root metadata probe avoids foreign contact
or blocking before device refusal; search owns its fixed bootstrap premise,
inspection policy and native-call lifecycle limits.

This decision does not make applications accept long locations. macOS opener,
registration, type and handler services take whole pathnames and fail at
`PATH_MAX`; v1 refuses that hand-off truthfully instead of working around it
([Linkuistics/Koine#1](https://github.com/Linkuistics/Koine/issues/1)), as the
action contract states. Revisit this decision only if a supported platform
service gives prompt-free presence, identity and cause at any length with the
kernel's semantics.
