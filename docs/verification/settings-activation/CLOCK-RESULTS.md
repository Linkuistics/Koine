# Native scale established; application clock relation remains unqualified

The offline investigation establishes the persisted archive's native boot and
tick scale using Apple's own decoder. It does **not** establish an exact join
between native continuous time and the application's awake-time clock. The
[original strict wall-clock result](persisted-01/strict-interval-joins.json) remains
false with no joined selections. No guest was started, no application source or
signed candidate changed, and no activation repair or ordinary acceptance ran.

## Evidence and clock contracts

The complete Apple [timesync output](clock-evidence/timesync.txt) and its
[command/exit receipt](clock-evidence/timesync.json) come from offline
`/usr/bin/log raw-dump --no-pager -t <saved-archive>/timesync`. Exit is 0 and
[stderr](clock-evidence/timesync.stderr) is empty. The decoded guest boot is
`2C83AC73-0855-44FD-A8A4-E03E227E1A01`, matching the archive's
[EndTimeRef UUID](persisted-01/archive-clock/Info.plist) and every extracted Koine
client row. Its native timebase is **125/3 nanoseconds per tick**, equivalent
to 24 million ticks per second. This scale comes from the saved guest, not a
host timebase query or fitting the application's uptime.

The [decoder subjects](clock-evidence/decoder-subjects.sha256) identify the Apple
tool and both archive/committed clock copies. The copies match byte for byte.
The retained timesync contains several older boots, so choosing its first boot
would be wrong. The focused reader requires exactly one matching boot block and
a positive numerator/denominator. It does not parse undocumented binary fields.
The native `machTimestamp` values also match Apple's already retained
[continuous default rendering](persisted-native-continuous-default.txt).

