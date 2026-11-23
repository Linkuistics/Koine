# Settings evidence storage plan

This plan belongs to `settings-ordering-evidence-storage-k176`. It closes duties
D215, D216, D270, D275 and D372 of the
[duty ledger](ordering-reconciliation-evidence/duties.json).

**No proven byte bound exists for the evidence of a slot.** The transports cap
neither guest output nor image size, and a guest is necessary to measure real
responses. This plan therefore gives a planning allowance, and it requires
300 GB of free space. The owner must accept or replace this allowance before k54
freezes a subject.

No VM ran for this plan. The sizes come from simulated runs, retained images and
the golden image. Every E and A assertion stays NOT RUN.

## Location and retained classes

The sequence directory is `.build/settings-activation/ordering-sequence`, in the
workspace that runs k54. Git and jj ignore this path, and it does not exist yet.
The [location record](ordering-storage-evidence/location.json) holds the guard
result for this path.

The directory keeps these classes of evidence:

| Class | Location | Contents |
|---|---|---|
| Declaration | `sequence.json` | The five slots and their identities |
| Ledger | `ledger/`, `refusals.jsonl` | Each sequence event and each refused step |
| Raw attempts | `<namespace>/<slot>/evidence/` | Requests, responses, partials, screenshots and refusals |
| Slot records | `<namespace>/<slot>/containment/` | Process group, actions, audits, manifest, phases and result |
| Scenario status | `<namespace>/<slot>/scenario.exit` | The exit status of the scenario |
| Transcripts | `transcripts/<slot>/` | Copies of the `.build/vm-verify` files of each slot |

The raw attempts can hold `KOINE_VM_PASSWORD` in argv, predicates and responses.
Screenshots can show secret screen content. Keep the required raw bytes. Do not
redact them, and do not weaken text validation.

The scenario writes its transcript and installed text files to `.build/vm-verify`,
outside the slot output. That directory has mode 755. After each slot, k54 copies
the files of that slot to `transcripts/<slot>/`, and it leaves the originals. A
simulated consent run keeps the password out of the transcript. That control does
not cover every failure path, so treat each transcript as private.

## Privacy rules

- Do not commit or publish the sequence directory, a transcript or any part of them.
- Do not move the directory to a synchronised or shared folder.
- Do not delete the workspace that holds the directory until the owner decides how
  to keep the evidence.

`declare` refuses a directory that could enter version control. It checks each
enclosing Git or jj working tree, and it resolves a symlinked parent first. It
refuses each of these cases and creates nothing:

- The path is not ignored, or an ignore rule includes it again.
- Git or jj tracks a file under the path.
- Git or jj cannot read the tree, or a jj workspace has no Git view.

The guard cannot detect a backup or a file synchronisation tool. On 2026-11-23,
Time Machine had no destination, and it did not exclude `.build`. Before E01, k54
checks that no such tool copies the directory.

## Size of each slot

The allowance is not a cap, and no code enforces it.

| Class | Observed count or size | Allowance for one slot |
|---|---|---|
| Attempts | 217 focused and 740 ordinary, the most in 17 simulated cases | 10,000 attempts at 256 KiB each, 2.44 GiB |
| Screenshots | 13 focused and 23 ordinary, the largest of 207 retained images is 417,648 bytes | 32 images at 9 MB each, 0.27 GiB |
| Slot records | A fixed set of small JSON files | 0.04 GiB |
| Rounded evidence | | 3 GiB |
| Transcripts | 17,069,542 bytes for all retained runs in this workspace | 0.2 GiB |

The image allowance exceeds the raw size of a 1920×1080 RGBA frame, which is
8,294,400 bytes. The [attempt counts](ordering-storage-evidence/volume.json) come
from the simulated guest, which writes no real response bytes.

## Free space for the five slots

| Item | Size |
|---|---|
| Evidence and transcripts, 3.2 GiB for each of five slots | 17.2 GB |
| Five clones at their full logical size of 50,033,579,751 bytes | 250.2 GB |
| Total | 267.4 GB |
| **Required free space** | **300 GB** |

The clone figure assumes that all five clones stay on disk and that no clone grows
past its logical size. On 2026-11-23, the volume had 1.48 TB available.

Before each set's readiness, k54 runs `df -k` on the parent of the sequence
directory and on `~/.tart/vms`. Each volume must report at least 292,968,750 KiB
available. If a volume reports less, hold before the slot. This check is a reading
at one time, and it reserves no space.

## When space runs out

A failed write stays failed evidence. The harness deletes no original or partial
to recover space. Its two writers each delete one name, the temporary name of a
file that is already complete. The
[measurement](ordering-storage-evidence/enospc.json) ran the real caller on small
real volumes in ten cases with a fake Task. It contacted no guest.

| Fill level | Cases | Result |
|---|---|---|
| Enough space | 3 | E01 qualified. In one case, E02 then ran out of space and stayed unsettled |
| A write failed after admission | 6 | E01 stayed unsettled, and E02 did not start |
| No space at admission | 1 | The caller refused E01, and no slot started |

In every case, no file that existed after E01 later disappeared. The unrelated
file on the volume stayed intact.

**Warning: A zero exit status from `run` does not show that the caller kept its records.**
In six cases, `run` exited 0 after it lost its own records. In those cases and in
the E02 case above, the caller sent no `vm stop`. Four cases left a clone running.

If `phases.json` is missing or `settle-run` fails, do these steps:

1. Stop every later slot.
2. Contain the recorded process group, if `process.json` exists.
3. Stop the exact clone once, and check the stop with an independent inventory.
4. Record these actions separately.
5. Ask the owner to free space outside the sequence directory.
6. Run `settle DIR SLOT`.

In the six measured recoveries, `settle` recorded the slot and its cleanup as
`unresolved`. The sequence reported `no-acceptance`, and E02 stayed NOT RUN. The
measurement did not free space from a real host volume or stop a real clone.

## Controls and records

`task check:vm-settings-sequence` holds the declaration controls. The
[mutation record](ordering-storage-evidence/guard-mutations.json) changes each of
11 guard decisions in a private copy, and each change fails a control.

The records are in [`ordering-storage-evidence/`](ordering-storage-evidence/):

- `volume.json` and `measure-volume.py` hold the simulated attempt counts.
- `guard-mutations.json` and `guard-mutations.py` hold the guard mutations.
- `enospc.json` and `enospc-measure.py` hold the full-volume runs.
- `location.json` holds the guard result for the planned directory.
- `subjects.sha256` holds the digests of the measured files.
- `final-verification.txt` and its two receipts hold the harness checks.
  `final-check.py` is their instrument.

## Decision for the owner

Before k54 freezes a subject, the owner chooses one of these options:

- **Accept the allowance (recommended).** k54 requires 300 GB of free space and
  keeps the limits above. A larger real output then fails closed, as measured.
- **Request a finite resource design.** This adds a new leaf before k54, and the
  freeze waits for it.

The recommendation rests on the 1.48 TB available and the measured failure
behaviour. Accepting it does not establish a byte bound for a real guest.
