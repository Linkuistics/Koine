# TestAnyware 3.0.0 amendment results

This record belongs to `settings-testanyware-3-amendment-k177`. It moves the
ordering harness from TestAnyware 2.7.0 to 3.0.0.

No guest, clone or golden build ran for this amendment. The results below come
from the tagged source, the installed binary and synthetic controls. No real
3.0.0 agent reply qualified the new record check. The first real reply arrives
in k54.

## Subject

| Fact | Value |
|---|---|
| Tag | `v3.0.0`, commit `097ed8f7337ed9142c1aa8cda926a513c03108a4` |
| Earlier tag | `v2.7.0`, commit `65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03` |
| Installed tool | `/opt/homebrew/Cellar/testanyware/3.0.0/bin/testanyware` |
| Tool SHA-256 | `4587ab560fd77877cd9a21b683ab004dc365e1f603084e1c5dc6e5fdb42eb47e` |
| Host | macOS 27.2.1 (26B131), Tart 2.42.0 |

The host matches the release requirement. k54 still records these values at the
freeze.

## Citation recheck

Each live citation in `scripts/` and `Tests/scripts/` now names `v3.0.0`.
"Identical" means that the Git blob is the same at both tags.

| Cited file | Change | What the harness takes | Result |
|---|---|---|---|
| `agents/macos/.../ProcessRunner.swift` | Changed | `/bin/bash -c`, trimmed legacy streams | Holds for the macOS projection. Repaired for typed records |
| `cli-rs/.../testanyware-agent-client/src/lib.rs` | Changed | Upload size, download temporary file | Upload holds. Download comment and anchor repaired |
| `cli-rs/.../commands/agent.rs` | Identical | Snapshot and window payloads, `--open-menu` input | Holds |
| `cli-rs/.../commands/file.rs` | Changed | Exec envelope, transfer payloads | Legacy fields hold. Repaired for typed records |
| `cli-rs/.../commands/input.rs` | Identical | Input payloads | Payloads hold. The unconfirmed-read warning is repaired |
| `cli-rs/.../commands/screen.rs` | Changed | Size, capture and OCR payloads | Payloads hold. Crop change has a disposition below |
| `cli-rs/.../commands/vm.rs` | Changed | Start, stop and list payloads | Payloads hold. Only golden plans and the keeper changed here |
| `cli-rs/.../testanyware-cli/src/main.rs` | Changed | Flags and positional IDs | Holds. New `file cancel` stays outside the admitted commands |
| `cli-rs/.../testanyware-cli/src/output.rs` | Changed | Envelope and exit codes | Holds. `EXEC_ID_IN_USE` adds exit 5, which stays unavailable |
| `cli-rs/.../testanyware-cli/src/resolve.rs` | Identical | Explicit `--vm` precedence | Holds |
| `cli-rs/.../testanyware-ocr-client/src/detection.rs` | Identical | OCR detection fields | Holds |
| `cli-rs/.../testanyware-protocol/src/element_info.rs` | Identical | Element fields | Holds |
| `cli-rs/.../testanyware-protocol/src/window_info.rs` | Identical | Window fields | Holds |
| `cli-rs/.../testanyware-rfb/src/input.rs` | Identical | Button mask and anchored lines | Holds |
| `cli-rs/.../testanyware-vm/src/capture.rs` | Identical | 8-bit noninterlaced PNG | Holds |
| `cli-rs/.../testanyware-vm/src/listing.rs` | Identical | Inventory rows | Holds |
| `cli-rs/.../testanyware-vm/src/tart.rs` | Changed | `tart stop` has no bound of its own | Holds. Only list and pull helpers were added |

## Repairs

Each repair makes an attempt unavailable. None adds a read, a wait, a retry or a
wider tolerance.

- **Exec record.** A clean exec now needs a typed macOS agent record, the outcome
  `exited` with code 0, and two complete streams of valid UTF-8. The upstream
  specification forbids counting a legacy `unknown` outcome as success. An
  incomplete stream is only a prefix. The macOS projection turns a stream that is
  not UTF-8 into empty text, and a checked read could take that text as a negative.
- **Withdrawn CLI results.** Five stderr diagnostics now make a status 0 attempt
  unavailable. The table below names them. The installed binary contains each
  exact string.
- **Download comment.** The client now removes its temporary file on a failure,
  SIGINT or SIGTERM. Only SIGKILL leaves it.

| Command | Diagnostic prefix | Why the result is withdrawn |
|---|---|---|
| `vm start` | `warning: VNC size wait:` | No session read the set size in 30 seconds |
| `vm start` | `VNC size wait skipped:` | The start does not know the size, so it did not wait |
| `screen find-text` | `testanyware: the Vision worker failed` | OCR repeated a failed request |
| `input` | `warning: the guest gave no sign` | The guest gave no sign that it read the input |
| `input` | `warning: the guest connection ended before` | The connection ended before that sign |

The two `input` diagnostics also exist at v2.7.0. The recheck of `input.rs` found
this earlier gap, so 3.0.0 did not introduce it.

## Release behaviour dispositions

| Release behaviour | Disposition |
|---|---|
| Host needs the latest macOS 27 and Tart | Met now. k54 pins both at the freeze |
| VNC keeper removed | Compatible. The harness takes no keepalive captures and does not rely on the keeper |
| A golden holds the latest macOS 27 release | Open for k54. The plan still names guest macOS 27.0.1 |
| `vm start` ends with the size wait | A completed wait stays clean. An expired or skipped wait is unavailable |
| OCR replaces a failed worker and resends once | Conflicts with one-attempt evidence if accepted. The attempt is unavailable |
| ZRLE decodes a stale-size rectangle | Compatible. The capture check still reads the artifact and its size |
| `screen capture` crops by the captured frame | Compatible. The envelope size must still equal the PNG size |
| EasyOCR first read has a 60 s deadline | Not used on this path. A macOS host selects Vision unless the fallback variable is set |
| `agent snapshot` can return a front app's menu bar | Compatible. No scenario selector can match that pseudo-window, and a control proves it |

The OCR repair keeps the one-attempt rule without an owner decision. A retried
attempt never counts, so a later success in that CLI process cannot repair the
failed request.

The menu bar pseudo-window always reports `focused: false`. The harness takes
focus from the window list and its independent observer, not from this window.

CLI interruption now sends one guest cancellation before the same signal death.
The adapter still kills its child about 0.25 seconds after SIGINT, so that
cancellation may not reach the guest. The harness claims no cancellation. An
interrupted attempt stays interrupted, and only the exact stop may follow.

## Controls and ledger

These controls were added:

- `a legacy, partial or undecodable exec record cannot qualify a clean exit`
- `a clean CLI status with a withdrawing diagnostic stays unavailable`
- `a diagnostic stays clean when it withdraws nothing for that command`
- `a menu bar of the front regular app supplies no scenario element`

The source changes in `validate_response` and `run_locked` only add unavailable
outcomes. The recheck read the 58 ledger rows that cite `scripts/vm-guest-exec.py`.
Each disposition stands. Rows D031, D066 and D090 now cite the diagnostic control.
Rows D056, D088 and D130 now cite the record control. The note of D307 now names
the 3.0.0 poll, because `find.rs` keeps the same substring match.

## Limits

- The golden image must hold an agent from TestAnyware 2.9.0 or later, or every
  exec is unavailable. The upstream menu bar repair needs a golden that 3.0.0
  built.
- A stderr prefix is exact to the pinned binary. A changed binary needs this
  recheck again.
- These results establish no Koine behaviour, no reliability and no native cause.
