/**
 * Stub answers for `workspaceOpenURL`. The root returns the same
 * `WorkspaceOpenResult` as the launch root, so every shape is the launch table's,
 * with the URL root's own differences transcribed from the same documents:
 * the dependency reason is `NO_DEFAULT_HANDLER` ("Existing path or valid web URL has
 * no default opener ... no chooser/action"), and an invalid URL is an "Existing input
 * error at original response path, no `kind`; this field does not act". The spec's
 * "original response path" does not say whether that is the field's path or the
 * argument's, so both are stubbed. Nothing here is invented wire shape.
 */
import { PROCESS, capabilityError } from './launch-stubs.mjs';

export const ROOT = 'workspaceOpenURL';

const GUIDANCE = 'No default web browser is registered; choose one in System Settings, then open the URL again.';

const available = (process) => ({
  status: 200,
  body: { data: { [ROOT]: { status: 'AVAILABLE', value: { process }, dependency: null } } },
});

const dependency = (reason) => ({
  status: 200,
  body: {
    data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: { reason, guidance: GUIDANCE } } },
  },
});

export const OPEN_URL_ANSWERS = {
  // "URL submitted to the resolved default browser": a receipt with the browser's identity.
  'available-process': () => available(PROCESS),
  // "Exit, ambiguity or unreadable start time produces `process: null`".
  'available-null-process': () => available(null),

  // "Existing path or valid web URL has no default opener | Dependency NO_DEFAULT_HANDLER; no chooser/action."
  'dependency-no-default-handler': () => dependency('NO_DEFAULT_HANDLER'),

  // "Missing/revoked client authority": whole-mutation preflight, HTTP 403, errors and no data, the denied
  // action's response path, phase authorization; the complete set in the spec's order, never sorted.
  'denied-lacks-workspace': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'workspace:control', 'authorization')] },
  }),
  'denied-lacks-desktop': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'desktop:control', 'authorization')] },
  }),
  'denied-lacks-both': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'workspace:control', 'authorization')] },
  }),
  'denied-revoked-before-dispatch': () => ({
    status: 200,
    body: {
      data: { [ROOT]: null },
      errors: [capabilityError([ROOT], 'workspace:control', 'execution')],
    },
  }),

  // "Native error/false acknowledgment, timeout ... after submission: failed; effects may have begun; no replay."
  'failed-at-action': () => ({
    status: 200,
    body: {
      data: { [ROOT]: null },
      errors: [{ message: 'native open failed', path: [ROOT], extensions: { kind: 'failed' } }],
    },
  }),
  'failed-deadline': () => ({
    status: 200,
    body: { data: null, errors: [{ message: 'deadline', path: [], extensions: { kind: 'failed' } }] },
  }),

  // "Invalid input ...: Existing input error at original response path, no `kind`; this field does not act."
  // The field's path ...
  'input-error': () => ({
    status: 200,
    body: { data: { [ROOT]: null }, errors: [{ message: 'url is not an absolute HTTP(S) URI', path: [ROOT] }] },
  }),
  // ... or the argument's.
  'input-error-argument-path': () => ({
    status: 200,
    body: { data: { [ROOT]: null }, errors: [{ message: 'url is not an absolute HTTP(S) URI', path: [ROOT, 'url'] }] },
  }),

  // Publication denial (phase execution) at each field; the published status stays authoritative.
  'suppressed-value': () => ({
    status: 200,
    body: {
      data: { [ROOT]: { status: 'AVAILABLE', value: null, dependency: null } },
      errors: [capabilityError([ROOT, 'value'], 'workspace:control', 'execution')],
    },
  }),
  'suppressed-process': () => ({
    status: 200,
    body: {
      data: { [ROOT]: { status: 'AVAILABLE', value: { process: null }, dependency: null } },
      errors: [capabilityError([ROOT, 'value', 'process'], 'desktop:control', 'execution')],
    },
  }),
  'suppressed-dependency': () => ({
    status: 200,
    body: {
      data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: null } },
      errors: [capabilityError([ROOT, 'dependency'], 'workspace:control', 'execution')],
    },
  }),
  'suppressed-status': () => ({
    status: 200,
    body: {
      data: { [ROOT]: null },
      errors: [capabilityError([ROOT, 'status'], 'desktop:control', 'execution')],
    },
  }),

  // What the contract says cannot happen.
  'violation-null-root': () => ({ status: 200, body: { data: { [ROOT]: null } } }),
  'violation-both-branches': () => ({
    status: 200,
    body: {
      data: {
        [ROOT]: {
          status: 'AVAILABLE',
          value: { process: null },
          dependency: { reason: 'NO_DEFAULT_HANDLER', guidance: 'x' },
        },
      },
    },
  }),
  'violation-not-a-response': () => ({ status: 200, body: 'not a graphql response' }),
  'violation-dependency-missing': () => ({
    status: 200,
    body: { data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: null } } },
  }),
  // The launch root's answer arriving for the URL root: the field asked for is absent.
  'violation-wrong-root': () => ({
    status: 200,
    body: { data: { workspaceLaunchApplication: { status: 'AVAILABLE', value: { process: null }, dependency: null } } },
  }),
};
