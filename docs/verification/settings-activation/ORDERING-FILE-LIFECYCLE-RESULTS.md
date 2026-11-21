# File transfer and VM lifecycle evidence

k89 supplies source-only helpers for five transports of the Settings harness.
They are the upload, the download, the VM start, the exact VM stop and the VM
inventory. Each helper records one attempt in the shared writer domain of the
[shared adapter](ORDERING-NONEXEC-RESULTS.md). The domain has one lock, one
latch and one ordinal sequence.

No ordinary caller or scenario root changes. No VM, signed candidate, frozen
subject, native availability or repair acceptance follows. An independent
review and every earned integration come before k81 or k76 consumes this work.
The [ordering protocol](ORDERING-EVALUATION-PLAN.md) and the reviewed
[physical](ORDERING-PHYSICAL-RESULTS.md), [window](ORDERING-WINDOW-RESULTS.md),
[input](ORDERING-INPUT-RESULTS.md), [snapshot](ORDERING-SNAPSHOT-RESULTS.md),
[click](ORDERING-CLICK-RESULTS.md) and [capture](ORDERING-CAPTURE-RESULTS.md)
contracts stay binding.

## Interface

Source [the file facade](../../../scripts/vm-file-evidence-lib.sh) and
[the lifecycle facade](../../../scripts/vm-lifecycle-evidence-lib.sh). Sourcing
only defines functions. Each call needs a root that `init_guest_evidence`
initialised. An empty, missing or uninitialised root returns 125 without
dispatch.

| Function | Class | Operation |
|---|---|---|
| `upload_guest_file ROOT OPERATION LOCAL /REMOTE` | one-shot | One upload. The backend digests LOCAL under the lock before and after the dispatch. |
| `download_guest_file ROOT CLASS OPERATION /REMOTE [UPLOAD]` | read-poll or evidence | One download to a backend-owned path. A named upload ordinal must match the guest bytes. |
| `start_guest_vm ROOT OPERATION BASE [WIDTHxHEIGHT[@2x]]` | one-shot | One macOS clone start of an explicit golden BASE, with the original bare `--wait`. |
| `stop_guest_vm ROOT OPERATION` | evidence | One stop of the pinned clone. It stays callable after a latch. |
| `inventory_guest_vms ROOT CLASS OPERATION running\|absent` | read-poll or evidence | One complete clone list. It decides whether the pinned clone runs once or is absent. |

The generic route `cli_guest_evidence ... -- file upload` refuses in every
class, and so does `file download`. Both refusals occur before dispatch, and
each one latches the root. Only the checked backend constructs a transfer
command. This rule matches the earlier refusal of generic `screen capture`. It
is a contract between cooperating helpers. It is not a sandbox against arbitrary
host code.

## Upload identity

The tagged
[upload handler](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/file.rs)
prints `local`, `remote` and `bytes`. The tagged
[agent client](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-agent-client/src/lib.rs)
stats the local file, streams it and reports that size as `bytes`. Thus a clean
receipt proves neither the bytes that the client sent nor the bytes that the
guest wrote.

The backend therefore makes LOCAL absolute and digests it before the dispatch.
The file must be a regular file and not a symbolic link. The backend opens it
without following links. The device, inode, size and both times must stay the
same while the backend reads it. The backend writes `local-before.json` before
the CLI starts.

The payload predicate needs the exact key set, the exact local and remote paths
and a `bytes` value equal to the digested size. After a clean CLI completion,
the backend digests LOCAL again and writes `local-after.json`. Any difference
is unavailable, with the reason "upload input changed during the transfer". Only
an identical pair publishes `transfer.json`, with the remote path, the size and
the SHA-256. All of these checks occur under the writer lock.

A missing, symbolic-link or directory input is unavailable before dispatch. Its
result has no CLI status.

## Download identity

The tagged
[download handler](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/file.rs)
prints `remote`, `local` and `bytes`. The client renames a complete temporary
sibling into place. The backend selects `download.bin` in the exclusive attempt
directory, so no caller can name or replace an earlier file.

