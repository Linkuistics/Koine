# architecture-fragment-navigation-k316


## Goal

Repair fresh-document fragment navigation in the architecture viewer, including Safari's
reported Packaging deep-link failure, before app-and-file-search-k7 uses that delivery surface.


## Context

Review k312 R8 at 4392295c; final delivery limits in
docs/verification/application-reference-input-partition.md preserve the Safari failure.
The recorded Chrome fresh-fragment and Safari mobile-light fit observations do not fix it.
Own the viewer navigation implementation under docs/design/architecture/ and its focused
regression evidence. Follow the current documentation/readable-view contract and graph
coverage/source fallback for code discovery. Use existing design:serve/render/check tasks.
## Done when

Reproduce fresh Packaging-fragment navigation from a new Safari document, repair the cause,
and verify fresh and in-page navigation for all seven reference diagrams without losing
existing default/other-diagram navigation. Use isolated TestAnyware browser testing where
available under the GUI skill; record unavailable Safari as precise live acceptance work,
not a Chrome substitute or passing result. Verify at least one affected regression observes
the original defect before it passes with the fix. Record exact browser/viewport/surface
limits; prior mobile-dark/native-size and other unmeasured limits remain. Update only
affected current delivery notes after actual evidence.
## Notes

This is a presentation repair. It grants no instrument/control/authority/native pass and
does not gate Q/P qualification merely by existing. No installed evidence acquisition or
reference attempt is authorized. Preserve other agents' work and current diagram content.
