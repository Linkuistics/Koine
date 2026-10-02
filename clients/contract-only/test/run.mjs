import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { startStub } from './stub-server.mjs';
import { LAUNCH_ANSWERS, PROCESS } from './launch-stubs.mjs';
import { OPEN_URL_ANSWERS } from './open-url-stubs.mjs';
import { OPEN_PATH_ANSWERS } from './open-path-stubs.mjs';
import { startSuggestionSources } from './suggestion-stubs.mjs';

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
let openUrlMode = 'available-process';
const openUrlRequests = [];
let openPathMode = 'available-process';
const openPathRequests = [];
const stub = await startStub(({ request, auth }) => {
  const name = request.operationName;
  if (name === 'LaunchInstalledApplication') {
    launchRequests.push({ request, auth });
    return LAUNCH_ANSWERS[launchMode]();
  }
  if (name === 'OpenSearchURL') {
    openUrlRequests.push({ request, auth });
    return OPEN_URL_ANSWERS[openUrlMode]();
  }
  if (name === 'OpenDocumentOrDirectory') {
    openPathRequests.push({ request, auth });
    return OPEN_PATH_ANSWERS[openPathMode]();
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


// --- open-url -----------------------------------------------------------
// The same table as launch, from the URL root's own wire shapes. Every case sends
// exactly one request.
const OPEN_ROOT = 'workspaceOpenURL';
const goodUrl = 'https://example.com/path?q=1#frag';
const openArgs = ['open-url', '--secret', secret, '--url', goodUrl];
const openUrlCases = [
  // name, classification, status, actionEffect, processState, outcomeUnknown, extra checks
  ['available-process', 'ok', 'AVAILABLE', 'acknowledged', 'present', false, (r) => {
    check('open-url available: process copied unchanged', r.process.pid === PROCESS.pid && r.process.startedAt === PROCESS.startedAt, r.process);
    check('open-url available: receipt carries the process, no dependency, no capability facts', r.receipt.process.pid === PROCESS.pid && r.dependency === null && r.requiredCapability === null && r.requiredCapabilities === null);
    check('open-url available: ok, and the url echoed exactly', r.ok === true && r.url === goodUrl, r.url);
    check('open-url available: choices arguments hand the identity over unchanged', JSON.stringify(r.choicesArguments) === JSON.stringify(['--pid', '4242', '--started-at', PROCESS.startedAt]));
  }],
  ['available-null-process', 'ok', 'AVAILABLE', 'acknowledged', 'null-in-receipt', false, (r) => {
    check('open-url null process: receipt present, process null, still ok', r.process === null && r.receipt !== null && r.receipt.process === null && r.ok === true && r.errors.length === 0, r);
  }],
  ['dependency-no-default-handler', 'dependency-unavailable', 'DEPENDENCY_UNAVAILABLE', 'none', 'no-receipt', false, (r) => {
    check('open-url dependency: NO_DEFAULT_HANDLER with guidance', r.dependency.reason === 'NO_DEFAULT_HANDLER' && r.dependency.guidance.includes('browser'), r.dependency);
    check('open-url dependency: a typed result, not an error; nothing was submitted', r.errors.length === 0 && r.ok === false && r.process === null && r.receipt === null && r.outcomeUnknown === false);
  }],
  ['denied-lacks-workspace', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('open-url denied: HTTP 403, no data, phase authorization', r.http.status === 403 && r.response.data === undefined && r.phase === 'authorization', r.http);
    check('open-url denied: first unmet is workspace:control, set in the spec order', r.requiredCapability === 'workspace:control' && JSON.stringify(r.requiredCapabilities) === JSON.stringify(FULL_SET), r);
    check('open-url denied: per error, at the action path', JSON.stringify(r.errors[0].path) === JSON.stringify([OPEN_ROOT]) && JSON.stringify(r.errors[0].requiredCapabilities) === JSON.stringify(FULL_SET), r.errors[0]);
  }],
  ['denied-lacks-desktop', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('open-url denied: first unmet is desktop:control, the set is still whole', r.requiredCapability === 'desktop:control' && JSON.stringify(r.requiredCapabilities) === JSON.stringify(FULL_SET), r);
  }],
  ['denied-lacks-both', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('open-url denied: neither held, one first-unmet plus the whole set', r.requiredCapability === 'workspace:control' && r.requiredCapabilities.length === 2, r);
  }],
  ['denied-revoked-before-dispatch', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('open-url denied at execution: phase execution, HTTP 200', r.phase === 'execution' && r.http.status === 200, r);
  }],
  ['failed-at-action', 'failed', null, 'may-have-begun', 'no-receipt', true, (r) => {
    check('open-url failed: error at the action path, no dependency, no process', JSON.stringify(r.errors[0].path) === JSON.stringify([OPEN_ROOT]) && r.dependency === null && r.process === null, r.errors);
  }],
  ['failed-deadline', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('open-url failed deadline: empty path, data null', r.errors[0].path.length === 0 && r.response.data === null);
  }],
  ['input-error', 'input-error', null, 'none', 'no-receipt', false, (r) => {
    check('open-url input error: no kind, at the field path, nothing attempted', r.errors[0].kind === null && JSON.stringify(r.errors[0].path) === JSON.stringify([OPEN_ROOT]) && r.outcomeUnknown === false, r.errors);
    check('open-url input error: error path reported', JSON.stringify(r.resultErrorPaths) === JSON.stringify(PATHS([OPEN_ROOT])), r.resultErrorPaths);
  }],
  ['input-error-argument-path', 'input-error', null, 'none', 'no-receipt', false, (r) => {
    check('open-url input error at the argument path: no kind, reported at that path', r.errors[0].kind === null && JSON.stringify(r.resultErrorPaths) === JSON.stringify(PATHS([OPEN_ROOT, 'url'])), r);
  }],
  ['suppressed-value', 'capability-denied', 'AVAILABLE', 'acknowledged', 'suppressed', false, (r) => {
    check('open-url suppressed value: status still says acknowledged; error kept with path and set', r.status === 'AVAILABLE' && JSON.stringify(r.resultErrorPaths) === JSON.stringify(PATHS([OPEN_ROOT, 'value'])) && JSON.stringify(r.requiredCapabilities) === JSON.stringify(FULL_SET), r);
    check('open-url suppressed value: flagged as a suppressed branch', r.branchSuppressed === true && r.process === null && r.receipt === null);
  }],
  ['suppressed-process', 'capability-denied', 'AVAILABLE', 'acknowledged', 'suppressed', false, (r) => {
    check('open-url suppressed process: receipt present, process withheld, not absent', r.receipt !== null && r.process === null && r.branchSuppressed === false && r.requiredCapability === 'desktop:control', r);
  }],
  ['suppressed-dependency', 'capability-denied', 'DEPENDENCY_UNAVAILABLE', 'none', 'no-receipt', false, (r) => {
    check('open-url suppressed dependency: status says nothing was submitted', r.status === 'DEPENDENCY_UNAVAILABLE' && r.dependency === null && r.branchSuppressed === true, r);
  }],
  ['suppressed-status', 'capability-denied', null, 'unknown', 'no-receipt', true, (r) => {
    check('open-url suppressed status: the client cannot say what the action did', r.response.data[OPEN_ROOT] === null && r.actionEffect === 'unknown', r);
  }],
  ['violation-null-root', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('open-url null root with no error is not absence, and the message names this root', r.classification !== 'absent' && r.contractViolation.includes('workspaceOpenURL') && !r.contractViolation.includes('workspaceLaunchApplication'), r.contractViolation);
  }],
  ['violation-both-branches', 'failed', 'AVAILABLE', 'unknown', 'no-receipt', true, (r) => {
    check('open-url both branches: a contract violation', r.contractViolation !== null);
  }],
  ['violation-not-a-response', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('open-url not a response: never read as success', r.ok === false && r.contractViolation !== null, r);
  }],
  ['violation-dependency-missing', 'failed', 'DEPENDENCY_UNAVAILABLE', 'unknown', 'no-receipt', true, (r) => {
    check('open-url dependency branch missing: a contract violation', r.contractViolation !== null);
  }],
  ['violation-wrong-root', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('open-url answer for another root: a violation naming workspaceOpenURL, not success', r.ok === false && r.contractViolation.includes('workspaceOpenURL'), r.contractViolation);
  }],
];
for (const [name, classification, status, effect, processState, unknown, extra] of openUrlCases) {
  openUrlMode = name;
  const before = openUrlRequests.length;
  const before_ms = Date.now();
  const { result, stdout } = await cli(stub.descriptor, openArgs);
  const after_ms = Date.now();
  const sent = openUrlRequests.length - before;
  check(`open-url ${name}: exactly one request, never replayed`, sent === 1, sent);
  check(`open-url ${name}: classification ${classification}`, result.classification === classification, result.classification);
  check(`open-url ${name}: status ${status}`, result.status === status, result.status);
  check(`open-url ${name}: actionEffect ${effect}`, result.actionEffect === effect, result.actionEffect);
  check(`open-url ${name}: processState ${processState}`, result.processState === processState, result.processState);
  check(`open-url ${name}: outcomeUnknown ${unknown}`, result.outcomeUnknown === unknown, result.outcomeUnknown);
  check(`open-url ${name}: command, ok, url`, result.command === 'open-url' && result.ok === (classification === 'ok') && result.url === goodUrl);
  check(`open-url ${name}: timing fields`, Number.isInteger(result.sentMs) && Number.isInteger(result.receivedMs) && before_ms <= result.sentMs && result.sentMs <= result.receivedMs && result.receivedMs <= after_ms, [before_ms, result.sentMs, result.receivedMs, after_ms]);
  check(`open-url ${name}: secret never printed`, !stdout.includes(secretTextForLaunch));
  check(`open-url ${name}: common fields present`, ['endpoint', 'http', 'response', 'errors', 'transport', 'outcomeUnknown', 'receipt', 'process', 'processState', 'dependency', 'requiredCapability', 'requiredCapabilities', 'phase', 'branchSuppressed', 'resultErrorPaths', 'contractViolation', 'sentMs', 'receivedMs'].every((k) => k in result));
  extra(result);
}

