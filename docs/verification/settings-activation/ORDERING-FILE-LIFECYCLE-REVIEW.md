# File transfer and lifecycle review

Review `settings-file-lifecycle-k149` inspected producer `25ed10823ff8`
(`settings-file-lifecycle-k89`) against its parent `8918ca3c379f`. The preceding
report conversion is context. This review makes no production or test changes
and runs no test, build, lint, format or guest command. It establishes no
native availability, signed subject, freeze or acceptance.

Three findings need integration triage before k81 or k76 consumes the artifact.
They concern retention, an inconsistent adoption contract and measurement
provenance. They do not demonstrate a Koine failure.

## P2-1: The download dependency deletes partial file evidence

The new download path delegates directly to the tagged CLI and waits for it to
return (`scripts/vm-guest-exec.py:365-376,440-450`). Only a clean response reaches
the copy inspection at lines 476-495. The tagged agent client creates a temporary
sibling, streams into it, then removes it on a streaming error:
[`AgentClient::download`, v2.7.0, lines 456-485](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-agent-client/src/lib.rs#L456-L485).

Thus a transfer that writes a prefix and then times out or disconnects can
return unavailable with its raw error receipt retained, while its produced file
prefix has already been deleted. The backend's unique `download.bin` destination
does not prevent that deletion. This applies to evidence-class collection too.

The producer report's Records section says a failure keeps every partial record
and the original bytes in place. Its caller handoff presents the checked
download as the collection route. The k89 charter and current k36 brief require
original and partial retention, and the protocol's Required transport and
evidence handling section requires all produced originals and partials to be
retained. The tagged implementation cannot establish that promise for failed
download bytes. This is an existing dependency behavior newly consumed by the
helper, not a claim that the Python backend explicitly unlinks a file.

The synthetic download fixture (`Tests/scripts/fixtures/file-lifecycle-cli.py:47-69`)
models successful rename, missing output, symlink and corrupt output. It does
not model a streaming prefix followed by deletion on failure. The download
failure control at `Tests/scripts/vm-file-lifecycle-evidence.bats:173-185` checks
unavailability and absence of `transfer.json`; it cannot disprove loss of that
prefix. None of the retained mutations targets this dependency behavior.

This finding blocks a claim that collection satisfies the full retention duty.
Integration must establish what the permitted seam can retain, distinguish
unavailable/deleted partial bytes from preserved records and resolve the
contract before consumption. It must not infer that a later download recovers
the original failed transfer or silently relax the original retention duty.

## P2-2: The adoption handoff contradicts the preserved read counts

The k76 task's Contract ownership after k140 section requires all original
action and read counts to stay unchanged (producer lines 154-158). Its new K89
handoff then requires a download after each upload (lines 168-172). The current
k36 brief likewise says to preserve read counts. The producer report's caller
table adds this pair at all three reachable upload sites, and its Limits
section explicitly acknowledges the added read.

The original `install_app` has two uploads and no matching download
(`scripts/vm-verify-lib.sh:352-367`). The scenario adds the enrollment script
upload at `scripts/vm-verify-menu-bar.sh:86`. The proposed adoption therefore
adds three guest transfers before the Settings actions. A download supplies
useful byte evidence, but calling it a read does not reconcile the conflicting
count requirements. Its duration and another required failure point also change
the workload before the intermittent symptom is evaluated.

The ordering protocol authorizes specified new setup, route, title, liveness
and downstream confirmation evidence. That means not every added read is
automatically forbidden. However, neither the k89 handoff nor its decision log
identifies an accepted exception reconciling these three downloads with the
still-explicit read-count duty. The keepalive-removal ADR concerns periodic
captures and does not settle file-transfer counts.

This is a contract finding, not evidence that the digest comparison is wrong.
The upload receipt alone still does not prove guest bytes. Integration must
settle the authority and exact count for byte verification before k76 adopts
it, while retaining the upload-identity duty. If that requires changing agreed
scope, that decision belongs to the human. No such amendment is made by this
review, and no timing-neutrality claim follows from a decision to admit it.

## P3-1: The recorded unchanged-subject claim omits consumed inputs

`ordering-file-lifecycle-evidence/measure.sh:6-9` hashes ten fixed paths. The
final receipt runs eleven Taskfile checks whose commands consume more paths.
For example, the capture check executes `Tests/scripts/fixtures/capture-cli.py`
and sources `scripts/vm-capture-evidence-lib.sh`. Its Bats setup also reads
`persisted-01/failure-observed.png` (lines 21-27). The adapter's saved-timeout
control reads `persisted-01/trace-disabled-after.json`
(`Tests/scripts/vm-guest-exec.bats:435-436`). None of those four files is in the
measurement subject list. The window, input, UI, click, physical, pointer,
start and resize checks also consume omitted scripts and suites.

The retained final receipt does report exit zero and 190 named successful
tests. Its before/after digests establish equality for the ten named files.
They cannot establish the report's broader statement that no source or test
changed during the recorded run, or a complete consumed-input audit. The
capture report already identifies omission of the saved timeout fixture as a
provenance limitation in earlier measurements; the same issue recurs here.

This does not show that an omitted file actually changed, or that a recorded
test failed. It leaves the required measurement provenance incomplete.
Integration must qualify the historical receipt accurately and supply the
required complete input evidence for any fresh verification it relies on.
This review neither reruns those commands nor rewrites their old receipts.

## Source and contract checks without additional findings

The source comparison used immutable TestAnyware commit
`65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03`, identified as v2.7.0 by the producer.
All nine source digests in `ordering-file-lifecycle-evidence/official-source.json`
match fresh reads of those objects. This does not qualify the installed 2.9.0
executable. The k54 version/configuration hold remains necessary.

| Transport | Tagged evidence compared with the predicate |
|---|---|
| Upload | `commands/file.rs:104-122` returns `local`, `remote`, `bytes`; `output.rs` adds `schema_version`, `ok`. `AgentClient::upload` returns the stat size, so the upload receipt alone is insufficient for guest identity. |
| Download | `commands/file.rs:149-166` returns `remote`, `local`, `bytes`; the backend checks the exact destination and actual size, then the named upload's digest. The partial-retention finding above remains. |
| Start | `commands/vm.rs`, `Started::json` returns `id`, `platform`, `base`, `vnc`, `agent`, `spec_path`, `meta_path` and optional `tpm`; `tpm_json` supplies the two admitted shapes. The helper intentionally requires an agent endpoint. |
| Stop | `run_vm_stop` returns the exact `id` and `stopped:true`; dry-run and failed completion do not qualify. |
| Inventory | `item_to_json` and `list_json` emit the seven row fields and complete counts used by the helper. `listing.rs` explains golden/running rows and `--all`. The helper counts the pinned running identity and rejects truncation. |

`run` owns the nonblocking writer lock across `run_locked`, including both local
upload inspections, download inspection, digest comparison, transfer publication,
stdout emission and result publication. The next ordinal uses an exclusive
directory, and record publication uses exclusive partial creation and a
nonreplacing link. A reused output does not silently overwrite earlier evidence.
The named upload must be clean and name the same remote path before download
dispatch. A failed transport never reaches byte qualification. Evidence-class
collection preserves the old latch; it does not restore scenario eligibility.

The local before/after comparison includes device, inode, size, mtime, ctime and
SHA-256. A cooperating writer in the same domain cannot dispatch while those
checks own the lock. These observations support only the documented cooperative
contract. They do not prove continuous immutability against arbitrary same-user
host mutation or a later guest modification. The checked download proves the
copy at that read, not the installed tree after extraction.

The baseline receipt contains 17 failed controls against legacy wrappers. Several
stop at missing receipts, so it is not evidence that every nested bad-payload
variant separately failed. The mutation receipt supplies narrower disproofs for
the after-digest, guest-byte comparison, generic refusal, stop flag, complete
list, base and file guards. The first symlink mutation survived because other
guards remained; the combined mutation then failed. The report discloses that
result. The lock control holds the CLI, rather than inserting a new barrier
inside each local digest; lock lifetime at those boundaries is source evidence.

The two changed existing adapter tests now exercise the intended generic
transfer refusal. Checked upload/download controls replace their former generic
success expectations. This preserves the distinction between the generic seam
and the checked artifact path.

The bounded caller handoff covers the three reachable uploads, start, cleanup
stop, destructive WORK cleanup, overwriting installed/content host copies and
future collection. `guest_long` has an upload in its definition but no call on
this bounded Settings surface. No whole-repository or dynamic-shell completeness
claim follows. k81 retains exec environment/default/installed-tree checks; k57
retains independent per-item audits, the one-stop budget and containment; k76
retains adoption, statuses, signals and both held-pointer controls. k67, k62
and k54 retain their original duties. Those allocations leave no additional
environment or installed-identity finding in this review.

The archived k85/k80/k75/k71/k66 contracts were read through the retained
crosswalk. The current removal ADR supersedes their historical keepalive holds.
Missing snapshot trees, omitted empty AXValue, OCR substring stopping and private
secret-bearing evidence remain explicit limitations. No input, wait, poll,
historical cap or runtime slot was changed by this review.

Graph evidence is Tier 2, project
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14`, coverage
generation `2026-11-21T11:54:07Z`. The bounded graph lookup returned five facade
symbols without pagination. Its upload trace included unrelated cross-language
edges, which are not credited as calls. Coverage reports partial shell ranges
and changed or untracked metadata for several review inputs. Direct source reads
cover the material paths and reported ranges; graph counts are not used to
claim exhaustive caller coverage.

The findings belong to this review's commit. The integration task cites this
review's handle and independently classifies them. k36 and k12 remain open.
