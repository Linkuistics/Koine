import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { mkdtemp, readFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { startStub } from './stub-server.mjs';
import { LAUNCH_ANSWERS, PROCESS } from './launch-stubs.mjs';

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
let launchMode = 'available-process';
let choicesNull = false;
const launchRequests = [];
const stub = await startStub(({ request, auth }) => {
  const name = request.operationName;
  if (name === 'LaunchInstalledApplication') {
    launchRequests.push({ request, auth });
    return LAUNCH_ANSWERS[launchMode]();
  }
  if (name === 'DesktopChoices' && choicesNull) {
    return { status: 200, body: { data: { desktopApplication: null }, _process: request.variables.process } };
  }
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
  if (mode === 'input-error') {
    return { status: 200, body: { data: { desktopApplication: null }, errors: [{ message: 'startedAt is not canonical', path: ['desktopApplication'] }] } };
  }
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
  ['input-error', ['choices', '--secret', secret, '--pid', '1', '--started-at', 'not-an-instant'], 'input-error'],
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

// --- launch -------------------------------------------------------------
// One table: what the stub answers, and what the client must say about it. Every
// case sends exactly one request.
const bundle = 'com.apple.Notes';
const launchArgs = ['launch', '--secret', secret, '--bundle-identifier', bundle];
const PATHS = (...paths) => paths;
const ROOT = 'workspaceLaunchApplication';
const FULL_SET = ['workspace:control', 'desktop:control'];
const launchCases = [
  // name, classification, status, actionEffect, processState, outcomeUnknown, extra checks
  ['available-process', 'ok', 'AVAILABLE', 'acknowledged', 'present', false, (r) => {
    check('launch available: process copied unchanged', r.process.pid === PROCESS.pid && r.process.startedAt === PROCESS.startedAt, r.process);
    check('launch available: receipt carries the process', r.receipt.process.pid === PROCESS.pid);
    check('launch available: no dependency, no capability facts', r.dependency === null && r.requiredCapability === null && r.requiredCapabilities === null);
    check('launch available: ok is true', r.ok === true);
    check('launch available: choices arguments hand the identity over unchanged',
      JSON.stringify(r.choicesArguments) === JSON.stringify(['--pid', '4242', '--started-at', PROCESS.startedAt]), r.choicesArguments);
  }],
  ['available-null-process', 'ok', 'AVAILABLE', 'acknowledged', 'null-in-receipt', false, (r) => {
    check('launch null process: process is null and the receipt is still there', r.process === null && r.receipt !== null && r.receipt.process === null, r);
    check('launch null process: not a failed launch', r.ok === true && r.errors.length === 0);
    check('launch null process: nothing to hand to choices', r.choicesArguments === null);
  }],
  ['dependency-not-installed', 'dependency-unavailable', 'DEPENDENCY_UNAVAILABLE', 'none', 'no-receipt', false, (r) => {
    check('dependency: reason and guidance surfaced', r.dependency.reason === 'APPLICATION_NOT_INSTALLED' && r.dependency.guidance.includes('Notes'), r.dependency);
    check('dependency: a typed result, not an error', r.errors.length === 0 && r.ok === false && r.process === null && r.receipt === null);
    check('dependency: safe, nothing was submitted', r.outcomeUnknown === false);
  }],
  ['dependency-identity-mismatch', 'dependency-unavailable', 'DEPENDENCY_UNAVAILABLE', 'none', 'no-receipt', false, (r) => {
    check('dependency: mismatch reason surfaced', r.dependency.reason === 'APPLICATION_IDENTITY_MISMATCH');
  }],
  ['denied-lacks-workspace', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('denied: HTTP 403 with no data', r.http.status === 403 && r.response.data === undefined, r.http);
    check('denied: first unmet capability is the field\'s own', r.requiredCapability === 'workspace:control', r.requiredCapability);
    check('denied: complete ordered set, unsorted, as sent', JSON.stringify(r.requiredCapabilities) === JSON.stringify(FULL_SET), r.requiredCapabilities);
    check('denied: phase authorization', r.phase === 'authorization');
    check('denied: per error, at the action path', JSON.stringify(r.errors[0].requiredCapabilities) === JSON.stringify(FULL_SET) && r.errors[0].requiredCapability === 'workspace:control' && JSON.stringify(r.errors[0].path) === JSON.stringify([ROOT]) && r.errors[0].phase === 'authorization', r.errors[0]);
  }],
  ['denied-lacks-desktop', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('denied: first unmet is the additional capability, the set is still whole', r.requiredCapability === 'desktop:control' && JSON.stringify(r.requiredCapabilities) === JSON.stringify(FULL_SET), r);
  }],
  ['denied-lacks-both', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('denied: neither capability held, still one first-unmet plus the whole set', r.requiredCapability === 'workspace:control' && r.requiredCapabilities.length === 2, r);
  }],
  ['denied-revoked-before-dispatch', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('denied at execution: phase execution, HTTP 200', r.phase === 'execution' && r.http.status === 200, r);
  }],
  ['failed-at-action', 'failed', null, 'may-have-begun', 'no-receipt', true, (r) => {
    check('failed: error at the action path', JSON.stringify(r.errors[0].path) === JSON.stringify([ROOT]), r.errors);
    check('failed: no dependency, no process', r.dependency === null && r.process === null);
  }],
  ['failed-deadline', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('failed deadline: empty path, data null', r.errors[0].path.length === 0 && r.response.data === null);
  }],
  ['input-error', 'input-error', null, 'none', 'no-receipt', false, (r) => {
    check('input error: no kind, at the original path', r.errors[0].kind === null && JSON.stringify(r.errors[0].path) === JSON.stringify([ROOT]), r.errors);
  }],
  ['suppressed-value', 'capability-denied', 'AVAILABLE', 'acknowledged', 'suppressed', false, (r) => {
    check('suppressed value: the status still says the launch was acknowledged', r.status === 'AVAILABLE' && r.actionEffect === 'acknowledged');
    check('suppressed value: the error is kept, with its path and set', JSON.stringify(r.resultErrorPaths) === JSON.stringify(PATHS([ROOT, 'value'])) && JSON.stringify(r.requiredCapabilities) === JSON.stringify(FULL_SET), r);
    check('suppressed value: flagged as a suppressed branch, not as not-launched', r.branchSuppressed === true && r.process === null && r.receipt === null);
  }],
  ['suppressed-process', 'capability-denied', 'AVAILABLE', 'acknowledged', 'suppressed', false, (r) => {
    check('suppressed process: receipt present, process null because suppressed, not because absent', r.receipt !== null && r.process === null && r.branchSuppressed === false, r);
    check('suppressed process: first unmet capability from the nested error', r.requiredCapability === 'desktop:control');
  }],
  ['suppressed-dependency', 'capability-denied', 'DEPENDENCY_UNAVAILABLE', 'none', 'no-receipt', false, (r) => {
    check('suppressed dependency: status still says nothing was submitted', r.status === 'DEPENDENCY_UNAVAILABLE' && r.dependency === null && r.branchSuppressed === true, r);
  }],
  ['suppressed-status', 'capability-denied', null, 'unknown', 'no-receipt', true, (r) => {
    check('suppressed status: propagation removed the result; the client cannot say what the action did', r.response.data[ROOT] === null && r.actionEffect === 'unknown', r);
  }],
  ['violation-null-root', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('null root with no error is not absence', r.classification !== 'absent' && r.contractViolation !== null, r);
  }],
  ['violation-both-branches', 'failed', 'AVAILABLE', 'unknown', 'no-receipt', true, (r) => {
    check('both branches: reported as a contract violation', r.contractViolation !== null);
  }],
  ['violation-not-a-response', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('not a response: never read as success', r.ok === false && r.contractViolation !== null, r);
  }],
  ['violation-dependency-missing', 'failed', 'DEPENDENCY_UNAVAILABLE', 'unknown', 'no-receipt', true, (r) => {
    check('dependency branch missing: reported as a contract violation', r.contractViolation !== null);
  }],
];
const secretTextForLaunch = (await readFile(secret, 'utf8')).trim();
for (const [name, classification, status, effect, processState, unknown, extra] of launchCases) {
  launchMode = name;
  const before = launchRequests.length;
  const before_ms = Date.now();
  const { result, stdout } = await cli(stub.descriptor, launchArgs);
  const after_ms = Date.now();
  const sent = launchRequests.length - before;
  check(`launch ${name}: exactly one request, never replayed`, sent === 1, sent);
  check(`launch ${name}: classification ${classification}`, result.classification === classification, result.classification);
  check(`launch ${name}: status ${status}`, result.status === status, result.status);
  check(`launch ${name}: actionEffect ${effect}`, result.actionEffect === effect, result.actionEffect);
  check(`launch ${name}: processState ${processState}`, result.processState === processState, result.processState);
  check(`launch ${name}: outcomeUnknown ${unknown}`, result.outcomeUnknown === unknown, result.outcomeUnknown);
  check(`launch ${name}: command and ok`, result.command === 'launch' && result.ok === (classification === 'ok'));
  check(`launch ${name}: timing fields`, Number.isInteger(result.sentMs) && Number.isInteger(result.receivedMs) && before_ms <= result.sentMs && result.sentMs <= result.receivedMs && result.receivedMs <= after_ms, [before_ms, result.sentMs, result.receivedMs, after_ms]);
  check(`launch ${name}: secret never printed`, !stdout.includes(secretTextForLaunch));
  check(`launch ${name}: common fields present`, ['endpoint', 'http', 'response', 'errors', 'transport', 'outcomeUnknown'].every((k) => k in result));
  extra(result);
}

