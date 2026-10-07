# protected-default-open-k89

## Goal

Settle with Antony the one `workspaceOpenPath` case the project cannot accept without a
human decision: opening a **document** in its **default** application when the document is
in Desktop, Documents or Downloads. Nothing in `workspaceOpenPath` requests or suppresses
the consent that asking the system for that default can raise, so the case is pending, not
accepted.

## Context

- `docs/verification/protected-path-metadata.md`, "Handler lookup limit": the only route to a
  file's default application (`NSWorkspace.urlForApplication(toOpen:)` for the item's own
  URL) raised a Files and Folders prompt for documents on Desktop, Documents and Downloads, and
  returned a usable handler even after the prompt was denied. A folder's lookup did not prompt.
  Metadata inspection (`realpath`, `stat`, the three resource values) was prompt-free, and so
  are named-application opening and reveal.
- `docs/specs/workspace-launch-and-open.md`, "Documents, directories and settings" (the
  "Pending, and not accepted here" paragraph) and the Consent row; `docs/client-guide.md`,
  "Opening a document or folder" item 6, which tells a client to name an application for a
  protected document until this is decided.
- `docs/verification/target-locations-vm.md`, "First use in the protected folders" (found by
  `target-locations-vm-k180`): the prompt is wider than the default-handler lookup of a document.
  On first use in Desktop, Documents and Downloads, a document opened with Zed named and a
  directory opened by default or with Finder named each raised "Koine would like to access files in
  your … folder", while a reveal never did, and a plain program that is not Koine is prompted the same
  way when it hands such an item to an application. So naming an application is **not** an escape
  hatch, and a setup (or a decision to document the limitation) has to cover every open of a protected
  target, not only a default open of a document.
- `docs/verification/open-path-vm.md`: everything else about path opening is accepted at V in
  a prepared VM, with no fixture in a protected folder and Accessibility absent.
- `.grove/14-k7/_app-and-file-search.md`: search must not use the file-URL lookup as a readiness
  read, and must say which handler coverage is unknown or blocked.

## Done when

- Antony chooses, and the choice is recorded where the spec and the guide can cite it:
  - **keep the current no-new-consent policy**: a protected document can be opened by a
    **named** application only, and a default open of one is documented as a client choice
    (name an application) and is never accepted by this project; or
  - **an explicit, separately designed Files and Folders setup**: Koine asks for that
    access through its own window, as it does for other consents, so that default opening of
    a protected document is accepted after it (the recommendation of the protected-path
    probe); or
  - **type-only default matching** for protected documents (the default for the type, not for
    the item): a different contract that can ignore a per-file opener, for which no
    fallback was measured or approved.
- If the setup or the type-only rule is chosen, the work is cut as `impl` leaves with their
  own VM acceptance, and the Documents/directories/settings row and the Consent row say so.
- If the first is chosen, the spec's pending paragraph is rewritten as a documented
  limitation, and `baseline-acceptance` does not wait on it.

## Notes

Cut by `open-path-vm-k76` rather than left as prose in the documents: the launch-and-open
brief allows only certificate-dependent cases to remain pending when its node closes, and this
one is a consent decision, which only Antony can make. It sits before `baseline-acceptance`
so that the answer exists before the baseline is declared.