The payload predicate needs the exact key set, the exact remote path and the
backend-owned local path. After a clean CLI completion, the backend reads the
copy as a stable regular file. Its size must equal the receipt. When the caller
names an upload ordinal, the size and the SHA-256 must equal that upload record.
A difference is unavailable, with the reason "downloaded bytes differ from upload
ORDINAL". Only a match publishes `transfer.json` with `matches_upload`.

The named ordinal must hold a clean upload of the same remote path. Otherwise
the call refuses before dispatch and allocates no ordinal. The `one-shot` class
is a parser error, because a download is a read.

An evidence-class download stays callable after a latch. It collects context
only and never clears the latch. A read-poll download refuses after a latch.

## VM start, stop and inventory

The tagged
[vm handlers](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/vm.rs)
and the
[list rows](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-vm/src/listing.rs)
decide these schemas. The adapter still appends the pinned `--id` and `--json`
to a start and refuses `--viewer` and `--keep-on-failure`.

| Helper | Arguments sent | The payload must have |
|---|---|---|
| Start | `vm start --platform macos --wait --base BASE`, then `--display` if given | the exact keys, the pinned `id`, `platform` macos and the requested `base`. Also `vnc` and `agent` endpoints with ports from 1 to 65535, nonempty spec and meta paths and a valid optional `tpm` object |
| Stop | `vm stop` with the pinned identity | exactly `id` equal to the pinned identity and `stopped` true |
| Inventory | `vm list --all` | the exact keys, `truncated` false, `returned` equal to `total` and to the row count, exact rows, and one or zero running rows with the pinned name |

The start helper requires an explicit BASE. The protocol requires k57 to select
and audit the base, so no default golden image is implicit. A null agent
endpoint is unavailable, because every later transport needs the agent.

An absent clone is a clean negative only in a complete, untruncated list. A
truncated list, a duplicate row, a wrong field type or an unexpected state is
unavailable, never a negative.

The exact key sets make an unknown field unavailable. A changed CLI schema
therefore holds the harness visibly. It is never accepted silently.

## Records

Each attempt keeps the existing records of the shared adapter: `request.json`,
`raw.stdout`, `raw.stderr`, `cli.exit`, the validator streams and
`result.json`. Upload and download requests record the transports `upload` and
`download`. Start, stop and inventory requests record the transport `cli`.

| File | Written by | Content |
|---|---|---|
| `local-before.json` | upload, before the dispatch | the local path, size, SHA-256, device, inode and times |
| `local-after.json` | upload, after a clean CLI completion | the same fields, read again |
| `download.bin` | the CLI, at the backend-owned path | the guest bytes |
| `transfer.json` | upload or download, only when qualified | the direction, the paths, the size, the SHA-256 and any matched upload ordinal |

A failure keeps every partial record and the original bytes in place. The
backend never deletes, replaces or redacts them.

## Actual source and caller inventory

The [source receipt](ordering-file-lifecycle-evidence/official-source.json)
records the tagged v2.7.0 objects that this leaf read with `jj file show`. Its
manifest digests equal those in the capture receipt. Comments cite each
decision site in the source.

The [bounded caller inventory](ordering-file-lifecycle-evidence/callers.txt)
covers the Settings scenario and every file that it sources. Its positive
control found the known stop call, and a mutated pattern found nothing. It
makes no dynamic-shell or whole-repository completeness claim.

| Existing caller | Adoption duty |
|---|---|
| `install_app` upload of `Koine.zip` to `/tmp/Koine.zip` | k76 replaces it once with `upload_guest_file`, then one `download_guest_file` that names the upload. k54 freezes the bundle that `ditto -c` archives. |
| `install_app` upload of `vm-verify-client.sh` | k76 applies the same upload and download pair. |
| Scenario upload of `vm-verify-enrollment-client.py` | k76 applies the same upload and download pair. |
| `_start_vm` start | k57 supplies the clone identity and the explicit base. k76 calls `start_guest_vm` once, with an absent inventory before it and a running inventory after it. |
| `cleanup` stop, which ignores failure | k57 replaces it with one `stop_guest_vm` and one absent inventory. A failed stop leaves cleanup unresolved. `KOINE_VM_KEEP` stays a k57 containment decision. |
| `cleanup` deletion of `WORK` | k76 and k57 keep every original and partial before any deletion. |
| Host copies `installed-PHASE.txt` and `least-size-content.json` | k76 replaces each overwriting `>` write with the raw receipt or an exclusive write. |
| No guest file collection exists today | A collection step uses an evidence-class `download_guest_file`. |

