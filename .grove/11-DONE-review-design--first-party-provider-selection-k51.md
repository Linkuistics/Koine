# first-party-provider-selection-k51

**Reviews:** first-party-provider-selection-k50


## Goal

Adversarially review the first-party selection contract before launch-and-open
implements it. Find violations of the reserved-identity, explicit-approval,
independent-update, compatibility and no-concealed-failure obligations; produce
findings, not loader changes.



## Context

- The producer commit identified by `first-party-provider-selection-k50`.
- `docs/specs/machine.md#first-party-provider-selection`, composition and trust;
  `docs/specs/workflow-providers.md`, compatibility and selection acceptance.
- `docs/adr/koine-server-and-native-providers.md` and
  `docs/adr/resilient-provider-framework.md`.
- The two selection views in `docs/design/architecture/`, including captions.
- The producer task's goal/done conditions are the contract; the proposed
  algorithm and alternatives are the artifact to challenge.

## Done when

- Check the full candidate decision table, including missing/rejected bundled
  owners, reserved-only slots, untrusted claims, schema/version floors, multiple
  candidates and equal highest releases. Challenge discovery-order independence
  and whether one claimant can evict another outside the intended trust boundary.
- Trace every refusal boundary before and after dlopen; distinguish frozen
  selection, publication, startup and dependency cascades. Challenge paths that
  could load both versions, conceal a failed update, change authority or leave
  diagnostics falsely describing the selected binary.
- Check old/new host and bundle compatibility, canonical ordering/digests,
  additive management fields and exact-provider conformance. Determine whether
  the stated acceptance cases can distinguish policy failures at the three seams.
- Review spec/ADR/diagram/brief consistency and the minimum coherent ADR set.
- If integration is warranted, place it immediately before the launch-and-open
  sibling node under the Grove integration-placement rule, so no consuming
  design or planning runs first. Its charter points to this review's handle.

## Notes

Implementation and acceptance are launch-and-open's work. This review does not
claim the extension is already served. Signing-posture and incompatible desktop
contract changes still require Antony's decision. An absent second real signing
team cannot be replaced with mock acceptance.

## Decisions (running log)

Reviewed producer commit `d4043d4142fa` (`first-party-provider-selection-k50`).
The working copy began as an empty change on it, so there was no drift to
reconcile. Findings only: no production, test, spec, ADR or diagram edits, and no
test, build, lint, render or VM command.

The structure holds: a sealed catalogue independent of discovery, pre-load
selection over both roots, numeric floors, frozen choices with no retry and
per-candidate diagnostics. The findings concern what identity approval admits,
where the policy treats equivalent failures differently, and what the existing
staging and the old host actually do. None argues for a different architecture.
An `integrate-review-design` leaf is warranted immediately before the
launch-and-open node: S1–S5 change what its first slice implements and accepts.
S1 may narrow what an approval record admits, so it goes to Antony before anything
is built on it.

## Findings

Coordinates are at the producer commit; the working copy is identical.
`machine.md` is `docs/specs/machine.md` and `ADR` is
`docs/adr/koine-server-and-native-providers.md`.

### S1 — Any team-signed bundle claiming a reserved pair is an eligible, top-precedence update (high)

The catalogue names release/schema versions and "Koine's Team ID"
(`machine.md:1052-1053`). Per-user approval "authorizes compatible updates of that
identity, not a particular path or binary hash" (`machine.md:1079-1080`;
`ADR:79-81`). Koine's signature check admits any certificate chaining to Apple
with that Team ID in the leaf (`ProviderTrust.swift:128`), development
certificates included. So for a user holding `desktop.approval.json`, the slot
belongs to whichever team-signed `desktop` bundle claims the greatest release.

Koine's own test bundles are such bundles. `seal.sh` signs fixtures with the
production identity (`scripts/signing-env.sh:9`), and a notarized fixture already
exists for VM runs (`scripts/vm-verify-notarized.sh:37-43`). The selection
acceptance needs team-signed desktop/workspace updates at 1.9.0, 1.10.0 and other
releases in signed VMs (`machine.md:1249-1252`).

Consequence: an instrumented, marker-writing or deliberately broken test
`desktop` is indistinguishable from a release. With a high enough release it
outranks every real update until someone removes it. The untrusted-claims defence
does not apply, because the bundle passes every trust check; only the version in
diagnostics hints at it. The ADR rejected hash approval (`ADR:80-81`) without
considering the middle ground of a signing identifier or designated requirement.

Smallest correction: let each enabled catalogue entry name the code-signing
identifier its releases carry, and require per-user updates to match it. Sign
selection fixtures under a distinct identifier that only a test host's catalogue
admits. This tightens an existing check and adds no entitlement, but it narrows
what an approval record admits; raise it with Antony as a trust-contract decision.
Otherwise state the limit and forbid signing fixture updates of reserved
identities with the production identity.

