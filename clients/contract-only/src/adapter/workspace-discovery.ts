import type { Classification, ClassifiedError } from './classification.js';
import type { SendResult } from './transport.js';

/**
 * Reads one answer of `workspaceSpecialLocations` or `workspaceApplications`, whose results are
 * `WorkspaceSpecialLocationsResult` and `WorkspaceApplicationsResult` in
 * `docs/design/workspace-discovery-schema.graphql`. Both are reads: a request changes nothing, so
 * there is no action effect to report and a lost answer is simply a lost answer.
 *
 * What the contract says, and what this module therefore does:
 *
 * - `status` is the result's own word (`AVAILABLE`, `PARTIAL`, `UNKNOWN`, `BLOCKED`, `UNAVAILABLE`,
 *   `FAILED`) and is copied, never recomputed. `items` is a list or null, and null is not an empty
 *   list: an `UNKNOWN` answer has null items, so a client that needs "none" must not read null as
 *   it. The facts keep `items` null and add no length for it.
 * - `sources` is the coverage of each source: `observations` and `category` say whether the answer
 *   is complete, partial or unknown, and are copied with the diagnostics beside them. A result
 *   whose coverage is `UNKNOWN` is not a complete inventory, whatever its items hold.
 * - `FAILED` comes with an error at the `items` field. That error keeps its own classification,
 *   and the response keeps the most severe one; no error is dropped.
 * - A capability denial names the first unmet capability and the complete required set, which are
 *   copied as the server sent them.
 *
 * A response that breaks a rule the contract states (a null root with no error, a status that is
 * not in the enum, `AVAILABLE` or `PARTIAL` with null items and no error) is classified `failed`
 * with the rule named, so a client never reads it as an answer.
 */

export const LOCATIONS_ALIAS = 'locations';
export const APPLICATIONS_ALIAS = 'apps';
export type DiscoveryAlias = typeof LOCATIONS_ALIAS | typeof APPLICATIONS_ALIAS;

const STATUSES: readonly string[] = ['AVAILABLE', 'PARTIAL', 'UNKNOWN', 'BLOCKED', 'UNAVAILABLE', 'FAILED'];

export interface DiscoveryFacts {
  readonly classification: Classification;
  readonly status: string | null;
  /** The items exactly as served, or null: null is never an empty list. */
  readonly items: readonly unknown[] | null;
  readonly sources: readonly unknown[] | null;
  readonly resultsTruncated: boolean | null;
  readonly requiredCapability: string | null;
  readonly requiredCapabilities: readonly string[] | null;
  readonly phase: string | null;
  /** Paths of errors at or below the result. */
  readonly resultErrorPaths: readonly (readonly (string | number)[])[];
  /** Set when a response broke a rule the contract states; the classification is then `failed`. */
  readonly contractViolation: string | null;
}

type Json = Record<string, unknown>;

function isObject(value: unknown): value is Json {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

export function interpretDiscovery(result: SendResult, alias: DiscoveryAlias): DiscoveryFacts {
  const capability = result.errors.find((e: ClassifiedError) => e.classification === 'capability-denied');
  const denial = {
    requiredCapability: capability?.requiredCapability ?? null,
    requiredCapabilities: capability?.requiredCapabilities ?? null,
    phase: capability?.phase ?? null,
  };
  const empty = {
    status: null,
    items: null,
    sources: null,
    resultsTruncated: null,
    resultErrorPaths: [] as (readonly (string | number)[])[],
    contractViolation: null,
  };

  // Answers that never reached execution: the transport, an authentication or a preflight refusal.
  if (result.http === null || result.http.status !== 200) {
    return { ...empty, ...denial, classification: result.classification };
  }

  const root = result.data === null ? undefined : result.data[alias];
  const rootObject = isObject(root) ? root : null;
  const resultErrorPaths = result.errors
    .filter((e) => e.path !== null && e.path[0] === alias)
    .map((e) => e.path as readonly (string | number)[]);
  const statusNode = rootObject?.['status'];
  const status = typeof statusNode === 'string' ? statusNode : null;
  const itemsNode = rootObject?.['items'];
  const items = Array.isArray(itemsNode) ? (itemsNode as unknown[]) : null;
  const sourcesNode = rootObject?.['sources'];
  const sources = Array.isArray(sourcesNode) ? (sourcesNode as unknown[]) : null;
  const truncatedNode = rootObject?.['resultsTruncated'];
  const resultsTruncated = typeof truncatedNode === 'boolean' ? truncatedNode : null;
  const facts = { status, items, sources, resultsTruncated, resultErrorPaths, ...denial };

  const violate = (why: string): DiscoveryFacts => ({
    ...facts,
    classification: 'failed',
    contractViolation: why,
  });

  if (result.errors.length > 0) {
    // Errors are never dropped, and the response keeps the most severe class.
    return { ...facts, classification: result.classification, contractViolation: null };
  }
  if (rootObject === null) {
    return violate(
      root === null
        ? `the ${alias} root is null with no error, which the contract says cannot happen for this field`
        : `the response has no ${alias} result and no error`,
    );
  }
  if (status === null || !STATUSES.includes(status)) {
    return violate(`status ${JSON.stringify(statusNode)} is not a WorkspaceDiscoveryStatus`);
  }
  if ((status === 'AVAILABLE' || status === 'PARTIAL') && items === null) {
    return violate(`${status} without an error must carry items`);
  }
  if (sources === null) return violate('sources is not a list');
  return { ...facts, classification: 'ok', contractViolation: null };
}
