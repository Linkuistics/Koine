# settings-physical-evidence-k69

**Integrates:** settings-physical-evidence-k68

## Goal

Triage the k68 review of the k65 physical-helper migration. Apply the real
findings to the subject lists, the report and the handoffs. Finish before k66
consumes the physical helpers.

## Context

Read the findings in the k68 leaf at its review commit. Their line numbers
refer to the k65 producer commit 759ef19c. Then read
`scripts/vm-physical-evidence-lib.sh`, `scripts/vm-window-resize-lib.sh`,
`scripts/vm-verify-latency.sh`, `scripts/vm-verify-installations.sh` and
`docs/verification/settings-activation/ORDERING-PHYSICAL-RESULTS.md`. Read the
k66 and k57 task files and the parent brief chain.

The review read the TestAnyware v2.7.0 tag in the local checkout at
`../TestAnyware`. It ran no test, build, guest or reviewer. The graph CLI
refused with a pre-coordination error, so the review read the sources
directly. K65 supplies no complete scenario migration, VM, signed subject or
acceptance. This integration supplies none either.

## Done when

- Each k68 finding has a recorded disposition with its reason, read from the
  review's own commit.
- For P3-1, the frozen subject lists name every file that the pointer helper
  loads, or the leaf records why one stays out.
- For H-1, the report and the k57 handoff state how receipts show held input
  after a signal between clean attempts. K66 carries the held-point signal
  control as part of its signal work.
- Each changed check passes through its Taskfile task. Before/after digests of
  the changed subjects are retained.

## Notes

No VM, signed subject, freeze, slot or native acceptance is chartered. K66,
k67, k62, k57 and k54 stay open. The whole-harness review still precedes
runtime.
