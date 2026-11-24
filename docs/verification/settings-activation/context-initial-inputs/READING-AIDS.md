# Reading aids beside the archived charter

The archived [charter](CONTEXT-PLAN.md) links two relative targets:
`context-predicate.txt` and `context-qualify-filter.sh`. K19 retained this
archive in commit e3000cec on 2026-10-28, without those two files. On
2026-11-25, k23 added them beside the charter as reading aids, so that both
links resolve.

| Reading aid | Frozen subject | SHA-256 |
|---|---|---|
| [context-predicate.txt](context-predicate.txt) | [docs/verification/settings-activation/context-predicate.txt](../context-predicate.txt) | `36f5ed35408f91c186a806135f5487a44c09eefe806fd0796f2c21b86b8bec8b` |
| [context-qualify-filter.sh](context-qualify-filter.sh) | [docs/verification/settings-activation/context-qualify-filter.sh](../context-qualify-filter.sh) | `e32070d14c0a66b65f9999b2c72bd3785e45e22bd73bfca70cf8325428acd5fa` |

Each aid holds the bytes of its frozen subject in commit e3000cec. Its digest
equals the line for that subject in the [frozen manifest](context-subjects.sha256).
The guests used the frozen subjects at the manifest paths. No guest used these
copies, and the copies are not part of the measured overlay.

The charter and every other archived file keep their recorded bytes. The task
`check:settings-archive-links` compares the archived files and the two aids with
their recorded digests. It also runs the original overlay audit again, without
the aids.

This correction changes only the packaging of the archive. It establishes no
cause, activation repair, ordinary acceptance or release.
