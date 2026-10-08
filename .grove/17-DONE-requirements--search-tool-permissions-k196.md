# search-tool-permissions-k196

## Goal

Record Antony's revised ownership boundary: raw filesystem search belongs to
clients; Koine supplies special starting locations and native metadata discovery.
Settle the required discovery surface and test expectations, then externalize the
returned design/review that reconciles the former search mechanism and mixed
downstream obligations before implementation.

## Context

The running log records the original system-tool permissions interview and
Antony's ownership revision. Read the reviewed search-tooling-k195 contract and
k198 integration as the previous proposal, not as a requirement to preserve raw
search. Existing native application metadata and launch/open/reveal contracts
remain relevant; client-owned traversal does not imply Koine consent/setup or
filesystem access for a remote client. Reuse the agreed G/N/V seams. No backend
or native experiment belongs to this requirements leaf.

## Done when

- Record the revised client/raw-search and Koine/native-discovery boundary in
  durable requirements. Distinguish returning starting locations from inspecting
  or enumerating those locations; paths grant no filesystem access or OS consent.
- Settle whether metadata discovery is named native catalogues or a general
  metadata-query API, and the initial required categories. Preserve useful app
  discovery/metadata and existing explicit selection actions without silently
  substituting an OS-reported partial list for an exhaustive all-disk inventory.
- Retain prompt-free Koine reads, honest available/empty/blocked/unknown outcomes,
  independent native facts and ordinary-query no-dialog/no-hydration acceptance.
  Identify which earlier permissions remain applicable to individual native
  targets without treating them as a reason to keep a raw-search backend.
- Agree test expectations through the existing public GraphQL, actual native
  binary and isolated signed-host VM seams. Client-owned traversal, its ordering,
  budget and consent are client responsibilities; native catalogue/location and
  actual-selection acceptance stay Koine obligations.
- Externalize focused returned design before the existing search node, with
  mandatory review before consumption. It reconciles spec/API/guide/glossary/
  trace/views and every mixed live charter, preserving relevant native/binary/
  action obligations. No leaf is pruned or credited as passed by guess.
- Verify the reconciled requirements and immediate handoff on frozen inputs;
  retire this human-revised requirements leaf and seal its focused jj change.

## Notes

This human revision replaces the original permission-interview deliverable; it
does not select an inventory backend or complete native discovery acceptance.
No code, backend subprocess, VM, consent or signing work. The returned design
must precede app-and-file-search-k7 and its existing mixed design/review chain.

## Decisions (running log)

- Adopt the mandated requirements leaf in the authoritative jj workspace, empty
  on search-tooling-k198's integration commit f6e0c27d. Read the glossary, root
  brief, reviewed mechanism, integration decisions and prior k115/k190 human
  answers. The graph CLI refused an active pre-coordination/unverified generation;
  current document reads provide the evidence, with no graph coverage or native
  acceptance claim. Taskfile.yml is the existing reusable-check entry point.
- Four open choices have interdependent answers: process permission selects the
  backend posture that protection, ordering and dataless handling must satisfy.
  Use the focused one-question-at-a-time requirements interview, starting with
  process permission. Earlier helper refusal and OS/tool reuse are settled inputs,
  not permissions to infer. No design commitment or tree growth precedes the
  human's confirmation of shared understanding.
- Process permission: Antony selected "Allow built-in find (Recommended)".
  Permit the proposed fixed Apple-signed /usr/bin/find child, one live/unreaped
  child per admitted job and at most four process-wide, with no shell, custom or
  privileged helper, distribution/signing/entitlement/usage-key, consent or
  RLIMIT change. The presented cancellation contract sends TERM, then KILL after
  250 ms if still owned, retaining capacity through actual reap/native return.
  Blocked child/native work may retain all slots indefinitely; abrupt Koine death
  may leave a blocked orphan without a lifetime bound. This answers the distinct
  system-command proposal without approving k115's declined custom helper or
  proving native behavior. Target lookup/protection, ordering and dataless policy
  remain separate unanswered choices.
- Lookup-only identification: Antony selected "Allow bounded lookup-only
  identification (Recommended)". Search may reuse the existing bounded
  component-relative location resolution for individual roots, known policy
  targets and application targets, using search-only directory lookup and
  metadata without directory listing or file-content reads. This permits target
  identity acquisition, not a new custom traversal/witness engine, consent/setup
  operation or target-listing exemption. Metadata contact/blocking remains
  possible; actual signed-host no-dialog/no-hydration acceptance is required.
  Unknown aliases and relocation/replacement protection limits remain the next
  separate question.
- Protection policy: Antony answered "accepted." to excluding known protected
  targets while acknowledging unrecognized cloud aliases, mid-search relocation/
  replacement races and metadata contact before prune/device refusal. Retain
  known-target exclusions across established aliases: Documents redirecting to
  Work excludes Work under either name while unrelated home folders remain
  searchable. k191 must qualify known case/NFC/NFD/Data-root aliases; literal
  path patterns alone are not identity protection. Protected/package anchors and
  foreign mounts may receive metadata contact before refusal. This accepts the
  stated platform protection limit, not a prompting/hydrating ordinary query,
  systematic all-home refusal, new setup/domain/backend or actual workflow loss.
  Signed dialog/hydration controls and useful-home witnesses remain required;
  k93 separately decides actual measured omissions. If the selected backend
  cannot satisfy this known-target contract, return the specific gap to design
  rather than silently weakening it.
