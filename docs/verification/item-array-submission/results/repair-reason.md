# Instrumentation repair (the one permitted by k146)

Run 1 delivered an `aevt/odoc` to the recording application for both 1,023-byte calls, but the recorder kept only a
file URL coerced from the item descriptor (type `bmrk`, a bookmark). That coercion returned nothing at 1,023 bytes
(worked at 900), so an undelivered spelling, a wrong spelling and an unreadable bookmark were indistinguishable and
the raw delivered descriptor had not been retained. Repair: the recorder additionally logs the raw item descriptor
bytes and what Foundation reads from the bookmark (stored path; resolution result/error), and the reader uses the
stored path when the coerced URL is absent. The helper, API calls, flags, subjects, bounds and process/privacy
posture are unchanged. The 1,024-byte calls failed at the API (status -41) in run 1 and are not an
instrumentation question; they are rerun unchanged in the second, final collection. Run 1 records are retained
unmodified in `run1/`.