## Environment and installed identity

This leaf supplies the identity of the uploaded bytes and of the guest copy
at the moment of the download. It does not observe the installed tree after
`ditto -x`. k81 owns every exec read: the guest environment, the diagnostics
and defaults and the exact installed inventory. k57 owns the per-item original,
installed and golden audits. k54 pins the CLI identity, its configuration and
the host versions.

The installed CLI on this host reports TestAnyware 2.9.0. The protocol and these
schemas name 2.7.0. k54 must pin the frozen CLI, and a difference holds before
E01. The exact key sets also make a changed payload unavailable.

## Controls and provenance

The [baseline run](ordering-file-lifecycle-evidence/baseline-red.txt) runs the
17 new controls against the legacy semantics, through test-only wrappers. All 17
fail. Each failure has a legacy cause: no receipt, an accepted wrong payload, an
ignored stop failure, no inventory or an admitted generic upload. The wrappers
adapt the new signatures only.

The [green run](ordering-file-lifecycle-evidence/final-verification.txt) runs
11 Taskfile checks. The new check passes its 17 controls. The ten existing
checks that share the backend pass their 173 tests.
The fixture CLI is synthetic. The backend, lock, receipts, jq and file
inspection are real. No VM, agent or golden image is contacted.

The [mutation receipt](ordering-file-lifecycle-evidence/mutations.jsonl) disables
one repair at a time in an isolated copy, with the
[mutation instrument](ordering-file-lifecycle-evidence/mutate.py). Each named
control fails. The first symbolic-link mutation survived, because the
`O_NOFOLLOW` guard and the identity check still refused the link. The second
mutation disables all three guards, and both symbolic-link controls then fail.

Two existing adapter controls used the generic upload and download routes. They
now assert the refusal. The checked routes have their own controls in the new
suite.

Run `mise exec -- task check:vm-file-lifecycle-evidence`. The
[measurement script](ordering-file-lifecycle-evidence/measure.sh) digests each
subject before and after each recorded run. No source or test changed during a
recorded run.

The [documentation check](ordering-file-lifecycle-evidence/docs-check.txt)
reports only the two known missing archive links that k23 owns. It is not a
clean documentation result.

## Limits

A download proves the guest bytes at the moment of the download. It proves no
later state and no installed tree. Each checked upload adds one download read.
That read can end a slot as unavailable, like any other required read. It adds
no input, wait or poll.

The local digest holds only for cooperating processes. A same-user process
can still change a file between two reads and restore every checked field. The
backend reads in 1 MiB blocks, so memory stays bounded. Neither the upload nor
the download has a byte cap. Guest files can contain secrets, so the whole
evidence root stays private. Do not publish or commit it.

The stop helper does not count stops. k57 owns the single stop budget, the
orphan-lock rule and the exact containment. The start payload does not show
whether the TestAnyware app or the direct CLI started the clone. k54 pins that
configuration.

## Remaining duties

<!-- tc: depart synonym-rotation because VM start and application launch are different operations -->
k81 keeps EVERY exec and one-shot confirmation. These include the environment,
the defaults and their absence, the exact installed inventory and the launch,
quit, restart and port consequences. No upload or download receipt replaces
them. k76 keeps complete caller and root adoption, signals and both held-pointer
controls. k67, k62, k57 and k54 keep their original duties.

The availability limits stay binding: the missing snapshot tree, the empty
AXValue and the OCR substring stop. The private secret-bearing roots stay
private. Every original criterion of k85, k80, k75, k71 and k66 survives. No
VM, candidate, freeze, acceptance or ancestor closure follows.
