import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { mkdtemp, readFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { startStub } from './stub-server.mjs';

const run = promisify(execFile);
const here = dirname(fileURLToPath(import.meta.url));
const CLI = join(here, '../dist/koine-client.mjs');

let failures = 0;
function check(name, condition, detail) {
  if (condition) {
    console.log(`ok   ${name}`);
  } else {
    failures += 1;
    console.log(`FAIL ${name}${detail === undefined ? '' : ` — ${JSON.stringify(detail)}`}`);
  }
}

async function cli(descriptor, args) {
  const { stdout, stderr } = await run(process.execPath, [CLI, ...args], {
    env: { ...process.env, KOINE_ENDPOINT_DESCRIPTOR: descriptor },
    maxBuffer: 64 * 1024 * 1024,
  });
  const lines = stdout.split('\n').filter((l) => l !== '');
  check(`${args[0]}: exactly one stdout line`, lines.length === 1, stdout.slice(0, 200));
  return { result: JSON.parse(lines[0]), stderr, stdout };
}

const dir = await mkdtemp(join(tmpdir(), 'koine-test-'));
const secret = join(dir, 'secret');

const errorBody = (kind, extra = {}, path = ['desktopApplication']) => ({
  data: null,
  errors: [{ message: 'refused', path, extensions: { kind, ...extra } }],
});

let mode = 'ok';
const stub = await startStub(({ request, auth }) => {
  const name = request.operationName;
  if (mode === '401') return { status: 401, body: { errors: [{ message: 'unauthenticated' }] } };
  if (mode === '429') {
    return {
      status: 429,
      headers: { 'Retry-After': '17' },
      body: { errors: [{ message: 'rate limited' }] },
    };
  }
  if (mode === '400') return { status: 400, body: { errors: [{ message: 'bad request' }] } };
  if (mode === 'capability') {
    return {
      status: 403,
      body: errorBody('permission', { permissionClass: 'capability', requiredCapability: 'desktop:read' }),
    };
  }
  if (mode === 'os-permission') {
    return {
      status: 200,
      body: errorBody('permission', {
        permissionClass: 'os-permission',
        osPermission: 'accessibility',
        permissionOwner: 'koine',
      }),
    };
  }
  if (mode === 'unavailable') return { status: 200, body: errorBody('unavailable', {}, ['desktopFocusWindow']) };
  if (mode === 'failed') return { status: 200, body: errorBody('failed', {}, ['desktopFocusWindow']) };
  if (mode === 'unknown-provider') return { status: 200, body: errorBody('unknown-provider', {}, ['desktopFocusWindow']) };
  if (mode === 'absent') return { status: 200, body: { data: { desktopApplication: null } } };

  switch (name) {
    case 'KoineProbe':
      return auth === null
        ? { status: 401, body: { errors: [{ message: 'unauthenticated' }] } }
        : { status: 200, body: { data: { __typename: 'Query' } } };
    case 'RequestDesktopGrant':
      return {
        status: 200,
        body: {
          data: {
            koineRequestGrant: { requestId: 'req-1', comparisonCode: 'FROG-7', __typename: 'KoineGrantRequestReceipt' },
          },
          _sawAuthorizationHeader: auth !== null,
        },
      };
    case 'PollOwnGrantRequest':
      return {
        status: 200,
        body: {
          data: {
            koineGrantRequest: {
              state: 'APPROVED',
              grant: { grantId: 'g-1', capabilities: ['desktop:read', 'desktop:control'], state: 'ACTIVE' },
            },
          },
        },
      };
    case 'InspectOwnConnection':
      return {
        status: 200,
        body: {
          data: {
            koine: {
              contractVersion: stubRef.capture.contractVersion,
              instanceId: 'stub-instance',
              schemaDigest: stubRef.capture.schemaDigest,
              ownGrant: { capabilities: ['desktop:read'], state: 'ACTIVE' },
            },
          },
        },
      };
    case 'IntrospectionQuery':
      return { status: 200, raw: true, body: JSON.parse(stubRef.introspection) };
    case 'DesktopChoices':
      return {
        status: 200,
        body: {
          data: {
            desktopApplication: {
              ref: 'koine://desktop/app/7%2Fx?i=1',
              name: 'Stub',
              windows: [
                { ref: 'koine://desktop/window/7%2Fx?w=%2Fa+b', title: '', observation: 'REMEMBERED' },
              ],
            },
          },
          _process: request.variables.process,
        },
      };
    case 'FocusDesktopWindow':
      return {
        status: 200,
        body: {
          data: { desktopFocusWindow: { ref: request.variables.ref } },
          _submitted: request.variables.ref,
        },
      };
    default:
      return { status: 400, body: { errors: [{ message: `unknown operation ${name}` }] } };
  }
});
const stubRef = stub;

// --- happy path ---------------------------------------------------------
const probe = await cli(stub.descriptor, ['probe']);
check('probe: reachable', probe.result.classification === 'ok' && probe.result.serviceReachable === true, probe.result);
check('probe: authentication demanded', probe.result.authenticationDemanded === true);

const enrol = await cli(stub.descriptor, [
  'enrol', '--secret', secret, '--label', 'Harness', '--capability', 'desktop:read', '--capability', 'desktop:control',
]);
check('enrol: receipt', enrol.result.requestId === 'req-1' && enrol.result.comparisonCode === 'FROG-7', enrol.result);
check('enrol: sent anonymously', enrol.result.response._sawAuthorizationHeader === false);
check('enrol: reports creating the secret once', enrol.result.credential.created === true);

const enrol2 = await cli(stub.descriptor, [
  'enrol', '--secret', secret, '--label', 'Harness', '--capability', 'desktop:read', '--capability', 'desktop:control',
]);
check('enrol: rerun reuses the secret', enrol2.result.credential.created === false);

const secretText = (await readFile(secret, 'utf8')).trim();
check('enrol: secret never printed', !enrol.stdout.includes(secretText) && !enrol.stderr.includes(secretText));

const poll = await cli(stub.descriptor, ['poll', '--secret', secret]);
check('poll: state and grant', poll.result.requestState === 'APPROVED' && poll.result.grant.grantId === 'g-1', poll.result);

const inspect = await cli(stub.descriptor, ['inspect', '--secret', secret]);
check('inspect: koine metadata', inspect.result.koine.contractVersion === 'koine-desktop/1', inspect.result);

const out = join(dir, 'introspection.json');
const intro = await cli(stub.descriptor, ['introspect', '--secret', secret, '--out', out]);
const written = await readFile(out, 'utf8');
check('introspect: byte count matches the file', intro.result.byteCount === Buffer.byteLength(written, 'utf8'), intro.result.byteCount);
check('introspect: digests compared', intro.result.schemaDigestsEqual === true, intro.result);
check('introspect: wrote a usable schema', JSON.parse(written).data.__schema.types.length > 0);

const choices = await cli(stub.descriptor, ['choices', '--secret', secret, '--application', 'Finder']);
check('choices: application returned', choices.result.desktopApplication.name === 'Stub', choices.result.classification);
check('choices: reference passed through unchanged', choices.result.windows[0].ref === 'koine://desktop/window/7%2Fx?w=%2Fa+b');
check('choices: six fractional digits', /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}Z$/.test(choices.result.process.startedAt), choices.result.process);

