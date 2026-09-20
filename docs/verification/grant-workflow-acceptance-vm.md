# Both grant workflows on the release build: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, for
`grant-workflow-acceptance-k43`: the grant half of release acceptance, run
against the **notarized, stapled, quarantined** `Koine.app` on a
**Gatekeeper-enforcing** clone, in one session. Both agreed workflows have each
been driven before on a development-signed bundle
([resident-app-vm.md](resident-app-vm.md),
[grant-enrollment-vm.md](grant-enrollment-vm.md)); what this run adds is that
they hold on the release artifact, together, and that it drives the four things
`grant-enrollment-vm.md` said it did not: a refusal shown in the window, several
requests pending at once, the pending cap and the enrollment rate limit, and
revocation of an enrolled grant through the window.

The protocol itself is covered at the public GraphQL seam
(`GrantEnrollmentTests`, `GrantDecisionTests`, `GrantRequestLifetimeTests`), the
window's operations in `KoineManagementClientTests`, and revocation's ordering in
`RevocationOrderingTests`; this run is where they are seen working together in
the installed, notarized application. The Gatekeeper procedure is
[notarized-release-vm.md](notarized-release-vm.md)'s, reused through
`scripts/vm-verify-gatekeeper-lib.sh`; the TestAnyware workarounds are
[resident-app-vm.md](resident-app-vm.md)'s.

## Procedure

```sh
task app                             # build and sign .build/app/Koine.app
task app:notarize                    # submit, wait, staple, zip the release artifact
task app:vm-verify-grant-workflows   # scripts/vm-verify-grant-workflows.sh
```

The script refuses to start unless `stapler validate` passes on the bundle: run
against an unnotarized build the quarantined first launch would be refused, and
the run would say nothing about either workflow. The guest is started at
`1920x2160` only so the Gatekeeper policy control is on screen
([notarized-release-vm.md](notarized-release-vm.md) explains why that is the
mechanism); Koine's own window is a fixed frame whose content area is 480x680
and does not grow with the screen, which is what makes the scrolling case real.

**No credential reaches the host.** The manual workflow's delivery is the
**guest's** clipboard, which is where the window's Copy button puts it — reading
the credential out of the accessibility tree instead would bring it here, which
is the thing the rule exists to prevent. The enrolling clients each make their
own 32-byte secret into a `0600` file, send Koine only its SHA-256 digest, and
present the unchanged secret as their bearer; neither secret nor digest is ever
printed. The enrollment workflow touches no clipboard at all.

| Case | How | Expectation checked |
|---|---|---|
| Workflow 1, manual | a grant created in the window, its credential copied to a guest file | the script is `vm-script` with exactly `desktop:read`, `ACTIVE`, HTTP 200 |
| Workflow 2, enrollment | a guest client asks for `koine:manage`, `desktop:read`, `desktop:control`; `desktop:control` unticked; approved with the confirmation | its unchanged secret is a grant holding exactly `desktop:read` and `koine:manage`, and it reads `koineManagement`; nothing typed, pasted or shown |
| The window shows no secret | the whole accessibility tree uploaded to the guest and searched there | neither the secret nor its digest occurs, in 101 860 bytes of tree |
| A pending requester | five probes under a pending request's secret | reads its **own** request; `koineApproveGrantRequest` is 403 `permission`; `koineManagement` and `desktopApplicationByReference` are 200 with a `permission` error and null; `koine { ownGrant }` propagates to `data: null` |
| **A refusal in the window** | Approve clicked on a `koine:manage` request raises the confirmation and sends Koine nothing; the request is then denied over GraphQL; the confirmation is clicked through | the window composes `“refused-client” was not approved: it is already denied.`, and its re-read leaves the row gone, no grant made, and the other pending request untouched |
| Persistence | Koine quit and started again | the manual credential, the enrolled manager and all three decisions survive |
| **The rate limit** | eleven enrollments inside one 60s window | ten admitted; the eleventh is **HTTP 429** with **`Retry-After: 60`** |
| **The pending cap** | five more to sixteen pending, then one more | the seventeenth is an ordinary **200** carrying reason **`pending-request-limit`** and **no** `Retry-After` — a different refusal from the one above |
| **Sixteen pending together** | the window's own polling, with nothing clicked to make it look | sixteen rows; **five** reachable without scrolling; all sixteen reachable by scrolling |
| **Scrolling to reach one** | scroll until a row that was not reachable is inside the frame, then Deny it | `bulk-12` leaves the list and its own poll says `DENIED` |
| **An enrolled grant revoked in the window** | Revoke, then its destructive confirmation | the row reads `Revoked`; the credential is refused **401** with `WWW-Authenticate: Bearer` **on the connection that had just served it** (local port 49245 before and after), and again on a new connection after a restart |
| After the restart | the manager's lists | nineteen requests (17 `DENIED`, 2 `APPROVED`) and three grants (`vm-script` and `first-manager` `ACTIVE`, `keepalive-client` `REVOKED`), and no request pending |

