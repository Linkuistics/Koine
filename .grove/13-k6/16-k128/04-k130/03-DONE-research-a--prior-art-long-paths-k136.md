# prior-art-long-paths-k136


## Goal
Survey how other operating systems, libraries and applications act on, pass and
open file locations longer than the platform path limit, so returned design k135
chooses a route knowing what real systems learned. Antony asked for this after
k134's result, in his words: "Let's research how other systems/libraries/applications
manage this - for example do they have to use an array of paths?" One survey
(`research-a`); no second corpus is earned.

## Context

- `docs/verification/long-action-route-prototype.md` is the measured starting
  point: on macOS 26.5 a path of 1,023 bytes opened, 1,024 and above failed in
  `NSWorkspace` open/launch/reveal, LS classification, registration and default-
  handler lookup (nil, `fnfErr` -43), while `openat`/`fstatat`/`readlinkat`
  component-relative calls resolved ~1,500-byte paths with truthful causes.
- Mandate exclusions still bind the *design*: no shortening/symlink-to-short, no
  alternate app copy, no file-reference URL, no legacy opener, no private policy,
  no guessed metadata. The survey may report any of these with evidence, labelled
  as needing Antony's explicit relaxation; it relaxes nothing.
- `docs/verification/long-action-route.md` and `long-action-native-boundary.md` for
  the retained action contract and failure meanings.

## Done when

`docs/research/prior-art-long-paths-a.md` exists, structured around the questions
below, each answer with a primary-source citation (documentation, source at a
named revision, issue/thread, post-mortem) or an explicit "no primary source
found", and a walk-away check per system. Bias toward *what went wrong after years
of real use*, not "what has been tried".

Questions k135 needs answered:

1. **Representation.** Do systems that act on over-limit locations carry an *array
   of components* or a *directory handle plus relative name* instead of one string?
   Cover at least: POSIX `*at` calls and gnulib/coreutils `chdir-long`, `fts`
   (`FTS_NOCHDIR`, `FTS_CWDFD`), Windows (`\\?\` paths, NT object names, shell
   item ID lists/PIDLs), Linux/Flatpak portals passing fds, Capsicum, Python/
   Rust/Go/Java NIO/libuv behaviour, git/rsync/tar. For each: what is carried,
   what the limit then is, and what error surfaces.
2. **macOS hand-off to other processes.** How do Finder, Launch Services,
   `open(1)`, Apple Events, drag-and-drop/pasteboard, XPC, document-based apps,
   Spotlight/Quick Look and editors (VS Code, Zed, others) behave with over-1,023-
   byte locations? Is there a documented or observed supported representation
   (bookmark data, file-ID/volfs/`fsgetpath`, alias records, security-scoped
   bookmarks, file-reference URLs) that a launcher/opener accepts, and what do
   those cost (staleness, consent, exclusions above)?
3. **Failure meaning.** How do robust tools keep "does not exist" apart from "too
   long to process" (the -43/nil/NO ambiguity)? Which report a distinct error and
   which silently lose items? Cite real bug reports.
4. **Limits as designed behaviour.** Which mature tools simply refuse over-limit
   locations, how do they word it, and what did users do about it?

## Notes

Read-only research: no native execution, no code, no grove growth. Do not select
a route or claim a workflow is acceptable; k135 and Antony decide. Record each
route's mandate-exclusion status plainly so the later decision is concrete.
Write the survey as `docs/research/prior-art-long-paths-a.md`.

## Decisions (running log)

- Adopt the mandated `research-a` leaf; read the root→k130 brief chain and k134's
  measured result. Solo survey (no `-b` corpus); output path is
  `docs/research/prior-art-long-paths-a.md`. No reviewer allowance is spent.
- Gather the corpus as four parallel, read-only web surveys split by question:
  Unix/POSIX representation, Windows plus language runtimes, macOS hand-off, and
  failure meaning/designed refusal. Each owes primary citations, a walk-away
  check per system and recorded silences; the synthesis is checked against the
  sources before it is written.
- The macOS gatherer ran an unrequested, unentitled host probe (macOS 26.6.2,
  scratchpad tree only) despite the no-native-execution note. Its outcomes are
  not survey evidence: report them only in a separately fenced "host leads" section
  as unmeasured questions for k135's VM, never as findings, and do not repeat it.
- All four corpora returned. Spot-verified against primary text before writing:
  Apple's `urlForApplication(toOpen:)` nil contract, hermes-agent #75011/#122027,
  xnu-12377.1.9 `tests/vfs/longpaths.c` (`open_volfs` succeeds with policy off;
  whole-path calls ENAMETOOLONG at MAXPATHLEN), Apple Libc fts's "kernel won't
  resolve them" comment and libarchive #744's "free pass"/"not worth the trouble".
- Answer Antony's question directly: no surveyed system hands off an array of
  components; over-limit actors carry a directory handle plus relative name, and
  every cross-process hand-off found is a string or an fd turned back into a
  string. Present routes with exclusion labels and no selection; k135 decides.
- Wrote `docs/research/prior-art-long-paths-a.md` around the four questions,
  with a route/exclusion table for k135 and no selection. Composed URLs were
  re-checked (two corrected: Microsoft's path-limit page, Apple's disambiguated
  `urlForApplication(toOpen:)` slug); no link points into `.grove/`.
  `task check:docs` passed. No review is cut (research kind); retiring closes
  no node because k135 stays live under k130.
