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