// The request itself: literal variables, the published operation, the bearer.
launchMode = 'available-process';
{
  const before = launchRequests.length;
  await cli(stub.descriptor, launchArgs);
  const sent = launchRequests.at(-1);
  check('launch request: operation name and literal variables', sent.request.operationName === 'LaunchInstalledApplication' && JSON.stringify(sent.request.variables) === JSON.stringify({ application: { bundleIdentifier: bundle } }), sent.request.variables);
  check('launch request: no applicationPath unless given', !('applicationPath' in sent.request.variables.application));
  check('launch request: bearer presented', sent.auth !== null && sent.auth.startsWith('Bearer '));
  check('launch request: the published document, fragment included', sent.request.query.includes('workspaceLaunchApplication(application: $application)') && sent.request.query.includes('fragment WorkspaceOpenOutcome on WorkspaceOpenResult'), sent.request.query);
  check('launch request: one request', launchRequests.length - before === 1);
  const path = '/Applications/Notes Two.app';
  await cli(stub.descriptor, [...launchArgs, '--application-path', path]);
  check('launch request: applicationPath sent verbatim', launchRequests.at(-1).request.variables.application.applicationPath === path, launchRequests.at(-1).request.variables);
}

// Timing: the answer is held 40 ms, so the two instants are visibly apart.
launchMode = 'available-slow';
{
  const { result } = await cli(stub.descriptor, launchArgs);
  check('launch timing: receivedMs - sentMs covers the held answer', result.receivedMs - result.sentMs >= 35, [result.sentMs, result.receivedMs]);
}

