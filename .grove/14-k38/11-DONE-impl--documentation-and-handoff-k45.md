# documentation-and-handoff-k45

## Goal

Make the documentation describe the Koine that now exists — nothing still
reading as unbuilt or partly built, every acceptance obligation either marked
established with its evidence or explicitly still open — and hand ModalAnyware a
contract version it can target, with the changes its owner has to make.

## Context

- The spec's "Client handoff" states what ModalAnyware must do: target
  `koine-desktop/1`, capture the process incarnation at interaction start,
  preserve opaque references through configuration and effects, store its own
  credential, map capability denial separately from Koine OS-consent guidance,
  and distinguish a missing process from a stale selected window and from an
  unknown mutation outcome. Its public TypeScript facade may keep convenience
  operations as client adapters, not as a second wire contract.
- **Koine sessions do not edit ModalAnyware.** That repository is local-only
  (no GitHub remote), and its own grove has a live `acceptance-k23` planning
  leaf. The handoff is a note delivered to its owner.
- Stale text known to exist today, and certainly not all of it:
  - `docs/specs/machine.md` line 6: "it does not claim that Koine is implemented
    or its platform behavior has been verified."
  - `README.md`'s status paragraph, written increment by increment — "The first
    increment is built… The second increment is built too… the desktop path has
    begun".
  - `docs/design/architecture/README.md`: "The viewer is currently served at
    <http://127.0.0.1:8772/#discussion> **by this design session**", and
    `README.md`'s link to that local URL as though it were live.
  - The spec's "Scope and agreement": "Platform behavior and native binary
    compatibility remain release acceptance obligations."
- The evidence base to cite: everything under `docs/verification/`, including
  the documents this stage's earlier leaves added.
- **`contract-only-client-k41`'s findings are already written down and ranked.**
  `docs/verification/contract-only-client.md` ranks the eight that cost the most;
  `docs/verification/contract-only-client-gaps.md` is the author's own unedited
  record of all of them, and is evidence rather than prose to be tidied — it is
  a stranger's account of reading Koine's documents, and re-writing it for tone
  would destroy the one thing in it that cannot be reproduced. Most of those
  findings are about **Koine's own spec**, not only about what ModalAnyware's
  owner needs to be told.

## Done when

- **Nothing in `README.md`, `docs/specs/machine.md` or
  `docs/design/architecture/` describes Koine as unbuilt, partly built, or
  mid-design.** The README's incremental status narrative becomes a description
  of what Koine does; the spec's opening disclaimer and its "Scope and
  agreement" closing sentence are replaced by what is now established.
- **Every acceptance obligation the spec lists is resolved in the text**, each
  one either:
  - marked **established**, naming the evidence document that establishes it; or
  - marked **still open**, saying so plainly.
  Enumerate the obligations from the spec's own acceptance table and closing
  paragraphs rather than from a list written here — the table is the claim's
  scope, and a list goes stale.
