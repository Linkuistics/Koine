# Browser URL: VM acceptance

The "Isolated TestAnyware macOS VMs" seam of the **Browser URL** row of
[workspace-launch-and-open.md](../specs/workspace-launch-and-open.md), and of the URL
parts of its **Input boundary**, **Receipt/failure boundary** (the receipt),
**Bounded acknowledgment** (answer times only: see the limits), **Authority/revocation**
and **Consent and prompts** rows. It runs the Developer ID signed `Koine.app` (0.1.0) in a
clone of the prepared image from [launcher-apps-vm.md](launcher-apps-vm.md): Gatekeeper
enforcing, Safari the default browser, Dia installed and past Gatekeeper and its first-run
UI (where it stops, at an account gate), nothing signed in to. Nothing runs an application
on the host. No browser's interface is driven to open a page; the recipe does quit browsers
(Command-Q, with a force-kill recorded), answers the system's own default-browser
confirmations, and runs a plain `open` as a recorded comparison.

**What passed, what is pending, and what could not be shown.**

- Passed, with Safari the default and with a test browser made the alternate default: the
  URL, byte for byte, as the browser was handed it (encoded path, query and fragment; an
  ASCII IDNA host; the client's search flow with a failing suggestion source); the 18
  refused inputs, the denied and the revoked grants; Koine's own packets on loopback only;
  Accessibility absent.
- **Pending, not passed: Dia's page load.** Dia cannot load a page in this image. For Dia the
  run observes only that Koine's open was acknowledged, Dia activated, and the receipt equal
  to the kernel's identity; **what Dia was handed is not observed**. That is [one live leaf
  for Antony](#dia-delivery-observed-page-load-pending) (`dia-url-page-load-k88`).
- **Could not be shown in this image: a URL being diverted to an application by the system's
  own dispatch.** The "universal-link candidate" case therefore does not, by itself,
  discriminate the scheme-only lookup from a URL-aware one; that clause of the done-when rests
  on `task check:launch-call-path` ([below](#the-cases)).

## Procedure

```sh
task launchers:prepare   # once: the reusable image (about 40 minutes)
task open-url:vm         # scripts/vm-verify-open-url.sh, one clone of that image (about 3 hours)
```

`task open-url:vm` builds the signed app and the contract-only client, then runs one
clone. `KOINE_OPEN_URL_ONLY=Safari,UrlBrowser,Dia,refus` (any of them) runs those sections
only. It exits 0 when everything passed, 1 when a case failed, and 3 when nothing failed
but something is pending (Dia's page load, or an acknowledged open the witness did not see
activate).

**Every request is made by the contract-only client** ([launch-contract.md](launch-contract.md),
[open-url-contract-client-findings.md](open-url-contract-client-findings.md)), which
enrols its own grants through the settings window and was regenerated from the schema the
signed build serves (digest `1815b52f078ff4a1c7ca08d284ccfd50c03422d47055c8b926500391a1569d19`,
introspected by `task conformance:vm`, below). Four grants are enrolled: both controls, each
control alone, and a fourth for both controls that a `koine:manage` grant, made in the
window first, then revokes. **Koine has no Accessibility consent in the clone** and the run
checks Koine's own account of that at the start and at the end, so every open below is by
`workspace:control` and `desktop:control` alone, with no read capability.

### What saw what the browser was handed

A request's acknowledgment says nothing about the browser, so three independent things do:

| Witness | What it is | What it sees |
|---|---|---|
| **The page server** (`scripts/vm-url-witness-server.mjs`) | A Node server in the guest, no Koine or client code. `koine-url.test` and `xn--bcher-kva.test` are `/etc/hosts` entries for 127.0.0.1 in the disposable clone, so no name reaches the network. Plain HTTP on an explicit port: no certificate and no HTTPS upgrade is in play | Each request's target and `Host` header **exactly as the browser wrote them**; and the page it serves posts the browser's own `location.href`, hostname, pathname, search and **hash** back, the only way the fragment (never sent to a server) is seen without automating the browser's interface |
| **The test browser** (`Fixtures/UrlBrowser`) | An application the system treats as a browser: it declares `http`, `https` and HTML, is listed, is made the default browser through the system's own confirmation, and is handed web URLs. It shows nothing and records what it receives | The **exact string** each URL arrives as (the GetURL Apple event's payload, and the open-URLs call's, whichever the system used), with the guest's clock |
| **`Fixtures/LaunchWitness`** | The signed witness of [launch-vm.md](launch-vm.md): no Koine code, no Accessibility | Who is in front, which instances run, the kernel's start instant of each, and every launch and activation, on the guest's clock |

Safari is observed by the first, the test browser by the second, and both by the third.
Dia, which shows no page, by the third alone.

Before each request TextEdit is put in front and Koine is inactive. The run digests the
eleven files it lists (the script and its main libraries, the page server, the test browser's
source and build script, the client bundle and Koine's executable; not the provider library, the
other helper libraries or the witness) before and after, and fails if one changed under it; the
digests are printed at the start of the transcript. Two comments in the script's header and one
in its body, which still described a design abandoned during the runs (a plain `open` that goes
to Maps), were corrected after the run; no behaviour changed, so the digest printed at the start
of the cited transcript is of the script before those comments.

## Opening in each browser

### Safari 26.5 (build 21624.2.5.11.4), `com.apple.Safari`

The default at the start of the run; at `/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app`. Witness: **page**.

| Case | What the witness saw | Answer / activation (ms) | Receipt = kernel's |
|---|---|---|---|
| encoded path, query and fragment (cold browser) | The page server received exactly the submitted request-target and `Host`; the page reported the submitted `location.href` and fragment | 110 / 93 | yes |
| encoded path, query and fragment (running browser) | The page server received exactly the submitted request-target and `Host`; the page reported the submitted `location.href` and fragment | 43 / 32 | yes |
| ASCII IDNA host | The page server received exactly the submitted request-target and `Host`; the page reported the submitted `location.href` and fragment | 59 / 51 | yes |
| universal-link candidate stays in the browser | The browser was the first application activated; Maps was reached only afterwards, by Safari's own forwarding of the Apple link | 44 / 22 | yes |
| search, suggestion source refusing the connection | The client reported the failed suggestion source; the page server received exactly the typed-query request-target and the page reported the typed-query `location.href` | 33 / 12 | not compared |
| search, suggestion source that never answers | The client reported the failed suggestion source; the page server received exactly the typed-query request-target and the page reported the typed-query `location.href` | 45 / 18 | not compared |

Plain `open` of the universal-link candidate with this browser the default (recorded, not asserted; for Safari the counts are Safari and Maps taking the front from each other for some seconds): the first application was `com.apple.Safari`, 6 activation(s) of the browser, 7 Maps launch or activation event(s).

### The test browser 1.0 (build 1), `dev.koine.test.UrlBrowser`

Made the alternate default through the system's confirmation (Safari restored at the end); at `/Users/admin/Applications/UrlBrowser.app`. Witness: **fixture**.

| Case | What the witness saw | Answer / activation (ms) | Receipt = kernel's |
|---|---|---|---|
| encoded path, query and fragment (cold browser) | The test browser was handed exactly the submitted string | 579 / 561 | yes |
| encoded path, query and fragment (running browser) | The test browser was handed exactly the submitted string | 34 / 29 | yes |
| ASCII IDNA host | The test browser was handed exactly the submitted string | 33 / 27 | yes |
| universal-link candidate stays in the browser | The test browser was the first application activated and was handed exactly the submitted string; Maps never started | 34 / 29 | yes |
| search, suggestion source refusing the connection | The client reported the failed suggestion source; the test browser was handed exactly the typed-query URL | 21 / 9 | not compared |
| search, suggestion source that never answers | The client reported the failed suggestion source; the test browser was handed exactly the typed-query URL | 22 / 8 | not compared |

Plain `open` of the universal-link candidate with this browser the default (recorded, not asserted): the first application was `dev.koine.test.UrlBrowser`, 1 activation(s) of the browser, 0 Maps launch or activation event(s).

### Dia 1.50.1 (build 87750), `company.thebrowser.dia`

Made the alternate default through the system's confirmation; at `/Applications/Dia.app`. Witness: **delivered**.

| Case | What the witness saw | Answer / activation (ms) | Receipt = kernel's |
|---|---|---|---|
| encoded path, query and fragment (cold browser) | Delivery only (no page): acknowledged, activated, nothing else received it | 275 / 264 | yes |
| encoded path, query and fragment (running browser) | Delivery only (no page): acknowledged, activated, nothing else received it | 180 / 158 | yes |
| ASCII IDNA host | Delivery only (no page): acknowledged, activated, nothing else received it | 61 / 39 | yes |
| universal-link candidate stays in the browser | Dia was the first application activated; Maps never started. Delivery only (no page) | 46 / 33 | yes |
| search, suggestion source refusing the connection | The client reported the failed suggestion source and the typed-query URL it opened. Delivery only (no page) | 32 / 10 | not compared |
| search, suggestion source that never answers | The client reported the failed suggestion source and the typed-query URL it opened. Delivery only (no page) | 41 / 16 | not compared |

Plain `open` of the universal-link candidate with this browser the default (recorded, not asserted): the first application was `company.thebrowser.dia`, 1 activation(s) of the browser, 0 Maps launch or activation event(s).


## The cases

**Encoded path, query and fragment.** `http://koine-url.test:8765/search/a%20b?q=caf%C3%A9+%E6%97%A5%E6%9C%AC&x=%26%23%25&e=%3D#frag%20ment-%C3%A9`
and, once the browser runs, `.../second/%E6%97%A5?k=%2B%2F%3F&v=a%20b#%E2%9C%93-frag`. For
Safari the page server's distinct request-targets since the request were exactly the one
submitted (path and query) with exactly the submitted `Host`, and the page's `location.href` and
`hash` were the submitted URL and fragment, byte for byte (the check is on the *set* of
targets, so a page loaded twice would not show). For the test browser the string it was
handed is the submitted string, and its log held exactly one record in each case (read from the
transcript; the recipe requires at least one and that all equal the string). The first case of
each browser is a **cold** launch (the browser quit first, the receipt's process starting after
the request) and the second finds it running.

**ASCII IDNA host.** `http://xn--bcher-kva.test:8765/idna?label=b%C3%BCcher#top`: the page
server saw `Host: xn--bcher-kva.test:8765` and Safari's page reported that hostname; the
test browser was handed the same string.

**A universal-link candidate.** `https://maps.apple.com/?q=Koine%20URL%20acceptance`. What the
recipe asserts is **who received the URL from Koine**: the first application the system
reports launched or activated after the request is the browser; no Maps event comes before the
browser's activation; the receipt's process is the browser's; and, for the browsers that do not
forward Apple links (the test browser, Dia), Maps is never launched or activated and the browser
is in front (the test browser was also handed the exact string). For Safari a Maps launch that
follows its activation is recorded as Safari's own handling of an Apple link: that attribution is
inferred from the order, and Safari does not do it on every open (an earlier run of the same
case left Maps unlaunched).

**This case does not, by itself, discriminate the scheme-only lookup from a URL-aware one, and
the document does not claim it does.** This image cannot show a URL being diverted to an
application by the system's own dispatch: a plain `open` of the URL, recorded beside every
browser, also reaches the *default browser* first (Safari, the test browser, Dia), and with
Safari Safari then hands it to Maps itself. A Koine that regressed to `NSWorkspace.open(url)`
would therefore give the same observation here. No application in the image has an associated
domain that LaunchServices resolves for a plain `open`, and a fixture cannot be given one without
an Apple-served association file. (Dia's own `applinks:share.diabrowser.engineering` was tried
interactively while the recipe was being written, and a plain `open` of it reached Safari; that
is an unrecorded exploratory observation, not part of the run.)

**So the done-when's "universal-link candidate that must stay in the browser" rests on the
inspection of the call path**, as the row says ("inspect scheme-only handler discovery"):
`task check:launch-call-path` on the built bundle finds one handler lookup, whose only argument
is `http:` or `https:` built from the scheme and nothing of the submitted URL, and one open
request addressed to the resolved application with launch's ten configuration settings; no other
activation, hiding, input, scripting or process call; and no Objective-C networking class in the
provider library's imports (Swift or BSD symbols are not listed there). The lookup and open-request
checks are of the provider's source, the selectors and imports of the built library; the bundle
was built once, before every run cited here, and not rebuilt ([Regression](#regression-and-what-was-re-run)).
The L, G and N tests of the previous leaf pin the same lookup with a recording adapter. Producing
the divergence itself needs an application with a verified associated domain: a limit of this
image, below.

**Search.** The client's own `search` flow, an engine template that is the page server and
a suggestion source that **refuses the connection** and then one that **never answers**:
the client reports the failed source (`fetch failed`; `no complete answer within 2000 ms`), and
the `workspaceOpenURL` it then sends carries the typed-query URL, percent-encoded from the UTF-8
bytes of `koine café & co #1` (`/search?q=koine%20caf%C3%A9%20%26%20co%20%231`), which the page
server's distinct request-targets were exactly and the test browser was handed exactly. The
hanging source was asked (the recipe requires the page server to have logged it). How long the
open took after that is not measured here: the answer time recorded is the open request's alone,
and the 2000 ms limit is the client's own report. The typed text is given to the guest as ASCII
escapes of its bytes, because the agent's exec channel hands a literal `é` to the guest
decomposed (`e` and U+0301), which is the harness changing the text, not the client.

**The default engine.** `search --query 'koine url acceptance'`, no engine given, builds
`https://www.google.com/search?q=koine%20url%20acceptance` and opens it in Safari: Safari was
activated by the request (the witness saw it), and Koine made no packet on a network (below).
Nothing here witnesses the engine's page loading in Safari beyond that; the dedicated network
check shows the engine's lookups made for Safari.

## Refused inputs and denied grants

The refused inputs and the three denied grants run as one batch in the guest under one
witness, with TextEdit in front. The witness reported no launch or activation event over the
batch, the page server received no request, and the front application was the same before and
after (two samples, not a continuous watch). The witness was started with a 20-minute bound and
the batch took about 12 minutes; **nothing in the run proves the witness was still alive at the
end**, so an empty event list is weaker evidence than the page server's silence, which is
independent. Each refusal is
HTTP 200 with a single execution error at **`["workspaceOpenURL"]`**, the root field's own
path, **no `kind`**, `classification: input-error`, `actionEffect: none`, no receipt and
nothing opened. Nothing was repaired (the client sends the file's bytes unchanged, a
trailing newline included, and the provider's message is what came back).

| Input (the file's exact bytes) | Class | Koine's message |
|---|---|---|
| `…/a%zz` | invalid percent escape (non-hex digits) | url has an invalid percent escape in its path. |
| `…/a%2` | invalid percent escape (truncated) | url has an invalid percent escape in its path. |
| `…/?q=%G1` | invalid percent escape in the query | url has an invalid percent escape in its query. |
| `…/café` | raw Unicode in the path | url must be ASCII: percent-encode UTF-8 path and query text, and give the host as ASCII IDNA labels. |
| `…/?q=日本` | raw Unicode in the query | url must be ASCII: percent-encode UTF-8 path and query text, and give the host as ASCII IDNA labels. |
| `http://bücher.test:8765/` | raw Unicode in the host | url must be ASCII: percent-encode UTF-8 path and query text, and give the host as ASCII IDNA labels. |
| `…/a b` | a space | url must not contain whitespace. |
| ` http://…/` (leading space) | whitespace, not trimmed | url must not contain whitespace. |
| `http://…/` and a line feed | a trailing newline, not stripped | url must not contain a control character. |
| `…/a<TAB>b` | a tab | url must not contain a control character. |
| `…/a<U+0001>b` | a control character | url must not contain a control character. |
| `…/a\b` | a backslash in the path | url must not contain a backslash. |
| `http://koine-url.test:8765\a` | a backslash after the authority | url must not contain a backslash. |
| `http://user:secret@…/` | credentials | url must not contain credentials. |
| `file:///etc/hosts` | another scheme | url must use the http or https scheme. |
| `javascript:alert(1)` | another scheme | url must use the http or https scheme. |
| `koine-test://example/x` | a custom scheme | url must use the http or https scheme. |
| the empty string | an empty URL | url must not be empty. |

| Grant | Answer |
|---|---|
| `workspace:control` alone | HTTP 403, `capability-denied`, `phase: authorization`; first unmet `desktop:control`; the complete set `["workspace:control","desktop:control"]` in that order |
| `desktop:control` alone | HTTP 403, `capability-denied`; first unmet `workspace:control`; the same complete set |
| a grant for both, revoked by the manager | HTTP 401 (`unauthenticated`): a revoked credential never reaches admission, so this is the transport-level refusal and not a `capability` error; the revocation made through `koineRevokeGrant` |

## Koine made no request of its own

"Koine makes no Google request" is read from the system, with two instruments, of which only
the second can carry the claim.

**1. `fs_usage -f network` over the main run (weak).** As root, filtered to `Koine` and `curl`,
from before the first open (after the grants were enrolled) to the end. Koine's 200 lines were
80 `accept`, 80 `read` and 40 `close`, and **no `connect`**; curl, the control, made 3. This is
less than it looks. The capture lists no send or write at all, though Koine accepted about 80
connections and answered them, so it shows the calls its filter classes as network and not all of
them; the control is curl's BSD `connect()` alone; and a CFNetwork client (`nscurl`, tried
interactively afterwards and not retained) showed only its DNS lookup in the same filter and no
TCP `connect`, so a connection by `URLSession` or Network.framework is not seen as one. The run's "0 connect" is therefore a statement about BSD sockets, and
Koine's network stack, if it ever made a request, would not be BSD sockets.

**2. `task open-url:network` (`scripts/vm-verify-network.sh`), a packet-level capture.**
`tcpdump -i pktap,all -k NPID` writes every packet the system carries with its interface, the
process whose socket carried it and the process it was carried for (a DNS lookup is carried by
`mDNSResponder` for the application that asked). It sees any stack, a connection made and
closed included. Its transcript is `open-url-network-20261002T143336.log` and its summary
[open-url-vm/network-summary.json](open-url-vm/network-summary.json).

- *Controls, before Koine runs.* curl, and a Swift program compiled in the guest under the name
  `Koine` (`Fixtures/NetControl`), which makes a `URLSession` request (HTTP/3, as QUIC) and a
  Network.framework connection to `example.com`, were each attributed on a non-loopback
  interface under their names: `Koine` 96 packets, `curl` 31; and the DNS lookup of
  `example.com` made for the control was attributed to `Koine`. A capture that could not do
  that could not witness Koine.
- *The signed Koine, with the client sending the default-engine search (Google) and a second
  search whose suggestion source refuses the connection*, each opened in Safari. Koine: **0
  packets on any non-loopback interface and 22 on loopback**, so the instrument sees it; the
  engine's `google` DNS lookups, 30 of them, were all made for **Safari**, none for Koine; and
  Safari's own processes carried the external traffic (`Safari` 5515, `com.apple.WebKit` 5326,
  `com.apple.Safari` 79 packets). The client (`node`) shows only loopback packets (20).
- *What this cannot say.* 25 external packets and 15 loopback packets in the capture carry no
  process attribution, so the capture cannot say whether any of those were Koine's; the two
  searches are the traffic Koine saw, not every operation; and the capture covers a short
  interval (about a minute), not the three-hour run, whose own evidence is the weaker
  instrument above.

## Accessibility and consent

Koine's own account, read under the manager grant (`osPermissions`), was `granted: false`
at the start and at the end of the run, and the system's dialogs listed on screen after each of
the 18 browser cases (by their buttons: Gatekeeper's, a permission request, a default-browser
confirmation) were none. At the end the screen was also read for the consent dialog's text
(once, after Dia, as in [launch-vm.md](launch-vm.md); the host process `universalAccessAuthWarn`
runs, as macOS starts it when an untrusted application merely asks whether it is trusted, and
shows nothing). That Accessibility was absent for *every* open is therefore an inference from the
two readings of Koine's account and the dialog listings, not a reading taken at each open. No
open raised a dialog of the system's Gatekeeper process or a permission request naming Koine.
The signed bundle is not notarized and was installed without a quarantine attribute, so
Gatekeeper never assessed Koine itself in this run; that is [launch-vm.md](launch-vm.md)'s and
[release-acceptance-vm.md](release-acceptance-vm.md)'s ground.

## Dia: delivery observed, page load pending

Dia 1.50.1's first run stops at an account gate (an intro film, then "Welcome to Dia"
asking for a work email; in a fresh profile its page is an Atlassian sign-up); the
preparation records that it is never filled in, and this run did not either. A page Koine
submits to Dia is therefore never shown. **The recipe cannot see what Dia was handed**, and
three other witnesses were tried interactively while it was being written, none of them part
of the run and none retained: the page server received nothing; the unified log redacts URLs
(`<private>`) and refused to enable private data; and a Dia started with
`--remote-debugging-port` and a fresh profile listed the sign-up page and extension workers,
no tab for a submitted URL.

What the run does observe for Dia, in each of its six cases, is that Koine's open was
acknowledged, the witness saw Dia activated, and the receipt's `{pid, startedAt}` was the
kernel's for the one Dia instance. The witness's events for every Dia case are printed in the
transcript and name only Dia; the recipe asserts that no other application received the URL
only in the universal-link case (Dia first, Maps never). The same evidence for a launcher is
what [launchers-vm.md](launchers-vm.md) accepts; for a browser it is **not** the row's "the URL
opens with Dia as the alternate default" in the sense that a page appears, and a regression that
activated Dia without handing it the URL (an open of the application alone) would pass it. That
handoff is observed only for the test browser.

**This is pending and is Antony's to settle.** It is an account-dependent case, so it is cut as
live work in `account-acceptance`, the leaf `dia-url-page-load-k88`, which holds three options:
a Dia account used in isolated VMs only, with the Dia cases rerun against the page server;
accepting delivery for Dia and recording that; or a real, account-free alternate browser standing
in. The test browser above already shows the alternate-default mechanism with an exact witness of
the string delivered, and that Koine follows the *system's* default and not Safari.

## Findings from the runs

- **The agent's false timeouts set the pace, and they lengthened the first runs to hours.**
  About half of all guest commands report "timed out after 30s" after completing; the recipe
  retries them (as every VM recipe here does). The refusals, which took seven minutes each
  one at a time, now run as one guest-side batch (ten minutes in all) with a stricter
  observation.
- **A command run twice starts two of anything it starts.** The agent retried the page
  server's start (the second instance truncated the log before failing to bind: the log is
  now truncated only once the port is held), and the default-browser change (each run raises
  a confirmation dialog of its own, and the stray ones were read as Gatekeeper's). Both are
  idempotent now: the server start checks the port, and `set_default_browser` takes a guard
  directory unique to the run and call. A leftover confirmation is now a failure with its
  own message, not a "Gatekeeper dialog".
- **The agent's exec channel changes typed text.** A literal `é` reaches the guest
  decomposed. The typed query is passed as ASCII escapes.
- **A script edited while it runs is read from the new offsets.** One run was lost to that
  (an editing session changed the script under the shell running it, and the shell read
  garbage from shifted offsets); the run now digests its inputs before and after and fails
  if any changed.
- **`fs_usage`'s number after a process name is the thread, not the process id.** The first
  version of the network check looked for Koine's pid and found no Koine call.
- **The `fs_usage` witness was not enough, and a review said so.** It sees BSD `connect()` and
  not a CFNetwork connection, and lists accept, read and close but no send. The packet-level
  capture above replaced it as the instrument for the claim, with controls for both stacks and
  for a process named `Koine`. A control built as a copy of `curl` named `Koine` did not run (a
  copied platform binary is killed), which is why the control is a Swift program compiled in the
  guest.
- **Safari forwards Apple-domain links to the Maps application itself, not on every
  open**: the same URL once left Maps unlaunched and once launched it after Safari's
  activation. That is why the universal-link case is judged by order and not by absence.
- **The system's launch notification is not a reliable witness of a cold launch**, as
  [launchers-vm.md](launchers-vm.md) found; the criterion is the kernel's start instant of the
  one instance, after the request.

## Regression and what was re-run

The leaf changed shared material (the contract-only client, the schema it is generated
from, three VM libraries and the launchers script that used them), and the URL root's
contract checks are part of its brief, so these were run, each to a pass, on one signed build:
`.build/app/Koine.app` was assembled once (01:29:47-54 on 2 October) and not rebuilt, before every
run cited here and the main run; its executable's digest is `9a8eada5…` (printed by the main run)
and its provider library's `a200f463…` (digested after the runs, the file being unchanged since
its build time). The logs of the other runs carry no build digest, so "one build" rests on that
modification time.

- **`task conformance`**, all three profiles (transcript
  `conformance-20261002T140931.log`; the workspace profile's capture, from which the client
  is regenerated, is `conformance-20261002T013001.log`). The workspace profile's design file
  declares `workspaceOpenURL` and the signed application serves exactly it, digest
  `1815b52f078ff4a1c7ca08d284ccfd50c03422d47055c8b926500391a1569d19` on both sides. The check
  was first seen red against a design file with **the URL root removed** ("red, caught by the
  report and the digest"), beside its other controls. This is the "workspace profile includes
  the URL root" item.
- **`task client`** (codegen validated against the captured schema, typecheck, bundle, 938
  adapter checks, from clean): the `OpenSearchURL` operation of the published
  `workspace-operations.graphql` validates against what the signed build serves, and a name
  the client uses that the schema lacks stops generation (watched in the client's README).
- **`task app:vm-verify-launch-contract-client`**, the launch drive with the regenerated
  client (transcript `launch-contract-client-20261002T031340.log`): the client's introspection
  reports `schemaDigestsEqual: true` against the new digest, and the launch, the handoff and
  the absent-process cases pass as before.
- **`task check:launch-call-path`** on the built signed bundle (run again after the main run, with
  the same result): one handler lookup, whose
  only parameter is `http:` or `https:` built from the scheme alone
  (`NativeWorkspace.swift:112-113`); one open request addressed to the resolved application
  (`:126`), with launch's ten configuration settings; no activation, hiding, raising, input,
  scripting or process call beside it; the provider library imports `NSBundle`, `NSError`,
  `NSLock`, `NSObject`, `NSRunningApplication`, `NSThread`, `NSWorkspace` and
  `NSWorkspaceOpenConfiguration`, `OS_dispatch_queue` and Swift's own object root, and no Objective-C
  networking class (the check lists the imports and asserts none; Swift and BSD symbols are not
  among them). *PASSED.*
- **`task open-url:network`**, the packet-level check above (transcript
  `open-url-network-20261002T143336.log`), on the same build; it digests its own eight inputs,
  the provider library included, before and after.
- **`task design:workspace-check`** after the comment added to `OpenSearchURL`: valid, both
  negative controls rejected.
- **`scripts/vm-verify-launchers.sh` with no applications**
  (`KOINE_LAUNCHERS_ONLY=none KOINE_LAUNCHERS_SKIP_EXTRA=1`, transcript
  `launchers-vm-20261002T140717.log`): it sources the moved helpers
  (`vm-verify-witness-lib.sh`, the shared `contract_client_once`), starts a clone, enrols its
  grant and quits. This proves the libraries load and the enrolment works; it is **not** a
  rerun of the twelve launchers (three hours), whose own code is byte for byte what it was:
  the moved functions are the same text; `set_default_browser` (preparation's) is not on the
  launchers' path; and `judge_dialogs`, which is, fails the same cases as before with a different
  message for a standing dialog that is not Gatekeeper's.

No Swift source of the package changed in this leaf, so the L, G and N suites of
`open-url-k71` are as they were.

## Limits and what stays pending

- One macOS (26.5), one architecture, one clone, **one sample** of each timing. Safari 26.5,
  Dia 1.50.1 and the test browser are as the image holds them.
- **Pending: Dia's page load** (above), which includes that **what Dia was handed is not
  observed**. Neither the test browser nor the call-path inspection is a substitute for a real
  Dia page; they are what the image allows, stated as that.
- **Not shown in this image: a URL diverted to an application by the system's own dispatch.** The
  universal-link case records who received the URL from Koine and cannot, by itself, tell the
  scheme-only lookup from a URL-aware one; that rests on the call-path inspection. This is a
  limit of the image (no application with a resolvable associated domain), not pending work with
  an owner; a later image with one would settle it.
- **Bounded acknowledgment, at V, is answer times only.** Every URL open answered in under 600 ms,
  so none was held past three seconds; the hold-and-dismiss case is the Gatekeeper-held launch in
  [launchers-vm.md](launchers-vm.md), and the late-callback and bound handling is established at L
  (`OpenURLTests`).
- Safari's page is the browser's own report (the page server and its `location.href`), not a
  screenshot, and what Safari then did with a page it loaded is outside the row. The search
  cases do not compare the receipt with the kernel's identity (the twelve direct opens do), and
  the default-engine case records a pass whenever the open was acknowledged, with Safari's
  activation recorded beside it rather than required.
- The refusal batch's witness has no liveness control (above), and "the front application never
  changed" is two samples.
- The network claim is bounded as above: the packet-level capture is of a short interval and two
  searches, with unattributed packets it cannot account for; the three-hour run's own capture is
  the weaker instrument.
- Accessibility being absent at *each* open is an inference from two readings and the dialog
  listings.
- Multiple copies, the path and reveal roots and disclosure are other increments.
