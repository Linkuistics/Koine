# callback-publication-generator-envelope-k271

## Goal
Add the scaling parameters to the generator: rows per lane, target activities
and members, commits and their begins, and sampler acquisitions. Check every
generated history against the envelope.

## Context
The k265 brief (Done when, envelope bullet). The k269/k270 generator and its
recipes. `lane_violations`, `ENVELOPE`, `ENVELOPE_ROWS` and the /2 kind
maxima in publication_profile.py.

## Done when
- Each parameter has a stated insertion rule, and recipes pick up the added
  rows by rule, never by count. For example, each added B activity issues its
  four comparisons and its membership query.
- Every generated history passes `lane_violations` and the /2 kind maxima.
  A deliberate over-cap vector is refused, and the violation is named.
- An over-cap lane is a mutation the census catches. The census is green
  under evidence/k254.

## Decisions (running log)
- The scaling parameters join k270's `Vector`, so one vector carries the whole
  history: `rows`, `activities`, `members`, `commits`, `begins` and
  `acquisitions`. Semantic parameters insert producer records into the base
  history, and each role's seqs are renumbered. The unchanged recipes read the
  added rows through `History` by event and position, never by count.
  Transport parameters (added frames) are emitted by the lift.
- Insertion rules. rows: an app's added rows are neutral `scaled` semantic
  records just before its `end`, and no recipe reads that event. The
  supervisor's added rows are local rows before its lane end. activities /
  members: `activity` records, then `input` records with fresh unique markers,
  just before the target's `closed` (inside its window). acquisitions:
  `acquire` records just after the sampler's last base acquire, so the hint
  chain still picks the base acquire. commits/begins: at an app's `end`, each
  added commit is a frame to the supervisor itself (commit, `begins` begin and
  result pairs, complete), with its receipt on the supervisor lane. It is
  unrelayed, so it carries no join. No parameter adds a relay, so supervisor
  commits stay at the base's.
- Stated per-row rates, which the census checks as recipe deltas: an
  activity issues 4 comparisons and 1 membership. A member issues 1
  membership and 1 input reply. An acquisition issues 1 acquire→f_begin.
  Rows, commits and begins issue no query.
- Kinds are physical events (commit, begin, result, complete, receipt,
  semantic, else local). A producer `receive` is a receipt row, as in the
  clean file. The generated kinds must equal each oracle file's event census.
- The envelope check is passed in, as `select` is. `envelope_violations` in
  the profile is `lane_violations` per owner plus the case caps stress_fit
  already applied (commit, begin, result, receipt), factored out and shared.
  `generate` raises `Refused(violations)` when given the check.
- Checked vectors. The six path-control vectors, every mutant, "one of each"
  and "at the caps" all generate under the envelope. At the caps, controller
  semantic is 257, B commit 81 and B begin 606 (cap 641), giving 2,228
  vertices, 493 queries and 38,444 / 38,444. Five over-cap vectors are refused
  with the named violation: controller semantic 258 > 257, B commit 82 > 81,
  B begin 66 > 63 (nine per commit), case commit 162 > 161 (case receipt
  162 > 161 comes with it, since every added commit has one receipt), and
  supervisor has 2049 rows. The case begin/result caps are unreachable alone,
  because the case commit cap binds first at nine begins per commit.
- Controls seen to fail, run in-process on the unedited files. Dropping the
  case maxima admits "case commits". Admitting everything admits all five.
  A lift that ignores `begins` admits "B begins per commit". Comparisons that
  skip added activities, or acquisitions that are not inserted, break the
  recipe-delta rate check on both scaled vectors.
- The file-kinds check shares `KIND` with the lift. It checks the lift's rows
  per event against the loader's, not the mapping itself, which is the
  definition. The only census change outside `path_generator` is the
  selector's wall-clock timing field (3.47 s to 3.5 s). The k253 record keeps
  digest b1d4e0e2.
