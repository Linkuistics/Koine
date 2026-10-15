import type { Classification, ClassifiedError } from './classification.js';
import type { SendResult } from './transport.js';
import type { ActionEffect } from './workspace-open.js';

/**
 * Reads one answer of `workspaceRevealPath`, whose result is `WorkspaceRevealResult`.
 * It is the same contract as the open roots' (status `AVAILABLE` or
 * `DEPENDENCY_UNAVAILABLE`, exactly one of `value` and `dependency` absent an error,
 * a published status authoritative when an error suppresses its branch, a null root
 * never absence, a dependency certifying that this action submitted nothing), with
 * two differences this module is the single place to apply:
 *
 * - The receipt is `{ path }`, "Submitted absolute path", echoed. There is no process
 *   and nothing to hand to a desktop read. The echo is copied, never compared with
 *   what was sent, normalised or resolved: the contract promises the submitted path
 *   and this client reports what it was given.
 * - `AVAILABLE` is "Finder acknowledgment ... selection is not independently
 *   observed" and "Native acknowledgment is not observed selection". `acknowledged`
 *   here therefore never means "the item is selected", and the facts say so in the
 *   field's name: `selectionObserved` is always false, because nothing in the
 *   contract could make it true.
 *
 * Dependency reasons for this root are `PATH_NOT_FOUND` and `APPLICATION_NOT_INSTALLED`
 * (Finder). Each is copied verbatim with its guidance, the effect is `none`, and
 * neither is turned into a claim about the world: "nothing was submitted", never "the
 * path does not exist" or "Finder is not installed". `failed` is "effects may have
 * begun; no replay": a false acknowledgment, the three-second bound, cancellation, or
 * a lost prerequisite.
 */

export const REVEAL_ROOT = 'workspaceRevealPath';

/** The fields of `WorkspaceRevealResult`: an error below one of these is below the result, not the action's own. */
const RESULT_FIELDS: readonly string[] = ['status', 'value', 'dependency'];

export interface WorkspaceRevealFacts {
  readonly classification: Classification;
  readonly status: string | null;
  readonly actionEffect: ActionEffect;
  readonly outcomeUnknown: boolean;
  /** The echoed path, or null when there is no receipt. */
  readonly receipt: { readonly path: string } | null;
  /** Always false: Finder's acknowledgment is the whole of what the contract offers. */
  readonly selectionObserved: false;
  readonly dependency: { readonly reason: string; readonly guidance: string } | null;
  readonly requiredCapability: string | null;
  readonly requiredCapabilities: readonly string[] | null;
  readonly phase: string | null;
  /** Paths of errors at or below the result. */
  readonly resultErrorPaths: readonly (readonly (string | number)[])[];
  /** The published status selected a branch that an error left null. */
  readonly branchSuppressed: boolean;
  /** Set when a response broke a rule the contract states; the classification is then `failed`. */
  readonly contractViolation: string | null;
}

type Json = Record<string, unknown>;

