# reference-evidence-native-types-k254

## Goal

Implement a byte-only native decoder with complete type-ID export and reproducible
independent CF format/type/duplicate/coercion qualification.

## Context

Consume replay-k250's actual schema and verifier. Use CFPropertyListCreateWithData
on immutable bytes with format/error outputs; the durable design requires no
plutil/plistlib normalization, foreign Bundle lookup or target pathname.

## Work and verification

1. Freeze independently authored XML, binary and OpenStep/.strings payloads and
expected native observations, encoding/BOM/header facts and duplicate-key positions.
Include malformed/unsupported/unavailable cases; parser rejection without support
must retain unestablished format/validity rather than inventing malformed input.
2. Create standalone Tools/ReferenceEvidence/Package.swift, NativeDecoder.swift,
a byte-input/output decoder entry and package tests. No root Package.swift,
Koine/provider dependency or signing posture change is needed. Keep the public
input immutable bytes; use the selected closed tagged schema as its result.
3. Traverse all values using CFGetTypeID, CFBoolean before numbers; export CFString
as exact big-endian UTF-16 code units, CFData bytes, arrays in order and dictionary
entry arrays in observed order. Do not bridge through normalized language maps.
4. Export exact CFNumber storage type/byte size/integer-or-real branch. Integers
need successful exact conversion and reconstruction; wider/lossy values remain
incomplete. Reals retain IEEE bits for signed zero, infinities and NaNs. Dates
retain binary64 absolute-time bits and 2001 epoch. Qualify these observations
without asserting preservation of original lexical widths/order/NaN payloads.
5. Record actual source/build/compiler/SDK/OS and acquisition/decoder executable
digests and obtainable loaded-runtime images. Unavailable identity is a gap;
changed images invalidate proof. Qualify serialized duplicates independently for
each admitted format with observed surviving entries/coercion limits.
6. Add task evidence:reference-decoder-check: build/test the isolated tool, invoke
the separate verifier on the frozen specimens and run prior replay checks.
Retain per-item positives/intended negatives and complete before/after digests.

## Done when

A usable original-byte decoder emits schema-valid complete trees or exact typed
failures without altering original payloads. Every admitted format/type/encoding/
duplicate branch has independent actual proof; required unqualified branches remain
named work before k244 closure. Document the image-bound qualification boundary.

## Notes

Do not read installed app files or invoke mdfind. Actual decoded bytes are pure
fixtures. No SDK/source declaration alone proves runtime acceptance or identity.
