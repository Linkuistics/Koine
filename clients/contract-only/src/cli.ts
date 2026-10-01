import { readEndpoint, DESCRIPTOR_PATH, type EndpointLookup } from './adapter/endpoint.js';
import { loadOrCreateCredential, type Credential } from './adapter/credential.js';
import { absentIfNullRoot, send, type SendResult } from './adapter/transport.js';
import type { Classification } from './adapter/classification.js';
import {
  captureProcessIdentity,
  findApplication,
  type ProcessIdentity,
} from './adapter/process-identity.js';
import { interpretLaunch, interpretOpenURL, type WorkspaceOpenFacts } from './adapter/workspace-open.js';
import {
  askSuggestions,
  DEFAULT_ENGINE_TEMPLATE,
  fillTemplate,
  splitTemplate,
  type SuggestionReport,
} from './adapter/search.js';
import {
  GENERATED_AGAINST_CONTRACT_VERSION,
  GENERATED_AGAINST_SCHEMA_DIGEST,
  INTROSPECTION_QUERY,
} from './generated/contract.js';
import {
  DesktopChoicesDocument,
  FocusDesktopWindowDocument,
  InspectOwnConnectionDocument,
  LaunchInstalledApplicationDocument,
  OpenSearchUrlDocument,
  PollOwnGrantRequestDocument,
  RequestDesktopGrantDocument,
} from './generated/graphql.js';
import { readFile, writeFile } from 'node:fs/promises';

type Json = Record<string, unknown>;

const USAGE = `koine-client <command> [options]

  probe
  enrol      --secret <path> --label <label> --capability <cap> [--capability <cap>]...
  poll       --secret <path>
  inspect    --secret <path>
  introspect --secret <path> --out <path>
  choices    --secret <path> --application <name>
  choices    --secret <path> --pid <n> --started-at <instant>
  focus      --secret <path> --ref <reference>
  launch     --secret <path> --bundle-identifier <id> [--application-path <absolute path>]
  open-url   --secret <path> (--url <text> | --url-file <path>)
  search     --secret <path> --query <text> [--engine-template <url with one %s>] [--suggestions-url <url with one %s>]

Any --name value may also be written --name=value, which is the only way to give a
value that itself begins with "--".
`;

interface Args {
  readonly command: string;
  readonly single: ReadonlyMap<string, string>;
  readonly capabilities: readonly string[];
}

function parseArgs(argv: readonly string[]): Args {
  const command = argv[0] ?? '';
  const single = new Map<string, string>();
  const capabilities: string[] = [];
  for (let i = 1; i < argv.length; i += 1) {
    const flag = argv[i];
    if (flag === undefined || !flag.startsWith('--')) {
      throw new UsageError(`unexpected argument ${JSON.stringify(flag ?? '')}`);
    }
    // `--name=value` carries its value in the same argument, so a value that begins
    // with `--` (a query, a URL under test) can still be given.
    const equals = flag.indexOf('=');
    let name = flag;
    let value: string | undefined;
    if (equals > 2) {
      name = flag.slice(0, equals);
      value = flag.slice(equals + 1);
    } else {
      value = argv[i + 1];
      if (value === undefined || value.startsWith('--')) {
        throw new UsageError(`option ${flag} needs a value`);
      }
      i += 1;
    }
    if (name === '--capability') capabilities.push(value);
    else if (single.has(name.slice(2))) throw new UsageError(`option ${name} given twice`);
    else single.set(name.slice(2), value);
  }
  return { command, single, capabilities };
}

class UsageError extends Error {}

function require_(args: Args, name: string): string {
  const value = args.single.get(name);
  if (value === undefined) throw new UsageError(`--${name} is required`);
  return value;
}

/** The wire facts every command that made a request reports identically. */
function wire(result: SendResult): Json {
  return {
    endpoint: result.endpoint,
    http: result.http,
    response: result.response,
    errors: result.errors,
    transport: result.transport,
    outcomeUnknown: result.outcomeUnknown,
  };
}

function credentialFacts(credential: Credential, path: string): Json {
  return { path, mode: credential.mode, created: credential.created };
}