- **Every finding `contract-only-client-k41` recorded is settled**, each one
  either repaired in `docs/specs/machine.md` (or the schema's descriptions) or
  explicitly declined with a reason. The sharpest is the first: the contract
  demands a process start instant with six fractional second digits and names no
  macOS source for one, which is why that client compiles a C helper at runtime.
  Deciding it needs the human — state the instant's source, or state that the
  comparison is tolerant — and until it is settled a TypeScript client cannot
  resolve a running application by documented means alone.
- **A contract-version statement exists** on Koine's side: which version a
  client targets (`koine-desktop/1`), the `Koine.schemaDigest` it was generated
  against, how a client verifies it is talking to a compatible Koine, and what
  changes would change the digest without changing the contract.
- **The ModalAnyware handoff note is written and delivered to its owner** — the
  required changes from the spec's "Client handoff", plus the gaps
  `contract-only-client-k41` found, which are the part its owner cannot get from
  the spec. It goes to the human, since that repository has no issue tracker to
  file against; do not edit ModalAnyware.
- The architecture views' README no longer speaks in the voice of the design
  session that wrote it, and the README does not point a reader at a local URL
  that nobody is serving.

## Notes

**This is a sweep, and a sweep is where the scope silently narrows**
(`references/execute.md`). Three narrowings to avoid, each of which has passed
for done before: grep the **claim**, not a file list written before the work;
remember that a path scope never reaches files in no tree at all — a root
`README.md`, a dotfile; and a fix to a section does not reach the **summary**
layer, so when a stale claim is found in a section, sweep the abstract, the
table and the overview too. Enumerate every candidate and classify each; do not
sweep a list of phrases and call the list complete.

**Do not document a claim with a count of itself.** "Three places say Koine is
unbuilt" invalidates itself the moment the sentence is written down. State the
structural fact.

**A clause rescued by its neighbour is not correct.** The spec's disclaimers
often pair a false clause with a true one; check whether the true half only
reads as true in the false half's company before deleting either.

**Being honest about what is still open is the deliverable, not a failure.**
Several things are deliberately out of scope and should be *stated* rather than
quietly dropped: the back-deployment and x86_64 items dissolved by the narrowed
matrix (`support-matrix-and-latency-k44`), the provider install and trust-renewal
UI with its library-validation entitlement (`native-provider-contribution-k8`
deferred both with the human; the root brief's "On the horizon" says what that UI
must produce), a second real signing identity, and the user comparing the
enrollment code. A reader should finish the documents knowing exactly what has
not been proven.

**This leaf runs before `homebrew-distribution-k46` on purpose**: the next leaf
makes this repository public, and a public README that says Koine is partly built
is the version the world reads first.

## Decisions (running log)

- **Finding 1, the process start instant: not settled by stating it.** Put to
  the human with three answers (state the `proc_pidinfo` source and keep the
  exact comparison, recommended; make the comparison tolerant; add a Koine
  lookup). They rejected time as an identity altogether: "Anything that depends
  on time is inherently problematic. You cannot guarantee non-collision,
  especially given multi-core machines. I would prefer some mechanism other than
  time." The public SDK was read for a non-time per-pid incarnation and has none
  (`PROC_PIDUNIQIDENTIFIERINFO` is not in the public `proc_info.h`;
  `audit_token_to_pidversion` needs a token for that task), so the choice is
  design work. Asked where it goes, they chose a design leaf and its impl
  **before** the release: `process-identity-without-time-k51` and `-k52`,
  inserted ahead of `homebrew-distribution-k46`. Here, finding 1 is marked open
  and points at k51; the rest of this leaf proceeds.
- **Schema-side repairs are declined for `koine-desktop/1`; prose repairs are
  made.** The human chose "prose now, decline schema": an example or
  `@specifiedBy` on the scalars, an enum for `extensions.kind`, a distinct kind
  for caller-fixable enrollment outcomes, an outcome marker on deadline errors and
  anonymous `availableCapabilities` each move the digest or change behaviour
  after the release evidence was taken. Each is declined with its reason in the
  spec; the spec's prose carries the repair. (k51/k52 will move the digest anyway;
  that is its own decision and does not reopen these.)
- **The handoff is a generic client guide, not a ModalAnyware note.** Asked where
  the note should live, the human answered: "This should not be modalanyware
  specific - we should have documentation that the ModalAnyware dev (a grove
  process) can read without being specific." So the deliverable is a Koine
  client guide in this repository — contract version, compatibility check, and
  everything a client author needs that the contract-only client had to guess —
  and the human is pointed at it to pass to ModalAnyware's grove.
- **The leaf's one in-session review was spent on `docs/client-guide.md`**
  against the source, since it is what outside clients build from and its claims
  are behavioural. Eleven findings, all valid, all actionable, none a defect in
  Koine: an error's `path` is always encoded, empty when it belongs to no field,
  so "no `path`" was wrong in the guide, the spec and the settlement table; a 400
  can have no body; the enrollment digest is of the decoded bytes; anonymous
  enrollment can be 400 (variable coercion) or 429 (budget spent before
  validation); `phase: execution` also covers a mutation action revoked after
  preflight; a `failed` error at an action's path is not only a provider step; a
  403 can be `failed` on a store failure; the conformance query is not verbatim
  `getIntrospectionQuery`; the schema's own description is not digested; expired
  requests are status-only too; an enrollment retry can meet 429 or, past
  retention, `credential-in-use`. All repaired in place; no second review needed,
  since each repair restates what the reviewer cited from the code.
