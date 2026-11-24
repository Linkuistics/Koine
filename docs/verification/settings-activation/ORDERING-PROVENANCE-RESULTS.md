# Ordering clone provenance results

Leaf `settings-clone-provenance-k180` gives the k54 freeze a harness that binds
each guest transport to its exact clone. This record states what the harness
does, which control shows each refusal, and what stays open. No guest, clone or
golden build ran.

## The duty

Finding P3-3 of the
[exec evidence review](../../../.grove/11-k12/28-k36/03-DONE-review-impl--settings-exec-evidence-k58.md)
showed that a receipt named neither the CLI binary nor the agent endpoint. The
adapter ran the bare name `testanyware`, which `PATH` resolved. A stale spec file
with the same VM name stayed invisible. k59 assigned the correction to the k54
freeze. The k54 task found that the freeze alone cannot meet it, because the
binding must act in the transport path.

## How TestAnyware 3.0.0 finds an endpoint

These facts come from the tagged source.

- On a macOS host, each guest stream goes through the TestAnyware app. For a
  `--vm` ID, the app reads `<state_dir>/vms/<id>.json` itself
  ([streams.rs](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-app/src/streams.rs)).
- The CLI sends its own state directory with each request. The app refuses a
  request when that directory differs from its own
  ([error.rs](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-app-protocol/src/error.rs)).
  Thus the spec that the CLI resolves is the spec that the app reads.
- The state directory is `$XDG_STATE_HOME/testanyware`, then the `state_dir` of
  `config.rhai`, then `$HOME/.local/state/testanyware`
  ([paths.rs](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-vm/src/paths.rs)).
  `TESTANYWARE_CONFIG` names another file, and `none` disables the file
  ([location.rs](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-config/src/location.rs)).
- `vm start` writes the spec once, with an atomic rename. Only a kept failure or
  an adoption writes it again
  ([lifecycle.rs](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-vm/src/lifecycle.rs)).

