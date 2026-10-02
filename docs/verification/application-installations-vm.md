# Multiple copies and installation: VM acceptance

The "Isolated TestAnyware macOS VMs" seam of the **Multiple copies and installation** row of
[workspace-launch-and-open.md](../specs/workspace-launch-and-open.md), for both
`workspaceLaunchApplication` and `workspaceOpenPath` with a named application. It runs the
Developer ID signed `Koine.app` (0.1.0, executable digest `dc080eb6…`, the build the run below
used) in a clone of the prepared image from [launcher-apps-vm.md](launcher-apps-vm.md): macOS 26.5,
Gatekeeper enforcing, nothing signed in to. The app under test is **not notarized** and is copied in
without a quarantine attribute, as in the earlier VM acceptances. Nothing runs an application on the
host.

**What passed, what is recorded, and what is a platform limit.**

- **Passed.** 48 cases, each a request sent once by the contract-only client under
  `workspace:control` and `desktop:control` alone, with Accessibility never granted, observed by an
  independent witness and by the copies' own logs:
  - one identifier on two registered copies: an unconstrained launch and an unconstrained named open
    **reuse the copy running at the other location** and start no second one; an installation path
    **addresses exactly the chosen copy**, whichever of the two is running, and when both are;
  - a symlink to the copy's folder, a symlink to its bundle and composed and decomposed Unicode
    spellings of a registered path each choose their copy **by file identity**;
  - a missing copy, a present copy that is not registered, a copy deleted after it was registered, a
    bundle whose Info.plist is gone and a bundle with another identifier each report their dependency,
    by path and by identifier alone, with **nothing launched, opened or substituted**;
  - a path inside an unreadable folder and a bundle with unreadable contents are `failed`, never absence
    and never another identifier;
  - a program that is not a bundle has no named-selector route; a bundle that declares no identifier is
    not reachable by one; and a default handler that declares no identifier still receives a document.
- **Recorded, not asserted.** What Launch Services itself answered for each identifier before and
  during the run (below), and the timeline of a registered copy moved into the Trash.
