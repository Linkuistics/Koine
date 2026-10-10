# Application metadata selected-wire derivation

[Selected wire → Expand selection before counting bytes](../design/architecture/index.html#diagram-native-metadata-wire)
shows the independent response boundary. Graphs begin at their dark **Start here**
node; numbered edges give accounting order. This is a pure design instrument,
not provider implementation or native qualification. The
[source/root contract](../specs/application-metadata-source-root.md),
[owned-storage subcertificate](application-metadata-owned-storage.md) and
[saved episodes](application-metadata-episode-certificate.md) remain its inputs.

**The useful whole-job construction remains unestablished.** This closes the
finite selection and JSON accounting grammar. Actual final ordinary/indexed values,
publication costs and emitted errors remain inputs. Conditional byte uppers are
neither actual responses nor proof that the useful subject fits 8 MiB. The family
consumption hold, selected 20 MiB gross/4,194,304 attempts, three/five-second
deadlines, four true-return slots and pending native G/N/V remain binding.

## Complete selection and ownership

The [saved GraphQL document](../design/application-metadata-wire.graphql) validates
against the complete native design SDL. Its `CompleteApplicationWire` operation
selects two independently admitted root aliases, `alpha` and `beta`, with two
distinct items aliases under each. A repeated fragment and an explicit duplicate
`first` field exercise response-key merging. `includeSecond` can omit the second
root through an ordinary GraphQL directive; it does not change the public contract.

Each choice includes every public field: path, nullable name and identifier,
metadata source, installation state, nullable flags, complete unique policy/source
lists, plus a second name alias and typename. Result status, truncation and every
coverage/diagnostic/permission field are selected, including nullable subject,
event and permission. `SingleApplicationWire` selects one root and one items list,
with the same complete choice and coverage fields. `ApplicationSourcesWire` is
the independent no-items failure-inspection control. It is not a smaller selection
used to rescue a failed full-body certificate.

The collector groups fields by their **response key**, preserving each distinct
alias. Repeated fragments and equal response keys union child selections; they do
not duplicate a JSON property or make another native observation. Different root
aliases own separate snapshots and may publish different values or outcomes.
Nested aliases read one frozen snapshot and repeat its encoded values without
native work. This decouples selection multiplicity from reader/source budgets.

The executable full-field check enumerates the SDL fields for every reachable
object and rejects an omitted item, coverage, diagnostic or permission field.
Schema changes therefore require revisiting the selected certificate. This finite
document is a verification subject, not a whitelist or public selection limit.
Other admitted documents need their own expanded selection accounting and remain
subject to the independent core body guard.

## JSON accounting

The [pure counter](../../scripts/application_metadata_wire.mjs) traverses the
selected value tree independently of an encoder. For a known string it counts
two quotes plus the encoded bytes for each scalar: quote, reverse solidus and
slash cost two; backspace/tab/newline/form-feed/carriage-return cost two; other
C0 controls cost six; other characters retain their lossless UTF-8 bytes. A
supplementary Unicode scalar contributes four UTF-8 bytes, not a guessed locale
character count. No NUL terminator is sent as a storage convention. An actual
embedded NUL, if admitted in a guidance example, is escaped rather than discarded.

For a string whose content is unavailable but whose UTF-8 bound is B, the
conservative token upper is `2 + 6B`. This is a byte upper, not a value, allocation
capacity or new field quota. Nullable known null costs four. An **unknown** value
keeps the containing byte total unknown; it does not become JSON null or zero.

| JSON value | Encoded byte term |
| --- | --- |
| Object with n fields | 2 braces + max(0,n−1) commas + each quoted response key + colon + each selected value |
| List with n entries | 2 brackets + max(0,n−1) commas + every element, including repeated aliases |
| Boolean | true: 4; false: 5; nullable null: 4 |
| GraphQL Int | Signed decimal length, including the minus; −2,147,483,648 costs 11 |
| Enum | Quoted exact schema token; list counts and punctuation remain separate |
| Response | Ordinary object algebra over data and any nonempty errors array |
| Error | message + optional nonempty locations + path + optional nonempty extensions, with all keys and punctuation |

The local Swift `GraphQLJSONEncoder` source has default compact output and slash
escaping, preserves UTF-8, and writes list/object separators without whitespace.
`GraphQLResult` omits an empty errors array and absent data. The local
`GraphQLError` **always encodes path**, including `[]` for the core replacement
error, even though GraphQL-js omits an absent path in its default error formatting.
The model supplies the read Swift shape explicitly where those defaults differ.
Each error location's line/column, path string or integer segment and every
extension member receives ordinary JSON accounting; there is no fixed error fee.

Tier 2 graph generation 2026-09-29T10:36:20Z excludes docs/scripts and returned
stale Engine snippet contents. Exact Engine and dependency source reads provide
these encoding claims; their digests are frozen by the instrument. The independent
encoder oracle uses JSON.stringify plus slash escaping. Pure GraphQL-js fixtures
characterize the selected-document boundary; they do not qualify the Swift runtime,
provider publication, transport or any installed native binary.

## Failure and saturation

FAILED produces ordinary null items and one failed error per **selected distinct
items alias**. The complete document has four error paths: alpha/first,
alpha/second, beta/first and beta/second. The merged alpha/first field retains two
contributing locations, counted individually. Sources-only inspection generates
no items error. BLOCKED/UNAVAILABLE/UNKNOWN yield ordinary null items without
generated errors. Explicit publication/permission failures preserve their actual
extensions and original alias/list-index path; non-null propagation may null the
items list or root. No surviving status erases errors.

The declared saturation fixture retains its choice, false resultsTruncated and
63 detail records plus one DIAGNOSTIC_LIMIT record. All three source summaries
remain. Canonical guidance containing every current application source/reason
pair is 843 UTF-8 bytes under the current enums; it includes a failure after
saturation. Subject and permission nulls, prompt-risk hints and optional event
values all contribute. A diagnostic sink does not silently omit a choice to fit
wire or change category completeness.

Actual independent publication errors are not bounded by these fixture messages.
Their actual message, locations, path and extensions are explicit inputs. The
counter can accept any finite supplied shape within its GraphQL scalar types;
unavailable members keep the total unknown. The counter does not establish the
number or contents of runtime errors merely by counting successful data fields.

## Saved episode association and conditional bounds

The [per-item report](../design/application-metadata-wire.json) joins all 2,043
ordered spellings with k223 and k226 independently for both saved runs. Every
row preserves the saved resolved-root byte dimension, exact literal-spelling
JSON size, conditional path-token upper, complete selected choice upper, four
alias contribution and an unknown actual selected size. The 129-byte name and
1,500-byte saved root witnesses remain. Every one of the 149 outside query
records is retained verbatim; no new copy eligibility, source/category exclusion
or outside-root outcome is inferred.

These rows assume final native paths equal the historical saved resolved targets;
literal spellings themselves are not substituted as final paths. Their final
name/identifier terms use the existing 1,024/512-byte bounds, with no invented
regional name, native getter/type outcome or en/de-only product restriction.
The two runs have identical wire uppers because those content-independent bounds
are used, not because their actual names are known equal. Every alias episode
is conservatively allowed to contribute a choice; identity merging can reduce
published multiplicity. This is an upper construction, not predicted duplicates.

For a **declared conditional completion example**, successful data includes three
source groups and a total of 64 diagnostics. It assumes declaredDomain <=1,024
and permission target <=8,192 UTF-8 bytes in addition to existing guidance and
subject bounds. Those two dimensions are assumptions, not newly selected product
quotas or actual source observations. Each is exposed in the report. The aggregate
does not include unavailable publication errors or extra choices from outside
paths. Real outcomes for those paths must be composed before claiming fit.

| Subject and full-field selection | Conditional successful-data upper |
| --- | ---: |
| Either saved run, one root/items list | 40,141,782 bytes |
| Either saved run, two roots/four items aliases | 147,120,535 bytes |
| General 2,048-choice envelope at 8,192-byte paths, one root | 139,562,727 bytes |
| Same general envelope, two roots/four items aliases | 544,804,315 bytes |

These conservative uppers **cannot establish an 8 MiB useful fit**. An upper
above the cap is not a lower bound or evidence that the real useful response
must exceed it. No budget increase or smaller public selection follows. A
conditional fit needs actual final scalar and source/error dimensions; until
then actual response, whole-job gross and attempts remain null. Keeping explicit
symbolic uppers avoids fabricating values, at the cost of not certifying useful
wire fit. Reverse that limitation only with checked final inputs and complete
selected output/error accounting.

## Core response guard and owned-output handoff

Exact Engine source encodes the complete result before checking `body.count`.
At <=8,388,608 bytes the body passes; above it the entire data is replaced with
null and a failed error. Under the read default encoding, the fixed replacement
body is 174 bytes, including its empty path. The model exercises both sides of
the exact boundary and a declared complete two-root/four-alias long indexed
fixture that exceeds it. It retains all selected arrays before replacement,
without dropping fields, truncating choices, changing a grant or lowering a gate.
This is the existing core policy, not a new adapter behavior.

The body guard proves no pre-encoding allocation bound, parser/native peak,
deadline or application-owned-budget fit. Before it, result maps/arrays and every
alias value may be materialized, then encoder intermediate bytes and final Data
may overlap. Wire punctuation and escape bytes are performed writes too when
the relevant accounting owner performs them; a body byte count is not a receipt
for their allocations, copies, ARC/COW operations or lifetime. The remaining
owned-composition design must bind final scalar conversion/publication, distinguish
borrowed spans from created Strings/maps and host encoding, assign every actual
copy/attempt/owner and specify cleanup at failure prefixes. This instrument makes
none of those operations free and supplies no convenient storage-adoption claim.

## Reproduction and limits

Run `task design:application-metadata-wire` after edits settle, then
`task design:application-metadata-wire-check`. Inputs include every saved subject
used, selection/SDL, model/test/mutation tools, this contract, diagram/manifest,
Taskfile, Engine, resolved dependency manifests and exact Swift encoding/error
sources, every GraphQL-js runtime source and the Node executable. Digests precede
the subject/dependency reads and are compared after each derivation/check. Full per-item
rows and hashes are compared, not only totals. Swift dependencies and the existing
client development dependencies must already be present; these tasks execute no
Koine/native code.

Isolated disposable source mutants must fail behavioral assertions for escaping,
keys/punctuation, aliases, fragments, errors, unknown-to-zero, row association,
outside records, cap equality and the Swift replacement path shape. The inherited
subject/reader/ledger/episode/source/root/storage and localized-boundary checks
retain charge/call/branch and original oversize/baseline/omitted-table controls.
Passing pure checks closes no native G/N/V case, useful whole-job fit, family hold
or whole-producer review. Owned composition and all parent close checks stay live.
