# protected-path-metadata-k73

## Goal

Answer one bounded native question before any operation relies on its answer:
launch's installation selection, path opening, reveal or search. Can signed,
hardened Koine perform the spec's pre-submission path inspection on first-use
protected locations without raising a consent prompt?

The inspection is:

- existence and dangling links;
- symlink resolution;
- volume and file identity;
- application-bundle and content-type metadata, including the bundle identifier
  and presence check launch selection makes for a constrained or unconstrained
  installation;
- alias-file type;
- default-handler lookup.

## Context

- `docs/specs/workspace-launch-and-open.md`: the application-input, path and
  refusal-policy paragraphs, "Consent and prompts", and the rule that inspection
  never requests consent, enumerates contents or opens protected bytes.
- `docs/specs/workflow-providers.md`, prompt-free reads.
- The root brief's "Evidence stays bounded".

## Done when

- A signed build runs in an isolated VM with no Files and Folders consent
  established. Each inspection primitive the launch and path operations will use
  is run once against Desktop, Documents and Downloads. That includes a registered
  application bundle placed in each location. Removable and network volumes
  are included where the VM can provide them. Each result is recorded as a
  prompt, no prompt, or error class.
- Locations the VM cannot provide are recorded as unavailable rather than passed.
- There is one answer. Either the inspection holds prompt-free, recorded with
  the exact calls, or each prompting call is a stated limit raised with Antony.
  No consent identifier is added, and no deeper evidence chain is opened.
- The spec's application-input and path paragraphs and the Consent and prompts
  row reflect the answer. The answer is stated where `workspace-launch`,
  `document-paths`, `reveal-path` and `app-and-file-search` will read it.

## Notes

This is one named question for one decision. An unknown becomes a stated limit
or an escalation. A denial is `failed`, never absence.

`launch-and-open-k82` moved this probe ahead of `launch-path`, so no workspace
code exists when it runs. Exercise the primitives from a throwaway probe bundle
that mirrors Koine's signing posture: its team, hardened runtime, entitlements
and Info.plist usage keys. Launch it so that it is its own responsible process,
not a child of Terminal. The probe is evidence tooling, not workspace code, and
it authorizes no new entitlement or consent.

## Decisions (running log)

- Use a disposable Developer ID probe launched as a GUI application through
  Launch Services, matching Koine's Team ID, hardened runtime, empty entitlements
  and absence of Files and Folders usage keys. Reset its consent before each case;
  do not inherit the test agent's authorization. Keep exact per-call results and
  a separate protected-content-read positive control. No workspace implementation
  is part of this leaf.
- The measured file-URL default-handler lookup prompts on first-use Desktop,
  Documents and Downloads, including a text file whose lookup still returns a
  handler after denial. That call cannot be credited as a prompt-free readiness
  check. Keep protected default-handler paths pending for an explicit human
  consent/semantics decision; no consent identifier or entitlement is added.
  Metadata, symlink and identity observations alone do not establish safe handler
  discovery. Correct the fixture executable's minimum OS before recording the
  installation-selection result.
- The corrected final measurement records 105 individual cases on macOS
  26.5/25F71. Registered compatible app fixtures resolve to their exact paths;
  metadata, symlink and identity calls do not prompt. Document file-URL handler
  lookup prompts on all three home roots. Content-read controls prompt and fail
  after denial. Source and guest-fixture digests match before/after; every case
  starts with absent probe consent and runs with parent PID 1. Durable evidence is
  in `docs/verification/protected-path-metadata.md` and its adjacent artifacts.
- Keep protected default opening live in `document-paths`, and carry the handler
  read limit into `app-and-file-search`. Ask Antony which later design direction
  he prefers; until answered, retain the authorized no-new-consent policy.
  Removable/network scopes are unavailable and remain unaccepted. This bounded
  evidence leaf introduces no deeper native-evidence chain.
- Decline an in-session prose reviewer for the native conclusion: the executable
  dialog/denial controls, matching per-case results, fixture-registration check
  and frozen subjects are the stronger instrument for this bounded measurement.
  A fresh read cannot establish a wider prompt-free native guarantee; no such
  guarantee is asserted. Reusable evidence tooling passes lint/type checks.
