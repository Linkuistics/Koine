# settings-file-lifecycle-k150

**Integrates:** settings-file-lifecycle-k149

## Goal

Triage the independent review of the k89 file transfer and lifecycle artifact.
Apply findings that meet the agreed acceptance and material-risk threshold
before k81 or k76 consumes it.

## Context

Find the commit for `settings-file-lifecycle-k149` and read its findings from
that commit. The review artifact is
`docs/verification/settings-activation/ORDERING-FILE-LIFECYCLE-REVIEW.md`.
Read the producer `settings-file-lifecycle-k89`, the current file/lifecycle
report, the inherited k36 contract and the archived charters it names.

## Done when

- Independently check and classify each finding against source and the
  agreed contract. Record each disposition and its evidence.
- Repair real issues within this kind's scope and run the appropriate reusable
  checks. Preserve old receipts and qualify their limitations accurately.
- Reconcile every original duty with its existing owner before handoff.
  Retain any question that requires a human scope decision rather than
  silently changing acceptance.
- Keep caller adoption, signals, finite runtime and actual freeze with their
  existing owners. Permit no VM, candidate, native acceptance or ancestor
  closure from these source-only helpers.

## Notes

The findings belong to the review's own commit. This body does not prescribe
their acceptance. k81 and k76 follow this integration. k67, k62, k57 and k54
retain their original duties and runtime holds.

## Decisions (running log)

- 2026-11-21: Read the findings from review commit 8383de152354. The tagged
  agent client object at 65bc05c91cc5 has the receipted digest af438f8d…a48a.
  Its `download` deletes the temporary sibling on any streaming error. The
  backend has no timeout of its own, so the client deadline governs.
- 2026-11-21: P2-1 is a real issue. The report claims that a failure keeps the
  original bytes, and the dependency deletes them before it returns. The
  rejected resource contract needed a dependency change for partial downloads.
  The ADR withdrew that design, and external implementation stays unauthorised.
  Repair the report, and state the bytes of a failed download as explicitly
  unavailable. Add a control that a signal-killed CLI leaves its temporary file
  in place. A failed download already stops the slot without acceptance, so
  this limit changes no acceptance.
- 2026-11-21: P2-2 is a contract stated unclearly. The k76 rule keeps all
  original action and read counts. The protocol gives an unlisted one-shot
  operation only its existing assertion. No agreed text admits the three added
  downloads. Withdraw the paired download from the k76 handoff and the caller
  table. Each upload keeps the checked local, remote and byte identity. The
  k57 installed-file audit and the k81 installed inventory keep the guest-side
  checks. A scenario download of the guest bytes needs a new human amendment.
- 2026-11-21: P3-1 is a real issue. The ten measured subjects do not cover the
  inputs of the eleven checks. Qualify the k89 receipt in the report, and keep
  its bytes unchanged. Measure the fresh verification over every tracked and
  untracked file of the working copy, and record the tool versions.
- 2026-11-21: The new control passes unchanged source. Two mutations in
  `ordering-file-lifecycle-integration/mutations.jsonl` each fail only that
  control. One makes the backend delete the leftover file. The other keeps the
  fixture prefix after a streaming error.
- 2026-11-21: The measured final run exits zero with 191 passing tests and no
  failure. Its 4386 subjects stayed the same, and no file appeared or disappeared.
  The manifest holds the four inputs that P3-1 named. In a scratch repository,
  one changed and one added file read as changed. The shellcheck entry kept
  only the banner line of the version output. The documentation check reports
  only the two known k23 archive links.
- 2026-11-21: Reconcile the duties. The backend keeps every byte that the
  harness holds. Failed download bytes are explicitly unavailable. The upload
  helper keeps the local, remote and byte identity. k57 keeps the installed
  audits, the collection plan and the stop. k81 keeps every exec read. k76
  keeps adoption, signals and both held-pointer controls. k67, k62 and k54
  keep their duties and holds. No question needs a human decision now.
