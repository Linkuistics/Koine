# Finite Settings caller: audits and the declared environment

This report belongs to `settings-ordering-audits-k170`. That task adds the
per-item audits to `scripts/settings-ordering-sequence.py`. It also adds the
comparison with the declared environment, which is gap G5 of the
[prefix report](ORDERING-PREFIX-RESULTS.md).

The evidence is source and controls only. No VM ran, and no clone, signed
subject or runtime slot exists. The actual digests of the subject and the golden
image do not exist yet, because k54 owns the freeze. The work establishes no
native behaviour, no native cause and no scenario readiness. It closes no
ancestor.

## The changed flow

One slot now takes these steps:

1. `run` checks the readiness receipt against its ledger digest.
2. `run` audits the host inputs. Before A01, it also audits the golden image.
3. `run` admits the slot and starts its Task entry.
4. After the entry, `run` freezes the classification.
5. `run` reads the installed bundle, the defaults and the Koine process.
6. `run` stops the exact clone and reads the independent inventory.
7. `run` audits the host inputs again and compares the saved originals.
8. `run` exits and leaves the slot unsettled.
9. The k54 operator audits the screenshots.
10. `settle-run` takes that result, compares the evidence with its manifest and settles the slot.

After the last slot, or after a stop, `close` rechecks the golden image.

An audit before a slot that does not pass writes a `held` ledger entry. The slot
stays unconsumed, and every later admission is refused. A restored input does
not clear the entry.

## New verbs

| Verb | Effect |
|---|---|
| `inventory ROOT NAME` | Prints one tree in the exact form of the readiness receipt |
| `settle-run DIR SLOT AUDIT` | Settles a collected run with one screenshot result. It can change no other phase, except that a manifest mismatch fails `audit` |
| `close DIR` | Records the closing golden audit, once |

`settle` now refuses a slot that has collected phases, so hand-written phases
cannot replace audited ones. It stays available for a run that died before it
wrote those phases.

## The readiness receipt

`run` needs a frozen declaration in the readiness receipt of the set. A receipt
without one refuses before admission and consumes no slot.

```json
{
  "schema": 1,
  "set": "focused",
  "environment": {
    "product_version": "27.0.1",
    "product_version_extra": null,
    "build_version": "26A434",
    "arch": "arm64",
    "assessments": "enabled"
  },
  "process_arguments": "/Applications/Koine.app/Contents/MacOS/Koine",
  "inputs": ["one inventory tree for each input, with one named bundle"],
  "golden": "one inventory tree of the stopped image"
}
```

The ordinary receipt must equal the focused receipt in every field except `set`.
A difference holds the sequence at A01.

## Separate results

Each audit keeps its own entry in `containment/audits.json`. Three settlement
phases take them.

| Phase | Audit | A pass needs |
|---|---|---|
| `environment` | System | The `system` receipt equals the declared image |
| `environment` | Gatekeeper | The `gatekeeper` receipt equals the declared state |
| `environment` | Process | At least one Koine process row, and each row has the declared arguments |
| `environment` | Defaults | A clean read after the slot shows the diagnostics disabled |
| `endpoint` | Installed before | The `installed-before` receipt equals the frozen bundle, item by item |
| `endpoint` | Installed after | The caller's read equals the frozen bundle, item by item |
| `audit` | Host before and after | Each input tree equals its frozen items |
| `audit` | Originals | Each saved artifact equals the digest or response of its original |

A clean difference is `failed`. A failed read is `unavailable`, and it is never
a negative fact. A read that could not run is `not-run`. No audit compares counts
alone. Each one compares paths and identities, so a renamed file with an equal
count fails.

The originals audit covers saved screenshots, downloads and guest streams. A
partial attempt has no completed original, so the audit names it and the
manifest keeps its bytes.

## Decisions for review

- The `endpoint` phase is the installed audit at both endpoints. The protocol
  and [ORDERING-REVIEW](ORDERING-REVIEW.md) name "original/endpoint/golden
  audits", and no other owner of that phase exists.
- Each installed endpoint is compared with the frozen bundle. A comparison of the
  two endpoints alone would accept a wrong bundle that stayed the same.
- The focused prefix has no process read while Koine runs. The caller therefore
  takes that read before its stop. An ordinary slot quits Koine first, so its
  arguments come from the `login-process` receipt.
- The defaults audit uses the existing `diagnostics_disabled` field. The protocol
  admits `KoineSettingsMenuProbe` as absent or false, and the task text says
  "clean absence". The protocol is the wider contract, so a false probe passes.
- `run` no longer settles a collected slot, because a screenshot audit needs a
  judgement that this tool cannot make.
- Five qualified slots report `awaiting-golden-audit` until `close` passes.

## Controls and provenance

`task check:vm-settings-audits` runs 65 controls without a VM. A fake `task`
writes real receipts through the real facades, and a synthetic CLI answers each
checked guest read in its exact grammar. The existing containment and sequence
controls now expect the new flow.

The records are in [`ordering-audits-evidence/`](ordering-audits-evidence/):

- `red.txt` runs the first 60 controls before the audit verbs exist. All 60 fail,
  for that broad reason.
- `defects-red.txt` runs them on the first implementation. Two fail, because an
  unreadable item was reported as a missing item.
- `mutations.jsonl` disables 38 guards, one at a time, in isolated copies. Each
  named control passes on the unmutated copy and fails on the mutated copy.
  `mutate.py` is the instrument.
- `final-verification.txt` runs the affected checks. Its `.subjects` files record
  the digests before and after the run.

Five controls came after the first implementation. A read of that source added
four. They cover an unreadable directory, a malformed read record, a forged
manual settlement and a one-file bundle. The first mutation run added the fifth,
because the `process-read-failed` mutation survived. The old control had no clean
process row beside the failed read. The failing record of each is its mutation.

## Limits

- The controls use a synthetic guest. E01 still qualifies each real read.
- The exact process arguments come from historical guest rows. E01 is the first
  check of them under this comparison. The login read matches the whole bundle
  path, so a helper process with other arguments would fail the environment.
- No control ran against a real Tart image. If Tart adds or changes a file in the
  golden directory during a clone, the audit before A01 holds the sequence. k54
  must check this before it relies on the golden inventory.
- The scenario writes its transcript and installed text files to
  `.build/vm-verify`, outside the slot's output directory. The originals audit
  and the manifest do not cover those copies. The receipts in the evidence root
  hold the originals.
- The manifest recheck excludes the run's own `containment` records, because
  those files are still being written. A same-user process can still change them.
- The `admit` and `settle` verbs can still consume and settle a slot without
  these audits. k54 must use `run` and `settle-run`.
- The audits read each file once. A change between the audit and the next step
  stays possible.

## Handoff

The next task is the independent whole-harness and caller review, which this
task cuts. k171 reconciles every original duty after that review. k54 still owns
the freeze, the readiness receipts, the screenshot audit and the runtime.
