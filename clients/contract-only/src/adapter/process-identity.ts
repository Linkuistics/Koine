import { execFile } from 'node:child_process';
import { mkdtemp, writeFile, rm, access, mkdir } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { promisify } from 'node:util';

const run = promisify(execFile);

/**
 * `DesktopProcessIdentity` is a positive pid plus `startedAt`, "the process
 * start instant in canonical UTC with six fractional second digits", and the
 * provider "compares both before resolving". Nothing in the contract says how a
 * client on macOS obtains that instant, and the precision it demands is finer
 * than any documented macOS command-line tool reports. See GAPS.md.
 */
export type StartedAtSource = 'helper' | 'ps' | 'literal';

export interface ProcessIdentity {
  readonly pid: number;
  readonly startedAt: string;
  readonly startedAtSource: StartedAtSource;
  /** Seconds of resolution actually available from that source. */
  readonly startedAtPrecision: 'microsecond' | 'second';
  readonly notes: readonly string[];
}

/** Uses libproc's PROC_PIDTBSDINFO, whose start time is a struct timeval. */
const HELPER_SOURCE = `#include <libproc.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char **argv) {
  if (argc != 2) return 2;
  pid_t pid = (pid_t)atoi(argv[1]);
  struct proc_bsdinfo info;
  int n = proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, PROC_PIDTBSDINFO_SIZE);
  if (n != PROC_PIDTBSDINFO_SIZE) return 1;
  printf("%llu %llu\\n", (unsigned long long)info.pbi_start_tvsec,
         (unsigned long long)info.pbi_start_tvusec);
  return 0;
}
`;

const HELPER_DIR = join(tmpdir(), 'koine-client-helper-v1');
const HELPER_BIN = join(HELPER_DIR, 'procstart');

export function formatInstant(seconds: number, micros: number): string {
  const iso = new Date(seconds * 1000).toISOString();
  return `${iso.slice(0, 19)}.${String(micros).padStart(6, '0')}Z`;
}

async function helperPath(notes: string[]): Promise<string | null> {
  try {
    await access(HELPER_BIN);
    return HELPER_BIN;
  } catch {
    /* not built yet */
  }
  let scratch: string | null = null;
  try {
    await mkdir(HELPER_DIR, { recursive: true, mode: 0o700 });
    scratch = await mkdtemp(join(tmpdir(), 'koine-helper-'));
    const source = join(scratch, 'procstart.c');
    const output = join(scratch, 'procstart');
    await writeFile(source, HELPER_SOURCE, 'utf8');
    await run('/usr/bin/cc', ['-O2', '-o', output, source], { timeout: 30_000 });
    await run('/bin/mv', ['-f', output, HELPER_BIN], { timeout: 10_000 });
    notes.push('compiled the libproc start-time helper on first use');
    return HELPER_BIN;
  } catch (cause) {
    notes.push(
      `no libproc helper available (${(cause as Error).message.split('\n')[0] ?? 'unknown'}); falling back to ps`,
    );
    return null;
  } finally {
    if (scratch !== null) await rm(scratch, { recursive: true, force: true });
  }
}

async function viaHelper(pid: number, notes: string[]): Promise<ProcessIdentity | null> {
  const bin = await helperPath(notes);
  if (bin === null) return null;
  try {
    const { stdout } = await run(bin, [String(pid)], { timeout: 10_000 });
    const [secs, micros] = stdout.trim().split(/\s+/);
    if (secs === undefined || micros === undefined) return null;
    return {
      pid,
      startedAt: formatInstant(Number(secs), Number(micros)),
      startedAtSource: 'helper',
      startedAtPrecision: 'microsecond',
      notes,
    };
  } catch {
    notes.push(`libproc helper could not read pid ${pid}`);
    return null;
  }
}

async function viaPs(pid: number, notes: string[]): Promise<ProcessIdentity | null> {
  try {
    const { stdout } = await run('/bin/ps', ['-p', String(pid), '-o', 'lstart='], {
      timeout: 10_000,
    });
    const text = stdout.trim();
    if (text === '') return null;
    const millis = Date.parse(text);
    if (Number.isNaN(millis)) {
      notes.push(`could not parse ps lstart output ${JSON.stringify(text)}`);
      return null;
    }
    notes.push(
      'ps reports whole seconds only; the six fractional digits are zeros and may not match the instant Koine captured',
    );
    return {
      pid,
      startedAt: formatInstant(Math.floor(millis / 1000), 0),
      startedAtSource: 'ps',
      startedAtPrecision: 'second',
      notes,
    };
  } catch {
    return null;
  }
}

export async function captureProcessIdentity(pid: number): Promise<ProcessIdentity | null> {
  const notes: string[] = [];
  return (await viaHelper(pid, notes)) ?? (await viaPs(pid, notes));
}

export interface ApplicationCandidate {
  readonly pid: number;
  readonly command: string;
  readonly tier: number;
}

/**
 * Resolves a display name to a running process. The contract says a client
 * "captures both at interaction start" and never says how it finds the
 * application; this is entirely client-owned guesswork over `ps`.
 */
export async function findApplication(name: string): Promise<readonly ApplicationCandidate[]> {
  const { stdout } = await run('/bin/ps', ['-Ao', 'pid=,comm='], {
    timeout: 15_000,
    maxBuffer: 16 * 1024 * 1024,
  });
  const wanted = name.toLowerCase();
  const bundleFragment = `/${wanted}.app/contents/macos/`;
  const candidates: ApplicationCandidate[] = [];

  for (const line of stdout.split('\n')) {
    const match = /^\s*(\d+)\s+(.*)$/.exec(line);
    if (match === null) continue;
    const pid = Number(match[1]);
    const command = (match[2] ?? '').trim();
    if (pid === process.pid || command === '') continue;
    const lower = command.toLowerCase();
    const base = lower.slice(lower.lastIndexOf('/') + 1);

    let tier = -1;
    if (lower.includes(bundleFragment) && base === wanted) tier = 0;
    else if (lower.includes(bundleFragment)) tier = 1;
    else if (base === wanted) tier = 2;
    else if (base.startsWith(wanted)) tier = 3;
    if (tier < 0) continue;
    candidates.push({ pid, command, tier });
  }

  candidates.sort((a, b) => a.tier - b.tier || a.pid - b.pid);
  return candidates;
}
