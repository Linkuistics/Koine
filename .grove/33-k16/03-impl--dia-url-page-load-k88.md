# dia-url-page-load-k88

## Goal

Close the one part of the Browser URL V row the prepared image cannot show: Dia
loading a URL that `workspaceOpenURL` delivered. Dia's first run stops at an
account gate, so the page never appears.

## Context

- `docs/verification/open-url-vm.md`, "Dia: delivery observed, page load
  pending". For Dia the run observed delivery in every case (acknowledged,
  activated, the receipt equal to the kernel's identity, nothing else receiving
  the URL, Maps never started for the Apple link) and no page. The page server
  received nothing, the unified log redacts URLs, and a Dia started with
  `--remote-debugging-port` and a fresh profile lists the sign-up page and
  extension workers, no tab for the submitted URL.
- Dia 1.50.1's first run: an intro film, then "Welcome to Dia" asking for a work
  email (an Atlassian sign-up page in a fresh profile). `docs/verification/launcher-apps-vm.md`
  records that the preparation never fills it in.
- `Fixtures/UrlBrowser`, the test browser, already shows the alternate-default
  mechanism with an exact witness of the delivered string, and that Koine follows
  the system's default rather than Safari. It is not Dia.
- `scripts/vm-verify-open-url.sh`: `browser_section Dia ... delivered` is the one
  line that decides the witness; `page` is what Safari uses.

## Done when

- With Antony, settle what counts for Dia, and record the decision:
  - a Dia account created for isolated VMs only, never on the live desktop, with
    its credentials supplied the way `test-accounts-k28` supplies the others; or
  - delivery is accepted for Dia, and the pending case is closed on that
    ground; or
  - another real, account-free browser stands in as the alternate default.
- If an account is provided: the Dia cases run with the page-server witness
  (`task open-url:vm`, Dia's witness changed from `delivered` to `page`) and
  pass; the Browser URL row and the Web search trace row say so.
- If neither happens, the case stays pending as live work and
  `baseline-acceptance` does not close around it.

## Notes

Cut by `open-url-vm-k72` rather than left as prose in a document: the web-urls
brief allows only certificate-dependent cases to remain pending when its node
closes, and this one is account-dependent, which `account-acceptance` is
chartered for. It sits here, late, so that waiting on a human-supplied account does
not stall the AFK increments.
