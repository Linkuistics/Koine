# Shipped application metadata counterexample

Read-only remeasurement for application-localized-metadata-k214 on macOS 26.6.2
(25G83). The [per-item manifest](../design/application-localized-baseline.json)
records selected information/loctable byte sizes and SHA-256, root identities,
direct-entry/localization counts and inventory digests. All records and the fixed
query path set matched on before/after reads; the measurement instrument's digest
also matched. This is shipped-file design evidence, not a Koine call-path, timing,
parser-peak, permission or native G/N/V pass.

The exact indexed predicate was `kMDItemContentTypeTree ==
'com.apple.application-bundle'`. Contents were read only for returned checked
`.app` directories under `/System`, plus the named Unarchiver witness. No home,
external-volume or other third-party contents were read. The narrower system
subject contains 290 directories. Another 35 `/System` query paths are outside
that directory subject (recorded explicitly, including `.ds` files). The review's
325-item count is not adopted as a bundle count. The smaller independently
checked subject is already enough to reproduce its sizing and format defects;
it is no exhaustive supported-VM baseline or P1024 manifest.

| Measured dimension | Value |
| --- | ---: |
| System information-file input, excluding all name files | 934,207 bytes |
| Direct checked `.lproj` directories | 10,794 |
| Raw direct resource entries | 14,721 |
| System bundles with `InfoPlist.loctable` | 247 |
| Maximum loctable size | 103,197 bytes |
| Loctables exceeding the proposed 65,536-byte file gate | 10 |
| System bundles with any planned `.strings` file | 2 |
| The Unarchiver information file | 83,346 bytes |

The Unarchiver is an actual fixed-query result. Its information file exceeds the
proposed per-file gate. The current text's individual-refusal and global-failure
readings disagree; neither is a useful accepted result for this witness.
The system information files plus this one useful witness total 1,017,553 bytes,
already above the proposed 1,000,000 aggregate input assumption without any name
files, repetitions or controlled fixture additions.

At the old full cardinality envelope, substituting **only this smaller system
subject's** input and retained-localization dimensions gives
`6,816,128 + 934,207 + 10,794 × 128 = 9,131,967` gross bytes, above 8,388,608.
This is a subtotal of the proposed certificate using its fixed 128-byte
localization reservation, not measured allocation or a lower bound on actual
component-copy bytes. This 290-app sample does not itself incur every old
full-envelope record term. Name files, repeated reads and the controlled P1024
additions have not been added. The old 4,096-localization assumption is already
refuted; the complete required finite subject needs an independent measured
manifest before a replacement certificate can be derived.

FindMy's information dictionary names `FindMy`, but its loctable's English value
is `Find My`; VoiceMemos similarly differs from `Voice Memos`. German values are
`Wo ist?` and `Sprachmemos`. These locale-keyed binary plists are absent from the
proposed reader file set. Their measured bytes are evidence of the missing
format, not approval to parse it or a proof of current private Bundle precedence.

Pure CF selector measurements on literal arrays reproduce the positional
backstop: `[ar,de,fr,it,ja]` with `[en-AU,en]` selects `ar`; moving the observed
development region `it` first selects `it`. The same reordered array with `[de]`
still selects `de`. No target pathname, Bundle lookup, launch or consent is
involved. R4's repair explicitly orders the backstop; actual language/layout
qualification stays pending.

Application-localized-metadata-k215 owns the coupled file-format/sizing/accounting
redesign and mandatory review before k7. The recommendation is to preserve the
required useful category, support measured loctable names through an explicit
target-local plan, and first attempt a sound construction under existing owned
and core response gates. A sizing, format or accounting choice outside the
existing approval must be presented to Antony with the complete measured subject
and a concrete alternative before adoption. No filtering, new posture or larger
gate is selected by this evidence.