### S2 — A highest-release tie disables the slot, unlike every other pre-load failure (medium)

A refused newest copy falls back, visibly, to the lower eligible copy or the
bundle (`machine.md:1114-1120`). Two eligible copies tied at the highest release
instead select nothing and withhold the bundle and lower copies too
(`machine.md:1104`; `ADR:66`). Both are failed updates detected before any code
loads. Diagnostics already make the fallback non-concealing, so no-concealment
does not explain the difference, and neither the spec nor the ADR gives another
reason.

The tie is also the cheapest failure to produce. A Finder duplicate
(`Desktop copy.koineprovider`) or the same release unpacked twice leaves identical
bytes in two directories, which the spec calls ambiguous (`machine.md:1104`). An
unavailable desktop then removes workspace and every other dependent through the
missing-owner cascade (`machine.md:1030-1034`; acceptance `:1257`).

Smallest correction: treat a tie like any other pre-load refusal. Mark the tied
copies `ambiguous-update`, never load them, and select the next eligible candidate
or the bundle with `selected-with-refusals`. If the harsher rule is intended,
record why in the ADR and add the cascade consequence to the tie row (`:1253`).

### S3 — Staged copies are shared across roots, so the bundle can load an unassessed quarantined copy (medium)

`ProviderStaging` names a copy by the installed directory's basename plus a
content digest that excludes extended attributes, and reuses a copy that already
exists (`ProviderStaging.swift:22-31`, `:51-53`). One staging directory serves
both roots (`KoineServer.swift:102-109`). The bundled desktop is
`Desktop.koineprovider` (`scripts/verify-app.sh:103-105`), and a per-user update
installed from a release will usually carry the same name.

The ordinary update path makes the bytes identical as well:

1. The user installs a downloaded, quarantined `Desktop.koineprovider` 1.1.
2. A later host bundles the same 1.1.
3. The per-user copy is now `equal-to-bundled` and refused.
4. The selected bundle resolves to the staged copy made from the quarantined
   download.

The in-application root skips the Gatekeeper precheck (`ProviderLoader.swift:131`;
`machine.md:1013-1015`), so an unassessed quarantined image reaches `dlopen`. That
risks the startup-holding dialog or late refusal the precheck exists to prevent,
and under no-retry a late refusal leaves desktop unavailable. In the reverse
order, the per-user copy's assessment is silently skipped instead.

Whichever root stages first sets the attribute. That contradicts discovery-order
independence, and the design leaves cross-root staging order open
(`machine.md:1134-1137`, `:1144-1146`). The claim that bundled quarantine "is the
application's" no longer holds for a shared copy.

Smallest correction: include the candidate's origin, or its canonical installed
location, in staging identity so candidates never share a copy. Add an acceptance
case with equal bytes in both roots and a quarantined per-user copy.

### S4 — A pre-extension host loads a per-user desktop update before refusing it (medium)

The old-host row says 0.1.0 "still refuses external desktop replacement"
(`machine.md:1250`). But 0.1.0 verifies an approved team-signed per-user `desktop`,
then calls `dlopen`, constructs its factory and calls `makeProvider()`
(`ProviderLoader.swift:131-135`, `:392-422`). Only afterwards does composition
refuse the reserved identity (`Composition.swift:74-76`, `:412`).

One accident prevents the load. The bundled root loads first
(`AppDelegate.swift:19`) and registers `KoineDesktopProviderFactory`, so an update
reusing that principal name fails `checkPrincipalNameIsFree`
(`ProviderLoader.swift:134`, `:370-373`). The design makes principal names free
between alternatives (`machine.md:1152-1153`). It gives updates no manifest
marker that an older host refuses before load; the row's "new required framework
feature" covers workspace, not a pure desktop update.

Consequence: a desktop update that renames its principal class runs its
initializers and factory on every old host, beside the bundled desktop. That is
the two-version, conflicting-class situation the ADR cites against retry
(`ADR:74-77`), and the row cannot detect it because it observes only the
refusal.

Smallest correction: either require every release of a shipped identity to keep
its manifest principal name, or have first-party manifests declare a host feature
(say `first-party-selection-v1`) that extension hosts supply, so older hosts
refuse the update as `INCOMPATIBLE` before `dlopen`. Either way, the old-host row
should assert no initializer marker for the update.

### S5 — Acceptance assigns no case to a seam, and the in-process seam cannot show "never loads" (medium)

The preamble says the three seams complement one another (`machine.md:1240-1244`)
but assigns no case to any of them. Three problems follow.