// The request itself: the published operation, the url as one literal variable, the bearer.
openUrlMode = 'available-process';
{
  const before = openUrlRequests.length;
  await cli(stub.descriptor, openArgs);
  const sent = openUrlRequests.at(-1);
  check('open-url request: operation name and exactly one literal variable', sent.request.operationName === 'OpenSearchURL' && JSON.stringify(sent.request.variables) === JSON.stringify({ url: goodUrl }), sent.request.variables);
  check('open-url request: bearer presented', sent.auth !== null && sent.auth.startsWith('Bearer '));
  check('open-url request: the published document, fragment included', sent.request.query.includes('workspaceOpenURL(url: $url)') && sent.request.query.includes('fragment WorkspaceOpenOutcome on WorkspaceOpenResult') && !sent.request.query.includes('workspaceLaunchApplication'), sent.request.query);
  check('open-url request: one request', openUrlRequests.length - before === 1);
}

// Bytes in, bytes out: no trimming, normalising, decoding or encoding, whatever the
// text is. The provider refuses what it refuses; here the stub answers an input error
// and the client must have sent the text untouched and reported the refusal.
openUrlMode = 'input-error';
const rawUrls = [
  'https://example.com/a b',
  ' https://example.com/ ',
  'https://example.com/café/日本?q=\u{1F600}',
  'https://example.com/a\\b',
  'https://user:pw@example.com/',
  'file:///etc/passwd',
  'javascript:alert(1)',
  'HTTPS://EXAMPLE.COM/%zz/%41',
  'https://example.com/\ttab',
  'https://bücher.example/',
  '--looks-like-an-option',
  'https://example.com/́é',
  '',
];
for (const raw of rawUrls) {
  const before = openUrlRequests.length;
  const { result } = await cli(stub.descriptor, ['open-url', '--secret', secret, `--url=${raw}`]);
  check(`open-url raw ${JSON.stringify(raw)}: sent byte-for-byte, once`, openUrlRequests.length - before === 1 && openUrlRequests.at(-1).request.variables.url === raw, openUrlRequests.at(-1)?.request.variables);
  check(`open-url raw ${JSON.stringify(raw)}: refusal observed, url echoed`, result.classification === 'input-error' && result.url === raw && result.actionEffect === 'none', result.classification);
}
{
  // The two-argument form gives the same text.
  const before = openUrlRequests.length;
  await cli(stub.descriptor, ['open-url', '--secret', secret, '--url', 'https://example.com/a b\\c']);
  check('open-url: separate --url value sent verbatim', openUrlRequests.length - before === 1 && openUrlRequests.at(-1).request.variables.url === 'https://example.com/a b\\c');
}

