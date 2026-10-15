/**
 * Stand-ins for the things `search` may talk to besides Koine: four suggestion
 * sources (one that answers, one that answers garbage, one whose port is closed, one
 * that never answers), two more that misbehave in common ways (a non-2xx status and
 * a redirect), and a recorder standing in for the search engine, which the client
 * must never contact.
 */
import { createServer } from 'node:http';

function listen(handler) {
  const server = createServer(handler);
  const sockets = new Set();
  server.on('connection', (socket) => {
    sockets.add(socket);
    socket.on('close', () => sockets.delete(socket));
  });
  return new Promise((resolve) => {
    server.listen(0, '127.0.0.1', () => {
      resolve({
        server,
        port: server.address().port,
        close: () => {
          for (const socket of sockets) socket.destroy();
          server.close();
        },
      });
    });
  });
}

export async function startSuggestionSources() {
  const hits = { engine: [], answers: [], garbage: [], hang: [], status: [], redirect: [] };

  const engine = await listen((req, res) => {
    hits.engine.push(req.url);
    res.writeHead(200).end('a search results page');
  });
  const answers = await listen((req, res) => {
    hits.answers.push({ url: req.url, method: req.method, headers: req.headers });
    res.writeHead(200, { 'Content-Type': 'application/json' }).end(JSON.stringify(['q', ['one', 'two', 'three']]));
  });
  const garbage = await listen((req, res) => {
    hits.garbage.push(req.url);
    res.writeHead(200, { 'Content-Type': 'text/html' }).end('<html>\u0000 not suggestions {{{');
  });
  const hang = await listen((req) => {
    hits.hang.push(req.url);
    // never answers
  });
  const status = await listen((req, res) => {
    hits.status.push(req.url);
    res.writeHead(503).end('busy');
  });
  const redirect = await listen((req, res) => {
    hits.redirect.push(req.url);
    res.writeHead(302, { Location: `http://127.0.0.1:${engine.port}/from-redirect` }).end();
  });
  // A closed port: bind, note the number, release it.
  const closed = await listen(() => {});
  const closedPort = closed.port;
  closed.close();
  await new Promise((r) => setTimeout(r, 30));

  return {
    hits,
    enginePort: engine.port,
    sources: {
      answers: `http://127.0.0.1:${answers.port}/complete?q=%s`,
      garbage: `http://127.0.0.1:${garbage.port}/complete?q=%s`,
      refused: `http://127.0.0.1:${closedPort}/complete?q=%s`,
      hang: `http://127.0.0.1:${hang.port}/complete?q=%s`,
      status: `http://127.0.0.1:${status.port}/complete?q=%s`,
      redirect: `http://127.0.0.1:${redirect.port}/complete?q=%s`,
    },
    close: () => [engine, answers, garbage, hang, status, redirect].forEach((s) => s.close()),
  };
}
