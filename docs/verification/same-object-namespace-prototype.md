# Bare native-ID same-object prototype — k152

The short `/.vol/<device>/<inode>` operand reopened the original 900- and
1,500-byte file and directory targets and read their exact markers on this
guest. It did not establish a complete opener/receiver route. The collection
is **incomplete with a stop-rule deviation**, not a passing charter execution.

TextEdit rendered the 900-byte file before the stop boundary. The next request,
named Zed opening of that control file, displayed an **Unrecognized Project**
trust dialog. The driver's wording-based security detector missed it and
continued. The supervisor saw the saved screenshot and interrupted the run;
the `finally` block stopped/disposed the guest. No trust choice was clicked,
no setting was changed and no replacement collection is commissioned.

The binding [authorized charter](long-action-route.md#authorized-finite-same-object-namespace-diagnostic)
requires stopping on unexpected consent/security UI. Six requests after the
first recorded trust dialog are preserved as out-of-charter observations and
earn **no compliant receiver/selection credit**. Their apparent successes or
failures must not be rolled into a successful diagnostic. The native/local
checks below were collected before any action or trust dialog.

## Execution and provenance

- One disposable macOS clone, `koine-k152`; one build, one collection, zero
  instrumentation corrections or retries. Clone request through teardown:
  **91.58 seconds**, within the 45-minute cap. Task exit 130 follows the
  supervisor's interrupt; `complete:false` in the raw summary is intentional.
- Guest macOS **26.5**, build **25F71**, Darwin 25.5.0,
  `xnu-12377.121.6~2/RELEASE_ARM64_VMAPPLE`, arm64, VirtualMac2,1.
  Host compiler/SDK are recorded in
  [host-build-environment.txt](same-object-namespace/results/host-build-environment.txt).
- Exact short registered Zed copy: `/Applications/Zed.app`, **1.22.0**,
  bundle `dev.zed.Zed`, Developer ID team MQ55VZLNZQ. Ordinary launch produced
  an empty project without a trust prompt; that preparation did not prevent
  the later fixture-specific trust dialog. No project trust was preauthorized.
- K152Probe has ordinary Developer ID team TA43A4RUP3 signing, hardened
  runtime and an empty entitlement dictionary. Guest executable SHA-256:
  `4f64daac0bdb680d485af1fb528bc4d27916e5917d2bf9ef982b4c39af950aaf`.
  [Guest environment](same-object-namespace/results/guest-environment.out)
  and stderr preserve verification/signature output. No private long-path
  policy, extra entitlement, receiver instrumentation or consent was added.
- Fixture-native device **16777233**; `getattrlist` at `/Users/admin/k152`
  returned volume capabilities `[26963679,28274631,0,0]`, valid masks
  `[134217727,33554431,0,0]`, status zero. `diskutil info /` records an APFS
  system snapshot; it does **not** independently name the fixture's Data-volume
  mount. Native device and fixture-root capability provenance are the measured
  volume evidence; a complete fixture mount inventory is not established.
- Helper source is [probe.m](same-object-namespace/probe.m). Build and collection
  commands are the `fixture:same-object-namespace` and
  `fixture:same-object-namespace-vm` tasks. Their archived collection allowance
  is spent: these commands are not authorization to run again. The driver is
  intentionally preserved as measured, including its defective stop detector.

## Independently created subjects and local results

[corpus.json](same-object-namespace/results/corpus.json) contains exact original
inputs. Creation uses `mkdirat/openat`, with ASCII component lengths at most
245 bytes and five/seven levels. Each file has a distinct same-parent decoy;
each directory and its decoy have a uniquely named child with distinct fixed
marker contents. All reads are at most 64 bytes. No hard link, alternate
namespace, copied object, cwd change or user/protected/remote file is used.

The helper serializes its owned descriptors: parent/target/marker-child is the
maximum of three. Opaque Foundation/AppKit descriptor acquisition is not
measured by that owned bound. Values in helper records are below 8,192 bytes.
The target, parent and decoy are opened independently; the namespace operand
is reopened and compared by full native device/inode and exact marker contents.
This uses full inode formatting, not Carbon node-ID narrowing. These observed
inodes fit within 32 bits, so the sample does not exercise a high-bit inode.

| Original subject | Parent inode | Target / decoy inode | Bare operand | Local identity and marker |
| --- | --- | --- | --- | --- |
| File, 900 bytes | 224514 | 224515 / 224516 | `/.vol/16777233/224515` | Pass; target, never decoy |
| Directory, 900 bytes | 224525 | 224526 / 224528 | `/.vol/16777233/224526` | Pass; exact `CHILD_K152_900.txt` marker |
| File, 1,500 bytes | 224540 | 224541 / 224542 | `/.vol/16777233/224541` | Pass; target, never decoy |
| Directory, 1,500 bytes | 224553 | 224554 / 224556 | `/.vol/16777233/224554` | Pass; exact `CHILD_K152_1500.txt` marker |

All four 900-byte and long controls passed before submission. The namespace
path URLs were ordinary file URLs, `isFileReferenceURL:false`, without a base.
The original pathname stayed separately recorded; external submission used the
changed bare spelling. That diagnostic exception satisfies no original-byte
external-submission requirement.

The raw `fixture-*.out` and `inspect-*.out` records preserve identity/marker
checks. Each completed action helper additionally records original identity
and marker checks before and after the native request, with matching values.
The end-of-collection `final-*` inspections were **unrun** after interruption;
there is no global post-teardown identity claim.

## Native facts and exact-item handler observations

At 900 bytes, resource flags and type acquisition returned regular-file versus
directory, not package/application/alias, with `public.plain-text` or
`public.folder`. `NSURLIsExecutableKey` returned false for files and true for
directories; this native result is not a permission-bit inference or a claim
that a directory is a runnable program. The exact-item handler calls returned
TextEdit for files and Finder for directories.

At 1,500 bytes, regular-file/directory/package/alias/executable keys still
returned values, but **application and type acquisition failed** with
`NSCocoaErrorDomain 256`, underlying `NSPOSIXErrorDomain 28`. Keep those typed
failures as unacquired facts. Exact-item handler calls nevertheless returned
TextEdit/Finder; a handler result does not repair the missing classification.
No guessed extension, permission-bit substitute or nil-as-absence mapping was
used. There was no nil handler in the collected subjects. Bundle identifier,
long app registration/selection and receipt identity were not measured.

## Requests and independent receiver observations

The helper uses `NSWorkspace.openURLs` with activation enabled, no new app
instance, running-app substitution disabled and prompting disabled. The named
copy is the exact registered short Zed URL. Finder reveal uses the existing
`selectFile:inFileViewerRootedAtPath:` primitive. Every recorded callback
arrived within three seconds; all recorded callbacks carried an empty error
dictionary. That is acknowledgment, not receiver access. Reveal's Boolean
supplies no NSError cause. No timeout/early cancellation test was performed;
the observer exits at the acknowledgment bound and cannot retract an OS request.

Before each attempted request, the driver asked known receiver processes to
terminate, activated Finder and sent Close All Windows. Saved UI trees showed
no prior fixture window for the first request and no target/decoy strings.
No text or trust option was clicked. Later than the stop boundary, apparent
absent-name baselines do not establish compliant reset; the final attempted
named request also had a residual TextEdit error dialog. Trust UI was missed
because the detector searched different phrases, not `Unrecognized Project`.

| Subject | Default open | Named Zed open | Finder reveal |
| --- | --- | --- | --- |
| File, 900 | **Measured pass:** TextEdit AX text and screenshot contain exact target marker, absent in baseline and different from decoy | **Stop boundary:** callback acknowledged; screenshot shows exact target marker behind unexpected project trust dialog. No prompt-free receiver pass | Attempted after required stop; Boolean YES; no compliant selection credit |
| Directory, 900 | Attempted after required stop; callback acknowledged; no compliant child-rendering credit | Attempted after required stop; callback acknowledged; no compliant child-rendering credit | Attempted after required stop; Boolean YES; no compliant selection credit |
| File, 1,500 | Attempted after required stop; callback acknowledged but TextEdit says document could not be opened. Also missing production classification facts; no compliant default-open result | Attempted after required stop; callback acknowledged; interrupted before post-request UI capture; receiver **unmeasured** | **Unrun** |
| Directory, 1,500 | **Unrun** | **Unrun** | **Unrun** |

Eight raw request outputs exist: one before the trust-dialog boundary, the
boundary request and six after it. The raw summary includes seven post-UI
completed rows; the eighth helper output was saved before the interrupt but
never added to that list. Do not use its list length as the attempted-request
count. The remaining four requests and all final inspections were unrun.

Independent evidence for the sole clean receiver row is
[TextEdit UI](same-object-namespace/results/after-file-900-default-ui.json) and
[screenshot](same-object-namespace/results/after-file-900-default.png), compared
with the [absent baseline](same-object-namespace/results/before-file-900-default-ui.json).
The [Zed trust screenshot](same-object-namespace/results/after-file-900-named.png)
establishes the stop boundary; its native callback alone would have missed it.
The post-boundary [TextEdit error](same-object-namespace/results/after-file-1500-default.png)
is preserved but does not become an admitted long receiver verdict.
Exact delivered operands are **opaque**: no receiver interception was authorized.
Visible original filenames show UI naming recovery for the control file, not
byte-exact delivered-path provenance. No Finder actual selection was established,
and no save/write behavior was tested or inferred.

## Frozen evidence and teardown

The original [summary](same-object-namespace/results/summary.json),
[driver log](same-object-namespace/results/driver-log.jsonl), all case inputs,
raw stdout/stderr/exit codes and UI captures remain unchanged. Per-subject
input/output files are hashed in
[output-digests.json](same-object-namespace/results/output-digests.json).
The frozen driver, reused command module, helper, plan, signing inputs,
Taskfile, charter, archives and corpus matched item-by-item between
[subjects-before.json](same-object-namespace/results/subjects-before.json) and
[subjects-after.json](same-object-namespace/results/subjects-after.json).
That proves immutability during the reading, not instrument correctness.

[vm-stop.json](same-object-namespace/results/vm-stop.json) records
`stopped:true`, `ok:true` for `koine-k152`. Subsequent VM listing showed only
golden images. The clone was disposed even on incomplete execution. UI samples
before the boundary are bounded observations; the actual later trust dialog
prevents a general no-dialog assertion. No second guest, repair, replacement
collection or new investigation is authorized or run.

## Returned gap and human reaction

Recommend carrying this **incomplete report** into k153: local long-object
access is a measured positive, but long native application/type facts and the
receiver/Finder route remain unresolved. Discard post-boundary rows as compliant
acceptance while retaining them as evidence of the instrument failure.
The allowance is spent; k153 receives no automatic retry permission.

This report neither rejects the absolute long-path requirement nor adopts a
production spelling/support exception. It establishes no lasting volfs support,
long app registration/selection/constrained launch/executable receipt, native
metadata parity, save semantics, search G/N/V handoff, public/binary acceptance
or complete route. Keep k153 and every route ancestor live, with the original
final-review obligation. A finite failure is no universal impossibility result.

Antony answered **“I agree” on 2026-10-06** to accepting this incomplete report
for k153 to assess the remaining route gap, with no retry authorized. This
completes the prototype's reaction deliverable. Retire only k152; k153 and all
complete-route ancestors remain live under the unchanged absolute requirement.