// --url-file: the file's bytes as UTF-8 text, nothing stripped.
const fileCases = [
  ['plain', Buffer.from('https://example.com/x', 'utf8')],
  ['trailing LF', Buffer.from('https://example.com/x\n', 'utf8')],
  ['trailing CRLF', Buffer.from('https://example.com/x\r\n', 'utf8')],
  ['leading space and trailing spaces', Buffer.from('  https://example.com/x  ', 'utf8')],
  ['raw Unicode and backslash', Buffer.from('https://example.com/café\\日本', 'utf8')],
  ['NUL inside', Buffer.from('https://example.com/a\u0000b', 'utf8')],
  ['byte order mark kept', Buffer.concat([Buffer.from([0xef, 0xbb, 0xbf]), Buffer.from('https://example.com/x', 'utf8')])],
  ['empty file', Buffer.alloc(0)],
];
const urlFile = join(dir, 'url.txt');
for (const [label, bytes] of fileCases) {
  await writeFile(urlFile, bytes);
  const before = openUrlRequests.length;
  const { result } = await cli(stub.descriptor, ['open-url', '--secret', secret, '--url-file', urlFile]);
  const expected = bytes.toString('utf8');
  check(`open-url file (${label}): the file's text sent exactly, once`, openUrlRequests.length - before === 1 && openUrlRequests.at(-1).request.variables.url === expected && Buffer.from(openUrlRequests.at(-1).request.variables.url, 'utf8').equals(bytes), openUrlRequests.at(-1)?.request.variables);
  check(`open-url file (${label}): url echoed exactly`, result.url === expected);
}
{
  // Bytes that are not UTF-8 cannot be a GraphQL string; nothing is sent, and nothing is repaired.
  await writeFile(urlFile, Buffer.from([0x68, 0x74, 0x74, 0x70, 0xff, 0xfe]));
  const before = openUrlRequests.length;
  const { result } = await cli(stub.descriptor, ['open-url', '--secret', secret, '--url-file', urlFile]);
  check('open-url file (not UTF-8): nothing sent, reported as a client error', openUrlRequests.length === before && result.classification === 'failed' && /UTF-8/.test(result.clientError) && result.ok === false, result);
  const { result: missing } = await cli(stub.descriptor, ['open-url', '--secret', secret, '--url-file', join(dir, 'absent.txt')]);
  check('open-url file (missing): nothing sent, reported as a client error', openUrlRequests.length === before && missing.classification === 'failed' && typeof missing.clientError === 'string', missing);
  const neither = await cli(stub.descriptor, ['open-url', '--secret', secret]);
  const both = await cli(stub.descriptor, ['open-url', '--secret', secret, '--url', 'x', '--url-file', urlFile]);
  check('open-url: --url or --url-file is required, and not both; nothing sent', openUrlRequests.length === before && neither.result.classification === 'request-error' && both.result.classification === 'request-error', [neither.result, both.result]);
}