// An absent process: the receipt's identity goes to `choices` unchanged, and a
// process that no longer runs is ordinary null, not a launch failure.
launchMode = 'available-process';
{
  const { result: launched } = await cli(stub.descriptor, launchArgs);
  choicesNull = true;
  const { result: later } = await cli(stub.descriptor, ['choices', '--secret', secret, ...launched.choicesArguments]);
  choicesNull = false;
  check('handoff: choices received the receipt identity verbatim', later.response._process.pid === launched.process.pid && later.response._process.startedAt === launched.process.startedAt, later.response._process);
  check('handoff: a process that no longer runs is absent, without error', later.classification === 'absent' && later.errors.length === 0 && later.absence === 'server-null', later);
  check('handoff: the launch itself stays ok', launched.classification === 'ok');
  const { result: running } = await cli(stub.descriptor, ['choices', '--secret', secret, ...launched.choicesArguments]);
  check('handoff: a running process resolves', running.classification === 'ok' && running.desktopApplication.name === 'Stub', running);
}

// --- service unavailable and unknown outcome ----------------------------
stub.close();
await new Promise((r) => setTimeout(r, 50));
const down = await cli(stub.descriptor, ['inspect', '--secret', secret]);
check('service down -> service-unavailable', down.result.classification === 'service-unavailable', down.result);
const downMutation = await cli(stub.descriptor, ['focus', '--secret', secret, '--ref', ref]);
check('mutation with no connection -> service-unavailable', downMutation.result.classification === 'service-unavailable', downMutation.result);
const downLaunch = await cli(stub.descriptor, launchArgs);
check('launch with no connection -> service-unavailable, nothing submitted', downLaunch.result.classification === 'service-unavailable' && downLaunch.result.actionEffect === 'none' && downLaunch.result.outcomeUnknown === false && downLaunch.result.sentMs === null && downLaunch.result.receivedMs === null, downLaunch.result);

const missing = await cli(join(dir, 'no-such-descriptor.json'), ['probe']);
check('no descriptor -> service-unavailable', missing.result.classification === 'service-unavailable');

// a server that accepts the connection then drops it mid-mutation
const { createServer } = await import('node:http');
let killed = 0;
const killer = createServer((req, res) => { killed += 1; req.socket.destroy(); });
await new Promise((r) => killer.listen(0, '127.0.0.1', r));
const { writeFile } = await import('node:fs/promises');
const killerDescriptor = join(dir, 'killer.json');
await writeFile(killerDescriptor, JSON.stringify({
  descriptorVersion: 1, instanceId: 'k', pid: 1, port: killer.address().port,
  path: '/graphql', contractVersion: 'koine-desktop/1',
}), { mode: 0o600 });
const lost = await cli(killerDescriptor, ['focus', '--secret', secret, '--ref', ref]);
check('mutation cut after send -> unknown-outcome', lost.result.classification === 'unknown-outcome' && lost.result.outcomeUnknown === true, lost.result);
killed = 0;
const lostLaunch = await cli(killerDescriptor, launchArgs);
check('launch cut after send -> unknown-outcome', lostLaunch.result.classification === 'unknown-outcome' && lostLaunch.result.outcomeUnknown === true && lostLaunch.result.actionEffect === 'unknown', lostLaunch.result);
check('launch cut after send: sent once, never replayed', killed === 1, killed);
check('launch cut after send: sentMs set, receivedMs null', Number.isInteger(lostLaunch.result.sentMs) && lostLaunch.result.receivedMs === null, [lostLaunch.result.sentMs, lostLaunch.result.receivedMs]);
check('launch cut after send: no process, no receipt', lostLaunch.result.process === null && lostLaunch.result.processState === 'no-receipt');
const lostQuery = await cli(killerDescriptor, ['inspect', '--secret', secret]);
check('query cut after send -> service-unavailable', lostQuery.result.classification === 'service-unavailable', lostQuery.result.classification);
killer.close();

console.log(failures === 0 ? '\nall checks passed' : `\n${failures} check(s) failed`);
process.exit(failures === 0 ? 0 : 1);
