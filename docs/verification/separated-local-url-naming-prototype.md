# Separated local naming collection: eight cases ran

**All eight cases ran in one disposable guest.** The 900-byte cases mostly worked.
The 1,500-byte cases mostly did not. The decisive finding is that a **parent
reference plus the original name carries the original basename at both lengths
(in the URL text), while the file-reading step fails at 1,500 bytes.** Nothing
here is a Zed or production result.

## The two attempts

An earlier collection (`separated-local-url-naming/results/`) passed its fixture
controls but stopped before any case, because my supervisor reply missed a 60-second
bound. It ran no cases and is preserved unchanged. After Antony's **"b"** granted one
new collection, this one ran (`results-2/`). Same frozen instrument, one build, new
guest, 183.9 s clone-to-disposal (cap 900 s), disposal and absent-inventory confirmed,
preflight round trip 9.2 s, 725 frozen subjects unchanged, 111 output digests. Zero
external requests, UI interactions, repairs or retries.

## What the separated controls bought

Both fixtures completed shared file controls (original, decoy, unsuffixed bare-file
identity/marker, component-opened parent type) with no slash-ended parent prerequisite.
Every parent case then passed its **unsuffixed** bare-parent open/fstat identity
control before and after, at both lengths. The slash-ended open that stopped k161 is
never required.

## Bookmark cases

| Case | Creation | Stored Name / Path | Resolution | Same-object read |
| --- | --- | --- | --- | --- |
| original path, 900 | OK (2,168 B) | original name and path exact | OK, not stale | **Yes** (marker, original identity, not decoy) |
| bare file address, 900 | OK (1,292 B) | original name and path exact | OK | **Yes** — resolved to the long original path |
| original path, 1,500 | **Failed**, Cocoa 260 | unrun | unrun | unrun |
| bare file address, 1,500 | OK (292 B) | Name **exact** (`K164-original-1500.txt`); Path is just `/` | **Failed**, Cocoa 4 | unrun |

So at 900 bytes a bookmark made from the short address recovers the original name,
path and object. At 1,500 it still *stores* the original name (readable without
resolving), but its stored path is `/` and it cannot resolve.

## Parent reference plus original name

| Case | Name in relative text | Name in absolute URL | Absolute spelling | Path / read |
| --- | --- | --- | --- | --- |
| public reference, 900 | exact | exact | `file:///.file/id=…286162/K164-original-900.txt` | long original path; **same-object read yes** |
| bare parent, 900 | exact | exact | `file:///.vol/…/286162/K164-original-900.txt` | short path; **same-object read yes** (original path not reproduced) |
| public reference, 1,500 | exact | exact | `file:///.file/id=…286184/K164-original-1500.txt` | **path extraction returned nil**; read unrun |
| bare parent, 1,500 | exact | exact | `file:///.vol/…/286184/K164-original-1500.txt` | path extracted (44 B); **open failed, errno 63 ENAMETOOLONG**; read failed |

The original 21/22-byte basename is present in every constructed URL. At 900 the
reader follows it to the right object; at 1,500 the reader cannot, because the
public reference gives no path and the bare `/.vol` path resolves back to a name too
long for the kernel. "Name readable" and "same object read" are graded separately;
later successes repair no earlier failure.

## Limits and what this does not show

Local, single-guest, two lengths, one run each. It is not Zed's actual naming or
opener behavior, not a durable supported spelling, and not a route. The 1,500-byte
failure may be specific to these exact constructors. Raw evidence, exact errors and
spellings: `separated-local-url-naming/results-2/` (`summary.json`, per-case `.out`).

## Antony's reaction (2026-10-07)

Stop pursuing this: record it as a GitHub issue ([Linkuistics/Koine#1](https://github.com/Linkuistics/Koine/issues/1))
and move on. Koine's own traversal/filesystem code should use a directory-descriptor
abstraction over `openat`-family calls, resolving component by component so path
length is not a limit. Applications that cannot handle long absolute paths should
simply surface the failure; making them work is deferred until after v1. This report
grants no repair, recollection or further native investigation.
