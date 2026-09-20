# grant-workflow-acceptance-k43

## Goal

Run both agreed grant workflows end to end against the **notarized** build, and
drive the three things `grant-enrollment-vm.md` explicitly did not: a refusal
shown in the window, several requests pending at once, and revoking an enrolled
grant through the window.

## Context

- `docs/verification/grant-enrollment-vm.md`, "What this does not show" — this
  leaf's checklist, and the reason it is a leaf rather than a paragraph of
  `platform-acceptance-k42`:
  - **A refusal shown in the window.** `KoineManagementClientTests` shows the
    client surfacing `already-decided` with `DENIED` and `EXPIRED`,
    `invalid-subset` and an unknown request, but "the sentence the window
    composes from them, and its re-read of the lists afterwards, were not seen
    in a VM".
  - **Several requests pending together** — "At most one was pending at a time,
    so the window's layout with many, and scrolling to reach one, were not
    driven."
  - **Revocation of an enrolled grant** through the window, and the secret's 401
    after it — covered by `GrantEnrollmentTests`, not repeated in a VM.
- The spec's "Public GraphQL management" acceptance row: both workflows persist
  across restart; a pending requester cannot approve itself, enumerate others or
  use provider operations; revoked credentials fail on an existing keep-alive
  connection and after restart; a store or commit failure never reports a
  successful durable approval or revocation; lost manual-secret delivery
  requires revoke and recreate.
- `task app:vm-verify-enrollment` and `scripts/vm-verify-enrollment.sh` are the
  existing route; `scripts/vm-verify-enrollment-client.py` is a complete
  enrolling client and the pattern for a guest mutation that survives the
  agent's repeated execs.

## Done when

- **Both workflows run against the notarized build**: a user-created grant
  handed to a script, and a client that enrols itself and is approved in the
  window — the latter still with no credential typed, pasted or shown.
- **A refusal is seen in the window.** Force `already-decided` by deciding the
  same request over GraphQL between the window's poll and the click, and assert
  the sentence the window composes and its re-read of both lists afterwards.
  This is a race the earlier script declined to run; `OrderingHook` and the
  polled `ManagementClient.status()` are the means.
- **Several requests pending together**: enough simultaneous pending requests to
  drive the window's layout with many and to require scrolling to reach one,
  staying inside the pending cap (16) and the enrollment rate limit (10/minute)
  — or deliberately crossing one and asserting `pending-request-limit` and HTTP
  429 with `Retry-After`, which no VM run has yet seen.
- **An enrolled grant is revoked through the window**, and its secret gets 401
  afterwards — on an existing keep-alive connection and after a restart.
- **Persistence across restart** for both workflows, and a pending requester
  shown unable to approve itself, list others, or use provider operations.
- `docs/verification/grant-workflow-acceptance-vm.md` records it, and says which
  items of `grant-enrollment-vm.md`'s "does not show" list are now closed and
  which remain open with why.

## Notes

**Two platform facts from the earlier enrollment run still bind**, and both cost
a debugging session to find: a SwiftUI confirmation whose action carries the
destructive role has **no default button** on macOS 26.5, so Return decides
nothing and the click must be real; and a grant's capabilities are served as a
**sorted set**, so scripts compare them sorted.

**"The user compares the code" stays out of scope.** `grant-enrollment-vm.md`
records that the run shows the window's code equals the client's receipt, and
that a client which displays it and a person who looks are outside it. That
remains true here — do not claim otherwise.

**Expiry and retention need a clock the VM does not have.** They are covered by
`GrantRequestLifetimeTests` with `Harness(clock:)` and are not this leaf's to
re-prove in a VM; the pending cap and the rate limit, by contrast, need only
volume and **are** drivable here, which is why they are listed above.

**A store or commit failure never reporting success** is a public-seam property
already held by `RevocationOrderingTests`' scripted `GrantStore`. Cite it; do not
try to induce a store failure in a VM.

**Host rule**: the window is driven in a TestAnyware VM, never on the host. The
clipboard is never touched by either workflow — keep it that way, and note that
an accessibility search covers what the window exposes, not pixels.

## Decisions (running log)

