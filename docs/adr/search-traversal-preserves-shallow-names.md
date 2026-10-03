# Search traversal preserves shallow names

Per-root FIFO breadth-first traversal finishes shallower admitted listings
before deeper names with one current stream and a bounded pending queue.
Frontier overflow counts observed matchable anchors in one reserved root group
and continues sibling examination; it omits descendants. This ordering and
public omission contract affect what clients can find under fixed work/wait
bounds and are costly to reverse after workflow acceptance. The
[search contract](../specs/workspace-search.md#resource-accounting-and-scheduling)
owns exact order, charges, revalidation and subjects.

Held-stream DFS loses later shallow names inside an enormous early branch and
requires too many descriptors for the shared process. Iterative deepening
repeats shallower name listings against entry and wait budgets. FIFO lists names
once, but each depth-k dequeue repeats k checked component opens and canonical
checks; chains therefore still have quadratic prefix work, charged to wait and
scratch. Turn checks add work too. The queue costs retained paths and can omit
descendants in wide trees. A large listing at one depth can cut that level short
and starve later same-level names or listings; shallow order alone is not useful
workflow coverage.

These are visible trade-offs awaiting measured per-witness acceptance, not an
accepted sample or a smaller domain. Revisit when measured frontier, same-level,
entry or repeated-walk deadline omissions defeat the workflow and a bounded
alternative gives better coverage without larger budgets or unapproved setup.
The [discovery obligations](../specs/workspace-search.md#discovery-obligations-before-planning)
keep native canonical-path/resource design, their reviews and normally launched
host evidence live before planning and acceptance.
