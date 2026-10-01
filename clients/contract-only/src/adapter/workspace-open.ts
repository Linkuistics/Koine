import type { Classification, ClassifiedError } from './classification.js';
import type { SendResult } from './transport.js';

/**
 * Reads one answer of a workspace root that returns `WorkspaceOpenResult`
 * (`workspaceLaunchApplication`, `workspaceOpenURL`; the spec gives them one result
 * type, one invariant and one failure table, so one reading serves both, told only
 * which root it is reading). The contract's rules, which this module is the single
 * place to apply:
 *
 * - `status` is `AVAILABLE` or `DEPENDENCY_UNAVAILABLE`. Absent an error at or
 *   below the result, exactly one of `value` and `dependency` is non-null,
 *   selected by status. "A published status remains authoritative if an error
 *   suppresses its branch; a null branch with an error is not a different
 *   operation outcome." Non-null propagation can remove the status or the whole
 *   result.
 * - "A null root always has an execution/input error for these four fields": a
 *   null root with no error is never absence here.
 * - A dependency result "certifies that this action submitted no domain request".
 * - `AVAILABLE` "means native acknowledgment", not that anything rendered.
 * - `failed`: "effects may have begun; no replay". Preflight refusal happens
 *   before any action.
 */

/** The two roots this reading is applied to. */
export type WorkspaceOpenRoot = 'workspaceLaunchApplication' | 'workspaceOpenURL';

/** The fields of `WorkspaceOpenResult`: an error below one of these is below the result, not the action's own. */
const RESULT_FIELDS: readonly string[] = ['status', 'value', 'dependency'];

export type ActionEffect =
  /** This action submitted nothing: dependency result, input error, refusal before dispatch. */
  | 'none'
  /** Native acknowledgment was published as the status. Not proof of rendering or focus. */
  | 'acknowledged'
  /** `failed` at the action's own path: effects may have begun. */
  | 'may-have-begun'
  /** The response cannot say (deadline, propagation removed the status, broken invariant, lost answer). */
  | 'unknown';

export type ProcessState =
  /** The receipt carried an identity. */
  | 'present'
  /** The receipt is there and its `process` is null: exit, ambiguity, unreadable start time or a mismatch. Not a failed launch. */
  | 'null-in-receipt'
  /** An error suppressed the receipt or its `process`: unknown, not absent. */
  | 'suppressed'
  /** There is no receipt at all (dependency result, failure, refusal, lost answer). */
  | 'no-receipt';