const literal = await cli(stub.descriptor, ['choices', '--secret', secret, '--pid', '999999', '--started-at', '2020-01-01T00:00:00.000000Z']);
check('choices: literal identity sent verbatim', literal.result.response._process.startedAt === '2020-01-01T00:00:00.000000Z');

const ref = 'koine://desktop/window/7%2Fx?w=%2Fa+b';
const focus = await cli(stub.descriptor, ['focus', '--secret', secret, '--ref', ref]);
check('focus: reference byte-for-byte', focus.result.response._submitted === ref && focus.result.receiptRefMatchesSubmitted === true);

// --- classification table ----------------------------------------------
const cases = [
  ['absent', ['choices', '--secret', secret, '--pid', '1', '--started-at', '2020-01-01T00:00:00.000000Z'], 'absent'],
  ['capability', ['choices', '--secret', secret, '--pid', '1', '--started-at', '2020-01-01T00:00:00.000000Z'], 'capability-denied'],
  ['os-permission', ['choices', '--secret', secret, '--pid', '1', '--started-at', '2020-01-01T00:00:00.000000Z'], 'os-permission-denied'],
  ['unavailable', ['focus', '--secret', secret, '--ref', ref], 'unavailable'],
  ['failed', ['focus', '--secret', secret, '--ref', ref], 'failed'],
  ['unknown-provider', ['focus', '--secret', secret, '--ref', ref], 'unknown-provider'],
  ['400', ['inspect', '--secret', secret], 'request-error'],
  ['401', ['inspect', '--secret', secret], 'unauthenticated'],
  ['429', ['enrol', '--secret', secret, '--label', 'H', '--capability', 'desktop:read'], 'rate-limited'],
];
for (const [behaviour, args, expected] of cases) {
  mode = behaviour;
  const { result } = await cli(stub.descriptor, args);
  check(`classify ${behaviour} -> ${expected}`, result.classification === expected, result.classification);
  if (behaviour === '429') check('429: retry-after surfaced', result.http.retryAfterSeconds === 17);
  if (behaviour === 'capability') check('capability: requiredCapability surfaced', result.errors[0].requiredCapability === 'desktop:read');
  if (behaviour === 'os-permission') check('os-permission: owner surfaced', result.errors[0].permissionOwner === 'koine');
  if (behaviour === 'failed') check('failed mutation: outcome unknown', result.outcomeUnknown === true);
}
mode = 'ok';

