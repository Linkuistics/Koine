# settings-clone-provenance-k180

## Goal

Bind each guest transport of a Settings ordering slot to the provenance of its
exact clone. Also run every attempt through the frozen CLI and jq executables.
k54 needs this harness change before it freezes a subject.

## Context

The duty is P3-3 of the k58 review. See
`.grove/11-k12/28-k36/03-DONE-review-impl--settings-exec-evidence-k58.md`.
k59 assigned it to the k54 freeze, and not to the exec seam. No later leaf
implemented it. The k171 duty ledger has no row for it, because the duty lives in
the k54 task file and not in the eight archived contracts.

The first item of the k54 `Done when` states the duty. Its parts:

- Freeze the absolute paths, versions and hashes of the CLI and jq executables.
- Freeze the effective TestAnyware state and configuration paths.
- After each declared clone exists, record its provenance before its first guest
  transport. The provenance is the exact VM spec path, its content digest and the
  resolved agent endpoint.
- Bind each attempt's VM to that provenance, and reject a stale or changed
  mapping. A bare argv VM name is not endpoint provenance.
- Use the frozen binaries and environment. Audit them and the per-clone mapping
  afterwards. Clone creation supplies no exec success.

k54 owns the freeze itself. This leaf gives k54 a harness that can carry it out.

TestAnyware 3.0.0 resolves `--vm <id>` to the spec file
`<state>/testanyware/vms/<id>.json`. The state directory comes from
`XDG_STATE_HOME`, then from the `state_dir` of `config.rhai`, then from the host
default. See `vms_dir` in
[resolve.rs](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/resolve.rs).
The spec file holds an `agent` section. Read the tagged source with
`git -C ../TestAnyware.gh-issue-13 show v3.0.0:<path>`. Another session owns that
worktree, so do not edit it.

On this host, the configuration file is `~/.config/testanyware/config.rhai`, and
the spec directory is `~/.local/state/testanyware/vms`. Check both against the
resolver. Do not assume them.

These are the code coordinates on 2026-11-24:

- `scripts/vm-guest-exec.py` builds each argv with the bare name `testanyware`,
  near lines 371 to 381 and 428 to 435.
- `settings_start_vm` in `scripts/vm-settings-scenario-lib.sh` runs the
  `vm-before` inventory, the start and the `vm-after` inventory. The first guest
  transport follows, the `system` read near line 319.
- `scripts/settings-ordering-sequence.py` audits each slot and settles it. Its
  `environment` and `audit` phases are the likely owners of the audit after the
  slot.

## Done when

- Each attempt runs the CLI and jq through absolute paths that the caller
  declares. A missing or changed executable refuses the attempt before dispatch.
  The record of each attempt names the path that ran.
- After the `vm-after` inventory and before the first guest transport, the
  harness records the provenance of the clone once, in the evidence root. The
  record holds the spec path, its SHA-256, the agent endpoint and the state and
  configuration paths that resolved it.
- Before each later guest transport of the slot, the harness checks the spec
  against that record. A missing, changed or different spec refuses the attempt
  as unavailable, and it latches like any other failed transport.
- A slot without a valid provenance record cannot qualify. After the slot, the
  finite caller audits the record and the executables against the frozen values.
- The change adds no guest read, wait, retry or wider tolerance. The protocol's
  input order, read counts, sleeps and poll bounds stay unchanged. A spec check is
  a host file read, not a guest transport.
- Each refusal has a control with a failing record, and the guards have mutation
  evidence in the house form.
- The affected Taskfile checks pass, including `check:vm-guest-exec` and
  `check:vm-settings-sequence`. `task check:settings-duty-ledger -- --require-closed`
  passes. Recheck each ledger row whose source or control changed.
- The change touches a transport and an evidence class. Cut a `review-impl` leaf
  for this handle before k54.

## Notes

Start no guest, clone or golden build. The k54 log settles the golden image and
the guest release. Leave the historical evidence, subjects and caps unchanged.

If the tagged resolver makes a strict binding impossible, ask the owner. Do not
weaken the duty.

## Decisions (running log)

- 2026-11-24, source: on a macOS host, TestAnyware 3.0.0 sends each guest
  stream through its app. For a `--vm` ID, the app reads
  `<state_dir>/vms/<id>.json` itself, in `streams.rs`. The CLI sends its own
  state directory with each request. The app refuses a request when that
  directory differs from its own, in `incompatible_directories` of `error.rs`.
  Thus the spec path that the CLI resolves is also the path that the app reads.
- 2026-11-24, source: `VmPaths::from_env_and_file` of `paths.rs` gives the state
  directory. It is `$XDG_STATE_HOME/testanyware`, then the `state_dir` of
  `config.rhai`, then `$HOME/.local/state/testanyware`. `vm start` writes the
  spec once with `write_atomic`. Only a kept failure or an adoption writes it
  again.
- 2026-11-24, decision: the harness does not evaluate Rhai. It accepts an absent
  or disabled configuration file, or a file that holds only comments and one
  empty map. Each other file refuses the attempt. The host file is only
  comments and an empty map. A non-empty `TESTANYWARE_APP_SOCKET` also refuses,
  because another app can read other directories.
- 2026-11-24, decision: the caller declares the executables in
  `KOINE_TESTANYWARE_CLI` and `KOINE_JQ` before `init`. `init` refuses a missing,
  relative, symbolic-link or non-executable path, and it records each identity
  in `subject.json`. No attempt falls back to `PATH`. Before each dispatch, the
  adapter compares the path, size, SHA-256, device and inode. It ignores the
  times, because a metadata change alone does not change the executable.
- 2026-11-24, decision: a guest transport is an attempt whose argv carries
  `--vm`. The `vm` family and the host-only steps are not guest transports. After
  a `vm start` attempt, a guest transport without a provenance record refuses.
  The caller's `subject` phase also requires a valid record, so the slot cannot
  qualify, and a recurrence cannot reject the repair, without one.
- 2026-11-24, decision: the frozen receipt names the two executables as input
  trees `testanyware` and `jq`, and the state and configuration paths in
  `testanyware_paths`. The existing tree audit then digests the executables
  before admission and after the slot. The run passes the two roots to the
  scenario.
- 2026-11-24, decision: the strict scenario also runs its local `jq` decisions
  through the declared jq, because a local predicate decides a clean false state.
  The caller's facades keep the `jq` on `PATH`. They use it only to format the
  stop argument, and the adapter refuses any other stop argument.
- 2026-11-24, observation: after a failed provenance, the scenario still asks for
  its failure screenshot. That collection reaches the guest, so the adapter
  refuses it too. A latch admits collection, but it does not admit an unbound
  guest transport.
- 2026-11-24, decision: `check-settings-baseline.py` declares both executables for
  its scenario run. The baseline comparison still finds 17 cases and 0 findings,
  so the provenance step changes no compared input, wait or assertion.
- 2026-11-24, observation: the first mutation run missed six of 36 mutations.
  Five cases of the configuration control failed on a configuration file that
  an earlier case left behind. The second-record case failed on the earlier
  guest transport guard. Each case now starts from a clean file, and the second
  record precedes any guest transport. The second run detected all 36.