async function commandProbe(): Promise<Json> {
  const lookup: EndpointLookup = await readEndpoint();
  const descriptor: Json = lookup.found
    ? {
        path: DESCRIPTOR_PATH,
        present: true,
        mode: lookup.endpoint.descriptorMode,
        descriptorVersion: lookup.endpoint.descriptor.descriptorVersion,
        instanceId: lookup.endpoint.descriptor.instanceId,
        pid: lookup.endpoint.descriptor.pid,
        port: lookup.endpoint.descriptor.port,
        graphqlPath: lookup.endpoint.descriptor.path,
        contractVersion: lookup.endpoint.descriptor.contractVersion,
        url: lookup.endpoint.url,
      }
    : { path: DESCRIPTOR_PATH, present: false, detail: lookup.detail };

  if (!lookup.found) {
    return {
      classification: 'service-unavailable' satisfies Classification,
      descriptor,
      serviceReachable: false,
      endpoint: null,
      http: null,
      response: null,
      errors: [],
      transport: `no endpoint: ${lookup.detail}`,
      outcomeUnknown: false,
    };
  }

  // A credential-free, non-enrollment request. The spec answers it 401 before
  // execution and it spends no anonymous-enrollment budget, so it is a safe
  // liveness probe that can be repeated.
  const result = await send({
    document: 'query KoineProbe { __typename }',
    operationName: 'KoineProbe',
    kind: 'query',
    timeoutMs: 5_000,
  });
  const reachable = result.http !== null;
  return {
    classification: (reachable ? 'ok' : 'service-unavailable') satisfies Classification,
    descriptor,
    serviceReachable: reachable,
    probeClassification: result.classification,
    authenticationDemanded: result.http?.status === 401,
    ...wire(result),
  };
}

async function commandEnrol(args: Args): Promise<Json> {
  const secretPath = require_(args, 'secret');
  const label = require_(args, 'label');
  if (args.capabilities.length === 0) throw new UsageError('--capability is required at least once');
  const credential = await loadOrCreateCredential(secretPath);

  // Anonymous enrollment: no Authorization header. Presenting the not-yet-
  // granted secret would be an invalid credential and answered 401 before
  // execution, and a status-only secret "cannot be mixed with ordinary
  // operations". Retrying with the same digest, label and set is answered with
  // the original receipt, which is what makes this command safe to repeat.
  const result = await send({
    document: RequestDesktopGrantDocument.toString(),
    operationName: 'RequestDesktopGrant',
    kind: 'mutation',
    variables: {
      input: {
        credentialDigest: credential.digest,
        clientLabel: label,
        capabilities: args.capabilities,
      },
    },
  });

  const receipt = (result.data?.['koineRequestGrant'] ?? null) as Json | null;
  return {
    classification: absentIfNullRoot(result, 'koineRequestGrant'),
    credential: credentialFacts(credential, secretPath),
    label,
    requestedCapabilities: args.capabilities,
    requestId: (receipt?.['requestId'] as string | undefined) ?? null,
    comparisonCode: (receipt?.['comparisonCode'] as string | undefined) ?? null,
    ...wire(result),
  };
}

async function commandPoll(args: Args): Promise<Json> {
  const secretPath = require_(args, 'secret');
  const credential = await loadOrCreateCredential(secretPath);
  const result = await send({
    document: PollOwnGrantRequestDocument.toString(),
    operationName: 'PollOwnGrantRequest',
    kind: 'query',
    secret: credential.secret,
  });
  const request = (result.data?.['koineGrantRequest'] ?? null) as Json | null;
  return {
    classification: absentIfNullRoot(result, 'koineGrantRequest'),
    credential: credentialFacts(credential, secretPath),
    requestState: (request?.['state'] as string | undefined) ?? null,
    grant: (request?.['grant'] as Json | undefined) ?? null,
    ...wire(result),
  };
}

async function commandInspect(args: Args): Promise<Json> {
  const secretPath = require_(args, 'secret');
  const credential = await loadOrCreateCredential(secretPath);
  const result = await send({
    document: InspectOwnConnectionDocument.toString(),
    operationName: 'InspectOwnConnection',
    kind: 'query',
    secret: credential.secret,
  });
  const koine = (result.data?.['koine'] ?? null) as Json | null;
  return {
    classification: result.classification,
    credential: credentialFacts(credential, secretPath),
    koine,
    generatedAgainst: {
      contractVersion: GENERATED_AGAINST_CONTRACT_VERSION,
      schemaDigest: GENERATED_AGAINST_SCHEMA_DIGEST,
    },
    ...wire(result),
  };
}