Apple's [systemUptime contract](https://developer.apple.com/documentation/foundation/processinfo/systemuptime)
counts awake time since restart. Its
[absolute clock](https://developer.apple.com/documentation/kernel/1462446-mach_absolute_time)
stops during sleep, while its
[continuous clock](https://developer.apple.com/documentation/kernel/1646199-mach_continuous_time)
includes sleep. Mach ticks convert to nanoseconds using the timebase fraction.
The [saved Apple documentation](clock-evidence/systemUptime.json),
[absolute documentation](clock-evidence/mach-absolute.json) and
[continuous documentation](clock-evidence/mach-continuous.json) preserve the
retrieved contracts. These API contracts do not promise that Foundation uptime
and continuous ticks have identical origins, or establish this guest's sleep
offset. The recorder reads `systemUptime` then `Date` separately; those are not
an atomic clock pair.

The installed Apple [show help](clock-evidence/show-help.stderr) explicitly
describes `--mach-continuous-time`. The [raw-dump usage](clock-evidence/raw-dump-usage.stderr)
describes decoding a timesync directory. Help/usage invocations exit 64, and
`log help raw-dump` is unsupported with exit 64; their text is retained as usage
information, never promoted to a successful decode. The actual decode is a
separate successful command. Host OS [identity](clock-evidence/host.txt) is
provenance only; sharing a build with the guest establishes no shared clock.

## What numerical enclosure does and does not show

`mise exec -- task report:settings-native-clock` runs the new
[offline reader](clock-report.py). Its [retained result](clock-evidence/report.json)
uses exact recorded interval endpoints, with no tolerance or clock correction.
Under the explicitly conditional assumption that continuous seconds equal
recorded uptime, it finds:

| Selection | Native ticks | Native continuous seconds | After recorded before | Before recorded after |
|---|---|---|---|---|
| Initial, PASS | 4338579225 | 180.774134375 | 7.958 µs | 1369.583 µs |
| Reopen 1, FAIL | 4476843871 | 186.5351612917 | 14.167 µs | 1214.375 µs |

These are **conditional numerical candidates**, not qualified joined requests.
The buffer has no boot UUID, paired absolute/continuous measurements, or measured
sleep offset. Same-guest provenance is supported indirectly by the original
acquisition and PID/image evidence, but the buffer itself cannot verify boot
identity. Neither enclosure nor absence of a sleep message proves zero sleep
offset or a common origin. Missing logs are not proof of an uninterrupted clock.
The reader therefore always leaves this format's cross-clock qualification
false and `joinedSelections` empty. Its success exit means the report was
computed, not that clock correlation or activation succeeded.

The old native wall times remain 0.399/0.554 ms after the respective buffered
after-times. They cannot become enclosed by silently shifting wall times or
substituting the table above. Those small discrepancies need no interval
widening to retain the observations: the native and application records remain
available independently, with the precise relation explicitly unknown.

The [persisted result](PERSISTED-RESULTS.md) still supplies positive callback,
show/activation return and inactive/no-key evidence, plus a clean independent
snapshot of Koine behind TextEdit. The same changed instrument preserves the
failure, with no timing neutrality. Nearby native client/token rows and native
successful front/result/resume rows remain positive observations. Shared -50
results/token fields, remote-menu teardown and missing front/resume records
still establish neither an explicit failed native disposition nor its cause.

## Verification and integrity

The [12 focused controls](clock-evidence/controls.txt) pass through
`task check:settings-native-clock`, including Ruff. They reject unknown/duplicate
boots, absent or zero scale, lost/noncontiguous/incomplete/reversed buffers and
wrong native boot despite matching PID/ticks. A wrong scale removes the numerical
candidates while leaving qualification false. The [initial failing controls](clock-evidence/controls-red.txt)
precede implementation. The [sole adversarial review](clock-evidence/review.txt)
finds no concrete issue within its stated reader/evidence scope. These controls
verify the instrument, not native Settings behavior.
The [inherited capture checks](clock-evidence/inherited-controls.txt) also pass
through `check:vm-settings-persisted`; no guest is allocated by those controls.

The final offline run's [input manifest](clock-evidence/subjects.sha256) and
[after-check](clock-evidence/subjects-check.txt) cover every persisted original,
the local raw archive and its extracted inventory, the unchanged signed events
candidate, reader/tests/Taskfile, recorder source and new decoder/contract inputs.
Every listed digest matches before/after the reported final analysis. Historical
frozen runs remain historical: changing the current Taskfile after a closed run
does not claim that its old 316-input manifest matches the current tree.
All original VM outcome distinctions in PERSISTED-RESULTS.md remain unchanged.
The [original archive/candidate audit](clock-evidence/original-audit.txt) verifies
the raw archive's retained digest, every extracted archive file against its old
inventory and the full candidate inventory against persisted-bundle.txt.

## Original duties and remaining work

The complete original-duty comparison in
[PERSISTED-RESULTS.md](PERSISTED-RESULTS.md#every-original-duty-and-remaining-work)
remains authoritative. This table checks the same duties with the new clock
boundary; it replaces none of their original criteria.

| Original duty / owners | Current outcome and remaining duty |
|---|---|
| Offline boot/timebase/sleep qualification, k29 | Native boot/scale established by Apple decoder. Application boot/origin/sleep relation remains unqualified; strict wall-clock false preserved |
| Historical classification, k12/k14/k16 | Diagnostic-02's delivered callback/failed activation remains met; persisted failure corroborates it unchanged |
| Supported hypothesis and discriminating finite protocol, k27/k25/k22/k20/k18/k16/k14 | Cooperative rejection versus pre-submission suppression remains a hypothesis pair. No new experiment or discrimination; next protocol must measure a usable clock relation and target positive native disposition/context |
| New observation and timing, k29/k27/k25/k22/k20/k18/k16/k14/k12 | Offline work adds no scenario load. Persisted Debug symptom preservation remains demonstrated, timing neutrality unknown. A changed future recorder needs its own qualification |
| Separate bound/freeze/completed golden, k29/k27/k25/k22/k20/k18/k16/k14 | No guest launched here. All old caps closed; a new experiment must be separately named, finite and frozen before launch, with completed golden hashes |
| Acquisition/default fallback/lag, k25/k22/k20/k18 | Earlier actual-path capability/lag preserved. Native scale improves interpretation only; complete precise causal capture remains unqualified |
| Retain failures/transports/partials/NOT RUN, audit/stop, k29/k27/k25/k22/k20/k18/k16/k14 | All originals preserved. Prior scenario/inner Task 1/201, native/collection/audit 1/1/1, outer Task 201 and timeout/-1 remain failures. Prior clone stopped; no clone here |
| Positive failed request/disposition/context, k29/k27/k25/k22/k20/k18/k16/k14 | Still open. Conditional tick enclosure supplies no explicit failed native result, responsible context or external owner |
| Justified product repair/useful failing seam, k29/k27/k25/k22/k20/k18/k16/k14/k12 | No product change or repair selected. Demonstrate a useful failing product seam where feasible once justified; no driver wait/retry/repeated input repair |
| One selection, one front/focused window, same owners | Persisted initial action passes and reopen 1 fails. Product outcome unresolved |
| Separate finite complete ordinary acceptance, same owners | NOT RUN. Must use app:vm-verify-menu-bar with diagnostics disabled, final ordinary subject/all inputs frozen and all outcomes/timing retained; no final repair subject selected |
| External cause/reproducer/approval, same owners | No external ownership established. Leave repair unresolved if external; no upstream report without Antony's approval |
| Root/verification reconciliation and release constraints, same owners | Updated here and in both verification handoffs/root brief. No causal ancestor closes; no release/notarization or upstream report |

K29 decomposes into clock evidence k30 and the remaining measured-clock/native-
disposition work. The precise next question is whether a recorder with guest boot
identity and directly bracketed native continuous ticks can bind actual activation
calls to positive native processing/disposition under a separately justified
causal protocol. First consider any independent offline evidence still available;
do not launch a guest merely to retry this saved question. A future guest must
answer the new discrimination/capability question under a declared finite matched
protocol; it cannot repeat the unchanged four-action instrument to chase failure.
The original persisted sample cannot retroactively gain measurements it omitted.
K29/k27/k25/k22/k20/k18/k16/k14/k12 remain open with every original duty above.