// --- open-path ----------------------------------------------------------
// The same table as open-url, from the path root's own wire shapes (test/open-path-stubs.mjs).
// Every case sends exactly one request. The PATH_NOT_FOUND, NO_DEFAULT_HANDLER and both
// application reasons are rows of their own: the client reads each the same way.
const PATH_ROOT = 'workspaceOpenPath';
const goodPath = '/tmp/koine test/notes (1).txt';
const pathArgs = ['open-path', '--secret', secret, '--path', goodPath];
const NAMED = ['--bundle-identifier', 'dev.zed.Zed'];
const OPEN_URL_KEYS = ['credential', 'sentMs', 'receivedMs', 'status', 'actionEffect', 'receipt', 'process', 'processState', 'choicesArguments', 'dependency', 'requiredCapability', 'requiredCapabilities', 'phase', 'branchSuppressed', 'resultErrorPaths', 'contractViolation'];
const dependencyRow = (reason, text) => ['dependency-' + reason.toLowerCase().replaceAll('_', '-').replace('application-', ''), 'dependency-unavailable', 'DEPENDENCY_UNAVAILABLE', 'none', 'no-receipt', false, (r) => {
  check(`open-path ${reason}: reason and guidance copied verbatim`, r.dependency.reason === reason && r.dependency.guidance.includes(text), r.dependency);
  check(`open-path ${reason}: a typed result, not an error; nothing was submitted, nothing is unknown`, r.errors.length === 0 && r.ok === false && r.process === null && r.receipt === null && r.outcomeUnknown === false && r.actionEffect === 'none', r);
  check(`open-path ${reason}: only the contract's facts, no claim of its own about the world`, JSON.stringify(Object.keys(r.dependency)) === JSON.stringify(['reason', 'guidance']) && !Object.keys(r).some((k) => /exist|found|missing|handler/i.test(k)), Object.keys(r));
}];
const openPathCases = [
  // name, classification, status, actionEffect, processState, outcomeUnknown, extra checks
  ['available-process', 'ok', 'AVAILABLE', 'acknowledged', 'present', false, (r) => {
    check('open-path available: process copied unchanged', r.process.pid === PROCESS.pid && r.process.startedAt === PROCESS.startedAt, r.process);
    check('open-path available: receipt carries the process, no dependency, no capability facts', r.receipt.process.pid === PROCESS.pid && r.dependency === null && r.requiredCapability === null && r.requiredCapabilities === null);
    check('open-path available: ok, the path echoed exactly, no application', r.ok === true && r.path === goodPath && r.application === null, [r.path, r.application]);
    check('open-path available: choices arguments hand the identity over unchanged', JSON.stringify(r.choicesArguments) === JSON.stringify(['--pid', '4242', '--started-at', PROCESS.startedAt]));
    check('open-path available: the same facts as open-url, plus path and application, and nothing else',
      JSON.stringify(Object.keys(r).filter((k) => ![...OPEN_URL_KEYS, 'command', 'ok', 'classification', 'endpoint', 'http', 'response', 'errors', 'transport', 'outcomeUnknown'].includes(k)).sort()) === JSON.stringify(['application', 'path']), Object.keys(r));
  }],
  ['available-null-process', 'ok', 'AVAILABLE', 'acknowledged', 'null-in-receipt', false, (r) => {
    check('open-path null process: receipt present, process null, still ok', r.process === null && r.receipt !== null && r.receipt.process === null && r.ok === true && r.errors.length === 0, r);
  }],
  dependencyRow('PATH_NOT_FOUND', 'Nothing was found'),
  dependencyRow('NO_DEFAULT_HANDLER', 'registered to open'),
  dependencyRow('APPLICATION_NOT_INSTALLED', 'Zed'),
  dependencyRow('APPLICATION_IDENTITY_MISMATCH', 'different identifier'),
  ['denied-lacks-workspace', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('open-path denied: HTTP 403, no data, phase authorization', r.http.status === 403 && r.response.data === undefined && r.phase === 'authorization', r.http);
    check('open-path denied: first unmet is workspace:control, the complete set in the spec order', r.requiredCapability === 'workspace:control' && JSON.stringify(r.requiredCapabilities) === JSON.stringify(FULL_SET), r);
    check('open-path denied: per error, at the action path', JSON.stringify(r.errors[0].path) === JSON.stringify([PATH_ROOT]) && JSON.stringify(r.errors[0].requiredCapabilities) === JSON.stringify(FULL_SET), r.errors[0]);
  }],
  ['denied-lacks-desktop', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('open-path denied: first unmet is desktop:control, the set is still whole', r.requiredCapability === 'desktop:control' && JSON.stringify(r.requiredCapabilities) === JSON.stringify(FULL_SET), r);
  }],
  ['denied-lacks-both', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('open-path denied: neither held, one first-unmet plus the whole set', r.requiredCapability === 'workspace:control' && r.requiredCapabilities.length === 2, r);
  }],
  ['denied-revoked-before-dispatch', 'capability-denied', null, 'none', 'no-receipt', false, (r) => {
    check('open-path denied at execution: phase execution, HTTP 200', r.phase === 'execution' && r.http.status === 200, r);
  }],
  ['failed-at-action', 'failed', null, 'may-have-begun', 'no-receipt', true, (r) => {
    check('open-path failed: error at the action path, no dependency, no process', JSON.stringify(r.errors[0].path) === JSON.stringify([PATH_ROOT]) && r.dependency === null && r.process === null, r.errors);
  }],
  ['failed-inspection-denied', 'failed', null, 'may-have-begun', 'no-receipt', true, (r) => {
    check('open-path failed inspection: never read as a missing path', r.dependency === null && r.status === null && r.classification === 'failed', r);
  }],
  ['failed-deadline', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('open-path failed deadline: empty path, data null', r.errors[0].path.length === 0 && r.response.data === null);
  }],
  ['input-error', 'input-error', null, 'none', 'no-receipt', false, (r) => {
    check('open-path input error: no kind, at the root field\'s own path, nothing attempted', r.errors[0].kind === null && JSON.stringify(r.errors[0].path) === JSON.stringify([PATH_ROOT]) && r.outcomeUnknown === false, r.errors);
    check('open-path input error: error path reported', JSON.stringify(r.resultErrorPaths) === JSON.stringify(PATHS([PATH_ROOT])), r.resultErrorPaths);
  }],
  ['input-error-argument-path', 'input-error', null, 'none', 'no-receipt', false, (r) => {
    check('open-path input error one level down: still the action\'s own refusal, reported at that path', r.errors[0].kind === null && JSON.stringify(r.resultErrorPaths) === JSON.stringify(PATHS([PATH_ROOT, 'path'])), r);
  }],
  ['input-error-application-path', 'input-error', null, 'none', 'no-receipt', false, (r) => {
    check('open-path input error at the application\'s identifier: the action\'s own refusal', JSON.stringify(r.resultErrorPaths) === JSON.stringify(PATHS([PATH_ROOT, 'application', 'bundleIdentifier'])), r);
  }],
  ['suppressed-value', 'capability-denied', 'AVAILABLE', 'acknowledged', 'suppressed', false, (r) => {
    check('open-path suppressed value: status still says acknowledged; error kept with path and set', r.status === 'AVAILABLE' && JSON.stringify(r.resultErrorPaths) === JSON.stringify(PATHS([PATH_ROOT, 'value'])) && JSON.stringify(r.requiredCapabilities) === JSON.stringify(FULL_SET), r);
    check('open-path suppressed value: flagged as a suppressed branch', r.branchSuppressed === true && r.process === null && r.receipt === null);
  }],
  ['suppressed-process', 'capability-denied', 'AVAILABLE', 'acknowledged', 'suppressed', false, (r) => {
    check('open-path suppressed process: receipt present, process withheld, not absent', r.receipt !== null && r.process === null && r.branchSuppressed === false && r.requiredCapability === 'desktop:control', r);
  }],
  ['suppressed-dependency', 'capability-denied', 'DEPENDENCY_UNAVAILABLE', 'none', 'no-receipt', false, (r) => {
    check('open-path suppressed dependency: status says nothing was submitted', r.status === 'DEPENDENCY_UNAVAILABLE' && r.dependency === null && r.branchSuppressed === true, r);
  }],
  ['suppressed-dependency-guidance', 'capability-denied', 'DEPENDENCY_UNAVAILABLE', 'none', 'no-receipt', false, (r) => {
    check('open-path suppressed guidance: the reason went with the dependency object and is not guessed; still nothing submitted', r.dependency === null && r.branchSuppressed === true && r.actionEffect === 'none' && r.outcomeUnknown === false, r);
    check('open-path suppressed guidance: the error is kept with its path', JSON.stringify(r.resultErrorPaths) === JSON.stringify(PATHS([PATH_ROOT, 'dependency', 'guidance'])), r.resultErrorPaths);
  }],
  ['suppressed-status', 'capability-denied', null, 'unknown', 'no-receipt', true, (r) => {
    check('open-path suppressed status: the client cannot say what the action did', r.response.data[PATH_ROOT] === null && r.actionEffect === 'unknown', r);
  }],
  ['violation-null-root', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('open-path null root with no error is not absence, and the message names this root', r.classification !== 'absent' && r.contractViolation.includes('workspaceOpenPath') && !r.contractViolation.includes('workspaceOpenURL'), r.contractViolation);
  }],
  ['violation-both-branches', 'failed', 'AVAILABLE', 'unknown', 'no-receipt', true, (r) => {
    check('open-path both branches: a contract violation', r.contractViolation !== null);
  }],
  ['violation-not-a-response', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('open-path not a response: never read as success', r.ok === false && r.contractViolation !== null, r);
  }],
  ['violation-dependency-missing', 'failed', 'DEPENDENCY_UNAVAILABLE', 'unknown', 'no-receipt', true, (r) => {
    check('open-path dependency branch missing: a contract violation', r.contractViolation !== null);
  }],
  ['violation-unnamed-status', 'failed', 'PATH_NOT_FOUND', 'unknown', 'no-receipt', true, (r) => {
    check('open-path a reason where a status belongs: a contract violation, not a dependency result', r.contractViolation !== null && r.dependency === null, r);
  }],
  ['violation-wrong-root', 'failed', null, 'unknown', 'no-receipt', true, (r) => {
    check('open-path answer for another root: a violation naming workspaceOpenPath, not success', r.ok === false && r.contractViolation.includes('workspaceOpenPath'), r.contractViolation);
  }],
];
for (const [name, classification, status, effect, processState, unknown, extra] of openPathCases) {
  openPathMode = name;
  const before = openPathRequests.length;
  const before_ms = Date.now();
  const { result, stdout } = await cli(stub.descriptor, pathArgs);
  const after_ms = Date.now();
  const sent = openPathRequests.length - before;
  check(`open-path ${name}: exactly one request, never replayed`, sent === 1, sent);
  check(`open-path ${name}: classification ${classification}`, result.classification === classification, result.classification);
  check(`open-path ${name}: status ${status}`, result.status === status, result.status);
  check(`open-path ${name}: actionEffect ${effect}`, result.actionEffect === effect, result.actionEffect);
  check(`open-path ${name}: processState ${processState}`, result.processState === processState, result.processState);
  check(`open-path ${name}: outcomeUnknown ${unknown}`, result.outcomeUnknown === unknown, result.outcomeUnknown);
  check(`open-path ${name}: command, ok, path, application`, result.command === 'open-path' && result.ok === (classification === 'ok') && result.path === goodPath && result.application === null);
  check(`open-path ${name}: timing fields`, Number.isInteger(result.sentMs) && Number.isInteger(result.receivedMs) && before_ms <= result.sentMs && result.sentMs <= result.receivedMs && result.receivedMs <= after_ms, [before_ms, result.sentMs, result.receivedMs, after_ms]);
  check(`open-path ${name}: secret never printed`, !stdout.includes(secretTextForLaunch));
  check(`open-path ${name}: common fields present`, ['endpoint', 'http', 'response', 'errors', 'transport', 'outcomeUnknown', 'receipt', 'process', 'processState', 'dependency', 'requiredCapability', 'requiredCapabilities', 'phase', 'branchSuppressed', 'resultErrorPaths', 'contractViolation', 'sentMs', 'receivedMs', 'path', 'application'].every((k) => k in result));
  extra(result);
}

