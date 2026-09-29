# callback-publication-legacy-comparison-k227

## Goal
The detached legacy CLI comparison section: exact projection of retained app
rows to the unchanged analyzer command boundary, captured in full and admitted
under max_comparison_bytes.

## Context
publication-replay.md "Detached legacy CLI comparison" and the "Existing
producer families and migration" dispatch table.

## Done when
- Projection writes the manifest `producer` object unchanged and every non-null
  embedded producer of all physically retained app rows in owner then
  observation order (faults, tail rows and duplicates included, supervisor
  and excluded rows omitted) to `case.json`/`trace.jsonl` in an isolated
  directory; projection hashes, interpreter/analyzer identity, command and cwd
  convention are recorded.
- A pinned-interpreter `-I -S` subprocess runs parse_manifest → parse_records →
  analyze → main post-processing; stdout/stderr bytes, parsed result and exit
  are preserved. Setup/launch failure is a comparison infrastructure error,
  never an empty trace; uncaught failure is reported as comparison failure.
- R19 in full: V11 fallback fields/marker encoding/scope, V12–V25 without V11
  slice flags, V26 frozen, schema/size failure and multi-defect precedence
  fixtures; kill direct-analyze comparison, map-only projection, version
  widening and startup partial_history dispatch.
- Capture keeps at most 262,144 stdout and 65,536 stderr bytes, stored as
  padded base64 beside the parsed result and metadata. Difference records are
  charged to the report, not the comparison.
- The parsed result is archived as legacy's own stdout JSON text, spliced
  verbatim when it is ASCII strict JSON, otherwise null with its reason. It is
  never re-serialized. Only stdout is parsed. Before `json.loads`, the parse
  charges 49×len(stdout)+65,536 against the reserved 12,910,592-byte allowance
  of profile `/2`. Parsed objects are released at the end of stage 6 and never
  outlive encoding. The census's 21-shape parse battery, run through this
  parse function, stays at or below the model.
- Comparison capture is charged before growth; exhaustion yields
  incomplete-resource with comparison incomplete (R31 comparison variant),
  never a normalized partial legacy result.
- The optional frozen base fixture/report identity is a second labelled
  artifact, never a substitute for projection.

## Notes
Difference labels need successor claims and belong to k239.