export interface WorkspaceOpenFacts {
  readonly classification: Classification;
  readonly status: string | null;
  readonly actionEffect: ActionEffect;
  readonly outcomeUnknown: boolean;
  readonly receipt: { readonly process: ProcessIdentityOut | null } | null;
  readonly process: ProcessIdentityOut | null;
  readonly processState: ProcessState;
  /** Arguments that hand `process` to `choices` unchanged, or null. */
  readonly choicesArguments: readonly string[] | null;
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

export interface ProcessIdentityOut {
  readonly pid: number;
  readonly startedAt: string;
}

type Json = Record<string, unknown>;

function isObject(value: unknown): value is Json {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function processOf(value: unknown): ProcessIdentityOut | 'malformed' | null {
  if (value === null || value === undefined) return null;
  if (!isObject(value)) return 'malformed';
  const { pid, startedAt } = value;
  if (typeof pid !== 'number' || !Number.isInteger(pid) || pid <= 0) return 'malformed';
  if (typeof startedAt !== 'string') return 'malformed';
  // Copied, never parsed or normalised: the contract says to pass both unchanged.
  return { pid, startedAt };
}

function under(error: ClassifiedError, prefix: readonly (string | number)[]): boolean {
  const path = error.path;
  if (path === null || path.length < prefix.length) return false;
  return prefix.every((segment, i) => path[i] === segment);
}

export function interpretWorkspaceOpen(result: SendResult, rootName: WorkspaceOpenRoot): WorkspaceOpenFacts {
  const base = {
    receipt: null,
    process: null,
    processState: 'no-receipt' as ProcessState,
    choicesArguments: null,
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
    // 401, 400, 404..421, 429: "Nothing ran". 403 with errors is preflight
    // refusal of the whole operation, also before any action. A 5xx is outside
    // the contract; nothing says whether it ran.
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
  const root = data === null ? undefined : data[rootName];
  const rootObject = isObject(root) ? root : null;
  const resultErrors = result.errors.filter((e) => e.path !== null && e.path[0] === rootName);
  const resultErrorPaths = resultErrors.map((e) => e.path as readonly (string | number)[]);

  const status = rootObject !== null && typeof rootObject['status'] === 'string' ? rootObject['status'] : null;
  const valueNode = rootObject?.['value'];
  const receiptObject = isObject(valueNode) ? valueNode : null;
  const processParsed = processOf(receiptObject?.['process']);
  const dependencyNode = rootObject?.['dependency'];
  const dependencyObject = isObject(dependencyNode) ? dependencyNode : null;
  const dependency =
    dependencyObject !== null &&
    typeof dependencyObject['reason'] === 'string' &&
    typeof dependencyObject['guidance'] === 'string'
      ? { reason: dependencyObject['reason'], guidance: dependencyObject['guidance'] }
      : null;

  const violate = (why: string): WorkspaceOpenFacts => ({
    ...base,
    ...capabilityFacts,
    status,
    resultErrorPaths,
    classification: 'failed',
    actionEffect: 'unknown',
    outcomeUnknown: true,
    contractViolation: why,
  });

  if (processParsed === 'malformed') {
    return violate('receipt.process is not {pid: positive Int, startedAt: String} or null');
  }
  const process = processParsed;

  const receipt = receiptObject === null ? null : { process };
  let processState: ProcessState;
  if (process !== null) processState = 'present';
  else if (receipt !== null) {
    processState = result.errors.some((e) => under(e, [rootName, 'value', 'process']))
      ? 'suppressed'
      : 'null-in-receipt';
  } else if (status === 'AVAILABLE') processState = 'suppressed';
  else processState = 'no-receipt';

  const facts = {
    status,
    receipt,
    process,
    processState,
    choicesArguments:
      process === null ? null : ['--pid', String(process.pid), '--started-at', process.startedAt],
    dependency,
    ...capabilityFacts,
    resultErrorPaths,
  };

  if (result.errors.length > 0) {
    // Errors are never dropped, and the response keeps the most severe class. The
    // status, if one was published, still says what the action did.
    let actionEffect: ActionEffect;
    if (status === 'AVAILABLE') actionEffect = 'acknowledged';
    else if (status === 'DEPENDENCY_UNAVAILABLE') actionEffect = 'none';
    else {
      // An error at the action's own path, or an input error at one of its
      // arguments (a path of the root plus the argument name): "this field does not
      // act". An error at a result field is below the result, not the action's own.
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
        own.every((e) =>
          ['capability-denied', 'os-permission-denied', 'input-error'].includes(e.classification),
        )
      ) {
        // The action's own refusal: a grant revoked before dispatch ("that action
        // cannot start") or an argument the provider found invalid ("this field
        // does not act").
        actionEffect = 'none';
      } else actionEffect = 'unknown';
    }
    const branchSuppressed =
      (status === 'AVAILABLE' && receipt === null) ||
      (status === 'DEPENDENCY_UNAVAILABLE' && dependency === null);
    return {
      ...facts,
      classification: result.classification,
      actionEffect,
      outcomeUnknown:
        actionEffect === 'may-have-begun' ||
        actionEffect === 'unknown' ||
        result.classification === 'failed',
      branchSuppressed,
      contractViolation: null,
    };
  }

  // No error anywhere: the exclusive-branch invariant must hold exactly.
  if (rootObject === null) {
    return violate(
      root === null
        ? `the ${rootName} root is null with no error, which the contract says cannot happen for this field (it is not absence)`
        : `the response has no ${rootName} result and no error`,
    );
  }
  if (status === 'AVAILABLE') {
    if (receipt === null || dependencyNode !== null) {
      return violate('AVAILABLE without an error must have value only');
    }
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

export function interpretLaunch(result: SendResult): WorkspaceOpenFacts {
  return interpretWorkspaceOpen(result, 'workspaceLaunchApplication');
}

export function interpretOpenURL(result: SendResult): WorkspaceOpenFacts {
  return interpretWorkspaceOpen(result, 'workspaceOpenURL');
}
