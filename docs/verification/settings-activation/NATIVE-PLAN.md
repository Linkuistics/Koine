# Native activation log qualification

Declared before the first guest on 2026-10-28. This is an instrument
qualification experiment, separate from the closed diagnostic and order samples
and from ordinary-operation repair acceptance.

Use the unchanged signed diagnostic bundle, copied to the separately named
`.build/settings-activation/native/Koine.app`. Compare its complete relative
file/link inventory to the original diagnostic inventory. Do not overwrite any
previous candidate. The frozen diagnostic source overlay identifies its source.

Run exactly two fresh clones, native 01 and native 02, from
testanyware-golden-macos-27 at 1920×1080. Each runs the existing focused prefix:
first launch, TextEdit in front, initial Settings selection and three reopens.
Each ends at its first failed assertion, transport failure or interruption.
No replacement or extension. All later complete-scenario assertions are NOT RUN.

The only new intervention is a guest `/usr/bin/log stream` sidecar, at debug
level, selecting Koine and the named native application/focus services. Start
it before application launch and retain its exact command, process identity,
stdout, stderr and exit status. Stop it after untouched failure observations
and before clone stop. One guarded launch/readiness exec preserves its raw JSON
envelope and is never retried. A timeout ends that attempt even if it returns
text; collection still runs. Existing safe-read retries elsewhere in the
scenario are unchanged.

Qualification requires identifiable native records for the actual NSApp path,
correlated by process and time to observed successful activation. A failure's
request/disposition record must itself identify the responsible path or context.
Missing records, private/redacted fields, guessed names and successful calls
through another API do not qualify a request/disposition observation. Match
successful and failed selections within the unchanged path and disclose any
state differences. No claim of native-log completeness is made.

The sidecar adds CPU, disk and logging load; the candidate also retains its
existing synchronous JSON-lines tracing. This may change timings. A recorded
failure establishes only that the symptom survives this instrumentation. These
guests cannot qualify ordinary operation or establish a reliability rate.

Before collection, freeze actual bundle inventories, every consumed script,
Taskfile, source/manifests, observer binary, this protocol and golden
config/disk/NVRAM. Audit the same subjects afterwards, retain every started
attempt and native transport failure, and stop every clone. Readiness and clean
stop are separate from whether the log contains useful native evidence.

If the bound yields no qualified discrimination, report the instrument's exact
limit and hand off the remaining causal question. Do not extend the sample or
select a repair from green counts. An eventual repair requires a separately
declared bounded complete fresh-guest sample through app:vm-verify-menu-bar with
KOINE_SETTINGS_TRACE disabled. No release, notarization or upstream report.
