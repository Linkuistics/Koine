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

## Decisions (running log)

- **Controls are `open` and `open -R` from the test agent, the K134 witness and Finder's own account.** The
  witness (`.k134w` handler recording exact bytes, from k134) and Finder's AppleScript account give exact
  bytes; TextEdit's, Zed's and Finder's windows are read by title (every name unique, a pre-existing window
  fails the run). No 1,024-byte subject is a control. All seven controls were seen at 1,023 bytes in every run.
- **Long subjects are built by `scripts/vm-long-location-fixtures.py` in the guest with `dir_fd` calls**, so
  no whole-path call addresses a long location; the guest's own descriptor-only account of each subject
  (present/absent/impossible) is kept as `descriptor-check.txt`.
- **A chain of more than ten links has no default handler, and that is the platform's.** The first run's
  31- and 32-link default opens answered `NO_DEFAULT_HANDLER` (first with extensionless links, then with
  `.txt` links). A plain program asking `NSWorkspace.urlForApplication(toOpen:)` gets TextEdit up to ten links
  and nil from eleven. The spec already maps a nil handler for a found target to `NO_DEFAULT_HANDLER`, so
  nothing is changed: the chains are opened with Zed named (Zed's window) and revealed (Finder), a 10-link
  chain opens by default, and the 11-, 31- and 32-link default opens are asserted to be `NO_DEFAULT_HANDLER`
  with nothing opened. Recorded as a finding in `docs/verification/target-locations-vm.md`.
- **First-use opening prompts; the walk does not.** A reveal of a document and of a directory in Desktop,
  Documents and Downloads never prompted, with a standalone probe's prompt seen first as the positive
  control. Every open there (document with Zed named, directory with Finder named, directory by default)
  raised "Koine would like to access files in your … folder". A plain ad-hoc-signed program that is not Koine
  is prompted the same way when it hands such an item to an application, so the prompt is the platform's at
  submission and is not caused by 1.0.1's walk. The brief says a prompt stops the leaf and goes to Antony,
  so the leaf stopped and went to Antony, who answered: run it in TestAnyware, where the dialog can be approved. Run 3 declined every request; run 4 (the `prompt` section alone) allows Koine's request in the clone, and each open then completed with its effect and a second request was prompt-free (16 rows, exit 0). The spec's
  consent rows, the client guide (item 6) and `protected-path-metadata.md` were corrected to say a named
  application does not avoid the prompt; `protected-default-open-k89` got a Context bullet with the finding.
- **Three runs, the third cited.** Run 1 found the extensionless chain-link fixture fault; run 2 the
  ten-link limit and the prompt matrix (with Zed's own prompt masking one cell); run 3 separated Zed's prompt
  (Zed quit before each case) and capped the per-case prompt watch at 150 s. The recipe was never edited under
  a running run.
- **Retired after Antony's answer.** Every Done-when row has its evidence: the controls, the 1,023-byte opens
  and reveals, the refusals and the observation of nothing, the walk's present outcomes by effect (with the
  ten-link default-handler finding), the missing long path, the roots, and first use in the protected folders
  (walk prompt-free, opens prompted by the platform once and allowed in the clone). Whether Koine ever helps with
  that consent stays `protected-default-open-k89`'s.
