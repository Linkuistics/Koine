# long-pathname-applications-k140


## Goal

Synthesize the two independent long-pathname application surveys into
`docs/research/long-pathname-applications.md`: union their evidenced coverage,
expose disagreements and correlated sources, and perform the adversarial move
neither survey performs on itself.

## Context

Read the ancestor briefs and both committed surveys:
`docs/research/long-pathname-applications-a.md` and
`docs/research/long-pathname-applications-b.md`.
Their identical brief follows real application representations and operations
through file/editor/launch, build/package/repository, archive/backup/sync and
remote/virtual workflows across macOS/POSIX/Windows. The earlier
`docs/research/prior-art-long-paths-a.md` and native prototype are prior leads,
not a conclusion to ratify. Antony retained the original requirement.

## Done when

- Produce the Grove combined-research artifact with unioned primary evidence,
  preserved source/provenance trails, explicit disagreement locations and
  unresolved silences. Agreement based on the same source is not independent
  corroboration; verify citations for every load-bearing mechanism/limit.
- Attack the proposed transferable mechanisms: locate contrary primary source,
  tests or maintainer reports; follow reconstructed full strings, metadata and
  receiver boundaries that might defeat apparent success. Distinguish storing
  a long name, operating on it and passing it to an arbitrary application.
- Compare actual use cases, representations, units/limits, platform/version
  conditions, failure behavior and process cooperation. Preserve systems that
  succeed beyond whole-path limits and systems that shorten/refuse, without
  converting either into a universal conclusion.
- Give returned design an explicit Koine applicability map: supported promising
  leads, excluded choices needing a new human decision, demonstrated dead ends
  for a bounded mechanism, and precise open questions. Retain roughly 1,500-byte
  original-location/exact-copy working cases, native provenance/receipt rules,
  controls, consent posture and all action/search/review obligations.
- Credit no native action acceptance or complete production route. Do not run
  new native experiments, write implementation, adopt workflow loss or grow an
  automatic follow-on chain; the commissioned returned design consumes this
  result and owns the next concrete design or human scope decision.

## Notes

The research pair and this synthesis are the bounded commission. Preserve
meaningful disagreements even when one looks likely wrong; settle claims only
with evidence and label remaining inference.

## Decisions (running log)

- Adopt the mandated combine-research leaf in the stated jj workspace. Read the
  brief chain, glossary, both surveys in full, the prototype/route evaluation
  and the commissioning/consumer siblings. Combine-research spends no reviewer;
  the adversarial move is this session's own source work. No native probe runs.
- Correlation finding: survey A's headline (no component-array handoff; every
  cross-process handoff is a string or an fd turned back into one) restates the
  earlier prior-art survey's headline, and A's macOS id/descriptor, portal,
  gnulib and rsync material retraces that survey's leads. The A/B overlap set
  (Zed, GNU tar, CMake, GLib/Nautilus, restic, robocopy, OpenSSH, Windows
  process creation, units) is read from the *same* primary sources, mostly at
  different pins: independent readings, not independent evidence.
- Re-fetched and checked load-bearing sources myself (pinned GitHub raw, the
  GNU tar 1.35 release tarball with B's SHA-256 reproduced, Savannah cgit, the
  GitHub/Qt/GNOME issue APIs, Microsoft/Dropbox/freedesktop pages, the local
  SDK 27.0 headers). The xnu, Apple userland, libarchive, Zed (both commits),
  OpenSSH, CMake, Vim/Emacs/Electron, portal, rsync, Samba, Rust, git for
  Windows, Bazel, restic and Qt/GLib claims match their sources.
- Corrections recorded for the synthesis: GNU tar 1.35's whole-name parent
  fallback fstat()s the wrong descriptor and never adopts its reopen (fixed by
  upstream af552a07, 2026-03-10), so both surveys' description is of an attempt;
  the Go #78601 "nothing can be done at the toolchain level" quote is the
  reporter's, not a maintainer's; restic #4693 is a crash report whose skip-
  with-warning comes from the reporter's later, unreproduced follow-up; the
  OneDrive "macOS Finder 1,024 characters" row is a filesystem-level byte
  restatement in characters, not independent Finder evidence.
- Contrary sources found: public fsgetpath accepts 8,192-byte buffers without
  the long-path policy (A's descriptor/receipt rows cite only F_GETPATH);
  proc_pidpath builds up to 4,096 bytes then revalidates by whole-path kernel
  lookup; Windows DelegateExecute handlers receive a Shell item array, refuting
  A's inferred "handler is still started with a command line" as universal; the
  desktop-entry spec's temporary copy for non-local %f differs from GLib's FUSE
  substitution (A cites the spec, B the implementation). The k134 Documents
  prompt on the long component walk qualifies both surveys' within-mandate label
  for presence/cause. pthread_fchdir_np stays private (SDK only marks it so).
- Receiver wall: the reviewed long-file subject requires observing
  delivery/rendering, and every receiver whose macOS/Unix code either survey
  read (Zed GUI, Rust std, Emacs, Vim) opens by whole path. Recorded as the
  first open question for k141 (delivery versus rendering), not a decision.
- Delivered `docs/research/long-pathname-applications.md`: coverage union,
  independence table, per-claim citation checks, ten disagreement/correction
  locations, storing/operating/passing attacks, use-case comparison, and a Koine
  applicability map (retained obligations, five leads, seven excluded choices,
  five bounded dead ends, six open questions) plus unresolved silences. It
  selects no route, credits no acceptance and changes no requirement.
- `task check:docs` passed; a deliberately broken anchor in the new file made it
  fail, and the file was restored byte-identical by SHA-256 before the final
  green run. Every added external link returned 200 except GNOME GitLab
  (bot-blocked 406; issue content confirmed through its API).
- No review is cut (combine-research spends none) and none names this leaf; no
  run ID is set, so no Creator line. Node k135 keeps live k141, so retirement
  closes no node and no ADR is earned.
