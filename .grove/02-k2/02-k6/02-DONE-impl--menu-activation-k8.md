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
- CBM `list_projects` again refused access because a pre-coordination or unverified generation is active. Use bounded source reads; do not stop another session.
- Recreate the historical route on released 0.4.0 in one clean macOS 27 guest before selecting any repair. Reuse the fresh-process native observer qualified in k7, retain native state and screenshots before keyboard intervention, and separate exploratory diagnosis from complete-scenario acceptance. No activation workaround or new polling bound is justified by the source alone.
- The one historical-route action succeeded with TextEdit natively active beforehand, Koine active and first in native window order afterward, and visible menu dismissal before keyboard input. The initial observer failed on upload permissions before any Settings action; preserve both attempts. This does not establish the historical cause, justify an application repair, or select a focus polling bound.
- Close the concrete k7 inventory gap by recording every regular file and symlink of the installed guest bundle before launch and after final Quit in the existing scenario. Compare those manifests as part of acceptance. Run exactly one full attempt with the host scripts, Taskfile, App/Info.plist, fixtures and extracted bundle frozen too. Keep historical activation unresolved and check the parent criteria explicitly.
- One fresh-context reviewer read the inventory helper, its two call sites and guest()/guest_text(). No actionable defect was found in read completeness, symlink association, action replay or comparison placement. This spends k8's one in-session review allowance; it is a bounded source review, not native activation evidence.
- Use the existing k2/k6 allowance for an unexplained historical symptom with a precise remaining task. K4 already owns the finite diagnostic sample; its body now requires qualified observation-only capture at the first reproduced failure, before keyboard/focus/action intervention, without expanding the cap. This preserves issue 14's activation outcome as unresolved. Any parent close still requires the complete stricter scenario and full endpoint inventories to pass.
- The single frozen full Taskfile attempt exited 0. Every intended reopen, silent launch, explicit reopen, Command-Q, reboot/login launch and final Quit completed; resize alone was NOT RUN. Every host input hash verified, re-enumerated file and symlink inventories matched, and the installed guest manifests matched each other and the extracted host app. Both investigation guests are stopped. The evidence and limits are retained in docs/verification/menu-bar-vm.md and menu-bar-activation/.