// A named application changes the variables and the echo, not the reading.
{
  openPathMode = 'dependency-not-installed';
  const before = openPathRequests.length;
  const { result } = await cli(stub.descriptor, [...pathArgs, ...NAMED]);
  check('open-path named application: one request; the reading is the same', openPathRequests.length - before === 1 && result.classification === 'dependency-unavailable' && result.dependency.reason === 'APPLICATION_NOT_INSTALLED' && result.actionEffect === 'none', result);
  check('open-path named application: echoed as sent', JSON.stringify(result.application) === JSON.stringify({ bundleIdentifier: 'dev.zed.Zed' }), result.application);
  // PATH_NOT_FOUND for a named application is still only "nothing was submitted".
  openPathMode = 'dependency-path-not-found';
  const second = await cli(stub.descriptor, [...pathArgs, ...NAMED, '--application-path', '/Applications/Zed.app']);
  check('open-path named application and a missing path: PATH_NOT_FOUND, nothing submitted', second.result.dependency.reason === 'PATH_NOT_FOUND' && second.result.actionEffect === 'none' && second.result.outcomeUnknown === false && JSON.stringify(second.result.application) === JSON.stringify({ bundleIdentifier: 'dev.zed.Zed', applicationPath: '/Applications/Zed.app' }), second.result);
}

// The request itself: the published operation, literal variables, the bearer.
openPathMode = 'available-process';
{
  const before = openPathRequests.length;
  await cli(stub.descriptor, pathArgs);
  const sent = openPathRequests.at(-1);
  check('open-path request: operation name and exactly one literal variable for the default handler', sent.request.operationName === 'OpenDocumentOrDirectory' && JSON.stringify(sent.request.variables) === JSON.stringify({ path: goodPath }), sent.request.variables);
  check('open-path request: no application key for the default handler', !('application' in sent.request.variables));
  check('open-path request: bearer presented', sent.auth !== null && sent.auth.startsWith('Bearer '));
  check('open-path request: the published document, fragment included', sent.request.query.includes('workspaceOpenPath(path: $path, application: $application)') && sent.request.query.includes('fragment WorkspaceOpenOutcome on WorkspaceOpenResult') && !sent.request.query.includes('workspaceOpenURL') && !sent.request.query.includes('workspaceLaunchApplication'), sent.request.query);
  check('open-path request: one request', openPathRequests.length - before === 1);
  await cli(stub.descriptor, [...pathArgs, ...NAMED]);
  check('open-path request: a named application is {bundleIdentifier} and nothing else', JSON.stringify(openPathRequests.at(-1).request.variables) === JSON.stringify({ path: goodPath, application: { bundleIdentifier: 'dev.zed.Zed' } }), openPathRequests.at(-1).request.variables);
  await cli(stub.descriptor, [...pathArgs, ...NAMED, '--application-path', '/Applications/Zed Two.app']);
  check('open-path request: applicationPath sent verbatim, only when given', JSON.stringify(openPathRequests.at(-1).request.variables) === JSON.stringify({ path: goodPath, application: { bundleIdentifier: 'dev.zed.Zed', applicationPath: '/Applications/Zed Two.app' } }), openPathRequests.at(-1).request.variables);
  await cli(stub.descriptor, [...pathArgs, '--bundle-identifier', '']);
  check('open-path request: a blank identifier is sent for the provider to refuse', JSON.stringify(openPathRequests.at(-1).request.variables) === JSON.stringify({ path: goodPath, application: { bundleIdentifier: '' } }), openPathRequests.at(-1).request.variables);
}