- Antony revised the ownership direction before answering home ordering:
  "I am now thinking that we should completely leave raw search up to the client,
  and not have it as a koine feature. Koine should return special locations to
  search *from* or metadata-based searches (e.g. all apps, all preference panels
  etc)." Treat this as steering the active requirements leaf, not as acceptance
  of the pending shallow-pass proposal. Establish the intended boundary and
  finite native discovery scope before reconciling the durable requirement and
  returned design. Earlier find/lookup/protection permissions do not require
  retaining a raw-search feature, and no existing search leaf is pruned by
  inference.
- Native discovery surface: Antony answered "I agree - for v1" to the
  recommendation for named native catalogues and special-location lookup, rather
  than a general OS metadata-query API. For v1, clients own raw traversal,
  filtering/ranking and their filesystem permissions; Koine supplies the agreed
  named native categories, with honest availability/completeness and existing
  explicit selection actions. General metadata queries are outside v1, not
  rejected forever. Initial category semantics and test expectations remain to
  be made concrete before the returned design.
- Compatibility scope: Antony answered the preference-panel question with
  "we only need to be compatible with MacOS 26+". The repository already
  declares macOS 26+ on Apple Silicon in the Machine contract and macOS 26 in
  SwiftPM. Carry that floor into this workstream and design the preference
  catalogue around modern System Settings. No older-OS or legacy .prefPane
  compatibility programme is required; supported destinations exposed on macOS
  26+ are not excluded merely because of their implementation. The returned
  design must establish actual native discoverability and make any useful-
  category gap explicit, without inventing an inventory.
- The revised boundary no longer needs Koine's raw-search ordering answer.
  The original dataless-policy question was never answered, and no shallow pass,
  process-wide OFF pin or raw-search coverage loss is approved by omission.
  Catalogue mechanisms and their own prompt/materialization policy belong to
  returned design within the unchanged prompt-free/no-hydration requirement.
  Remaining compatibility clarification and the seam check fall below the
  full-grilling threshold; do not continue the former raw-search interview.
- Test expectations and shared scope: Antony selected "Agree with these
  acceptance expectations (Recommended)". Reuse GraphQL for special locations,
  named application/settings catalogues, authorization/revocation and honest
  empty/blocked/unavailable/incomplete/unknown observations; actual provider/host
  binaries for metadata, loader compatibility and existing action authority;
  signed macOS 26+ VMs for actual starting locations, configured launchers plus
  Safari/Finder, modern System Settings destinations and independent dialog/
  hydration controls. Returned choices need the appropriate explicit actions;
  unavailable native subjects stay pending. Clients own raw-search permissions,
  ordering and coverage; a location value supplies no filesystem access. Shared
  understanding is now confirmed for the v1 boundary and its three test seams.

- Reconcile the durable ownership requirement/ADR, relevant native identity/fact/
  coverage/prompt principles, guide/glossary and Machine/workflow summaries to
  the agreed boundary. Retain the former raw spec/SDL and eight architecture
  views explicitly as comparison until returned design replaces them; update
  the ownership view and current manifest. Preserve historical citation anchors
  while naming the moved current ownership record.
- Reconcile the root and mixed k7/k19/k126/k191/k193/k127/k123/k120/k30/k93
  charters to retained native obligations before their consumers run. No raw
  ordering/dataless answer, new catalogue child, global policy or useful-category
  loss is inferred, and no live item is pruned or credited as native-passed.
- Review judgment: the ownership and test expectations are explicit human
  decisions; this requirements leaf selects no native API/backend. Native source,
  payload, resource/authority and compatibility choices need a focused returned
  native-discovery design and mandatory fresh review before k7. Externalize that
  producer as the last substantive work; its reviewed handoff completes the
  mixed-charter/API reconciliation before implementation.

## Verification

- D2 0.9.0: task design:search-render passed for the ownership sketch and eight
  comparison views. SHA-256 before/after compared Taskfile.yml and each of
  docs/design/architecture/search-{discovery,preopen,canonical,resources,
  inspection,serviceability,traversal,coverage,handoff}.d2; all ten inputs stayed
  unchanged. All nine SVG outputs were hashed and inspected via rasterized
  1,200-pixel views for labels, layout and clipping.
- task check:docs rejected a temporary missing-target and missing-anchor control,
  then passed after that control was removed. Before/after records compared
  every checker.sources() document/manifest, Taskfile.yml, scripts/check-doc-links.py
  and every resolved local target: 112 scanned sources / 411 final records,
  unchanged per item. The controlled failing run likewise kept its inputs frozen.
  Inventories/output hashes are local .build/k196-verification artifacts.
- The manifest parses, its diagram IDs are unique and the discussion resolves
  the ownership sketch plus eight labelled prior-proposal sources/exports.
  Requirements, guide, Machine/trace summaries and mixed charter diffs were
  reviewed against the human agreement. These are document/design checks,
  not a new catalogue SDL, native binary or signed-VM acceptance pass.

- Externalized native-discovery-k199 immediately before app-and-file-search-k7;
  the CLI shifted later root siblings mechanically. Its full charter requires
  actual native source/API and mixed-artifact reconciliation plus mandatory
  review-design/earned integration before k7. No review is fabricated for an
  unfinished producer, and existing k193/k120 stay with their retained producers.
