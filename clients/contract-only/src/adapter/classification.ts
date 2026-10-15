/**
 * Error classification, derived from "Errors and partial data" and "Local
 * transport and discovery" in the machine spec. The spec names the server-side
 * vocabulary (`extensions.kind` plus `extensions.permissionClass`) and names
 * two client-side transport states ("Transport unavailability and an unknown
 * mutation outcome are client transport states"); this module is the single
 * place where both halves become one closed set.
 */
export const CLASSIFICATIONS = [
  'ok',
  'absent',
  'capability-denied',
  'os-permission-denied',
  'unavailable',
  'unknown-provider',
  'failed',
  'request-error',
  'unauthenticated',
  'rate-limited',
  'service-unavailable',
  'unknown-outcome',
  // Added for the workspace launch path; see the README's classification section.
  'dependency-unavailable',
  'input-error',
] as const;

export type Classification = (typeof CLASSIFICATIONS)[number];

/**
 * Precedence when one response carries several execution errors. Permission
 * outranks everything because it is the only class the spec asks a client to
 * route to a different human action (ask Koine's owner for a capability, or
 * send the user to Koine's own UI for OS consent).
 */
const SEVERITY: readonly Classification[] = [
  'os-permission-denied',
  'capability-denied',
  'unauthenticated',
  'rate-limited',
  'request-error',
  'unknown-provider',
  'unavailable',
  'failed',
  'input-error',
  'unknown-outcome',
  'service-unavailable',
  'dependency-unavailable',
  'absent',
  'ok',
];

export function mostSevere(values: readonly Classification[]): Classification {
  let best: Classification = 'ok';
  let bestRank = SEVERITY.length;
  for (const value of values) {
    const rank = SEVERITY.indexOf(value);
    if (rank < bestRank) {
      bestRank = rank;
      best = value;
    }
  }
  return best;
}

export interface GraphQLErrorShape {
  readonly message?: unknown;
  readonly path?: unknown;
  readonly extensions?: Record<string, unknown> | undefined;
}

export interface GraphQLBody {
  readonly data?: unknown;
  readonly errors?: readonly GraphQLErrorShape[];
}

export interface ClassifiedError {
  readonly classification: Classification;
  readonly message: string;
  readonly path: readonly (string | number)[] | null;
  readonly kind: string | null;
  readonly permissionClass: string | null;
  /** The first unmet member of the field's ordered requirement set. */
  readonly requiredCapability: string | null;
  /**
   * The complete ordered set the failing field requires, as the server sent it
   * (never sorted, never reduced to the unmet members), or null when the error
   * carries none or carries something that is not a list of strings.
   */
  readonly requiredCapabilities: readonly string[] | null;
  /** `authorization` (preflight refused the whole operation) or `execution`. */
  readonly phase: string | null;
  readonly osPermission: string | null;
  readonly permissionOwner: string | null;
  /** Additive per the spec's management-outcome table; absent from other errors. */
  readonly reason: string | null;
  readonly requestState: string | null;
}

function str(value: unknown): string | null {
  return typeof value === 'string' ? value : null;
}

function strList(value: unknown): readonly string[] | null {
  if (!Array.isArray(value)) return null;
  return value.every((v) => typeof v === 'string') ? (value as string[]) : null;
}

/** Maps one execution error's `extensions` onto the client vocabulary. */
export function classifyExecutionError(error: GraphQLErrorShape): ClassifiedError {
  const ext = (error.extensions ?? {}) as Record<string, unknown>;
  const kind = str(ext['kind']);
  const permissionClass = str(ext['permissionClass']);

  let classification: Classification;
  switch (kind) {
    case 'permission':
      classification =
        permissionClass === 'os-permission' ? 'os-permission-denied' : 'capability-denied';
      break;
    case 'unavailable':
      classification = 'unavailable';
      break;
    case 'unknown-provider':
      classification = 'unknown-provider';
      break;
    case 'failed':
      classification = 'failed';
      break;
    case null:
      // "An error with a non-empty `path` and no `kind` is an input error a
      // provider found in an argument ... and nothing was attempted." With an
      // empty path and no kind the client guide says `failed`.
      classification =
        Array.isArray(error.path) && error.path.length > 0 ? 'input-error' : 'failed';
      break;
    default:
      // "A `kind` outside these four is not served by this contract; a client
      // that meets one ... classifies it as `failed`".
      classification = 'failed';
  }

  return {
    classification,
    message: str(error.message) ?? '',
    path: Array.isArray(error.path) ? (error.path as (string | number)[]) : null,
    kind,
    permissionClass,
    requiredCapability: str(ext['requiredCapability']),
    requiredCapabilities: strList(ext['requiredCapabilities']),
    phase: str(ext['phase']),
    osPermission: str(ext['osPermission']),
    permissionOwner: str(ext['permissionOwner']),
    reason: str(ext['reason']),
    requestState: str(ext['requestState']),
  };
}

export interface HttpFacts {
  readonly status: number;
  readonly retryAfterSeconds: number | null;
}

/**
 * HTTP status decides first, because the spec decides transport and
 * authentication before execution and those responses either carry no GraphQL
 * body or carry one whose `data` is absent.
 */
export function classifyStatus(http: HttpFacts, body: GraphQLBody | null): Classification | null {
  switch (http.status) {
    case 200:
      return null;
    case 429:
      return 'rate-limited';
    case 401:
      return 'unauthenticated';
    case 400:
    case 404:
    case 405:
    case 413:
    case 415:
    case 421:
      return 'request-error';
    case 403: {
      // Two different 403s: capability preflight (carries `errors`) and the
      // browser-Origin refusal (a transport error with no GraphQL body).
      const errors = body?.errors ?? [];
      if (errors.length > 0) {
        return mostSevere(errors.map((e) => classifyExecutionError(e).classification));
      }
      return 'request-error';
    }
    default:
      return http.status >= 500 ? 'failed' : 'request-error';
  }
}
