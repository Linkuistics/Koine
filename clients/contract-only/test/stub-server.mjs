/**
 * A stand-in for Koine that answers exactly the wire shapes the contract
 * describes, so the adapter's classification rules can be exercised without a
 * running Koine. It is not a second implementation of the contract: every
 * response below is transcribed from the spec's own tables.
 */
import { createServer } from 'node:http';
import { mkdtemp, writeFile, readFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const introspection = await readFile(join(here, '../capture/introspection.json'), 'utf8');
const capture = JSON.parse(await readFile(join(here, '../capture/capture.json'), 'utf8'));

export async function startStub(behaviour) {
  const server = createServer((req, res) => {
    let body = '';
    req.on('data', (c) => (body += c));
    req.on('end', () => {
      const request = body.length > 0 ? JSON.parse(body) : {};
      const auth = req.headers['authorization'] ?? null;
      const answer = behaviour({ request, auth, headers: req.headers });
      res.writeHead(answer.status, {
        'Content-Type': 'application/graphql-response+json',
        'Cache-Control': 'no-store',
        ...(answer.headers ?? {}),
      });
      res.end(answer.body === undefined ? '' : JSON.stringify(answer.body));
    });
  });
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const { port } = server.address();
  const dir = await mkdtemp(join(tmpdir(), 'koine-stub-'));
  const descriptor = join(dir, 'endpoint.json');
  await writeFile(
    descriptor,
    JSON.stringify({
      descriptorVersion: 1,
      instanceId: 'stub-instance',
      pid: process.pid,
      port,
      path: '/graphql',
      contractVersion: 'koine-desktop/1',
    }),
    { mode: 0o600 },
  );
  return { descriptor, port, capture, introspection, close: () => server.close() };
}
