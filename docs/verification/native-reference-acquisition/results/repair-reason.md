# Instrumentation repair (the one permitted by k143)

Run 1 stopped the 1,500-byte walks (file and directory) at a probe-added gate: after descending into a returned
child reference the helper called `FSGetCatalogInfo` and ended the walk if that failed (-43 at 1,258 cumulative
bytes). The charter's walk ends at an iterator/enumeration failure; a catalog-info consumer failure is separate
evidence and the gate hid whether `FSOpenIterator`/`FSGetCatalogInfoBulk` work from a reference past the boundary.
Repair: record the status as `firstConsumerFailure` and continue the walk. Nothing else changed (API route,
platform, subjects, process/privacy posture, bounds). Run 1's records are retained unmodified in `run1/`.