async function commandIntrospect(args: Args): Promise<Json> {
  const secretPath = require_(args, 'secret');
  const out = require_(args, 'out');
  const credential = await loadOrCreateCredential(secretPath);

  const introspection = await send({
    document: INTROSPECTION_QUERY,
    operationName: 'IntrospectionQuery',
    kind: 'query',
    secret: credential.secret,
  });

  const bodyText =
    typeof introspection.response === 'string'
      ? introspection.response
      : introspection.response === null
        ? ''
        : JSON.stringify(introspection.response);
  const byteCount = Buffer.byteLength(bodyText, 'utf8');
  await writeFile(out, bodyText, 'utf8');

  // The digest as reported now, over the same connection and session.
  const metadata = await send({
    document: InspectOwnConnectionDocument.toString(),
    operationName: 'InspectOwnConnection',
    kind: 'query',
    secret: credential.secret,
  });
  const koine = (metadata.data?.['koine'] ?? null) as Json | null;
  const servedDigest = (koine?.['schemaDigest'] as string | undefined) ?? null;

  return {
    classification: introspection.classification,
    credential: credentialFacts(credential, secretPath),
    out,
    byteCount,
    servedSchemaDigest: servedDigest,
    generatedAgainstSchemaDigest: GENERATED_AGAINST_SCHEMA_DIGEST,
    schemaDigestsEqual: servedDigest !== null && servedDigest === GENERATED_AGAINST_SCHEMA_DIGEST,
    servedContractVersion: (koine?.['contractVersion'] as string | undefined) ?? null,
    generatedAgainstContractVersion: GENERATED_AGAINST_CONTRACT_VERSION,
    metadataClassification: metadata.classification,
    metadataResponse: metadata.response,
    ...wire(introspection),
  };
}

async function resolveProcess(args: Args): Promise<
  | { readonly kind: 'identity'; readonly identity: ProcessIdentity; readonly extra: Json }
  | { readonly kind: 'absent'; readonly extra: Json }
> {
  const pidText = args.single.get('pid');
  const startedAt = args.single.get('started-at');
  const application = args.single.get('application');

  if (pidText !== undefined || startedAt !== undefined) {
    if (application !== undefined) throw new UsageError('--application cannot be combined with --pid');
    if (pidText === undefined || startedAt === undefined) {
      throw new UsageError('--pid and --started-at must be given together');
    }
    const pid = Number(pidText);
    if (!Number.isInteger(pid) || pid <= 0) throw new UsageError('--pid must be a positive integer');
    return {
      kind: 'identity',
      identity: {
        pid,
        startedAt,
        startedAtSource: 'literal',
        startedAtPrecision: 'microsecond',
        notes: [],
      },
      extra: { application: null },
    };
  }

  if (application === undefined) {
    throw new UsageError('choices needs either --application or --pid with --started-at');
  }
  const candidates = await findApplication(application);
  const chosen = candidates[0];
  if (chosen === undefined) {
    return {
      kind: 'absent',
      extra: {
        application,
        candidates: [],
        absence: 'no-such-running-application',
        detail: `no running process matches ${JSON.stringify(application)}`,
      },
    };
  }
  const identity = await captureProcessIdentity(chosen.pid);
  if (identity === null) {
    return {
      kind: 'absent',
      extra: {
        application,
        candidates,
        absence: 'process-start-instant-unavailable',
        detail: `pid ${chosen.pid} matched but its start instant could not be read; the contract makes a missing reliable start instant an input error, not permission to target by pid alone`,
      },
    };
  }
  return { kind: 'identity', identity, extra: { application, candidates } };
}

async function commandChoices(args: Args): Promise<Json> {
  const secretPath = require_(args, 'secret');
  const credential = await loadOrCreateCredential(secretPath);
  const resolution = await resolveProcess(args);

  if (resolution.kind === 'absent') {
    return {
      classification: 'absent' satisfies Classification,
      credential: credentialFacts(credential, secretPath),
      process: null,
      desktopApplication: null,
      endpoint: null,
      http: null,
      response: null,
      errors: [],
      transport: null,
      outcomeUnknown: false,
      ...resolution.extra,
    };
  }

  const { identity } = resolution;
  const result = await send({
    document: DesktopChoicesDocument.toString(),
    operationName: 'DesktopChoices',
    kind: 'query',
    secret: credential.secret,
    variables: { process: { pid: identity.pid, startedAt: identity.startedAt } },
  });

  const app = (result.data?.['desktopApplication'] ?? null) as Json | null;
  const classification = absentIfNullRoot(result, 'desktopApplication');
  return {
    classification,
    credential: credentialFacts(credential, secretPath),
    process: {
      pid: identity.pid,
      startedAt: identity.startedAt,
      startedAtSource: identity.startedAtSource,
      startedAtPrecision: identity.startedAtPrecision,
      notes: identity.notes,
    },
    ...(classification === 'absent' ? { absence: 'server-null' } : {}),
    desktopApplication: app,
    windows: (app?.['windows'] as unknown[] | undefined) ?? null,
    ...resolution.extra,
    ...wire(result),
  };
}

