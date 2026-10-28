# The native focus marker also occurs before successful activation

The saved native context does not justify treating TextEdit's
`viewbridge-key-window` marker as the cause of Settings activation failure.
The marker precedes the persisted failure, but it also precedes three successful
Koine front changes in the independent native-01 reference. This narrows the
next experiment: marker presence alone cannot be its failure discriminator.
No new guest, application change, native failed disposition or repair acceptance
is supplied by this offline comparison.

## Native sequence evidence

The [offline plan](focus-evidence/PLAN.md) names two original sources. The
[native-01 extract](focus-evidence/native-01.jsonl) and
[persisted extract](focus-evidence/persisted-01.jsonl) retain complete selected
records and their one-based line positions in the decompressed original source.
`sourceLine` is an original source position, not a line in the smaller extract.
No clock conversion or application-interval join is involved in these sequences.

In persisted-01, WindowServer generation 45 at native tick **4338531160**
(source line 5534) names frontmost TextEdit, ending at PID 974. The Koine client
call at 4338579225 is followed by positive native front changes and generation
46's Koine chain at 4338598329. Before the failed-adjacent client at 4476843871,
generation 57 at **4476508590** (line 5956) instead ends with
`<token: viewbridge-key-window; pid: 974>` after the TextEdit PID. Native token
processing then targets Koine PID 814. At 4476872612 (line 5975), WindowServer
positively records connection 53ea7 requesting window 32's active key appearance.
That connection was previously identified as TextEdit's main connection.
This is an observed request, not proof of a completed appearance change or an
activation refusal. The independent failure snapshot remains the outcome evidence.

The differing chain is worth comparing, but the older source contains these
counterexamples, all within native-01's own tick domain:

| Native-01 generation / original source line | TextEdit terminal-chain tick | Koine client tick | Positive Koine front-change tick / source line |
|---|---|---|---|
| 50 / 126847 | 2682970417 | 2683087302 | 2683108692 / 126898 |
| 62 / 135293 | 2822046283 | 2822165555 | 2822320616 / 135339 |
| 75 / 143301 | 2962083253 | 2962277092 | 2962438854 / 143358 |

Each preceding chain names frontmost TextEdit PID 792 and ends with
`<token: viewbridge-key-window; pid: 792>`. Each following front-change record
names Koine PSN 0x0-0x2a02a, connection 1400b. Their native activities are
75118, 76116 and 76842 respectively; the same activity labels occur on the
respective client records. Later LS/CAS err=0/noErr and Koine resume records
provide further positive native evidence. Activity labels and sequence are useful
correlation fields, not a verified transaction identifier.
The [original native result](NATIVE-RESULTS.md) independently retains all four
successful Settings checks. These three records correspond to its reopens; the
extract also retains earlier Koine launch/initial requests rather than silently
restricting the source to a preferred subset.

The native-01 live stream has substantially more observation load than deferred
persisted acquisition. This is not a matched causal comparison, and it cannot
exclude an interaction between the marker, timing and another condition. It does
contradict the unrestricted claim that this marker alone prevents activation.
It neither qualifies sleep/clock calibration nor supplies a failed native result.
The live source's empty bootUUID fields cannot establish boot identity; native
ordering here is confined to each separately retained capture.

## Competing predictions and the next boundary

A sufficient-marker hypothesis predicts that a request following this TextEdit
terminal marker cannot make Koine frontmost. The positive native-01 sequences
contradict that prediction. A context-interaction hypothesis predicts different
outcomes despite the same marker when another activation-authority or timing
condition differs. It is consistent with these observations, but too broad to
serve as a causal explanation. Pre-submission suppression versus native rejection
also remains unresolved for the actual application interval, because its old
clock relation is unqualified. Nearby native processing cannot repair that gap.

Before any new guest, select an independently supported, controllable condition
with distinct competing predictions; specify how the intervention changes that
condition while matching the application/window and foreground setup. A new
recorder must identify the guest boot/timebase and directly bracket activation
with native continuous ticks, or establish an equally independent relation.
A richer recorder alone, another unchanged four-action sample, a timing wait,
repeated failed selection or a successful alternative API supplies no causal
experiment. Qualify availability, symptom preservation and observation load for
the changed subject. No specific new intervention is established here, and this
offline plan authorizes no VM allocation.

## Reproduction and limits

Use the existing Taskfile entry point through mise:

```sh
mise exec -- task check:settings-native-focus
mise exec -- task report:settings-native-focus SOURCE=docs/verification/settings-activation/native-01/native-log/stream.jsonl.gz
mise exec -- task report:settings-native-focus SOURCE=docs/verification/settings-activation/persisted-01/deferred-native/native.jsonl.gz
```

The [extractor](focus-extract.jq) selects the event families declared in the plan;
it is not a complete native failure monitor. It preserves known framing and
rejects unknown headers, malformed JSON, non-object rows and missing messages.
A nonzero command can emit partial output; only a successful whole pipeline may
be used. The archive completion object is retained as an observation, not as
proof of system-wide delivery or catalogue completeness.

