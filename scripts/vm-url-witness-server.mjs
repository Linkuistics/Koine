// Runs in the guest of scripts/vm-verify-open-url.sh, under the Node runtime the
// acceptance carries there. Test material, never shipped: the independent witness of
// what a browser was asked to open. It holds no Koine code and no client code.
//
//   node vm-url-witness-server.mjs <port> <log file>
//
// Every request is written to the log as one JSON line, with the request-target
// exactly as it arrived on the wire (the bytes after the method, before the HTTP
// version) and the Host header exactly as sent. The pages it serves report the
// browser's own account of where it is (`location.href`, hostname, pathname, search
// and hash) back to `/__report`, which is the only way the fragment, never sent to a
// server, can be observed without driving the browser's interface. `/hang` (with or without a query) answers
// nothing, for a suggestion source that never replies. The guest's /etc/hosts maps
// the witness's names to 127.0.0.1; no name here reaches the network.
import { createServer } from 'node:http';
import { appendFileSync, writeFileSync } from 'node:fs';

const [port, logPath] = process.argv.slice(2);
if (port === undefined || logPath === undefined) {
  console.error('usage: vm-url-witness-server.mjs <port> <log file>');
  process.exit(2);
}

const record = (object) =>
  appendFileSync(logPath, `${JSON.stringify({ atMs: Date.now(), ...object })}\n`);

const PAGE = `<!doctype html><meta charset="utf-8"><title>Koine URL witness</title>
<body>Koine URL witness
<script>
fetch('/__report', {
  method: 'POST',
  headers: { 'Content-Type': 'text/plain' },
  body: JSON.stringify({
    href: location.href, hostname: location.hostname, port: location.port,
    pathname: location.pathname, search: location.search, hash: location.hash,
    agent: navigator.userAgent,
  }),
});
</script>`;

createServer((request, response) => {
  // rawHeaders keeps the Host header as the browser wrote it.
  const host = request.rawHeaders.find((_, i) => i % 2 === 0 && _.toLowerCase() === 'host');
  const hostValue = host === undefined ? null : request.rawHeaders[request.rawHeaders.indexOf(host) + 1];
  if (request.url.split('?')[0] === '/hang') {
    record({ kind: 'hang', host: hostValue });
    return; // never answered
  }
  if (request.method === 'POST' && request.url === '/__report') {
    const chunks = [];
    request.on('data', (chunk) => chunks.push(chunk));
    request.on('end', () => {
      let report = null;
      try {
        report = JSON.parse(Buffer.concat(chunks).toString('utf8'));
      } catch {
        /* recorded as null */
      }
      record({ kind: 'report', host: hostValue, report });
      response.writeHead(204).end();
    });
    return;
  }
  if (request.url === '/favicon.ico') {
    response.writeHead(404).end();
    return;
  }
  record({
    kind: 'request',
    method: request.method,
    target: request.url,
    host: hostValue,
    agent: request.headers['user-agent'] ?? null,
  });
  response.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'no-store' }).end(PAGE);
}).listen(Number(port), '127.0.0.1', () => {
  // Truncated only once the port is held: a second start (the guest's exec channel can run a
  // command twice) fails to bind and must leave the first server's log alone.
  writeFileSync(logPath, '');
  record({ kind: 'listening', port: Number(port) });
});
