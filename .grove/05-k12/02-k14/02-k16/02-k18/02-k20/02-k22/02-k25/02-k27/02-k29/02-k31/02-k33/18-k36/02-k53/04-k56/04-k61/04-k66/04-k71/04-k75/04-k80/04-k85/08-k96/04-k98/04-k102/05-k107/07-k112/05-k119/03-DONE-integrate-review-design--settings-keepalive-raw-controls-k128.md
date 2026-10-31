# settings-keepalive-raw-controls-k128

**Integrates:** settings-keepalive-raw-controls-k127

## Goal
Triage the k127 review of the k122 raw-output control design. Apply the real
findings to the design document and to the documents it changed. Do this before
settings-keepalive-recovery-controls-k123 consumes the design.

## Context
Read the findings in the k127 review leaf and its commit. The reviewed artifact
is commit 716caad9. The design is
docs/verification/settings-activation/KEEPALIVE-RAW-CONTROLS.md with its
owner-spec link, the qualification proposal's R rows and the raw-output view.
Grade each finding against the k122 charter and the k119 brief chain. Grade it
also against the owner spec, the producer contract, the record schema and the
qualification proposal. No in-session reviewer ran in k122 or k127.

## Done when
- Classify each k127 finding as real, a visible trade-off, an unclear contract
  or noise, with a reason.
- Apply each real finding inside the design document and the documents it
  touches. Where a finding changes an R obligation's coverage, reconcile the
  qualification proposal's R rows to the same coverage.
- Keep every approved substitution as approved. Add no collector site,
  replacement collector, second raw writer, allocator seam or production
  injection. Preserve the exact R3 and R5 scope and its separate audit.
- Present any loss of an original R obligation to Antony as an explicit choice
  with costs. Infer no relaxation.
- Adopt no numerical capacity, queue bound, storage result or mechanism result.
  Keep every prerequisite and the complete-profile duties live in k119 and the
  parents.
- Record each disposition in the edited documents or this leaf. Check the
  edited documents and views. Retire only this leaf.

## Notes
The integration owns corrections and all post-correction document checks. It
may spend one narrow in-session reviewer. A redesign of the collector mechanism
or a new control class is a new producer and review chain beside this leaf, not
an inline change. No coordinator or native control runs.

## Decisions (running log)

- 2026-11-01: Adopt k128 from clean parent fb86d64d. Read k127's findings from that commit against producer commit 716caad9.
  Use the mandated jj interface and Tier 2 graph coverage, with direct reads for these document contracts.
  Convert the qualification proposal's existing prose findings separately in be88a75e before substantive edits.
- 2026-11-01: P1-1 is real. The absent-executable fixture exercises backend setup refusal, not loader output.
  Fix its detection point, zero invocations, empty originals and absent process/EOF facts.
  Keep actual loader output as an additional open R obligation in k125's existing evidence scope and k126's reconciliation.
  No requirement is removed, and no native subject is adopted.
- 2026-11-01: P2-1 and P2-2 are real. Entry telemetry proves neither blocked execution nor accepted bytes from a killed write.
  Specify return/release classification and an independent remainder-count oracle.
  Keep the observation route unavailable pending k125's reviewed design. No extra collector seam is inferred.
  Only established blocking tests release deadlock. Only known accepted counts test complete retention.
- 2026-11-01: P2-3 is an unclear contract. Count sentinel invocations by scenario class and submission identity.
  Preserve applicable real collection transitions through separately identified synthetic CLI fixtures and their own accounting.
  Missing fixtures or ownership stay unavailable, without suppressing the collection path.
- 2026-11-01: P2-4 and P2-5 are real. Require raw-clean exact-limit EOF rows and explicit excess retention lengths.
  Make the inherited-holder row retain exactly 4096 stdout bytes while its child holds both descriptors.
  Distinguish eligible bytes from the retained first excess and tail. The requested total becomes 69,634 bytes.
- 2026-11-01: P3-1 is real. Replace constant bytes with declared position-dependent stream fixtures.
  Compare exact offsets and retain fixture digests. The source-copy audit remains necessary.
- 2026-11-01: P3-2 is an unclear contract. Select real containment of the recorded cooperating child after deadline expiry.
  Require reap, descriptor closure and the single remainder drain. Missing ownership stays unavailable.
  Preserve the separate unresolved-holder controls in the expanded S design.
- 2026-11-01: P3-3 is an unclear contract. Require production persistence after each nonempty read, before another raw read.
  R4 observes those actual writes. R5 targets the same first data write without adding a collector site.
  A first read shorter than 1024 bytes still leaves the prefix substitution unavailable.
- 2026-11-01: P3-4 is real. Restore the documented default viewer port and label the general graph edge with collector reading.
  Keep R3's special release rule in its caption. Reconcile the summaries with the remaining loader and R3 obligations.
  No change meets the three-part ADR test. These are corrections to reversible control-design contracts.
- 2026-11-01: Spend the one narrow reviewer on counterexample schedules for the byte, EOF and invocation oracles.
  Its one P2 finding is an unclear ownership contract: the backend cannot reap its emitter's orphaned helper.
  Apply the owner's existing actual-parent rule. Separate emitter reap, qualified helper-exit evidence, descriptor closure and EOF.
  An unavailable helper-exit route keeps resolved containment unavailable. No adopting process or new collector site is selected.
  This correction restates the authoritative ownership boundary. It requires no second reviewer or redesigned mechanism.
- 2026-11-01: Check the revised documents and diagram after all substantive edits.
  The prose checker reports zero hard findings. The 17 case identities match the original inventory.
  Per-case arithmetic gives 69,634 requested bytes and the unchanged 8,912,896-byte base raw extent envelope.
  The document task returns 201 and names only the two existing k23 archive targets.
  All 207 measured input hashes match before and after. The integration receipt retains the exact paths and output.
  Chrome shows the final general read edge, sentinel identity, open-coverage caption, outline and current marker.
  Default port 8765 returns an empty reply, so verification uses the Taskfile's PORT=8821 override without changing the documented default.
  Mobile and dark appearance remain unchecked. No coordinator or native control runs.
- 2026-11-01: Final graph coverage reports changed metadata and partial Mermaid coverage at lines 1–28.
  Use current direct document reads and the complete Mermaid source for those paths. Make no graph completeness claim.
  Retire only k128. K123 through k126 remain live, so no parent closes.