## What this run establishes that the earlier one could not

- **The refusal is not raced.** `RequestReviewView` captures the request **by
  value** into `pendingManageApproval` when the `koine:manage` confirmation
  opens, and sends the server nothing until the second click, so the decision
  made over GraphQL while the dialog stands lands squarely between the window's
  read and the click that reaches Koine. `grant-enrollment-vm.md` called forcing
  that order "a race the script does not run"; it is not a race, and no clock is
  beaten. `OrderingHook` is internal to `KoineCore` and reaches no notarized
  bundle.
- **The two refusals are told apart.** Past the rate limit the transport answers
  429 with `Retry-After` and no GraphQL error extensions; past the pending cap
  the request is an ordinary 200 carrying `reason: "pending-request-limit"` and
  the message "Too many grant requests are waiting for a decision.". Asserting
  both, in one run, is what distinguishes them.
- **Reachability is decided geometrically, not by the accessibility tree.** The
  tree reports a row that is scrolled out of view, so a row counts as reachable
  only when its Deny button lies wholly inside the window's frame, less the
  title bar. That is why "five of sixteen" is a claim about what a user can
  reach and not about what the tree holds.
- **One connection, not two.** The keep-alive client records `getsockname()` on
  both sides of the revocation. Equal local ports are the witness that the 401
  was served on the connection that had just been served 200; without it the run
  would show only that a revoked credential fails on *some* connection.

## What `grant-enrollment-vm.md`'s "does not show" list looks like now

- **A refusal shown in the window** — **closed**. The sentence the window
  composes and its re-read of both lists were driven here.
- **The pending cap and the enrollment rate limit** — **closed**, both crossed.
  **Expiry and retention remain open** here and are not this run's: they need a
  clock a VM does not have, and `GrantRequestLifetimeTests` covers them with
  `Harness(clock:)`.
- **Several requests pending together** — **closed**. Sixteen at once, with the
  layout and the scrolling driven.
- **Revocation of an enrolled grant** through the window, and the secret's 401
  afterwards — **closed**, on a live connection and after a restart.
- **That the user compares the code** — **still open, and deliberately outside
  this leaf.** The run shows the window's code equals the client's receipt
  (`G69V-VQJJ`). A client that displays it, and a person who looks, are not
  shown here either.
- **The clipboard** — the enrollment workflow still touches none. The manual
  workflow touches the **guest's**, which is the window's only credential
  delivery; the host's is never touched. An accessibility search covers what the
  window exposes, not pixels.
- **Gatekeeper assessments disabled, no quarantine** — **closed**. This run is
  on a Gatekeeper-enforcing clone with the quarantined notarized bundle, so the
  enrollment cases themselves now stand on the release artifact.

## What this does not show

- **It is one OS build on one architecture.** macOS 26.5 (25F71) on arm64; the
  supported matrix is `support-matrix-and-latency-k44`'s, and no latency is
  measured here.
- **A store or commit failure** is not induced. That a failure never reports a
  successful durable approval or revocation is a public-seam property held by
  `RevocationOrderingTests`' scripted `GrantStore`; a VM cannot make the store
  fail on demand and a run that tried would be testing the harness.
