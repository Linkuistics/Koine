# contract-only-client-k41

## Goal

Prove the handoff claim by exercising it: a client written from the **documented
contract alone** — endpoint descriptor, bearer header, the operations in
`docs/design/desktop-operations.graphql`, and types generated from introspection
— obtains a grant and runs the whole discover, list, focus path against the
notarized application, knowing nothing of Koine's internals.

## Context

- The spec's "Client handoff": "No Koine-owned Swift client library is required
  in the first deliverable: standard GraphQL tooling plus a small client-owned
  adapter covers endpoint discovery, Keychain storage, authorization headers and
  error classification." That is a claim about what a stranger can do, and
  nothing has tested it.
- `docs/design/desktop-operations.graphql` holds the client's view. The spec's
  acceptance row requires that "generated desktop operations validate and run
  with only the documented contract".
- Two complete clients already exist and are **the wrong shape for this leaf**:
  `scripts/vm-verify-desktop-client.py` and
  `scripts/vm-verify-enrollment-client.py` were written by sessions that could
  read the source. They are the pattern for surviving TestAnyware's false 30s
  timeouts, and that is what to take from them.
- The endpoint descriptor and grant protocol are in the spec's "Local transport
  and discovery" and "Grants and management".

## Done when

- **A client exists that was built from the documents**, using standard GraphQL
  tooling and a schema fetched by introspection — not from `Sources/`, not from
  the design SDL file in this repository, and not by copying an existing
  verification script's Koine-specific knowledge.
- **It runs the whole path in a VM** against the notarized build: obtain a grant
  (one of the two workflows), read the endpoint descriptor to find where to
  connect, present the bearer credential, resolve a running application, list
  its windows, and focus a chosen one — with the window reference passed back
  unchanged, as the spec's addressing rule requires.
- **The five documented operations validate against the introspected schema**
  and run unmodified. Any operation in `desktop-operations.graphql` that does
  not is a finding against the contract, not something to edit in passing.
- **The gaps a stranger would fall into are written down** — each place the
  client needed something the documents do not state, or state in a way that
  misleads. Those are the handoff's real content and feed
  `documentation-and-handoff-k45`; a leaf that finds none should say so and be
  believed only if it genuinely never consulted the source.
- Error classification is exercised, not just the happy path: at minimum a
  capability denial and an OS-permission error, distinguished by the client from
  ordinary absence, as ModalAnyware will have to.
- `docs/verification/contract-only-client.md` records the run and the gaps.

## Notes

**The discipline is the deliverable.** The value of this leaf is entirely in
*not* reading the implementation, and it is trivially and invisibly lost — one
glance at a resolver to settle an ambiguity turns the client into another
insider's client and the whole exercise into theatre. Work from
`docs/specs/machine.md`, `docs/design/*.graphql` and the introspection response;
when something is ambiguous, **record the ambiguity and guess**, because the
guess is the finding. If the session cannot proceed without reading source, that
too is a finding: write down what forced it before reading.

**A subagent with a clean context is the honest way to do this**, given the same
documents and no repository access beyond them. That spends the picked leaf's
one in-session reviewer allowance (`references/execute.md`) — it is the right
thing to spend it on, and there is then no second pass available.

**Language choice is open**, but prefer one with real GraphQL codegen so
"standard tooling" is actually standard, and note that ModalAnyware is
TypeScript-fronted — a TypeScript client makes the gaps found here directly
useful to its owner.

**Host rule**: the client talks to a running Koine, so it runs in a VM. Use
`guest_json` and the `ask` pattern for guest reads that survive TestAnyware's
bursts of false timeouts, and remember that a step which reads state only after
acting cannot fail (`desktop-focus-vm.md`).

## Decisions (running log)

**The client is TypeScript, and it is written by a subagent that has four
documents and nothing else.** The sandbox it works in holds
`docs/specs/machine.md`, `docs/design/desktop-operations.graphql`,
`docs/adr/bearer-grants-and-live-revocation.md` and one captured introspection
response; it has no path into this repository at all, so the discipline is a
property of what it can reach rather than of what it was asked not to read.
`docs/design/desktop-schema.graphql` is **withheld** — "Done when" says the
schema must come from introspection, not from the design SDL — while the
operations file is handed over, because the contract names it as the client's
view. TypeScript because ModalAnyware is TypeScript-fronted, so a gap found here
lands on the client that has to live with it, and because `graphql-codegen`
makes "standard tooling" literal. This spends the leaf's one in-session reviewer
allowance (`references/execute.md`); there is no second pass.

**The schema the client generates against is a capture of the bundle under
test.** `.build/conformance/introspection.json` is the response the notarized
0.1.0 bundle gave in `schema-conformance-k40`'s run, whose
`Koine.schemaDigest` is `ee17dfd1…`. The run then re-introspects in the guest
and makes the client compare the served digest with the one it generated
against — which is exactly what the spec's "Schema digest" says a client does
with that value, so the comparison is part of the contract being exercised
rather than a test fixture.

**Node is not in the golden image, so the run carries its own.** The guest has
`python3` and `curl` and no `node`; it does have network. The host downloads one
pinned Node tarball, checks it against Apple-independent published SHASUMS, and
uploads it, so the VM run does not depend on nodejs.org being reachable at run
time. The client is bundled to one dependency-free `.mjs` file on the host, so
nothing is installed in the guest.

**The author's gap record is kept verbatim, as evidence rather than as prose to
be tidied.** `docs/verification/contract-only-client-gaps.md` is the stranger's
own account, 614 lines of it, with a header saying why a later session must not
edit it for tone: it is the one artifact in this leaf that cannot be reproduced,
because reproducing it would need another author who has not read the source.
`docs/verification/contract-only-client.md` is the run, and ranks the findings
that `documentation-and-handoff-k45` has to act on.

**The client generates against the published operations file itself, not a
copy.** `clients/contract-only/codegen.ts` reads
`../../docs/design/desktop-operations.graphql`, so there is no second copy to
drift and no drift check to write; `capture/` keeps the introspection response
and the digest it was generated against, because that capture is the *other*
input and `.build/` does not survive. The validation was watched going red
before it was believed: `nonsenseField` inserted into the published operations
failed generation with "Cannot query field \"nonsenseField\" on type
\"DesktopWindow\"", and the file is byte-identical again (`c3d2a827…`).

**The findings are routed, not absorbed.** Every one of them is about the
*documents*, and the node brief's rule is that an acceptance failure belongs to
the stage that owns it rather than to this one. `documentation-and-handoff-k45`
already had to carry these gaps into the ModalAnyware note; its Context now
names both files and its "Done when" gains the clause that matters — each
finding is repaired in the spec or explicitly declined. The sharpest, the
process start instant with no named macOS source, is flagged there as needing
the human, because "state the source" and "state that the comparison is
tolerant" are different contracts and a session should not pick between them.

**A harness lesson worth more than this leaf.** The first run failed clicking
Approve for the second grant: `testanyware agent snapshot` reads a window's
accessibility tree *through* whatever covers it, so the label and comparison
code verified correctly while the click at those screen coordinates landed in
TextEdit. Nothing in the answer distinguishes a covered window from a present
one. Any click driven from a snapshot must raise its window first; the first
approval only worked because no application windows were open yet.