// Bytes in, bytes out: no trimming, expanding, resolving, decoding or encoding, whatever the
// text is. The provider refuses what it refuses; here the stub answers an input error and
// the client must have sent the text untouched and reported the refusal.
openPathMode = 'input-error';
const rawPaths = [
  '',
  'relative/notes.txt',
  '~/notes.txt',
  '$HOME/notes.txt',
  'file:///tmp/notes.txt',
  ' /tmp/notes.txt',
  '/tmp/notes.txt ',
  '/tmp/notes.txt\n',
  '/tmp/notes.txt\r\n',
  '/tmp/a b/c\td',
  '/tmp/*.txt',
  '/tmp/{a,b}/$(id)/`id`/;rm -rf x',
  '/tmp/café/日本/\u{1F600}',
  '/tmp/café/é',
  '/tmp/100%25/%41/%zz',
  '/tmp/x/',
  '//tmp//x/./y/../z',
  // (A NUL cannot be an argv element at all; that is what --path-file is for, below.)
  '/' + 'a'.repeat(5000),
  '--looks-like-an-option',
  '/Applications/Notes.app',
];
for (const raw of rawPaths) {
  const before = openPathRequests.length;
  const { result } = await cli(stub.descriptor, ['open-path', '--secret', secret, `--path=${raw}`]);
  const shown = JSON.stringify(raw).slice(0, 60);
  check(`open-path raw ${shown}: sent byte-for-byte, once`, openPathRequests.length - before === 1 && openPathRequests.at(-1).request.variables.path === raw && JSON.stringify(Object.keys(openPathRequests.at(-1).request.variables)) === JSON.stringify(['path']), shown);
  check(`open-path raw ${shown}: refusal observed, path echoed`, result.classification === 'input-error' && result.path === raw && result.actionEffect === 'none', result.classification);
}
{
  // The two-argument form gives the same text.
  const before = openPathRequests.length;
  await cli(stub.descriptor, ['open-path', '--secret', secret, '--path', '/tmp/a b\\c']);
  check('open-path: separate --path value sent verbatim', openPathRequests.length - before === 1 && openPathRequests.at(-1).request.variables.path === '/tmp/a b\\c');
}

// --path-file: the file's bytes as UTF-8 text, nothing stripped.
const pathFileCases = [
  ['plain', Buffer.from('/tmp/notes.txt', 'utf8')],
  ['trailing LF', Buffer.from('/tmp/notes.txt\n', 'utf8')],
  ['trailing CRLF', Buffer.from('/tmp/notes.txt\r\n', 'utf8')],
  ['two lines', Buffer.from('/tmp/a\n/tmp/b\n', 'utf8')],
  ['leading space and trailing spaces', Buffer.from('  /tmp/notes.txt  ', 'utf8')],
  ['non-ASCII and emoji', Buffer.from('/tmp/café/日本/\u{1F600}.txt', 'utf8')],
  ['decomposed accent', Buffer.from('/tmp/café', 'utf8')],
  ['NUL inside', Buffer.from('/tmp/a\u0000b', 'utf8')],
  ['NUL at the end', Buffer.from('/tmp/a\u0000', 'utf8')],
  ['byte order mark kept', Buffer.concat([Buffer.from([0xef, 0xbb, 0xbf]), Buffer.from('/tmp/notes.txt', 'utf8')])],
  ['empty file', Buffer.alloc(0)],
  ['just a newline', Buffer.from('\n', 'utf8')],
];
const pathFile = join(dir, 'path.txt');
for (const [label, bytes] of pathFileCases) {
  await writeFile(pathFile, bytes);
  const before = openPathRequests.length;
  const { result } = await cli(stub.descriptor, ['open-path', '--secret', secret, '--path-file', pathFile]);
  const expected = bytes.toString('utf8');
  check(`open-path file (${label}): the file's text sent exactly, once`, openPathRequests.length - before === 1 && openPathRequests.at(-1).request.variables.path === expected && Buffer.from(openPathRequests.at(-1).request.variables.path, 'utf8').equals(bytes), openPathRequests.at(-1)?.request.variables);
  check(`open-path file (${label}): path echoed exactly`, result.path === expected);
}
{
  // The same file with a named application: the path is still the file's text.
  await writeFile(pathFile, Buffer.from('/tmp/dir with space/\n', 'utf8'));
  const before = openPathRequests.length;
  await cli(stub.descriptor, ['open-path', '--secret', secret, '--path-file', pathFile, ...NAMED]);
  check('open-path file with a named application: path exact, application sent', openPathRequests.length - before === 1 && openPathRequests.at(-1).request.variables.path === '/tmp/dir with space/\n' && openPathRequests.at(-1).request.variables.application.bundleIdentifier === 'dev.zed.Zed', openPathRequests.at(-1).request.variables);
}
{
  // Bytes that are not UTF-8 cannot be a GraphQL string; nothing is sent, and nothing is repaired.
  const before = openPathRequests.length;
  for (const [label, bytes] of [
    ['invalid byte', Buffer.from([0x2f, 0x74, 0x6d, 0x70, 0x2f, 0xff, 0xfe])],
    ['truncated sequence', Buffer.from([0x2f, 0x74, 0xe6, 0x97])],
    ['overlong NUL', Buffer.from([0x2f, 0xc0, 0x80])],
    ['lone surrogate encoded', Buffer.from([0x2f, 0xed, 0xa0, 0x80])],
    ['Latin-1 name', Buffer.from('/tmp/caf\xe9', 'latin1')],
  ]) {
    await writeFile(pathFile, bytes);
    const { result } = await cli(stub.descriptor, ['open-path', '--secret', secret, '--path-file', pathFile]);
    check(`open-path file (not UTF-8: ${label}): nothing sent, reported as a client error`, openPathRequests.length === before && result.classification === 'failed' && /UTF-8/.test(result.clientError) && result.ok === false && result.outcomeUnknown === false, result);
  }
  const { result: missing } = await cli(stub.descriptor, ['open-path', '--secret', secret, '--path-file', join(dir, 'absent.txt')]);
  check('open-path file (missing): nothing sent, reported as a client error', openPathRequests.length === before && missing.classification === 'failed' && typeof missing.clientError === 'string', missing);
  const neither = await cli(stub.descriptor, ['open-path', '--secret', secret]);
  const both = await cli(stub.descriptor, ['open-path', '--secret', secret, '--path', '/tmp/x', '--path-file', pathFile]);
  const pathOnly = await cli(stub.descriptor, ['open-path', '--secret', secret, '--path', '/tmp/x', '--application-path', '/Applications/Zed.app']);
  const twice = await cli(stub.descriptor, ['open-path', '--secret', secret, '--path', '/tmp/x', '--path', '/tmp/y']);
  check('open-path: --path or --path-file is required, and not both; --application-path needs an identifier; nothing sent',
    openPathRequests.length === before && [neither, both, pathOnly, twice].every((x) => x.result.classification === 'request-error' && x.result.ok === false), [neither.result, both.result, pathOnly.result, twice.result]);
}
openPathMode = 'available-process';

