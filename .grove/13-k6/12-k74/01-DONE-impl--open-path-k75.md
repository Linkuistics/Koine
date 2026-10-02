# open-path-k75

## Goal

Serve `workspaceOpenPath` complete to its design, verified at L, G and N.

## Context

- `docs/specs/workspace-launch-and-open.md`: the path, refusal-policy, source
  document and named-application paragraphs, and the failure table.
- The protected-path answer recorded by `protected-path-metadata-k73`.

## Done when

- Paths are literal and absolute. Empty, relative and NUL-containing paths are
  input errors; spaces and shell punctuation stay literal. A missing path or
  dangling link is `PATH_NOT_FOUND`, checked before handler resolution so a
  missing file is never conflated with a missing handler.
- After symlink resolution, the policy refuses:
  - application bundles identified by resource metadata;
  - content conforming to `com.apple.application-bundle`,
    `public.unix-executable` or `com.microsoft.windows-executable`;
  - `com.apple.alias-file`, for both default and named opening.
  Ordinary source and script documents are not refused on the grounds of
  `public.executable`, `public.script` or permission bits. Failed inspection is
  `failed`.
- A null application selects the default handler, and a missing one is
  `NO_DEFAULT_HANDLER`. A named application uses the shared application input and
  its installation semantics; native refusal is `failed`, with no fallback,
  chooser or handler change. Directories reach a named application such as Zed.
- L: with the adapter substituted, cover metadata variations, replacement races,
  a missing handler, inspection denial and every acknowledgment path.
- G: composition tests cover the path field's authority, branches, input errors
  and multi-action behavior.
- N: the real bundle serves the widened contribution. Nothing is opened on the
  host.
- The served contribution adds the path root verbatim from the design file.

## Decisions (running log)

- **Order and shape.** `planPathOpen` (Logic/OpenPath.swift) is the whole decision: validate the
  path and the optional application as input, then inspect the target (absent is
  `PATH_NOT_FOUND`, unreadable is `failed`), then apply the refusal policy, then choose the
  handler (a named application through launch's `selectInstallation`, otherwise the default
  through `selectPathHandler`), and only then submit. A missing path therefore wins over a
  missing named application, and an unusable application is input before the target is
  looked at. The provider submits through the same `submit` as launch and the URL root, so one
  capacity, bound and receipt serve all three.
- **Metadata route.** `inspectPath` uses `realpath`, `stat` on the resolved path and the
  `isApplicationKey`, `contentTypeKey` and `isAliasFileKey` resource values, all of which the
  protected-path probe measured prompt-free (directory-ness comes from `stat`, which it also
  measured). `realpath` resolves symlinks, so a link to an application is an application and a
  dangling link is absent; an alias file is not a symlink and is seen as itself. (After the review below: the literal path is `stat`ed first, and
  ENOENT, ENOTDIR, ELOOP and ENAMETOOLONG are absent; everything else, EACCES included, is
  `failed`.)
- **Refusal policy is data-driven.** The native layer reports facts (`isApplication`,
  `isAliasFile`, content type identifier) and a `contentType(_:conformsTo:)` primitive; the
  policy is workspace logic, so L varies the metadata. Order: alias, application, executable.
  Host probe of the real classification (throwaway, not committed): a Mach-O program and an
  extensionless executable text file are `public.unix-executable` (refused); `.sh`, `.js`,
  `.command`, `.webloc`, a folder and an `.rtfd` package are not; a symlink to an `.app`
  resolves to an application; a bookmark-file alias is `com.apple.alias-file`. An
  extensionless executable *text* file being refused follows from the spec's own type rule.
- **What is submitted.** `URL(fileURLWithPath: path, isDirectory:)` from the literal path, not the
  resolved one, so the handler follows links as usual (a location request). The default
  application is looked up for that same URL. Whether the file-URL lookup follows a symlink is
  for V (`open-path-vm`) to confirm with a real link.
- **Protected default opening is not decided here.** The file-URL default-handler lookup is the
  only route to a default application, and it prompted for documents in protected folders in
  the probe. The leaf's contract requires a default open, so it is implemented, with no consent
  added and no fallback, and documented as accepted for unprotected locations and for named
  applications only. The brief's pending human decision stands (`document-paths`); it is
  stated in the spec, the client guide and the native adapter's comment.
- **Dependency text does not echo the path.** `PATH_NOT_FOUND` and `NO_DEFAULT_HANDLER`
  guidance is generic, as the URL's is, so a filename is never copied into a message.
- **Call-path check widened.** `task check:launch-call-path` now expects exactly two handler
  lookups (the scheme-only one and the item's own URL), still one open request shared by the
  URL and path roots, the item built from the validated path, the three measured resource keys,
  and no directory listing or content read. Each new check was seen red against a mutated
  source (wrong lookup argument, an extra resource key, a directory listing, a second open).
- **Conformance.** The workspace profile's design file gains the path root (two lines,
  verbatim), `SchemaConformanceTests` moves it out of the not-yet-implemented set, and
  `conformance-lib.sh` gains a control that removes it. The profile run itself is V
  (`open-path-vm`, which also owns the contract-only client's examples).
- **A second flaky test.** `denialAtANonNullProcessFieldRemovesTheProcessAndNamesThatField`
  failed once in a full run beside the known `denialInsideADependency...` one; it is the same
  family (non-null siblings resolved concurrently, the error reported at either). Noted in
  `stabilise-dependency-denial-test-k87`. Neither touches this leaf's code.
- **In-session review (the leaf's one allowance), on the refusal policy and the inspection.**
  A fresh context was given the contract and the code. Valid and fixed, each with an N case:
  `realpath` resolves `file.txt/`, `file.txt//` and `file.txt/.` to the file though the kernel
  rejects them (ENOTDIR), so a file addressed with a trailing slash was inspected as present,
  had its slash dropped by `URL(fileURLWithPath:)`, and would have been opened; the literal path
  is now `stat`ed first (a measured prompt-free call). A symlink loop (ELOOP) and a name too long
  to exist (ENAMETOOLONG) were `failed` and are now absent, since nothing is there to open.
  `isApplication` and `isAliasFile` read as "no" when the platform supplied no value; an unset
  value is now `failed` (not reproducible on a local volume, cheap and in the spec's rule).
  Visible trade-off, accepted and not changed: an extensionless script is `public.unix-executable`
  with its executable bit and so refused, and `public.data` without it and opened. That is the
  spec's own type rule against its own "irrespective of executable bits" sentence; with a
  typed extension (`.sh`, `.js`, `.command`) the bits play no part, and the refusal for the
  extensionless case is stated in the client guide. Raise it in the spec if Antony wants the
  rule narrowed. Held up under its attack: `..` through a symlink, `%` in names, directory
  symlinks, ordering, cancellation, one-shot, capacity and the conformance helper's fallbacks.

