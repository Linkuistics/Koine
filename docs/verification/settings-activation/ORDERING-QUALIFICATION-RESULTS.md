# Settings ordering qualification results

This record belongs to `settings-ordering-qualification-k54`. That task froze one
signed 0.4.0 subject and ran the declared ordering sequence of the
[evaluation plan](ORDERING-EVALUATION-PLAN.md).

**The outcome is no acceptance, and the repair stays unresolved.** E01 stopped at
the positive setup before the first Settings selection. One required read of the
front process was unavailable. No Koine failure and no test-driver crash
occurred. E02, A01, A02 and A03 did not run.

The result says nothing about the activation-before-window ordering. No Settings
selection ran, so the run gives no evidence for or against the repair. The next
decision belongs to `settings-ordering-next-decision-k183`.

## Owner decisions before the freeze

Antony made these decisions before the freeze. The task log of k54 holds each one
with its date.

- Pin TestAnyware 3.0.0.
- Accept the 300 GB storage allowance. This acceptance gives no byte bound.
- Accept guest macOS 27.2.1 build 26B131. A result on this release covers this
  release only.
- Accept the 19:03 `testanyware-golden-macos-27` image as stopped and final.
- Accept the check before dispatch and after each attempt as the endpoint binding
  of finding P3-3. The [provenance record](ORDERING-PROVENANCE-RESULTS.md#limits)
  keeps the two gaps of that binding.

## The freeze

The freeze finished at 10:27:24 UTC on 2026-11-24, before the first clone request.

| Item | Value |
|---|---|
| Source | Commit `37d09ab2`. The working copy changed only the k54 task file and the provenance record |
| Build | Swift 6.4.2 and Xcode 27.2 (27B52), release configuration |
| Signature | Developer ID, Team ID TA43A4RUP3, hardened runtime, not notarised |
| Executable UUID | `3D5E7700-B5F2-3A99-AEDA-F2601CB5CEBD` |
| Framework UUID | `1B6A8D3F-15BA-340A-88F0-09BC1154AB85` |
| Provider UUIDs | Desktop `CF06F06A-7A73-3F32-9F5C-B34EA6E59870`, Workspace `76B0A371-BB26-34C2-BB31-AFCDD7DF298E` |
| Host | macOS 27.2.1 (26B131), Tart 2.42.0 |
| Tools | TestAnyware 3.0.0 CLI and app, jq 1.8.2, Task 3.54.0, Python 3.15.2 |
| Focused receipt | SHA-256 `7b60058cd4b7af000baecfc5b5ce56d1fdf9a2a6b261750c02c9b2b31f53f3e8` |

`codesign --verify --deep --strict` passed, and the bundle satisfies its
designated requirement. The host's `spctl` rejects the bundle as an unnotarised
Developer ID build. The scenario installs it without quarantine, so the guest
does not assess it.

The receipt holds 20 input trees and the golden tree. The trees are the bundle,
the two executables, the TestAnyware app and its configuration, the Tart keg,
Task and Python. They also hold the application source, the providers, the
package manifest and lock, the scripts, the script tests and the Taskfile. The
protocol, its review, the spec and the keepalive ADR complete the list.

The golden digests are these:

| File | Bytes | SHA-256 |
|---|---|---|
| `config.json` | 587 | `e5e314dd027571ffeaa87d50b083b14ad557a6f9b6271092b4a2b5a41a37ec5b` |
| `disk.img` | 50,000,000,000 | `f30cfdbdbe788aa36d7e78173773840c961ee018dc4c42bacf232b19fca6fffe` |
| `nvram.bin` | 33,579,164 | `6c64366a6ace2cdff210643dcd74e9969955abe857d5c5e269ddcdcf7fe54078` |

### Checks before the freeze

- The closed ledger check passed, with 393 duties and 0 findings.
- One Tart clone of the golden, with no boot, left the golden tree unchanged item
  by item. A changed digest in a copy of the comparison showed that the
  comparison can fail.
- The volume of the sequence and of `~/.tart/vms` had 1,339,403,300 KiB available.
  The floor is 292,968,750 KiB.
- Time Machine had no destination. Google Drive backs up no local folder, and
  Dropbox syncs only its own folder. Carbon Copy Cloner has one task without
  automation.

The receipt declared Gatekeeper `enabled` and no `ProductVersionExtra`. A
read-only mount of the golden supported both values, and the tagged 3.0.0 golden
creation leaves Gatekeeper on. The file read of the policy state was not a proven
instrument. E01's guest reads then reported exactly the declared values.

Each slot ran through one wrapper. It puts Task 3.54.0 first on `PATH` and sets
`KOINE_APP_BUNDLE` to the subject. It also turns off Python byte-code writes,
which would change the `scripts` tree between its audits.

## E01

E01 ran from 10:28:04 to 10:28:56 UTC in clone `koine-k49-ordering-e01`. It made
82 attempts.

These steps completed:

1. The clone started, and its provenance record matched the start reply.
2. The guest reported macOS 27.2.1, 26B131, arm64 and Gatekeeper enabled.
3. The checked upload and extraction installed the subject. The installed
   inventory matched the frozen bundle.
4. First launch showed one `Koine Settings` window at the default frame, no Dock
   icon and one menu bar item. <!-- tc: depart synonym-rotation because an application launch differs from a VM or clone start -->
5. TextEdit launched with one `Untitled` window, and the scenario moved it. Two
   clean reads named TextEdit, PID 807, as the front process.
6. The scenario closed the Settings window. The count read showed zero Koine
   windows, and the identity and window reads of the setup were clean.

Attempt 000081 then read the front process through System Events. This read is
one part of the positive setup before the first selection. It came about 750 ms
after the close. The guest returned this text with status 1:

```text
40:96: execution error: Can’t get {"loginwindow", 167} whose frontmost = true. (-1728)
```

The strict grammar accepts -1728 only as a missing element, so the read was
unavailable. The classification froze as `unavailable` at
`first-selection-setup-front`. The failure capture 000082 followed, and the
scenario stopped with status 125.

### Phases

| Phase | Result |
|---|---|
| Scenario status | 125 |
| Task status | 201 |
| Collection | Passed, with no refusal |
| Subject | Passed: system, Gatekeeper, installed bundle, process arguments and provenance |
| Environment | Passed: system, Gatekeeper, process and defaults |
| Endpoint | Passed before and after |
| Audit | Passed for all 20 trees before and after, and for the originals |
| Stop and inventory | Passed. The independent inventory shows the clone stopped |
| Screenshots | Passed |

The slot settled `unresolved`, and its cleanup is `confirmed`.

### Screenshot audit

The audit followed the rule that the k54 log set before the slot. Both retained
images are readable.

- 000058, the first-launch image, agrees with its structured result. A Finder
  `Utilities` window is in front of the Settings window, and the menu bar names
  Finder. The first-launch assertion has no front predicate.
- 000082, the failure capture, shows TextEdit in front with its `Untitled`
  document. It shows no Koine window and no open menu.

The failure capture suggests that the missing front process was a short gap. It
does not change the failed read, because no later observation repairs a failed
transport.

## The three outcome classes

| Class | Result |
|---|---|
| Koine failure | None observed |
| Test-driver failure | None. Tart did not crash, and every TestAnyware transport completed |
| Required evidence unavailable | The front-process read of the first positive setup |

These assertions did not run in E01: the first selection, reopens 1 to 3, every
title audit of a return and the TextEdit quit. Every assertion of E02, A01, A02
and A03 also did not run.

## After the stop

`close` rechecked the golden image, and every item matched. The report gives
the outcome `no-acceptance`, stopped at E01. A deliberate `run E02` was refused
before admission with "the sequence stopped at E01". It consumed nothing and
wrote one refusal record.

The protocol gives this evaluation no replacement. A new run needs a new explicit
scope decision, a new declared sequence and a new freeze.

## Classification of the duties that k54 owned

The [duty ledger](ordering-reconciliation-evidence/duties.json) assigned 37 rows
to k54. Each row now names `settings-ordering-next-decision-k183` as its owner,
because each still binds any future runtime.

| Rows | Duty | Result in k54 |
|---|---|---|
| D010, D034, D039, D044, D069, D076, D105, D124, D147, D187, D201, D206, D229, D269, D300, D319 | Every review and integration precedes runtime | Met. Every k36 review and integration leaf was complete before E01 |
| D023, D063, D101, D134, D180, D224 | Demonstrated unavailable completion holds before E01, with no qualifying guest | Met. No unavailability was known before E01. E01 then showed one, and the sequence stopped with no replacement guest |
| D037, D073, D148, D188 | Historical evidence, closed caps and held causal slots stay unchanged | Met. The run changed no historical record, and `events/Koine.app` stays. The causal slots stay unstarted |
| D038 | No native acceptance, cause, ownership or ancestor closure | Met. This record claims none |
| D168, D176, D218, D251, D286, D324, D336, D352, D384, D393 | Every original duty survives | Kept. The runtime duties stay unmet, because E01 stopped before the first selection |

## Private evidence

The raw evidence is in `.build/settings-activation/ordering-sequence` of this
workspace. The freeze records are in `.build/settings-activation/ordering-freeze`.
Both stay private, and neither is committed. The raw attempts can hold the guest
password.

The E01 transcript and installed inventory are copied to `transcripts/E01/`. The
originals stay in `.build/vm-verify`.

## Limits

- No Settings selection ran. The run supports no claim about the repair, its
  reliability, an API violation or the preservation of the symptom.
- The front-process gap has no native explanation. It may be a property of the
  guest, of System Events or of the closed agent window.
- The golden shows a Finder window at login. No structured check covers it, so
  this record does not classify it.
- The spec changed after `close`, as part of this reconciliation. The sequence
  was already closed, so no audit compared those bytes.
