# open-url-vm-k72

## Goal

Accept URL opening at V with real browsers in the prepared VM, and widen the
public contract checks to the URL root.

## Context

- The workspace spec's Browser URL row, and the prepared VM from
  `application-launchers`.

## Done when

- The URL opens with Safari as the default and again with Dia as the alternate
  default. The cases cover an encoded query and fragment, an IDNA host, and a
  universal-link candidate that must stay in the browser. Scheme-only handler
  discovery is inspected in the actual call path.
- Invalid escapes, raw Unicode, whitespace and backslashes are refused without
  repair.
- A client whose suggestion source fails still opens the typed-query URL. Koine
  makes no Google request.
- Accessibility is absent throughout, and the operation still works.
- `task conformance`'s workspace profile includes the URL root, and the
  contract-only client opens a URL through the documented contract.
- The spec rows and the Web search trace row link the evidence document.

## Decisions (running log)

- **What the browser opened is witnessed by a page server, not by Koine's answer.** A guest-side
  Node server (`scripts/vm-url-witness-server.mjs`, no Koine or client code) logs each request's
  target and `Host` exactly as the browser wrote them, and its page posts `location.href`,
  hostname and hash back, which is the only way the never-transmitted fragment is seen without
  automating a browser's UI. Names (`koine-url.test`, `xn--bcher-kva.test`) are `/etc/hosts`
  entries for 127.0.0.1 in the disposable clone; both browsers resolved them in a hand trial
  (Safari reported the fragment and the exact href). Plain http on an explicit port, so no
  certificate and no HTTPS upgrade is in play.
- **Universal-link candidate: `https://maps.apple.com/?q=...`**, with a control. A plain
  `open` of it launches Maps in this image (seen before writing the case), so a Koine open that
  leaves Maps unlaunched is a result and not a vacuous one. The control is part of the run and
  fails it if Maps does not start.
- **The CLI client is extended by a reading-restricted pass** (as `launch` was), asked for
  `open-url` and `search`; its guesses go to `open-url-contract-client-findings.md`. The
  `search` flow is the client-owned part Web search leaves out of Koine: suggestion source,
  typed-query fallback, percent-encoding into an engine template.
- **"Koine makes no Google request" is read from the system.** `nettop` per-process external
  bytes plus `lsof` of Koine's sockets, with two controls: Koine's own row must appear when
  loopback is included (the instrument sees it) and a browser's networking process must show
  external bytes (the instrument sees real traffic).
- **The schema capture is the signed build's own.** `task conformance:vm` (the signed bundle in a
  clean VM) passed with the URL root in the design file and its removal seen red, and its
  introspection response and digest `1815b52f...` are what the client is regenerated from;
  `task client:capture` records that route.
- **Shared helpers moved, not rewritten.** `contract_client_once` (the launchers script's careful
  version) went to the contract-client library and the witness/dialog helpers to
  `vm-verify-witness-lib.sh`, so the URL acceptance and the launchers' share them.
- **Dia cannot show a page in this image, so Dia is observed at delivery and its page load is
  pending.** Its first run stops at an account gate (intro film, then a work-email gate; an
  Atlassian sign-up page in a fresh profile). Tried and rejected as witnesses: the page server
  (nothing arrives), the unified log (URLs redacted as `<private>`, and private data cannot be
  switched on), and a Dia started with `--remote-debugging-port` and a fresh profile (the target
  list holds the sign-up page and extension workers, no tab for the URL). Neither signing in nor
  inventing an account is this session's to do. Cut as `dia-url-page-load-k88` under
  `account-acceptance` (an account-dependent case, which that node exists to hold) rather than
  left as prose, because the web-urls brief lets only certificate-dependent cases stay pending
  when its node closes. The run exits 3 for it, as it does for an acknowledged open the witness
  did not see activate.
- **A test browser, `Fixtures/UrlBrowser`, stands beside Dia as the second alternate default.**
  A signed application that declares http/https and HTML, is listed and made default through the
  system's own confirmation, and records the exact string each URL arrives as (the GetURL Apple
  event's payload and the open-URLs call's). It needs no account, network or Accessibility and
  shows nothing, so it is a byte-exact witness of delivery to *the system's* default browser,
  which is what an alternate default is for. It does not replace Dia; it says so.
- **The universal-link candidate cannot be shown being diverted to an application at V.** Seen
  here: a plain `open` of `https://maps.apple.com/...` goes to the default browser and, with
  Safari, Safari then hands it to Maps itself (not on every open); Dia's own
  `applinks:share.diabrowser.engineering` did not divert a plain `open` either, and a fixture cannot
  be given an associated domain without Apple's association file. So the case is judged by who
  received the URL from Koine, first (the first application launched or activated after the
  request is the browser, no application before it, Maps never for the browsers that do not
  forward), and the scheme-only lookup rests on `task check:launch-call-path` run on the signed
  bundle, which is what the Browser URL row asks for ("inspect scheme-only handler discovery").
  The first design (Maps must not start; a control that Maps does start on a plain open) failed
  on both counts and was dropped, not softened: the control is now recorded, not asserted.
