# native-observation-request-decoding-k97


## Goal

Resolve the add/remove header literals, NDR bytes and target-side request
decoders on the pinned 25F71 image, producing a checked wire specification or
an exact unresolved link. No AX request is sent in this investigation.



## Context

Read the k93 layout dossier and preserved scans under
`docs/verification/native-observation/`. Use the existing read-only receiver
inspector in a disposable TestAnyware clone. Static symbol absence is not
runtime failure or evidence that the native mechanism is impossible.

## Done when

- Freeze the query, scanner/tool identities and platform before each read.
  Read the actual request constants; identify the matching server dispatch and
  decoders by exact symbols/addresses, preserving raw bytes and control results.
- Reconcile field offsets, length/disposition checks, argument handoff and
  structural failure/reply construction against the existing dossier. Separate
  decoder-enforced facts from scalar/flag/requester semantics owned by k98.
- Record precisely which connection, authentication, cleanup and runtime
  premises still prevent an owned exchange; pass those to k98/k99 without
  guessing values or granting permission to send. Update the wire view.

## Notes

This is the first independently verifiable preflight slice of k94. The original
live add/delivery/remove and witness/control obligations remain in its children.

## Decisions (running log)

- Pinned reads resolve actual add/remove IDs, NDR bytes and matching server
  dispatch/decoders. Record their checks and argument handoff as a static wire
  specification in `docs/verification/native-observation-requests.md`. The
  decoder's audit-field reads exceed its visible minimum trailer-size guard;
  require the full owned receive envelope, not that guard alone. No native
  authentication, connection-policy or window-lifetime claim follows.

## Verification

The native scanner runs, host/guest subject hashes, exact dispatch/NDR pointer
checks and deterministic decode task passed. One independent bounded byte
review found no material error. The updated wire view rendered and its Safari
deep link, discussion/outline/updated markers and light/dark narrow appearance
were inspected in the disposable VM. k98/k99 retain every remaining k94
preflight and runtime obligation; no parent closes and no ADR decision changed.