The configuration file is a Rhai script. The harness does not evaluate Rhai. It
accepts an absent or disabled file, or a file of comments around one empty map.
Rhai 1.26.1, the locked version, nests block comments
([tokenizer.rs](https://docs.rs/crate/rhai/1.26.1/source/src/tokenizer.rs)). The
host file holds only comments and an empty map, so the built-in directory
applies.

## What the harness does now

### The declared executables

The caller declares `KOINE_TESTANYWARE_CLI` and `KOINE_JQ` before `init`. Each
value is the absolute path of a regular, runnable file that is not a symbolic
link. `init` records the path, size, SHA-256, device and inode of each file in
`subject.json`. It refuses a missing declaration and creates no root.

Each later attempt runs those two paths. No attempt searches `PATH`. Before each
dispatch, the adapter reads both files again. A changed identity refuses the
attempt as unavailable, and the refusal latches. The receipt `request.json` names
the CLI in `argv[0]` and the jq in its `jq` field. A checked read runs no jq, so
its receipt has no `jq` field.

The strict scenario also runs its local `jq` decisions through `KOINE_JQ`. The
caller's own facades use `jq` only to format a stop argument, and the adapter
checks that argument.

### The clone provenance

`settings_start_vm` records the provenance after the `vm-after` inventory and
before the `system` read. The backend verb `provenance ROOT OPERATION` is a host
file read, not a guest transport. It writes `provenance.json` in the root once,
with these fields:

| Field | Content |
|---|---|
| `vm` | The clone ID of the root |
| `spec` | The spec path, its size, SHA-256, device and inode |
| `agent` | The host and port of the spec's `agent` section |
| `state_dir`, `state_source` | The resolved state directory, and `XDG_STATE_HOME` or `default` |
| `config` | The configuration path, its state (`absent`, `empty` or `disabled`) and its SHA-256 |
| `environment` | `HOME`, `XDG_STATE_HOME`, `TESTANYWARE_CONFIG` and `TESTANYWARE_APP_SOCKET` |
| `ordinal` | The ordinal of the provenance attempt |

A guest transport is an attempt whose pinned options carry `--vm`. The `vm`
family and the host-only steps are not guest transports. Before each guest
transport, the adapter resolves the spec again and compares every field. A
missing, changed or different spec refuses the attempt as unavailable, and the
refusal latches. This rule also covers evidence collection after a latch,
because collection reaches the guest. The exact `vm stop` still runs.

After a `vm start` attempt, a guest transport without a provenance record also
refuses. The provenance step itself refuses before a start, after a guest
transport and on a second record.

### The finite caller

The readiness receipt now names the two executables as input trees `testanyware`
and `jq`. Each tree is one regular file. A new field, `testanyware_paths`, holds
the absolute `state_dir` and `config` paths. The existing tree audit digests the
executables before admission and after the slot. A changed executable holds the
sequence before admission.

The run passes the two tree roots to the scenario as `KOINE_TESTANYWARE_CLI` and
`KOINE_JQ`. After the slot, `provenance_check` compares the root with the freeze.
It requires these facts:

- `subject.json` names the frozen path, size and SHA-256 of each executable.
- Each attempt ran the frozen CLI and, where it ran jq, the frozen jq.
- One clean provenance attempt follows a VM start and precedes every guest
  transport.
- The record names the clone, the frozen state and configuration paths, and the
  spec path under that state directory.

The `subject` phase includes this check, and `audits.json` keeps its detail.
Thus a slot without a valid record cannot qualify. A recurrence cannot reject
the repair either, because a recurrence needs a passed `subject` phase.

## Controls

Each refusal has a control whose record shows the failure.

| Refusal | Control |
|---|---|
| Undeclared, relative, linked or unrunnable executable at `init` | `init refuses an undeclared, relative, linked or non-executable tool and creates no root (k180)` |
| The receipt names the executables that ran | `each attempt runs the declared executables and its receipt names them (k180)` |
| Changed, replaced or missing executable | `a changed, replaced or missing executable refuses the attempt before dispatch and latches (k180)` |
| One record, with its fields | `the clone provenance records the spec, its digest, the endpoint and the resolving paths once (k180)` |
| Provenance before a start or after a guest transport | `provenance refuses before a VM start and after a guest transport (k180)` |
| Guest transport without a record | `a guest transport after a VM start needs a provenance record, and VM lifecycle does not (k180)` |
| Missing, changed or different spec | `a missing, changed or different spec refuses the next guest transport and latches (k180)` |
| Configuration, socket, relative path, no `HOME` or no agent | `a configuration or environment that the harness cannot evaluate refuses the provenance (k180)` |
| Scenario order and declared jq | `the scenario records the clone provenance between the inventory and the first guest read, with the declared jq (k180)` |
| Failed provenance stops the scenario | `a failed clone provenance stops the scenario, and only the failure screenshot follows (k180)` |
| Receipt without the executables or paths | `a receipt without both executables or the TestAnyware paths refuses the run before admission (k180)` |
| The run passes the frozen executables | `the run passes the frozen executables, and a qualifying slot names them and its provenance (k180)` |
| Changed executable before admission | `a changed executable holds the sequence before admission (k180)` |
| Slot without a record | `a slot without a provenance record cannot qualify (k180)` |
| Other paths, CLI or jq | `a provenance on other frozen paths or a scenario on another CLI fails the subject (k180)` |
| Receipt order | `a guest transport ordered before the provenance record fails the provenance audit (k180)` |

The first ten controls are in `Tests/scripts/vm-guest-exec.bats` and
`Tests/scripts/vm-settings-scenario.bats`. The others are in
`Tests/scripts/vm-settings-audits.bats`.

The [mutation script](ordering-provenance-evidence/mutations.sh) breaks each
guard in a copy of the tree and runs its controls. Its
[record](ordering-provenance-evidence/mutations.txt) shows that a control fails
for each mutation. The
[final verification](ordering-provenance-evidence/final-verification.txt) runs
the affected Taskfile checks and the closed ledger check once. Each record has a
receipt with the digests of every tracked file before and after the run.

## Ledger recheck

85 ledger rows cite source inside a function that this leaf changed. The change
adds refusals and records, and it removes no behaviour that a row cites. Each
note still holds, and each cited control still passes in the final verification.
Row D019 now also cites the receipt control above, because a receipt now names
the CLI that ran. `task check:settings-duty-ledger -- --require-closed` passes.

The baseline check, `check-settings-baseline.py`, now declares both executables
for its scenario run. It still finds 17 cases and 0 findings, so the provenance
step changes no compared input, wait or assertion.

## Limits

- A check and the dispatch that follows it are two steps. An executable or a spec
  that changes between them is not refused. The next attempt refuses it.
- The harness accepts only a configuration file of comments around an empty map.
  A file with any setting refuses every provenance. A setting then needs an
  owner decision and a harness change.
- Each dispatch now digests the 21 MB CLI first. On this host that took about
  20 ms. No sleep, read count or poll bound changed.
- The record binds the endpoint that the spec names. It cannot show that the
  guest at that endpoint is the clone. The app reads the same spec, so the two
  agree.
- The harness records no version strings. The SHA-256 binds each binary, and k54
  records the versions at the freeze.
- The Task executable is outside this change. k54 pins it.
