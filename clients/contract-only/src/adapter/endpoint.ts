import { homedir } from 'node:os';
import { join } from 'node:path';
import { readFile, stat } from 'node:fs/promises';

const SPEC_DESCRIPTOR_PATH = join(
  homedir(),
  'Library',
  'Application Support',
  'Koine',
  'endpoint.json',
);

/**
 * The contract fixes one descriptor location. The override exists only so this
 * client can be exercised against a stand-in server off a real desktop; it is
 * never consulted unless it is set, and the published path is the default.
 */
export const DESCRIPTOR_PATH = process.env['KOINE_ENDPOINT_DESCRIPTOR'] ?? SPEC_DESCRIPTOR_PATH;

export const EXPECTED_CONTRACT_VERSION = 'koine-desktop/1';

export interface EndpointDescriptor {
  readonly descriptorVersion: number;
  readonly instanceId: string;
  readonly pid: number;
  readonly port: number;
  readonly path: string;
  readonly contractVersion: string;
}

export interface Endpoint {
  readonly descriptor: EndpointDescriptor;
  /** Always built literally from 127.0.0.1 and the descriptor's port. */
  readonly url: string;
  readonly host: string;
  readonly descriptorMode: string | null;
}

export type EndpointLookup =
  | { readonly found: true; readonly endpoint: Endpoint }
  | { readonly found: false; readonly detail: string };

function isPositiveInt(value: unknown): value is number {
  return typeof value === 'number' && Number.isInteger(value) && value > 0;
}

export async function readEndpoint(): Promise<EndpointLookup> {
  let raw: string;
  let mode: string | null = null;
  try {
    raw = await readFile(DESCRIPTOR_PATH, 'utf8');
    const info = await stat(DESCRIPTOR_PATH);
    mode = (info.mode & 0o777).toString(8).padStart(3, '0');
  } catch (cause) {
    const code = (cause as NodeJS.ErrnoException).code ?? 'unknown';
    return { found: false, detail: `endpoint descriptor unreadable (${code})` };
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(raw);
  } catch {
    return { found: false, detail: 'endpoint descriptor is not JSON' };
  }
  if (typeof parsed !== 'object' || parsed === null) {
    return { found: false, detail: 'endpoint descriptor is not an object' };
  }

  const d = parsed as Record<string, unknown>;
  if (d['descriptorVersion'] !== 1) {
    return { found: false, detail: `unsupported descriptorVersion ${String(d['descriptorVersion'])}` };
  }
  if (!isPositiveInt(d['port']) || d['port'] > 65535) {
    return { found: false, detail: 'endpoint descriptor has no usable port' };
  }
  if (d['path'] !== '/graphql') {
    return { found: false, detail: `unexpected descriptor path ${String(d['path'])}` };
  }
  if (d['contractVersion'] !== EXPECTED_CONTRACT_VERSION) {
    return {
      found: false,
      detail: `descriptor states contract ${String(d['contractVersion'])}, this client speaks ${EXPECTED_CONTRACT_VERSION}`,
    };
  }

  const port = d['port'];
  const host = `127.0.0.1:${port}`;
  return {
    found: true,
    endpoint: {
      descriptor: {
        descriptorVersion: 1,
        instanceId: typeof d['instanceId'] === 'string' ? d['instanceId'] : '',
        pid: isPositiveInt(d['pid']) ? d['pid'] : 0,
        port,
        path: '/graphql',
        contractVersion: EXPECTED_CONTRACT_VERSION,
      },
      // The spec: "Clients construct the literal loopback URL; they do not
      // follow an arbitrary host or scheme from a file."
      url: `http://${host}/graphql`,
      host,
      descriptorMode: mode,
    },
  };
}
