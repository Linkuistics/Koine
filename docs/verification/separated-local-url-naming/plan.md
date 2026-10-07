# Separated local bookmark and parent-reference naming — k164-1

Binding [authorized separated charter](../focused-zed-route-assessment.md#separated-local-naming-proposal)
(seven numbered conditions), with the original
[bookmark options](../focused-zed-route-assessment.md#finite-bookmark-diagnostic) and
[parent/name construction](../focused-zed-route-assessment.md#parent-reference-name-diagnostic)
unchanged. This is a distinct instrument: k161's instrument, report and raw corpus,
and every earlier corpus, stay byte-for-byte unchanged.

What differs from k161 (only these):

1. Shared file controls (component-opened original/decoy identity and markers, and the
   **unsuffixed** bare-file identity/marker) plus the component-opened parent
   identity/type bind every case. A failure there ends the whole collection incomplete.
2. The slash-ended bare-parent open is gone. Parent cases instead run one
   **unsuffixed** bare-parent directory open/fstat before and after, compared with the
   component-opened parent. Open/fstat failure makes the remaining parent stages at that
   length unrun/incomplete (never a candidate negative) and does not erase bookmark
   results; identity mismatch ends the collection.
3. Bookmark cases carry no parent-address control.

Unchanged: WithoutImplicitSecurityScope Name/Path bookmark, one WithoutUI/WithoutMounting/
WithoutImplicitStartAccessing resolution, exact returned-path single whole-path
open/fstat/64-byte reader; slash-ended directory NSURL for parent cases, public
`CFURLCreateFileReferenceURL` on it, relative constructor, text-only name observation
before one `absoluteURL`, then the returned-path reader. No fallback, conversion,
slash removal or alternate constructor.

Order: original-900, bare-900, original-1500, bare-1500; parent-public-900,
parent-bare-900, parent-public-1500, parent-bare-1500. One guest, one collection,
at most two builds, 900 seconds clone-through-disposal (native work stops at 840),
preflight prompt/token round trip within 60 seconds before cloning, fresh
screenshot/full agent tree before each separate READY, no external request, UI
interaction, repair or retry. Descriptors <=3, NSURLs <=4, bookmark <=64 KiB,
strings <=8,192 bytes, markers <=64 bytes (caller limits only).
