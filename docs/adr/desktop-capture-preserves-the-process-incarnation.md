# Desktop capture preserves the process incarnation

The desktop target is the frontmost application captured by the client's native
event handler when the callback executes. Its non-time identity denotes that OS
process incarnation and expires when the process ends or exec invalidates its
held identity. Restoring the logical application does not keep a capture alive.
Koine never substitutes a later foreground application or a new process under an
old capture. A delayed callback after an app switch captures the new foreground
application; a switch after capture leaves that capture unchanged. Fresh sampling,
its linearization point and attribution to the held identity still need evidence.

## Endpoint addressing is the effect boundary

The agreed future effect contract is **endpoint addressing only**. Koine
attributes an endpoint's responder to the captured process at admission,
continuously retains the actual endpoint, and sends target AX operations through
it. Koine never reacquires or rebinds a destination under the old capture.
Capture and reference expiry remain strict; the effect guarantee does not extend
to permanent receiver ownership, descriptor interpretation or downstream work.
The [machine spec](../specs/machine.md#native-targeting-discussion) defines refusal,
uncertainty and the client-visible focus-attempt meaning.

This explicitly permits effects on another window or process, including a
restored successor, through receive-right movement, descriptor reuse, forwarding
or queued activation. A live-identity check before a send cannot atomically
exclude death during that send or execution of accepted work afterward. Neither
reply authentication nor a post-check undoes an effect. The contract promises
Koine's unchanged address, not delivery to a permanently captured receiver or an
end-to-end no-substitute effect. A client must see that weaker meaning in the
public operation and its introspection descriptions before the replacement ships.

This is the accepted trade-off for keeping arbitrary application behavior out of
Koine's unconditional guarantee. A maintained application/descriptor support
profile was considered instead: exact code membership alone cannot attest mutable
handlers, receiver ownership or downstream lifetimes, and no qualifying profile
has been established. Keeping the original strict effect requirement would leave
the same feasibility conflict unresolved. Either alternative can be reconsidered
if a concrete enforceable profile or stronger native primitive establishes the
needed lifetime properties; an app name, Cocoa classification or OS allowlist
alone is insufficient.

## What the evidence establishes

The [source survey](../research/native-process-bound-effects-a.md#the-gap-map)
found no complete strict binding in its bounded scope. Its
[dispatch analysis](../research/native-process-bound-effects-a.md#1-binding-an-effect-acquisition-attribution-dispatch-downstream)
separates a retained port object from the task owning its movable receive right;
[loaded callbacks](../verification/ax-top-level-routing.md#registered-callbacks-and-descriptor-ownership)
show dynamic target dispatch and downstream activation. These premises motivate
the weaker contract; they are not evidence that the relaxed contract is implemented.

PSN plus boot identity remains rejected for capture: the
[restoration counterexample](../verification/process-serial-lifetime.md) retains
the pair while the OS process changes. Public held AX objects and private token/
data reconstruction remain excluded as endpoint bindings: the
[actual PID-recycling experiments](../verification/retained-ax-binding.md)
show successor effects without a fresh acquisition by the holder. Merely holding
those wrappers or adding another task check does not demonstrate that Koine
retains the same native destination.

The investigated direct endpoint is still **not adopted as a shipping mechanism**.
Its [audited read and same-endpoint effects](../verification/direct-ax-endpoint.md)
provide bounded responder-authentication and transport evidence, including refusal
after tested death, actual PID reuse and exec. The strict end-to-end promise for
which it was declined remains unestablished; that is now an excluded promise,
not an implicit proof obligation for the chosen addressing boundary. The existing
endpoint is a candidate for evaluation against this revised contract after design
review. No new native observation follows from the scope decision.

The separate window-qualified activation route addresses a different service
using logical application/window identifiers. It is outside the agreed
same-endpoint operation path; it is neither a fallback nor a required proof of
an effect guarantee the contract no longer makes. Reopening that route requires
an explicit change to the addressing boundary and a concrete benefit to justify
its native evidence work.

## What remains unresolved

Public client APIs, client-owned adapters, Koine-owned Accessibility consent and
no injection, helper or target cooperation remain required. Native capture,
actual right transfer, discovery/authentication, reference grammar/non-reuse,
restart semantics and prepublication version framing remain to be agreed.

[AX contact inhibited automatic termination](../verification/ax-automatic-restoration.md)
on the tested target after the reader exited. The weaker effect promise does not
approve that lifecycle consequence. Its duration/release and product policy still
need evidence and agreement; nontermination is not a passing restoration test.
Separate Koine consent, denial/revocation and notarized private-path launch are
also untested. Prior public-AX acceptance does not establish private-path policy.

Any future private adapter must own bounded local resources, cleanup, cancellation
uncertainty and exact-version refusal inside the desktop provider. The
[adoption synthesis](../verification/ax-endpoint-adoption.md) separates these
remaining obligations from the excluded guarantees. Internal entry points and an
owned wire encoder both impose recurring OS verification costs. The approved
private-adapter support set is empty. The served timestamp mechanism remains
explicitly awaiting replacement and is not approved for the first public release.
