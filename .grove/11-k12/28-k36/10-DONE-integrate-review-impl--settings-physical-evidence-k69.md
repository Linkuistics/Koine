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

## Decisions (running log)

- 2026-10-29: Adopt the mandated integration on empty jj change kpsptllo,
  parent bfa2342d. Read k68's findings from bfa2342d, not from this leaf's
  restatement. The graph CLI refuses before project/generation discovery with
  the pre-coordination/unverified-generation error. Use bounded source reads;
  stop no other CBM session and claim no graph coverage.
- 2026-10-29: P3-1 is a real retention issue. Both verifiers source the common
  library, which loads pointer and resize helpers; each loads the physical
  facade, which loads the shell adapter facade. Add both facades to both
  unconditional SUBJECTS arrays. Include the older missing resize helper at
  the same boundary. The Python backend is called only when a facade function
  runs; these verifiers do not invoke that lane. Its omission is retained for
  that reason. This bounded repair is not a full audit of the older verifiers.
- 2026-10-29: H-1 is a real handoff gap. A clean resize-down-N can be followed
  by termination during its settling sleep, with no failed receipt or latch.
  Report and k57 must treat that receipt without a later clean resize-release
  as held input, and preserve failed/partial held-point uncertainty too. K66
  owns controls for signals at a held point and between clean attempts; no
  physical-helper runtime or signal implementation belongs to this integration.
- 2026-10-29: Use a reusable Taskfile syntax/shellcheck task for the two changed
  verifier scripts. The changes are declarative subject-list additions and
  handoff text, with no new transport behavior or test seam. Retain pre-edit
  digests and frozen verification before/after digests. No in-session reviewer
  or VM is needed for these source-derived findings; later harness review and
  all k66/k67/k62/k57/k54 duties remain live.
- 2026-10-29: The new syntax/shellcheck task and bounded array checks pass;
  initial verification subjects remain byte-identical during the run.
  check:docs returns Task 201 because the archived initial context charter's
  two relative targets are missing. Its SHA-256 equals parent bfa2342d and jj
  file list confirms both targets absent there. Existing live
  settings-archive-links-k23 owns this exact gap, so add no duplicate leaf and
  alter no measured archive bytes. Retain the first verification, disclose the
  known failure in the report, then verify the final report and subjects.
- 2026-10-29: Final check:vm-latency-installations is 0; both unconditional
  arrays include each of the four named physical/shell-adapter libraries once.
  Final check:docs remains 201 with only the two existing k23 target failures.
  The final before/after manifests compare item by item with status 0; outputs,
  pre-edit digests and both verification attempts are retained under
  docs/verification/settings-activation/ordering-physical-evidence/k69.
  P3-1 and H-1 are repaired at their chartered boundaries. Retire only k69:
  k66/k67 remain live in its parent, so no parent closes and no Creator line is
  due for a finished producer review. No new review is earned by these bounded
  list/text corrections. All runtime holds survive.