async function commandFocus(args: Args): Promise<Json> {
  const secretPath = require_(args, 'secret');
  const ref = require_(args, 'ref');
  const credential = await loadOrCreateCredential(secretPath);

  // `ref` goes back exactly as the server handed it over: never parsed,
  // normalised or rebuilt.
  const result = await send({
    document: FocusDesktopWindowDocument.toString(),
    operationName: 'FocusDesktopWindow',
    kind: 'mutation',
    secret: credential.secret,
    variables: { ref },
  });
  const receipt = (result.data?.['desktopFocusWindow'] ?? null) as Json | null;
  return {
    classification: absentIfNullRoot(result, 'desktopFocusWindow'),
    credential: credentialFacts(credential, secretPath),
    submittedRef: ref,
    receipt,
    receiptRefMatchesSubmitted:
      receipt === null ? null : receipt['ref'] === ref,
    ...wire(result),
  };
}

async function commandLaunch(args: Args): Promise<Json> {
  const secretPath = require_(args, 'secret');
  const bundleIdentifier = require_(args, 'bundle-identifier');
  const applicationPath = args.single.get('application-path');
  const credential = await loadOrCreateCredential(secretPath);

  // Sent exactly once, whatever happens: a launch is not safe to repeat, and a
  // lost answer is `unknown-outcome`. Values go in as literal variables; nothing
  // is checked client-side, so an input the provider refuses is refused by the
  // provider, at the original path, where this client can report it.
  const application: Json = {
    bundleIdentifier,
    ...(applicationPath === undefined ? {} : { applicationPath }),
  };
  const result = await send({
    document: LaunchInstalledApplicationDocument.toString(),
    operationName: 'LaunchInstalledApplication',
    kind: 'mutation',
    secret: credential.secret,
    variables: { application },
  });

  const facts = interpretLaunch(result);
  return {
    classification: facts.classification,
    credential: credentialFacts(credential, secretPath),
    application,
    sentMs: result.sentMs,
    receivedMs: result.receivedMs,
    status: facts.status,
    actionEffect: facts.actionEffect,
    receipt: facts.receipt,
    process: facts.process,
    processState: facts.processState,
    choicesArguments: facts.choicesArguments,
    dependency: facts.dependency,
    requiredCapability: facts.requiredCapability,
    requiredCapabilities: facts.requiredCapabilities,
    phase: facts.phase,
    branchSuppressed: facts.branchSuppressed,
    resultErrorPaths: facts.resultErrorPaths,
    contractViolation: facts.contractViolation,
    ...wire(result),
    // After `wire`: the launch reading of "unknown" is stricter than the generic one.
    outcomeUnknown: facts.outcomeUnknown,
  };
}

/**
 * The facts every `workspaceOpenURL` command prints. `url` is the exact text that
 * went into the variable. Sent exactly once, whatever happens: a URL open is not
 * safe to repeat, and a lost answer is `unknown-outcome`. Nothing is checked,
 * trimmed, normalised or encoded here, so a URL the provider refuses (raw Unicode,
 * whitespace, a backslash) is refused by the provider, at the original path, where
 * this client can report it.
 */
async function openUrl(secretPath: string, credential: Credential, url: string): Promise<Json> {
  const result = await send({
    document: OpenSearchUrlDocument.toString(),
    operationName: 'OpenSearchURL',
    kind: 'mutation',
    secret: credential.secret,
    variables: { url },
  });
  const facts: WorkspaceOpenFacts = interpretOpenURL(result);
  return {
    classification: facts.classification,
    credential: credentialFacts(credential, secretPath),
    url,
    sentMs: result.sentMs,
    receivedMs: result.receivedMs,
    status: facts.status,
    actionEffect: facts.actionEffect,
    receipt: facts.receipt,
    process: facts.process,
    processState: facts.processState,
    choicesArguments: facts.choicesArguments,
    dependency: facts.dependency,
    requiredCapability: facts.requiredCapability,
    requiredCapabilities: facts.requiredCapabilities,
    phase: facts.phase,
    branchSuppressed: facts.branchSuppressed,
    resultErrorPaths: facts.resultErrorPaths,
    contractViolation: facts.contractViolation,
    ...wire(result),
    // After `wire`: the workspace reading of "unknown" is stricter than the generic one.
    outcomeUnknown: facts.outcomeUnknown,
  };
}

