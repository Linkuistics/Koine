# First-party provider selection

The workflow extension reserves shipped identities in a sealed host catalogue
and selects each identity's approved compatible candidate before loading any
provider code. It chooses the highest unambiguous per-user release above the
bundled baseline, otherwise the verified bundle. Tied highest release groups
are refused visibly and removed before considering lower releases. Choices
freeze before principal checks and loading; subsequent failure never retries
another candidate in that process. The
[Machine contract](../specs/machine.md#first-party-provider-selection) defines
the complete policy and diagnostics. This is designed extension behavior;
Koine 0.1.0 does not support replacing its shipped desktop provider.

Reservation survives missing or rejected bundles. A replacement occupies the
same identifier-sorted shipped composition position regardless of physical
origin. Candidate-specific staging keeps verification and quarantine attached
to the copy that will load. Newly published first-party updates declare the
selection feature so old hosts refuse them before running initializers, even
when principal names change. Independently updated provider identities publish
disjoint native module/class names, or use a single host-supplied shared image.

The loader owns installation policy and immutable candidate reports; the core
retains independent schema/authority validation and lifecycle. Callers supply
roots once, rather than choosing files or reconstructing the loading protocol.
The cost is a sealed catalogue and explicit diagnostics for every refused copy,
including missing packaged bundles even when an update runs.

## Trade-offs and alternatives

Pre-load refusal, including ambiguity, can select a lower eligible release while
showing what failed. Disabling a healthy bundled slot because the same update
was installed twice buys no additional trust: neither tied image will run.
Path-based tie-breaking would instead hide an ambiguous installation. Once a
choice is frozen, retrying would risk executing two versions' initializers and
registering conflicting native identities; that availability cost lasts until
the installed set is repaired and Koine restarted.

Shipped selections are equal slot owners, whether bundled or per-user. A
principal-name collision refuses both and can remove their authority dependents;
preferring the bundled side would make physical origin an authority tie-breaker
after selection. Publication discipline limits accidental conflicts, but native
providers remain trusted code in one process. Stronger runtime isolation or
fallback requires a different process/restart design.

**Always prefer the bundle or reject every duplicate** prevents independent
updates of shipped identities. Reopen only if independent updates are no longer
required. Binary compatibility alone cannot supply the host's selection feature.

**A pinned candidate/version manager** could resolve duplicate versions or
enforce rollback policy, but adds mutable installation state and repair
operations. No highest-seen-version store is maintained: the sealed host baseline
is the floor, not anti-rollback across host releases. Revisit if intentional
pinning or cross-restart rollback protection becomes a requirement.

The existing provider-ID/Team-ID approval is additionally bounded by the release
code-signing identifier sealed into the catalogue. Fixture identifiers are
distinct and admitted only by test catalogues: team-wide signing alone cannot
make a test build a shipped update. This narrows the approval contract without
new entitlements or certificate-class restrictions. It does not defend against
a trusted publisher deliberately signing code under the release identifier.
Per-update hash approval would add an approval operation to every compatible
release; a stable signing identifier separates publication identities without
that cost. Online verification verdicts
can vary between restarts; selection is deterministic for fixed verdicts, and
startup verification cost grows with installed candidates. Neither persistent
verdicts nor a total startup deadline is promised.
