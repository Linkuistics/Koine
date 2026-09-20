import { createHash, randomBytes } from 'node:crypto';
import { chmod, mkdir, readFile, stat, writeFile } from 'node:fs/promises';
import { dirname } from 'node:path';

/**
 * The spec allows "a user-only credential file when Keychain access is
 * impractical", which is what a non-interactive CLI is. The file holds the
 * unpadded base64url secret and nothing else, so rerunning any command reuses
 * one identity: the first run mints it, every later run reads it back.
 */
export interface Credential {
  readonly secret: string;
  readonly digest: string;
  readonly created: boolean;
  readonly mode: string;
}

const UNPADDED_BASE64URL = /^[A-Za-z0-9_-]{43}$/;

export function digestOf(secret: string): string {
  const decoded = Buffer.from(secret, 'base64url');
  if (decoded.byteLength !== 32) {
    throw new Error('stored bearer secret does not decode to 32 bytes');
  }
  return createHash('sha256').update(decoded).digest('hex');
}

const cache = new Map<string, Promise<Credential>>();

/** Memoised so one process reports one truthful `created` flag for one path. */
export function loadOrCreateCredential(path: string): Promise<Credential> {
  const hit = cache.get(path);
  if (hit !== undefined) return hit;
  const pending = mintOrRead(path);
  cache.set(path, pending);
  return pending;
}

async function mintOrRead(path: string): Promise<Credential> {
  const found = await readCredential(path);
  if (found !== null) return found;

  const secret = randomBytes(32).toString('base64url');
  await mkdir(dirname(path), { recursive: true, mode: 0o700 });
  try {
    // `wx` so two concurrent runs (the harness repeats timed-out commands)
    // cannot mint two identities into one file; the loser reads the winner's.
    await writeFile(path, `${secret}\n`, { mode: 0o600, flag: 'wx' });
  } catch (cause) {
    if ((cause as NodeJS.ErrnoException).code !== 'EEXIST') throw cause;
    const raced = await readCredential(path);
    if (raced === null) throw cause;
    return raced;
  }
  await chmod(path, 0o600);
  const info = await stat(path);
  return {
    secret,
    digest: digestOf(secret),
    created: true,
    mode: (info.mode & 0o777).toString(8).padStart(3, '0'),
  };
}

async function readCredential(path: string): Promise<Credential | null> {
  try {
    const existing = (await readFile(path, 'utf8')).trim();
    if (!UNPADDED_BASE64URL.test(existing)) {
      throw new Error(
        'credential file does not hold 256 random bits as unpadded base64url; refusing to overwrite it',
      );
    }
    await chmod(path, 0o600);
    const info = await stat(path);
    return {
      secret: existing,
      digest: digestOf(existing),
      created: false,
      mode: (info.mode & 0o777).toString(8).padStart(3, '0'),
    };
  } catch (cause) {
    if ((cause as NodeJS.ErrnoException).code !== 'ENOENT') throw cause;
    return null;
  }
}
