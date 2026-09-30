# open-url-k71

## Goal

Serve `workspaceOpenURL` complete to its design, verified at L, G and N.

## Context

- `docs/specs/workspace-launch-and-open.md`: the URL paragraphs, "Results and
  failure boundary" and the Browser URL and Input boundary rows.
- RFC 3986 section 3: the `URI` production, including its optional fragment.

## Done when

- Input validation accepts exactly the spec's ASCII grammar:
  - an `http` or `https` scheme and a nonempty host;
  - valid percent escapes;
  - no credentials, whitespace, backslashes or control characters.
  Other schemes, raw Unicode and IDNA violations are input errors at the
  original path. Nothing is trimmed, repaired or re-encoded. Valid path, query
  and fragment bytes are preserved.
- The default handler is resolved by scheme alone, never by passing the
  submitted URL to universal-link-aware discovery. The URL is submitted
  explicitly to that application, with the same activation, no-new-instance,
  prompt and one-shot acknowledgment bounds as launch.
- A missing handler is `NO_DEFAULT_HANDLER`. Default changes after resolution do
  not retarget or replay.
- L: with the adapter substituted, cover the absent handler, false or late
  acknowledgment, cancellation and capacity exhaustion.
- G: composition tests cover the URL field's authority, branches and
  multi-action behavior. Grammar positives and negatives include encoded query
  and fragment, IDNA labels, and each refused class.
- N: the real bundle serves the widened contribution. No browser is driven on
  the host.
- The served contribution adds the URL root verbatim from the design file.
