# long-pathname-applications-k139


## Goal

Research how real applications handle long pathnames in practice across several
use cases and platforms. Follow their representation and operations through the
whole workflow, including process/API handoffs. Find reusable mechanisms and
their actual limits for the retained Koine requirement; do not assume the
tested macOS opener failure settles the wider question.

## Context

Antony retained the original requirement: "retain the original requirement -
invoke research processes to see how other applications deal with this problem."
He clarified: "Specifically how long pathnames are dealt with. This must occur
for other use cases and contexts."

Read the ancestor briefs, `docs/verification/long-action-route.md`,
`docs/verification/long-action-route-prototype.md` and
`docs/verification/long-action-native-boundary.md` for the Koine question,
measurements and exclusions. `docs/research/prior-art-long-paths-a.md` is a
lead catalogue, not a conclusion to corroborate. The native prototype found
component-relative local access working while tested long classification,
registration, handler and original-path submissions failed or stayed unmeasured.
That is neither universal impossibility nor permission to drop working cases.

Koine still requires roughly 1,500-byte ordinary-file default/Zed opening and
Finder reveal, constrained long-app launch/named open for the exact selected
registered copy, unchanged supplied locations, native facts/cause provenance,
truthful receipts and short-workflow regressions. No shortening, alternate copy,
identity-spelled submission, private entitlement/policy, new consent, guessed
metadata or systematic length-caused null receipt is authorized.

## Done when

- Deliver this kind's independently sourced survey as
  `docs/research/long-pathname-applications-a.md` for research-a or
  `docs/research/long-pathname-applications-b.md` for research-b, using the
  Grove research citation/provenance discipline. Survey breadth and real
  application behavior, not only OS API documentation or the previous survey.
- Cover these use-case families with a bounded selection of concrete systems:
  file managers/editors/document launch; build/package/repository tools;
  archive/copy/backup/sync; and remote or virtual namespaces/protocol handoff.
  Seek macOS, Linux/POSIX and Windows contrasts. Record source silence or an
  unavailable representative instead of inventing coverage. Do not force a
  catalogue of every named product.
- For each system, trace a normal and an over-limit pathname through actual
  source/documented behavior: ingress, internal representation, traversal,
  metadata, external boundary and consumer. Separate accepted/stored/displayed
  names from successful filesystem operations and downstream delivery.
  Identify where a full string is reconstructed. Record concrete failure,
  refusal or shortening as carefully as successful over-limit handling.
- Investigate full strings, component sequences, cwd-relative/dirfd traversal,
  retained handles, bookmarks/IDs, virtual mappings and name rewriting where
  real systems use them. Explain which limit each removes or merely moves.
  Distinguish within-process I/O from cooperating process transfer and arbitrary
  third-party opener integration. Include actual receiver behavior where sourced.
- State units and boundary conditions: bytes versus characters/UTF-16 units,
  terminator inclusion, per-component versus whole/expanded path, library versus
  kernel versus argv/protocol limit, and platform/version/configuration.
  Follow symlink/dot/trailing-separator and identity/race behavior where material;
  do not infer successful long paths merely from a large allocation or API name.
- Anchor load-bearing claims to official documentation, pinned implementation
  source/tests or primary maintainer issue discussions. Separate normative
  promises, observed test evidence and inference. Each system gets a walk-away
  conclusion, failure limits and unanswered questions. Do not run a new native
  probe or treat an existing diagnostic submission as passing an action row.
- End with a comparison of mechanisms, applicability to Koine and remaining
  evidence gaps. Mark excluded mechanisms as requiring a new human decision,
  not an adopted repair. Name promising supported leads and bounded next
  questions without promising success or concluding universal impossibility.
  No production route or requirement change is selected by a survey.

## Notes

Both research leaves receive this identical brief and investigate independently.
Do not read the other survey or consult it for coverage/conclusions. Neither
survey is the adversarial pass; the separate combine-research leaf owns that
move, contradictions and source-correlation checks. Reuse the earlier survey
only as leads and verify the primary evidence afresh.

This commission authorizes one pair and its synthesis, read-only public/source
research and durable survey artifacts. It authorizes no code changes, new
native experiment or automatic further evidence chain. The returned design
consumes the synthesis before route selection. Keep the original requirement
and all mandatory review/acceptance obligations intact.

## Decisions (running log)

- Adopt the mandated research-b leaf and preserve the identical commission's
  retained working cases and exclusions. Read the ancestor briefs, glossary,
  cited ADRs and bounded native evidence; do not read survey A. No native probe,
  production change, route selection or new task chain belongs to this survey.
- The codebase-memory CLI refuses startup because a pre-coordination or
  unverified generation is active. No project/generation/coverage result is
  available. Use bounded document reads and pinned public implementation source
  without codebase completeness claims. The existing Taskfile owns document checks.
- Select a bounded corpus spanning Zed's cooperating CLI/editor, Nautilus/GIO
  launch and local traversal, CMake/Ninja generated paths and compiler handoff,
  GNU tar archive creation/extraction, restic backup/restore, Robocopy and OpenSSH
  SFTP. Follow representation through each consumer, labelling documented
  promises, source-derived behavior, historical reports and unresolved outcomes.
- CotEditor 5.0.0 supplies an additional real macOS bookmark/restoration workflow:
  security-scoped blobs resolve back to URLs, reachability and document reads.
  This establishes application usage, not long-path success or permission to
  change consent. Preserve failed-restoration and long-support uncertainty.
- Deliver the independent source-backed survey in the mandated `-b.md` path.
  Separate Zed's small-launch/IPC transfer from whole-path receiver I/O, GNU tar
  creation from extraction, restic's repaired Windows metadata regression from
  its POSIX whole-path backend, generated-name shortening from unchanged source
  locations, and protocol handles from initial OPEN/reconstructed metadata.
  Source tests/reporter follow-ups are evidence at their stated boundaries;
  no complete Koine route, universal impossibility or accepted loss is inferred.
- Final `task check:docs` passed. All 79 documentation, diagram-manifest,
  Taskfile and check-script subjects matched their frozen SHA-256 values
  item-by-item before/after; all 49 survey reference labels are defined. Checked
  the GNU release-source archive digest and corrected the recorded value to the
  actual downloaded bytes. These checks establish documentation integrity,
  not external/native action acceptance.
- The survey satisfies this research leaf's bounded families, operation/receiver
  traces, unit distinctions, walk-away conclusions, citation/evidence levels,
  silences and Koine comparison. Retire only k139; k140 synthesis and k141
  returned design stay live, so no route-node close, ADR selection or final
  producer review is earned here.
