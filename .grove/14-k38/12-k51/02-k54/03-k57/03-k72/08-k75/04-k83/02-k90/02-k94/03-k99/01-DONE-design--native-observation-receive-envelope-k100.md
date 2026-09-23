# native-observation-receive-envelope-k100


## Goal
Establish the bounded native receive-source and envelope ownership contract
needed before k99's owned exchange, with exact static evidence and explicit
runtime prerequisites.



## Context
Consume the request, connection and layout reports under docs/verification.
Inspect the native source creation/dispatch and post callback on the pinned
25F71 image, reusing the existing read-only inspector in a disposable VM.

## Done when
- Freeze inputs and platform identity; inspect source context, receive options,
  dispatch, reply construction and every cleanup branch claimed, with exact
  function boundaries. Distinguish the native wrapper from the owned contract.
- Specify complete audit-trailer validation, sender comparison ordering,
  bounded inline/OOL handling and one envelope owner, including success,
  rejection and unsupported receive outcomes. Cite primary kernel/userland
  semantics for destruction rather than inferring ownership from status names.
- Name unresolved voucher/context, source-chain and runtime accounting
  prerequisites precisely. Update the existing view and evidence reports.
  No AX request or closure schedule runs in this static slice.

## Notes
The second child retains every native exchange/control and k94 reconciliation
criterion. This slice establishes no native policy acceptance, event provenance,
window lifetime, publication barrier or complete stream.

## Decisions (running log)

- Pinned native receive helpers request an AV trailer and adopt a received
  voucher; HIServices overwrites the trailer context with its observer pointer.
  Keep source authentication and execution context explicit in the owned loop.
  Native callbacks are comparison evidence, not the receiver implementation.
- The post handler's success-path OOL unmap and dispatcher's rejection-path
  destruction must not be combined with a second envelope release. Use one
  envelope owner and a borrowing decoder. A post-receive OOL cap does not bound
  kernel acquisition; actual receive errors, all exposed descriptor cleanup,
  acquired-memory bounds and voucher context remain preflight for k101.