- **A platform limit, held at L and G instead.** On this macOS, Launch Services drops the
  registration of a copy within about 50 ms of its being moved into the Trash. No request can meet a
  registered present copy in the Trash, so that case cannot be produced at V. See
  [The Trash](#the-trash).
- **Two defects found by this increment, both fixed.** A registered copy in the Trash was refused when
  chosen by its path, and a bundle whose Info.plist could not be read was reported as an identifier
  mismatch. See [What it found](#what-it-found).

## Procedure

```sh
task launchers:prepare   # once: the reusable image
task installations:vm    # scripts/vm-verify-installations.sh, one clone of that image (about 1 hour 40 minutes)
```

`task installations:vm` builds the signed app and the contract-only client, then runs one clone.
`KOINE_INSTALLATIONS_ONLY=reuse,spelling,absent,trash,denied,bundle` runs the named sections. It exits
0 when everything passed and 1 when a case failed. The run in this document is
`.build/vm-verify/installations-vm-20261003T081519.log`; its results are kept in
[application-installations-vm/results.json](application-installations-vm/results.json), one record per
case with the client's answer, the copies' logs, the instances before and after and the witness's
account.

### The fixture, and what saw what

`Fixtures/InstallationFixture` is an application built once **in the guest** and installed at several
locations by `scripts/vm-installation-fixtures.sh`, a **reusable recipe** (the search increment's
constrained launch needs the same): ad-hoc signed copies, so Gatekeeper never assesses them, each with
its own Info.plist and its own label, registered with Launch Services under one identifier twice
(`A/Fixture.app` and `B/Fixture.app`), under one each for the Unicode, deleted, Info.plist-less,
unregistered and unreadable cases, and under no identifier at all for the bundle that declares none. It
declares only its own document extension, as an alternate viewer, so it is never a default for an
existing type and no default-handler setting changes.

What each case saw, none of it Koine's account of itself:

- **The copies' own logs** (`$HOME/install-fixture.jsonl`, the guest's clock): each copy writes
  `launched`, `reopen` (the system asking a running copy to come forward) and `open` (a document handed
  to it) with **its own label and path**. Which copy ran is the copy's report, not an inference from a
  path.
- **`LaunchWitness`** (`Fixtures/LaunchWitness`, an independent signed tool that holds no Koine code):
  the instances of the identifier before and after, and, for the process the receipt names, the
  kernel's start instant and the system's bundle path for it. A receipt passes only if its pid and
  start instant are the kernel's **and** its pid is the one the chosen copy logged.
- **`scripts/vm-registration-lookup.swift`**: what `NSWorkspace` answers, the same two calls the
  provider's adapter makes (the registered copy for an identifier, and every registered copy), read in
  the guest before each section so that no case rests on an assumed registration.

Everything one case needs is done by `scripts/vm-installation-request.py` in **one guest process**, and
its one answer is read back once. The agent's exec channel costs seconds per command and reports a
false timeout for about a quarter of them; a first version of this script made about fifteen execs per
request and took ten minutes a case. The guest script takes its own lock, so an exec the agent reports
as timed out and retries cannot send a request twice, and it is started in a session of its own
(`start_new_session`), because the agent kills what an exec it gave up on left running.

The run digests its twelve subjects (the scripts, the fixture source, the libraries, the client and the
app's executable) before and after; none changed.

## Reuse and exact installations

Launch Services chose copy **A** for the identifier (`urlForApplication(withBundleIdentifier:)`) and
listed both. A is therefore the copy an unconstrained request would address, and B is the copy a
running copy must stand in for.

| Case | What the logs, the witness and the receipt showed |
| --- | --- |
| Launch, nothing running, unconstrained | A started; the receipt is the kernel's identity for A's process; one instance. |
| Launch, B running, unconstrained | B was asked to **reopen**; **no** copy started; still one instance, the same process; the receipt is B's. |
| Launch, B running, path A | A started beside it (two instances); B's process survived untouched; the receipt is A's. |
| Launch, both running, path B, then path A | The chosen copy was asked to reopen and nothing else was reached or started; the two processes are the same before and after. |
| Open a document, nothing running, named, unconstrained | A started and was handed the document. |
| Open, B running, named, unconstrained | B was handed the document; A never started. |
| Open, B running, path A | A started and was handed the document; B was not handed it. |
| Open, both running, path B | B was handed the document and no copy started. |

The unconstrained rule, **a running copy at another location is reused**, is what the native request is
configured for (`allowsRunningApplicationSubstitution`, enabled except for a path constraint) and is
now seen to be what the system does; the constrained rule, **only the chosen copy**, is the same flag
disabled. Neither is claimed for an application that handles reopen differently: the fixture reports
what it was asked.

## Spellings

Each case starts with copy A running, so that a launch which merely reused "a running copy" would show:

- **A symlink to B's folder** and **a symlink to B's bundle** chose B, started it beside A (two
  instances) and, for the open, handed it the document, with B stopped before the open. The registered
  copy was addressed, not the link.
- **A Unicode path spelled in the other normalization form** chose the copy registered under the
  first: registered composed (`Café`) and asked for decomposed (`Cafe` and U+0301), and registered
  decomposed (`Café ñ`) and asked for composed. Both started their own copy and, for the open, received
  the document. The path files carry the exact bytes; the exec channel is known to re-normalise
  Unicode in a command line, so no Unicode path is typed into one (the installation path is read in the
  guest by `$(cat …)`, and the client echoes what it sent).

## Absent and mismatched installations

Each is asked **by path** and **by identifier alone**, as a launch and as a named open, and in every
case nothing launched, no fixture process started or changed and the log stayed empty.

| Installation | Result |
| --- | --- |
| A path that does not exist | `APPLICATION_NOT_INSTALLED` |
| A present copy, not registered (Launch Services itself reported nothing for it, read in the same guest process right before the request) | `APPLICATION_NOT_INSTALLED` |
| A copy deleted after it was registered | `APPLICATION_NOT_INSTALLED` |
| A registration that outlived its bundle's Info.plist: the folder and the registration remain, and the bundle declares no identifier | `APPLICATION_IDENTITY_MISMATCH` |
| A present copy of another identifier | `APPLICATION_IDENTITY_MISMATCH`, and neither copy of the requested identifier was substituted |
| B running, a missing path | `APPLICATION_NOT_INSTALLED`; B was not reopened and nothing started |

**Launch Services drops a registration the moment its bundle is deleted.** The look-up for the deleted
copy returned nothing at once, so a registration that is stale in the sense the spec fears (listed, and
its bundle gone) is not what a deletion leaves. The stale record this system *does* keep is the one
above, a bundle that stopped being an application bundle while its registration stayed, and the
provider decided it by inspecting the bundle and not by trusting the registration: the bundle declares
no identifier, so it is a mismatch, and nothing else stood in.

**Launch Services also registers a bundle it finds under the home folder on its own**, some time after
it appears, and `lsregister -u` is what keeps it unregistered. In an earlier run the system
had registered the copy again by the time of the second request after the first one was refused, and
that request opened a document in it. Each
unregistered case therefore unregisters the copy and reads the answer in the same guest process,
immediately before the request, and fails the run if the system will not stay silent.

## The Trash

The contract keeps a registered present copy in the Trash eligible: moving it there is not an
uninstall. The platform does not keep the registration. After a registered copy was moved into the
Trash (three rounds, a fresh copy each, Launch Services asked as fast as the guest could ask for four
seconds, about 790 lookups a round):

| Round | First answer after the move | First "none" | Later answers |
| --- | --- | --- | --- |
| 1 | the Trash path, 40 ms after (and the list of every copy: none) | 52 ms | none, every time |
| 2 | the Trash path, 63 ms after (list: none) | 72 ms | none, every time |
| 3 | the Trash path, 40 ms after (list: none) | 51 ms | none, every time |

**For about fifty milliseconds Launch Services reports the copy at its Trash path, through the lookup by
identifier and not through the list of every copy, and then deregisters it.** In probes that the run does not record, a
running copy and a `.Trashes` folder on a mounted volume were dropped as well, and a registration made
for a bundle already in the Trash was refused. A request made after the move therefore met no registration, and
the three cases (an unconstrained launch, a path-chosen launch and a path-chosen open, each with a fresh
copy moved into the Trash immediately before the request) reported `APPLICATION_NOT_INSTALLED` with
nothing launched, which is what the system's own answer, read right after, says.

That is why **the case "a registered present copy in the Trash stays eligible" is not produced at V**:
a request cannot be made inside a fifty-millisecond window. It is held where the answers can be
arranged as they were observed: `SelectionTests` and `WorkspaceInstallationsCompositionTests` give the
provider a copy that only the lookup by identifier reports, and it is selected, unconstrained and
chosen by its path. Nothing the provider does is Trash-specific: registration and presence decide, at
whatever location.

## Unreadable installations

- **A path inside a folder nobody may enter** (mode 000): `failed`, as a launch and as a named open,
  with the system's `Permission denied` in the message and nothing launched.
- **A bundle whose contents nobody may read** (the folder readable, `Contents` mode 000):
  `failed`, never `APPLICATION_IDENTITY_MISMATCH`. See [What it found](#what-it-found).
- **A registration that points into an unreadable folder or bundle** cannot be produced either:
  Launch Services stops reporting the registration once the copy is unreadable (recorded). Denial is
  therefore shown for the chosen path, and held for the registered path at L and G
  (`aChosenCopyThatCannotBeReadIsFailed…`, `anUnreadableInstallationIsAFailureAtTheActionsPath…`).

## Bundle-less programs and default handlers

- A **program that is not a bundle** is present and is not an application: a launch or a named open of
  it, with the identifier of the fixture, reports `APPLICATION_NOT_INSTALLED`. There is no
  named-selector route for it.
- A **bundle that declares no identifier** is an application bundle and is not reachable by any
  identifier: `APPLICATION_IDENTITY_MISMATCH` for a launch and for a named open.
- **Default-handler use is distinct.** Launch Services names that same bundle as the default handler of
  `default-anon.koineanon` (its only claimant) and reports **no identifier** for it. A `workspaceOpenPath` with no application
  for that document was acknowledged, the bundle logged the document, and the
  receipt is the kernel's identity for its process. A handler without an identifier receives a document;
  it only has no selector.

## What it found

Two defects, each seen red at the seam that caught it, then fixed:

1. **A registered present copy in the Trash was refused when chosen by its path.** `urlsForApplications`
   leaves a copy at a Trash path out of its list while `urlForApplication` still returns it, and the
   constrained selection looked only in the list. Seen red at L (`SelectionTests`, with a registration
   the fake reports only by identifier) and at G, with the real provider over a stand-in doing the same,
   against the source with the fix removed; fixed by asking both answers
   (`Providers/WorkspaceProvider/Logic/Selection.swift`).
2. **A bundle whose Info.plist could not be read was an identifier mismatch.** `Bundle(url:)` answers
   nil for a bundle that declares no identifier and for one it may not read. Seen red at N
   (`WorkspaceProviderTests`, the signed bundle against a real sealed bundle on the host); fixed in the
   adapter, which now tells the two apart by `stat` and `access` on the one path, never opening the file
   (`Providers/WorkspaceProvider/Sources/NativeWorkspace.swift`). A run of the `denied` section against
   the build from before the fix already answered `failed` at V (`Permission denied`, from the call that
   reads the bundle's resource values), so V alone did not distinguish the two.

The L gaps that earlier leaves left, now closed: a chosen path that cannot be read is `failed` (not
absence or another copy); a bundle that declares no identifier is a mismatch; a bundle-less program is
never selected; several registered copies are each addressed by their own identity; and a default
handler without an identifier still receives a document. The first and the last were seen red against a
mutated source (an inspection denial read as absence, and a handler required to have an identifier).

## Accessibility and consent

Accessibility was read as absent through Koine's own `osPermissions` at the start and at the end, and
every request above was by `workspace:control` and `desktop:control`. No Gatekeeper, consent or other
system dialog was on screen after any section. Nothing here needed or added a consent, an entitlement
or a certificate class.

## The contract-only client

The requests use the client as it is: `launch --application-path` and
`open-path --bundle-identifier --application-path` already carry the installation. The client was not
changed.

## Limits and what stays pending

- **The Trash** is a platform limit, above. Eligibility is held at L and G; the registered present copy
  in the Trash cannot be shown at V on macOS 26.5.
- **Removable and network volumes** were not observed (no such volume in the image), as in the earlier
  increments.
- **A registration pointing into an unreadable folder** is held at L and G, not V, above.
- **Running-copy reuse is observed for the fixture only.** The twelve real applications were launched
  and reactivated in [launchers-vm.md](launchers-vm.md); a second installed copy of any of them is not
  part of the image.
- Nothing here is notarized or quarantined; Gatekeeper's behavior is [launchers-vm.md](launchers-vm.md)'s.
- Disclosure of the registered-application boundary is `workspace-disclosure`'s.