- **"Koine makes no Google request" is read from `fs_usage -f network`** (root, filtered to
  `Koine` and `curl`, from before the first open to the end): every network system call either
  made, one line each, so a connection made and closed is seen, which a socket listing and
  `nettop`'s per-process counters (open sockets only) are not. Koine: 200 calls (80 accept, 80
  read, 40 close), no `connect`; the control, curl's one request, shows 3 `connect`s in the same
  capture. (fs_usage's number after the process name is the thread, not the pid: the first
  version searched for the pid.)
- **Refusals, denials and the revoked grant run as one batch in the guest.** Each guest command
  costs about 15 s on average because the agent reports "timed out after 30s" for about half of
  them; the per-case form took 7 minutes a case. The batch is also the stricter observation: one
  watch from the first request to the last, not one launch or activation, no request at the
  page server, front application unchanged.
- **The typed query is passed as `$'caf\xc3\xa9'`.** The exec channel hands a literal é to the
  guest decomposed (e + U+0301), which is the harness changing the user's text.
- **Idempotence of the guest commands the agent may run twice**: the page server's start checks
  the port and truncates its log only once it has bound it; `set_default_browser` takes a guard
  directory per run and call (a late retry raised a second confirmation that nothing answered and
  that was read as Gatekeeper's); `judge_dialogs` now names a stray system dialog for what it is.
- **The run digests its inputs before and after** (11 files, the script itself included). One
  run was lost to editing the script while the shell was reading it, which is the provenance rule
  `references/execute.md` states; the run now fails if a subject changed.
- **Documents repaired from the client findings** (F1-F15 of
  `open-url-contract-client-findings.md`): the guide's "Opening a URL" gained the error path and
  HTTP 200, the accepted/refused classes, the encode set with a worked example, the client's own
  handling, the fallback as a choice before the one open, and what the receipt names; the spec's
  outcome table, Browser URL row and Operations paragraph, `machine.md`'s error table row and a
  comment on `OpenSearchURL` were corrected. Declined ones (F4, F6, F7 protocol, F10, F14, F15) are
  recorded with their reasons in the findings' disposition table.
- **In-session review (the leaf's one allowance), on the evidence document.** A fresh context read
  `open-url-vm.md` and the spec's V paragraph against the transcript, `results.json` and the
  recipe, looking for overclaims and vacuous passes; 16 findings, all classified:
  *valid and fixed in the documents:* the `ECONNREFUSED` quote (the client said `fetch failed`);
  Dia's "delivery" and "nothing else received it" (only acknowledgment, activation and the
  receipt's kernel identity are observed; what Dia was handed is not, and is now pending too); the
  Dia exploratory observations (page server, unified log, remote debugging, `applinks`), which were
  not retained and are now labelled so; the receipt claim for search cases (not compared); "once"
  (the recipe requires at least one, and Safari's is a set); the hang-duration claim (cannot fail,
  dropped); the default-engine claim (Safari activated, no witness of the engine page); the digest
  claim (eleven listed files, not the provider library or the witness); "no networking class"
  (Objective-C imports only); the Accessibility "every open" (an inference); "same signed build"
  (rests on the build's modification time, now stated, with the library digest taken); the intro
  and the limits (Dia "past its first run", "nothing else pending", "bounded acknowledgment",
  "driven by anything but the system"); the spec's revoked-grant row (401, not `capability`) and
  its receipt and search parentheses. *Valid, and a visible trade-off recorded as a limit:* the
  refusal batch's witness has no liveness control (the page server's silence is independent); the
  universal-link case is not discriminating (below). *Valid and fixed by new work:* the network
  witness: `fs_usage` sees BSD `connect()` and neither a CFNetwork connection nor a send, and its
  control was curl alone. Replaced as the instrument for the claim by `task open-url:network`
  (`tcpdump` over PKTAP, process-attributed), validated first against curl and a Swift program
  named `Koine` using `URLSession` and Network.framework (96 and 31 packets attributed on a
  non-loopback interface), then showing the real Koine's packets on loopback only (22), the engine's
  30 lookups made for Safari, and Safari's processes carrying the traffic; it records its limits
  (25 external packets carry no attribution; a short interval). *The universal-link finding was
  accepted as stated:* the case cannot tell the scheme-only lookup from a URL-aware one in this
  image, and now says it rests on the call-path inspection; the run's results keep `passed` for it,
  which the document explains. Two header comments and one body comment of the recipe, still
  describing the abandoned design, were corrected after the run (no behaviour). No finding was
  noise.
