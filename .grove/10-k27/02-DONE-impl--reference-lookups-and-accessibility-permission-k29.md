# reference-lookups-and-accessibility-permission-k29

## Goal

Constrain the path the identity leaf opened: the three desktop lookups agree,
every reference that no longer names its target is `unavailable`, and a read
without Accessibility consent is an OS-permission error that names Koine and
never prompts.

## Context

- Spec: the desktop signatures table; "Resource references and desktop
  behavior"; "Errors and partial data"; the OS-permission paragraphs of
  "Application composition and availability".
- The identity evidence and reference encoding recorded by
  `application-identity-and-window-listing-k28`, including its route for
  granting and removing Accessibility consent in a VM.

## Done when

- `desktopApplicationByReference(ref:)` and `desktopWindow(ref:)` are served
  under `desktop:read`. For one running application, the application reached by
  process identity and by its reference, and a window reached through
  `windows` and through `desktopWindow`, report the same references and
  fields.
- Each use re-resolves. A reference is `unavailable` when its process
  incarnation has ended, when its window has closed, when it names the other
  resource kind (a window reference given to the application lookup and the
  reverse), when its remainder is malformed for this provider, and when the
  native identity is ambiguous by the identity leaf's evidence. A reference
  naming another provider reaches this provider and is `unavailable`. None of
  these is null without an error, and none resolves a substitute.
- What a reference does across a Koine restart is stated and verified: it
  resolves again where the encoded identity is sufficient, otherwise it is
  `unavailable`.
- Without Accessibility consent, reads that need it fail with `permission`,
  permission class `os-permission`, naming `accessibility` and Koine as the
  owner, at the original response path with standard non-null propagation. A
  grant without `desktop:read` still gets the `capability` class; the two are
  distinguishable in one verification run. State which fields need consent and
  which resolve without it, and serve the latter.
- No read triggers the consent dialog: the provider checks trust without the
  prompt option. Verified in a VM with consent absent by observing that no
  dialog appears, and with consent revoked while Koine runs.
- The VM verification task covers these cases against the signed build; the
  evidence is under `docs/verification/`.

## Notes

`ProviderFailure` already carries an OS-permission kind and the engine already
maps it to the `os-permission` extensions; this leaf uses that path and adds no
second one.

Whether macOS reports revoked consent to a running process promptly is an
observation to record, not a behaviour to paper over.

## Decisions (running log)

- **Order of a window lookup.** Parse, process incarnation (kernel), session and
  table membership are decided before the trust check, because none needs an
  Accessibility call. A reference that names nothing is `unavailable` with or
  without consent; only asking the held element needs consent. This also makes
  every no-Accessibility case testable on the host.
- **Fields and consent.** `DesktopApplication.ref`, `name` and `bundleIdentifier`
  resolve without consent, by either application lookup. `windows` and
  `desktopWindow` need it.
- **By reference, an ended application is `unavailable`, not null.** Null is for
  a process identity the caller captured itself; a reference was issued by Koine.
- **Ambiguous identity.** A held element that is no longer a window, or fails the
  own-window check, is `unavailable`. Its token is retired only when the element
  answers that it no longer exists, so a transient failure of the check does not
  change a live window's reference.
- **`kAXErrorAPIDisabled` is the OS-permission error too**, so consent that ends
  between the trust check and the call is not reported as `failed`.
- **`desktopWindow` reports `CURRENT`**: the element answered just now.
  `remembered-windows-across-spaces` owns what a listing says of a held window
  that `AXWindows` does not list.
- **The process that shows the consent dialog is no detector of it.**
  `universalAccessAuthWarn` runs, showing nothing, after Koine's plain
  `AXIsProcessTrusted()` answers false. The VM run reads the screen for the
  dialog's text, and `Fixtures/ConsentPromptControl` shows that reading dirty.
- **`tccutil reset Accessibility dev.antony.Koine` does not revoke in effect for
  the running Koine**: observed, 60 s of successful window listings after it
  reported success. Recorded as found.
- **Revocation in the run is the user's route**: Koine's switch in System
  Settings, then the account password. Observed by hand first: the running
  Koine's next read, 4 s later, was the `os-permission` error, with no dialog.
  The switch shows off before the password sheet is answered, so only the read
  proves revocation.
