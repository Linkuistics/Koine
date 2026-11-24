# Archived charter link aids: evidence — k23

On 2026-11-25, k23 added two [reading aids](../context-initial-inputs/READING-AIDS.md)
beside the archived initial context charter. These files record the checks for
that packaging correction.

| File | Content |
|---|---|
| [controls.txt](controls.txt) | Two live mutation controls on the real tree, and the restored digests |
| [archive-check.txt](archive-check.txt) | The full output of `task check:settings-archive-links` |
| [doc-links.txt](doc-links.txt) | The full output of `task check:docs` |
| [subjects-before.sha256](subjects-before.sha256) | Subject digests before the final runs |
| [subjects-after.sha256](subjects-after.sha256) | Subject digests after the final runs |

The first control appends one byte to an aid. The archive check then fails, and
it names that aid. The second control removes the other aid. The documentation
check then reports the missing target again. After each control, the aid is
restored from commit e3000cec, and its digest equals the manifest.

The archive check passes. All 7 files of the initial archive and all 5 files of
the second archive keep the bytes of commit e3000cec. Both aids equal their
frozen subjects. The overlay audit reconciles every repository subject at that
commit, with the original 4 overlay files in each archive.

The host mise configuration in each manifest changed after the freeze. The
repository does not hold that file, so the audit reports it as NOT CHECKED. That
outcome is missing evidence, not a failure. The 18 .build subjects in each
manifest match their current local bytes.

The documentation check passes with no missing target. Earlier records of the
two missing targets keep their historical text.

This correction changes only the packaging of the archive. It establishes no
cause, activation repair, ordinary acceptance or release.
