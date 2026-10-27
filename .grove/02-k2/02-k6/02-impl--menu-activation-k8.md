# menu-activation-k8

## Goal

Explain the historical Settings action that visibly opened behind TextEdit, and
repair an established local cause if one is found. Complete menu-focus-k6 and
menu-interaction-k2 only against their original acceptance criteria.

## Context

Read the parent briefs and docs/verification/menu-bar-vm.md, including the k5
failure and k7 observer qualification. The historical screenshot and agent
window order showed Koine behind TextEdit; k7 did not reproduce that failure.
System Events process/frontmost and window AXFocused reads can disagree with
fresh AppKit activation, CoreGraphics ordering and actual keyboard delivery.
Do not treat that observer as an independent focus oracle without qualification.
The exploratory NSWorkspace polling monitor did not pump AppKit's run loop;
its activation trace is excluded. Native AX system-wide reads failed -25204.

## Done when

- Use a qualified native activation observer, independent window ordering and
  visible menu dismissal around one action; record the native state before any
  keyboard intervention. Separate input-route, application and observer defects.
- Establish a cause before application changes or a focus polling bound. For
  AppKit decisions consult version-matched official sources. Preserve each
  attempt and intervention; no action retries may turn a failure into success.
- Repair and verify any established local defect. If an external limitation or
  unreproduced historical symptom remains, retain a precise unresolved outcome
  rather than claiming a repair. Decompose if investigation expands again.
- Run a complete frozen scenario when warranted by a repair or unresolved
  concern, retaining every file of the actual app bundle, sourced scripts,
  Taskfile, App/Info.plist (read by signing-env.sh) and client fixtures in its
  before/after inventory. K7's original SHA inventory covers the extracted app
  tree and named scripts/fixtures; repository Info.plist identity is a separate
  comparison against the session's initial clean VCS parent. Check the k6 and
  k2 criteria explicitly before closing either node. Resize remains k3's work.

## Decisions (running log)
- K7's one full stricter-scenario attempt passed, with resize NOT RUN. It retained
  inherited TextEdit settling and window-count timing. Do not infer a historical
  activation repair from this run. If claiming a complete installed-subject
  freeze in a later run, collect the guest app tree before and after as well as
  the extracted host input, and include App/Info.plist in the original inventory.
