# Search enumeration reuses system find

Search delegates candidate enumeration to macOS system find and literal name
matching to Foundation. The client owns ranking and MRU. The
[search contract](../specs/workspace-search.md#backend-invocation-and-worker-cleanup)
keeps the adapter to command I/O, lifecycle, source coverage and native metadata.
Only individual root/policy/application targets use Koine's
[descriptor-relative resolution](filesystem-access-is-descriptor-relative.md);
the child's enumeration is the OS's fts walk, not Koine's descriptor-relative walk.
This is the selected design under the human's reuse requirement, conditional on
explicit process/target-policy, materialization and ordering decisions, review
and native acceptance. It does not override the earlier custom-helper refusal.

A built-in command avoids distributing a second search engine and supplies files
and folders. It costs child-process lifecycle/TCC attribution, unlocalized command
errors and loss of the custom queue order/prefix witnesses/directory counters.
Unsorted preorder traversal can spend the home budget in one subtree before later
shallow siblings. k196 separately chooses that explicit order limit or a returned,
reviewed find-backed shallow-pass/immediate-child source design. No workflow loss
is accepted here. Native metadata still shares Koine's blocking/allocation risks;
prune and device tests can follow metadata contact. Ordinary reads remain
prompt-free. The [finite comparison](../verification/search-tooling.md) supplies
primary sources and pending signed/native acceptance.

FileManager's directory enumerator is a concrete in-process refusal alternative:
native skip/error facilities remove pipes, child attribution, signals/reap and
orphans. Blocking enumeration cannot be killed; long-path/error and useful-order
behavior need returned design/review and measurement. libc fts is another genuine
OS reuse route, with entry identity/errno and pruning. Koine's multithreaded host
requires FTS_NOCHDIR, exposing whole-path PATH_MAX costs; changing the server's
working directory is unsuitable. Neither is the rejected custom FIFO walker or
a pre-access target-protection guarantee. A killable ordinary find child keeps
its traversal separate and allows the OS walker to change its own directory;
uninterruptible child and in-process native calls remain explicit limits.

Spotlight needs an explicitly accepted indexed-domain contract: startup/count
prove no health/completeness, and the earlier protected probe prompted. rg's file
list omits ordinary directory choices; fd/fzf add distribution/config/signing and
matching choices without a fuzzy-search need. A bespoke walker/matcher is rejected
by the human reuse requirement. Revisit the selected route if child permission,
protection or useful order is refused, through returned design and mandatory review;
never silently accept reduced home/default coverage.