- **One shared test process.** The native seam runs many harnesses in one test
  process. Initializer evidence is one process-wide log
  (`ProviderLoaderTests.swift:14-21`). The loader treats a principal class an
  earlier image registered as a collision (`ProviderLoader.swift:370-380`). So a
  bundled→update pair sharing its principal name, the realistic case, is refused as
  `principal-collision` in any later harness. "Bundled copy never loads" and
  "exactly one … marker per slot" (`machine.md:1249`) are then unobservable there.
- **Cases a notarized application cannot produce.** A malformed catalogue and an
  unexpected in-app claimant (`machine.md:1255`, `:1261`) cannot exist in a
  notarized application without breaking its seal. They need a purpose-built
  signed test host, or the native seam alone.
- **Order reversal.** Reversing discovery order (`machine.md:1252`) is a
  candidate-set substitution at the native seam, not something a VM arranges.

Smallest correction: assign each row its seam or seams, require one host process
per selection scenario for marker and principal observations, and name how each
sealed-root case is produced.

### S6 — Updates of different identities can load two versions of shared native code (medium-low)

The workflow spec lets private helpers share mechanics
(`workflow-providers.md:50-51`), and input and menus share one lifecycle design.
With per-identity updates, `input` 1.2 and `menus` 1.0 can each carry a different
version of one Swift module. Both are selected, since they are different
identities. Their classes then register the same runtime names from two images,
and which one the runtime uses is undefined.

The design files this under "the existing trusted-code limitation"
(`machine.md:1155-1156`). But the ADR's case against retry is avoiding
conflicting native class identities (`ADR:76-77`), and the design makes version
skew between first-party bundles a normal state.

Smallest correction: add a publication rule. First-party bundles must not share
Objective-C-visible class names or Swift module names across identities, so a
shared helper is compiled under a bundle-unique module name. Otherwise shared
helpers belong in the host framework, or the risk is stated as an accepted limit.

### S7 — The diagnostics decision table has gaps (low)

Acceptance demands "exact refusal classes", but several rows are unspecified:

- **Tie.** The reason and selection of the withheld bundle and lower copies, and
  the synthetic row's reason (`machine.md:1104`, `:1184-1187`).
- **`missing-bundled`.** When an update fills the slot, the missing bundle has no
  candidate row and no synthetic row exists. A selected update with no competing
  refusal has `reason: null` (`machine.md:1203`), so a packaging defect can hide
  behind a healthy row.
- **Mismatched designated bundle.** A designated bundle that disagrees with its
  catalogue versions (`machine.md:1068-1069`) has no reason code.
- **Ordinary providers.** Their `selection` value is unspecified, as it is for
  providers refused as both-claimed duplicates.
- **The `unknown` sentinel.** `provider: unknown` (`machine.md:1188-1191`) is a
  valid provider identifier (`machine.md:324-325`), so a real provider of that name
  is ambiguous with it; reserve or refuse the name.
- **Types.** `origin` and `selection` are closed vocabularies typed `String`
  (`machine.md:1200-1201`) where the core schema uses an enum for provider state.
  `reason` rightly stays open.

### S8 — Wording that changes outcomes (low)

- **Composition order.** "Shipped-slot order" (`machine.md:1226`) can be read as
  catalogue order (desktop, workspace, input, …), while composition sorts each
  group by identifier (`machine.md:331-336`). Root fields keep composition order
  in the digest (`Composition.swift:111-116`), so the readings give different
  digests once input is enabled. Say "sorted by identifier".
- **Prefix example.** "`Desk` and `DesktopTools` are not alternate claims on
  `Desktop`" (`machine.md:1061`) can be read as permitting them, although the
  sentence before refuses them. Say "are refused alone".
- **Catalogue Team ID.** "Koine's Team ID" in the catalogue (`machine.md:1053`)
  conflicts with the baseline, which derives the bundled approval Team ID from the
  running host's own signature (`AppDelegate.swift:44-54`). A build signed under
  `KOINE_SIGNING_IDENTITY` by another team, as the open-source distribution allows,
  would meet an "internally conflicting" catalogue and lose every provider
  (`machine.md:1073-1075`). Say the catalogue uses the host's own Team ID, and state
  what an unsigned development run does.
- **Collision ownership.** "The Machine core owns … collision handling"
  (`machine.md:1137`) contradicts the loader's pre-load identifier/prefix check
  (`machine.md:1145-1146`).

### S9 — Less-covered policy edges (low)

- **Pre-load collisions.** The check (`machine.md:1145-1146`) does not say whether
  pre-load-refused non-reserved candidates contest. In the baseline, unapproved,
  unsigned or incompatible bundles never reach composition
  (`KoineServer.swift:111-129`) and cannot evict. "Untrusted claims cannot affect
  another candidate" (`machine.md:1084-1085`) sits only in the reserved-identity
  subsection; extend it to ordinary collisions.
