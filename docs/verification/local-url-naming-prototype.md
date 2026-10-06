# Local naming collection: stopped at a parent-directory control

**The replacement collection passed its interactive-input check, but stopped
before any of the eight naming cases.** While checking the 1,500-byte fixture,
the instrument opened the bare parent-directory address with a trailing slash.
That exact control returned `ENAMETOOLONG` (errno 63). The guest was disposed.
Bookmarks and the parent-reference-plus-original-name candidate remain unanswered.

This is a distinct attempt from the earlier
[closed-input stop](bookmark-name-resolution-prototype.md). The new terminal
round trip succeeded before guest allocation, and I inspected the fresh
preparation screenshot and every returned full-mode agent-tree node before
responding READY. The collection then reached fixture creation and controls.

The 900-byte fixture completed its independent original, sibling-decoy,
bare-file and bare-parent identity/marker controls. The 1,500-byte fixture
reached successful component-based original and decoy marker reads, then failed
the bare-parent open. Its full controls did not complete. Because these controls
are prerequisites shared by the cases, the instrument stopped immediately.

The control spells the parent address as `/.vol/<device>/<full-parent-inode>/`.
It calls ordinary POSIX `open` with directory, no-follow and close-on-exec flags.
It has not yet made a parent-reference URL, appended the original filename, or
created a bookmark. The unsuffixed parent address was not tried. Consequently,
this observation applies only to that exact prerequisite open; it establishes
neither a bookmark negative nor the outcome of either parent URL construction.
I will preserve the instrument as run rather than silently change that control.

## Eight cases remain unrun

| Planned case | Name/property observation | URL creation/resolution | Measured same-object read |
| --- | --- | --- | --- |
| Original pathname, 900 bytes | Unrun | Unrun | Unrun |
| Bare file address, 900 bytes | Unrun | Unrun | Unrun |
| Original pathname, 1,500 bytes | Unrun | Unrun | Unrun |
| Bare file address, 1,500 bytes | Unrun | Unrun | Unrun |
| Public parent reference plus name, 900 bytes | Unrun | Unrun | Unrun |
| Bare parent address plus name, 900 bytes | Unrun | Unrun | Unrun |
| Public parent reference plus name, 1,500 bytes | Unrun | Unrun | Unrun |
| Bare parent address plus name, 1,500 bytes | Unrun | Unrun | Unrun |

No stored Name/Path, bookmark resolution error or stale flag, constructed
relative/absolute child spelling, parsed URL basename, returned-path extraction,
or measured whole-path open/fstat/read exists for those cases. Successful fixture
marker controls are separate local preparation evidence, not a naming result.
No Zed or other receiver was requested, and no UI interaction occurred.

The [approved charter](focused-zed-route-assessment.md#replacement-bookmark-decision)
and [parent group](focused-zed-route-assessment.md#parent-reference-name-diagnostic)
allow one guest and collection, with no repair or recollection. Those limits
were respected: **two precollection builds, one collection, zero case attempts,
zero external requests, zero repairs and zero retries**. The clone reported
macOS 26.5 / 25F71 on APFS, with Gatekeeper enabled and the expected Developer ID
signature, hardened runtime and empty entitlements. Disposal completed after
**55.22 seconds**, within the 15-minute cap; the stop receipt and final inventory
confirm its removal.

All 672 frozen input subjects agree individually before and after collection,
including the earlier evidence corpora. All 45 final output-manifest subjects
also match. Exact source, build/input/raw records, terminal facts, controls and
teardown receipts are linked from the
[technical evidence](local-url-naming-technical-evidence.md).

## Recommended disposition

I recommend accepting this as an **incomplete local diagnostic** for the already
scheduled returned design, k162. Acceptance would acknowledge the actual stop
and let that design assess the control failure and remaining question. It would
establish no naming/receiver result, authorize no repair or new experiment, and
adopt no production spelling or support exception. The complete long-path route
and all its ancestors remain live. No automatic follow-on is selected.


Antony answered **“Accepted.”** on 2026-10-07. This accepts the incomplete
report for k162's assessment and completes the scoped prototype's human
reaction. It grants no repair, recollection, new experiment, receiver result
or production exception. All eight cases and the complete route remain unresolved.
