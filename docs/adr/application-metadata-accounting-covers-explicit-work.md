# Application metadata accounting covers explicit work

Application metadata admission uses a scoped explicit-work guarantee. Its
20,971,520-byte cumulative gross gate charges application-controlled raw
requested allocations and every performed source-level raw initialization,
input read, copy and field/owner write. Reuse, disposal and cancellation refund
nothing. Its 4,194,304-attempt gate charges explicit adapter, local and native
operations, including explicit cleanup, retains, releases and comparisons.
Pre-call reservation includes one complete terminal guard evaluation, including
refusal arithmetic, clocks, liveness and bookkeeping. Admitted checks charge their
work while retaining that credit; the first refusal or final return consumes it.
Sticky freeze permits no further optional evaluation. Unknown guard operands refuse
bootstrap, never become free work. The [guarded construction](../specs/application-metadata-private-qualification.md#pre-call-admission-and-actual-return-settlement)
owns the exact protocol and failure/cleanup reserves.

Compiler-generated ownership traffic and internal platform/Swift constructor,
bridge, copy-on-write, metadata and allocator work are excluded from these
numeric guards. Explicitly issuing a call or performing a charged raw operation
still costs its own attempt or bytes; excluding the callee's internal work
does not exclude the caller's explicit work. Excluded costs are disclosed as
outside the guarantee, rather than represented as known zero costs.

Publication through ProviderValue remains provider-owned. Its Swift runtime
backing is excluded from the numeric guards; it is neither moved to host
accounting nor certified by the independent 8 MiB response-body cap. This
decision promises no total provider heap, cumulative hidden-copy gross,
runtime-attempt, RSS or peak bound. Controlled conversion scratch, raw writes,
explicit publication calls and their ownership/cleanup remain accounted under
the selected scope.

This boundary preserves the existing public and binary interface and useful
application breadth while making controlled capacity and performed-work
admission derivable. The [runtime admission analysis](../specs/application-metadata-runtime-admission.md#evidence-and-incompatibility)
identifies why portable ABI/value layout and comparative Swift source do not
supply a complete upper for each deployed runtime implementation. Retaining
strict all-owned pre-call accounting would require implementation-specific
source/image/toolchain correspondence and complete uppers, with useful discovery
refused on unqualified combinations. No such attainable certificate is currently
supplied. Reconsider strict accounting only with a concrete certification route;
a larger budget alone supplies no missing upper. An ABI extension requires its
own decision.

Full explicit-work fit still requires a complete design and declared finite
input assumptions; this selection establishes neither fit nor native
acceptance. Existing deadlines, true-return slots, response cap, source and
locale breadth, authority, actions, disclosure, Settings, compatibility and
public/binary/isolated signed-VM test seams remain binding.
