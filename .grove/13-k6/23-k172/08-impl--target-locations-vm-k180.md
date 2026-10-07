# target-locations-vm-k180

## Goal

Accept target locations at V in signed isolated macOS: long documents and
directories open, are revealed, and are refused exactly at the limit, all
observed independently of Koine's answers, and first-use resolution is prompt-free.

## Context

- `docs/specs/workspace-launch-and-open.md#subjects-and-versions` (V) and the two
  long-location acceptance rows.
- `docs/verification/open-path-vm.md`, `reveal-path-vm.md` and
  `docs/verification/long-action-native-boundary.md` (observer controls).
- `scripts/vm-open-path-fixtures.sh`, `scripts/vm-reveal-path-fixtures.sh`,
  `scripts/vm-reveal-observe.applescript` (an existing short observer, not a
  long-path control).
- The 1.0.1 signed bundle from `action-repair-release-k178`. A V recipe takes
  hours: run it detached, as `docs/verification/open-path-vm.md` explains.

## Done when

- Observers are positively controlled before any Koine observation: the same
  long subject opened, and revealed, by an independent non-Koine route is seen by
  each delivery and Finder-selection observer, with exact bytes recorded.
- A document whose path is 1,023 bytes opens in its default handler and in Zed and
  is revealed. 1,024-byte and about 1,500-byte files and directories show nothing
  delivered or selected, and `failed` with guidance, not a dependency.
- A missing long path is `PATH_NOT_FOUND`; the root and a link-to-root reveals keep
  their accepted forms with and without a trailing slash.
- First-use resolution in Desktop, Documents and Downloads is prompt-free in the
  signed app. **If it prompts, the leaf stops and goes to Antony.**
- Evidence is a verification document under `docs/verification/`, linked from the
  spec rows, and reusable steps are in `Taskfile.yml`.

## Notes

- An observer limit leaves the observation pending; it can neither pass nor fail Koine.
