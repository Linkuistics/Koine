# target-locations-vm-k180

## Goal

Accept target locations at V in signed isolated macOS: a document or directory
whose path is 1,023 bytes opens and is revealed, one of 1,024 bytes or more is
refused and shows nothing delivered or selected, every walk outcome that only an
effect can show is observed, and first-use resolution is prompt-free. The
observers are controlled at the admitted length and never at a length the v1
decision deferred.

## Context

- `docs/specs/workspace-launch-and-open.md#subjects-and-versions` (V) and the two
  long-location acceptance rows.
- `docs/verification/open-path-vm.md`, `reveal-path-vm.md` and
  `docs/verification/long-action-native-boundary.md` (observer controls, as the
  v1 reading there states them).
- `scripts/vm-open-path-fixtures.sh`, `scripts/vm-reveal-path-fixtures.sh`,
  `scripts/vm-reveal-observe.applescript` (an existing short observer, not a
  long-path control).
- The 1.0.1 signed bundle from `action-repair-release-k178`. A V recipe takes
  hours: run it detached, as `docs/verification/open-path-vm.md` explains.
- `long-locations-k172` brief, "What N can see": the present walk outcomes the
  host cannot show without an effect are assigned here.

## Done when

- **Observers are positively controlled before any Koine observation, at the
  admitted length.** A 1,023-byte document and directory, built component by
  component, are opened and revealed by an independent non-Koine route, and each
  delivery and Finder-selection observer sees them, with exact bytes recorded.
  The 1,024-byte and about 1,500-byte subjects are never a control: no
  over-limit delivery by any route is a prerequisite, because the v1 decision
  defers it and k134 found submission failing there. An observer that cannot see
  the 1,023-byte control leaves every observation pending; it passes and fails
  nothing.
- A document whose path is 1,023 bytes opens in its default handler and in Zed and
  is revealed. For each 1,024-byte and about 1,500-byte file and directory, the
  controlled observers, watching for the window the 1,023-byte control needed,
  show nothing delivered or selected, and Koine answers `failed` with guidance
  naming the hand-off stage, the spelling and its byte count, not a dependency.
- **Present walk outcomes that no refusal can show on the host**, which
  `reveal-locations-k174` and `open-path-locations-k175` assign here: a 31- and a
  32-link chain that resolve, a final directory without search permission (mode
  0600), one symlink inode with entries in two directories whose path is finite
  where the guest admits it, and the extant multibyte and combining-character
  names beside the ASCII impossible component. Each target is within the limit and
  is opened or revealed in the guest, with the effect seen by the controlled
  observers. Their roughly 1,500-byte variants are seen through the refusal that
  names the resolved spelling, which `reveal-locations-k174` already checks.
- A missing long path is `PATH_NOT_FOUND`; the root and a link-to-root reveals keep
  their accepted forms with and without a trailing slash.
- First-use resolution in Desktop, Documents and Downloads is prompt-free in the
  signed app. **If it prompts, the leaf stops and goes to Antony.**
- Evidence is a verification document under `docs/verification/`, linked from the
  spec rows, and reusable steps are in `Taskfile.yml`.

## Notes

- An observer limit leaves the observation pending; it can neither pass nor fail Koine.
- No subject of 1,024 bytes or more is claimed to open, be revealed or be
  delivered by any route: the spec's "What v1 does not do" defers that.
