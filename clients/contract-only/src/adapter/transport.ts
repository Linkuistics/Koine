import { readEndpoint, type Endpoint } from './endpoint.js';
import {
  classifyExecutionError,
  classifyStatus,
  mostSevere,
  type ClassifiedError,
  type Classification,
  type GraphQLBody,
} from './classification.js';

export type OperationKind = 'query' | 'mutation';

export interface SendOptions {
  readonly document: string;
  readonly operationName: string;
  readonly kind: OperationKind;
  readonly variables?: Record<string, unknown>;
  /** Omitted for anonymous enrollment, which must not present a credential. */
  readonly secret?: string | undefined;
  readonly timeoutMs?: number;
}

export interface HttpFactsOut {
  readonly status: number;
  readonly contentType: string | null;
  readonly cacheControl: string | null;
  readonly retryAfterSeconds: number | null;
}

export interface SendResult {
  readonly classification: Classification;
  readonly endpoint: { readonly url: string; readonly instanceId: string } | null;
  readonly http: HttpFactsOut | null;
  /** The raw GraphQL response body, parsed if it was JSON, else the text. */
  readonly response: unknown;
  readonly errors: readonly ClassifiedError[];
  readonly transport: string | null;
  /** True when a mutation may have run even though no result was read back. */
  readonly outcomeUnknown: boolean;
  readonly data: Record<string, unknown> | null;
}

const DEFAULT_TIMEOUT_MS = 20_000;

/** Connect-time failures prove nothing was executed. */
const NOT_SENT = new Set(['ECONNREFUSED', 'ENOTFOUND', 'EHOSTUNREACH', 'ENETUNREACH', 'EACCES']);

function causeCode(error: unknown): string {
  const seen = new Set<unknown>();
  let current: unknown = error;
  while (current !== null && typeof current === 'object' && !seen.has(current)) {
    seen.add(current);
    const code = (current as { code?: unknown }).code;
    if (typeof code === 'string') return code;
    current = (current as { cause?: unknown }).cause;
  }
  if (error instanceof Error && error.name === 'TimeoutError') return 'ETIMEDOUT';
  if (error instanceof Error && error.name === 'AbortError') return 'ETIMEDOUT';
  return 'UNKNOWN';
}

export async function send(options: SendOptions): Promise<SendResult> {
  const lookup = await readEndpoint();
  if (!lookup.found) {
    return unavailable(null, `no endpoint: ${lookup.detail}`);
  }
  const first = await attempt(lookup.endpoint, options);
  if (first.classification !== 'service-unavailable' || first.transport === null) return first;

  // "A client reads the descriptor on connection and again after connection
  // failure." A second read only helps if Koine republished a new descriptor.
  const second = await readEndpoint();
  if (!second.found) return unavailable(lookup.endpoint, `no endpoint: ${second.detail}`);
  if (second.endpoint.url === lookup.endpoint.url) return first;
  return attempt(second.endpoint, options);
}

function unavailable(endpoint: Endpoint | null, transport: string): SendResult {
  return {
    classification: 'service-unavailable',
    endpoint: endpoint ? { url: endpoint.url, instanceId: endpoint.descriptor.instanceId } : null,
    http: null,
    response: null,
    errors: [],
    transport,
    outcomeUnknown: false,
    data: null,
  };
}

async function attempt(endpoint: Endpoint, options: SendOptions): Promise<SendResult> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    Accept: 'application/graphql-response+json',
  };
  if (options.secret !== undefined) {
    headers['Authorization'] = `Bearer ${options.secret}`;
  }

  const body = JSON.stringify({
    query: options.document,
    operationName: options.operationName,
    ...(options.variables ? { variables: options.variables } : {}),
  });

  const where = { url: endpoint.url, instanceId: endpoint.descriptor.instanceId };

  let response: Response;
  try {
    response = await fetch(endpoint.url, {
      method: 'POST',
      headers,
      body,
      redirect: 'error',
      signal: AbortSignal.timeout(options.timeoutMs ?? DEFAULT_TIMEOUT_MS),
    });
  } catch (cause) {
    const code = causeCode(cause);
    const sent = !NOT_SENT.has(code);
    if (options.kind === 'mutation' && sent) {
      return {
        classification: 'unknown-outcome',
        endpoint: where,
        http: null,
        response: null,
        errors: [],
        transport: `${code} after the request was written; the mutation may have run`,
        outcomeUnknown: true,
        data: null,
      };
    }
    return { ...unavailable(endpoint, `${code} contacting ${endpoint.url}`), endpoint: where };
  }

  let text: string;
  try {
    text = await response.text();
  } catch (cause) {
    const code = causeCode(cause);
    return {
      classification: options.kind === 'mutation' ? 'unknown-outcome' : 'service-unavailable',
      endpoint: where,
      http: httpFacts(response),
      response: null,
      errors: [],
      transport: `${code} while reading the response body`,
      outcomeUnknown: options.kind === 'mutation',
      data: null,
    };
  }

  let parsed: unknown = null;
  let parseFailed = false;
  if (text.length > 0) {
    try {
      parsed = JSON.parse(text);
    } catch {
      parsed = text;
      parseFailed = true;
    }
  }

  const graphql: GraphQLBody | null =
    !parseFailed && typeof parsed === 'object' && parsed !== null
      ? (parsed as GraphQLBody)
      : null;
  const http = httpFacts(response);
  const errors = (graphql?.errors ?? []).map(classifyExecutionError);

  let classification = classifyStatus(
    { status: http.status, retryAfterSeconds: http.retryAfterSeconds },
    graphql,
  );
  if (classification === null) {
    classification =
      errors.length > 0 ? mostSevere(errors.map((e) => e.classification)) : 'ok';
  }

  const data =
    graphql !== null && typeof graphql.data === 'object' && graphql.data !== null
      ? (graphql.data as Record<string, unknown>)
      : null;

  return {
    classification,
    endpoint: where,
    http,
    response: parsed,
    errors,
    transport: parseFailed ? 'response body was not JSON' : null,
    // The spec: a deadline or response cap answers HTTP 200 with kind `failed`
    // and "Neither says whether a requested action ran."
    outcomeUnknown: options.kind === 'mutation' && classification === 'failed',
    data,
  };
}

function httpFacts(response: Response): HttpFactsOut {
  const retryAfter = response.headers.get('retry-after');
  const seconds = retryAfter === null ? null : Number.parseInt(retryAfter, 10);
  return {
    status: response.status,
    contentType: response.headers.get('content-type'),
    cacheControl: response.headers.get('cache-control'),
    retryAfterSeconds: seconds !== null && Number.isFinite(seconds) ? seconds : null,
  };
}

/**
 * Distinguishes an ordinary absent result from a refusal: only a response with
 * no error at the root path and a null root value is absence.
 */
export function absentIfNullRoot(result: SendResult, rootField: string): Classification {
  if (result.classification !== 'ok') return result.classification;
  if (result.data === null) return 'ok';
  return result.data[rootField] === null ? 'absent' : 'ok';
}