function isObject(value: unknown): value is Json {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function under(error: ClassifiedError, prefix: readonly (string | number)[]): boolean {
  const path = error.path;
  if (path === null || path.length < prefix.length) return false;
  return prefix.every((segment, i) => path[i] === segment);
}

export function interpretReveal(result: SendResult): WorkspaceRevealFacts {
  const base = {
    receipt: null,
    selectionObserved: false as const,
    dependency: null,
    requiredCapability: null,
    requiredCapabilities: null,
    phase: null,
    resultErrorPaths: [] as (readonly (string | number)[])[],
    branchSuppressed: false,
    contractViolation: null,
    status: null,
  };
  const capability = result.errors.find((e) => e.classification === 'capability-denied');
  const capabilityFacts = {
    requiredCapability: capability?.requiredCapability ?? null,
    requiredCapabilities: capability?.requiredCapabilities ?? null,
    phase: capability?.phase ?? null,
  };

  // Answers that never reached execution, or were lost on the way back.
  if (result.http === null) {
    const lost = result.classification === 'unknown-outcome';
    return {
      ...base,
      classification: result.classification,
      actionEffect: lost ? 'unknown' : 'none',
      outcomeUnknown: lost,
    };
  }
  if (result.http.status !== 200) {
    // 401, 400, 404..421, 429: "Nothing ran". 403 with errors is preflight refusal of the
    // whole operation, also before any action. A 5xx is outside the contract.
    const outsideContract = result.http.status >= 500;
    return {
      ...base,
      ...capabilityFacts,
      classification: result.classification,
      actionEffect: outsideContract ? 'unknown' : 'none',
      outcomeUnknown: outsideContract,
    };
  }

  const data = result.data;
  const root = data === null ? undefined : data[REVEAL_ROOT];
  const rootObject = isObject(root) ? root : null;
  const resultErrors = result.errors.filter((e) => e.path !== null && e.path[0] === REVEAL_ROOT);
  const resultErrorPaths = resultErrors.map((e) => e.path as readonly (string | number)[]);

  const status = rootObject !== null && typeof rootObject['status'] === 'string' ? rootObject['status'] : null;
  const valueNode = rootObject?.['value'];
  const receiptObject = isObject(valueNode) ? valueNode : null;
  const pathNode = receiptObject?.['path'];
  const dependencyNode = rootObject?.['dependency'];
  const dependencyObject = isObject(dependencyNode) ? dependencyNode : null;
  const dependency =
    dependencyObject !== null &&
    typeof dependencyObject['reason'] === 'string' &&
    typeof dependencyObject['guidance'] === 'string'
      ? { reason: dependencyObject['reason'], guidance: dependencyObject['guidance'] }
      : null;

  const violate = (why: string): WorkspaceRevealFacts => ({
    ...base,
    ...capabilityFacts,
    status,
    resultErrorPaths,
    classification: 'failed',
    actionEffect: 'unknown',
    outcomeUnknown: true,
    contractViolation: why,
  });

  // `path` is `String!`: a receipt without a string path is not a receipt.
  if (receiptObject !== null && typeof pathNode !== 'string' && !result.errors.some((e) => under(e, [REVEAL_ROOT, 'value', 'path']))) {
    return violate('receipt.path is not a String');
  }
  const receipt = receiptObject !== null && typeof pathNode === 'string' ? { path: pathNode } : null;

  const facts = {
    status,
    receipt,
    selectionObserved: false as const,
    dependency,
    ...capabilityFacts,
    resultErrorPaths,
  };

  if (result.errors.length > 0) {
    // Errors are never dropped, and the response keeps the most severe class. The status, if
    // one was published, still says what the action did.
    let actionEffect: ActionEffect;
    if (status === 'AVAILABLE') actionEffect = 'acknowledged';
    else if (status === 'DEPENDENCY_UNAVAILABLE') actionEffect = 'none';
    else {
      // An error at the action's own path, or an input error at one of its arguments (the root
      // plus the argument name): "this field does not act". An error at a result field is
      // below the result, not the action's own.
      const own = resultErrors.filter(
        (e) =>
          e.path?.length === 1 ||
          (e.classification === 'input-error' &&
            e.path !== null &&
            e.path.length > 1 &&
            !RESULT_FIELDS.includes(String(e.path[1]))),
      );
      if (own.some((e) => e.classification === 'failed')) actionEffect = 'may-have-begun';
      else if (
        own.length > 0 &&
        own.every((e) => ['capability-denied', 'os-permission-denied', 'input-error'].includes(e.classification))
      ) {
        actionEffect = 'none';
      } else actionEffect = 'unknown';
    }
    const branchSuppressed =
      (status === 'AVAILABLE' && receipt === null) || (status === 'DEPENDENCY_UNAVAILABLE' && dependency === null);
    return {
      ...facts,
      classification: result.classification,
      actionEffect,
      outcomeUnknown:
        actionEffect === 'may-have-begun' || actionEffect === 'unknown' || result.classification === 'failed',
      branchSuppressed,
      contractViolation: null,
    };
  }

  // No error anywhere: the exclusive-branch invariant must hold exactly.
  if (rootObject === null) {
    return violate(
      root === null
        ? `the ${REVEAL_ROOT} root is null with no error, which the contract says cannot happen for this field (it is not absence)`
        : `the response has no ${REVEAL_ROOT} result and no error`,
    );
  }
  if (status === 'AVAILABLE') {
    if (receipt === null || dependencyNode !== null) return violate('AVAILABLE without an error must have value only');
    return {
      ...facts,
      classification: 'ok',
      actionEffect: 'acknowledged',
      outcomeUnknown: false,
      branchSuppressed: false,
      contractViolation: null,
    };
  }
  if (status === 'DEPENDENCY_UNAVAILABLE') {
    if (dependency === null || (valueNode !== null && valueNode !== undefined)) {
      return violate('DEPENDENCY_UNAVAILABLE without an error must have dependency only');
    }
    return {
      ...facts,
      classification: 'dependency-unavailable',
      actionEffect: 'none',
      outcomeUnknown: false,
      branchSuppressed: false,
      contractViolation: null,
    };
  }
  return violate(`status ${JSON.stringify(rootObject['status'])} is not AVAILABLE or DEPENDENCY_UNAVAILABLE`);
}