// --- search -------------------------------------------------------------
// The client-owned flow. Whatever the suggestion source does, exactly one
// OpenSearchURL carries the typed-query URL, and the search engine is never contacted.
openUrlMode = 'available-process';
const sources = await startSuggestionSources();
const queries = [
  // query, expected percent-encoding of its UTF-8 bytes (written out by hand)
  ['café 日本', 'caf%C3%A9%20%E6%97%A5%E6%9C%AC'],
  ['cats & dogs #1 100% "quoted"', 'cats%20%26%20dogs%20%231%20100%25%20%22quoted%22'],
  ["a-b_c.d~e+f*g!h(i)'j/k?l=m", 'a-b_c.d~e%2Bf%2Ag%21h%28i%29%27j%2Fk%3Fl%3Dm'],
  ['%s $& $1 \\ \t', '%25s%20%24%26%20%241%20%5C%20%09'],
  ['\u{1F600}', '%F0%9F%98%80'],
  ['', ''],
];
const GOOGLE = 'https://www.google.com/search?q=';
const sourceNames = ['answers', 'garbage', 'refused', 'hang', 'status', 'redirect'];
const expectedOutcome = { answers: 'answered', garbage: 'failed', refused: 'failed', hang: 'failed', status: 'failed', redirect: 'failed' };
for (const [query, encoded] of queries) {
  for (const sourceName of [...sourceNames, null]) {
    const label = `search ${JSON.stringify(query)} / ${sourceName ?? 'no source'}`;
    const before = openUrlRequests.length;
    const started = Date.now();
    const args = ['search', '--secret', secret, `--query=${query}`];
    if (sourceName !== null) args.push('--suggestions-url', sources.sources[sourceName]);
    const { result, stdout } = await cli(stub.descriptor, args);
    const elapsed = Date.now() - started;
    check(`${label}: exactly one OpenSearchURL request`, openUrlRequests.length - before === 1, openUrlRequests.length - before);
    const sent = openUrlRequests.at(-1);
    check(`${label}: it carries the typed-query URL, percent-encoded`, sent.request.operationName === 'OpenSearchURL' && sent.request.variables.url === GOOGLE + encoded && JSON.stringify(sent.request.variables) === JSON.stringify({ url: GOOGLE + encoded }), sent.request.variables);
    check(`${label}: output is the open-url output plus search`, result.command === 'search' && result.classification === 'ok' && result.url === GOOGLE + encoded && result.status === 'AVAILABLE' && result.process.pid === PROCESS.pid && result.search.query === query && result.search.urlBuilt === GOOGLE + encoded && result.search.engineTemplate === GOOGLE + '%s', result.search);
    const outcome = sourceName === null ? 'not-attempted' : expectedOutcome[sourceName];
    check(`${label}: suggestions ${outcome}, never fatal`, result.search.suggestions.outcome === outcome && result.search.suggestions.attempted === (sourceName !== null) && typeof result.search.suggestions.detail === 'string', result.search.suggestions);
    if (sourceName === 'hang') check(`${label}: gave up after about two seconds`, elapsed >= 1900 && elapsed < 6000 && /2000 ms/.test(result.search.suggestions.detail), [elapsed, result.search.suggestions]);
    check(`${label}: secret never printed`, !stdout.includes(secretTextForLaunch));
  }
}
check('search: the search engine was never contacted', sources.hits.engine.length === 0, sources.hits.engine);
check('search: the answering source got one plain GET per query, the query percent-encoded into its template',
  sources.hits.answers.length === queries.length &&
    sources.hits.answers.every((h) => h.method === 'GET' && !('authorization' in h.headers)) &&
    sources.hits.answers[0].url === '/complete?q=caf%C3%A9%20%E6%97%A5%E6%9C%AC',
  sources.hits.answers.map((h) => h.url));
check('search: the redirecting source was not followed', sources.hits.redirect.length === queries.length && sources.hits.engine.length === 0);

// A custom engine template, the engine on a live port: still only text, never contacted.
{
  const before = openUrlRequests.length;
  const template = `http://127.0.0.1:${sources.enginePort}/s?hl=en&q=%s&safe=1`;
  const { result } = await cli(stub.descriptor, ['search', '--secret', secret, '--query', 'café 日本', '--engine-template', template, '--suggestions-url', sources.sources.answers]);
  check('search: custom engine template filled and opened once', openUrlRequests.length - before === 1 && openUrlRequests.at(-1).request.variables.url === `http://127.0.0.1:${sources.enginePort}/s?hl=en&q=caf%C3%A9%20%E6%97%A5%E6%9C%AC&safe=1` && result.search.engineTemplate === template, result.search);
  check('search: still no request to the engine', sources.hits.engine.length === 0, sources.hits.engine);
}