- **Principal conflicts between shipped selections.** These "refuse the affected
  selections" (`machine.md:1150-1152`), so a per-user update of one identity can
  evict another identity's healthy bundled selection and its dependents.
  Non-reserved and post-load reserved-name claimants are refused alone. Refusing
  only the per-user side of a bundled/per-user conflict would match that stance.
- **Determinism.** Selection is deterministic only given each candidate's
  verdicts. The online, 30-second-bounded quarantine assessment
  (`machine.md:997-1001`) can vary across restarts, moving a slot between an
  update, a lower copy and (with S2) nothing. Every candidate is staged and
  verified before any load, so startup cost grows with superseded copies. State
  both.

### S10 — ADR and glossary shape (low)

- **Where the decision sits.** The selection decision lives in the server ADR's
  Trade-off section. Its Decision section still says compatible releases "can be
  upgraded independently" (`ADR:11-13`), and `ADR:57-58` says a first-party
  provider "can be upgraded without the host", unqualified for the served baseline.
  The record now carries two independent calls: a standalone server with one
  loader, and update selection. Put the selection decision in Decision, or split it
  into its own slug-named record and fix the citations. Either way it needs S2's
  rationale.
- **Grove vocabulary.** "A task whose existing approval is identity-based"
  (`ADR:103`) leaks grove vocabulary.
- **Glossary.** The **Provider** entry still promises independent upgrades without
  qualification (`CONTEXT.md:60-63`).

### Checked and accepted

- **Reservation.** The catalogue does not depend on discovery, reserved-only slots
  cannot load, and exact-pair claims generalise the baseline's desktop-only guard
  (`Composition.swift:408-413`). Missing, rejected and reserved-only owners stay
  reserved. Accepted, subject to S8.
- **Pre-load ordering.** The producer's source claim holds: the baseline calls
  `dlopen` for every approved bundle, root by root, before composition refuses
  duplicates (`KoineServer.swift:107-129`; `ProviderLoader.swift:76-84`,
  `:131-135`). Moving selection ahead of loading effects is necessary for the
  no-two-versions goal. Accepted, subject to S3, S4 and S6.
- **Version floors.** Numeric triples, a strict release floor, the same schema
  major, no schema regression, `REJECTED` for malformed versions and
  `INCOMPATIBLE` for honest incompatibility are coherent. Untrusted claims cannot
  create a tie. Order reversal and aliases are covered.
- **After the choice is frozen.** No retry, images left mapped, and start failure
  keeping the schema while rejection cascades agree with `machine.md:880-889`,
  `:970-973` and `:422-435`. Grants stay tied to identity.
- **Digests and conformance.** A replacement takes the shipped position and origin
  stays out of the SDL, so same-content replacement keeps its digest; the position
  matters because root field order is part of the digest. The stale
  order-independence comment in `CanonicalSDL.swift:18-19` is an implementation
  note for launch-and-open, not a design defect. Profiles pin candidates
  separately from the digest, as they must.
- **Management fields.** Nullable additions keep old queries valid. Mixed rows for
  one identity already occur in the baseline (bundled desktop `ACTIVE`, per-user
  desktop `REJECTED`), so reusing `REJECTED` for superseded copies adds no new
  class of ambiguity. The UI's `ForEach(..., id: \.provider)`
  (`StatusView.swift:96`) already assumes one row per provider, and the spec
  rightly requires grouping.
- **Consistency.** The root brief, launch-and-open node and design leaf, workflow
  spec, README, both ADRs and glossary cite the new section. The search for stale
  "selection pending" wording found nothing live, and the same search finds that
  wording in the pre-producer `machine.md` and in a finished leaf, so the clean
  result is evidence. Both views agree with the spec on tie, freeze, rejection
  versus startup failure, and management survival, and their SVG exports contain the
  current source labels.

### Review evidence and limits

Read directly:

- the producer's diff and running log;
- the complete new section, and the composition, loading/trust and
  additional-capability sections of `machine.md`;
- both ADRs, the workflow-spec changes, glossary, README and Taskfile task;
- both diagram sources and captions;
- the cited Swift sources, test support and scripts.

Tier-2 `check_index_coverage` at generation `2026-09-29T10:36:20Z` recorded no
issue for any cited Swift file. Each code claim rests on a direct read, not on
graph absence. Docs are excluded from the index and were read directly.

S6's duplicate-class behaviour and S3's Gatekeeper outcome for an unassessed
quarantined image are platform reasoning, not observations. The integration or
launch-and-open's native evidence should confirm them. No browser, test, build or
VM run was made; narrow and dark rendering remain unexercised, as the producer
recorded.