// --- service unavailable and unknown outcome ----------------------------
stub.close();
await new Promise((r) => setTimeout(r, 50));
const down = await cli(stub.descriptor, ['inspect', '--secret', secret]);
check('service down -> service-unavailable', down.result.classification === 'service-unavailable', down.result);
const downMutation = await cli(stub.descriptor, ['focus', '--secret', secret, '--ref', ref]);
check('mutation with no connection -> service-unavailable', downMutation.result.classification === 'service-unavailable', downMutation.result);

const missing = await cli(join(dir, 'no-such-descriptor.json'), ['probe']);
check('no descriptor -> service-unavailable', missing.result.classification === 'service-unavailable');

// a server that accepts the connection then drops it mid-mutation
const { createServer } = await import('node:http');
const killer = createServer((req, res) => { req.socket.destroy(); });
await new Promise((r) => killer.listen(0, '127.0.0.1', r));
const { writeFile } = await import('node:fs/promises');
const killerDescriptor = join(dir, 'killer.json');
await writeFile(killerDescriptor, JSON.stringify({
  descriptorVersion: 1, instanceId: 'k', pid: 1, port: killer.address().port,
  path: '/graphql', contractVersion: 'koine-desktop/1',
}), { mode: 0o600 });
const lost = await cli(killerDescriptor, ['focus', '--secret', secret, '--ref', ref]);
check('mutation cut after send -> unknown-outcome', lost.result.classification === 'unknown-outcome' && lost.result.outcomeUnknown === true, lost.result);
const lostQuery = await cli(killerDescriptor, ['inspect', '--secret', secret]);
check('query cut after send -> service-unavailable', lostQuery.result.classification === 'service-unavailable', lostQuery.result.classification);
killer.close();

console.log(failures === 0 ? '\nall checks passed' : `\n${failures} check(s) failed`);
process.exit(failures === 0 ? 0 : 1);