async function commandOpenUrl(args: Args): Promise<Json> {
  const secretPath = require_(args, 'secret');
  const literal = args.single.get('url');
  const file = args.single.get('url-file');
  if (literal === undefined && file === undefined) throw new UsageError('--url or --url-file is required');
  if (literal !== undefined && file !== undefined) throw new UsageError('--url and --url-file cannot be combined');

  let url: string;
  if (literal !== undefined) url = literal;
  else {
    // The file's bytes, as UTF-8, exactly: no trailing-newline stripping, no BOM
    // removal, no trimming. Bytes that are not UTF-8 cannot be a GraphQL string, so
    // they are a client error, not something to repair with U+FFFD.
    const bytes = await readFile(file as string);
    try {
      url = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true }).decode(bytes);
    } catch {
      throw new Error(`${file} is not valid UTF-8; nothing was sent`);
    }
  }

  const credential = await loadOrCreateCredential(secretPath);
  return openUrl(secretPath, credential, url);
}

async function commandSearch(args: Args): Promise<Json> {
  const secretPath = require_(args, 'secret');
  const query = require_(args, 'query');
  const engineTemplate = args.single.get('engine-template') ?? DEFAULT_ENGINE_TEMPLATE;
  const suggestionsUrl = args.single.get('suggestions-url');
  const engineParts = splitTemplate(engineTemplate);
  if (typeof engineParts === 'string') throw new UsageError(`--engine-template is unusable: ${engineParts}`);
  if (suggestionsUrl !== undefined) {
    const parts = splitTemplate(suggestionsUrl);
    if (typeof parts === 'string') throw new UsageError(`--suggestions-url is unusable: ${parts}`);
  }
  const credential = await loadOrCreateCredential(secretPath);

  // (a) Ask the suggestion source, if one was given. It is never fatal and never
  // decides anything: this command has no chooser, so whatever it answers or fails
  // to answer, (b) the typed query is what is opened. The search engine itself is
  // never contacted from here: the template is only text that goes to Koine.
  const suggestions: SuggestionReport = await askSuggestions(suggestionsUrl, query);

  // (b) The typed-query URL, then exactly one open.
  const urlBuilt = fillTemplate(engineTemplate, query);
  const opened = await openUrl(secretPath, credential, urlBuilt);
  return { ...opened, search: { query, engineTemplate, urlBuilt, suggestions } };
}

function redact(payload: Json, secrets: readonly string[]): string {
  let text = JSON.stringify(payload);
  for (const secret of secrets) {
    if (secret.length === 0) continue;
    text = text.split(secret).join('[redacted]');
  }
  return text;
}

async function main(): Promise<void> {
  const argv = process.argv.slice(2);
  let payload: Json;
  let command = argv[0] ?? '';
  const secrets: string[] = [];

  try {
    const args = parseArgs(argv);
    command = args.command;
    const secretPath = args.single.get('secret');
    if (secretPath !== undefined && command !== 'probe') {
      try {
        const credential = await loadOrCreateCredential(secretPath);
        secrets.push(credential.secret, credential.digest);
      } catch {
        /* the command itself reports the failure */
      }
    }

    switch (command) {
      case 'probe':
        payload = await commandProbe();
        break;
      case 'enrol':
      case 'enroll':
        payload = await commandEnrol(args);
        break;
      case 'poll':
        payload = await commandPoll(args);
        break;
      case 'inspect':
        payload = await commandInspect(args);
        break;
      case 'introspect':
        payload = await commandIntrospect(args);
        break;
      case 'choices':
        payload = await commandChoices(args);
        break;
      case 'focus':
        payload = await commandFocus(args);
        break;
      case 'launch':
        payload = await commandLaunch(args);
        break;
      case 'open-url':
        payload = await commandOpenUrl(args);
        break;
      case 'search':
        payload = await commandSearch(args);
        break;
      default:
        throw new UsageError(`unknown command ${JSON.stringify(command)}`);
    }
  } catch (cause) {
    const usage = cause instanceof UsageError;
    if (usage) process.stderr.write(USAGE);
    payload = {
      classification: (usage ? 'request-error' : 'failed') satisfies Classification,
      clientError: cause instanceof Error ? cause.message : String(cause),
      endpoint: null,
      http: null,
      response: null,
      errors: [],
      transport: null,
      outcomeUnknown: false,
    };
  }

  const line = redact({ command, ok: payload['classification'] === 'ok', ...payload }, secrets);
  process.stdout.write(`${line}\n`);
}

await main();
process.exit(0);