**The run is one Gatekeeper-enforcing session on the quarantined notarized
bundle, not a clean golden.** `platform-acceptance-k42` established that route in
`scripts/vm-verify-gatekeeper-lib.sh`, and the leaf's "against the notarized
build" is answered weakly by an unquarantined install on an assessments-disabled
golden: that is the posture every earlier enrollment run already had, so it would
add nothing the release path could break. Reuse `enforce_gatekeeper`,
`install_app_quarantined` and `first_launch_quarantined` unchanged rather than a
second spelling of them.

**The `already-decided` refusal is driven through the confirmation dialog, not
through a race against the 2s poll.** Clicking Approve on a request that asks for
`koine:manage` raises `RequestReviewView`'s `confirmationDialog` and sends the
server nothing; `pendingManageApproval` holds the `ManagedGrantRequest` by value,
and `approveConfirmed` later uses that captured request whatever the polled list
has since become. So the decision over GraphQL is made while the dialog stands,
with no clock to beat, and the second click is what reaches the server and is
refused. `OrderingHook` is internal to `KoineCore` and reaches no notarized
bundle; a click timed against `StatusModel.follow()`'s two-second poll would be a
race the run could lose silently, and losing it would move the click onto another
row. This way the order is forced by the UI itself.

**The enrollment budget is refilled by restarting Koine before the volume
phase.** `EnrollmentBudget` is in memory and a restart refills it, so the count
the rate-limit assertion needs does not have to survive the earlier phases —
where the agent's false-timeout retries re-send an enrolment and spend budget
that no assertion can see. After the restart the whole volume phase is one guest
process with one HTTP sequence, and each enrolment's answer is cached in the
guest beside its secret so a repeated exec replays it without reaching Koine.

**Both limits are crossed, not just one.** The leaf permits staying inside them;
crossing both is what no VM run has seen. Ten admitted then an eleventh gives
HTTP 429 with `Retry-After`; after the 60s window refills, six more reach the cap
of sixteen pending and a seventeenth gives `pending-request-limit` — which is an
ordinary 200 with a domain error, and telling the two refusals apart is the
point.

**The keep-alive case is a guest process that waits on a trigger file.** A guest
exec is one-shot, so the client opens `http.client.HTTPConnection`, makes one
authorized request, then blocks on a file the host touches after revoking the
grant in the window, and makes its second request on the same socket. It records
`getsockname()` on both sides of the revocation: equal local ports are the
witness that it is one connection rather than two.

**The manual workflow keeps using the guest's clipboard.** `create_grant`'s Copy
button and `pbpaste` are the window's only credential delivery that leaves the
secret in the guest; reading `grant-credential` from the accessibility tree would
bring it to the host, which is what the rule exists to prevent. The host's
clipboard is never touched, and the enrollment workflow touches no clipboard at
all.

**A guest command reports what it observes, never what it changed.** The first
run died at the refusal step on "the manager denied no such request" — a
sentence that reads as a finding against Koine and is not one. `deny-pending`
had printed the set it denied, the agent repeated the exec it had falsely
reported as timed out, and the repeat had nothing left to deny. Every guest
command here was then classified rather than the one instance patched: the
enrolling and polling cases are reads or are answered by Koine's identical-retry
path, `batch` caches each answer beside its secret, `keepalive` caches its
result — and the two that were not safe are fixed. `deny-pending` now prints
every request's state afterwards, with the listing's own status and errors so
that an empty list is never read as an empty set of requests; and the keep-alive
client is cleared and launched in two execs, the launch guarded by an atomic
`mkdir`, because one exec would let a repeat delete the first client's files
under it and an unguarded start would leave two clients racing on them. The
guard is a directory and not a `pgrep`, because the exec's own shell carries the
pattern in its command line and matches it.

**The refusal itself was right on the first run that reached it; the assertion
was not.** The second run drove the whole mechanism — the confirmation stood, the
manager denied the request over GraphQL, and the window composed
`“refused-client” was not approved: it is already denied.` — and then failed on
an equality against `text_of`, which joins **every** string in the element, so
the identifier and the platform role arrive in front of the sentence. The other
reads in this script pass that helper to `grep`, which is why the difference had
never shown. The sentence is read from the element's own `value` (or `label`)
and the emptiness is checked separately, so a missing sentence and a different
one are two distinct failures rather than one.