- **Lost manual-secret delivery** is not driven. The credential is shown once and
  the window says so ("Koine never shows a credential again. If one is lost,
  revoke its grant and create another."); that revoke-and-recreate is the only
  remedy follows from the credential never being served again, which
  `GrantManagementTests` holds at the public seam by searching a management
  response for each credential **and** its digest. What this run adds is the
  same search over the window's whole accessibility tree, twice.
- **Two managers deciding at once from two windows** is not shown. One window and
  one `koine:manage` client are the two deciders here, which is what produces
  `already-decided`; a second instance of Koine cannot run against one data
  directory anyway, since the instance lock is held for the server's life.
- **`EXPIRED` and `invalid-subset` refusals** are not shown in the window.
  `KoineManagementClientTests` covers the client surfacing all of them. `EXPIRED`
  reaches the same `already-decided` branch as `DENIED` and composes the same
  sentence with a different state word, so driving `DENIED` exercises that
  branch; `invalid-subset` does **not** — it falls to `RequestReviewModel`'s
  general `catch`, which composes a different sentence from the error's own
  description, and that sentence has not been seen in a VM.
- **No desktop operation succeeds here.** `desktopApplicationByReference` appears
  once, as a probe that a pending requester cannot reach a provider operation;
  the desktop path is [release-acceptance-vm.md](release-acceptance-vm.md)'s and
  the leaves it cites.
- **Login launch, consent and entitlements** are not re-driven;
  [release-acceptance-vm.md](release-acceptance-vm.md) owns them on this same
  bundle.

## Evidence

Run of 2026-09-21, transcript `grant-workflows-20260921T013850.log`, against the
**notarized, stapled 0.1.0** bundle that
[release-acceptance-vm.md](release-acceptance-vm.md) ran against, signed
`Developer ID Application: Antony Blakey (TA43A4RUP3)`; this leaf changes no
application source and did not rebuild it. The nine files the run reads — the
script, the three libraries it sources, `signing-env.sh`, the two guest Python
clients, the guest shell client and Koine's own executable — were digested
before and after and did not change. VM: clone of
`testanyware-golden-macos-tahoe`, macOS 26.5 (25F71), arm64, guest display
1920×2160, Gatekeeper `assessments enabled; developer id enabled`. Result:
**passed**, every expectation in the table above.

Three earlier runs stopped on this script's own expectations, not on Koine, and
each is worth recording because the first two read as findings against Koine and
were not:

1. `deny-pending` reported the set it had denied rather than the state
   afterwards. The agent repeated the exec it had falsely reported as timed out,
   the repeat had nothing left to deny, and the run died on "the manager denied
   no such request" — about a denial that had already happened. Every guest
   command was then classified rather than that one patched; the two that were
   not repeat-safe are fixed, and this one now prints every request's state with
   the listing's own status and errors beside it, so an empty list can never be
   read as an empty set of requests.
2. The refusal was driven correctly and asserted wrongly: the run reached
   `“refused-client” was not approved: it is already denied.` and then failed
   comparing it against `text_of`, which joins **every** string in the element,
   so the identifier and the platform role arrive in front of the sentence. The
   other reads here pass that helper to `grep`, which is why the difference had
   not shown up before.
3. `testanyware input scroll … --dy -10` is parsed as a cluster of short flags
   ("unexpected argument '-1' found"). `--dy=-10` is the form, and which sign
   moves towards the end of the list is now measured on a row rather than
   assumed.

In all three, Koine's own answers in the transcript were correct. No behaviour of
the notarized build differed from the spec in any run.

Lines over 300 characters are cut at `[…]`.

```

== Start a clean VM (koine-verify-20447)
Setting guest display resolution to 1920x2160 px...
  set-display-mode: switched main display to 1920x2160 pt @ 1x (1920x2160 px, modeID 11)
ProductName:		macOS
ProductVersion:		26.5
BuildVersion:		25F71
arm64
Gatekeeper: assessments disabled

== Put the clone into a Gatekeeper-enforcing state
Before: assessments disabled;
After:  assessments enabled;developer id disabled;
The clone is App Store-only; setting the default posture in System Settings.
After System Settings: assessments enabled;developer id enabled;

== Install the notarized bundle and quarantine it, as a download arrives
Quarantine on the bundle: 0181;6aaffe36;Safari;7CA45603-ED30-43E4-87E3-B2B016EDF7F1
Quarantined files inside it: 29
Processing: /Applications/Koine.app
The validate action worked!

== First launch of the quarantined copy: plain open, no right-click-Open
  “Koine” is an app downloaded from the Internet. Are you sure you want to open it?
  Safari downloaded this file today at 3:39 PM. Apple checked it for malicious software and none was detected.
  Photos will appear here when they are finished processing
Koine pid: 744

== Workflow 1: the user creates a grant in the window and hands it to a script
-rw-------  1 admin  staff  43 Sep 20 15:41 /Users/admin/koine-credential
{"data":{"koine":{"contractVersion":"koine-desktop\/1","ownGrant":{"clientLabel":"vm-script","capabilities":["desktop:read"],"state":"ACTIVE"}}}}
HTTP 200
The script's grant: ["vm-script",["desktop:read"],"ACTIVE"]

== Workflow 2: a client enrols itself and is approved in the window, with nothing typed, pasted or shown
{"case": "enrol", "status": 200, "response": {"data": {"koineRequestGrant": {"requestId": "6ed17c36-b483-473c-bd6f-35d6d4d0ddab", "comparisonCode": "G69V-VQJJ"}}}}
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "6ed17c36-b483-473c-bd6f-35d6d4d0ddab", "clientLabel": "first-manager", "comparisonCode": "G69V-VQJJ", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "PENDING", "grant": n[…]
Label: first-manager  Code: G69V-VQJJ  Client's code: G69V-VQJJ
{"case": "shown-in", "secret": false, "digest": false, "bytes": 101860}
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "6ed17c36-b483-473c-bd6f-35d6d4d0ddab", "clientLabel": "first-manager", "comparisonCode": "G69V-VQJJ", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "APPROVED", "grant": […]
{"case": "manage", "status": 200, "response": {"data": {"koineManagement": {"requests": [{"requestId": "6ed17c36-b483-473c-bd6f-35d6d4d0ddab", "clientLabel": "first-manager", "comparisonCode": "G69V-VQJJ", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "APPROV[…]

== A pending requester reads its own request and nothing else
{"case": "enrol", "status": 200, "response": {"data": {"koineRequestGrant": {"requestId": "2c5160a5-c2ac-4409-938a-296f5f003248", "comparisonCode": "3KHJ-JT92"}}}}
{"case": "forbidden", "probes": {"own-request": {"status": 200, "data": {"koineGrantRequest": {"requestId": "2c5160a5-c2ac-4409-938a-296f5f003248", "clientLabel": "pending-client", "comparisonCode": "3KHJ-JT92", "requestedCapabilities": ["desktop:read"], "state": "PENDING", "grant": null}}, "kinds":[…]

== A refusal in the window: the request is decided over GraphQL while the confirmation stands
{"case": "enrol", "status": 200, "response": {"data": {"koineRequestGrant": {"requestId": "6f00c25d-6877-46a9-8aee-8ed5a2d594ee", "comparisonCode": "J6VF-ZGZN"}}}}
The confirmation is up and Koine has been sent nothing:
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "6f00c25d-6877-46a9-8aee-8ed5a2d594ee", "clientLabel": "refused-client", "comparisonCode": "J6VF-ZGZN", "requestedCapabilities": ["koine:manage"], "state": "PENDING", "grant": null}}}}
{"case": "deny-pending", "denied": [{"label": "refused-client", "status": 200, "state": "DENIED"}], "listStatus": [200, 200], "listErrors": [], "states": {"first-manager": "APPROVED", "pending-client": "PENDING", "refused-client": "DENIED"}, "pending": 1}
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "6f00c25d-6877-46a9-8aee-8ed5a2d594ee", "clientLabel": "refused-client", "comparisonCode": "J6VF-ZGZN", "requestedCapabilities": ["koine:manage"], "state": "DENIED", "grant": null}}}}
The window says: “refused-client” was not approved: it is already denied.
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "6f00c25d-6877-46a9-8aee-8ed5a2d594ee", "clientLabel": "refused-client", "comparisonCode": "J6VF-ZGZN", "requestedCapabilities": ["koine:manage"], "state": "DENIED", "grant": null}}}}
{"case": "manage", "status": 200, "response": {"data": {"koineManagement": {"requests": [{"requestId": "6ed17c36-b483-473c-bd6f-35d6d4d0ddab", "clientLabel": "first-manager", "comparisonCode": "G69V-VQJJ", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "APPROV[…]
Pending rows after the re-read: 2c5160a5-c2ac-4409-938a-296f5f003248 

== Restart Koine: both workflows persist, and the in-memory enrollment budget refills
{"case": "own", "status": 200, "response": {"data": {"koine": {"ownGrant": {"grantId": "f0e459c0-729e-4ccf-9411-4037433b77a9", "clientLabel": "first-manager", "capabilities": ["desktop:read", "koine:manage"], "state": "ACTIVE"}}}}}
{"case": "manage", "status": 200, "response": {"data": {"koineManagement": {"requests": [{"requestId": "6ed17c36-b483-473c-bd6f-35d6d4d0ddab", "clientLabel": "first-manager", "comparisonCode": "G69V-VQJJ", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "APPROV[…]

== Crossing the enrollment rate limit: 10 admitted in a window, and the next refused with HTTP 429
[{"label":"bulk-01","status":200,"retryAfter":null,"reasons":[]},{"label":"bulk-02","status":200,"retryAfter":null,"reasons":[]},{"label":"bulk-03","status":200,"retryAfter":null,"reasons":[]},{"label":"bulk-04","status":200,"retryAfter":null,"reasons":[]},{"label":"bulk-05","status":200,"retryAfter[…]
Retry-After: 60s

== Waiting out the rate-limit window, then filling the pending cap (16) and crossing it
[{"label":"bulk-12","status":200,"retryAfter":null,"reasons":[]},{"label":"bulk-13","status":200,"retryAfter":null,"reasons":[]},{"label":"bulk-14","status":200,"retryAfter":null,"reasons":[]},{"label":"bulk-15","status":200,"retryAfter":null,"reasons":[]},{"label":"bulk-16","status":200,"retryAfter[…]
Pending-cap message: Too many grant requests are waiting for a decision.

== The window with 16 requests pending together, and scrolling to reach one
Pending request rows in the window's tree: 16
Koine's window: {"appName":"Koine","focused":true,"positionX":40.0,"positionY":40.0,"sizeHeight":708.0,"sizeWidth":480.0,"title":"Koine","windowType":"standard"}
A row at y=395.0 moved to y=295.0 under --dy -10; towards the end of the list is --dy -10
Rows a user can reach without scrolling: 5 of 16
Rows reached by scrolling through the list: 16
Denied by scrolling to its row: bulk-12
{"case": "poll", "label": "bulk-12", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "0ee5e6b2-02d9-4951-9d37-0878441b0abc", "clientLabel": "bulk-12", "comparisonCode": "5EM5-DT8J", "requestedCapabilities": ["desktop:read"], "state": "DENIED", "grant": null}}}}

== Clear the pending list over GraphQL
Requests by state afterwards: {"APPROVED":1,"DENIED":17}

== An enrolled grant is revoked in the window, and its credential is refused on the connection just served
{"case": "enrol", "status": 200, "response": {"data": {"koineRequestGrant": {"requestId": "53ded942-fe0e-4a1f-8ab7-999d07f0e49b", "comparisonCode": "7XQQ-XE8Q"}}}}
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "53ded942-fe0e-4a1f-8ab7-999d07f0e49b", "clientLabel": "keepalive-client", "comparisonCode": "7XQQ-XE8Q", "requestedCapabilities": ["desktop:read"], "state": "APPROVED", "grant": {"grantId": "50d50e2f-7f45-4622-[…]
cleared
started
The grant's row after the window revoked it: ["keepalive-client","desktop:read","Revoked","Revoke"]
{"case": "keepalive", "before": {"status": 200, "port": 49245, "connection": "keep-alive", "authenticate": null, "data": {"koine": {"ownGrant": {"grantId": "50d50e2f-7f45-4622-96b7-3a603f41e249", "clientLabel": "keepalive-client", "capabilities": ["desktop:read"], "state": "ACTIVE"}}}}, "after": {"s[…]

== Across a restart of Koine: the revoked credential is still refused and both workflows still work
{"case": "own", "status": 401, "response": null}
{"case": "manage", "status": 200, "response": {"data": {"koineManagement": {"requests": [{"requestId": "6ed17c36-b483-473c-bd6f-35d6d4d0ddab", "clientLabel": "first-manager", "comparisonCode": "G69V-VQJJ", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "APPROV[…]
{"case": "shown-in", "secret": false, "digest": false, "bytes": 101299}

== Quit Koine

== PASSED — transcript in .build/vm-verify/grant-workflows-20260921T013850.log
```

The refusal, the sixteen pending requests, the list scrolled to its end, the
grant revoked in the window, and the window after the restart:
[refusal.png](grant-workflow-acceptance/refusal.png),
[many-pending.png](grant-workflow-acceptance/many-pending.png),
[scrolled.png](grant-workflow-acceptance/scrolled.png),
[revoked.png](grant-workflow-acceptance/revoked.png),
[after-restart.png](grant-workflow-acceptance/after-restart.png).