// Whatever Koine answers is the open-url reading, with the search facts still reported.
for (const mode of ['denied-lacks-workspace', 'dependency-no-default-handler', 'input-error', 'failed-at-action']) {
  openUrlMode = mode;
  const before = openUrlRequests.length;
  const { result } = await cli(stub.descriptor, ['search', '--secret', secret, '--query', 'q w', '--suggestions-url', sources.sources.refused]);
  const expected = { 'denied-lacks-workspace': 'capability-denied', 'dependency-no-default-handler': 'dependency-unavailable', 'input-error': 'input-error', 'failed-at-action': 'failed' }[mode];
  check(`search with Koine answering ${mode}: one request, classified ${expected}, search facts kept`, openUrlRequests.length - before === 1 && result.classification === expected && result.search.urlBuilt === `${GOOGLE}q%20w` && result.search.suggestions.outcome === 'failed', result);
}
openUrlMode = 'available-process';

// A template that cannot be filled is a usage error: nothing is sent.
{
  const before = openUrlRequests.length;
  const none = await cli(stub.descriptor, ['search', '--secret', secret, '--query', 'x', '--engine-template', 'https://e.example/?q=']);
  const two = await cli(stub.descriptor, ['search', '--secret', secret, '--query', 'x', '--engine-template', 'https://e.example/?q=%s&r=%s']);
  const badSuggest = await cli(stub.descriptor, ['search', '--secret', secret, '--query', 'x', '--suggestions-url', 'https://s.example/?q=']);
  const noQuery = await cli(stub.descriptor, ['search', '--secret', secret]);
  check('search: a template without exactly one %s, or no --query, is refused before anything is sent',
    openUrlRequests.length === before && [none, two, badSuggest, noQuery].every((x) => x.result.classification === 'request-error'), [none.result, two.result, badSuggest.result, noQuery.result]);
}
sources.close();

// --- service unavailable and unknown outcome ----------------------------
stub.close();
await new Promise((r) => setTimeout(r, 50));
const down = await cli(stub.descriptor, ['inspect', '--secret', secret]);
check('service down -> service-unavailable', down.result.classification === 'service-unavailable', down.result);
const downMutation = await cli(stub.descriptor, ['focus', '--secret', secret, '--ref', ref]);
check('mutation with no connection -> service-unavailable', downMutation.result.classification === 'service-unavailable', downMutation.result);
const downLaunch = await cli(stub.descriptor, launchArgs);
check('launch with no connection -> service-unavailable, nothing submitted', downLaunch.result.classification === 'service-unavailable' && downLaunch.result.actionEffect === 'none' && downLaunch.result.outcomeUnknown === false && downLaunch.result.sentMs === null && downLaunch.result.receivedMs === null, downLaunch.result);

const downOpen = await cli(stub.descriptor, openArgs);
check('open-url with no connection -> service-unavailable, nothing submitted', downOpen.result.classification === 'service-unavailable' && downOpen.result.actionEffect === 'none' && downOpen.result.outcomeUnknown === false && downOpen.result.sentMs === null && downOpen.result.receivedMs === null && downOpen.result.url === goodUrl, downOpen.result);
const downPath = await cli(stub.descriptor, pathArgs);
check('open-path with no connection -> service-unavailable, nothing submitted', downPath.result.classification === 'service-unavailable' && downPath.result.actionEffect === 'none' && downPath.result.outcomeUnknown === false && downPath.result.sentMs === null && downPath.result.receivedMs === null && downPath.result.path === goodPath && downPath.result.application === null, downPath.result);
const downSearch = await cli(stub.descriptor, ['search', '--secret', secret, '--query', 'café 日本']);
check('search with no connection -> service-unavailable, URL still built, suggestions not attempted', downSearch.result.classification === 'service-unavailable' && downSearch.result.search.urlBuilt === `${GOOGLE}caf%C3%A9%20%E6%97%A5%E6%9C%AC` && downSearch.result.search.suggestions.outcome === 'not-attempted', downSearch.result);

const missing = await cli(join(dir, 'no-such-descriptor.json'), ['probe']);
check('no descriptor -> service-unavailable', missing.result.classification === 'service-unavailable');

// a server that accepts the connection then drops it mid-mutation
const { createServer } = await import('node:http');
let killed = 0;
const killer = createServer((req, res) => { killed += 1; req.socket.destroy(); });
await new Promise((r) => killer.listen(0, '127.0.0.1', r));
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
killed = 0;
const lostOpen = await cli(killerDescriptor, openArgs);
check('open-url cut after send -> unknown-outcome, sent once, never replayed', lostOpen.result.classification === 'unknown-outcome' && lostOpen.result.outcomeUnknown === true && lostOpen.result.actionEffect === 'unknown' && killed === 1 && lostOpen.result.processState === 'no-receipt' && lostOpen.result.receivedMs === null && Number.isInteger(lostOpen.result.sentMs), [killed, lostOpen.result]);
killed = 0;
const lostPath = await cli(killerDescriptor, [...pathArgs, ...NAMED]);
check('open-path cut after send -> unknown-outcome, sent once, never replayed', lostPath.result.classification === 'unknown-outcome' && lostPath.result.outcomeUnknown === true && lostPath.result.actionEffect === 'unknown' && killed === 1 && lostPath.result.processState === 'no-receipt' && lostPath.result.receivedMs === null && Number.isInteger(lostPath.result.sentMs) && lostPath.result.path === goodPath && lostPath.result.application.bundleIdentifier === 'dev.zed.Zed', [killed, lostPath.result]);
killed = 0;
const lostSearch = await cli(killerDescriptor, ['search', '--secret', secret, '--query', 'café 日本']);
check('search cut after send -> unknown-outcome, one request, URL reported', lostSearch.result.classification === 'unknown-outcome' && lostSearch.result.outcomeUnknown === true && killed === 1 && lostSearch.result.search.urlBuilt === `${GOOGLE}caf%C3%A9%20%E6%97%A5%E6%9C%AC`, [killed, lostSearch.result]);
const lostQuery = await cli(killerDescriptor, ['inspect', '--secret', secret]);
check('query cut after send -> service-unavailable', lostQuery.result.classification === 'service-unavailable', lostQuery.result.classification);
killer.close();

console.log(failures === 0 ? '\nall checks passed' : `\n${failures} check(s) failed`);
process.exit(failures === 0 ? 0 : 1);
