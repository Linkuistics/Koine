# Pre-copyout admission source manifest

This assessment uses Apple XNU commit
`f6217f891ac0bb64f3d375211650a4c1ff8ca1ea` and the installed macOS 27.0 SDK.
It does not identify that source revision with the running 25F71 kernel.
The [report](../native-observation-receive.md#pre-copyout-admission-assessment)
states the bounded conclusions and remaining native controls.

Download each source from
`https://raw.githubusercontent.com/apple-oss-distributions/xnu/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/`
plus the path below. Hashes in [admission-primary.sha256](admission-primary.sha256)
use those logical paths. Preserve line endings; compare SHA-256 before relying
on line coordinates. The SDK entry uses its absolute installed path.

| Source | Inspected range / subject |
|---|---|
| `osfmk/mach/message.h` | 1028–1184 receive flags and scalar/vector option definitions; no claim to a complete API survey |
| `osfmk/mach/port.h` | 349–410 status/limits types: queue limit is a message count |
| `osfmk/ipc/mach_port.c` | 928–1030 `mach_port_peek`, parameter validation and returned metadata |
| `osfmk/ipc/ipc_mqueue.c` | 431–475 `ipc_mqueue_send_locked`; 1143–1230 `ipc_mqueue_peek_locked` |
| `osfmk/ipc/ipc_kmsg.c` | 2260–2505 OOL/port-array input; 2820–2875 copyin dispatch; 3803–4144 mapping, port import, descriptor copyout and body-error accumulation |
| `osfmk/ipc/mach_msg.c` | 290–382 receive result ownership; 405–460 vector validation |
| `libsyscall/mach/mach_msg.c` | 175–270 overwrite wrapper, unused scatter size and inline/auxiliary vectors |
| Installed SDK `usr/include/mach/message.h` | 710–790 receive options/trailer definitions; overwrite value zero |

The requirements session subsequently checked one named enforcement candidate,
`MPO_FILTER_MSG`, against the same revision:

| Source | Inspected range / subject |
|---|---|
| `osfmk/mach/port.h` | 468–550 construction flags and options; no byte/right quota in this options structure |
| `osfmk/ipc/mach_port.c` | 2520–2640 construction and connection-label derivation with `MPO_FILTER_MSG` |
| `osfmk/kern/mach_filter.h` | Complete header; kernel-private callback interface and its arguments |
| `osfmk/ipc/ipc_policy.c` | 737–803 message-ID filter; 969–978 conditional invocation |

The reused port header and construction-source hashes match the original
manifest. The two new source hashes are included below those original entries
in `admission-primary.sha256`. This check ran no native code and neither
establishes a resource-enforcement mechanism nor surveys every policy path.

The earlier k102 primary digests match the three reused receive/copyout/wrapper
files item by item. Additional files were downloaded from the same pinned
revision. This is source inspection only; no kernel resource ceiling, API
availability or production policy is inferred from absence in a search result.

Repository graph verification used Tier 2 at generation
`2026-09-23T11:33:44Z`: the k102 probe's `run_case` was read exactly, its inbound
`main` and four graph callees were returned without pagination. Coverage for
the probe and consumed reports had matching metadata and no recorded gap.
The diagram source was marked not-tracked by the graph and was read directly.
Downloaded kernel source is outside the repository graph and was read directly;
the graph supplies no evidence about the running kernel.
