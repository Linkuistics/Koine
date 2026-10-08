# Search enumeration reuses system find

Search delegates candidate enumeration to macOS system find and literal name
matching to Foundation. The client owns ranking and MRU. The
[search contract](../specs/workspace-search.md#backend-invocation-and-worker-cleanup)
keeps the adapter to command I/O, lifecycle, source coverage and native metadata.
It does not promise shallow-first order or implement a replacement walker.
This is the selected design under the human's reuse requirement, conditional on
explicit process/target-policy decisions, review and native acceptance; it does
not override the earlier custom-helper refusal.

A built-in command avoids distributing a second search engine and supplies files
and folders. It costs child-process lifecycle/TCC attribution and gives up the
custom candidate's queue order, prefix witnesses and complete-directory counters.
Native metadata still shares Koine's process and allocations. Ordinary query
reads remain prompt-free; no permission, helper, signing or resource guarantee is
inferred from reuse. The [finite comparison](../verification/search-tooling.md)
records current primary sources and the remaining decisions.

The custom FIFO traversal was rejected by the reuse requirement. Spotlight's
availability/completeness cannot be inferred from startup/count and its earlier
protected query prompted. rg's file-list mode needs another source for folders;
fd/fzf add distribution or matching/presentation policy without a current need.
Revisit if measured system-tool omissions defeat required workflows or the human
rejects its process/protection contract; do not silently ship a smaller domain.
