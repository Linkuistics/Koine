# app-input-k10 — brief

## Goal

A client holding input authority delivers the configured keyboard shortcuts to
a captured target application and switches Spaces through the Control-digit
workflow. A client with only read or window-focus authority cannot.

## Done when

- Input is addressed to the captured target and is never deliberately
  retargeted by title or to whichever application is now foreground. A target
  that is gone, or that Koine finds not in the state delivery requires, is
  reported and nothing is sent. Any race left between that check and native
  delivery is the limit `app-input-evidence-k22` establishes, stated in the
  spec beside the existing accepted limits. A limit that would reduce the
  agreed baseline is raised with Antony.
- For every configured app-shortcut row, the intended result is designed. The
  row states whether a keystroke or a menu invocation achieves it. A row that
  needs menu invocation passes with its intended result to `menu-bar`, which
  owns its delivery and acceptance.
- VM acceptance shows the intended outcomes of the keystroke rows for Safari,
  Finder, Zed, Obsidian, Zotero and Dia's ordinary tab operations (new tab,
  find tab, positional next/previous). It also covers Space switching.
- The Mail, Slack, Signal, Messages and Telegram keystroke rows are
  implemented. Their account-dependent acceptance is recorded as pending for
  `account-acceptance`. The annotated Signal and Messages chords are checked
  there against intended results and are not assumed correct.
- Input authority is tested through the public operations. It can be granted
  without menu invocation. Read-only, focus-only, denied and revoked grants
  cannot deliver input. Trace rows are added.

## Decomposition

1. `design` evidence: how synthesized input reaches a captured target.
2. `design`: the API and per-row intended results.
3. `planning`: cut implementation leaves.

## Notes

Dia's recent-tab walk holds a modifier across requests, so it belongs to
`held-interactions`. That increment builds on this one's delivery. The
requirements neither demand a public arbitrary-shell executor nor forbid
generic chord delivery. The design chooses between semantic per-app
operations and generic delivery.
