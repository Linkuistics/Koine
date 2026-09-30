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