The [fifteen controls](focus-evidence/controls.txt) pass, including Ruff.
The [initial failing controls](focus-evidence/controls-red.txt) precede the
extractor. A positive fixture with an unterminated final line exposed incorrect
source numbering from jq's input_line_number; explicit input counting fixes it.
The [sole review](focus-evidence/review.txt) confirmed native record claims but
found corrupt/nonterminal completion admission. Eight [failing framing controls](focus-evidence/framing-red.txt)
precede the repair: the completion count must equal all observed native records,
and any subsequent input fails. The instrument was then frozen afresh for final
reproduction. These controls test extraction integrity, not Settings behavior.
The repository [documentation link check](focus-evidence/doc-links.txt) still
fails on the two previously recorded archived-context links owned by k23; it
reports no new missing target in this slice. Historical measured files stay intact.

The [frozen subjects](focus-evidence/subjects.sha256) name the two original source
directories, historical outcome/plan/manifests, local raw archive, current signed
candidate's regular files, extractor, tests, Taskfile and offline plan. The
[final digest check](focus-evidence/subjects-check.txt) verifies those inputs.
The [reproduction receipt](focus-evidence/reproduction.json) records successful
whole Task commands and exact item-for-item equality with both retained extracts.
The [original audit](focus-evidence/original-audit.txt) compares the local archive
and candidate against historical inventories. No measured input was edited during
this final extraction/reproduction. This new freeze does not claim the historical
316-input manifest still matches the changed current Taskfile.

## Every original duty

The [complete original-duty table](PERSISTED-RESULTS.md#every-original-duty-and-remaining-work)
and [clock-stage comparison](CLOCK-RESULTS.md#original-duties-and-remaining-work)
remain authoritative. The following checks their obligations at this boundary;
none is replaced by this narrower slice.

| Original duty / owners | Outcome and work still required |
|---|---|
| Historical classification, k12/k14/k16 | Diagnostic-02 delivered-callback/failed-activation classification unchanged; persisted corroboration unchanged |
| Independent clock relation, k29/k31 | Native boot/scale established earlier. Old application boot/origin/sleep relation unqualified; strict wall-clock false and empty joins preserved |
| Supported hypotheses and finite matched protocol, k31/k29/k27/k25/k22/k20/k18/k16/k14 | Marker-alone explanation contradicted by positive successes. Supported controllable interaction and discriminating matched protocol still required before a new guest |
| Changed-instrument availability, symptom preservation and timing, same owners plus k12 | No new runtime instrument here. Native-01 versus persisted is not matched; persisted symptom preservation remains historical, timing neutrality unknown |
| New bound/freeze/completed golden before launch, same owners | No new guest. Offline inputs frozen/audited; all diagnostic/order/native/context/events/deferred/retention/persisted caps remain closed. Future experiment needs its own declaration and completed golden digests |
| Acquisition/default fallback/lag, k25/k22/k20/k18 | Prior capabilities/lag and incomplete native-monitor limits preserved; extraction adds no runtime acquisition evidence |
| Retain failures/transports/partials/NOT RUN, audit and stop, k31/k29/k27/k25/k22/k20/k18/k16/k14 | Originals preserved. Prior scenario/inner Task 1/201, native/collection/audit 1/1/1, outer Task 201, timeout/-1 still failed; prior clone stopped. No clone here |
| Positive failed request/disposition/responsible context, same owners | Still open. TextEdit appearance request is positive context, not failed native disposition or cause. Shared -50/token fields, marker, age and missing rows do not discriminate |
| Justified application repair/useful failing seam, same owners plus k12 | No product change or final repair subject selected. A useful failing product seam is still required where feasible once a repair is justified |
| One selection, one front/focused Settings window, same owners | Persisted initial pass/reopen 1 failure remain; no driver wait/retry/repeated-input repair |
| Separate finite complete ordinary acceptance, same owners | NOT RUN. Freeze final ordinary subject/all inputs, disable diagnostics, run app:vm-verify-menu-bar under a separate predeclared finite fresh-guest charter and retain every outcome/timing effect. Diagnostic wrappers do not establish this |
| External cause/reproducer/approval, same owners | No external ownership. Retain positive external evidence/reproducer and unresolved repair if established; no upstream report without Antony's approval |
| Root/verification handoff and release constraints, same owners | Reconciled here and in both verification handoffs/root brief. No causal ancestor closes; no release/notarization or upstream report |

Reopens 2/3 and every later complete phase remain NOT RUN for persisted-01:
user-input resize/minimum size/content-height/scrolling, shortcuts, client
requests/denials, Accessibility consent, silent launch, running-app reopen, login
restart and Quit. Earlier successful phases belong only to their original runs.
K31 decomposes into this offline evidence slice and remaining causal intervention,
measured disposition, justified repair and separate ordinary acceptance work.
